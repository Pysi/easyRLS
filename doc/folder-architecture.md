# Folder architecture


## Data directory
The neurotools Focus class helps you deal with the folder architecture if you respect the 'Study/Date/Run' convention :

    Data
    └── RLS1P
        ├── 2018-01-11
        │   └── Run 01
        ├── 2018-01-31
        │   ...
        └── 2018-03-19


## Run directory
The basis architecture of a run is the following, it can vary depending on the analysis you are doing.

    Run 01/
    ├── Files
    │   ├── Config.mat
    │   ├── corrected.bin
    │   ├── corrected.mat
    │   ├── corrected.nhdr
    │   └── IP
    │       ├── background.mat
    │       ├── baseline_neuron
    │       ├── baseline_pixel
    │       ├── dff_neuron
    │       ├── dff_pixel
    │       ├── DriftBox.mat
    │       ├── driftCorrection.fig
    │       ├── Drifts.mat
    │       ├── graystack.bin
    │       ├── graystack.mat
    │       ├── mask.mat
    │       └── Segmented
    ├── Images
    │   ├── Image_00000.tif
    │   ├── Image_00001.tif
    │   ├── Image_00002.tif
    │   ├── ...
    │   └── Image_59999.tif
    └── Parameters.txt

Let decompose this.

### Run directory
The run usually contains 

    Run 01/
    ├── Files
    ├── Images
    └── Parameters.txt

It can also contain

    Run 01/
        ├── Files
        ├── Run.dcimg
        ├── Run.tif
        └── Parameters.txt

If working with dcimg.

#### Parameters.txt
Info about experiment. Created by Lightsheet program.

#### Images
Tif images ordered in time. (could be interleaved)

#### Files
Files containing the analysis

### Files directory
Files contains a `Config.mat`, created when initializing the Focus, a stack `corrected` corresponding to the drift corrected images, and the `IP` (for Image Processing) folder.

    Files/
    ├── Config.mat
    ├── corrected.bin
    ├── corrected.mat
    ├── corrected.nhdr
    └── IP
        ├── background.mat
        ├── baseline_neuron
        │   ├── 03.bin
        │   ├── 03.mat
        │   ├── 04.bin
        │   ├── 04.mat
        │   ├── ...
        │   ├── 20.bin
        │   └── 20.mat
        ├── baseline_pixel
        ├── dff_neuron
        │   ├── 03.bin
        │   ├── 03.mat
        │   ├── 04.bin
        │   ├── 04.mat
        │   ├── ...
        │   ├── 20.bin
        │   └── 20.mat
        ├── dff_pixel
        ├── DriftBox.mat
        ├── driftCorrection.fig
        ├── Drifts.mat
        ├── graystack.bin
        ├── graystack.mat
        ├── mask.mat
        └── Segmented
            ├── 03.mat
            ├── 04.mat
            ├── ...
            └── 20.mat

What each of the files are will be explained later.