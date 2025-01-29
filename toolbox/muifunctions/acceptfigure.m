function [h_plt,h_but] = acceptfigure(figtitle,promptxt,tag,butnames,position,tooltips)
%
%-------function help------------------------------------------------------
% NAME
%   acceptfigure.m
% PURPOSE
%   generate plot figure with buttons to accept/reject selection
% USAGE
%   [h_plt,h_but] = acceptfigure(figtitle,promptxt,tag,butnames,position);
% INPUTS
%   figtitle - figure title
%   promptxt - text used on figure to prompt user on selection to be made
%   tag - figure Tag name (used for group deletes in ModelUI)
%   butnames - names on buttons; optional, default is {'Yes','No'};
%   position - figure position; optional, default is [0.372,0.576,0.255,0.34]   
%   tooltips - cell array of tooltips to assign to buttons.cell size must
%              match number of buttons
% OUTPUT
%   h_plt - handle to plot panel
%   h_but - handle to button panel
% EXAMPLE
%   To initialise figure:
%       figtitle = sprintf('Extremes threshold selection for %s',ts.Name);
%       promptxt = 'Accept threshold definition';
%       tag = 'StatFig'; %used for collective deletes of a group
%       butnames = {'Yes','No'};
%       position = [0.2,0.4,0.5,0.4]; (optional, default is [0.372,0.576,0.255,0.34])
%       [h_plt,h_but] = acceptfigure(figtitle,promptxt,tag,butnames,position);
%   followed by a 'while ok<1' loop with (if butnames are Yes and No)
%       waitfor(h_but,'Tag');
%       if ~ishandle(h_but) %this handles the user deleting figure window    
%          ok = 1;  %continue or return depending on usage
%       elseif strcmp(h_but.Tag,'No')
%          %Do something
%          h_but.Tag = '';
%       else
%          ok = 1;
%          %Do something e.g call panelText (see below)  
%       end   
% SEE ALSO
%   see getpeaks, getclusters and extreme_stats for examples of usage
%   HydroFormModel.CSTmodelPlot function illustrates another us    
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%--------------------------------------------------------------------------
%
    if nargin<4
        butnames = {'Yes','No'};
        position = [0.372, 0.576, 0.255,0.34];
        tooltips = repmat({''},size(butnames));
    elseif nargin<5        
        position = [0.372, 0.576, 0.255,0.34];
        tooltips = repmat({''},size(butnames));
    elseif nargin<6
        tooltips = repmat({''},size(butnames));
    end
    
    if length(butnames)<2
        butnames = {'Yes','No'};
    end

    h_fig = figure('Name',figtitle,'Tag',tag,...
                   'Units','normalized','Position',position,...
                   'NextPlot','add');  
    h_fig.MenuBar = 'none';   %reduce clutter but
    h_fig.ToolBar = 'figure'; %allow access to data tips and save tools
    
    %move figure    
%     h_fig.Position(1) = 1-h_fig.Position(3)-0.01;  %top right
%     h_fig.Position(2) = 1-h_fig.Position(4)-0.12;           
              
    %add panel for plot window and create empty axes handle          
    h_plt = uipanel(h_fig,'Tag','PlotPanel',...
                    'Units','normalized','Position',[0.005 0.005 0.99 0.9]);       
                
    %add panel for buttons  
    h_but = acceptpanel(h_fig,promptxt,butnames,[0.005 0.904 0.99 0.098],tooltips);
end 
