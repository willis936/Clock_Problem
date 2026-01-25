%% calculation
close all;clear;clc;drawnow;drawnow;
tic;

% enabling this will give accurate but very slow results
flag_symbolic = true;
% changing this adjusts final answer precision
max_digits = 20;

fprintf('%s\n',datestr(datetime));

% check if quad precision is available
if flag_symbolic && exist('mp', 'class')
    mp.Digits(max_digits);
    n_guard = 20;
    mp.GuardDigits(n_guard);
    min_step = mp('eps');
    %min_step = mp(power(mp('10'),-(max_digits)));
    fprintf('Using Multiprecision Computing Toolbox to %d digits with %d guard digits.\n', max_digits, n_guard);
    quad_flag = 1;
    symb_flag = 0;
elseif flag_symbolic && license('test','Symbolic_Toolbox')
    fprintf('Multiprecision Computing Toolbox not installed.\n');
    fprintf('Using Symbolic Math Toolbox to %d digits.\n', max_digits);
    digits(max_digits);
    min_step = vpa(power(10,-max_digits));
    quad_flag = 0;
    symb_flag = 1;
else
    fprintf('Using double precision.\n');
    max_digits = floor(-log10(eps));
    min_step = power(10,-(max_digits+1));
    quad_flag = 0;
    symb_flag = 0;
end

precision = 2;
step = 1*power(10,-precision);
s = 0:step:60*60*12-step;
%{
ds = 1/ 60       *mod(s,60);
dm = 1/(60*60)   *mod(s,60*60);
dh = 1/(60*60*12)*mod(s,60*60*12);
eqn1 = mod(abs(ds - dm),1);
eqn2 = mod(abs(dm - dh),1);
eqn3 = mod(abs(dh - ds),1);

%% plotting
close all; drawnow;
idx_n = 0;
idx_plot = (idx_n*60*60)/step+1:(idx_n+1)*60*60/step;

figure;
plot(s(idx_plot),ds(idx_plot));
hold on;
plot(s(idx_plot),dm(idx_plot));
plot(s(idx_plot),dh(idx_plot));
xlim([s(idx_plot(1)) s(idx_plot(end))]);
legend('degs','degm','degh');
title('Angles');
xlabel('Seconds');
ylabel('Distance');
drawnow;

figure;
plot(s(idx_plot),eqn1(idx_plot));
hold on;
plot(s(idx_plot),eqn2(idx_plot));
plot(s(idx_plot),eqn3(idx_plot));
xlim([s(idx_plot(1)) s(idx_plot(end))]);
legend('eqn1','eqn2','eqn3');
title('Absolute Distance Differences');
xlabel('Seconds');
ylabel('Distance');
line([s(idx_plot(1)) s(idx_plot(end))], [1/3 1/3]);
%line([idx_plot(1) idx_plot(end)], [240 240]);
drawnow;
%}

%% some other stuff

