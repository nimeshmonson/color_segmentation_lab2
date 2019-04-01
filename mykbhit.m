function mykbhit( src, event_data )
%
% MYKBHIT implements the functionality of kbhit in "C"
%
%   MY_KBHIT( src, event_data )
%
%   This must be used in conjunction with a figure object. You need to declare a 
%   global variable "kbhit" in the main program You also need to associate the 
%   function with keypresses to the active figure, i.e.,  
%
%   figure('KeyPressFcn', @mykbhit);
%
%   The arguments are passed automatically with the key press
%
% Copyright (C) by JRS @ Lehigh University
%

global kbhit;
kbhit = true;
