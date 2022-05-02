import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "tile"

local gfx <const> = playdate.graphics
local counter = 0
local tiles = {}
local min_x = -2.00
local max_x = 0.47
local min_y = -1.12
local max_y = 1.12
local offset_x = 0
local offset_y = 0
local move_step = 0.05
local zoom_step <const> = 0.9
local tiles_x <const> = 16
local tiles_y <const> = 16
local tile_width <const> = playdate.display.getWidth() / tiles_x	
local tile_height <const> = playdate.display.getHeight() / tiles_y	

local max_iteration = 50
local show_debug = false
local slowest_elapsed = 0


function setup()
	print("SETUP")
	playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.display.setScale(1)

	create_tiles()
end

function playdate.update()
	create_tiles()

	local x = 0
	local y = 0

	playdate.resetElapsedTime()
	for i=1,(tiles_x*tiles_y) do
		local tile = tiles[i]
		x, y = index_to_xy(i)
		if counter % tiles_y == i % tiles_x then
			tile:crender(max_iteration)
		end
		tile.buffer:draw(x, y)
	end

	local elapsed = playdate.getElapsedTime()
	if elapsed > slowest_elapsed then
		slowest_elapsed = elapsed
		print("new slowest elapsed=", slowest_elapsed)	
	end

	counter += 1
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, 150, 20)
	gfx.setColor(gfx.kColorBlack)	
	if show_debug then
		gfx.drawText(string.format("max__iteration=%d", max_iteration), 0, 0)
	else
		gfx.drawText(" *mandelbr0t*", 0, 0)
	end
	playdate.drawFPS(0, playdate.display.getHeight()-10)
end

function index_to_xy(idx)
	local x = math.floor((idx - 1)/ tiles_x) * tile_width
	local y = ((idx - 1) % tiles_y) * tile_height
	return x, y
end

function create_tiles()
	local scaled_range_x = (max_x - min_x) / tiles_x
	local scaled_range_y = (max_y - min_y) / tiles_y

	for i=0,(tiles_x-1) do
		for j=0,(tiles_y-1) do
			local tile_min_x = scaled_range_x * i + min_x + offset_x
			local tile_max_x = scaled_range_x * (i + 1) + min_x + offset_x
			local tile_min_y = scaled_range_y * j + min_y + offset_y
			local tile_max_y = scaled_range_y * (j + 1) + min_y + offset_y
			local tile = Tile(
				tile_min_x, 
				tile_max_x, 
				tile_min_y, 
				tile_max_y, 
				tile_width,
				tile_height
			)
			tiles[i * tiles_x + j + 1] = tile
		end
	end
end

-- function playdate.downButtonUp()
-- 	max_iteration -= 1
-- end
-- function playdate.upButtonUp()
-- 	max_iteration += 1
-- end
function playdate.leftButtonUp()
	offset_x -= move_step
	offset_x -= move_step
end
function playdate.rightButtonUp()
	offset_x += move_step
	offset_x += move_step
end
function playdate.upButtonUp()
	offset_y -= move_step
	offset_y -= move_step
end
function playdate.downButtonUp()
	offset_y += move_step
	offset_y += move_step
end
function playdate.AButtonUp()
	min_x *= zoom_step
	min_y *= zoom_step
	max_x *= zoom_step
	max_y *= zoom_step
	move_step *= zoom_step
end
function playdate.BButtonUp()
	min_x /= zoom_step
	min_y /= zoom_step
	max_x /= zoom_step
	max_y /= zoom_step
	move_step /= zoom_step
end

setup()