#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    int comm_sz, my_rank;

    MPI_Init(NULL, NULL);
    MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

    int *globaldata=NULL;
    int local_data;

    if (my_rank == 0) {
        globaldata = malloc(comm_sz * sizeof(int) );
        for (int i=0; i<comm_sz; i++)
            globaldata[i] = 2*i+1;

        printf("Proceso %d tiene datos : ", my_rank);
        for (int i=0; i<comm_sz; i++)
            printf("%d ", globaldata[i]);
        printf("\n");
    }

// {
    // void* send_data  :   buffer de envio d datos 
    // int send_count  :    Cantidad de datos enviados
    // MPI_Datatype send_datatype : Tipo de datos enviados
    // void* recv_data  :   buffer de recepcion d datos/con parte de los datos
    // int recv_count  :    Cantidad de datos recibidos
    // MPI_Datatype recv_datatype  :    tipo de datos
    // int root  :      Proceso raiz con los datos a repartir
    // MPI_Comm communicator :
// }

    MPI_Scatter(globaldata, 1, MPI_INT, &local_data, 1, MPI_INT, 0, MPI_COMM_WORLD);

    printf("Procesador %d tiene datos %d\n", my_rank, local_data);
    local_data *= 2;        //Se realiza una operacion en cada proceso
    printf("Proceso %d duplica los datos, ahora tiene %d\n", my_rank, local_data);

    MPI_Gather(&local_data, 1, MPI_INT, globaldata, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if (my_rank == 0) {
        printf("Procesador %d tiene datos : ", my_rank);
        for (int i=0; i<comm_sz; i++)
            printf("%d ", globaldata[i]);
        printf("\n");
    }

    MPI_Finalize();
    return 0;
}
