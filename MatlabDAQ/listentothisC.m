 function listentothisC(~,evt)
% obj is the DataAcquisition object passed in. evt is not used.

    data = evt.Data;
    tim = evt.TimeStamps;

    FileName = sprintf('Eigen05LDC-%s.mat', datestr(now, 'mm-dd-yyyy_HH-MM-SS'));
    save(FileName, 'data', 'tim');

    % plot(tim, data);

    
 end
 