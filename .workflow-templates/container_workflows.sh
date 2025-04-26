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

    generate \
        'quay.io/fedora/fedora-coreos' \
        'stable' \
        'x86_64' \
        'Fedora CoreOS'

    generate \
        'quay.io/fedora/fedora-coreos' \
        'stable' \
        'aarch64' \
        'Fedora CoreOS'

    generate \
        'quay.io/fedora/fedora-coreos' \
        'next' \
        'x86_64' \
        'Fedora CoreOS'

    generate \
        'quay.io/fedora/fedora-coreos' \
        'next' \
        'aarch64' \
        'Fedora CoreOS'

    generate \
        'quay.io/fedora-ostree-desktops/silverblue' \
        '41' \
        'x86_64' \
        'Fedora Silverblue'

    generate \
        'quay.io/fedora-ostree-desktops/silverblue' \
        '42' \
        'x86_64' \
        'Fedora Silverblue'

    generate \
        'quay.io/fedora-ostree-desktops/kinoite' \
        '41' \
        'x86_64' \
        'Fedora Kinoite'

    generate \
        'quay.io/fedora-ostree-desktops/kinoite' \
        '42' \
        'x86_64' \
        'Fedora Kinoite'
}

generate() {
    local -r image="${1}"
    local -r release="${2}"
    local -r arch="${3}"
    local -r name="${4}"
    local -r shortname="$(echo "${name}" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')"

    # For containers only
    local -r registry="quay.io/travier"
    local -r destination_suffix="-sysexts"

    # Get the list of sysexts for a given target
    sysexts=()
    for s in $(git ls-tree -d --name-only HEAD | grep -Ev ".github|templates"); do
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

    local -r tmpl=".workflow-templates/"
    if [[ ! -d "${tmpl}" ]]; then
        echo "Could not find the templates. Is this script run from the root of the repo?"
        exit 1
    fi

    # Generate container sysexts workflows
    # Skip non x86-64 builds for now
    if [[ "${arch}" != "x86_64" ]]; then
        return 0
    fi
    {
    sed \
        -e "s|%%IMAGE%%|${image}|g" \
        -e "s|%%RELEASE%%|${release}|g" \
        -e "s|%%NAME%%|${name}|g" \
        -e "s|%%REGISTRY%%|${registry}|g" \
        -e "s|%%DESTINATION%%|${shortname}${destination_suffix}|g" \
        -e "s|%%ARCH%%|${arch}|g" \
        "${tmpl}/containers_header"
    echo ""
    for s in "${sysexts[@]}"; do
        if [[ -f "${s}/Containerfile" ]]; then
            sed \
                -e "s|%%SYSEXT%%|${s}|g" \
                -e "s|%%SYSEXT_NODOT%%|${s//\./_}|g" \
                "${tmpl}/containers_build"
            echo ""
        fi
    done

    # Skip pushing containers for now
    return 0

    cat "${tmpl}/containers_logincosign"
    echo ""
    for s in "${sysexts[@]}"; do
        if [[ -f "${s}/Containerfile" ]]; then
            sed \
                -e "s|%%SYSEXT%%|${s}|g" \
                -e "s|%%SYSEXT_NODOT%%|${s//\./_}|g" \
                "${tmpl}/containers_pushsign"
            echo ""
        fi
    done
    } > ".github/workflows/containers-${shortname}-${release}.yml"
}

main "${@}"
