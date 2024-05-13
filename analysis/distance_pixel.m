

clear all;
addpath '../function';
addpath '../data';
load('hjh_2024_05_13_14_22.mat');

% sbjnames = {'hjh','jye'};
% path = strcat('../data/');
% cd(path);
%
%
% for sbjnum = 1:length(sbjnames)
%
%         s1 = sbjnames(sbjnum);
%         s2 = '*.mat';
%         s3 = strcat(s1,s2);
% %         load(fullfile(path, s3));
%         Files = dir(fullfile(path, s3));
%         load (Files.name);
% end

[urI,urO,lrI,lrO,llI,llO,ulI,ulO] = deal([]);

for block = 1:blockNum
    for trial = 1: trialNum

        distancePix(block,trial) =  flash.CenterDvaResp(block,trial) - sqrt(probe.PosXMat(block,trial)^2 + probe.PosYMat(block,trial)^2) ;

        if flash.QuadMatTemp(block,trial) == 45
            if flash.MotDirec(block,trial) == - 1
                urI = [urI,distancePix(block,trial)];
            elseif flash.MotDirec(block,trial) == 1
                urO = [urO,distancePix(block,trial)];
            end
        elseif flash.QuadMatTemp(block,trial) == 135
            if flash.MotDirec(block,trial) == - 1
                lrI = [lrI,distancePix(block,trial)];
            elseif flash.MotDirec(block,trial) == 1
                lrO = [lrO,distancePix(block,trial)];
            end
        elseif flash.QuadMatTemp(block,trial) == 225
            if flash.MotDirec(block,trial) == - 1
                llI = [llI,distancePix(block,trial)];
            elseif flash.MotDirec(block,trial) == 1
                llO = [llO,distancePix(block,trial)];
            end
        elseif flash.QuadMatTemp(block,trial) == 315
            if flash.MotDirec(block,trial) == - 1
                ulI = [ulI,distancePix(block,trial)];
            elseif flash.MotDirec(block,trial) == 1
                ulO = [ulO,distancePix(block,trial)];
            end
        end

    end
end

means = [mean(urI), mean(urO), mean(lrI), mean(lrO), ...
         mean(llI), mean(llO), mean(ulI), mean(ulO)];

labels = {'urI', 'urO', 'lrI', 'lrO', 'llI', 'llO', 'ulI', 'ulO'};

% Create a bar chart
bar(means);
set(gca, 'XTickLabel', labels);

% Add titles and labels
title('Mean of Each Condition');
xlabel('Condition');
ylabel('Mean distance from the flash');

% Show the plot
grid on;


