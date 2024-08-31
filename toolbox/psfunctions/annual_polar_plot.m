function annual_polar_plot(var,tvar,tint,plotxt,stderr)
%
%-------function help------------------------------------------------------
% NAME
%   annual_polar_plot.m
% PURPOSE
%   plot the monthly or seasonal values of a timeseries variable
% USAGE
%   annual_polar_plot(var,tvar,tint,plotxt,stderr)
% INPUTS
%   var - data at tint interevals 
%   tvar - values of tint used by var
%   tint - increments to plot (eg 4 seasons or 12 months)
%   plotxt - struct of labels, legend and title text with fields:
%            xlabel, ylabel,title,legend
%   stderr - standard error or deviation to be plotted as +/-error bars (optional)
% OUTPUT
%   polar plot of mean and standard error as a function of month in year
% EXAMPLE
%     var = [1.4,2.3,7.6,3.2;...       %row 1 = first variable
%            2.1,2.5,7.3,2.9];         %row 2 = 2nd variable
%     tvar = [3,6,9,12];               %month of sampling
%     stderr = [0.2,0.15,0.53,0.24;... %row 1 stderror for first variable
%               0.12,0.2,0.55,0.31];   %row 1 stderror for 2nd variable
%     plotxt = struct('rlabel','','thetalabel','','title','','legend','');
%     plotxt.rlabel = "Variable name (units)";       %text for radius (magnitude)
%     plotxt.thetalabel = cellstr(num2str((1:12)'))';%text for radial points
%     plotxt.title = 'Test of annual polar plot';    %plot title
%     plotxt.legend = {'Set 1','Set 2'};             %legend for each variable
% 
%     annual_polar_plot(var,tvar,12,plotxt,stderr); 
% 
%     plotxt.thetalabel = {'Spring','Summer','Autumn','Winter'};
%     annual_polar_plot(var,tvar,4,plotxt,stderr); 
% NOTES
%   alternative to cartesian plot to avoid "end of year gap", called in
%   descriptive_stats
%
% Author: Ian Townend
% CoastalSEA (c)June 2021
%--------------------------------------------------------------------------
%
    if nargin<3
        stderr = [];
        plotxt = struct('rlabel','Rvar','thetalabel','Theta',...
                        'title','Annual polar plot','legend',{''});
    elseif nargin<4
        stderr = [];
    end

    %create figure and axes
    [hfig,h_ax] = getFigAx(tint,plotxt);
    hold(h_ax,'on')
    
    thetavar = 2*pi/tint*tvar; 
    thetavar(end+1) = thetavar(1);
    var(:,end+1) = var(:,1);
    
    polarplot(h_ax,thetavar,var(1,:),'DisplayName',plotxt.legend{1})
    hold on
    for i=2:size(var,1)
        polarplot(h_ax,thetavar,var(i,:),'DisplayName',plotxt.legend{i})
    end
    

    if ~isempty(stderr)
        %add error bars to plot
        var = var(:,1:end-1);
        tvar = thetavar(1:end-1);
        polarErrorBars(h_ax,var,tvar,stderr)
    end
    
    hold off
    titletxt = wraptext(plotxt.title,hfig,true); 
    subtitletxt = wraptext(plotxt.rlabel,hfig,false);
    title(titletxt);
    subtitle(subtitletxt);
    legend('Location','southeast');
    hold(h_ax,'off')   
end
%
function [h_f,h_ax] = getFigAx(tint,plotxt)
    %initialise figure and polar plot axes
    h_f = figure('Name','Results Plot','Units','normalized',...                
                'Resize','on','HandleVisibility','on','Tag','PlotFig');
    %move figure to top right
    h_f.Position(1) = 1-h_f.Position(3)-0.01;
    h_f.Position(2) = 1-h_f.Position(4)-0.12;    
    h_ax = polaraxes('Parent',h_f,'Tag','PlotFigAxes');
    h_ax.ThetaAxisUnits = 'radians';
    h_ax.ThetaTickMode = 'manual';
    h_ax.ThetaTick = linspace(0,2*pi,tint+1); 
    h_ax.ThetaTickLabel = [plotxt.thetalabel{end},plotxt.thetalabel(1:end-1)];
    h_ax.ThetaZeroLocation = 'top';
    h_ax.ThetaDir = 'clockwise';
    h_ax.RAxisLocation = 2*pi/tint/2;
end
%
function polarErrorBars(h_ax,var,tvar,stderr)
    %add error bars to a polat plot
    varplus = var+stderr;
    varminus = var-stderr;
    varminus(varminus<0) = 0;
    hl = flipud(findobj(h_ax,'Type','line'));
    for i=1:size(var,1)  %select each variable
        ivarplus = varplus(i,:);
        ivarminus = varminus(i,:);
        for j=1:length(ivarplus) %select each time interval
            jvar = [ivarplus(j),ivarminus(j)];
            jt = [tvar(j),tvar(j)];
            h1 = polarplot(h_ax,jt,jvar,'Color',hl(i).Color);  %errorbar
            h1.Annotation.LegendInformation.IconDisplayStyle = 'off';
            h2 = polarscatter(h_ax,jt,jvar,'.','SizeData',30,...
                               'MarkerEdgeColor',hl(i).Color); %end marker
            h2.Annotation.LegendInformation.IconDisplayStyle = 'off';
        end
    end
end