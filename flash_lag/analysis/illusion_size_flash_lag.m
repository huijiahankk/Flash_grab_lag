clear all;
addpath '../function';

sbjnames = {'053','054','055','056','057','058','059','060','061','062','063','064','065','066','067','068'...
    '069','070','071','072','073','074','075','076','077','078','079','080','081','082'};  %  '039','040','041','042','043','044','045','046','047','048'

path = '../data';
cd(path);



for sbjnum = 1:length(sbjnames)
    s1 = sbjnames(sbjnum);
    s2 = '*.mat';
    s3 = strcat(s1,s2);
    Files = dir(fullfile(path, s3{1}));
    load (Files.name);


    [upperRightInward,upperRightOutward,upperRightNoMotion,lowerRightInward,lowerRightOutward,lowerRightNoMotion,lowerLeftInward,...
        lowerLeftOutward,lowerLeftNoMotion,upperLeftInward,upperLeftOutward,upperLeftNoMotion...
        nearFixInward,farFixInward,nearFixOutward,farFixOutward,nearFixNoMotion,farFixNoMotion] = deal([]);


    % mov.QuadMat = shuffledCombinations(:, 1)';
    % target.MotDirecMat = shuffledCombinations(:, 2)';
    % probe.CenterMat  = shuffledCombinations(:, 3)';


    for block = 1:blockNum
        for trial = 1: trialNum

            probe.CenterDist(block,trial) = sqrt((probe.PosXMat(block,trial) - xCenter)^2 + (probe.PosYMat(block,trial)-yCenter)^2);
