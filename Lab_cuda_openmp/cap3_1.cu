#include <stdio.h>

__global__
void matrix_addkernel(float* A , float* B , float* C, int n)
{
   int i = threadIdx.x + blockDim.x * blockIdx.x;
   if(i < (n*n))
      C[i] = A[i] + B[i];
}

__global__
void matrix_addkernel_row(float * A , float * B , float * C, int n){
   int i = threadIdx.x + blockDim.x * blockIdx.x;
   if(i < n)
      for(int j =0 ; j < n ; ++j)
         C[i*n+j] = A[i*n+j] + B[i*n+j];

}

__global__
void matrix_addkernel_col(float * A , float * B , float * C, int n){
   int i = threadIdx.x + blockDim.x * blockIdx.x;
   if(i < n)
      for (int j = 0; j < n; ++j)
         C[j*n+i] = A[j*n+i] + B[j*n+i];
}

void sum_matrix(float* A, float* B, float* C, int n)
{
   int size = n*n*sizeof(float);
  
   float *dA, * dB , *dC;
   
   cudaMalloc((void**) &dA, size);
   cudaMalloc((void**) &dB, size);
   cudaMalloc((void**) &dC, size);

   cudaMemcpy(dA,A,size,cudaMemcpyHostToDevice);
   cudaMemcpy(dB,B,size,cudaMemcpyHostToDevice);

   //matrix_addkernel<<< ceil((float)n/256.0), 256>>>(dA, dB, dC,n);
   //matrix_addkernel_row<<< ceil((float)n/256.0), 256>>>(dA, dB, dC,n);
   matrix_addkernel_col<<< ceil((float)n/256.0), 256>>>(dA, dB, dC,n);
   
   cudaMemcpy(C,dC,size,cudaMemcpyDeviceToHost);

   cudaFree(dA);
   cudaFree(dB);
   cudaFree(dC);
   
}

int main(int argc, char* argv[])
{
   int n ;
   n = strtol(argv[1], NULL, 10); 
   
   float * h_a, * h_b, * h_c;
   int size = n*n*sizeof(float);
   h_a = (float*)malloc(size);
   h_b = (float*)malloc(size);
   h_c = (float*)malloc(size);

   printf ("Matriz A \n");
   for(int i = 0 ; i < n ; i++){
      for(int j = 0 ; j < n ; j++){
         h_a[i*n +j] = rand() % 100;
         printf ("%4.2f \t", h_a[i*n +j]);
      }
      printf ("\n");
   }
   printf ("Matriz B \n");
   for(int i = 0 ; i < n ; ++i){
      for(int j = 0 ; j < n ; ++j){
         h_b[i*n +j] = rand() % 100;
         printf ("%4.2f \t", h_b[i*n +j]);
      }
      printf ("\n");
   }
   
   sum_matrix(h_a, h_b, h_c, n);

   printf("RESULTADOS :\n");   
   for(int i = 0 ; i < n ; ++i){
      for(int j = 0 ; j < n ; ++j){
         printf ("%4.2f \t", h_c[j*n +i]);
      }
      printf ("\n");
   }
   
}
