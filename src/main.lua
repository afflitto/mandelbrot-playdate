import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "tile"

local gfx <const> = playdate.graphics
local counter = 0
local tiles = {}
local min_x <const> = -2.00
local max_x <const> = 0.47
local min_y <const> = -1.12
local max_y <const> = 1.12
local tiles_x <const> = 16
local tiles_y <const> = 16
local tile_width <const> = playdate.display.getWidth() / tiles_x	
local tile_height <const> = playdate.display.getHeight() / tiles_y	

local max_iteration = 50
local show_debug = true


function setup()
	print("SETUP")
	playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.display.setScale(1)

	local scaled_range_x = (max_x - min_x) / tiles_x
	local scaled_range_y = (max_y - min_y) / tiles_y
	print("i, j, tile_min_x, tile_max_x, tile_min_y, tile_max_y")

	for i=0,(tiles_x-1) do
		for j=0,(tiles_y-1) do
			local tile_min_x = scaled_range_x * i + min_x
			local tile_max_x = scaled_range_x * (i + 1) + min_x
			local tile_min_y = scaled_range_y * j + min_y
			local tile_max_y = scaled_range_y * (j + 1) + min_y
			local tile = Tile(
				tile_min_x, 
				tile_max_x, 
				tile_min_y, 
				tile_max_y, 
				tile_width,
				tile_height
			)
			-- tile:render()
			tiles[i * tiles_x + j + 1] = tile
			print(i, j, tile_min_x, tile_max_x, tile_min_y, tile_max_y)
		end
	end
end
setup()

function playdate.update()
	local idx = math.floor(counter / 1) % (tiles_x * tiles_y)
	local tile = tiles[idx + 1]
	local x, y = index_to_xy(idx)

	tile:render(max_iteration)
	tile.buffer:draw(x, y)

	counter += 1
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, 150, 20)
	gfx.setColor(gfx.kColorBlack)	
	if show_debug then
		-- Draw box around next tile to be updated
		local next_idx = math.floor(counter / 1) % (tiles_x * tiles_y)
		x, y = index_to_xy(next_idx)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(x, y, tile_width, tile_height)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(x+1, y+1, tile_width-2, tile_height-2)

		-- Draw max_iteration text
		gfx.drawText(string.format("max__iteration=%d", max_iteration), 0, 0)

		playdate.drawFPS(0, playdate.display.getHeight()-10)
	else
		gfx.drawText(" *mandelbr0t*", 0, 0)
	end
end

function index_to_xy(idx)
	local x = math.floor(idx / tiles_x) * tile_width
	local y = (idx % tiles_y) * tile_height
	return x, y
end

function playdate.downButtonUp()
	max_iteration -= 1
end
function playdate.upButtonUp()
	max_iteration += 1
end
function playdate.AButtonUp()
	show_debug = not show_debug
end
