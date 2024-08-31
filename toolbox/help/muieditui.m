%% muiEditUI
% The muiEditUI class inherits the <matlab:doc('muidataui') muiDataUI> 
% class and provides a user interface for selection of datasets and 
% variables, along with the methods to edit the data and save the
% results to a project catalogue ( <matlab:doc('muicatalogue') muiCatalogue>).

%% Syntax
%   obj = muiEditUI.getEditUI(mobj);  %mobj is handle to main UI.

%% Description
% The selection process allows multi-dimensional data to be sub-selected to
% a 1, or 2, dimensional array for editing in an interactive table figure.

%% muiEditUI properties
% * *TabOptions* - names the tabs used in the UI.
% * *Tabs2Use* - cell array of tabs to include in UI. Allows subselection of
% the tabs included in a UI based on muiDataUI to suit the application.
% There is only a single tab in the Edit UI.
%%
% The properties _UIselections_ and _UIsettings_ are initialised and set
% by the muiDataUI superclass and define the selections made by the user.

%% muiEditUI methods
% *getEditUI* - static function used to initialise the UI from the main UI
%%
% The following methods are required by muiDataUI: 
%%
% * *setTabContent* - calls functions that define the layout options for individual tabs.  
% * *setVariableLists* - initialises the selection variables for each tab in the UI.
% * *useSelection* - function to do something with selected data.

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muicatalogue') muiCatalogue>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.