classdef mui_usage < handle
%
%-------class help---------------------------------------------------------
% NAME
%   mui_usage.m
% PURPOSE
%   Class to demonstrate use of muitoolbox abstract classes
% USAGE
%   mui = mui_usage;  %instantiate class object
%   run_a_model(dm);  %run model 
%   load_data(dm);    %load a data set 
%   plotCase(dm);     %plot results
%   displayProps(dm); %display DSproperties
% SEE ALSO
%   see test_muitoolbox.m for examples of usage of each class in toolbox
%
% Author: Ian Townend
% CoastalSEA (c)Nov 2020
%--------------------------------------------------------------------------
%   
    properties  
        Cases = muiCatalogue;  
        Inputs
    end
%%
    methods
        function obj = mui_usage
            %class constructor
        end
%%        
        function run_a_model(obj)
            %run models and add to the Cases catalogue
            mui_demoModel.runModel(obj);      
        end
%%
        function load_data(obj,type)
            %load an imported data set
            switch type
                case 'diffusion'
                    mui_demoData.loadData(obj);  
                case 'timeseries'
                    mui_demoTSdata.loadData(obj); 
            end
        end
%%
        function plotCase(obj)
            %plot the results for a model or imported data
            muicat = obj.Cases;
            promptxt = 'Select case to plot';
            [caserec,ok] = selectCase(muicat,promptxt,'single',0);
            if ok<1, return; end
            [mobj,~,~] = getCase(muicat,caserec);
            tabPlot(mobj);
        end
%%
        function displayProps(obj)
            %displeay the metadata properties of a selected case
            muicat = obj.Cases;
            promptxt = 'Select case to plot';
            [caserec,ok] = selectCase(muicat,promptxt,'single',0);            
            if ok<1, return; end
            mobj = getCase(muicat,caserec);            
            displayDSproperties(mobj.Data.Dataset.DSproperties);
        end
    end
end