
% For flash grab illusion test.It's a concentric grating.
% Testting the Flash grab illusion size in 4 quadrant


clear all;close all;

if 1
    sbjname = 'hjh';
    isEyelink = 0;
    blockNum= 4;
    trialNum = 32;
else
    prompt = {'subject''s name','isEyelink(without eyelink 0 or use eyelink 1)','block number','trial number(multiples of 10)'};
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
white = WhiteIndex(screenNumber) ;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, [0 0 800 600]); %
% refreshRate = FrameRate(window);
refreshRate = 60;
commandwindow;
addpath ../function/;

eyeScreenDistence = 66;  %  57 cm
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
gratingRadiusDva = 20; % degree of visual angle
gratingRadiusPix = dva2pix(gratingRadiusDva,eyeScreenDistence,windowRect,screenHeight); % Radius of the grating

gratingRect = [xCenter - gratingRadiusPix, yCenter - gratingRadiusPix, xCenter + gratingRadiusPix, yCenter + gratingRadiusPix];
contrastFactor = 0.1;
gratingMaskRadius = 15; % degree of visual angle
gratingMaskRadiusPix = dva2pix(gratingMaskRadius,eyeScreenDistence,windowRect,screenHeight); % Radius of the grating

% Define variables for the animation speed and the phase of the grating
phaseSpeed = 3; % Speed of phase shift (pixel/frame)
% phaseSpeedDva = pix2dva(phaseSpeed,eyeScreenDistence,windowRect,screenHeight);
% phaseSpeedDvaPerSec = phaseSpeedDva * pi * 60;

cycleWidthDva = 5;  % 5.6 in flash grab patient
cycleWidthPix = dva2pix(cycleWidthDva,eyeScreenDistence,windowRect,screenHeight) + 1;
% maxPhaseShiftDva = 10; % flash.CenterPix, Maximum phase shift, typically one cycle width
flash.maxPhaseShift = 2 * cycleWidthPix; % dva2pix(maxPhaseShiftDva,eyeScreenDistence,windowRect,screenHeight);
flash.maxPhaseShiftdva = 1;
flash.maxPhaseShiftPixTemp = dva2pix(flash.maxPhaseShiftdva,eyeScreenDistence,windowRect,screenHeight);
flash.maxPhaseShiftPix = [flash.maxPhaseShift - flash.maxPhaseShiftPix   flash.maxPhaseShift + flash.Tem];

% maxPhaseShiftdva = pix2dva(ceil(maxPhaseShift),eyeScreenDistence,windowRect,screenHeight);
gratDurationInSec = 1.5; % grating show duration in seconds
gratDuraFrame= refreshRate * gratDurationInSec;
% gratDurationInSec = 3 * cycleWidth /(phaseSpeed * refreshRate);

% Create a lower resolution grid for the grating image
% resolutionFactor = 0.5; % Adjust this to balance between performance and quality
% numPoints = round(2 * gratingRadiusPix * resolutionFactor);
% [X, Y] = meshgrid(linspace(-gratingRadiusPix, gratingRadiusPix, numPoints), linspace(-gratingRadiusPix, gratingRadiusPix, numPoints));
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
flash.QuadDegree = [45 135 225 315]; % % 10 pixels [45 45 45 45]     [45 135 225 315]
% flash.Quad =  repmat(flash.QuadDegree,1,trialNum/length(flash.QuadDegree));
% flash.CenterDva = 180 * maxPhaseShiftdva; % degree of visual angle from fixation center
flash.PresFrame = 3; % frame
flash.MotDirec = [-1 1]; % repmat([-1 1],1,trialNum/2); % - 1 means illusion inward   1 mean illusion outward

flash.Image(:,:,1) = ones(flash.LengthPix,  flash.WidthPix);
flash.Image(:,:,2) = zeros(flash.LengthPix,  flash.WidthPix);
flash.Image(:,:,3) = flash.Image(:,:,2);
flash.Texture = Screen('MakeTexture', window, flash.Image);

%----------------------------------------------------------------------
%            parameters of black line
%----------------------------------------------------------------------
probe.shiftDva = [-1 1];
probe.shiftPix = dva2pix(probe.shiftDva,eyeScreenDistence,windowRect,screenHeight);

probe.MoveStep = 0.3; % pixel
probe.Tilt = 135;  % in degree
probe.WidthDva = 0.5;
probe.LengthDva = 3;
probe.WidthPix = dva2pix(probe.WidthDva,eyeScreenDistence,windowRect,screenHeight);
probe.LengthPix = dva2pix(probe.LengthDva,eyeScreenDistence,windowRect,screenHeight);

