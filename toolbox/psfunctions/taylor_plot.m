function ax = taylor_plot(refvar,testvar,metatxt,option,rLim,skill)
%
%-------function help------------------------------------------------------
% NAME
%   taylor_plot.m
% PURPOSE
%   Create plot of Taylor diagram and, optionally, plot compute skill score
%   and plot a skill map (2 or 3D depending on data)
% USAGE
%   ax = taylor_plot(refvar,testvar,metatxt,option,rLim,skill);
% INPUTS
%   refvar  - reference dataset or a time series (timeseries or dstable)
%   testvar - test dataset or a time series (timeseries or dstable)
%   metatxt - cell array for data set and variable descriptions of the 
%             reference and test data (order is {reference, test})
%   option  - character vector to set New, Add, Delete; 
%   rLim    - radial limit (e.g. rLim=2)
%   skill   - structure with:
%             inc - flag to include skill score + parameters if true
%             Ro - Reference correlation, 
%             n - Exponent, 
%             W - number of points to sub-sample over: +/-W (-)
%             iter - flag to define iteration as
%                    true - iterates over every grid cell i=1:m-2W
%                    false - avoids overlaps and iterates over i=1:2W:m-2W
%             SD   - subdomain in which to define average local skill 
%                    uses a polyshape defined by:
%                    ([ix0,ix0,ixN,ixN],[iy0,iyN,iy0,iyN])  
% OUTPUT
%   ax - axes to plot of Taylor diagram
% NOTES
%   Taylor, K, 2001, Summarizing multiple aspects of model performance 
%   in a single diagram, JGR-Atmospheres, V106, D7. 
%   Bosboom J and Reniers A J H M, 2014, Displacement-based error metrics 
%   for morphodynamic models. Advances in Geosciences, 39, 37-43, 10.5194/adgeo-39-37-2014.
%   Bosboom J, Reniers A J H M and Luijendijk A P, 2014, On the perception 
%   of morphodynamic model skill. Coastal Engineering, 94, 112-125, 
%   https://doi.org/10.1016/j.coastaleng.2014.08.008.
% SEE ALSO
%   Function getTaylorStats in DataStats.m and getTaylorPlot.m used in
%   ModelSkill
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%--------------------------------------------------------------------------
%
    if isa(refvar,'timeseries') || istimeseriesdst(refvar)
        %sort data type and interpolate if vars are timeseries datasets
        [refvar,testvar,ok] = sortTSdata(refvar,testvar);
        if ok<1, ax = []; return; end   %user cancelled or wrong data type
        cfstats = TS_DifferenceStatistics(refvar,testvar);
    else
        cfstats = DS_DifferenceStatistics(refvar,testvar);
    end
    %get skill score if required
    if skill.Inc
        skill = getSkillScores(skill,cfstats,refvar,testvar,metatxt);
    else
        skill.global = [];
    end
    
    %generate base figure
    if strcmp(option,'New')
        ax = taylor_plot_figure(rLim);
    end

    plotTaylor(metatxt,cfstats,option,skill);                                                    
