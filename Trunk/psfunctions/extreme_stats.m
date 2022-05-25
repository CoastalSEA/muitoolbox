function [stats,h_fig] = extreme_stats(ts,metatxt,src)   
%
%-------function help------------------------------------------------------
% NAME
%   extreme_stats.m
% PURPOSE
%   Compute extreme values for a range of return periods using GPD
%   ts is a timeseries of the data to be used for the extremes fit
% USAGE
%   stats = extreme_stats(mobj,ts,metatxt,src)
%INPUT
%   ts - timeseries or dstable dataset
%   metatxt -  case and variable name being sampled
%   src - handle to tab or figure if output is being displayed (optional)
%OUTPUT
%   stats - table of extreme stastic results
%   h_fig - handle to figure (or tab if src used)
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%--------------------------------------------------------------------------
%
    [zp,threshold,npeaks,params,parmci,strtend] = get_extremes(ts); %#ok<ASGLU>
    %zp - return period estimates
    %threshold - threshold used in fit
    %params - gpd fit parameters
    %parmci - 95% confidence intervals
    if isempty(zp), stats = []; return; end
    %assign data to a table for display in SummaryTable figure
    Lower = zp(:,2);
    Estimate = zp(:,3);
    Upper = zp(:,4);
    stats = table(Lower,Estimate,Upper,'RowNames',string(zp(:,1)));
    stats.Properties.Description = sprintf('Return period (years) for %s\n%s\nThreshold=%gm, No. of peaks=%g, Shape=%g, Scale=%g',...
                      metatxt{1},var2range(strtend),threshold,npeaks,params(1),params(2));
    stats.Properties.DimensionNames = {'ReturnPeriod','Results'}; 
    if isempty(src)
        src = 'Extreme statistics';
    end 
    h_fig = tablefigure(src,stats.Properties.Description,stats);
end
%%
function [zp,threshold,npeaks,paramEsts,parmci,strend] = get_extremes(ts)    
    %prompt user to to define parameters for selection method, display
    %selection and return extreme return period estimates
    zp = []; paramEsts = []; parmci = []; npeaks = [];
    if isa(ts,'timeseries')
        mdate = datetime(getabstime(ts));
        data = ts.Data;
        varunits = ts.UserData.Units;
        varname = ts.Name;
    elseif isa(ts,'dstable')
        mdate = ts.RowNames;
        data = ts.(ts.VariableNames{1});
        varunits = ts.VariableLabels{1};
        varname = ts.VariableNames{1};
    else
        warndlg('Data format not recognised in getpeaks')
        return;
    end    
    strend = {mdate(1), mdate(end)};
    threshold = mean(data,'omitnan')+2*std(data,'omitnan');

    %plot timeseries and threshold to allow user to adjust
    mdate.Format = 'mmm-yy';       % Set format for display on x-axis.
    figtitle = sprintf('Extremes threshold selection for %s',varname);
    promptxt = 'Accept threshold definition';
    buttxt = {'Yes','No'};
    position = [0.2 0.4 0.5 0.4];
    [h_plt,h_but] = acceptfigure(figtitle,promptxt,'StatFig',buttxt,position);
    axes(h_plt);
    ax1 = subplot(1,2,1);
    plot(mdate,data);
    xlabel('Time');
    hold on 
    plot([strend{:}],[threshold,threshold],'--r','Tag','Threshold');
    hold off   

    %setup plot of mean excees v threshold
    % find peaks (method 1:all peaks; 2:independent crossings; 3:timing
    % seperation of tint) 
    method = 3;
    tint = 18;
    returnflag = 1; %0:returns indices of peaks; 1:returns values
    pks = peaksoverthreshold(data,threshold,method,...
        mdate,hours(tint),returnflag);
    orderpeaks = sort(pks);
    interval = linspace(threshold,orderpeaks(end-2),50);
    for i = 1:length(interval)
        ui(i) = interval(i);
        excesses = pks(pks>interval(i))-interval(i);
        nmExcs(i) = length(excesses);
        mExcs(i) = mean(excesses);                
        %~95% confidence interval
        ciExcs(i) = 1.96*std(excesses)/sqrt(nmExcs(i)); 
    end
    subplot(1,2,2);
    plot(ui,mExcs,'o');
    xlabel('Threshold');
    ylabel('Mean excess above threshold');
    hold on
    plot(ui,mExcs+ciExcs,':');
    plot(ui,mExcs-ciExcs,':');
    yyaxis right
    bar(ui,nmExcs,'EdgeColor',[.9 .9 .9],'FaceColor','none');
    ylabel('Number of peaks');
    hold off

    %gui definition to get input from user (called in ExtrPeaksSelect)
    guinp.prompt = {'Threshold for peaks:','Selection method', ...
              'Time between peaks (hours)'};
    guinp.title = 'Peak Selection';
    guinp.numlines = 1;
    guinp.default = {num2str(threshold),num2str(3),num2str(18)};
    [idpks,threshold] = ExtrPeakSelect(data,mdate,guinp,ax1,h_but);
    if isempty(idpks), return; end % user cancelled
    npeaks = length(idpks);
    
    button = questdlg('Select figure type','Extremes plot',...
        'None','Type 1','Type 2','Type 2');
    switch button
        case 'Type 1'
            fig = 'H';
        case 'Type 2'
            fig = 'C';
        otherwise
            fig = 'N';
    end
    recdur = years(strend{2}-strend{1});
    nrec = length(data);
    varlabel = sprintf('%s (%s)',varname,varunits);
    [zp,paramEsts,parmci] = mgpdfit(data(idpks),threshold,recdur,...
        'NumRec',nrec,'FigType',fig,'VarName',varlabel);
