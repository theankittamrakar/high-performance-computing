/*
To Compile:
    cc -o task2_B 2039281_Task2_B.c -lrt -pthread -fno-stack-protector

To Run:
    ./task2_B

To Record Output:
    ./task2_B > task2_B_output.txt
*/
/*****************************************************
 BY Subin Shrestha
 ID 2039281 

--Implementation of Matrix Multiplication using multithrading.
--Number of threads is confirugable at runtime using input.txt file.
--Prints average run time after running the program for 10 times.
--Threads are used to compute each row of the result matrix.
--Say Result matrix is of size 1500 x 1500
--1500 threads will be used to compute each row of the result matrix
******************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>

//Defining MAtrix Size
#define matSize 1500

//Defining 3 matrices A, B and result
int A[matSize][matSize], B[matSize][matSize], result[matSize][matSize];

//To calculate time
int time_difference(struct timespec *start, struct timespec *finish,
                    long long int *difference)
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

void *mult(void *arg)
{
    args *p = arg;
    for (int y = 0; y < matSize; y++)
    {
        //Calculating Each Element in Result Matrix Using Passed Arguments
        int cache = 0;
        for (int a = 0; a < matSize; a++)
        {
            cache += A[p->x][a] * B[a][y];
        }
        result[p->x][y] = cache;
    }

    //End Of Thread
    pthread_exit(0);
}

//method to multipy two matrices. takex max number of threads as parameters
float matMuil_multiThreading(int maxThread)
{
    //To calculate time
    struct timespec start, finish;
    long long int difference;
    clock_gettime(CLOCK_MONOTONIC, &start);

    //Defining Threads
    pthread_t thread[maxThread];

    //Counter For Thread Index
    int thread_number = 0;

    //Defining p For Passing Parameters To Function As Struct
    args p[matSize];

    //Creates seperate thread for each row in the output matrix
    for (int x = 0; x < matSize; x++)
    {
        //Initializing Parameters For Passing To Function
        p[thread_number].x = x;

        //Status For Checking Errors
        int status;

        //Create Specific Thread For Each Element In Result Matrix
        status = pthread_create(&thread[thread_number], NULL, mult, (void *)&p[thread_number]);

        //Check For Error
        if (status != 0)
        {
            printf("Error In Threads");
            exit(0);
        }

        thread_number++;
    }

    //Wait For All Threads Done - - - - - - - - - - - - - - - - - - - - - - //
    for (int z = 0; z < (matSize); z++)
        pthread_join(thread[z], NULL);

    //Print Multiplied Matrix (Result) - - - - - - - - - - - - - - - - - - -//
    //Uncomment lines beow to print the resut matrix
    // printf(" --- Multiplied Matrix ---\n\n");
    // for (int x = 0; x < matSize; x++)
    // {
    //     for (int y = 0; y < matSize; y++)
    //     {
    //         printf("%5d", result[x][y]);
    //     }
    //     printf("\n\n");
    // }

    //Stopping the clock to calculate time
    clock_gettime(CLOCK_MONOTONIC, &finish);
    time_difference(&start, &finish, &difference);
    //printf("run lasted %lldns or %9.5lfs\n", difference, difference / 1000000000.0);

    //Total Threads Used In Process - - - - - - - - - - - - - - - - - - - -//

    // printf(" ---> Used Threads : %d \n\n", thread_number);
    // for (int z = 0; z < thread_number; z++)
    //     printf(" - Thread %d ID : %d\n", z + 1, (int)thread[z]);

    //Returing time in seconds
    return difference / 1000000000.0;
}

//Main Methods
int main(int argc, char const *argv[])
{
    //Takes input from file
    char c[1];
    FILE *fptr;
    int num;
    if ((fptr = fopen("input.txt", "r")) == NULL)
    {
        printf("Error! opening file");
        // Program exits if file pointer returns NULL.
        exit(1);
    }

    // reads text until newline is encountered
    fscanf(fptr, "%[^\n]", c);
    num = atoi(&c[0]);
    printf("Number of Threads Used: %d \n", num);
    fclose(fptr);

    //Defines max thread as the number in the file.
    int maxThread = num;

    //the values of the matrix are given random values between 0 and 70.
    //time taken to assign this value is not added to the final time.
    for (int a = 0; a < matSize; a++)
    {
        for (int b = 0; b < matSize; b++)
        {
            A[a][b] = rand() % 70;
            B[a][b] = rand() % 70;
        }
    }
    //Runs matrix multiplication 10 times and gives average time taken to compute.
    float timeTaken[10];
    float sum = 0;
    for (int i = 0; i < 10; i++)
    {
        timeTaken[i] = matMuil_multiThreading(maxThread);
        printf("Time Taken for run %d = %9.5lf\n", i, timeTaken[i]);
        sum = sum + timeTaken[i];
    }
    printf("Average Taken %9.5lf\n", sum / 10);
    /* code */
    return 0;
}
