import "CoreLibs/graphics"
import "tile_manager"

local gfx <const> = playdate.graphics
local min_x = -2.00
local max_x = 0.47
local min_y = -1.12
local max_y = 1.12
local tiles_x = 4
local tiles_y = 4
local move_step <const> = 0.05
local zoom_step <const> = 0.9

local tileManager

function setup()
	playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.display.setScale(1)

	tileManager = TileManager(min_x, min_y, max_x, max_y, tiles_x, tiles_y, 100)
end
setup()

function playdate.update()
	tileManager:render()

	gfx.drawTextInRect("*mandelbr0t*", 0, 0, 100, 20, 10)
	playdate.drawFPS(0, playdate.display.getHeight()-10)
end

function playdate.leftButtonUp()
	tileManager:translate(-move_step, 0)
end
function playdate.rightButtonUp()
	tileManager:translate(move_step, 0)
end
function playdate.upButtonUp()
	tileManager:translate(0, -move_step)
end
function playdate.downButtonUp()
	tileManager:translate(0, move_step)
end
function playdate.AButtonUp()
	tileManager:scale(zoom_step, zoom_step)
end
function playdate.BButtonUp()
	tileManager:scale(1/zoom_step, 1/zoom_step)
end

