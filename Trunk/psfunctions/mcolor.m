function acolor = mcolor(idx)
%
%-------function help------------------------------------------------------
% NAME
%   mcolor.m
% PURPOSE
%   select a default Matlab color definition from table
% USAGE
%   acolor = mcolor(idx)
% INPUTS
%   idx - index to row selection in color table (integer or text)
% OUTPUT
%   acolor - RGB values for selected color
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
matlabcolor = [ 0,      0.4470, 0.7410;...   %dark blue
                0.8500, 0.3250, 0.0980;...   %orange
                0.9290, 0.6940, 0.1250;...   %yellow
                0.4940, 0.1840, 0.5560;...   %purple
                0.4660, 0.6740, 0.1880;...   %green
                0.3010, 0.7450, 0.9330;...   %light blue
                0.6350, 0.0780, 0.1840;...   %scarlet
                0.90,   0.90,   0.90;...     %light grey
                0.95,   0.95,   0.95];       %darker grey
            
colornames = {'dark blue';'orange';'yellow';'purple';'green';'light blue';...
              'scarlet';'light grey';'dark grey'};
          
if ~isnumeric(idx)
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
        