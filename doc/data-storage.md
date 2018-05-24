# Data storage
Here I describe the compromise we have found to store data.

## 4D stack
We are working with 4D images. Their dimensions are:
- x, first dimension, oriented right
- y, second dimension, oriented anterior
- z, third dimension, oriented superior
- t, fourth dimension, oriented causal

This defines the RAST standard (right-anterior-superior-time). Raw data might not be RAS, but all processed data has to be RAS.

### In the matfile
The matfile contains:
- space (orientation)
- x (x size)
- y (y size)
- z (z size)
- t (t size)
- Z (layers concerned)
- T (frames concerned)

Example:
- space = 'RAST'
- x = 604
- y = 1024
- z = 10
- t = 1500
- Z = \[12, 11, 10, 9, 8, 7, 6, 5, 4, 3\]
- T = 1×1500 double

## 3D stack collection
Because the brain is about 1/3 of the volume of the parallelepiped, we do not compute over the whole stack. The following folders contain a collection of 3D stacks:
- baseline_pixel
- baseline_neuron
- dff_neuron
- dff_pixel

For example:

    dff_neuron/
    ├── 03.bin
    ├── 03.mat
    ├── 04.bin
    ├── 04.mat
    ├── ...
    ├── 20.bin
    └── 20.mat

In the matfiles associated with the binary files, we can find the information about the pixels concerned by the binary file.

The first dimension is the time, and the second dimension is the xy position of the neuron / pixel. The linear indexes of the neuron or the linear index of the pixel is given in the matfile:

- t (time)
- xy linear index, pixel or neuron index

### In the matfile
For per_pixel, The matfile contains:
- mmap (memory map on the binary file)
- x (x size)
- y (y size)
- z (z size = 1)
- t (t size)
- Z (layer concerned)
- T (frames concerned)
- indices (list of linear indexes)
- numIndex (number of linear indexes)

For per_neuron, The matfile contains:
- mmap (memory map on the binary file)
- x (x size)
- y (y size)
- z (z size = 1)
- t (t size)
- Z (layer concerned)
- T (frames concerned)
- numNeurons (number of neurons)
- centerCoord (x and y coordinates of neurons center)
- neuronShape (cell array containing linear indexes of each neuron pixels) 

## Bit depth
The images are `uint16`. We keep `uint16` for the following files:
- corrected.bin
- graystack.bin
- baseline/*

Then, we use `single` (float 32 bit) for:
- background.mat
- dff/*

The mask is `logical` (1 bit):
- mask