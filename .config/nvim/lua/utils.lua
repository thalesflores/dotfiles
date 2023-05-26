local build_mapper = function(mode, noremap)
  return function(lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = noremap

    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

return {
  noremap  = build_mapper("n", false),
  nnoremap = build_mapper("n", true),
  inoremap = build_mapper("i", true),
  tnoremap = build_mapper("t", true),
  vnoremap = build_mapper("v", true),
  map_bang = build_mapper("!", true)
}
