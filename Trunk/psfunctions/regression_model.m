function [a,b,Rsq,x,y,txt] = regression_model(inddata,depdata,model,nint,isplot)
%
%-------function help------------------------------------------------------
% NAME
%   regression_model.m
% PURPOSE
%   transform data for selected regression model and return regression
%   coefficients and sample values. 
% USAGE
%   [a,b,Rsq,x,y,txt] = regression_model(inddata,depdata,model,nint)
% INPUT
%   inddata - independent variable
%   depdata - dependent variable
%   model - regression model to use (linear,power,exp,log)
%   nint - number of points for regression line. 
%          If not supplied or empty uses the inddata points
%   isplot- true generates a plot of the fit
% OUTPUT
%   a and b - fit coefficients (intecept and slope in linear form)
%   Rsq - coefficient of determination
%   x and y - the co-ordinates of the fitted model at nint points
%   txt - provides a text summary of the results
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%--------------------------------------------------------------------------
%
    if nargin<4
        nint = [];
        isplot = false;
    elseif nargin<5
        isplot = false;
    end
    %
    model = lower(model);
    switch model
        case 'linear'
            depvar = depdata;
            indvar = inddata;
        case 'power'
            depvar = log(depdata);
            indvar = log(inddata);
        case 'exponential'
            depvar = log(depdata);
            indvar = inddata;
        case 'logarithm'
            depvar = depdata;
            indvar = log(inddata);
    end
    %remove infinite values in power/logarithm cases when data<=0
    depvar(isinf(depvar)) = NaN;
    indvar(isinf(indvar)) = NaN;
    %fit transformed data and create regression line
    [b,a,Rsq] = simpleLinearRegression(indvar,depvar);
    if b==0
        x = []; y  = []; txt = 'No solution found';
        return;
    end
    %
    if nargin<4 || isempty(nint)
        x = indvar;
    else
        xint = (max(indvar)-min(indvar))/nint;
        x = min(indvar):xint:max(indvar);
    end     
    y = a+b*x;
    %now transform back
    switch model
        case 'linear'
            txt = sprintf('y=%.3f+%.3f.x; R^2=%.3f',a,b,Rsq);
        case 'power'
            x = exp(x);
            y = exp(y);
            a = exp(a);
            txt = sprintf('y=%.3f.x^{%.3f}; R^2=%.3f',a,b,Rsq);
        case 'exponential'
            y = exp(y);
            a = exp(a);
            txt = sprintf('y=%.3f.exp(%.3f.x); R^2=%.3f',a,b,Rsq);
        case 'logarithm'
            x = exp(x);
            txt = sprintf('y=%.3f+%.3f.Log(x); R^2=%.3f',a,b,Rsq);
    end
    if isplot
        plot_of_fit(inddata,depdata,x,y,txt);
    end
end
%% 
function [slope,intercept,Rsq] = simpleLinearRegression(x,y)
    %find slope intercept and r^2 using linear regression
    % see Matlab documentation for Simple Linear Regression
    % Considers only one independent variable using the relation
    % y = a + b.x, where a is the y-intercept and b is the slope
    % for intercept=0 just use slope=x\y
    % this code uses y = intercept + slope.x
    if length(x)~=length(y)
        slope = 0; intercept = 0; Rsq = 0;
        return;
    end
    
    idx = ~isnan(x) & ~isnan(y); %remove any NaNs
    %[m,n] = size(x);
    xx = x(idx);
    yy = y(idx);
    
    if size(xx,2)>1
        xx = xx';   yy = yy'; 
    end

    X = [ones(length(xx),1) xx]; %this adds intercept to l.sq. estimate
    a_b = X\yy;       %the \ operator performs a least-squares regression
    yCalc = X*a_b;
    Rsq = 1 - sum((yy - yCalc).^2)/sum((yy - mean(yy)).^2);
    slope = a_b(2);
    intercept = a_b(1);
end
%%
function plot_of_fit(xi,yi,xo,yo,res)
    %plot the curve fit
    hf = figure('Name','Regression plot', ...
            'Units','normalized', ...
            'Resize','on','HandleVisibility','on', ...
            'Tag','PlotFig');
    plot(xi,yi,'.','MarkerSize',8);
    xlabel('Independent data');
    ylabel('Dependent data');
    hold on
    plot(xo,yo,'-','LineWidth',1)
    hold off
    title(sprintf('%s',res));
end