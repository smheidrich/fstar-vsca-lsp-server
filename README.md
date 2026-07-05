# fstar-vsca-lsp-server

This package publishes the LSP server that's part of the [F* VS Code
Assistant][1] as a standalone package.


## Installation

> [!IMPORTANT]
> Unfortunately, you can't just plug this into an LSP client and expect it to
> work as-is. You do, for now, need some special configuration owing to its
> origin as a component in a VS Code extension. **Pay close attention to the
> configuration section below this one** or you will get very confusing error
> messages.

The easiest way to make the server executable available to your editor is to
install it somewhere into your `$PATH`. I'm not really familiar with the JS/TS
ecosystem, so after consulting with an LLM, apparently it's done like this
(assuming `~/.local/bin` is in your `$PATH`):

```bash
npm install -g --prefix $HOME/.local/bin fstar-vsca-lsp-server
```

If you have some cool modern better way to do this (something equivalent to
Python's `pipx install some-package` or `uv tool install some-package`), just
use that instead.


## Configuring your editor

You **must** configure your editor so that it:

1. Runs the executable with the `--stdio` command-line argument and accordingly
   performs the LSP communication via standard input/output
2. Sends a [`workspace/configuration`][2] response to the server with at least
   these contents (you can change the values, but the presence of the keys is
   important or the server will crash with a strange error message):

   ```json
   {
     "fstarVSCodeAssistant": {
       "debug": false,
       "verifyOnOpen": false,
       "verifyOnSave": true,
       "flyCheck": true,
       "showLightCheckIcon": false
     }
   }
   ```
3. Uses the LSP server thus configured for F* files (`.fst` or `.fsti`
   extension)

### Other options

If your editor can communicate with LSP servers via "Node IPC" (whatever that
is), then for point (1), you can instead use the `--node-ipc` command-line
argument and set things up accordingly. But I don't know anything about that
so I won't be able to help you with it.


## Configuration examples

### Neovim

Note that you first need a **filetype plugin** (e.g. [VimFStar][4], which comes
with a very outdated Python extension that you should probably just remove)
that detects F* files and sets their buffer's `filetype` to `fstar`.

Assuming you have that, here's a [nvim-lspconfig][3] configuration:

```lua
vim.lsp.config('fstar-lsp', {
  cmd = { 'fstar-vsca-lsp-server', '--stdio' },
  filetypes = { 'fstar' },
  settings = {
    -- REQUIRED pretending-to-be-the-VS-Code-plugin options:
    fstarVSCodeAssistant = {
      debug = false,
      verifyOnOpen = false,
      verifyOnSave = true,
      flyCheck = true,
      showLightCheckIcon = false
    }
  },
})
vim.lsp.enable('fstar-lsp')
```


## Development

As already pointed out, this project just extracts the LSP server package from
the upstream [fstar-vscode-assistant][1] repository, which can be fetched via:

```bash
./fetch-upstream.sh
```

However, it also needs makes some changes to this code before it can be
published as a standalone package. This repo includes a script for this
purpose (probably only works on Linux):

```bash
./make-package.sh
```

This should put the modified package under `build/fstar-vsca-lsp-server/`.

The package can then be published to npm like so:

```bash
cd build/fstar-vsca-lsp-server
npm publish --access public
```

**NOTE:** I was going to set up trusted publishing, which would be especially
important for an application package like this that only ships
difficult-to-audit bundled code, but npm doesn't allow me to do that unless I
buy a physical key thing for their 2FA, which I haven't done.


[1]: https://github.com/FStarLang/fstar-vscode-assistant
[2]: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_configuration
[3]: https://github.com/neovim/nvim-lspconfig
[4]: https://github.com/FStarLang/VimFStar
