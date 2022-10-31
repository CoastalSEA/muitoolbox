%% ModelUI - Getting Started
% The steps below outline how to setup a bespoke application of ModelUI
% by modifying the default UI. How to develop more complex UIs is explained
% in the <matlab:mui_open_manual ModelUI manual>.
%%
% # Decide on what components are needed. These might include: <br>
%   o UI - the main interface for the application  <br>
%   o Data import - load different types of data <br>
%   o Input parameters - define any parameters needed for the application <br>
%   o Model(s) - initialise and call any models to be run by the application.  <br>
% # Give names to each component, e.g.: <br>
%   ModelUI, demoData, demoProps, demoModel
% # Copy the class templates for the components from here to your working folder
% # Create classes for each component by editing the templates as illustrated
%   for each template below.

%%
% Templates for the main components are provided in the muitemplates 
% folder, which can be found <matlab:template_folder here>. The templates 
% provide the code for each component and the comments highlight where the 
% files need to be edited to adapt the templates to a different application. 

%% Main UI
% To adapt the demonstration <matlab:doc('modelui') ModelUI> App for a new
% application, the class inherits the ModelUI class.
%%
% Define a classname that reflects the intended application. In the setMUI
% method define the components of the application, such as the model and input
% parameter classes used that define the ModelInputs property and the
% plottig and statistics options to include in the respective UIs. The
% setTabProperties method has to be edited to match the class names for the
% parameter inputs and the position for each parameter set on the tab. Finally, 
% the calls to input classes and to run the model need to be edited to the 
% class and method names to be used.
%
% <include>../muitemplates/UseModelUI_template.m</include>
%
%%
% For bespoke implementations the new class should inherit the 
% <matlab:doc('muimodelui') muiModelUI> interface. There are important 
% differences in the class constructor method and these are highlighted in
% the UseUI_template.m template file.

%% Data import
% For each type of _data_ to be imported, define a classname and edit the
% template where indicated using the classname. The classname can be
% generic (e.g. Waves) and the meta-data can be modified to reflect
% variation in data from different sources (number of variables, file
% format, etc). This is used extensively in the ModelUI CoastalTools App.
% In the template provided, edit the call to dstable (line 46) and the file format defined in
% readInputData (line 67) to match the data being loaded. The Q-Plot tab
% displays a fixed format plot of the data. This can use the default format
% or be customised in the tabPlot function.
%%
% At the bottom of the template is the dataDSproperties function. This must
% be edited to match the data being loaded. Working out the details of the
% fomrat of the data being loaded helps to ensure that the data is being
% formatted correctly and defining the metadata defined by the dsproperties
% stuct ensures that the meta-data is avaialble for subsequent use of the
% data in plotting, statical analysis, etc.
%
% <include>../muitemplates/DataImport_template.m</include>
%
%% Input parameters
% For each set of _input parameters_, define a classname and edit the
% template where indicated using the classname. Define the _input
% parameters_ required in the properties block and provide a description 
% (used in the input UI) for each parameter as a cell array of strings in 
% the PropertyLabels property.
%
% <include>../muitemplates/ParamInput_template.m</include>
%
%% Models
% For each _model_ to be included, define a classname and edit the
% template where indicated using the classname. In the sections of the
% template indicated as Model code and Assing model output, edit to suit
% the needs of the application. The Q-Plot tab display a fixed format plot
% of the model output. This can use the default format or be customised in 
% the tabPlot function.
%
% <include>../muitemplates/Model_template</include>
%
%%
% At the bottom of the template is the dataDSproperties function. This must
% be edited to match the data being loaded. Working out the details of the
% format of the data being loaded helps to ensure that the data is being
% formatted correctly and defining the metadata defined by the dsproperties
% stuct ensures that the meta-data is avaialable for subsequent use of the
% data in plotting, statical analysis, etc.	

%% Data access UIs
% Default interfaces for editing, plotting, statistical analysis and data
% mainpulation are provided as part of the <matlab:doc('muitoolbox') muitoolbox>.
% Alternative or addional UIs can be added using the <matlab:doc('muidataui') muiDataUI> 
% abstract class. This allows a number of tabs to be defined, each with its
% own set of controls to define the selection needed for a specific
% application. See <matlab:doc('muieditui') muiEditUI>,
% <matlab:doc('muiplotsui') muiPlotsUI>, <matlab:doc('muistatsui') muiStatsUI>
% and <matlab:doc('muimanipui') muiManipUI> for examples of different
% configurations. The setXXXXtab methods at the end of the template and
% example classes, are used to define the content of each tab. The methods
% that <matlab:doc('muidataui') muiDataUI> requires in a subclass include:
%%
% * *setTabContent* - define the layout options for individual tabs by
% calling the setXXXXtab methods for each tab.
% * *setVariableLists* - initialise selection lists defined for each tab
% * *useSelection* - implement the actions to be taken in response to the
% action buttons. The Clear and Close options are handled within muiDataUI.
%%
% 
% <include>../muitemplates/DataUI_template</include>
%
%%
% Classes derived from muiDataUI are intended to enable easy access to 
% multi-dimensional data stored in <matlab:doc('dstable') dstables>,
% allowing the user to select individual Cases and Datasets before selecting
% specific variables and data ranges of both the variable and any associated
% dimension data.

%% See Also
% A full list of the <matlab:doc('muitemplates') Templates> which can be found in
% the templates folder <matlab:template_folder here>.  <br>
% <matlab:doc('modelui_examples') Examples> of using the interface for
% different applications. The files for these examples can be found in
% the example folder <matlab:mui_example_folder here>.  <br>
% <matlab:doc('muitoolbox') muitoolbox> documentation for details of the
% _muiModelUI_ abstract interface class and the other UIs used in _ModelUI_. <br>
% <matlab:doc('dstoolbox') dstoolbox> documentation for details of 
% _dstable_ and _dsproperties_. <br>
% The demonstration UI provided in the <matlab:doc('modelui') ModelUI> App. 






