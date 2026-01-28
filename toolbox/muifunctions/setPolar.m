function setPolar(src,~) 
%
%-------function help------------------------------------------------------
% NAME
%   setPolar.m
% PURPOSE
%   callback function for button to set XY plot to be polar 
%   instead of cartesian
% USAGE
%   callback function: @(src,evt)setPolar(src,evt)
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
    if strcmp(src.String,'+')
        src.String = 'O';
        src.UserData = 1;
        src.Tooltip = 'Switch Polar to XY';
    elseif strcmp(src.String,'O')
        src.String = '+';
        src.UserData = 0;
        src.Tooltip = 'Switch XY to Polar; X data in degrees or radians';
    end
end
