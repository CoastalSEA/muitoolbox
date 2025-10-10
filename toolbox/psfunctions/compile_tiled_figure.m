function hf = compile_tiled_figure(mrows,ncols)
%
%-------function help------------------------------------------------------
% NAME
%   compile_tiled_figure
% PURPOSE
%   interactively add existing axes from single axes figures to a figure
%   with multiple tiles (regular grid only)
% USAGE
%   hf = compile_tiled_figure(mrows,ncols);
% INPUT
%   mrows - number of rows in tiled grid
%   ncols - number of columns in tiled grid
% OUTPUT
%   hf - handle to compiled figure
% NOTES
%   utility function in muitoolbox
% SEE ALSO
%   uses select_figure.m
%
% Author: Ian Townend
% CoastalSEA (c) Oct 2025
%----------------------------------------------------------------------
% 
    hf = figure('Tag','PlotFig');
    t = tiledlayout(hf,mrows,ncols,'TileSpacing','compact','Padding','compact');

    getdialog('Tile order is across each row in order of rows')
    
    for i=1:mrows*ncols
        hfig = select_figure('PlotFig');        %select a figure to use
        ax = findobj(hfig,'Type','Axes');
        leg = findobj(hfig,'Type','Legend');
        figObj = copyobj([ax,leg],t);           %make a copy of the axes and legend
        axTile = figObj(1);                     %copied axes
        legTile = figObj(2);                    %copied legend
        axTile.Parent = t;
        axTile.Layout.Tile = i;                 %assign to the tile

        %ensure the legend targets the copied axes’ lines
        legTile.PlotChildren = axTile.Children; 
        % Some releases need this explicit association:
        set(legTile, 'Axes', axTile);
    end
end