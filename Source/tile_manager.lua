import "CoreLibs/object"
import "camera"
import "tile"


class("TileManager").extends("Camera")
function TileManager:init(minX, minY, maxX, maxY, tilesX, tilesY, budget)
	TileManager.super.init(self, minX, minY, maxX, maxY)
	self.tilesX = tilesX
	self.tilesY = tilesY
	self.tiles = {}
	self.budget = budget
	self.last_tile = 1

	local worldWidth = maxX - minX
	local worldHeight = maxY - minY
	for i=0,(tilesY-1) do
		for j=0,(tilesX-1) do
			local tileWorldWidth = worldWidth / tilesX
			local tileWorldHeight = worldHeight / tilesY
			local tileMinX = tileWorldWidth * j + minX
			local tileMinY = tileWorldHeight * i + minY
			self.tiles[i * tilesX + j + 1] = Tile(
				tileMinX,
				tileMinX + tileWorldWidth,
				tileMinY,
				tileMinY + tileWorldHeight
			)
		end
	end
end

function TileManager:render()
	-- Plot mandelbrot until we reach our frame calculation budget
	cost = 0
	while cost < self.budget and self.last_tile <= self.tilesX * self.tilesY do
		cost += self.tiles[self.last_tile]:update() + 100
		self.last_tile += 1
	end
	if self.last_tile > self.tilesX * self.tilesY then
		self.last_tile = 1
	end	

	-- Draw everything to the screen
	for i=1,(self.tilesX * self.tilesY) do
		self:drawTile(self.tiles[i])
	end
end