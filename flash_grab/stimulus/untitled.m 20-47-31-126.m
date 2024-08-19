                if phaseShift >= flash.maxPhaseShiftPixMat(trial)
                    phaseSpeed = - phaseSpeed; % Reverse the direction of motion
                    phaseShiftCheck(trial) = phaseShift;
                   if flash.maxPhaseShiftPixMat(trial) == flash.maxPhaseShiftPix(1) && flash.MotDirecMat(trial) == - 1
                        alignPhaseShift = (4 * cycleWidthPix + phaseShift);
                        a = 1
                    elseif flash.maxPhaseShiftPixMat(trial) == flash.maxPhaseShiftPix(2) && flash.MotDirecMat(trial) == - 1
                        alignPhaseShift = (4 * cycleWidthPix + phaseShift);
                        b = 2
                   end

                elseif  phaseShift <= - flash.maxPhaseShiftPixMat(trial)
                    phaseSpeed = - phaseSpeed; % Reverse the direction of motion
                    phaseShiftCheck(trial) = phaseShift;

                    % Check if the phaseShift is greater than maxPhaseShift and the direction has changed to inward
                    %  1 means illusion outward   grating moving inward at
                    %  the beginning flash.MotDirecMat(trial)
                    % -1 mean illusion inward grating moving ourward at the beginning

                    if flash.maxPhaseShiftPixMat(trial) == flash.maxPhaseShiftPix(1) && flash.MotDirecMat(trial) ==  1
                        alignPhaseShift = - phaseShift; % (4 * cycleWidthPix + phaseShift);
                        c = 3
%                     elseif flash.maxPhaseShiftPixMat(trial) == flash.maxPhaseShiftPix(1) && flash.MotDirecMat(trial) == -1
%                         alignPhaseShift = - phaseShift; % (4 * cycleWidthPix + phaseShift);
%                         b = 2
                    elseif flash.maxPhaseShiftPixMat(trial) == flash.maxPhaseShiftPix(2) && flash.MotDirecMat(trial) ==  1
                        alignPhaseShift = - phaseShift; %(4 * cycleWidthPix + phaseShift);
                        d = 4
%                     elseif flash.maxPhaseShiftPixMat(trial) == flash.maxPhaseShiftPix(2) && flash.MotDirecMat(trial) == -1
%                         alignPhaseShift = - phaseShift; %(4 * cycleWidthPix + phaseShift);
%                         d = 4
                    end

                    flash.CenterPosX(block,trial) = xCenter + phaseshiftFactorX * alignPhaseShift * sind(45);
                    flash.CenterPosY(block,trial) = yCenter + phaseshiftFactorY * alignPhaseShift * cosd(45);
                    phaseShiftMat(block,trial) = alignPhaseShift;

                    flash.Rect = CenterRectOnPointd(flash.Size, flash.CenterPosX(block,trial), flash.CenterPosY(block,trial) );
                    Screen('DrawTexture', window, flash.Texture, [], flash.Rect, flash.Angle);
                    flashPresentFlag = 1;
                end
            end