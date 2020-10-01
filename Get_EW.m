clc
close all
clear
% Load FF
FF = xlsread('FF_Monthly.xlsx');
% Risk-free
Rf = FF(:, 8);
% Load prices
load('priceM.mat');
% Load Returns
load('retM.mat');
% Load shares
load('shareM.mat');
% Time series length
 T = size(priceM, 1);
 
 for t = 1 : T
     % Prices, rets, and shares at date t
      Temp_Ret = retM(t, :); 
      Temp_Price = priceM(t, :);
      Temp_Share = shareM(t, :);
      % Indices where prices and shares are non-zero
      Inds = (Temp_Price > 0 & Temp_Share >0);
      % Keep these shares and prices and rets
      Price = Temp_Price(Inds);
      Share = Temp_Share(Inds);
      Return = Temp_Ret(Inds);
      % Number of stocks kept in each data (not actually used, just for
      % checking
      Num_Stocks(t) = sum(Inds);
      % EW
      EW(t) = mean(Temp_Ret(Inds));
 end
 
% Add back Rf (Note that date starts later for Rf)
EW_Plus_Rf = EW(13: end)';

% EW_Final
EW_Final(:,1) = EW(end-623:end);
EW_Long(:,1) = EW(13:end);