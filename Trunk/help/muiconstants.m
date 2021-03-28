%% muiConstants
% Class to hold constants that are commonly used in applications

%% Syntax
%   Constants = muiConstants.Evoke;  %constants used by applications

%% muiConstants properties
% The following are helds as a default set of constant properties:
%%
% * *y2s* - factor to convert years to seconds (365.2425 days).
% * *Gravity* - acceleration due to gravity (m/s2). Default is 9.81.
% * *WaterDensity* - density of water (kg/m3). Default is 1025.
% * *SedimentDensity* - density of sediment (kg/m3). Default is 2650.
% * *KinematicViscosity* - kinematic viscosity of water (m2/s). Default is 1.36e-6.

%% muiConstants methods
% Class inherits muiPropertyUI. Properties are set on initialisation and
% can be edited using the default dialog. This is called from
% Setup>Model Constants menu in the <matlab:doc('modelui') ModelUI> App.

%% See Also
% <matlab:doc('muitoolbox') muitoolbox><matlab:doc('muicatalogue') muiCatalogue>,
% <matlab:doc('dstoolbox') dstoolbox>, <matlab:doc('dstable') dstable>.