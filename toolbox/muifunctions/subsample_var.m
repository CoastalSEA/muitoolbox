function [X,Var,idx,issub] = subsample_var(x,var)                       
%
%-------function help------------------------------------------------------
% NAME
%   subsample_var.m
% PURPOSE
%   subsample a unique index, X, and return X and var for selected values
% USAGE
%   [X,var] = subsample_var(X,var) 
% INPUTS
%   x - vector of unique values to be subsampled (e.g. place names)
%   var - variable to be subsampled
% OUTPUT
%   X - sumsampled vector of input x
%   Var - subsampled vector of input var
%   idx - indices of subsmapled x values
%   issub - logical true if data has been subsampled
% NOTES
%    used to sumsample plotting variables such as location v variable.
% SEE ALSO
%   used in muiTableImport for scalar tabPlot
%
% Author: Ian Townend
% CoastalSEA (c) Oct 2024
%--------------------------------------------------------------------------
%  
    issub = false; X = x; Var = var; 
    promptxt = sprintf('Subsample X-values\nSelect values to include\nPress Cancel to use full list');   
    idx = listdlg('PromptString',promptxt,'ListString',X,...
                         'SelectionMode','multiple','ListSize',[180,300]);
    if isempty(idx), idx = 1:length(X); return; end
    
    X = x(idx);
    if iscategorical(x)     %categorical or ordinal data
        X = removecats(X);  %remove categories that are not used in the subsampled categorical array
    end
    if ~isempty(var), Var = var(idx); end 
    if length(X)~=length(x), issub = true; end    
end