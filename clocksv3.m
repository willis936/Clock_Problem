%{
/*=======================================================================*/
/* AUTHOR:
 *      Paul Willis
 * DATE:
 *       2/ 7/2013
 *      12/20/2015
 * PURPOSE:
 *      This program calculates and prints approximate times at which the
 *      second, minute, and hour hands are all equal parts away from each
 *      other on a clock face.
 * INPUT:
 *      NONE
 * OUTPUT:
 *      Prints a greeting, pacifier, answer set, and farewell to the
 *      screen.
 *=======================================================================*/
%}
clear;close all force;clc;drawnow;tic;

tolerance = .001;
step = .1;

idx = 0:step:(43200 - step);

hrs = idx/3600;
min = mod(hrs,1)*60;
sec = mod(min,1)*60;

angle_hrs = abs(sin(hrs*pi));
angle_min = abs(sin(min*pi));
angle_sec = abs(sin(sec*pi));

% theta1 = angle_hrs - angle_min;
% theta2 = angle_min - angle_sec;
% theta3 = angle_sec - angle_hrs;

% cand1 = find(abs(angle_hrs - angle_min) < tolerance);
% cand2 = find(abs(angle_min - angle_sec) < tolerance);
% cand3 = find(abs(angle_sec - angle_hrs) < tolerance);

plot(hrs, abs(hrs/12 - sec/60),'g');
hold on;
plot(hrs, abs(min/60 - sec/60));
plot(hrs, abs(hrs/12 - min/60),'r');
stem(hrs(13022), .5, 'r*');
legend('abs(hrs-sec)', 'abs(min-sec)', 'abs(hrs-min)');

drawnow;
toc