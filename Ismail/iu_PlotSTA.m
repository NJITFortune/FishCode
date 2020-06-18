function asdf = iu_PlotSTA(data, entry, tims)
% function asdf = iu_PlotSTA(data, entry, tims)
% Plots spike triggered averages
% asdf is our output structure (not set at the moment)
% data is ismail
% entry is the index for ismail, e.g. 3 for ismail(3)
% tims are the start and end times, e.g. [30 60] would be between 30 and 60 seconds

% Plot spike triggered averages for error_pos, error_vel, error_acc, and error_jerk
% Load data first! Relies on iu_sta.m

entry=1;
%startim = 0;
%endtim = 30;

spks = data(1).spikes.times(data(1).spikes.times > tims(0) & data(1).spikes.times < tims(30));
rspks = data(1).spikes_rand.times(data(1).spikes_rand.times > tims(0) & data(1).spikes_rand.times < tims(30));


asdf  = 0;
% k=1% Entry number
% startim = 0;
% endtim = 90;
% % Load your data first (downsampled_data.mat)
% 


% spks = spikes.times(spikes.times > startim & spikes.times < endtim);
% rspks = spikes_rand.times(spikes_rand.times > endtim & spikes_rand.times < startim);

% spks = ismail(k).spikes.times;
% rspks = ismail(k).spikes_rand.times;

% spks = spikes.times;
% rspks = spikes_rand.times;

%% Calculate spike triggered averages
    fprintf('Calculating error_pos STA.\n');
    epos = iu_sta(spks, rspks, data(entry).fish_pos, data(entry).Fs, 2);
    fprintf('Calculating error_vel STA.\n');
    evel = iu_sta(spks, rspks, data(entry).fish_vel, data(entry).Fs, 2);
    fprintf('Calculating error_acc STA.\n');
    eacc = iu_sta(spks, rspks, data(entry).fish_acc, data(entry).Fs, 2);
    fprintf('Calculating error_jerk STA.\n');
    ejerk = iu_sta(spks, rspks, data(entry).fish_jerk, data(entry).Fs, 2);
    fprintf('And we are done!!!\n');

    %% Plot them all in one figure
    figure(1); clf; 

    subplot(2,2,1); title('Position'); hold on;
    plot([0, 0], [min(epos.MEAN), max(epos.MEAN)], 'k-', 'LineWidth',1);
    plot(epos.time, epos.MEAN, 'b-', 'LineWidth', 3);
    plot(epos.time, epos.randMEAN,'r-','LineWidth',3);

    subplot(222); title('Acceleration'); hold on;
    plot([0, 0], [min(eacc.MEAN), max(eacc.MEAN)], 'k-', 'LineWidth',1);
    plot(eacc.time, eacc.MEAN, 'b-', 'LineWidth', 3);
    plot(eacc.time, eacc.randMEAN,'r-','LineWidth',3);

    subplot(223); title('Velocity'); hold on;
    plot([0, 0], [min(evel.MEAN), max(evel.MEAN)], 'k-', 'LineWidth',1);
    plot(evel.time, evel.MEAN, 'b-', 'LineWidth', 3);
    plot(evel.time, evel.randMEAN,'r-','LineWidth',3);
    
    subplot(224); title('Jerk'); hold on;
    plot([0, 0], [min(ejerk.MEAN), max(ejerk.MEAN)], 'k-', 'LineWidth',1);
    plot(ejerk.time, ejerk.MEAN, 'b-', 'LineWidth', 3);
    plot(ejerk.time, ejerk.randMEAN,'r-','LineWidth',3);

%% Plot the error

figure(2); clf; 

    subplot(221); title('Position'); hold on;
    plot([0, 0], [min(epos.STD), max(epos.STD)], 'k-', 'LineWidth',1);
    plot(epos.time, epos.STD, 'b-', 'LineWidth', 3);
    plot(epos.time, epos.randSTD, 'r-', 'LineWidth', 3);

    subplot(222); title('Acceleration'); hold on;
    plot([0, 0], [min(eacc.STD), max(eacc.STD)], 'k-', 'LineWidth',1);
    plot(eacc.time, eacc.STD, 'b-', 'LineWidth', 3);
    plot(eacc.time, eacc.randSTD, 'r-', 'LineWidth', 3);

    subplot(223); title('Velocity'); hold on;
    plot([0, 0], [min(evel.STD), max(evel.STD)], 'k-', 'LineWidth',1);
    plot(evel.time, evel.STD, 'b-', 'LineWidth', 3);
    plot(evel.time, evel.randSTD, 'r-', 'LineWidth', 3);

    subplot(224); title('Jerk'); hold on;
    plot([0, 0], [min(ejerk.STD), max(ejerk.STD)], 'k-', 'LineWidth',1);
    plot(ejerk.time, ejerk.STD, 'b-', 'LineWidth', 3);
    plot(ejerk.time, ejerk.randSTD, 'r-', 'LineWidth', 3);

    %% Plot the raw data
    
    figure(3); clf;
    
    plot(data(entry).time, data(entry).shuttlevel, 'b-'); 
    