%            
%              target.CenterDist(block,trial) = (object.CenterPosX(block,trial) - xCenter)^2 + (object.CenterPosY(block,trial) - yCenter)^2;
            target.CenterDist(block,trial) = sqrt((target.locWhenFlashX(block,trial) - xCenter)^2 + (target.locWhenFlashY(block,trial)-yCenter)^2);

            distancePix(block,trial) =  probe.CenterDist(block,trial) - target.CenterDist(block,trial) ;

            if target.QuadMat(trial) == 45
                if target.MotDirecMat(trial) == - 1   % -1 inward
                    upperRightInward = [upperRightInward,distancePix(block,trial)];
                elseif target.MotDirecMat(trial) == 1   % 1 outward
                    upperRightOutward = [upperRightOutward,distancePix(block,trial)];
                elseif target.MotDirecMat(trial) == 0
                    upperRightNoMotion = [upperRightNoMotion,distancePix(block,trial)];
                end
            elseif target.QuadMat(trial) == 135
                if target.MotDirecMat(trial) == - 1
                    lowerRightInward = [lowerRightInward,distancePix(block,trial)];
                elseif target.MotDirecMat(trial) == 1
                    lowerRightOutward= [lowerRightOutward,distancePix(block,trial)];
                elseif target.MotDirecMat(trial) == 0
                    lowerRightNoMotion= [lowerRightNoMotion,distancePix(block,trial)];
                end
            elseif target.QuadMat(trial) == 225
                if target.MotDirecMat(trial) == - 1
                    lowerLeftInward = [lowerLeftInward,distancePix(block,trial)];
                elseif target.MotDirecMat(trial) == 1
                    lowerLeftOutward = [lowerLeftOutward,distancePix(block,trial)];
                elseif target.MotDirecMat(trial) == 0
                    lowerLeftNoMotion= [lowerLeftNoMotion,distancePix(block,trial)];
                end
            elseif target.QuadMat(trial) == 315
                if target.MotDirecMat(trial) == - 1
                    upperLeftInward = [upperLeftInward,distancePix(block,trial)];
                elseif target.MotDirecMat(trial) == 1
                    upperLeftOutward = [upperLeftOutward,distancePix(block,trial)];
                elseif target.MotDirecMat(trial) == 0
                    upperLeftNoMotion= [upperLeftNoMotion,distancePix(block,trial)];
                end
            end

            if target.MotDirecMat(trial) == - 1   % illusion inward
                if object.locMat(trial) == object.locPix(1)
                    nearFixInward = [nearFixInward,distancePix(block,trial)];
                elseif object.locMat(trial) == object.locPix(2)
                    farFixInward = [farFixInward,distancePix(block,trial)];
                end
            elseif target.MotDirecMat(trial) ==  1  % illusion outward
                if object.locMat(trial) == object.locPix(1)
                    nearFixOutward = [nearFixOutward,distancePix(block,trial)];
                elseif object.locMat(trial) == object.locPix(2)
                    farFixOutward = [farFixOutward,distancePix(block,trial)];
                end
            elseif target.MotDirecMat(trial) ==  0  % no motion
                if object.locMat(trial) == object.locPix(1)
                    nearFixNoMotion = [nearFixNoMotion,distancePix(block,trial)];
                elseif object.locMat(trial) == object.locPix(2)
                    farFixNoMotion = [farFixNoMotion,distancePix(block,trial)];
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

    nearFixInwardMat(sbjnum,:) = - nearFixInward;
    farFixInwardMat(sbjnum,:)  = - farFixInward;
    nearFixOutwardMat(sbjnum,:) = nearFixOutward;
    farFixOutwardMat(sbjnum,:) = farFixOutward;

    nearFixNoMotionMat(sbjnum,:) = nearFixNoMotion;
    farFixNoMotionMat(sbjnum,:) = farFixNoMotion;


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

    nearFixInwardMatDva(sbjnum,:) = pix2dva(nearFixInwardMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);
    farFixInwardMatDva(sbjnum,:)  = pix2dva(farFixInwardMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);
    nearFixOutwardMatDva(sbjnum,:) = pix2dva(nearFixOutwardMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);
    farFixOutwardMatDva(sbjnum,:) = pix2dva(farFixOutwardMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);

    nearFixNoMotionMatDva(sbjnum,:) = pix2dva(nearFixNoMotionMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);
    farFixNoMotionMatDva(sbjnum,:) = pix2dva(farFixNoMotionMat(sbjnum,:), eyeScreenDistence, windowRect, screenHeight);


     % save each subjects' data into excel file
    data = table(upperRightInwardMatDva(sbjnum, :)', upperRightOutwardMatDva(sbjnum, :)', upperRightNoMotionMatDva(sbjnum, :)', lowerRightInwardMatDva(sbjnum, :)', ...
                 lowerRightOutwardMatDva(sbjnum, :)', lowerRightNoMotionMatDva(sbjnum, :)',lowerLeftInwardMatDva(sbjnum, :)', lowerLeftOutwardMatDva(sbjnum, :)', ...
                 lowerLeftNoMotionMatDva(sbjnum,:)',upperLeftInwardMatDva(sbjnum, :)', upperLeftOutwardMatDva(sbjnum, :)', upperLeftNoMotionMatDva(sbjnum, :)', ...
                 'VariableNames', {'upperRightInward', 'upperRightOutward', 'upperRightNoMotion','lowerRightInward', 'lowerRightOutward','lowerRightNoMotion' ...
                                   'lowerLeftInward', 'lowerLeftOutward','lowerLeftNoMotion', 'upperLeftInward', 'upperLeftOutward','upperLeftNoMotion'});
    data_near_far = table(nearFixInwardMatDva(sbjnum,:)',farFixInwardMatDva(sbjnum,:)',nearFixOutwardMatDva(sbjnum,:)', farFixOutwardMatDva(sbjnum,:)',...
        nearFixNoMotionMatDva(sbjnum,:)', farFixNoMotionMatDva(sbjnum,:)', 'VariableNames',{'nearFixInward','farFixInward','nearFixOutward','farFixOutward','nearFixNoMotion','farFixNoMotion'});


