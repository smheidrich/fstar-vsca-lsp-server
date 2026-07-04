#!/bin/bash
# Modify the upstream package for publication
#
# The code is pretty easy to understand so I won't explain further here, you'll
# figure it out.
#
# Requires:
# - [jq](https://github.com/jqlang/jq)
set -euo pipefail

rm -rf build
mkdir -p build
cp -r upstream/fstar-vscode-assistant/lspserver/ build/fstar-vsca-lsp-server

cd build/fstar-vsca-lsp-server
for x in **/*.ts; do
  # As we use stdio as the LSP transport, we must prevent any other outputs to
  # stdout; stderr is fine though:
  sed -i 's/console.log/console.error/g' "$x"
  # We need to change the package name, add a postinstall script to perform the
  # compilation step on the user's machine and then expose the compiled script
  # as an executable (jq lacks in-place editing support, hence the `jq ; mv`
  # thing):
  jq '.name |= "fstar-vsca-lsp-server" | .scripts.postinstall |= "npm run compile" | .bin |= {"fstar-vsca-lsp-server": "out/main.js"}' \
    < package.json > package.json.tmp
  mv package.json.tmp package.json
done
