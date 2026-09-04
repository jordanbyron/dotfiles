# LSP Keybindings Reference (Ruby & TypeScript)

## Basic Navigation
- **`gd`** - Go to definition
  - Jump to where a method, class, or variable is defined
  - Works with local variables, methods, classes, constants, modules

- **`gr`** - Find references
  - Show all places where a symbol is used
  - Opens a quickfix list with all references

## Information & Documentation
- **`K`** - Hover documentation
  - Show method signatures, documentation, type information
  - Works on method calls, class names, constants

## Refactoring
- **`,rn`** - Rename symbol
  - Rename a variable, method, class across the entire codebase
  - Smart renaming that updates all references

- **`,ca`** - Code actions
  - Context-aware quick fixes and refactoring suggestions
  - See "Code Actions Explained" below

## Formatting
- **`,f`** - Format current file
  - **Ruby**: Uses rubocop (matches your Neomake setup)
  - **TypeScript/JavaScript**: Uses Prettier
  - **CSS/JSON/HTML**: Uses Prettier

## Other LSP Features
- **Diagnostics** - Automatic error/warning detection (shown in gutter)
- **Completion** - Smart autocomplete suggestions while typing
- **Semantic Highlighting** - Enhanced syntax highlighting based on code meaning
- **Document Symbols** - Outline view of classes/methods in current file

## Code Actions Explained

Code actions are context-sensitive quick fixes and refactoring suggestions that ruby-lsp provides based on your cursor position. When you press `,ca`, you'll get a menu of available actions such as:

### Common Code Actions:
1. **Quick Fixes**
   - Fix missing `require` statements
   - Add missing method arguments
   - Fix syntax errors

2. **Refactoring**
   - Extract method from selected code
   - Extract variable from expression
   - Inline method or variable
   - Add explicit type annotations

3. **Ruby-specific Actions**
   - Convert string to symbol (or vice versa)
   - Change hash syntax (old → new style)
   - Add missing `end` statements
   - Convert blocks between `{}` and `do/end` styles

4. **Rails-specific Actions** (with ruby-lsp-rails)
   - Generate missing model methods
   - Add validations or associations
   - Create missing migration files

### How to Use Code Actions:
1. Position cursor on or select the code you want to improve
2. Press `,ca`
3. Choose from the menu of available actions
4. LSP automatically applies the changes

Code actions are one of the most powerful LSP features because they provide intelligent, context-aware suggestions that understand your Ruby code structure and Rails conventions.

## Language Support

### Ruby (.rb files)
- Powered by **ruby-lsp**
- Works with Rails-specific conventions
- Integrates with your existing vim-ruby and Neomake setup

### TypeScript/JavaScript (.ts, .tsx, .js, .jsx files)  
- Powered by **typescript-tools.nvim**
- Full React/JSX support
- Type inference and checking
- Auto-imports and intelligent refactoring

## TypeScript-Specific Features

### Inlay Hints
- Shows parameter names and types inline
- Variable type annotations
- Return type hints for functions

### React Support
- JSX/TSX syntax and completion
- Component prop validation
- Auto-closing JSX tags
- React hooks support

### Code Actions for TypeScript:
- Auto-import missing modules
- Add missing function return types
- Convert between arrow functions and function declarations
- Extract JSX into components
- Add missing React imports
- Organize imports
- Generate interface from usage

## Format on Save (Optional)

Both Ruby and TypeScript formatting can be configured to run automatically when you save files. This is currently **disabled** by default, but you can enable it by:

1. **For Ruby files**: Uncomment the format-on-save section in `~/.config/nvim/lua/lsp-config.lua` (lines ~20-28)
2. **For TypeScript files**: Uncomment the auto-format section in the same file (lines ~148-155)

**Recommendation**: Start with manual formatting (`,f`) and only enable auto-format if you prefer it, as it can sometimes interfere with your workflow.

## Tips:
- LSP may need a minute to fully index large codebases on first startup
- **Ruby**: All keybindings work alongside your existing vim-ruby and Neomake setup
- **TypeScript**: Requires tsconfig.json in project root for best results
- For best results, ensure you're in the project root directory
- Works with both Ruby (.rb, .erb) and TypeScript/JavaScript (.ts, .tsx, .js, .jsx) files