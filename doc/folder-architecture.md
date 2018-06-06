# Folder architecture

The old folder architecture has been replaced by the one given in the Focus (see Neurotools +NT.@Focus.architecture). Here is a sample

    Run 03
    ├── Analysis
    │   ├── Background
    │   │   └── background.mat
    │   ├── Baseline
    │   │   ├── neuron
    │   │   └── pixel
    │   ├── corrected.stack
    │   │   ├── corrected.bin
    │   │   ├── corrected.mat
    │   │   └── corrected.nhdr
    │   ├── DFF
    │   │   ├── neuron
    │   │   └── pixel
    │   ├── Drift
    │   │   ├── DriftBox.mat
    │   │   ├── driftCorrection.fig
    │   │   └── Drifts.mat
    │   ├── graystack.stack
    │   │   ├── graystack.bin
    │   │   ├── graystack.mat
    │   │   └── graystack.nhdr
    │   ├── Mask
    │   │   └── mask.mat
    │   ├── PhaseMap
    │   │   ├── neuron
    │   │   └── pixel
    │   └── Segmentation
    │       ├── 03.mat
    │       ├── 04.mat
    │       ├── ...
    │       ├── 19.mat
    │       └── 20.mat
    ├── Config.mat
    ├── Images
    │   ├── dcimg.dcimg
    │   └── dcimg.mat
    ├── Parameters.txt
    └── Stimulus.txt

### Data types
- `background.mat` 3D (x,y,z) `single` matrix
- `baseline` (per pixel or per neuron) 2D (t, xy) `uint16` collection
- `dff` (per pixel or per neuron) 2D (t, xy) `single` collection
- `DriftBox.mat` bounding box for drift computation ([x0 x1 y0 y1])
- `Drifts.mat` dx and dy in pixel
- `graystack` averaged 3D stack
- `mask.mat` 3D (x,y,z) `logical` matrix

#### Segmentation
'Segmented' folder contains a collection of mat files (one per layer) containing centerCoord, neuronShape and numberNeuron.
- centerCoord is x,y pixel coordinates of neurons centers
- neuronShape is a cell containing linear indexes for neuron pixels
- numberNeuron is the number of neurons in this layer.