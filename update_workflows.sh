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

    for image in "${images[@]}"; do
        # Get the list of sysexts for a given target
        sysexts=()
        for s in $(git ls-tree -d --name-only HEAD | grep -Ev ".github|.workflow-templates"); do
            pushd "${s}" > /dev/null
            # Only require the architecture to be explicitly listed for non x86_64 for now
            if [[ "${arch}" == "x86_64" ]]; then
                if [[ $(just targets | grep -c "${image}") == "1" ]]; then
                    sysexts+=("${s}")
                fi
            else
                if [[ $(just targets | grep -cE "${image} .*${arch}.*") == "1" ]]; then
                    sysexts+=("${s}")
                fi
            fi
            popd > /dev/null
        done

        if [[ "${image}" == "quay.io/fedora-ostree-desktops/base-atomic:41" ]]; then
            sysexts_fedora_41=("${sysexts[@]}")
        fi
        if [[ "${image}" == "quay.io/fedora-ostree-desktops/base-atomic:42" ]]; then
            sysexts_fedora_42=("${sysexts[@]}")
        fi
        if [[ "${image}" == "quay.io/fedora/fedora-coreos:stable" ]]; then
            sysexts_fedora_coreos_stable=("${sysexts[@]}")
        fi
        if [[ "${image}" == "quay.io/fedora/fedora-coreos:next" ]]; then
            sysexts_fedora_coreos_next=("${sysexts[@]}")
        fi
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
        jobname=""
        if [[ "${image}" == "quay.io/fedora-ostree-desktops/base-atomic:41" ]]; then
            jobname="fedora-41"
            sysexts=("${sysexts_fedora_41[@]}")
        fi
        if [[ "${image}" == "quay.io/fedora-ostree-desktops/base-atomic:42" ]]; then
            jobname="fedora-42"
            sysexts=("${sysexts_fedora_42[@]}")
        fi
        if [[ "${image}" == "quay.io/fedora/fedora-coreos:stable" ]]; then
            jobname="fedora-coreos-stable"
            sysexts=("${sysexts_fedora_coreos_stable[@]}")
        fi
        if [[ "${image}" == "quay.io/fedora/fedora-coreos:next" ]]; then
            jobname="fedora-coreos-next"
            sysexts=("${sysexts_fedora_coreos_next[@]}")
        fi

        sed -e "s|%%JOBNAME%%|${jobname}|g" \
            -e "s|%%IMAGE%%|${image}|g" \
            "${tmpl}/10_sysexts_build_header"
        echo ""
        for s in "${sysexts[@]}"; do
            sed "s|%%SYSEXT%%|${s}|g" "${tmpl}/15_sysexts_build"
            echo ""
        done
    done

    # TODO
    cat "${tmpl}/20_sysexts_gather_header"

    for image in "${images[@]}"; do
        if [[ "${image}" == "quay.io/fedora-ostree-desktops/base-atomic:41" ]]; then
            sysexts=("${sysexts_fedora_41[@]}")
        fi
        if [[ "${image}" == "quay.io/fedora-ostree-desktops/base-atomic:42" ]]; then
            sysexts=("${sysexts_fedora_42[@]}")
        fi
        if [[ "${image}" == "quay.io/fedora/fedora-coreos:stable" ]]; then
            sysexts=("${sysexts_fedora_coreos_stable[@]}")
        fi
        if [[ "${image}" == "quay.io/fedora/fedora-coreos:next" ]]; then
            sysexts=("${sysexts_fedora_coreos_next[@]}")
        fi

        echo ""
        for s in "${sysexts[@]}"; do
            sed -e "s|%%SYSEXT%%|${s}|g" "${tmpl}/25_sysexts_gather"
            echo ""
        done
    done

    cat "${tmpl}/30_sysexts_latest"
    } > ".github/workflows/sysexts-fedora-${arch}.yml"
}

main "${@}"
