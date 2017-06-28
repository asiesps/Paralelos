#include <cuda.h>
#include <iostream>
using namespace std;
#define TILE_WIDTH 64
// #define Height 1024
// #define Width 1024
int Width = 1024 ;
int Height = 1024 ;
using namespace std;
float aleatorio(){
  return random()/((double) RAND_MAX);
}

void llenar_matriz(float* M) {
  for(int i = 0; i < Height; i++) {
    for(int j = 0; j < Width; j++) {
      M[i * Width + j] = 1;
    }
  }
}

void Matrix_mult(float* A, float* B,float* C) {
  float tmp = 0;
  for(int i = 0; i < Height; i++) {
    for(int j = 0; j < Width; j++) {
      tmp = 0;
      for(int k=0; k < Width; k++)
        tmp += A[i * Width + k] * B[k * Width + j];
     C[i * Width + j] = tmp;
    }
  }

}

void print_matriz(float* v) {
  for(int i = 0; i < Height; i++){
    for(int j = 0; j < Width; j++){
      cout << v[i * Width + j] << " ";
    }
    cout << endl;
  }
}

__global__
void MatrixMulKernel_Tailed(float* M, float* N, float* P,int Width){
  __shared__ float ds_M[TILE_WIDTH][TILE_WIDTH];
  __shared__ float ds_N[TILE_WIDTH][TILE_WIDTH];
  int bx = blockIdx.x; 
  int by = blockIdx.y;
  int tx = threadIdx.x; 
  int ty = threadIdx.y;

  int Row = by * TILE_WIDTH + ty;
  int Col = bx * TILE_WIDTH + tx;

  float Pvalue = 0;
  // Loop over the M and N tiles required to compute the P element
  for (int ph = 0; ph < Width/TILE_WIDTH; ++ph) {    

    // ph representa el índice de mosaico que se encuentra, 
    // por lo que ph * T_Wle dará el índice x-global del primer thread en un bloque. 
    // Dentro de cada bloque, los hilos tienen sus propios índices y por lo tanto
    // es necesario añadir el x-índice del thread dentro de ese bloque. 
    // Por lo que tiene p * T_W + tx.
    // Collaborative loading of M and N tiles into shared memory
    ds_M[ty][tx] = M[Row*Width + ph*TILE_WIDTH+tx];    //ph=indice del azulejo
    ds_N[ty][tx] = N[(ph*TILE_WIDTH+ty)*Width + Col];  

    __syncthreads();

    for (int i = 0; i < TILE_WIDTH; ++i)
      Pvalue += ds_M[ty][i] * ds_N[i][tx];

    __syncthreads();
  }
  P[Row*Width+Col] = Pvalue;
}

int main() {
  clock_t inicio,fin;
  double tiempo_cpu;

  // Separo espacio de memoria para las variables en host
  float* A = new float[Height*Width];
  float* B = new float[Height*Width];
  float* C = new float[Height*Width];
  float* CC = new float[Height*Width];

  llenar_matriz(A);
  llenar_matriz(B);
// ========================================================
  // inicio = clock();
  // print_matriz(A);
  // print_matriz(B);
  cout << endl;
  // Matrix_mult(A, B, C);
  // // print_matriz(C);

  // fin = clock();
  // tiempo_cpu = ((double)(fin - inicio)) / CLOCKS_PER_SEC;
  // cout << "Tiempo en CPU : " << tiempo_cpu << endl;

// ========================================================

  float *d_A, *d_B, *d_C;
  float blockSize = TILE_WIDTH;

  dim3 dimBlock(blockSize, blockSize);
  dim3 dimGrid(ceil(Width/float(blockSize)), ceil(Height/float(blockSize)), 1);
  
  int size = sizeof(float)*Height*Width;

  cudaMalloc((void**)&d_A, size);
  cudaMalloc((void**)&d_B, size);
  cudaMalloc((void**)&d_C, size);

  inicio = clock();
  cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);

  MatrixMulKernel_Tailed<<<dimGrid, dimBlock>>>(d_A, d_B, d_C,Width);
  cudaMemcpy(CC, d_C, size, cudaMemcpyDeviceToHost);

  fin = clock();
  tiempo_cpu = ((double)(fin - inicio))/CLOCKS_PER_SEC;
  cout << "Tiempo en GPU : " << tiempo_cpu << endl;
  print_matriz(CC);
  delete A; delete B;
  delete C; delete CC;

  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_C);
}
