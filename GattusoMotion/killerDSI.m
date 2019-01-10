%% DSI Calculations
function out = killerDSI(in)


% 
% %Direction
% tail = 0;
% head = 0;
% 
% for jj = 1:length(in.pos)
%     if in.pos(jj) < -0.1
%         tail = tail+1;
%     end
%     if in.pos(jj) > 0.1
%         head = head + 1;
%     end
% end  
% 
% out.DSI = (head-tail)/(head+tail);
% %out.DSI = (head-tail)/max([head tail]); %if we wanted to use the max
% %instead of the sum
% fprintf('DSI=')
% fprintf(num2str(out.DSI));
% fprintf('\n')
% 


%Velocity

negvel = 0;
posvel = 0;

for kk = 1:length(in.vel)
    if in.vel(kk) < -0.002
        negvel = negvel+1;
    end
    if in.vel(kk) > 0.002
        posvel = posvel+1;
    end
end  


%out.VSI = (posvel-negvel)/max([posvel negvel]);
fprintf('VSI=')
fprintf(num2str(out.VSI))
fprintf('\n')

objposvel = length(find(in.objvel>0));
objnegvel = length(find(in.objvel<0));
objratio = objposvel/objnegvel;

out.VSI = (posvel-negvel)/(posvel+negvel);

%Acceleration
 
posacc = 0;
negacc = 0;

for mm = 1:length(in.acc)
    if in.acc(mm) < -3E-6
        negacc = negacc + 1;
    end
    if in.acc(mm) > 3E-6
       posacc = posacc+1;
    end
end  

out.ASI = (posacc-negacc)/(posacc+negacc);
%out.ASI = (posacc-negacc)/max([posacc negacc]);
fprintf('ASI=')
fprintf(num2str(out.ASI))
fprintf('\n')
end

