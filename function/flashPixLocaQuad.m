% flash location in 4 different quadrants
function  [CenterPosX,CenterPosY] = flashDvaLocaQuad(LocSecq,CenterPix,eyeScreenDistence,windowRect,screenHeight,xCenter,yCenter)


% CenterPix = dva2pix(CenterPix,eyeScreenDistence,windowRect,screenHeight);
% CenterPosX = xCenter + CenterPix * sind(45);
% CenterPosY = yCenter - CenterPix * cosd(45);

if LocSecq == 45
    CenterPosX = CenterPix * sind(45);
    CenterPosY =  - CenterPix * cosd(45);
elseif LocSecq == 135
    CenterPosX =  CenterPix * sind(45);
    CenterPosY =  CenterPix * cosd(45);
elseif LocSecq == 225
    CenterPosX =  - CenterPix * sind(45);
    CenterPosY = CenterPix * cosd(45);
elseif LocSecq == 315
    CenterPosX =  - CenterPix * sind(45);
    CenterPosY =  - CenterPix * cosd(45);
end



