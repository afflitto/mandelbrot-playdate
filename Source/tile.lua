import "CoreLibs/object"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
local sizeX = 100
local sizeY = 60
local maxiteration <const> = 50
local margin <const> = 0.01

local subdivideX <const> = 2
local subdivideY <const> = 2

class("Tile").extends()

function Tile:init(minX, maxX, minY, maxY)
	self.minX = minX - margin
	self.maxX = maxX + margin
	self.minY = minY - margin
	self.maxY = maxY + margin
	self.buffer = gfx.image.new(sizeX, sizeY, gfx.kColorWhite)
	self.tile_context = tile_context.new(sizeX, sizeY)
	self.parent = false
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
	-- scale from screen size to world size
	xform:scale(worldWidth/sizeX, worldHeight/sizeY)
	-- translate by world offset, plus size/2 because gfx draws centered
	xform:translate(self.minX + worldWidth/2, self.minY + worldHeight/2)
	return xform
end