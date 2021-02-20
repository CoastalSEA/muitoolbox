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
        function saveCase(obj)  
            %write the results for a selected case to an excel file            
            [caserec,ok] = selectCase(obj,'Select case to save:','single',2);
            if ok<1, return; end 
            
            
            
            
        end         
%%
        function deleteCases(obj,caserec)
            %select one or more records and delete records from catalogue 
            %and class instances
            if nargin<2  %if case to delete has not been specified
                [caserec,ok] = selectCase(obj,'Select cases to delete:',...
                                                       'multiple',2);                                      
                if ok<1 || isempty(caserec), return; end  
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
                mobj.Inputs.(minp{i}) = cobj.RunParam.(minp{i});
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
                propdata = {}; proplabels = {};
                for k=1:length(inputs)
                    localObj = cobj.RunParam.(inputs{k});
                    propdata = vertcat(propdata,getProperties(localObj));
                    proplabels = vertcat(proplabels,getPropertyNames(localObj));
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
        function [cobj,classrec,catrec] = getCase(obj,caserec)
            %retrieve the class instance, class record and catalogue record
            catrec = getRecord(obj,caserec); 
            lobj = obj.DataSets.(catrec.CaseClass);  
            classrec = [lobj.CaseIndex]==catrec.CaseID;            
            cobj = lobj(classrec);
        end
%%
        function [dst,caserec,idset] = getDataset(obj,caserec,idset)
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
            if ~isnumeric(idset) 
                idset =  find(strcmp(cobj.MetaData,idset));
                if isempty(idset)
                    idset = 1;    %no datasets defined so must only be one
                end
            end
            dst = cobj.Data{idset};  %selected dataset
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
            if nargin<3, type = 'array'; end
            istable = false;
            dst = getDataset(obj,UIsel.caserec,UIsel.dataset);
            [varatt,vardesc] = getVarAttributes(dst,UIsel.variable);
            useprop = varatt{UIsel.property};
            usedesc = vardesc{UIsel.property};
            
            if any(strcmp(dst.VariableNames,useprop))                
                %return selected dimensions of variable
                %NB: any range defined for the Variable is NOT applied
                %returns all values within dimension range specified
                [id,dvals] = getSelectedIndices(obj,UIsel,dst,varatt);
                varlabels = getLabels(dst,'Variable');
                label = varlabels{id.var};
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
                        dimnames = setDimNames(obj,array,dvals,varatt);                        
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
                rowlabel = getLabels(dst,'Row');
                label = rowlabel{1};
            elseif any(strcmp(dst.DimensionNames,useprop))
                %return selected dimension              
                iddim = getIndices(obj,dst.Dimensions.(useprop),UIsel.range);
                data = dst.Dimensions.(useprop)(iddim);
                dimlabels = getLabels(dst,'Dimension');
                %subtract variable and row (if used)
                if height(dst.DataTable)>1, nr=2; else, nr=1; end                  
                label = dimlabels{UIsel.property-nr}; 
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
            props.desc = usedesc;
            props.label = label;
            props.data = data;                    
        end
%%
        function [idx,dimnames] = getSelectedIndices(obj,UIsel,dst,names)
            %find the indices for the selected variable, and the row and 
            %dimension values.
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
                    var = dst.Dimensions.(uidims(i).name);
                    if height(dst.DataTable)>1   %ensure offset is correct
                        idd = strcmp(names(3:end),uidims(i).name);
                    else  
                        idd = strcmp(names(2:end),uidims(i).name);
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
            %text RowNames and valid variable names
            % array - sqeezed array sampled from first cell (note this is
            %         still (1xn) if vector data in a single row)
            % dimvalues - dimension values
            % varatt - variable attributes (variable,row,dimension names)
            sz = size(array);
            ndim = length(dimvalues.dim);
            dimatt = varatt(2:end);
            dimnames{1} = dimvalues.row;
            if sz(1)==1                    %single row
                dimnames{1} = 1;
                dimatt = ['Row1',dimatt];
            elseif isempty(dimnames{1})    %no RowNames assigned (not tested)
                dimnames{1} = 1:sz(1);
            end
            dimnames(2:ndim+1) = dimvalues.dim;

            sdim = length(sz);
            seldim = cell(1,sdim); seldimname = seldim;
            for i=1:sdim
                idx = cellfun(@length,dimnames)==sz(i);
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
        function [caserec,ok] = selectCase(obj,mode,promptxt,selopt)
            %select a case to use for something with options to subselect
            %the selection list based on class or type
            % mode - single or multiple selection mode
            % promtxt - text to use to prompt user
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
    end
%%
    methods (Access=private)      
        function delete_dataset(obj,caserec)
            %delete selected record and data set 
            [~,classrec,catrec] = getCase(obj,caserec);
            classname = catrec.CaseClass; 
            %clear instance of data set class
            obj.DataSets.(classname)(classrec) = [];
        end          
    end
end