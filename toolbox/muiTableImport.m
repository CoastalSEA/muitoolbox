classdef muiTableImport < muiDataSet                          
%
%-------class help---------------------------------------------------------
% NAME
%   muiTableImport.m
% PURPOSE
%   Class to import a spreadsheet table, ascii data or Matlab table, adding 
%   the results to dstable and a record in a dscatlogue (as a property 
%   of muiCatalogue)
% USAGE
%   muiTableImport.loadData(muicat) %create a record
%   othe methods include assRows, addVariables, addDataset, delRows,
%   delVariables, delDataset, tabPlot, tabTable
% SEE ALSO
%   uses dstable and dscatalogue, called in TableViewer
%
% Author: Ian Townend
% CoastalSEA (c) May 2024
%--------------------------------------------------------------------------
%    
    properties  
        %inherits Data, RunParam, MetaData and CaseIndex from muiDataSet
    end
    
    methods 
        function obj = muiTableImport()                
            %class constructor
        end
    end
%%    
    methods (Static)
        function loadData(muicat)
            %read and load a data set from a file
            obj = muiTableImport;  
            [newdst,fname] = muiTableImport.loadFile();
            if isempty(newdst), return; end

            promptxt = {'Provide description of the data sources          >','Name for dataset being added'};
            metatxt = inputdlg(promptxt,'muiTableImport',1);

            %extract dataset names and ensure valid fieldname
            if isempty(metatxt{2})
                datasetname = 'Dataset';
            else
                datasetname = matlab.lang.makeValidName(metatxt{2});
            end

            if isa(newdst,'struct')
                dst = newdst;
                %handle multiple dstables
                dsetnames = fieldnames(dst); %names of datasets
                for j=1:length(dsetnames)
                    %use existing dataset names (ignore datasetname)
                    dsname = dsetnames{j};
                    %use UI to allow user to add/edit DS properties
                    dst.(dsname) = muiTableImport.updateDSproperties(dst.(dsname)); 
                    %assign metadata about data
                    dst.(dsname).Source{1} = fname;
                    dst.(dsname).MetaData = metatxt{1};
                end
            elseif isa(newdst,'dstable')
                %single table loaded
                promptxt = 'Option to load DS properties';
                answer = questdlg(promptxt,'Import','File','UI','Skip','UI');
                if strcmp(answer,'Skip')
                    %check that variable descriptions have been defined and
                    %if not use variable names.
                    idx = cellfun(@isempty,newdst.VariableDescriptions);
                    if any(idx)    
                        newdst.VariableDescriptions(idx) = newdst.VariableNames(idx);
                    end
                    %
                    idy = cellfun(@isempty,newdst.VariableLabels);
                    if any(idy)    
                        newdst.VariableLabels(idy) = newdst.VariableNames(idy);                        
                    end                    
                else
                    if strcmp(answer,'File')
                        newdst = muiTableImport.getDSpropertyFile(newdst);
                    end
                    if isempty(newdst), return; end %user cancelled loading of file
                    newdst = muiTableImport.updateDSproperties(newdst); 
                end
                %assign metadata about data
                newdst.Source{1} = fname;
                newdst.MetaData = metatxt{1};
                dst.(datasetname) = newdst;
            else
                warndlg('Unrecognised data type for newdst in muiTableImport.loadData')
                return;
            end
            
            %setDataRecord classobj, muiCatalogue obj, dataset, classtype
            setDataSetRecord(obj,muicat,dst,'data');           
        end 
    end
