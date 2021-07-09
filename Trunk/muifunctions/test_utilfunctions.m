function test_utilfunctions(func,caseid)
%
%-------function help------------------------------------------------------
% NAME
%   test_utilfunctions.m
% PURPOSE
%   functions to test utility functions
% USAGE
%   test_utilfunctions(<functionname>,caseid)
% INPUT
%   func - name of function as a character vector or string
%   caseid - test option to run - only used for some functions
% OUTPUT
%   runs test code for requested function
% NOTES
%   
% 
% Author: Ian Townend
% CoastalSEA (c)Sept 2020
%--------------------------------------------------------------------------
%
    switch func
        case 'str2duration'
            test_str2dur
        case 'var2range'
            test_var2range
        case 'range2var'
            test_range2var
        case 'getdatatype'
            test_getdatatype
        case 'setdatatype'
            test_setdatatype    
        case 'isvalidrange'
            test_ValidRange
        case 'editrange'
            test_getwidget(caseid)
        case 'getwidget'
            test_getwidget(caseid)
        case 'tablefigure'
            test_tablefigure(caseid)
        case 'cellstruct2cell'
            test_cellstruct2cell(caseid)
        case 'mcolor'
            test_mcolor
    end
end
%%
function test_str2dur()
    %   str2duration.m
    %   convert a string created from a duration back to a duration
    strvar = string(years(21.4));
    durvar1 = str2duration(strvar);     %string created from duration
    durvar2 = str2duration(strvar,'y'); %string with defined format
    durvar3 = str2duration('21.4');     %invalid string - no format defined  
    fprintf('out1=%s out2=%s out3=%s and warning box\n',durvar1,durvar2,durvar3)
end
%%
function test_var2range
    %   var2range.m
    %   convert start and end variable to a range character array
    rangevar = [1,100];
    pretext = 'Case1: ';
    rangetext1 = var2range(rangevar,pretext);  %integer values with pretext
    rangetext2 = var2range(rangevar);          %integer values no pretext
    fprintf(' %s\n %s\n',rangetext1,rangetext2);
    
    rangevar = categorical({'S1','S2'},'Ordinal',true); 
    rangetext = var2range(rangevar);           %categorical values
    fprintf(' %s\n',rangetext);
    
    rangevar = [datetime('12-Aug-2020'),datetime('18-Aug-2020')];    
    rangetext1 = var2range(rangevar);          %datetime values
    rangevar = [years(33.45);years(37.8)];
    rangetext2 = var2range(rangevar);          %duration values
    fprintf(' %s\n %s\n',rangetext1,rangetext2);
end
%%
function test_range2var
    %   range2var.m
    %   convert range character array start and end variables
    %Case 1: numeric
    rangetext = var2range([1,100]);
    rangevar = range2var(rangetext);
    fprintf(' var1: %g var2: %g\n',rangevar{1},rangevar{2});
    %Case 2: categorical
    rangetext = var2range(categorical({'S1','S2'},'Ordinal',true));
    rangevar = range2var(rangetext);
    fprintf(' var1: %s var2: %s\n',rangevar{1},rangevar{2});
    %Case 3: datetime
    rangetext = var2range([datetime('12-Aug-2020'),datetime('18-Aug-2020')]);
    rangevar = range2var(rangetext);
    fprintf(' var1: %s var2: %s\n',rangevar{1},rangevar{2});
    %Case 4: duration
    rangetext = var2range([years(33.45);years(37.8)]);
    rangevar = range2var(rangetext);
    fprintf(' var1: %s var2: %s\n',rangevar{1},rangevar{2});    
