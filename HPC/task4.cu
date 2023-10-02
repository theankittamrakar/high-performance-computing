/*
To Compile:
    nvcc task4.cu lodepng.cpp -o task4

To Run:
    ./task4 image.png

To Store Output:
    ./task4 image.png > CUDA_Gaussian_output.txt
*/

#include "lodepng.h"
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime_api.h>
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
//Global Device Variable
__device__ unsigned int width;
__device__ unsigned int height;

//Device Function to get requred red color from the image
__device__ unsigned char getRed(unsigned char *image, unsigned int row, unsigned int col){
  unsigned int i = (row * width * 4) + (col * 4);
  return image[i];
}

//Device Function to get requred green color from the image
__device__ unsigned char getGreen(unsigned char *image, unsigned int row, unsigned int col){
  unsigned int i = (row * width * 4) + (col * 4) +1;
  return image[i];
}
//Device Function to get requred blue color from the image
__device__ unsigned char getBlue(unsigned char *image, unsigned int row, unsigned int col){
  unsigned int i = (row * width * 4) + (col * 4) +2;
  return image[i];
}
//Device Function to get requred alpha channel from the image
__device__ unsigned char getAlpha(unsigned char *image, unsigned int row, unsigned int col){
  unsigned int i = (row * width * 4) + (col * 4) +3;
  return image[i];
}

//Device function to set red
__device__ void setRed(unsigned char *image, unsigned int row, unsigned int col, unsigned char red){
  unsigned int i = (row * width * 4) + (col * 4);
  image[i] = red;
}

//Device Function to set Green
__device__ void setGreen(unsigned char *image, unsigned int row, unsigned int col, unsigned char green){
  unsigned int i = (row * width * 4) + (col * 4) +1;
  image[i] = green;
}

//Device function to set Blue
__device__ void setBlue(unsigned char *image, unsigned int row, unsigned int col, unsigned char blue){
  unsigned int i = (row * width * 4) + (col * 4) +2;
  image[i] = blue;
}

//Device funtion to set alpha
__device__ void setAlpha(unsigned char *image, unsigned int row, unsigned int col, unsigned char alpha){
  unsigned int i = (row * width * 4) + (col * 4) +3;
  image[i] = alpha;
}

//Main gunction to Blur the image in device
//Does not blur if the axis is zero to ignore the pixel at the edges
__global__ void cudaBlur(unsigned char* img_in, unsigned char* newImage){
    if(blockIdx.x == 0 || threadIdx.x == 0 ){

    }
    else{
      //Weight matrix to apply blur.
        float filter[3][3] = {
  { 1.0/16, 2.0/16, 1.0/16 },
  { 2.0/16, 4.0/16, 2.0/16 },
  { 1.0/16, 2.0/16, 1.0/16 }};
  
  //variables
    unsigned redTL,redTC, redTR;
    unsigned redL, redC, redR;
    unsigned redBL,redBC, redBR;
    unsigned newRed;

    unsigned greenTL,greenTC, greenTR;
    unsigned greenL, greenC, greenR;
    unsigned greenBL,greenBC, greenBR;
    unsigned newGreen;

    unsigned blueTL,blueTC, blueTR;
    unsigned blueL, blueC, blueR;
    unsigned blueBL,blueBC, blueBR;
    unsigned newBlue;

    int row = threadIdx.x;
    int col = blockIdx.x;

      setGreen(newImage, row, col, getGreen(img_in, row, col));
      setBlue(newImage, row, col, getBlue(img_in, row, col));
      setAlpha(newImage, row, col, 255);		

      redTL = getRed(img_in, row-1, col-1);
      redTC = getRed(img_in, row-1, col);
      redTR = getRed(img_in, row-1, col+1);

      redL = getRed(img_in, row, col-1);
      redC = getRed(img_in, row, col);
      redR = getRed(img_in, row, col+1);

      redBL = getRed(img_in, row+1, col-1);
      redBC = getRed(img_in, row+1, col);
      redBR = getRed(img_in, row+1, col+1);
      //Calculating new values for Red
      newRed = redTL*filter[0][0] + redTC*filter[0][1] + redTR*filter[0][2]
             + redL*filter[1][0]  + redC*filter[1][1]  + redR*filter[1][2]
             + redBL*filter[2][0] + redBC*filter[2][1] + redBR*filter[2][2];
      //setting new values for red
      setRed(newImage, row, col, newRed);

      greenTL = getGreen(img_in, row-1, col-1);
      greenTC = getGreen(img_in, row-1, col);
      greenTR = getGreen(img_in, row-1, col+1);

      greenL = getGreen(img_in, row, col-1);
      greenC = getGreen(img_in, row, col);
      greenR = getGreen(img_in, row, col+1);

      greenBL = getGreen(img_in, row+1, col-1);
      greenBC = getGreen(img_in, row+1, col);
      greenBR = getGreen(img_in, row+1, col+1);
      
      //Calculating new values for Green
      newGreen = greenTL*filter[0][0] + greenTC*filter[0][1] + greenTR*filter[0][2]
             + greenL*filter[1][0]  + greenC*filter[1][1]  + greenR*filter[1][2]
             + greenBL*filter[2][0] + greenBC*filter[2][1] + greenBR*filter[2][2];
      
      //Setting new values for green
      setGreen(newImage, row, col, newGreen);

      blueTL = getBlue(img_in, row-1, col-1);
      blueTC = getBlue(img_in, row-1, col);
      blueTR = getBlue(img_in, row-1, col+1);

      blueL = getBlue(img_in, row, col-1);
      blueC = getBlue(img_in, row, col);
      blueR = getBlue(img_in, row, col+1);

      blueBL = getBlue(img_in, row+1, col-1);
      blueBC = getBlue(img_in, row+1, col);
      blueBR = getBlue(img_in, row+1, col+1);
      
      //calculating new values for Blue
      newBlue = blueTL*filter[0][0] + blueTC*filter[0][1] + blueTR*filter[0][2]
             + blueL*filter[1][0]  + blueC*filter[1][1]  + blueR*filter[1][2]
             + blueBL*filter[2][0] + blueBC*filter[2][1] + blueBR*filter[2][2];
      
      //setting new values for blue
      setBlue(newImage, row, col, newBlue);        
    }
    
}

