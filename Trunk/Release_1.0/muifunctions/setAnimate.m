function setAnimate(src,~) 
%
%-------function help------------------------------------------------------
% NAME
%   setAnimate.m
% PURPOSE
%   callback function for button to set plot to be an animation instead
%   of a snap shot at selected time
% USAGE
%   callback function: @(src,evt)setAnimate(src,evt)
% INPUT
%   src - handle to calling object (eg graphical button)
% OUTPUT
%   change the String, UserData and Tooltip of src object
% SEE ALSO
%   used in data UIS that are based on the muiDataUI abstract class
%
% Author: Ian Townend
% CoastalSEA (c)June 2021
%--------------------------------------------------------------------------
%
    %
    if strcmp(src.String,'Ti')
        src.String = 'Mv';
        src.UserData = 1;
        src. Tooltip = 'Animate. Press to use Snap shot';
    elseif strcmp(src.String,'Mv')
        src.String = 'Ti';
        src.UserData = 0;
        src. Tooltip = 'Snap shot. Press to use animate';
    end
end