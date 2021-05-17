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
%         Stats           %struct array for 
%                         %   FigNum - index to figures created
%                         %   CurrentFig - handle to current figure
%                         %   Order - struct that defines variable order for
%                         %           stats type options (selection held in Order)
        UIsel           %structure for the variable selection made in the UI
        UIset           %structure for the plot settings made in the UI
        Data            %data to use in statistic (x,y,z)
        MetaData        %text summary of primary variable selection
        Labels          %struct for XYZ labels
        Title           %Title text
        Order           %order of variables for selected statistic
        DescOut         %structure for descriptive output tables
        ExtrOut         %structure for extremes output tables
        Taylor          %structure for parameters defined for skill score        
    end
%%    
    methods (Access=protected)  %allows muiPlot to be used as a superclass
        function obj = muiStats
            
        end      
    end
%%    
    methods (Static)
        function getStats(gobj,src,mobj)
            %get existing instance or create new class instance
            if isa(mobj.mUI.Stats,'muiStats')
                obj = mobj.mUI.Stats;    %get existing instance  
                clearPreviousStatsData(obj);
            else
                obj = muiStats;                   %create new instance
            end
            obj.UIsel = gobj.UIselection;
            obj.UIset = gobj.UIsettings;

            %get the data to be used in the plot
            ok = getStatsData(obj,mobj.Cases);
            if ok<1, return; end %data not found

            if strcmp(obj.UIset.Type,'User')
                UserStats(obj,src,mobj);  %pass control to user function
            else
                %generate the plot
                setStats(obj,src,mobj);
            end
        end
%%
    
        function tabStats(mobj,src,~)
            %pass current statistical results held in obj.StatOut to a 
            %table on the Stats tab (if included in the main UI)
            if isa(mobj.mUI.Stats,'muiStats')
                obj = mobj.mUI.Stats;
            else
                warndlg('No statistics results available')
                return;
            end
            
            if strcmp(src.Tag,'Descriptive')
                idx = selectStatOuput(obj.DescOut);
                if isempty(idx), return; end
                SummaryTable(mobj,obj.DescOut{idx},'StatTable',src);
            else
                idx = selectStatOuput(obj.ExtrOut);
                if isempty(idx), return; end
                SummaryTable(mobj,obj.ExtrOut{idx},'StatTable',src);
            end
            %
            function idx = selectStatOuput(output)
                idx = [];
                nruns = length(output);
                if nruns>1
                    rundesc = cell(nruns,1);
                    for i=1:nruns
                        rundesc{i} = output{i}.Properties.Description;                        
                    end
                    [idx,ok] = listdlg('PromptString','Select a regression model:',...
                           'SelectionMode','single','ListSize',[500,100],...
                           'ListString',rundesc);
                    if ok<1, idx = 1; end
                elseif nruns==1
                    idx = 1;
                end
            end
        end
    end  
 %%  
    methods (Access=protected)  
         function ok = getStatsData(obj,muicat)
            %get the data set and add metadata to metatxt
            %obj - DataStats UI object, muicat - instance of muiCatatalogue
            ok = 1;
            nvar = length(obj.UIsel);
            %initialise struct used in muiCatalogue.getProperty
            props(nvar) = setPropsStruct(muicat);
            xyzset = [obj.UIsel(:).caserec]==0;
            for i=1:nvar
                %get the data and labels for each variable
                if obj.UIsel(i).caserec>0
                    props(i) = getProperty(muicat,obj.UIsel(i),'array');
                    if isempty(props(i).data), ok = ok-1; end
                end
            end  
            props(xyzset) = [];  %remove unused selections
            %
            xyz = {'X','Y','Z'};
            for i=1:length(props)
                %assign the data to the correct axis
                %NB this assigns data in order assigned on tab. If Y and Z
                %defined on tab this is assigned as X and Y          
                data2use = props(i).data;
                if obj.UIsel(i).scale>1 %apply selected scaling to variable
                    usescale = obj.UIset.scaleList{obj.UIsel(i).scale};
                    dim = 1; %dimension to apply scaling function if matrix
                    data2use = scalevariable(data2use,usescale,dim);
                end
                obj.Data.(xyz{i}) = data2use;
                obj.Labels.(xyz{i}) = props(i).label;
                obj.MetaData.(xyz{i}) = obj.UIsel(i).desc;                
            end
            %description of selection (may need sub-selection if more than
            %one case/variable used in plot)
            dimtxt = {props(:).desc};
            title = sprintf('%s (',dimtxt{1});
            for j=2:length(dimtxt)
                title = sprintf('%s%s, ',title,dimtxt{j});
            end
            obj.Title = sprintf('%s)',title(1:end-2));  
        end       
