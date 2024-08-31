function h = test_muitoolbox(classname)
%
%-------function help------------------------------------------------------
% NAME
%   test_muitoolbox.m
% PURPOSE
%   functions to test the abstract classes in the muitoolbox
% USAGE
%   test_muitoolbox('funcname',casenum,option);
%       e.g. test_muitoolbox('muiCatalogue');
% INPUT
%   classsname - name of muitoolbox or example class function to be tested

% OUTPUT
%   See in-code comments for details of test and in-code outputs.
%
% Author: Ian Townend
% CoastalSEA (c)Nov 2020
%--------------------------------------------------------------------------
%
    switch classname
        case 'muiProject'
            test_muiProject;
        case 'muiConstants'
            test_muiConstants;     
        case 'mui_demoPropsInput'  %test  data input using muiPropertyUI
            test_mui_demoPropsInput();
        case 'muiCatalogue'        %test assiging and accessing catalogue
            test_muiCatalogue();
        case 'mui_usage'           %test the usage of muitoolbox components
            h = test_mui_usage();    
    end
end
%%
function test_muiProject()
    %create and edit project settings
    muiproject = muiProject;
    editProject(muiproject);
end
%%
function test_muiConstants
    %create and edit Constants
    muiconstants = muiConstants.Evoke;
    setInput(muiconstants);
end
%%
function test_mui_demoPropsInput()
    %test the inheritance of muiPropertyUI when used to define some data
    %input. Note - only tests input not tab display.
    mobj.Inputs = [];    %dummy struct to represent Properties initialied
    mobj.TabProps = [];  %by the main UI when using muiModelUI.
    
    obj = mui_demoPropsInput.setInput(mobj);
    propstruct = getPropertiesStruct(obj);
    display(propstruct)
end
%%
function test_muiCatalogue()  %tested with code on 20Feb21
    %test setting up of a data set, accessing and deleting. 
    % mobj - instance of ModelUI with some data loaded
    obj = muiCatalogue;
    %set up dummy records
    addRecord(obj,'Class1','data',{'record 1'});
    addRecord(obj,'Class2','model',{'record 1'});
    addRecord(obj,'Class2','model',{'record 2'});
    dobj.CaseIndex = 1;    %CaseIndex used in getCase
    obj.DataSets.Class1 = dobj;
    dobj.CaseIndex = 2;
    obj.DataSets.Class2 = dobj;
    dobj.CaseIndex = 3;
    obj.DataSets.Class2(2) = dobj;
    %now use muiCatalogue functions to manipulate Cases
    casedef = getRecord(obj);
    display(casedef)
    
    [caserec,ok] = selectCase(obj,'single','Select case:',0);
    if ok<1, return; end
    [~,classrec,catrec] = getCase(obj,caserec);  %~ = cobj, class obj not used
    fprintf('Case %g: classrec=%g',caserec,classrec)
    display(catrec)
    [caserec,newdesc] = editRecord(obj,caserec);
    fprintf('Case %g: %s\n',caserec,newdesc{1})
    deleteCases(obj,caserec)    %delete specific case
    display(obj.Catalogue)
    deleteCases(obj)            %select and delete cases
    display(obj.Catalogue)
end
%%
function dm = test_mui_usage()
    %test components of the toolbox using a calling class    
    %initialise class that manages calls to models and data classes
    dm = mui_usage;
    %run model twice and load a data set
    run_a_model(dm);
    load_data(dm,'diffusion');
    run_a_model(dm);
    load_data(dm,'timeseries');
    %plot results
    plotCase(dm);
    %display DSproperties of a selected Case
    displayProps(dm);
end
%%
%--------------------------------------------------------------------------
%   Additional functions used by test functions
%--------------------------------------------------------------------------
%
