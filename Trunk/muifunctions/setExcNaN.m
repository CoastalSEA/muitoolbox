function setExcNaN(src,~)
%
%-------function help------------------------------------------------------
% NAME
%   setExcNaN.m
% PURPOSE
%   callback function for button to set data selection to include 
%   or exclude NaNs
% USAGE
%   callback function: @(src,evt)setExcNaN(src,evt)
% INPUT
%   src - handle to calling object (eg graphical button)
% OUTPUT
%   change the String, UserData and Tooltip of src object
%   src.UserData = 1 to Exclude NaNs
% SEE ALSO
%   used in data UIS that are based on the muiDataUI abstract class
%
% Author: Ian Townend
% CoastalSEA (c)June 2021
%--------------------------------------------------------------------------
%
    if strcmp(src.String,'+N')
        src.String = '-N';
        src.UserData = 1;
        src. Tooltip = 'Exclude NaNs in output';
    elseif strcmp(src.String,'-N')
        src.String = '+N';
        src.UserData = 0;
        src. Tooltip = 'Include NaNs in output';
    end
end 