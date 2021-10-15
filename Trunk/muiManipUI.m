classdef muiManipUI < muiDataUI
%
%-------class help------------------------------------------------------
% NAME
%   muiManipUI.m
% PURPOSE
%   Class implements the muiDataUI class to access data and derive new
%   variables by calling muiUserModel
% SEE ALSO
%   muiDataUI.m and muiUserModel.m
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
% 
    properties (Transient)
        %Abstract variables for muiDataUI----------------------------------        
        %names of tabs providing different data accces options
        TabOptions = {'Calc'};       
        %Additional variables for application------------------------------
        Tabs2Use         %number of tabs to include  (set in getPlotGui)     
    end  
%%  
    methods (Access=protected)
        function obj = muiManipUI(mobj)
            %initialise standard figure and menus
            guititle = 'Derive output';
            setDataUIfigure(obj,mobj,guititle);    %initialise figure     
        end
    end
%%    
    methods (Static)
        function obj = getManipUI(mobj)
            %this is the function call to initialise the UI and assigning
            %to a handle of the main model UI (mobj.mUI.ManipUI) 
            %options for selection on each tab are defined in setTabContent
            if isempty(mobj.Cases.Catalogue.CaseID)
                warndlg('No data available to manipulate');
                obj = [];
                return;
            elseif isa(mobj.mUI.ManipUI,'muiManipUI')
                obj = mobj.mUI.ManipUI;
                if isempty(obj.dataUI.Figure)
                    %initialise figure 
                    guititle = 'Derive output';
                    setDataUIfigure(obj,mobj,guititle);   
                    setDataUItabs(obj,mobj); %add tabs 
                else
                    getdialog('Derive Output UI is open');
                end
            else
                obj = muiManipUI(mobj);
                obj.Tabs2Use = {'Calc'};
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
            %Abstract function required by muiDataUI
            itab = find(strcmp(obj.Tabs2Use,src.Tag));
            obj.TabContent(itab) = muiDataUI.defaultTabContent;
            
            %customise the layout of each tab. Overload the default
            %template with a function for the tab specific definition
            setCalcTab(obj,src) 
        end                
%%
        function setVariableLists(obj,src,mobj)
            %initialise the variable lists or values
            %Abstract function required by muiDataUI
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
                end
            end        
            obj.TabContent(itab).Selections = sel_uic;
        end    
%%        
        function useSelection(obj,src,mobj)  
            %make use of the selection made to create a plot of selected type
            %Abstract function required by muiDataUI
            switch src.String
                case 'Calculate'    %calculate result
                    cobj = muiUserModel;                    
                    createVar(cobj,obj,mobj);
                 case 'Function'
                    selectFunction(obj,mobj);    
            end 
        end           
    end
%%
%--------------------------------------------------------------------------
% Additional methods used to control selection and functionality of UI
%--------------------------------------------------------------------------
    methods (Access=private)
        function selectFunction(obj,mobj)
            %allow user to select a function from a defined list of available
            %functions (specified in functionlibrarylist)
            fn = functionlibrarylist(mobj);
            if isempty(fn.fname)
                warndlg('No functions defined (see functionlibrarylist.m)');
                return; 
            end
            ok = 1;
            while ok>0
                [idx,ok] = listdlg('Name','Function options', ...
                        'PromptString','Select a function:', ...
                        'ListSize',[350,200],...
                        'SelectionMode','single', ...
                        'ListString',fn.fdesc);
                if ok<1, return, end

                qtxt = sprintf('Selected:  %s\nFunction:  %s\nVariables: %s',...
                                 fn.fdesc{idx},fn.fname{idx},fn.fvars{idx});
                answer = questdlg(qtxt,'Selected function','Use','Change','Quit','Use');
                switch answer
                    case 'Use'
                        ok = 0;  %use selection
                    case 'Change'
                        %return to list
                    case 'Quit'
                        return;
                end
            end
            heq = findobj(obj.dataUI.Tabs,'Tag','UserEqn');
            heq.String = fn.fname{idx};
        end   
%%
%--------------------------------------------------------------------------
% Additional methods used to define tab content
%--------------------------------------------------------------------------
        function setCalcTab(obj,src)
            %customise the layout of the Calc tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            %Header size and text
            S.HeadPos = [0.8,0.14]; %vertical position and height of header
            txt1 = 'Select the variables to be used and assign to X Y Z buttons.';
            txt2 = 'You may be prompted to sub-sample the data if multi-dimensional.';
            txt3 = 'Use the Function to select a function, or define a Matlab expression.';
            S.HeadText = sprintf('1 %s\n2 %s\n3 %s',txt1,txt2,txt3);
            
            %Specification of uicontrol for each selection variable  
            S.Titles = {'Case','Datset','Variable'};            
            S.Style = {'popupmenu','popupmenu','popupmenu'};
            S.Order = {'Case','Dataset','Variable'};
            S.Scaling = {};  %options for ScaleVariable - exclude option
            
            %Tab control button options
            S.TabButText = {'Calculate','Function','Clear'}; %labels for tab button definition
            S.TabButPos = [0.1,0.03;0.3,0.03;0.5,0.03]; %default positions
            
            %XYZ panel definition (if required)
            S.XYZnset = 1;                        %minimum number of buttons to use
            S.XYZmxvar = [inf,inf,inf];           %maximum number of dimensions per selection
            S.XYZpanel = [0.05,0.30,0.9,0.3];     %position for XYZ button panel
            S.XYZlabels = {'X','Y','Z'};          %default button labels
            
            %Action button specifications
            S.ActButNames = {'Refresh','ExcNaN'}; %names assigned selection struct
            S.ActButText = {char(174),'+N'};      %labels for additional action buttons
            % Negative values in ActButPos indicate that a
            % button is alligned with a selection option numbered in the 
            % order given by S.Titles
            S.ActButPos = [0.86,-1;0.86,-3];      %positions for action buttons   
            % action button callback function names
            S.ActButCall = {'@(src,evt)updateCaseList(obj,src,evt,mobj)',...
                            '@(src,evt)setExcNaN(src,evt)'};
            % tool tips for buttons             
            S.ActButTip = {'Refresh data list',...%tool tips for buttons
                           'Switch to exclude NaNs in output'};         
            obj.TabContent(itab) = S;             %update object
            setEquationBox(obj,src);
        end    
    end
end