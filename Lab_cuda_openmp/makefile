CC = /usr/local/cuda/bin/nvcc
SRC = gray.cu
OUT = gray
OPENCV = `pkg-config opencv --cflags --libs`
LIBS = $(OPENCV)
all:
	@echo [Compiling]: $(@:.o=.c)
	$(CC) $(SRC) -o $(OUT) $(LIBS)
	./$(OUT) entrada.png salida.png
clean:
	rm -r $(OUT)
