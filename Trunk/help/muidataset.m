%% muiDataSet
% Abstract class with properties and methods to manipulate datasets for use
% in applications that import data, or save model ouput.

%% Description
% muiDataSet is used as a superclass to provide data handling 
% functionality for classes that import different types of data or models
% that need to store outputs in a consistent and documented format.

%% muiDataSet properties
% * *Data* - struct of datasets. These can be multiple dstables, or a mix of 
% tables and other data types. The data are indexed using the fieldnames
% of the struct.
% * *RunParam* - instance of run parameter classes defining settings used.
% * *MetaData* - property for user defined input.               
% * *DataFormats* - cell array of data formats available.
% * *idFormat* - class instance file format index.
% * *FileSpec* - cell array of the parameters used to load a file: { _MultiSelect_ (on/off),
% _FileType_}. where _MultiSelect_ defines whether single or multiple
% selection is allowed and _FileType_ determines the fie extensions to be
% shown in the file selection dialog.

%% muiDataSet abstract methods
% *tabPlot* is an abstract method that must be implemented in classes that inherit 
% muiDataSet. Used to generate a plot for display on Q-Plot tab. The default
% version of this method can call _tabDefaultPlot_ in muiDataSet which
% provides with a basic set of plotting tools to handle 2D and 3D data.

%% muiDataSet methods
% Methods for loading, adding, deleting and applying quality to control to
% datasets.
%%
% *loadData* - set up a new dataset by loading data from a file. The input
% _muicat_ is a handle to a muiCatalogue instance and classname is the name 
% of the class to use for the dataset being loaded. 
%%
%   loadData(muicat,classname);

%%
% *addData* - add additional data to an existing dataset, where _obj_ is an
% instance of a class that uses muiDataSet, _classrec_ is the id of the
% record in the class handle, _catrec_ is the Catalogue record for the
% selected case and _muicat_ is a handle to a muiCatalogue instance.
%%
%   addData(obj,classrec,catrec,muicat); 

%% 
% *deleteData* - delete variable or rows from a dataset, where _obj_ is an
% instance of a class that uses muiDataSet, _classrec_ is the id of the
% record in the class handle, _catrec_ is the Catalogue record for the
% selected case and _muicat_ is a handle to a muiCatalogue instance.
%%
%   deleteData(obj,classrec,catrec,muicat);

%%
% *qcData* - apply quality control to a dataset, where _obj_ is an
% instance of a class that uses muiDataSet, _classrec_ is the id of the
% record in the class handle, _catrec_ is the Catalogue record for the
% selected case and _muicat_ is a handle to a muiCatalogue instance.
%%
%   qcData(obj,classrec,catrec,muicat);  %catrec not used

%%
% *getDataSetName* - check whether there is more than one dstable and select
%%
%   datasetname = getDataSetName(obj);   %obj is a class instance

%%
% *readTSinputFile* - uses Matlab detectImportOptions to decipher the header and read the
% data into a table, where the columns use the variable names in file (if
% defined). Checks are made to ensure that no times are duplicated and the data
% are standardised so that missing times are removed and missing data are set to NaN
% Time MUST be first column in table to use this function.
%%
% data = readTSinputFile(obj,filename);  %returns a table of data read from filename

%% muiUserData format file
% Data import into a _muitoolbox_ UI using _muiUserData_ and classes that
% inherit <matlab:doc('muidatadet') muiDataSet> requires a format file to
% be created. A template is provided in the muiTemplates folder, which sets 
% out the code for each of the functions requied, with comments to
% highlight where the files need to be edited to adapt the templates to 
% a different application. The format file has the following form:

% <include>../muiTemplates/dataimport_format_template.m</include>

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muicatalogue') muiCatalogue>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.
 