%%
    methods (Static, Access = protected)
        function [newdst,fname] = loadFile()
            %prompt user to select file, open and load file based on
            %file extension and create dstable with data, variable names
            %and row names.
            newdst = [];
            [fname,path,~] = getfiles('FileType','*.mat; *.txt; *.xlsx',...
                                           'PromptText','Select file to load');
            if fname==0, newdst = []; return; end
            [~,~,ext] = fileparts(fname);

            if strcmp(ext,'.mat')
                %load data from an existing Matlab dstable or table
                S = load([path,fname]); %loads saved variables a struct
                sname = fieldnames(S);
                inp = S.(sname{1});     %assume only 1 variable in load file
                if isstruct(inp)
                    tablenames = fieldnames(inp);
                    for i=1:length(tablenames)
                        intable = inp.(tablenames{i});
                        if isa(intable,'table')      %change a table to a dstable                          
                            rownames = intable.Properties.RowNames;
                            dst = dstable(intable,'RowNames',rownames);
                            newdst.(tablenames{i}) = dst;
                        elseif isa(intable,'dstable')     
                            newdst.(tablenames{i}) = intable; %copy dstable
                        else
                            warndlg('Data type not handled in muiTableImport.loadFile')
                        end                            
                    end
                elseif isa(inp,'table')      %change a table to a dstable
                    rownames = inp.Properties.RowNames;
                    newdst = dstable(inp,'RowNames',rownames);
                elseif isa(inp,'dstable') 
                    newdst = inp;
                else
                    warndlg('Data type not handled in muiTableImport.loadFile')
                end
            elseif strcmp(ext,'.txt')
                %read a text file with the row names defined in the first
                %column and the variable names defined in the first row
                intable = readtable([path,fname],'FileType','text',...
                     'ReadRowNames',true,'ReadVariableNames',true,...
                     'VariableNamingRule','preserve');
                rownames = intable.Properties.RowNames;
                newdst = dstable(intable,'RowNames',rownames);
            elseif strcmp(ext,'.xlsx')
                %load data from an Excel spreadsheet
                newdst = readspreadsheet([path,fname],true); %return a dstable
            else
                warndlg('File type not handled in muiTableImport.loadFile')
            end
        end
%%
        function newdst = getDSpropertyFile(newdst)
            %load DSproperties from a struct in an m file or as variables
            %from a text file
            [fname,path,~] = getfiles('FileType','*.m; *.txt;*.xlsx',...
                               'PromptText','Select file to load');
            if fname==0, newdst = []; return; end
            [~,~,ext] = fileparts(fname);

            if strcmp(ext,'.m')    %matlab file loaded
                %run and check that it containts a struct
                addpath(path);
                dspfunc = str2func(fname(1:end-2));
                dsp = dspfunc();
                rmpath(path);
                newdst.DSproperties = dsp;    
            elseif strcmp(ext,'.txt')    %text file loaded
                %load and create dsproperties struct 
                opts = detectImportOptions([path,fname], 'Delimiter', {'\t',','});
                opts.VariableNamesLine = 1; 
                intable = readtable([path,fname],opts);

                %format as a dsproperty struct
                dspvars = table2struct(intable);
                dsp = muiTableImport.loadDSproperties(dspvars);
                newdst.DSproperties = dsp;   
            elseif strcmp(ext,'.xlsx')
                %load data from an Excel spreadsheet
                cell_ids = {'A1';'A2';''};
                vartable = readspreadsheet([path,fname],false,cell_ids); %return a table
                dspvars = table2struct(vartable);
                dsp = muiTableImport.loadDSproperties(dspvars);
                newdst.DSproperties = dsp;
            else
                warndlg('File type not handled in muiTableImport.loadFile')
                newdst = [];
            end    
        end
