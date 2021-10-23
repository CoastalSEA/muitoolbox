function valididx = getvarindices(var,limtxt)  
%
%-------function help------------------------------------------------------
% NAME
%   getvarindices.m
% PURPOSE
%   unpack the limits text and find indices of values that lie 
%   within the lower/upper limits defined
% USAGE
%   valididx = getvarindices(var,limtxt);
% INPUT
%   var - variable for which indices of range are required
%   limtxt - range text in the form 'From > XXXX To > YYYY'
%            append range text with xNaN ie 'xNaN From > XXXX To > YYYY'
%            eg using rangetext = var2range(rangevar,pretext)
% OUTPUT
%   validindex - vector of valid indices   
% SEE ALSO
%   used in muiCatalogue.m
%
% Author: Ian Townend
% CoastalSEA (c)Jan 2021
%--------------------------------------------------------------------------
%
            valididx = [];
            idx = regexp(limtxt,'>');
            lowerlimit = limtxt(idx(1)+1:idx(2)-4);
            upperlimit = limtxt(idx(2)+1:end);
            %handle exclusion/inclusion of NaN values in a Variable
            excnan = false;   %default is to include NaNs
            if contains(limtxt,'xNaN')
                excnan = true;
            end 
            
            if isdatetime(var)  
                try 
                    minB = datetime(lowerlimit,'InputFormat',var.Format);
                    maxB = datetime(upperlimit,'InputFormat',var.Format);
                    if strcmp(var.Format,'y')
                        maxB = maxB+364;
                    end
                catch
                    warndlg('Specified Date Range is not valid');                    
                    return;
                end
            elseif isduration(var)
                minB = str2duration(lowerlimit,var.Format);
                maxB = str2duration(upperlimit,var.Format);
            elseif iscalendarduration(var)
                startyear = datetime(0,1,1,0,0,0);
                var = startyear+var;
                minB = startyear+str2caldur(lowerlimit);
                maxB = startyear+str2caldur(upperlimit);
            elseif iscell(var) && ischar(lowerlimit)
                %cell array of character vectors with limits being values
                %in list
                minV = find(strcmp(var,strip(lowerlimit)));
                maxV = find(strcmp(var,strip(upperlimit)));
                valididx = minV:maxV;
                return;
            elseif iscell(var)  && ischar(var{1})
                %handle limits for categorical data
                minV = str2double(lowerlimit);
                maxV = str2double(upperlimit);
                valididx = minV:maxV;
                return;
            else 
                minV = str2double(lowerlimit);
                maxV = str2double(upperlimit);
                if minV>maxV
                    minV = maxV;
                    maxV = str2double(lowerlimit);
                elseif isnan(minV) && ischar(lowerlimit)
                    %handle limits for categorical data
                    var = categorical(var,'Ordinal',true);
                    cats = categories(var);
                    minV = categorical({lowerlimit},cats,'Ordinal',true);
                    maxV = categorical({upperlimit},cats,'Ordinal',true);
                    valididx = find(var>=(minV) & var<=(maxV));
                    return;
                end
                %need to ensure that end values are not cut off (rounding
                %errors mean the >= and <= do not always work)    
                loweridx = find(var>=minV);
                upperidx = find(var<=maxV); 
                if ~isempty(loweridx) && ~isempty(upperidx)
                    if length(loweridx)==1 ||  length(upperidx)==1
                        %handle case of only one value in the index range
                        minB = minV-minV/100; %arbitrary small offset
                        maxB = maxV+maxV/100;
                    else
                        minB = minV-abs(var(loweridx(1))-var(loweridx(1)+1))/2;
                        maxB = maxV+abs(var(upperidx(end))-var(upperidx(end)-1))/2;
                    end
                    %
                    if isnan(minB) || isnan(maxB)
                        minB = minV;
                        maxB = maxV;
                    end    
                elseif minV==maxV           %vector of values are same
                    minB = floor(var(1));   %avoid rounding error in text
                    maxB = ceil(var(1));    %string
                else
                    warndlg('Could not find limits in getVarIndices')
                    valididx =[];
                    return;
                end
            end        
            %find indices of the values that lie within the limits
            if ~excnan && ~isdatetime(var) && ~isduration(var)
                valididx = find((var>=(minB) & var<=(maxB)) | isnan(var));
            else
                valididx = find(var>=(minB) & var<=(maxB));
            end
        end  