%     filename = sprintf('%s_data.xlsx', sbjnames{sbjnum});
% writetable(data, filename);
    filename_near_far = sprintf('%s_data_near_far_data.xlsx',sbjnames{sbjnum});
    writetable(data_near_far, filename_near_far);
    
end




left = [lowerLeftInwardMatDva lowerLeftOutwardMatDva upperLeftInwardMatDva upperLeftOutwardMatDva];
right = [upperRightInwardMatDva upperRightOutwardMatDva lowerRightInwardMatDva lowerRightOutwardMatDva];
upper = [upperRightInwardMatDva upperRightOutwardMatDva upperLeftInwardMatDva upperLeftOutwardMatDva];
lower = [lowerRightInwardMatDva lowerRightOutwardMatDva lowerLeftInwardMatDva lowerLeftOutwardMatDva];
Petal = [upperRightInwardMatDva lowerRightInwardMatDva lowerLeftInwardMatDva upperLeftInwardMatDva];
Fugal = [upperRightOutwardMatDva lowerRightOutwardMatDva lowerLeftOutwardMatDva upperLeftOutwardMatDva];
control = [upperRightNoMotionMatDva lowerRightNoMotionMatDva lowerLeftNoMotionMatDva upperLeftNoMotionMatDva];
nearIn = nearFixInwardMatDva;
farIn = farFixInwardMatDva;
nearOut = nearFixOutwardMatDva;
farOut = farFixOutwardMatDva;
nearNoMotion = nearFixNoMotionMatDva;
farNoMotion = farFixNoMotionMatDva;


% Store all matrices in a cell array
matrices = {left, right, upper, lower, Petal, Fugal,control,nearIn,farIn,nearOut,farOut,nearNoMotion,farNoMotion};
% matrices = {nearIn,farIn,nearOut,farOut};

% Calculate the mean of all elements in each matrix using cellfun
means = cellfun(@(x) mean(x, 'all'), matrices);
% Calculate the standard error of the mean (SEM)
sems = cellfun(@(x) std(x(:)) / sqrt(numel(x)), matrices);

% % Convert means to degrees of visual angle (dva)
% dvamean = pix2dva(means, eyeScreenDistence, windowRect, screenHeight);
% dvase = pix2dva(sems, eyeScreenDistence, windowRect, screenHeight);


labels = {'left', 'right','upper', 'lower', 'Petal', 'Fugal','Control','nearIn','farIn','nearOut','farOut','nearNoMotion','farNoMotion'};
% labels = {'nearIn','farIn','nearOut','farOut'};

bar(means);
hold on;
errorbar(means, sems, 'k', 'LineStyle', 'none'); % 'k' for black color, 'LineStyle', 'none' to remove connecting lines
set(gca, 'XTickLabel', labels);

% Add titles and labels
title('Mean of Each Condition');
xlabel('Condition');
ylabel('Mean distance from the target (dva)');


% Perform t-tests
[h_lr, p_lr] = ttest2(left(:), right(:));
[h_ul, p_ul] = ttest2(upper(:), lower(:));
[h_pf, p_pf] = ttest2(Petal(:), Fugal(:));
[h_nfi, p_nfi] = ttest2(nearIn(:), farIn(:));
[h_nfo, p_nfo] = ttest2(nearOut(:), farOut(:));


% Display results
disp('t-test results:');
disp(['Left vs Right: h = ', num2str(h_lr), ', p = ', num2str(p_lr)]);
disp(['Upper vs Lower: h = ', num2str(h_ul), ', p = ', num2str(p_ul)]);
disp(['Petal vs Fugal: h = ', num2str(h_pf), ', p = ', num2str(p_pf)]);
disp(['nearIn vs farIn: h = ', num2str(h_nfi), ', p = ', num2str(p_nfi)]);
disp(['nearOut vs farOut: h = ', num2str(h_nfo), ', p = ', num2str(p_nfo)]);


