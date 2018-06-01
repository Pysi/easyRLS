# Install and update
easyRLS depends on matlab and non-matlab programs

## Matlab

To get easyRLS, do

    git clone https://github.com/LaboJeanPerrin/easyRLS.git

easyRLS depends heavily on NeuroTools, to get it do

    git clone https://github.com/LaboJeanPerrin/NeuroTools.git



## R runquantile
To compute the baseline, we use the function `runquantile` from the `caTools` R library. To install R 

    sudo apt install r-base

To install the library directly from R, run `R` and then `install.packages("caTools")`. This is not necessary for linux systems because the projects contains a copy of the shared library (`.so`).

In both cases, you have to add the shared library in Matlab by calling

    loadlibrary('caTools.so', 'caTools.h');
These files are present in easyRLS/Tools/caTools/.

## CMTK
See [mini cmtk doc](https://github.com/LaboJeanPerrin/easyRLS/tree/master/Tools/cmtk). You only have to do

    sudo apt install cmtk


## Update

To update the Matlab code, go in the concerned directory and pull the code with `git pull`. If you changed your local version of the code, you can use Gitkraken to resolve the conflicts.