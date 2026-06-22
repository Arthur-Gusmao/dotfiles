-- ~/.config/vis/visrc.lua
require('vis')

vis.events.subscribe(vis.events.INIT, function()
  vis:command('set theme kanagawa-dragon')
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
  vis:command('set relativenumbers true')
  vis:command('set autoindent true')
  vis:command('set showtabs')
  vis:command('set tabwidth 2')
  vis:command('set cursorline')
  vis:command('set expandtab')
end)
