%% muiPlots
% Class for data that are selected using the <matlab:doc('muiplotsui') muiPlotsUI> 
% interface included in  ModelUI, CoastalTools and other ModelUI apps.

%% Syntax
%%
%   muiStats.getPlots(gobj,src,mobj);
%%
% where _gobj_ is a handle to <matlab:doc('muiplotsui') muiPlotsUI>, _src_ is a
% handle to the graphical object used to initialise the call, and _mobj_ is a
% handle to the main UI.

%% Description
% Implement the plotting options that are provided for in
% <matlab:doc('muiplotsui') muiPlotsUI>.

%% muiPlots properties
% muiPlots uses the following Transient properties:
%%
% * *Plot* - struct array for: FigNum - index to figures created, 
% CurrentFig - handle to current figure, Order - struct that defines 
% variable order for plot type options (selection held in Order);
% * *ModelMovie* - store animation in case user wants to save;
% * *UIsel* - structure for the variable selection made in the UI;
% * *UIset* - structure for the plot settings made in the UI;
% * *Data* - data to use in plot (x,y,z);
% * *TickLabels* - struct for XYZ tick labels;
% * *AxisLabels* - struct for XYZ axis labels;
% * *Legend* - Legend text;
% * *MetaData* - ext summary of primary variable selection;
% * *Title* - Title text;
% * *Order* - order of variables for selected plot type;
% * *idxfig* - figure number of the current figure.

%% muiPlots methods
% * *getPlot* is a static function called from muiPlotsUI.
% * *get_muiPlots* is a static function to create an instance of the class 
% for use by other functions or methods.
% * *getAplot* is used in external functions to call a muiPlots plot by first
% creating an instance of muiPlots using _get_muiPlots_ and populating the
% muiPlots properties needed for the plot required.

%% Statistcal analysis options
% muiStats implements the following options:
%%
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

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muiplotsui) muiPlotsUI>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.