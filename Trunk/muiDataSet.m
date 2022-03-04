classdef (Abstract = true) muiDataSet < handle
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
        Data        %struct of datasets. These can be multiple dstables, 
                    %or a mix of tables and other data types. The data are 
                    %indexed using the fieldnames of the struct
        RunParam    %instance of run parameter classes defining settings used
        MetaData    %property for user defined input                   
        %Note: dstables have constant dimensions for all variables in table.
        %      Variables with different dimensions should be stored in 
        %      seperate dstables. Variables with time-varying dimensions 
        %      should store the dimensions as variables.
        DataFormats %cell array of data formats available 
        idFormat    %class instance file format    
        FileSpec    %file loading spec {MultiSelect(on/off),FileType}       
    end
    
    properties (Hidden, SetAccess=private)
        CaseIndex       %case index assigned when class instance is loaded
    end
    
    methods (Abstract)    
        %methods that all subclasses must define
        tabPlot(obj)    %define how data should be displayed on tab
                        %when called by UI Plot tab
    end 
%% ------------------------------------------------------------------------
%   Methods for subclasses to load and add data
%--------------------------------------------------------------------------
    methods (Static)
        function loadData(muicat,classname)
            %load user data set from one or more files
            
            heq = str2func(classname);
            obj = heq();  %instance of class object
            if isempty(obj.DataFormats), return; end  %user cancelled
            
            if ~isa(obj,'UserData')  
                %get file format from class definition (note: UserData
                %FileFormat defined in class constructor)
                ok = setFileFormatID(obj);
                if ok<1, return; end
            end

            [fname,path,nfiles] = getfiles('MultiSelect',obj.FileSpec{1},...
                'FileType',obj.FileSpec{2},'PromptText','Select file(s):');
            if nfiles==0
                return;
            elseif iscell(fname)
                filename = [path fname{1}]; %multiselect returns cell array
            else
                filename = [path fname];    %single select returns char
            end
            
            %get data
            funcname = 'getData';
            [dst,ok] = callFileFormatFcn(obj,funcname,obj,filename);
            if ok<1 || isempty(dst), return; end
            %assign metadata about data, Note dst can be a struct
            dst = updateSource(dst,filename,1);
            
            hw = waitbar(0, 'Loading data. Please wait');
            %now load any other files of the same format
            if nfiles>1
                for jf = 2:nfiles
                    jf_file = fname{jf};
                    filename = [path jf_file];
                    adn_dst = callFileFormatFcn(obj,funcname,obj,filename);
                    if ~isempty(adn_dst)
                        dst = vertcat(dst,adn_dst); %#ok<AGROW>
                    end
                    dst = updateSource(dst,filename,jf);
                    waitbar(jf/nfiles)
                end                
            end
            close(hw);
            
            setDataSetRecord(obj,muicat,dst,'data');
            getdialog(sprintf('Data loaded in class: %s',classname));
            %--------------------------------------------------------------
            function dst = updateSource(dst,filename,jf)
                if isstruct(dst)
                    fnames = fieldnames(dst);
                    for i=1:length(fnames)
                        dst.(fnames{i}).Source{jf,1} = filename;
                    end
                else
                    dst.Source{jf,1} = filename;
                end
            end
        end
    end
%%    
    methods
        function addData(obj,classrec,catrec,muicat) 
            %add additional data to an existing user dataset
            datasetname = getDataSetName(obj);
            if isempty(datasetname), return; end
            dst = obj.Data.(datasetname);

            [fname,path,nfiles] = getfiles('MultiSelect','off',...
                'FileType',obj.FileSpec{2},'PromptText','Select file:');
            if nfiles==0, return; end
            filename = [path fname];
            %get data
            funcname = 'getData';
            [adn_dst,ok] = callFileFormatFcn(obj,funcname,obj,filename);
            if ok<1 || isempty(adn_dst), return; end
            
            [~,~,ndim] = getvariabledimensions(dst,1);
            if strcmp(dst.RowType,'datetime')  %insert data in existing record
                dst = mergerows(dst,adn_dst);  
            elseif ndim(1)==1 && ndim(2)>1
                warndlg('Vertical concatenation of X-arrays not possible')
                return
            else                               %concatenate in order to end
                dst = vertcat(dst,adn_dst);
            end
            if isempty(dst), return; end
            
            %assign metadata about data
            nfile = length(dst.Source);
            dst.Source{nfile+1} = filename;
            
            obj.Data.(datasetname) = dst;  
            updateCase(muicat,obj,classrec);
            getdialog(sprintf('Data added to: %s',catrec.CaseDescription));
        end        
