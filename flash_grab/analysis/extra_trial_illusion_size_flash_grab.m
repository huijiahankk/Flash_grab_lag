clear all;
addpath '../function';

sbjnames = {'003','004','005','006'}; % '003','004','005','006'
path = '../data';
cd(path);



for sbjnum = 1:length(sbjnames)
    s1 = sbjnames(sbjnum);
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    Files = dir(fullfile(path, s3{1}));
    load (Files.name);


    [upperRightInward,upperRightOutward,upperRightNoMotion,lowerRightInward,lowerRightOutward,lowerRightNoMotion,lowerLeftInward,...
        lowerLeftOutward,lowerLeftNoMotion,upperLeftInward,upperLeftOutward,upperLeftNoMotion] = deal([]);


    % flash.QuadMat = shuffledCombinations(:, 1)';
    % flash.MotDirecMat = shuffledCombinations(:, 2)';
    % probe.CenterMat  = shuffledCombinations(:, 3)';
    validTrialMat 

    for block = 1:blockNum
        for trial = 1: (trialNum + extraTrialNum)

            probe.CenterDist(block,trial) = sqrt((probe.PosXMat(block,trial) - xCenter)^2 + (probe.PosYMat(block,trial)-yCenter)^2);
            flash.CenterDist(block,trial) = sqrt((flash.CenterPosX(block,trial) - xCenter)^2 + (flash.CenterPosY(block,trial)-yCenter)^2);

            distancePix(block,trial) =  probe.CenterDist(block,trial) - flash.CenterDist(block,trial) ;


            
            if flash.QuadMat(trial) == 45
                if flash.MotDirecMat(trial) == - 1   % -1 inward
                    upperRightInward = [upperRightInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1   % 1 outward
                    upperRightOutward = [upperRightOutward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 0
                    upperRightNoMotion = [upperRightNoMotion,distancePix(block,trial)];
                end
            elseif flash.QuadMat(trial) == 135
                if flash.MotDirecMat(trial) == - 1
                    lowerRightInward = [lowerRightInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1
                    lowerRightOutward= [lowerRightOutward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 0
                    lowerRightNoMotion= [lowerRightNoMotion,distancePix(block,trial)];
                end
            elseif flash.QuadMat(trial) == 225
                if flash.MotDirecMat(trial) == - 1
                    lowerLeftInward = [lowerLeftInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1
                    lowerLeftOutward = [lowerLeftOutward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 0
                    lowerLeftNoMotion= [lowerLeftNoMotion,distancePix(block,trial)];
                end
            elseif flash.QuadMat(trial) == 315
                if flash.MotDirecMat(trial) == - 1
                    upperLeftInward = [upperLeftInward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 1
                    upperLeftOutward = [upperLeftOutward,distancePix(block,trial)];
                elseif flash.MotDirecMat(trial) == 0
                    upperLeftNoMotion= [upperLeftNoMotion,distancePix(block,trial)];
                end
            end

        end
    end

    upperRightInwardMat(sbjnum,:) = - upperRightInward;
    upperRightOutwardMat(sbjnum,:) = upperRightOutward;
    upperRightNoMotionMat(sbjnum,:) = upperRightNoMotion;

    lowerRightInwardMat(sbjnum,:) = - lowerRightInward;
    lowerRightOutwardMat(sbjnum,:) = lowerRightOutward;
    lowerRightNoMotionMat(sbjnum,:) = lowerRightNoMotion;

    lowerLeftInwardMat(sbjnum,:) = - lowerLeftInward;
    lowerLeftOutwardMat(sbjnum,:) = lowerLeftOutward;
    lowerLeftNoMotionMat(sbjnum,:) = lowerLeftNoMotion;

    upperLeftInwardMat(sbjnum,:) = - upperLeftInward;
    upperLeftOutwardMat(sbjnum,:) = upperLeftOutward;
    upperLeftNoMotionMat(sbjnum,:) = upperLeftNoMotion;



    upperRightInwardMatDva(sbjnum, :) = pix2dva(upperRightInwardMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);
    upperRightOutwardMatDva(sbjnum, :) = pix2dva(upperRightOutwardMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);
    upperRightNoMotionMatDva(sbjnum, :) = pix2dva(upperRightNoMotionMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);

    lowerRightInwardMatDva(sbjnum, :) = pix2dva(lowerRightInwardMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);
    lowerRightOutwardMatDva(sbjnum, :) = pix2dva(lowerRightOutwardMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);
    lowerRightNoMotionMatDva(sbjnum, :) = pix2dva(lowerRightNoMotionMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);

    lowerLeftInwardMatDva(sbjnum, :) = pix2dva(lowerLeftInwardMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);
    lowerLeftOutwardMatDva(sbjnum, :) = pix2dva(lowerLeftOutwardMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);
    lowerLeftNoMotionMatDva(sbjnum, :) = pix2dva(lowerLeftNoMotionMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);

    upperLeftInwardMatDva(sbjnum, :) = pix2dva(upperLeftInwardMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);
    upperLeftOutwardMatDva(sbjnum, :) = pix2dva(upperLeftOutwardMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);
    upperLeftNoMotionMatDva(sbjnum, :) = pix2dva(upperLeftNoMotionMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);



     % save each subjects' data into excel file
    data = table(upperRightInwardMatDva(sbjnum, :)', upperRightOutwardMatDva(sbjnum, :)', upperRightNoMotionMatDva(sbjnum, :)', lowerRightInwardMatDva(sbjnum, :)', ...
                 lowerRightOutwardMatDva(sbjnum, :)', lowerRightNoMotionMatDva(sbjnum, :)',lowerLeftInwardMatDva(sbjnum, :)', lowerLeftOutwardMatDva(sbjnum, :)', ...
                 lowerLeftNoMotionMatDva(sbjnum,:)',upperLeftInwardMatDva(sbjnum, :)', upperLeftOutwardMatDva(sbjnum, :)', upperLeftNoMotionMatDva(sbjnum, :)', ...
                 'VariableNames', {'upperRightInward', 'upperRightOutward', 'upperRightNoMotion','lowerRightInward', 'lowerRightOutward','lowerRightNoMotion' ...
                                   'lowerLeftInward', 'lowerLeftOutward','lowerLeftNoMotion', 'upperLeftInward', 'upperLeftOutward','upperLeftNoMotion'});


    filename = sprintf('%s_data.xlsx', sbjnames{sbjnum});
%     writetable(data, filename);

end

left = [lowerLeftInwardMat lowerLeftOutwardMat upperLeftInwardMat upperLeftOutwardMat];
right = [upperRightInwardMat upperRightOutwardMat lowerRightInwardMat lowerRightOutwardMat];
upper = [upperRightInwardMat upperRightOutwardMat upperLeftInwardMat upperLeftOutwardMat];
lower = [lowerRightInwardMat lowerRightOutwardMat lowerLeftInwardMat lowerLeftOutwardMat];
Petal = [upperRightInwardMat lowerRightInwardMat lowerLeftInwardMat upperLeftInwardMat];
Fugal = [upperRightOutwardMat lowerRightOutwardMat lowerLeftOutwardMat upperLeftOutwardMat];
control = [upperRightNoMotionMat lowerRightNoMotionMat lowerLeftNoMotionMat upperLeftNoMotionMat];

% Store all matrices in a cell array
matrices = {left, right, upper, lower, Petal, Fugal,control};

% Calculate the mean of all elements in each matrix using cellfun
means = cellfun(@(x) mean(x, 'all'), matrices);
% Calculate the standard error of the mean (SEM)
sems = cellfun(@(x) std(x(:)) / sqrt(numel(x)), matrices);

% Convert means to degrees of visual angle (dva)
dvamean = pix2dva(means, eyeScreenDistence, windowRect, screenHeight);
dvase = pix2dva(sems, eyeScreenDistence, windowRect, screenHeight);


labels = {'left', 'right','upper', 'lower', 'Petal', 'Fugal','Control'};

bar(dvamean);
hold on;
errorbar(dvamean, dvase, 'k', 'LineStyle', 'none'); % 'k' for black color, 'LineStyle', 'none' to remove connecting lines
set(gca, 'XTickLabel', labels);
ylim([-1 6]);

% Add titles and labels
title('Mean of Each Condition');
xlabel('Condition');
ylabel('Mean distance from the flash (dva)');


% Perform t-tests
[h_lr, p_lr] = ttest2(left(:), right(:));
[h_ul, p_ul] = ttest2(upper(:), lower(:));
[h_pf, p_pf] = ttest2(Petal(:), Fugal(:));


% Display results
disp('t-test results:');
disp(['Left vs Right: h = ', num2str(h_lr), ', p = ', num2str(p_lr)]);
disp(['Upper vs Lower: h = ', num2str(h_ul), ', p = ', num2str(p_ul)]);
disp(['Petal vs Fugal: h = ', num2str(h_pf), ', p = ', num2str(p_pf)]);