hrs = [0 0 1 1 2 2 3 3 4 5 5 6 6 7 8 8 9 9 10 10 11 11];
mns = [21 43 27 49 32 54 37 59 44 5 49 10 54 15 0 22 5 27 10 33 16 38];
sec = [42.203363 23.898265 47.816412 29.624455 53.240601 35.048662 58.474538 40.169449 4.172462 45.980487 9.596629 51.355904 14.745745 56.440670 20.528510 2.336535 25.932177 7.627071 31.016931 13.268381 36.884541 18.692588];
time = hrs*60*60 + mns*60 + sec;
%time_diff = [time(1:end) 0] - [0 time(1:end)];
%time_diff = time_diff(1:end-1);
diff_time = diff(time);
%{
% plot gaps between times
figure;stem(diff_time);xlim([1 length(time)-1]);
%figure;plot(diff_time(1:2:end));xlim([1 (length(diff_time)-1)/2]);
%figure;plot(diff_time(2:2:end));xlim([1 (length(diff_time)-1)/2]);
drawnow;
%}
%{
% symbolic toolbox approach.  doesn't yield a pretty solution.
syms t
ft = 1/2*abs(sin(pi*59*t/1800) + sin(-pi*719*t/21600) - sin(-pi*11*t/21600));
[solt, param, cond] = solve(ft == sqrt(3)*3/4, 'ReturnConditions', true);
%g = diff(ft, t);
g = ((59*pi*cos((59*pi*t)/1800))/1800 + (11*pi*cos((11*pi*t)/21600))/21600 - (719*pi*cos((719*pi*t)/21600))/21600)/2;
solg = solve(g == 0, t > 1301, t < 1302, t, 'MaxDegree', 4);
extrema = vpa(solg, 6);
%%{
assume(cond);
interval = [solt > 0, solt < 43200];
solk = solve(interval, param);
if ~isempty(solk.k)
    valx = subs(solt, param, solk);
end
%}

%% equilateral triangle

% http://www.math-only-math.com/area-of-the-triangle-formed-by-three-co-ordinate-points.html
% A = 1/2 | r? r? sin (?? – ??) + r? r? sin (?? - ??) - r? r? sin (?? - ??) |
%A = 1/2*abs(sin(2*pi*hrs-2*pi*min) + sin (2*pi*sec-2*pi*hrs) - sin(2*pi*sec-2*pi*min));
A = 1/2*abs(sin(pi*59*s/1800) + sin(-pi*719*s/21600) - sin(-pi*11*s/21600));
%A_diff = ((sin(pi*11*s/21600) + sin(-pi*719*s)))
[pks,locs] = findpeaks(A,'MinPeakProminence',sqrt(3)*3/4-750e-6);
%%{
figure;plot(s,A);xlim([s(1) s(end)]);
hold on;
line([s(1) s(end)], [sqrt(3)*3/4 sqrt(3)*3/4]);
stem(time,sqrt(3)*3/4*ones(1,length(time)));
stem(s(locs),pks);
xlabel('seconds');
ylabel('Area');
drawnow;
%}

%%{

pks_precise = zeros(1,length(locs));
res_precise = s(locs);

precise_precision = precision + 1;
step_precise = power(10,-precise_precision);
while step_precise > min_step
    if quad_flag
        step_precise = mp(1*power(10,-precise_precision));
        res_precise  = mp(res_precise);
        k1 =  mp('pi *  59 /  1800');
        k2 = -mp('pi * 719 / 21600');
        k3 =  mp('pi *  11 / 21600');
    elseif symb_flag
        step_precise = vpa(1*power(10,-precise_precision));
        res_precise  = vpa(res_precise);
        k1 =  vpa(pi) *  vpa(59) /  vpa(1800);
        k2 = -vpa(pi) * vpa(719) / vpa(21600);
        k3 =  vpa(pi) *  vpa(11) / vpa(21600);
    else
        step_precise = 1*power(10,-precise_precision);
        k1 =  pi *  59 /  1800;
        k2 = -pi * 719 / 21600;
        k3 =  pi *  11 / 21600;
    end
    for idx = 1:length(res_precise)
        if quad_flag
            s_precise = res_precise(idx)-step_precise*mp('99'):step_precise:res_precise(idx)+step_precise*mp('100');
        elseif symb_flag
            s_precise = res_precise(idx)-step_precise*vpa(99):step_precise:res_precise(idx)+step_precise*vpa(100);
        else
            s_precise = res_precise(idx)-step_precise*99:step_precise:res_precise(idx)+step_precise*100;
        end
        
        A_precise = sin(k1*s_precise) + sin(k2*s_precise) + sin(k3*s_precise);
        
        if A_precise < 0
            [pks_precise(idx),res_precise(idx)] = min(A_precise);
            pks_precise(idx) = -pks_precise(idx);
        else
            [pks_precise(idx),res_precise(idx)] = max(A_precise);
        end
        if quad_flag
            pks_precise(idx) =  mp(0.5) * pks_precise(idx);
            res_precise(idx) = round(s_precise(res_precise(idx))/step_precise)*step_precise;
        elseif symb_flag
            pks_precise(idx) = vpa(0.5) * pks_precise(idx);
            res_precise(idx) = s_precise(res_precise(idx));
        else
            pks_precise(idx) =     0.5  * pks_precise(idx);
            res_precise(idx) = round(s_precise(res_precise(idx))/step_precise)*step_precise;
        end
    end
    precise_precision = precise_precision + 1;
end
precise_precision = precise_precision - 1;

%{
figure;
stem(pks_precise - sqrt(3)*3/4);
ylabel('sqrt(3)*3/4 - A');
xlabel('Solution candidate number');
xlim([1 length(pks_precise)]);
drawnow;

figure;
stem(diff(res_precise));
xlabel('Solution candidate number');
ylabel('Time between solution candidates');
xlim([1 length(res_precise)-1]);
drawnow;
%}

for idx = 1:length(res_precise)
    if symb_flag
        if mod(res_precise(idx),60) < 10
            fprintf('%2d: %2s:%02s:0%s\n', ...
            idx, char(floor(mod(res_precise(idx)/60/60+11,12)+1)), ...
            char(floor(mod(res_precise(idx)/60,60))), char(mod(res_precise(idx),60)));
        else
            fprintf('%2d: %2s:%02s:%s\n', ...
            idx, char(floor(mod(res_precise(idx)/60/60+11,12)+1)), ...
            char(floor(mod(res_precise(idx)/60,60))), char(mod(res_precise(idx),60)));
        end
    else
        fprintf(['%2d: %2s:%02s:%0' sprintf('%d.%d',max_digits+3,max_digits) 'f\n'], ...
            idx, char(floor(mod(res_precise(idx)/60/60+11,12)+1)), ...
            char(floor(mod(res_precise(idx)/60,60))), char(mod(res_precise(idx),60)));
    end
    drawnow;
end
%}

dt = toc;
fprintf('Program ran in %.3f ms.\n', dt*1e3);
