%% muiModelUI
% Abstract class for creating graphic user interfaces with pulldown menus 
% to control application and tabs to display settings and output.

%% Description
% The muiModelUI class provides a set of properties and methods that allow
% the creation of a bepoke user interface suitable for a range of data
% analysis and modelling applications. The subclass defines the manu and
% tab structure to be used and implements the menu and tab callback
% functions (which call external functions and classes to implement menu 
% and tab options). 

%% muiModelUI abstract properties
% Properties that all subclasses must include:
%%
% * *vNumber* - version number of model.
% * *vDate* - date of current version.
% * *modelName* - name for model/user interface.       

%% muiModelUI hidden properties
% The follwoing properties are used to hold class handles and properties
% that determine the UI behaviour.
%%
% * *mUI* - struct containing fields for: <br>
% o Figure - handle for main UI figure <br>
% o Menus - handle for drop down menus in main UI <br>
% o Tabs - handle for the Tab Group in the main main UI <br>
% o PlotsUI - handle for plotting UI <br>
% o EditUI - handle for editing UI <br>
% o ManipUI - handle for data manipulation UI <br>
% o StatsUI - handle for statistics UI <br>
% o Plots - handle to muiPlots instance <br>
% o Stats - handle to muiStats instance <br>
% * *TabProps* - struct to hold TabDisplay and position for each data input
% * *ModelInputs* - classes required by model used in isValidModel check 
% * *DataUItabs* - structure to define muiDataUI tabs for each use

%% muiModelUI properties
% Properties that hold the input parameters, model data, information about
% the project and commonly used constants
%%
% * *Inputs* - input parameters (handle to classes the use <matlab:doc('muipropertyui') muiPropertyUI>).
% * *Cases* - holds DataSets and Catalogue (handle to <matlab:doc('muicatalogue') muiCatalogue>
% class).
% * *Info* - project information (handle to <matlab:doc('muiproject') muProject> class).
% * *Constants* - constants used by applications (invokes <matlab:doc('muiconstants') muiConstants> class).

%% muiModelUI abstract methods
% Methods that all subclasses must include:
%%
% * *setMenus* - define the menus to be used in the application.
% * *setTabs* - define the tabs that are to be included in the application.
% * *setTabAction* - define how tab callbacks are to be handled.
% * *setTabProperties* - define the tab and table layout for classes that 
% import data using the <matlab:doc('muipropertyui') muiPropertyUI>
% abstract class.

%% Creating a class using muiModelUI
% A template to create a class that uses muiModelUI can be found in the
% <matlab:template_folder muitemplates folder>. The template provides the code for a subclass
% and the comments highlight where the file needs to be edited to adapt 
% the template to a new application, as explained further in the 
% <matlab:doc('muitbx_gettingstarted') Getting Started> documentation. 

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muicatalogue') muiCatalogue>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.
 