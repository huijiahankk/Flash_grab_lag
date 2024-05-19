function dva = pix2dva(pixel,eyeScreenDistence,windowRect,screenHeight)

% pixel = tand(dva) * eyeScreenDistence *  rect(4)/screenHeight;
dva = atand(pixel * screenHeight/(eyeScreenDistence *  windowRect(4))); 