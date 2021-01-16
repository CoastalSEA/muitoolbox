classdef muiDataSet < handle
%
%-------class help------------------------------------------------------
% NAME
%   muiDataSet.m
% PURPOSE
%   Abstract class for handling all types of data set (eg imported or 
%   model data) which are loaded into a dstable.
% NOTES
%   muiDataSet is used as a superclass to provide data handling 
%   functionality for classes that import different types of data or models
%   that need to store outputs in a consistent and documented format
% SEE ALSO
%   see test_dstoolbox.m for examples of usage
%
% Author: Ian Townend
% CoastalSEA (c) Sep 2020
%--------------------------------------------------------------------------
%       
    properties  
        Data        %cell array of datasets. These can be multiple dstables, 
                    %or a mix of tables and other data types. The data are 
                    %indexed using the MetaData property.
        RunParam    %instance of run parameter classes defining settings used
        MetaData    %cell array of names for the datasets held in data. 
                    %Implementing classes need to define a name for each
                    %type of output data.                     
        %Note: dstables have constant dimensions for all variables in table.
        %      Variables with different dimensions should be stored in 
        %      seperate dstables. Variables with time-varying dimensions 
        %      should store the dimensions as variables.
    end
    
    properties (Hidden, SetAccess=private)
        CaseIndex   %case index assigned when class instance is loaded
    end
    
    methods (Abstract)    
        %methods that all subclasses must define
        tabPlot(obj)     %define how data should be displayed on tab
                         %when called by UI Plot tab
    end 
%%






%--------------------------------------------------------------------------
%   Methods to set and get a DataSet
%--------------------------------------------------------------------------     
    methods (Access=protected)
      
%         function setDSproperties(obj)
%             %assign the empty DSproperties stuct
%             % var.Names  - names used in tscollection/table to label variables
%             % var.Descriptions - description of variables used in data access UIs
%             % var.Units  - variable units 
%             % var.Labels - axis labels for results
%             
%             % row.Description - description for RowNames in table (usually Time but
%             %              rows can be any unique descriptor)              
%             % row.Unit   - units of row data > MAY DUPLICATE FORMAT???
%             % row.Label  - axis labels for use with row data 
%             % row.Format - time format to use when saving time data
%             %              formats can be durations: y,d,m,s 
%             %              or datetime: dd-MMM-uuuu HH:mm:ss 
%             
%             % dim.Fields - stuct name used for dimensions?????
%             % dim.Descriptions - description to be used for x, y and z co-ordinates
%             % dim.Units  - units for the defined co-ordinates
%             % dim.Labels - axis labels for use with XYZ data
%             
%             
%             %NEED TO CHANGE THESE AS NO LONGER IN dsproperties
%             % dim.Default- x-axis for XY plots ('Time' or 'X', 'Y', 'Z' or 'C')
%             %              where C is for categorical data
%             
%             % additionalOutVar - property names for additional outputs
%             % dataType - data type (model, data, etc for partitioning tab display)
%             % outputStyle - used to write results to Excel spreadsheet
%             %               'Single'-all variables on one sheet
%             %               'Multiple'-Xdata and one variable per spreadsheet                       
%             obj.DSproperties = struct('var',[],'row',[],'dim',[],...
%                                    'additionalOutVar',{''},...
%                                    'dataType',{''},'outputStyle',{''});
%             obj.DSproperties.var = struct('Names',{''},'Descriptions',{''},...
%                                    'Units',{''},'Labels',{''});
%             obj.DSproperties.row = struct('Description',{''},...
%                                    'Unit',{''},'Label',{''},'Format',{''});
%             obj.DSproperties.dim = struct('Fields',{''},'Descriptions',{''},...
%                                    'Units',{''},'Labels',{''},'Default',{''});
%         end
%%
%         function setDataSet(obj,varargin)
%             %set a Dataset to the correct instance (id_class)
%           %varargin - options to pass dsproperties, create new or add to
%           %existing, etc
%             %what should this do if DataSet is self contained?
%             %'SetType','new, creates a new class instsnce, 'add' adds
%             %variable to existing dstable NB must have the same row
%             %definition and length. Variable description is the case
%             %description and a derived Variable name is added. When adding
%             %the exiting dscatalogue record should be used.
%         end      
    end  
