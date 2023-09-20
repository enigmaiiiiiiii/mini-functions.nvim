local M = {}

local function generate_markdown_TOC()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local toc = {}
	for _, line in ipairs(lines) do
		local level, title = string.match(line, "^(##+)%s*(.*)")
		if level and title then
			local item =
				string.format("%s* [%s](#%s)", string.rep("  ", #level - 2), title, title:lower():gsub("%s+", "-"))
			table.insert(toc, item)
		end
	end
	return toc
end

M.insert_markdown_TOC = function()
	local toc = generate_markdown_TOC()
	local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_lines(0, row, row, false, toc)
end

return M

