%% muiSelectUI
% The muiManipUI class inherits the <matlab:doc('muidataui') muiDataUI> 
% class and provides a user interface for selection of datasets and 
% variables, along with the methods to edit the data and save the
% results to a project catalogue ( <matlab:doc('muicatalogue') muiCatalogue>).

%% Syntax
%   obj = muiSelectUI.getSelectUI(mobj);  %mobj is handle to main UI.

%% Description
% The selection process allows multi-dimensional data to be sub-selected to
% a 1, or 2, dimensional array for editing in an interactive table figure.

%% muiSelectUI properties
% * *TabOptions* - names the tabs used in the UI.
% * *Tabs2Use* - cell array of tabs to include in UI. Allows subselection of
% * *Selected* - logical flag to indicate that the 'Select' button has been selected in the UI.
% the tabs included in a UI based on muiDataUI to suit the application.
% There is only a single tab in the Select UI.
%%
% The properties _UIselections_ and _UIsettings_ are initialised and set
% by the muiDataUI superclass and define the selections made by the user.

%% muiSelectUI methods
% *getSelectUI* - static function used to initialise the UI from the main UI
%%
% The following methods are required by muiDataUI: 
%%
% * *setTabContent* - calls functions that define the layout options for individual tabs.  
% * *setVariableLists* - initialises the selection variables for each tab in the UI.
% * *useSelection* - function to do something with selected data.

%% Usage
%   selobj = muiSelectUI.getSelectUI(mobj);
%   waitfor(selobj,'Selected')
% 
%   UIsel = selobj.UIselection;    %user selection
%   UIset = selobj.UIsettings;     %other UI settings
%   delete(selobj.dataUI.Figure);
%   delete(selobj)

%% selectui function
% The _selectui_ function implements the above code and can be found in 
% ../muitoolbox/muifunctions. This allows muiSelectUI to be called, returns 
% the _UIselections_ and _UIsettings_ properties and deletes the UI.
%%
%   [UIsel,UIset] = selectui(mobj)   %where mobj is handle to calling App UI

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muicatalogue') muiCatalogue>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.