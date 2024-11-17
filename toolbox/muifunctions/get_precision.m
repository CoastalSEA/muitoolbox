function p = get_precision(x)
%
%-------function help------------------------------------------------------
% NAME
%   get_precision.m
% PURPOSE
%   find the precision of  a number
% USAGE
%   p = get_precision(x)
% INPUTS
%    x - a number to be tested
% OUTPUT
%   p - precision of x
% SEE ALSO
%   called in editrange_ui and var2str
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
% 
    maxp = 20;                  %maximum number of decimal places
    y = x.*10.^(1:maxp);
    p = find(y==round(y),1);
end