end
%%
function test_getdatatype()
    %   getdatatype.m
    %   find the data type of 'var'
    %single variable calls
    dtype(1) = getdatatype(true);
    dtype(2) = getdatatype(int8(1));
    dtype(3) = getdatatype(5.99);
    dtype(4) = getdatatype('isachar');
    dtype(5) = getdatatype("isastring");
    dtype(6) = getdatatype(categorical({'S1'},'Ordinal',true));
    dtype(7) = getdatatype(datetime('12-Aug-2020'));
    dtype(8) = getdatatype(years(33.45));
    output = cell2table(dtype');
    display(output);
    %cell array of variables of different type
    var = {true,int8(1),5.99,'isachar',"isastring",categorical({'S1'}),...
           datetime('12-Aug-2020'),years(33.45)};
    dtype = getdatatype(var);
    output = cell2table(dtype');
    display(output);
end
%%
function test_setdatatype
    %   setdatatype.m
    %   set the data type of a text string
    dtype = {'logical','int16','double','char','string','categorical',...
             'datetime','duration'};
    vtext = {'1','1','5.99','isachar','isastring','S1','12-Aug-2020','33.45 yrs'};
    var = setdatatype(vtext,dtype);
    output = cell2table(var');
    display(output);
end
%%
function test_ValidRange()
    %   checkValidRange.m
    %   check user input is a valid date string for use in 'dformat'
    dstart = datetime('12-Aug-2020');
    dend = datetime('20-Aug-2020');
    %check valid datetime range
    call_isValidRange(dstart,dend,1)
    %check invalid datetime range
    call_isValidRange(dend,dstart,2);
    %check valid duration range
    dstart = years(33.45);
    dend = years(37.8);
    call_isValidRange(dstart,dend,3);
    %check valid numeric range
    dstart = 0;
    dend = 100;
    call_isValidRange(dstart,dend,4);
    %check valid ordinal range
    valueset = {'S1','S2','S3','S4','S5'};
    catvar = categorical({'S1','S5'},valueset,'Ordinal',true);
    call_isValidRange(catvar(1),catvar(2),5);
    %
    function call_isValidRange(dstart,dend,runid)
        isvalid  = isvalidrange({dstart,dend});
        fprintf('Case %u: %g\n',runid,isvalid)
    end
end
%%
function test_getwidget(caseid)
    hfig = figure;
    hfig.Unit = 'normalized';
    switch caseid
        case 1  %input datetime
            dstart = datetime('12-Aug-2020');
            dend = datetime('20-Aug-2020');
            rangevars = {dstart,dend};  
            pretext = 'Test 1:';
        case 2  %input duration
            dstart = years(33.45);
            dend = years(37.8);
            rangevars = {dstart,dend}; 
            pretext = 'Test 2:';
        case 3  %input numeric
            dstart = 0;
            dend = 100;
            rangevars ={dstart,dend};
            pretext = 'Test 3:';
        case 4  %input categorical
            valueset = {'S1','S2','S3','S4','S5'};
            catvar = categorical({'S1','S5'},valueset,'Ordinal',true);
            dstart = catvar(1);
            dend = catvar(2);
            rangevars = {dstart,dend};   
            pretext = 'Test 4:';
        case 5  %input text string
            dstart = "start";
            dend = "end";
            rangevars = {dstart,dend}; 
            pretext = 'Test 5:';
    end
    %
    settings.InputFields = {'var1'};      %text prompt for input field to be displayed
    settings.Style = {'text'};            %uicontrols for each input field (same no. as input fields)
    rangetext = var2range(rangevars,pretext); 
    if caseid==4, rangevars=categorical(valueset,'Ordinal',true); end
    settings.DefaultInputs = {rangetext}; %default text or selection lists
    settings.UserData = {rangevars};        %used to define bounds
    settings.ControlButtons = {'Ev'};     %text for buttons to edit or update selection
    widgetpos.height = 0.4;               %vertical position from bottom
    widgetpos.pos4 = 0.04;                %botton height
    getwidget(hfig,settings,widgetpos,1)
end
%%
function test_tablefigure(option)
    %test generation of a tablefigure using table or     
    msg1 = sprintf('RMI = mean/(mean+st.dev) = %.2f',0.5);
    msg2 = sprintf('CVI = coefficient of variation = %.2f',0.8555);
    msg3 = sprintf('BVI = beach vulnerability index (based on Alexandrakis et al) = %.2f',0.0001);
    msg = sprintf('%s\n%s\n%s',msg1,msg2,msg3);    
    bvitable = table([1;1;1],[2;2;2],[3;3;3],[4;4;4],[5;5;5],...
           'VariableNames',{'Drift','Xshore','Runup','Shoreline','Index'});
       switch option
           case 'table'
               tablefigure('BVI output',msg,bvitable);
           case 'var'
               rownames = {'Index 1','Index 2','Index 3'};
               varnames = {'Drift','Xshore','Runup','Shoreline','Index'};
               data = table2cell(bvitable);
               tablefigure('Title','Descriptive text',rownames,varnames,data);
           case 'tab'
               h_fig = figure('Name','DSproperties','Tag','TableFig',...
                   'MenuBar','none','Visible','off');
               
               h_tab = uitabgroup(h_fig,'Tag','uiTabs');
               uitab(h_tab,'Title','  Rows  ','Tag','Rows');
               tablefigure(h_fig,msg,bvitable);
               
               varpos = findobj(h_tab,'Tag','TableFig_panel');
               width = varpos.Position(3)*1.1;
               height = varpos.Position(4)*2.5;
               h_fig.Position(3) = width;
               h_fig.Position(4) = height;
               h_fig.Visible = 'on';
       end
end
%%
function test_cellstruct2cell(option)
    %create a struct of cell arrays and convert to a cell array
    fnames = {'Name','Description','Unit','Label','QCflag'};
    instruct = struct(fnames{1},[],fnames{2},[],fnames{3},[],...
                fnames{4},[],fnames{5},[]);     
    switch option
        case 1  %struct of {1,3} cell arrays
            instruct.Name = {'var1','var2','var3'};
            instruct.Description = {'Variable 1','Variable 2','Variable 3'};
            instruct.Unit = {'m2','m3','m'};
            instruct.Label = {'Area','Volume','Length'};
            instruct.QCflag = {'raw','-','model'};
            %this is the same as:
                % instruct = struct('Name',{{'var1','var2','var3'}},...
                %    'Description',{{'Variable 1','Variable 2','Variable 3'}},...
                %    'Unit',{{'m2','m3','m'}},...
                %    'Label',{{'Area','Volume','Length'}},...
                %    'QCflag',{{'raw','-','model'}}); 
            %however row,column order matters in cellstruct2cell and the
                %following syntax results in an error:
                % instruct.Name = {'var1';'var2';'var3'};
                % instruct.Description = {'Variable 1';'Variable 2';'Variable 3'};
                % instruct.Unit = {'m2';'m3';'m'};
                % instruct.Label = {'Area';'Volume';'Length'};
                % instruct.QCflag = {'raw';'-';'model'};            
        case 2  %struct with mix of {1,3} cell arrays and [1,3] string arrays
            instruct.Name = ["var1","var2","var3"];
            instruct.Description = {'Variable 1','Variable 2','Variable 3'};
            instruct.Unit = ["m2","m3","m"];
            instruct.Label = {'Area','Volume','Length'};
            instruct.QCflag = {'raw','-','model'};
        case 3  %struct of character vectors - defines a struct array directly                             
            ndimstruct = struct('Name',{'var1','var2','var3'},...
               'Description',{'Variable 1','Variable 2','Variable 3'},...
               'Unit',{'m2','m3','m'},...
               'Label',{'Area','Volume','Length'},...
               'QCflag',{'raw','-','model'}); 
            %this is the same as: 
                % incell = {'var1','var2','var3';
                %          'Variable 1','Variable 2','Variable 3';
                %           'm2','m3','m';
                %           'Area','Volume','Length';
                %           'raw','-','model'};
                % instruct = cell2struct(incell,fnames,1);
            
            %convert struct array to struct of cell arrays
            for i=1:length(fnames)
                instruct.(fnames{i}) = {ndimstruct.(fnames{i})};
            end
        case 4  %incomplete struct definition
            instruct.Name = {'var1','var2','var3'};
            instruct.Description = {'Variable 1','Variable 2','Variable 3'};
            instruct.Unit = {'m2','m3','m'};
        case 5  %missing columns in array definition
            instruct.Name = {'var1','var2','var3'};
            instruct.Description = {'Variable 1','Variable 2','Variable 3'};
            instruct.Unit = {'m2','m'};   %missing value
            instruct.Label = {'Area','Volume','Length'};
            instruct.QCflag = {'raw','-','model'};
        case 6   %incomplete struct array definition 
            instruct = struct('Name',{'var1','var2','var3'},...
                'Description',{'Variable 1','Variable 2','Variable 3'},...
                'Unit',{'m2','m3','m'});
            fnames = fieldnames(instruct);
        case 7   %missing columns in struct array definition 
                 %error message in Command Window
            instruct = struct('Name',{'var1','var2','var3'},...
                'Description',{'Variable 1','Variable 2','Variable 3'},...
                'Unit',{'m2','m'},...      %missing value
                'Label',{'Area','Volume','Length'},...
                'QCflag',{'raw','-','model'}); 
        case 8
            instruct.Name = {'var1'};
            instruct.Description = {'Variable 1'};
            instruct.Unit = {'m2'};
            instruct.Label = {'Area'};
            instruct.QCflag = {'raw'};
         case 9
            instruct.Name = 'var1';
            instruct.Description = 'Variable 1';
            instruct.Unit = 'm2';
            instruct.Label = 'Area';
            instruct.QCflag = 'raw';              
    end

%     outcell = cellstruct2cell(instruct)
    
%     if ~isempty(outcell)
%         %convert cell array to struct with 1 x n cell array or string array
%         for i=1:length(fnames)
%             outstruct_ca.(fnames{i}) = outcell(i,:);
%         end
%         
%         %convert cell array to 1 x n struct array
%         %if mix of string array and cell array, a string array is returned    
%         outcell = convertStringsToChars(outcell);     %convert to cell array
%         %convert to n x 1 struct
%         dim = 1;
%         ndim = size(outcell,dim);
%         if ndim==length(fnames)
%             outstruct = cell2struct(outcell,fnames,1)' %#ok<*NOPRT>
%         else
%             warndlg('Number of rows in cell array does not match number of fields');
%         end        
%     end
    
    %alternatively call cellstruct2structarray directly
    outstruct = cellstruct2structarray(instruct)   %#ok<NOPRT>
end
%%
function test_mcolor()
    %   mcolor.m
    %   select a default Matlab color definition from table
    ac1 = mcolor(3);            %call using index
    ac2 = mcolor('yellow');     %call using string
    ac3 = mcolor(10);           %invalid index - out of range
    fprintf(' out1=[%.3f %.3f %.3f]\n out2=[%.3f %.3f %.3f]\n out3=[%s] and warning box\n',ac1,ac2,ac3)
end

