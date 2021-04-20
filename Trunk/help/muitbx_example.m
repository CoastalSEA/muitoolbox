%% muitoolbox - simple model examples
% A number of examples are provided to illustrate a range of uses. The 
% files for the example use case can be found in the example folder 
% <matlab:example_folder here>. 

%%
% The example folder includes the following options:
%%
% # Examples of individual class usage provided in the _test_muitoolbox.m_
% function;
% # The construct illustrated in the introduction of the
% <matlab:doc('muitoolbox') muitoolbox>,
% illustrated using the calling function _mui_usage.m_ and the
% *mui_demoData* amd *mui_demoModel* classes that inherit from the 
% <matlab:doc('dmuidataset') muiDataSet> abstract class;  
% # A demonstration UI, provided by the *mui_demoUI* class that inherits
% from the <matlab:doc('muimodelui') muiModelUI> abstract class. 

%% mui_demoData class
% A class to load data from a file and store it in a <matlab:doc('dstable') dstable>. 
% The class includes methods to define the dsproperties, read the 
% input file format, load the data into a _dstable_ and plot some output.

%% mui_demoModel class
% A class to run a simple model (2D diffusion using parameter settings 
% defined in mui_demo_inputprops.m when called by *mui_usage* class, and using 
% the Setup>Input Parameters when called from within *mui_demoUI*).
% The class includes methods to run the model, save the results, and plot
% the model output.

%% mui_demoPropsInput class
% A class to demonstrate the definition of model input parameters using the
% <matlab:doc('muipropertyui') muiPropertyUI> abstract class. The interface
% loads the properties required to run *mui_demoModel*.

%% mui_demoUI class
% A class to demonstrate the implementation of the
% <matlab:doc('muimodelui') muiModelUI> abstract class. The model has calls
% to *mui_demoPropsInput*, *mui_demoModel*, and *mui_demoData*, to set up
% the model input, call the model and load data from a text file. The UI is
% initialised by simply typing the class name in the Command Window:
%%
%   mui_demoUI;

%% mui_usage class
% A class to illustrate the combined use of data and model classes that use 
% dstable and dsproperties, with a record for each data set held in
% dscatalouge. An option to run dstb_usage is included in test_dstoolbox
%%
%   dm = dstb_usage;    %initialise class that manages calls to models and data classes
%   run_a_model(dm);    %run the demonstation model
%   load_data(dm);      %load a dataset from a text file
%   plotCase(dm);       %plot some results for a selected Case
%   displayProps(dm);   %display the DSproperties for a selected Case
%%
% The above sequence of calls is is also provided in the *test_toolbox
% function and can be accessed using the call:
%%
%   test_muitoolbox('mui_usage');

%% test_muitoolbox function
% 
%%
% *Examples of usage*
%%
%   test_muitoolbox(classname);
%%
% _classname_ is one of the <matlab:doc('muitbx_utilityclasses') muitoolbox classes> 
% or one of the example classes that illustrates the use of a muitoolbox
% abstract class.

%% 
% *muiCatalogue* <br>
% Initialises the class object, adds and removes some records, prompt to edit
% record, select records to be deleted. Results are displayed in 
% the Command Window.
%%
%   test_muitoolbox('muiCatlogue');

%% 
% *muiProject* <br>
% Initialises the class object, and prompts to edit the project
% properties. 
 %%
%   test_muitoolbox('muiProject');  

%% 
% *muiConstants* <br>
% Initialises the class object, and prompts to edit the project
% the properties. 
%%
%   test_muitoolbox('muiConstants');

%% 
% *mui_demoPropsInput* <br>
% Initialises the class object, and prompts to edit the project
% the properties. 
%%
%   test_muitoolbox('mui_demoPropsInput');

%%
% *mui_usage* <br>
% Runs the model twice and loads a data set to create a catalogue of three data
% sets, then calls plot and display functions for selected cases.
%%
%   test_muitoolbox('mui_usage');

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muitbx_gettingstarted') Getting Started>, and
% The demonstration UI provided in the <matlab:doc('modelui') ModelUI> App. 
