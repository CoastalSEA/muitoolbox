%% muiStats
% Class for data that is selected using the <matlab:doc('muistatsui') muiStatsUI> 
% interface included in  ModelUI, CoastalTools and other ModelUI apps.

%% Syntax
%%
%   muiStats.getStats(gobj,src,mobj);
%%
% where _gobj_ is a handle to <matlab:doc('muistatsui') muiStatsUI>, _src_ is a
% handle to the graphical object used to initialise the call, and _mobj_ is a
% handle to the main UI.

%% Description
% Implement the Statistical analysis options that are provided for in
% <matlab:doc('muistatsui') muiStatsUI>.

%% muiStats properties
% muiStats using the following Transient properties:
%%
% * *UIsel* - structure for the variable selection made in muiStatsUI;
% * *UIset* - structure for the plot settings made in muiStatsUI;
% * *Data* - data to use in statistic (x,y,z);
% * *MetaData* - text summary of primary variable selection;
% * *Labels* - struct for XYZ labels;
% * *Title* - Title text;
% * *Order* - order of variables for selected statistic;
% * *DescOut* - structure for descriptive output tables;
% * *ExtrOut* - structure for extremes output tables;
% * *Taylor* - structure for parameters defined for skill score; 

%% muiStats methods
% * *getStats* is a static function called from muiStatsUI.

%% Statistcal analysis options
% muiStats implements the following options, calling external functions
% that can be found in the muiApps/muiAppStatsFcns folder:
%%
% * *General* - Descriptive for X, Regression, Cross-correlation, or User 
% defined methods;
% * *Timeseries* - Descriptive, Peaks, Clusters, Extremes, Poisson Stats, 
% or User defined methods;
% * *Taylor* - implements the generation of a Taylor diagram to compare
% data with a reference dataset;
% * *Intervals* - compute general statistics of one dataset for the intervals 
% defined by another data set (e.g. wave statistics in the interval between
% profile surveys).

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muistatsui) muiStatsUI>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.