function newtable = matrixtableUI(figtitle,promptxt,colnames,inpmatrix)
%
%-------function help------------------------------------------------------
% NAME
%   matrixtableUI.m
% PURPOSE
%   generate UI to edit a matrix using tablefigureUI
% USAGE
%   newtable = matrixtableUI(figtitle,promptxt,colnames,inpmatrix);
% INPUT
%   figtitle - title of the UI figure
%   promptxt - descriptive text that preceeds table used to prompt user
%   colnames - cell array of column names
%   inpmatrix - data to be used to populate the table
% OUTPUT
%   newtable - table with any changes made to inpmatrix data
% SEE ALSO
%   tablefigureUI.m, tablefigure.m and tabtablefigure.m. Used in Asmita
%
% Author: Ian Townend
% CoastalSEA (c)Oct 2021
%--------------------------------------------------------------------------
%
    data = num2cell(inpmatrix,1);
    rownames = colnames;
    oldtable = table(data{:},'RowNames',rownames,'VariableNames', colnames); 
    but.Text = {'Save','Cancel'}; %labels for tab button definition
    newtable = tablefigureUI(figtitle,promptxt,oldtable,true,but,[0.1,0.6]);
    if isempty(newtable), newtable = oldtable; return; end  
end