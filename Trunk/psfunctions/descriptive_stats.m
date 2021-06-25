function [stats,h_fig] = descriptive_stats(data,metatxt,src)
%
%-------function help------------------------------------------------------
% NAME
%   descriptive_stats.m
% PURPOSE
%   generate descriptive stats table for timeseries or table of a variable
% USAGE
%   stats = descriptive_stats(mobj,data,metatxt,src)
% INPUTS
%   data - timeseries of variable or table of variable
%   metatxt - text describing user selection 
%   src - handle to tab for results display (empty if stand-alone figure)
% OUTPUT
%   stats - summary table or results
%   h_fig - handle to figure (or tab if src used)
%
% Author: Ian Townend
% CoastalSEA (c)June 2019
%--------------------------------------------------------------------------
%
    if isa(data,'dstable')
        stats = getTSstats(data,metatxt);        
    else
        stats = getDSstats(data,metatxt);
    end
    if isempty(stats), return; end
    
%     SummaryTable(mobj,stats,'StatTable',src)
    if isempty(src)
        src = 'General statistics';
    end 
    h_fig = tablefigure(src,metatxt,stats);
end
%%
function stats = getTSstats(data,metatxt)
    %compute descriptive statistics (mean,std,etc) for selected
    %timeseries variable
    stats = []; 
    cthr = getSeasonUI();
    if isempty(cthr), return; end %user cancelled
    if isempty(cthr{1}) || isempty(cthr{2}) %check for valid entry
        warntxt = sprintf('Invalid data entry:\nEnter 0 and 1 for basic stats');
        warndlg(warntxt);
        return; 
    end
    
    dst = data.DataTable;
    ts = timeseries(dst{:,1},dst.Properties.RowNames);
    
    %get statistics for time series as a whole
    stats = time_stats(ts,cthr);
    stats.Properties.Description = metatxt;
    %get statistics for seasons if defined
    seasons = eval(cthr{2});
%     stats.Properties.UserData  = cellstr(num2str(seasons));
    if length(seasons)>1   
        seastr = cellstr(num2str(seasons));
        seastxt = 'Seasons:';
        stats = season_stats(ts,cthr,stats,seasons);
        varnames = stats.Properties.VariableNames;
        for i=2:length(varnames)
            seastxt = sprintf('%s %s - %s',seastxt,varnames{i},seastr{i-1});
        end
        stats.Properties.Description = sprintf('%s\n%s',metatxt,seastxt);
    end 
end
%%
function cthr = getSeasonUI()
    %    
    figtitle = 'Seasonal Definitions';
    varnames = {'Seasons','Syntax'};
    rownames = [];
    values = {'J-F-M, A-M-J, J-A-S, O-N-D','[1,2,3; 4,5,6; 7,8,9; 10,11,12]';...
              'D-J-F, M-A-M, J-J-A, S-O-N','[12,1,2; 3,4,5; 6,7,8; 9,10,11]';...
              'F-M-A, M-J-J, A-S-O, N-D-J','[2,3,4; 5,6,7; 8,9,10; 11,12,1]';...
              'J-F-M-A, M-J-J-A, S-O-N-D','[1,2,3,4; 5,6,7,8; 9,10,11,12]';...
              'J-F-M-A-M-J; J-A-S-O-N-D','[1,2,3,4,5,6; 7,8,9,10,11,12]';...
              'A-M-J-J-A-S, O-N-D-J-F-M','[4,5,6,7,8,9; 10,11,12,1,2,3]';...
              'Monthly', '[1:1:12].''';...
              'Annual','1'};
            
    h_fig = tablefigure(figtitle,'Select seasonal definition',rownames,varnames,values); 
    %rearrange table layout and copy button
    h_tab = findobj(h_fig,'Tag','uitablefigure');
    h_tab.ColumnEditable = [false true];    
    h_but = findobj(h_fig,'String','Copy to clipboard');
    h_but.Position(1) = h_but.Position(1)-0.020;
    h_but.Position(3) = h_but.Position(3)+0.020;
    h_but.String = 'Copy Syntax & Close';
    h_but.Tooltip = 'Copy selected syntax to clipboard';
    %callbacks to copy cell content and close UI
    h_tab.CellSelectionCallback = @(src,evt)setSeasonUI(src,evt,h_but);
    h_but.Callback = @(src,evt)copyClose(src,evt,h_fig);
    uiwait(h_fig)
    prompt = {'Threshold for calms:','Seasonal divisions'};
    title = 'Descriptive Statistics';
    numlines = 1;
    defaultvalues{1} = num2str(0.1);
    defaultvalues{2} = clipboard('paste');
    opts.WindowStlye = 'normal';
    cthr = inputdlg(prompt,title,numlines,defaultvalues,opts);
end
%%
function setSeasonUI(~,evt,h_but)
    %assign selected cell content to the close button
    h_but.UserData = evt.Source.Data{evt.Indices(1),evt.Indices(2)}; 
end
%%
function copyClose(src,~,h_fig)
    %copy selected data to the clipboard and close the figure
    if ischar(src.UserData)
        clipboard('copy',src.UserData) ;
        delete(h_fig)
    else
        warndlg('No Syntax selection made. Select a cell');
    end
