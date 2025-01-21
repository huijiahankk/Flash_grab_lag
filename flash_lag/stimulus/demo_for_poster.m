
% For flash grab illusion test.It's a concentric grating.
% Testting the Flash grab illusion size in 4 quadrant
% phaseShiftMat in flash grab experiment is [160 200]
% moving bar is target,  flashed bar is object


clear all;close all;

if 1
    sbjname = 'kk';
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
target.MotDirec = [-1 1]; % - 1 means flash moves inward   1 mean flash moves outward

target.Image(:,:,1) = ones(target.LengthPix,  target.WidthPix);  % set the target color red
target.Image(:,:,2) = zeros(target.LengthPix,  target.WidthPix);
target.Image(:,:,3) = zeros(target.LengthPix,  target.WidthPix);
target.Texture = Screen('MakeTexture', window, target.Image);

target.startdistDva = 3;
target.startdistPix = dva2pix(target.startdistDva,eyeScreenDistence,windowRect,screenHeight) + 1;

target.StartdistanceX = target.startdistPix * cosd(85);
target.StartdistanceY = target.startdistPix * sind(85);

target.enddistDva = 15;
target.enddistPix = dva2pix(target.enddistDva,eyeScreenDistence,windowRect,screenHeight);

target.midpointPix = (target.startdistPix + target.enddistPix)/2;

target.moveMidDva = 6;
target.moveMidPix = dva2pix(target.moveMidDva,eyeScreenDistence,windowRect,screenHeight);


%----------------------------------------------------------------------
%        flashed red bar parameters
%----------------------------------------------------------------------
object.locPhaseShiftdva = 2;
object.locPhaseShiftPixTemp = dva2pix(object.locPhaseShiftdva,eyeScreenDistence,windowRect,screenHeight);
% have to consider FactorX * target.StartdistanceX
% object.locPix = [target.midpointPix - object.locPhaseShiftPixTemp - 0.5   target.midpointPix  + object.locPhaseShiftPixTemp + 1.5] - target.startdistPix;
% object.locPix = [target.midpointPix -  200];  % 160 196 200 236  same with phaseShift = 160;  when flash.maxPhaseShiftMat(trial) == flash.maxPhaseShiftPix(1)
object.locPix = [target.moveMidPix   target.moveMidPix];


object.Image(:,:,1) = zeros(target.LengthPix,  target.WidthPix); % set object green
object.Image(:,:,2) = ones(target.LengthPix,  target.WidthPix);
object.Image(:,:,3) = object.Image(:,:,1);
object.Texture = Screen('MakeTexture', window, object.Image);

object.presentFrame = 1; % frame

%----------------------------------------------------------------------
%            parameters of response probe
%----------------------------------------------------------------------
probe.shiftDva = [-1 1];
probe.shiftPix = dva2pix(probe.shiftDva,eyeScreenDistence,windowRect,screenHeight);

probe.MoveStep = 0.7; % pixel
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
    WaitSecs(0.3);
    %     %     KbStrokeWait;
    %     % Find all keyboard devices
    %     devices = PsychHID('Devices');
    %     keyboardIndices = [];
    %     for i = 1:length(devices)
    %         if strcmp(devices(i).usageName, 'Keyboard')
    %             keyboardIndices = [keyboardIndices, devices(i).index];
    %         end
    %     end

    % Example of using KbCheck to get keyboard input
%     [keyIsDown, seconds, keyCode] = KbCheck;
%     if keyIsDown
%         key = find(keyCode); % Returns the key code of the pressed key(s)
%         disp(['Key pressed: ', KbName(key)]);
%     end


    % Wait for any key press on any keyboard
    keyIsDown = false;
%     [keyIsDown, seconds, keyCode] = KbCheck;
    while ~keyIsDown
%         for i = 1:length(keyboardIndices)
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown
                keyIsDown = true;
                break; % Exit the loop once a key is detected
            end
