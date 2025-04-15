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

    Remove all existing worflows
    rm -f "./.github/workflows/containers"*".yml"
    rm "./.github/workflows/sysexts"*".yml"

    generate "x86-64"
    generate "aarch64"
}

generate() {

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

    for image in "${images[@]}"; do
        # Get the list of sysexts for a given target
        sysexts=()
        for s in $(git ls-tree -d --name-only HEAD | grep -Ev ".github|.workflow-templates"); do
            pushd "${s}" > /dev/null
            # Only require the architecture to be explicitly listed for non x86_64 for now
            if [[ "${arch}" == "x86_64" ]]; then
                if [[ $(just targets | grep -c "${image}:${release}") == "1" ]]; then
                    sysexts+=("${s}")
                fi
            else
                if [[ $(just targets | grep -cE "${image}:${release} .*${arch}.*") == "1" ]]; then
                    sysexts+=("${s}")
                fi
            fi
            popd > /dev/null
        done
        echo "${sysexts}"
    done

    exit 0

    local -r tmpl=".workflow-templates/"
    if [[ ! -d "${tmpl}" ]]; then
        echo "Could not find the templates. Is this script run from the root of the repo?"
        exit 1
    fi

    jobname="fedora-41"
    image="quay.io/fedora-ostree-desktops/base-atomic:41"


    # Generate EROFS sysexts workflows
    {
    cat "${tmpl}/00_sysexts_header"

    sed -e "s|%%JOBNAME%%|${jobname}|g" \
        "${tmpl}/10_sysexts_build_x86-64"

    echo ""
    for s in "${sysexts_x86_64[@]}"; do
        sed -e "s|%%IMAGE%%|${image}|g" \
            -e "s|%%SYSEXT%%|${s}|g" "${tmpl}/15_sysexts_build"
        echo ""
    done

    sed -e "s|%%SHORTNAME%%|${shortname}|g" \
        "${tmpl}/11_sysexts_build_aarch64"

    echo ""
    for s in "${sysexts_aarch64[@]}"; do
        sed "s|%%SYSEXT%%|${s}|g" "${tmpl}/15_sysexts_build"
        echo ""
    done

    cat "${tmpl}/20_sysexts_gather_pre"

    echo ""
    for s in "${sysexts_x86_64[@]}"; do
        sed "s|%%SYSEXT%%|${s}|g" "${tmpl}/21_sysexts_gather"
        echo ""
    done

    cat "${tmpl}/30_sysexts_latest"
    } > ".github/workflows/sysexts-${jobname}.yml"
}

main "${@}"
