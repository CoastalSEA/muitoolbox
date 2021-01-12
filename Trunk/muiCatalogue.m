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
            [caserec,ok] = selectCase(obj,'Select case to save:','single');
            if ok<1, return; end 
            
            
            
            
        end         
%%
        function deleteCases(obj,type,caserec)
            %select one or more records and delete records from catalogue 
            %and class instances
            if nargin<3  %if case to delete has not been specified
                [caserec,ok] = selectCase(obj,'Select cases to delete:',...
                                                         'multiple',type);                                      
                if ok<1, return; end  
            elseif contains(caserec,'All')
                if isempty(type) || strcmp(type,'All')
                    caserec = 1:height(obj.Catalogue);
                else
                    caserec = strcmp(obj.Catalogue.CaseType,type);
                end
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
        function reloadCase(obj,mobj,type,caserec)  
            %reload model input variables as the current settings
            if nargin<4  %if case to reload has not been specified
                [caserec,ok] = selectCase(obj,'Select case to reload:',...
                                                            'single',type); 
                if ok<1, return; end  
            end  
            cobj = getCase(obj,caserec);      %selected case
            minp = fieldnames(cobj.RunProps); %saved input class instances
            for i=1:length(minp)
                mobj.Inputs.(minp{i}) = cobj.RunProps.(minp{i});
            end          
        end
%% 
        function viewCaseSettings(obj,type,caserec)
            %view the saved input data for a selected Case
            if nargin<3  %if case to view has not been specified
                [caserec,ok] = selectCase(obj,'Select case to view:',...
                                                            'single',type); 
                if ok<1, return; end  
            end
            [cobj,~,catrec] = getCase(obj,caserec);
            
            casedesc = catrec.CaseDescription;
            inputs = fieldnames(cobj.RunProps);
            if isempty(cobj.RunProps)
                warndlg('The case selected has no input data');
                return;
            else
                propdata = {}; proplabels = {};
                for k=1:length(inputs)
                    localObj = cobj.RunProps.(inputs{k});
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
                tablefigure('Scenario settings',figtitle,{},varnames,propdata);
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
            % type - options to return the data as an array, table, dstable
            %        or a table where the 2nd dimension has been split into
            %        variables (see muiEditUI for example of usage)
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
                [id,dnames] = getSelectedIndices(obj,UIsel,dst,varatt);
                varlabels = getLabels(dst,'Variable');
                label = varlabels{UIsel.property};
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
                        dimnames = setDimNames(obj,array,dnames,varatt);                        
                        data = array2table(array,'RowNames',dimnames{1},...
                                            'VariableNames',dimnames{2});
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
                label = dimlabels{UIsel.property-2}; %subtract variable and row
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
            %dimension ranges or values.
            idx.var = UIsel.variable;
            uidims = UIsel.dims;
            ndim = length(uidims);
            idx.dim = cell(1,ndim-1);
            for i=1:ndim
                %assign to dimension or row                    
                if strcmp(names{2},uidims(i).name) %this is a row
                    var = dst.RowNames;
                    idx.row = getIndices(obj,var,uidims(i).value);
                    dimnames.row = var(idx.row);
                else                               %must be a dimension
                    var = dst.Dimensions.(uidims(i).name);
                    idd = strcmp(names(3:end),uidims(i).name);
                    idx.dim{idd} = getIndices(obj,var,uidims(i).value);
                    dimnames.dim{idd} = var(idx.dim{idd});
                end  
            end
        end
%%
        function indices = getIndices(~,var,value)
            %get the index or vector of indices based on selection
            % var is the variable to select from and value is a single
            % value to select the nearest index or a text dtring defining
            % the range of values required
            if ischar(value)
                indices = getVarIndices(var,value);
            else
                indices = interp1(var,1:length(var),value,'nearest');                                   
            end
        end
%%
        function seldim = setDimNames(~,array,dnames,varatt)
            %match the selected dimensions to the data array and convert to
            %text RowNames and valid variable names
            sz = size(array);
            ndim = length(dnames.dim);
            dimnames{1} = dnames.row;
            dimnames(2:ndim+1) = dnames.dim;
            dimatt = varatt(2:end);
            sdim = length(sz);
            seldim = cell(1,sdim); seldimname = seldim;
            for i=1:sdim
                idx = cellfun(@length,dimnames)==sz(i);
                seldim{i} = var2str(dimnames{idx});
                seldimname{i} = dimatt{idx};
            end
            %
            for j=2:sdim
                myfun = @(x) sprintf('%s_%s',seldimname{j},x);
                seldim{j} = cellfun(myfun,seldim{j},'UniformOutput',false);
            end
        end
    end
%%
    methods (Access=private)
        function [caserec,ok] = selectCase(obj,promptxt,mode,type)
            if nargin<4  || strcmpi(type,'All')
                type = [];
            end
            [caserec,ok] = selectRecord(obj,'PromptText',promptxt,...
                'SelectionMode',mode,'CaseType',type,'ListSize',[250,200]);
        end
%%       
        function delete_dataset(obj,caserec)
            %delete selected record and data set 
            [~,classrec,catrec] = getCase(obj,caserec);
            classname = catrec.CaseClass; 
            %clear instance of data set class
            obj.DataSets.(classname)(classrec) = [];
        end          
    end
end