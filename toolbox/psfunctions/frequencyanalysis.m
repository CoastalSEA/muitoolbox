function res = frequencyanalysis(var,t,vartxt)
%
%-------function help------------------------------------------------------
% NAME
%   frequencyanalysis.m
% PURPOSE
%   generate a range of plots of frequency, probability of exceedance and
%   duration of exceedance for a timeseries of data
% USAGE
%   res = frequencyanalysis(var,t,vartxt)
% INPUTS
%   var - timeseries variable
%   t - time
%   vartxt - text to use to describe the variable (optional)
% OUTPUT
%   res - dummy text so that function can be called from Derive Output UI
%
% Author: Ian Townend
% CoastalSEA (c)June 2021
%--------------------------------------------------------------------------
%
    if nargin<3
        vartxt  = 'Variable';
    end
    res = {'Plots completed'}; %cell ouput required by call from DataManip.createVar   
    ok = 1;
    while ok>0
        z0 = [];
        %allow user to generate various plots
        plotlist = {'Time series plot of variable',...
                    'Time series plot of variable above threshold',...
                    'Plot variable frequency',...
                    'Plot variable frequency above threshold',...
                    'Spectral analysis plot',...
                    'Duration of threshold exceedance',...
                    'Rolling mean duration above a threshold'};
        [idx,ok] = listdlg('Name','Plot options', ...
            'PromptString','Select a plot:', ...
            'SelectionMode','single', ...
            'ListSize',[250,150],...
            'ListString',plotlist);
        if ok<1, return; end

        switch plotlist{idx}
            case 'Time series plot of variable'
                var_ts_exceed_thr(var,t,z0,vartxt);
            case 'Plot variable frequency'
                var_freq_plot(var,z0,vartxt);
            case 'Spectral analysis plot'
                var_spectrum(var,t,vartxt)       
            otherwise            
                %get threshold elevation from user
                prompt = {'Threshold elevation (mOD):'};
                dlgtitle = 'Define elevation (mOD)';
                numlines = 1;
                defaultvalues{1} = num2str(0);
                useInp=inputdlg(prompt,dlgtitle,numlines,defaultvalues);
                if isempty(useInp), return; end %user cancelled
                z0 = str2double(useInp{1});
                thrvar = var;

                switch plotlist{idx}
                    case 'Time series plot of variable above threshold'
                        thrvar(var<=z0) = NaN;
                        var_ts_exceed_thr(thrvar,t,z0,vartxt);
                    case 'Plot variable frequency above threshold'
                        thrvar(var<=z0) = NaN;
                        var_freq_plot(thrvar,z0,vartxt);
                    case 'Duration of threshold exceedance'   
                        thr_durations(var,t,z0,false);
                    case 'Rolling mean duration above a threshold'
                        thr_durations(var,t,z0,true);
                end
        end
    end
end
%%
function var_ts_exceed_thr(var,t,z0,vartxt)
    %Plot time series of variable above a threshold if specified
    figure('Name','Elevation exceedance','Units','normalized',...                
           'Resize','on','HandleVisibility','on','Tag','PlotFig'); 
    plot(t,var);
    title(sprintf('Elevations above %.3g (mOD) threshold',z0))
    ylabel(vartxt)
    xlabel('Time')
end
%%
function var_freq_plot(var,z0,vartxt)
    %plot the frequency of occurence of a variable
    minwl = min(var,[],1,'omitnan');
    maxwl = max(var,[],1,'omitnan');
    zedges = floor(minwl):0.1:ceil(maxwl);
    fc = histcounts(var,zedges,'Normalization', 'probability');
    z = zedges(1)+0.05:0.1:zedges(end)-0.05;
    figure('Name','Elevation frequency','Units','normalized',...                
           'Resize','on','HandleVisibility','on','Tag','PlotFig');            
    barh(z,fc*100);
    if isempty(z0)
        title('Frequency of occurrence')
    else
        title(sprintf('Frequency of occurrence above %.3g threshold',z0))
    end
    ylabel(vartxt)
    xlabel('Probability of occurrence (%)')   
end
%%
function var_spectrum(var,t,vartxt)
    %Plot a spectrum based on an fft analysis of the timeseries
    %code to compute the fft of the water level signal (based on Matlab Help)
    var(isnan(var)) = [];  %remove Nans
    Y= fft(var);
    Ts = seconds(mean(diff(datenum(t))));
    Fs = seconds(1)/Ts;
    L = length(var);
    P2 = abs(Y/L);
    P1 = P2(1:floor(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = 1/Fs/24.*(0:floor(L/2))/L;
    figure('Name','Variable spectrum','Units','normalized',...                
           'Resize','on','HandleVisibility','on','Tag','PlotFig'); 
    plot(f,P1)
    title(sprintf('Single-Sided Amplitude Spectrum of %s',vartxt))
    xlabel('f (Hz)')
    ylabel('|P1(f)|')     
end
%%
function thr_durations(var,t,z0,ismoving)
    %Plot - 'Duration of threshold exceedance' 
    [stid,edid] = zero_crossing(var,z0);
    if isempty(stid)
        hw = warndlg('No exceedances found'); 
        waitfor(hw);
        return; 
    end
    %
    if stid(1)>edid(1)
        temp = stid;
        stid = edid;
        edid  = temp;
    end
    vardur = t(edid)-t(stid);
    vardur.Format = 'h';
    figure('Name','Duration exceedance','Units','normalized',...                
           'Resize','on','HandleVisibility','on','Tag','PlotFig'); 
    if ismoving
        vardur = hours(vardur);
        tper = years(1);  %set to annual but movingtime allows this to be changed!
        [tm,vm] = movingtime(vardur,t(stid),tper,tper,'mean');
        plot(tm,vm);
        title(sprintf('Rolling mean above %.3g (mOD) threshold',z0))
        ylabel('Mean annual duration of exceedances (hours)')
        xlabel('Time')
        reclen = t(end)-t(1);
        pcntexcdur = sum(vardur)/hours(reclen)*100;
        numexc = mean(length(stid),length(edid));
        aveannumexc = numexc/years(reclen);
        msg1 = sprintf('Percentage time duration exceeded in %.3g years = %.3g%%',years(reclen),pcntexcdur);
        msg2 = sprintf('Average annual number of threshold exceedances = %.3g',aveannumexc);
        msgtxt = sprintf('%s\n%s',msg1,msg2);
        hm = msgbox(msgtxt,'Mean duration results');
        waitfor(hm)
    else 
        sledges = min(vardur):(max(vardur)-min(vardur))/10:max(vardur);
        histogram(vardur,sledges,'Normalization', 'probability');
        title(sprintf('Duration of %.3g (mOD) threshold exceedance',z0))
        ylabel('Probability of occurrence (%)')
        xlabel('Duration (hours)')
    end
end
