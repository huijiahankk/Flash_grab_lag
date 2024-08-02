
% For flash grab illusion test.It's a concentric grating.
% Testting the Flash grab illusion size in 4 quadrant
% phaseShiftMat in flash grab experiment is [148 176 184 212]
% grating between gratingMaskRadiusPix 274 centerDiskRadiusPix 54 the
% width of the grading is 220 pixel



clear all;close all;

if 1
    sbjname = 'hjh';
    isEyelink = 0;
    blockNum= 1;
    trialNum = 48;
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
xCenter = windowRect(3) / 2; % Center X-coordinate
yCenter = windowRect(4) / 2; % Center Y-coordinate
refreshRate = FrameRate(window);
% refreshRate = 60;
commandwindow;
addpath ../function/;

eyeScreenDistence = 57;  %  57 cm
screenHeight = 30.5; % 26.8 cm  33.5
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
%         moving bar parameters
%----------------------------------------------------------------------
target.WidthDva = 0.5; % Width of the red flashed bar in visual degree angle
target.LengthDva = 3; % Height of the red flashed bar in visual degree angle
target.WidthPix = dva2pix(target.WidthDva,eyeScreenDistence,windowRect,screenHeight);
target.LengthPix = dva2pix(target.LengthDva,eyeScreenDistence,windowRect,screenHeight);
target.movDistDva = 12;  % in flash grab equals to gratingMaskRadius - centerDiskRadiusDva = 15-3=12
target.movDistPix = dva2pix(target.movDistDva,eyeScreenDistence,windowRect,screenHeight);

% flash.Angle = 135;% The angle of rotation in degrees
target.Size = [0, 0, target.WidthPix, target.LengthPix];  % Red bar size before rotation
target.QuadDegree = [45 135 225 315]; % % 10 pixels [45 45 45 45]     [45 135 225 315]
target.speed = 4; % pixel per frame
% mov.PresFrame = mov.lenghPix/mov.speed; % frame
target.MotDirec = [-1 0 1]; % - 1 means flash moves inward   1 mean flash moves outward

target.Image(:,:,1) = ones(target.LengthPix,  target.WidthPix);  % set the target color red
target.Image(:,:,2) = zeros(target.LengthPix,  target.WidthPix);
target.Image(:,:,3) = zeros(target.LengthPix,  target.WidthPix);
target.Texture = Screen('MakeTexture', window, target.Image);

target.startdistDva = 3;
target.startdistPix = dva2pix(target.startdistDva,eyeScreenDistence,windowRect,screenHeight);

target.StartdistanceX = target.startdistPix * cosd(85);
target.StartdistanceY = target.startdistPix * sind(85);

target.enddistDva = 15;
target.enddistPix = dva2pix(target.enddistDva,eyeScreenDistence,windowRect,screenHeight);


%----------------------------------------------------------------------
%        flashed red bar parameters
%----------------------------------------------------------------------
object.locPhaseShiftdva = 1;
object.locPhaseShiftPixTemp = dva2pix(object.locPhaseShiftdva,eyeScreenDistence,windowRect,screenHeight);
% object.loc = floor([target.movDistPix/2  - object.locPhaseShiftPixTemp   target.movDistPix/2  + object.locPhaseShiftPixTemp]);
object.locPix = [160 236];  % 160 196 200 236  same with phaseShift = 160;  when flash.maxPhaseShiftMat(trial) == flash.maxPhaseShiftPix(1)

object.Image(:,:,1) = zeros(target.LengthPix,  target.WidthPix); % set object green
object.Image(:,:,2) = ones(target.LengthPix,  target.WidthPix);
object.Image(:,:,3) = object.Image(:,:,1);
object.Texture = Screen('MakeTexture', window, object.Image);

object.presentFrame = 3; % frame

%----------------------------------------------------------------------
%            parameters of response probe
%----------------------------------------------------------------------
probe.shiftDva = [-1 1];
probe.shiftPix = dva2pix(probe.shiftDva,eyeScreenDistence,windowRect,screenHeight);

probe.MoveStep = 1; % pixel
probe.Tilt = 135;  % in degree
probe.WidthDva = 0.5;
probe.LengthDva = 3;
probe.WidthPix = dva2pix(probe.WidthDva,eyeScreenDistence,windowRect,screenHeight);
probe.LengthPix = dva2pix(probe.LengthDva,eyeScreenDistence,windowRect,screenHeight);

% Define a rectangle
probe.Image(:,:,1) = ones(probe.LengthPix,  probe.WidthPix);  % set the probe color red
probe.Image(:,:,2) = zeros(probe.LengthPix,  probe.WidthPix);
probe.Image(:,:,3) = probe.Image(:,:,2);

% Make the rectangle into a texure
probe.Texture = Screen('MakeTexture', window, probe.Image);
% probe.Rect = Screen('Rect',probe.Texture);
probe.Size = target.Size;
probe.intervalTime = 1;

%----------------------------------------------------------------------
%        Define all possible combinations of parameters
%----------------------------------------------------------------------
% Create all possible combinations
combinations = combvec(target.QuadDegree, target.MotDirec, probe.shiftPix,object.locPix)';
numCombinations = size(combinations, 1);

