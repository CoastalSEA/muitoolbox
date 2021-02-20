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
        CaseIndex       %case index assigned when class instance is loaded
    end
    
    properties (Transient, Access=protected) 
        sdsc            %Transient dataset from individual files 
                        %that are combined to form master ts collection
        DataFormats     %cell array of data formats available 
        idFormat        %class instance file format               
    end
    
    methods (Abstract)    
        %methods that all subclasses must define
        tabPlot(obj)    %define how data should be displayed on tab
                        %when called by UI Plot tab
    end 
%%
%--------------------------------------------------------------------------
%   Methods to set a DataSet and RunParam
%--------------------------------------------------------------------------     
    methods (Access=protected)
        function setRunParam(obj,mobj)
            %assign the run parameters needed for a model
            classname = metaclass(obj).Name;
            minp = mobj.ModelInputs.(classname);
            for i=1:length(minp)
                obj.RunParam.(minp{i}) = copy(mobj.Inputs.(minp{i}));
            end
        end
%%
        function setDataSetRecord(obj,muicat,dataset,datatype)
            %assign dataset to class Data property and update catalogue
            classname = metaclass(obj).Name;
            if iscell(dataset)
                obj.Data = dataset;   %can be cell arry of multiple tables
            else
                obj.Data = {dataset};  
            end

            %add record to the catalogue and update mui.Cases.DataSets
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
    end
%%        
        
        
%         function classrec = getClassIndex(obj,caseid)
%             %find the record id of an instance in a class array using the
%             %CaseIindex
%             classname = metaclass(obj).Name;
%             
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


%%  NEED TO DETERMINE WHAT OF THE FUNCTIONS BELOW ARE REALLY NEEDED
%--------------------------------------------------------------------------
%   Methods for subclasses to load and add data
%--------------------------------------------------------------------------
    methods (Static)
        function loadData(mobj)
            %load user data set from one or more files
            muicat = mobj.Cases;
%             classname = 'UserData';
%             if ~isempty(mobj.ImportClasses)
%                 dataclasses = [mobj.ImportClasses,'Generic'];
%                 promptxt = 'Select which Data Class to use:';
%                 [sel,ok] = listdlg('PromptString',promptxt,'ListSize',[300,100],...
%                             'SelectionMode','single','ListString',dataclasses);                    
%                 if ok<1, return; end    %user cancelled       
%                 classname = dataclasses{sel};
%             end
            
                
            setDataSetRecord(obj,muicat,dataset,'data')
            DrawMap(mobj);
        end
%%
        function addData(mobj)
            %add additional data to an existing user dataset
            
            [lobj,classrec,~]  = selectCase2Use(mobj,'single');
            if isempty(lobj), return; end
            
            
            updateSelectedCase(lobj,mobj,classrec);
        end        
%%
        function deleteData(mobj)
            %delete variable or rows from a dataset
            
            [lobj,classrec,~]  = selectCase2Use(mobj,'single');
            if isempty(lobj), return; end
            
            updateSelectedCase(lobj,mobj,classrec);
        end
%%
        function qcData(mobj)
            %apply quality control to a dataset
            [lobj,classrec,~]  = selectCase2Use(mobj,'single');
            if isempty(lobj), return; end
            
            updateSelectedCase(lobj,mobj,classrec);
        end
%%
        function [cobj,classrec,catrec]  = selectCase2Use(mobj,mode)
            %select which existing data set to use
            cobj = []; classrec = []; catrec = [];
            muicat = mobj.Cases;      
            promptxt = 'Select Case to use:';
            [caserec,ok] = selectRecord(muicat,'PromptText',promptxt,...
                'SelectionMode',mode,'CaseType','data','ListSize',[250,200]);
            if ok<1, return; end  
            [cobj,classrec,catrec] = getCase(muicat,caserec);
        end
    end
    
    methods
        function updateSelectedCase(obj,mobj,classrec)
            %update the save record with the amended version of instance
            classname = metaclass(obj).Name;
            mobj.Cases.DataSets.(classname)(classrec) = obj;
            DrawMap(mobj);
        end
%%
        function old
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
        function selection = setImportFormat(obj,id_class,isnew)
            %prompt user to select a file format for importing data
            % obj - class object 
            % id_class - id of new instance
            % isnew - true indicates that a new instance is to be created
            % selection - user file format selection id
            newobj = obj(id_class);
            nformats = size(newobj(1).DataFormats,1);
            if (isnew || size(obj,2)>1) && nformats>1 
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
                selection = obj.idFormat;
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