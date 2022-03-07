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
%   position - figure position; optional, default is [0.372,0.576,0.255,0.34]         
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
        position = [0.372, 0.576, 0.255,0.34];
    elseif nargin<4        
        position = [0.372, 0.576, 0.255,0.34];
    end
    
    h_pnl = uipanel(h1,'Tag','ButtonPanel',...
        'Title',promptxt,'TitlePosition','centertop',...
        'Units','normalized','Position',position);

    % Create push button to accept
    uicontrol('Parent',h_pnl,...
        'Style', 'pushbutton', 'String', butnames{1},...
        'Units','normalized', ...
        'Position', [0.25 0.08 0.2 0.8],...
        'Callback', @panelButton);

    %Create push button to reject
    uicontrol('Parent',h_pnl,...
        'Style','pushbutton',...
        'String', butnames{2},...
        'Units','normalized', ...
        'Position', [0.55 0.08 0.2 0.8], ...
        'Callback', @panelButton);
end
        
%%        
function panelButton(src,~)
    %callback for acceptPanel
    src.Parent.Tag = src.String;
end   
