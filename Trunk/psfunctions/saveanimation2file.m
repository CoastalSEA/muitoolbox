function saveanimation2file(ModelMovie,~,~)
%
%-------function help------------------------------------------------------
% NAME
%   saveanimation2file.m
% PURPOSE
%   saves movie to selected file type
% USAGE
%   saveanimation2file(MovieModel,~,~)
% INPUTS
%   MovieModel - movie object created using getframe function
%   ~ are for src and event properties for when used as a callback function
% OUTPUT
%   saves movie to selected file type
% NOTES
%   
% SEE ALSO
%   used in muiPlots and Asmita Saltmarsh CSThydraulics and River classes
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
%        
    answer = questdlg('Save as which file type?','Save animation',...
                      'MPEG-4','AVI','Quit','MPEG-4');
    
    %set up inputs based on user selection and get output file name
    if strcmp(answer,'Quit')
        return;
    elseif strcmp(answer,'MPEG-4')
        extension = '*.mp4';
        ftext = 'muimovie.mp4';
        profile = answer;
    else
        extension = '*.avi';
        ftext = 'muimovie.avi';
        profile = 'Uncompressed AVI';
    end
    [file,path] = uiputfile(extension,'Save file as',ftext);
    if file==0, return; end
    
    %initialise the video writer class
    v = VideoWriter([path,file],profile);
    if strcmp(answer,'MPEG-4')
        spec = inputdlg({'Frame rate (fps):','Quality:'},'Save animations',...
                         1,{num2str(v.FrameRate),num2str(v.Quality)});
    else
        spec = inputdlg({'Frame rate (fps):'},'Save animations',...
                         1,{num2str(v.FrameRate)});
                     
    end
    %update if changed
    if ~isempty(spec)
        v.FrameRate = str2double(spec{1});
        if strcmp(answer,'MPEG-4')
            v.Quality = str2double(spec{2});
        end
    end
    
    %write movie to file
    open(v);            
    warning('off','MATLAB:audiovideo:VideoWriter:mp4FramePadded')
    writeVideo(v,ModelMovie);
    warning('on','MATLAB:audiovideo:VideoWriter:mp4FramePadded')
    close(v);
end