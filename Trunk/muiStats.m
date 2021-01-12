classdef muiStats < handle
%
%-------class help---------------------------------------------------------
% NAME
%   muiStats.m
% PURPOSE
%   Class to implement running a range of statistical functions
% SEE ALSO
%   called from muiStatsUI.m, which defines the selection and settings in
%   properties UIselection and UIsettings
%
% Author: Ian Townend
% CoastalSEA (c)Jan 2021
%--------------------------------------------------------------------------
%
    properties (Transient)
        StatFigNum      %array of figure numbers for each plot created
        UIsel           %structure for the variable selection made in the UI
        UIset           %structure for the plot settings made in the UI
        Data            %data to use in plot (x,y,z)
        DescOut         %structure for descriptive output tables
        ExtrOut         %structure for extremes output tables
        Taylor          %structure for parameters defined for skill score        
    end
    
    methods (Access=protected)  %allows muiPlot to be used as a superclass
        function obj = muiStats
        end      
    end
    
    methods (Static)
        function getStats(gobj,src,mobj)
            %get existing instance or create new class instance
            if isa(mobj.mUI.Stats.GuiChild,'muiStats')
                obj = mobj.mUI.Stats.GuiChild;    %get existing instance          
            else
                obj = muiStats;                   %create new instance
            end
            obj.UIsel = gobj.UIselection;
            obj.UIset = gobj.UIsettings;
            %get the data to be used in the plot
            [obj,ok] = getStatsData(obj,mobj);
            if isempty(ok), return; end %data not found
            
            if strcmp(obj.UIsel.Type,'User')
                UserStatsobj,mobj);  %pass control to user function
            else
                %generate the plot
                setStats(obj,src,mobj);
            end
        end
    end
    
 %%  
    methods (Access=protected)  
        function setStats(obj,src,mobj)
            %make use of the selection made to run stats of selected type
            srcVal = src.Parent.Tag;
            switch srcVal
                case 'General'
                    getGeneralStats(obj,mobj,srcVal);
                case 'Timeseries'
                    getTimeseriesStats(obj,mobj,srcVal);
                case 'Taylor'
                    getTaylorStats(obj,src,mobj);
                case 'Intervals'
                    getIntervalStats(obj,mobj);
            end             
        end
%%
%--------------------------------------------------------------------------
% Statistical call functions
%--------------------------------------------------------------------------           
        function getGeneralStats(obj,mobj,srcVal) 
            %call relevant functions based on user selection
            statoption = obj.UIsettings.Type;
            switch statoption
                case 'Descriptive for X'
                    getDescriptiveStats(obj,mobj)
                case 'Regression'
                    getRegressionStats(obj,mobj)
                case 'Cross-correlation'
                    getCrossCorrelationStats(obj,mobj)
                case 'User'
                    UserStats(obj,mobj,srcVal);
            end                    
        end       
        
        
        
        
         function [obj,ok] = setTaylorParams(obj)
            %Skill score requires correlation and exponent. Give user option
            %to include skill score and then set parameters if included
            %persists until DataStats is closed
            %obj - muiStats object
            skill = obj.Taylor;
            if isempty(skill)
                skill = muiStats.skillStruct();
                skill.Inc = questdlg('Plot skill score?',...
                                     'Skill score','Yes','No','Yes');
            end
            %
            if strcmp(skill.Inc,'Yes')      %flag to include skill score
                default = {num2str(skill.Ro),num2str(skill.n),...
                           num2str(skill.W),num2str(skill.iter)};
                promptxt = {'Reference correlation, Ro','Exponent,n ',...
                            'Local skill window','Iteration option (0 or 1)'};
                titletxt = 'Define skill score parameters:';
                answer = inputdlg(promptxt,titletxt,1,default);
                if isempty(answer), ok = 0; return; end
                
                skill.Ro = str2double(answer{1});   %reference correlation coefficient
                skill.n = str2double(answer{2});    %skill exponent
                skill.W = str2double(answer{3});    %local skill sampling window
                skill.iter = logical(str2double(answer{4})); %local skill iteration method
                %skill.SD = [];                     %subdomain sampling (not used)
            end
            obj.Taylor = skill;
            ok = 1;
        end        
    end
%%
    methods (Static, Access=private)
         function skill = skillStruct()
            %return an empty struct for the Taylor skill input parameters
            skill = struct('Inc','No','Ro',1,'n',1,'W',0,'iter',false,'SD',[]);
        end          
    end
end