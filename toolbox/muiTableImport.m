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
                else
                    if strcmp(answer,'File')
                        newdst = muiTableImport.getDSpropertyFile(newdst);
                    end
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
            [fname,path,~] = getfiles('FileType','*.mat; *.txt; *.xlsx',...
                                           'PromptText','Select file to load');
            if fname==0, newdst = []; return; end
            [~,~,ext] = fileparts(fname);

            if strcmp(ext,'.mat')
                %load data from an existing Matlab dstable or table
                inp = load([path,fname]);
                tablename = fieldnames(inp); %assumes inp is a struct?????
                intable = inp.(tablename{1});
                if isa(intable,'table')      %change a table to a dstable                          
                    rownames = intable.Properties.RowNames;
                    newdst = dstable(intable,'RowNames',rownames);
                else                         %load a dstable 
                    newdst = inp.(tablename{1});
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
                newdst = [];
            end
        end
%%
        function newdst = getDSpropertyFile(newdst)
            %load DSproperties from a struct in an m file or as variables
            %from a text file
            [fname,path,~] = getfiles('FileType','*.m; *.txt',...
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

                newdst.DSproperties = dsp;    
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

            %assign metadata about data
            newdst.Source{1} = fname;
            newdst.MetaData = metatxt{1};
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
            N = length(fieldnames(dst));
            if N==1
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
        function tabPlot(obj,src)
            %generate plot for display on Q-Plot tab
            tabcb  = @(src,evdat)tabPlot(obj,src);
            ax = tabfigureplot(obj,src,tabcb,false);
            %get data for variable and dimensions x,y,t
            datasetname = getDataSetName(obj);
            dst = obj.Data.(datasetname);
            %--------------------------------------------------------------
            vardesc = dst.VariableDescriptions;
            if length(vardesc)>1
                idv = listdlg('PromptString','Select variable:',...
                          'SelectionMode','single','ListString',vardesc);                
                if isempty(idv), return; end
            else
                idv = 1;
            end
            %test for array of allowed data types for a color image
            isim = isimage(dst.DataTable{1,1});
            if isim(1) %isim(1) is color and isim(2) is greyscale
                img = dst.(dst.VariableNames{idv});
                location = dst.RowNames;
                idl = listdlg('PromptString','Select estuary:',...
                          'SelectionMode','single','ListString',location);                    
                imshow(img{idl});
            else
                if size(dst.DataTable{1,1},2)>1
                    idx = listdlg('PromptString','Select X-variable:',...
                            'SelectionMode','single','ListString',vardesc);                        
                    if isempty(idv), return; end
                    vectorplot(obj,ax,dst,idv,idx);
                else
                    scalarplot(obj,ax,dst,idv);
                end
            end
        end

%%
        function tabTable(obj,src)
            %generate table for display on Table tab
            ht = findobj(src,'-not','Type','uitab'); %clear any existing content
            delete(ht)
            datasetname = getDataSetName(obj);
            dst = obj.Data.(datasetname);
            firstcell = dst.DataTable{1,1};
            if ~isscalar(firstcell) || (iscell(firstcell) && ~isscalar(firstcell{1}))
                %not tabular data
                warndlg('Selected dataset is not tabular')
                return; 
            end 
            %title = sprintf('Data for %s table',datasetname);
            desc = sprintf('Source:%s\nMeta-data: %s',dst.Source{1},dst.MetaData);
            tablefigure(src,desc,dst);        
            src.Units = 'normalized';
            uicontrol('Parent',src,'Style','text',...
                       'Units','normalized','Position',[0.1,0.95,0.8,0.05],...
                       'String',['Case: ',dst.Description],'FontSize',10,...
                       'HorizontalAlignment','center','Tag','titletxt');
        end

    end
%%
    methods(Access = protected)
        function vectorplot(~,ax,dst,idv,idx)
            %plot selected variable for all locations
            location = dst.RowNames;
            var = dst.(dst.VariableNames{idv});
            Xvar = dst.(dst.VariableNames{idx});
            hold on
            for i=1:size(var,1)
                pvar = var(i,:)/max(var(i,:));   
                xvar = Xvar(i,:)/max(Xvar(i,:));
                p1 = plot(ax,xvar,pvar,'DisplayName',location{i});
                p1.ButtonDownFcn = {@godisplay};
            end
            hold off
            xlabel(sprintf('Normalised %s',dst.VariableLabels{idx}))
            ylabel(sprintf('Normalised %s',dst.VariableLabels{idv}))
            title(dst.Description)
            ax.Color = [0.96,0.96,0.96];  %needs to be set after plot  
        end

%%
        function scalarplot(obj,ax,dst,idv)
            %plot selected variable as function of location
            location = dst.RowNames;
            rn = categorical(location,location);

            x = dst.DataTable{:,idv};
            if iscell(x) && ischar(x{1})      
                %if variable is not numeric make it numeric
                x = categorical(x,'Ordinal',true);    
                cats = categories(x);
                x = double(x); %convert categorical data to numerical
            else
                cats = [];
            end

            if isempty(rn) %handle case where rownames not defined
                rn = 1:length(x);
                rn = categorical(rn,rn);
            end

            %option to plot alphabetically or in index order
            answer = questdlg('Sort X-variable?','Import','Index','Sorted','Unsorted','Index');
            rn = sortXdata(obj,dst,rn,answer);
            
            %bar plot of selected variable
            bar(ax,rn,x);          
            title (dst.Description);
            if ~isempty(cats)
                yticks(1:length(cats));
                yticklabels(cats);
            end
            xlabel(dst.RowLabel)
            if isempty(dst.VariableLabels)
                ylabel(dst.VariableNames{idv})
            else
                ylabel(dst.VariableLabels{idv})
            end
            answer = questdlg('Linear or Log y-axis?','Qplot','Linear','Log','Linear');
            if strcmp(answer,'Log')
                ax.YScale = 'log';
            end
            ax.Color = [0.96,0.96,0.96];  %needs to be set after plot  
        end

%%
        function loc  = sortXdata(~,dst,loc,answer)
            %function to sort x-axis data to required order
            if strcmp(answer,'Index')
                %allow user to select a variable to sort by (must return
                %vector of unique values)
                ok = 1;
                while ok>0
                    var = [];
                    vardesc = dst.VariableDescriptions;
                    idv = listdlg('PromptString','Select variable:',...
                               'SelectionMode','single',...
                               'ListString',vardesc);
                    if isempty(idv), break; end
                    var = dst.(dst.VariableNames{idv});
                    if isunique(var)
                        ok = 0; 
                    else
                        hw = warndlg('Index variable must be vector of unique values');
                        waitfor(hw)
                    end
                end
                if isempty(var), return; end
                [~,idx] = sort(var);
                loc = reordercats(loc,idx);   
                
            elseif strcmp(answer,'Sorted')
                %sort categorical rownames into alphabetical order
                sloc = string(loc);
                [~,idx] = sort(sloc);
                loc = reordercats(loc,idx);
            end
        end

    end
end