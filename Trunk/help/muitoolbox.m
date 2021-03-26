%% muitoolbox
% _muitoolbox_ is a collection of classes used to create bespoke UIs for models and data 
% analysis. 
%% Abstract classes
% These include the following abstract classes:  <br>
% *muiModelUI* – an abstract class that defines the requirements for a user interface and 
% provides several methods that are implemented unless overloaded in the implementing class. <br>
% *muPropertyUI* – an abstract class the provides the methods for loading and displaying 
% input parameters, minimising the effort to set-up interactive data input. <br>
% *muiDataUI* - an abstract class for creating graphic user interface to select data
% and pass selection to applications. <br>
% *muiDataSet* – an abstract class that defines the requirements for user interfaces to 
% access the data. 

%% Utility classes
% In addition the toolbox includes the following utility classes: <br>
% *muiCatalogue* – manages the storing and access to model Cases (imported data or model 
% outputs). <br>
% *muiProject* – holds current project details. <br>
% *muiConstants* – standard physical values (acceleration due to gravity, densities, year 
% to seconds, etc). <br>
% *muiUserData* - import data sets using user-defined format file.  <br>
% *muiEditUI* - data selection UI to edit data sets.  <br>
% *muiPlotsUI* - data selection UI to generate plots.  <br>
% *muiPlots* - methods for plot options based on UI selection. <br>
% *muiStatsUI* - data selection UI for statistical anlysis. <br>
% *muiStats* - methods for statistical analysis based on UI selectio.  <br>
% *muiManipUI* - data selection UI to define an equiation of function call.  <br>
% *muiUserModel* - methods to evaluate functions based on UI selection. 
%%
% For further documentation of these classes see
% <matlab:doc('muitbx_classes') muitoolbox classes>.
%%
% The _muitoolbox_ integrates with the <matlab:doc('dstoolbox') dstoolbox>, 
% which stores and manages access to multi-dimensional data sets.

%% Schematic
% These classes can be used together as illustrated in the following figure, where 
% *ModelUI* is the class that defines the bespoke UI:

%%
% <<muitoolbox_model.png>>

%% Description
% The purpose of the muitoolbox is to minimise the effort in creating or prototyping an 
% interface for a model or data analysis tool. Creating a new model requires 3 components to 
% be defined, namely the interface (ModelUI in the above illustration), one or more classes 
% to manage the input of model parameters (if required) and the classes to hold imported 
% data, or running a model and storing the output. Central to this is the holding of input 
% data in the Inputs property and accessing the data via the Cases property. In this 
% context, Cases comprise a record of each Case and a dataset. The records are held in the 
% Catalogue property and the dataset (an instance of the data or model class) in the 
% DataSets property of muiCatalogue. Each data or model class stores the dataset in the Data 
% property, with additional information held in the RunData property (e.g. holding input 
% parameters of a model run). Any type of dataset can be stored in the Data property but 
% when using the dstoolbox multidimensional data sets can be stored using dstable and a full 
% set of meta-data attached using dsproperties. The overall architecture and the properties 
% that provide the links between one class and another are shown in the flow chart below.

%%
% <<muitoolbox_flow_diagram.png>>

%% Usage
% The <matlab:doc('muitbx_example') muitoolbox example> provides details
% of a simple implementation. An implementation of the suite of muitoolbox utilities 
% is provided in the <matlab:doc('modelui') ModelUI> App, which also 
% illustrates how to customise the default UI or define a bespoke UI.

%% See Also
% muitoolbox uses <matlab:doc('dstoolbox') dstoolbox> and use of both
% toolboxes is llustrated in the <matlab:doc('modelui') ModelUI> App.
