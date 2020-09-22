function out = gallmAnalysis(userfilespec, Fs, numstart)
% Function out = gallmAnalysis(userfilespec, Fs)
% userfilespec is data from listentothis.m, e.g. 'EigenTest*.mat'
% Fs is the sample rate, usually 20kHz
% numstart is the first character of the hour. 

%% Setup

dataChans = [1 2]; % EOD recording channels in recorded files
rango = 10; % Hz around peak frequency over which to sum amplitude.

tempchan = 3; % Either 4 or 3
lightchan = 4; % Either 5 or 4

sampidx = 1:Fs*0.100; % Duration of sample (make sure integer!)
% So far either 0.050 or 0.100 has been best

[b,a] = butter(5, 200/(Fs/2), 'high'); % Filter to eliminate 60Hz contamination

iFiles = dir(userfilespec);

daycount = 0;

%% Cycle through every file in the directory

k = 1; % Our counter.

while k <= length(iFiles)

eval(['load ' iFiles(k).name]);

% Get EOD amplitudes for each channel
for j = length(dataChans):-1:1
    
    tmpsig = filtfilt(b,a,data(sampidx,dataChans(j)));
    tmp = fftmachine(tmpsig, Fs);
    [peakAmp(j), peakIDX] = max(tmp.fftdata);
    peakFreq(j) = tmp.fftfreq(peakIDX);
    sumAmp(j) = sum(tmp.fftdata(tmp.fftfreq > (peakFreq(j) - rango) & tmp.fftfreq < (peakFreq(j) + rango)));

    
    z = zeros(1,length(sampidx));
    z(tmpsig > 0) = 1;
    z = diff(z);
    posZs = find(z == 1);
    for kk = 2:length(posZs)
       amp(kk-1) = max(tmpsig(posZs(kk-1):posZs(kk))) + abs(min(tmpsig(posZs(kk-1):posZs(kk))));
    end
    
    zAmp(j) = mean(amp);
    
end

% Crappy coding... but why not!
    out(k).Ch1peakAmp = peakAmp(1);
    out(k).Ch1peakFreq = peakFreq(1);
    out(k).Ch1sumAmp = sumAmp(1);
    out(k).Ch2peakAmp = peakAmp(2);
    out(k).Ch2peakFreq = peakFreq(2);
    out(k).Ch2sumAmp = sumAmp(2);
%    out(k).Ch3peakAmp = peakAmp(3);
%    out(k).Ch3peakFreq = peakFreq(3);
%    out(k).Ch3sumAmp = sumAmp(3);
    out(k).Ch1zAmp = zAmp(1);
    out(k).Ch2zAmp = zAmp(2);

    out(k).light = mean(data(:,lightchan));
    out(k).temp = mean(data(:,tempchan));
    
% Add time stamps (in seconds) relative to computer midnight
    hour = str2num(iFiles(k).name(numstart:numstart+1));
    minute = str2num(iFiles(k).name(numstart+3:numstart+4));
    second = str2num(iFiles(k).name(numstart+6:numstart+7));

    if k > 1 && ((hour*60*60) + (minute*60) + second) < out(k-1).tim24
        daycount = daycount + 1;
    end
        % There are 86400 seconds in a day.
    out(k).timcont = (hour*60*60) + (minute*60) + second + (daycount*86400) ;
    out(k).tim24 = (hour*60*60) + (minute*60) + second;
    
    k = k+1;
    

end

%% Plot the data for fun

figure(1); clf; 
    set(gcf, 'Position', [200 100 2*560 2*420]);

ax(1) = subplot(411); hold on;
    plot([out.timcont]/(60*60), [out.Ch1sumAmp], '.');
    plot([out.timcont]/(60*60), [out.Ch2sumAmp], '.');
%    plot([out.timcont]/(60*60), [out.Ch3sumAmp], '.');

ax(2) = subplot(412); hold on;
    plot([out.timcont]/(60*60), [out.Ch1zAmp], '.');
    plot([out.timcont]/(60*60), [out.Ch2zAmp], '.');

ax(3) = subplot(413); hold on;
    yyaxis right; plot([out.timcont]/(60*60), -[out.temp], '.');
    yyaxis left; ylim([200 800]);
        plot([out.timcont]/(60*60), [out.Ch1peakFreq], '.', 'Markersize', 8);
        plot([out.timcont]/(60*60), [out.Ch2peakFreq], '.', 'Markersize', 8);
%        plot([out.timcont]/(60*60), [out.Ch3peakFreq], '.', 'Markersize', 8);
    
ax(4) = subplot(414); hold on;
    plot([out.timcont]/(60*60), [out.light], '.', 'Markersize', 8);
    ylim([-1, 6]);
    xlabel('Continuous');

linkaxes(ax, 'x');
    
figure(2); clf; 
    set(gcf, 'Position', [400 100 2*560 2*420]);

xa(1) = subplot(411); hold on;
    plot([out.tim24]/(60*60), [out.Ch1sumAmp], '.');
    plot([out.tim24]/(60*60), [out.Ch2sumAmp], '.');
%    plot([out.tim24]/(60*60), [out.Ch3sumAmp], '.');

xa(2) = subplot(412); hold on;
    plot([out.tim24]/(60*60), [out.Ch1zAmp], '.');
    plot([out.tim24]/(60*60), [out.Ch2zAmp], '.');

xa(3) = subplot(413); hold on;
    yyaxis right; plot([out.tim24]/(60*60), -[out.temp], '.');
    yyaxis left; ylim([200 800]);
        plot([out.tim24]/(60*60), [out.Ch1peakFreq], '.', 'Markersize', 8);
        plot([out.tim24]/(60*60), [out.Ch2peakFreq], '.', 'Markersize', 8);
%        plot([out.tim24]/(60*60), [out.Ch3peakFreq], '.', 'Markersize', 8);
    
xa(4) = subplot(414); hold on;
    plot([out.tim24]/(60*60), [out.light], '.', 'Markersize', 8);
    xlabel('24 Hour');
    ylim([-1, 6]);

linkaxes(xa, 'x');
