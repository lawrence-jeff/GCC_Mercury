# GCC_Mercury
Repository for GCC Mercury Laser Cutter Related work

The powershell script attempts to convert standard Gcode created by Lightburn to the format accepted by the GCC laser driver (a form of HPGL). 
You need to adjust the script to identify where to find the gcode file, and then at the end where to save the BIN

You can send the bin using window's shell copy cmd to LTP1: (In my case I was using the parallel port, on a USB device I'm not sure how to handle)

Currently it has a single hardcoded 'Pen' inside so you have one fixed speed and power level, I intended to parse the GCODE find all the changes and create additional pens up front and then switch to them as the GCODE did but I kind of gave up on this when I realized I couldn't decode how the driver did raster engrave (it seems binary in the files not ASCII) - eventually I just retrofit the device with a Ruida controller.. I will post those details when I get a change

So this does NOT handle native Raster.. although I guess if the GCODE treats it as line movements you could probably get it close enough

Developed using Mercury LaserPro 1
If you want to expirement the best way I found was to create simple shapes (say a 100x100mm square) in a supported piece of software that correctly vectorizes (Corel and Nanocad were about the only things I found that did) then using the driver print to a file.. then open the file and using HPGL reference try to understand what it is doing.
