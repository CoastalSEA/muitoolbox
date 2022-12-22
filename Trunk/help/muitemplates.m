%% muitoolbox templates
% Templates for the main components (classes) are provided in the _muitemplates_ 
% folder, which can be found <matlab:mui_template_folder here>. The templates 
% provide the code for each component and the comments highlight where the 
% files need to be edited to adapt the templates to a different application.
%%
% The folder includes the following files:
%%
% * *DataImport_formatfiles_template.m* - inherits muiDataSet and is used to
% import data into the application from external files. A class can import
% data of different formats. Each format must be defined in a format file.
% * *dataimport_format_template.m* -  defines the data format to be loaded.
% * *DataImport_template.m* - used to import data into the application 
% from external files but does not use format files and does not inherit
% the muiDataSet abstract class.
% * *DataUI_template.m* - example of a class for bespoke UIs for
% accessing data (eg for plotting, analysis, etc), which inherits
% muiDataUI.
% * *function_template.m* - default template used to guide standard format
% on function documentatiion.
% * *Model_template.m* - example of a class to run a model and save the
% results, which inheirts muiDataSet.
% * *ParamInput_template.m* - example of a class to define the parameters
% and associated property names to use the methods defined in the
% muiPropertyUI abstract class, to handle interactive setting of property values.
% * *UseModelUI_template.m* - example of a class to create a bespoke
% application that inherits the ModelUI application and modifies the
% function calls to suit the application (UI is the same as ModelUI).
% * *UseUI_template.m* - example of a class to create a bespoke
% application that inherits the muiModelUI abstract class, allowing menus
% tabs and any other functionality required to be defined to suit the
% application.