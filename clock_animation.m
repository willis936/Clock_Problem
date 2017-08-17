clear; close all; clc;
figure;
drawnow;

save_flag = 0;

% fullscreen the figure
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
step = 0.001;
idx = 10473.562:step:10475.561;

if save_flag
    f(length(idx)) = struct('cdata',[],'colormap',[]);
    v = VideoWriter('P:\clocks.mp4','MPEG-4');
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
    movefile('P:\clocks.mp4',pwd);
end
