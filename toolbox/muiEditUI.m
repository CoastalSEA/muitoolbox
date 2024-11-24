classdef muiEditUI < muiDataUI
%
%-------class help------------------------------------------------------
% NAME
%   muiEditUI.m
% PURPOSE
%   Class implements the muiDataUIclass to access data for editing
% SEE ALSO
%   muiDataUI.m
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
% 
    properties (Transient)
        %Abstract variables for muiDataUI----------------------------------       
        % names of tabs providing different data accces options
        TabOptions = {'Edit'};   
        % selections that force a call to setVariableLists
        updateSelections = {'Case','Dataset'};
        %Additional variables for application------------------------------
        Tabs2Use         %number of tabs to include  (set in getPlotGui)     
    end  
%%  
    methods (Access=protected)
        function obj = muiEditUI(mobj)
            %initialise standard figure and menus
            guititle = 'Select Data for Editing';
            setDataUIfigure(obj,mobj,guititle);    %initialise figure     
        end
    end
%%    
    methods (Static)
        function obj = getEditUI(mobj)
            %this is the function call to initialise the UI and assigning
            %to a handle of the main model UI (mobj.mUI.EditUI) 
            %options for selection on each tab are defined in setTabContent
            if isempty(mobj.Cases.Catalogue.CaseID)
                warndlg('No data available to edit');
                obj = [];
                return;
            elseif isa(mobj.mUI.EditUI,'muiEditUI')
                obj = mobj.mUI.EditUI;
                if isempty(obj.dataUI.Figure)
                    %initialise figure 
                    guititle = 'Select Data for Editing';
                    setDataUIfigure(obj,mobj,guititle);    
                    setDataUItabs(obj,mobj); %add tabs 
                else
                    getdialog('Edit UI is open');
                end
            else
                obj = muiEditUI(mobj);
                obj.Tabs2Use = {'Edit'};
                setDataUItabs(obj,mobj); %add tabs                
            end                
        end
    end
%%
%--------------------------------------------------------------------------
% Abstract methods required by muiDataUI to define tab content
%--------------------------------------------------------------------------
    methods (Access=protected) 
        function setTabContent(obj,src)
            %setup default layout options for individual tabs
            %Abstract function required by DataGUIinterface
            itab = find(strcmp(obj.Tabs2Use,src.Tag));
            obj.TabContent(itab) = muiDataUI.defaultTabContent;
            
            %customise the layout of each tab. Overload the default
            %template with a function for the tab specific definition
            setEditTab(obj,src)            
        end                
%%
        function setVariableLists(obj,src,mobj)
            %Abstract function required by DataGUIinterface
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            sel_uic = S.Selections;
            caserec = sel_uic{strcmp(S.Order,'Case')}.Value;
            cobj = getCase(mobj.Cases,caserec);
            dsnames = fieldnames(cobj.Data);
            ids = sel_uic{strcmp(S.Order,'Dataset')}.Value;
            for i=1:length(sel_uic)                
                switch sel_uic{i}.Tag
                    case 'Case'
                        muicat = mobj.Cases.Catalogue;
                        sel_uic{i}.String = muicat.CaseDescription;
                        sel_uic{i}.UserData = sel_uic{i}.Value; %used to track changes
                    case 'Dataset'
                        sel_uic{i}.String = dsnames;
                        sel_uic{i}.UserData = sel_uic{i}.Value; %used to track changes
                    case 'Variable'     
                        ds = fieldnames(cobj.Data);
                        sel_uic{i}.String = cobj.Data.(ds{ids}).VariableDescriptions;
                        sel_uic{i}.Value = 1;
                    case 'Type'
                        sel_uic{i}.String = S.Type;
                end
            end        
            obj.TabContent(itab).Selections = sel_uic;
        end        
