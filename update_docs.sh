#!/bin/bash

# Re-generate the docs. Might be later converted to a GitHub workflow
# publishing to GitHub Pages directly.

set -euo pipefail
# set -x

main() {
    if [[ ! -d .github ]] || [[ ! -d .git ]]; then
        echo "This script must be run at the root of the repo"
        exit 1
    fi

    # TODO: Remove existing directories in docs

    local -r extensionsurl="https://extensions.fcos.fr/extensions"
    local -r releaseurl="https://github.com/travier/fedora-sysexts-exp/releases/tag"

    # arches=(
    #     'x86_64'
    #     'aarch64'
    # )
    # images=(
    #     'quay.io/fedora-ostree-desktops/base-atomic:41'
    #     'quay.io/fedora-ostree-desktops/base-atomic:42'
    #     'quay.io/fedora/fedora-coreos:stable'
    #     'quay.io/fedora/fedora-coreos:next'
    # )

    local -r tmpl=".docs-templates/"

    if [[ ! -d "${tmpl}" ]]; then
        echo "Could not find the templates. Is this script run from the root of the repo?"
        exit 1
    fi

    navorder=1

    for s in $(git ls-tree -d --name-only HEAD | grep -Ev ".github|.workflow-templates|docs"); do
        navorder=$((navorder+1))
        mkdir -p "docs/${s}"
        {
        sed -e "s|%%SYSEXT%%|${s}|g" \
            -e "s|%%NAVORDER%%|${navorder}|g" \
           "${tmpl}/header.md"
        pushd "${s}" > /dev/null
        if [[ -f "README.md" ]]; then
            tail -n +2 README.md
        fi
        # TODO
        # just targets
        popd > /dev/null
        echo ""
        sed -e "s|%%SYSEXT%%|${s}|g" \
            -e "s|%%RELEASEURL%%|${releaseurl}|g" \
            -e "s|%%EXTENSIONSURL%%|${extensionsurl}|g" \
           "${tmpl}/setup-install-update.md"
        } > "docs/${s}/index.md"
    done
}

main "${@}"
