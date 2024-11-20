local config = require('snipbase.config')
local M = {}

function M.get_visual_selection()
    -- Get the starting and ending positions of the selection
    local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
    local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))

    -- If the selection is backwards, swap the positions
    if csrow > cerow then
        csrow, cerow = cerow, csrow
        cscol, cecol = cecol, cscol
    elseif csrow == cerow and cscol > cecol then
        cscol, cecol = cecol, cscol
    end

    -- Get the lines in the selection
    local lines = vim.fn.getline(csrow, cerow)

    -- If it's a single line, extract the substring
    if #lines == 1 then
        lines[1] = string.sub(lines[1], cscol, cecol)
    else
        -- For the first line, from cscol to the end
        lines[1] = string.sub(lines[1], cscol)
        -- For the last line, from the start to cecol
        lines[#lines] = string.sub(lines[#lines], 1, cecol)
    end

    if type(lines) == "string" then
		  lines = { lines } -- Convert single string to table
    end

    -- Concatenate the lines
    return table.concat(lines, '\n')
end

function M.append_snippet_to_file(snippet, description)
    local file = io.open(config.options.snippet_file, 'a+b')  -- Open in binary append mode
    if not file then
        vim.notify("Failed to open snippet file", vim.log.levels.ERROR)
        return
    end

    file:write('Description: ' .. description .. '\n')
    file:write('Snippet:\n')
    file:write(snippet .. '\n')
    file:write('---\n')
    file:close()
end

function M.save_snippet()
    local snippet = M.get_visual_selection()
    if snippet == '' then
        vim.notify("No text selected", vim.log.levels.WARN)
        return
    end

    -- Prompt for a description
    local description = vim.fn.input('Enter a description for the snippet: ')
    if description == '' then
        vim.notify("Description cannot be empty", vim.log.levels.WARN)
        return
    end

    -- Now save the snippet
    M.append_snippet_to_file(snippet, description)
    vim.notify("Snippet saved successfully!", vim.log.levels.INFO)
end

function M.get_all_snippets()
    local file = io.open(config.options.snippet_file, 'r')
    if not file then
        vim.notify("Snippet file not found", vim.log.levels.WARN)
        return {}
    end

    local snippets = {}
    local current_description
    local current_snippet = {}
    local capture_snippet = false

    for line in file:lines() do
        if line:match('^Description: ') then
            current_description = line:sub(13)
            current_snippet = {}
            capture_snippet = false
        elseif line == 'Snippet:' then
            capture_snippet = true
        elseif line == '---' then
            if current_description then
                snippets[current_description] = table.concat(current_snippet, '\n')
            end
            capture_snippet = false
        elseif capture_snippet then
            table.insert(current_snippet, line)
        end
    end

    file:close()
    return snippets
end

function M.search_snippets()
    -- Check if telescope is available
    local ok, telescope = pcall(require, 'telescope.builtin')
    if not ok then
        vim.notify("Telescope.nvim is required for snippet search", vim.log.levels.ERROR)
        return
    end

    local snippets = M.get_all_snippets()
    local descriptions = {}
    for desc, _ in pairs(snippets) do
        table.insert(descriptions, desc)
    end
    table.sort(descriptions)

    require('telescope.pickers').new({}, {
        prompt_title = 'Snippets',
        finder = require('telescope.finders').new_table({
            results = descriptions,
            entry_maker = function(description)
                return {
                    value = description,
                    display = description,
                    ordinal = description,
                    preview_command = function(entry, bufnr)
                        local snippet = snippets[entry.value]
                        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(snippet, '\n'))
                    end,
                }
            end,
        }),
        sorter = require('telescope.config').values.generic_sorter({}),
        previewer = require('telescope.previewers').new_buffer_previewer({
            title = 'Snippet Preview',
            define_preview = function(self, entry)
                entry.preview_command(entry, self.state.bufnr)
            end,
        }),
        attach_mappings = function(prompt_bufnr, map)
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')

            local function paste_snippet()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                local snippet = snippets[selection.value]
                if snippet then
                    local lines = vim.split(snippet, '\n')
                    vim.api.nvim_put(lines, 'l', true, true)
                    vim.notify("Snippet inserted", vim.log.levels.INFO)
                else
                    vim.notify("Snippet not found", vim.log.levels.ERROR)
                end
            end

            map('i', '<CR>', paste_snippet)
            map('n', '<CR>', paste_snippet)
            return true
        end,
    }):find()
end

function M.setup(opts)
    -- Initialize configuration
    config.setup(opts)

    -- Ensure the snippet file directory exists
    local snippet_dir = vim.fn.fnamemodify(config.options.snippet_file, ':h')
    if vim.fn.isdirectory(snippet_dir) == 0 then
        vim.fn.mkdir(snippet_dir, 'p')
    end

    -- Set up keymaps
    vim.api.nvim_set_keymap('v', config.options.mappings.save,
        [[:lua require('snipbase').save_snippet()<cr>]],
        { noremap = true, silent = true, desc = 'Save snippet' })

    vim.api.nvim_set_keymap('n', config.options.mappings.search,
        [[:lua require('snipbase').search_snippets()<cr>]],
        { noremap = true, silent = true, desc = 'Search snippet' })

    vim.notify("Snipbase initialized", vim.log.levels.INFO)
end

return M
