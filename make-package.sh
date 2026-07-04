#!/bin/bash
# Modify the upstream package for publication
#
# The code is pretty easy to understand so I won't explain further here, you'll
# figure it out.
#
# Requires:
# - [jq](https://github.com/jqlang/jq)
set -euo pipefail

mkdir -p build
# Supposedly -T only works on Linux, not Mac OS. Too bad.
cp -Tr upstream/fstar-vscode-assistant/lspserver/ build/fstar-vsca-lsp-server

cd build/fstar-vsca-lsp-server

shopt -s globstar nullglob
for x in src/**/*.{ts,js}; do
  # As we use stdio as the LSP transport, we must prevent any other outputs to
  # stdout; stderr is fine though:
  sed -i 's/console.log/console.error/g' "$x"
done

# We need to change the package name, add a postinstall script to perform the
# compilation step on the user's machine and then expose the compiled script
# as an executable (jq lacks in-place editing support, hence the `jq ; mv`
# thing):
jq -f ../../package-json-filter.jq < package.json > package.json.tmp
mv package.json.tmp package.json

# We need to ensure the main script has a shebang:
{ echo "#!/usr/bin/env node" ; cat src/main.ts; } > src/main.ts.tmp
mv src/main.ts.tmp src/main.ts

# And we need to add `esbuild` to our dependencies so the postinstall script
# can work:
npm add 'esbuild@^0.28'
