.PHONY = all 
CC := nvcc
CFLAGS := 
FLAGS := -lSDL2_image -lSDL2 -lGLU -lglut -lGL 
OBJFILES := gpu.o window.o 
TARGET := fix

all: ${TARGET}

${TARGET}: ${OBJFILES}
	${CC} -o ${TARGET} ${OBJFILES} ${FLAGS}

gpu.o : gpu.cu gpu.h const.h 
	${CC} $(CFLAGS) -c gpu.cu 