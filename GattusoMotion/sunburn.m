function out = sunburn(neuron)
%hint out = sunburn(AL(2).s) 
%this will give you all of the stimuli in the second cataloged neuron

size = input('size idx for heat/hist');

Fs = neuron(1).s(1).pFs;
position =[];
tim = [];
spikes = [];
for kk = 1:length(neuron)
for jj = 1:length(neuron(kk).s)               %% this cycles through all of the stimuli
    if neuron(kk).s(jj).sizeDX == size
        position = [position neuron(kk).s(jj).pos'];
        
        if isempty(tim) %must use isempty because the first stimuli of a particular size is not always jj=1
            nextim = 0; 
        else 
            nextim = tim(end);
        end
        
        curtim = (1/Fs:1/Fs:length(neuron(kk).s(jj).pos)/Fs) + nextim;
        tim = [tim curtim];
        spikes = [spikes (neuron(kk).s(jj).st' + nextim)];
    end
end
end
out.spikes = spikes;
out.Fs = Fs;

buff = 0.100;

[b,a] = butter(3, 30/Fs, 'low'); 
[d,c] = butter(5, 20/Fs, 'low'); 

firstorder = filtfilt(b,a,diff(position));
secondorder = filtfilt(d,c,diff(firstorder));
out.objpos = position;
out.objvel = firstorder;
out.objacc = secondorder;

cpos = []; cvel = []; cacc = [];
for ss = length(spikes):-1:1;    
    tt = find(tim(1:end-2) < spikes(ss) & tim(1:end-2) > spikes(ss) - buff);
    cpos(ss) = mean(position(tt));
    cvel(ss) = mean(firstorder(tt)); %does not like when you select an even number of options*****
    cacc(ss) = mean(secondorder(tt));

    pv(ss,:) = [cpos(ss) cvel(ss)];
    av(ss,:) = [cacc(ss) cvel(ss)];
    
end
out.cpos = cpos;
out.cvel = cvel;
out.cacc = cacc;


thresh = 0.0001;
goodpoints = find(abs(av(:,1)) < thresh); 
pv = pv(goodpoints,:);
av = av(goodpoints,:);

%out.posvel = hist3(pv,{-6:0.01:6 -0.0012:.0024/128:0.0012});
out.posvel = hist3(pv,[50 50]);
    out.tmpPV = medfilt2(out.posvel, [3 3]); cmaxPV = max(max(out.tmpPV)); 
out.accvel = hist3(av,[50 50]);
    out.tmpAV = medfilt2(out.accvel, [3 3]); cmaxAV =  max(max(out.tmpAV));

out.pos = cpos;
out.vel = cvel;
out.acc = cacc;
        
pp = find(abs(out.acc) < thresh);

maxvellabelhigh = max(firstorder);
maxvellabellow = -1*maxvellabelhigh;
midvellabellow = -1*maxvellabelhigh/2;
midvellabelhigh = 1*maxvellabelhigh/2;
maxacclabelhigh = max(secondorder);
maxacclabellow = -1*maxacclabelhigh;
midacclabellow = -1*maxacclabelhigh/2;
midacclabelhigh = max(secondorder)/2;

figure; clf;
subplot(221); surf(out.posvel', 'EdgeColor', 'none'); view(0,90); caxis([0 cmaxPV]); xlabel('Position'); ylabel('Velocity'); 
xticks([0 50/4 25 150/4 50]); xticklabels({'-5' '-2.5' '0' '2.5' '5'}); 
yticks([0 50/4 25 150/4 50]); yticklabels({num2str(maxvellabellow) num2str(midvellabellow) '0' num2str(midvellabelhigh) num2str(maxvellabelhigh)});
subplot(222); surf(out.accvel', 'EdgeColor', 'none'); view(0,90); caxis([0 cmaxAV]); xlabel('Acceleration'); ylabel('Velocity');
xticks([0 50/4 25 150/4 50]); xticklabels({num2str(maxacclabellow) num2str(midacclabellow) '0' num2str(midacclabelhigh) num2str(maxacclabelhigh)}); 
yticks([0 50/4 25 150/4 50]); yticklabels({num2str(maxvellabellow) num2str(midvellabellow) '0' num2str(midvellabelhigh) num2str(maxvellabelhigh)});
colormap('HOT');
subplot(223); plot(out.pos(pp), out.vel(pp),'.'); xlabel('Position'); ylabel('Velocity');
subplot(224); plot(out.acc(pp), out.vel(pp), '.'); xlabel('Acceleration'); ylabel('Velocity');

figure;
velsteps = 0.0005;
accsteps = 0.0000015;
posedges = -5:0.1:5;
veledges = min(out.vel):velsteps:max(out.vel);

accedges = min(out.acc):accsteps:max(out.acc);

subplot(131); a = histcounts(out.pos, posedges); %plot(posedges(1:end-1), a/sum(a), 'b'), 
subplot(132); b = histcounts(out.vel, veledges); %plot(veledges(1:end-1), b/sum(b), 'b'),
subplot(133); c = histcounts(out.acc, accedges); %plot(accedges(1:end-1), c/sum(c), 'b'), 

stimedges = -5:0.1:5;
foedges = min(firstorder):velsteps: max(firstorder);
soedges = min(secondorder):accsteps:max(secondorder);

subplot(131); hold on, d = histcounts(position, stimedges); %plot(stimedges(1:end-1), d/ (sum(d)), 'r'), xlabel('Position'); ylabel('Time Percentge'); legend('Spikes', 'Stimulus')
subplot(132); hold on, f = histcounts(firstorder, foedges); %plot(foedges(1:end-1), f / (sum(f)), 'r'), xlabel('Velocity'); ylabel('Time Percentage'); legend('Spikes', 'Stimulus')
subplot(133); hold on, g = histcounts(secondorder, soedges); %plot(soedges(1:end-1), g/ (sum(g)), 'r'), 
%xlabel('Acceleration'); ylabel('Time Percentage'); legend('Spikes', 'Stimulus'); % axis([-5*10^(-5), 5*10^(-5), 0, 0.005])
% 
% aa = a/sum(a);
% bb = b/sum(b);
% cc = c/sum(c);
% dd = d/sum(d);
% ff = f/sum(f);
% gg = g/sum(g);
% length(aa)
% length(dd)
% length(bb)
% length(ff)
% length(cc)
% length(gg)
posad = aa/dd;
velbf = bb/ff;
acccg = cc/gg;


end

