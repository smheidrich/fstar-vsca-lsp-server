.name |= "@smheidrich/fstar-vsca-lsp-server" |
.description |= "LSP server extracted from fstar-vscode-assistant" |
.version |= env.VERSION |
.scripts.prepare |= "npm run compile" |
.bin |= {"fstar-vsca-lsp-server": "out/main.js"} |
.repository.url |= "https://github.com/smheidrich/fstar-vsca-lsp-server"
