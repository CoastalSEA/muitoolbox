classdef DataImport_formatfiles_template < muiDataSet        % << Edit to classname
%
%-------class help------------------------------------------------------===
% NAME
%   DataImport_formatfiles_template.m
% PURPOSE
%   Class to illustrate importing a data set, adding the results to dstable
%   and a record in a dscatlogue (as a property of muiCatalogue)
% USAGE
%   obj = DataImport_formatfiles_template()
% SEE ALSO
%   inherits muiDataSet and uses dstable and dscatalogue
%   format files used to load data of varying formats (variables and file format)
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
%    
    properties  
        %inherits Data, RunParam, MetaData and CaseIndex from muiDataSet
        % importing data requires muiDataSet propertiesm DataFormats and
        % FileSpec to be defined in class constructor.
        %Additional properties:  
    end
    
    methods 
        function obj = DataImport_formatfiles_template()     % << Edit to classname
            %class constructor
            %initialise list of available input file formats. Format is:
            %{'label 1','formatfile name 1';'label 2','formatfile name 2'; etc}
            obj.DataFormats = {'UserData1',formatfile1;...   % << Edit to file list
                               'UserData2',formatfile2};
            %define file specification, format is: {multiselect,file extension types}
            obj.FileSpec = {'on','*.txt;*.csv'};             % << Edit to file types
        end
%%
        function tabPlot(obj,src)
            %generate plot for display on Q-Plot tab
            funcname = 'getPlot';
            dst = obj.Data{1};
            [var,ok] = callFileFormatFcn(obj,funcname,dst,src);
            if ok<1, return; end
            
            if var==0  %no plot defined so use muiDataSet default plot
                tabDefaultPlot(obj,src);
            end
        end       
%%
%--------------------------------------------------------------------------
% if only the default plot is needed, use the following function
%         function tabPlot(obj,src)
%             %generate plot for display on Q-Plot tab
%             tabDefaultPlot(obj,src);
%         end         
%--------------------------------------------------------------------------    

%%
        function output = dataQC(obj)
            %quality control a dataset
            % datasetname = getDataSetName(obj); %prompts user to select dataset if more than one
            % dst = obj.Data.(datasetname);      %selected dstable
            warndlg('No qualtiy control defined for this format');
            output = [];    %if no QC implemented in dataQC
        end      
        
    end
end