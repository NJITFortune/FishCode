function [foo] = gallmanPostAnal(out)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

timstep = 5; % Step size of integration window in minutes
timwin = 30; % Time of integration window in minutes

%% Calculate our time window

startim = out(1).timcont;
endtim = out(end).timcont;

totaltim = endtim - startim;


% Smoothed trend line (20 minute duration window with 10 minute overlap)
for ttk = 1:floor(totaltim/(timstep*60))   % Every timwin minutes
    
    tt = find([out.timcont] > ((ttk-1)*timstep*60) & [out.timcont] < (((ttk-1)*timstep*60) + (timwin*60)) );
    
    foo.medianCh1sumAmp(ttk) = median([out(tt).Ch1obwAmp]); 
    foo.medianCh2sumAmp(ttk) = median([out(tt).Ch2obwAmp]);
    
    foo.medianCh1zAmp(ttk) = median([out(tt).Ch1zAmp]);
    foo.medianCh2zAmp(ttk) = median([out(tt).Ch2zAmp]);
    
    foo.mediantims(ttk) = (((ttk-1)*timstep*60) + (timstep*60));

end

figure(1); clf;

subplot(211); hold on;
    plot(foo.mediantims, foo.medianCh1zAmp, 'b-')
    plot(foo.mediantims, foo.medianCh2zAmp, 'r-')

subplot(212); hold on;
    plot(foo.mediantims, foo.medianCh1sumAmp, 'b-')
    plot(foo.mediantims, foo.medianCh2sumAmp, 'r-')

end

