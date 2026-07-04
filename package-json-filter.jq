.name |= "fstar-vsca-lsp-server" |
.scripts.postinstall |= "npm run compile" |
#.scripts.compile += " --external:vscode-* --external:which --external:ps-tree --external:node:* --banner:js=#!/usr/bin/env node" |
.bin |= {"fstar-vsca-lsp-server": "out/main.js"}
