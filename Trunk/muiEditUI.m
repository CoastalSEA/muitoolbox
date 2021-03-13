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
        %Abstract variables for DataGUIinterface---------------------------        
        %names of tabs providing different data accces options
        TabOptions = {'Edit'};       
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
            %this is the function call to initialise the Plot GUI.
            %the input is a handle to the data to be plotted  
            %the options for plot selection are defined in setTabContent
            if isempty(mobj.Cases.Catalogue.CaseID)
                warndlg('No data available to edit');
                obj = [];
                return;
            elseif isa(mobj.mUI.EditUI,'muiEditUI')
                obj = mobj.mUI.EditUI;
                if isempty(obj.dataUI.Figure)
                    obj = obj.setDataUIfigure(mobj);    %initialise figure 
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
            cobj = getCase(mobj.Cases,1);
            for i=1:length(sel_uic)                
                switch sel_uic{i}.Tag
                    case 'Case'
                        muicat = mobj.Cases.Catalogue;
                        sel_uic{i}.String = muicat.CaseDescription;
                    case 'Dataset'
                        sel_uic{i}.String = fieldnames(cobj.Data);
                    case 'Variable'     
                        ds = fieldnames(cobj.Data);
                        sel_uic{i}.String = cobj.Data.(ds{1}).VariableDescriptions;
                    case 'Type'
                        sel_uic{i}.String = S.Type;
                end
            end        
            obj.TabContent(itab).Selections = sel_uic;
        end
%%       
        function setTabActions(obj,src,~,~) 
            %actions needed when activating a tab
            %Abstract function required by DataGUIinterface
            initialiseUIselection(obj,src);
            initialiseUIsettings(obj,src);
            resetVariableSelection(obj,src);
            clearXYZselection(obj,src);
        end         
%%        
        function UseSelection(obj,~,mobj)  
            %make use of the selection made to create a plot of selected type
            %Abstract function required by DataGUIinterface
            muicat = mobj.Cases;
            uisel = obj.UIselection;
            %subtable holds data defined by selection which can be a subset
            props = getProperty(muicat,uisel,'splittable'); 
            subtable = props.data;
            
            %if vector remove rows outside the specified variable range
            if width(subtable)==1
                idxrow = getvarindices(subtable{:,:},uisel.range);
                subtable = subtable(idxrow,:);
            end
            %create tablefigure for editing data
            casedesc = muicat.Catalogue.CaseDescription(uisel.caserec);
            title = sprintf('Edit %s',casedesc); 
            txt1 = 'To edit select a cell, amend value and press return, or select another cell';
            header = sprintf('%s\n%s',txt1,uisel.desc);    
            but.Text = {'Save','Cancel'}; %Figure control button options
            subtable = tablefigureUI(title,header,subtable,true,but);
            if isempty(subtable), return; end  %user cancelled
            idx = true(1,size(subtable,2));
            
            %recompile edited data into a single variable            
            varname = split(subtable.Properties.VariableNames{1},'_');
            newtable = mergevars(subtable,idx,'NewVariableName',varname{1});
            %save output to source dataset
            saveData(obj,mobj,newtable)
        end           
%%
        function saveData(obj,mobj,newtable)
            %update the edited record, var, to array or timeseries
            muicat = mobj.Cases;
            UIsel = obj.UIselection; 

            %selected case object and data table
            [cobj,~,~] = getCase(muicat,UIsel.caserec);   
            ds = fieldnames(cobj.Data);
            dst = cobj.Data.(ds{UIsel.dataset});  %selected dataset
            
            %get the sub-sampling indices
            varatt = getVarAttributes(dst,UIsel.variable);
            [id,~] = getSelectedIndices(muicat,UIsel,dst,varatt);
            
            %assign subsampled data to the selected case object
            dst.DataTable.(id.var)(id.row,id.dim{:}) = newtable{:,:};
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
            
            %Action button specifications
%             S.ActButNames = {'Refresh'};           %names assigned selection struct
%             S.ActButText = {char(174)};            %labels for additional action buttons
%             % Negative values in ActButPos indicate that a
%             % button is alligned with a selection option numbered in the 
%             % order given by S.Titles
%             S.ActButPos = [0.86,-1];%positions for action buttons   
%             % action button callback function names
%             S.ActButCall = {'@(src,evt)updateCaseList(obj,src,evt,mobj)'};
%             % tool tips for buttons             
%             S.ActButTip = {'Refresh data list'};         
            obj.TabContent(itab) = S;         %update object
        end    
    end
end