function acolor = mcolor(idx)
%
%-------function help------------------------------------------------------
% NAME
%   mcolor.m
% PURPOSE
%   select a default Matlab colour definition from table and common colours
% USAGE
%   acolor = mcolor(idx)
% INPUTS
%   idx - index to row selection in colour table (integer or text) - optional
%         if mcolor called without idx, user is prompted to select a color       
% OUTPUT
%   acolor - RGB values for selected colour
% NOTES
%   default Matlab colours defined include 
%       1 crimson blue,
%       2 dark blue, 
%       3 orange, 
%       4 yellow ochre, 
%       5 pale yellow, 
%       6 purple, 
%       7 burnt green, 
%       8 light blue, 
%       9 scarlet, 
%       10 dark grey, 
%       11 mid grey, 
%       12 light grey 
%       13 red
%       14 green
%       15 blue
%       16 cyan
%       17 magenta
%       18 yellow
%       19 black
%       20 white
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
matlabcolor = [ 0,      0.1,      0.3;...    %1 crimson blue
                0,      0.4470, 0.7410;...   %2 dark blue
                0.8500, 0.3250, 0.0980;...   %3 orange
                0.9290, 0.6940, 0.1250;...   %4 yellow ochre
                0.9,      1,      0.7;...    %5 pale yellow
                0.4940, 0.1840, 0.5560;...   %6 purple
                0.4660, 0.6740, 0.1880;...   %7 burnt green
                0.3010, 0.7450, 0.9330;...   %8 light blue
                0.6350, 0.0780, 0.1840;...   %9 scarlet
                0.70,   0.70,   0.70;...     %10 dark grey
                0.80,   0.80,   0.80;...     %11 mid grey
                0.90,   0.90,   0.90;...     %12 light grey
                1, 0, 0;...                  %13 red
                0, 1, 0;...                  %14 green
                0, 0, 1;...                  %15 blue
                0, 1, 1;...                  %16 cyan
                1, 0, 1;...                  %17 magenta
                1, 1, 0;...                  %18 yellow
                0, 0, 0;...                  %19 black
                1, 1, 1;...                  %20 white
                ];   
            
colornames = {'crimson blue';'dark blue';'orange';'yellow ochre';'pale yellow';...
              'purple';'burnt green';'light blue';'scarlet';'dark grey';...
              'mid grey';'light grey';'red';'green';'blue';'cyan';...
              'magenta';'yellow';'black';'white'};

if nargin<1
    idx = listdlg("PromptString",'Select colour:','Name','Colour',...
                  'SelectionMode','single','ListSize',[120,160],...
                  'ListString',colornames);
elseif ~isnumeric(idx)
    idx = find(strcmp(colornames,idx));    
end
%
if isempty(idx) || idx<1 || idx>length(colornames)
    warning('Selection not found in mcolor.m')
    acolor = [];
    return;
else
    acolor = matlabcolor(idx,:);
end
        