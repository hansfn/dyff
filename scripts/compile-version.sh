#!/usr/bin/env bash

# Copyright © 2018 Matthias Diester
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

set -euo pipefail

BASEDIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(cd "$BASEDIR" && git describe --tags)"
VERFILE="$BASEDIR/cmd/version.go"

on_exit() {
  if [[ -f "${VERFILE}.bak" ]]; then
    mv "${VERFILE}.bak" "${VERFILE}"
  fi
}

# Run on exit function to clean-up
trap on_exit EXIT

# Backup current version of the version subcommand and set current tag as version
cp -p "${VERFILE}" "${VERFILE}.bak"
perl -pi -e "s/const version = \"\\(development\\)\"/const version = \"${VERSION}\"/g" "${VERFILE}"

TARGET_PATH="${BASEDIR}/binaries"
mkdir -p "$TARGET_PATH"
while read -r OS ARCH; do
  echo -e "Compiling \\033[1mdyff version ${VERSION}\\033[0m for OS \\033[1m${OS}\\033[0m and architecture \\033[1m${ARCH}\\033[0m"
  TARGET_FILE="${TARGET_PATH}/dyff-${OS}-${ARCH}"
  if [[ "${OS}" == "windows" ]]; then
    TARGET_FILE="${TARGET_FILE}.exe"
  fi

  ( cd "$BASEDIR" && GOOS="$OS" GOARCH="$ARCH" go build -o "$TARGET_FILE" cmd/dyff/main.go )

done << EOL
darwin	386
darwin	amd64
linux	386
linux	amd64
linux	s390x
windows	386
windows	amd64
EOL