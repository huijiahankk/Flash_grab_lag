
% For flash grab illusion test.It's a concentric grating.
% Testting the Flash grab illusion size in 4 quadrant


clear all;close all;

if 1
    sbjname = 'hjh';
    isEyelink = 0;
    blockNum= 2;
    trialNum = 12;
elseif 0
    prompt = {'subject''s name','isEyelink(without eyelink 0 or use eyelink 1)','block number','trial number(multiples of 12)'};
    dlg_title = 'Set experiment parameters ';
    answer  = inputdlg(prompt,dlg_title);
    [sbjname] = answer{1};
    [isEyelink] = str2double(answer{2});
    [blockNum] = str2double(answer{3})
    [trialNum] = str2double(answer{4});
end
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
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, []); %
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
phaseShiftMat = [];

%----------------------------------------------------------------------
%         Grating parameters
%----------------------------------------------------------------------
% Define the dimensions of the grating and the number of cycles.
xCenter = windowRect(3) / 2; % Center X-coordinate
yCenter = windowRect(4) / 2; % Center Y-coordinate
gratingRadiusDva = 18; % degree of visual angle
gratingRadiusPix = dva2pix(gratingRadiusDva,eyeScreenDistence,windowRect,screenHeight); % Radius of the grating
numCycles = 18; % Number of cycles
cycleWidth = gratingRadiusPix / numCycles; % Width of each cycle in pixel
gratingRect = [xCenter - gratingRadiusPix, yCenter - gratingRadiusPix, xCenter + gratingRadiusPix, yCenter + gratingRadiusPix];

% Define variables for the animation speed and the phase of the grating
phaseSpeed = 4; % Speed of phase shift (pixel/frame)
maxPhaseShift = 3 * cycleWidth; % Maximum phase shift, typically one cycle width
maxPhaseShiftdva = pix2dva(ceil(maxPhaseShift),eyeScreenDistence,windowRect,screenHeight);
gratDurationInSec = 1; % grating show duration in seconds
gratDuraFrame= refreshRate * gratDurationInSec;


% Create a matrix to store the grating image
[X, Y] = meshgrid(linspace(-gratingRadiusPix, gratingRadiusPix, round(2 * gratingRadiusPix)), linspace(-gratingRadiusPix, gratingRadiusPix, round(2 * gratingRadiusPix)));
R = sqrt(X.^2 + Y.^2);

%----------------------------------------------------------------------
%  define the size of the center grey disk and mask wedge
%----------------------------------------------------------------------
centerDiskRadiusDva = 3;
centerDiskRadiusPix = dva2pix(centerDiskRadiusDva,eyeScreenDistence,windowRect,screenHeight); % Diameter of the grey disk in pixels, adjust as needed
centerDiskRect = [xCenter - centerDiskRadiusPix, yCenter - centerDiskRadiusPix, xCenter + centerDiskRadiusPix, yCenter + centerDiskRadiusPix];

% Define mask wedge angles
wedgeCoverAngle = 315;
wedgeStartMat = [67.5 157.5 247.5 337.5];


%----------------------------------------------------------------------
%        flashed red bar parameters
%----------------------------------------------------------------------
flash.WidthDva = 0.5; % Width of the red flashed bar in visual degree angle
flash.LengthDva = 3; % Height of the red flashed bar in visual degree angle
flash.WidthPix = dva2pix(flash.WidthDva,eyeScreenDistence,windowRect,screenHeight);
flash.LengthPix = dva2pix(flash.LengthDva,eyeScreenDistence,windowRect,screenHeight);
% flash.Angle = 135;% The angle of rotation in degrees
flash.Size = [0, 0, flash.WidthPix, flash.LengthPix];  % Red bar size before rotation
flash.LocDegree = [45 135 225 315];
flash.LocMat =  repmat(flash.LocDegree,1,trialNum/4);
flash.CenterDva = 300 * maxPhaseShiftdva; % degree of visual angle from fixation center
flash.PresFrame = 3; % frame
flash.MotDirecMat = repmat([-1 1],1,trialNum/2); % - 1 means motion outward   1 mean inward