%%
        function deleteData(obj,classrec,catrec,muicat)
            %delete variable or rows from a dataset
            datasetname = getDataSetName(obj);
            dst = obj.Data.(datasetname);
            
            %option to delete a variable (column) or dimension rows (rows of
            %array - not just table rows)
            title = 'Delete data';
            selopt = questdlg('Delete selected:',title',...
                                      'variable','dimension','variable');
            if strcmp(selopt,'variable')
                delist = dst.VariableNames;
            else
                names = getVarAttributes(dst,1);
                delist = names(2:end);
            end
            %select variable or dimension to use
            promptxt = {sprintf('Select %s',selopt)}; 
            att2use = 1;
            if length(delist)>1
                [att2use,ok] = listdlg('PromptString',promptxt,...
                                 'Name',title,'SelectionMode','single',...
                                 'ListSize',[250,100],'ListString',delist);
                if ok<1, return; end  
            end
            
            if strcmp(selopt,'variable')
                dst.(delist{att2use}) = [];  %delete selected variable
            else
                %use access via DataTable so that values are returned as
                %cell array of character vectors
                dimprops = dst.DataTable.Properties;
                %get list of row or dimension values
                if strcmp(delist{att2use},'RowNames')
                    dimlist = dimprops.RowNames;
                    isrow = true;
                else
                    dimlist = dimprops.CustomProperties.Dimensions.(delist{att2use});
                    isrow = false;
                end                
                [rows2use,ok] = listdlg('PromptString',promptxt,...
                                 'Name',title,'SelectionMode','multiple',...
                                 'ListSize',[120,300],'ListString',dimlist);
                if ok<1, return; end  
                %delete selected values for row or dimension                
                idx = setdiff((1:length(dimlist)),rows2use); %rows to be kept
                if isrow  
                    dst = removerows(dst,rownames);          %delete rows
                else
                    dimcall = sprintf('Dimensions.%s',delist{att2use});                    
                    dimlist = dst.Dimensions.(delist{att2use})(idx);
                    dst = getDSTable(dst,dimcall,dimlist);  %resample dstable
                end
            end
            
            obj.Data.(datasetname) = dst;            
            updateCase(muicat,obj,classrec);
            getdialog(sprintf('Data deleted from: %s',catrec.CaseDescription));
        end
%%
        function qcData(obj,classrec,~,muicat)
            %apply quality control to a dataset
            funcname = 'dataQC';
            [output,ok] = callFileFormatFcn(obj,funcname,obj);
            if ok<1 || isempty(output), return; end
            
            %update dataset record - output contains {dst,datasetname}
            obj.Data.(output{2}) = output{1};             
            updateCase(muicat,obj,classrec);
        end
%%
        function [datasetname,ok] = getDataSetName(obj)
            %check whether there is more than one dstable and select
            dataset = 1; ok = 1; datasetname = [];  %initialise variables
            
            datasetnames = fieldnames(obj.Data);
            if length(datasetnames)>1
                promptxt = {'Select dataset'};
                title = 'DataSet names';
                [dataset,ok] = listdlg('PromptString',promptxt,...
                           'SelectionMode','single','Name',title,...
                           'ListSize',[300,100],'ListString',datasetnames);
                if ok<1,  return; end       
            end
            datasetname = datasetnames{dataset};
        end  
