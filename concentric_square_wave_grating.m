
% For flash grab illusion test.It's a concentric grating.
% Testting the Flash grab illusion size in 4 quadrant


clear all;close all;

prompt = {'subject''s name','isEyelink(without eyelink 0 or use eyelink 1)','block number','trial number(multiples of 3)'};
dlg_title = 'Set experiment parameters ';
answer  = inputdlg(prompt,dlg_title);
[sbjname] = answer{1};
[isEyelink] = str2double(answer{2});
[blockNum] = str2double(answer{3})
[trialNum] = str2double(answer{4});

fprintf(['sbjname: %s\n','isEyelink: %d\n','block number: %d\n','trial number: %d\n'],sbjname,isEyelink,blockNum,trialNum);

% isEyelink = str2num(isEyelink);

%----------------------------------------------------------------------
%           Initialize Psychtoolbox and open a window
%----------------------------------------------------------------------
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
grey = WhiteIndex(screenNumber) / 2;
black = BlackIndex(screenNumber) ;
red = [255, 0, 0];
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [0 0 800 600]);
refreshRate = FrameRate(window);
commandwindow;
addpath function/;

eyeScreenDistence = 57;  % 78cm  68sunnannan
screenHeight = 33.5; % 26.8 cm
% Get the number of pixels in the vertical dimension of the screen
screenHeightPixels = windowRect(4);

%   draw the fixcross
fixCrossDimPixDva = 0.5;
fixCrossDimPix = dva2pix(fixCrossDimPixDva,eyeScreenDistence,windowRect,screenHeight);
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
LineWithPix = 6;

%----------------------------------------------------------------------
%         Grating parameters
%----------------------------------------------------------------------
% Define the dimensions of the grating and the number of cycles.
xCenter = windowRect(3) / 2; % Center X-coordinate
yCenter = windowRect(4) / 2; % Center Y-coordinate
gratingRadius = min(xCenter, yCenter) - 50; % Radius of the grating
numCycles = 18; % Number of cycles
cycleWidth = gratingRadius / numCycles; % Width of each cycle

% define the size of the center grey disk
centerDiskRadiusDva = 3;
centerDiskRadiusPix = dva2pix(centerDiskRadiusDva,eyeScreenDistence,windowRect,screenHeight); % Diameter of the grey disk in pixels, adjust as needed
centerDiskRect = [xCenter - centerDiskRadiusPix, yCenter - centerDiskRadiusPix, xCenter + centerDiskRadiusPix, yCenter + centerDiskRadiusPix];

% Define variables for the animation speed and the phase of the grating
phaseShift = 0; % Initial phase shift (frame)
phaseSpeed = 3; % Speed of phase shift (pixel/frame)
maxPhaseShift = 3 * cycleWidth; % Maximum phase shift, typically one cycle width

% Define wedge angles
wedgeAngle = 45;
wedgeAnglesStart = -25;
wedgeAnglesMat = [wedgeAnglesStart, wedgeAnglesStart + 90, wedgeAnglesStart + 180, wedgeAnglesStart + 270];
gratingRect = [xCenter - gratingRadius, yCenter - gratingRadius, xCenter + gratingRadius, yCenter + gratingRadius];

% Create a matrix to store the grating image
[X, Y] = meshgrid(linspace(-gratingRadius, gratingRadius, round(2 * gratingRadius)), linspace(-gratingRadius, gratingRadius, round(2 * gratingRadius)));
R = sqrt(X.^2 + Y.^2);
grating = zeros(size(R));


% flashed red bar parameters
flash.WidthDva = 0.2; % Width of the red flashed bar in visual degree angle
flash.LengthDva = 5; % Height of the red flashed bar in visual degree angle
flash.WidthPix = dva2pix(flash.WidthDva,eyeScreenDistence,windowRect,screenHeight);
flash.LengthPix = dva2pix(flash.LengthDva,eyeScreenDistence,windowRect,screenHeight);
flash.Angle = 135;% The angle of rotation in degrees
flash.Size = [0, 0, flash.WidthPix, flash.LengthPix];  % Red bar size before rotation
flash.CenterDva = 10; % degree of visual angle from fixation center 
flash.CenterPix = dva2pix(flash.CenterDva,eyeScreenDistence,windowRect,screenHeight);
flash.CenterPosX = xCenter + flash.CenterPix * sin(45);
flash.CenterPosY = yCenter - flash.CenterPix * sin(45);
flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX, flash.CenterPosY);  % Position the center of the bar at the center of the grating

flash.Image = ones(10, 100, 3);
flash.Image(:, :, 1) = 1;
flash.Image(:, :, 2) = 0;
flash.Image(:, :, 3) = 0;
flash.Texture = Screen('MakeTexture', window, flash.Image);

%----------------------------------------------------------------------
%            parameters of black line
%----------------------------------------------------------------------

