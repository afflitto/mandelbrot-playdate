#include "pd_api.h"

#define RENDER_REGION_ARGC 7

static PlaydateAPI* pd = NULL;
static int render_region(lua_State* L);
static int test(lua_State* L);
static float map(float value, float fromLow, float fromHigh, float toLow, float toHigh);
static void set_pixel(uint8_t* data, int x, int y, int rowbytes, uint8_t value);

int eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint32_t arg)
{
	pd = playdate;

	if(event == kEventInitLua)
	{
		pd->system->logToConsole("Hello from c!");
		const char* err;
		if(!pd->lua->addFunction(render_region, "c_render_region", &err))
		{
			pd->system->error("%s:%i: addFunction failed, %s", __FILE__, __LINE__, err);
		}
		if(!pd->lua->addFunction(test, "c_test", &err))
		{
			pd->system->error("%s:%i: addFunction failed, %s", __FILE__, __LINE__, err);
		}
	}

	return 0;
}

static int test(lua_State* L)
{
	pd->system->logToConsole("called test");
	return 0;
}

static int render_region(lua_State* L)
// c_render_region(image, float minx, float miny, float maxx, float maxy, int maxiteration, int threshold)
{
	// Sanity check args
	int argc = pd->lua->getArgCount();
	if(argc != RENDER_REGION_ARGC)
	{
		pd->system->error("%s:%i: render_region called with %i args instead of %i", __FILE__, __LINE__, argc, RENDER_REGION_ARGC);
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
	int threshold = pd->lua->getArgInt(argi++);


	// Get bitmap data
	int width = 0;
	int height = 0;
	int rowbytes = 0;
	int hasmask = 0;
	uint8_t* data;
	pd->graphics->getBitmapData(bitmap, &width, &height, &rowbytes, &hasmask, &data);

	// Render mandelbrot region to bitmap
	pd->graphics->pushContext(bitmap);
	pd->graphics->clear(kColorBlack);

	for(int py = 0; py < height; py++)
	{
		for(int px = 0; px < width; px++)
		{
			float x0 = map(px, 0.0f, (float)width, minx, maxx);
			float y0 = map(py, 0.0f, (float)height, miny, maxy);
			
			float x = 0;
			float y = 0;
			int iteration = 0;
			while(x*x + y*y <= 2*2 && iteration <= maxiteration) 
			{
				float xtemp = x*x - y*y + x0;
				y = 2*x*y + y0;
				x = xtemp;
				iteration++;
			}

			if(iteration > maxiteration)
			{
				set_pixel(data, px, py, rowbytes, 1);
			} else {
				set_pixel(data, px, py, rowbytes, 0);
			}
		}
	}

	pd->graphics->popContext();
	return 0;
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