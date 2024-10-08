function saveanimation2file(ModelMovie,~,~)
%
%-------function help------------------------------------------------------
% NAME
%   saveanimation2file.m
% PURPOSE
%   saves movie to selected file type (mp4, avi or gif)
% USAGE
%   saveanimation2file(MovieModel,~,~)
% INPUTS
%   MovieModel - movie object created using getframe function
%   ~ are for src and event properties for when used as a callback function
% OUTPUT
%   saves movie to selected file type
% NOTES
%   thanks to Kenta (2022) for movie2gif int he Matlab File Forum
% SEE ALSO
%   used in muiPlots and Asmita Saltmarsh CSThydraulics and River classes
%
% Author: Ian Townend
% CoastalSEA (c) Jan 2021
%--------------------------------------------------------------------------
%        
    answer = questdlg('Save as which file type?','Save animation',...
                      'MPEG-4','AVI','GIF','MPEG-4');
    
    %set up inputs based on user selection and get output file name
    if strcmp(answer,'GIF')        
        movie2gif(ModelMovie);
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
%%
function movie2gif(MovieObj)
    extension = '*.gif';
    ftext = 'muimovie.gif';
    [file,path] = uiputfile(extension,'Save file as',ftext);
    if file==0, return; end
    filename = [path,file];
    %based on code from Matlab Forum, see:
    %Kenta (2022). movie2gif
    %https://github.com/KentaItakura/movie2gif-using-MATLAB/releases/tag/1.0  
    %GitHub. Retrieved February 9, 2022.
    % |DelayTime| represents delay before displaying next image, in seconds
    % A value of |0| displays images as fast as your hardware allows.
    %DelayTime=0.5;
    % The video frame is used for gif for every "|rate|" frames. For example, if 
    % you set at 2, the second, forth, sixth, eighth, ... frames are saved as gif. 
    % Increasing this parameter decreases the file size of the gif. 
    %rate=1;
    spec = inputdlg({'Delay before displaying next image','Sampling rate'},...
                     'Save animations',1,{'0.5','1'}); 
    if isempty(spec), return; end                          
    DelayTime = str2double(spec{1});
    rate = str2double(spec{2});
    
    idx=1;
    for i=1:length(MovieObj)
        im = frame2im(MovieObj(i));
        if mod(idx,rate)==0
            [A,map] = rgb2ind(im,256);
            if idx == 1
                imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',DelayTime)
            else
                imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',DelayTime);
            end
        end
        idx=idx+1;
    end
end