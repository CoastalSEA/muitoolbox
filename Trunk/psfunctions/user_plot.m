function user_plot(obj,mobj)
%
%-------function help------------------------------------------------------
% NAME
%   user_plot.m
% PURPOSE
%   User defined plotting function
% USAGE
%   user_plot(obj,mobj)
% INPUT
%   obj - handle to instance of calling PlotFig class
%   mobj - handle to CoastalTools to allow access to data
% OUTPUT
%   user plot
% SEE ALSO
%   muiPlotsUI.m, muiPlots.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2021
%--------------------------------------------------------------------------
%

    %manage plot generation for different types and add/delete                   
    %get an existing figure of create a new one
    getFigure(obj); 
%--------------------------------------------------------------------------
% Plot implementation - see muiPlots.m for existing examples of different 
% types of plot. An instance of muiPlots is passed as obj and contains the
% user selection in UIsel and UIset, along with the Data, Labels, Legend
% text, etc (see properties of muiPlots).% 
%--------------------------------------------------------------------------         
    %define plot to be produced
    if ~isfield(obj.Data,'Z')
        %e.g. line plot       
        x = obj.Data.X; y = obj.Data.Y;
        figax = axes('Parent',obj.Plot.CurrentFig,'Tag','PlotFigAxes'); 
        hold(figax,'on')
        plot(x,y)
        hold(figax,'off')
        legend(obj.Legend)
    else
        %e.g. surface plot of X,Y,Z data
        nint = 50;
        convertTime(obj);
        x = obj.Data.X; y = obj.Data.Y; z = obj.Data.Z';        
        wid = 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId';
        minX = min(min(x)); maxX = max(max(x));
        minY = min(min(y)); maxY = max(max(y));
        xint = (minX:(maxX-minX)/nint:maxX);
        yint = (minY:(maxY-minY)/nint:maxY);
        [xq,yq] = meshgrid(xint,yint);
        warning('off',wid)
        zq = griddata(x,y,z,xq,yq);
        surf(xq,yq,zq,'EdgeColor','none'); %plotting the field variable
        shading interp
        warning('on',wid)
        cb = colorbar;
        cb.Label.String = obj.Legend; 
    end
    xlabel(obj.AxisLabels.X);
    ylabel(obj.AxisLabels.Y);
    title(obj.Title);
    
%--------------------------------------------------------------------------
% Finish - assign muiPlot instance to handle
%--------------------------------------------------------------------------         
    mobj.mUI.Plots = obj;
end