end
%%
function [refvar,testvar,ok] = sortTSdata(ts1,ts2)
    %sort data type and interpolate if vars are timeseries datasets
    ok = 1;
    if isa(ts1,'timeseries')
        refvar = ts1; testvar = ts2; 
        if length(ts1.Data(~isnan(ts1.Data)))~=length(ts2.Data(~isnan(ts2.Data)))
            answer = questdlg('Need to interpolate. Select which time series to interpolate:',...
                'Taylor plot','Test','Reference','Quit','Test');
            switch answer
                case 'Reference'
                    refvar =  resample(ts1,getabstime(ts2));
                    testvar = ts2;
                case 'Test'
                    refvar = ts1;
                    testvar =  resample(ts2,getabstime(ts1));
                case 'Quit'
                    ok = 0;
                    return;
            end
        end    
    elseif isa(ts1,'dstable')
        ts1.DataTable = rmmissing(ts1.DataTable);         
        ts2.DataTable = rmmissing(ts2.DataTable);       
        if height(ts1)~=height(ts2)
            answer = questdlg('Need to interpolate. Select which time series to interpolate:',...
                'Taylor plot','Test','Reference','Quit','Test');
            switch answer
                case 'Reference'
                    time = ts2.RowNames;
                    ts1data = ts1.(ts1.VariableNames{1});  
                    refvar.Data = interp1(ts1.RowNames,ts1data,time,'linear');
                    testvar.Data = ts2.(ts2.VariableNames{1});
                case 'Test'
                    time = ts1.RowNames;
                    refvar.Data = ts1.(ts1.VariableNames{1}); 
                    ts2data = ts2.(ts2.VariableNames{1});
                    testvar.Data = interp1(ts2.RowNames,ts2data,time,'linear');
                case 'Quit'
                    ok = 0;
                    return;
            end 
            refvar.time = time;
        else
            refvar.Data = ts1.(ts1.VariableNames{1}); 
            refvar.time = ts1.RowNames;
            testvar.Data = ts2.(ts2.VariableNames{1});            
        end
    else
        warndlg('Data format not recognised in taylor_plot')
        ok = 0;
        return;
    end    
end
%%
function cfstats = TS_DifferenceStatistics(ts1,ts2)
    %compute difference statisics for two time series and plot
    %results on a Taylor diagram
    % ts1 is the reference timeseries and ts2 is the test timeseries
    % cfstats - descriptive statistics for both data sets
    % timeseries must be for the sameperiod and have the same number
    % of data points
    cfstats.refstd = std(ts1.Data,'omitnan');
    cfstats.teststd = std(ts2.Data,'omitnan');
    cfstats.refmean = mean(ts1.Data,'omitnan');            
    cfstats.testmean = mean(ts2.Data,'omitnan');
    cfstats.corrcoef = corrcoef(ts1.Data,ts2.Data,'rows','complete');
    cfstats.crmsd = centredRMSD(ts1.Data,ts2.Data,cfstats);
end   
%%
function cRMSD = centredRMSD(ds1,ds2,cfstats)
    %compute centred root mean square difference 
    %ds1 is the reference data set and ds2 is the test data set
%     refmean = mean(ds1,'omitnan');
%     testmean = mean(ds2,'omitnan');
%     cSD = ((ds2-testmean)-(ds1-refmean)).^2;
    cSD = ((ds2-cfstats.testmean)-(ds1-cfstats.refmean)).^2;
    cSD = cSD(~isnan(cSD));
    nrec = length(cSD);
    cMSD = sum(cSD)/nrec;
    cRMSD = sqrt(cMSD);
