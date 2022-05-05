import "CoreLibs/object"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
local sizeX <const> = 64
local sizeY <const> = 64
local maxiteration <const> = 50

class("Tile").extends()

function Tile:init(minX, maxX, minY, maxY)
	self.minX = minX
	self.maxX = maxX
	self.minY = minY
	self.maxY = maxY
	self.buffer = gfx.image.new(sizeX, sizeY, gfx.kColorClear)

	self.solved = false
end

function Tile:update()
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

function Tile:getWorldXform()
	local worldWidth = self.maxX - self.minX
	local worldHeight = self.maxY - self.minY

	local xform = playdate.geometry.affineTransform.new()
	xform:scale(worldWidth/sizeX, worldHeight/sizeY)
	xform:translate(self.minX, self.minY)
	return xform
end

function Tile:render(max_iteration)
	local width, height = self.buffer:getSize()
	gfx.pushContext(self.buffer)
	gfx.clear(gfx.kColorClear)

	for px=0,width,1 do
		for py=0,height,1 do

			local x0 = scale(
				0,
				width,
				self.min_x,
				self.max_x,
				px
			)
			local y0 = scale(
				0,
				height,
				self.min_y,
				self.max_y,
				py
			)
			local x = 0
			local y = 0
			local iteration = 0
			while (x*x + y*y <= 2*2 and iteration <= max_iteration) do
				local xtemp = x*x - y*y + x0
				y = 2*x*y + y0
				x = xtemp
				iteration = iteration + 1
			end
			
			if scale(0,max_iteration,0,360,iteration) > (playdate.getCrankPosition() + 180) % 360 then
				gfx.setColor(gfx.kColorWhite)
			else
				gfx.setColor(gfx.kColorBlack)
			end
			gfx.drawPixel(px, py)	

			-- draw a border around the tile??
			-- if px == 0 or py == 0 then
				-- gfx.setColor(gfx.kColorXOR)
				-- gfx.drawPixel(px, py)
			-- end
		end
	end
	gfx.popContext()
end

function Tile:crender(max_iteration)
	c_render_region(self.buffer, self.min_x, self.min_y, self.max_x, self.max_y, max_iteration, math.floor(max_iteration/2))
end

function scale(fullMin, fullMax, scaleMin, scaleMax, val)
	local fullDelta = fullMax - fullMin
	local ret = (val - fullMin) / fullDelta
	local scaleDelta = scaleMax - scaleMin
	ret = ret * scaleDelta
	ret = ret + scaleMin
	return ret
end


-- static float map(float value, float fromLow, float fromHigh, float toLow, float toHigh)
-- {
-- 	float fromDelta = fromHigh - fromLow;
-- 	float toDelta = toHigh - toLow;
-- 	float ret = (value - fromLow) / fromDelta;
-- 	ret = ret * toDelta;
-- 	ret = ret + toLow;
-- 	return ret;
-- }
function map(value, fromLow, fromHigh, toLow, toHigh)
	fromDelta = fromHigh - fromLow
	toDelta = toHigh - toLow
	local ret = (value - fromLow) / fromDelta
	ret *= toDelta
	ret += toLow
	return ret
end