function user_model(mobj)
%
%-------function help------------------------------------------------------
% NAME
%   user_model.m
% PURPOSE
%   Calls user defined model
% USAGE
%   user_model(mobj)
% INPUT
%   mobj - handle to App UI to allow access to data
% OUTPUT
%   run user model
% SEE ALSO
%   Model_template.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2021
%--------------------------------------------------------------------------
%
promptxt = {'Define class to use:','Define function call'};
titletxt = 'User model';
defaultprops = {'Classname','runModel'};
answer = inputdlg(promptxt,titletxt,1,defaultprops);
if isempty(answer), return; end  %user cancelled

iscl = exist(answer{1},'class');
if iscl~=8
    warndlg('Requested class not found')
    return;
end

%Set up call to model method and execute
try
    callstring = sprintf('@(mobj) %s.%s(mobj)',answer{1},answer{2});
    heq = str2func(callstring);  
    heq(mobj);
catch ME
    msgtxt = ('Call to class, or class method failed in user_model');
    disp([msgtxt, ME.identifier])
    rethrow(ME)  
end