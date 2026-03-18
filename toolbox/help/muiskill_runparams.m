%% muiSkill_RunParams
% UI Class to set parameters used for the skill score calculation.

%% Syntax
%%
%   muiSkill_RunParams.setInput(obj);  %where obj is a an App instance

%% Description
% The class is used to set the parameters required to run the skill 
% statistical tools and generate a Taylor Diagram.

%% muiSkill_RunParams properties
% The class has the following properties:
%%
% * _maxcorr_ - maximimum correlation achievable (-)
% * _skillexponent_ - exponent to be used in skill score (-)
% * _skillwindow_ - number of points or grids to sub-sample over: +/-W (-)
% * _skillsubdomain_ - used to average local skill over a sub domain, where
% the subdomain is defined as [x0,xN,y0,yN];
% * _skilliteration_ - flag to define iteration as:
% true - iterates over every grid cell i=1:m-2W; 
% false - avoids overlaps and iterates over i=1:2W:m-2W.

%% muiSkill_RunParams methods
% Methods for entering, editing and displaying hte input properties 
% are inherited from the muitoolbox <matlab:doc('muipropertyui') muiPropertyUI>
% abstract class.

%% See Also
% <matlab:doc('muitoolbox') muitoolbox>,
% <matlab:doc('dstoolbox') dstoolbox>, 
% <matlab:doc('modelskill') ModelSkill App>.