
local DropBoxManager = require( "Dropbox" )
local widget = require( "widget" )

_W = display.contentWidth
_H = display.contentHeight


local function reqAccess( event )
	DropBoxManager.displayAuthButton()
end

--------------------------------
-- Create "Dropbox Request Access" Button
--------------------------------
--
dropBoxButton = widget.newButton{
	id = "button1",
	label = "1. Request Access",
	left = _W*0.05,
	top = _H*0.1,
	width = _W*.9, height = _H*.1,
	fontSize = 24,
	labelColor = { default = {80, 80, 255}, over = {255} },
	strokeColor = {0},
	defaultColor = {255},
	overColor = {128},
	cornerRadius = 8,
	-- Interesting, you can call dropit with no ()'s
	--    and if you put in the ()'s it runs automatically without waiting for button press?
	onPress = reqAccess
}