%% muiPlotsUI
% The muiPlotsUI class inherits the <matlab:doc('muidataui') muiDataUI> 
% class and provides a user interface for selection of datasets and 
% variables and using these in <matlab:doc('muiplots') muiPlots>.

%% Syntax
%   obj = muiPlotsUI.getPlotsUI(mobj);  %mobj is handle to main UI.

%% Description
% The selection process allows multi-dimensional data to be sub-selected to
% suite the needs of 2, 3 and 4 dimensional data plots and animations using
% 2, 3 or 4 dimensions.

%% muiPlotsUI properties
% * *TabOptions* - names the tabs used in the UI.
% * *Tabs2Use* - cell array of tabs to include in UI. Allows subselection of
% the tabs included in a UI based on muiDataUI to suit the application.
% _muiPlotsUI_ defines a wide range of plotting options, (2D, 3D,
% etc) and only some of these may be needed in a given application.
%%
% The properties _UIselections_ and _UIsettings_ are initialised and set
% by the muiDataUI superclass and define the selections made by the user.

%% muiPlotsUI methods
% *getPlotsUI* - static function used to initialise the UI from the main UI
%%
% The following methods are required by muiDataUI: 
%%
% * *setTabContent* - calls functions that define the layout options for individual tabs.
% * *setVariableLists* - initialises the selection variables for each tab in the UI.
% * *useSelection* - function to do something with selected data.

%% Plotting options
% * *2D* - cartesian or polcar plots using line, bar, scatter, stem, 
% stairs, barh, or User defined plot types;
% * *3D* - plots using surf, contour, contourf, contour3, mesh, or User 
% defined plot types;
% * *4D* - plots using slice,contourslice,isosurface, streamlines, or 
% User defined plot types;
%%
% Animation use the row dimension descriptions as the time variable 
% (typically these will be datetime or duration dagta in a dstable).
%%
% * *2DT* - plot types as for 2D 
% * *3DT* - plot types as for 3D 
% * *4DT* - plot types as for 4D 

%% muiPlots
% <matlab:doc('muiplots') muiPlots> is called from muiPlotsUI and
% implements the plot selection made using the muiPlotsUI. 

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muiplots) muiPlots>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.