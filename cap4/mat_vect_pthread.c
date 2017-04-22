#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include "timer.h"

int     limite;
int     m, n;
double* M;
double* x;
double* y;

void llenar_matriz(double M[], int m, int n) {
      int i, j;
      for (i = 0; i < m; i++)
            for (j = 0; j < n; j++)
                  M[i*n+j] = random()/((double) RAND_MAX);
}

void llenar_vec(double x[], int n) {
      int i;
      for (i = 0; i < n; i++)
            x[i] = random()/((double) RAND_MAX);
}

void Print_matrix( char* name, double M[], int m, int n) {
      int   i, j;

      printf("%s\n", name);
      for (i = 0; i < m; i++) {
            for (j = 0; j < n; j++)
                  printf("%6.3f ", M[i*n + j]);
      printf("\n");
   }
}
void Print_vector(char* name, double y[], double m) {
      int   i;

      printf("%s\n", name);
      for (i = 0; i < m; i++)
            printf("%6.3f ", y[i]);
      printf("\n");
}

void *Pth_mat_vect(void* rank) {
      long my_rank = (long) rank;
      int i,j;
      int local_m = m/limite; 
      int my_first_row = my_rank*local_m;
      int my_last_row = my_first_row + local_m;
      register int sub = my_first_row*n;
      double inicio, fin ;
      double temp;

      GET_TIME(inicio);
      for (i = my_first_row; i < my_last_row; i++) {
            y[i] = 0.0;
            for (j = 0; j < n; j++) {
                  temp = M[sub++];
                  temp *= x[j];
                  y[i] += temp;
            }
      }
      GET_TIME(fin);
      printf("Thread %ld > tiempo transcurrido = %e seconds\n", my_rank, fin - inicio);

      return NULL;
      }

int main(int argc, char* argv[]) {
      long       thread;
      pthread_t* thread_handles;
      
      printf("\nSe crearan %s hilos\n",argv[1]);
      limite= atoi(argv[1]);
      m = strtoll(argv[2], NULL, 10);
      n = strtoll(argv[3], NULL, 10);

      printf("limite =  %d, m = %d, n = %d\n", limite, m, n);

      thread_handles = malloc(limite*sizeof(pthread_t));
      M = malloc(m*n*sizeof(double));
      x = malloc(n*sizeof(double));
      y = malloc(m*sizeof(double));
      
      llenar_matriz(M, m, n);
      // Print_matrix("We generated", A, m, n); 

      llenar_vec(x, n);
      // Print_vector("We generated", x, n); 

      for (thread = 0; thread < limite; thread++)
            pthread_create(&thread_handles[thread], NULL, Pth_mat_vect, (void*) thread);

      for (thread = 0; thread < limite; thread++)
            pthread_join(thread_handles[thread], NULL);

      // Print_vector("The product is", y, m); 


      free(M);
      free(x);
      free(y);

      return 0;
}