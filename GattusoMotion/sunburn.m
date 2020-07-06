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
        position = [position neuron(kk).s(jj).pos']; %change the "prime"
        
        if isempty(tim) %must use isempty because the first stimuli of a particular size is not always jj=1
            nextim = 0; 
        else 
            nextim = tim(end);
        end
        
        curtim = (1/Fs:1/Fs:length(neuron(kk).s(jj).pos)/Fs) + nextim;
        tim = [tim curtim];
        spikes = [spikes (neuron(kk).s(jj).st + nextim)'];
    end
end
end
out.spikes = spikes;
figure(1); clf; plot(spikes, '*');
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
for ss = length(spikes):-1:1    %looking for the time when the spikes occured
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
velsteps = 0.001;
accsteps = 0.0000015;
posedges = -5:0.2:5;
veledges = -0.02:velsteps:0.02; % need to define bins rather than calculate them on a per trial basis 

accedges = -0.25*10^(-4):accsteps:0.25*10^(-4); % need to define bins rather than calculate them on a per trial basis 

newout.acc = [];
holder = [];
for zz = 1:length(out.acc)
    if out.acc(zz) == 0
        holder = [holder out.acc(zz)];
    else
        newout.acc = [newout.acc out.acc(zz)];
    end
end
        
out.acc = newout.acc;

subplot(231); a = histcounts(out.pos, posedges); plot(posedges(1:end-1), a/sum(a), 'b'), 
subplot(232); b = histcounts(out.vel, veledges); plot(veledges(1:end-1), b/sum(b), 'b'),
subplot(233); c = histcounts(out.acc, accedges); plot(accedges(1:end-1), c/sum(c), 'b'), 

stimedges = -5:0.2:5;
foedges = -0.02:velsteps: 0.02;
soedges = -0.25*10^(-4):accsteps:0.25*10^(-4);

subplot(231); hold on, d = histcounts(position, stimedges); plot(stimedges(1:end-1), d/ (sum(d)), 'r'), xlabel('Position'); ylabel('Time Percentge'); legend('Spikes', 'Stimulus')
subplot(232); hold on, f = histcounts(firstorder, foedges); plot(foedges(1:end-1), f / (sum(f)), 'r'), xlabel('Velocity'); ylabel('Time Percentage'); legend('Spikes', 'Stimulus')
subplot(233); hold on, g = histcounts(secondorder, soedges); plot(soedges(1:end-1), g/ (sum(g)), 'r'), 
xlabel('Acceleration'); ylabel('Time Percentage'); legend('Spikes', 'Stimulus'); % axis([-5*10^(-5), 5*10^(-5), 0, 0.005])

for kk = 1:length(a)
    posad(kk) = (d(kk)/sum(d))-(a(kk)/sum(a));
%     posad(kk) = (a(kk)/sum(a))/(d(kk)/sum(d));
end
for jj = 1:length(b)
    velbf(jj) = (f(jj)/sum(f))-(b(jj)/sum(b));
%     velbf(jj) = (b(jj)/sum(b))/(f(jj)/sum(f));
end
for mm = 1:length(c)
    acccg(mm) = (g(mm)/sum(g))-(c(mm)/sum(c));
%     acccg(mm) = (c(mm)/sum(c))/(g(mm)/sum(g));
end

subplot(234); plot(stimedges(1:end-1), 1 * posad, 'k', 'LineWidth', 2); xlabel('Spikes-Stimulus : Position');
subplot(235); plot(foedges(1:end-1), 1 * velbf, 'k', 'LineWidth', 2); xlabel('Spikes-Stimulus : Velocity');
subplot(236); plot(soedges(1:end-1), 1 * acccg, 'k', 'LineWidth', 2); xlabel('Spikes-Stimulus : Acceleration');

end