//function that sets width and height in global device variables
__global__ void setDimentions(unsigned int givenWidth, unsigned int givenHeight){
    width = givenWidth;
    height = givenHeight;
    
}

//Main function
int main(int argc, char **argv){
      for (int i = 0; i < 10; i++)
  {
    //Starting Clock
    struct timespec start, finish;
    long long int difference;
    clock_gettime(CLOCK_MONOTONIC, &start);
   
    //image variables
    unsigned char *image;
    unsigned int w;
    unsigned int h;
    //getting vthe image at runtime
    const char* filename = argv[1];
    const char* img_output = "bluredImage.png";
    unsigned char* output_raw;
    cudaError_t error;
    
    //decoding image file
    lodepng_decode32_file(&image, &w, &h, filename);
    
    printf("width = %d height = %d\n", w, h);

    //calling function to set global device variables
    setDimentions<<<1,1>>>(w, h);

    unsigned char * d_image;
    const int ARRAY_BYTES = h*w*4 * sizeof(unsigned char);

    output_raw = (unsigned char *)malloc(ARRAY_BYTES);
    
    //Memory allocation and Copyting image into GPU memory
    cudaMalloc((void**) &d_image, ARRAY_BYTES);
    cudaMemcpy(d_image, image, ARRAY_BYTES, cudaMemcpyHostToDevice);
    
    //Defining and memory allocation for output image
    unsigned char * d_out;
    cudaMalloc((void**) &d_out, ARRAY_BYTES);

    //calling main device function to blur
    cudaBlur<<<w-1, h-1>>>(d_image, d_out);
    
    //checking error
    error = cudaGetLastError();
    if(error){
      fprintf(stderr, "Kernel launch returned %d %s\n", error,
        cudaGetErrorString(error));
      exit(1);
    }
    //Declaration of cuda thread synchronize
    cudaDeviceSynchronize();

    //Copyting output back tohost memory
    cudaMemcpy(output_raw, d_out, ARRAY_BYTES, cudaMemcpyDeviceToHost);
    
    //Encoding image into output file
    lodepng_encode32_file(img_output, output_raw, w, h);

    //freeing variable
    free(image);

    //Stopping Clock
    clock_gettime(CLOCK_MONOTONIC, &finish);
    time_difference(&start, &finish, &difference);
    printf("run no %d lasted %lldns or %9.5lfs\n", i, difference, difference / 1000000000.0);
    printf("##############################################\n");
  }

    return 0;
}