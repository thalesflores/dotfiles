local create_new_file = function(input, path)
  command = 'e ' .. path .. '/dq-' .. input.args .. '.md'
  vim.cmd(command)
end

vim.api.nvim_create_user_command("Refinement", function(input)
    create_new_file(input, 'refinements')
  end,
  { desc = "Create a new refinement", nargs = '*', bang = true })

vim.api.nvim_create_user_command("Kickoff", function(input)
    create_new_file(input, 'kickoffs')
  end,
  { desc = "Create a new refinement", nargs = '*', bang = true })

