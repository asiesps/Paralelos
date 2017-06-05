#include <stdio.h>     

__global__
void matrixVectorKernel(float* A, float* B, float* C, int n)
{
	int i = threadIdx.x + (blockDim.x * blockIdx.x);

	if(i<n){
	C[i] = 0;
	for(int j=0;j<n;j++)
		 C[i] += A[i*n+j] * B[j];
	}
	
}

void matrixVector(float* A, float* B, float* C, int n)
{
	int sizeA = (n*n) * sizeof(float);
	int size =  n * sizeof(float);
	float *d_A,*d_B,*d_C;

	cudaMalloc((void**)&d_A,sizeA);
	cudaMalloc((void**)&d_B,size);
	cudaMalloc((void**)&d_C,size);

	cudaMemcpy(d_A,A,sizeA,cudaMemcpyHostToDevice);
	cudaMemcpy(d_B,B,size,cudaMemcpyHostToDevice);

	matrixVectorKernel<<<ceil(n/256.0),256>>>(d_A,d_B,d_C,n);
	cudaMemcpy(C,d_C,size,cudaMemcpyDeviceToHost);

	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
}

int main(int argc, char* argv[])
{
	int n ;
	n = strtol(argv[1], NULL, 10); 
	
	float *h_a,*h_b,*h_c;
	int size = n*n*sizeof(float);
	int size_v = n*sizeof(float);
	h_a = (float*)malloc(size);
	h_b = (float*)malloc(size_v);
	h_c = (float*)malloc(size_v);

	printf ("Matriz A \n");
	for(int i = 0 ; i < n ; i++){
		for(int j = 0 ; j < n ; j++){
			h_a[i*n +j] = rand() % n + 1;
			printf ("%4.2f \t", h_a[i*n +j]);
		}
		printf ("\n");
   	}

   	printf ("Vector B \n");
	for(int i = 0 ; i < n ; i++){
		h_b[i] = rand() % n + 1;
		printf ("%4.2f \t", h_b[i]);
	}

    matrixVector(h_a, h_b, h_c, n);
    
    printf("Vector Resultado\n");
    for(int i = 0; i < n; i++){
    	printf(" %f \n", h_c[i]);
  	}
  	printf("\n");

   	return 0;
}