% Number of repetitions to ensure at least 40 trials for each combination
numRepetitions = ceil(trialNum / numCombinations);

% Repeat the combinations to ensure we have enough trials
combinationsRepeated = repmat(combinations, numRepetitions, 1);

% Shuffle the repeated combinations
shuffledCombinations = combinationsRepeated(randperm(size(combinationsRepeated, 1)), :);

% Assign the combinations to the parameters for the current block
target.QuadMat = shuffledCombinations(:, 1)';
target.MotDirecMat = shuffledCombinations(:, 2)';
probe.shiftPixMat  = shuffledCombinations(:, 3)';
object.locMat = shuffledCombinations(:, 4)';

%----------------------------------------------------------------------
%       load instruction image and waiting for a key press
%----------------------------------------------------------------------
ThisDirectory = pwd;
InstructImFile = strcat(ThisDirectory,'/FLE.png');
InstructIm     = imread(InstructImFile);
InstructTex    = Screen('MakeTexture',window,InstructIm);
sizeIm         = size(InstructIm);
InstructSrc    = [0 0 sizeIm(2) sizeIm(1)];
InstructDest   = [1 1 xCenter*2 yCenter*2];

%draw instructions
Screen('DrawTexture',window,InstructTex,InstructSrc,InstructDest,0); %draw fixation Gaussian
vbl=Screen('Flip', window);%, vbl + (waitframes - 0.5) * sp.ifi);

KbStrokeWait;




%----------------------------------------------------------------------
%      Experiment introduction
%----------------------------------------------------------------------



