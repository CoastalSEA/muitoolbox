function editlist(src,~)
%
%-------function help------------------------------------------------------
% NAME
%   editlist.m
% PURPOSE
%   callback function to select single value from list
% USAGE
%   editlist(src,~)
% INPUTS
%   src - handle to uicontrol
% OUTPUT
%   updated uicontrol defined by src handle
% SEE ALSO
%   used to update UI in inputUI.m
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024 
%--------------------------------------------------------------------------
% 
    %callback function to select single value from list
    uicoption = replace(src.Tag,'but','uic'); %order of Selections on itab
                                              %replace but with uic to get
                                              %existing selection
    %get existing range text and extract range values 
    uic = findobj(src.Parent,'Tag',uicoption);
    rangetxt =  uic.UserData;
    uivalue = listdlg('PromptString','Select a value:','Name','Edit',...
                  'SelectionMode','single','ListSize',[250,100],...
                  'ListString',rangetxt);
    if ~isempty(uivalue)          
        uic.Value = uivalue; 
    end
end