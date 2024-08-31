function [rangevar,pretext] = range2var(rangetext,bounds)
%
%-------function help------------------------------------------------------
% NAME
%   range2var.m
% PURPOSE
%   convert range character array to start and end variables
% USAGE
%   [rangevar,pretext] = range2var(rangetext)
% INPUT
%   rangetext - range character array in format From > xxx To > yyy
%   bounds - user defined lower and upper limits to the range (optional)
% OUTPUT
%   rangevar - 1x2 cell array of values to define start and end or range
%   pretext  - text that precedes the range text (ie before 'From...to...')
% SEE ALS
%   used in muiDataUI
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
% 
    if nargin<2, bounds = []; end
    rangevar = [];
    idx = regexp(rangetext,'>');
    if length(idx)<2, return; end

    Vin{1} = strip(rangetext(idx(1)+1:idx(2)-4));
    Vin{2} = strip(rangetext(idx(2)+1:end));
    rangevar{1,2} = [];
    if isempty(bounds)  
        %no bounds to determine data type so find by trial and error  
        for i=1:2  %could do this without for loop but this traps specific error
            try                                           %datetime  
                rangevar{i} = getdatevariable(Vin{i});   
            catch                                                  
               rangevar{i} = str2duration(Vin{i});    %duration
               if isempty(rangevar{1}) 
                    try   
                        if isempty(str2num(Vin{i})) %#ok<ST2NM> %returns empty if not numeric
                            rangevar(i) = Vin(i);         %categorical or text              
                        else                              %numeric
                            rangevar{i} = str2double(Vin{i});  
                        end
                    catch                                  
                        if isnan(rangevar{i}) 
                            %return erroneous text + message - should not get
                            %here since addition of categorical/text
                            msgbox(sprintf('%s Invald value. Please correct input', Vin{i}))
                            return
                        end
                    end
                end
            end
        end
    else    %use bounds to determine data type and unpack variables
        dtype = getdatatype(bounds);
        rangevar = setdatatype(Vin,dtype);
    end
    idx = regexp(rangetext,'F');
    pretext = strip(rangetext(1:idx-1)); %text that precedes 'From ....
end
%%
function datevar = getdatevariable(Vin)
    %extract a datetime variable checking for non-standard format
    %same function used in setdatatype
    [datebrk,matches] = strsplit(Vin,{'/','-',' '});
    if length(datebrk{2})==2 && length(datebrk{3})==4
        %this traps the format day-month-year that is not
        %recognised by datetime (does accept yyyy-mm-dd)
        fmt = ['dd',matches{1},'MM',matches{2},'yyyy',' HH:mm:ss'];
        datevar = datetime(char(Vin),'InputFormat',fmt);
    else
        datevar = datetime(char(Vin),'Format','preserveinput'); 
    end 
end
