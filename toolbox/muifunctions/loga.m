function y = loga(x,a)
%
%-------function help------------------------------------------------------
% NAME
%   loga.m
% PURPOSE
%   Compute the logarithm of x to base a
% USAGE
%   y = loga(x,a)
% INPUTS
%   x - scalar or vector numerical values. must be positive because 
%   logarithms are undefined for non-positive numbers.
%   a - base to use for the logarithm
% OUTPUT
%   y - values to the log of base a. must be positive and not equal to 1 
%   because a logarithmic base must satisfy these conditions.
% See Also
%   called in base_a_hypsometry.m
%
% Author: Ian Townend
% CoastalSEA (c) Oct 2025
%--------------------------------------------------------------------------
%    
    if any(x<=0)                                 % Input validation
        error('Input x must be positive.');
    end
    if a<=0 || a==1
        error('Base a must be positive and not equal to 1.');
    end
    
    % Compute log to the base a
    y = log(x)/log(a);
end