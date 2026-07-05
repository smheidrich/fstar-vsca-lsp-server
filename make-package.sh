#!/bin/bash
# Modify the upstream package for publication
#
# Requires:
# - [jq](https://github.com/jqlang/jq)
# - GNU coreutils compatible cp and sed (unlikely on e.g. Mac)

set -euo pipefail

mkdir -p build

# Supposedly -T only works on Linux, not Mac OS. Too bad.
cp -Tr upstream/fstar-vscode-assistant/lspserver/ build/fstar-vsca-lsp-server

# We also need to copy the LICENSE file from the parent...
cp upstream/fstar-vscode-assistant/LICENSE build/fstar-vsca-lsp-server/

# ... and our own README
cp README.md build/fstar-vsca-lsp-server/

cd build/fstar-vsca-lsp-server

shopt -s globstar nullglob
for x in src/**/*.{ts,js}; do
  # Because we use stdio as the LSP transport, we must prevent any other
  # outputs to stdout; stderr is fine though:
  sed -i -E 's/console.(log|info)/console.error/g' "$x"
done

# We need to change the package name, version, ...,  add a prepare script to
# perform the compilation with dev dependencies installed, and then expose the
# compiled script as an executable (jq lacks in-place editing support, hence
# the `jq ; mv` thing):
export VERSION=0.1.2
jq -f ../../package-json-filter.jq < package.json > package.json.tmp
mv package.json.tmp package.json

# We need to ensure the main script has a shebang (esbuild then automatically
# sets the executable flag [^1]):
sed -i '1i #!/usr/bin/env node' src/main.ts
# [^1]: https://github.com/evanw/esbuild/commit/b808c0d905551dde55e2485eb18d488b12e4ba94

# And we need to add `esbuild` to our devDependencies (upstream has it in the
# parent package and invokes the lspserver compilation via the parent package's
# tasks, which I guess under certain circumstances ensures devDependencies of
# the parent are available, but we don't have that luxury):
npm add --save-dev 'esbuild@^0.28'
