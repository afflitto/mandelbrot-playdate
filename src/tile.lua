import "CoreLibs/object"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

class("Tile").extends()

function Tile:init(min_x, max_x, min_y, max_y, screenWidth, screenHeight)
	self.min_x = min_x
	self.max_x = max_x
	self.min_y = min_y
	self.max_y = max_y
	self.buffer = gfx.image.new(screenWidth, screenHeight, gfx.kColorClear)
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

function scale(fullMin, fullMax, scaleMin, scaleMax, val)
	local fullDelta = fullMax - fullMin
	local ret = (val - fullMin) / fullDelta
	local scaleDelta = scaleMax - scaleMin
	ret = ret * scaleDelta
	ret = ret + scaleMin
	return ret
end