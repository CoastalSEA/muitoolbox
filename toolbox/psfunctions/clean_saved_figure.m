function clean_saved_figure(hf)
    %
%-------function help------------------------------------------------------
% NAME
%   clean_saved_figure.m
% PURPOSE
%   function to clean mui obj declarations in fig files (eg when saving for
%   reuse)
% USAGE
%   hf = clean_saved_figure(hf);
%   e.g. use hf = findobj('Type','figure') and identify the index of the
%   figure to be cleaned
% INPUT
%   hf - handle to figure
% OUTPUT
%   muitoolbox specific CloseRequestFcn and WindowButtonDownFcn removed
% NOTES
%   utility function in muitoolbox
% SEE ALSO
%   uses select_figure.m and  compile_tiled_figure,m
%
% Author: Ian Townend
% CoastalSEA (c) Feb 2026
%----------------------------------------------------------------------
%
    hf.CloseRequestFcn = 'closereq';
    hf.WindowButtonDownFcn = [];
end