require('vis')

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
	vis:command('set theme gruvbox')
	vis:command('set relativenumber')

	win.options.autoindent = true
	win.options.tabwidth = 2
	win.options.relativenumber = true
	win.options.ignorecase = true

	local name = win.file and win.file.name or ""

	if name:match("Makefile$") or
		name:match("GNUmakefile$") or
		name:match("%.mk$") then
		win.options.expandtab = false
	else
		win.options.expandtab = true
	end
end)

