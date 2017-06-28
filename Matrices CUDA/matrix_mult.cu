#include <cuda.h>
#include <iostream>
using namespace std;

// #define Height 32768
// #define Width 32768
int Width = 10240  ;
int Height = 10240 ;
using namespace std;
float aleatorio(){
  return random()/((double) RAND_MAX);
}

void llenar_matriz(float* M) {
  for(int i = 0; i < Height; i++) {
    for(int j = 0; j < Width; j++) {
      M[i*Width + j] = 1;
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
void MatrixMulKernel(float* M, float* N, float* P,int Width) {
  // Calculate the row index of the P element and M
  int Row = blockIdx.y*blockDim.y+threadIdx.y;
  // Calculate the column index of P and N
  int Col = blockIdx.x*blockDim.x+threadIdx.x;

  if ((Row < Width) && (Col < Width)) {
    float Pvalue = 0;
    // each thread computes one element of the block sub-matrix
    for (int k = 0; k < Width; ++k) {
      Pvalue += M[Row*Width+k]*N[k*Width+Col];
    }
    P[Row*Width+Col] = Pvalue;
  }
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
  // // print_matriz(A);
  // // print_matriz(B);
  // Matrix_mult(A, B, C);
  // // print_matriz(C);

  // fin = clock();
  // tiempo_cpu = ((double)(fin - inicio)) / CLOCKS_PER_SEC;
  // cout << "Tiempo en CPU : " << tiempo_cpu << endl;

// ========================================================
  float *d_A, *d_B, *d_C;
  float size_block = 64;

  dim3 dimBlock(size_block, size_block);
  dim3 dimGrid(ceil(Width / float(size_block)), ceil(Height / float(size_block)), 1);
  
  int size = sizeof(float)*Height*Width;

  cudaMalloc((void**)&d_A, size);
  cudaMalloc((void**)&d_B, size);
  cudaMalloc((void**)&d_C, size);

  inicio = clock();
  cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);

  MatrixMulKernel<<<dimGrid, dimBlock>>>(d_A, d_B, d_C, Width);
  cudaMemcpy(CC, d_C, size, cudaMemcpyDeviceToHost);
  // print_matriz(CC);
  fin = clock();
  tiempo_cpu = ((double)(fin - inicio))/CLOCKS_PER_SEC;
  cout << "Tiempo en GPU : " << tiempo_cpu << endl;

  delete A; delete B;
  delete C; delete CC;

  cudaFree(d_A);
  cudaFree(d_B);
  cudaFree(d_C);
}
