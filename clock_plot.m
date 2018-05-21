function clock_plot(time)
% plot a clock from time in seconds since 12:00:00

r = 0.9;
hrs = mod(time / (60*60*12), 60*60*12);
mns = mod(time / (60*60),    60*60);
sec = mod(time /  60,        60);

% prepare figure
init_flag = strcmp(get(gca,'Tag'),'clock_plot');
if ~init_flag
    hold on;
    axis off;
    pbaspect([1 1 1]);
    set(gca, 'Tag', 'clock_plot');
end
cla;

% plot clock hands
xhrs = -r*cos(2*pi*hrs+pi/2);
yhrs =  r*sin(2*pi*hrs+pi/2);
xmns = -r*cos(2*pi*mns+pi/2);
ymns =  r*sin(2*pi*mns+pi/2);
xsec = -r*cos(2*pi*sec+pi/2);
ysec =  r*sin(2*pi*sec+pi/2);
hhrs = plot([0 xhrs], [0 yhrs], 'r-');
hmns = plot([0 xmns], [0 ymns], 'g-');
hsec = plot([0 xsec], [0 ysec], 'b-');

if ~init_flag
    legend([hhrs hmns hsec], {'hours','minutes','seconds'}, ...
        'Location', 'NorthWest', 'AutoUpdate','off');
end

% plot clock face
plot(r*cos(0:pi/200:2*pi), r*sin(0:pi/200:2*pi), 'k-', 'LineWidth', 1);
for i = 1:12
    plot([0 -r*cos(2*pi*mod(i,12)/12+pi/2)], [0 r*sin(2*pi*mod(i,12)/12+pi/2)], 'k:', 'LineWidth', 0.25);
    text(-1.05*r*cos(2*pi*mod(i,12)/12+pi/2), 1.05*r*sin(2*pi*mod(i,12)/12+pi/2), num2str(i), 'FontWeight', 'Bold');
end

% plot area triangle
A = 1/2*abs(sin(2*pi*(sec-mns)) + sin(2*pi*(hrs-sec)) - sin(2*pi*(hrs-mns)));
plot([xhrs xmns], [yhrs ymns], 'm-');
plot([xmns xsec], [ymns ysec], 'm-');
plot([xsec xhrs], [ysec yhrs], 'm-');

% print out some info about the clock
thetahm = mod(360*abs(hrs-mns),360);
if thetahm > 180;
    thetahm = 360 - thetahm;
end
thetams = mod(360*abs(mns-mod(sec,1)),360);
if thetams > 180;
    thetams = 360 - thetams;
end
thetash = mod(360*abs(mod(sec,1)-hrs),360);
if thetash > 180;
    thetash = 360 - thetash;
end
text(0.70,0.95,['t = ' sprintf('%.3f', time) ' s'], 'FontName', 'FixedWidth');
text(0.70,0.90,['\Theta_h_m = ' sprintf('%.3f%c', thetahm, char(176))], 'FontName', 'FixedWidth');
text(0.70,0.85,['\Theta_m_s = ' sprintf('%.3f%c', thetams, char(176))], 'FontName', 'FixedWidth');
text(0.70,0.80,['\Theta_s_h = ' sprintf('%.3f%c', thetash, char(176))], 'FontName', 'FixedWidth');
%text(0.70,0.75,['A = ' sprintf('%.6f', A) ' u^2'], 'FontName', 'FixedWidth');
text(0.70,0.75,['A = ' sprintf('%.6f', A/(3*sqrt(3)/4)*100) ' %'], 'FontName', 'FixedWidth');

drawnow;
drawnow;
