classdef muiCatalogue < dscatalogue
%
%-------class help------------------------------------------------------
% NAME
%   muiCatalogue.m
% PURPOSE
%   Class to manage catalogue of cases held
% NOTES
%   Requires R2018a for syntax to create empty table in the inherited 
%   function dscatalogue.catalogueTable. Also uses strings and double 
%   quotes which require R2017a
% SEE ALSO
%   Called by models and data import functions to save results as a Case
%
% Author: Ian Townend
% CoastalSEA (c)Sep 2020
%--------------------------------------------------------------------------
% 
    properties
        %Catalogue          %inherited property from dscatalogue
        DataSets            %handle to class instances
    end
    
    methods
        function obj = muiCatalogue
            %constructor to initialise object
        end
%% ------------------------------------------------------------------------
% Methods used in ModelUI Project menu
%--------------------------------------------------------------------------
        function editCase(obj,caserec)
            %edit Case description in the Catalogue record and update the
            %Description property in any dstables held in DataSets
            if nargin<2, caserec = []; end
            [caserec,newdesc] = editRecord(obj,caserec);
            %user can select a case but cancel editing
            if isempty(newdesc), return; end %user cancelled
     
            [cobj,~,~] = getCase(obj,caserec);
            if isprop(cobj,'Data') && ~isempty(cobj.Data)
                dsnames = fieldnames(cobj.Data);
                for k=1:length(dsnames)
                    dst = cobj.Data.(dsnames{k});
                    dst.Description = newdesc{1};
                end
            end
        end
%%
        function saveCase(obj,caserec)  
            %write the results for a selected case to an excel file   
            if nargin<2  %if case to save has not been specified
                [caserec,ok] = selectCase(obj,'Select case to save:','single',2);
                if ok<1, return; end 
            end
            
            [cobj,~,catrec] = getCase(obj,caserec);
            
            %if class has more than one dataset per record prompt for selection
            dataset = 1;
            datasetnames = fieldnames(cobj.Data);
            if length(datasetnames)>1
                promptxt = {'Select dataset'};
                title = 'Save dataset';
                [dataset,ok] = listdlg('PromptString',promptxt,...
                           'SelectionMode','single','Name',title,...
                           'ListSize',[300,100],'ListString',datasetnames);
                if ok<1, return; end       
            end
            dst = cobj.Data.(datasetnames{dataset});
            
            %determine save options based on dimensions of first cell
            if numel(dst.DataTable{1,1})>1
            	saveas = questdlg('Save data as','Save dataset',...
                                           'dstable','table','dstable');
            else
                saveas = questdlg('Save data as','Save dataset',...
                                     'Excel','dstable','table','Excel');
            end
            
            %use description as suggested file name and prompt user
            casedesc = catrec.CaseDescription;
            casedesc = char(matlab.lang.makeValidName(casedesc));            
            %prompt user for file name to use
            prompt = {'File name'};
            title = 'Save case';
            filename = inputdlg(prompt,title,1,{casedesc});
            if isempty(filename), return; end
            
            %write selection to file
            atable = dst.DataTable;
            if strcmp(saveas,'Excel') 
                rn = false;
                if ~isempty(dst.RowNames), rn = true; end   
                writetable(atable,[pwd,'/',filename{1},'.xlsx'],...
                           'WriteRowNames',rn,'FileType','spreadsheet');
            elseif strcmp(saveas,'dstable')                 
                save([pwd,'/',filename{1},'.mat'],'dst') %save as dstable
            else                
                save([pwd,'/',filename{1},'.mat'],'atable') %save as table
            end 
            getdialog(sprintf('Data saved as ''%s'' to: %s',saveas,filename{1}));
        end         
%%
        function deleteCases(obj,caserec)
            %select one or more records and delete records from catalogue 
            %and class instances
            if nargin<2  %if case to delete has not been specified
                [caserec,ok] = selectCase(obj,'Select cases to delete:',...
                                                       'multiple',2,true);                                      
                if ok<1, return; end  
            end 
            
            %sort in reverse order so that record ids do not change as
            msg = sprintf('Deleting %d cases',length(caserec));
            hw = waitbar(0,msg);
            caserec = sort(caserec,'descend');
            nrec = length(caserec);
            for i=1:nrec
                %delete each instance of class
                delete_dataset(obj,caserec(i))
                waitbar(i/nrec);
            end            
            obj.Catalogue(caserec,:) = [];     %delete selected records
            close(hw)
        end    
%%
        function reloadCase(obj,mobj,caserec)  
            %reload model input variables as the current settings
            if nargin<3  %if case to reload has not been specified
                [caserec,ok] = selectCase(obj,'Select case to reload:',...
                                                            'single',2); 
                if ok<1, return; end  
            end  
            cobj = getCase(obj,caserec);      %selected case
            minp = fieldnames(cobj.RunParam); %saved input class instances
            
            for i=1:length(minp)
                if ~isnumeric(cobj.RunParam.(minp{i}))
                    %if traps datasets used as inputs which are saved in the 
                    %Case record as their caseID rather than the source data
                    mobj.Inputs.(minp{i}) = copy(cobj.RunParam.(minp{i}));
                end
            end   
            casedesc = obj.Catalogue.CaseDescription(caserec);
            getdialog(sprintf('Reloaded: %s',casedesc));
        end
