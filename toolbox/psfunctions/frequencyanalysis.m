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
    res = 'no output'; %null ouput required for exit in muiUserModel.setEqnData
    ok = 1;
    while ok>0
        z0 = [];
        %allow user to generate various plots
        plotlist = {'Time series plot of variable',...
                    'Time series plot of variable above/below threshold',...
                    'Plot variable frequency',...
                    'Plot variable frequency above/below threshold',...
                    'Spectral analysis plot',...
                    'Duration of threshold exceedance',...
                    'Rolling mean duration above/below a threshold'};
        [idx,ok] = listdlg('Name','Plot options', ...
            'PromptString','Select a plot:', ...
            'SelectionMode','single', ...
            'ListSize',[300,150],...
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
                prompt = {'Threshold value:','Above (1), Below (0)'};
                dlgtitle = 'Define threshold';
                numlines = 1;
                defaultvalues = {'0','1'};
                useInp=inputdlg(prompt,dlgtitle,numlines,defaultvalues);
                if isempty(useInp), return; end %user cancelled
                z0 = str2double(useInp{1});
                isabove = logical(str2double(useInp{2}));

                thrvar = var;  %apply threshold
                if isabove
                    thrvar(var<=z0) = NaN;
                else
                    thrvar(var>z0) = NaN;
                end

                switch plotlist{idx}
                    case 'Time series plot of variable above/below threshold'                    
                        var_ts_exceed_thr(thrvar,t,z0,vartxt,isabove);
                    case 'Plot variable frequency above/below threshold'
                        var_freq_plot(thrvar,z0,vartxt,isabove);
                    case 'Duration of threshold exceedance'   
                        thr_durations(var,t,z0,false,isabove);
                    case 'Rolling mean duration above/below a threshold'
                        thr_durations(var,t,z0,true,isabove);
                end
        end
    end
end
%%
function var_ts_exceed_thr(var,t,z0,vartxt,isabove)
    %Plot time series of variable above a threshold if specified
    figure('Name','Elevation exceedance','Units','normalized',...                
           'Resize','on','HandleVisibility','on','Tag','PlotFig');
    plot(t,var);
    if isempty(z0)
        title(sprintf('Full time series for %s',vartxt))
    else
        if isabove
            title(sprintf('%s above %.3g threshold',vartxt,z0))
        else
            title(sprintf('%s below %.3g threshold',vartxt,z0))
        end
    end
    ylabel(vartxt)
    xlabel('Time')
end
%%
function var_freq_plot(var,z0,vartxt,isabove)
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
        if isabove
            title(sprintf('Frequency of occurrence above %.3g threshold',z0))
        else
            title(sprintf('Frequency of occurrence below %.3g threshold',z0))
        end
    end
    ylabel(vartxt)
    xlabel('Probability of occurrence (%)')   
end
%%
function var_spectrum(var,t,vartxt)
    %Plot a spectrum based on an fft analysis of the timeseries
    %code to compute the fft of the water level signal (based on Matlab fft Help)
    var(isnan(var)) = [];  %remove Nans
    Y = fft(var);
    Ts = seconds(mean(diff(t)));  %sampling period (returns a double)
    Fs = 1/Ts;                    %sampling frequency in Hz
    L = length(var);              %signal length
    P2 = abs(Y/L);                %double sided spectrum
    P1 = P2(1:floor(L/2)+1);     
    P1(2:end-1) = 2*P1(2:end-1);  %single sided spectrum 
    f = Fs.*(0:floor(L/2))/L;     %frequency values
    figure('Name','Variable spectrum','Units','normalized',...                
           'Resize','on','HandleVisibility','on','Tag','PlotFig'); 
    plot(f,P1)
    title(sprintf('Single-Sided Amplitude Spectrum of %s',vartxt))
    xlabel('f (Hz)')
    ylabel('|P1(f)|')     
end
%%
function thr_durations(var,t,z0,ismoving,isabove)
    %Plot - 'Duration of threshold exceedance' 
    [stid,edid] = zero_crossing(var,z0);
    if isempty(stid)
        hw = warndlg('No exceedances found'); 
        waitfor(hw);
        return; 
    end
    %
    if ~isabove
        temp = stid;
        stid = edid;
        edid  = temp;
    end

    if stid(1)>edid(1)   %correct order for exceedances above threshold
        stid = stid(1:end-1);
        edid = edid(2:end);
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
        xlabel('Time')

        reclen = t(end)-t(1);
        pcntexcdur = sum(vardur)/hours(reclen)*100;
        numexc = mean(length(stid),length(edid));
        aveannumexc = numexc/years(reclen);
        if isabove
            ylabel('Mean annual duration of exceedances (hours)')
            title(sprintf('Rolling mean above %.3g threshold',z0))
            msg1 = sprintf('Percentage time above threshold in %.3g years = %.3g%%',years(reclen),pcntexcdur);
            msg2 = sprintf('Average annual number of events above threshold = %.3g',aveannumexc);
        else
            ylabel('Mean annual duration of non-exceedances (hours)')
            title(sprintf('Rolling mean below %.3g threshold',z0))
            msg1 = sprintf('Percentage time below threshold in %.3g years = %.3g%%',years(reclen),pcntexcdur);
            msg2 = sprintf('Average annual number of events below threshold = %.3g',aveannumexc);
        end
        msgtxt = sprintf('%s\n%s',msg1,msg2);
        hm = msgbox(msgtxt,'Mean duration results');
        waitfor(hm)
    else 
        sledges = min(vardur):(max(vardur)-min(vardur))/10:max(vardur);
        histogram(vardur,sledges,'Normalization', 'probability');
        if isabove
            title(sprintf('Duration above %.3g threshold',z0))
        else
            title(sprintf('Duration below %.3g threshold',z0))
        end
        ylabel('Probability of occurrence (%)')
        xlabel('Duration (hours)')
    end
end
