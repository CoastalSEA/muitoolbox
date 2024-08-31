function [casenum,casedesc] = setcase(caseobj,SupressPrompts,casename)
%
%-------function help------------------------------------------------------
% NAME
%   setcase.m
% PURPOSE
%   set case number and prompt user to provide a description
% USAGE
%   [casenum,casedesc] = setcase(caseobj)
% INPUT
%   caseobj - the case object or list to add to
%   SupressPrompts - logical flag to supress UI call if true
%   casename - user defined name or prompt for case
% OUTPUT
%   casenum - unique id for the record
%   casedesc - user or default case description
% SEE ALSO
%   used in muiStats (based on newRecord method in dscatalogue.m)
%
% Author: Ian Townend
% CoastalSEA (c)June 2021
%--------------------------------------------------------------------------
%
    if isempty(caseobj)
        casenum = 1;
    else
        casenum = length(caseobj)+1;
    end
    
    if nargin<3
        casename = {''};
    end
    %
    if SupressPrompts  %supress prompt if true
        answer = casename;
    else
        answer = inputdlg('Case Description','Case',1,casename);
    end
    
    if isempty(answer) || strcmp(answer,'')
        casedesc = sprintf('Case no: %g',casenum);
    else
        casedesc = answer{1};
    end
end