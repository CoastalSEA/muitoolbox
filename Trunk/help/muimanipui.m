%% muiManipUI
% The muiManipUI class inherits the <matlab:doc('muidataui') muiDataUI> 
% class and provides a user interface for selection of datasets and 
% variables, and using these in a Matlab(TM) expression or in a function
% call.

%% Syntax
%   obj = muiManipUI.getManipUI(mobj);  %mobj is handle to main UI. 

%% muiManipUI properties
% * *TabOptions* - names the tabs used in the UI.
% * *Tabs2Use* - cell array of tabs to include in UI. Allows subselection of
% the tabs included in a UI based on muiDataUI to suit the application. For
% example _muiPlotsUI_ defines a wide range of plotting options, (2D, 3D,
% etc) and only some of these may be needed in a given application.
%%
% The properties _UIselections_ and _UIsettings_ are initialised and set
% by the muiDataUI superclass and hold the selections made by the user.
%
%% muiManipUI methods
% *getManipUI* - static function used to initialise the UI from the main UI
%%
% The following methods are required by muiDataUI: 
%%
% * *setTabContent* - calls functions that define the layout options for individual tabs. 
% * *setVariableLists* - initialises the selection variables for each tab in the UI.
% * *useSelection* - function to do something with selected data.

%% User Equation or Function
% The text box is used to define a Matlab(TM) algebraic script , call a
% Matlab(TM) function, or call an external function. The main constraint
% when using this utility is that the number of variables is limited to 3
% (X, Y, and Z) in addition T can be used in the call to make use of the
% dataset RowNames (eg time), without the need to assign T to a button. 
% The variables can be written in upper or lower case. For each variable defined 
% in the call, a variable must be assigned to one or more of the XYZ buttons
% (with the exception of T). In addition, text inputs 
% required by the call and the model instance (mobj) can also be passed. 
% Comments can be used to pass additional instructions, such as the
% inclusion of the RowNames in the output to be saved as a new dataset,
% using either %time or %rows. 
%%
% For example any of the following could be entered into the equation box:
%%
%   x.^2+y   %time
%   myfunction1(x,y,t,'usertext') 
%   myfunction2(x,mobj)
%%
% The output from this type of function call can be figures or tables, a 
% single numeric value, or a dataset to be saved (character vector or array).
% External functions must return output as a cell array with the new variable
% in the first cell and data to be used to define RowNames in the second
% cell. If the %time or %rows instruction is included in the call, row data
% are added providing that the length of the input dataset matches the output
% dataset. If there is no output to be passed back the function should
% return a cell array containing the string 'no output' to suppress the
% message box which is used for single value outputs. For expressions that
% return a result that is the same length as one, or more, of the
% variables used in the call, there is also the option to add the variable
% to one of the input datasets as a new variable. In all there are three
% ways in which results can be saved:
%%
% # Expression or function returns a result that is the same number of rows as one or 
% more of the input datasets. Option to (a) add as a new variable to an
% existing data set, or (b) create a new dataset with no assignement to the
% RowNames property.
% # As (1) with the comment of %time or %rows in the call. Attempts to use
% the RowNames property of one of the inputs to define RowNames in a new
% dataset. Requires the input variables to have same number of rows.
% (_Plan to add interpolation so this may change_).
% # Expression or function returns a result with a new variable and time
% time in a 2-element cell array. The variable is saved as a new dataset.

%%
% An alternative when calling external functions is to pass the selected
% variables as dstables, thereby also passing all the associated metadata
% and RowNames for each dataset selected. For this option up to 3 variables
% can be selected but they are defined in the call using dst, for example:
%%
%   myfunction3(dst,'usertext',mobj)
%%
% This passes the selected variables as a struct array of dstables to the
% function. Using this syntax the function can return a dstable, or struct of
% dstables, or a cell array containing one or more data sets. The options
% for saving the data are the same, with the additional option that when a
% dstable, or struct of dstables, is returned, these are saved directly and
% it is assumed that the <matlab:doc('dsproperties') dsproperties> 
% have been defined in the function called.

%% Function library
% To simplify accessing and using a range of functions that are commonly
% used in an application, the function syntax can be predefined in the file
% functionlibrarylist.m which can be found in the utils folder of the
% _muitoolbox_.  This defines a struct for library entries that contains:
%%
% * fname - cell array of function call syntax
% * fvars - cell array describing the input variables for each function
% * fdesc - cell array with a short description of each function
%%
% In addition a subselection of the list can be associated with a given App
% based on the classname of the main UI.
% The Function button on the Derive Output UI can be used to access the
% list, select a function and add the syntax to the function input box,
% where it can be edited to suit the variable assignment to the XYZ
% buttons.

%% muiUserModel
% Inherits from <matlab:doc('muidataset') muiDataSet> to allow new variables to be created using a
% selection of the existing variables and adds the results to the model
% catalogue. <matlab:doc('muiusermodel') muiUserModel> is called from _muiManipUI_.

%% See Also
% See <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('dstoolbox') dstoolbox>
% and documentation for the <matlab:doc('modelui') ModelUI> App.

