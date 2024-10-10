function [UIsel,UIset] = selectui(mobj,promptxt)
%
%-------function help------------------------------------------------------
% NAME
%   selectui.m
% PURPOSE
%   provides access to the muiSelectUI class to use Case/Dataset/Variable
%   selection interface and return the selections made
% USAGE
%   selection = selectui(mobj,promptxt)
% INPUTS
%   mobj - handle to App UI to allow access to data 
%   promptxt - text used in figure title (optional)
% OUTPUT
%   UIsel - user selection (UIselection   struct defined in muiDataUI)
%   UIset - UI settings (UIsettings struct defined in muiDataUI)
% SEE ALSO
%   muiDataUI.m and muiSelectUI.m
%
% Author: Ian Townend
% CoastalSEA (c) May 2024 
%--------------------------------------------------------------------------
% 
    if nargin<2, promptxt = 'Select Data:'; end
    selobj = muiSelectUI.getSelectUI(mobj,promptxt);
    waitfor(selobj,'Selected')

    UIsel = selobj.UIselection;    %user selection
    UIset = selobj.UIsettings;     %other UI settings
    delete(selobj.dataUI.Figure);
    delete(selobj)
    if UIsel.xyz==0
        UIsel = []; UIset = []; 
    end
end

