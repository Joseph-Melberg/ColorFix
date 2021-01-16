#include "gpu.h"
#include <cuda.h>
#include <stdio.h>

uint32_t * gpuAlloc(int w, int h) {
	uint32_t* gpu_mem;

	cudaError_t err = cudaMalloc(&gpu_mem, w * h * sizeof(int));
	if ( err != cudaSuccess ) return NULL;

	return gpu_mem;
};

void checkError()
{
	cudaError_t error = cudaGetLastError();
  if(error != cudaSuccess)
  {
    // print the CUDA error message and exit
    printf("CUDA error: %s\n", cudaGetErrorString(error));
    exit(-1);
  }
}
void gpuFree(void* gpu_mem) {
	cudaFree(gpu_mem);
}
int gpuUp(void* src, void* dst,int size){
	cudaError_t err = cudaMemcpy(dst, src, size , cudaMemcpyHostToDevice);
	if ( err != cudaSuccess ) return 1;
	return 0;	
}
int gpuBlit(void* src, void* dst, int size){
	cudaError_t err = cudaMemcpy(dst, src, size , cudaMemcpyDeviceToHost);
	if ( err != cudaSuccess ) return 1;
	return 0;
}

// ----- 

__host__
__device__
uint32_t getPixColor(int x, int y) {
	return 0xFF000000 + x + y;
}
__device__ void extractRGB_kernel(uint32_t pixel,char& a, char &r, char &g, char &b)
{
	a = 0xFF & (pixel >> 24);
	r = 0xFF & (pixel >> 16);
	g = 0xFF & (pixel >> 8 );
	b = 0xFF &  pixel       ;
}

__device__ void infuseRGB_kernel(uint32_t& poxil, char a, char r, char g, char b)
{
	uint32_t a32 = (uint32_t) a;
	uint32_t r32 = (uint32_t) r;
	uint32_t g32 = (uint32_t) g;
	uint32_t b32 = (uint32_t) b;
	poxil =
	 (a32 << 24) & 0xFF000000 |
	 (r32 << 16) & 0x00FF0000 |
	 (g32 <<  8) & 0x0000FF00 |
	 (b32      ) & 0x000000FF;
}

__device__ void shift_kernel(uint32_t& value)
{
	char a, r, g, b;
	extractRGB_kernel(value,a,r,g,b);
	infuseRGB_kernel(value,a,g,r,b);

}

__global__ void my_kernel(uint32_t* buf,int w, int h) {
	const int xPix = blockDim.x * blockIdx.x + threadIdx.x;
	const int yPix = blockDim.y * blockIdx.y + threadIdx.y;
	unsigned int pos = w * yPix + xPix;
	if(xPix + yPix*w >= w * h || xPix >= w || yPix > h)
	{

	}
	else if(threadIdx.x == 0 || threadIdx.y == 0)
	{
		buf[pos] = 0xFF000000;
	}
	else 
	{
		if(xPix == 4 && yPix == 4)
		{
			printf("The value at 4,4 is %d\n", buf[pos]);
			char a,r,b,g;
			extractRGB_kernel(buf[pos],a,r,g,b);
			printf("The values are %d,%d,%d,%d\n",a,r,g,b);
		}
		 //char a,r,b,g; 
		uint32_t pixel = buf[pos];
		shift_kernel(pixel);
		///pixel |= 0xFF000000;
		
		buf[pos] = pixel;	
		if(xPix == 4 && yPix == 4)
		{
			printf("The value at 4,4 is %d\n", buf[pos]);
			char a,r,b,g;
			extractRGB_kernel(buf[pos],a,r,g,b);
			printf("The values are %d,%d,%d,%d\n",a,r,g,b);
		}

	}
	__syncthreads();
}

void gpuRender(uint32_t* buf, int w, int h) {
	checkError();

	printf("The output is %d by %d\n",w,h);
	int gridw = 1 + (w / TILE_WIDTH);
	int gridh = 1 + (h / TILE_HEIGHT);
	printf("Grid (w,h): (%d,%d)\n",gridw,gridh);
	checkError();
	printf("Readying dims\n");
	checkError();
	const dim3 blocksPerGrid(gridw,gridh);
	printf("Tiles are %d by %d\n",TILE_WIDTH , TILE_HEIGHT);
	const dim3 threadsPerBlock(TILE_WIDTH, TILE_HEIGHT);
	checkError();	
	printf("For real\n");
	printf("The image is %d by %d",w,h);
	my_kernel<<<blocksPerGrid, threadsPerBlock>>>(buf,w,h);
	checkError();
	cudaDeviceSynchronize();
	printf("Done\n");
	
}