function ax = var_range_plot(ax,X,Y,names)
%
%-------function help------------------------------------------------------
% NAME
%   var_range_plot.m
% PURPOSE
%   plot mean values with high and low bars. x and y are 3 column matrices
    %offsets from mean to low and high values
% USAGE
%   var_range_plot(ax,X,Y,names)
% INPUTS
%   ax - handle to figure or plot axes
%   X - 3 column array of upper, mean and lower values (must be in this order)
%   Y - 3 column array of upper, mean and lower values (must be in this order)
%   names - cell or string array of names for each tuple (rows in X and Y)
% OUTPUT
%   plot of X and Y using error bars to indicate range
%   ax - returns axes handle
% SEE ALSO
%   used in EstuaryDB and called from edb_user_plots.m
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
% 
    if isgraphics(ax,'figure')
        h_fig = ax;
        h_fig.Tag = 'PlotFig';
        ax = axes('Parent',h_fig);
    end
    
    TT = [X(:,2),Y(:,2)];            %cental values
    [~,idn] = rmmissing(TT,1);       %removing rows with NaN central values
    X = X(~idn,:);
    Y = Y(~idn,:);
    names = names(~idn);    

    %first order difference between columns to define offsets
    Xdiff = diff(X,1,2);   
    Ydiff = diff(Y,1,2);

    %marker for central point when one of the range values is NaN
    divx = X(:,2); 
    divx(~any(isnan(Xdiff),2)) = NaN; 
    divy = Y(:,2); 
    divy(~any(isnan(Ydiff),2)) = NaN;

    %offset position for text estuary names
    xtxt = X(:,2)+abs(sum([Xdiff(:,1),Xdiff(:,2)],2,'omitnan')*1.1);
    idt = Xdiff(:,1)>0 & Xdiff(:,2)>0;      %find two sided cases (both +ve)
    xtxt(idt) = X(idt,2)+max(Xdiff(idt,1),Xdiff(idt,2))*1.1; %use maximum of the two

    %generate plot  
    errorbar(ax,X(:,2),Y(:,2),Ydiff(:,1),Ydiff(:,2),Xdiff(:,1),Xdiff(:,2),...
                                                         'o','CapSize',8)
    hold on
    plot(divx,divy,'og')
    text(xtxt,Y(:,2),names,'FontSize',8);
    %annotation('textbox','String',names,'FitBoxToText','on',X(:,2),Y(:,2))

    hold off
    answer = questdlg('Log axes?','Range plot','Yes','No','Yes');
    if strcmp(answer,'Yes')
        answer = questdlg('Log axes?','Range plot','X','Y','Both','Both');
        if strcmp(answer,'X')
            ax.XScale = 'log';
        elseif strcmp(answer,'Y')
            ax.YScale = 'log';
        elseif strcmp(answer,'Both')
            ax.XScale = 'log';
            ax.YScale = 'log';
        end
    end
end