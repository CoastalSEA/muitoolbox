function  var = scalevariable(inputvar,selection,dim)
%
%-------function help------------------------------------------------------
% NAME
%   scalevariable.m
% PURPOSE
%   rescale a variable (vector or matrix) based on user selection
% USAGE
%    var = scalevariable(inputvar,selection,dim)
% INPUT
%   inputvar  - the input variable to be scaled
%   selection - type of scaling to be applied. Any of the following:
%               'Linear','Log','Relative: V-V(x=0)','Scaled: V/V(x=0)',
%               'Normalised','Normalised (-ve)','Differences','Rolling
%               mean'
%   dim       - dimension over which to apply the scaling function to matrix
%               optional and default is dim = 1. 
% OUTPUT
%   var - rescaled variable
% NOTES
%   dim is typically the time dimension but may be the distance
%   dimension when normalising space-time plots
% SEE ALSO
% used in muiDataUI classes to rescale a variable (eg for plotting or
% statistical anslyis)
%   
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    if nargin<3
        dim = 1;
    end    
    vardims = fliplr(size(inputvar));
    %invert matrix if dim=2 to obtain values for each row 
    if dim==2
        inputvar = inputvar';
    end
    %apply selected re-scaling method            
    var = zeros(size(inputvar));
    for i = 1:vardims(dim)
        subvar = inputvar(:,i);
        idx = find(~isnan(subvar),1,'first');
        switch selection
            case 'Log'
                var(:,i) = log10(subvar);
            case 'Relative: V-V(x=0)'                    
                var(:,i) = subvar-subvar(idx);               
            case 'Scaled: V/V(x=0)',...
                var(:,i) = subvar/subvar(idx);                    
            case 'Normalised'                    
                mvar = mean(subvar,'omitnan');
                svar = std(subvar,'omitnan');
                var(:,i) = (subvar-mvar)/svar;
            case 'Normalised (-ve)'
                mvar = mean(subvar,'omitnan');
                svar = std(subvar,'omitnan');
                var(:,i) = -(subvar-mvar)/svar;
            case 'Differences'
                diffs = diff(subvar);
                var(:,1) = [diffs(1);diffs];
            case 'Rolling mean'
                qinp = inputdlg('No of intervals?','Rolling mean');
                if isempty(qinp)
                    int = 1;
                else
                    int = str2double(qinp{1});
                end
                var(:,1) = moving(subvar,int);
        end 
    end
    %restore matrix if dim=2
    if dim==2
        var = var';
    end
end