%         end
        WaitSecs(0.01); % Short pause to avoid overwhelming the CPU
    end



    %----------------------------------------------------------------------
    %                 Experiment loop
    %----------------------------------------------------------------------

    trial = 1;

    while trial <=  trialNum % + extraTrialNum
        validTrialFlag = 1;   % validTrialFlag 1 valid trial     0 abandoned trial

        prekeyIsDown = 0;
        flashShowFlag = 0;
        target.shift = 0;
        object.flashFlag = 0;

        % - 1 means flash moves inward  illusion direction inward
        % 1 mean flash moves outward illusion outward
        %         if         target.MotDirecMat(trial) == 1
        target.shift1 = 0;
        responseTrialOnsetInterval = 0.01;
        %         elseif     target.MotDirecMat(trial) == - 1
        target.shift2 = target.enddistPix - target.startdistPix;  % have to consider FactorX * target.StartdistanceX
        %             responseTrialOnsetInterval = 0.01;
        %         elseif     target.MotDirecMat(trial) == 0
        %             if object.locMat(trial) == object.locPix(1)
        %                 target.shift = 140;   % 160  between 039 - 049
        %             elseif object.locMat(trial) == object.locPix(2)
        %                 target.shift = 220;  % 200  between 039 - 049
        %             end
        %             responseTrialOnsetInterval = 0.5;
        %         end


        FactorX = 1;
        FactorY = 1;
        target.Angle = 135;

        probe.TempX = 0;
        probe.TempY = 0;

        %         if target.MotDirecMat(trial) ~= 0

        for i = 1: (target.movDistPix/target.speed)
            flashShowFlag = 0;
            flashPresentFlag = 0;
            target.shift1 = target.shift1 + target.speed;
            target.CenterPosX1 = xCenter + FactorX * target.StartdistanceX + FactorX * target.shift1 * sind(45);
            target.CenterPosY1 = yCenter - FactorY * target.StartdistanceY - FactorY * target.shift1 * cosd(45);
            target.Rect = CenterRectOnPointd(target.Size, target.CenterPosX1, target.CenterPosY1);
            Screen('DrawTexture', window, target.Texture, [], target.Rect, target.Angle);
            target.shiftPerFrameMat1(i) = target.shift1;
            iMat(trial,i) = i;

            target.shift2 = target.shift2 - target.speed;
            target.CenterPosX2 = xCenter - FactorX * target.StartdistanceX - FactorX * target.shift2 * sind(45);
            target.CenterPosY2 = yCenter - FactorY * target.StartdistanceY - FactorY * target.shift2 * cosd(45);
            target.Rect = CenterRectOnPointd(target.Size, target.CenterPosX2, target.CenterPosY2);
            Screen('DrawTexture', window, target.Texture, [], target.Rect, 45);
            target.shiftPerFrameMat2(i) = target.shift2;



            if target.shift1 <= 124 && target.shift1 >= 116

                object.CenterPosX(block,trial) = xCenter + FactorX * target.StartdistanceY + FactorX * object.locMat(trial) * sind(45);
                object.CenterPosY(block,trial) = yCenter - FactorY * target.StartdistanceX - FactorY * object.locMat(trial) * cosd(45);
                target.locWhenFlashX(block,trial) = target.CenterPosX1;  %
                target.locWhenFlashY(block,trial) = target.CenterPosY1;
                object.Rect = CenterRectOnPointd(target.Size, object.CenterPosX(block,trial), object.CenterPosY(block,trial) );
                Screen('DrawTexture', window, object.Texture, [], object.Rect, 135);
                target.lastLocMat1(block,trial) = target.shift1;
                objectMat1(block,trial) = i;
                target.locMat(block,trial)= object.locMat(trial);
            end

            if target.shift2 >= 116 && target.shift2 <= 124

                object.CenterPosX2(block,trial) = xCenter - FactorX * target.StartdistanceY - FactorX * object.locMat(trial) * sind(45);
                object.CenterPosY2(block,trial) = yCenter - FactorY * target.StartdistanceX - FactorY * object.locMat(trial) * cosd(45);
                target.locWhenFlashX(block,trial) = target.CenterPosX2;
                target.locWhenFlashY(block,trial) = target.CenterPosY2;
                object.Rect2 = CenterRectOnPointd(target.Size, object.CenterPosX2(block,trial), object.CenterPosY2(block,trial) );
                Screen('DrawTexture', window, object.Texture, [], object.Rect2, 45);
                objectMat2(block,trial) = i;
                target.lastLocMat2(block,trial) = target.shift2;
                target.locMat(block,trial)= object.locMat(trial);

            end

            Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
            Screen('Flip', window);

        end

        Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
        Screen('Flip', window);
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
                        if  target.QuadMat(trial) == 135 || target.QuadMat(trial) == 315
                            probe.TempX = probe.TempX - probe.MoveStep;
                            probe.TempY = probe.TempY - probe.MoveStep;
                        else  target.QuadMat(trial) == 45 | target.QuadMat(trial) == 225;
                            probe.TempX = probe.TempX - probe.MoveStep;
                            probe.TempY = probe.TempY + probe.MoveStep;
                        end
                    elseif keyCode(KbName('RightArrow'))
                        if  target.QuadMat(trial) == 135 || target.QuadMat(trial) == 315
                            probe.TempX = probe.TempX + probe.MoveStep;
                            probe.TempY = probe.TempY + probe.MoveStep;
                        else  target.QuadMat(trial) == 45 | target.QuadMat(trial) == 225
                            probe.TempX = probe.TempX + probe.MoveStep;
                            probe.TempY = probe.TempY - probe.MoveStep;
                        end
                    elseif keyCode(KbName('UpArrow'))
                        validTrialFlag = 0;
                        fprintf(['Miss flash block number: %d\n','trial number: %d\n'],block,trial);
                        respToBeMade = false;
                    elseif keyCode(KbName('Space'))
                        OriginConditionMat{trial,:,block} = [target.QuadMat(trial), target.MotDirecMat(trial), probe.shiftPixMat(trial), object.locMat(trial)];
                        respToBeMade = false;
                    end
                    prekeyIsDown = keyIsDown;
                end
            end
            % draw reference line
            probe.DestinationRect = CenterRectOnPoint(probe.Size,probe.CenterPosX(block,trial) + probe.TempX, probe.CenterPosY(block,trial) + probe.TempY);

            %             strResponse = 'Please adjust the probe' ;
            %             Screen ('TextSize',window,30);
            %             Screen('TextFont',window,'Courier');
            %             DrawFormattedText(window, strResponse, 'center', 'center', grey,[],[],[],[],[],CenterQuadRect);
            Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);
            %             Screen('DrawTexture',window,probe.Te xture,[],probe.DestinationRect,target.Angle); % flash.Rect

            %             Screen('DrawLines', window, allCoords, LineWithPix, white, [xCenter,yCenter]);

            %             Screen('Flip', window);
            % add a small pause to prevent CPU overloading
            WaitSecs(0.01);
        end

        %  intervel between response and the trial onset
        WaitSecs(responseTrialOnsetInterval);

        % recording the location of the probe at the end of the trial
        probe.PosXMat(block,trial) = probe.CenterPosX(block,trial)  + probe.TempX;
        probe.PosYMat(block,trial) = probe.CenterPosY(block,trial)  + probe.TempY;

        % valid trial  1   % abandon trial  0
        validTrialMat(block,trial) = validTrialFlag;

        if validTrialFlag == 0
            trial = trial;
        elseif validTrialFlag == 1
            trial = trial + 1;
        end
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