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
        %Catalogue          %inherited property from dscatalgue
        DataSets            %handle to class instances
    end
    
    methods
        function obj = muiCatalogue
            %constructor to initialise object
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
                                                       'multiple',2);                                      
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
                    %trap datasets used as inputs which are saved as caseID
                    mobj.Inputs.(minp{i}) = cobj.RunParam.(minp{i});
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
            elseif nargin<3
                %if case to view has not been specified or only one case
                [caserec,ok] = selectCase(obj,'Select case to view:',...
                                                            'single',2); 
                if ok<1, return; end                  
            end
            [cobj,~,catrec] = getCase(obj,caserec);
            
            casedesc = catrec.CaseDescription;
            inputs = fieldnames(cobj.RunParam);
            if isempty(cobj.RunParam)
                warndlg('The case selected has no input data');
                return;
            else
                ninp = length(inputs);
                propdata = {}; proplabels = {};
                for k=1:ninp
                    localObj = cobj.RunParam.(inputs{k});
                    propdata = vertcat(propdata,getProperties(localObj)); %#ok<AGROW>
                    proplabels = vertcat(proplabels,getPropertyNames(localObj)); %#ok<AGROW>
                end
                idx = find(~(cellfun(@isscalar,propdata)));
                for i=1:length(idx)
                    propdata{idx(i)} = num2str(propdata{idx(i)});
                end
                propdata = [proplabels,propdata];
                figtitle = sprintf('Settings used for %s',casedesc);
                varnames = {'Variable','Values'};                                
                h_fig = tablefigure('Scenario settings',figtitle,{},varnames,propdata);
                %adjust position on screen            
            
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
            
            prompt = {'Data type:'};
            title = 'Import case';
            datatype = inputdlg(prompt,title,1,{'data'});
            if isempty(datatype), return; end
            
            addCaseRecord(cobj,obj,datatype);
        end
%%
        function exportCase(obj,caserec)
            %save selected case to a mat file
            if nargin<2  %if case to delete has not been specified
                [caserec,ok] = selectCase(obj,'Select cases to delete:',...
                                                       'multiple',2);                                      
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
%%
        function updateCase(obj,cobj,classrec,ismsg)
            %update the saved record with an amended version of instance
            if nargin<4
                ismsg = true;
            end
            classname = metaclass(cobj).Name;
            obj.DataSets.(classname)(classrec) = cobj;
            if ismsg
                getdialog(sprintf('Updated case for %s',classname));
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
            lobj = obj.DataSets.(catrec.CaseClass);  
            classrec = [lobj.CaseIndex]==catrec.CaseID;            
            cobj = lobj(classrec);
        end
%%
        function [dst,caserec,idset,dstxt] = getDataset(obj,caserec,idset)
            %use the caserec id to get a case and return selected dataset
            %also returns caserec and idset as numeric index values
            % caserec - record id in mui Catalogue
            % idset - numeric index or a name defined dataset MetaData property
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
            else
                dstxt = datasetnames(idset);
            end
            dst = cobj.Data.(datasetnames{idset});  %selected dataset
            varnames = dst.VariableNames;
            if ~isprop(dst,varnames{1})         %dynamic properties not set
                dst = activatedynamicprops(dst);
            end
        end
%%
        function props = getProperty(obj,UIsel,type)
            %extract the data based on the selection made using a UI that
            %inherits muiDataUI and provides the UIselection struct
            % UIsel - UIselection struct that defines the dataset and
            %         dimensions/indices required
            % type - options to return the data as an array, table, dstable,
            %        a splittable where the 2nd dimension has been split into
            %        variables (see muiEditUI for example of usage), or a
            %        timeseries data set (assumes rows are datetime)
            % props - returns a struct containing data, description of 
            %         property being used and the associated label 
            props = setPropsStruct(obj);
            if nargin<3, type = 'array'; end
            istable = false;
            [dst,~,~,dstxt] = getDataset(obj,UIsel.caserec,UIsel.dataset);
            [attribnames,attribdesc,attriblabel] = getVarAttributes(dst,UIsel.variable);
            useprop = attribnames{UIsel.property};
            usedesc = attribdesc{UIsel.property};
            
            if any(strcmp(dst.VariableNames,useprop))                
                %return selected dimensions of variable
                %NB: any range defined for the Variable is NOT applied
                %returns all values within dimension range specified
                [id,dvals] = getSelectedIndices(obj,UIsel,dst,attribnames);
                label = attriblabel{1};
                switch type
                    case 'array'
                        %extracts array for selected variable
                        data = getData(dst,id.row,id.var,id.dim); 
                        data = squeeze(data{1}); %getData returns a cell array
                    case 'table'
                        data = getDataTable(dst,id.row,id.var,id.dim);
                    case 'dstable'
                        data = getDSTable(dst,id.row,id.var,id.dim);
                    case 'splittable'
                        %split array variable into multiple variables
                        array = getData(dst,id.row,id.var,id.dim);
                        array = squeeze(array{1});
                        %get dimension name and indices
                        dimnames = setDimNames(obj,array,dvals,attribnames);                        
                        data = array2table(array,'RowNames',dimnames{1},...
                                            'VariableNames',dimnames{2});
                    case 'timeseries'
                        
                end
                istable = true;
            elseif any(strcmp('RowNames',useprop)) %value set in dstable.getVarAttributes
                %return selected row values 
                idrow = getIndices(obj,dst.RowNames,UIsel.range);
                data = dst.RowNames(idrow); %returns values in source data type
                useprop = dst.TableRowName;
