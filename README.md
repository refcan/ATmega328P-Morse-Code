# Computer Logic Module Coursework - Group 14
This is just a little repo to manage the source code of the coursework for the computer logic module.

Here is an explanation of the files:

## Makefile
The file responsible for the compilation of the code and upload to arduino uno.

## Untitled Diagram.xml
A diagram overview of the project I made using <https://www.draw.io/>, the file itself seems to do nothing but if you put it back into <https://www.draw.io/> you can view the diagram

## group_14.S
Main file that is executed, includes `main` segment and sets up inputs / outputs, then just waits for interrupts.

## init.S
File that does even more basic setup, provided by the uni in the archive of files we got for the coursework. No reason to think about it much

## input_handling.S
File that will handle reading the input, that's where the the interrupts and timers go!

## letters.S
File that will hold the declerations for the letter representations in a 7-segment display

## parse_input.S
File that has the task of determining what letter to display based on the input. More than likely the hardest part of the project.