flash.Image = ones(10, 100, 3);
flash.Image(:, :, 1) = 1;
flash.Image(:, :, 2) = 0;
flash.Image(:, :, 3) = 0;
flash.Texture = Screen('MakeTexture', window, flash.Image);

%----------------------------------------------------------------------
%            parameters of black line
%----------------------------------------------------------------------

probe.LocDva = [0 0 0] + flash.CenterDva; % degree of visual angle
probe.LocPixel = dva2pix(probe.LocDva,eyeScreenDistence,windowRect,screenHeight);
probe.LocMat = Shuffle(repelem(probe.LocPixel,trialNum/3));
probe.MoveStep = 0.3; % pixel
probe.TempX = 0;
probe.TempY = 0;

probe.Tilt = 135;  % in degree
probe.WidthDva = 0.5;
probe.LengthDva = 3;
probe.WidthPix = dva2pix(probe.WidthDva,eyeScreenDistence,windowRect,screenHeight);
probe.LengthPix = dva2pix(probe.LengthDva,eyeScreenDistence,windowRect,screenHeight);

% Define a rectangle
probe.Mat(:,:,1) = zeros(probe.LengthPix,  probe.WidthPix);
probe.Mat(:,:,2) = zeros(probe.LengthPix,  probe.WidthPix) * 255;
probe.Mat(:,:,3) = probe.Mat(:,:,2);

% Make the rectangle into a texure
probe.Texture = Screen('MakeTexture', window, probe.Mat);
probe.Rect = Screen('Rect',probe.Texture);


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
    flash.LocMatTemp(block,:) = flash.LocMat(randperm(numel(flash.LocMat)));
    flash.MotDirec(block,:) = flash.MotDirecMat(randperm(numel(flash.MotDirecMat)));
