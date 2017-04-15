#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>     //sleep
void* hilo(){

    printf("\nsoy un hilo de INFORMATICAPARATODOS...no haga nada :\n");

}

int main(int argc, char * argv[]) {
    int i;
    pthread_t hiloescribir;

    printf("Argument: %d \n",argc);
    printf("\nSe crearan %s hilos",argv[1]);
    int limite= atoi(argv[1]);

    printf("limitee : %d \n",limite);
    for(i=0; i < limite ; i++)
    {
        pthread_create(&hiloescribir,NULL,hilo,NULL);
        // sleep(0);
    }

}