%%        
        function useSelection(obj,~,mobj)  
            %make use of the selection made to create a plot of selected type
            %Abstract function required by DataGUIinterface
            %NB tested for row vectors but NOT for N-dimensional arrays ***
            msgtxt = 'No data found for selection';
            muicat = mobj.Cases;
            uisel = obj.UIselection;
            
            %getProperty subsamples based on row and dimension selection
            %and applies a mask of NaN, undefined or '' for any variable 
            %limits set
            props = getProperty(muicat,uisel,'splittable'); 
            subtable = props.data; %data defined by selection - can be a subset
            if isempty(subtable), warndlg(msgtxt); return; end
            idrows = props.idx.row;                      %indices of rows used in full table            

            %if data is a vector can remove those rows that are outside 
            %the specified variable range and are set to NaN or '' 
            if width(subtable)==1
                %idxrow = getvarindices(subtable{:,:},props.dvals.var);
                subtable = subtable(props.idx.idv,:);
                if isempty(subtable), warndlg(msgtxt); return; end
                idrows = props.idx.row(props.idx.idv);   %indices of rows used in full table
            end

            %remove NaN, NaT, missing, undefined or '' if ExcNaN button set
            if obj.UIsettings.ExcNaN   
                [subtable,idr] = rmmissing(subtable); %removes any row in table that contains missing data
                if isempty(subtable), warndlg(msgtxt); return; end
                idrows = idrows(~idr);             %indices of rows used in full table
            end

            %create tablefigure for editing data
            casedesc = muicat.Catalogue.CaseDescription(uisel.caserec);
            title = sprintf('Edit %s',casedesc); 
            txt1 = 'To edit select a cell, amend value and press return, or select another cell';
            header = sprintf('%s\n%s',txt1,uisel.desc);    
            but.Text = {'Save','Cancel'}; %Figure control button options
            subtable = tablefigureUI(title,header,subtable,true,but);
            if isempty(subtable), return; end  %user cancelled
            idt = true(1,size(subtable,2));
            
            %recompile edited data into a single variable            
            varname = split(subtable.Properties.VariableNames{1},'_');
            newtable = mergevars(subtable,idt,'NewVariableName',varname{1});
            %save output to source dataset
            saveData(obj,mobj,newtable,idrows)
        end           
%%
        function saveData(obj,mobj,newtable,idrows)
            %update the edited record, var, to array or timeseries
            %newtable is table generated by useSelection and idrows is indices
            %of the data selcted (indices are row ids in full table)
            %NB tested for row vectors but NOT for N-dimensional arrays ***
            muicat = mobj.Cases;
            UIsel = obj.UIselection; 

            %selected case object and data table
            [cobj,~,~] = getCase(muicat,UIsel.caserec);   
            ds = fieldnames(cobj.Data);
            dst = cobj.Data.(ds{UIsel.dataset});  %selected dataset
            
            %get the sub-sampling indices
            varatt = getVarAttributes(dst,UIsel.variable);
            [id,~] = getSelectedIndices(muicat,UIsel,dst,varatt);
            
            % if size(idrows,1)~=height(newtable)
            %     newtable = newtable(idrows,:);
            % end
            %assign subsampled data to the selected case object
            dst.DataTable.(id.var)(idrows,id.dim{:}) = newtable{:,:};
            cobj.Data.(ds{UIsel.dataset}) = dst;
        end
    end
%%
%--------------------------------------------------------------------------
% Additional methods used to define tab content
%--------------------------------------------------------------------------
    methods (Access=private)
        function setEditTab(obj,src)
            %customise the layout of the Edit tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.8,0.14]; %vertical position and height of header
            txt1 = 'Select the variable to be edited.';
            txt2 = 'Use the ''Var'' button to select the attibute of the variable (data or dimension) to be edited.';
            txt3 = 'You may be prompted to sub-sample the data if multi-dimensional.';
            txt4 = 'The variable range is only applied when a vector of data is selected.';
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s\n4 %s',txt1,txt2,txt3,txt4);
            
            %Specification of uicontrol for each selection variable  
            S.Titles = {'Case','Datset','Variable'};            
            S.Style = {'popupmenu','popupmenu','popupmenu'};
            S.Order = {'Case','Dataset','Variable'};
            S.Scaling = {};  %options for ScaleVariable - exclude option
           
            %Tab control button options
            S.TabButText = {'Edit','Clear'}; %labels for tab button definition
            S.TabButPos = [0.1,0.03;0.3,0.03]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 1;                     %minimum number of buttons to use
            S.XYZmxvar = 2;                    %maximum number of dimensions per selection
            S.XYZpanel = [0.04,0.2,0.91,0.15]; %position for XYZ button panel
            S.XYZlabels = {'Var'};             %default button labels
            
            %Action button specifications - use default
            S = setActionButtonSpec(obj,S);
            S.ActButPos = [0.86,-1;0.895,0.27];     %positions for action buttons

            obj.TabContent(itab) = S;         %update object
        end  
 %%
        function S = setActionButtonSpec(~,S)
            %Default Action button specification for Stats UIs
            S.ActButNames = {'Refresh','ExcNaN'}; %names assigned selection struct
            S.ActButText = {char(174),'+N'};      %labels for additional action buttons
            % Negative values in ActButPos indicate that a
            % button is alligned with a selection option numbered in the 
            % order given by S.Titles
            S.ActButPos = [0.86,-1;0.86,-3];   %positions for action buttons   
            % action button callback function names
            S.ActButCall = {'@(src,evt)updateCaseList(obj,src,evt,mobj)',...
                            '@(src,evt)setExcNaN(src,evt)'};            
            S.ActButTip = {'Refresh data list',...%tool tips for buttons
                           'Include NaNs in edit'};            
        end       
    end
end