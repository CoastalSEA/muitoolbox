function res = recursive_plot(data,varname,nint)    
%
%-------function help------------------------------------------------------
% NAME
%   recursive_plot.m
% PURPOSE
%   Plot a variable against itself with a step interval of nint
% USAGE
%   res = recursive_plot(data,varname,nint) 
% INPUT
%   data - data set to used to generate plot
%   varname - name of variable being plotted
%   nint - number of data points to use as an offset (optional, default = 1)
% OUTPUT
%   plot of x(i) versus x(i+nint)
%   res - dummy text so that function can be called from Derive Output UI
% SEE ALSO
%   phaseplot.m to plot x(i) v x(i+1) with time markers where x(i) and x(i+1) 
%   are input as x,y values
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%
    res = 'no output'; %null ouput required for exit in muiUserModel.setEqnData

    if nargin<2
        varname = 'X';
        nint = 1;
    elseif nargin<3
        nint = 1;
    end

    nrec = length(data);
    if nint==1
        y(1) = data(1);
        y(2:nrec+1) = data;
        data(nrec+1) = data(nrec);
    else
        nin = nint-1;
        y(:,1) = NaN(nint,1);
        for i=1:nrec-nin
            y(nin+i,1) = data(i);
        end
    end
    %generate plot of x(i) v x(i+nint)
    plotRecursive(data,y,nint,varname,'Recursive plot')
end
%%
function plotRecursive(x,y,nint,varname,txt)
    % plot the recursive data set
    hf = figure('Name','Recursive Plot','Tag','PlotFig');
    ax = axes(hf);
    plot(ax,x,y,'.--','MarkerSize',8)
    xlabel(sprintf('%s(i)',varname))
    ylabel(sprintf('%s(i+%d)',varname,nint))
    title(txt)            
end