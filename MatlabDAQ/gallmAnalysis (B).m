function out = gallmAnalysis(userfilespec, Fs, numstart)
% Function out = gallmAnalysis(userfilespec, Fs)
% userfilespec is data from listentothis.m, e.g. 'EigenTest*.mat'
% Fs is the sample rate, was 20kHz but now 40kHz
% numstart is the first character of the hour. 

%% Setup

dataChans = [1 2]; % EOD recording channels in recorded files
rango = 10; % Hz around peak frequency over which to sum amplitude.

tempchan = 3; % Either 4 or 3
lightchan = 4; % Either 5 or 4

% THIS IS IMPORTANT USER DEFINED DETAILS (ddellayy, windw, highp, lowp)
    % Delay (currently 0 seconds from start)
    ddellayy = 0;
    % Window width (Empirically either 0.050 or 0.100 have been best)
    windw = 0.1;
    
    startidx = max([1, (ddellayy * Fs)]); % In case we want to start before 0 (max avoids zero problem)
    endidx = (windw * Fs) + startidx;
    sampidx = startidx:endidx; % Duration of sample (make sure integer!)

    % High pass filter cutoff frequency
    highp = 200;
    % Low pass filter cutoff frequency
    lowp = 2000;
    
    [b,a] = butter(7, highp/(Fs/2), 'high'); % Filter to eliminate 60Hz contamination
    [f,e] = butter(7, lowp/(Fs/2), 'low'); % Filter to eliminate high frequency contamination

iFiles = dir(userfilespec);

daycount = 0;

%% Cycle through every file in the directory

k = 1; % Our counter.

while k <= length(iFiles)

eval(['load ' iFiles(k).name]);

% Get EOD amplitudes for each channel
for j = length(dataChans):-1:1

% ORIGINAL FFT METHOD - sumAmp
    tmpfft = fftmachine(data(sampidx,dataChans(j)), Fs);
    [peakAmp(j), peakIDX] = max(tmpfft.fftdata);
    peakFreq(j) = tmpfft.fftfreq(peakIDX);
    sumAmp(j) = sum(tmpfft.fftdata(tmpfft.fftfreq > (peakFreq(j) - rango) & tmpfft.fftfreq < (peakFreq(j) + rango)));

% NEW FFT METHOD - obwAmp

[~,~,~,obwAmp(j)] = obw(data(sampidx,dataChans(j)), Fs, [200 700]);

    tmpsig = filtfilt(b,a,data(sampidx,dataChans(j))); % High pass filter
    tmpsig = filtfilt(f,e,tmpsig); % Low pass filter    

% Mean amplitude method
    z = zeros(1,length(sampidx)); %creat vector length of data
    z(tmpsig > 0) = 1; %fill with 1s for all filtered data greater than 0
    z = diff(z); %subtract the X(2) - X(1) to find the positive zero crossings
    
    posZs = find(z == 1); 
    
    for kk = 2:length(posZs)
       amp(kk-1) = max(tmpsig(posZs(kk-1):posZs(kk))) - (min(tmpsig(posZs(kk-1):posZs(kk)))); % Max + min of signal for each cycle
    end
    
    zAmp(j) = mean(amp);
    
end

% Crappy coding... but why not!
    out(k).Ch1peakAmp = peakAmp(1);
    out(k).Ch1peakFreq = peakFreq(1);
    out(k).Ch1sumAmp = sumAmp(1);
    out(k).Ch1obwAmp = obwAmp(1);
    out(k).Ch2peakAmp = peakAmp(2);
    out(k).Ch2peakFreq = peakFreq(2);
    out(k).Ch2sumAmp = sumAmp(2);
    out(k).Ch2obwAmp = obwAmp(2);
    out(k).Ch1zAmp = zAmp(1);
    out(k).Ch2zAmp = zAmp(2);

    out(k).light = mean(data(:,lightchan));
    out(k).temp = mean(data(:,tempchan));
    
% Add time stamps (in seconds) relative to computer midnight
    hour = str2num(iFiles(k).name(numstart:numstart+1)); %numstart based on time stamp text location
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

% Continuous data plot
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
    
% 24-hour data plot
figure(2); clf; 
    set(gcf, 'Position', [400 100 2*560 2*420]);

% Smoothed trend line (20 minute duration window with 10 minute overlap)
for ttk = 1:143   
    tt = find([out.tim24] > ((ttk-1)*10*60) & [out.tim24] < (((ttk-1)*10*60) + (20*60)) );
    meanCh1sumAmp(ttk) = mean([out(tt).Ch1obwAmp]); %huh? %is this just a quick way to replace one with the other?
    meanCh2sumAmp(ttk) = mean([out(tt).Ch2obwAmp]);
    meanCh1zAmp(ttk) = mean([out(tt).Ch1zAmp]);
    meanCh2zAmp(ttk) = mean([out(tt).Ch2zAmp]);
    meantims(ttk) = (((ttk-1)*10*60) + (10*60));
