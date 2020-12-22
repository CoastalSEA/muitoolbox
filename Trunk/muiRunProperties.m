classdef muiRunProperties < handle
    
    %SHOULD THIS JUST BE A PROPERTY IN dscollection?
    
    %class to handle input data passed to a class that loads a dscollection
    %class. For data this is typically just the file name but could include
    %other metadata. For models this is the input data including: 
    %       input data caseid
    %       input data filename (in case data instance is deleted)
    %       input variables
    %       model version number
    %       model run date
    properties (Transient)
        RunProps
    end
    
    methods
        function obj = muiRunProperties
            obj.RunProps = struct('inpcid',[],'inpfname',[],'inpvar',[],...
                                       'vNum',[],'runDate',[]);
        end      
%%
        function set.RunProps(obj,props)
            %create a struct to hold variables and meta-data that defines
            %the model run. props is a partial RunProps struct 
            props.runDate = datetime('now');
            obj.RunProps = props;
        end
%%        
        function runprops = get.RunProps(obj)
            runprops = obj.RunProps;
        end
    end    
end

%props needs to include handle to model, input classes, input data cid and file name