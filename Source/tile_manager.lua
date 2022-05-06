import "CoreLibs/object"
import "camera"
import "tile"

local overlap <const> = 0

class("TileManager").extends("Camera")
function TileManager:init(minX, minY, maxX, maxY, tilesX, tilesY, budget)
	TileManager.super.init(self, minX, minY, maxX, maxY)
	self.tilesX = tilesX
	self.tilesY = tilesY
	self.tiles = {}
	self.budget = budget

	local worldWidth = maxX - minX
	local worldHeight = maxY - minY
	for i=0,(tilesY-1) do
		for j=0,(tilesX-1) do
			local tileWorldWidth = worldWidth / tilesX
			local tileWorldHeight = worldHeight / tilesY
			local tileMinX = tileWorldWidth * j + minX
			local tileMinY = tileWorldHeight * i + minY
			self.tiles[i * tilesX + j + 1] = Tile(
				tileMinX - overlap,
				tileMinX + tileWorldWidth + overlap,
				tileMinY - overlap,
				tileMinY + tileWorldHeight + overlap
			)
		end
	end
end

function TileManager:render()
	-- Update all tiles until we reach our frame calculation budget
	cost = 0
	while cost < self.budget do	
		for i=1,(self.tilesX * self.tilesY) do
			cost += 1 + self.tiles[i]:update()
		end
	end

	-- Draw everything to the screen
	for i=1,(self.tilesX * self.tilesY) do
		self:drawTile(self.tiles[i])
	end
end
