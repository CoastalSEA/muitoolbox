function regression_plot(ind_ds,dep_ds,metatxt,model)
%
%-------function help------------------------------------------------------
% NAME
%   regression_plot.m
% PURPOSE
%   generate a regression plot for 2-D data and fitted regression model
% USAGE
%   regression_plot(ind_ds,dep_ds,metatxt,model)
% INPUT
%   ind_ds - independent data set
%   dep_ds - dependent data set
%   metatxt - cell array for describing user selection, 
%             order is {dependent label, independent label, title, data selection} 
%             only labels are required but data selection must be cell(4)
%   model - regression model to fit
% OUTPUT
%   plot of results from regression_model
% NOTES
%   timeseries data are interpolated to a common time, all other data have
%   to be the same length vectors
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%--------------------------------------------------------------------------
%
    istime = [];
    if isa(ind_ds,'timeseries') && isa(dep_ds,'timeseries')
        %both variables are timeseries data
        [~,idx] = min([dep_ds.Length,ind_ds.Length]);
        switch idx %use ts with least points as ts to interpolate onto                
            case 1
                time = getabstime(dep_ds);
                indat = TSDataSet.interpolateTSdata(ind_ds,time); 
                depdat = dep_ds.Data;
            case 2
                time = getabstime(ind_ds);
                depdat = TSDataSet.interpolateTSdata(dep_ds,time);
                indat = ind_ds.Data;
        end
    elseif isa(ind_ds,'timeseries') || isa(dep_ds,'timeseries')
        %one of the variables is a timeseries
        %assume that they are the same length
        if isa(ind_ds,'timeseries') && isdatetime(dep_ds)
            indat = ind_ds.Data;
            %eps(0) to avoid divide by zero in linear regression  
            [depdat,istime] = set_time_units(dep_ds,eps(0));              
        elseif isa(dep_ds,'timeseries') && isdatetime(ind_ds)
            [indat,istime] = set_time_units(ind_ds,eps(0));  
            depdat = dep_ds.Data;
        else
            warndlg('Unknown data types in regression_plot');
            return;
        end
    else   %not time series data
        if istable(ind_ds)
            ind_ds = squeeze(ind_ds{:,1});
            if iscell(ind_ds) && ischar(ind_ds{1})
                ind_ds = double(categorical(ind_ds,'Ordinal',true));
            end
            dep_ds = squeeze(dep_ds{:,1}); 
            if iscell(dep_ds) && ischar(dep_ds{1})
                dep_ds = double(categorical(dep_ds,'Ordinal',true));
            end
        end
        %
        nind = length(ind_ds); ndep = length(dep_ds);
        if nind==ndep 
            indat = ind_ds;
            depdat = dep_ds;
        else
            if nind<ndep
                x  = (1:nind)*100/nind;
                xv = (1:ndep)*100/ndep;
                indat = interp1(x',ind_ds,xv','linear','extrap');
                depdat = dep_ds;
            else
                x  = (1:ndep)*100/ndep;
                xv = (1:nind)*100/nind;
                indat = ind_ds;
                depdat = (interp1(x',dep_ds,xv','linear','extrap'));
            end
            msg = sprintf('Datasets are not the same length.\nInteprolation assumes data are uniformly spaced');
            warndlg(msg);
        end
    end
    nint = 10; %number of points in regression line
    [~,~,~,x,y,res] = regression_model(indat,depdat,model,nint);
    if ~isempty(istime)
        if isdatetime(ind_ds), idx = 1; else, idx = 2; end
        metatxt{idx} = sprintf('%s (%s)',metatxt{idx},istime);    
    end
    plot_figure(indat,depdat,x,y,res,metatxt);
end
%%
function plot_figure(indat,depdat,x,y,res,metatxt)
    %generate plot of results
    figure('Name','Regression plot', ...
            'Units','normalized', ...
            'Resize','on','HandleVisibility','on', ...
            'Tag','StatFig');
    hp = plot(indat,depdat,'o');
    if length(metatxt)>3
        %add metadata to line if provided
        hp.UserData  = metatxt{4};
        hp.ButtonDownFcn = @godisplay;
    end
    
    xlabel(metatxt{1});
    ylabel(metatxt{2});
    hold on
    plot(x,y,'-')
    hold off
    
    if length(metatxt)>2
        %add title if provided
        title(sprintf('Regression of %s',metatxt{3}));
    end
    
    %add regression equation to figure
    ha = annotation('textbox','String',sprintf('%s',res),...
        'FitBoxToText','on');
    ax = gca;
    ha.Position(2) = ax.Position(2)+ax.Position(4)-ha.Position(4)-0.01;
end