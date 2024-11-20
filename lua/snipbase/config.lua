local M = {}

M.defaults = {
    snippet_file = vim.fn.stdpath('data') .. '/snipbase.txt',
    mappings = {
        save = '<Leader>ns',
        search = '<Leader>nf'
    }
}

M.options = {}

function M.setup(opts)
    M.options = vim.tbl_deep_extend('force', {}, M.defaults, opts or {})
end

return M
