import "CoreLibs/object"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
local sizeX = 10
local sizeY = 10
local maxiteration <const> = 35

class("Tile").extends()

function Tile:init(minX, maxX, minY, maxY)
	self.minX = minX
	self.maxX = maxX
	self.minY = minY
	self.maxY = maxY
	self.buffer = gfx.image.new(sizeX, sizeY, gfx.kColorWhite)
	self.tile_context = tile_context.new(sizeX, sizeY)
	self.solved = false
end

function Tile:update()
	if self.solved then
		return 1
	end

	local cost = update_cell_step(
		self.buffer, 
		self.minX, 
		self.minY, 
		self.maxX, 
		self.maxY, 
		maxiteration, 
		self.tile_context
	)

	if cost == 0 then
		self.solved = true
		return 1
	end
	
	return cost
end

function Tile:getWorldXform()
	local worldWidth = self.maxX - self.minX
	local worldHeight = self.maxY - self.minY

	local xform = playdate.geometry.affineTransform.new()
	xform:scale(worldWidth/sizeX, worldHeight/sizeY)
	xform:translate(self.minX, self.minY)
	return xform
end

function Tile:update_legacy()
	local width, height = self.buffer:getSize()
	local cost = 0

	if self.solved then
		return 0
	end

	gfx.pushContext(self.buffer)
	gfx.clear(gfx.kColorClear)
	for px=0,(width-1) do
		for py=0,(height-1) do
			local x0 = map(px, 0, width-1, self.minX, self.maxX)
			local y0 = map(py, 0, height-1, self.minY, self.maxY)
			local x = 0
			local y = 0
			local iteration = 0
			while(x*x + y*y <= 2*2 and iteration <= maxiteration) do
				local xtemp = x*x - y*y + x0
				y = 2*x*y + y0
				x = xtemp
				iteration += 1
			end

			if iteration > maxiteration then
				gfx.setColor(gfx.kColorBlack)
			else
				gfx.setColor(gfx.kColorWhite)
			end
			gfx.drawPixel(px, py)

			cost += iteration
		end
	end
	print("returning cost", cost)
	self.solved = true
	gfx.popContext()
	return cost
end

function map(value, fromLow, fromHigh, toLow, toHigh)
	fromDelta = fromHigh - fromLow
	toDelta = toHigh - toLow
	local ret = (value - fromLow) / fromDelta
	ret *= toDelta
	ret += toLow
	return ret
end