end
%%
function stats = time_stats(ts,cthr,varargin)            
    %statistics for a time series ts
    %cthr - calms threshold
    %varagin{1} = stats - table for results (empty on first call)
    %varagin{2} = index for season number
    dummy = zeros(11,1);
    if isempty(varargin)
        varname = 'All';
        stats = table(dummy);
        stats.Properties.RowNames = {'No of records','% Gaps','% Calms',...
                    'Mean','St.Dev.','Min','Max','Sum',...
                    'Slope','Intercept@t0','R_squared'};
        stats.Properties.VariableNames = {varname};
        stats.Properties.DimensionNames = {'Statistic','Results'};
    else
        stats = varargin{1};
        varname = sprintf('S%g',varargin{2});
        stats = addvars(stats,dummy,'NewVariableNames',varname);
        if isempty(ts) || ts.Length==0
            return;
        end
    end
    
    %generate statistical results
    nrec = length(ts.Data(~isnan(ts.Data)));
    calms = length(ts.Data(ts.Data<str2double(cthr{1})))/nrec*100;
    gaps = (ts.Length-nrec)/ts.Length*100;
    stsum = sum(ts,'Weighting','time');  
    mtime = datetime(getabstime(ts));
    %eps(0) to avoid divide by zero in linear regression
    mtime = years(mtime-mtime(1)+eps(0)); 
    var = ts.Data;
    [slope,intcpt,Rsq] = regression_model(mtime,var,'Linear');
    
    %create results vector and assign to table
    vals = [nrec;calms;gaps;mean(ts);std(ts);min(ts);max(ts);stsum;...
                                     slope;intcpt;Rsq];   
    stats.(varname) = vals;
end
%%
function stats = season_stats(ts,cthr,stats,seasons)
    %Sort seasonsal statistics plot and return extended stats array
    %this only works for seasons that divide the year in months
    seasons = seasons';      %transpose so that seasons are ns  = size(seasons,1);
    ns  = size(seasons,2);
    if ns>1                
        time = getabstime(ts);
        datim = datetime(time);
        idx = [];
        for is=1:ns  %each season
            for jm=1:length(seasons(:,is)) %months in each season
                idx= cat(1,idx,find(datim.Month==seasons(jm,is)));
            end
            tsi = timeseries(ts.Data(idx),time(idx));
            stats = time_stats(tsi,cthr,stats,is);
            idx = [];
        end
        seasonalPlot(stats)
    end
end
%%
function stats = getDSstats(data,metatxt) 
    %generate descriptive stats for numeric data
%     data = squeeze(data{:,1});
    if iscell(data) && ischar(data{1})
        data = categorical(data,'Ordinal',true);
        data = double(data);
    end
    dummy = zeros(9,1);
    stats = table(dummy);
    stats.Properties.RowNames = {'No of records',...
                    'Mean','St.Dev.','Min','Max','Sum',...
                    'Slope','Intercept@x0','R_squared'};
    varname = 'Results';            
    stats.Properties.VariableNames = {varname};
    stats.Properties.DimensionNames = {'Statistic','Statistical_Results'};
    nrec = numel(data);
    x = 1:nrec;    
    if isvector(data) && ~iscategorical(data)
        if isrow(data), data = data'; end
        [slope,intcpt,Rsq] = regression_model(x',data,'Linear');
    else
        slope = NaN; intcpt = NaN; Rsq = NaN;
    end
    
    %create results vector and assign to table
    vals = [nrec;mean(data,[1,2],'omitnan');std(data,0,[1,2],'omitnan');...
                           min(data,[],[1,2]);max(data,[],[1,2]);...
                           sum(data,[1,2],'omitnan');slope;intcpt;Rsq];   
    stats.(varname) = vals;
    stats.Properties.Description = sprintf('Descriptive statistics for %s',...
                                                            metatxt{1});                                            
end   
%% 
function seasonalPlot(stats)
    %plot seasonal variation of mean and standard deviation
    mvals  = stats{'Mean',:};
    stvals = stats{'St.Dev.',:};
    stext  = stats.Properties.UserData;
    tsdesc = stats.Properties.Description;
    ns = length(stext);
    %
    hf = figure('Name','Seasonal Plot','Tag','StatFig',...
                'Units','normalized',...
                'Resize','on','HandleVisibility','on');
    %move figure to top right
    hf.Position(1) = 1-hf.Position(3)-0.01;
    hf.Position(2) = 1-hf.Position(4)-0.12;
    he = errorbar(1:ns,mvals(2:end),stvals(2:end),...
        '-o','LineWidth',1,'MarkerSize',10,...
        'MarkerEdgeColor','red');
    hold on
    plot([0.1,ns+0.9],[mvals(1),mvals(1)],'-k','LineWidth',0.25);
    plot([0.1,ns+0.9],[mvals(1)+stvals(1),mvals(1)+stvals(1)],':k','LineWidth',0.25);
    plot([0.1,ns+0.9],[mvals(1)-stvals(1),mvals(1)-stvals(1)],':k','LineWidth',0.25);
    xlabel('Season');
    mver = version('-release'); %options added to errorbar in v2017a
    if str2double(mver(1:4))>=2017
        he.CapSize = 10;
        xticks(1:ns);
        xticklabels(stext);
    end
    ylabel('Mean (+/-1 Std.Dev.)');
    title(tsdesc);
    hold off
end