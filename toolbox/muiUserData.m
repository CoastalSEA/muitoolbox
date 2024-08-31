classdef muiUserData < muiDataSet
%
%-------class help------------------------------------------------------===
% NAME
%   UserData.m
% PURPOSE
%   Class to import data sets, adding the results to dstable
%   and a record in a dscatlogue (as a property of muiCatalogue)
% USAGE
%   obj = UserData()
% SEE ALSO
%   inherits muiDataSet and uses dstable and dscatalogue
%   see CoastalTools for example of usage
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
        function obj = muiUserData()
            %class constructor
            formatfile = obj.setFileFormat;
            if isempty(formatfile), return; end
            obj.DataFormats = {'muiUserData',formatfile};
            obj.idFormat = 1;
            defaults= {'off','*.txt; *.csv; *.xlsx'};
            promptxt = {'MultiSelect (on or off):','File types:'};
            answer = inputdlg(promptxt,'File spec',1,defaults);
            if isempty(answer)
                obj.FileSpec = defaults;
            else
                obj.FileSpec = answer;
            end            
        end        
%%
        function tabPlot(obj,src)
            %generate plot for display on Q-Plot tab
            funcname = 'getPlot';
            dst = obj.Data.Dataset;
            [var,ok] = callFileFormatFcn(obj,funcname,dst,src);
            if ok<1, return; end
            
            if var==0  %no plot defined so use muiDataSet default plot
                tabDefaultPlot(obj,src);
            end
        end 
    end  
end