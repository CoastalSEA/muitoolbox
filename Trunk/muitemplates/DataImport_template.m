classdef DataImport_template                                 % << Edit to classname
%
%-------class help---------------------------------------------------------
% NAME
%   DataImport_template.m
% PURPOSE
%   Class to illustrate importing a data set, adding the results to dstable
%   and a record in a dscatlogue (as a property of muiCatalogue)
% USAGE
%   obj = DataImport_template()
% SEE ALSO
%   uses dstable and dscatalogue
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
%    
    properties  
        Data
        RunParam
    end
    
    properties (Hidden, SetAccess=private)
        CaseIndex       %case index assigned when class instance is loaded
    end
    
    methods 
        function obj = DataImport_template()                 % << Edit to classname
            %class constructor
        end
    end
%%    
    methods (Static)
        function loadData(muicat,~)
            %read and load a data set from a file
            obj = DataImport_template;                       % << Edit to classnamet
            [data,~,filename] = readInputData(obj);             
            if isempty(data), return; end
            dsp = setDSproperties(obj);  %initialise dsproperties for data
            
            %code to parse input data and assign to varData
            rdata = data{1};
            vardata = data{2};

            %load the results into a dstable  
            dst = dstable(vardata,'RowNames',rdata,'DSproperties',dsp); 
            
            %assign metadata about data
            dst.Source{1} = filename;
            %setDataRecord classobj, muiCatalogue obj, dataset, classtype
            setDataSetRecord(obj,muicat,dst,'data');           
        end 
    end   
%%
    methods
        function addData(obj,classrec,catrec,muicat) 
            %add additional data to an existing user dataset
            datasetname = getDataSetName(obj); %prompts user to select dataset if more than one
            dst = obj.Data.(datasetname);      %selected dstable
            
            [data,~,filename] = readInputData(obj);             
            if isempty(data), return; end
            dsp = setDSproperties(obj);  %initialise dsproperties for data
            %load the results into a dstable            
            adn_dst = dstable(data{2},'DSproperties',dsp);
            adn_dst.Dimensions.Z = data{1};     %grid z-coordinate
            if isempty(adn_dst), return; end
            
            [~,~,ndim] = getvariabledimensions(dst,'uObs');
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
            datasetname = getDataSetName(obj); %prompts user to select dataset if more than one
            dst = obj.Data.(datasetname);      %selected dstable
            
            delist = dst.VariableNames;
            %select variable to use
            promptxt = {sprintf('Select Variable')}; 
            att2use = 1;
            if length(delist)>1
                [att2use,ok] = listdlg('PromptString',promptxt,...
                                 'Name',title,'SelectionMode','single',...
                                 'ListSize',[250,100],'ListString',delist);
                if ok<1, return; end  
            end
            promptxt = sprintf('Delete variable: %s?',delist{att2use});
            selopt = questdlg(promptxt,'Delete variable',...
                                      'Yes','No','No');
            if strcmp(selopt,'Yes')
                dst.(delist{att2use}) = [];  %delete selected variable

                obj.Data.(datasetname) = dst;            
                updateCase(muicat,obj,classrec);
                getdialog(sprintf('Data deleted from: %s',catrec.CaseDescription));
            end
        end
%%
        function qcData(obj,classrec,catrec,muicat)
            %quality control a dataset
            warndlg('No qualtiy control defined for this format');
        end          
%%
        function tabPlot(obj,src)
            %generate plot for display on Q-Plot tab
            
            %define data specific plot
        end     
        
    end
%%
    methods (Access = private)
         function setDataSetRecord(obj,muicat,dataset,datatype)
            %assign dataset to class Data property and update catalogue
            if isstruct(dataset)
                obj.Data = dataset;   %can be struct of multiple tables
            else
                obj.Data.Dataset = dataset;  
            end 
            classname = metaclass(obj).Name;            
            %add record to the catalogue and update mui.Cases.DataSets
            caserec = addRecord(muicat,classname,datatype);
            casedef = getRecord(muicat,caserec);
            obj.CaseIndex = casedef.CaseID;
            datasets = fieldnames(obj.Data);
            for i=1:length(datasets)
                if isa(obj.Data.(datasets{i}),'dstable')
                    obj.Data.(datasets{i}).Description = casedef.CaseDescription;
                end
            end
            %
            if isempty(muicat.DataSets) || ~isfield(muicat.DataSets,classname) ||...
                    isempty(muicat.DataSets.(classname))
                idrec = 1;
            else
                idrec = length(muicat.DataSets.(classname))+1;
            end
            muicat.DataSets.(classname)(idrec) = obj;           
        end  
%%
        function datasetname = getDataSetName(obj)
            %check whether there is more than one dstable and select
            dataset = 1;
            datasetnames = fieldnames(obj.Data);
            if length(datasetnames)>1
                promptxt = {'Select dataset'};
                title = 'Save dataset';
                [dataset,ok] = listdlg('PromptString',promptxt,...
                           'SelectionMode','single','Name',title,...
                           'ListSize',[300,100],'ListString',datasetnames);
                if ok<1, return; end       
            end
            datasetname = datasetnames{dataset};
        end
%%
        function [data,header,filename] = readInputData(~) 
            %read wind data (read format is file specific).
            [fname,path,~] = getfiles('FileType','*.txt');
            filename = [path fname];
            dataSpec = '%d %d %s %s %s %s'; 
            nhead = 1;     %number of header lines
            [data,header] = readinputfile(filename,nhead,dataSpec);
        end       
%%        
        function dsp = setDSproperties(~)
            %define the metadata properties for the demo data set
            dsp = struct('Variables',[],'Row',[],'Dimensions',[]);  
            %define each variable to be included in the data table and any
            %information about the dimensions. dstable Row and Dimensions can
            %accept most data types but the values in each vector must be unique
            
            %struct entries are cell arrays and can be column or row vectors
            dsp.Variables = struct(...
                'Name',{'Var1','Var2'},...                   % <<Edit metadata to suit model
                'Description',{'Variable 1','Variable 2'},...
                'Unit',{'m/s','m/s'},...
                'Label',{'Plot label 1','Plot label 2'},...
                'QCflag',repmat({'raw'},1,2));  
            dsp.Row = struct(...
                'Name',{'Time'},...
                'Description',{'Time'},...
                'Unit',{'h'},...
                'Label',{'Time'},...
                'Format',{'dd-MM-yyyy HH:mm:ss'});        
            dsp.Dimensions = struct(...    
                'Name',{''},...
                'Description',{''},...
                'Unit',{''},...
                'Label',{''},...
                'Format',{''});  
        end
    end
end