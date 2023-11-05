# GCC_Mercury
Repository for GCC Mercury Laser Cutter Related work

The powershell script attempts to convert standard Gcode created by Lightburn to the format accepted by the GCC laser driver (a form of HPGL)
You need to adjust the script to identify where to find the gcode file, and then at the end where to save the BIN

You can send the bin using window's shell copy cmd to LTP1:

Currently it has a single hardcoded 'Pen' inside so you have one fixed speed and power level, I intended to parse the GCODE find all the changes and create additional pens up front and then switch to them as the GCODE did but I kind of gave up on this when I realized I couldn't decode how the driver did raster engrave (it seems binary in the files not ASCII) - eventually I just retrofit the device with a Ruida controller.. I will post those details when I get a change

So this does NOT handle native Raster.. although I guess if the GCODE treats it as line movements you could probably get it close enough

