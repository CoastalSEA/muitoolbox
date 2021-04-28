function [h_plt,h_but] = acceptfigure(figtitle,promptxt,tag,butnames,position)
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
%          ok = 0;
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
    elseif nargin<5        
        position = [0.372, 0.576, 0.255,0.34];
    end

    h_fig = figure('Name',figtitle,'Tag',tag,...
                   'Units','normalized','Position',position,...
                   'NextPlot','add');  
    h_fig.MenuBar = 'none';
    
    %move figure    
    h_fig.Position(1) = 1-h_fig.Position(3)-0.01;  %top right
    h_fig.Position(2) = 1-h_fig.Position(4)-0.12;           
              
    %add panel for plot window and create empty axes handle          
    h_plt = uipanel(h_fig,'Tag','PlotPanel',...
                    'Units','normalized','Position',[0.005 0.005 0.99 0.9]);       
                
    %add panel for buttons         
    h_but = uipanel(h_fig,'Tag','ButtonPanel',...
                    'Title',promptxt,'TitlePosition','centertop',...
                    'Units','normalized','Position',[0.005 0.904 0.99 0.098]);

    %Create push button to accept
    uicontrol('Parent',h_but,'Tag','YesNo',...
        'Style', 'pushbutton',... 
        'String', butnames{1},...
        'Units','normalized', ...
        'Position', [0.39 0.08 0.1 0.9],...
        'Callback', @panelButton);

    %Create push button to reject
    uicontrol('Parent',h_but,'Tag','YesNo',...
        'Style','pushbutton',...
        'String', butnames{2},...
        'Units','normalized', ...
        'Position', [0.51 0.08 0.1 0.9], ...
        'Callback', @panelButton);         
end
%%        
function panelButton(src,~)
    %callback for acceptPanel
    switch src.String
        case 'Yes'
            src.Parent.Tag = 'Yes';
        case 'No'
            src.Parent.Tag = 'No';
    end
end   
