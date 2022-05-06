function xcorrelation_plot(ds1,ds2,metatxt)
%
%-------function help------------------------------------------------------
% NAME
%   xcorrelation_plot.m
% PURPOSE
%   Generate a cross-correlation plot for user selected data and model
%   timeseries data are interpolated to a common time over shortest record,
%   all other data have to be the same length vectors 
% USAGE
%   xcorrelation_plot(ds1,ds2,metatxt)
% INPUTS
%   ds1 - first data set (X)  - reference vector
%   ds1 - second data set (Y) - vector to apply the lag to
%   metatxt - text describing user selection 
%             order is {dependent label, independent label, title, data selection} 
%             only labels are required but data selection must be cell(4)
% OUTPUT
%   plot of X-correlation lags with details of lag in title
% SEE ALSO
%   regression_model.m, regression_plot.m, DataStats.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%--------------------------------------------------------------------------
%

    if isa(ds1,'dstable') && isa(ds2,'dstable')
        %both are timeseries data sets and may need interpolation
        if (isdatetime(ds1.RowNames) || isduration(ds1.RowNames)) && ...
                (isdatetime(ds2.RowNames) || isduration(ds2.RowNames))
            %both data sets are time or duration timeseries
            [ref_ds,lag_ds] = getoverlappingtimes(ds1,ds2,false);
            %use ts with least points as ts to interpolate onto 
            refdat = ref_ds.DataTable{:,1};
            lagdat = lag_ds.DataTable{:,1};
            if height(ref_ds)<height(lag_ds)            
                lagdat = interp1(lag_ds.RowNames,lagdat,ref_ds.RowNames,'linear');
                mtime = ref_ds.RowNames;
            else
                refdat = interp1(ref_ds.RowNames,refdat,lag_ds.RowNames,'linear');            
                mtime = lag_ds.RowNames;
            end
        else
            warndlg('dstables are not both timeseries data sets')
            return
        end

        %simple sign wave code to test function------------------------
%             mtime = datetime:hours(1):datetime+days(4);                       
%             refdat = 10*sin(2*pi()*(mtime-datetime)/days(1));
%             lagdat = 10*sin(2*pi()*((mtime-datetime)/days(1)+0.15));
        %end-----------------------------------------------------------
        startyear = year(mtime(1));
        intime = startyear+years(mtime-datetime(startyear,1,1)); 
        intime = mean(diff(intime)); %mean time interval of data set (years)
        
        tlist = {'years','days','hours','minutes','seconds'};
        [h_dlg,ok] = listdlg('Name','X-correlation', ...
                        'PromptString','Select units for lag', ...
                        'SelectionMode','single', ...
                        'ListSize',[150,80],...
                        'ListString',tlist);
        if ok==0, return; end 
        switch tlist{h_dlg}
            case 'years'
                Ts = intime; %average sampling interval
            case 'days'
                Ts = intime*365;
            case 'hours'
                Ts = intime*365*24;
            case 'minutes'
                Ts = intime*365*24*60;
            case 'seconds'
                Ts = intime*365*24*3600;
        end
        nint = 2*length(mtime)-1;

        prompt = {'Maximum lag:'};
        titxt = 'X-correlation lag';
        dims = [1 35];
        definput = {num2str(nint)};
        answer = inputdlg(prompt,titxt,dims,definput);
        if ~isempty(answer)
            nint = str2double(answer);
        end
    else   %not time series data
        mtime = [];
        if istable(ds1)
            ds1 = squeeze(ds1{:,1}); 
            if iscell(ds1) && ischar(ds1{1})
                %categories for ds1 will reordered sequentially
                ds1 = double(categorical(ds1,'Ordinal',true));
            end
            ds2 = squeeze(ds2{:,1}); 
            if iscell(ds2) && ischar(ds2{1})
                %categories for ds2 will reordered sequentially
                ds2 = double(categorical(ds2,'Ordinal',true));
            end
        end
        %
        if length(ds1)==length(ds2)
            refdat = ds1;
            lagdat = ds2;
            nint = 2*length(ds1)-1;
            Ts = 1;
            tlist = {'Unit interval'};
            h_dlg = 1;
        else
            warndlg('Datasets are not the same length. Case not handled');
            return;           
        end        
    end
    %extract data from table and run x-correlation (in Signal Toolbox)
    inp = table(refdat,lagdat);
    inp = rmmissing(inp,1); %remove rows with NaNs
    ds1 = table2array(inp(:,1));
    ds1 = reshape(ds1,numel(ds1),1);
    ds2 = table2array(inp(:,2));
    ds2 = reshape(ds2,numel(ds2),1);
    [acor,lag] = xcorr(ds1,ds2,nint);
    [~,I] = max(abs(acor));
    lagDiff = lag(I);
    timeDiff = lagDiff*Ts;
    lag = lag*Ts;
    plot_figure(tlist{h_dlg}) 
%%
    function plot_figure(unitxt)    
        %plot cross-correlation as a function of lag
        figure('Name','X-correlation plot', ...
            'Units','normalized', ...
            'Resize','on','HandleVisibility','on', ...
            'Tag','StatFig');
        if length(refdat)<30
            hp = stem(lag,acor);
        else
            hp = plot(lag,acor);
        end  
        
        if length(metatxt)>3
            %add metadata to line if provided
            hp.UserData  = metatxt{4};
            hp.ButtonDownFcn = @godisplay;
        end
        xlabel(sprintf('Lag in %s',unitxt));
        ylabel('Cross-correlation');
        title(sprintf('Maximum lag time: %g %s\nfor %s relative to %s',...
                             timeDiff,unitxt,metatxt{2},metatxt{1}));
        if isa(ds1,'timeseries')
            %plot adjusted time series
            timeadj = eval(sprintf('%s(timeDiff)',unitxt));
            if lagDiff>0
                datadj = lagdat(1:end-lagDiff);
                tinadj = mtime(1:end-lagDiff)+timeadj;
            else
                datadj = lagdat(-lagDiff+1:end);
                tinadj = mtime(-lagDiff+1:end)+timeadj;
            end

            figure('Name','Adjusted timeseries plot', ...
                'Units','normalized', ...
                'Resize','on','HandleVisibility','on', ...
                'Tag','PlotFig');
            plot(mtime,normvar(refdat))
            hold on
            plot(tinadj,normvar(datadj))
            xlabel('Time')
            ylabel('Normalised variable')
            adjtxt = sprintf('%s adjusted by %0.3g %s',ds2.Name,timeDiff,unitxt);
            legend(ds1.Name,adjtxt)
            title(sprintf('%s lagged relative to %s',metatxt{2},metatxt{1}));
            hold off
        end
    end
end
%%    
function var = normvar(subvar)
    mvar = mean(subvar,'omitnan');
    svar = std(subvar,'omitnan');
    var(:,1) = (subvar-mvar)/svar;
end