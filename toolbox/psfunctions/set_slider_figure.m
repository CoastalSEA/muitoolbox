function hf = set_slider_figure(func,nslide)
%
%-------function help------------------------------------------------------
% NAME
%   set_slider_figure.m
% PURPOSE
%   initialise a figure with two tiles and one or two sliders. The sliders
%   can be used to control the display by calling a function, with the 
%   function name passed as an input variable.
% USAGE
%   hf = set_slider_figure(func,nslide)
%   e.g.: hf = set_slider_figure('edb_plot_update',2);
% INPUTS
%   func - function to be called when slider is moved. function is passed
%   the axes handle, ax and the current value of the slider, k
%   nslide - number of slides: a value of 1 or 2
% OUTPUT
%   hf - figure handle
% NOTES
%   The left and right plots are accessed using the Tags 'lefttile' and
%   'righttile'. The sliders are accessed using the Tags 'slider1' and
%   'slider2'.
% SEE ALSO
%   called in edb_form_plots as part of EstuaryDB and edb_plot_update for
%   an example of updating the two tiles based on the slider position
%
% Author: Ian Townend
% CoastalSEA (c) Sept 2025
%--------------------------------------------------------------------------
%   
 hf = figure('Name','Hypsometry','Tag','PlotFig','Position',[200 200 900 400]);
    t = tiledlayout(hf,1,2,'TileSpacing','compact','Padding','compact');
    %adjust tiles so bottom of figure is free to place slider
    t.OuterPosition = [0.0650, 0.1, 0.8800, 0.88];
    
    %create blank axes
    ax1 = nexttile(t,1);
    ax1.Tag = 'lefttile';
    ax2 = nexttile(t,2);
    ax2.Tag = 'righttile';

    %get position of ax1 in normalized units
    ax1Pos = ax1.OuterPosition;
    sliderHeight = 0.05;
    sliderPos1 = [ax1Pos(1)+0.08, 0.02, ax1Pos(3)-0.08, sliderHeight];
    
    %add slider under the first (left) tile
    uicontrol('Style','slider',...
        'Min',0,'Max',1,'Value',0,...
        'Units','normalized',...
        'Position',sliderPos1,...
        'Tag','slider1',...
        'Callback',@(src,~) updatePlot(src,ax1,func));

    % Add a label for the slider
    uicontrol('Style','text','Units','normalized',...
        'Position',[ax1Pos(1)+0.01, sliderPos1(2), 0.07, 0.04],...
        'String','Position','Tag','slabel1','BackgroundColor',hf.Color);

    if nslide==2
        %add second slider and label under the second tile
        ax2Pos = ax2.OuterPosition;
        sliderPos2 = [ax2Pos(1)+0.06, 0.02, ax2Pos(3)-0.12, sliderHeight];

        uicontrol('Style','slider',...
            'Min',0,'Max',1,'Value',0,...
            'Units','normalized',...
            'Position',sliderPos2,...
            'Tag','slider2',...
            'Callback',@(src,~) updatePlot(src,ax1,func));
    
        % Add a label for the slider
        uicontrol('Style','text','Units','normalized',...
            'Position',[ax2Pos(1)-0.01, sliderPos2(2), 0.07, 0.04],...
            'String','Position','Tag','slabel2','BackgroundColor',hf.Color);
    end
end    

%%
function updatePlot(slider,ax,func)
    %extract curent slider value and call anonymous function
    fh = str2func(sprintf('@(src,ax) %s(src,ax)',func));
    fh(slider,ax);
end