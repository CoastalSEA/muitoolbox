%% muiDataUI
% Abstract class for creating graphic user interfaces to select data
% and pass selection to applications.


%% Description
% The muiDataUI class provides a set of properties and methods that allow
% the creation of a bepoke user interfaces to access data held in a 
% <matlab:doc('muicatalogue') muiCatalogue>. Several classes in the 
% <matlab:doc('muitoolbox') muitoolbox> make use of muiDataUI, including
% <matlab:doc('muieditui') muiEditUI>, <matlab:doc('muiplotsui') muiPlotsUI>, 
% <matlab:doc('muistatsui') muiStatsUI> and <matlab:doc('muimanipui') muiManipUI>. 
% Classes derived from muiDataUI are intended to enable easy access to 
% multi-dimensional data stored in <matlab:doc('dstable') dstables>,
% allowing the user to select individual Cases and Datasets before selecting
% specific variables and data ranges of both the variable and any associated
% dimension data.

%% muiDataUI abstract properties
% Properties that all subclasses must include:
%%
% * *TabOptions* - names of tabs that provide different data accces options

%% muiDataUI properties
% In addition to some properties that handle internal controls, the following
% two transient properties are set by muiDataUI derived classes in order 
% to pass the user selection to other classes and methods:
%%
% *UIselection* - struct array of UI selections (one struct for each selection
% option).
%%
% * caserec - case record index of selected case;
% * dataset - index to field name in Data struct to selected dstable;
% * variable - index to selected Variable in selected dstable;
% * property - name of what to use: variable,row or dimension description;  
% * range - limits set for selected property;
% * scale - any scaling function to be applied to the variable;
% * dims - struct to hold dimension 'name' and 'value' when
% subselecting from a multi-dimensional array;
% * desc - text string that is displayed in the xyz selection text box.

%%
% *UIsettings* - struct of UI settings. The defaullt struct includes fields
% for the UserData value of any action buttons included on a tab, any
% settings that apply to the overall selection (e.g. plot type) any 
% equation defined in a text box and details of the tab and calling button 
% used to initiate the call to the useSelection method.

%% muiDataUI abstract methods
% Methods that all subclasses must include:
%%
% * *setTabContent* - define the layout options for individual tabs.
% * *setVariableLists* - initialise selection lists defined for each tab
% * *useSelection* - implement the actions to be taken in response to the
% calls from the control buttons. The Clear and Close buttons are handled 
% within muiDataUI.

%% Creating a class using muiDataUI
% A template to create a class that uses muiDataSet can be found in the
% <matlab:mui_template_folder muitemplates folder>. The template provides the code for a subclass
% and the comments highlight where the file needs to be edited to adapt 
% the template to a new application, as explained further in the 
% <matlab:doc('muitbx_gettingstarted') Getting Started> documentation. 

%% See Also
% <matlab:doc('muitoolbox') muitoolbox><matlab:doc('muicatalogue') muiCatalogue>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.
 
