function pixel = dva2pix(dva,eyeScreenDistence,windowRect,screenHeight)

pixel = round(tand(dva) * eyeScreenDistence *  windowRect(4)/screenHeight);