function godisplay(src,~)
%
%-------function help------------------------------------------------------
% NAME
%   godisplay.m
% PURPOSE
%   Display the legend name or DisplayName of the selected graphical object
% USAGE
%   godisplay(src,~)
%   e.g. plot(ax,.....,'ButtonDownFcn',@godisplay)
% INPUTS
%   src - handle to graphic object
%   evt - event (not used)
% OUTPUT
%   name of object is displayed a temporary dialogue box
% NOTES
%   Example usage:
%   
% SEE ALSO
%   uses getdialog and setdialog
%
% Author: Ian Townend
% CoastalSEA, (c) 2020
%--------------------------------------------------------------------------
%
    if ~isempty(src.UserData)
        msgtxt = src.UserData;
    elseif ~isempty(src.DisplayName)
        msgtxt = src.DisplayName;
    else
        return;
    end

    delay = 3;
    [~,colwidth] = getcolumnwidths({msgtxt});
    screendata = get(0,'ScreenSize');
    txtwidth = colwidth/screendata(3)*1.15;
    msgpos = [0.5,0.5,txtwidth,0.08];
    getdialog(msgtxt,msgpos,delay)
end