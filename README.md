# MIPS Image Processing

This project has 2 parts. 

## First Part

The first part, named `increase_brightness.asm`, reads a PPM file and increases the brightness of all pixels by ten, before writing the adjusted image to a new file. If the value of the pixel is already at the maximum value (255), it remains unchanged. Depending on which Operating System you are on, change the value `13` on lines `72` and `81` to `10` for Linux Operating System or keep it the same value of `10` for Mac Operating System.

## Second Part
The second part,named `greyscale.asm`, converts a colour image, consisting of RGB values [0-255], to a greyscale image by calculating the average of the RGB values and storing that as the new pixel and changing the file header to P2, before writing to disk. Depending on which Operating System you are on, change the value `13` on lines `81` and `90` to `10` for Linux Operating System or keep it the same value of `10` for Mac Operating System.


## Installation

You will need QTSPIM to run the code and a text editor of your choice to view the .asm and .ppm files

An image viewer is also needed. GIMP was used on Windows, but a VS Code extension will also work.
    
## Run Locally

Please note that the file paths for the 'inputfile' and 'outputfile' in both `increase_brightness.asm` and `greyscale.asm` are absolute paths and need to be adjusted for your pc. They can be found at lines 5 and 6 in both files. These addresses are the location of the PPM file to be read and the location of the file to write to. Ensure that the file being written to is empty. The code will always store the new image under the name `ALTERED_IMAGE.ppm`

It is important to understand that the code for this assignment only works with files that use the 'cr' file ending. The written file has been proven to open on windows but you might need to use an alternate file ending to view the original image.