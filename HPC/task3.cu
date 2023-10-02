/*
To Compile:
    nvcc task3.cu -o task3

To Run:
    ./task3
*/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

//Global variable for device
__device__ char* encText;

//To calculate Time
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
//Custom Encryption function to run on device
__device__ char* CudaCrypt(char* rawPassword){

	char * newPassword = (char *) malloc(sizeof(char) * 11);

	newPassword[0] = rawPassword[0] + 2;
	newPassword[1] = rawPassword[0] - 2;
	newPassword[2] = rawPassword[0] + 1;
	newPassword[3] = rawPassword[1] + 3;
	newPassword[4] = rawPassword[1] - 3;
	newPassword[5] = rawPassword[1] - 1;
	newPassword[6] = rawPassword[2] + 2;
	newPassword[7] = rawPassword[2] - 2;
	newPassword[8] = rawPassword[3] + 4;
	newPassword[9] = rawPassword[3] - 4;
	newPassword[10] = '\0';

	for(int i =0; i<10; i++){
		if(i >= 0 && i < 6){ //checking all lower case letter limits
			if(newPassword[i] > 122){
				newPassword[i] = (newPassword[i] - 122) + 97;
			}else if(newPassword[i] < 97){
				newPassword[i] = (97 - newPassword[i]) + 97;
			}
		}else{ //checking number section
			if(newPassword[i] > 57){
				newPassword[i] = (newPassword[i] - 57) + 48;
			}else if(newPassword[i] < 48){
				newPassword[i] = (48 - newPassword[i]) + 48;
			}
		}
	}
	return newPassword;
}

//Device function to match string
__device__ int passwordMatch(char* currentEncText){
    char* check = currentEncText;
    char* match = encText;
  while(*check == *match){
    if(*check == '\0'){
        return 1;
    }
      check++;
      match++;
  }
  return 0;
    
}
//Encrypts given plain text using custom encryption
//Stores the encrypted text at global device variable
__global__ void Encrypt(){
char genRawPass[5] = "cd20";
encText = CudaCrypt(genRawPass);
//firstLetter - 'a' - 'z' (26 characters)
//secondLetter - 'a' - 'z' (26 characters)
//firstNum - '0' - '9' (10 characters)
//secondNum - '0' - '9' (10 characters)

printf("Encrypted text is: ");
printf("%c %c %c %c = %s\n", genRawPass[0],genRawPass[1],genRawPass[2],genRawPass[3], encText);
printf("Decrypting %s using Brute Force \n", encText);
}

//Cracks the the encrypted text in global variable
__global__ void crack(char * alphabet, char * numbers){

char rawPass[5];

rawPass[0] = alphabet[blockIdx.x];
rawPass[1] = alphabet[blockIdx.y];

rawPass[2] = numbers[threadIdx.x];
rawPass[3] = numbers[threadIdx.y];
rawPass[4] = '\0';

//firstLetter - 'a' - 'z' (26 characters)
//secondLetter - 'a' - 'z' (26 characters)
//firstNum - '0' - '9' (10 characters)
//secondNum - '0' - '9' (10 characters)
  
  if(passwordMatch(CudaCrypt(rawPass))){
      printf("Match Found Your Password is %s \n", rawPass);
  }

}

//Main Function
int main(int argc, char ** argv){
      //starting clock
      struct timespec start, finish;
      long long int difference;
      clock_gettime(CLOCK_MONOTONIC, &start);

	//Calls Encryption method
    Encrypt<<< 1, 1 >>>();    

    char cpuAlphabet[26] = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
    char cpuNumbers[26] = {'0','1','2','3','4','5','6','7','8','9'};

    char * gpuAlphabet;
    cudaMalloc( (void**) &gpuAlphabet, sizeof(char) * 26);
    cudaMemcpy(gpuAlphabet, cpuAlphabet, sizeof(char) * 26, cudaMemcpyHostToDevice);

    char * gpuNumbers;
    cudaMalloc( (void**) &gpuNumbers, sizeof(char) * 26);
    cudaMemcpy(gpuNumbers, cpuNumbers, sizeof(char) * 26, cudaMemcpyHostToDevice);

    crack<<< dim3(26,26,1), dim3(10,10,1) >>>( gpuAlphabet, gpuNumbers );
    cudaDeviceSynchronize();

    //Stopping Clock
    clock_gettime(CLOCK_MONOTONIC, &finish);
    time_difference(&start, &finish, &difference);
    printf("run lasted %lldns or %9.5lfs\n", difference, difference / 1000000000.0);
  
return 0;
}