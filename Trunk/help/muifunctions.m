%% muitoolbox functions
% Summary of functions available in the _muifunctions_ folder. Use the Matlab(TM)
% help function in the command window to get further details of each
% function.

%%
% * *acceptfigure.m*
% - generate plot figure with buttons to accept/reject selection
% 
% * *acceptpanel.m*
% - create a yes/no panel within a figure
% 
% * *add_copy_button.m*
% - add a 'Copy to Clipboard' button to a figure or tab
%
% * *add_file_header.m*
% - function to add the same header to batch of user selected files (eg to
% add a format definition to the top of a data file)
% 
% * *check4toolbox.m*
% - check whether a toolbox is available
%
% * *check_unique_names.m*
% - check that names in list are unique and if required replace suplicates
% with a unique name
%
% * *check_vector_lengths.m*
% - check that all input values are either scalar or vectors of the same length 
% 
% * *check_xyz_dims.m*
% - check that dimensions of array for 3D plotting are not too big
% 
% * *cleantable.m*
% - clean table by checking numeric data are not cells and 
% replacing non-standard values
% 
% * *editrange.m*
% - button callback function to edit range and enter in a text uicontrol
% 
% * *editrange_ui.m*
% - test whether Vin is datetime and if so use datepicker otherwise use  
% inputdlg to let user edit range values
%
% * *functionlibrarylist.m*
% - Lists available functions for use in DataManip
% 
% * *getintervaldata.m*
% - compute the mean values of the property values in dst2 between the time
% intervals for dst1
% 
% * *getoverlappingtimes.m*
% - find the start and end dates of the overlapping portions of two 
% timeseries in dstables and trim both to the common interval.
% 
% * *getpreceedingdata.m*
% - compute  the mean values of the input dst, inpdst, for the 
% interval preceeding each occurrence in the reference timeseries,
% refdst, using the duration defined by prevint in days 
% 
% * *getvarindices.m*
% - unpack the limits text and find indices of values that lie 
% within the lower/upper limits defined
% 
% * *getwidget.m*
% - widget for text,input uicontrol and control buttons (eg edit) 
%
% * *initialise_mui_app.m*
% - intiailise paths for  a mui App and supporting functions
% 
% * *inpaint_nans.m* 
% - in-paints over nans in an array. From Matlab(TM) Forum by John
% D'Errico, (c) 2012,
% https://www.mathworks.com/matlabcentral/fileexchange/4551-inpaint_nans.
% 
% * *inputgui.m*
% - provides access to the inputUI class to generate a mutli control input
% user interface and return the selections made (can use inputUI.getUI
% instead)
% 
% * *inputUI.m*
% - creates a multi-field UI
%
% * *ismatch.m*
% - finds the occurence of matches between two sets of character vectors,
% cell arrays or string arrays (from v2019b can use Matlab(TM) matches function)
%
% * *isvalidrange.m*
% - check user input is valid for the data type used and within bounds
% 
% * *matrixtableUI.m*
% - generate UI to edit a matrix using tablefigureUI
%
% * *minmax.m*
% - find min and max of multidimensional numeric or ordinal array
%
% * *model_catch.m*
% - display warning dialogue if model fails to find a solution in try-catch
%
% * *paste_text.m*
% - callback function to paste the contents of the clipboard
% to a uicontrol (src)
% 
% * *range2var.m*
% - convert range character array start and end variables
% 
% * *rotatebutton.m*
% - callback for the rotate button on a figure or tab plot
% 
% * *scalevariable.m*
% - rescale a variable (vector or matrix) based on user selection
%
% * *selectui.m*
% - provides access to an instance of the muiSelectUI class for
% Case/Dataset/Variable selection and returns the selections made
%
% * *setAnimate.m*
% - callback function for button to set plot to be an animation instead
% of a snap shot at selected time
%
% * *setcase.m*
% - set case number and prompt user to provide a description
% 
% * *setdatatype.m*
% - set the data type of a text string, where the data type can be: 
% logical,integer,float,char,string,categorical,datetime,duration  
%
% * *setExcNaN.m* 
% - callback function for button to set data selection to include 
% or exclude NaNs
% 
% * *setslider.m*
% - define slider range text and value for data selection uicontrol  
% 
% * *sortplots.m*
% - reorder plot handles so that the legend plots in sequence added
% 
% * *setPolar.m* 
% - callback function for button to set XY plot to be polar 
% instead of cartesian
%
% * *setXYorder.m*
% - callback function for button to switch X and Y data (eg on
% a UI selecting data for plotting)
%
% * *tablefigureUI.m*
% - generate tablefigure and add buttons and controls to edit and return
% updated table
% 
% * *test_utilfunctions.m*
% - functions to test utility functions
% 
% * *ts2_endpoints_in_ts1.m*
% - return indices in ts1 for end points of ts2 that fall within ts1
% if ts2 extends beyond ts1 returns the start and/or end of ts1
% 
% * *ts_interval.m*
% - find the time interval of a time vector based on selected method
% 
% * *uigetdate.m* 
% - date selection dialog box. From Matlab(TM) Forum, Elmar Tarajan (2021)
% https://www.mathworks.com/matlabcentral/fileexchange/8313-uigetdate.
% 
% * *var2range.m*
% - convert start and end variable to a range character array
% 
% * *var2str.m*
% - convert the input variable to a cell array of strings and return the 
% data type and format (for datetime and duration only) 
%
% * *wraptext.m*
% - wrap text to fit within a given graphical object (eg figure,panel,etc)