%% 
        function viewCaseSettings(obj,caserec)
            %view the saved input data for a selected Case
            nrec = height(obj.Catalogue);
            if nrec==1
                caserec = 1; %overrides caserec input if only one record
            elseif nargin<2
                %if case to view has not been specified
                [caserec,ok] = selectCase(obj,'Select case to view:',...
                                                            'single',2); 
                if ok<1, return; end                  
            end
            [cobj,~,catrec] = getCase(obj,caserec);            
            
            if isempty(cobj.RunParam)
                warndlg('The case selected has no input data');
                return;
            else
                casedesc = catrec.CaseDescription;
                inputs = fieldnames(cobj.RunParam);
                ninp = length(inputs);
                propdata = {}; proplabels = {};
                for kk=1:ninp         %concatenate the Run Parameters
                    localObj = cobj.RunParam.(inputs{kk});
                        nobj = length(localObj);
                        if nobj>1
                            %localObj is an array of objects so concatenate
                            %the properties from each object. Requires
                            %dimensions of properties to be consistent.
                            for jj=1:nobj
                                [pdatajj,plabels] = setPropertyData(obj,...
                                                            localObj(jj));
                                %vertically concatenate properties for each instance
                                %matrix is [nobj,nprop]
                                try
                                    input = [pdatajj{:}];
                                catch
                                    %fails if dimensions not consistent
                                    input = NaN(size(pdatajj)); %multi-object vector
                                end
                                pdata(jj,:) =  input; %#ok<AGROW>
                            end
                            %reshape to [nprop,nobj] and then to nprop cell
                            %array with nobj vectors for each property
                            pdata = mat2cell(pdata',ones(1,size(pdata',1)));
                        else
                            %extract the properties from localObj and 
                            %return data and labels.
                            [pdata,plabels] = setPropertyData(obj,...
                                                            localObj);
                        end   
                        propdata = [propdata;pdata];         %#ok<AGROW>
                        proplabels = [proplabels;plabels];   %#ok<AGROW>
                        clear pdata plabels
                end

                %check for scalar values 
                ids = find(~(cellfun(@isscalar,propdata)));
                for i=1:length(ids)  %convert any numerical data to char vectors
                    if iscell(propdata{ids(i)})     
                        propdata{ids(i)} = char(join(string(propdata{ids(i)}),','));  %#ok<AGROW>                  
                    elseif istable(propdata{ids(i)})
                        propdata{ids(i)} = 'Table data'; %#ok<AGROW> 
                    elseif isa(propdata{ids(i)},'tscollection')
                        propdata{ids(i)} = 'Timeseries data'; %#ok<AGROW> 
                    elseif isstring(propdata{ids(i)})
                        %do not modify char trap occurrence before nan test
                    elseif any(isnan(propdata{ids(i)})) %cannot display multi-object vectors in table
                        propdata{ids(i)} = 'Vector array or empty'; %#ok<AGROW> 
                    elseif isnumeric(propdata{ids(i)}) %converet to a char vector
                        propdata{ids(i)} = num2str(propdata{ids(i)});  %#ok<AGROW>    
                    end
                end

                %check for matlab objects (graphs, tables, etc)
                test = {'graph','digraph','table'};
                idg = [];
                for j=1:3
                        htest = @(x) isa(x,test{j});
                        idg = [idg;find(cellfun(htest,propdata))]; %#ok<AGROW> 
                end
                %char
                for i=1:length(idg)  %convert any numerical data to char vectors
                    objtype = class(propdata{idg(i)});
                    propdata{idg(i)} = sprintf('%s object',objtype); %#ok<AGROW> 
                end

                propdata = [proplabels,propdata]; %cell array of labels and values
                figtitle = sprintf('Settings used for %s',casedesc);
                varnames = {'Variable','Values'};                                
                h_fig = tablefigure('Case settings',figtitle,{},varnames,propdata); %#ok<NASGU>
                %use h_fig to adjust position on screen if required                
            end            
        end   
%%
        function importCase(obj)
            %import a case from a mat file that was saved using exportCase
            %prompt user to select file to import
            [fname,path] = getfiles('PromptText','Select case file to import',...
                                                     'FileType','*.mat');
            if fname==0, return; end
            load([path,fname],'cobj','-mat');    
            %function only accepts data exported as muiDataSet derived class
            if isprop(cobj,'ClassIndex') %check 'cobj'is a muiDataSet class
                msgbox('File does not contain a valid case to import');
                return;
            end 
            
            prompt = {'Data type (e.g. data/model/derived:'};
            title = 'Import case';
            datatype = inputdlg(prompt,title,1,{'data'});
            if isempty(datatype), return; end
            
%             addCaseRecord(cobj,obj,datatype);
            setCase(obj,cobj,datatype);
            activateTables(obj);
        end
%%
        function exportCase(obj,caserec)
            %save selected case to a mat file
            if nargin<2  %if case to delete has not been specified
                [caserec,ok] = selectCase(obj,'Select case to ecport:',...
                                                       'single',2);                                      
                if ok<1, return; end  
            end 
            [cobj,~,catrec] = getCase(obj,caserec);
            
            %use description as suggested file name and prompt user
            casedesc = catrec.CaseDescription;
            casedesc = char(matlab.lang.makeValidName(casedesc));            
            %prompt user for file name to use
            prompt = {'File name'};
            title = 'Export case';
            filename = inputdlg(prompt,title,1,{casedesc});
            if isempty(filename), return; end
            
            save([pwd,'/',filename{1},'.mat'],'cobj') %save as cobj
            getdialog(sprintf('Case exported to: %s',filename{1}));
        end
%% ------------------------------------------------------------------------
% Methods to manipulate Cases held in the Catalogue
%--------------------------------------------------------------------------
        function updateCase(obj,cobj,classrec,ismsg)
            %update the saved record with an amended version of instance
            if nargin<4
                ismsg = true;
            end
            classname = metaclass(cobj).Name;
            obj.DataSets.(classname)(classrec) = cobj;
            if ismsg
                caserec = caseRec(obj,cobj.CaseIndex);
                casedesc = obj.Catalogue.CaseDescription{caserec};
                getdialog(sprintf('Updated case for %s',casedesc));
            end
        end  
