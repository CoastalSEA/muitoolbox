%% muitoolbox examples
% The construct illustrated in the introduction of the <matlab:doc('muitoolbox') muitoolbox>
% is illustrated using the calling function mui_usage.m and the
% muiData amd muiModel classes that inherit from the <matlab:doc('dscollection') dscollection> abstract class.
%
% Usage of the individual classes is provided in the test_muitoolbox
% function.
%%
%   dm = dstb_usage;    %initialise class that manages calls to models and data classes
%   run_a_model(dm);
%   load_data(dm);
%   plotCase(dm);       %plot some results for a selected Case
%   displayProps(dm);   %display DSproperties for a selected Case
%

%% mui_usage class
% A class to illustrate the combined use of data and model classes that use 
% dstable and dsproperties, with a record for each data set held in
% dscatalouge. An option to run dstb_usage is included in test_dstoolbox

%% muiData class
% A class to load data from a file and store it in a <matlab:doc('dstable') dstable>. 
% The class includes methods to define the dsproperties, read the 
% input file format, load the data into a _dstable_ and plot some output.

%% muiModel class
% A class to run a simple model (2D diffusion using hard code parameter settings)
% The class includes methods to run the model, save the results, and plot
% the model output

%% test_muitoolbox function
% 
%%
% *Examples of usage*
%%
%   test_muitoolbox(classname,casenum,options)
%%
%
%%
% *mui_usage* <br>
% _casenum_ and _options_ input arguments not used <br>
% Runs the model and loads data twice to create a catalogue of four data
% sets. then calls plot and display functions for selected cases.