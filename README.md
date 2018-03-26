# Mini doc for easyRLS

"easyRLS" is intended to provide a stable and efficient code base for RLS computations
- correct drift
- map to ref brain 
- compute baseline
- compute DFF

You will find :
- [how to install the programs](https://github.com/LaboJeanPerrin/easyRLS#install-matlab-programs)
- [how to run the main script to understand how it works](https://github.com/LaboJeanPerrin/easyRLS#run-the-code-section-after-section)
- [a definition of the standard document architecure](https://github.com/LaboJeanPerrin/easyRLS#defining-folder-architecture-and-file-formats)
- [benchmarks on diffents computers](https://github.com/LaboJeanPerrin/easyRLS#benchmark)

## Install Matlab programs

### Install dependencies
Install NeuroTools :

    git clone https://github.com/LaboJeanPerrin/NeuroTools.git
    
In Matlab, do "add with subfolders" for the 'Neurotools/Matlab' folder.

### Install easyRLS
First, clone the code by doing 

    git clone https://github.com/LaboJeanPerrin/easyRLS.git

In Matlab, do "add with subfolders" for the 'easyRLS/Matlab' folder.

### Install R runquantile
You need to install R because of the shared library.

	sudo apt install r-base

It is *not* necessary to install the package for runquantile (it is in the library) but if you want, run `R` and then `install.packages("caTools")`

## Update programs

Just go in the concerned directory and do `git pull`. You will have to manage changes made on the code. Gitkraken could be useful in such a case.

## Run the code section after section

Once you have the code, open the `script.m` in 'easyRLS/Matlab/Utils'. You will run this script section by section. For each section, the approximative time is given. The benchmarks have been performed on 'Dream' for the run 2018-01-11/Run 05 on the layers 3 to 12 (10 layers) for 1500 time frames.

### Set working directory

Replace the `cd` command argument by your project's folder containing the 'Data' directory. The architecture of 'Data' has to be 'Data/yyyy-mm-dd/Run xx/'.

The 'get focus' section loads the parameters and create a config file.

### Create binary from tif (448 s)

`tifToMmap` creates a 'raw.bin' binary file directly from the tif images. This file can be accessed with memory mapping in matlab thanks to the class `Mmap` and the info in the 'raw.mat' file. It can also be accessed from imageJ with the bioformats plugin by writing the appropriate NRRD header.

`stackViewer` allows to view the binary stack in a matlab figure with gui control thanks to memory mapping (like virtual stack in imageJ).

### Working on dcimg

Alternatively, you can work on dcimg. x and y still have to be found. The function `dcimgRASdrift` is a shortcut for `dcimgToMmap`, `transposeMmap`, `driftCorrect`.

### Correct drift 

`driftCompute` **(92 s)** computes the drift on the projection of the reference layers relatively to the reference layer at the given reference index.

`seeDriftCorrection` plays a movie of the drift corrected brain by computing the translation online. You can then run `driftApply` **(175 s)** to create corrected binary stack if you are satisfied with the correction. `stackViewer` allows you to view the drift corrected hyperstack.

To view the stack in imageJ, you can create a NRRD header like the following in the same folder as the vinary stack.

    NRRD0001
    # Complete NRRD file format specification at:
    # http://teem.sourceforge.net/nrrd/format.html
    type: uint16
    dimension: 4
    sizes: 1018 634 10 1500
    endian: little
    encoding: raw
    data file: ./corrected.bin

You can then drag and drop the text file to imageJ, and the bioformats plugin will create a virtual stack.

### Select the ROI for dff computation

To avoid computing the dff on useless regions (i.e. background), you can select the ROI. It will be recorded in a 'mask.mat' matlab logical matrix. `maskViewer` will let you see the contour overlay on the stack.

#### Manually

`selectROI` will prompt each layer and let you draw a polygon whose inside defines the ROI.

#### Automatically

You can use a reference stack which already has a mask and use this mask after a registration. (Now only layer by layer using 2D imregdemons, but only a few seconds).

### Computing baseline (2313 s)

To compute baseline, we use the '[runquantile](https://www.rdocumentation.org/packages/caTools/versions/1.17.1/topics/runquantile)' function of '[caTools](https://www.rdocumentation.org/packages/caTools/versions/1.17.1)', a R plugin coded in C. You need to install this before use.

#### Installing R and caTools plugin

To install R

    sudo apt install r-base

Then start R

    R

In the command prompt, install package with

    install.packages("caTools")

If it is the first time, your `/usr/local/lib/R` will probably not be accessible with write permissions. Run

    sudo chown -R ljp:ljp /usr/local/lib/R

to correct this. Run again the install package command, it will let you select a mirror, and will download the package and install it.

#### Using it from Matlab

To use it with matlab, you only have to run `loadlibrary` with the path of the `.so` and the `.h`. They are in 'easyRLS/Tools/caTools', an example is given in the script.

Then you can run `caToolsRunquantile` which reads the signal in the 'corrected.bin' file and creates a folder 'baseline' in the 'IP' folder. In this folder, there will be a `.bin` and a `.mat` file by layer.

/!\ THIS IS NOT A GOOD WAY TO DO : 
- BECAUSE OF ABSOLUTE PATH IN MMAP
- BECAUSE MATLAB STORES THE OUTPUT IN MEMORY BEFORE WRITING IT

Example of time taken from layer 3 to layer 12. The time depends on the number of pixels in ROI.

    183042    Elapsed time is 129.968375 seconds.
    208560    Elapsed time is 191.647284 seconds.
    215296    Elapsed time is 197.718126 seconds.
    237943    Elapsed time is 212.829820 seconds.
    255385    Elapsed time is 278.645149 seconds.
    263575    Elapsed time is 230.729000 seconds.
    272680    Elapsed time is 236.663611 seconds.
    286021    Elapsed time is 255.703843 seconds.
    294492    Elapsed time is 255.595885 seconds.
    295021    Elapsed time is 258.743297 seconds.

If you get an 'out of memory', due to matlab putting the output in memory, you can use `caToolsRunquantileLin`, which is a bit slower (about 20% slower), but does the same job.

Time taken for the three first layers as before :

    Elapsed time is 172.569686 seconds.
    Elapsed time is 196.399570 seconds.
    Elapsed time is 209.400558 seconds.

Seems quite good though...

### Computing DFF (647 s)

The formula for the dff computation is the following :

$$ \frac{\Delta f}{f} = \frac{\text{Signal} - \text{Baseline}}{\text{Baseline} - \text{Background}}$$

![equation](https://latex.codecogs.com/svg.latex?%5Cfrac%7B%5CDelta%7Ef%7D%7Bf%7D%3D%5Cfrac%7B%5Ctext%7BSignal%7D-%5Ctext%7BBaseline%7D%7D%7B%5Ctext%7BBaseline%7D-%5Ctext%7BBackground%7D%7D)

Then it is quite fast to compute with the `dff` function.

    Elapsed time is 11.994007 seconds.
    Elapsed time is 55.649569 seconds.
    Elapsed time is 72.661948 seconds.
    Elapsed time is 70.141947 seconds.
    Elapsed time is 74.381304 seconds.
    Elapsed time is 71.651774 seconds.
    Elapsed time is 70.866094 seconds.
    Elapsed time is 70.864970 seconds.
    Elapsed time is 71.309378 seconds.
    Elapsed time is 72.151579 seconds.

## Defining folder architecture and file formats

### Project organisation

A project is organised as follows :

> Project/Data/Study/Date/Run/

In a run, there is :
- an 'Image' folder with well named tif images or a dcimg file
- or a 'dcimg' raw data.
- a 'Parameter.txt'

After analysis, there is a 'Files' folder with :
- a 'Config.mat' config file
- the raw or corrected stack (uint16)
- an 'IP' folder

The stack contains :
- a binary file, RAST, uint16
- a mat file with dimensions (x,y,z,t,Z,T)
- a nhdr file to drag and drop in imageJ for instance

x, y, z, t, Z, T are :
- the x,y,z,t sizes
- Z : list of layers recorded in stack (useful ?)
- T : list of times concerned (useful ?)
- (could add) orientation (i.e. RAS)
- (could add) type (i.e. uint16)

The IP folder contains :
- drift info : Drifts.mat, DriftBox.mat, driftCorrection.fig
- image registration info : defMap.mat (could change to a xform)
- a graystack stack (bin, mat, nhdr), (t,T are here just for Mmap)
- a mask (now .mat, should become stack)
- the 'background.mat' values (single)
- baseline folder
- dff folder

The baseline folder contains :
- a bin and mat file for each layer
- bin is a 2D t×index (uint16)
- mat contains x,y,z,t,Z,T,indices,numindex,mmap (mmap, z and T should disappear)
(mmap should be reconstructed, z = 1 always, is T useful ?)
- indices are accessible via matfile if you do not want to load it

The dff folder contains :
- a bin and mat file for each layer
- bin is 2D t×index (single)
- mat is the same as before

## Benchmark

### Dream
This benchmark has been computed for 18 layers (3 → 20) of 3000 time frames on computer 'Dream' (Intel® Core™ i7-6700K CPU @ 4.00GHz × 8, but not parallelized)

    layer 3, numIndex 197480
    layer 4, numIndex 218788
    layer 5, numIndex 234647
    layer 6, numIndex 256632
    layer 7, numIndex 271762
    layer 8, numIndex 284101
    layer 9, numIndex 300836
    layer 10, numIndex 325213
    layer 11, numIndex 339521
    layer 12, numIndex 349962
    layer 13, numIndex 353243
    layer 14, numIndex 360801
    layer 15, numIndex 358265
    layer 16, numIndex 354024
    layer 17, numIndex 335077
    layer 18, numIndex 325625
    layer 19, numIndex 320476
    layer 20, numIndex 322100

    creating 'baseline' directory
    computing baseline for layer 3
    Elapsed time is 666.037684 seconds.
    computing baseline for layer 4
    Elapsed time is 430.974213 seconds.
    computing baseline for layer 5
    Elapsed time is 457.901151 seconds.
    computing baseline for layer 6
    Elapsed time is 476.981205 seconds.
    computing baseline for layer 7
    Elapsed time is 492.908462 seconds.
    computing baseline for layer 8
    Elapsed time is 503.302138 seconds.
    computing baseline for layer 9
    Elapsed time is 539.941323 seconds.
    computing baseline for layer 10
    Elapsed time is 563.164443 seconds.
    computing baseline for layer 11
    Elapsed time is 589.400313 seconds.
    computing baseline for layer 12
    Elapsed time is 619.239420 seconds.
    computing baseline for layer 13
    Elapsed time is 616.485916 seconds.
    computing baseline for layer 14
    Elapsed time is 632.351206 seconds.
    computing baseline for layer 15
    Elapsed time is 635.598164 seconds.
    computing baseline for layer 16
    Elapsed time is 651.299828 seconds.
    computing baseline for layer 17
    Elapsed time is 616.103178 seconds.
    computing baseline for layer 18
    Elapsed time is 596.929938 seconds.
    computing baseline for layer 19
    Elapsed time is 607.170558 seconds.
    computing baseline for layer 20
    Elapsed time is 596.004071 seconds.
    creating 'dff' directory
    Elapsed time is 134.996219 seconds.
    Elapsed time is 149.832010 seconds.
    Elapsed time is 144.765864 seconds.
    Elapsed time is 161.145919 seconds.
    Elapsed time is 177.627739 seconds.
    Elapsed time is 178.335567 seconds.
    Elapsed time is 163.284241 seconds.
    Elapsed time is 149.934031 seconds.
    Elapsed time is 151.228832 seconds.
    Elapsed time is 178.686603 seconds.
    Elapsed time is 178.841415 seconds.
    Elapsed time is 155.352043 seconds.
    Elapsed time is 163.606614 seconds.
    Elapsed time is 167.015503 seconds.
    Elapsed time is 153.724379 seconds.
    Elapsed time is 150.455047 seconds.
    Elapsed time is 148.272154 seconds.
    Elapsed time is 142.306286 seconds.
    Time elapsed for drift computation, baseline computation, graystack computation, dff computation
    Elapsed time is 14120.873724 seconds.

### Redstar

1500 tframes, layers 3:12

dcimgRASdrift

	Elapsed time is 593.834627 seconds.

baseline

    computing baseline for layer 3 (231721 points, 1500 timeframes)
    Elapsed time is 468.451551 seconds.
    computing baseline for layer 4 (255636 points, 1500 timeframes)
    Elapsed time is 542.108043 seconds.
    computing baseline for layer 5 (267917 points, 1500 timeframes)
    Elapsed time is 584.353121 seconds.
    computing baseline for layer 6 (278355 points, 1500 timeframes)
    Elapsed time is 605.411876 seconds.
