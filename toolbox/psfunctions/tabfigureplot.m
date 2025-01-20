function ax = tabfigureplot(obj,src,tabcb,isrotate,logaxis) %#ok<INUSL>
%
%-------function help------------------------------------------------------
% NAME
%   tabfigureplot.m
% PURPOSE
%   generate axes on Q-Plot tab including '>Figure' and 'Rotate' or '>Log'
%   buttons (Rotate is optional), or as a standalone figure.
% USAGE
%   ax = tabfigureplot(obj,src,tabcb,isrotate,logaxis)
% INPUTS
%   obj - instance of a class derived from muiDataSet that uses tabPlot
%   src - handle to tab or button that calls tabPlot
%   tabcb - tab callback e.g. tabcb = @(src,evdat)tabPlot(obj,src)
%   isrotate - logical true to include button to allow plot on tab to be 
%              rotated (optional)
%   logaxis - empty if not needed, otherwise set to 'x-axis', 'y-axis', or
%   'both'.
% OUTPUT
%   buttons on tab to generate standalone figure and rotate the plot
% NOTES
%   used by calling:
%             tabcb  = @(src,evdat)tabPlot(obj,src);
%             ax = tabfigureplot(obj,src,tabcb,false);
%             someOutputPlot(obj,ax);
%   NB1: sets axes Tag to tab name, or PlotFig if stand-alone plot
%   NB2: can only set one action button to rotate or set log axis. If both
%   are needed adjust the default position settings for the buttons.
% SEE ALSO
%   used in tabPlot in CSTrunmodel, 
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
%
    if nargin<4
        isrotate = false;
        logaxis = [];
    elseif nargin<5
        logaxis = []; 
    end
    %
    if isempty(isrotate)
        isrotate = false;
    end

    %
    if strcmp(src.Tag,'FigButton')
        hfig = figure('Tag','PlotFig');
        ax = axes('Parent',hfig,'Tag','PlotFig','Units','normalized');              
    else
        ht = findobj(src,'Type','axes');
        delete(ht);
        ax = axes('Parent',src,'Tag',src.Tag);
        hb = findobj(src,'Tag','FigButton');
        if isempty(hb)
            %button to create plot as stand-alone figure
            uicontrol('Parent',src,'Style','pushbutton',...
                'String','>Figure','Tag','FigButton',...
                'TooltipString','Create plot as stand alone figure',...
                'Units','normalized','Position',[0.88 0.95 0.10 0.044],...
                'Callback',tabcb);  %eg: tabcb = @(src,evdat)tabPlot(obj,src)
        else
            hb.Callback = tabcb;
        end


        %add rotate button if specified
        hr = findobj(src,'Tag','RotateButton');
        delete(hr) %delete button so that new axes is assigned to callback
        if isrotate

            uicontrol('Parent',src,'Tag','RotateButton',...  %callback button
                'Style','pushbutton',...
                'String', 'Rotate off',...
                'Units','normalized', ...
                'Position', [0.02,0.92,0.1,0.05],...
                'TooltipString','Turn OFF when finished, otherwise tabs do not work',...
                'Callback',@(src,evtdat)rotatebutton(ax,src,evtdat)); 
        end
        
        %add Log button if specified -logaxis defines the axes to be adjusted
        hl = findobj(src,'Tag','LogButton');
        delete(hl) %delete button so that new axes is assigned to callback
        if ~isempty(logaxis)            
            %button to toggle y-axis between linear and log scale
            uicontrol('Parent',src,'Style','pushbutton',...
                'String',' >Log ','Tag','LogButton',...
                'TooltipString','Switch to Log',...
                'Units','normalized','Position',[0.02 0.95 0.055 0.044],...
                'UserData',logaxis,...
                'Callback',@(src,evdat)setlog(ax,src,evdat));
        end
    end
end