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