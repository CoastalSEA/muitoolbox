function poisson_stats(ts,metatxt)
%
%-------function help------------------------------------------------------
% NAME
%   poisson_stats.m
% PURPOSE
%   Compute the inter-arrival time, magnitude and duration of
%   events assuming that they are a Poisson process
%   fitting an exponential pdf and plotting 
% USAGE
%   poisson_stats(ts,metatxt)
% INPUTS
%   ts - timeseries or dstable dataset
%   metatxt - description of case and variable selected
% OUTPUT
%   Plot of Poisson inter-arrival time, magnitude and duration with fit
%   parameters included in the plot title
% NOTES
%   makes use of fitdist and pdf in Statistical and Machine Learning Toolbox
% SEE ALSO
%   zero_crossing.m, getpeaks.m, 
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%--------------------------------------------------------------------------
%
%     if contains(ts.Name,'Peaks')
%         warndlg('Place holder - code not written yet')
%         return;
%         %recover options
%     else
%         
%     end
    [idpks,options] = getpeaks(ts);
    if isempty(idpks), return; end
    
    if isa(ts,'timeseries')
        mdate = datetime(getabstime(ts));
        data = ts.Data;
        labeltxt = ts.UserData.Labels;
        unitstxt = ts.DataInfo.Units;
    elseif isa(ts,'dstable')
        mdate = ts.RowNames;
        data = ts.(ts.VariableNames{1});
        labeltxt = ts.VariableLabels{1};
        unitstxt = ts.VariableUnits{1};
    else
        warndlg('Data format not recognised in poisson_stats')
        return;
    end
    
    [upid,downid] = zero_crossing(data,options.threshold);
    thr = options.threshold;

    pkdate = mdate(idpks);
    update = mdate(upid);
    dndate = mdate(downid);
    pksize = sort(data(idpks))-thr;            

    pkdiff = sort(days(diff(pkdate)));
    if update(1)<dndate(1)
        pkdura = sort(hours(dndate-update));
    else
        pkdura = sort(hours(update-dndate));
    end
    nrec = length(pksize);
    nbins =floor(nrec/2);
%             if nrec>30
%                 nbins = 20;
%             else
%                 nbins = 10;
%             end
    pkszefit = fitExp(pksize,nbins);
    pkintfit = fitExp(pkdiff,nbins);     
    pkdurfit = fitExp(pkdura,nbins);

    hf = figure('Name','Poisson Plot','Tag','StatFig');
    subplot(3,1,1)
    ttxt = sprintf('Peaks over threshold of %1.3g',thr);
    xtxt = sprintf('%s (%s)',labeltxt,unitstxt);
    plotPoisson(pksize,pkszefit,thr,nbins,ttxt,xtxt);
    subplot(3,1,2)
    ttxt = 'Interval between peaks';
    xtxt = 'Time (days)';
    plotPoisson(pkdiff,pkintfit,0,nbins,ttxt,xtxt);
    subplot(3,1,3)
    ttxt = 'Peak duration above threshold';
    xtxt = 'Time (hours)';
    plotPoisson(pkdura,pkdurfit,0,nbins,ttxt,xtxt);
    fittedtitle(hf,metatxt,true,0.68);
end
%%
function fit = fitExp(var,nbins)
    %use the Statistic Tool box function to get exponential fit
    pdf_name = 'Exponential';
    fit.pv = 0:max(var)/nbins:max(var);
    fit.obj = fitdist(var,pdf_name);
    fit.pdf = pdf(fit.obj,fit.pv); 
end
%%
function plotPoisson(data,datafit,threshold,nbins,ttxt,xtxt)
    %plot for exponential fit of 'data' using data held in structure
    %datafit which contains the fitdist object and the pdf
    norm_type = 'pdf';
    histogram(data+threshold,nbins,'Normalization',norm_type);
    title(sprintf('%s: mu=%0.3g, variance=%0.3g',...
                ttxt,datafit.obj.mu,var(datafit.obj)))
    xlabel(xtxt)
    ylabel('Probability')
    hold on
    plot(datafit.pv+threshold,datafit.pdf,'--r');
    xscale = datafit.pv+threshold;
    xlim(gca,[min(xscale),max(xscale)]);
    hold off    
end