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
    # rm -f "./.github/workflows/containers"*".yml"
    # rm "./.github/workflows/sysexts"*".yml"

    generate \
        'quay.io/fedora-ostree-desktops/base-atomic:41' \
        'Fedora 41' \
        'fedora-41'

    generate \
        'quay.io/fedora-ostree-desktops/base-atomic:42' \
        'Fedora 42' \
        'fedora-42'

    # generate \
    #     'quay.io/fedora/fedora-coreos:stable' \
    #     'Fedora CoreOS (stable)'
    #
    # generate \
    #     'quay.io/fedora/fedora-coreos:next' \
    #     'Fedora CoreOS (next)'

    # generate \
    #     'quay.io/fedora-ostree-desktops/silverblue' \
    #     '41' \
    #     'Fedora Silverblue'

    # generate \
    #     'quay.io/fedora-ostree-desktops/silverblue' \
    #     '42' \
    #     'Fedora Silverblue'

    # generate \
    #     'quay.io/fedora-ostree-desktops/kinoite' \
    #     '41' \
    #     'Fedora Kinoite'

    # generate \
    #     'quay.io/fedora-ostree-desktops/kinoite' \
    #     '42' \
    #     'Fedora Kinoite'
}

generate() {
    local -r image="${1}"
    local -r name="${2}"
    local -r jobname="${3}"

    # Get the list of sysexts for a given target
    sysexts=(
        '1password-cli'
        '1password-gui'
        'bitwarden'
        'cilium-cli'
        'cloud-hypervisor'
        'docker-ce'
        'google-chrome'
        'incus'
        'microsoft-edge'
        'mullvad-vpn'
        'virtctl'
        'vscode'
        'vscodium'
        'wasmtime'
        'youki'
    )
    # for s in $(git ls-tree -d --name-only HEAD | grep -Ev ".github|templates"); do
    #     pushd "${s}" > /dev/null
    #     # TODO: Only require the architecture to be explicitly listed for non x86_64 for now
    #     if [[ $(just targets | grep -c "${image}") == "1" ]]; then
    #         sysexts+=("${s}")
    #     fi
    #     popd > /dev/null
    # done

    local -r tmpl=".workflow-templates/"
    if [[ ! -d "${tmpl}" ]]; then
        echo "Could not find the templates. Is this script run from the root of the repo?"
        exit 1
    fi

    # Generate EROFS sysexts workflows
    {
    sed -e "s|%%IMAGE%%|${image}|g" \
        -e "s|%%NAME%%|${name}|g" \
        "${tmpl}/00_sysexts_header"

    cat "${tmpl}/10_sysexts_build_x86-64"

    echo ""
    for s in "${sysexts[@]}"; do
        sed "s|%%SYSEXT%%|${s}|g" "${tmpl}/15_sysexts_build"
        echo ""
    done

    cat "${tmpl}/11_sysexts_build_aarch64"

    echo ""
    for s in "${sysexts[@]}"; do
        sed "s|%%SYSEXT%%|${s}|g" "${tmpl}/15_sysexts_build"
        echo ""
    done

    cat "${tmpl}/20_sysexts_gather_pre"

    echo ""
    for s in "${sysexts[@]}"; do
        sed "s|%%SYSEXT%%|${s}|g" "${tmpl}/21_sysexts_gather"
        echo ""
    done

    cat "${tmpl}/30_sysexts_latest"
    } > ".github/workflows/sysexts-${jobname}.yml"
}

main "${@}"
