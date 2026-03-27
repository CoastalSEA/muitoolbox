function res = histogram_plot(x,y,labels)                       
%
%-------function help------------------------------------------------------
% NAME
%   histogram_plot.m
% PURPOSE
%   2D histogram plot for 2 variables of same length
% USAGE
%   res = histogram_plot(x,y,labels);
% INPUTS
%   x - x variable
%   y - y variable (same length as x)
%   labels - struct containing:   (optional)
%       title - plot title text
%       xlabel  - label for x-axis
%       ylabel  - label for y-axis
% OUTPUT
%   histogram plot as frequency of 2D bins
%   res - dummy text so that function can be called from Derive Output UI  
%
% Author: Ian Townend
% CoastalSEA (c) March 2026
%--------------------------------------------------------------------------
%
    res = 'no output'; %null ouput required for exit in muiUserModel.setEqnData
    if nargin<3
        labels = struct('title','','xlabel','X-variable','ylabel','Y-variable');
    end
    
    hf = figure('Name','Histogram','Units','normalized',...
                'Tag','PlotFig');
    ax = axes(hf);

    plot(ax,x,y,'.k','MarkerSize',0.1);
    hold on
    nint = round(log10(numel(y)))*10;
    nbins = [nint,nint];
    xy = [x,y];
    [Z,XY] = hist3(xy,'Nbins',nbins);
    htrec = max(length(find(~isnan(x))),length(find(~isnan(y))));
    Z = Z/htrec*100;                %percentage occurrence
    zmx = max(max(Z));
    %
    ci = [0.02,0.05,0.1,0.2,0.5,0.8]*zmx;
    contourf(ax,XY{1},XY{2},Z',ci,'FaceAlpha',0.8);
    hold off
    colormap(flipud(colormap('bone')));
    cb  = colorbar;
    cb.Label.String = 'Frequency (%)';
    
    xlabel(labels.xlabel)
    ylabel(labels.ylabel)
    title(labels.title)
    if isfield(labels,'subtitle'), subtitle(labels.subtitle); end
end