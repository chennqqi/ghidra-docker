#!/usr/bin/env bash
set -Eeuo pipefail

# Creates a git tag and GitHub release for the Ghidra version configured in
# Dockerfile.ghidra. Idempotent: exits early if the release already exists.
#
# Env:
#   GITHUB_REPOSITORY  owner/repo (defaults to the origin remote or gh's context)
#   GITHUB_SHA         commit the release tag points at (defaults to main)
#   IMAGE_NAME         Docker Hub image name shown in the notes

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$(sed -n 's/^ARG GHIDRA_VERSION=//p' "${repo_root}/Dockerfile.ghidra")"
tag="v${version}"

repo="${GITHUB_REPOSITORY:-}"
if [[ -z "${repo}" ]]; then
    repo="$(cd "${repo_root}" && gh repo view --json nameWithOwner --jq .nameWithOwner)"
fi

if gh release view "${tag}" --repo "${repo}" >/dev/null 2>&1; then
    echo "Release ${tag} already exists in ${repo}"
    exit 0
fi

upstream_repo="NationalSecurityAgency/ghidra"
upstream_tag="Ghidra_${version}_build"
upstream_url="https://github.com/${upstream_repo}/releases/tag/${upstream_tag}"
image_name="${IMAGE_NAME:-ghidra}"

# Extract only this version's section from the upstream ChangeHistory.md.
changelog="$(gh api \
    "repos/${upstream_repo}/contents/Ghidra/Configurations/Public_Release/src/global/docs/ChangeHistory.md?ref=${upstream_tag}" \
    --jq .content 2>/dev/null | base64 -d | awk -v v="${version}" '
        $0 ~ "^# Ghidra " v " Change History" { found = 1; print; next }
        found && /^# Ghidra / { exit }
        found { print }
    ' || true)"

notes_file="$(mktemp)"
{
    echo "Multi-distro Ghidra ${version} images, built from \`Dockerfile.ghidra\`."
    echo
    echo "## Images"
    echo
    echo "Published to [Docker Hub](https://hub.docker.com/r/${image_name}) as"
    echo "\`${image_name}:<distro>-${version}\` for:"
    echo "debian, ubuntu, fedora, rocky, almalinux, opensuse."
    echo
    echo "## Upstream"
    echo
    echo "- Repository: https://github.com/${upstream_repo}"
    echo "- Release: ${upstream_url}"
    if [[ -n "${changelog//[[:space:]]/}" ]]; then
        echo
        echo "${changelog}"
    else
        echo "- Changelog: ${upstream_url} (could not extract per-version notes)"
    fi
} > "${notes_file}"

gh release create "${tag}" \
    --repo "${repo}" \
    --target "${GITHUB_SHA:-main}" \
    --title "Ghidra ${version}" \
    --notes-file "${notes_file}"

rm -f "${notes_file}"
echo "Created release ${tag} in ${repo}"
