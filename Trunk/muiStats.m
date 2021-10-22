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
            if isa(mobj.mUI.Stats,'muiStats') && isvalid(mobj.mUI.Stats)
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

            if strcmp(obj.UIset.Type.String,'User')
                user_stats(obj,src,mobj);  %pass control to user function
            else
                %generate the plot
                setStats(obj,src,mobj);
            end
        end
    end
%%
   methods 
        function tabStats(obj,src)
            %pass current statistical results held in obj.StatOut to a 
            %table on the Stats tab (if included in the main UI)
            ht = src.Children;   %clear any existing tab content
            delete(ht);
            
            switch src.Tag
                case {'Stats','Descriptive'}
                    idx = selectStatOuput(obj.DescOut);
                    if isempty(idx), return; end
                    metatxt = obj.DescOut{idx}.Properties.Description; 
                    tablefigure(src,metatxt,obj.DescOut{idx});
                case 'Extremes'
                    idx = selectStatOuput(obj.ExtrOut);
                    if isempty(idx), return; end
                    metatxt = obj.ExtrOut{idx}.Properties.Description; 
                    tablefigure(src,metatxt,obj.ExtrOut{idx});
            end
            %-nested function----------------------------------------------
            function idx = selectStatOuput(output)
                idx = [];
                nruns = length(output);
                if nruns>1
                    rundesc = cell(nruns,1);
                    for i=1:nruns
                        rundesc{i} = output{i}.Properties.UserData;                        
                    end
                    [idx,ok] = listdlg('PromptString','Select a case:',...
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
                    props(i) = getProperty(muicat,obj.UIsel(i),'dstable');
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
                if obj.UIsel(i).scale>1 %apply selected scaling to variable
                    usescale = obj.UIset.scaleList{obj.UIsel(i).scale};
                    dim = 1; %dimension to apply scaling function if matrix
                    data2use = props(i).data.DataTable{:,1};
                    data2use = scalevariable(data2use,usescale,dim);
                    props(i).data.DataTable{:,1} = data2use;
                end                
                obj.Data.(xyz{i}) = props(i).data;
                obj.Labels.(xyz{i}) = props(i).label;
                obj.MetaData.(xyz{i}) = obj.UIsel(i).desc;                
            end
            %description of selection (may need sub-selection if more than
            %one case/variable used)
            dimtxt = {props(:).desc};
            if length(dimtxt)>1
                title = sprintf('%s (',dimtxt{end});
                for j=1:length(dimtxt)-1
                    title = sprintf('%s%s, ',title,dimtxt{j});
                end
                obj.Title = sprintf('%s)',title(1:end-2));  
            else
                obj.Title = dimtxt{1};
            end
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
            %assign muiStats instance to handle
            mobj.mUI.Stats = obj;
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
                case 'User'
                    user_stats(obj,mobj,srcVal);
            end                    
        end       
%%        
%--------------------------------------------------------------------------
% Functions called to implement General Statistics options
%--------------------------------------------------------------------------
        function getDescriptiveStats(obj,mobj)
            %call descriptive_stats based on user selection  
            if isempty(obj.Data.X) && ~isempty(obj.Data.Y)
                %move Y to X if defined and no X defined
                obj.Data.X = obj.Data.Y;
                obj.MetaData.X = obj.MetaData.Y;
            end
            dataset = obj.Data.X.DataTable{:,1};
            if isdatetime(dataset)
                %adjust datetime to a duration
                dataset = set_time_units(dataset);
            end
            %to assign to a tab need to define src. If src not defined 
            %(ie [])then a stand-alone figure is used
            src = getTabHandle(obj,mobj,1);
            results = descriptive_stats(dataset,obj.MetaData.X,src);
            [idx,casedesc] = setcase(obj.DescOut,false);
            results.Properties.UserData = casedesc;
            obj.DescOut{idx} = results;
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
            isvalid = isValidSelection(obj,'Regression',false);
            if ~isvalid, return; end            
            metadata = setMetaData(obj);
            
            %handle time formats
            checkDatDur(obj)

            regression_plot(obj.Data.X,obj.Data.Y,metadata,model);
        end
%%
        function getCrossCorrelationStats(obj)
            %call xcorrelation_plot based on user selection
            % X taken as reference variable and Y as the lag variable
            
            %check that user has correctly defined X and Y
            isvalid = isValidSelection(obj,'Cross-correlation',false);
            if ~isvalid, return; end
            metadata = setMetaData(obj);
            
            %handle time formats
            checkDatDur(obj)

            xcorrelation_plot(obj.Data.X,obj.Data.Y,metadata);
        end
%%
%--------------------------------------------------------------------------
% Timeseries options
%--------------------------------------------------------------------------        
         function getTimeseriesStats(obj,mobj,srcVal) 
            %retrieve selected dataset and call relevant functions 
            %based on user selection
%             statoption = obj.DataSelection.C{9,1};
%             [ts,metatxt,dataObj] = getDatasetVars(obj,mobj,{},'C',1,1);
%             %if dataset comes back as a table convert to timeseries
%             if isempty(ts)
%                 return;
%             elseif isa(ts,'table')  %1=table. 0=timeseries
%                 %convert table to a vector timeseries
%                 ts = table2ts(dataObj,ts);
%             end   
            %
            switch obj.UIset.Type.String
                case 'Descriptive'
                    %to assign to a tab need to define src. If src not defined 
                    %(ie [])then a stand-alone figure is used
                    src = getTabHandle(obj,mobj,1);  
                    results = descriptive_stats(obj.Data.X,obj.MetaData.X,src);
                    [idx,casedesc] = setcase(obj.DescOut,false);
                    results.Properties.UserData = casedesc;
                    obj.DescOut{idx} = results;
                case 'Regression'
                    obj.Data.Y = obj.Data.X;  %assign variable to Y
                    obj.Labels.Y = obj.Labels.X;
                    obj.Labels.X = 'Time';
                    %Assign the RowNames datetime to X as a dstable so that
                    %checkDatDur in getRegressionStats works
                    obj.Data.X = dstable(obj.Data.X.RowNames,'VariableNames',{'Time'});
                    obj.Data.X.VariableDescriptions = {'Time'};
                    getRegressionStats(obj);
                case 'Peaks'                    
                    getPeaksStats(obj,mobj);
                case 'Clusters'
                    getClusterStats(obj,mobj);
                case 'Extremes'
                    getExtremeStats(obj,mobj);
                case 'Poisson Stats'
                    poisson_stats(obj.Data.X,obj.MetaData.X);
                case 'User'
                    user_stats(obj,mobj,srcVal);
            end
         end
%%
%--------------------------------------------------------------------------
% Functions called to implement Timeseries options
%--------------------------------------------------------------------------
        function checkDatDur(obj)
            %check whether inputs are datetime or duration
            %isdd true if datetime or duration, isdt true if datetime
            [isdd,~] = isdatdur('RowNames',obj.Data.X,obj.Data.Y);
            %isdv true if datetime or duration, istv true if datetime
            varnames = [obj.Data.X.VariableNames,obj.Data.Y.VariableNames];
            [isdv,istv] = isdatdur(varnames,obj.Data.X,obj.Data.Y);
            
            %re-assign if one of the variables is datetime or duration, or
            %the RowNames are not datetime or duration
            %pass dstables if the RowNames are datetime or duration to 
            %allow interpolation to common time intervals.
            
            if ~all(isdd)  
                %selected datasets do not both have datetime or duration RowNames
                obj.Data.X = obj.Data.X.DataTable{:,1};
                obj.Data.Y = obj.Data.Y.DataTable{:,1};
                if any(isdv)
                    if istv(1)       %variable assigned to X is a datetime
                        obj.Data.X = set_time_units(obj.Data.X);
                    elseif istv(2)   %variable assigned to Y is a datetime
                        obj.Data.Y = set_time_units(obj.Data.Y);
                    end
                end
            end
        end
%%
        function getPeaksStats(obj,mobj)
            %find peaks above a threshold and write the timeseries of peaks
            dst = obj.Data.X;
            [idpks,ops] = getpeaks(dst);
            if isempty(ops), return; end          
            dst = getDSTable(dst,idpks,':');
            %assign metadata about statistic
            dst.Source = sprintf('%s peaks using %s',dst.VariableNames{1},...
                                                        dst.Description);  
            dst.MetaData = sprintf('Peaks from %s, threshold=%.4g, method=%.4g, minimum interval=%.4g',...
                obj.MetaData.X,ops.threshold,ops.method,ops.tint);
            %get new object based on source data class
            classname = mobj.Cases.Catalogue.CaseClass(obj.UIsel(1).caserec); 
            heq = str2func(classname);
            cobj = heq();  %instance of class object
            %save results  
            setDataSetRecord(cobj,mobj.Cases,dst,'stats');
            getdialog('Run complete');
        end         
%%
        function getClusterStats(obj,mobj)
            %find clusters above a specified threshold and save as a new
            %data record with peak values and a flag for cluster number 
            dst = obj.Data.X;
            [idcls,ops] = getclusters(dst);
            if isempty(ops), return; end
            %get subset of source timeseries using id of peaks in each
            %cluster and a flag to record cluster number
            numcluster = []; clusterdates = [];
            for i=1:length(idcls)
                numcluster = [numcluster;i*ones(length(idcls(i).pks),1)]; %#ok<AGROW>
                clusterdates = [clusterdates;idcls(i).date]; %#ok<AGROW>
            end
            dst = getDSTable(dst,clusterdates,':');
            dst = addvars(dst,numcluster,'NewDSproperties',...
                {'ClusterNumber','Cluster Numbers','-','Cluster Numbers','-'});
            %assign metadata about statistic
            dst.Source = sprintf('%s peaks using %s',dst.VariableNames{1},...
                                                        dst.Description);
            dst.MetaData = sprintf('Clusters from %s, threshold=%.4g, method=%.4g, minimum interval=%.4g and time between clusters of %0.4g',...
                obj.MetaData.X,ops.threshold,ops.method,ops.tint,ops.clint);
            %get new object based on source data class
            classname = mobj.Cases.Catalogue.CaseClass(obj.UIsel(1).caserec); 
            heq = str2func(classname);
            cobj = heq();  %instance of class object
            %save results  
            setDataSetRecord(cobj,mobj.Cases,dst,'stats');
            getdialog('Run complete');
        end
%%
        function getExtremeStats(obj,mobj)
            %compute extreme values for a range of return periods using GPD            
            src = getTabHandle(obj,mobj,2);%to assign to a tab need to define src
            mtxt = {sprintf('Selection used:\nX: %s',obj.MetaData.X)};
            stats = extreme_stats(obj.Data.X,mtxt,src);
            [idx,casedesc] = setcase(obj.DescOut,false);
            stats.Properties.UserData = casedesc;
            obj.ExtrOut{idx} = stats;  
            msgtxt = sprintf('Results are displayed on the Stats>%s tab',strip(src.Title));
            getdialog(msgtxt);
        end
%--------------------------------------------------------------------------
% Functions called to implement Taylor Plot 
%--------------------------------------------------------------------------
        function getTaylorStats(obj,src) 
            %call taylor_plot based on user selection
            
            %check that user has correctly defined X and Y
            isvalid = isValidSelection(obj,'Taylor Plot',true);
            if ~isvalid, return; end
            refts = obj.Data.X;
            tests = obj.Data.Y;
            metadata{1} = sprintf('%s: %s',refts.Description,refts.VariableDescriptions{1});
            metadata{2} = sprintf('%s: %s',tests.Description,tests.VariableDescriptions{1});
            rLim = obj.UIset.Other;
            %see if user wants to include skill score
            ok = setTaylorParams(obj);
            if ok<1, return; end
            
            taylor_plot(refts,tests,metadata,src.String,...
                                                        rLim,obj.Taylor);
        end
%%
%--------------------------------------------------------------------------
% Functions called to implement Interval Statistics
%--------------------------------------------------------------------------
        function getIntervalStats(obj,mobj)
            % find intervals in one timeseries and compute statistcs within each
            % interval in a second timeseries (use tsc for multiple variables
            
            %check that user has defined X and Y
            isvalid = isValidSelection(obj,'Interval statistics',false);
            if ~isvalid, return; end            
            %ensure that the two records overlap
            [ds1,ds2] = getoverlappingtimes(obj.Data.X,obj.Data.Y,true);
            
            statoptions = {'median','mean','std','var','min','max','sum'};
            txt1 = 'Define the statistical function to be used';
            txt2 = 'Select from: median, mean, std, var, min, max, sum';                                                
            inptxt = sprintf('%s\n%s',txt1,txt2);   
            selstat = {'mean'};
%             stext = 'Intervals Stats using: ';
            ok = 1; count = 1;
            while ok>0
                selstat = inputdlg(inptxt,'Interval statistics',1,selstat);
                if isempty(selstat)       %user cancelled
                    return;
                elseif ismember(selstat{1},statoptions)
                    statxt = sprintf('@(x) %s(x)',selstat{1});
                    statfunc = str2func(statxt);         
                    [statval{1,count},numts] = getintervaldata(ds1,ds2,statfunc); 
                    stext{1,count} = selstat{1};            
                    count = count+1;

                    %
                    quest = 'Do you want to resample using a different statistcal function?';
                    answer = questdlg(quest,'Interval Statistics',...
                                        'Yes','No','No');
                    if strcmp(answer,'No'), ok = 0; end
                else
                    getdialog('Option entered is not in list')
                end
            end
            stext{1,count} = 'reclength';
            %save results as a dstable, including dates from ts1,
            %recordlength of ts2 in each interval and the selected
            %statistical functions.
            dst = dstable(statval{:},numts,'RowNames',ds1.RowNames);
%             dsp1 = ds1.DSproperties;
            dsp = ds2.DSproperties;
            dsp.Variables = muiStats.setVariableDSP(dsp,stext);
            dst.DSproperties = dsp;
            
            %assign metadata about statistic
            dst.Source = sprintf('Interval stats for %s from %s using reference times from %s ',...
                         ds2.VariableNames{1},ds2.Description,ds1.Description);
            dst.MetaData = sprintf('Interval stats for %s using time intervals from %s',...
                            obj.MetaData.Y,obj.MetaData.X);
            %get new object based on source data class
            classname = mobj.Cases.Catalogue.CaseClass(obj.UIsel(2).caserec); 
            heq = str2func(classname);
            cobj = heq();  %instance of class object
            %save results  
            setDataSetRecord(cobj,mobj.Cases,dst,'stats');
            getdialog('Run complete');
        end
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
        function isvalid = isValidSelection(obj,fncdesc,iseq)
            %check that user has made a valid selection for function
            % fncdesc - description of function to use
            % iseq - logical flag, true if length of variables to be checked
            fnames = fields(obj.Data);
            if length(fnames)<2
                warndlg(sprintf('Select X and Y for %s',fncdesc))
                isvalid = false;
            else
                isvalid = true;
            end
            %
            if iseq && isvalid && length(obj.Data.X)~=length(obj.Data.Y)
                warndlg('Variables need to be the same length')
                isvalid = false;
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
            %idx - index for subtab to use as Tag name or numeric index
            tabobj = findobj(mobj.mUI.Tabs.Children,'-regexp','Tag','Stat');
            if isempty(tabobj), return; end
            subtabgrp = tabobj(1).Children;  %tabgroup to use
            if isa(subtabgrp,'matlab.ui.container.Tab') 
                %use one of the subtabs defined by idx
                statstabs = subtabgrp.Children;
            else
                %use main tab as there are no subtabs
                statstabs = tabobj;
            end
            %
            if ischar(idx)
                idx = find(strcmp({statstabs(:).Tag},idx));
            end
            tab = statstabs(idx);            %tab to use
            %
            if isempty(tab)
                src = [];
            else
                src = tab;
                delete(src.Children);  %clear existing tab
            end
        end    
%%
        function ok = setTaylorParams(obj)
            %Skill score requires correlation and exponent. Give user option
            %to include skill score and then set parameters if included
            %persists until muiStats is deleted
            %obj - muiStats object
            skill = obj.Taylor;
            if isempty(skill)
                skill = muiStats.skillStruct();
                answer = questdlg('Plot skill score?',...
                                     'Skill score','Yes','No','Yes');
                if strcmp(answer,'Yes'), skill.Inc = true; end                 
            end
            %
            if skill.Inc      %flag to include skill score
                default = {num2str(skill.Ro),num2str(skill.n),...
                    num2str(skill.W),num2str(skill.iter),num2str(skill.subdomain)};
                promptxt = {'Reference correlation, Ro','Exponent,n ',...
                            'Local skill window','Iteration option (0 or 1)',...
                            'Skill score averaging window (grids only)'};
                titletxt = 'Define skill score parameters:';
                answer = inputdlg(promptxt,titletxt,1,default);
                if isempty(answer), ok = 0; return; end
                
                skill.Ro = str2double(answer{1});     %reference correlation coefficient
                skill.n = str2double(answer{2});      %skill exponent
                skill.W = str2double(answer{3});      %local skill sampling window
                skill.iter = logical(str2double(answer{4})); %local skill iteration method
                skill.subdomain = str2num(answer{5}); %#ok<ST2NM> %subdomain sampling (use str2num to handle vector)
                [vdim,~,vsze] = getvariabledimensions(obj.Data.X,1);
                if vdim==2
                    skill.SD = getSubDomain(obj,skill.subdomain,vsze);
                end
            end
            obj.Taylor = skill;
            ok = 1;
        end
%%
        function sd = getSubDomain(obj,subdomain,vsze)
            %find the subdomain in integer grid indices defined by x,y range
            %subdomain defined as [x0,xN,y0,yN];
            dst = obj.Data.X;
            if ~isempty(dst.Dimensions)
                dnames = dst.DimensionNames;
                x = dst.Dimensions.(dnames{1});
                y = dst.Dimensions.(dnames{2});
            else
                x = 1:vsze(2);
                y = 1:vsze(3);
            end

            if isempty(subdomain) || length(subdomain)~=4
                subdomain = [min(x),max(x),min(y),max(y)];
            end
            ix0 = find(x<=subdomain(1),1,'last');
            ixN = find(x>=subdomain(2),1,'first');
            iy0 = find(y<=subdomain(3),1,'last');
            iyN = find(y>=subdomain(4),1,'first');
            sd.x = [ix0,ix0,ixN,ixN];
            sd.y = [iyN,iy0,iy0,iyN];
        end
    end
%%
    methods (Static, Access=private)
         function skill = skillStruct()
            %return an empty struct for the Taylor skill input parameters
            skill = struct('Inc',false,'Ro',1,'n',1,'W',0,'iter',false,...
                           'subdomain',[],'SD',[]);
         end  
%%
        function dsp = setVariableDSP(dsp,statops)
            %assign the variable dsproperties based on user selection
            nvar = length(statops);
            varnames = cell(1,nvar); vardesc = varnames; varlabels = varnames;
            for i=1:nvar
                varnames{i} = sprintf('%s%s',statops{i},dsp.Variables.Name{1});
                vardesc{i} = sprintf('%s %s',statops{i},dsp.Variables.Description{1});
                varlabel{i} = sprintf('%s %s',statops{i},dsp.Variables.Label{1});
            end
            instruct = struct(...                       
                'Name',varnames,...
                'Description',vardesc,...
                'Unit',repmat(dsp.Variables.Unit,1,nvar),...
                'Label',varlabel,...
                'QCflag',repmat(dsp.Variables.QCflag,1,nvar));
            dsp.Variables = instruct;
        end
    end
end