function setlog(src,~) 
%
%-------function help------------------------------------------------------
% NAME
%   setlog.m
% PURPOSE
%   callback function for button to set XY plot to have log/linear y-axis
% USAGE
%   callback function: @(src,evt)setlog(src,evt)
% INPUT
%   src - handle to calling object (eg graphical button)
% OUTPUT
%   change the String and Tooltip of src object and modify scale of Y-axis
% SEE ALSO
%   used on tabs plots such as in EstuaryDB for muiTableImport class
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
%
    %
    if strcmp(src.String,'>Log ')
        src.String = '>Lin ';
        src. Tooltip = 'Switch to Linear';
        ax = src.UserData;
        ax.YScale = 'log';
    elseif strcmp(src.String,'>Lin ')
        src.String = '>Log ';
        src. Tooltip = 'Switch to Log';
        ax = src.UserData;
        ax.YScale = 'linear';
    end
end