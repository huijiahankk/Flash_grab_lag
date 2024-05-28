

clear all;
addpath '../function';

sbjnames = {'hjh'};
path = '../data'; 
cd(path);


for sbjnum = 1:length(sbjnames)
    s1 = sbjnames(sbjnum);
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    Files = dir(fullfile(path, s3{1}));
    load (Files.name);


    [upperRightInward,upperRightOutward,lowerRightInward,lowerRightOutward,lowerLeftInward,...
        lowerLeftOutward,upperLeftInward,upperLeftOurward] = deal([]);


% flash.QuadMat = shuffledCombinations(:, 1)';
% flash.MotDirecMat = shuffledCombinations(:, 2)';
% probe.CenterMat  = shuffledCombinations(:, 3)';



    for block = 1:blockNum
        for trial = 1: trialNum

%             flash.CenterPix = flash.phaseshiftFactor * cycleWidth;
%             flash.CenterPixResp(trial) = dva2pix(dva,eyeScreenDistence,windowRect,screenHeight);
            distancePix(block,trial) =  sqrt(probe.PosXMat(block,trial)^2 + probe.PosYMat(block,trial)^2) - flash.CenterPix;

            if flash.QuadMat(trial) == 45
                if flash.MotDirecMat(trial) == - 1   % -1 inward
                    upperRightInward = [upperRightInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1   % 1 outward 
                    upperRightOutward = [upperRightOutward,distancePix(block,trial)];
                end
            elseif flash.QuadMat(trial) == 135
                if flash.MotDirecMat(trial) == - 1
                    lowerRightInward = [lowerRightInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1
                    lowerRightOutward = [lowerRightOutward,distancePix(block,trial)];
                end
            elseif flash.QuadMat(trial) == 225
                if flash.MotDirecMat(trial) == - 1
                    lowerLeftInward = [lowerLeftInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1
                    lowerLeftOutward = [lowerLeftOutward,distancePix(block,trial)];
                end
            elseif flash.QuadMat(trial) == 315
                if flash.MotDirecMat(trial) == - 1
                    upperLeftInward = [upperLeftInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1
                    upperLeftOurward = [upperLeftOurward,distancePix(block,trial)];
                end
            end

        end
    end
end


means = [mean(upperRightInward), mean(upperRightOutward), mean(lowerRightInward), mean(lowerRightOutward), ...
    mean(lowerLeftInward), mean(lowerLeftOutward), mean(upperLeftInward), mean(upperLeftOurward)];

dvamean = pix2dva(means,eyeScreenDistence,windowRect,screenHeight);

labels = {'upperRightInward', 'upperRightOutward', 'lowerRightInward', 'lowerRightOutward'...
    'lowerLeftInward', 'lowerLeftOutward', 'upperLeftInward', 'upperLeftOurward'};

% Create a bar chart
bar(dvamean);
set(gca, 'XTickLabel', labels);

% Add titles and labels
title('Mean of Each Condition');
xlabel('Condition');
ylabel('Mean distance from the flash (dva)');



