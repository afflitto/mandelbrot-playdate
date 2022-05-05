#include <stddef.h>
#include "pd_api.h"
#include "tile.h"

typedef struct {
	float x;
	float y;
	uint8_t iteration;
	uint8_t solved;
} cell_t;

typedef struct {
	cell_t* cells;
	int cells_x;
	int cells_y;
} tile_context_t;

static int ctx_newobject(lua_State* L);
static int ctx_gc(lua_State* L);
static void set_pixel(uint8_t* data, int x, int y, int rowbytes, uint8_t value);
static float map(float value, float fromLow, float fromHigh, float toLow, float toHigh);

static PlaydateAPI* pd = NULL;

static int ctx_newobject(lua_State* L)
{
	int cells_x = pd->lua->getArgInt(1);
	int cells_y = pd->lua->getArgInt(2);

	tile_context_t* ctx = pd->system->realloc(NULL, sizeof(tile_context_t));
	ctx->cells_x = cells_x;
	ctx->cells_y = cells_y;
	ctx->cells = pd->system->realloc(NULL, sizeof(cell_t) * cells_x * cells_y);

	for(int i=0; i < cells_x * cells_y; i++)
	{
		cell_t* cell = ctx->cells + i;
		cell->x = 0.0f;
		cell->y = 0.0f;
		cell->iteration = 0;
		cell->solved = 0;
	}

	pd->lua->pushObject(ctx, "tile_context", 0);
	return 1;
}

static int ctx_gc(lua_State* L)
{
	tile_context_t* tile_context = pd->lua->getArgObject(1, "tile_context", NULL);

	if(tile_context != NULL)
	{
		pd->system->realloc(tile_context->cells, 0);
		pd->system->realloc(tile_context, 0);
	}

	return 0;
}

static const lua_reg tile_context_lib[] =
{
	{"new", ctx_newobject},
	{"__gc", ctx_gc},
};

void register_tile(PlaydateAPI* playdate)
{
	pd = playdate;
	const char* err;
	if(!pd->lua->registerClass("tile_context", tile_context_lib, NULL, 0, &err))
	{
        pd->system->logToConsole("%s:%i: registerClass failed, %s", __FILE__, __LINE__, err);
	}
}

int update_cell_step(lua_State* L)
// c_render_region(image, float minx, float miny, float maxx, float maxy, int maxiteration, tile_context_t tile_context)
{
	// Sanity check args
	int argc = pd->lua->getArgCount();
	if(argc != 7)
	{
		pd->system->error("%s:%i: render_region called with %i args instead of %i", __FILE__, __LINE__, argc, 7);
	}
	for(int i = 1; i <= argc; i++)
	{
		if(pd->lua->argIsNil(i))
		{
			pd->system->error("%s:%i: render_region argument %i is nil!", __FILE__, __LINE__, i);
		}
	}

	// Get args
	int argi = 1;
	LCDBitmap* bitmap = pd->lua->getBitmap(argi++);
	float minx = pd->lua->getArgFloat(argi++);
	float miny = pd->lua->getArgFloat(argi++);
	float maxx = pd->lua->getArgFloat(argi++);
	float maxy = pd->lua->getArgFloat(argi++);
	int maxiteration = pd->lua->getArgInt(argi++);
	tile_context_t* ctx = pd->lua->getArgObject(argi++, "tile_context", NULL);
	cell_t* cells = ctx->cells;
	uint32_t cost = 0;

	// Get bitmap data
	int width = 0;
	int height = 0;
	int rowbytes = 0;
	int hasmask = 0;
	uint8_t* data;
	pd->graphics->getBitmapData(bitmap, &width, &height, &rowbytes, &hasmask, &data);

	// Render mandelbrot region to bitmap
	pd->graphics->pushContext(bitmap);
	for(int py = 0; py < height; py++)
	{
		for(int px = 0; px < width; px++)
		{
			cell_t* cell = cells + py * ctx->cells_x + px;

			if(cell->solved) {
				continue;
			}

			float x = cell->x;
			float y = cell->y;
			float x0 = map(px, 0.0f, (float)width, minx, maxx);
			float y0 = map(py, 0.0f, (float)height, miny, maxy);

			cell->x = x*x - y*y + x0;
			cell->y = 2*x*y + y0;
			cell->iteration += 1;
			cost += 1;

			if(cell->x*cell->x + cell->y*cell->y >= 2*2)
			{
				cell->solved = 1;
				set_pixel(data, px, py, rowbytes, 0);
			}

			if(cell->iteration > maxiteration)
			{
				cell->solved = 1;
				set_pixel(data, px, py, rowbytes, 1);
			}
		}
	}

	pd->graphics->popContext();
	pd->lua->pushInt(cost);
	return 1;
}

static void set_pixel(uint8_t* data, int x, int y, int rowbytes, uint8_t value)
{
	//The data is 1 bit per pixel packed format, in MSB order; in other words, the high bit 
	//of the first byte in data is the top left pixel of the image.
	int byte_index = y * rowbytes + x / 8;
	int bit_index = 7 - x % 8;

	if(value == 0) {
		data[byte_index] &= ~(1 << bit_index);
	} else {
		data[byte_index] |= 1 << bit_index;
	}
}

static float map(float value, float fromLow, float fromHigh, float toLow, float toHigh)
{
	float fromDelta = fromHigh - fromLow;
	float toDelta = toHigh - toLow;
	float ret = (value - fromLow) / fromDelta;
	ret = ret * toDelta;
	ret = ret + toLow;
	return ret;
}