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
%try    
    % Stream images until there is a keyboard press
    while ~kbhit
        % Get the image here (just 1)
        im = getdata(cam,1);

        % *** ADD YOUR CODE HERE ***
        % This is just to show an RGB image. You should comment this out as we
        % will be operating in YUV space
        %im = ycbcr2rgb(im);

        % More efficient to update the display this way
        set(h_im,'cdata',im);
        % Need this to flush the display for real-time updates
        drawnow;   
    end 
    mask = roipoly(im);
    
    yim = im(:,:,1);
    uim = im(:,:,2);
    vim = im(:,:,3);

    meanArray = [mean(yim(mask)) mean(uim(mask)) mean(vim(mask))];
    covArray = cov([double(yim(mask)) double(uim(mask)) double(vim(mask))]);
    disp(covArray);
    disp(meanArray);
    
    %Creating the box model
    ystd = sqrt(covArray(1));
    ustd = sqrt(covArray(5));
    vstd = sqrt(covArray(9));
    
    boxModelY = (im(:,:,1) > meanArray(1) - 2*ystd & im(:,:,1) < meanArray(1) + 2*ystd); 
    boxModelU = (im(:,:,2) > meanArray(2) - 2*ustd & im(:,:,2) < meanArray(2) + 2*ustd);
    boxModelV = (im(:,:,3) > meanArray(3) - 2*vstd & im(:,:,3) < meanArray(3) + 2*vstd);
    boxModel = boxModelY & boxModelU & boxModelV;
    
    
    %creating the Mahalobonis Model
    pixelArray = im;
    invCovArray = inv(covArray);
    pixelArrayY = pixelArray(:,:,1) - meanArray(1);
    pixelArrayU = pixelArray(:,:,2) - meanArray(2);
    pixelArrayV = pixelArray(:,:,3) - meanArray(3);
    
    mahalobonisModel = invCovArray(2,2).*pixelArrayU.^2 + 2.*invCovArray(2,3).*pixelArrayU.*pixelArrayV + 2.*invCovArray(1,2).*pixelArrayU.*pixelArrayY + invCovArray(3,3).*pixelArrayV.^2 + 2.*invCovArray(1,3).*pixelArrayV.*pixelArrayY + invCovArray(1,1).*pixelArrayY.^2;
    
    mahalobonisModel = mahalobonisModel < 16;
    
    
    %implementing a tracker
    im = zeros(480,640,3,'uint8');
    % Get the handle for the image. We'll use this to update the figure
    h_im = image(im);
    kbhit = false;
    while ~kbhit
        im = getdata(cam,1);
        
        %boxModelY = (im(:,:,1) > meanArray(1) - 2*ystd & im(:,:,1) < meanArray(1) + 2*ystd); 
        %boxModelU = (im(:,:,2) > meanArray(2) - 2*ustd & im(:,:,2) < meanArray(2) + 2*ustd);
        %boxModelV = (im(:,:,3) > meanArray(3) - 2*vstd & im(:,:,3) < meanArray(3) + 2*vstd);
        %boxModel = boxModelY & boxModelU & boxModelV;
        
        pixelArray = im;
        invCovArray = inv(covArray);
        pixelArrayY = pixelArray(:,:,1) - meanArray(1);
        pixelArrayU = pixelArray(:,:,2) - meanArray(2);
        pixelArrayV = pixelArray(:,:,3) - meanArray(3);
    
        mahalobonisModel = invCovArray(2,2).*pixelArrayU.^2 + 2.*invCovArray(2,3).*pixelArrayU.*pixelArrayV + 2.*invCovArray(1,2).*pixelArrayU.*pixelArrayY + invCovArray(3,3).*pixelArrayV.^2 + 2.*invCovArray(1,3).*pixelArrayV.*pixelArrayY + invCovArray(1,1).*pixelArrayY.^2;
    
        mahalobonisModel = mahalobonisModel < 9;
        
        %CC = bwconncomp(boxModel);
        CC = bwconncomp(mahalobonisModel);
        regionProp = regionprops(CC, 'BoundingBox');
        if (numel(regionProp) ~= 0)
            box = regionProp(1).BoundingBox;
            rect=rectangle('Position', box,'EdgeColor','r','LineWidth',2 );
        end
        
        set(h_im,'cdata',im);
        %imagesc(boxModel);
        %Need this to flush the display for real-time updates
        drawnow;
        delete(rect);
    end
    
    
    
% Something not quite right if the catch block is executed
%catch
%    warning('Some shoddy code was executed!');
%end

% Stop the camera and cleanup
stop(cam);
delete(cam);