end

xa(1) = subplot(411); hold on;
    plot([out.tim24]/(60*60), [out.Ch1obwAmp], '.');
    plot([out.tim24]/(60*60), [out.Ch2obwAmp], '.');
%    plot([out.tim24]/(60*60), [out.Ch3sumAmp], '.');
    plot(meantims/(60*60), meanCh1sumAmp, 'c-', 'Linewidth', 2);
    plot(meantims/(60*60), meanCh2sumAmp, 'm-', 'Linewidth', 2);

xa(2) = subplot(412); hold on;
    plot([out.tim24]/(60*60), [out.Ch1zAmp], '.');
    plot([out.tim24]/(60*60), [out.Ch2zAmp], '.');
    plot(meantims/(60*60), meanCh1zAmp, 'c-', 'Linewidth', 2);
    plot(meantims/(60*60), meanCh2zAmp, 'm-', 'Linewidth', 2);

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

% Light / Dark plot

figure(3); clf;
set(gcf, 'Position', [400 100 2*560 2*420]);

    ld = [out.light];
    ldOnOff = diff(ld);
    tim = [out.timcont];
    dat1 = [out.Ch1obwAmp];
    dat2 = [out.Ch2obwAmp];
    
    Ons = find(ldOnOff > 1); % lights turned on
    Offs = find(ldOnOff < -1); % lights turned on

subplot(411); hold on; subplot(412); hold on;   
    for j = 2:length(Ons) % Synchronize at light on
    subplot(411);
        plot(tim(Ons(j-1):Ons(j))-tim(Ons(j-1)), dat1(Ons(j-1):Ons(j)), '.');
        plot(tim(Ons(j-1):Ons(j))-tim(Ons(j-1)), dat2(Ons(j-1):Ons(j)), '.');
    subplot(412);
        plot(tim(Ons(j-1):Ons(j))-tim(Ons(j-1)), ld(Ons(j-1):Ons(j)), '.');
    end

subplot(413); hold on; subplot(414); hold on;   
    for j = 2:length(Offs) % Synchronize at light off
    subplot(413);
        plot(tim(Offs(j-1):Offs(j))-tim(Offs(j-1)), dat1(Offs(j-1):Offs(j)), '.');
        plot(tim(Offs(j-1):Offs(j))-tim(Offs(j-1)), dat2(Offs(j-1):Offs(j)), '.');
    subplot(414);
        plot(tim(Offs(j-1):Offs(j))-tim(Offs(j-1)), ld(Offs(j-1):Offs(j)), '.');
    end

    
% Detrend the data

resampFs = 0.005; % May need to change this
cutfreq = 0.00001; % Low pass filter for detrend - need to adjust re resampFs

    [dat1r, newtim] = resample(dat1, tim, resampFs);
    [dat2r, ~] = resample(dat2, tim, resampFs);
    [ldr, ~] = resample(ld, tim, resampFs);

    [h,g] = butter(5,cutfreq/(resampFs/2),'low');
    
    % Filter the data
    dat1rlf = filtfilt(h,g,dat1r);
    dat2rlf = filtfilt(h,g,dat2r);

    % Remove the low frequency information
    datrend1 = dat1r-dat1rlf;
    datrend2 = dat2r-dat2rlf;
    
figure(4); clf;
set(gcf, 'Position', [400 100 2*560 2*420]);

subplot(611); hold on; subplot(612); hold on;   subplot(613); hold on;
    for j = 2:length(Ons) % Synchronize at light on
        
    ttOn = find(newtim > tim(Ons(j-1)) & newtim < tim(Ons(j)));
        
    subplot(611);
        plot(newtim(ttOn)-newtim(ttOn(1)), datrend1(ttOn), '.');
    subplot(612);
        plot(newtim(ttOn)-newtim(ttOn(1)), datrend2(ttOn), '.');
    subplot(613);
        plot(newtim(ttOn)-newtim(ttOn(1)), ldr(ttOn), '.');
    end

subplot(614); hold on; subplot(615); hold on; subplot(616); hold on;
    for j = 2:length(Offs) % Synchronize at light off
        
    ttOff = find(newtim > tim(Offs(j-1)) & newtim < tim(Offs(j)));
        
    subplot(614);
        plot(newtim(ttOff)-newtim(ttOff(1)), datrend1(ttOff), '.');
    subplot(615);
        plot(newtim(ttOff)-newtim(ttOff(1)), datrend2(ttOff), '.');
    subplot(616);
        plot(newtim(ttOff)-newtim(ttOff(1)), ldr(ttOff), '.');
    end

    
% Continuous data plot with OBW
figure(5); clf; 
    set(gcf, 'Position', [200 100 2*560 2*420]);

ax(1) = subplot(411); hold on;
    plot([out.timcont]/(60*60), [out.Ch1obwAmp], '.');
    plot([out.timcont]/(60*60), [out.Ch2obwAmp], '.');
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

    
