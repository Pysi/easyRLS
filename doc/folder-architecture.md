# Folder architecture

This document intends to provide an overview of the folder architecture. Each time you see three files with extensions xxx.bin, xxx.mat, xxx.nhdr, this corresponds to a single stack and the informations attached to it.

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
    ├── Parameters.txt
    └── RefBrain

Lets decompose this.

### Run directory
The run usually contains images

    Run 01/
    ├── Files/
    Images
    │   ├── Image_00000.tif
    │   ├── Image_00001.tif
    │   ├── Image_00002.tif
    │   ├── ...
    │   └── Image_59999.tif
    ├── Parameters.txt
    └── RefBrain/

It can also contain dcimg

    Run 01/
    ├── Files/
    ├── Run.dcimg
    ├── Run.tif
    ├── Parameters.txt
    └── RefBrain/

if working with dcimg.

#### Parameters.txt
Info about experiment. Created by Lightsheet program.

#### Images
Tif images ordered in time. (could be interleaved)

#### Reference brain
The RefBrain folder contains

    RefBrain/
    ├── affine.xform/
    │   ├── registration
    │   ├── settings
    │   ├── statistics
    │   └── studylist
    ├── RefBrain.nhdr
    ├── refCoordinates.mat
    └── reformated.nrrd
- RefBrain.nhdr is a link to a reference brain independent from the run.
- affine.xform is a transformation in xform style. Open affine.xform/registration to get more details.
- refCoordinates.mat are the coordinates of the segmented neurons transposed in the reference brain.
- reformated.nrrd is the stack given in affine.xform with the transformation applied.

#### Files
Files containing the analysis

### Files directory
Files contains a `Config.mat`, created when initializing the Focus, a stack `corrected` corresponding to the drift corrected images (RAST, uint16), and the `IP` (for Image Processing) folder.

    Files/
    ├── Config.mat
    ├── corrected.bin
    ├── corrected.mat
    ├── corrected.nhdr
    └── IP/
        ├── background.mat
        ├── baseline_neuron/
        │   ├── 03.bin
        │   ├── 03.mat
        │   ├── 04.bin
        │   ├── 04.mat
        │   ├── ...
        │   ├── 20.bin
        │   └── 20.mat
        ├── baseline_pixel/
        ├── dff_neuron/
        │   ├── 03.bin
        │   ├── 03.mat
        │   ├── 04.bin
        │   ├── 04.mat
        │   ├── ...
        │   ├── 20.bin
        │   └── 20.mat
        ├── dff_pixel/
        ├── DriftBox.mat
        ├── driftCorrection.fig
        ├── Drifts.mat
        ├── graystack.bin
        ├── graystack.mat
        ├── mask.mat
        └── Segmented/
            ├── 03.mat
            ├── 04.mat
            ├── ...
            ├── 20.mat
            └── coordinates.mat

### IP directory
A collection is a set of files with the layer number as their name. 

- `background.mat` 3D (x,y,z) `single` matrix
- `baseline` (per pixel or per neuron) 2D (t, xy) `uint16` collection
- `dff` (per pixel or per neuron) 2D (t, xy) `single` collection
- `DriftBox.mat` bounding box for drift computation ([x0 x1 y0 y1])
- `Drifts.mat` dx and dy in pixel
- `graystack` averaged 3D stack
- `mask.mat` 3D (x,y,z) `logical` matrix

#### Segmentation
'Segmented' folder contains a collection of mat files containing centerCoord, neuronShape and numberNeuron.
- centerCoord is x,y pixel coordinates of neurons centers
- neuronShape is a cell containing linear indexes for neuron pixels
- numberNeuron is the number of neurons in this layer.

