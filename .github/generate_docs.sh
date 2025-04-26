#!/bin/bash

# Re-generate the docs for the GitHub Pages workflow.
# TODO: Note somewhere for which images the sysext is for?

set -euo pipefail
# set -x

main() {
    if [[ ! -d .github ]] || [[ ! -d .git ]]; then
        echo "This script must be run at the root of the repo"
        exit 1
    fi

    local -r extensionsurl="https://extensions.fcos.fr/extensions"
    local -r releaseurl="https://github.com/travier/fedora-sysexts-exp/releases/tag"

    local -r tmpl=".docs-templates/"

    if [[ ! -d "${tmpl}" ]]; then
        echo "Could not find the templates. Is this script run from the root of the repo?"
        exit 1
    fi

    navorder=1

    for s in $(git ls-tree -d --name-only HEAD | grep -Ev ".github|.workflow-templates|docs"); do
        if [[ -f ./${s}/.docs-ignore ]]; then
            continue
        fi
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
        popd > /dev/null
        echo ""
        sed -e "s|%%SYSEXT%%|${s}|g" \
            -e "s|%%RELEASEURL%%|${releaseurl}|g" \
            -e "s|%%EXTENSIONSURL%%|${extensionsurl}|g" \
           "${tmpl}/setup-install-update.md"
        } > "docs/${s}/index.md"
    done

    pushd docs > /dev/null
    docs_dir="$(ls -d ./*/ | grep -vE "_site|vendor")"
    popd > /dev/null
    sysexts_dirs="$(ls -d ./*/ | grep -vE "docs|mpd|steam|steam-devices|wireshark")"

    diff="$(diff -u <(echo "${docs_dir}") <(echo "${sysexts_dirs}") || true)"
    if [[ -n "${diff}" ]]; then
        echo "Diff between current sysexts and docs is not empty. Cleanup needed following a sysext removal?"
        echo ""
        echo "${diff}"
    fi
}

main "${@}"
