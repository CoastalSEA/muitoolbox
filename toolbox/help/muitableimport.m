%% muiTableImport
% Class to import tabular data sets from text files, mat files or spreadsheets, 
% adding the results to a dstable and a record in the muiCatalogue.

%% Syntax
%%
%   muiTableImport.loadData(muicat); %where muicat is the App object catalogue; e.g. mobj.Cases

%% Description
% The class is used for importing tabular datasets from a text file, a
% spreadsheet, or an existing table or dstable in a mat file. The class 
% inherits the <matlab:doc('muidatadet') muiDataSet> abstract class.

%% muiDataSet properties
% The class inherits the <matlab:doc('muidataset') muiDataSet> properties 
% for Data, RunParam, MetaData and CaseIndex.

%% muiTableImport methods
% Methods for loading, adding, deleting data are as follows
%%
% * *loadData* - static method to load data from file.
% * *addRows* - add additional rows to an existing user dataset. Data can be 
% loaded from a table or spreadsheet but the number of variables should be 
% the same as the existing dataset.
% * *addVariables* - add additional variables to an existing user dataset. 
% Data can be loaded from a table or spreadsheet but the number of rows 
% should be the same as the existing dataset.
% * *addDataset* -add additional dataset to an existing case record. The 
% dataset is loaded using the same process as used to load  the initial dataset. 
% * *delRows* - delete rows from a dataset.
% * *delVariables* - delete variable from a dataset.
% * *delDataset* - delete a dataset.
% * *tabPlot* - generate a plot for display on Q-Plot tab.
% * *tabTable* - generate a table for display on the Table tab.

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muidatadet') muiDataSet>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>,