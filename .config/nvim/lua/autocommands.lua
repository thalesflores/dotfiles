local autocmd = vim.api.nvim_create_autocmd

autocmd('BufNewFile', {pattern='**/kickoffs/*.md', command='0r ~/skeletons/kickoff_template.md'})
autocmd('BufNewFile', {pattern='**/refinements/*.md', command='0r ~/skeletons/refinement_template.md'})
