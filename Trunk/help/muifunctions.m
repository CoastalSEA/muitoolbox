%% muifunctions
% Summary of functions available in muifunctions folder. Use the Matlab(TM)
% help function in the command window to get forther details of each
% function.

%%
% * *acceptfigure.m*
% - generate plot figure with buttons to accept/reject selection
% 
% * *acceptpanel.m**
% - create a yes/no panel within a figure
% 
% * *add_file_header.m*
% - function to add the same header to batch of user selected files
% 
% * *cellstruct2cell.m*
% - convert a struct of cell arrays of the same dimension, to a cell array
% with fields as the rows and cell entries as the columns
% 
% * *cellstruct2structarray.m*
% - convert a struct of cell arrays of the same dimension to a struct array
% with a set of fields for each entry in the cell array
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
% * *cmap_selection.m*
% - select a color map definition from Matlab(TM) default list and cbrewer
% generated mat files
% 
% * *copydata2clip.m*
% - copy data from the active figure or tab to the clipboard
% 
% * *editrange.m*
% - button callback function to edit range and enter in a text uicontrol
% 
% * *editrange_ui.m*
% - test whether Vin is datetime and if so use datepicker otherwise use  
% inputdlg to let user edit range values
% 
% * *getcolumnwidths.m*
% - find the extent of text in each column (including the header), and the
% row text (if included)
% 
% * *getdatatype.m*
% - find the data type of 'var', checks for:
%   logical,integer,float,char,string,categorical,datetime,duration  
% 
% * *getdateformat.m*
% - try to determine the datetime format of a text string
% 
% * *getdialog.m*
% - generate a message dialogue box with no buttons. Calls setDialog.m
% 
% * *getfiles.m*
% - call uigetfile and return one or more files
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
% * *getvariabledimensions.m*
% - find total number of dimensions for a variable in a table or dstable
% 
% * *getvarindices.m*
% - unpack the limits text and find indices of values that lie 
% within the lower/upper limits defined
% 
% * *getwidget.m*
% - widget for text,input uicontrol and control buttons (eg edit) 
% 
% * *godisplay.m*
% - display the legend name or DisplayName of the selected graphical object
% 
% * *inpaint_nans.m* from Matlab(TM) Forum
% - in-paints over nans in an array (Copyright  John D'Errico)
% 
% * *inputgui.m*
% - provides access to the inputUI class to generate a mutli control input
% user interface and return the selections made (can use inputUI.getUI
% instead)
% 
% * *inputUI.m*
% - creates a multi-field UI
% 
% * *isunique.m*
% - check that all values in usevals are unique
% 
% * *isvalidrange.m*
% - check user input is valid for the data type used and within bounds
% 
% * *mat2clip.m* from Matlab(TM) Forum
% - Copies matrix to system clipboard
% 
% * *mcolor.m*
% - select a default Matlab(TM) color definition from table
% 
% * *minmax.m*
% - find min and max of multidimensional numeric or ordinal array
% 
% * *num2duration.m*
% - convert a number to a duration based on specified
% 
% * *range2var.m*
% - convert range character array start and end variables
% 
% * *readinputfile.m*
% - read data from a file
% 
% * *rotatebutton.m*
% - callback for the rotate button on a figure or tab plot
% 
% * *scalevariable.m*
% - rescale a variable (vector or matrix) based on user selection
% 
% * *setactionbutton.m*
% - add an action button with callback to graphical object
% 
% * *setdatatype.m*
% - set the data type of a text string, where the data type can be: 
%   logical,integer,float,char,string,categorical,datetime,duration  
% 
% * *setdialog.m*
% - generate a dialogue with message and no buttons. Called by getDialog.m
% 
% * *setslider.m*
% - define slider range text and value for data selection uicontrol  
% 
% * *sortplots.m*
% - reorder plot handles so that the legend plots in sequence added
% 
% * *statictextbox.m*
% - create static text box with wrapped text to fit the number of lines
% if greater that nlines make box scrollable
% 
% * *str2duration.m*
% - convert a string created from a duration back to a duration
% 
% * *str2var.m*
% - Convert the input cell array of character vectors to an array of the 
% specified data type and using the given format if datetime or duration
% 
% * *tablefigure.m*
% - generate plot figure to show table with a button to copy to clipboard
% 
% * *tablefigureUI.m*
% - generate tablefigure and add buttons and controls to edit and return
% updated table
% 
% * *tabtablefigure.m*
% - generate figure with tabs to show set of tables 
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
% * *uigetdate.m* from Matlab(TM) Forum
% - date selection dialog box
% 
% * *var2range.m*
% - convert start and end variable to a range character array
% 
% * *var2str.m*
% - convert the input variable to a cell array of strings and return the 
% data type and format (for datetime and duration only) 

