function dva = pix2dva(pixel,eyeScreenDistence,rect,screenHeight);

% pixel = tand(dva) * eyeScreenDistence *  rect(4)/screenHeight;
dva = atan(pixel * screenHeight/(eyeScreenDistence *  rect(4))); 