#include <iostream>
#include <vector>
#include <time.h>
#include <stdlib.h>
#include <fstream>
using namespace std;

ofstream fs("fichero.txt");
typedef vector<int> array;
typedef vector<vector<int> > matriz;

void crear_matriz(matriz &M, int f, int c){
	M.resize(f);
	for(int i=0; i<f ; i++)	
		M[i].resize(c);
}

void load_matriz(matriz &M, int f, int c){
	for(int i=0; i<f ; i++){
		for(int j=0 ; j<c ; j++){
			cout << "M["<< i << "][" <<j<< "] ";
			cin >> M[i][j];
		}
	}
}
void load_rand(matriz &M,int val_max){
	srand(time(NULL));
	for (int i = 0; i < M.size(); i++){
		for (int j = 0; j < M.size(); j++)
			M[i][j] = rand()%val_max ;
	}
}
void llenar_ceros(matriz &M, int f, int c){
	for(int i=0; i<f ; i++){
		for(int j=0 ; j<c ; j++){
			M[i][j]=0;
		}
	}

}
matriz normal_multi(matriz &A,int m,int n, matriz &B ,int o){
	matriz C;
	crear_matriz(C,m,o);
	llenar_ceros(C,m,o);			
	for(int i=0;i<m;i++)
		for(int j=0;j<n;j++)
			for(int k=0;k<o;k++)
				C[i][j] = C[i][j] + A[i][k]*B[k][j];

	return C;
}

matriz bloq_multi(matriz &A,int N, matriz &B){

    	matriz rpta;
	double BlockS=32;
    
	crear_matriz(rpta,N,N);
	llenar_ceros(rpta,N,N);

	for (int i1 = 0; i1 < N/BlockS ; i1 += BlockS)
		for (int j1 = 0; j1 < N/BlockS ; j1 += BlockS)
			for ( int k1 = 0; k1 <N/BlockS ; k1 += BlockS)
				for (int i = i1; i<i1+BlockS&&i<N ;i++)
					for	(int j=j1; j<j1+BlockS&&j<N ;j++)
						for	(int k=k1; k<k1+BlockS&&k<N ;k++)
							rpta[i][j] = rpta[i][j] + A[i][k]*B[k][j];

	return rpta;
}	

void print(matriz &v, int a , int b){
	for(int i=0;i<a;i++){
		for(int j=0;j<b;j++){
			cout<<v[i][j]<<"\t";
			fs << v[i][j]<<"\t";
		}
		cout<<endl;
	}
}
int main()
{
	int m,n,o;
	matriz M1,M2;
	

	cout<<"Tamaño de la primera matriz :"<<endl;	
	cin>>m>>n;
	crear_matriz(M1,m,n);			//Separa memoria
	cout<<"LLenar:"<< endl;
	// load_matriz(M1,m,n);				//llena la matriz manualmente
	load_rand(M1,5);					//llena la matriz al random
	// print(M1,m,n);	

	
	cout<<"Tamaño de la segunda matriz :"<<endl;	
	cin>>n>>o;
	crear_matriz(M2,n,o);
	cout<<"LLenar :"<< endl;
	// load_matriz(M1,m,n);				//llena la matriz manualmente
	load_rand(M2,5);					//llena la matriz al random
	// print(M2,n,o);	
	
	// cout << "----------- multiplicacion 3 For ---------------" << endl;
	// matriz M= normal_multi(M1,m,n,M2,o);
	// print(M,o,o);

	cout << "----------- multiplicacion 6 For ---------------" << endl;
	matriz W= bloq_multi(M1,o,M2);
	// print(W,o,o);

}