%%
    methods
        
%         function set.RunParam(obj,runprops)
%         end
%         
%         function runprops = get.RunParam(obj)
%         end
        
%         function set.ClassIndex(obj,caseid)
%             %set the class index for a new instance
%             %obj is handle to class instance  
%             obj.ClassIndex = caseid;
%             fprintf('set class index %d',caseid)
%             %check if besoke code is actually needed
%             %obj.ClassIndex = caseid;
%         end
%%        
%         function classrec = get.ClassIndex(obj)
%             %set the class index for a new instance
%             %obj is handle to class instance
%             classrec = obj.ClassIndex;
%             fprintf('get class index %d',classrec)
%             %see what this does without bespoke code. If does not work for
%             %multiple instances of obj then use code below
% %             nclass = length(obj);
% %             classid = zeros(1,nclass);
% %             for i=1:nclass
% %                 classid(i) = obj(i).ClassIndex;
% %             end
% %             classrec = find(classid==caseid);
%         end
%%        
% function set.Collection(obj,dst)
%     
% end
% function dsc = get.Collection(obj)
%     
% end

%%
        function setRunParam(obj,mobj)
            %assign the run prarameters needed for a model or the file name for
            %imported data sets
            classname = metaclass(obj).Name;
            minp = mobj.ModelInputs.(classname);
            for i=1:length(minp)
                obj.RunParam.(minp{i}) = copy(mobj.Inputs.(minp{i}));
            end
        end
%%
        function setDataRecord(obj,muicat,dataset,datatype)
            %assign data to class Data property and update catalogue
            classname = metaclass(obj).Name;
            if iscell(dataset)
                obj.Data = dataset;   %can be cell arry of multiple tables
            else
                obj.Data = {dataset};  
            end
%             numdata = length(dataset);
            %add the run to the catalogue and update mui.Cases.DataSets
            caserec = addRecord(muicat,classname,datatype);
            casedef = getRecord(muicat,caserec);
            obj.CaseIndex = casedef.CaseID;
            obj.Data{end}.Description = casedef.CaseDescription;
            if isempty(muicat.DataSets) || ~isfield(muicat.DataSets,classname) ||...
                    isempty(muicat.DataSets.(classname))
                idrec = 1;
            else
                idrec = length(muicat.DataSets.(classname))+1;
            end
            muicat.DataSets.(classname)(idrec) = obj;
        end
        
        
        
%         function classrec = getClassIndex(obj,caseid)
%             %find the record id of an instance in a class array using the
%             %CaseIindex
%             classname = metaclass(obj).Name;
%             
%         end




