classdef muiConstants < muiPropertyUI
%
%-------class help------------------------------------------------------
% NAME
%   muiConstants.m
% PURPOSE
%   Class to hold constants that are used in the gui and models
%
% Author: Ian Townend
% CoastalSEA(c) Aug 2020
%--------------------------------------------------------------------------
%
    properties (Constant)
        y2s = 31556952          %factor to convert years to seconds (365.2425 days)    
        Evoke = muiConstants
    end
    
    properties (Hidden)
        PropertyLabels = {'Acceleration due to gravity (m/s2)',...
                          'Water density (kg/m3)',...
                          'Sediment density (kg/m3)',...
                          'Kinematic viscosity (m2/s)'};
        TabDisplay %abstract property required by muiPropertyUI but not used
    end
    
    properties
        Gravity                      %acceleration due to gravity (m/s2)
        WaterDensity                 %density of water (kg/m3)
        SedimentDensity              %density of sediment (kg/m3)
        KinematicViscosity           %kinematic viscosity of water (m2/s)
    end   
%%        
    methods (Access = private)
        function obj = muiConstants
            %constructor defines values of constants
            obj.Gravity = 9.81;
            obj.WaterDensity = 1025;
            obj.SedimentDensity = 2650;
            obj.KinematicViscosity = 1.36e-6;
        end
    end
%%
    methods  
        function obj = setInput(obj)
            %gui for user to set Parameter Input values
            obj = editProperties(obj);  
        end     
%%  
        function cn = getConstantStruct(obj)
            %contant values as a struct with abbreviated field names
            cn.y2s = obj.y2s;
            cn.g = obj.Gravity;
            cn.rhow = obj.WaterDensity;
            cn.rhos = obj.SedimentDensity;
            cn.visc = obj.KinematicViscosity;
        end
    end
end