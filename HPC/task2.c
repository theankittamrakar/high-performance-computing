/*To Compile:
    cc -o task2 task2.c -lcrypt -lpthread

To Run:
    ./task2
*/

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>
#include<stdbool.h>
#include<pthread.h>
#include<crypt.h>

int count1 = 0;
int count2 = 0;
bool found = false;


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

void substr(char *dest, char *src, int start, int length)
{
    memcpy(dest, src + start, length);
    *(dest + length) = '\0';
}

void kernel_function_1(char *salt_and_encrypted)
{
    int x, y, z;   // Loop counters
    char salt[7];  // String used in hashing the password. Need space for \0 // incase you have modified the salt value, then should modifiy the number accordingly
    char plain[7]; // The combination of letters currently being checked // Please modifiy the number when you enlarge the encrypted password.
    char *enc;     // Pointer to the encrypted password

    substr(salt, salt_and_encrypted, 0, 6);
    //2 loops for letters and 1 loop for number
    for (x = 'A'; x <= 'M'; x++)
    {
        for (y = 'A'; y <= 'Z'; y++)
        {
            for (z = 0; z <= 99; z++)
            {
                sprintf(plain, "%c%c%02d", x, y, z);
                enc = (char *)crypt(plain, salt);
                count1++;
                if (strcmp(salt_and_encrypted, enc) == 0)
                {
                    printf("#%-8d%s %s\n", count1, plain, enc);
                    found = true;
                    pthread_exit(0);
                    return; //Comment line to explore all possible solutions
                }
                //Uncomment lines below to print all possible solutions
                // else{
                //   printf("%-8d%s %s\n", count, plain, enc);
                // }
                //Ends this thread if the solution is found on other thread
                if (found)
                {
                    printf("Solution Found \n");
                    pthread_exit(0);
                    return;
                }
            }
        }
    }
}


void kernel_function_2(char *salt_and_encrypted)
{
    int x, y, z;   // Loop counters
    char salt[7];  // String used in hashing the password. Need space for \0 // incase you have modified the salt value, then should modifiy the number accordingly
    char plain[7]; // The combination of letters currently being checked // Please modifiy the number when you enlarge the encrypted password.
    char *enc;     // Pointer to the encrypted password

    substr(salt, salt_and_encrypted, 0, 6);
    //2 loops for letters and 1 loop for number
    for (x = 'N'; x <= 'Z'; x++)
    {
        for (y = 'A'; y <= 'Z'; y++)
        {
            for (z = 0; z <= 99; z++)
            {
                sprintf(plain, "%c%c%02d", x, y, z);
                enc = (char *)crypt(plain, salt);
                count2++;
                if (strcmp(salt_and_encrypted, enc) == 0)
                {
                    printf("#%-8d%s %s\n", count2, plain, enc);
                    found = true;
                    pthread_exit(0);
                    return; //Comment line to explore all possible solutions
                }
                //Uncomment lines below to print all possible solutions
                // else{
                //   printf("%-8d%s %s\n", count, plain, enc);
                // }
                //Ends this thread if the solution is found on other thread
                if (found)
                {
                    printf("Solution Found \n");
                    pthread_exit(0);
                    return;
                }
            }
        }
    }
}

int main(int argc, char const *argv[])
{
    for (int i = 0; i < 10; i++)
    {
        //Variables
        pthread_t thread_1, thread_2;

        char pass[] = "$6$AS$KDz2YK3J483TubP5vGxy79Xa1cmV8e75Asy0ekjoV7HtuS7EAjnH.xWmVng0IhoIg12JEzlnHFcu9UzS1tbXk1";
        //Starting Clock
        struct timespec start, finish;
        long long int difference;
        clock_gettime(CLOCK_MONOTONIC, &start);

        //Thread Code
        pthread_create(&thread_1, NULL, (void *(*)(void *))kernel_function_1, &pass);
        pthread_create(&thread_2, NULL, (void *(*)(void *))kernel_function_2, &pass);

        pthread_join(thread_1, NULL);
        pthread_join(thread_2, NULL);
        printf("%d solutions explored\n", count1);
        printf("%d solutions explored\n", count2);

        //Stopping Clock
        clock_gettime(CLOCK_MONOTONIC, &finish);
        time_difference(&start, &finish, &difference);
        printf("run no %d lasted %lldns or %9.5lfs\n", i, difference, difference / 1000000000.0);
        count1 = 0;
        count2 = 0;
        found = false;
        printf("##############################################\n");
    }

    return 0;
}