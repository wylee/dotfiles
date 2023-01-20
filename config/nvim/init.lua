vim.cmd [[source ~/.config/nvim/legacy.vim]]

vim.filetype.add({
  extension = {
    fi = "feint",
  },
})

local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

parser_config.feint = {
  install_info = {
    url = "~/Projects/feint-lang/tree-sitter-feint",
    files = {"src/parser.c", "src/scanner.cc"},
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = "fi",
}

require"nvim-treesitter.configs".setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
}

local ft_to_parser = require"nvim-treesitter.parsers".filetype_to_parsername
ft_to_parser.feint = "feint"
