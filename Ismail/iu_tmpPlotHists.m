figure(1); clf;
    subplot(211); plot(out.errorVEL.Xs, out.errorVEL.OccCorrHist); 
    subplot(212); hold on;
        plot(out.errorVEL.Xs, out.errorVEL.responseHist); 
        plot(out.errorVEL.Xs, out.errorVEL.stimulusHist);
        
figure(2); clf;
    subplot(211); plot(out.errorACC.edges(1:end-1), out.errorACC.OccCorrHist); 
    subplot(212); hold on; 
        plot(out.errorACC.edges(1:end-1), out.errorACC.responseHist); 
        plot(out.errorACC.edges(1:end-1), out.errorACC.stimulusHist);

figure(3); clf;
    subplot(211); plot(out.errorJRK.edges(1:end-1), out.errorJRK.OccCorrHist); 
    subplot(212); hold on; 
        plot(out.errorJRK.edges(1:end-1), out.errorJRK.responseHist); 
        plot(out.errorJRK.edges(1:end-1), out.errorJRK.stimulusHist);
