function im = lab3()
% LAB3 skeleton file for doing color segmentation
%
%   im = LAB3() is called with no arguments, and returns the image 'im'
%
%   You will need to add the necessary code to implement color segmentation IAW
%   with the lab handout. 


% Set up the figure for streaming the image
close all;
% This implements the functionality of C's kbhit in Matlab.
% Note you need the associated my_kbhit.m file for this to work.
global kbhit;
kbhit = false;
figure('KeyPressFcn', @mykbhit);
% Create the image buffer.  Note im is a *color* buffer (3 channels)
im = zeros(480,640,3,'uint8');
% Get the handle for the image. We'll use this to update the figure
h_im = image(im);
% Make the axis equal and direction consistent
axis image;

% We'll do a hardware reset each time just in case... 
imaqreset();
% Create the camera in YUV colorspace. 
cam = videoinput('winvideo',1,'YUY2_640x480');
% Keep streaming images
cam.TriggerRepeat = Inf;
% Right now we're grabbing every third frame -> 10 Hz max frame rate
cam.FrameGrabInterval = 3;

% Start the camera
start(cam);

% Put this in a try-catch to ensure the camera is stopped. Otherwise, you
% may not be able to get the video object again if it's still in use without
% restarting Matlab. 
try    
    % Stream images until there is a keyboard press
    while ~kbhit
        % Get the image here (just 1)
        im = getdata(cam,1);

        % *** ADD YOUR CODE HERE ***
        % This is just to show an RGB image. You should comment this out as we
        % will be operating in YUV space
        %im = ycbcr2rgb(im);
        mask = roipoly(im);
        yim = im(:,:,1);
        uim = im(:,:,2);
        vim = im(:,:,3);
        
        meanArray = [mean(yim(mask)) mean(uim(mask)) mean(vim(mask))];
        covArray = cov([double(yim(mask)) double(uim(mask)) double(vim(mask))])
        disp(covArray);
        disp(meanArray);
        break;
        % More efficient to update the display this way
        set(h_im,'cdata',im);
        % Need this to flush the display for real-time updates
        drawnow;
    end 
% Something not quite right if the catch block is executed
catch
    warning('Some shoddy code was executed!');
end

% Stop the camera and cleanup
stop(cam);
delete(cam);

