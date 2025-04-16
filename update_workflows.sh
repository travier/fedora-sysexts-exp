#!/bin/bash

# Re-generate the GitHub workflows based on templates. We do not use a matrix
# build strategy in GitHub worflows to reduce overall build time and avoid
# pulling the same base container image multiple time, once for each individual
# job.

set -euo pipefail
# set -x

main() {
    if [[ ! -d .github ]] || [[ ! -d .git ]]; then
        echo "This script must be run at the root of the repo"
        exit 1
    fi

    # Remove all existing worflows
    rm -f "./.github/workflows/containers"*".yml"
    rm -f "./.github/workflows/sysexts"*".yml"

    generate "x86_64"
    generate "aarch64"
}

# Generate EROFS sysexts workflows
generate() {
    local arch="${1}"

    images=(
        'quay.io/fedora-ostree-desktops/base-atomic:41'
        'quay.io/fedora-ostree-desktops/base-atomic:42'
        'quay.io/fedora/fedora-coreos:stable'
        'quay.io/fedora/fedora-coreos:next'
    )
    # 'quay.io/fedora-ostree-desktops/silverblue:41'
    # 'quay.io/fedora-ostree-desktops/silverblue:42'
    # 'quay.io/fedora-ostree-desktops/kinoite:41'
    # 'quay.io/fedora-ostree-desktops/kinoite:42'

    # Set jobnames
    declare -A jobnames
    jobnames["quay.io/fedora-ostree-desktops/base-atomic:41"]="fedora-41"
    jobnames["quay.io/fedora-ostree-desktops/base-atomic:42"]="fedora-42"
    jobnames["quay.io/fedora/fedora-coreos:stable"]="fedora-coreos-stable"
    jobnames["quay.io/fedora/fedora-coreos:next"]="fedora-coreos-next"

    # Get the list of sysexts for each target
    declare -A sysexts
    for image in "${images[@]}"; do
        list=()
        for s in $(git ls-tree -d --name-only HEAD | grep -Ev ".github|.workflow-templates"); do
            pushd "${s}" > /dev/null
            # Only require the architecture to be explicitly listed for non x86_64 for now
            if [[ "${arch}" == "x86_64" ]]; then
                if [[ $(just targets | grep -c "${image}") == "1" ]]; then
                    list+=("${s}")
                fi
            else
                if [[ $(just targets | grep -cE "${image} .*${arch}.*") == "1" ]]; then
                    list+=("${s}")
                fi
            fi
            popd > /dev/null
        done
        sysexts["${image}"]="$(echo "${list[@]}" | tr ' ' ';')"
    done

    local -r tmpl=".workflow-templates/"
    if [[ ! -d "${tmpl}" ]]; then
        echo "Could not find the templates. Is this script run from the root of the repo?"
        exit 1
    fi

    if [[ "${arch}" == "x86_64" ]]; then
        arch="x86-64"
    fi

    releaseurl="https://github.com/travier/fedora-sysexts-exp/releases/download"

    {
    sed -e "s|%%ARCH%%|${arch}|g" \
        -e "s|%%RELEASEURL%%|${releaseurl}|g" \
        "${tmpl}/00_sysexts_header"

    for image in "${images[@]}"; do
        sed -e "s|%%JOBNAME%%|${jobnames["${image}"]}|g" \
            -e "s|%%IMAGE%%|${image}|g" \
            "${tmpl}/10_sysexts_build_header"
        echo ""
        for s in $(echo "${sysexts["${image}"]}" | tr ';' ' '); do
            sed "s|%%SYSEXT%%|${s}|g" "${tmpl}/15_sysexts_build"
            echo ""
        done
    done

    # TODO: Dynamic list of jobs to depend on
    cat "${tmpl}/20_sysexts_gather_header"

    all_sysexts=()
    for image in "${images[@]}"; do
        for s in $(echo "${sysexts["${image}"]}" | tr ';' ' '); do
            all_sysexts+=("${s}")
        done
    done
    IFS=" " read -r -a uniq_sysexts <<< "$(echo "${all_sysexts[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
    echo ""
    for s in "${uniq_sysexts[@]}"; do
        sed -e "s|%%SYSEXT%%|${s}|g" "${tmpl}/25_sysexts_gather"
        echo ""
    done

    cat "${tmpl}/30_sysexts_latest"
    } > ".github/workflows/sysexts-fedora-${arch}.yml"

    # Fixup runs-on for aarch64
    if [[ "${arch}" == "aarch64" ]]; then
        sed -i "s/ubuntu-24.04/ubuntu-24.04-arm/g" ".github/workflows/sysexts-fedora-${arch}.yml"
    fi
}

main "${@}"
