import "CoreLibs/object"

local geo <const> = playdate.geometry

-- DEMO:
-- local img = gfx.image.new(64, 64, gfx.kColorBlack)
-- local xformToWorld = playdate.geometry.affineTransform.new()
-- local imgWorldWidth = 0.33
-- local imgWorldHeight = 0.33
-- local imgWidth, imgHeight = img:getSize()
-- xformToWorld:scale(
-- 	imgWorldWidth / imgWidth, -- x range / image width
-- 	imgWorldHeight / imgHeight -- y range / image height
-- )
-- -- translate to where we wanna draw in world coords
-- local worldX = 0.5
-- local worldY = 0.5
-- xformToWorld:translate(worldX, worldY)
-- local xformToScreen = xformToWorld:copy()
-- -- if x/y mins are not 0, translate by that amount i guess
-- local worldXMin = -1
-- local worldYMin = -1
-- local worldWidth = 2.0
-- local worldHeight = 2.0
-- xformToWorld:translate(-worldXMin, -worldYMin)
-- local screenWidth, screenHeight = playdate.display.getSize()
-- xformToWorld:scale(
-- 	screenWidth / worldWidth,
-- 	screenHeight / worldHeight
-- )
-- img:drawWithTransform(xformToWorld, 0, 0)


class("Camera").extends()
function Camera:init(minX, minY, maxX, maxY)
	self.minX = minX
	self.maxX = maxX
	self.minY = minY
	self.maxY = maxY

	self.screenXform = self:getScreenXform()
end

function Camera:drawTile(tile)
	local xform = tile:getWorldXform() * self.screenXform
	tile.buffer:drawWithTransform(xform, 0, 0)
end

function Camera:getScreenXform()
	local screenWidth, screenHeight = playdate.display.getSize()
	local xform = geo.affineTransform.new()
	xform:translate(-self.minX, -self.minY)
	xform:scale(
		screenWidth / (self.maxX - self.minX),
		screenHeight / (self.maxY - self.minY)
	)
	return xform
end

function Camera:translate(x, y)
	local xform = geo.affineTransform.new()
	xform:translate(x, y)
	self.minX, self.minY = xform:transformXY(self.minX, self.minY)
	self.maxX, self.maxY = xform:transformXY(self.maxX, self.maxY)
	self.screenXform = self:getScreenXform()
end

function Camera:scale(sx, sy)
	local xform = geo.affineTransform.new()
	xform:scale(sx, sy)
	self.minX, self.minY = xform:transformXY(self.minX, self.minY)
	self.maxX, self.maxY = xform:transformXY(self.maxX, self.maxY)
	self.screenXform = self:getScreenXform()
end