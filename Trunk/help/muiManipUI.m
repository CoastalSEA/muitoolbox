%% muiManipUI
% The _muiManipUI_ class inherits the <matlab:doc('muiDataUI') muiDataUI> 
% class and provides a user interface for selection of datasets or 
% variables and using these in a Matlab(TM) expression or in a function
% call.
%% muiManipUI properties
% *TabOptions* - names the tabs used in the UI
% *Tabs2Use* - cell array of tabs to include in UI. Allows subselection of
% the tabs included in a UI based on muiDataUI to suit the application. For
% example _muiPlotsUI_ defines a wide range of plotting options, (2D, 3D,
% etc) and only some of these may be needed in a given application.
%%
% The properies _UIselections_ and _UIsettings_ are initialised and set
% by the muiDataUI superclass and define the selections made by the user.
%
%% muiManipUI methods
% *getManipUI* - static function used to initialise the UI from the main UI
%   muiManipUI.getManiopUI(mobj)
%%
% The following methods are required by muiDataUI
% *setTabContent* - calls functions that define the layout options for individual tabs 
% *setVariableLists* - initialises the selection variables for each tab in the UI
% *useSelection* - function to do something with selected data

%% 

%% User Equation or Function
% The text box is used to define a Matlab(TM) algebraic script , call a
% Matlab(TM) function, or call an external function. The main constraint
% when using this utility is that the number of variables is limited to 3
% (X, Y, and Z) in addition T can be used in the call to make use of the
% dataset RowNames (eg time). The variables can be written in upper or
% lower case. For each variable defined in the call, a variable must be
% assigned to one or more of the XYZ buttons. In addition text inputs
% required by the call and the model object (mobj) can also be passed. 
% Comments can be used to pass additional instructions, such as the
% inclusion of the RowNames in the output to be saved as a new dataset,
% using either %time or %rows.
% For example:
%   x.^2+y   %time
%   myfunction1(x,y,t,'usertext')
%   myfunction2(x,mobj)
% The output from this type of function call can be figures or tables, a 
% single numeric value or character vector, or an array of data to be saved.
% External functions must return output as a cell array with the new variable
% in the first cell and data to be used to define RowNames in the second
% cell. If the %time or %rows instruction is included in the call, row data
% are added providing that the length of the input dataset matches the output
% dataset. If there is no output to be passed back the function should
% return a cell array containing the string 'no output' to suppress the
% message box which is used for single value outputs.
%%
% An alternative when calling external functions is to pass the selected
% variables as dstables, thereby also passing all the associated metadata
% and RowNames for each dataset selected. For this option up to 3 variables
% can be selected but they are defined in the call using dst, for example:
%   mufunction3(dst,'usertext',mobj)
% This passes the selected variables as a struct array of dstables to the
% function.
% Using this syntax the function can return a dstable or struct of
% dstables, or a cell array containing one or more data sets

%% Function library
% To simplify accessing and using a range of functions that are commonly
% used in an application, the function syntax can be predefined in the file
% functionlibrarylist.m which can be found in the utils folder of the
% _muitoolbox_.  This defines a struct for library entries that contain:
% *fname - cell array of function call syntax
% *fvars - cell array describing the input variables for each function
% *fdesc - cell array with a short description of each function
% In addition a subselection of the list can be associated with a given App
% based on the classname of the main UI.
% The Function button on the Derive Output UI can be used to access the
% list, select a function and add the syntax to the function input box,
% where it can be edited to suit the variable assignment to the XYZ
% buttons.

%% muiUserModel
% inherits from muiDataSet to allow new variables to be created using a
% selection of the existing variables and adds the results to the model
% catalogue.
%%
% *muiUserModel methods* <br>
%   createVar(obj,gobj,src,mobj)  %parse and execute the user equation or function
% This function is called from muiManipoUI. 

