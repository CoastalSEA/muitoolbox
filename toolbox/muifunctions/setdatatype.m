function var = setdatatype(vtext,dtype)
%
%-------function help------------------------------------------------------
% NAME
%   setdatatype.m
% PURPOSE
%   set the data type of a text string, where the data type can be:
%       logical,integer,float,char,string,categorical,datetime,duration    
% USAGE
%   var = setdatatype(vtext,dtype)
% INPUT
%   vtext - char array or strings to be converted to a data type
%   dtype - data type of variable
% OUTPUT
%   var - variable converted from text string to date type defined by dtype
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------
%     
    nvar = length(vtext);
    %check there is a type for each variable
    if nvar~=length(dtype)  && ~strcmp(dtype{1},'categorical') && ...
                               ~strcmp(dtype{1},'ordinal')
        var = [];
        return; 
    end  
    
    var = cell(size(vtext));
    for i=1:nvar
        switch dtype{i}
            case 'logical'
                var{i} = logical(vtext{i});
            case 'int8'
                var{i} = int8(str2num(vtext{i})); %#ok<*ST2NM>
            case 'int16'
                var{i} = int16(str2num(vtext{i}));
            case 'int32'
                var{i} = int32(str2num(vtext{i}));
            case 'int64'
                var{i} = int64(str2num(vtext{i}));    
            case 'single'
                var{i} = single(str2num(vtext{i}));
            case 'double'
                var{i} = str2double(vtext{i});
            case 'char'
                var{i} = vtext{i};
            case 'string'
                var{i} = string(vtext{i});
            case 'categorical'
                var{i} = vtext{i}; %return as text string (need valueset to assign as category)
            case 'ordinal'
                var{i} = vtext{i}; %return as text string (need valueset to assign as ordinal)
            case 'datetime'
                var{i} = getdatevariable(vtext{i});
            case 'duration'
                var{i} = str2duration(vtext{i});
            otherwise
                var{i} = vtext{i};
        end
    end
end

%%
function datevar = getdatevariable(Vin)
    %extract a datetime variable checking for non-standard format
    %same function used in range2var
    [datebrk,matches] = strsplit(Vin,{'/','-',' '});
    if length(datebrk{2})==2 && length(datebrk{3})==4
        %this traps the format day-month-year that is not
        %recognised by datetime (does accept yyyy-mm-dd)
        fmt = ['dd',matches{1},'MM',matches{2},'yyyy',' HH:mm:ss'];
        datevar = datetime(char(Vin),'InputFormat',fmt);
        datevar.Format = fmt;
    else
        datevar = datetime(char(Vin),'Format','preserveinput'); 
    end 
end

