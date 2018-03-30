# Memory mapping

To access easily huge 4D files as a matrix, I created a class `Mmap`. It is a wrapper for the matlab class `memmapfile`. I created a function in the `Focused` function group to make the use of Mmap easier in a Focused environment.

To instanciate this class in a focused environment, just call

	m = Focused.Mmap(F, 'corrected')

Where `F` is your current focus and `'corrected'` an example of a tag. This will let you call m as a 4D matrix. For example:

	m(:,:,3,1200)

gives you an image of the layer 3, timeframe 1200.

## 3D or 4D subscripting
The Mmap objects only support 4D (x,y,z,t) and 3D (xy,z,t) subscripting. Here, xy represent the linear indexing for the two first dimensions.

As a reminder for linear indexing:

    >> A=NaN(2,2)
    A =
       NaN   NaN
       NaN   NaN
    >> A([1 2 3 4]) = [1 2 3 4]
    A =
         1     3
         2     4
    >> 

It allows you to select a (x,y,z) region along time:

    m(312, 566, 7, :)

will return you the value of the pixel (312, 566) of the layer 7 for all the timeframes.

## Z renaming
The main thing that does the Mmap class is to redefine the Z when you call the memory map to keep the same names as during the experiment. For example:

1. during the experiment, you call the 1st layer '1' (top layer) and the 20th '20' (bottom layer).
2. when creating the binary file, you only select the layers '3' to '20'
3. these layers are written using the RAS standard, which means layer '20' becomes 1st and layer '3' becomes 12th.
4. when calling the Mmap, it will preserve the old names of the layers: calling layer '4' will return you the layer '4', which is the 11th in the binary file.

## Unfocused Mmap
If you want to use the Mmap outside a focused context, you can call it with:

    Mmap(inPathTag)

Where `inPathTag` is a string representing the absolute or relative path of the `.mat` and `.bin` files followed by the tag of the files (filename without extension). Example:

    Mmap('Data/RLS1P/2016-02-29/Run 05/Files/corrected')

It will give you exactly the same object, the only difference being you have to tell it the path you want to look at.