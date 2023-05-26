-- run code snippets
return {
  'michaelb/sniprun',
  build = 'bash ./install.sh',
  config = function()
    require 'sniprun'.setup({
      display = { "Classic" }
    })
  end
}
