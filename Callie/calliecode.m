function out = calliecode(in)

Fs = 500;

%% Get centroid for every frame

for kk = 1:length(in) % For each frame (you gave me 2500 frames)
    
    % Get the centroid of ALL points.
    % If you wanted to get the centroid of a subset of points, use
    % something like:     
    
    for j=2:3:86 % This is for each feature you tracked
        idx = (j+1)/3; % Making for a convenient indexing
        dat(idx,:) = [in(kk,j), in(kk,j+1)]; % Get the X and Y points for each feature
    end
    
        convx = convhull(dat(:,1),dat(:,2)); % Get the convex hull (only border of the object)
        poly = polyshape(dat(convx,:)); % Change the data into a Matlab object known as a polyshape for use with 'centroid'
        [out.xC(kk),out.yC(kk)] = centroid(poly); % centroid calculates the centroid X and Y values
        
        % Copy some useful points for fun
        out.xT(kk) = in(kk,62); % Trunk
        out.yT(kk) = in(kk,63);
        out.xR(kk) = in(kk,2); % Rostrum
        out.yR(kk) = in(kk,3);
        out.xP(kk) = in(kk,68); % Pelvius
        out.yP(kk) = in(kk,69); 
end

% Plot for amusement purposes only
figure(1); clf; hold on;

    plot(out.xC, out.yC, '.k', 'MarkerSize', 8);
    plot(out.xT, out.yT, '.b', 'MarkerSize', 8);
    plot(out.xR, out.yR, '.m', 'MarkerSize', 8);
    plot(out.xP, out.yP, '.g', 'MarkerSize', 8);

%% Calculate the angle of movement for each frame

    % This gives the angle for each frame
    out.Crad = atan2(out.yC, out.xC); % Centroid
    out.Trad = atan2(out.yT, out.xT); % Trunk
    out.Rrad = atan2(out.yR, out.xR); % Rostrum
    out.Prad = atan2(out.yP, out.xP); % Pelvis
    
    % out.rad = unwrap(out.rad); % You may need to "unwrap" the data depending on the angle of the fish in the video

% Plotting is fun!  
figure(2); clf; hold on;
    plot(out.Crad, 'k');
    plot(out.Trad, 'b');
    plot(out.Rrad, 'm');
    plot(out.Prad, 'g');


    
    
    
%% Filter the angle change to smooth things out

    [b,a] = butter(3, 1/(Fs/2), 'low');
    out.fCrad = filtfilt(b,a,out.Crad);
    
hold on; plot(out.fCrad, 'c');    
    
%% Rotate the fish for each frame

