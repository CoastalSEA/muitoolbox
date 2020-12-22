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
            
            [caserec,ok] = selectCase(obj,'PromptText','Select case to save:',...
                                                    'ListSize',[250,200]);
            if ok<1, return; end 
        end         
%%
        function deleteCases(obj,type,caserec)
            %select one or more records and delete records from catalogue 
            %and class instances
            if nargin<3  %if case to reload has not been specified
                [caserec,ok] = selectCase(obj,'PromptText','Select cases to delete:',...
                                      'CaseType',type,'ListSize',[250,200]);
                if ok<1, return; end  
            elseif contains(caserec,'All')
                if isempty(type) || strcmp(type,'All')
                    caserec = 1:height(obj.Catalogue);
                else
                    caserec = strcmp(obj.Catalogue.CaseType,type);
                end
            end 
            
            %sort in reverse order so that record ids do not change as
            %deleted  (NOT NEEDED NOW as catalogue cleared after Datasets
            %deleted) CHECK!!!
            msg = sprintf('Deleting %d cases',length(caserec));
            hw = waitbar(0,msg);
%             caserec = sort(caserec,'descend');
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
        function reloadCase(obj,type,caserec)  
            %reload model input variables as the current settings
            if nargin<3  %if case to reload has not been specified
                [caserec,ok] = selectCase(obj,'PromptText','Select case to reload:',...
                                      'CaseType',type,'ListSize',[250,200]);
                if ok<1, return; end  
            end            
            
            
        end
%% 
        function viewCaseSettings(obj,type,caserec)
            %view the saved input data for a selected Case
            if nargin<3  %if case to reload has not been specified
                [~,ok] = selectCase(obj,'PromptText','Select case to view:',...
                                      'CaseType',type,'ListSize',[250,200]);
                if ok<1, return; end  
            end
            
            
        end        
%%        
        function editCaseData(obj)  %if runprops does not hold case description this function is not needed
            %extension of dscatalogue.editRecord to also update exsitig
            %metadata in class properties
            [caserec,newdesc] = editRecord(obj);
%             obj.CaseModel{caserec}.scen = newdesc{1}; %%DEPENDS on how this is stored
%               
        end
        
%% 
        function [cobj,classrec,catrec] = getCase(obj,caserec)
            %retrieve the class instance, class record and catalogue record
            catrec = getRecord(obj,caserec); 
            lobj = obj.DataSets.(catrec.CaseClass);  
            classrec = [lobj.ClassIndex]==catrec.CaseID;            
            cobj = lobj(classrec);
        end
    end
    
    methods (Access=private)
        function delete_dataset(obj,caserec)
            %delete selected record and data set 
            catrec = getRecord(obj,caserec);
            classname = catrec.CaseClass;
            %class index for the classid instance
            classrec = getClassIndex(obj.DataSets.(classname),caseid); %in dscollection?   
            %clear instance of data set class
            obj.DataSets.(classname)(classrec) = [];
        end          
    end
end