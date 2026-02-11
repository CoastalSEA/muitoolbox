%% muiCatalogue
% Class to manage catalogue of classes held in the mui comprising both the
% catlogue record and the associated datasets.

%% Syntax
%%
%   muicat = muiCatalogue;

%% Description
% Imported and model data sets are all assigned to a handle in muiCatalogue
% which is in turn assigned to a handle in the main UI. 
%%
% Within UIs developed using the _muitoolbox_, the access syntax is as follows (see 
% <matlab:doc('muitoolbox') muitoolbox> for details of the main UI structure):
%%
%   mobj.Cases = muiCatalogue;  %the main UI holds an instance of muiCatalogue in the Cases property
%   mobj.Cases.Catalogue = dscatalogue;                   %catalogue table
%   mobj.Cases.DataSets.(classname)(classrec) = classobj; %an instance of a class
%%
% Note: _classrec_ is not the same as _caserec_. The former, _classrec_, is 
% an instance of a class where there can be multiple instances, whereas 
% _caserec_ is the current index in the Catalogue (which may change if
% cases are deleted). For models and data that are based on the muiDataSet
% abstract class, the CaseIndex property provides a unique identifier. The
% _case id_, _case record_ and _class record_ can be found from each other 
% using the following methods:
%%
%   caserec = caseRec(muicat,cobj.CaseIndex); %cobj is the instance of a Case
%   caseid = caseID(muicat,caserec);
%   classrec = classRec(muicat,caserec);

%%
% For further details on *caseRec* and *caseID* see the <matlab:doc('dscatalogue')
% dscatalogue> documentation. For *classRec* see below.

%% muiCatalogue properties
% * *Catalogue* inherited property from <matlab:doc('dscatalogue') dscatalogue>
% that holds the case index, description, class name and class type.
% * *DataSets* handle to dataset class instances, stored as a struct with the
% field names derived from the class names. 

%% muiCatalogue methods
% *setCase* add a case to the Catalogue and assign to DataSets. 
%%
%   setCase(muicat,cobj,varargin) %where varargin are as defined for addRecord method in dscatalogue

%%
% *getCase* retrieve the class instance, class record and catalogue record
%%
%   [cobj,classrec,catrec] = getCase(muicat,caserec)  %caserec is the current index of the record in the catalogue
  
%%
% *getCases* retrieve an array of objects held as DataSets based on
% _caserecs_.
%%
%   cobj = getCases(muicat,caserecs) %where caserecs is a list of index values