referLine.LocDva = [10 10 10]; % degree of visual angle
referLine.LocPixel = dva2pix(referLine.LocDva,eyeScreenDistence,windowRect,screenHeight);
referLine.LocMat = Shuffle(repelem(referLine.LocPixel,trialNum/3));

referLine.Tilt = 135;  % in degree
referline.WidthDva = 0.2;
referline.LengthDva = 3;
referline.WidthPix = dva2pix(referline.WidthDva,eyeScreenDistence,windowRect,screenHeight);
referline.LengthPix = dva2pix(referline.LengthDva,eyeScreenDistence,windowRect,screenHeight);

% Define a rectangle
referLine.Mat(:,:,1) = zeros(referline.LengthPix,  referline.WidthPix);
referLine.Mat(:,:,2) = zeros(referline.LengthPix,  referline.WidthPix) * 255;
referLine.Mat(:,:,3) = referLine.Mat(:,:,2);

% Make the rectangle into a texure
referLine.Texture = Screen('MakeTexture', window, referLine.Mat);
referLine.Rect = Screen('Rect',referLine.Texture);


for block = 1: blockNum
    %----------------------------------------------------------------------
    %       present a start screen and wait for a key-press
    %----------------------------------------------------------------------

    formatSpec = 'This is the %dth of %d block. \n \n Press Any Key To Begin';
    A1 = block;
    A2 = blockNum;
    str = sprintf(formatSpec,A1,A2);

    Screen ('TextSize',window,30);
    Screen('TextFont',window,'Courier');

    topCenterQuadRect = [xCenter/2 0  xCenter*3/2 yCenter];
    DrawFormattedText(window, str, 'center', 'center', black,[],[],[],[],[],topCenterQuadRect);
    Screen('Flip', window);
    KbStrokeWait;


    %----------------------------------------------------------------------
    %                 Experiment loop
    %----------------------------------------------------------------------


    for trial = 1:trialNum

        respToBeMade = true;
        durationInSeconds = 2; % grating show duration in seconds
        totalRefreshes = refreshRate * durationInSeconds;

        for i = 1:totalRefreshes
            % Calculate the current phase shift
            phaseShift = phaseShift + phaseSpeed;

            % Generate the dynamic concentric square-wave grating
            dynamicR = sqrt(X.^2 + Y.^2) + phaseShift; % Apply the phase shift

            dynamicGrating = double(rem(dynamicR, cycleWidth * 2) < cycleWidth);

            % Apply the circular mask: inside the grating radius, use dynamicGrating; outside, keep it grey
            maskedGrating = ones(size(R)) * grey;  % Start with a grey mask everywhere
            maskedGrating(R <= gratingRadius) = dynamicGrating(R <= gratingRadius);  % Apply updated grating inside the mask

            maskedGratingTexture = Screen('MakeTexture', window, maskedGrating);
            Screen('DrawTexture', window, maskedGratingTexture, [], gratingRect);

            %         Draw grating wedges
            for angle = 1: length(wedgeAnglesMat)
                Screen('FillArc', window, grey, gratingRect,wedgeAnglesMat(angle), wedgeAngle);
            end

            % Reset the phaseShift to create continuous motion
            if phaseShift > maxPhaseShift || phaseShift < -maxPhaseShift
                phaseSpeed = -phaseSpeed; % Reverse the direction of motion
                % Draw the rotated red bar
                Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                WaitSecs(3/refreshRate);
            end


            %         Draw the grey disk and fixtion in the center of the screen
            Screen('FillOval', window, grey, centerDiskRect);
            Screen('DrawLines', window, allCoords, LineWithPix, black, [xCenter,yCenter]);
            Screen('Flip', window);
            WaitSecs(1/refreshRate);
        end

        % -------------------------------------------------------
        %             Draw  response picture
        % --------------------------------------------------------

        while respToBeMade

            % draw reference line
            lineDestinationRect = CenterRectOnPoint(referLine.Rect,xCenter + referLine.LocMat(trial) * sind(45), yCenter - referLine.LocMat(trial) * cosd(45));
            Screen('DrawTexture',window,referLine.Texture,referLine.Rect,lineDestinationRect,referLine.Tilt);
            Screen('DrawLines', window, allCoords, LineWithPix, black, [xCenter,yCenter]);
            Screen('Flip', window);

            [keyIsDown,secs,keyCode] = KbCheck(-1);
            %         if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
            if keyCode(KbName('ESCAPE'))
                ShowCursor;
                sca;
                return
                % the bar was on the left of the gabor
            elseif keyCode(KbName('LeftArrow')) % || keyCode(KbName('1!'))
                response = 1;
                respToBeMade = false;
            elseif keyCode(KbName('RightArrow')) % || keyCode(KbName('2@'))
                response = 2;
                respToBeMade = false;
            elseif keyCode(KbName('Space'))
                respToBeMade = false;
            end
        end
        
        responseData(block,trial) = response;
    end
end
%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------

savePath = 'data/';
time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
save(filename2,'flash','referLine','responseData');
% save(filename2);

sca;