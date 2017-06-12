#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <string.h>
// gcc -g -Wall -fopenmp -o m program_5_3.c 
// ./m <num_hilos> <tam>\n

int num_aleatorio() {
   int numero = random() % 200;
   return numero;
}

void create_vec(int * a, int n) {
   int i;
   for (i = 0; i < n; ++i) {  
      a[i] = num_aleatorio();
   }
}

void print_vec(int * a, int n) {
   int i;
   for (i = 0; i < n; ++i) {
      printf("%d ", a[i]);
   }
   printf("\n");
}

int main(int argc, char* argv[]) {
   int num_hilos, i, j, tam; 
   int count;

   num_hilos = strtol(argv[1], NULL, 10);
   tam = strtol(argv[2], NULL, 10);
   
   int * Vec = malloc(tam* sizeof(int));
   create_vec(Vec, tam);
   print_vec(Vec, tam);

   int * temp = malloc(tam* sizeof(int));
   // double start = omp_get_wtime();
   
#pragma omp parallel for num_threads(num_hilos) \
   default(none) private(i, j, count) shared(Vec, tam, temp, num_hilos)
      for (i = 0; i < tam; i++) {
         count = 0;
         for (j = 0; j < tam; j++)
            if (Vec[j] < Vec[i])       //Uno con todos
               count++;
            else if (Vec[j] == Vec[i] && j < i) //Si es = , pero esta en otra posicion
               count++;

         temp[count] = Vec[i];      //El comparado ,coloca en un tmp
      }
   memcpy ( Vec , temp, tam * sizeof(int));
   // double finish = omp_get_wtime();
   
   // printf("Tiempo estimado %e segundos\n", finish - start);
   print_vec(Vec, tam);
   free(temp );
   return 0;

}

