function h = getwidget(handle,settings,widgetpos,idx)
%
%-------function help------------------------------------------------------
% NAME
%   getwidget.m
% PURPOSE
%   widget for text,input uicontrol and control buttons (eg edit) 
% USAGE
%   getwidget(h_pnl,fig,pos,idx)
% INPUT
%   handle - handle of parent object (panel, tab, figure)
%   settings - widget settings struct including
%       InputFields     - text prompt for input fields to be displayed
%       Style           - uicontrols for each input field (same no. as input fields)
%       DefaultInputs   - default text or selection lists
%       UserData        - data assigned to UserData of uicontrol
%       ControlButtons  - text for buttons to edit or update selection      
%   widgetpos - position of widget components stuct for bottom and height
%   idx - index identifier of widget
% OUTPUT
%   adds text, uicontrol and control button (optional) to handle
%   h - array of handles to input field and button
% NOTES
%   script to set up settings input required:
%   settings.InputFields = {'var1'};   %text prompt for input field to be displayed
%   settings.Style = {'style'};        %uicontrols for each input field (same no. as input fields)
%   settings.DefaultInputs = {'test'}; %default text or selection lists
%   settings.Userdata = [];           %data assigned to UserData of uicontrol
%   settings.ControlButtons = {'Ev'};  %text for buttons to edit or update selection
%   widgetpos.height = 0.9;
%   widgetpos.pos4 = 0.1;
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%      
    if strcmp(settings.Style{idx},'linkedpopup')
        %capture any popupmenus that determine the range field
        settings.Style{idx} = 'popupmenu';
    elseif strcmp(settings.Style{idx},'linkedslider')
        settings.Style{idx} = 'slider';
    end
    %Descriptive text
    widgetname = settings.InputFields{idx};
    uicontrol('Parent',handle, 'Style','text',...
            'String',settings.InputFields{idx},...
            'HorizontalAlignment', 'left',...
            'Units','normalized', ...
            'Position',[0.05 widgetpos.height-0.01/idx 0.2 widgetpos.pos4],...
            'Tag',sprintf('%s>txt%d',widgetname,idx));
    %input uicontrol
    h(1) = uicontrol('Parent',handle, ...
            'Style',settings.Style{idx}, ...
            'Units','normalized', ...
            'Position',[0.25 widgetpos.height 0.58 widgetpos.pos4], ...
            'String',settings.DefaultInputs{idx}, ...
            'UserData',settings.UserData{idx}, ...
            'ListboxTop',1, ...
            'Tag',sprintf('%s>uic%d',widgetname,idx)); 
    %control button if included
    %if not visible, check that handle Units are normalized
    if ~isempty(settings.ControlButtons) && ~isempty(settings.ControlButtons{idx})
        butcall = @(src,evt)editrange(src,evt);
        buttxt = settings.ControlButtons{idx};
        buttip = 'Edit range';
        butpos = [0.88,widgetpos.height,0.05,widgetpos.pos4];
        buttag = sprintf('%s>but%d',widgetname,idx);
        h(2) = setactionbutton(handle,buttxt,butpos,butcall,buttag,buttip);                                 
    end            
end