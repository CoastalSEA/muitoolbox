classdef mui_demoData < muiDataSet
%
%-------class help------------------------------------------------------===
% NAME
%   mui_demoData.m
% PURPOSE
%   Class to illustrate importing a data set, adding the results to dstable
%   and a record in a dscatlogue with a method to plot the output
% USAGE
%   obj = mui_demoData.loadData(catobj) %where is a handle to a dscatalogue
% SEE ALSO
%   inherits muuiDataSet and uses dstable and dscatalogue
%
% Author: Ian Townend
% CoastalSEA (c)Nov 2020
%--------------------------------------------------------------------------
%    
    properties  
        %inherits Data, RunParam, MetaData and CaseIndex from muiDataSet
        %Additional properties:  
    end
    
    methods (Access = private)
        function obj = mui_demoData()
            %class constructor
        end
    end
%%    
    methods (Static)
        function loadData(mobj)
            %read and load a data set from a file 
            %(overloads the muiDataSet method)
            obj = mui_demoData;               %initialise class object
            [data,filename] = readInputData(obj);             
            if isempty(data), return; end
            dsp = dataDSproperties(obj);  %initialise dsproperties for data
            muicat = mobj.Cases;
            %Adjust the data to march the form of the diffusion model
            sz = num2cell(size(data));    %NB this iis specific to the 
            data = reshape(data,1,sz{:}); %demo input data file
            time = seconds(0);            %mui_demo_dfdata.m
            %load the results into a dstable            
            dst = dstable(data,'RowNames',time,'DSproperties',dsp);
            dst.Dimensions.X = (1:20);
            dst.Dimensions.Y = (1:30);
            %assign metadata about dagta
            dst.Source = filename;
            %setDataRecord classobj, muiCatalogue obj, dataset, classtype
            setDataSetRecord(obj,muicat,dst,'data');           
        end 
    end
%%
    methods
        function tabPlot(obj,src)
            %generate plot for display  
            if nargin<2
                src = figure;
            end
            tabDefaultPlot(obj,src);
        end   
    end
%%
    methods (Access = private)
        function [data,filename] = readInputData(~)
            %read wind data (read format is file specific).
            [fname,path,~] = getfiles('FileType','*.txt');
            filename = [path fname];
            data = readmatrix(filename);
        end      
%%        
        function dsp = dataDSproperties(~)
            %define the metadata properties for the demo data set
            dsp = struct('Variables',[],'Row',[],'Dimensions',[]);           
            dsp.Variables = struct(...   %cell arrays can be column or row vectors
                'Name',{'u'},...
                'Description',{'Transport property'},...
                'Unit',{'m/s'},...
                'Label',{'Transport property'},...
                'QCflag',{'model'}); 
            dsp.Row = struct(...
                'Name',{'Time'},...
                'Description',{'Time'},...
                'Unit',{'s'},...
                'Label',{'Time (s)'},...
                'Format',{'s'});        
            dsp.Dimensions = struct(...    
                'Name',{'X','Y'},...
                'Description',{'X co-ordinate','Y co-ordinate'},...
                'Unit',{'m','m'},...
                'Label',{'X co-ordinate (m)','Y co-ordinate (m)'},...
                'Format',{'-','-'});  
        end
    end
end