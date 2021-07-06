% add path for regression utilities
addpath(genpath(strcat(pwd, "\utils")));

% Load FF factors
FF = xlsread('data\FF_Monthly.csv');
% Load FF factors size
FF_Size_1 = xlsread('data\monthly_cap_merged.csv');
% Collect dates
Dates = FF(:, 1);
% Turn them into strings
StrDates = num2str(Dates);
% Extract the first four elements of the string (year)
Years = str2double(cellstr(StrDates(:, 1 : 4)));
% Extract last two elements (month)
Months = str2double(cellstr(StrDates(:, 5 : 6)));


% Load FF portfolios
Ports_1 = xlsread('data\monthly_merged.csv');
% Load EW FF portfolios
RetsEW_1 = xlsread('data\monthly_ew_merged.csv');
% Risk-free rate
RF_1 = FF(:, end) ./ 100;
% Clean data
Ports_Start = Ports_1./ 100 - RF_1;


% Load prices
load('data\priceM.mat');
% Load Returns
load('data\retM.mat');
% These portfolios are used to construct PCs
RetsEW_1 = RetsEW_1 ./ 100 - RF_1;
% Need to shorten series, because FF start later and divide by 100 and make
% into excess return
RetsM_1 = retM(13 : end, :) ./ 100 - RF_1;
% Shorten price series
Price_1 = priceM(13 : end, :);

% Excess market return
Ex_Mkt_1 = FF(:,2) ./ 100;
% HML
HML_1 = FF(:, 4) ./ 100;
% SMB
SMB_1 = FF(:, 3) ./ 100;
% 5 port names per row)
Names = {'10 Size', '10 BM', '10 INV', '10 OP', '10 EP',...
    '10 CF-P', '10 DP', '10 AC', '10 NI', '10 VAR',...
    '10 RESVAR', '10 BETA','5x5 Size and BM','5x5 Size and OP','5x5 Size and INV', ...
    '5x5 Size and MOM','10 MOM','5x5 Size and STREV','10 STREV', '5x5 Size and LTREV',...
    '10 IND', '5x5 Size and VAR','5x7 Size and NI','5x5 Size and BETA','5x5 Size and AC' };
% Which portfolios? This is for monthly. Highly recommended to keep first 3
P_Select = [1,13,12,24];
Lag = 60;
% % Number of PCs
K = 3;
% Index
id = 1;
