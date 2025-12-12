#!/bin/bash

set -euo pipefail

get_os_codename() {
  . /etc/os-release
  echo "$VERSION_CODENAME"
}

if [[ $# -gt 0 ]]; then
  exec "$@"
else
  if [[ -z ${PYTHON_VERSION:-} ]]; then
    echo "ERROR: PYTHON_VERSION is not set"
    exit 1
  fi

  CC=clang pyenv install "$PYTHON_VERSION" -v
  pyenv global "$PYTHON_VERSION"

  os_codename=$(get_os_codename)

  mkdir -p /output
  cd /opt/pyenv/versions
  tar -czf "/output/python-${PYTHON_VERSION}-${os_codename}.tar.gz" "${PYTHON_VERSION}"
  cd /output
  sha256sum "python-${PYTHON_VERSION}-${os_codename}.tar.gz" > "python-${PYTHON_VERSION}-${os_codename}.tar.gz.sha256"

  if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "ERROR: GITHUB_TOKEN is missing"
    exit 1
  fi

  FILE="/output/python-${PYTHON_VERSION}-${os_codename}.tar.gz"
  FILE_SHA256="/output/python-${PYTHON_VERSION}-${os_codename}.tar.gz.sha256"
  TAG="v${PYTHON_VERSION}"
  REPO="vindops/builder"

  echo "Files: $FILE $FILE_SHA256"
  echo "Release tag: $TAG"
  echo "Uploading to: $REPO"

  # Check if release exists
  if gh release view "$TAG" -R "$REPO" > /dev/null 2>&1; then
    echo "Release $TAG already exists → uploading asset..."
    gh release upload "$TAG" "$FILE" "$FILE_SHA256" -R "$REPO" --clobber
  else
    echo "Creating release $TAG..."
    gh release create "$TAG" "$FILE" "$FILE_SHA256" \
      -R "$REPO" \
      -t "Python $PYTHON_VERSION" \
      -n "Python built with pyenv version $PYTHON_VERSION"
  fi

  echo "Upload completed"
fi
