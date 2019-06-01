function preTExplorer(dFdist, orig)
% ESF

for j=1:length(dFdist)

    figure(1); clf;
    
    subplot(411); % plot original frequency data
    hold on;
        plot(orig(dFdist(j).fishnums(1)).tim, orig(dFdist(j).fishnums(1)).EOD, '.b', 'MarkerSize', 2);
        plot(orig(dFdist(j).fishnums(1)).tim, orig(dFdist(j).fishnums(2)).EOD, '.m', 'MarkerSize', 2);
    xlim([0 orig(dFdist(j).fishnums(1)).tim(end)]);
    ylim([250 500]);
    text(100, 450, num2str(dFdist(j).fishnums));
    text(100, 400, num2str(j));

    subplot(412); % plot Distance and dF data
    xlim([0 orig(dFdist(j).fishnums(1)).tim(end)]);
    hold on;
    yyaxis right;
        plot(dFdist(j).tim, dFdist(j).distance);
    ylabel('distance')
    yyaxis left;
        plot(dFdist(j).tim, dFdist(j).dF);
    ylabel('dF')
    
    subplot(425);
    plot(orig(dFdist(j).fishnums(1)).xy(:,1), orig(dFdist(j).fishnums(1)).xy(:,2), '.b', 'MarkerSize', 4);
    xlim([-250, 250]);
    ylim([-250, 250]);
    
    subplot(426);
    plot(orig(dFdist(j).fishnums(2)).xy(:,1), orig(dFdist(j).fishnums(2)).xy(:,2), '.m', 'MarkerSize', 4);
    xlim([-250, 250]);
    ylim([-250, 250]);
    
    subplot(4,1,4); hold on;
    tmpdF = dFdist(j).dF-mean(dFdist(j).dF);
    tmpdF = tmpdF/(max(abs(tmpdF)));
    tmpDistance = dFdist(j).distance-mean(dFdist(j).distance);
    tmpDistance = tmpDistance/(max(abs(tmpDistance)));
    
    xa = xcorr(tmpdF, tmpDistance);
    plot(xa); xlim([0 length(xa)]);
    [mm, midx] = max(xa);
    plot([length(xa)/2, length(xa)/2], [0 mm], 'r');
    plot(midx, mm, 'go');
    [h,~] = corrcoef(dFdist(j).dF-mean(dFdist(j).dF), dFdist(j).distance-mean(dFdist(j).distance));
    text(length(xa)/2, 0, num2str(h(2)));
    ylim([-1000, 1000]);
    
    endogo = input('foobar 9 to end: ');  
    if endogo == 9; break; end
    
end

%% Embedded function slideCorr
function slideCorr(dat, win, overlp)
function [currTE, currTT] = calcTE(data, windo, stp, kk)

ll = 1; 

currTE = []; currTT = [];

strts = 0:stp:data.tim(end)-windo;


parfor loopr = 1:length(strts)
    
      curstart = strts(loopr);
      aaa= data.dF(data.tim > curstart & data.tim < curstart+windo);
      bbb = data.distance(data.tim > curstart & data.tim < curstart+windo);
      [currTE(loopr),~ ,~] = transferEntropyPartition(aaa(1:2:end), bbb(1:2:end), ll, kk);
      
      [currTE(loopr),~ ,~] = transferEntropyPartition(data.dF(data.tim > curstart & data.tim < curstart+windo), data.distance(data.tim > curstart & data.tim < curstart+windo), ll, kk);      
      %currTE(loopr) = transferEntropyKDE(data.dF(data.tim > curstart & data.tim < curstart+windo), data.distance(data.tim > curstart & data.tim < curstart+windo), ll, kk, 2, 2); 
      %currTE(loopr) = transferEntropyRank(data.dF(data.tim > curstart & data.tim < curstart+windo), data.distance(data.tim > curstart & data.tim < curstart+windo), ll, kk, 2, 2, 10);

      currTT(loopr) = curstart + (windo/2);
                 
end


end



end


end
    