%     figure;
%     time = datetime(getabstime(ts));
%     plot(time(idpks),ts.Data(idpks),'o');
end
%%
function [idpks,threshold] = ExtrPeakSelect(tsData,mdate,guinp,ax1,h_but)
    %control selection of peaks for use in extremes gpd
    %updates plot of peak selection (ax1) residuals plot unchanged
    ok=0; h3=[]; 
    h2 = findobj(ax1,'Tag','Threshold');
    stdat = min(mdate); endat = max(mdate);
%     promptxt = 'Accept threshold definition';
    while ok<1
        useInp = inputdlg(guinp.prompt,guinp.title,...
                            guinp.numlines,guinp.default);
        if isempty(useInp) %user cancelled
            idpks = []; threshold = [];
            return; 
        end 
        threshold = str2double(useInp{1});
        method = str2double(useInp{2});
        tint = str2double(useInp{3});                
        % find peaks (method 1:all peaks; 2:independent crossings; 3:timing
        % seperation of tint)
        returnflag = 0; %0:returns indices of peaks; 1:returns values
        idpks = peaksoverthreshold(tsData,threshold,method,...
            mdate,hours(tint),returnflag);
        if isempty(idpks)
            warndlg('No peaks selected. Try lower threshold');
            pause(3);
        else
            delete(h2)
            delete(h3)
            subplot(ax1);
            hold on
            h2 = plot(ax1,[stdat,endat],[threshold,threshold],'--r');
            h3 = plot(ax1,mdate(idpks),tsData(idpks),'xr');
            hold off              
            waitfor(h_but,'Tag');
            if strcmp(h_but.Tag,'Yes')
                ok=1;
                npeaks = length(idpks);
                panelText(h_but,threshold,npeaks,method,tint);
            else
                guinp.default{1} = num2str(threshold);
                guinp.default{2} = num2str(method);
                guinp.default{3} = num2str(tint);
                h_but.Tag = '';
            end
        end
    end            
end
%%
function panelText(h_but,threshold,npeaks,method,tint)
    %set text to display selected parameters
    hbyn = findobj(h_but,'Tag','YesNo');
    delete(hbyn)
    h_but.Title = 'Selected parameters';
    txt1 = sprintf('Threshold for peaks = %g m',threshold);
    txt2 = sprintf('No. of peaks = %g',npeaks);
    txt3 = sprintf('Selection method = %g',method);
    txt4 = sprintf('Time between peaks = %g hours',tint);
    selparams = sprintf('%s; %s; %s; %s.',txt1,txt2,txt3,txt4);            
    uicontrol('Parent',h_but,'Tag','YesNo',...
              'Style', 'text', 'String', selparams,...
              'Units','normalized', ...
              'Position', [0.01 0.01 0.99 0.8]); 
end