%%
        function [cobj,dst,ok] = selectClassInstance(obj,propname,propvalue)
            %Prompt to select a class instance. Filter based on a class
            %property is optional. Returns class instance and selected
            %dataset
            select = 1; dst = [];   %initialise variables
            
            [dsname,ok] = getDataSetName(obj(1));
            if ok<1,  return; end  
            caselist = arrayfun(@(x) x.Data.(dsname).Description,obj,...
                                                    'UniformOutput',false);                                  
            if length(caselist)>1                                    
                if nargin==3 && ~isempty(propvalue)      
                    %subselect based on user defined class property and value
                    proplist = {obj(:).(propname)};
                    idx = find(ismember(proplist,propvalue));
                    caselist = caselist(idx);
                end
                %
                if length(caselist)>1 
                    promptxt = {'Select case to use:'};
                    title = 'Class instances';
                    [select,ok] = listdlg('PromptString',promptxt,...
                               'SelectionMode','single','Name',title,...
                               'ListSize',[300,100],'ListString',caselist);
                    if ok<1, return; end     
                end
            end
            
            if length(obj)~=length(caselist)
                %find index in full list if subselection used
                select = idx(select);
            end
            
            cobj = obj(select);
            dst = cobj.Data.(dsname);
        end
%%
        function caseidx = getClassInstances(obj,propname,propvalue)
            %get the class indices for the instances where propname 
            %matches propvalue (propvalue can be a cell array
            proplist = {obj(:).(propname)};
            idx = ismember(proplist,propvalue);
            caseidx = [obj(idx).CaseIndex];
        end
%%
        function data = readTSinputFile(~,filename)
            %uses Matlab detectImportOptions to decipher the header and read the
            %data into a table where the columns use the variable names in file (if
            %defined). Check that no times are duplicated and standardise the data
            %so that missing times are removed and missing data are set to NaN
            %Time MUST be first column in table to use this function
            opts = detectImportOptions(filename,'FileType','text');  %v2016b
            data = readtable(filename,opts); 
            if isempty(data)
                data = [];
                return; 
            end
            
            %check for duplicate records - time is first column in table!!!
            [~,iu] = unique(data.(1));
            data = data(iu,:);
            %check for missing data
            data = standardizeMissing(data,[99,99.9,99.99,999,9999]);
            %check for incorrect date-time (NAT)
            data = rmmissing(data,'DataVariables',1);
        end   
%%
        function caseid = setDataSetRecord(obj,muicat,dataset,varargin)
            %assign dataset to class Data property and update catalogue
            % muicat - muiCatalogue object
            % dataset - the dataset or cell array of data sets to be added
            % varargin - input to dscatalogue.addRecord. minimum is
            %            datatype but can also include a cell with the case 
            %            description and logical flag to supress user prompt
            %returns caseid to enable retrieval of newly created record
            if isstruct(dataset)
                obj.Data = dataset;   %can be struct of multiple tables
            else
                obj.Data.Dataset = dataset;  
            end
            caseid = setCase(muicat,obj,varargin{:});
        end           
        
    end
%% ------------------------------------------------------------------------
%   Methods to set DataSet, RunParam, FileFormat and FileFormatID
%--------------------------------------------------------------------------     
    methods (Access = {?muiDataSet,?muiCatalogue}) %self reference is equivalent to protected
        function setRunParam(obj,mobj,varargin)
            %assign the run parameters needed for a model (NB data source
            %files are saved to the dstable.Source property)
            %varargin used to pass additional caserec values of the model
            %cases used as input (see eg ctTidalAnalysis)
            classname = metaclass(obj).Name;
            minp = mobj.ModelInputs.(classname);

            if ~isempty(mobj.Inputs)
                %classes that define runtime parameters
                definedinput = fieldnames(mobj.Inputs);
                isinp = find(ismember(minp,definedinput));
                for i=1:length(isinp)
                    obj.RunParam.(minp{isinp(i)}) = copy(mobj.Inputs.(minp{isinp(i)}));
                end
            end
            %
            muicat = mobj.Cases;
            if ~isempty(muicat.DataSets)
                %classes that define model input datasets
                %save caseID, caseDescription and caseClass for use in
                %muiCatalogue-viewCaseSettings (because Case may get deleted)
                for i=1:length(varargin)
                    [cobj,~,catrec] = getCase(muicat,varargin{i});
                    cname = metaclass(cobj).Name;
                    obj.RunParam.(cname).caseid = cobj.CaseIndex;
                    obj.RunParam.(cname).casedesc = catrec.CaseDescription;
                    obj.RunParam.(cname).caseclass = cname;
                end
            end            
        end                 
%%
        function setCaseIndex(obj,caseid)
            %Assign the CaseIndex property (called by muiCatalogue.setCase)
            obj.CaseIndex = caseid;
        end
%%
        function formatfile = setFileFormat(~)
            %prompt user to select a FileFormat m file
            [fname,~,~] = getfiles('PromptText','Format code file','FileType','*.m');
            if fname==0, formatfile = []; return; end  %user cancelled
            %check that can find file on path
            isfile = exist(fname,'file');
            if isfile==2
                formatfile = fname(1:end-2); %function name to call format file
            else
                warndlg('File not found. Check that folder is on Matlab path')
                formatfile = [];
            end
        end
%%
        function ok = setFileFormatID(obj)
            %prompt user to select a file format 
            if length(obj.DataFormats(:,1))>1
                [selection,ok] = listdlg('PromptString','Select a file format',...
                        'SelectionMode','single','ListSize',[300,100],...
                        'ListString',obj.DataFormats(:,1));
            obj.idFormat = selection;  
            else
                obj.idFormat = 1;
                ok = 1;
            end
        end
%%
        function idf = getFileFormatID(obj,muicat)
            %extract all the file formats from a set of objects
            classname = metaclass(obj).Name; 
            idf = []; 
            caserec = find(strcmp(muicat.Catalogue.CaseClass,classname));
            if isempty(caserec), return; end
            cobj = getCases(muicat,caserec);
            if isempty(cobj), return; end
            idf = unique([cobj.idFormat]);
        end
%%
        function [out1,ok] = callFileFormatFcn(obj,funcname,varargin)
            %call a function in the data format file 
            % funcname - name of the functions ('getDSproperties','getData','dataQC')
            % 
            % outvar - variable returned by function (if any)
            % ok - error flag; 1-if executions successful           
            formatfile = obj.DataFormats{obj.idFormat,2};    
            
            %unpack varargin to define call function
            nvar = length(varargin);
            varlist = '(funcname,var1';
            for i=2:nvar
                varlist = sprintf('%s,var%d',varlist,i);
            end
            varlist = sprintf('%s)',varlist);
            funcall = sprintf('@%s ',varlist);
            
            try
                heq = str2func([funcall,[formatfile,varlist]]);  
                out1 = heq(funcname,varargin{:});
                ok = 1;
            catch ME
                msgtxt = sprintf('Unable to evaluate call to %s function %s\nID: ',...
                                              formatfile,funcname);
                disp([msgtxt, ME.identifier])
                rethrow(ME)  
            end            
        end 
%%
%--------------------------------------------------------------------------
%   Default tab plot
%--------------------------------------------------------------------------    
        function tabDefaultPlot(obj,src)
            %default plotting function for Q-Plot tab

            %get data for variable
            datasetname = getDataSetName(obj);
            dst = obj.Data.(datasetname);
            [varname,varidx] = selectAttribute(dst,1);    %1=select variable
            [~,cdim,vsze] = getvariabledimensions(dst,varname);
            [attnames,~,attlabels] = getVarAttributes(dst,varidx);

            %get main variable
            pdat.V = dst.(varname);
            if size(pdat.V,1)==1
                pdat.V = squeeze(pdat.V);
            end
            labs.V = attlabels{1};
            
            %find if there are rows and if they are monotonic            
            if vsze(1)>1 || ...  %multiple rows
                    (vsze(1)==1 && ~isempty(dst.RowNames))
                nr = 3;           %dimension offset if rows
                rdim = 'X';
                istime = false;
                t = dst.RowNames;                
                if isdatetime(t) || isduration(t) || isnumeric(t)
                    istime = true;  rdim = 'T';
                elseif isnumeric(t) && issorted(t,'monotonic')
                    istime = true;  rdim = 'T';
                end
                pdat.(rdim) = t;
                labs.(rdim) = dst.RowDescription;
            else
                nr = 2;           %dimension offset if no rows 
                istime = true;    %ensures correct dimension assignment
            end
            
            %get the dimension names and unpack if used   
            dimnames = attnames(nr:end);
            dimlab = attlabels(nr:end);
            D = {'X','Y','Z'};
            for i=1:cdim    %unpack the dimensions if used
                if istime, j=i; else, j=i+1; end  %offset if rows are not time
                pdat.(D{j}) = dst.Dimensions.(dimnames{i});
                labs.(D{j}) = dimlab{i};
            end
            
            %merge row and dimension selection
            if istime && cdim<1    %row and no dimensions
                pdat.X = pdat.T; 
                labs.X = labs.T;
            end

            %generate plot for display on Q-Plot tab
            ht = findobj(src,'Type','axes');
            delete(ht);
            ax = axes('Parent',src,'Tag','Qplot');

            if vsze(1)==1            %no rowa
                if cdim==1           %line plot
                    DSplot(obj,ax,pdat,labs);  
                elseif cdim==2       %surface plot
                    DSsurface(obj,ax,pdat,labs);
%                     title(dst.Description);
                    DSrotatebutton(obj,ax,src);
                elseif cdim==3       %volume plot
                    DSvolume(obj,ax,pdat,labs);
%                     title(dst.Description);
                    DSrotatebutton(obj,ax,src);
                end
            elseif istime            %rows that are time or ordered
                if cdim==0  
                    DSplot(obj,ax,pdat,labs);     
                elseif cdim==1
                    DSsurface(obj,ax,pdat,labs);
%                     title(dst.Description);
                    DSrotatebutton(obj,ax,src);
                elseif cdim<4
                    DSanimation(obj,ax,pdat,labs,dst.Description,cdim);
                end    
            else                    %rows that are char,string,categorical,ordinal
                if cdim==0    
                        DSbar(obj,ax,pdat,labs); 
                elseif cdim==1
                    DSsurface(obj,ax,pdat,labs);
%                     title(dst.Description);
                    DSrotatebutton(obj,ax,src);
                elseif cdim==2
                    DSvolume(obj,ax,pdat,labs);
%                     title(dst.Description);
                    DSrotatebutton(obj,ax,src);
                end                  
            end
            title (dst.Description);
            ax.Color = [0.96,0.96,0.96];  %needs to be set after plot          
        end
%%
        function h = DSplot(~,ax,data,labels)
            %line plot for 1D variable
            cats = [];
            if iscell(data.V) && ischar(data.V{1})                   
                v = categorical(data.V,'Ordinal',true);    
                cats = categories(v);
                data.V = double(v); %convert categorical data to numerical
            end
            %
            if isempty(data.X)
                data.X = (1:length(data.V))';                
            end
            
            h = plot(ax,data.X,data.V);
            
            if ~isempty(cats)
                yticks(1:length(cats));
                yticklabels(cats);
            end
            xlabel(labels.X); 
            ylabel(labels.V);  
        end
%%
        function h = DSbar(~,ax,data,labels)
            %line plot for 1D variable
            if ~iscategorical(data.X)
                data.X = categorical(data.X,data.X);
            end
            %
            cats = [];
            if iscell(data.V) && ischar(data.V{1})                   
                y = categorical(data.V,'Ordinal',true);    
                cats = categories(y);
                data.V = double(y); %convert categorical data to numerical
            end
            %
            if isempty(data.X)
                data.X = (1:length(data.V))';                
            end
            
            h = bar(ax,data.X,data.V);
            
            if ~isempty(cats)
                yticks(1:length(cats));
                yticklabels(cats);
            end
            xlabel(labels.X); 
            ylabel(labels.V);  
        end
%%
        function h = DSsurface(~,ax,data,labels)
            %surface plot for 2D variable            
            h = surf(ax,data.X,data.Y,data.V','EdgeColor','none');
            shading interp
            h.ZDataSource = 'vi';
            xlabel(labels.X); 
            ylabel(labels.Y);  
            zlabel(labels.V)  
            view(3);
            cmap = cmap_selection;
            colormap(cmap)
            cb = colorbar;
            cb.Label.String = labels.V;
        end   
%%
        function h = DSvolume(~,ax,data,labels)
            %volume plot for 3D variable
            isovalue = mean(data.V,'all');
            h = patch(ax,isosurface(data.Y,data.X,data.Z,data.V,isovalue));
            isonormals(data.Y,data.X,data.Z,data.V,h);            
            h.FaceColor = 'blue';
            h.EdgeColor = 'red';
            view(3); 
            camlight 
            lighting gouraud
            xlabel(labels.Y); 
            ylabel(labels.X);
            zlabel(labels.Z);
        end
%%
        function DSanimation(obj,ax,data,labels,titletxt,cdim)
            %aninmate surface for time+2D data
            
            data1 = data;
            if cdim==2
                data1.V = squeeze(data.V(1,:,:));
                h = DSsurface(obj,ax,data1,labels);
                ax.XLim = [min(data.X),max(data.X)];
                ax.YLim = [min(data.Y),max(data.Y)];
                ax.ZLim = [min(data.V,[],'all'),max(data.V,[],'all')];
                hold(ax,'on')
                ax.ZLimMode = 'manual';
                for i=2:length(data.T)
                    vi = squeeze(data.V(i,:,:))'; %#ok<NASGU>
                    refreshdata(h,'caller')
                    txt1 = sprintf('Time = %s', string(data.T(i)));
                    title(sprintf('%s\n%s',titletxt,txt1))
                    drawnow; 
                end
            else
                data1.V = squeeze(data.V(1,:,:,:));
                h = DSvolume(obj,ax,data1,labels);
                ax.XLim = [min(data.Y),max(data.Y)];
                ax.YLim = [min(data.X),max(data.X)];
                ax.ZLim = [min(data.Z),max(data.Z)];
                grid on
                hold(ax,'on')
                for i=2:length(data.T)
                    vi = squeeze(data.V(i,:,:,:));
                    isovalue = mean(vi,'all');
                    delete(h)
                    h = patch(isosurface(data.Y,data.X,data.Z,vi,isovalue));
                    isonormals(data.Y,data.X,data.Z,vi,h)
                    h.FaceColor = 'blue';
                    h.EdgeColor = 'red';
                    txt1 = sprintf('Time = %s', string(data.T(i)));
                    title(sprintf('%s\n%s',titletxt,txt1))
                    drawnow; 
                end
            end 
            hold(ax,'off')
        end         
%%
        function DSrotatebutton(~,ax,src)
            %button to rotate surface plot
            hb = findobj(src,'Style','pushbutton','Tag','RotateButton');
            delete(hb) %delete button so that new axes is assigned to callback
            uicontrol('Parent',src,'Tag','RotateButton',...  %callback button
                'Style','pushbutton',...
                'String', 'Rotate off',...
                'Units','normalized', ...
                'Position', [0.02,0.92,0.1,0.05],...
                'TooltipString','Turn OFF when fiinished, otherwise tabs do not work',...
                'Callback',@(src,evtdat)rotatebutton(ax,src,evtdat));
        end
    end
end