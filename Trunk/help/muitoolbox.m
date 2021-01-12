%% muitoolbox
% _muitoolbox_ is a collection of classes used to create bespoke UIs for models and data 
% analysis. These include:  <br>
% *muiModelUI* – an abstract class that defines the requirements for a user interface and 
% provides several methods that are implemented unless overloaded in the implementing class. <br>
% *muPropertyUI* – an abstract class the provides the methods for loading and displaying 
% input parameters, minimising the effort to set-up interactive data input. <br>
% *muiCatalogue* – manages the storing and access to model Cases (imported data or model 
% outputs). <br>
% *muiDataSet* – an abstract class that defines the requirements for user interfaces to 
% access the data. <br>
% *muiProject* – holds path and file of current project (working model or data set) and 
% project details. <br>
% *muiConstants* – standard physical values (acceleration due to gravity, densities, year 
% to seconds, etc). <br>
% The _muitoolbox_ integrates with the _dstoolbox_, which stores and manages access to 
% multi-dimensional data sets (see Appendix B).

%% Schematic
% These classes can be used together as illustrated in the following figure, where 
% *ModelUI* is the class that defines the bespoke UI:

%%
% <<muitoolbox_model.png>>

%%
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
% The toolbox is designed to 
