function datable = readspreadsheet(filename,isdst)
%
%-------header-------------------------------------------------------------
% NAME
%   readspreadsheet.m
% PURPOSE
%   prompt user for selection on what to read from Excel spreadsheet and
%   load selected data as table or a dstable
% USAGE
%   datable = readspreadsheet(filename,isdst)
% INPUTS
%   filename - path and filename of spreadsheet to be read
%   isdst - return data in a dstable if true, and a table if false
%           (optional, default is false)
% OUTPUT
%   datable - table of selected data
% NOTES
%   To omit Row Names, set Row names start cell to empty
%   If included Row Names must use first or last column of the data range.
% Author: Ian Townend
% CoastalSEA (c) May 2024
%--------------------------------------------------------------------------
% 
    if nargin<2, isdst = false; end

    snames = sheetnames(filename);
    if length(snames)>1
        %select worksheet if more more than one.
        selection = listdlg("ListString",snames,"PromptString",'Select worksheet:',...
                    'ListSize',[150,200],'Name','EDBimports','SelectionMode','single');
    else
        selection = 1;
    end
    opts = detectImportOptions(filename,'FileType','spreadsheet','Sheet',selection);
    
    %prompt user to select data range, row range, etc
    promptxt = sprintf('Edit defaults to required variables and ranges\nTo omit Row Names, set Row names start cell to empty\nIf included Row Names must use first or last column of the data range\n\nVariables to use:');
    promptxt = {promptxt,'Variable names start cell:','Data start cell:','Row names start cell:'};
    varnames = opts.VariableNames{1};
    for i=2:length(opts.VariableNames)
        varnames = sprintf('%s %s',varnames,opts.VariableNames{i});
    end
    defaults = {varnames;'B1';'B2';'A2'};
    answers = inputdlg(promptxt,'Read spreadsheet',1,defaults);
    if isempty(answers), datable = []; return; end
    
    %use repsonse to amend the opts struct and read the data
    varnames = split(answers{1});
    vartypes = opts.VariableTypes;
    idx = ismatch(opts.VariableNames,varnames);
    opts.VariableNames = opts.VariableNames(idx);
    opts.VariableTypes = vartypes(idx);
    opts.SelectedVariableNames = varnames';    
    opts.VariableNamesRange = answers{2};
    opts.DataRange = answers{3};
    opts.RowNamesRange = answers{4};
    datable = readtable(filename,opts);

    if isdst
        rownames = datable.Properties.RowNames;
        if isempty(rownames)
            datable = dstable(datable);
        else
            datable = dstable(datable,'RowNames',rownames);
        end
    end
end