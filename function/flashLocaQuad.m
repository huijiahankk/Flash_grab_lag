% flash location in 4 different quadrants
function  [CenterPosX,CenterPosY] = flashLocaQuad(LocSecq,CenterDva,eyeScreenDistence,windowRect,screenHeight,xCenter,yCenter)


CenterPix = dva2pix(CenterDva,eyeScreenDistence,windowRect,screenHeight);
CenterPosX = xCenter + CenterPix * sind(45);
CenterPosY = yCenter - CenterPix * cosd(45);

if LocSecq == 45
    CenterPosX = xCenter + CenterPix * sind(45);
    CenterPosY = yCenter - CenterPix * cosd(45);
elseif LocSecq == 135
    CenterPosX = xCenter + CenterPix * sind(45);
    CenterPosY = yCenter + CenterPix * cosd(45);
elseif LocSecq == 225
    CenterPosX = xCenter - CenterPix * sind(45);
    CenterPosY = yCenter + CenterPix * cosd(45);
elseif LocSecq == 315
    CenterPosX = xCenter - CenterPix * sind(45);
    CenterPosY = yCenter - CenterPix * cosd(45);
end



