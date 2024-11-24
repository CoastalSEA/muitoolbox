function [valididx,range,cats] = listrange(var,limtxt)
%
%-------function help------------------------------------------------------
% NAME
%   listrange.m
% PURPOSE
%   extract range and indices within range for a list variable
% USAGE
%   varargout = listrange(var,limtxt)
% INPUTS
%   var - variable to be used to determine range and indices. variable list 
%         can be cellstr, string, categorical, char (NxM) array
%   limtxt - range text in the form 'From > XXXX To > YYYY'. Optional when
%            only rannge and cats output are required.
% OUTPUT
%   valididx - indices of the variable that are between the defined limits
%   range - the first and last value of the of categories of the list
%   cats - categories for the input list
% SEE ALSO
%   used in getvarindices
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024 
%--------------------------------------------------------------------------
% 
    if nargin<2, limtxt = []; end

    valididx = []; range = []; cats = [];
    
    if islist(var,1) %cellstr, string, categorical, char (NxM) array ie a list
        if isunique(var)
            %retain order of var by specifying categories
            var = categorical(var,var,'Ordinal',true);
        else
            %var has multiple occurrences of a category
            var = categorical(var,'Ordinal',true);
        end
        cats = categories(var);
        range = {cats{1},cats{end}};
        
        if ~isempty(limtxt)
            idx = regexp(limtxt,'>');
            lowerlimit = limtxt(idx(1)+1:idx(2)-4);
            upperlimit = limtxt(idx(2)+1:end);
            minV = categorical({lowerlimit},cats,'Ordinal',true);
            maxV = categorical({upperlimit},cats,'Ordinal',true);
            valididx = find(var>=(minV) & var<=(maxV));
        end
    end  
end