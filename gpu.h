#pragma once

#include <stdint.h>

#include "const.h"

uint32_t * gpuAlloc(int w, int h) ;
void gpuFree(void* gpu_mem);
int gpuBlit(void* src, void* dst, int size);
int gpuUp(void* src, void* dst, int size);
void checkError();
void gpuRender(uint32_t* buf, int w, int h);