classdef ParamInput_template < muiPropertyUI                 % << Edit to classname
%
%-------class help------------------------------------------------------===
% NAME
%   PropsInput_template.m
% PURPOSE
%   Class for input parameters for some component of the UI application
% USAGE
%   obj = PamamInput_template.setParamInput(mobj); %mobj is a handle to Main UI
% SEE ALSO
%   inherits muiPropertyUI
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
%      
    properties (Hidden)
        %abstract properties in muiPropertyUI to define input parameters
        PropertyLabels = {'Parameter 1 short description',... % << Edit to property descriptions
                          'Parameter 2 short description',...
                          'etc'};
        %abstract properties in muiPropertyUI for tab display
        TabDisplay   %structure defines how the property table is displayed 
    end
    
    properties
        Parameter_1                %definition of parameter 1  % << Edit to property names
        Parameter_2                %definition of parameter 2
        etc   %there should be as many properties as labels
    end    

%%   
    methods (Access=protected)
        function obj = ParamInput_template(mobj)             % << Edit to classname
            %constructor code:            
            %values defined in UI function setTabProperties used to assign
            %the tabname and position on tab for the data to be displayed
            obj = setTabProps(obj,mobj);  %muiPropertyUI function
            
            %to use non-numeric entries then one can either pre-assign 
            %the values in the class properties defintion, above, or 
            %specify the PropertyType as a cell array here in the class 
            %constructor, e.g.:
            % obj.PropertyType = [{'datetime','string','logical'},...
            %                                       repmat({'double'},1,8)];
        end 
    end
%%  
    methods (Static)  
        function obj = setParamInput(mobj,editflag)
            %gui for user to set Parameter Input values
            classname = 'ParamInput_template';               % <<Edit to classname
            if isfield(mobj.Inputs,classname) && ...
                            isa(mobj.Inputs.(classname),classname)
                obj = mobj.Inputs.(classname);  
            else
                obj = ParamInput_template(mobj);             % << Edit to classname
            end
            %use muiPropertyUI function to generate UI
            if nargin<2 || editflag
                %add nrec to limit length of props UI (default=12)
                obj = editProperties(obj);  
                %add any additional manipulation of the input here
            end
            mobj.Inputs.(classname) = obj;
        end     
    end
%%        
        %add other functions to operate on properties as required   
end