%     flash.MotDirec(block,:) = flash.MotDirecMat;

    %----------------------------------------------------------------------
    %                 Experiment loop
    %----------------------------------------------------------------------


    for trial = 1:trialNum

        respToBeMade = true;
        phaseShift = 0; % Initial phase shift (frame)

        flash.LocSecq = flash.LocMatTemp(block,trial);

        [flash.CenterPosX flash.CenterPosY] = flashLocaQuad(flash.LocSecq,flash.CenterDva,eyeScreenDistence,windowRect,screenHeight,xCenter,yCenter);
        flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX, flash.CenterPosY);  % Position the center of the bar at the center of the grating

        if  flash.LocSecq == 135 | flash.LocSecq == 315
            flash.Angle = 45;
        else  flash.LocSecq == 45 | flash.LocSecq == 225
            flash.Angle = 135;
        end
        probe.TempX = 0;
        probe.TempY = 0;


        for i = 1:gratDuraFrame

            flashPresentFlag = 0;
            if flash.MotDirec(block,trial) == - 1
                % Calculate the current phase shift
                phaseShift = phaseShift - phaseSpeed;
            elseif flash.MotDirec(block,trial) == 1
                phaseShift = phaseShift + phaseSpeed;
            end
            phaseShiftMat(round(i)) = phaseShift;


            % Generate the dynamic concentric square-wave grating
            dynamicR = R + phaseShift; % Apply the phase shift
            dynamicGrating = double(rem(dynamicR, cycleWidth * 2) < cycleWidth);

            % Apply the circular mask: inside the grating radius, use dynamicGrating; outside, keep it grey
            maskedGrating = ones(size(R)) * grey;  % Start with a grey mask everywhere
            maskedGrating(R <= gratingRadiusPix) = dynamicGrating(R <= gratingRadiusPix);  % Apply updated grating inside the mask

            maskedGratingTexture = Screen('MakeTexture', window, maskedGrating);
            Screen('DrawTexture', window, maskedGratingTexture, [], gratingRect);

            %         Draw grating wedges
            if flash.LocSecq == 45
                wedgeStart = wedgeStartMat(1);
            elseif flash.LocSecq == 135
                wedgeStart = wedgeStartMat(2);
            elseif flash.LocSecq == 225
                wedgeStart = wedgeStartMat(3);
            elseif flash.LocSecq == 315
                wedgeStart = wedgeStartMat(4);
            end
            Screen('FillArc', window, grey, gratingRect,wedgeStart, wedgeCoverAngle);

            % Reset the phaseShift to create continuous motion
            if phaseShift > maxPhaseShift || phaseShift < -maxPhaseShift
                phaseSpeed = -phaseSpeed; % Reverse the direction of motion

                % Check if the phaseShift is greater than maxPhaseShift and the direction has changed to inward
                %  - 1 means motion outward   1 mean inward
                if flash.MotDirec(block,trial) == 1  &&   phaseShift > maxPhaseShift
                    % Draw the rotated red bar only when the direction changes to inward
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    flashPresentFlag = 1; % Set flag to indicate the flash was presented
                elseif  flash.MotDirec(block,trial) == -1  &&   phaseShift < - maxPhaseShift
                    % Draw the rotated red bar only when the direction changes to inward
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    flashPresentFlag = 1; % Set flag to indicate the flash was presented

                end
            end


            %         Draw the grey disk and fixtion in the center of the screen
            Screen('FillOval', window, grey, centerDiskRect);
            Screen('DrawLines', window, allCoords, LineWithPix, black, [xCenter,yCenter]);
            Screen('Flip', window);
            % define the present frame of the flash
            if flashPresentFlag
                WaitSecs((1/refreshRate) * flash.PresFrame);
            end
            WaitSecs(1/refreshRate);
        end

        % -------------------------------------------------------
        %             Draw  response picture
        % --------------------------------------------------------

        % Find all keyboards (returns a device index for each keyboard)
        [keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
        % Start a loop to check for key presses
        respToBeMade = true;
        while respToBeMade
            % Check each connected keyboard
            for i = 1:length(keyboardIndices)
                [keyIsDown, ~, keyCode] = KbCheck(keyboardIndices(i));

                if keyIsDown
                    if keyCode(KbName('ESCAPE'))
                        ShowCursor;
                        sca;
                        return;
                    elseif keyCode(KbName('LeftArrow'))
                        if  flash.LocSecq == 135 | flash.LocSecq == 315
                            probe.TempX = probe.TempX - probe.MoveStep;
                            probe.TempY = probe.TempY - probe.MoveStep;
                        else  flash.LocSecq == 45 | flash.LocSecq == 225
                            probe.TempX = probe.TempX - probe.MoveStep;
                            probe.TempY = probe.TempY + probe.MoveStep;
                        end
                    elseif keyCode(KbName('RightArrow'))
                        if  flash.LocSecq == 135 | flash.LocSecq == 315
                            probe.TempX = probe.TempX + probe.MoveStep;
                            probe.TempY = probe.TempY + probe.MoveStep;
                        else  flash.LocSecq == 45 | flash.LocSecq == 225
                            probe.TempX = probe.TempX + probe.MoveStep;
                            probe.TempY = probe.TempY - probe.MoveStep;
                        end
                    elseif keyCode(KbName('Space'))
                        respToBeMade = false;
                    end
                end
            end
            % draw reference line
            lineDestinationRect = CenterRectOnPoint(probe.Rect,flash.CenterPosX + probe.TempX, flash.CenterPosY + probe.TempY);
            Screen('DrawTexture',window,probe.Texture,flash.Rect,lineDestinationRect,flash.Angle);
            Screen('DrawLines', window, allCoords, LineWithPix, black, [xCenter,yCenter]);
            Screen('Flip', window);
            % You can add a small pause to prevent CPU overloading
            WaitSecs(0.01);
        end
    end
    probe.PosXMat(block,trial) = probe.TempX;
    probe.PosYMat(block,trial) = probe.TempY;
end

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------

savePath = 'data/';
time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
save(filename2,'flash','probe');
% save(filename2);

sca;