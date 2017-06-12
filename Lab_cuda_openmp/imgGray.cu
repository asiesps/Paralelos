#include <iostream>
#include </usr/include/opencv2/core/core.hpp>
#include </usr/include/opencv2/highgui/highgui.hpp>
#include <time.h>

#define CHANNELS 3

using namespace cv;
using namespace std;

__global__
void imgGrayGPU(unsigned char *imageInput, unsigned char *imageOutput, int width, int height) {
  int col = blockIdx.x * blockDim.x + threadIdx.x;
  int row = blockIdx.y * blockDim.y + threadIdx.y;

  if ((col < width) and (row < height)) {
    int grayOffset = row * width + col;
    int rgbOffset = grayOffset * CHANNELS;

    unsigned char b = imageInput[rgbOffset + 0];
    unsigned char g = imageInput[rgbOffset + 1];
    unsigned char r = imageInput[rgbOffset + 2];

    imageOutput[grayOffset] = 0.21f * r + 0.71f * g + 0.07f * b;
  }
}

int main(int argc, char** argv) {
  
  clock_t startGPU, endGPU;
  double gpu_time_used;
  if (argc < 3){
    cout << "USO : " << argv[0] << " <entrada.png>" << " <salida.png>" << endl;
    exit(1);
  }

  Mat image;
  // Cargamos la imagen pasada por primer parametro
  image = imread(argv[1], CV_LOAD_IMAGE_COLOR);

  unsigned char *dataImage;
  unsigned char *d_dataImage, *d_imageOutput;
  unsigned char *h_imageOutput;
  Size s = image.size();

  int width = s.width;
  int height = s.height;

  int size = sizeof(unsigned char) * width * height * image.channels();
  int sizeGray = sizeof(unsigned char) * width * height;

  dataImage = (unsigned char*)malloc(size);
  h_imageOutput = (unsigned char*)malloc(sizeGray);

  // Reservar memoria para d_dataImage
  cudaMalloc((void**)&d_dataImage, size);
// Reservar memoria para la salida de la imegn
  cudaMalloc((void**)&d_imageOutput, sizeGray);

  dataImage = image.data;
  startGPU = clock();
  // Copiar de dataImage a d_dataImage
  cudaMemcpy(d_dataImage, dataImage, size, cudaMemcpyHostToDevice);
    
  int blockSize = 16;
  dim3 dimBlock(blockSize, blockSize, 1);
  dim3 dimGrid(ceil(width / float(blockSize)), ceil(height / float(blockSize)), 1);
  imgGrayGPU<<< dimGrid, dimBlock >>>(d_dataImage, d_imageOutput, width, height);
  cudaMemcpy(h_imageOutput, d_imageOutput, sizeGray, cudaMemcpyDeviceToHost);
  endGPU = clock();

  Mat grayImg;
  grayImg.create(height, width, CV_8UC1);
  grayImg.data = h_imageOutput;

  // Guardar la imagen con el segundo parametro de llamada
  imwrite(argv[2], grayImg);

  gpu_time_used = ((double)(endGPU - startGPU)) / CLOCKS_PER_SEC;
  cout << "Tiempo Algoritmo en GPU: " << gpu_time_used << endl;

  cudaFree(d_dataImage);
  cudaFree(d_imageOutput);

  // free(dataImage);
  free(h_imageOutput);

  return 0;
}
