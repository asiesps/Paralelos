#include <mpi.h>
#include <stdio.h>

double f(double x) {
   return x*x;
}

double Trap(double val_izq , double val_der ,int trap_count  , double altura ) {
   double integral, x; 
   int i;

// Hallar el area del trapecio
   integral = (f(val_izq) + f(val_der))/2.0;    //
//    printf("integ : %f \n",integral);
   for (i = 1; i <= trap_count-1; i++) {
      x = val_izq + i*altura;       //area de 1 trapecio
      integral += f(x);             //area de conjunto de trapecios
   }
   integral = integral*altura;

   return integral;
}

int main(void) {
   int my_rank, comm_sz, n = 12, local_n;   
   double a = 0.0, b = 3.0, h, local_a, local_b;
   double local_int, total_int;
   int source; 

   MPI_Init(NULL, NULL);
   MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);  
   MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);

   h = (b-a)/n;             // ancho o altura de los trapecios         
   local_n = n/comm_sz;     // Numero de trapecios

// Dividimos los intervalos de integracion, 
// entre los procesos, deacuerdo al numero de trapecios
   local_a = a + my_rank*local_n*h;     //l_n* h = intervalo de integracion
   local_b = local_a + local_n*h;       //Desde A, hasta su intervalo de integracion
   
   //almacena la integral temporal de un conjunto de trapecios
   local_int = Trap(local_a, local_b, local_n, h );     
   
   if (my_rank != 0) { 
      MPI_Send(&local_int, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD); 
      printf("Cero - Soy el proceso: %d y envio esta data: %f \n",my_rank,local_int);
   } 
   else {
      total_int = local_int;
      for (source = 1; source < comm_sz; source++) {        // ?
        printf("Soy el proceso: %d y recibo esta data: %f \n",my_rank,total_int);
         MPI_Recv(&local_int, 1, MPI_DOUBLE, source, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
         total_int += local_int;
      }
   } 

   if (my_rank == 0) {
      printf("Con n = %d trapezoides ", n);
      printf("la integral de %f a %f = %.15e\n", a, b, total_int);
   }

   MPI_Finalize();

   return 0;
} 
