function hb = add_copy_button(hf,outable,butpos)
%
%-------function help------------------------------------------------------
% NAME
%   add_copy_button.m
% PURPOSE
%   add a 'Copy to Clipboard' button to a figure
% USAGE
%   add_copy_button(hf,outable,butpos)
% INPUTS
%   hf - handle to figure (or tab) to add button to
%   outable - data to be made available can be dstable, table, or data
%             types handled by mat2clip
%   butpos  - position of button, default is top right (optional)
% OUTPUT
%   hb - handle to uicontrol button to post data to the clipboard
%
% Author: Ian Townend
% CoastalSEA (c)July 2022
%--------------------------------------------------------------------------
%
    %add copy to clipbaord button to figure
    if nargin<3
        butpos = [0.88 0.945 0.10 0.044];
    end
    %Create push button to copy data to clipboard
    hb = uicontrol('Parent',hf,...
        'Style','pushbutton',...
        'String', '>Copy',...
        'Tooltip', 'Copy data to clipboard',...
        'Units',hf.Units, ...
        'Position', butpos, ...
        'UserData',outable, ...
        'Callback',@copydata2clip);
end