%%      
        function setStats(obj,src,mobj)
            %make use of the selection made to run stats of selected type
            srcVal = src.Parent.Tag;
            switch srcVal
                case 'General'
                    getGeneralStats(obj,mobj);
                case 'Timeseries'
                    getTimeseriesStats(obj,mobj,srcVal);
                case 'Taylor'
                    getTaylorStats(obj,src);
                case 'Intervals'
                    getIntervalStats(obj,mobj);
            end             
        end
%%
%--------------------------------------------------------------------------
% General Statistics options
%--------------------------------------------------------------------------           
        function getGeneralStats(obj,mobj) 
            %call relevant functions based on user selection
            statoption = obj.UIset.Type;
            switch statoption.String
                case 'Descriptive for X'
                    getDescriptiveStats(obj,mobj)
                case 'Regression'
                    getRegressionStats(obj)
                case 'Cross-correlation'
                    getCrossCorrelationStats(obj)
            end                    
        end       
%%        
%--------------------------------------------------------------------------
% Functions called to implement General Statistics options
%--------------------------------------------------------------------------
        function getDescriptiveStats(obj,mobj)
            %call descriptive_stats based on user selection  
            if isempty(obj.Data.X) && ~isempty(obj.Data.Y)
                obj.Data.X = obj.Data.Y;
                obj.MetaData.X = obj.MetaData.Y;
            end
            %to assign to a tab need to define src. If src not defined 
            %(ie [])then a stand-alone figure is used
            src = getTabHandle(obj,mobj,1);
            delete(src.Children);   %remove existing tab contents
            idx = 1;
            if ~isempty(obj.DescOut)
                idx = length(obj.DescOut)+1;
            end
            mtxt = 'Selection used:';
            mtxt = {sprintf('%s\nX: %s',mtxt,obj.MetaData.X)};
            obj.DescOut{idx} = descriptive_stats(mobj,obj.Data.X,mtxt,src);
            msgtxt = sprintf('Results are displayed on the Stats>%s tab',strip(src.Title));
            getdialog(msgtxt);
        end
%%
        function getRegressionStats(obj)
            %call regression_plot based on user selection
            % X taken as indpendent variable and Y as dependent variable
            regression_models = {'Linear','Power','Exponential','Logarithm'};
            [indx,ok] = listdlg('PromptString','Select a regression model:',...
                           'SelectionMode','single','ListSize',[150,60],...
                           'ListString',regression_models);
            if ok<1, return, end
            model = regression_models{indx}; %selected model type
            
            %check that user has correctly defined X and Y
            isvalid = isValidSelection(obj,'Regression');
            if~isvalid, return; end
            
%             %handle time formats
%             if isdatetime(obj.Data.X) 
%             elseif isduration(obj.Data.X)                
%             end

            metadata = setMetaData(obj);
          
            regression_plot(obj.Data.X,obj.Data.Y,metadata,model);
        end
%%
        function getCrossCorrelationStats(obj)
            %call xcorrelation_plot based on user selection
            % X taken as reference variable and Y as the lag variable
            
            %check that user has correctly defined X and Y
            isvalid = isValidSelection(obj,'Regression');
            if~isvalid, return; end
            
%             %handle time formats
%             if isdatetime(obj.Data.X) 
%             elseif isduration(obj.Data.X)                
%             end

            metadata = setMetaData(obj);

            xcorrelation_plot(obj.Data.X,obj.Data.Y,metadata);
        end
%%
%--------------------------------------------------------------------------
% Timeseries options
%--------------------------------------------------------------------------        
         function getTimeseriesStats(obj,mobj,srcVal) 
            %retrieve selected dataset and call relevant functions 
            %based on user selection
            statoption = obj.DataSelection.C{9,1};
            [ts,metatxt,dataObj] = getDatasetVars(obj,mobj,{},'C',1,1);
            %if dataset comes back as a table convert to timeseries
            if isempty(ts)
                return;
            elseif isa(ts,'table')  %1=table. 0=timeseries
                %convert table to a vector timeseries
                ts = table2ts(dataObj,ts);
            end   
            %
            switch statoption
                case 'Descriptive'
                    %to assign to a tab need to define src. If src not defined 
                    %(ie [])then a stand-alone figure is used
                    src = getTabHandle(obj,mobj,1);  
                    idx = 1;
                    if ~isempty(obj.DescOut)
                        idx = length(obj.DescOut)+1;
                    end
                    obj.DescOut{idx} = descriptive_stats(mobj,ts,metatxt,src);
                case 'Peaks'
                    PeaksStats(obj,mobj,ts,metatxt);
                case 'Clusters'
                    ClusterStats(obj,mobj,ts,metatxt);
                case 'Extremes'
                    %to assign to a tab need to define src. If src not defined 
                    %(ie [])then a stand-alone figure is used
                    src = getTabHandle(obj,mobj,2);
                    idx = 1;
                    if ~isempty(obj.ExtrOut)
                        idx = length(obj.ExtrOut)+1;
                    end
                    obj.ExtrOut{idx} = extreme_stats(mobj,ts,metatxt,src);
                case 'Poisson Stats'
                    poisson_stats(ts,metatxt);
                case 'User'
                    UserStats(obj,mobj,srcVal,ts,metatxt);
            end
         end
