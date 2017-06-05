#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>
// gcc -g -Wall -fopenmp -o m program_5_2.c 
// ./prog5_2 <num_hilos> <num_tiros>\n

double num_aleatorio() {
   double numero = (double) random() / (double) RAND_MAX;
   if((double) random() / (double) RAND_MAX < 0.5) {
      numero *= -1;
   }
   return numero;
}

int main(int argc, char* argv[]) {

   long int num_tiros;
   long int number_in_circle;
   int num_hilos, i;
   double x, y, distancia;

   num_hilos = strtol(argv[1], NULL, 10);
   num_tiros = strtoll(argv[2], NULL, 10);

   number_in_circle = 0;
   srandom(0);
#  pragma omp parallel for num_threads(num_hilos) \
      reduction(+: number_in_circle) private(x, y, distancia)
   for (i = 0; i < num_tiros; i++) {
      x = num_aleatorio();             // Genera numero entre -1 y 1
      y = num_aleatorio();
      distancia = x*x + y*y;           //Distancia al cuadrado

      if (distancia <= 1) 
         number_in_circle++;
      
   }

   double pi_val = 4*number_in_circle/((double) num_tiros);
   printf("Valor de pi = %.14f\n", pi_val);
   return 0;
}
