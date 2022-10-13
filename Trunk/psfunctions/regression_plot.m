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
%             order is {independent label, dependent label, title, data selection} 
%             only labels are required but data selection must be cell(4)
%   model - regression model to fit
% OUTPUT
%   plot of results from regression_model
% NOTES
%   Input data can be numeric, datetime, duration, ordinal, or
%   timeseries data in a dstable which are interpolated to a common time
%   Interpoaltion is over period with common data overlap using the data 
%   set with the least points as the reference data set.
%   Datasets of different length that are not timeseries are interpolated
%   to the same length by assuming data are uniformly spaced
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%--------------------------------------------------------------------------
%
    istime = []; indat = []; depdat = [];
    if isa(ind_ds,'dstable') && isa(ind_ds,'dstable')
        %both are timeseries data sets and may need interpolation
        if (isdatetime(ind_ds.RowNames) || isduration(ind_ds.RowNames)) && ...
                (isdatetime(dep_ds.RowNames) || isduration(dep_ds.RowNames))
            %both data sets are time or duration timeseries
            [ind_ds,dep_ds] = getoverlappingtimes(ind_ds,dep_ds,false);
            %use ts with least points as ts to interpolate onto 
            indat = ind_ds.DataTable{:,1};
            depdat = dep_ds.DataTable{:,1};
            if height(ind_ds)<height(dep_ds)            
                depdat = interp1(dep_ds.RowNames,depdat,ind_ds.RowNames,'linear');
            else
                indat = interp1(ind_ds.RowNames,indat,dep_ds.RowNames,'linear');            
            end
        else
            warndlg('dstables are not both timeseries data sets')
            return
        end
    end

    %convert ordinal categorical data to numeric values
    if iscell(ind_ds) && ischar(ind_ds{1})
    if iscell(ind_ds) && ischar(ind_ds{1})
        ind_ds = double(categorical(ind_ds,'Ordinal',true));
        % a use case introduced a check that ind_ds values are unque
        % but the code below is the same whether unique or not???
        % if isunique(ind_ds)
        %    %independent variable may be an ordered set of unique values
        %    ind_ds = double(categorical(ind_ds,'Ordinal',true));
        % else
        %     ind_ds = double(categorical(ind_ds,'Ordinal',true));
        % end
    end
    %
    if iscell(dep_ds) && ischar(dep_ds{1})
        dep_ds = double(categorical(dep_ds,'Ordinal',true));
    end   

    if isdatetime(ind_ds) || isdatetime(dep_ds)
        %one of the inputs is time (assume both are not time)    
        if isdatetime(ind_ds)
            [indat,istime] = date2duration(ind_ds);  %returns calendar duration
            depdat = dep_ds; 
            idx = 1;
        else 
            indat = ind_ds;
            [depdat,istime] = date2duration(dep_ds); 
            idx = 2;
        end
    elseif isduration(ind_ds) || isduration(dep_ds) || ...
           iscalendarduration(ind_ds) || iscalendarduration(dep_ds)
        %one of the inputs is duration
        indat = ind_ds;
        depdat = dep_ds; 
        if isduration(indat) || iscalendarduration(ind_ds)
            istime = indat.Format;
            idx = 1;
        else 
            istime = depdat.Format;
            idx = 2;
        end
    end

    %check if data sets are same length and if not try interpolating
    if isempty(indat) %exclude time data which is already assigned
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
    
    %modify the metatxt and select origin if time units have been defined
    if ~isempty(istime)
        metatxt{idx} = sprintf('%s (%s)',metatxt{idx},istime);   
        answer = questdlg('Set time origin at 0 or first record?','Regression',...
                          'Origin','1st record','Origin');
        if strcmp(answer,'1st record')     %elapsed years from 1st record
           indat = time2num(indat,eps(0)); %add small offset to zero to
        else                               %avoid divide by zero
           indat = time2num(indat);        %elapsed years from 1-Jan-01
        end        
    end

    %now call regression model
    nint = 10; %number of points in regression line
    [~,~,~,x,y,res] = regression_model(indat,depdat,model,nint);

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