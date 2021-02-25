classdef muiProject < handle
%
%-------class help---------------------------------------------------------
% NAME
%   muiProject.m
% PURPOSE
%   Class to hold project details
% SEE ALSO
%
%
% Author: Ian Townend
% CoastalSEA(c) Aug 2020
%--------------------------------------------------------------------------
%  
    properties
        PathName                     %path for user selected file
        FileName                     %user selected file
        ProjectName                  %project name defined in model setup
        ProjectDate                  %date project initialised
        SupressPrompts = false %flag for unit testing to supress user promts
    end
    
    methods
        function obj = muiProject
            obj.PathName = '';
            obj.FileName = '';
            obj.ProjectName  = '';
            obj.ProjectDate = datestr(now,'dd-mmm-yyyy');
        end
    end
%%   
    methods     
        function editProject(obj)
            %edit project name and date
            Prompt = {'Project Name','Date'};
            Title = 'Project';
            NumLines = 1;
            if strcmp(obj.ProjectDate(1:2),'00')
            	obj.ProjectDate = char(datetime('now'),'dd-MMM-yyyy ');
            end
            DefaultValues = {obj.ProjectName,obj.ProjectDate};
            %use updated properties to call inpudlg and return new values
            answer=inputdlg(Prompt,Title,NumLines,DefaultValues);
            if isempty(answer), return; end            
            obj.ProjectName = answer{1};
            obj.ProjectDate = answer{2};
%             if ~isempty(mobj.Cases.Catalogue)
%                 button = questdlg('Correct Project Name in existing scenarios?',...
%                                      'Edit Project','Yes','No','No');
%                 if strcmp(button,'Yes') 
%                     %WILL DEPEND ON HOW THIS IS HELD IN dscollection
% %                     localObj = mobj.Cases;
% %                     for i=1:length(localObj.CaseID)
% %                         localObj.CaseModel{i}.pname = answer{1};
% %                         localObj.CaseModel{i}.pdat = answer{2};
% %                     end
%                 end
%             end
        end
    end
end
