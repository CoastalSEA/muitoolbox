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
% *getDataSetName* - check whether there is more than one dstable
% and prompts user to select if there is. Options to provide a suitable
% prompt, _promptxt_ and define whether select multiple or single datasets,
% _selectmode_.
%%
%   datasetname = getDataSetName(obj,promptxt,selectmode);   %obj is a class instance, promptxt and selectmode are optional

%%
% *selectClassInstance* - Prompt to select a class instance from an array 
% of class instances held in obj. Filter based on a class
% property is optional, where propname is the class property to test and 
% propvalue is the value to match. Returns class instance and selected 
% dataset. Flag ok=1 if successful and ok =0 if user cancels selection.
% 
%%
%   [cobj,dst,ok] = selectClassInstance(obj,propname,propvalue);

%%
% *getClassInstances* - get the class indices for the instances in an array 
% of class instances, obj, where the class property name, propname (as a character 
% vector), matches propvalue (propvalue can be a numeric or logical array,
% or a cell array of character vectors, or a string array - similar to 
% Matlab(TM) <matlab:doc('ismember') ismember>)
%%
%   caseidx = getClassInstances(obj,propname,propvalue);

%%
% *readTSinputFile* - uses Matlab detectImportOptions to decipher the header and read the
% data into a table, where the columns use the variable names in file (if
% defined). Checks are made to ensure that no times are duplicated and the data
% are standardised so that missing times are removed and missing data are set to NaN
% Time MUST be first column in table to use this function.
%%
%   data = readTSinputFile(obj,filename);  %returns a table of data read from filename

%% Creating a class using muiPropertyUI
% A template to create a class that uses muiPropertyUI can be found in the 
% <matlab:mui_template_folder muitemplates folder>. The template provides the code for a subclass
% and the comments highlight where the file needs to be edited to adapt 
% the template to a new application, as explained further in the 
% <matlab:doc('muitbx_gettingstarted') Getting Started> documentation.

%% muiUserData format file
% Data import into a _muitoolbox_ UI using _muiUserData_ and classes that
% inherit <matlab:doc('muidataset') muiDataSet> requires a format file to
% be created. A template is provided in the <matlab:mui_template_folder muitemplates folder>. 
% and sets out the code for each of the functions requied, with comments to
% highlight where the files need to be edited to adapt the templates to 
% a different application. The format file has the following form:
%
% <include>../muitemplates/dataimport_format_template.m</include>

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muicatalogue') muiCatalogue>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.
 