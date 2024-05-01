function pdf = gram_charlier_pdf(x,m,s,sk,ku,isplot)
%
%-------function help------------------------------------------------------
% NAME
%   gram_charlier_pdf.m
% PURPOSE
%   Estimates the Probability Density Function of the Gram Charlier Distribution 
%   for a series of x values, given the mean, variance, skewness and kurtosis parameters.
% USAGE
%    pdf = gram_charlier_pdf(x,m,s,sk,ku,isplot)
% INPUTS
%   x - values at which to sample the probability distribution function
%   m - mean of distribution (empty, scalar or vector)
%   s - standard deviation of distribution (empty, scalar or vector)
%   sk - skew of distribution (scalar)
%   ku - kurtosis of distribution (scalar)
%   isplot - logical true if plot is required (optional)
% OUTPUTS
%   pdf - probability distribution for given x values and the defined
%   statistical parameters.
% NOTES
%   Based on Matlab Forum function by Alexandros Gabrielsen, a.gabrielsen@city.ac.uk
%   Uses the method outlined by León, Á., Rubio, G., Serna, G., 2005. 
%   Autoregresive conditional volatility, skewness and kurtosis. The 
%   Quarterly Review of Economics and Finance, 45(4-5), 599-618. [10.1016/j.qref.2004.12.020]
%
% Author: Alexandros Gabrielsen
% Modified by Ian Townend,Mar 2023
%--------------------------------------------------------------------------
%
    if nargin<6
        isplot = false;
    end
    
    nint = length(x);
    nmean = length(m);
    nstd = length(s);
    
    %check that sk and ku are scalar 
    check = @(var) isscalar(var);
    assert(ccheck(sk) && check(ku),...
        'Skew and kurtosis statistical parameters must be scalar');
    
    if isempty(m), m=-50:1:50; end
    if isempty(s), s=1:1:51; end

    %compute the the polynomial part of fourth order and take the square to 
    %obtain a well defined density everywhere. Then divide by the
    %integral of the polynomial to ensure the density integrates to one.
    p = zeros(1,nint);
    for i = 1:nint 
              poly = (1+sk*(x(i)^3-3*x(i))/6+(ku-3)*(x(i)^4-6*x(i)^2+3)/24).^2;
              intpoly = 1+sk.^2/6+ku.^2/24;
              p(i) = poly./intpoly;
    end
    product = prod(p);

    pdf = zeros(nmean,nstd);
    for j=1:nmean
        for k=1:nstd
            pdf(j,k) = (1/(sqrt(2*pi)*s(k)))*exp(-(sum((x-m(j))/s(k)).^2))*product;
        end
    end

    if isplot && nmean>1 && nstd>1
        hf = figure('Name','Gram_Charlier','Tag','PlotFig');
        ax = axes(hf);
        [X,Y] = meshgrid(m,s);
        mesh(ax,X,Y,pdf');
        xlabel('Mean')
        ylabel('Standard deviation')
    end
end


