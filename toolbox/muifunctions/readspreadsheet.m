function datable = readspreadsheet(filename,isdst,cell_ids,promptxt)
%
%-------header-------------------------------------------------------------
% NAME
%   readspreadsheet.m
% PURPOSE
%   prompt user for selection on what to read from Excel spreadsheet and
%   load selected data as table or a dstable
% USAGE
%   datable = readspreadsheet(filename,isdst,cell_ids);
% INPUTS
%   filename - path and filename of spreadsheet to be read
%   isdst - return data in a dstable if true, and a table if false
%           (optional, default is false)
%   cell_ids - location of start cells in spreadsheet for variable names,
%           data and row names as character cell array (optional, default 
%           uses 'B1';'B2';'A2'). Use empty '' value if no variable names
%           or row names.
%   promptxt - prompt for selection of worksheet if more than one worksheet
% OUTPUT
%   datable - table of selected data
% NOTES
%   To omit Row Names, set Row names start cell to empty and adjust the
%   start cell of the variable names and data based on required data
%   If included, Row Names must use column before the data range
% Author: Ian Townend
% CoastalSEA (c) May 2024
%--------------------------------------------------------------------------
% 
    istime = false;
    if nargin<2
        isdst = false; 
        cell_ids = {'B1';'B2';'A2';'0'};
        promptxt = 'Select worksheet:';
    elseif nargin<3
        cell_ids = {'B1';'B2';'A2';'0'};
        promptxt = 'Select worksheet:';
    elseif nargin<4
        promptxt = 'Select worksheet:';
    end
    istime = logical(str2double(cell_ids{4}));
    cell_ids = cell_ids(1:3);

    snames = sheetnames(filename);
    if length(snames)>1
        %select worksheet if more more than one.
        selection = listdlg("ListString",snames,"PromptString",promptxt,...
                    'ListSize',[150,200],'Name','EDBimports','SelectionMode','single');
        if isempty(selection), return; end   %user cancelled
    else
        selection = 1;
    end

    opts = detectImportOptions(filename,'FileType','spreadsheet','Sheet',selection,...
                   'VariableNamesRange',cell_ids{1},...
                   'DataRange',cell_ids{2},'RowNamesRange',cell_ids{3});
    
    %prompt user to select data range, row range, etc
    promptxt = sprintf('Edit defaults to required variables and ranges\nTo omit Row Names, set Row names start cell to empty\nIf included Row Names must use column either side of the data range\n\nVariables to use:');
    promptxt = {promptxt,'Variable names start cell:','Data start cell:','Row names start cell:'};
    varnames = opts.VariableNames{1};
    for i=2:length(opts.VariableNames)
        varnames = sprintf('%s %s',varnames,opts.VariableNames{i});
    end
    defaults = [{varnames};cell_ids(:)];
    answers = inputdlg(promptxt,'Read spreadsheet',1,defaults);
    if isempty(answers), datable = []; return; end
    
    %assign start of variables range if known
    if isempty(opts.VariableNamesRange) && ~isempty(answers{2})
        opts.VariableNamesRange = answers{2};
    end
    
    %use response to amend the opts struct and read the data
    varnames = split(answers{1});
    if ~isempty(answers{4})
        %check if variable names start in same column as rownames and
        %whether the user has adjusted any padded values
        if strcmp(opts.VariableNamesRange(1),answers{4}(1)) && ...
                length(opts.VariableNames)==length(varnames)
            %rownames uses first column of values so trim variable names
            varnames = varnames(2:end);
        end
    end

    vartypes = opts.VariableTypes;
    idx = matches(opts.VariableNames,varnames);
    opts.VariableNames = opts.VariableNames(idx);
    opts.VariableTypes = vartypes(idx);
    opts.SelectedVariableNames = varnames';    
    opts.VariableNamesRange = answers{2};
    opts.DataRange = answers{3};
    opts.RowNamesRange = answers{4};

    if istime
        temp = readtimetable(filename,opts,'RowTimes','Date');
        rownames = temp.Properties.RowTimes;
        datable = timetable2table(temp,'ConvertRowTimes',false);
        clear temp
    else
        datable = readtable(filename,opts);
        rownames = datable.Properties.RowNames;
    end

    if isdst
        
        if isempty(rownames)
            datable = dstable(datable);
        else
            datable = dstable(datable,'RowNames',rownames);
        end
    end
end