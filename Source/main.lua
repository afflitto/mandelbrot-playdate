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
local zoom_step <const> = 0.95

local tileManager

function setup()
	playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.display.setScale(1)

	tileManager = TileManager(min_x, min_y, max_x, max_y, tiles_x, tiles_y, 500)
end
setup()

function playdate.update()
	gfx.clear(gfx.kColorBlack)

	tileManager:render()

	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, 100, 20)
	gfx.drawTextInRect(" *mandelbr0t*", 0, 0, 100, 20, 10)
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
	tileManager = TileManager(min_x, min_y, max_x, max_y, tiles_x, tiles_y, 500)
end
function playdate.cranked(change, accelChange)
	if change > 0 then
		tileManager:scale(zoom_step, zoom_step)
	else
		tileManager:scale(1/zoom_step, 1/zoom_step)
	end
end
