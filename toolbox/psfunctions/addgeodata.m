function addgeodata(cfig)
%
%-------function help------------------------------------------------------
% NAME
%   addgeodata.m
% PURPOSE
%   add data to an existing figure from a shape file, geospatial table file 
%   or raster image file
% USAGE
%   addgeodata; or addgeodata(cfig);
% INPUTS
%   cfig - handle to figure to modify (optional)
% OUTPUT
%   updated figure
% NOTE
%   adds 
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2025
%--------------------------------------------------------------------------
% 
    %check whether Mapping toolbox is available
    if nargin<1 || isempty(cfig)
        cfig = selectFigure; 
        if isempty(cfig), return; end
    end

    isok = license('test','MAP_Toolbox');   %toolbox is licensed to use
    if isok
        addons = matlab.addons.installedAddons;
        isok = any(matches(addons.Name,'Mapping Toolbox')); %toolbox is installed
    end
    
    if ~isok
        isok_m = isfile('m_shaperead'); %check if M-Map function is available instead
    end
    
    if ~isok && ~isok_m
        warndlg('Unable to read Shape file. Check that Mapping toolbox or M-Map is installed')
        return
    end

    %select data type to load Shape file  uses shaperead, Table uses
    %readgeotable and Raster uses readgeoraster
    promptxt = 'Load a shape file (*.shp), geospatial table () or raster (*.tiff)';
    answer = questdlg(promptxt,'GeoLoad','Shape','Table','Raster','Shape');
    switch answer
        case 'Shape'
            ftype = '*.shp;';
        case 'Table'
            ftype = '*.shp; *.json; *.geojson; *.gpx; *.kml; *.shp;';
        case 'Raster'
            ftype = '*.tiff;';
    end
    promptxt = 'Select image or shape file';
    [fname,fpath,~] = getfiles('PromptText',promptxt,'MultiSelect','off',...
                                                          'FileType',ftype);
    if isnumeric(fname) && fname==0, return; end
    
     switch answer
        case 'Shape'
            addShapeFile([fpath,fname],isok,cfig);
        case 'Table'
            warndlg('Not yet developed'); return;
            % addTableFile([fpath,fname],isok,cfig)
        case 'Raster'
            warndlg('Not yet developed'); return;
            % addRasterFile([fpath,fname],isok,cfig)
     end   
end
%%
function addShapeFile(filename,isok,cfig)
    %add shape file to current plot
    if isok
        Shp = shaperead(filename);   %requires Mapping toolbox
        ftypes = unique({Shp(:).Theme});
        idf = listdlg("PromptString",'Select themes to Exclude','Name','Themes',...
                      'SelectionMode','multiple','ListSize',[160,300],'ListString',ftypes);
        for i=1:length(idf)
            idx = strcmp({Shp(:).Theme},ftypes{idf(i)});
            Shp(idx) = [];
        end
    else
        shp = m_shaperead(filename); %not tested
        for i=1:length(shp.ncst)
            Shp(i).X = shp.ncst{i}(:,1); %#ok<AGROW>
            Shp(i).Y = shp.ncst{i}(:,2); %#ok<AGROW>
        end
    end
    nrec = length(Shp);
    figure(cfig);
    ax = gca;
    green = mcolor();
    hold on
    for i=1:nrec
        plot(ax,Shp(i).X,Shp(i).Y,'Color',green,'LineWidth',0.01)
    end
    hold off
end
%%
function addTableFile(filename,isok,cfig)
    %add data from geospatial table to current plot
    if isok
        Shp = readgeotable(filename);   %requires Mapping toolbox
    else
        shp = m_readgeotable(filename); %not tested
    end
    hfig = figure(cfig);
    ax = gca;
end
%%
function addRasterFile(filename,isok,cfig)
    %add data from geo referenced raster file to current plot
    if isok
        Shp = readgeoraster(filename);   %requires Mapping toolbox
    else
        shp = m_readgeoraster(filename); %not tested
    end
    hfig = figure(cfig);
    ax = gca;
end
%%
function cfig = selectFigure
    %prompt user to select a figure
    cfig = [];
    figs = findall(0,'type','figure');
    if isempty(figs), return; end
    fignums = sort([figs(:).Number]);
    if length(fignums)>1
        prmptxt = 'Select Figure Number:';                       
        hd = listdlg('PromptString',prmptxt,'ListString',string(fignums'),...
                     'ListSize',[100,200],'SelectionMode','single'); 
        if isempty(hd), return; end
    else
        hd = fignums;
    end
    
    cfig = figs(hd);
end