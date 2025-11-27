function type_plot(mobj)                       
%
%-------function help------------------------------------------------------
% NAME
%   type_plot.m
% PURPOSE
%   bar plot of variable against table rows, with bars shaded to reflect a
%   classification variable (e.g. Type)
% USAGE
%   type_plot(mobj)
% INPUTS
%   mobj - ModelUI instance - variable selection is for instances of
%   the muiTableImport class
% OUTPUT
%   type plot of selected variables
% SEE ALSO
%   TableViewer and tableviewer_user_tools.m, EstuaryDB and edb_user_tools.m
%
% Author: Ian Townend
% CoastalSEA (c) Nov 2024
%--------------------------------------------------------------------------
%
    promptxt = 'Select Case to plot';
    [cobj,~,datasets,idd] = selectCaseDataset(mobj.Cases,[],{'muiTableImport'},promptxt);
    if isempty(cobj), return; end
    dst = cobj.Data.(datasets{idd});  %selected dataset
    promptxt = 'Select Variable to plot:'; 
    [~,idv] = selectAttribute(dst,1,promptxt); %1 - select a variable
    if isempty(idv), return; end

    [ax,idx,ids] = userPlot(cobj,mobj,idd,idv); %idx sort order of x-variable if a scalarplot
                                           %ids indices of selected sub-set (after sorting)                                           

    %select variable to use for classification (restrict to selection from
    %same case but allow different dataset to be used
    if length(mobj.Cases.DataSets.muiTableImport)>1
        prmptxt = 'Select case to use for type classificaton';
        cobj = selectCaseObj(mobj.Cases,[],{'muiTableImport'},prmptxt);
    end
    promptxt = 'Select type classification variable:'; 
    datasetname = getDataSetName(cobj,promptxt); 
    classdst = cobj.Data.(datasetname);    
    [varname,idc] = selectAttribute(classdst,1,promptxt); %1 - select a variable
    if isempty(idc), return; end
    vardesc = classdst.VariableDescriptions{idc};
    typevar = classdst.(varname); 
    typevar = typevar(idx); %if sorted in userPlot ensure same order

    if isnumeric(typevar)
        %find set of unique index values
        types = unique(typevar);
    elseif iscategorical(typevar)
        types = categories(typevar);
    elseif ischar(typevar{1}) || isstring(typevar{1})
        %if char or string convert to categorical and ordinal
        typevar = categorical(typevar);    
        types = categories(typevar);
    end
    ntypes = length(types);

    typevar = typevar(ids); 

    %amend X-ticks if too many labels to fit easily
    if length(ax.Children.XData)>50
        nvar = length(ax.Children.XData);
        promptxt = sprintf('%d X-tick labels. Replace with integers?',nvar);
        answer = questdlg(promptxt,'Type plot','Yes','No','Yes');
        if strcmp(answer,'Yes')
            nint = 10;
            ints = 0:nint:nvar; ints(1) = 1;
            ax.XTick = num2ruler(ints,ax.XAxis);
            ax.XTickLabel =  ints;
            ax.XAxis.TickDirection = 'out';
        end
    end

    %set color map to identify each type
    mycolormap = cmap_selection();  %prompts user to select a colormap
    ncolor = size(mycolormap,1);
    %subsample the colormap for the number of types required
    custom_colormap = colormap(mycolormap(1:round(ncolor/ntypes):ncolor,:));

    %adjust bar face color to class colors    
    hb = findobj(ax.Children,'Type','bar');
    hb.FaceColor = 'flat';
    for k = 1:length(typevar)
        %assign color to variable bar based on typevar
        hb.CData(k,:) = custom_colormap(types==typevar(k),:);
    end
    cb = colorbar;
    cb.Ticks = (0.5:1:length(types)-0.5)/ntypes;
    if isnumeric(types)
        cb.TickLabels = num2str(types);  %unique index numbers
    else
        cb.TickLabels = types;           %categories
    end

    %add label above colorbar so it does not disappear off side of figure
    cb.Label.String = vardesc;  %add variable description to colorbar
    cb.Label.Rotation = 0;      % Set rotation to 0 degrees
    cb.Label.Position = [0.5, 1.05]; % Adjust position to be above the colorbar
    cb.Label.VerticalAlignment = 'bottom'; % Align the label vertically
    cb.Label.HorizontalAlignment = 'left';
end