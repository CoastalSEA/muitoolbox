function model = regression_selection()
%
%-------function help------------------------------------------------------
% NAME
%   regression_selection.m
% PURPOSE
%   select rregression model to use from Linear, Linear0, Power, 
%   Exponential, Logarithm. Linear0 forces intercept to zero
% USAGE
%   model = regression_selection();
% OUTPUT
%   model - seleected regression model
%
% Author: Ian Townend
% CoastalSEA (c) March 2026
%--------------------------------------------------------------------------
%
    regression_models = {'Linear','Linear0','Power','Exponential','Logarithm'};
    [indx,ok] = listdlg('PromptString','Select a regression model:',...
        'SelectionMode','single','ListSize',[150,100],...
        'ListString',regression_models);
    if ok<1, model = ''; return, end
    model = regression_models{indx}; %selected model type
end