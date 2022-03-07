function stderr = stderror(x,y,a,b,model)
%
%-------function help------------------------------------------------------
% NAME
%   stderror.m
% PURPOSE
%   Compute the standard error of a data set relative to a fitted
%   regression line
% USAGE
%   stderr = stderror(x,y,a,b)
% INPUTS
%   x - independent variable
%   y - dependent variable
%   a - intercept of regression
%   b - slope of regression 
%   model - regression model used to estimate a and b (linear,power,exp,log)
% OUTPUT
%   stderr - standard error
% NOTES
%   Computes tha anomoly of the fit line defined by intercept a and slope b
%   and the data set defined by x and y.
% SEE ALSO
%   regression_model.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    if nargin<4
        model = 'linear';
    end

    if length(x)~=length(y) || b==0 %trap incorrect input data
        stderr = -99;
        return;
    end
    
    model = lower(model);
    switch model
        case 'linear'
            Xm = x;
        case 'power'
            Xm = ln(x);  %NOT TESTED
            a = ln(a);
        case 'exponential'
            Xm = ln(x);  %NOT TESTED
            a = ln(a);
        case 'logarithm'
            Xm = exp(x);  %NOT TESTED
    end
    
    ye = a+b*Xm;
    diff = y-ye;
    diff(isnan(diff)) = [];
    stderr = std(diff)/sqrt(length(diff));
    