%%
%--------------------------------------------------------------------------
% Functions called to implement Timeseries options
%--------------------------------------------------------------------------



%%
%--------------------------------------------------------------------------
% Functions called to implement Taylor Plot 
%--------------------------------------------------------------------------
        function getTaylorStats(obj,src) 
            %call taylor_plot based on user selection
            
            %check that user has correctly defined X and Y
            isvalid = isValidSelection(obj,'Taylor Plot');
            if~isvalid, return; end
            metadata = setMetaData(obj);
            
            rLim = obj.UIset.Other;
            %see if user wants to include skill score
            [obj,ok] = setTaylorParams(obj);
            if ok<1, return; end

            taylor_plot(obj.Data.X,obj.Data.Y,metadata,src.String,...
                                                        rLim,obj.Taylor);
        end
%%
%--------------------------------------------------------------------------
% Functions called to implement Interval Statistics
%--------------------------------------------------------------------------


%%
%--------------------------------------------------------------------------
% Functions called by implementation functions
%--------------------------------------------------------------------------        
        function clearPreviousStatsData(obj)
            %reset the property values used to generate stats output
            obj.Data = [];            %data to use in plot (x,y,z)
            obj.Labels = [];          %struct for XYZ axis labels
            obj.MetaData = [];        %text summary of primary variable selection
            obj.Title = [];           %Title text
            obj.Order = [];           %order of variables for selected plot type
        end
%%
        function isvalid = isValidSelection(obj,fncdesc)
            %check that user has made a valid selection for function
            fnames = fields(obj.Data);
            if length(fnames)<2
                warndlg(sprintf('Select X and Y for %s',fncdesc))
                isvalid = false;
            elseif length(obj.Data.X)~=length(obj.Data.Y)
                warndlg('Variables need to be the same length')
                isvalid = false;
            else
                isvalid = true;
            end            
        end
%%
        function metadata = setMetaData(obj)
            %define metatdata required by regression and x-correlation
            fnames = fields(obj.Data);
            metadata = struct2cell(obj.Labels);
            metadata{3} = obj.Title;           
            mtxt = 'Selection used:';
            temptxt = struct2cell(obj.MetaData);
            for j=1:length(temptxt)
                mtxt = sprintf('%s\n%s: %s',mtxt,fnames{j},temptxt{j});   
            end
            metadata{4} = mtxt;
        end
%%
        function src = getTabHandle(~,mobj,idx)
            %find the handle of the tab if there is one
            %obj - DataStats UI object, mobj - Main UI object
            tabobj = findobj(mobj.mUI.Tabs.Children,'-regexp','Tag','Stat');
            subtabgrp = tabobj(1).Children;
            statstabs = subtabgrp.Children;
            if idx==1
                tab = statstabs(1);
            else
                tab = statstabs(2);
            end
            %
            if isempty(tab)
                src = [];
            else
                src = tab;
            end
        end    
    end
%%
    methods (Static)
        function skill = setTaylorParams(skill)
            %Skill score requires correlation and exponent. Give user option
            %to include skill score and then set parameters if included
            %persists until muiStats is deleted
            %obj - muiStats object
%             skill = obj.Taylor;
            if isempty(skill)
                skill = muiStats.skillStruct();
                answer = questdlg('Plot skill score?',...
                                     'Skill score','Yes','No','Yes');
                if strcmp(answer,'Yes'), skill.Inc = true; end                 
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
%             obj.Taylor = skill;
            ok = 1;
        end
    end
%%
    methods (Static, Access=private)
         function skill = skillStruct()
            %return an empty struct for the Taylor skill input parameters
            skill = struct('Inc',false,'Ro',1,'n',1,'W',0,'iter',false,'SD',[]);
        end          
    end
end