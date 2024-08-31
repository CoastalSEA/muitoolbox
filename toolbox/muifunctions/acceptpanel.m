function h_pnl = acceptpanel(h1,promptxt,butnames,position)
%
%-------function help------------------------------------------------------
% NAME
%   acceptpanel.m
% PURPOSE
%   Create a yes/no panel within a figure
% USAGE
%   h_pnl = acceptpanel(h1,promptxt,butnames,position)
% INPUTS
%   h1 - handle to figure or tab to position panel within
%   promptxt - text used in panel to prompt user on selection to be made
%   butnames - names on buttons; optional, default is {'Yes','No'};
%   position - panel position; optional, default is [0.005 0.92 0.99 0.08]        
% OUTPUT
%   h_pnl - handle to panel
% EXAMPLE
%   h_pnl = acceptpanel(h1,promptxt,butnames,position);
%   waitfor(h_pnl,'Tag');
%   if strcmp(h_pnl.Tag,'Yes')
%       ok=1;
%   else
%       %do something
%       h_but.Tag = '';
%   end
% NOTES
%   Alternative to using questdlg which is modal so figure cannot
%   be moved or resized
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%--------------------------------------------------------------------------
%
    if nargin<3
        butnames = {'Yes','No'};
        position = [0.005 0.92 0.99 0.08];
    elseif nargin<4        
        position = [0.005 0.92 0.99 0.08];
    end
    
    h_pnl = uipanel(h1,'Tag','ButtonPanel',...
        'Title',promptxt,'TitlePosition','centertop',...
        'Units','normalized','Position',position);

    % Create push buttons
    nbut = length(butnames);
    pos0 = 0.5-(0.1*nbut/2+(nbut-1)*0.01/2);
    for i=1:nbut
        pos1 = pos0+(i-1)*0.11;
        uicontrol('Parent',h_pnl,'Tag','YesNo',...
        'Style','pushbutton',...
        'String', butnames{i},...
        'Units','normalized', ...
        'Position', [pos1 0.08 0.1 0.8], ...
        'Callback', @panelButton);  
    end    
end
        
%%        
function panelButton(src,~)
    %callback for acceptPanel
    src.Parent.Tag = src.String;
end   
