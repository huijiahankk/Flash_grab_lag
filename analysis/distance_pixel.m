

clear all;
addpath '../function';

load('../data/hjh_2024_05_08_12_06.mat');

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

for block = 1:blockNum
    for trial = 1: trialNum

        flash.LocMatTemp
        flash.MotDirec
        flash.CenterMatPosX
        probe.PosXMat

        distancePix = sqrt((flash.CenterMatPosX(block,trial) - probe.PosXMat(block,trial))^2 +...
            (flash.CenterMatPosY(block,trial) - probe.PosYMat(block,trial))^2) ;

    end
end
