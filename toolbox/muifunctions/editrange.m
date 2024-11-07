function editrange(src,~)
%
%-------function help------------------------------------------------------
% NAME
%   editrange.m
% PURPOSE
%   button callback function to edit range and enter in a text uicontrol
% USAGE
%   editrange(src,~)
% INPUT
%   src - handle to UI component that triggered the callback
%   ~   - dummy variable for event data to the callback function
% OUTPUT
%   update the range value in the text box associated with the button
% NOTES
%   requires button to be created using getWidget so that index # of 
%   text box and button are the same. See also captureButton.m
%   NB categorical data are passed as character vectors but checked against
%   categorical array, if held in uic.UserData
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    uicoption = replace(src.Tag,'but','uic'); %order of Selections on itab
    %get existing range text and extract range values 
    uic = findobj(src.Parent,'Tag',uicoption);
    rangetext = uic.String;
    bounds = uic.UserData;
    if length(bounds)>2
%     if length(bounds)>2 && ~iscategorical(bounds)
        bounds = [bounds(1),bounds(end)];
    end
    [rangevar,pretext] = range2var(rangetext,bounds);

    newrange = editrange_ui(rangevar,uic.UserData);

    if isvalidrange(newrange,bounds)
        astring = var2range(newrange,pretext);
        uic.String = astring;   %update string in text uicontrol
    end
end
