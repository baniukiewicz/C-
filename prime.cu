#include <iostream>
#include <math.h>
#include <stdio.h>
#include <chrono> 
#include <omp.h>
using namespace std::chrono;
#define THREADS_PER_BLOCK 1024
__global__ void prm(unsigned long long int* a, int* b, int* c, int* d) {
	unsigned long long int i = threadIdx.x + blockIdx.x * blockDim.x;
	
	if (*a % 2 == 0 && *a != 2)
	{
		*b = *d;
	}
	else 
	{
		if (*a % i == 0 && i != 1 && i <= *c)
		{
			*b = *d;
		}
	}
}


int main(void) {
	int b, c, d, e, f;
	unsigned long long int a;
	unsigned long long int* d_a;
	int* d_b, * d_c, * d_d;
	int size_m = sizeof(int);
	unsigned long long int size_d = sizeof(unsigned long long int);

	cudaMalloc((void**)&d_a, size_d);
	cudaMalloc((void**)&d_b, size_m);
	cudaMalloc((void**)&d_c, size_m);
	cudaMalloc((void**)&d_d, size_m);

	std::cout << "podaj liczbe " << std::endl;
	std::cin >> a;

	b = 0;
	d = 1;
	e = 0;
	f = 1;

	c = ceil(sqrt(a));
	auto start1 = high_resolution_clock::now();
	if (a % 2 == 0 && a != 2)
		e = f;
	else {
		for (int i = 3; i <= c; i += 2)
		{
			if (a % i == 0)
			{
				e = f;
			}
		};
	};
	
	auto stop1 = high_resolution_clock::now();
	auto duration1 = duration_cast<nanoseconds>(stop1 - start1);

	if (!e)
	{
		std::cout << "CPU: number is prime, computed in = " << duration1.count() << "ns" << std::endl;
	}
	if (e)
	{
		std::cout << "CPU: number is not prime, computed in = " << duration1.count() << "ns" << std::endl;
	}

	e = 0;
	auto start3 = high_resolution_clock::now();
	

		
		if (a % 2 == 0 && a != 2)
			e = f;
		else {
			#pragma omp parallel shared(a,c,e,f)
			{
			#pragma omp for
				for (int i = 3; i <= c; i += 2)
				{
					if (a % i == 0)
					{
						e = f;
					}
				};
			}
		};
	
	auto stop3 = high_resolution_clock::now();
	auto duration3 = duration_cast<nanoseconds>(stop3 - start3);

	if (!e)
	{
		std::cout << "CPU OpenMP: number is prime, computed in = " << duration3.count() << "ns" << std::endl;
	}
	if (e)
	{
		std::cout << "CPU OpenMP: number is not prime, computed in = " << duration3.count() << "ns" << std::endl;
	}

	cudaMemcpy(d_a, &a, size_d, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, &b, size_m, cudaMemcpyHostToDevice);
	cudaMemcpy(d_c, &c, size_m, cudaMemcpyHostToDevice);
	cudaMemcpy(d_d, &d, size_m, cudaMemcpyHostToDevice);

	auto start2 = high_resolution_clock::now();
	int N = 512;

	prm << <N, THREADS_PER_BLOCK >> > (d_a, d_b, d_c, d_d);

	auto stop2 = high_resolution_clock::now();
	auto duration2 = duration_cast<nanoseconds>(stop2 - start2);

	cudaMemcpy(&b, d_b, size_m, cudaMemcpyDeviceToHost);

	if (!b) 
	{ 
		std::cout << "GPU: number is prime, computed in = " << duration2.count() << "ns" << std::endl; 
	}
	if (b) 
	{ 
		std::cout << "GPU: number is not prime, computed in = " << duration2.count() << "ns" << std::endl; 
	}
	
	cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);

	return 0;
}
