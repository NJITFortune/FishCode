function yCalc = KatieRegress(x, y)
% plot the data for fun
% Usage: k_initialplotter(kg(#));

    
%% Linear Regression
X = [ones(length(x),1) x];
b = X\y;
yCalc = X*b;
%b1 = x/y;
%yCalc1 = b1*x;
end