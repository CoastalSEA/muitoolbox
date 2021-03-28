%% muiStatsUI
% The muiStatsUI class inherits the <matlab:doc('muidataui') muiDataUI> 
% class and provides a user interface for selection of datasets and 
% variables and using these in <matlab:doc('muistats') muiStats>.

%% Syntax
%   obj = muiStatsUI.getStatsUI(mobj);  %mobj is handle to main UI.

%% Description
% The selection process allows multi-dimensional data to be sub-selected to
% suit the needs of the selected statistical analysis method.

%% muiStatsUI properties
% * *TabOptions* - names the tabs used in the UI.
% * *Tabs2Use* - cell array of tabs to include in UI. Allows subselection of
% the tabs included in a UI based on muiDataUI to suit the application.
% _muiStatssUI_ defines several analysis options, (general statistics,
% extremes analysis, etc) and only some of these may be needed in a 
% given application.
%%
% The properties _UIselections_ and _UIsettings_ are initialised and set
% by the muiDataUI superclass and define the selections made by the user.%

%% muiStatsUI methods
% *getStatsUI* - static function used to initialise the UI from the main UI
%%
% The following methods are required by muiDataUI: 
%%
% * *setTabContent* - calls functions that define the layout options for individual tabs. <br> 
% * *setVariableLists* - initialises the selection variables for each tab in the UI. <br>
% * *useSelection* - function to do something with selected data.

%% Statistcal analysis options
% * *General* - Descriptive for X, Regression, Cross-correlation, or User 
% defined methods;
% * *Timeseries* - Descriptive, Peaks, Clusters, Extremes, Poisson Stats, 
% or User defined methods;
% * *Taylor* - implements the generation of a Taylor diagram to compare
% data with a reference dataset;
% * *Intervals* - compute general statistics of one dataset for the intervals 
% defined by another data set (e.g. wave statistics in the interval between
% profile surveys).

%% muiStats
% <matlab:doc('muistats') muiStats> is called from muiStatsUI and
% implements the statistical analysis selection made using the muiStatsUI. 

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muistats) muiStats>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.