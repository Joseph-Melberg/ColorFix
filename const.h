#define SCREEN_WIDTH 500 
#define SCREEN_HEIGHT 500 
#define TILE_WIDTH 32
#define TILE_HEIGHT 16 
#define H_TILES (1 + SCREEN_WIDTH  / TILE_WIDTH)
#define V_TILES (1 + SCREEN_HEIGHT / TILE_HEIGHT)
#define SCREEN_SIZE (SCREEN_WIDTH * SCREEN_HEIGHT)
#define ALPHA_MASK 0xFF000000
#define RED_MASK   0x00FF0000
#define GREEN_MASK 0x0000FF00
#define BLUE_MASK  0x000000FF