classdef mui_demoPropsInput < muiPropertyUI
%
%-------class help------------------------------------------------------===
% NAME
%   mui_demoPropsInput.m
% PURPOSE
%   Class for input data used in muitoolbox example to implement the
%   Diffusion2D model
% USAGE
%   obj = mui_demoPropsInput.setPropsInput(mobj); %mobj is a handle to Main UI
% SEE ALSO
%   inherits muiPropertyUI
%
% Author: Ian Townend
% CoastalSEA (c)Nov 2020
%--------------------------------------------------------------------------
%
    properties (Hidden)
        %abstract properties in PropertyInterface to define input variables
        PropertyLabels = {'Length of X dimension',...
                          'Length of Y dimension',...
                          'Number of intervals in X dimension',...
                          'Number of intervals in Y dimension',...
                          'Boundary condition at X=0',...
                          'Boundary condition at X=L',...
                          'Boundary condition at Y=0',...
                          'Boundary condition at Y=L',...
                          'Diffusion coefficient',...
                          'Peak disturbance',...
                          'Size of disturbance (0-1)',...
                          'Duration of time step (s)',...
                          'Number of time steps ',...
                          'Boundary condition (1=Dirichlet,2=Neumann)',...
                          'Numerical Scheme (1=Implicit,2=Explicit)',...
                          'Pseudo-3D output'};
        %abstract properties in PropertyInterface for tab display
        TabDisplay   %structure defines how the property table is displayed 
    end    
    
    properties
        Xlength             %Length of X dimension (m)
        Ylength             %Length of Y dimension', (m)
        Xint                %Number of intervals in X dimension
        Yint                %Number of intervals in Y dimension
        uWest = 0;          %Boundary condition at X=0
        uEast = 0;          %Boundary condition at X=L
        uNorth = 0;         %Boundary condition at Y=0
        uSouth = 0;         %Boundary condition at Y=L
        DiffCoeff           %Diffusion coefficient (-) 
        uPeak               %magnitude of initial distrubance
        PkSize              %proportion of X and Y that is disturbed  
        TimeStep = 0.1      %time step duration (seconds)
        NumStep = 100       %number of time steps(-)
        BCoption = 1        %selected boundary condition (1 or 2)  
        NumScheme = 1       %selected numerical scheme (1 or 2)
        is3D = false        %option to output pseudo-3D output
    end
%%   
    methods (Access=protected)       
        function obj = mui_demoPropsInput(mobj)  %instantiate class
            %constructor code:            
            %values defined in UI function setTabProperties used to assign
            %the tabname and position on tab for the data to be displayed
            obj = setTabProps(obj,mobj);  %muiPropertyUI fcn
            
            %to use non-numeric entries then one can either pre-assign 
            %the values in properties defintion, above, or specity the 
            %PropertyType as a cell array, e.g.:
            % obj.PropertyType = [{'datetime','string','logical'},...
            %                                       repmat({'double'},1,8)];
        end       
    end
%%
    methods (Static)     
        function obj = setInput(mobj,editflag)
            %gui for user to set Input demo propery values
            classname = 'mui_demoPropsInput';    
            if isfield(mobj.Inputs,classname) && ...
                            isa(mobj.Inputs.(classname),classname)
                obj = mobj.Inputs.(classname);  
            else
                obj = mui_demoPropsInput(mobj);  %instanstiate class instance
            end
            %use muiPropertyUI function to generate UI
            if nargin<2 || editflag
                %add nrec to limit length of props UI (default=12)
                obj = editProperties(obj,11);  
                %add any additional manipulation of the input here
            end
            mobj.Inputs.(classname) = obj;
        end  
    end    
%%     
        %add other functions to operate on properties as required    
end    
    