% Define a rectangle
probe.Image(:,:,1) = ones(probe.LengthPix,  probe.WidthPix);
probe.Image(:,:,2) = ones(probe.LengthPix,  probe.WidthPix);
probe.Image(:,:,3) = probe.Image(:,:,2);

% Make the rectangle into a texure
probe.Texture = Screen('MakeTexture', window, probe.Image);
% probe.Rect = Screen('Rect',probe.Texture);
probe.Size = flash.Size;


%----------------------------------------------------------------------
%        Define all possible combinations of parameters
%----------------------------------------------------------------------
% Create all possible combinations
combinations = combvec(flash.QuadDegree, flash.MotDirec, probe.shiftPix, flash.maxPhaseShiftPix)';
numCombinations = size(combinations, 1);

% Number of repetitions to ensure at least 40 trials for each combination
numRepetitions = ceil(trialNum / numCombinations);

% Repeat the combinations to ensure we have enough trials
combinationsRepeated = repmat(combinations, numRepetitions, 1);

% Shuffle the repeated combinations
shuffledCombinations = combinationsRepeated(randperm(size(combinationsRepeated, 1)), :);

% Assign the combinations to the parameters for the current block
flash.QuadMat = shuffledCombinations(:, 1)';
flash.MotDirecMat = shuffledCombinations(:, 2)';
probe.shiftPixMat  = shuffledCombinations(:, 3)';
flash.maxPhaseShiftMat = shuffledCombinations(:, 4)';

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

        phaseShift = 0; %flash.MotDirecMat(trial) * (maxPhaseShift); % Initial phase shift (frame)
        prekeyIsDown = 0;
        phaseSpeed = abs(phaseSpeed);
        flash.LocSecq = flash.QuadMat(trial);

        % Add jittering to maxPhaseShift   Random pixel shift less than 5
        jitterAmount(block,trial) = 0; %floor(rand * 10);  

        if  flash.LocSecq == 135 | flash.LocSecq == 315
            flash.Angle = 45;
        else  flash.LocSecq == 45 | flash.LocSecq == 225
            flash.Angle = 135;
        end

        %         Draw grating wedges
        if flash.LocSecq == 45
            wedgeStart = wedgeStartMat(1);
            phaseshiftFactorX = 1;
            phaseshiftFactorY = -1;
        elseif flash.LocSecq == 135
            wedgeStart = wedgeStartMat(2);
            phaseshiftFactorX = 1;
            phaseshiftFactorY = 1;
        elseif flash.LocSecq == 225
            wedgeStart = wedgeStartMat(3);
            phaseshiftFactorX = -1;
            phaseshiftFactorY = 1;
        elseif flash.LocSecq == 315
            wedgeStart = wedgeStartMat(4);
            phaseshiftFactorX = -1;
            phaseshiftFactorY = -1;
        end



        probe.TempX = 0;
        probe.TempY = 0;


        for i = 1:gratDuraFrame

            flashPresentFlag = 0;
            % Update R directly using speed  if phaseShift is increasing,
            % the grating moving inward, phaseShift decreasing, grating
            % moving outward
            phaseShift = phaseShift + flash.MotDirecMat(trial) * phaseSpeed;

            % Generate the dynamic concentric square-wave grating
            dynamicR = R + phaseShift; % Apply the phase shift
            dynamicGrating = double(mod(dynamicR, cycleWidthPix * 2) < cycleWidthPix);
            dynamicGrating = (dynamicGrating * 2 - 1) * contrastFactor + grey;

            % Apply the circular mask: inside the grating radius, use dynamicGrating; outside, keep it grey
            maskedGrating = ones(size(R)) * grey;  % Start with a grey mask everywhere
            maskedGrating(R <= gratingMaskRadiusPix) = dynamicGrating(R <= gratingMaskRadiusPix);  % Apply updated grating inside the mask

            maskedGratingTexture = Screen('MakeTexture', window, maskedGrating);
            Screen('DrawTexture', window, maskedGratingTexture, [], gratingRect);

            Screen('FillArc', window, grey, gratingRect,wedgeStart, wedgeCoverAngle);
            %                         phaseShiftAll(trial,i) = phaseShift;

            %             % Reset the phaseShift to create continuous motion
            if phaseShift >= flash.maxPhaseShiftMat(trial) + jitterAmount | phaseShift <= - flash.maxPhaseShiftMat(trial) -  jitterAmount(block,trial) 
                phaseSpeed = -phaseSpeed; % Reverse the direction of motion
                phaseShiftCheck(trial) = phaseShift;
            end

            phaseShiftFrame(trial,i) = phaseShift;

            % Check if the phaseShift is greater than maxPhaseShift and the direction has changed to inward
            %  - 1 means motion outward   1 mean inward 
            if flash.MotDirecMat(trial) == 1  &&  phaseShift >= (flash.maxPhaseShiftMat(trial) + jitterAmount(block,trial))

                % Draw the rotated red bar only when the direction changes to inward

                flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * (4 * cycleWidthPix - phaseShift)  * sind(45);
                flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * (4 * cycleWidthPix - phaseShift)  * cosd(45);
                flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial), flash.CenterPosY(block,trial) );
                Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                phaseShiftMat(trial) = phaseShift;
                flashPresentFlag = 1; % Set flag to indicate the flash was presented

            elseif  flash.MotDirecMat(trial) == -1  &&   phaseShift <= (- flash.maxPhaseShiftMat(trial) -  jitterAmount(block,trial) )
                % Draw the rotated red bar only when the direction changes to inward
                flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * abs(phaseShift)  * sind(45);
                flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * abs(phaseShift)  * cosd(45);
                flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial) , flash.CenterPosY(block,trial) );
                Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                phaseShiftMat(trial) = phaseShift;
                flashPresentFlag = 1; % Set flag to indicate the flash was presented
            end

            %       Draw the grey disk and fixtion in the center of the screen
                        Screen('FillOval', window, grey, centerDiskRect);
            Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
            Screen('Flip', window);
            % define the present frame of the flash
            if flashPresentFlag
                WaitSecs((1/refreshRate) * flash.PresFrame);
            end

        end

        % -------------------------------------------------------
        %             Draw  response picture
        % --------------------------------------------------------
        probe.CenterPosX(block,trial) = flash.CenterPosX(block,trial) + phaseshiftFactorX * probe.shiftPixMat(trial) * sind(45);
        probe.CenterPosY(block,trial) = flash.CenterPosY(block,trial) + phaseshiftFactorY * probe.shiftPixMat(trial) * cosd(45);

        % Find all keyboards (returns a device index for each keyboard)
        [keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
        % Start a loop to check for key presses
        respToBeMade = true;
        while respToBeMade
            % Check each connected keyboard
            for i = 1:length(keyboardIndices)
                [keyIsDown, ~, keyCode] = KbCheck(keyboardIndices(i));
                %                 if keyIsDown && ~prekeyIsDown   % prevent the same press was treated twice
                if keyIsDown
                    if keyCode(KbName('ESCAPE'))
                        ShowCursor;
                        sca;
                        return;
                    elseif keyCode(KbName('LeftArrow'))
                        if  flash.LocSecq == 135 || flash.LocSecq == 315
                            probe.TempX = probe.TempX - probe.MoveStep;
                            probe.TempY = probe.TempY - probe.MoveStep;
                        else  flash.LocSecq == 45 | flash.LocSecq == 225;
                            probe.TempX = probe.TempX - probe.MoveStep;
                            probe.TempY = probe.TempY + probe.MoveStep;
                        end
                    elseif keyCode(KbName('RightArrow'))
                        if  flash.LocSecq == 135 || flash.LocSecq == 315
                            probe.TempX = probe.TempX + probe.MoveStep;
                            probe.TempY = probe.TempY + probe.MoveStep;
                        else  flash.LocSecq == 45 | flash.LocSecq == 225
                            probe.TempX = probe.TempX + probe.MoveStep;
                            probe.TempY = probe.TempY - probe.MoveStep;
                        end
                    elseif keyCode(KbName('Space'))
                        respToBeMade = false;
                    end
                    prekeyIsDown = keyIsDown;
                end
                %                 end
            end
            % draw reference line
            probe.DestinationRect = CenterRectOnPoint(probe.Size,probe.CenterPosX(block,trial) + probe.TempX, probe.CenterPosY(block,trial) + probe.TempY);
            Screen('DrawTexture',window,probe.Texture,[],probe.DestinationRect,flash.Angle); % flash.Rect
            Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
            Screen('Flip', window);
            % You can add a small pause to prevent CPU overloading
            WaitSecs(0.01);
        end
        probe.PosXMat(block,trial) = probe.CenterPosX(block,trial)  + probe.TempX;
        probe.PosYMat(block,trial) = probe.CenterPosY(block,trial)  + probe.TempY;
    end
end

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------

savePath = '../data/flash_grab';
time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'flash','probe');
save(filename2);

sca;