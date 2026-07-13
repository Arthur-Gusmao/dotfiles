require('vis')

vis.events.subscribe(vis.events.INIT, function()
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	vis:command('set autoindent')
	vis:command('set expandtab')
	vis:command('set tabwidth 2')
	vis:command('set relativenumber')
	vis:command('set ignorecase on')
end)

