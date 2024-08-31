function [uniquenames,isunique] = check_unique_names(names,incsub,msg)
%
%-------function help------------------------------------------------------
% NAME
%   check_unique_names.m
% PURPOSE
%   check that names in list are unique and if required replace suplicates
%   with a unique name
% USAGE
%   [uniquenames,isunique] = check_unique_names(names,incsub)
% INPUTS
%   names - cell array of character vectors or string array to be checked
%   incsub - true if duplicate names are to be replaced so that a list of
%            unique names is returned
%   msg - warning message for when duplicates are found (optional)
% OUTPUTS
%   uniquenames - list of unique names
% SEE ALSO
%   used in Asmita Estuary class to check node names
% EXAMPLE
%   text = {'cow','pig','cow','sheep','dog','cow','sheep'};
%   [unames,isun] = check_unique_names(text,true,'message');
%   >> unames = {'cow 1','pig','cow 2','sheep 1','dog','cow 3','sheep 2'}
%
% Author: Ian Townend
% CoastalSEA (c) Oct 2021
%--------------------------------------------------------------------------
%
    if ischar(names) || length(names)==1 %trap single values
        uniquenames = names; 
        isunique = true;
        return;
    end
    %
    [uniquenames,ia,ic] = unique(names,'stable');
    if numel(ia)~=numel(ic)  && incsub 
        %add substitues for duplicates in names
        isunique = false;
        uniquenames = names;
        for j=1:length(ia)
            %check whether each unique value has any duplicates
            idd = find(ic==j);
            if length(idd)>1
                %duplicates found so rename                
                for k=1:length(idd)
                    uniquenames{idd(k)} = [names{ia(j)},sprintf(': %d',k)];
                end
            end
        end
        %issue message that not all input names are unique (if provided)
        if nargin==3 && ~isempty(msg)
            warndlg(msg)
        end
    elseif numel(ia)~=numel(ic)
        %return names with no duplicates 
        isunique = false;
    else
        %no duplicates in names
        isunique = true;
    end
end