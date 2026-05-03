function  res = plot_scatter_surface(x,y,plotxt,iscentroid,ispolar)
%
%-------function help------------------------------------------------------
% NAME
%   plot_scatter_surface.m
% PURPOSE
%   plot points as a scatter diagram and contour the frequency surface
% USAGE
%   plot_scatter_surface(x,y,ispolar,iscentroid)
% INPUTS
%   x - vector of x or R
%   y - vector of y or theta 
%   plotxt - struct for title,subtitle,xlabel,ylabel strings or character
%            vectors
%   iscentroid - true if centroid point is to be added; default is false
%   ispolar - true if polar coordinates; default is false
% OUTPUT
%   scatter plot with frequency surface
%   res - silent output when called from muiManipUI class
% NOTES
%   empty plotxt struct:
%   plotxt = struct('title','','subtitle','','xlabel','','ylabel','');
%
% Author: Ian Townend
% CoastalSEA (c) May 2026
%--------------------------------------------------------------------------
%
    res = 'no output';
    blnktxt = struct('title','','subtitle','','xlabel','Var1','ylabel','Var2');

    %parse input
    if nargin<3, plotxt = blnktxt; iscentroid = 0; ispolar = 0; 
    elseif nargin<4, iscentroid = 0; ispolar = 0; 
    elseif nargin<5, ispolar = 0; 
    end

    if isempty(plotxt), plotxt = blnktxt; end

    %convert polar coordinates to cartesian
    if ispolar
        xx = x.*cos(y);
        yy = x.*sin(y);
        x = xx; y = yy; clear xx yy
    end
    
    %create figure and axes
    hf = figure('Name','Taylor Diagram','Tag','PlotFig');
    ax = axes(hf);  
   

    %plot the data set points
    plot(ax,x,y,'xk','MarkerSize',0.5,'DisplayName','Data points');
    hold(ax,'on')

    %get the histogram data
    nint = round(log10(numel(x)))*10;
    nbins = [nint,nint];
    xy = [x,y];
    [Z,XY] = hist3(xy,'Nbins',nbins); %requires Statistics and Machine Learning Toolbox
    htrec = max(length(find(~isnan(y))),length(find(~isnan(x))));
    Z = Z/htrec*100;                       %percentage occurrence
    [zmx,idz] = max(Z,[],'all');
    [ihx,ihy] = ind2sub(size(Z),idz);

    ci = [0.02,0.05,0.1,0.2,0.5,0.8]*zmx;  %contour intervals
    contourf(ax,XY{1},XY{2},Z',ci,'FaceAlpha',0.75,'DisplayName','Histogram');    
    colormap(flipud(colormap('bone')));
    cb  = colorbar;
    cb.Label.String = 'Frequency (%)';

    if iscentroid
        %plot peak of 2D histogram   
        hxx = XY{1}(ihx);
        hyy = XY{2}(ihy);   
        mdtxt = sprintf('Mode at x=%.1f, y=%.1f',hxx,hyy);
        plot(ax,hxx,hyy,'o',...
                    'LineWidth',2.0,'MarkerSize',6,'Color','r',...
                    'DisplayName','Histogram centroid','ButtonDownFcn',@godisplay,...           
                    'Tag','Histogram marker','UserData',mdtxt);    
        
        %plot mean value of all points    
        mxx = mean(x,'omitnan');
        myy = mean(y,'omitnan');  
        mntxt = sprintf('Mean at x=%.1f, y=%.1f',mxx,myy);
        plot(ax,mxx,myy,'x',...
                    'LineWidth',2.0,'MarkerSize',10,'Color','b',...
                    'DisplayName','Sample Mean','ButtonDownFcn',@godisplay,...           
                    'Tag','Mean marker','UserData',mntxt); 
    end

    xlabel(plotxt.xlabel)
    ylabel(plotxt.ylabel)
    if ~isempty(plotxt.title), title(plotxt.title); end
    if ~isempty(plotxt.subtitle), subtitle(plotxt.subtitle); end
    %add legend
    hold(ax,'off')
    legend(ax,'show','Location','northeast');
end