%  %%OLD CODE *************************************>       
%         function sdsc = setCollection(obj,VarData,varargin)
%             %create a table or tscollection and add variables and metadata
%             %variable names are defined as part of ResDef in the data or
%             %model class properties and constructor (dobj)
%             %obj - an instance of a data class (i.e. classobj(id_class))
%             %VarData - column data to be loaded. Can be a cell array if
%             %          data type is not the same for all variables 
%             %Time    - for a tscollection, Time MUST be a datetime array
%             %          for a table
%             %dimData - position variables, one or more of which may be the
%             %          dependent variable (and may include numeric time)
%             %rowNames- char array to describe each row of data (optional)
%             %          must be a cell array with same length as the data 
%             %call: sdsc = setCollection(obj,VarData,'Time',time,...
%             %                        'xyzData',xyzdata,'rowNames',rownames)
%             ncol = length(obj.DSproperties.var.Names);
%             inprops.Time = 0;
%             inprops.dimData = [];
%             inprops.rowNames = '';
%             inprops.metaData = repmat({''},1,ncol); 
%             varVars = {'dimData','rowNames','metaData'};
%             if nargin>2
%                 for k=1:2:length(varargin)
%                     if contains(varargin{k},varVars)
%                         inprops.(varargin{k}) = varargin{k+1};
%                     else
%                         warndlg('Unknown variable in setCollection')
%                         sdsc = [];
%                         return;
%                     end
%                 end                  
%             end
% 
%             %check that the Name list matches the size of Data
%             sdsc = setDScollection(obj,VarData,inprops);
%         end
% %%
%         function dsc = setDScollection(obj,VarData,inprops)
%             %load data into a dscollection table
%             dsc = dscollection;   
%             %find the number of variables to load
%             if iscell(VarData) || ismatrix(VarData)                                
%                 nvar = size(VarData,2);
%             else
%                 nvar = 1;
%             end
%             %check that there are enough variable names
%             nvarnames = length(obj.DSproperties.var.Names);
%             if nvarnames<nvar 
%                 warndlg('Insufficient variable names in DSproperties');
%                 dsc = [];
%                 return;
%             end
%             %
%             for i=1:nvar
%                 if iscell(VarData)       %cells can be vectors, arrays or char
%                     vdata = VarData{i};
%                 elseif ismatrix(VarData) %matrix used for collection of vectors                    
%                     vdata = VarData(:,i);%e.g. for 2D array with x-var or t-var data 
%                 else                     
%                     vdata = VarData;     %vector variable
%                 end
%                 %check that name is a valid Matlab identifier
%                 varname = matlab.lang.makeValidName(obj.DSproperties.var.Names{i},...
%                                         'ReplacementStyle','delete');
%                 dsc.DataTable.(varname)= vdata;
%             end  
%             
%             %assign row data if included
%             isvalidrow = length(inprops.rowNames)==size(vdata,1) && ...
%                                             isunique(obj,inprops.rowNames);                
%             if ~isempty(inprops.rowNames) && isvalidrow
%                 dsc.RowNames = inprops.rowNames;
%             elseif ~isempty(inprops.rowNames) && ~isvalidrow
%                 msg1 = 'RowNames NOT added to dscollection';
%                 msg2 = 'RowNames must be same length as data and ';
%                 msg3 = 'define each row using distinct non-empty values';
%                 warndlg(sprintf('%s\n%s\n%s',msg1,msg2,msg3));
%             end
%             
%             %now assign metadata from DSproperties to the dsc
%             dsc = dsproperties2dscollection(obj,dsc,inprops);
%         end
%%
%         function dsc = dsproperties2dscollection(obj,dsc,inprops)
%             
%             %SORT OUT WHETHER THIS SHOULD BE DSCOLLECTION (INCLUDING
%             %METATDATA) OR DSTABLE? SHOULD DSTABLE ACCEPT dsproperties
%             %object as input?
%             
%             %assign metadata in DSproperties to properties of dstable
%             % obj - instance of a dscollection subclass
%             % dsc - dscollection to be updated
%             % inprops - additional props defined in call to setCollection
%             % NB: uses short names (var,row,dim) in DSproperties to sort
%             
%             if nargin<3  %allows function to be used to just load DSproperties
%                 inprops.dimData = [];  
%             end
%             %
%             dscproperties = sort(properties(dsc));
%             dspropnames = fieldnames(obj.DSproperties);
%             isshortnames = find(cellfun(@length,dspropnames)<=3);
%             for i=isshortnames'
%                 subnames  = fieldnames(obj.DSproperties.(dspropnames{i}));
%                 for j = 1:length(subnames)
%                     if strcmp(subnames{j},'Names'), continue; end
%                     switch dspropnames{i}                        
%                         case 'dim'
%                             subpropname = ['Dimension',subnames{j}];                            
%                         case 'row'                            
%                             subpropname = ['Row',subnames{j}]; 
%                         case 'var'
%                             subpropname = ['Variable',subnames{j}];
%                     end
%                     idv = strcmp(dscproperties,subpropname);
%                     if any(idv)
%                         dsc.(dscproperties{idv}) = ...
%                            obj.DSproperties.(dspropnames{i}).(subnames{j});
%                     end
%                 end
%             end
%             if ~isempty(obj.DSproperties.row.Field)
%                 dsc.DimensionNames{1} = obj.DSproperties.row.Field{1};
%             end
%             %handle other DSproperties data
%             obj.MetaData.DataType = obj.DSproperties.dataType;
%             obj.MetaData.OutputStyle = obj.DSproperties.outputStyle;
%             obj.MetaData.DefaultDimension = obj.DSproperties.dim.Default;            
%             %handle inprops with dimensions and metadata
%             for k=1:length(inprops.dimData)
%                 if isempty(obj.DSproperties.dim.Fields)
%                     FieldName = sprintf('D%d',k);
%                 else
%                     FieldName = obj.DSproperties.dim.Fields{k};
%                 end
%                 dsc.Dimensions.(FieldName) = inprops.dimData{k};                                                                                                    
%             end
%             dsc.MetaData = inprops.metaData;
%         end

