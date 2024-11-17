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
%            range or valid list if text (optional)
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
    nvar = length(testvar);
    %----------------------------------------------------------------------
    for i=1:nvar  %check each range value in turn
        testval = testvar{i};
        %check for NaNs
        if isnumeric(testval)
            if isnan(testval)
                isvalid = false;
                msgbox('Invald data. Cannot be a NaN value')
                return
            end
        elseif isdatetime(testval)
            if isnat(testval)
                msgbox('Invald data. Cannot be a NaT value')
                return
            else
                %check that date is not negative and in a sensible range
                tlower = datetime(0,1,1);
                tupper = datetime(2500,12,31);
                if ~isempty(bounds)
                    tlower = max([tlower,bounds{1}]);
                    tupper = min([tupper,bounds{2}]);
                end
                %
                if ~isbetween(testval,tlower,tupper)
                    %return out or range date + message
                    isvalid = false;
                    msgbox(sprintf('%s Invald date. Please correct input', testval))
                    return
                end
            end
        elseif iscategorical(testval)
            %catch user entering a value that is not in category list
            if isundefined(testval) %indicates which elements in categorical array contain undefined values
                isvalid = false;
                msgbox(setmsgtext(i,3));
            end
        end    
    end    
    
    %now check relative order
    if ~isempty(bounds)
        if islist(bounds)
            %if bounds is a list of text data convert to 
            stid = find(strcmp(bounds,testvar{1}));
            ndid = find(strcmp(bounds,testvar{2}));
            if ndid<stid
                isvalid = false;
                msgbox('Invald selection: range values are in the wrong order')
            end 
        elseif isnumeric(bounds{1})  
            bounds = check_bounds(bounds);       %check for rounding errors
            
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
        end
    end
    
    %check that range is in correct order (From->To)
    if ~islist(testvar,1) && testvar{2}<testvar{1}
        isvalid = false;
        msgbox('Invald selection: range values are in the wrong order')
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