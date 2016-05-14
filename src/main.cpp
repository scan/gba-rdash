#include <gba.h>

#define RGB16(r,g,b)  ((r)+(g<<5)+(b<<10))

static inline void PlotPixel(int x, int y, u16 c) {
  ((u16*) VRAM)[y * (SCREEN_WIDTH / 2) + x] = c; 
}

int main() {
	char x,y;
	u16* Screen = (u16*)VRAM;
	SetMode(MODE_4 | BG2_ON);

	// clear screen, and draw a blue back ground
	for(x = 0; x<240;x++)   //loop through all x
	{
		for(y = 0; y<160; y++)  //loop through all y
		{
			Screen[x+y*240] = RGB16(0,0,31);
		}
	}

	// draw a white HI on the background
	for(x = 20; x<=60; x+=15)
		for(y = 30; y<50; y++)
			Screen[x+y*240] = RGB16(31,31,31);
	for (x = 20; x < 35; x++)
		Screen[x+40*240] = RGB16(31,31,31);

	while(1){}	//loop forever
}
