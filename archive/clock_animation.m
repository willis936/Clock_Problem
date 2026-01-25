clear; close all; clc;
figure;
drawnow;

save_flag = true;
fn = sprintf('%s_clocks',datestr(datetime,'yyyymmdd_HHMMSS'));
ramdrive = 'P:';

% fullscreen the figure
%%{
robot = java.awt.Robot; 
robot.keyPress(java.awt.event.KeyEvent.VK_ALT);      %// send ALT
robot.keyPress(java.awt.event.KeyEvent.VK_SPACE);    %// send SPACE
robot.keyRelease(java.awt.event.KeyEvent.VK_SPACE);  %// release SPACE
robot.keyRelease(java.awt.event.KeyEvent.VK_ALT);    %// release ALT
robot.keyPress(java.awt.event.KeyEvent.VK_X);        %// send X
robot.keyRelease(java.awt.event.KeyEvent.VK_X);      %// release X
drawnow;
drawnow;
pause(0.1);
%}

% best candidate 1 minute
%step = 0.001;
%idx = 10473.562:step:10475.561;

% best candidate 6 seconds
step = 0.001;
idx = 10474.3815:step:10474.7415;

% full 12 hours in 5 ish seconds
%step = 151;
%idx = 0:step:43200;

if save_flag
    f(length(idx)) = struct('cdata',[],'colormap',[]);
    v = VideoWriter(fullfile(ramdrive,fn),'MPEG-4');
    v.FrameRate = 60;
    open(v);
end

for i = idx
    clock_plot(i);
    if save_flag
        writeVideo(v,getframe);
    end
end

if save_flag
    close(v);
    pause(0.1);
    movefile(sprintf('%s.mp4',fullfile(ramdrive,fn)),pwd);
end
