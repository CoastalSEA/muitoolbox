function cvar = complex_vector_plot(x,y,figtitle)
%
%-------function help------------------------------------------------------
% NAME
%   complex_vector_plot.m
% PURPOSE
%   Creates a polar plot of the movement at each interval from one position
%   to the next
% USAGE
%   cvar = complex_vector_plot(x,y,figtitle)
% INPUTS
%   x - complex number vector
%   OR
%   x - real part, or x coordinate
%   y - imaginary part, or y coordinate
%   figtitle - title to be added to plot (optional)
% OUTPUT
%   cvar - dummy ouput allows function to be called from DataManip.m
% SEE ALSO
%   phaseplot.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%--------------------------------------------------------------------------
%
    if nargin==1 || (nargin==2 && isreal(x)) 
        figtitle = 'Complex vector plot';
    end
    
    if isreal(x)
        cvar = zeros(size(x));
        for jj=2:length(x)
            a = x(jj)-x(jj-1);
            b = y(jj)-y(jj-1);
            cvar(jj) = complex(a,b);
        end
    else
        for jj = 2:length(x)
            cvar = x(jj)-x(jj-1);
        end        
    end
    
    figure('Tag','PlotFig');
    %can use polarplot, feather and compass
    polarplot(cvar,'o','DisplayName','Centroids')
    %compass(cvar)
    %feather(cvar);
    hold on
    h1 = polarplot(cvar,'.');
    % Exclude line from legend
    h1.Annotation.LegendInformation.IconDisplayStyle = 'off';  
    hold off
    legend
    title(figtitle);
    cvar = {'Plot completed'}; %cell ouput required by call from DataManip.createVar 
end