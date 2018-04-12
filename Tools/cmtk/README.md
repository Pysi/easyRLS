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

### cmtk registration

To get help :

    man cmtk registration

Example :

    cmtk registration -o transformation.xform --dofs 3,6,9 ReferenceImage.nrrd FloatingImage.nhdr

### apply transformation

To apply a transformation already computed :

    cmtk reformatx -o transformed.nrrd --floating floatingImage.nhdr targetImage.nrrd transformation.xform

To apply the inverse transformation, just add `-i` or `--inverse` :

    cmtk reformatx -o transformed.nrrd --floating floatingImage.nhdr targetImage.nrrd -i transformation.xform

## Alternatives

Instead of NRRD, we can use NIFTI (https://nifti.nimh.nih.gov/)

Instead of CMTK, we can use Ants (http://stnava.github.io/ANTsDoc/)