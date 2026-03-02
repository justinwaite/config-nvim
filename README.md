# nvim configs

## system dependencies

### neovim 12
neovim 12 is required for some of the features used in this configuration. 
You can install it from the official github while it's still in pre-release.

### system dependencies
you can install these with brew
- `treesitter` - for syntax highlighting and code parsing
- `treesitter-cli` - for installing treesitter parsers
- `ripgrep` - for searching
- `fzf` - for fuzzy finding

## language servers
language servers are installed using the `:Mason` command in nvim.
- `copilot-language-server`
- `css-lsp`
- `css-variables-language-server`
- `eslint-lsp`
- `gopls`
- `js-debug-adapter`
- `json-lsp`
- `lua-language-server`
- `markdownlint`
- `oxfmt`
- `oxlint`
- `sql-formatter`
- `stylua`
- `tailwindcss-language-server`

## signing into copilot
to sign into copilot you can call :LspCopilotSignIn (or use the shortcut `<leader>ai`)
to sign out you can call :LspCopilotSignOut (or use the shortcut `<leader>ao`)

## how to debug an application
to debug an application, you first need to run the application with debugging 
enabled. for example, if you are debugging a react-router application, you can
run `NODE_OPTIONS='--inspect=0' pnpm dev`. 

once you have the application started, run the `<leader>dc` which will open a 
list of debug configurations. for a react-router application, the easiest way 
to connect is selecting `Attach (by app port)`. you then provide the port number
and the debug adapter will connect to the application. 

checkout [the debugger config](./lua/configs/debugging.lua) to view all of the
keyboard shortcuts (or use which-key to view them in nvim)
