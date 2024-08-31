function add_file_header
%
%-------function help------------------------------------------------------
% NAME
%   add_file_header.m
% PURPOSE
%   function to add the same header to batch of user selected files
% USAGE
%   add_file_header
% INPUTS
%   none
% OUTPUT
%   File(s) updated with defined file header
%
% Author: Ian Townend
% CoastalSEA (c)June 2020
%--------------------------------------------------------------------------

%get data from file
userprompt = 'Select data file(s)>';
[fname, path]=uigetfile('*.txt',userprompt,'MultiSelect','on');
if isequal(fname,0)
    return; 
elseif ischar(fname)
    fname = {fname};
end

% Define header to add to all files
header = '%{dd-MMM-yyyy}D %{HH:mm:ss}D %f %f';
width = 80;
height = 1; % lines in the edit field.
num_lines = [height, width];   
answer = inputdlg('Define required header format string:',...
                                            'Add header',num_lines,{header});                                
if isempty(answer), return; end
    
for kk = 1:numel(fname)
    % Read the file
    fid = fopen([path,fname{kk}],'r');
    data = textscan(fid,'%s','Delimiter','\n');
    fclose(fid); 
    
    %do things with the data
                                      
    data = [answer{1}; data{1}];    
    % Save as a text file
    fnam = sprintf('xyz_%s',fname{kk});
    fid = fopen([path,fnam],'w');
    fprintf(fid,'%s\n', data{:});
    fclose(fid);
end