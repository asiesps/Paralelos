#include <omp.h>
#include <iostream>
#include <vector>
#include <stdio.h>
#include <stdlib.h>

using namespace std;
/*
gcc -g  -Wall  -fopenmp -o omp_hello omp_hello.c
./omp_hello 6
*/
int thread_count;
void generar_aleatorios(vector<float>&data, float ini, float fin , int cantidad){
	for (int i = 0; i < cantidad; ++i){
		data.push_back(rand() /fin + ini);
	}
}
int Find_bin(float value_data, vector<float> bin_maxes , int bin_count, int min_meas){
	int posi =min_meas;				//posicion inicial

	for (int i = 0; i < bin_count; ++i){
		if(posi <= value_data && value_data <=bin_maxes[i]){
			//cout<<finl<<value_data<<" : "<<i<<finl;
			return i; 
		}
		else{
			posi =bin_maxes[i];

		}
	}
	cout<<"\nERROR\n";

}
void histograma(vector<float> &data, int bin_count){
	//bins: sub_intervalos
	//bin_count: numero de intervalos
	int data_count;
	float min_meas, max_meas, bin_width;
	vector<int> bin_counts;//tamanio de bin_count
	vector<float> bin_maxes;//tamanio de bin_count
	
	bin_counts.resize(bin_count);
	bin_maxes.resize(bin_count);
	data_count =data.size();

	//Hallamos al minimo valor y maximo
	min_meas =data[0];
	max_meas =data[0];
	for (size_t i = 1; i < data.size(); ++i){
		if(min_meas>data[i])
			min_meas =data[i];
		if(max_meas<data[i])
			max_meas =data[i];
	}
	cout<<"\nMinimo: "<<min_meas<<finl;
	cout<<"Maximo: "<<max_meas<<finl;

	//ahora bin_width toma el ancho de cada bin
	bin_width = (max_meas - min_meas)/bin_count;
	cout<<"\nbin_width: "<<bin_width<<finl;

	//hallamos los anchos maximos de cada bin
	for ( int b = 0; b < bin_count ; b ++)
		bin_maxes [b] = min_meas + bin_width *(b +1);

	cout<<"\nMostrar bin_maxes\n";
	for (int i = 0; i < bin_maxes.size(); ++i){
		cout<<bin_maxes[i]<<"\t";
	}
	
	//ahora llenamos el histograma
	int bin, i;
	#pragma omp parallel for num_threads(thread_count) default(none) \
	shared(data_count, data, bin_maxes, bin_count, min_meas, bin_counts) \
      private(bin, i)
	for (i = 0; i < data_count ; i++) {
		bin = Find_bin(data[i], bin_maxes ,bin_count, min_meas);
		#pragma omp critical
		bin_counts[bin]++;
	}

	cout<<"\nMostramos el histograma:\n";
	//mostramos el histograma
	for (int i = 0; i < bin_count; ++i){
		cout<<i<<": ";
		for (int j = 0; j < bin_counts[i]; ++j){
			cout<<"*";
		}
		cout<<finl;
	}

}

int main(int argc, char const *argv[])
{
	double inicio = omp_get_wtime( ); 
	// code
	vector<float> data;
	thread_count= strtol(argv[1], NULL, 10);
	
	generar_aleatorios(data, 0.3, 26.0, 1000 );//inicio y fin de los datos
	//generar_ejemplo(data);
	histograma(data, 5);
	double fin = omp_get_wtime( );  
    double wtick = omp_get_wtick( );
    printf("inicio = %.16g\nfin = %.16g\ndiff = %.16g\n",   inicio, fin, fin - inicio);  

	return 0;
}

