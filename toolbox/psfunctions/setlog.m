function setlog(ax,src,~) 
%
%-------function help------------------------------------------------------
% NAME
%   setlog.m
% PURPOSE
%   callback function for button to set XY plot to have log/linear y-axis
% USAGE
%   callback function: @(src,evt)setlog(src,evt)
% INPUT
%   ax - axes for plot to be scaled
%   src - handle to calling object (eg graphical button)
%         src.UserData used to pass  'x-axis', 'y-axis', or 'both'
% OUTPUT
%   change the String and Tooltip of src object and modify scale of Y-axis
% SEE ALSO
%   used on tabs plots such as in EstuaryDB for muiTableImport class
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
%
    if strcmp(src.String,'>Log ')
        src.String = '>Lin ';
        src. Tooltip = 'Switch to Linear';
        if isvalid(ax)         %when tab plots an image there is no axes
            if strcmp(src.UserData,'x-axis')
                ax.XScale = 'log';
            elseif strcmp(src.UserData,'y-axis')
                ax.YScale = 'log';
            elseif strcmp(src.UserData,'both')
                ax.XScale = 'log';
                ax.YScale = 'log';
            end
        end
    elseif strcmp(src.String,'>Lin ')
        src.String = '>Log ';
        src. Tooltip = 'Switch to Log';
        if isvalid(ax)
            if strcmp(src.UserData,'x-axis')
                ax.XScale = 'linear';
            elseif strcmp(src.UserData,'y-axis')
                ax.YScale = 'linear';
            elseif strcmp(src.UserData,'both')
                ax.XScale = 'linear';
                ax.YScale = 'linear';              
            end
        end
    end
end