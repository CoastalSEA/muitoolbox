function metatxt = get_selection_text(props,option,pretxt)
%
%-------function help------------------------------------------------------
% NAME
%   get_selection_text.m
% PURPOSE
%   generate text to summarise the selection made from a data ui using
%   properties that are defined in muiCatalogue.getProperty
% USAGE
%   var = get_selection_text(props,option,pretxt)
% INPUTS
%   props - struct of data and metadata for selected variables.  
%           struct is as used in muiCatalogue.getProperty with fields describing selection:
%           case, dset, desc, label, data, dvals
%   option - format of output (see below)
%   pretxt - text to use instead of attribute name at start of text string (optional)
% OUTPUT
%   metatxt - defines any subselection of rows and dimensions, options:  
%             0: case, dataset > case (dset)
%             1: case, dataset, variable > case (dset) Var
%             2: variable and dimensions short> Var(dim1,dim2,...)
%             3: variable and dimensions, define scalar > Var(dim1,dim2:value,dim3:value, etc)
%             4: variable and dimensions, define all > Var:range(dim1:range,dim2:value,dim3:value, etc)
%             5: combine options 1 and 3 > case(dset)Var(Dim1,Dim2:value,Dim3:value, etc)
%             6: combine options 1 and 4 > case(dset)Var:range(Dim1:range,Dim2:value,Dim3:value, etc)
% NOTES
%   used to set a full definition of the selection
%   modification of label and desc for any scaling should be done before
%   calling get_selection_text
% SEE ALSO
%   called from get_variable, get_selection, muiPlots
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
%            
    if nargin<3
        pretxt = [];
    end
    casetxt = sprintf('%s (%s)',props.case,props.dset);
    switch option
        case 0                              %format: Case(Dataset)
            metatxt = casetxt;
        case 1                              %format: Case(Dataset)Var
            metatxt = sprintf('%s %s',casetxt,props.desc);
        case 2                              %format: Var(Dim1,Dim2,etc)
            metatxt = setSummaryDims(props);
        case 3                              %format: Var(Dim1,Dim2:value,Dim3:value, etc)
            metatxt = setDimsTextShort(props);            
        case 4                              %format: Var:range(Dim1:range,Dim2:value,Dim3:value, etc)
            metatxt = setDimsTextLong(props);
        case 5                              %format: Case(Dataset)Var(Dim1,Dim2:value,Dim3:value, etc)
            metatxt = setDimsTextShort(props);
            metatxt = sprintf('%s: %s',casetxt,metatxt);
        case 6                              %format: Case(Dataset)Var:range(Dim1:range,Dim2:value,Dim3:value, etc)
            metatxt = setDimsTextLong(props);
            metatxt = sprintf('%s: %s',casetxt,metatxt);
        otherwise
            warndlg('Specified option not recognised in get_selection_text')
            metatxt = [];
    end   
    %add any prefix text if included in input
    if ~isempty(pretxt)
        metatxt = sprintf('%s: %s',pretxt,metatxt);
    end
end
%%
function proptxt = getPropRangeText(props)
    %extract the attribute description and range
    proptxt = struct('desc','','range','');
    %attribute lists for variable, exclude any unused dimensions - see
    %muiCatalogue.getProperty and dstable.getVatAttributes
    attdesc = props.attribs.desc;  %may need to change this to labels in getProperty
    dimvals = props.dvals;
    if isempty(dimvals)
        proptxt.desc = props.desc;
        proptxt.range = getDimensionText(props.data);
        proptxt.isvec = true;
    else
        for i=1:length(attdesc)        
            proptxt(i).desc = attdesc{i};
            if i==1
                proptxt(i).range = dimvals.var;
                offset = 1;
            elseif i==2
                proptxt(i).range = dimvals.row;
                offset = 2;
            else
                proptxt(i).range = dimvals.dim{i-offset};
            end   
            proptxt(i).range = getDimensionText(proptxt(i).range);
            proptxt(i).isvec = contains(proptxt(i).range,'From');
        end
    end
end
%%
function dimstxt = setSummaryDims(props)
    %set variable and dimensions text using just attribute names
    %format: Var(Dim1,Dim2,etc)
    attdesc = props.attribs.desc;  %may need to change this to labels in getProperty
    dimstxt = sprintf('%s (',attdesc{1});
    for i=2:length(attdesc)
        dimstxt = sprintf('%s%s, ',dimstxt,attdesc{i});
    end
    dimstxt = sprintf('%s)',dimstxt(1:end-2));
end
%%
function dimstxt = setDimsTextShort(props)
    %set dimensions text with format: Var(Dim1,Dim2:value,Dim3:value, etc)
    ptxt = getPropRangeText(props);
    isvec = find([ptxt(:).isvec]);
    isnot = find(~[ptxt(:).isvec]);
    initxt = sprintf('%s (',ptxt(1).desc);  %variable
    
    for j=2:length(isvec)                   %dimensions with a range
        initxt = sprintf('%s%s, ',initxt,ptxt(j).desc);
    end
    
    for k=1:length(isnot)                   %scalar dimenion selections
        if k==1
            subtxt = sprintf('%s: %s',ptxt(isnot(k)).desc,ptxt(isnot(k)).range);
        else
            subtxt = sprintf('%s, %s: %s',subtxt,ptxt(isnot(k)).desc,ptxt(isnot(k)).range);
        end
    end

    if isempty(props.dvals)
        dimstxt = sprintf('%s',initxt(1:end-2));
    elseif isempty(isnot)
        dimstxt = sprintf('%s)',initxt(1:end-2));
    else
        dimstxt = sprintf('%s, %s)',initxt(1:end-2),subtxt);
    end
end
%%
function dimstxt = setDimsTextLong(props)
    %set dimensions text with format:  Var:range(Dim1:range,Dim2:value,Dim3:value, etc)
    ptxt = getPropRangeText(props);
    isvec = find([ptxt(:).isvec]);
    isnot = find(~[ptxt(:).isvec]);
    initxt = sprintf('%s: %s (',ptxt(1).desc,ptxt(1).range);  %variable
    
    for j=2:length(isvec)                   %dimensions with a range
        initxt = sprintf('%s%s: %s, ',initxt,ptxt(j).desc,ptxt(j).range);
    end
    
    for k=1:length(isnot)                   %scalar dimenion selections
        if k==1
            subtxt = sprintf('%s: %s',ptxt(isnot(k)).desc,ptxt(isnot(k)).range);
        else
            subtxt = sprintf('%s, %s: %s',subtxt,ptxt(isnot(k)).desc,ptxt(isnot(k)).range);
        end
    end

    if isempty(props.dvals)
        dimstxt = sprintf('%s',initxt(1:end-2));
    elseif isempty(isnot)
        dimstxt = sprintf('%s)',initxt(1:end-2));
    else
        dimstxt = sprintf('%s, %s)',initxt(1:end-2),subtxt);
    end
end
%%
function dimtxt = getDimensionText(var)
    if length(var)>1 && ~ischar(var)
        dimtxt = var2range(var); 
    else
        dimcell = var2str(var); %returns a cell character vector
        dimtxt = dimcell{1};
    end
end

