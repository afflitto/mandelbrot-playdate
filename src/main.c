#include "pd_api.h"
#include "tile.h"

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
		if(!pd->lua->addFunction(update_cell_step, "update_cell_step", &err))
		{
			pd->system->error("%s:%i: addFunction failed, %s", __FILE__, __LINE__, err);
		}
		if(!pd->lua->addFunction(test, "c_test", &err))
		{
			pd->system->error("%s:%i: addFunction failed, %s", __FILE__, __LINE__, err);
		}

		register_tile(pd);
	}

	return 0;
}

static int test(lua_State* L)
{
	pd->system->logToConsole("called test");
	return 0;
}