%%  NEED TO DETERMINE WHAT OF THE FUNCTIONS BELOW ARE REALLY NEEDED
%--------------------------------------------------------------------------
%   Methods for subclasses to load and add data
%--------------------------------------------------------------------------

        function classhandle = loadData(classname,classhandle)
            %load user data set from one or more files
            % classname - name of class to be loaded
            % classhandle - handle to existing class object (may be empty)
            if nargin<2
                classhandle = [];
            end
            
            isnew = true;
            if ~isempty(classhandle)
                newflg = questdlg('Create a new data definition?','Load data',...
                                                        'Yes','No','No');
                if strcmp(newflg,'No'), isnew = false; end                                    
            end

            heq = str2func(['@ ',classname]);
            newobj = heq();  %instance of class object

            [classobj,id_class] = setDataClassID(newobj,classhandle);  

            localObj = classobj(id_class);  %instance to be used for new data
            %check whether ResDef is defined and if not load definition
            
            if isempty(localObj.DSproperties.var.Names)                
                %models define DSproperties when run so already defined
                %imported data calls function getDSproperties in format file
                localObj.idFormat = setImportFormat(classobj,id_class,isnew);
                if isempty(localObj.idFormat), return; end
                %
                localObj = callFileFunction(localObj,'getDSproperties');
                if isempty(localObj), return; end
                
                %possibly call loadTSDataSet here for multiple timeseries
                %files
            else
                %load the model data
                %possibly use loadDSDataSet for models and non-timeseries
                
            end
            
            id_rec = 1;  %first data in new data set
            localObj = loadDSDataSet(localObj,id_rec);
            if isempty(localObj), return; end
            
            %save data set
            classobj(id_class) = localObj;
            classhandle = classobj;
%             mtxt = 'Data successfully loaded';
%             setDataSet(localObj,mobj,h_data,id_class,id_rec,mtxt);
        end
% %%
%         function [fname,path,nfiles] = getfiles(mflag,filetype)
%             %ask for filename(s)- multiple selection allowed if mflag='on'
%             %function is static so that it can be called without obj
%             userprompt = 'Select data file(s)>';
%             [fname, path]=uigetfile(filetype,userprompt,'MultiSelect',mflag);
%             %get number of files if multiple selection
%             if iscell(fname)
%                 nfiles = length(fname);
%             else
%                 if fname==0 %user has cancelled - no file selected
%                     nfiles = 0;
%                 elseif strcmp(mflag,'on')   %if multiple select
%                     nfiles = 1;
%                     fname = cellstr(fname); %return fname as a cell array
%                 else
%                     nfiles = 1;             %fname is a character array
%                 end
%             end
%         end 
    end
