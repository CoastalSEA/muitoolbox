function setRightYaxis(src,~) 
%
%-------function help------------------------------------------------------
% NAME
%   setRightYaxis.m
% PURPOSE
%   callback function for button to switch between using the left and right
%   Y-axis
% USAGE
%   callback function: @(src,evt)setRightYaxis(src,evt)
% INPUT
%   src - handle to calling object (eg graphical button)
% OUTPUT
%   change the String, UserData and Tooltip of src object
% SEE ALSO
%   used in data UIS that are based on the muiDataUI abstract class
%
% Author: Ian Townend
% CoastalSEA (c)Jan 2026
%--------------------------------------------------------------------------
%
    %
    if strcmp(src.String,'yL')
        src.String = 'yR';
        src.UserData = 1;            %true if using right axis
        src.Tooltip = 'Swap from right to left axis';
    elseif strcmp(src.String,'yR')
        src.String = 'yL';
        src.UserData = 0;            %false if using left axis
        src.Tooltip = 'Swap from left to right axis';
    end
end