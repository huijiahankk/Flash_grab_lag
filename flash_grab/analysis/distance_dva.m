

clear all;
addpath '../function';

sbjnames = {'hjh','pilotfour'};
path = '../data'; 
cd(path);


for sbjnum = 1:length(sbjnames)
    s1 = sbjnames(sbjnum);
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    Files = dir(fullfile(path, s3{1}));
    load (Files.name);


    [upperRightInward,upperRightOutward,lowerRightInward,lowerRightOutward,lowerLeftInward,...
        lowerLeftOutward,upperLeftInward,upperLeftOutward] = deal([]);


% flash.QuadMat = shuffledCombinations(:, 1)';
% flash.MotDirecMat = shuffledCombinations(:, 2)';
% probe.CenterMat  = shuffledCombinations(:, 3)';



    for block = 1:blockNum
        for trial = 1: trialNum

            probe.CenterDist(block,trial) = sqrt((probe.PosXMat(block,trial) - xCenter)^2 + (probe.PosYMat(block,trial)-yCenter)^2);
            flash.CenterDist(block,trial) = sqrt((flash.CenterPosX(block,trial) - xCenter)^2 + (flash.CenterPosY(block,trial)-yCenter)^2);

            distancePix(block,trial) =  probe.CenterDist(block,trial) - flash.CenterDist(block,trial) ;

            if flash.QuadMat(trial) == 45
                if flash.MotDirecMat(trial) == - 1   % -1 inward
                    upperRightInward(sbjnum,:) = [upperRightInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1   % 1 outward 
                    upperRightOutward(sbjnum,:) = [upperRightOutward,distancePix(block,trial)];
                end
            elseif flash.QuadMat(trial) == 135
                if flash.MotDirecMat(trial) == - 1
                    lowerRightInward(sbjnum,:) = [lowerRightInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1
                    lowerRightOutward(sbjnum,:) = [lowerRightOutward,distancePix(block,trial)];
                end
            elseif flash.QuadMat(trial) == 225
                if flash.MotDirecMat(trial) == - 1
                    lowerLeftInward(sbjnum,:) = [lowerLeftInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1
                    lowerLeftOutward(sbjnum,:) = [lowerLeftOutward,distancePix(block,trial)];
                end
            elseif flash.QuadMat(trial) == 315
                if flash.MotDirecMat(trial) == - 1
                    upperLeftInward(sbjnum) = [upperLeftInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1
                    upperLeftOutward(sbjnum) = [upperLeftOutward,distancePix(block,trial)];
                end
            end

        end
    end
end


means = [mean(upperRightInward), mean(upperRightOutward), mean(lowerRightInward), mean(lowerRightOutward), ...
    mean(lowerLeftInward), mean(lowerLeftOutward), mean(upperLeftInward), mean(upperLeftOutward)];

dvamean = pix2dva(means,eyeScreenDistence,windowRect,screenHeight);

labels = {'upperRightInward', 'upperRightOutward', 'lowerRightInward', 'lowerRightOutward'...
    'lowerLeftInward', 'lowerLeftOutward', 'upperLeftInward', 'upperLeftOurward'};

% Create a bar chart
bar(dvamean);
% errorbar(1:2:number_x_axis * 2,cell2mat(ave),cell2mat(ave_ste),'k.','LineWidth',1);
set(gca, 'XTickLabel', labels);

% Add titles and labels
title('Mean of Each Condition');
xlabel('Condition');
ylabel('Mean distance from the flash (dva)');



