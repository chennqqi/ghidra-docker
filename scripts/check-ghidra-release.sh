#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
api_url="https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest"
curl_headers=(
    -H "Accept: application/vnd.github+json"
    -H "X-GitHub-Api-Version: 2022-11-28"
)
github_token="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
if [[ -n "${github_token}" ]]; then
    curl_headers+=(-H "Authorization: Bearer ${github_token}")
fi

release_json="$(curl --fail --silent --show-error --location \
    "${curl_headers[@]}" \
    "${api_url}")"

asset_name="$(jq -r '
    [.assets[].name
      | select(test("^ghidra_[0-9.]+_PUBLIC_[0-9]{8}\\.zip$"))][0] // empty
' <<<"${release_json}")"

if [[ -z "${asset_name}" ]]; then
    echo "The latest release has no official Ghidra PUBLIC zip asset" >&2
    exit 1
fi

if [[ ! "${asset_name}" =~ ^ghidra_([0-9.]+)_PUBLIC_([0-9]{8})\.zip$ ]]; then
    echo "Unexpected Ghidra asset name: ${asset_name}" >&2
    exit 1
fi

version="${BASH_REMATCH[1]}"
release_date="${BASH_REMATCH[2]}"
digest="$(jq -r --arg name "${asset_name}" '
    [.assets[] | select(.name == $name) | .digest][0] // ""
' <<<"${release_json}")"
sha256="${digest#sha256:}"

current_version="$(sed -n 's/^ARG GHIDRA_VERSION=//p' "${repo_root}/Dockerfile.ghidra")"
if [[ "${version}" == "${current_version}" ]]; then
    echo "Ghidra ${version} is already configured"
    exit 0
fi

sed -i \
    -e "s/^ARG GHIDRA_VERSION=.*/ARG GHIDRA_VERSION=${version}/" \
    -e "s/^ARG GHIDRA_RELEASE_DATE=.*/ARG GHIDRA_RELEASE_DATE=${release_date}/" \
    "${repo_root}/Dockerfile.ghidra"
sed -i \
    -e "s/default = \"${current_version}\"/default = \"${version}\"/" \
    -e "s/default = \"[0-9]\\{8\\}\"/default = \"${release_date}\"/" \
    "${repo_root}/docker-bake.hcl"

if [[ "${sha256}" =~ ^[0-9a-fA-F]{64}$ ]]; then
    sed -i "/variable \"GHIDRA_SHA256\"/,/}/{s/default = .*/default = \"${sha256}\"/;}" \
        "${repo_root}/docker-bake.hcl"
fi

echo "Updated Ghidra ${current_version} to ${version} (${release_date})"