%%
    methods
        function obj = loadDSDataSet(obj,irec)
            %load first time series (or set of variables with common time)
            %obj - instance of a DataSet class object
            %irec - id of record in class object
            ismodel=false;

            formatxt = sprintf('Files %s',obj.FileFormats);
            filetype = {obj.FileFormats,formatxt};
            [fname,path,nfiles] = getfiles('on',filetype);
            if nfiles==0, return; end

            hw = waitbar(0, 'Loading data. Please wait');
            %load first file and create master collection
            obj.filename = [path fname{1}];
            
            %if imported else model
            if ismodel
                
            else
                obj = callFileFunction(obj,'getDSdata');
                if isempty(obj), return; end
            end    
            
            if isempty(obj.sdsc)
                close(hw);
                return;
            else
                obj.DataSets{irec} = obj.sdsc;  
            end
            %now load any other files (they need to be in time order)
            if nfiles>1
                for jf = 2:nfiles
                    jf_file = fname{jf};
                    obj.filename = [path,jf_file];
                    obj = callFileFunction(obj,'getDSdata');
                    if ~isempty(obj.stsc)
                        obj.DataSet{irec} = vertcat(obj.DataSet{irec},obj.stsc);
                    end
                    waitbar(jf/nfiles)
                end
            end
            close(hw);
        end         
%%        
        function obj = callFileFunction(obj,funcall)
            %call external function used to load data fo defined format
            %funcall - function in data format function
            %compile handle to anonymous function
            dataformat = obj.DataFormats{obj.idFormat,2};
            heq = str2func(['@(obj,funcall) ',[dataformat,'(obj,funcall)']]);                  
            try
                obj = heq(obj,funcall);
            catch
                warndlg(sprintf('Unable to run %s using %s',funcall,dataformat));
                obj = [];
                return;
            end            
        end
%%        
        function [classobj,id_class] = setDataClassID(newobj,classobj)
            %assign the class instance and record ids and add new instance
            %to class handle. 
            % obj - new instance of class, 
            % classobj class handle
            if isempty(classobj)
                id_class = 1;
                classobj = newobj;                
            else
                id_class = length(classobj)+1;
                classobj(id_class) = newobj;      %assign new class object
            end                      
        end
%%
        function selection = setImportFormat(classobj,id_class,isnew)
            %prompt user to select a file format for importing data
            % classobj - class object 
            % id_class - id of new instance
            % isnew - true indicates that a new instance is to be created
            % selection - user file format selection id
            newobj = classobj(id_class);
            nformats = size(newobj(1).DataFormats,1);
            if (isnew || size(classobj,2)>1) && nformats>1 
                %no selection or multiple definitions already used
                [selection,ok] = listdlg('PromptString','Select a file format',...
                    'SelectionMode','single',...
                    'ListSize',[300,100],...
                    'ListString',newobj(1).DataFormats(:,1));
                if ok<1
                    selection = [];
                    return; 
                end
            elseif nformats==1 %only one selection available
                selection = 1;
            else  %use existing definition when only one defined
                selection = classobj.idFormat;
            end
        end        
        
%%
%         function [header,data] = readInputFile(obj,nhead,dataSpec)
%             %generic function to read data from a file
%             %obj - an instance of a data class (i.e. classobj(id_class))
%             %nhead - number of header lines
%             %dataSpec - defines read format (not required if defined in header)
%             header = ''; data = [];
% 
%             if nhead==0 && (nargin<3 || isempty(dataSpec))
%                 warndlg('Define read format in call to readInputFile using dataSpec');
%                 return
%             end
%             %
%             if nargin<3
%                 dataSpec = [];
%             end
%             
%             %open file
%             fid = fopen(obj.filename, 'r');
%             if fid<0
%                 errordlg('Could not open file for reading','File write error','modal')
%                 return;
%             end
%             
%             %read header and data as required
%             if nhead>0
%                 for i=1:nhead
%                     header{i} = fgets(fid); 
%                 end
%             end
%             
%             if isempty(dataSpec)
%                 dataSpec = header{1}; %format spec MUST be on first line
%             end
%             %read numeric data            
%             data = textscan(fid,dataSpec);
%             if isempty(data)
%                 warndlg('No data. Check file format selected')
%             end
%             fclose(fid);
%         end  
%--------------------------------------------------------------------------
% Other functions
%--------------------------------------------------------------------------  
%         function answer = isunique(~,usevals)
%             %check that all values in usevals are unique
%             if isdatetime(usevals) || isduration(usevals)
%                 usevals = cellstr(usevals);
%             end
%             [~,idx,idy] = unique(usevals,'stable');
%             answer = numel(idx)==numel(idy);
%         end
    end
end