%                 rowlabel = getLabels(dst,'Row');
                label = attriblabel{2};
            elseif any(strcmp(dst.DimensionNames,useprop))
                %return selected dimension              
                iddim = getIndices(obj,dst.Dimensions.(useprop),UIsel.range);
                data = dst.Dimensions.(useprop)(iddim);
%                 dimlabels = getLabels(dst,'Dimension');
                %subtract variable and row (if used)
                if height(dst.DataTable)>1, nr=2; else, nr=1; end                  
                label = attriblabel{UIsel.property}; 
            else
                errordlg('Incorrect property selection in getProperty') 
            end
            %
            if ~istable && any(strcmp({'dstable','table'},type))
                switch type                    
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
        end
%%
        function [caserec,ok] = selectCase(obj,promptxt,mode,selopt)
            %select a case to use for something with options to subselect
            %the selection list based on class or type
            % promtxt - text to use to prompt user
            % mode - single or multiple selection mode            
            % selopt - selection options:
            %          0 = no subselection, 
            %          1 = subselect using class, 
            %          2 = subselect using type, 
            %          3 = subselect using both
            classops = unique(obj.Catalogue.CaseClass);
            typeops  = unique(obj.Catalogue.CaseType);
            classel = []; typesel = [];
            if selopt==1
                classel  = selectRecordOptions(obj,classops,'Select classes:');
            elseif selopt==2
                typesel  = selectRecordOptions(obj,typeops,'Select types:');
            elseif selopt==3
                classel  = selectRecordOptions(obj,classops,'Select classes:');
                typesel  = selectRecordOptions(obj,typeops,'Select types:'); 
            end

            [caserec,ok] = selectRecord(obj,'PromptText',promptxt,...
                                'CaseType',typesel,'CaseClass',classel,...
                                'SelectionMode',mode,'ListSize',[250,200]);
        end
%%
        function useCase(obj,mode,classname,action)
            %select which existing data set to use and pass to action method
            % mode - none, single or multiple selection mode  
            % classname - name of class to select cases for
            % action - method of class to pass class object to (eg addData 
            %          in muiDataSet) 
            if strcmp(mode,'none')
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
        function id_class = setDataClassID(obj,classname)                                                          
            %assign the class instance and record ids and add new instance
            %to class handle. obj - new instance of class, 
            %handle - class handle, mobj - UI handle. 
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
            props = struct('case',[],'dset',[],'desc',[],'label',[],'data',[]);
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
        function [idx,dimnames] = getSelectedIndices(obj,UIsel,dst,attnames)
            %find the indices for the selected variable, and the row and 
            %dimension values. If dimension exists but is not defined, a
            %set of index values is created
            % UIsel - struct defined by UIs derived from muiDataUI
            % dst - dstable to extract indices from
            % attnames - field names of attributes {variable,row,dimensions}
            
            idx.var = UIsel.variable;
            uidims = UIsel.dims;
            ndim = length(uidims);
            idx.row = 1; dimnames.row = dst.RowNames;
            idx.dim = cell(1,ndim-1);
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
                        rvals = range2var(UIsel.dims(i).value);
                        var = int16(rvals{1}):int16(rvals{2});
                    end
                    %
                    if height(dst.DataTable)>1   %ensure offset is correct
                        idd = strcmp(attnames(3:end),uidims(i).name);
                    else  
                        idd = strcmp(attnames(2:end),uidims(i).name);
                    end
                    idx.dim{idd} = getIndices(obj,var,uidims(i).value);
                    dimnames.dim{idd} = var(idx.dim{idd});
                end  
            end
        end        
%%
        function indices = getIndices(~,var,value)
            %get the index or vector of indices based on selection
            % var is the variable to select from and value is a single
            % value to select the nearest index or a text string defining
            % the range of values required
            if ischar(value)
                indices = getvarindices(var,value);
            elseif length(var)>1
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
            dimnames{1} = dimvalues.row;
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
                seldim{i} = strip(var2str(dimnames{idx}'));
                seldimname{i} = dimatt{idx};
            end
            %
            for j=2:sdim
                myfun = @(x) sprintf('%s_%s',seldimname{j},x);
                seldim{j} = cellfun(myfun,seldim{j},'UniformOutput',false);
            end
        end
    end
end