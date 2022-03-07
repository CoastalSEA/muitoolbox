function user_stats(obj,mobj,srcVal) %#ok<INUSL>
%
%-------function help------------------------------------------------------
% NAME
% user_stats.m
% PURPOSE
%   Function to allow user to implement own statistical function
% USAGE
%   user_stats(obj,mobj,srcVal,ts,metatxt)
% INPUT
%   obj - handle for muiStats with user selected options
%   mobj - handle to App UI to allow access to data
%   srcVal - handle to UI tab to display results (if required - optional)
% NOTES
%   No provision to pass results back to CoastalTools at present
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%

% code to get time series (modify options to get a different timeseries to
% the one selected in the muiStatsUI)
% ts = setDatasetVars(obj,mobj,[],'C');
if nargin<3, srcVal = []; end

if strcmp(srcVal,'General')
    warndlg('psfunctions/user_stats.m called. Nothing implemented for General Stats');
    return;
end

ts = obj.Data.X;
metatxt = obj.MetaData.X;

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

%--CODE TO USE TIME SERIES ts ---------------------------------------------

%prompt user to select threshold and peak selection definition
prompt = {'Threshold for peaks:','Selection method', ...
          'Time between peaks (hours)','Cluster time interval (days)'};
dlgtxt = 'Cluster Statistics';
numlines = 1;
default = {num2str(mean(data,'omitnan')+2*std(data,'omitnan')),...
                                      num2str(3),num2str(18),num2str(15)};
answer = inputdlg(prompt,dlgtxt,numlines,default);
if isempty(answer), return; end

%set inputs based on user defined values
threshold = str2double(answer{1});   %selected threshold
method = str2double(answer{2});      %peak selection method (see peaks.m)
tint = hours(str2double(answer{3})); %time interval between independent peaks
clint = days(str2double(answer{4})); %time interval for clusters

% find peaks (method 1:all peaks; 2:independent crossings; 3:timing
% seperation of tint)
returnflag = 0; %0:returns indices of peaks; 1:returns values
idp = peaksoverthreshold(data,threshold,method,mdate,tint,returnflag);

% find clusters based on results from peak selection
pk_date = mdate(idp);
pk_vals = data(idp);
cls = clusters(pk_date,pk_vals,clint);

%initialise plot variables
symb = ['o','+','*','.','x','s','d','^','v','<','>','p','h'];
nsymb = length(symb)-1;
ncls = length(cls); % number of clusters

% plot selected clusters
hf = figure('Name','User Stats Plot','Tag','StatFig');
plot(mdate,data);
hold on
plot([mdate(1),mdate(end)],[threshold,threshold],'-.r');
for ij = 1:ncls
    plot(cls(ij).date,cls(ij).pks,symb(mod(ij,nsymb)+1));
end
xlabel('Date');
ylabel(sprintf('%s (%s)',labeltxt,unitstxt));
fittedtitle(hf,metatxt,false,0.68)
hold off
