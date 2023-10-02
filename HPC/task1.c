/*To Compile:
    cc -o task1 task1.c -lrt -pthread -fno-stack-protector

To Run:
    ./task1

To Record Output:
    ./task1 > resultmatrix2050058.txt
*/

#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>

#define matrixSize 2000

int P[matrixSize][matrixSize], Q[matrixSize][matrixSize], result[matrixSize][matrixSize];
//defining global variables


//Main Method
int main(int argc, char const *argv[])
{
    char c[1];
    FILE *fptr;
    int num;
    if ((fptr = fopen("input.txt", "r")) == NULL)
    //reading input from file input.txt
    {
        printf("Error occured while opening file!!!");
        exit(1);
        //The program will get terminated if file pointer returns NULL value.
    }   

fscanf(fptr, "%[^\n]", c);
//reads text until newline
num = atoi(&c[0]);
//takes user input for number of threads using input arguement
printf("Number of threads used: %d \n", num);
fclose(fptr);

int maxThread = num;


}

int timeDiff(struct timespec *start, struct timespec *finish, long long int *difference)
{
    long long int ds = finish->tv_sec - start->tv_sec;
    long long int dn = finish->tv_nsec - start->tv_nsec;

    if (dn < 0)
    {
        ds--;
        dn += 1000000000;
    }
    *difference = ds * 1000000000 + dn;

    return !(*difference > 0); 
}

typedef struct parameters
{
    int x;
} args;

void *multiplication(void *arg)
{
    args *p = arg;
    for (int y = 0; y < matrixSize; y++)
    {
        //Calculating each element in result matrix
        int res = 0;
        for (int z = 0; z < matrixSize; z++)
        {
            res+= P[p->x][z] * Q[z][y];
        }
        result[p->x][y] = res;
    }

    pthread_exit(0);
}

//method to multiply matrices.
float MatrixMultiplication(int maxThread)
{
    struct timespec start, finish;
    long long int difference;
    clock_gettime(CLOCK_MONOTONIC, &start);

    pthread_t thread[maxThread];

    int threadNum = 0;

    args p[matrixSize];

    for (int x = 0; x < matrixSize; x++)
    {
        p[threadNum].x = x;
        int check;
        check = pthread_create(&thread[threadNum], NULL, multiplication, (void *)&p[threadNum]);
    
        if (check != 0)
        {
            printf("Error in Thread");
            exit(0);
        }
        threadNum++;
    }

    

    for(int h = 0; h < (matrixSize); h++)
        pthread_join(thread[h], NULL);

        //Print Multiplied Matrix (Result) - - - - - - - - - - - - - - - - - - -//
    printf(" --- Multiplied Matrix ---\n\n");
    for (int x = 0; x < matrixSize; x++)
    {
         for (int y = 0; y < matrixSize; y++)
         {
             printf("%5d", result[x][y]);
         }
         printf("\n\n");
    }

    clock_gettime(CLOCK_MONOTONIC, &finish);
    timeDiff(&start, &finish, &difference);

    return difference/1000000000.0;

}