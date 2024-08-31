function isvalid  = isvalidrange(testvar,bounds)
%
%-------function help------------------------------------------------------
% NAME
%   isvalidrange.m
% PURPOSE
%   check user input is valid for the data type used and within bounds
% USAGE
%   isvalid  = isvalidrange(testvar,bounds)
% INPUT
%   testvar - cell array with lower and upper values of range to be checked
%   bounds - cell array for user defined lower and upper limits to the 
%            range (optional)
% OUTPUT
%   isvalid - logical true if the range is valid
% NOTES
%   checks for valid date, not NaN, correct order, within bounds if supplied
%   called from editrange.m
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    if nargin<2, bounds = []; end
    isvalid = true;
    if isdatetime(testvar{1})
        upperyear = 2500;
        for i=1:2
            if isnat(testvar{i})
                msgbox('Invald data. Cannot be a NaT value')
            end
            %check that date is not negative and in a sensible range
            tlower = datetime(0,1,1);
            tupper = datetime(upperyear,12,31);
            if ~isbetween(testvar{i},tlower,tupper)
                %return out or range date + message
                isvalid = false;
                msgbox(sprintf('%s Invald date. Please correct input', testvar{i}))
                return
            end
        end
    end
    %check for NaNs
    if isnumeric(testvar{1})
        nancheck = cellfun(@isnan,testvar);
        if any(nancheck)
            isvalid = false;
            msgbox('Invald data. Cannot be a NaN value')
            return
        end
    end
    %check bounds
    if  ~isempty(bounds) && iscategorical(bounds)
        %testvar is as cell array with categorical cells. Need to convert to categorical array
        if any(~iscategory(bounds,testvar))
            isvalid = false;
            msgbox('Invald data. Input is not a valid category')
        elseif isordinal(bounds)
            catvar = categorical(testvar,string(bounds),'Ordinal',true);
            if catvar(1)>catvar(2)
                isvalid = false;
                msgbox('Invald data. Incorrect order for Ordinal data')
            end
        end
    elseif ~ischar(testvar{1}) && ~isempty(bounds)
        if isnumeric(bounds{1})
            bounds = check_bounds(bounds);
        end
        islower = testvar{1}<bounds{1} || testvar{2}<bounds{1};
        if islower
            isvalid = false;
            msgbox(setmsgtext(bounds{1},1));
            return;
        end
            
        isabove = testvar{1}>bounds{2} || testvar{2}>bounds{2};
        if isabove
            isvalid = false;
            msgbox(setmsgtext(bounds{2},2));
            return;
        end
        
        if iscategorical(testvar{1})
            %catch user entering a value that is not in category list
            if isundefined(testvar{1})
                isvalid = false;
                msgbox(setmsgtext(1,3));
            elseif isundefined(testvar{2})
                isvalid = false;
                msgbox(setmsgtext(2,3));
            end
        end
    end
    %check that range is in correct order (From->To)
    if ~ischar(testvar{1}) && testvar{2}<testvar{1}
        isvalid = false;
        msgbox('Warning: range values are in the wrong order')
    end
end
%%
function msgtxt = setmsgtext(var,idx)
    %set the message text depending on data type
    switch idx
        case 1
            msgtxt = 'Invald data. Value below lower limit of';
        case 2
            msgtxt = 'Invald data. Value above upper limit of';
        case 3
            msgtxt = 'Invald data. Undefined limit';
    end
    
    if isnumeric(var)   %numeric or sting data format required
        msgtxt = sprintf('%s %g',msgtxt,var);
    else
        msgtxt = sprintf('%s %s',msgtxt,var);
    end
        
end
%%
function outbounds = check_bounds(inbounds)
    %check for rounding errors when converting between numeric ranges and
    %the displayed text strings
    outbounds = inbounds;
    if str2double(sprintf('%g',inbounds{1}))~=inbounds{1}
        outbounds{1} = str2double(sprintf('%g',inbounds{1}));
    end
    %
    if str2double(sprintf('%g',inbounds{2}))~=inbounds{2}
        outbounds{2} = str2double(sprintf('%g',inbounds{2}));
    end
end