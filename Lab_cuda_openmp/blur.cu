#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <time.h>

#define BLUR_SIZE 3

using namespace cv;
using namespace std;

__global__
void blurKernel(unsigned char * in, unsigned char * out, int w, int h)
{
  int Col = blockIdx.x * blockDim.x + threadIdx.x;
  int Row = blockIdx.y * blockDim.y + threadIdx.y;
  if (Col < w && Row < h)
  {
    int pixVal = 0;
    int pixels = 0;
    // Get the average of the surrounding 2xBLUR_SIZE x 2xBLUR_SIZE box
    for(int blurRow = -BLUR_SIZE; blurRow < BLUR_SIZE+1; ++blurRow)
    {
      for(int blurCol = -BLUR_SIZE; blurCol < BLUR_SIZE+1; ++blurCol)
      {
        int curRow = Row + blurRow;
        int curCol = Col + blurCol;
        // Verify we have a valid image pixel
        if(curRow > -1 && curRow < h && curCol > -1 && curCol < w)
        {
          pixVal += in[curRow * w + curCol];
          pixels++; // Keep track of number of pixels in the accumulated total
        }
      }
    }
    // Write our new pixel value out
    out[Row * w + Col] = (unsigned char)(pixVal / pixels);
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

  unsigned char *dataRawImage;
  unsigned char *d_dataRawImage, *d_imageOutput;
  unsigned char *h_imageOutput;
  
  Size s = image.size();
  int width = s.width;
  int height = s.height;
  
  int size = sizeof(unsigned char) * width * height * image.channels();

  // Reservar memoria para los objetos en CPU
  dataRawImage = (unsigned char*)malloc(size);
  h_imageOutput = (unsigned char*)malloc(size);

  // Reservar memoria para d_dataRawImage
  cudaMalloc((void**)&d_dataRawImage, size);
  // Reservar memoria para la salida de la imegn
  cudaMalloc((void**)&d_imageOutput, size);

  // Obtenemos la data
  dataRawImage = image.data;
  startGPU = clock();
  
  // Copiar de dataRawImage a d_dataRawImage
  cudaMemcpy(d_dataRawImage, dataRawImage, size, cudaMemcpyHostToDevice);
   
  int blockSize = 32;
  dim3 dimBlock(blockSize, blockSize, 1);
  dim3 dimGrid(ceil(width / float(blockSize)), ceil(height / float(blockSize)), 1);
  
  blurKernel<<< dimGrid, dimBlock >>>(d_dataRawImage, d_imageOutput, width, height);
  cout << "Copiando ..." << endl;
  cudaMemcpy(h_imageOutput, d_imageOutput, size, cudaMemcpyDeviceToHost);
  
  endGPU = clock();
  
  Mat blurImg;
  blurImg.create(height, width, CV_8UC3);
  blurImg.data = h_imageOutput;

  // Guardar la imagen con el segundo parametro de llamada
  imwrite(argv[2], blurImg);

  gpu_time_used = ((double)(endGPU - startGPU)) / CLOCKS_PER_SEC;
  cout << "Tiempo Algoritmo en GPU: " << gpu_time_used << endl;

  cudaFree(d_dataRawImage);
  cudaFree(d_imageOutput);

  // free(blurImgCPU);
  free(h_imageOutput);

  return 0;
}
