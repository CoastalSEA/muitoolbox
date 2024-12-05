function [ax,idn] = var_range_plot(ax,X,Y,names,varnames,islog)
%
%-------function help------------------------------------------------------
% NAME
%   var_range_plot.m
% PURPOSE
%   plot mean values with high and low bars. x and y are 3 column matrices
    %offsets from mean to low and high values
% USAGE
%   var_range_plot(ax,X,Y,names,varnames,scale)
%   var_range_plot(ax,X,Y,names)
%   var_range_plot(ax,X,Y,names,[],scale)
% INPUTS
%   ax - handle to figure or plot axes
%   X - 3 column array of upper, mean and lower values (must be in this order)
%   Y - 3 column array of upper, mean and lower values (must be in this order)
%   names - cell or string array of names for each tuple (rows in X and Y)
%   varnames - names to use for the data point error bars and the centre
%              marker for point where one or more limit is NaN (optional)
%   islog - logical scalar: true if log has been applied as part of data
%           selection
% OUTPUT
%   plot of X and Y using error bars to indicate range
%   ax - returns axes handle
%   idn - indices of rows removed because central value is missing
% SEE ALSO
%   used in EstuaryDB and called from edb_user_plots.m
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
% 
    if nargin<5 
        varnames{1} = 'low-mean-high';
        varnames{2} = '1+out of bounds';
        islog = false;
    elseif nargin<6
        islog = false;
    elseif isempty(varnames)
        varnames{1} = 'low-mean-high';
        varnames{2} = '1+out of bounds';
    end

    if isgraphics(ax,'figure')
        h_fig = ax;
        h_fig.Tag = 'PlotFig';
        ax = axes('Parent',h_fig);
    end
    
    TT = [X(:,2),Y(:,2)];            %central values
    [~,idn] = rmmissing(TT,1);       %removing rows with NaN central values
    X = X(~idn,:);
    Y = Y(~idn,:);
    names = names(~idn);   

    %check that variables are in the correct order
    if X(1,1)>X(1,3), X = fliplr(X); end
    if Y(1,1)>Y(1,3), Y = fliplr(Y); end

    %first order difference between columns to define offsets
    Xdiff = diff(X,1,2);   
    Ydiff = diff(Y,1,2);

    %marker for central point when one of the range values is NaN
    idv = any(isnan(Xdiff),2) | any(isnan(Ydiff),2);
    divx = X(idv,2); 
    divy = Y(idv,2);     

    %generate plot  
    errorbar(ax,X(:,2),Y(:,2),Ydiff(:,1),Ydiff(:,2),Xdiff(:,1),Xdiff(:,2),...
               'o','CapSize',8,'DisplayName',varnames{1},'Tag','ErrSym')
    %offset position for text estuary names
    scalefactor = 0.008;
    xrange = diff(ax.XLim);  xtxt = X(:,2)+xrange*scalefactor;
    yrange = diff(ax.YLim);  ytxt = Y(:,2)+yrange*scalefactor;

    if ~islog
        %option to add log axes if not defined in select variable
        answer = questdlg('Log axes?','Range plot','Yes','No','Yes');
        if strcmp(answer,'Yes')
            scalefactor = 0.08;
            answer = questdlg('Log axes?','Range plot','X','Y','X & Y','X & Y');
            if strcmp(answer,'X')
                ax.XScale = 'log';
                xtxt = X(:,2)+scalefactor*10.^log10(X(:,2));
            elseif strcmp(answer,'Y')
                ax.YScale = 'log';
                ytxt = Y(:,2)+scalefactor*10.^log10(Y(:,2));
            elseif strcmp(answer,'X & Y')
                ax.XScale = 'log';
                ax.YScale = 'log';    
                xtxt = X(:,2)+scalefactor*10.^log10(X(:,2));
                ytxt = Y(:,2)+scalefactor*10.^log10(Y(:,2));
            end
        end
    elseif strcmp(ax.XScale,'log') || strcmp(ax.YScale,'log')            
        %log axis already set so use log scaling for text offsets
        scalefactor = 0.05;
        if strcmp(ax.XScale,'log')
            xtxt = X(:,2)+scalefactor*10.^log10(X(:,2));
        end
        if strcmp(ax.XScale,'log')
            ytxt = Y(:,2)+scalefactor*10.^log10(Y(:,2));
        end
    end

    hold on
        plot(ax,divx,divy,'og','DisplayName',varnames{2})
        text(ax,xtxt,ytxt,names,'FontSize',8);
    hold off

    legend('Location','best')
end