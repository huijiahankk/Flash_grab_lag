

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
                    upperRightInward = [upperRightInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1   % 1 outward
                    upperRightOutward = [upperRightOutward,distancePix(block,trial)];
                end
            elseif flash.QuadMat(trial) == 135
                if flash.MotDirecMat(trial) == - 1
                    lowerRightInward = [lowerRightInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1
                    lowerRightOutward= [lowerRightOutward,distancePix(block,trial)];
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
                    upperLeftOutward = [upperLeftOutward,distancePix(block,trial)];
                end
            end

        end
    end

    upperRightInwardMat(sbjnum,:) = upperRightInward;
    upperRightOutwardMat(sbjnum,:) = upperRightOutward;
    lowerRightInwardMat(sbjnum,:) = lowerRightInward;
    lowerRightOutwardMat(sbjnum,:) = lowerRightOutward;
    lowerLeftInwardMat(sbjnum,:) = lowerLeftInward;
    lowerLeftOutwardMat(sbjnum,:) = lowerLeftOutward;
    upperLeftInwardMat(sbjnum,:) = upperLeftInward;
    upperLeftOutwardMat(sbjnum,:) = upperLeftOutward;

    upperRight(sbjnum,:) = upperRightOutwardMat(sbjnum,:)  - upperRightInwardMat(sbjnum,:) ;
    lowerRight(sbjnum,:) = lowerRightOutwardMat(sbjnum,:)  - lowerRightInwardMat(sbjnum,:) ;
    lowerLeft(sbjnum,:) = lowerLeftOutwardMat(sbjnum,:)  - lowerLeftInwardMat(sbjnum,:) ;
    upperLeft(sbjnum,:) = upperLeftOutwardMat(sbjnum,:)  - upperLeftInwardMat(sbjnum,:) ;
end

% Store all matrices in a cell array
matrices = {upperRight, lowerRight, lowerLeft, upperLeft};

% Calculate the mean of all elements in each matrix using cellfun
means = cellfun(@(x) mean(x, 'all'), matrices);
% Calculate the standard error of the mean (SEM)
sems = cellfun(@(x) std(x(:)) / sqrt(numel(x)), matrices);

% Convert means to degrees of visual angle (dva)
dvamean = pix2dva(means, eyeScreenDistence, windowRect, screenHeight);
dvase = pix2dva(sems, eyeScreenDistence, windowRect, screenHeight);


labels = {'upperRight', 'lowerRight','lowerLeft', 'upperLeft'};

bar(dvamean);
hold on;
errorbar(dvamean, dvase, 'k', 'LineStyle', 'none'); % 'k' for black color, 'LineStyle', 'none' to remove connecting lines
set(gca, 'XTickLabel', labels);

% Add titles and labels
title('Mean of Each Condition');
xlabel('Condition');
ylabel('Mean distance from the flash (dva)');


% Perform t-tests
[h_ur, p_ur] = ttest2(upperRight(:), lowerRight(:));
[h_lr, p_lr] = ttest2(lowerRight(:), lowerLeft(:));
[h_ll, p_ll] = ttest2(lowerLeft(:), upperLeft(:));
[h_ul, p_ul] = ttest2(upperLeft(:), upperRight(:));

% Display results
disp('t-test results:');
disp(['UpperRight vs LowerRight: h = ', num2str(h_ur), ', p = ', num2str(p_ur)]);
disp(['LowerRight vs LowerLeft: h = ', num2str(h_lr), ', p = ', num2str(p_lr)]);
disp(['LowerLeft vs UpperLeft: h = ', num2str(h_ll), ', p = ', num2str(p_ll)]);
disp(['UpperLeft vs UpperRight: h = ', num2str(h_ul), ', p = ', num2str(p_ul)]);

