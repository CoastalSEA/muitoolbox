function reshape_axes(hf)
%
%-------function help------------------------------------------------------
% NAME
%   reshape_axes.m
% PURPOSE
%   reshape subplots in a figure from a single column to two columns
% USAGE
%   reshape_axes
% INPUT
%   hf - handle to figure. Optional if not specified uses the current
%   figure
% OUTPUT
%   single column of subplots converted to two columns
% SEE ALSO
%   used to adapt multi-reach plots in estuary database
%
% Author: Ian Townend
% CoastalSEA (c) March 2025
%
    if nargin<1
        hf = gcf;
    end
    
    sax = flipud(findobj(hf.Children,'Type','Axes'));
    cb = flipud(findobj(hf.Children,'Type','ColorBar'));
    nrow = ceil(length(sax)/2);
    figure;
    for i=1:length(sax)
        si = subplot(nrow,2,i);
        axChil = sax(i).Children; 
        copyobj(axChil,si)
        title(sax(i).Title.String)
        c = colorbar;
        c.Label.String = cb(i).Label.String;
        xlabel('Distance to mouth (m)');
        ylabel('Elevation (mAD)');
    end
    titletxt = findobj(hf.Children,'Type','subplottext');
    sgtitle(titletxt.String)
end