%% 
% *getDataSet* retrieve a case and return the selected dataset, the numeric
% case record id, the numeric dataset id and associated dataset name (the 
% dataset names are used in the Data property struct of class objects that 
% inherits <matlab:doc('muidataset') muiDataSet>.
%%
%   [dst,caserec,idset,dstxt] = getDataset(muicat,caserec,idset)
%%
% where the inputs value of _caserec_ can be the case desecription, or the
% case record number (not the CaseIndex), and _idset_ can be the dataset
% name, or the numeric dataset id.

%%
% *getProperty* extract data based on the selection made using a UI that
% inherits <matlab:doc('muidataui') muiDataUI> and provides the UIselection 
% struct. The UIselection struct defines the case, dataset, variable and
% subselections of the data based on any of the dimensions of the variable. 
% The _outopt_ input defines the format of the output, _props_. The
% options available include an 'array', 'table', 'dstable', a 'splittable' 
% (where the 2nd dimension has been split into variables), or a 'timeseries'
% data set to return a tscollection. 
%%
%   props = getProperty(muicat,UIsel,outopt);

%% 
% *selectCase* select a case to use with options to subselect, where
% _promptxt_ is the text to prompt user, _mode_ is 'single' or 'multiple'
% selection mode and _selopt_ is an option value from 0-3 (0 = no subselection, 
% 1 = subselect using class, 2 = subselect using type, 3 = subselect using
% both). Returns the case record ids for the selected cases and a check
% value of ok=1 for a correct selection and ok=0 if the user cancels.
%%
%   [caserec,ok] = selectCase(muicat,promptxt,mode,selopt);

%%
% *selectCaseObj* select a single case and return the class instance and
% the class record id, where _casetype_ and _classname_ can be used to 
% control the Case selection. They can be empty, or cell arrays of
% types/classes, e.g. [], or {'type1','type2'} and {class1'}. The _promptxt_
% input overides the default prompt of 'Select Case'. 
%%
%   [cobj,classrec] = selectCaseObj(muicat,casetype,classname,promptxt)  
%%
% Inputs for _casetype_, _classname_ and _promptxt_ are optional, or 
% empty, but must be included in order, e.g.:
%%
%   [cobj,classrec] = selectCaseObj(muicat);                %no sub-selection and default prompt
%   [cobj,classrec] = selectCaseObj(muicat,[],{'c1','c2'}); %selection uses classes c1 and c2 and default prompt

%%
% *selectCaseDatasetRow* select a row from a Dataset of a Case and return
% the class instance and class record id and the row id. The call is
% similar to *selectCaseObj* above, with the optional addition of the id of
% the dataset in the Data struct. If this is omitted and there is more than
% one dataset the user is prompted to select a dataset.
%%
%   [cobj,classrec,irow] = selectCaseDatasetRow(muicat,casetype,classname,promptxt,itable);

%%
% *selectCaseDataset* select a case and and dataset and return the class
% instance, the class record id, datesetnames and the id of the selected
% dataset, where _casetype_ and _classname_ can be used to control the 
% Case selection and _promptxt_ is used as a prompt for case selection.
%%
%   [cobj,classrec,datasets,idd] = selectCaseDataset(muicat,casetype,classname,promptxt);

%%
% *selectCaseDatasetVariable* prompt user to select a Case, Dataset (if not specified) and 
% a variable, return instance and variable id. All inputs except muicat are
% optional. if unspecified pass as []
%%
%   [cobj,classrec,dsname,ivar] = selectCaseDatasetVariable(muicat,casetype,classname,promptxt,idd);
%   cobj = selectCaseDatasetVariable(muicat);
%   [cobj,classrec] = selectCaseDatasetVariable(muicat,[],classname);
                                            
%%
% *selectDataset* select a dataset table to use for a given class
% instance, cobj. Returns dataset name, dsname, and index, idd.
%%
%   [dsname,idd] = selectDataset(muicat,cobj);

%%
% *useCase* select which existing data set to use and pass to another
% method, where _mode_ is 'none', 'single' or 'multiple'
% selection mode, _classname_ is the name of the class object to be used to
% call the method defined by the character vector in _action_. If the
% _mode_ is 'single' or 'multiple', the user selects a case from a list. If
% the _mode_ is 'none' the _action_ is assumed to be a static method and is
% called using (_classname_).(_action_). The method uses the Matlab function
% <matlab:doc('str2func') str2func> to call function defined by _action_.
%%
%   useCase(muicat,mode,classname,action);

%%
% *updateCase* update the saved record with a new version of the class 
% instance, where _cobj_ is the new class instance, _classrec_ is the id of
% the instance to be updated and _ismsg_ is a logical flag which true if a
% message is to be displayed upon completion.
%%
%   updateCase(obj,cobj,classrec,ismsg)

%%
% *addVariable2CaseDS* add a variable to an existing Case dataset in the
% Catalogue, where _caserec_ is the existing record to use, _newvar_ is the
% data for the variable to be added and _dsp_ is a
% <matlab:doc('dsproperties') dsproperties>, template for the variable being added. 
% The user is prompted to edit the variable definition before it is added
% as a new variable to an existing <matlab:doc('dstable') dstable> dataset.
%%
%   addVariable2CaseDS(muicat,caserec,newvar,dsp)

%%
% *activateTables* activates the dynamic properties of all the tables held
% as Cases in the Catalogue. When a <matlab:doc('dstable') dsctable> is loaded the dynamic
% properties need to be restored. Calls the dstable function _activatedynamicprops_
% which initialises the dynamic properties for the variables in the
% dstable. This is useful when loading classes that contain dstables from 
% a file. It is used by the _loadModel_ function in <matlab:doc('muimodelui') muiModelUI>.
%%
%   activateTables(muicat)

%%
% *classRec* find the class record number using the case record  in the
% Catalogue Case list, where _caserec_ is the existing record to use.
%%
%   classrec = classRec(muicat,caserec);

%%
% *modifyVariableType* select a variable and modify that data type of the variable
% used mainly to make data catagorical or ordinal
%%
%   modifyVariableType(muicat)

%%
% *setDataClassID* set the index for a new instance of class held in
% DataSets, where _classname_ is the name of the class to use.
%%
%   id_class = setDataClassID(muicat,classname);

%%
% *setPropsStruct* initialise struct used in getProperty
%%
%   props = setPropsStruct(muicat);

%% muiCatalogue methods used in the default Project menu
% The example interface provided in <matlab:doc('modelui') ModelUI>
% uses a number of tools that manipulate Cases held in muiCatalogue. These
% are accessed from the Project>Cases menu, which is standard for most Apps.

%%
% *editCase* edit Case description of the selected case. Calls _editRecord_
% in <matlab:doc('dscatalogue') dscatalogue> to update the catalogue and
% updates the Description property in any dstables held in the Case
% DataSets property.
%%
%   editCase(muicat,caserec);          %caserec is optonal

%%
% *saveCase* writes the results for a selected case to an Excel file, or as 
% dstable or table in a mat file. The Excel option is only available if the
% variables are column vectors (e.g. function of time).
% The _caserec_ input is optional and if it is not defined the user 
% is prompted to select a case.
%%
%   saveCase(muicat,caserec);          %caserec is optonal

%%
% *deleteCases* select one or more records and delete records from catalogue 
% and class instances. The _caserec_ input is optional and if it is not 
% defined the user is prompted to select case(s).
%%
%   deleteCases(muicat,caserec);       %caserec is optonal

%%
% *reloadCase* reload model input variables as the current settings. Where
% _mobj_ is a handle to the main UI and _caserec_ is optional and if it 
% is not defined the user is prompted to select a case.
%%
%   reloadCase(muicat,mobj,caserec);   %caserec is optonal 

%%
% *viewCaseSettings* view the saved input data for a selected Case. Where
% _caserec_ is optional and if it is not defined the user is prompted to 
% select a case.
%%
%   viewCaseSettings(muicat,caserec)   %caserec is optonal

%%
% *importCase* import a case from a mat file that was saved using exportCase
%%
%   importCase(muicat);

%%
% *exportCase* save selected case to a mat file. The _caserec_ input is 
% optional and if it is not defined the user is prompted to select a case.
%%
%   exportCase(muicat,caserec);        %caserec is optonal

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>, <matlab:doc('muidataset') muiDataSet>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dscatalogue') dscatalogue>.