for block = 1: blockNum
    %----------------------------------------------------------------------
    %       present a start screen and wait for a key-press
    %----------------------------------------------------------------------
    formatSpec = 'This is the %dth of %d block. \n \n Press Any Key To Begin';
    A1 = block;
    A2 = blockNum;
    str = sprintf(formatSpec,A1,A2);

    topCenterQuadRect = [xCenter/2 0  xCenter*3/2 yCenter];
    CenterQuadRect = [xCenter/2 yCenter  xCenter*3/2 yCenter];
    DrawFormattedText(window, str, 'center', 'center', grey,[],[],[],[],[],topCenterQuadRect);
    Screen('Flip', window);
    %     KbStrokeWait;
    % Find all keyboard devices
    devices = PsychHID('Devices');
    keyboardIndices = [];
    for i = 1:length(devices)
        if strcmp(devices(i).usageName, 'Keyboard')
            keyboardIndices = [keyboardIndices, devices(i).index];
        end
    end

    % Wait for any key press on any keyboard
    keyIsDown = false;
    while ~keyIsDown
        for i = 1:length(keyboardIndices)
            [keyDown, ~, keyCode] = KbCheck(keyboardIndices(i));
            if keyDown
                keyIsDown = true;
                break; % Exit the loop once a key is detected
            end
        end
        WaitSecs(0.01); % Short pause to avoid overwhelming the CPU
    end



    %----------------------------------------------------------------------
    %                 Experiment loop
    %----------------------------------------------------------------------


    for trial = 1:trialNum

        %         fprintf('Starting trial %d of %d\n', trial, trialNum);
        prekeyIsDown = 0;
        flashShowFlag = 0;
        target.shift = 0;

        target.LocSecq = target.QuadMat(trial);
        % - 1 means flash moves inward   1 mean flash moves outward
        if         target.MotDirecMat(trial) == 1
            target.shift = 0;
            responseTrialOnsetInterval = 0.01;
        elseif     target.MotDirecMat(trial) == - 1
            target.shift = target.enddistPix;
            responseTrialOnsetInterval = 0.01;
        elseif     target.MotDirecMat(trial) == 0
            if object.locMat(trial) == 9
                target.shift = 40;
            elseif object.locMat(trial) == 45
                target.shift = 234;
            end
            responseTrialOnsetInterval = 0.5;
        end


        % Add jittering to flash.start  Random pixel shift less than 5
        jitterAmount(block,trial) = 0; % floor(rand * 10);

        if target.LocSecq == 45
            FactorX = 1;
            FactorY = -1;
            target.Angle = 135;
        elseif target.LocSecq == 135
            FactorX = 1;
            FactorY = 1;
            target.Angle = 45;
        elseif target.LocSecq == 225
            FactorX = -1;
            FactorY = 1;
            target.Angle = 135;
        elseif target.LocSecq == 315
            FactorX = -1;
            FactorY = -1;
            target.Angle = 45;
        end


        probe.TempX = 0;
        probe.TempY = 0;

        if target.MotDirecMat(trial) ~= 0

            for i = 1: (target.movDistPix/target.speed)
                flashShowFlag = 0;
                flashPresentFlag = 0;
                target.shift = target.shift + target.MotDirecMat(trial) * target.speed;
                target.CenterPosX(block,trial) = xCenter + FactorX * target.StartdistanceX + FactorX * target.shift * sind(45);
                target.CenterPosY(block,trial) = yCenter + FactorY * target.StartdistanceY + FactorY * target.shift * cosd(45);
                target.Rect = CenterRectOnPointd(target.Size, target.CenterPosX(block,trial), target.CenterPosY(block,trial) );
                Screen('DrawTexture', window, target.Texture, [], target.Rect, target.Angle);
                target.shiftMat(i) = target.shift;
                iMat(trial,i) = i;


                %             if   i == flash.locMat(trial)
                if target.shift >= object.locMat(trial) - target.speed && target.shift <= object.locMat(trial) + target.speed

                    object.CenterPosX(block,trial) = xCenter + FactorX * target.StartdistanceY + FactorX * target.shift * sind(45);
                    object.CenterPosY(block,trial) = yCenter + FactorY * target.StartdistanceX + FactorY * target.shift * cosd(45);
                    target.locWhenFlashX(block,trial) = target.CenterPosX(block,trial);
                    target.locWhenFlashY(block,trial) = target.CenterPosY(block,trial);
                    object.Rect = CenterRectOnPointd(target.Size, object.CenterPosX(block,trial), object.CenterPosY(block,trial) );
                    Screen('DrawTexture', window, object.Texture, [], object.Rect, target.Angle);
                    objectiMat(block,trial) = target.shift;

                end
                Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
                Screen('Flip', window);
            end

        elseif target.MotDirecMat(trial) == 0
            target.shift = object.locMat(trial);
            target.CenterPosX(block,trial) = xCenter + FactorX * target.StartdistanceX + FactorX * target.shift * sind(45);
            target.CenterPosY(block,trial) = yCenter + FactorY * target.StartdistanceY + FactorY * target.shift * cosd(45);
            target.Rect = CenterRectOnPointd(target.Size, target.CenterPosX(block,trial), target.CenterPosY(block,trial) );
            Screen('DrawTexture', window, target.Texture, [], target.Rect, target.Angle);

            object.CenterPosX(block,trial) = xCenter + FactorX * target.StartdistanceY + FactorX * target.shift * sind(45);
            object.CenterPosY(block,trial) = yCenter + FactorY * target.StartdistanceX + FactorY * target.shift * cosd(45);
            target.locWhenFlashX(block,trial) = target.CenterPosX(block,trial);
            target.locWhenFlashY(block,trial) = target.CenterPosY(block,trial);
            object.Rect = CenterRectOnPointd(target.Size, object.CenterPosX(block,trial), object.CenterPosY(block,trial) );
            Screen('DrawTexture', window, object.Texture, [], object.Rect, target.Angle);
            objectiMat(block,trial) = i;
            Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
            Screen('Flip', window);
            WaitSecs(object.presentFrame/refreshRate);

        end

        Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
        Screen('Flip', window);
        WaitSecs(probe.intervalTime);

        % -------------------------------------------------------
        %             Draw  response picture
        % --------------------------------------------------------
        % probe around the moving bar when flashed location
        probe.CenterPosX(block,trial) = target.locWhenFlashX(block,trial) + FactorX * probe.shiftPixMat(trial) * sind(45);
        probe.CenterPosY(block,trial) =  target.locWhenFlashY(block,trial) + FactorY * probe.shiftPixMat(trial) * cosd(45);

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
                        if  target.LocSecq == 135 || target.LocSecq == 315
                            probe.TempX = probe.TempX - probe.MoveStep;
                            probe.TempY = probe.TempY - probe.MoveStep;
                        else  target.LocSecq == 45 | target.LocSecq == 225;
                            probe.TempX = probe.TempX - probe.MoveStep;
                            probe.TempY = probe.TempY + probe.MoveStep;
                        end
                    elseif keyCode(KbName('RightArrow'))
                        if  target.LocSecq == 135 || target.LocSecq == 315
                            probe.TempX = probe.TempX + probe.MoveStep;
                            probe.TempY = probe.TempY + probe.MoveStep;
                        else  target.LocSecq == 45 | target.LocSecq == 225
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

%             strResponse = 'Please adjust the probe' ;
%             Screen ('TextSize',window,30);
%             Screen('TextFont',window,'Courier');
%             DrawFormattedText(window, strResponse, 'center', 'center', grey,[],[],[],[],[],CenterQuadRect);
            Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
            Screen('DrawTexture',window,probe.Texture,[],probe.DestinationRect,target.Angle); % flash.Rect

            %             Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);

            Screen('Flip', window);
            % add a small pause to prevent CPU overloading
            WaitSecs(0.01);
        end

        %  intervel between response and the trial onset
        WaitSecs(responseTrialOnsetInterval);
        probe.PosXMat(block,trial) = probe.CenterPosX(block,trial)  + probe.TempX;
        probe.PosYMat(block,trial) = probe.CenterPosY(block,trial)  + probe.TempY;

    end
end

%----------------------------------------------------------------------
%                      save parameters files
%----------------------------------------------------------------------

savePath = '../data/';
time = clock;

filename = sprintf('%s_%02g_%02g_%02g_%02g_%02g',sbjname,time(1),time(2),time(3),time(4),time(5));
filename2 = [savePath,filename];
% save(filename2,'flash','probe');
save(filename2);

sca;