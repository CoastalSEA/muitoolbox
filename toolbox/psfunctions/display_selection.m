function hd = display_selection(src,~)
%
%-------function help------------------------------------------------------
% NAME
%   display_selection.m
% PURPOSE
%   callback function to display text from a uicontrol in a dialog box
% USAGE
%   display_selection(src,~)
% INPUTS
%   src - handle to uicontrol that calls the function
% OUTPUT
%   hd - handle to dialog created to display the text in src.UserData
% NOTES
%   Example of usage:
%     %create button to allow user to view detailed selection description 
%     hf.Units = 'normalized';
%     butxt = 'Selection';   %text to appear on button
%     position = [0.85,0.92,0.1,0.05]; 
%     callback =  @(src,evt)display_selection(src,evt); %function to be called on button press
%     tag = 'selbutton';
%     tooltip = 'Details of selection made';
%     hbut = setactionbutton(hf,butxt,position,callback,tag,tooltip);
%     hbut.UserData = seltxt;
% SEE ALSO
%   used in scatter_plot.m
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
% 
    msgpos = [0.5,0.5,0.8,0.5];
    hd = dialog('Units','Normalized','WindowStyle','normal',...
        'Position',msgpos,'Name','Selection','Visible','off','Resize','on');
    hd.Units = 'pixels';
    seltxt = src.UserData;
    [~,colwidth,tableheight] = getcolumnwidths(cellstr(seltxt));
    hd.Position(3:4) = [colwidth*1.15,tableheight*8];
    
    hd.Units = 'normalized';
    hd.Position(1) = (1-hd.Position(3))/2;
    uicontrol('Parent',hd,...
        'Style','text',...
        'Units','normalized','Position',[0.05,0.1,0.9,0.5],...
        'HorizontalAlignment','left',...
        'String',seltxt);

    hd.Visible = 'on';
end

   
    