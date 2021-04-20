classdef DataUI_template < muiDataUI                          % << Edit to classname
 %
%-------class help---------------------------------------------------------
% NAME
%   DataUI_template.m                                         % << Edit to file name
% PURPOSE
%   Template for Class that implements the muiDataUI class 
% SEE ALSO
%   muiDataUI.m and interfaces for editing, plotting etc
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
        function obj = DataUI_template(mobj)                 % << Edit to classname
            %initialise standard figure and menus
            guititle = 'Template title';                     % << Edit to suit application
            setDataUIfigure(obj,mobj,guititle);  %initialise figure     
        end
    end   
%%    
    methods (Static)
        function obj = getTemplateUI(mobj)                   % << Edit to suit application
            %this is the function call to initialise the UI and assigning
            %to a handle of the main model UI (mobj.mUI.****) 
            %options for selection on each tab are defined in setTabContent
            if isempty(mobj.Cases.Catalogue.CaseID)
                warndlg('No data available to XXXXXXX?');    % << Edit to suit application
                obj = [];
                return;
            elseif isa(mobj.mUI.DataUI_template,'DataUI_template') % << Edit to suit application
                obj = mobj.mUI.DataUI_template;
                if isempty(obj.dataUI.Figure)
                    obj = obj.setDataUIfigure(mobj); %initialise figure 
                    setDataUItabs(obj,mobj); %add tabs 
                else
                    getdialog('Derive Output UI is open');
                end
            else
                obj = DataUI_template(mobj);                 % << Edit to classname
                obj.Tabs2Use = {'TabName'};                  % << Edit to suit application
                setDataUItabs(obj,mobj); %add tabs           % << see muiPlotsUI for example of multiple tabs        
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
            setTabNameTab(obj,src)                           % << Edit to suit application   
                                                             % << use switch if multiple tabs
        end                
%%
        function setVariableLists(obj,src,mobj,caserec)
            %initialise the variable lists or values
            %Abstract function required by muiDataUI
            %called during initialisation by muiDataUI.setDataUItabs and 
            %whenever muiDataUI.updateCaseList is called
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            sel_uic = S.Selections;
            cobj = getCase(mobj.Cases,caserec);
            for i=1:length(sel_uic)                
                switch sel_uic{i}.Tag
                    case 'Case'
                        muicat = mobj.Cases.Catalogue;
                        sel_uic{i}.String = muicat.CaseDescription;
                        sel_uic{i}.UserData = sel_uic{i}.Value; %used to track changes
                    case 'Dataset'
                        sel_uic{i}.String = fieldnames(cobj.Data);
                        sel_uic{i}.Value = 1;
                    case 'Variable'     
                        ds = fieldnames(cobj.Data);
                        sel_uic{i}.String = cobj.Data.(ds{1}).VariableDescriptions;
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
                case 'Calculate'    %calculate result        % << Cases must match button names
                    cobj = muiUserModel;                     % << defined for tab. Defaults such as
                    createVar(cobj,obj,src,mobj);            % << Clear and Close are handled in muiDataUI
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
%
%%
%--------------------------------------------------------------------------
% Additional methods used to define tab content
%--------------------------------------------------------------------------
        function setTemplateTab(obj,src)                     % << Edit to suit application   
            %customise the layout of the Template tab
            %overload defaults defined in muiDataUI.defaultTabContent
            itab = strcmp(obj.Tabs2Use,src.Tag);
            S = obj.TabContent(itab);
            
            % overload default definition as required
            % see muiEditUI, muiManipUI, muiPlotsUI and muiStatsUI for
            % examples
            
            obj.TabContent(itab) = S;             %update object
        end        
    end   
end