%%
        function dst = updateDSproperties(dst)
            %prompt user to edit the variable and row definitions
            aa = dst.DSproperties;               
            vardef = getDSpropsStruct(aa,2);
            vardef.Variables.QCflag = 'none';
            vardef.Row.Format = '''';
            setDefaultDSproperties(aa,...
                        'Variables',vardef.Variables,'Row',vardef.Row);
            dst.DSproperties = setDSproperties(aa);

            %add data type to format
            varnames = dst.VariableNames;
            for i=1:length(varnames)
                value = dst.(varnames{i})(1);
                if isdatetime(value) || isduration(value)
                    dtype = value.Format;
                else
                    dtype = getdatatype(value);                    
                end
                dst.VariableQCflags{i} = dtype{1};
            end
        end

    end   
%%
    methods
        function addRows(obj,classrec,~,muicat) 
            %add additional rows to an existing user dataset
            datasetname = getDataSetName(obj); %prompts user to select dataset if more than one
            dst = obj.Data.(datasetname);      %selected dstable
            [newdst,fname] = muiTableImport.loadFile();
            if isempty(newdst), return; end
            dst = vertcat(dst,newdst);
            if isempty(dst), return; end
            %assign metadata about data
            nfile = length(dst.Source);
            dst.Source{nfile+1} = fname;
            
            obj.Data.(datasetname) = dst;  
            updateCase(muicat,obj,classrec);
        end

%%
        function addVariables(obj,classrec,~,muicat) 
            %add additional variables to an existing user dataset
            datasetname = getDataSetName(obj); %prompts user to select dataset if more than one
            dst = obj.Data.(datasetname);      %selected dstable
            [newdst,fname] = muiTableImport.loadFile();
            if isempty(newdst), return; end

            %new table loaded
            promptxt = 'Option to load DS properties';
            answer = questdlg(promptxt,'Import','File','UI','Skip','UI');
            if ~strcmp(answer,'Skip')
                if strcmp(answer,'File')
                    newdst = muiTableImport.getDSpropertyFile(newdst);
                end
                newdst = muiTableImport.updateDSproperties(newdst); 
            end

            dst = horzcat(dst,newdst);
            if isempty(dst), return; end
            %assign metadata about data
            nfile = length(dst.Source);
            dst.Source{nfile+1} = fname;
            
            obj.Data.(datasetname) = dst;  
            updateCase(muicat,obj,classrec);
        end

%%
        function addDataset(obj,classrec,~,muicat) 
            %add additional dataset to an existing case record
            [newdst,fname] = muiTableImport.loadFile();
            promptxt = 'Option to load DS properties';
            answer = questdlg(promptxt,'Import','File','UI','Skip','UI');
            if ~strcmp(answer,'Skip')
                if strcmp(answer,'File')
                    newdst = muiTableImport.getDSpropertyFile(newdst);
                end
                newdst = muiTableImport.updateDSproperties(newdst);
            end
            if isempty(newdst), return; end

            promptxt = {'Provide description of the data sources          >','Name for dataset being added'};
            metatxt = inputdlg(promptxt,'muiTableImport',1);
            dsnames = fieldnames(obj.Data);
            if isempty(metatxt{2})
                metatxt{2} = sprintf('%s_%d',fname,length(dsnames)+1);
            end

            %assign metadata about data
            newdst.Source{1} = fname;
            newdst.MetaData = metatxt{1};
            newdst.Description = obj.Data.(dsnames{1}).Description;
            %extrac dataset names and ensure valid fieldname
            datasetname = matlab.lang.makeValidName(metatxt{2});
            
            obj.Data.(datasetname) = newdst;  
            updateCase(muicat,obj,classrec);
        end

%%
        function delRows(obj,classrec,~,muicat)
            %delete rows from a dataset
            datasetname = getDataSetName(obj); %prompts user to select dataset if more than one
            dst = obj.Data.(datasetname);      %selected dstable
            %select rows to delete
            delist = dst.DataTable.Properties.RowNames; %get char row names
            promptxt = 'Select rows';
            att2use = 1;
            if length(delist)>1
                [att2use,ok] = listdlg('PromptString',promptxt,...
                    'Name','Delete data','SelectionMode','multiple',...
                    'ListSize',[250,100],'ListString',delist);
                if ok<1, return; end
            end

            %get user to confirm selection
            checktxt = 'Deleting the following rows:';
            for i=1:length(att2use)
                checktxt = sprintf('%s\n%s',checktxt,delist{att2use(i)});
            end
            answer = questdlg(checktxt,'Delete','Continue','Quit','Quit');
            if strcmp(answer,'Quit'), return; end

            %delete selected rows
            dst = removerows(dst,att2use);  
        
            obj.Data.(datasetname) = dst;
            updateCase(muicat,obj,classrec);
        end

%%
        function delVariables(obj,classrec,~,muicat)
            %delete variable from a dataset
            datasetname = getDataSetName(obj); %prompts user to select dataset if more than one
            dst = obj.Data.(datasetname);      %selected dstable
            %select variable to delete
            delist = dst.VariableDescriptions;        %get variable names
            promptxt = 'Select Variable';
            att2use = 1;
            if length(delist)>1
                [att2use,ok] = listdlg('PromptString',promptxt,...
                    'Name','Delete data','SelectionMode','multiple',...
                    'ListSize',[250,100],'ListString',delist);
                if ok<1, return; end
            end

            %get user to confirm selection
            checktxt = 'Deleting the following variables:';
            for i=1:length(att2use)
                checktxt = sprintf('%s\n%s',checktxt,delist{att2use(i)});
            end
            answer = questdlg(checktxt,'Delete','Continue','Quit','Quit');
            if strcmp(answer,'Quit'), return; end

            %delete selected variables
            dst = removevars(dst,dst.VariableNames(att2use));  
        
            obj.Data.(datasetname) = dst;
            updateCase(muicat,obj,classrec);
        end    

%%
        function delDataset(obj,classrec,~,muicat)
            %delete a dataset
            dst = obj.Data;
            if length(fieldnames(dst))==1
                %catch if only one dataset as need to delete Case
                warndlg(sprintf('There is only one dataset in this Case\nTo delete the Case use: Project > Cases > Delete Case'))
                return
            else
                datasetname = getDataSetName(obj); %prompts user to select dataset if more than one
                %get user to confirm selection
                checktxt = sprintf('Deleting the following dataset: %s',datasetname);
                answer = questdlg(checktxt,'Delete','Continue','Quit','Quit');
                if strcmp(answer,'Quit'), return; end
                dst = rmfield(dst,datasetname);    %delete selected dstable
            end

            obj.Data = dst;
            updateCase(muicat,obj,classrec);
        end

%%
        function tabPlot(obj,mobj,src)
            %generate plot for display on Q-Plot tab
            tabcb  = @(src,evdat)tabPlot(obj,mobj,src);
            ax = tabfigureplot(obj,src,tabcb,false);
            %get data and variable id
            [dst,idd,idv] =selectDataSet(obj);
            if isempty(idv), return; end

            %test for array of allowed data types for a color image
            [vdim,cdim,~] = getvariabledimensions(dst,idv);
            isim = isimage(dst.DataTable{1,1});
            if isim(1) && (vdim==1 && cdim==0) 
                %cannot be image if single row but can be an array
                %isim(1) is color and isim(2) is greyscale
                img = dst.(dst.VariableNames{idv});
                location = dst.RowNames;
                idl = listdlg('PromptString','Select estuary:',...
                          'SelectionMode','single','ListString',location);                    
                imshow(img{idl});
            else
                if cdim==0                       %scalar values
                    scalarplot(obj,mobj,ax,idd,idv);
                elseif cdim==1                   %vectors
                    vardesc = dst.VariableDescriptions;
                    idx = listdlg('PromptString','Select X-variable:',...
                            'SelectionMode','single','ListString',vardesc);                        
                    if isempty(idx), return; end
                    vectorplot(obj,ax,dst,idv,idx);
                elseif cdim==2                  %arrays
                    rowdesc = dst.RowNames;
                    if isnumeric(rowdesc), rowdesc = num2str(rowdesc); end
                    idx = listdlg('PromptString','Select X-variable:',...
                            'SelectionMode','single','ListString',rowdesc);                        
                    if isempty(idx), return; end
                    arrayplot(obj,ax,dst,idv,idx);
                else
                    warndlg('Tab plot currently only handles 1-3 dimensions')                    
                end
            end
        end

%%
        function [ax,idx,ids] = userPlot(obj,mobj,idd,idv,ax)
            %allows external functions to call vectorplot and scalarplot
            % idd - index of dataset to use for plot
            % idv - index of variable to use
            % ax - handle to figure axes (optional,created if not supplied) 
            % idx - sort order of x-variable if a scalarplot and the
            %       selected x-variable if a vector plot
            % ids - indices of selected sub-set (after sorting)             
            if nargin<5
                hfig = figure('Name','UserPlot','Units','normalized',...
                                            'Resize','on','Tag','PlotFig'); 
                ax = axes(hfig);
            end

            datasets = fieldnames(obj.Data);
            dst = obj.Data.(datasets{idd});  %selected dataset
            if size(dst.DataTable{1,1},2)>1  %matrix data set              
                vardesc = dst.VariableDescriptions;
                idx = listdlg('PromptString','Select X-variable:',...
                    'SelectionMode','single','ListString',vardesc);
                if isempty(idx), return; end
                vectorplot(obj,ax,idd,idv,idx);
            else
                [idx,ids] = scalarplot(obj,mobj,ax,idd,idv);
            end
        end

%%
        function tabTable(obj,src)
            %generate table for display on Table tab
            ht = findobj(src,'-not','Type','uitab'); %clear any existing content
            delete(ht)
            datasetname = getDataSetName(obj);
            dst = obj.Data.(datasetname);

            %generate table
            table_figure(dst,src)
        end

    end
%%
    methods(Access = protected)
        function [idx,ids] = scalarplot(obj,mobj,ax,idd,idv)
            %plot selected variable as function of location
            % idx - sort order of x-variable
            % ids - indices of selected sub-set (after sorting)
            datasets = fieldnames(obj.Data);
            dst = obj.Data.(datasets{idd});  %selected dataset
            location = dst.RowNames;
            rn = categorical(location,location);

            y = dst.DataTable{:,idv};
            if iscell(y) && ischar(y{1})      
                %if variable is not numeric make it numeric
                y = categorical(y,'Ordinal',true);    
                cats = categories(y);
                y = double(y); %convert categorical data to numerical
            else
                cats = [];
            end

            if isempty(rn) %handle case where rownames not defined
                rn = 1:length(y);
                rn = categorical(rn,rn);
            end

            %option to plot alphabetically or in index order  
            %NB rn and idx are unchanged if data is categorical but order 
            %of categories is modified according to selection            
            [rn,idx] = sort_var(obj,mobj,idd,rn);
            if isempty(idx), ids = []; return; end            

            %option to subsample the x-variable
            [sub_rn,sub_y,ids,~] = subsample_var(rn,y(idx)); 
            if iscategorical(sub_y)
                cats = categories(sub_y);
                sub_y = double(sub_y); %convert categorical data to numerical
            elseif isdatetime(sub_y)
                stdate = min(sub_y);
                sub_y = sub_y-stdate;  %convert to durations
            end           

            %bar plot of selected variable
            bar(ax,sub_rn,sub_y);  
            titletxt = sprintf('Case: %s (%s)',dst.Description,datasets{idd});
            subtitle(dst.VariableDescriptions{idv});
            title (titletxt);
            if ~isempty(cats)  
                yticks(1:length(cats));
                yticklabels(cats);
            elseif isdatetime(y)
                ytk = ax.YTick;
                dtime = stdate+ytk;
                yticklabels(datestr(dtime))  
            end
            xlabel(dst.RowLabel)
            if isempty(dst.VariableLabels)
                ylabel(dst.VariableNames{idv})
            else
                ylabel(dst.VariableLabels{idv})
            end
            
            src = ax.Parent;                             %handle to tab

            %add control buttons for scalar plots only (can be set in call
            %to tabfigureplot but that would set them for all plot types)
            hb = findobj(src,'Tag','LogButton'); delete(hb)
            hb = findobj(src,'Tag','NaNButton'); delete(hb)
            %button to toggle y-axis between linear and log scale
            uicontrol('Parent',src,'Style','pushbutton',...
                'String','>Log','Tag','LogButton',...
                'Tooltip','Switch to Log',...
                'Units','normalized','Position',[0.015 0.95 0.06 0.044],...
                'UserData','y-axis',...
                'Callback',@(src,evdat)setlog(ax,src,evdat));
            %button to remove or include Nan values
            src.UserData = {sub_rn,sub_y};
            uicontrol('Parent',src,'Style','pushbutton',...
                'String','-NaN','Tag','NaNButton',...
                'Tooltip','Exclude NaNs',...
                'Units','normalized','Position',[0.015 0.90 0.06 0.044],...
                'Callback',@(src,evdat)setnan(ax,src,evdat));

            ax.Color = [0.96,0.96,0.96];  %needs to be set after plot  
        end

%%
        function vectorplot(~,ax,dst,idv,idx)
            %plot selected variable for all locations
            rowname = dst.RowNames;
            var = dst.(dst.VariableNames{idv});
            Xvar = dst.(dst.VariableNames{idx});
            [rowname,~,ids,~] = subsample_var(rowname,[]); 
            var = var(ids,:); Xvar = Xvar(ids,:);
            hold on
            for i=1:size(var,1)
                pvar = var(i,:)/max(var(i,:));   
                xvar = Xvar(i,:)/max(Xvar(i,:));
                p1 = plot(ax,xvar,pvar,'DisplayName',rowname{i});
                p1.ButtonDownFcn = {@godisplay};
            end
            hold off
            xlabel(sprintf('Normalised %s',dst.VariableLabels{idx}))
            ylabel(sprintf('Normalised %s',dst.VariableLabels{idv}))
            title(['Case: ',dst.Description])
            ax.Color = [0.96,0.96,0.96];  %needs to be set after plot  
        end
     
%%
        function arrayplot(~,ax,dst,idv,idx)
            %plot 2-D array for selected row in table
            var = dst.(dst.VariableNames{idv});
            var = squeeze(var(idx,:,:));
            rowvar = dst.DataTable.Properties.RowNames{idx};  %get a text value
            dimnames = dst.DimensionNames;
            dim1 = dst.Dimensions.(dimnames{1});
            dim2 = dst.Dimensions.(dimnames{2});

            if isnumeric(dim1)
                x = dim1;
            else
                x = 1:length(dim1);
            end
            %
            if isnumeric(dim2)
                y = dim2;
            else
                y = 1:length(dim2);
            end

            [X,Y] =meshgrid(x,y);
            contourf(ax,X,Y,var')
            xticks(x); yticks(y);
            
            if ~isnumeric(dim1)
                if iscellstr(dim1) || isstring(dim1)                    
                    xticklabels(dim1)
                else
                    xticklabels(string(dim1))
                end
            end
            %
            if ~isnumeric(dim2)
                if iscellstr(dim2) || isstring(dim2) 
                    yticklabels(dim2)
                else
                    yticklabels(char(dim2))
                end
            end
            xlabel(dst.DimensionLabels{1})
            ylabel(dst.DimensionLabels{2})
            title(sprintf('Case: %s, Row: %s',dst.Description,rowvar))
        end
%%
        function [dst,idd,idv] =selectDataSet(obj)
            %select dataset and variable to use for plot/analysis
            % dst - dstable for selected data set
            % idv - index of selected variable in dstable
            [datasetname,ok,idd] = getDataSetName(obj);
            if ok<1, dst = []; idd = []; idv = []; return; end
            dst = obj.Data.(datasetname);
            %--------------------------------------------------------------
            vardesc = dst.VariableDescriptions;
            if length(vardesc)>1
                idv = listdlg('PromptString','Select variable:',...
                          'SelectionMode','single','ListString',vardesc);                
            else
                idv = 1;
            end
        end
    end
%%
    methods(Static, Access=protected)
        function dsp = loadDSproperties(dspvars)
            %define a dsproperties struct and add the metadata
            dsp = struct('Variables',[],'Row',[],'Dimensions',[]); 

            dsp.Variables = dspvars;
            dsp.Row = struct(...
                'Name',{'Row_Names'},...
                'Description',{'Row Description'},...
                'Unit',{'-'},...
                'Label',{'Row Label'},...
                'Format',{''});        
            dsp.Dimensions = struct(...    
                'Name',{''},...
                'Description',{''},...
                'Unit',{''},...
                'Label',{''},...
                'Format',{''});   
        end
    end
end