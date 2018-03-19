# Mini doc to use easyRLS

## Install Matlab programs

### Install dependencies

Install NeuroTools :

    git clone https://github.com/LaboJeanPerrin/NeuroTools.git
    
In Matlab, do "add with subfolders" for the 'Neurotools/Matlab' folder.

### Install easyRLS
First, clone the code by doing 

    git clone https://github.com/LaboJeanPerrin/easyRLS.git

In Matlab, do "add with subfolders" for the 'easyRLS/Matlab' folder.

## Run the code section after section

Once you have the code, open the `script.m` in 'easyRLS/Matlab/Utils'. You will run this script section by section. For each section, the approximative time is given. The benchmarks have been performed on 'Dream' for the run 2018-01-11/Run 05 on the layers 3 to 12 (10 layers) for 1500 time frames.

### Set working directory

Replace the `cd` command argument by your project's folder containing the 'Data' directory. The architecture of 'Data' has to be 'Data/yyyy-mm-dd/Run xx/'.

The 'get focus' section loads the parameters and create a config file.

### Create binary from tif (448 s)

`tifToMmap` creates a 'raw.bin' binary file directly from the tif images. This file can be accessed with memory mapping in matlab thanks to the class `Mmap` and the info in the 'raw.mat' file. It can also be accessed from imageJ with the bioformats plugin by writing the appropriate NRRD header.

`stackViewer` allows to view the binary stack in a matlab figure with gui control thanks to memory mapping (like virtual stack in imageJ).

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
- a 'Parameter.txt'

After analysis, there is a 'Files' folder with :
- a Config.mat config file
- the raw or corrected stack
- an IP folder

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
- baseline folder
- dff folder

The baseline folder contains :
- a bin and mat file for each layer
- bin is a 2D t×index (double, should become uint16)
- mat contains x,y,z,t,Z,T,indices,numindex,mmap (mmap, z and T should disappear)
(mmap should be reconstructed, z = 1 always, is T useful ?)

The dff folder contains :
- a bin and mat file for each layer
- bin is 2D t×index (double, should become single)
- mat is the same as before