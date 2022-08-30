function H = hurst_aalok_ihlen(x,scale,m,metatxt)
%
%-------function help------------------------------------------------------
% NAME
%   hurst_aalok_ihlen.m
% PURPOSE
%  Estimate the Hurst exponent of a timeseries, using the method proposed
%  by Aalok
% USAGE
%   H = hurst_aalok_ihlen(x,scale,m,metatxt)
% INPUTS
%   x - timeseries variable, timeseries, or dstable dataset
%   scale - vector of scale values to test
%   m - degree of polynomial fit, specified as a positive integer scalar.
%       optional, default = 1.
%   metatxt - description of case and variable selected (optional)
% OUTPUT
%   H - Hurst exponent
% NOTES
%   Code based on Hurst_Exponent.m using method of Ihlen
%   Ref: https://www.frontiersin.org/articles/10.3389/fphys.2012.00141/full
%   Source: https://www.mathworks.com/matlabcentral/fileexchange/100988-hurst-exponent
%   Author: atharva aalok
%   Date: unknown - downloaded 2022
%   To get a correct value for H a sufficient representation of data is 
%   needed in the scale. If too small a scale is chosen then Hurst may be 
%   unable to capture the data properties.
% SEE ALSO
%   called from hurst_exponent
%   modified to work with data that included NaNs, IHT, 25/08/22
% 
% CoastalSEA (c) Aug 2022
%--------------------------------------------------------------------------
%
    if nargin<4
        metatxt = 'Hurst Exponent';
    elseif nargin<3
        metatxt = 'Hurst Exponent';
        m = 1;
    end
    %ensure that variable is a row vector    
    if iscolumn(x), x = x'; end  
    %convert noise like time series to random walk like time series
    x = cumsum(x - mean(x,2,'omitnan'),'omitnan');
    
    for ns = 1:length(scale)
        segments = floor(length(x)/scale(ns));
        for v = 1:segments
            Idx_start = ((v-1)*scale(ns))+1;
            Idx_stop = v*scale(ns);
            Index = Idx_start:Idx_stop;
            X_Idx = x(Index);
            isf = isfinite(X_Idx);
            C = polyfit(Index(isf),X_Idx(isf), m);
            fit = polyval(C, Index(isf));
            RMS(ns,v) = sqrt(mean((X_Idx(isf)-fit).^2,2,'omitnan'));
        end
        F(ns) = sqrt(mean(RMS(ns,:).^2,2,'omitnan'));
    end
    
    C = polyfit(log2(scale), log2(F),1);
    H = C(1);
    RegLine = polyval(C, log2(scale));

    % Uncomment the following to visualize Hurst.
    hf = figure('Name','Hurst Plot','Tag','StatFig');
    ax = axes(hf);
    legtxt = sprintf('Final H = %.3g',H);
    plot(ax,(log2(scale)-min(log2(scale)))/max(log2(scale)-min(log2(scale))), (RegLine-min(RegLine))/max(log2(scale)-min(log2(scale))), 'LineWidth', 2, 'DisplayName', legtxt);
    hold on
    plot(ax,(log2(scale)-min(log2(scale)))/max(log2(scale)-min(log2(scale))), (log2(F)-min(RegLine))/max(log2(scale)-min(log2(scale))), 'LineWidth', 2, 'DisplayName', 'Variation of H');
    legend();
    ylim([0, 1]);
    hold off
    fittedtitle(hf,metatxt,false,0.68);
end