%%
        function cobj = getCases(obj,caserecs)
            %retrieve an array of objects held as DataSets based on caserecs
            selclass = obj.Catalogue.CaseClass(caserecs);
            if length(unique(selclass))>1
                warndlg('Selected records must be from the same class to use getCases')
                cobj = [];
                return
            end
            %may need to check that caserecs are all from the same class
            nrec = length(caserecs);
            cobj(nrec) = getCase(obj,caserecs(nrec));
            for i=1:nrec-1
                cobj(i) = getCase(obj,caserecs(i));
            end            
        end
%% 
        function [cobj,classrec,catrec] = getCase(obj,caserec)
            %retrieve the class instance, class record and catalogue record
            catrec = getRecord(obj,caserec); 
            if isempty(catrec), cobj = []; classrec = []; return; end
            lobj = obj.DataSets.(catrec.CaseClass);  
            classrec = [lobj.CaseIndex]==catrec.CaseID;            
            cobj = lobj(classrec);
        end
%%
        function caseid = setCase(obj,cobj,varargin)
            %add a case to the Catalogue and assign to DataSets
            % cobj - instance of class to be saved
            % varargin are as defined for dscatalogue.addRecord with
            % classname derived from obj          
            % casetype  - type of data set (e.g. keywords: model, data)
            % casedesc  - description of case (optional)
            % SupressPrompts - logical flag to use casedesc as record 
            %                  description without prompting user (optional
            %returns caseid to allow user to retrieve new record
            classname = metaclass(cobj).Name;            
            %add record to the catalogue and update mui.Cases.DataSets
            caserec = addRecord(obj,classname,varargin{:});
            casedef = getRecord(obj,caserec);
            setCaseIndex(cobj,casedef.CaseID);
            datasets = fieldnames(cobj.Data);
            for i=1:length(datasets)
                if isa(cobj.Data.(datasets{i}),'dstable')
                    cobj.Data.(datasets{i}).Description = casedef.CaseDescription;
                end
            end
            %assign dataset to class record
            id_class = setDataClassID(obj,classname);              
            obj.DataSets.(classname)(id_class) = cobj;
            caseid = casedef.CaseID;
        end
%%
        function [dst,caserec,idset,dstxt] = getDataset(obj,caserec,idset)
            %use the caserec id to get a case and return selected dataset
            %also returns caserec and idset as numeric index values and dstxt 
            % caserec - record id in mui Catalogue
            % idset - numeric index or a name defined dataset MetaData property
            % dstxt - dataset names used in class object Data property struct
            %function called by getProperty and muiDataUI.XYZselection
            if ~isnumeric(caserec)               
                caserec = find(strcmp(obj.Catalogue.CaseDescription,caserec));
            end
            cobj = getCase(obj,caserec);  %matches caseid to find record in class
            %
            datasetnames = fieldnames(cobj.Data);
            if ~isnumeric(idset) 
                dstxt = idset; 
                idset =  find(strcmp(datasetnames,dstxt));
                if isempty(idset), dst = []; return; end
            else
                dstxt = datasetnames{idset};
            end
            dst = cobj.Data.(datasetnames{idset});  %selected dataset
            varnames = dst.VariableNames;
            if ~isprop(dst,varnames{1})          %dynamic properties not set
                dst = activatedynamicprops(dst); %dstable now uses 
            end                                  %ConstructOnLoad so this 
        end                                      %should no longer be needed BUT IT IS!
%%
        function props = getProperty(obj,UIsel,outopt)
            %extract the data based on the selection made using a UI that
            %inherits muiDataUI and provides the UIselection struct
            % UIsel - UIselection struct that defines the dataset and
            %         dimensions/indices required
            % outopt - options to return the data as an array, table, dstable,
            %        a splittable where the 2nd dimension has been split into
            %        variables (see muiEditUI for example of usage), or a
            %        timeseries data set (assumes rows are datetime)
            % props - returns a struct containing data, description of 
            %         property being used and the associated label 
            dvals = [];
            props = setPropsStruct(obj);
            if nargin<3, outopt = 'array'; end
            istable = false;
            [dst,~,~,dstxt] = getDataset(obj,UIsel.caserec,UIsel.dataset);
            [attribnames,attribdesc,attriblabel] = getVarAttributes(dst,UIsel.variable);
            useprop = attribnames{UIsel.property};
            usedesc = attribdesc{UIsel.property};
            
            if any(strcmp(dst.VariableNames,useprop))                
                %return selected dimensions of variable
                %NB: any range defined for the Variable is NOT applied
                %returns all values within dimension range specified
                [idx,dvals] = getSelectedIndices(obj,UIsel,dst,attribnames);
                label = attriblabel{1};
                switch outopt
                    case 'array'
                        %extracts array for selected variable
                        data = getData(dst,idx.row,idx.var,idx.dim); 
                        if isempty(data), return; end
                        data = squeeze(data{1}); %getData returns a cell array
                    case 'table'
                        data = getDataTable(dst,idx.row,idx.var,idx.dim);
                    case 'dstable'
                        data = getDSTable(dst,idx.row,idx.var,idx.dim);
                    case 'splittable'
                        %split array variable into multiple variables
                        array = getData(dst,idx.row,idx.var,idx.dim);
                        if isempty(array), return; end
                        array = squeeze(array{1});
                        %get dimension name and indices
                        dimnames = setDimNames(obj,array,dvals,attribnames);                        
                        data = array2table(array,'RowNames',dimnames{1},...
                                            'VariableNames',dimnames{2});
                    case 'timeseries'
                        userdst = getDSTable(dst,idx.row,idx.var,idx.dim);
                        data = dst2tsc(userdst);
                end
                if isempty(data), return; end
                %apply any subselection to the range of the variable
                varange = dst.VariableRange.(useprop);
                subrange = UIsel.range;
                data = getVariableSubSelection(obj,data,varange,subrange,outopt);
                istable = true;
                dvals.nvar = length(attribnames);
            elseif any(strcmp('RowNames',useprop)) %value set in dstable.getVarAttributes
                %return selected row values 
                idx = getIndices(obj,dst.RowNames,UIsel.range);
                data = dst.RowNames(idx); %returns values in source data type
                useprop = dst.TableRowName;
                label = attriblabel{2};
            elseif any(strcmp(dst.DimensionNames,useprop))
                %return selected dimension              
                idx = getIndices(obj,dst.Dimensions.(useprop),UIsel.range);
                data = dst.Dimensions.(useprop)(idx);               
                label = attriblabel{UIsel.property}; 
            elseif any(contains(useprop,'noDim'))                
                rvals = range2var(UIsel.range);
                data = rvals{1}:rvals{2};
                label = 'Undefined dimension';
            else
                errordlg('Incorrect property selection in getProperty') 
            end
            %
            if ~istable && any(strcmp({'dstable','table'},outopt))
                switch outopt                    
                    case 'dstable'
                        data = dstable(data,'VariableNames',{useprop});
                    case 'table'
                        data = table(data,'VariableNames',{useprop});
                end
            end
            props.case = dst.Description;
            props.dset = dstxt;
            props.desc = usedesc;
            props.label = label;
            props.data = data; 
            props.dvals = dvals;
        end
%%
        function [caserec,ok] = selectCase(obj,promptxt,mode,selopt,ischeck)
            %select a case record to use with options to subselect
            %the selection list based on class or type (used in muiModelUI)
            % promptxt - text to use to prompt user
            % mode - single or multiple selection mode            
            % selopt - selection options:
            %          0 = no subselection, 
            %          1 = subselect using class, 
            %          2 = subselect using type, 
            %          3 = subselect using both
            % ischeck - flag to check selection if only a single option
            % Note: to select and return a class instance use selectCaseObj
            % to get a class object array (no Case/Record selection) use
            % getClassObj in muiModelUI.
            if nargin<5, ischeck = false; end
            classops = cellstr(unique(obj.Catalogue.CaseClass));
            typeops  = cellstr(unique(obj.Catalogue.CaseType));
            classel = []; typesel = []; ok = 1;
            if selopt==1
                [classel,ok]  = selectRecordOptions(obj,classops,'Select classes:');
            elseif selopt==2
                [typesel,ok]  = selectRecordOptions(obj,typeops,'Select types:');
            elseif selopt==3
                %if user cancels in selectRecordOptions use All
                classel  = selectRecordOptions(obj,classops,'Select classes:');
                typesel  = selectRecordOptions(obj,typeops,'Select types:'); 
            end
            if ok<1, caserec = []; return; end
        
            [caserec,ok] = selectRecord(obj,'PromptText',promptxt,...
                                'CaseType',typesel,'CaseClass',classel,...
                                'SelectionMode',mode,'ListSize',[250,200],...
                                'CheckSingle',ischeck);
        end
%%
        function [cobj,classrec] = selectCaseObj(obj,casetype,classname,...
                                                                 promptxt)
            %prompt user to select a Case and return instance (eg used in
            %GDinterface)
            % obj - class instance of muiCatalogue (eg using mobj.Cases for
            %       a class mobj that inherits muiModelUI)
            % casetype - can be empty, or cell array of one or more case
            %            types
            % classname - can be empty, or cell array of one or more
            %             class names 
            % promptxt - alternative text to use as a prompt (optional) 
            % [e.g. [cobj,crec] = selectCaseObj(obj,[],{'c1','c2'},'Select Case:');
            % Note: to select a Case when only caserec is required use 
            % selectCase (above). To get a class object array (no Case/Record 
            % selection) use getClassObj in muiModelUI.
            if nargin<2
                promptxt = 'Select Case:'; 
                classname = []; 
                casetype = [];
            elseif nargin<3
                promptxt = 'Select Case:';
                classname = [];
            elseif nargin<4
                promptxt = 'Select Case:';                
            end
                     
            [caserec,ok] = selectRecord(obj,'PromptText',promptxt,...
                              'CaseType',casetype,'CaseClass',classname,...
                              'SelectionMode','single','ListSize',[250,200]);
            if ok<1, cobj = []; classrec = []; return; end
            [cobj,classrec] = getCase(obj,caserec);    
        end
%%
        function [cobj,classrec,datasets,idd] = selectCaseDataset(obj,...
                                              casetype,classname,promptxt)
            %select case and dataset for use in plot or analysis
            [cobj,classrec] = selectCaseObj(obj,casetype,classname,promptxt);
            datasets = fields(cobj.Data);
            idd = 1;
            if length(datasets)>1
                idd = listdlg('PromptString','Select table:','ListString',datasets,...
                                    'SelectionMode','single','ListSize',[160,200]);
                if isempty(idd), return; end
            end
        end
%%
        function [cobj,classrec,irow] = selectCaseDatasetRow(obj,casetype,...
                                                classname,promptxt,idd)
            %prompt user to select a Case, Dataset (if not specified) and 
            %a row, return instance and row no.
            % obj - class instance of muiCatalogue (eg using mobj.Cases for
            %       a class mobj that inherits muiModelUI)
            % casetype - can be empty, or cell array of one or more case
            %            types
            % classname - can be empty, or cell array of one or more
            %             class names 
            % promptxt - alternative text to use as a prompt
            %            cell array for (1) case and (2) row
            % itable - id of dataset table to use
            %uses selectCaseObj above. Used in getInletTools.
            if nargin<2
                idd = [];
                promptxt = {'Select Case:','Select Row:'}; 
                classname = []; 
                casetype = [];
            elseif nargin<3
                idd = [];
                promptxt = {'Select Case:','Select Row:'};
                classname = [];
            elseif nargin<4
                idd = [];
                promptxt = {'Select Case:','Select Row:'};    
            elseif nargin<5
                idd = [];
            end
            
            if isempty(promptxt) || ~iscell(promptxt) || length(promptxt)<2
                promptxt = {'Select Case:','Select Row:'}; 
            end
            
            %select the Case to use
            [cobj,classrec] = selectCaseObj(obj,casetype,classname,promptxt{1});
            if isempty(cobj), irow = []; return; end
            %select a dataset table to use if not specified
            if isempty(idd)
                [dsname,~] = selectDataset(obj,cobj);
            else
                dsnames = fieldnames(cobj.Data);
                dsname = dsnames{idd};
            end

            %select the Row to use
            dst = cobj.Data.(dsname);
            if height(dst)>1
                %propmpt user to select timestep
                list = dst.DataTable.Properties.RowNames; %returns char values
                irow = listdlg('PromptString',promptxt{2},...
                               'Name','selectDSR','SelectionMode','single',...
                               'ListSize',[200,200],'ListString',list);
            else
                irow = 1;
            end
        end        
%%
function [cobj,classrec,dsname,ivar] = selectCaseDatasetVariable(obj,casetype,...
                                                        classname,promptxt,idd)
            %prompt user to select a Case, Dataset (if not specified) and 
            %a variable, return instance and variable id.
            % obj - class instance of muiCatalogue (eg using mobj.Cases for
            %       a class mobj that inherits muiModelUI)
            % casetype - can be empty, or cell array of one or more case
            %            types
            % classname - can be empty, or cell array of one or more
            %             class names 
            % promptxt - alternative text to use as a prompt
            %            cell array for (1) case and (2) row
            % itable - id of dataset table to use
            %uses selectCaseObj above. Used in getInletTools.
            if nargin<2
                idd = [];
                promptxt = {'Select Case:','Select Variable:'}; 
                classname = []; 
                casetype = [];
            elseif nargin<3
                idd = [];
                promptxt = {'Select Case:','Select Variabble:'};
                classname = [];
            elseif nargin<4
                idd = [];
                promptxt = {'Select Case:','Select Variable:'};    
            elseif nargin<5
                idd = [];
            end
            
            if isempty(promptxt) || ~iscell(promptxt) || length(promptxt)<2
                promptxt = {'Select Case:','Select Variable:'}; 
            end

            %select the Case to use
            [cobj,classrec] = selectCaseObj(obj,casetype,classname,promptxt{1});
            if isempty(cobj), ivar = []; return; end

            %select a dataset table to use if not specified
            if isempty(idd)
                [dsname,~] = selectDataset(obj,cobj);
            else
                dsnames = fieldnames(cobj.Data);
                dsname = dsnames{idd};
            end

            %select the variable to use
            dst = cobj.Data.(dsname);
            if height(dst)>1
                %propmpt user to select timestep
                list = dst.VariableDescriptions;
                ivar = listdlg('PromptString',promptxt{2},...
                               'Name','selectDSV','SelectionMode','single',...
                               'ListSize',[200,300],'ListString',list);
            else
                ivar = 1;
            end
        end

%%
        function [dsname,idd] = selectDataset(~,cobj)
            %select a dataset table to use for a given class instance
            dsnames = fieldnames(cobj.Data);             
            if length(dsnames)>1
                idd = listdlg('PromptString','Select dataset',...
                              'Name','selectDset','SelectionMode','single',...
                              'ListSize',[200,200],'ListString',dsnames);
                if isempty(idd), idd = 1; end
            else
                idd = 1;
            end
            dsname = dsnames{idd};
        end
%%
        function useCase(obj,mode,classname,action)
            %select which existing data set to use and pass to action method
            % mode - none, single or multiple selection mode  
            % classname - character vector or cell array of class name(s) to select cases for
            % action - method of class to pass class object to,
            %          e.g. 'addData' in muiDataSet abstract class.
            if strcmp(mode,'none')
                if iscell(classname), classname = classname{1}; end
                heq = str2func(['@(muicat,classname) ',...
                            [classname,'.',action,'(muicat,classname)']]); 
                heq(obj,classname);  %instance of class object   
            else
                promptxt = 'Select Case to use:';
                [caserec,ok] = selectRecord(obj,'PromptText',promptxt,...
                    'SelectionMode',mode,'CaseClass',classname,'ListSize',[250,200]);
                if ok<1, return; end  
                [cobj,classrec,catrec] = getCase(obj,caserec);

                heq = str2func(['@(cobj,classrec,catrec,muicat) ',...
                                    [action,'(cobj,classrec,catrec,muicat)']]); 
                heq(cobj,classrec,catrec,obj);  %instance of class object
            end
        end 
%%
        function activateTables(obj)
            %load dstables held as Data in muiDataSet derived classes and 
            %saved to DataSets in a muiCatalogue so that the dynamic
            %properties are accessible
            if isempty(obj.DataSets), return; end
            fnames = fieldnames(obj.DataSets);
            if ~isempty(fnames)
                for i=1:length(fnames)
                    cobj = obj.DataSets.(fnames{i});
                    for j = 1:length(cobj)
                        if isprop(cobj(j),'Data') && ~isempty(cobj(j).Data)
                            dsnames = fieldnames(cobj(j).Data);
                            for k=1:length(dsnames)
                                dst = cobj(j).Data.(dsnames{k});
                                varnames = dst.VariableNames;
                                activatedynamicprops(dst,varnames);
                            end
                        end
                    end
                end
            end
        end
%%
        function addVariable2CaseDS(obj,caserec,newvar,dsp)
            %add a variable to an existing Case dataset in the Catalogue
            [cobj,classrec,catrec] = getCase(obj,caserec); %use getCase because need classrec
            classname = catrec.CaseClass; 
            datasetname = getDataSetName(cobj);
            dst = cobj.Data.(datasetname);     %add variable to this dstable

            %need to prevent duplication of variable name and description
            nxvar = length(dst.VariableNames);
            dstvarnames = [dst.VariableNames];
            dspvarnames = {dsp.Variables(:).Name};
            if any(ismatch(dstvarnames,dspvarnames))
                %idx = find(ismatch(dstvarnames,dspvarnames));
                for i=1:length(dspvarnames)
                    newvarnum = num2str(nxvar+i);
                    dsp.Variables(i).Name = ['Var',newvarnum];
                    dsp.Variables(i).Description = ['desc',newvarnum];                    
                end
                %allow user to edit the modified names and descriptions
                editDSproperty(dsp,'Variables');
            end

            %add the variable(s) to the dstable, with variable names but not metadata 
            dst = addvars(dst,newvar{:},'NewVariableNames',{dsp.Variables(:).Name});
            %update the DSproperties
            dstdps = dst.DSproperties;
            dstdps.Variables(nxvar+1:end) = dsp.Variables;
            dst.DSproperties = dstdps;
            %save dstable to source class record
            obj.DataSets.(classname)(classrec).Data.(datasetname) = dst;
        end
%%
        function editDSprops(obj,caserec)
            %edit the DSproperties of a selected dataset
            if nargin<2 
                [caserec,ok] = selectCase(obj,'Select case to edit:','single',0);
                if ok<1, return; end
            end
            [cobj,classrec,catrec] = getCase(obj,caserec);
            if isempty(cobj), return; end
            classname = catrec.CaseClass; 
            datasetname = getDataSetName(cobj);
            if isempty(datasetname), return; end
            dst = cobj.Data.(datasetname); 
            %extract DSproperties and edit
            dsp = dst.DSproperties;
            editDSproperty(dsp,'Variables');
            editDSproperty(dsp,'Row');
            editDSproperty(dsp,'Dimensions');
            dst.DSproperties = dsp;
            %save dstable to source class record
            obj.DataSets.(classname)(classrec).Data.(datasetname) = dst;
        end
%%
        function classrec = classRec(obj,caserec)
            %find the class record number using the case record number in the
            %Catalogue case list
            catrec = getRecord(obj,caserec); 
            if isempty(catrec), classrec = []; return; end
            lobj = obj.DataSets.(catrec.CaseClass);  
            classrec = [lobj.CaseIndex]==catrec.CaseID; 
        end
%%
        function id_class = setDataClassID(obj,classname)                                                          
            %get the index for a new instance of class held in DataSets
            if isfield(obj.DataSets,classname) && ...
                                    ~isempty(obj.DataSets.(classname))
                id_class = length(obj.DataSets.(classname))+1;
            else
                id_class = 1;
            end 
        end
%%
        function props = setPropsStruct(~)
            %initialise struct used in muiCatalogue.getProperty
            props = struct('case',[],'dset',[],'desc',[],'label',[],'data',[],'dvals',[]);
        end 
%%
        function [idx,dimnames] = getSelectedIndices(obj,UIsel,dst,attnames)
            %find the indices for the selected variable, and the row and 
            %dimension values. If dimension exists but is not defined, a
            %set of index values is created
            % UIsel - struct defined by UIs derived from muiDataUI
            % dst - dstable to extract indices from
            % attnames - field names of attributes {variable,row,dimensions}
            
            idx.var = UIsel.variable;
            nvar = length(idx.var)+1;   %offset to first dimension
            uidims = UIsel.dims;
            ndim = length(uidims);
            idx.row = 1; 
            idx.dim = cell(1,ndim-1); %use cell because can be multiple dimensions of different length
            for i=1:ndim
                %assign to dimension or row                    
                if strcmp(uidims(i).name,'RowNames') %this is a row                    
                    var = dst.RowNames;
                    idx.row = getIndices(obj,var,uidims(i).value);
                    dimnames.row = var(idx.row);
                else                                 %must be a dimension
                    if isfield(dst.Dimensions,uidims(i).name)
                        var = dst.Dimensions.(uidims(i).name);
                    else                             %dimension not defined
                        if isinteger(UIsel.dims(i).value)
                            var = int16(1:UIsel.dims(i).value);
                        else
                            rvals = range2var(UIsel.dims(i).value);
                            var = int16(rvals{1}):int16(rvals{2});
                        end
                    end
                    %
                    isrowdim = ~isempty(dst.RowNames) && height(dst)==1; 
                    if height(dst.DataTable)>1 || isrowdim  %ensure offset is correct 
                        idd = strcmp(attnames(nvar+1:end),uidims(i).name);
                    else  
                        idd = strcmp(attnames(nvar:end),uidims(i).name);
                    end
                    idx.dim{idd} = getIndices(obj,var,uidims(i).value);
                    dimnames.dim{idd} = var(idx.dim{idd});
                end  
            end
        end 
%%
        function modifyVariableType(obj)
            %select a variable and modify that data type of the variable
            %used mainly to make data catagorical or ordinal
            [cobj,classrec,dsname,ivar]  = selectCaseDatasetVariable(obj);
            if isempty(ivar), return; end  %user did not select a variable
            dst = cobj.Data.(dsname);
            varnames = dst.VariableNames;
            selvar = varnames{ivar};
            seldesc = dst.VariableDescriptions{ivar};
            var = dst.(selvar);
            dtype = getdatatype(var);
            
            promptxt = sprintf('Data type is %s\nSelect new data type:',dtype{1});
            % types = {'logical','int8','int16','int32','int64','uint8',... 
            %          'uint16','uint32','uint64''single','double','char',...
            %          'string','categorical','ordinal','datetime','duration',...
            %          'calendarDuration'};
            %at the moment only categorical and ordinal is handled
            types = {'categorical','ordinal','datetime','duration'};              
            idt = listdlg('PromptString',promptxt,'ListString',types,...
                          'SelectionMode','single','ListSize',[160,260]);
            if isempty(idt), return; end
            seltype = types{idt};
            if strcmp(seltype,'ordinal') || strcmp(seltype,'categorical')
                valuestxt = sprintf('Uniques values of %s',seldesc);
                prompts = {valuestxt,'Matching category names'};
                classes = unique(var);  %find categories and allow user to edit
                [catstr,type,~] = var2str(classes);
                catstr = sprintf('%s, ',catstr{:});
                catstr = catstr(1:end-2);
                defaults = {catstr,catstr};
                opts.Resize = 'on';
                answers = inputdlg(prompts,'ModVar',1,defaults,opts);
                if isempty(answers), return; end   
                valueset = strsplit(answers{1},', ');
                catnames = strsplit(answers{2},', ');
                valueset = str2var(valueset,type,catnames);
                if iscategorical(var)
                    if isordinal(var) && strcmp(seltype,'categorical')
                        %switch from ordinal to categorical
                        var = categorical(var,'Ordinal',false);
                    elseif strcmp(seltype,'ordinal')
                        %switch from categorical to ordinal
                        var = categorical(var,'Ordinal',true);
                    elseif contains(answers{1},'order')
                        %reorder and existing categorical dataset
                        var = reordercats(var,catnames);
                    else
                        %rename categories of existing categorical dataset
                        var = renamecats(var,catnames);
                    end                       
                elseif strcmp(seltype,'ordinal')
                    %create a categorical dataset where values match the
                    %valueset and named using catnames and are ordered                    
                    var = categorical(var,valueset,catnames,'Ordinal',true);
                else
                    %create an ordinal dateset where values match the
                    %valueset and these are named using catnames
                    var = categorical(var,valueset,catnames);
                end
                dst.(selvar) = var;
                
                %update range based on categories used for var
                dst = setVariableRange(dst,selvar);
                cobj.Data.(dsname) = dst;
                updateCase(obj,cobj,classrec,true);
            elseif strcmp(seltype,'datetime') || strcmp(seltype,'duration')
                formatxt = sprintf('Format to use\nDatetime e.g. dd-MM-yyyy HH:mm:ss\nDuration e.g. s, m, h, d, y; or hh:mm:ss');
                opts.Resize = 'on';
                defaults = {'dd-MM-yyyy HH:mm:ss'};
                answers = inputdlg(formatxt,'ModVar',1,defaults,opts);
                format = answers{1};
                if strcmp(seltype,'datetime')
                    try
                        var = datetime(var,'InputFormat',format);
                    catch
                        warndlg('Unable to make coversion to input format')
                    end
                elseif strcmp(seltype,'duration')
                    try
                        if contains(format,':')
                            var = duration(var,'InputFormat',format); %uses duration input format
                        else
                            var = str2duration(var,format); %uses duration output string format
                        end
                    catch
                        warndlg('Unable to make coversion to input format')
                    end
                end 
                dst.(selvar) = var;
                %update range based on categories used for var
                dst = setVariableRange(dst,selvar);
                cobj.Data.(dsname) = dst;
                updateCase(obj,cobj,classrec,true);                
            else
                warndlg('Only categorial and ordinal currently handled');
            end
            %updateCase(obj,cobj,classrec,true);
        end
    end
%%
    methods (Access=private)      
        function delete_dataset(obj,caserec)
            %delete selected record from Catalogue and DataSet
            [~,classrec,catrec] = getCase(obj,caserec);
            classname = catrec.CaseClass; 
            %clear instance of data set class
            obj.DataSets.(classname)(classrec) = [];
        end          
%%
        function indices = getIndices(~,var,value)
            %get the index or vector of indices based on selection
            % var is the variable to select from and value is a numeric
            % value to select the nearest index, or a text string defining
            % the range of values required
            if ischar(value) && ~iscell(var)  
                %range character vector
                indices = getvarindices(var,value);
            elseif (iscell(var) || isstring(var)) && length(var)>1
                %cell array of character vectors NB value must be a cell
                if contains(value,'From')
                    value = range2var(value);
                end
                st_nd = find(ismatch(var,value)); %start and end values
                indices = min(st_nd):max(st_nd);  %indices from start to end
            elseif isinteger(var) && var(end)==value
                indices = value;   
            elseif iscategorical(var)
                indices = find(value==var);
            elseif length(var)>1
                %numerical array
                indices = interp1(var,1:length(var),value,'nearest'); 
            else
                indices = 1;
            end
        end  
%%
        function seldim = setDimNames(~,array,dimvalues,varatt)
            %match the selected dimensions to the data array and convert to
            %text RowNames and valid VariableNames for use in splittable
            % array - sqeezed array sampled from first cell (note this is
            %         still (1xn) if vector data in a single row)
            % dimvalues - dimension values
            % varatt - variable attributes (variable,row,dimension names)
            % seldim - {1}=RowNames and {2}=valid VariableNames
            sz = size(array);            
            dimatt = varatt(2:end);        %attributes excluding variable
            
            %handle single row and empty RowNames
            if isfield(dimvalues,'row')
                dimnames{1} = dimvalues.row;
            else
                dimnames{1} = [];
            end
            
            if sz(1)==1                    %single row
                dimnames{1} = 1;
                dimatt = ['Row1',dimatt];
            elseif isempty(dimnames{1})    %no RowNames assigned (not tested)
                dimnames{1} = 1:sz(1);
            end
            
            %handle dimensions if used
            if isfield(dimvalues,'dim')
                ndim = length(dimvalues.dim);
                dimnames(2:ndim+1) = dimvalues.dim;              
            else
                dimnames{2} = 1;
                dimatt(2) = varatt(1);
            end
            
            sdim = length(sz);
            seldim = cell(1,sdim); seldimname = seldim;
            for i=1:sdim
                idx = cellfun(@length,dimnames)==sz(i);
                if isrow(dimnames{idx}), dimnames{idx} = dimnames{idx}'; end
                seldim{i} = strip(var2str(dimnames{idx}));
                seldimname{i} = dimatt{idx};
            end
            %
            for j=2:sdim
                myfun = @(x) sprintf('%s_%s',seldimname{j},x);
                seldim{j} = cellfun(myfun,seldim{j},'UniformOutput',false);
            end
        end
%%
        function [propdata,proplabels] = setPropertyData(~,localObj) 
            %extract the properties from localObj and return data and
            %labels. Used to display run settings in viewCaseSettings
            if isa(localObj,'muiPropertyUI')  %mui input data
                propstruct = getPropertiesStruct(localObj);
                issubstruct = cellfun(@isstruct,struct2cell(propstruct));
                if any(issubstruct)
                    fnames = fieldnames(propstruct);
                    idx = find(issubstruct);
                    for j = 1:length(idx)
                        propstruct.(fnames{idx(j)}) = ...
                            cell2mat(struct2cell(propstruct.(fnames{idx(j)})))';
                    end
                end
                propdata = struct2cell(propstruct); 
                proplabels = fieldnames(propstruct); 
            elseif isstruct(localObj)   %input is an existing Case (model or imported data)
                propdata = char(localObj.casedesc);
                proplabels = sprintf('%s (cid=%d)',localObj.caseclass,localObj.caseid);            
            else %expose properties for inputs that do not use muiPropertyUI
                proplabels = properties(localObj);
                nlabels = length(proplabels);
                propdata = cell(nlabels,1);
                for k=1:nlabels
                    if isempty(localObj.(proplabels{k}))
                        propdata{k,1} = NaN;
                    else
                        propdata{k,1} = localObj.(proplabels{k});
                    end
                end
            end
        end
        %%
        function data = getVariableSubSelection(~,data,range,selrange,outopt)
            %if the range of a variable has been subselected, assign the
            %values outside the range as NaNs
            %NB - limited testing with real data ***
            subrange = range2var(selrange);
            range = check_bounds(range);
            if all(cellfun(@isequal,range,subrange)), return; end

            switch outopt
                case 'array'
                    data = applyrange(data,range,subrange);
                case 'table'
                    varname = data.Properties.VariableNames{1};
                    data.(varname) = applyrange(data.(varname),range,subrange);
                case 'dstable'
                    varname = data.VariableNames{1};
                    data.(varname) = applyrange(data.(varname),range,subrange);
                case 'splittable'
                    data{:,:} = applyrange(data{:,:},range,subrange); %assumes can only be 2D table
                case 'timeseries'
                    data.Data = applyrange(data.Data,range,subrange);                    
            end
            % Nested function----------------------------------------------
            function data = applyrange(data,range,subrange)
                %set values outside subrange to NaN
                if isnumeric(range{1})
                    if range{1}~=subrange{1}
                        data(data<subrange{1}) = NaN;
                    end
                    %
                    if range{2}~=subrange{2}
                        data(data>subrange{2}) = NaN;
                    end
                else
                    %for text it would be better to be able to multi-select 
                    %from a list but for now use a range to be consistent
                    valueset = categories(categorical(data));
                    ids = find(contains(valueset,subrange{1}));
                    ide = find(contains(valueset,subrange{2}));
                    idx = 1:length(valueset);
                    idx(ids:ide) = 0;
                    idx = idx>0;
                    if iscategorical(data)
                        data = removecats(data,valueset(idx));   
                    else
                        data(ismatch(data,valueset(idx))) = {''};
                    end
                end
            end     
            % Nested function----------------------------------------------
            function outrange = check_bounds(inrange)
                %check for rounding errors when converting between numeric 
                %ranges and the displayed text strings
                outrange = inrange;
                if isnumeric(inrange{1})                
                    if str2double(sprintf('%g',inrange{1}))~=inrange{1}
                        outrange{1} = str2double(sprintf('%g',inrange{1}));
                    end
                    %
                    if str2double(sprintf('%g',inrange{2}))~=inrange{2}
                        outrange{2} = str2double(sprintf('%g',inrange{2}));
                    end
                end
            end
        end
    end
end