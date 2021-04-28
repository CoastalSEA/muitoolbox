function godisplay(src,~)
%
%-------function help------------------------------------------------------
% NAME
%   godisplay.m
% PURPOSE
%   Display the legend name or DisplayName of the selected graphical object
% USAGE
%   godisplay(src,~)
% INPUTS
%   src - handle to graphic object
%   evt - event (not used)
% OUTPUT
%   name of object is displayed a temporary dialogue box
% NOTES
%   uses getdialog and setdialog
%
% Author: Ian Townend
% CoastalSEA, (c) 2020
%--------------------------------------------------------------------------
%
    msgtxt = src.UserData;

    delay = 5;
    msgpos = [0.5,0.5,0.15,0.08];
    getdialog(msgtxt,msgpos,delay)
end