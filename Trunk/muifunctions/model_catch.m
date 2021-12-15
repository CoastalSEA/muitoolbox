function model_catch(ME,modelname,pname,pvalue)
%
%-------function help------------------------------------------------------
% NAME
%   model_catch.m
% PURPOSE
%   display warning dialogue if model fails to find a solution in try-catch
% USAGE
%   model_catch(ME,modelname,pname,pvalue)
% INPUTS
%   ME - Matlab MException object
%   modelname - character vector or string for name of model or function 
%               being called in try,catch statement
%   pname - character vector or string for name of parameter that may
%               cause model to fail (optional)
%   pvalue - a run parameter that may be cause of failure to execute (optional)
% NOTES
%   also deletes waitbar, if created as part of model run
% SEE ALSO
%   used in CF_HydroData as part of the ChannelForm model 
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2022
%--------------------------------------------------------------------------
%
    if strcmp(ME.identifier,'MATLAB:UndefinedFunction')
        msgtxt = sprintf('Unable to evaluate call to %s\nID: ',modelname);
    else
        if nargin<3
            msgtxt = sprintf('Failed to find solution in %s\n%s',...
                                                   modelname,ME.message);
        else
            msgtxt = sprintf('Failed to find solution in %s for %s=%d\n%s',...
                                      modelname,pname,pvalue,ME.message);
        end
    end
    %
    hw = findall(0,'type','figure','tag','TMWWaitbar');
    delete(hw);
    warndlg(msgtxt);
end