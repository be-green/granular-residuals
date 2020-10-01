clc
close all
clear
% Load FF
RF = xlsread('RF.xlsx');
RF = RF ./ 100;
% Load Raw
CRSP = xlsread('EW_NYSE.xlsx');

Rets = [];
Rets = [Rets, CRSP(7 : end, 2) - RF];
% Load Raw
CRSP = xlsread('EW_NYSE_AMEX.xlsx');
Rets = [Rets, CRSP(7 : end, 2) - RF];
% Load Raw
CRSP = xlsread('EW_All.xlsx');
Rets = [Rets, CRSP(7 : end, 2) - RF];

% svM
S = xlsread('svM.csv');
R = [zeros(6, 3);Rets .* 100];
S = [S, R];

scatter(S(:,end), S(:,7))
xlabel('EW -  CRSP')
ylabel('Original')
saveas(gcf,'Scatter.pdf')

csvwrite('svM_alt_EW.csv', S);
