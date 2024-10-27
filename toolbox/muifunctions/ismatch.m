function ism = ismatch(str,pat)
%
%-------function help------------------------------------------------------
% NAME
%   ismatch.m
% PURPOSE
%   finds the occurence of matches between two sets of character vectors,
%   cell arrays or string arrays
% USAGE
%   ism = ismatch(str,pat)
% INPUTS
%   str - text, which means it can be a string array, a character vector, 
%          or a cell array of character vectors. 
%   pat - text, the same as str, but pat and str do NOT need to be the same
%         size
% OUTPUTS
%   ism - 1 (true) if STR is equal to PAT, and returns 0 (false) otherwise.
%         if STR is a string array or cell array, then ism is a logical 
%         array that is the same size.
% NOTES
%   Matlab (TM) function 'matches', available from v2019b, can be used
%   instead of this function.
% SEE ALSO
%   used in Asmita and muiCatalogue
%
% Author: Ian Townend
% CoastalSEA (c) Oct 2021
%--------------------------------------------------------------------------
%
%alternate to Matlab matches
if ischar(pat)
    ism = strcmp(str,pat);
elseif iscell(pat)
    ism = false(size(str));
    for i=1:length(pat)
        ism = ism + strcmp(str,pat{i});
    end  
    ism = logical(ism);
elseif isstring(pat)
    ism = false(size(str));
    for i=1:length(pat)
        ism = ism + strcmp(str,pat(i));
    end  
    ism = logical(ism);
else
    ism = [];
    warndlg('Type not handled in ismatch')
end
    