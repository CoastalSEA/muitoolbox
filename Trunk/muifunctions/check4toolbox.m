function isok = check4toolbox(feature_name)
%
%-------function help------------------------------------------------------===
% NAME
%   check4toolbox.m
% PURPOSE
%   Check whether a toolbox is available
% USAGE
%   isok = check4toolbox(name)
% INPUT
%   feature_name - feature name of toolbox to be checked (usually name with
%   underscores).
% OUTPUT
%   isok - ture if toolbox is available
% NOTES
%   https://uk.mathworks.com/matlabcentral/answers/377731-how-do-features-from-license-correspond-to-names-from-ver#answer_300675
% SEE ALSO
%	initialise_mui_app.m
%
% Author: Ian Townend
% CoastalSEA (c) Dec 2022
%--------------------------------------------------------------------------
% 
    if license('test', feature_name)
        isok = 1;
    else
        isok = 0;
    end
end