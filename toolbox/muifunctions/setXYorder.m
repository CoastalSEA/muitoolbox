function setXYorder(src,~)
%
%-------function help------------------------------------------------------
% NAME
%   setXYorder.m
% PURPOSE
%   callback function for button to switch X and Y data (eg on
%   a UI selecting data for plotting)
% USAGE
%   callback function: @(src,evt)setXYorder(src,evt)
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
    if strcmp(src.String,'XY')
        src.String = 'YX';
        src.UserData = 1;
        src.Tooltip = 'Switch from Y-X to X-Y axes';
    elseif strcmp(src.String,'YX')
        src.String = 'XY';
        src.UserData = 0;
        src.Tooltip = 'Switch from X-Y to Y-X axes';
    end
end