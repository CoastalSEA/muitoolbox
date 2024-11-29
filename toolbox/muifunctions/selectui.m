function [UIsel,UIset] = selectui(mobj,promptxt,varargin)
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
%   varargin - Name,Value pairs for properties set in TabContent (optional)
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
    if nargin<2
        promptxt = 'Select data:'; 
        varargin = {};
    elseif nargin<3
        varargin = {};
    end
    selobj = muiSelectUI.getSelectUI(mobj,promptxt,varargin{:});
    waitfor(selobj,'Selected')

    UIsel = selobj.UIselection;    %user selection
    UIset = selobj.UIsettings;     %other UI settings
    delete(selobj.dataUI.Figure);
    delete(selobj)

    for i=1:length(UIsel)
        %check whether each selection has been made-
        %assumes that all selections set for muiSelectUI are required
        isset = all(UIsel(1).xyz==0); 
        if isset, UIsel = []; UIset = []; return; end
    end
end

