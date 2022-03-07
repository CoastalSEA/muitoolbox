function wrappedtext = wraptext(text2wrap,gobj,isbold)
%
%-------function help------------------------------------------------------
% NAME
%   wraptext.m
% PURPOSE
%   wrap text to fit within a given graphical object (eg figure,panel,etc)
% USAGE
%   wrappedtext = wraptext(text2wrap,gobj)
% INPUT
%   test2wrap - string or cell array of character vectors to be wrapped
%   gobj - graphical object used to determine width available
%   isbold - logical flag, true if text is in bold (optional - default is false)
% OUTPUT
%   wrappedtext - cell array of character vectors with each character 
%                 vector shortened to fit the available width
% NOTES
%   assumes default values for FontSize (11) and bold size multiplier (1.1)
% SEE ALSO
%   used in descriptive_stats.m and annual_polar_plots.m
%
% Author: Ian Townend
% CoastalSEA (c) July 2021
%--------------------------------------------------------------------------
%
	if nargin<3
        isbold = false;
    end
    holdunits = gobj.Units;   
    gobj.Units = 'pixels';
    h_box = uicontrol('Style','text','String',text2wrap,...
                       'FontSize',11,...
                       'Units',gobj.Units,'Position',gobj.InnerPosition,...
                       'Visible','off' );  
    if isbold
        h_box.FontSize = h_box.FontSize*1.1;  
    end
    
    [wrappedtext,~] = textwrap(h_box,{text2wrap}); 
    delete(h_box);
    gobj.Units = holdunits;
end