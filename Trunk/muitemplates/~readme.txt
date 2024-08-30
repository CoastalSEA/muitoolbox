Readme file for .../muitoolbox/muitemplates folder

Class templates are as follows:

DataImport_formatfiles_template - import data using a format function file (see template below)
DataImport_template - self containted data import class
DataUI_template - define a User Interface using muitoolbox format and tools
Model_template - setup input, call a model and save results
ParamInput_template - define model input parameters (or a sub-set of them)
UseModelUI_template - bespoke model UI using the ModelUI App and inheriting ModelUI class
UseUI_template - bespoke model UI inheriting the abstract muiModeUI class

Function templates (NB use lower case naming convention):

function_template - blank function with default header ttext
dataimport_format_template - function to define data specific import, parsing, storing and qc functions

User function templates:
user_model - prompts for model class and fucntion call, passes the model handle to allow access to input data and results catalogue.
user_plot - provides some sample code to illustrate accessing and plotting data
user_stats - provides some sample code to illustrate accessing, computing some statistic and plotting result

User data import is handled using the muiUserData class and the dataimport_format_template