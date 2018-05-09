# svesketrigger
This is a small VJ app made in Processing 3. It's purpose is to make simple white-on-black animations that can be triggered by OSC messages from other apps such as VDMX.

I use it to avoid rendering a lot of simple animations in different resolutions.

# features
- Rescalable Syphon output. Will run slow in larger resolutions.
- 8 animations: Line left to right, right to left, top to bottom, bottom to top, ring in from center, ring out from center.
- Controls for line width and animation speed. Change in values will only affect newly triggered animations.
- Trigger animations and controls with OSC messages or GUI.
- OSC in with custom port. Simply send the correct messages to the local IP of your system with the port of your choice.

# dependencies
Processing 3+
Ani by Benedikt Gross
oscP5 by Andreas Schlegel
Syphon by Andres Colubri

# wishes for the future
- Base animations on shaders to add visuals effects and improve framerate.
- More animations.
- Color and alpha options.
