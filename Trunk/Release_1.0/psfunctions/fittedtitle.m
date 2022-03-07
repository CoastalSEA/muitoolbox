function fittedtitle(hfig,metatext,isubgroup,factor)
%
%-------function help------------------------------------------------------
% NAME
%   fittedtitle.m
% PURPOSE
%   fit title text to the width of a figure (handles title and sgtitle).
% USAGE
%   fittedtitle(hfig,metatext,factor)
% INPUT
%   hfig - handle to figure
%   metatext - text to be used for the title
%   isubgroup - logical flag: true if  subgroup title is to be used (sgtitle)
%   factor - scale the current figure width by this amount, default = 0.7
% OUTPUT
%   adds title to figure
% SEE ALSO
%   used in user_stats, poisson_stats, etc
%
% Author: Ian Townend
% CoastalSEA (c)June 2021
%--------------------------------------------------------------------------
%
if nargin<4, factor = 0.7; end

c = uicontrol(hfig,'Style','text');
c.Position(3) = hfig.Position(3)*factor;
wrappedtext= textwrap(c,{metatext});
delete(c);

if isubgroup
    htxt = findobj(hfig,'Type','title');
    fsze = hfig.Children(1).Title.FontSize;
    sgtitle(wrappedtext,'FontSize',fsze,'FontWeight','bold');
else
    title(wrappedtext);
end