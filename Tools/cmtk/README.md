# Mini cmtk user documentation

cmtk stands for Computational Morphometry ToolKit

## Online documentation

- [CMTK user guide (pdf)](https://www.nitrc.org/docman/view.php/212/708/UserGuideCMTK.pdf)
- [NITRC project page](https://www.nitrc.org/projects/cmtk)
- [all documents](https://www.nitrc.org/docman/?group_id=212)
- [Tommaso's guide](https://cloud.ljp.upmc.fr/index.php/s/AdYNq0zw65NUCBV)

## Install

Just install the 'cmtk' package.

    sudo apt install cmtk

That's all

## Use

All cmtk commands can be used from terminal. To know the all the available commands, enter

    cmtk --help

To get help for a specific command, see man page for this command.

In general, `-o` means 'output'.

### NRRD

NRRD is a format that can be read by CMTK. I strongly recommend using it. You can find online [documentation](http://teem.sourceforge.net/nrrd/) and [format specifications](http://teem.sourceforge.net/nrrd/format.html). It is composed of a header and a binary which can be in the same file (.nrrd) or in two different files (.bin and .nhdr for example).
You can read the head of a .nrrd file with `head your-file.nrrd`.

Create nrrd with ImageJ: Load image sequence with ImageJ and save it as .raw file. Then create a header file following this template and save it as a text file with the file extension .nhdr . 

NRRD0004 

type: uint16
dimension: 3
space: RAS
sizes: 614 1018 20
space directions: (0.8,0,0) (0,0.8,0) (0,0,10.00)
space units: "um" "um" "um"
encoding: raw
endian: big
space origin: (0,0,0)
data file: filename.raw

### cmtk registration

To get help :

    man cmtk registration

Example :

    cmtk registration -o transformation.xform --dofs 3,6,9 ReferenceImage.nrrd FloatingImage.nhdr
    
Example with options to run faster :
    
    cmtk registration --sampling 3 --coarsest 25 --omit-original-data --accuracy 3 \\
    -o transformation.xform --dofs 3,6,9 ReferenceImage.nrrd FloatingImage.nhdr

### apply transformation

To apply a transformation already computed :

    cmtk reformatx -o transformed.nrrd --floating floatingImage.nhdr targetImage.nrrd transformation.xform

To apply the inverse transformation, just add `-i` or `--inverse` :

    cmtk reformatx -o transformed.nrrd --floating floatingImage.nhdr targetImage.nrrd -i transformation.xform

### apply on coordinates

To apply a transformation on coordinates, use `streamxform` which reads from standard input and prints to standard output. For example

    echo 0 0 0 | cmtk streamxform affine.xform
If you want to convert a lot of coordinates, write them in a text file and pass them to streamxform with `cat`. To inverse the transformation, you have to specify the end of options with `--` and then precise `--inverse` before the transformation. For example

    cat coord.txt | cmtk streamxform -- --inverse affine.xform
Be careful, inverse means 'moving → reference' and direct means 'reference → moving'.


### Limit of Jacobian for warp on zbb brain GCaMP5
--jacobian-weight 0.05 
note that smaller values lead to more local deformations

### Fast warp registration on zbb or zBrain (~60s)
options= 'warp -v --fast --grid-spacing 40 --refine 2 --jacobian-weight 0.001 --coarsest 6.4 --sampling 3.2 --accuracy 3.2 --omit-original-data '


## Alternatives

Instead of NRRD, we can use NIFTI (https://nifti.nimh.nih.gov/)

Instead of CMTK, we can use Ants (http://stnava.github.io/ANTsDoc/)