end
%%
function cfstats = DS_DifferenceStatistics(ds1,ds2)
    %compute the difference between two vectors or arrays of the same size
    if isa(ds1,'dstable')
        ds1 = ds1.DataTable{:,1};
        ds2 = ds2.DataTable{:,1};
    end
    if numel(ds1)~=numel(ds2)
        warndlg('Data sets must be of the same size');
        cfstats = [];
        return
    end
    mver = version('-release'); 
    if str2double(mver(1:4))<2018 || strcmp(mver,'2018a')
        if isvector(ds1)
        cfstats.refstd = std(ds1,0,1,'omitnan'); 
        cfstats.teststd = std(ds2,0,1','omitnan');
        cfstats.refmean = mean(ds1,1,'omitnan');            
        cfstats.testmean = mean(ds2,1,'omitnan');             
        else
        cfstats.refstd = std(std(ds1,0,1,'omitnan'),0,2,'omitnan'); 
        cfstats.teststd = std(std(ds2,0,1','omitnan'),0,2,'omitnan');
        cfstats.refmean = mean(mean(ds1,1,'omitnan'),2,'omitnan');            
        cfstats.testmean = mean(mean(ds2,1,'omitnan'),2,'omitnan');  
        end
    else
        cfstats.refstd = std(ds1,0,'All','omitnan'); %requires R2018b or later
        cfstats.teststd = std(ds2,0,'All','omitnan');
        cfstats.refmean = mean(ds1,'All','omitnan');            
        cfstats.testmean = mean(ds2,'All','omitnan');        
    end
    cfstats.corrcoef = corrcoef(ds1,ds2,'rows','complete');
    cfstats.crmsd = centredRMSD(ds1,ds2,cfstats);
end
%%
function plotTaylor(metatxt,cfstats,option,skill)
    %generate the plot by adding or deleting points
    % metatxt - cell array for data set and variable descriptions of the 
    %          reference and test data (order is {reference, test})
    % cfstats - descriptive statistics for both data sets
    % option - New, Add, Delete; 
    % skill - struct which includes global and local skill estimates

    %unpack and normalize data to be plotted
    ndteststd = cfstats.teststd/cfstats.refstd; %normalised std
    ndcrmsd = cfstats.crmsd/cfstats.refstd;     %normalised centred root mean square differences
    acoscor = asin(cfstats.corrcoef(1,2));      %acos for trig angles, asin for compass angles
    bias = cfstats.testmean-cfstats.refmean;
    corr = cfstats.corrcoef(1,2);
    %check statistcs
    %RMSD-sqrt(testSTD^2+refSTD^2-2*testSTD*refSTD*COR)=0 (NB:refSTD=1)
    check = (ndcrmsd-sqrt(ndteststd^2+1-...
                    2*ndteststd*cfstats.corrcoef(1,2)));
    if check>0.1
        warndlg('Statistics do not agree. Error in plotTaylor');
        return;
    end           
    % find figure and get current axes
    fig = findobj('Name','Taylor Diagram');
    figax = fig.CurrentAxes;
    if figax.RLim(2)<ndteststd
        figax.RLim(2) = ceil(ndteststd);
    end
    symb = 'o';
    restxt = sprintf('corr= %.3f; ndstd= %.3f for %s',corr,ndteststd,metatxt{2});     
    if ~isempty(skill.global)  
        if skill.iter
            itxt = 'for all cells';
        else
            itxt = 'with no overlaps';
        end
        usertst = sprintf('%s with skill S.G= %1.3g, S.L= %1.3g. (Ro= %1.2g, n= %1.1g, W= %d, %s)',...
                 restxt,skill.global,skill.local,skill.Ro,skill.n,skill.W,itxt);
    else
        usertst = restxt;
    end
    
    hold(figax,'on')
    %new plot or add/delete a line
    switch option
        case 'New'                    
            useref = metatxt{1};  
            polarplot(figax,pi/2,1,'+','LineWidth',2.0,...
            'DisplayName','Reference','Tag','0','UserData',useref);
            %[polarscatter requires 2016b or later 
            % to use replace polarplot calls with polarscatter and 
            % findobj(figax,'Type','Line') to  findobj(figax,'Type','Scatter');
            % in all case calls and uiCaseList]

            %plot first test case
            legtext = sprintf('cf #1: B=%.3f; E"=%.3f',bias,ndcrmsd);                                            
            polarplot(figax,acoscor,ndteststd,...
              symb,'LineWidth',1.5,'DisplayName',legtext,...
              'Tag','1','UserData',usertst);
            h1 = legend(figax,'show','Location','northeastoutside');
            h1.Title.String = 'B=Bias; E''''=normalised-centred RMS error';
            h1.Title.FontWeight = 'normal';
            h1.Tag = 'Taylor';
        case 'Add'
            hp = findobj(figax,'Type','Line');
            idx = length(hp)+1;
            hpoints = findobj(figax,'Type','Line','Marker',symb);
            idcase = length(hpoints)+1;

            %plot test case
            legtext = sprintf('cf #%d: B=%.3f; E"=%.3f',...
                                            idcase,bias,ndcrmsd);  
            hp(idx) = polarplot(figax,acoscor,ndteststd,...
              symb,'LineWidth',1.5,'DisplayName',legtext,...
              'Tag',num2str(idcase),'UserData',usertst);
            hp = sortplots(hp);
            hp = suppressGridLines(hp);
            h1 = legend(figax,hp,'Location','northeastoutside');
            h1.Tag = 'Taylor';
        case 'Delete'
            figpts = findobj(figax,'Type','Line','Marker',symb);
            figleg = findobj('Type','legend','Tag','Taylor');
            idx = [];
            
            for ii=1:length(figpts)
                plotval = [figpts(ii).ThetaData,figpts(ii).RData];
                delval  = [acoscor,ndteststd];
                if isequaln(plotval,delval) && any(strcmp(figleg.String,figpts(ii).DisplayName))
                    idx = [idx,ii];                             %#ok<AGROW>
                end                       
            end
            
            if ~isempty(idx)
                delete(figpts(idx));
                figpts(idx) = [];
                if isempty(figpts)
                    delete(figleg)
                else
                    figpts = sortplots(figpts);
                    hl = legend(figax,figpts,'Location','northeastoutside');
                    hl.Tag = 'Taylor';
                end
            end
    end
    hold(figax,'off')  
    %
    function newhp = suppressGridLines(hp)
        %re-impose suppression of grid lines in the Taylor diagram plot
        hgrd = findobj(hp,'Tag','RMSgrid'); 
        hp = findobj(hp,'-not','Tag','RMSgrid'); 
        newhp = vertcat(hp,hgrd(1));
    end    
end
%%
function score = getSkill(skill,cfstats)
    %get the skill score as defined in Taylor, K. E. (2001). 
    %"Summarizing multiple aspects of model performance in a single diagram." 
    %Journal of Geophysical Research - Atmospheres 106(D7): 7183-7192.
    %Eq(4)
    Ro = skill.Ro;
    n = skill.n;
    sigobs = cfstats.teststd/cfstats.refstd;
    R = cfstats.corrcoef(1,2);
    score = 4*(1+R)^n/((sigobs+1/sigobs)^2*(1+Ro)^n);   
end
%%
function skill = getSkillScores(skill,cfstats,refvar,testvar,metatxt)
    %get the global and local skill scores using the approach of Taylor,
    %2001 and the local weighting procedure of Bosboom, 2014 (if defined)
    skill.global = getSkill(skill,cfstats);
    W = skill.W;
    if W>0
        skill.local = getLocalSkill(skill,refvar,testvar,metatxt);
    else
        skill.local = [];
    end
end
%%
function score = getLocalSkill(skill,refvar,testvar,metatxt)
    %iterate over data set based on interval W defined in skill struct
    %iter =  true iterates for i=1:m-2W,
    %iter = false avoids overlaps and iterates over i=1:2W:m--2W
     ists = false;
     tt = [];
    if isa(refvar,'timeseries') || isfield(refvar,'time')
        ists = true;
        if isa(refvar,'timeseries')
            tt = datetme(getabstime(refvar));
        else
            tt = refvar.time;
        end
        refvar = refvar.Data;        
        testvar = testvar.Data;
    elseif isa(refvar,'dstable')
        refvar = squeeze(refvar.DataTable{:,1});
        testvar = squeeze(testvar.DataTable{:,1});
    end

    W = skill.W;
    [m,n] = size(refvar);
    %set up sampling index to either examine a window at every point or a
    %set of windows that do not overlap
    if skill.iter %true iterates over every point, i=1:m-2W
        indx = 1:m-2*W;
        indy = 1:n-2*W;
    else         %false avoids overlaps and iterates over i=1:2W:m-2W
        indx = 1:2*W:m-2*W;
        indy = 1:2*W:n-2*W;
    end
    
    %generate title
    titletxt = sprintf('Reference: %s\nTest: %s',metatxt{1},metatxt{2});
    
    %check whether data is a vector or matrix and iterate over dimensions  
    ni = 1; nj = 1; 
    if n==1    %data is a column vector
        ss = zeros(length(indx),1);
        ts(length(indx),1) = datetime(1,1,1);
        ni = 1;
        for i=indx
            subref.Data = refvar(i:i+2*W,1);
            subtest.Data = testvar(i:i+2*W,1);
            cfstats = getDifferenceStats(subref,subtest,ists);
            ss(ni) = getSkill(skill,cfstats);            
            if ~isempty(tt)
                ts(ni) = tt(i);
            end
            ni = ni+1;
        end
        if isempty(tt)
            ts = 1:ni-1;
        end
        plotSkillGraph(ts,ss,titletxt)
    else       %data is a 2-D array
        ss = zeros(length(indx),length(indy));
        for i=indx
            for j=indy
                subref = refvar(i:i+2*W,j:j+2*W);
                subtest = testvar(i:i+2*W,j:j+2*W);
                cfstats = getDifferenceStats(subref,subtest,ists);
                ss(ni,nj) = getSkill(skill,cfstats);
                nj = nj+1;
            end
            nj = 1;
            ni = ni+1;
        end
        [ms,ns] = size(ss);
        xr = m/ms; yr = n/ns; %ratios to rescale indices based on
        %window used for local skill
        skill.SD.x = round(skill.SD.x/xr);
        skill.SD.y = round(skill.SD.y/yr);
        plotSkillMap(ss,skill,titletxt);
    end  
    %apply subdomain mask
    if ~isempty(skill.SD)   
        [X,Y] = meshgrid(1:size(ss,1),1:size(ss,2));
        in = inpolygon(X,Y,round(skill.SD.x),round(skill.SD.y));
        ss(~in') = NaN;
    end
    %subdomain average ('All' only implemented for >2018a)
    mver = version('-release'); 
    if str2double(mver(1:4))<2018 || strcmp(mver,'2018a')
        if isvector(ss)
            score = mean(ss,1,'omitnan');
        else
            score = mean(mean(ss,1,'omitnan'),2,'omitnan');
        end
    else        
        score = mean(ss,'All','omitnan');
    end
end
%%
function cfstats = getDifferenceStats(refvar,testvar,ists)
    if ists
        cfstats = TS_DifferenceStatistics(refvar,testvar);
    else
        cfstats = DS_DifferenceStatistics(refvar,testvar);
    end
end

%%
function plotSkillMap(ss,skill,titletxt)
    %plot a figure showing the local skill scores as a map
    h_fig = figure('Name','Skill Map', ...
        'Units','normalized','HandleVisibility','on', ...
        'Resize','on','Tag','StatFig');        
    ax = axes('Parent',h_fig,'Tag','SkillMap');    
    contourf(ax,ss');
    c = colorbar;
    c.Label.String = 'Local Skill Score';
    if ~isempty(skill.SD)
        hold on
            pgon = polyshape(skill.SD.x,skill.SD.y);
            plot(pgon,'LineStyle','--','EdgeColor','r','FaceColor','none');
        hold off
    end
    xlabel('Length intervals'); 
    ylabel('Width intervals'); 
    title(titletxt)
end
%%
function plotSkillGraph(tt,ss,titletxt)
    %plot a figure showing the local skill scores as a graph
    h_fig = figure('Name','Skill Graph', ...
        'Units','normalized','HandleVisibility','on', ...
        'Resize','on','Tag','StatFig');        
    ax = axes('Parent',h_fig,'Tag','SkillGraph');    
    plot(ax,tt,ss);
    xlabel('Intervals'); 
    ylabel('Local Skill Score'); 
    title(titletxt)
end