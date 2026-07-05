#!/bin/bash
# We don't use submodules because copybara doesn't support them [1], so this is
# the next best thing:
git clone \
  --revision=53a0c6e63f8a6022e4640b054ccb7b61c910937e \
  https://github.com/FStarLang/fstar-vscode-assistant.git \
  upstream
# [1]: https://github.com/google/copybara/issues/269
