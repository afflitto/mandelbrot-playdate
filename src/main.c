#include "pd_api.h"

#define RENDER_REGION_ARGC 5

static PlaydateAPI* pd = NULL;
static int render_region(lua_State* L);

int eventHandler(PlaydateAPI* playdate, PDSystemEvent event, uint32_t arg)
{
	pd = playdate;

	if(event == kEventInitLua)
	{
		const char* err;
		if(!pd->lua->addFunction(render_region, "tile.render_region_c", &err))
		{
			pd->system->error("%s:%i: addFunction failed, %s", __FILE__, __LINE__, err);
		}
	}

	return 0;
}

static int render_region(lua_State* L)
{
	// Sanity check args
	int argc = pd->lua->getArgCount();
	if(argc != RENDER_REGION_ARGC)
	{
		pd->system->error("%s:%i: render_region called with %i args instead of %i", __FILE__, __LINE__, argc, RENDER_REGION_ARGC);
	}
	for(int i = 0; i < argc; i++)
	{
		if(pd->lua->argIsNil(i))
		{
			pd->system->error("%s:%i: render_region argument %i is nil!", __FILE__, __LINE__, i);
		}
	}

	// Get args
	LCDBitmap* bitmap = pd->lua->getBitmap(0);
	float minx = pd->lua->getArgFloat(1);
	float miny = pd->lua->getArgFloat(2);
	float maxx = pd->lua->getArgFloat(3);
	float maxy = pd->lua->getArgFloat(4);

	// Get bitmap data
	int width = 0;
	int height = 0;
	int rowbytes = 0;
	int hasmask = 0;
	uint8_t** data;
	pd->graphics->getBitmapData(bitmap, &width, &height, &rowbytes, &hasmask, data);
	pd->system->logToConsole("render_region bitmap data: width=%i height=%i rowbytes=%i hasmask=%i", width, height, rowbytes, hasmask);

	return 0;
}