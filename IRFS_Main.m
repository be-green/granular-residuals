%%%%%% Testing GR Priced

clc
close all
clear all

% Load data
Data_Old = xlsread('GR_Quarterly_A.xlsx');
Data_Old = Data_Old(178:end,:);
% Vars
IP_Old = Data_Old(:, 1);
Emp_Old = Data_Old(:, 2);
CR_Old = 100 .* Data_Old(:, 3);
GR_Old = Data_Old(:, 4);
r_Old = Data_Old(:, 5);
Cons_Old = Data_Old(:,6);
V_Old = 100.*Data_Old(:,7);
F_Old = 100.*Data_Old(:, 8);
% Un-comment to winsorize
%  F_Old  = min(F_Old, quantile(F_Old,0.99));
%  F_Old   = max(F_Old, quantile(F_Old,0.01));
W_Old = Data_Old(:,9);
Skew_Old =Data_Old(:,10);
ADS_Old = Data_Old(:,11);
U_Old =Data_Old(:, 12);
GDP_Old = Data_Old(:, 13);
CFN_Old = Data_Old(:, 14);
%%% Parameters%%%%%%%%%%%%%%%
% Horizon
H = 10;
% Number of lags of LHS
lags = 3;
% Number of lhd vars
NY = 9;
        % Number of LHS vars
        Set_Params.NY = NY;
%%%%%%%%%%%%%%%%%%
% LHS vars
LHS_Old = [log(Cons_Old), log(GDP_Old), log(W_Old),log(Emp_Old),100.*CR_Old,  ...
    U_Old,log(IP_Old),ADS_Old,  CFN_Old];
% These are the level vars, so we standardize them
LHS_Old(:,5) = LHS_Old(:,5)./nanstd(LHS_Old(:,5));
LHS_Old(:,6) = LHS_Old(:,6)./nanstd(LHS_Old(:,6));
LHS_Old(:,8) = LHS_Old(:,8)./nanstd(LHS_Old(:,8));
LHS_Old(:,9) = LHS_Old(:,9)./nanstd(LHS_Old(:,9));
% Names
Names = {'Consumption Growth', 'GDP Growth', 'Compensation Growth', 'Employment Growth',...
    'Initial Claims / Employment','Unemployment Rate','IP Growth','Aruoba-Diebold-Scotti Index',...
    'Chicago Fed National Activity Index'};
% Loop through horizon lengths
for h = 1 : H
    % j tracks positions of saved betas and SEs
    j = 1;
    % Loop over LHS vars
    for p = 1 : NY
        % For each LHS var, find the maximum possible number of
        % observations
        nonmissingobs=find(~isnan(sum([LHS_Old(:,p),r_Old,V_Old,F_Old],2)));
        r =r_Old(nonmissingobs);
        V=V_Old(nonmissingobs);
        F=F_Old(nonmissingobs,:);
        LHS = LHS_Old(nonmissingobs,:);
        % Pre-allocate
        Lagged_LHS = [];
        % If no lags, simply use GR, r, V, and t value of LHS
        if lags==0
            % If using one of the level variables
            if p == 5 || p==6 || p==8 || p==9
                % Instruments
                RHS_I =  [F(lags + 3 : end - h + 1,:),V(lags + 3 : end - h + 1),...
                    LHS(2 + lags : end - h,p)];
                % First stage
                [~, ~, ~, ~, ~, ~, ~, r_hat] = ols(r(lags + 3: end - h + 1),...
                    RHS_I,1);
                % Use fitted value
                RHS = [r_hat,V(lags + 3 : end - h + 1),...
                    LHS(2 + lags : end - h,p)];
            else
                % If not level variable, we do difference
                % Instruments
                RHS_I =  [F(lags + 3 : end - h + 1,:),V(lags + 3 : end - h + 1),...
                    LHS(2 + lags : end - h,p) - LHS(1 + lags : end - h - 1,p)];
                [~, ~, ~, ~, ~, ~, ~, r_hat] = ols(r(lags + 3: end - h + 1),...
                    RHS_I,1);
                % First stage
                RHS = [r_hat,V(lags + 3 : end - h + 1),...
                    LHS(2 + lags : end - h,p) - LHS(1 + lags : end - h - 1,p)];
            end
               % If lags >0
        else
         % Loop through lags-1
            for i = 0 : lags - 1
                % If level var, don't difference
                if p == 5 || p==6 || p==8 || p==9
                    % Create lagged LHS
                    Lagged_LHS = [Lagged_LHS,LHS(1 + lags - i : end - h - i - 1,p)];
                    % If not a level var
                else
                    % Create lagged log differences (differences are always 1 period
                    % apart
                    Lagged_LHS = [Lagged_LHS,LHS(1 + lags - i : end - h - i - 1,p) - ...
                        LHS(lags - i :end - h - i - 2,p)];
                end
            end
            % If level var.
            if p == 5 || p==6 || p==8 || p==9
                % Instruments
                RHS_I =  [F(lags + 3 : end - h + 1,:),V(lags + 3 : end - h + 1),...
                    LHS(2 + lags : end - h,p),Lagged_LHS];
                % First stage
                [~, ~, ~, ~, ~, ~, ~, r_hat] = ols(r(lags + 3: end - h + 1),...
                    RHS_I,1);
                % Regressor mat
                RHS = [r_hat,V(lags + 3 : end - h + 1),...
                    LHS(2 + lags : end - h,p), Lagged_LHS];
                % If not level var...
            else
                % ... current (t) period value is differenced
                RHS_I =  [F(lags + 3 : end - h + 1,:),V(lags + 3 : end - h + 1),...
                    LHS(2 + lags : end - h,p) - LHS(1 + lags : end - h - 1,p),Lagged_LHS];
                % First stage
                [~, ~, ~, ~, ~, ~, ~, r_hat] = ols(r(lags + 3: end - h + 1),...
                    RHS_I,1);
                % Regressor matrix
                RHS = [r_hat,V(lags + 3 : end - h + 1),...
                    LHS(2 + lags : end - h,p) - LHS(1 + lags : end - h - 1,p), Lagged_LHS];
            end
            
        end
        % If level var
        if p == 5 || p==6 || p==8 || p==9
            % No need to standardize (already did above)
            LHS_H = LHS(lags + 2 + h:end,p);
       % If not level var
        else
            %... future LHS is differenced from today
            LHS_H = 100.*(LHS(lags + 2 + h:end,p) - LHS(lags + 2:end-h,p));
        end
           % Sample length
        Set_Params.T = length(LHS_H);
     % Make IV and OLS together
        Y = LHS_H;
        I = [ones(Set_Params.T,1), RHS_I];
                % Regressor matrix for OLS
        X = [ones(Set_Params.T,1), r(lags + 3: end - h + 1), RHS_I(:,2:end)];
        KI = size(I,2);
        KX = size(X,2);
        Set_Params.NI = KI;
        Set_Params.Num_Pred = KX;
       
     
        
        b = Make_Delta_IV([Y,I,X],Set_Params,inv(I'*I));
         Moments = IV_Mom([Y,I,X],b,Set_Params);
        % Contemporaneous variance
    S = Moments'*Moments./Set_Params.T;
    % Transpose moments
    t_M=transpose(Moments);
    % Initialize kernel
   L= 10;
    weight = zeros(1,L);
    % Loop through NW lags
    for k = 1:L
        % Initialize j-th auto-covariance matrix
        Om_j = zeros(size(Moments,2),size(Moments,2));
        % j-th kernel weight
        weight(k)=1-(k/(L+1));
        % Loop through all t used to calculate j-th auto-cov
        for r = (k+1):Set_Params.T
            % j-th auto-covariance
            Om_j = Om_j + t_M(:,r).*t_M(:,r-k)'./Set_Params.T;
        end
        % NW cov mat
        S=S+weight(k)*(Om_j+Om_j');
    end
    
Gradient = (1/Set_Params.T)*(-I'*X);

Joint_Cov = inv(Gradient'*inv(S)*Gradient);

G = zeros(length(b),1);
G(2) = 1;

        % Save beta
        Save_Betas_Ins(j,h) = b(2);
        % Save standard error (already divided by T!!!)
        Save_SEs_Ins(j,h) = sqrt((1/Set_Params.T)*(G'*Joint_Cov*G));

        
        
        b = Make_Delta_IV([Y,X,X],Set_Params,eye(KX));
         Moments = IV_Mom([Y,X,X],b,Set_Params);
        % Contemporaneous variance
    S = Moments'*Moments./Set_Params.T;
    % Transpose moments
    t_M=transpose(Moments);
    % Initialize kernel
   L= 10;
    weight = zeros(1,L);
    % Loop through NW lags
    for k = 1:L
        % Initialize j-th auto-covariance matrix
        Om_j = zeros(size(Moments,2),size(Moments,2));
        % j-th kernel weight
        weight(k)=1-(k/(L+1));
        % Loop through all t used to calculate j-th auto-cov
        for r = (k+1):Set_Params.T
            % j-th auto-covariance
            Om_j = Om_j + t_M(:,r).*t_M(:,r-k)'./Set_Params.T;
        end
        % NW cov mat
        S=S+weight(k)*(Om_j+Om_j');
    end
    
Gradient = (1/Set_Params.T)*(-X'*X);

Joint_Cov = inv(Gradient'*inv(S)*Gradient);

G = zeros(length(b),1);
G(2) = 1;

        % Save beta
        Save_Betas(j,h) = b(2);
        % Save standard error (already divided by T!!!)
        Save_SEs(j,h) = sqrt((1/Set_Params.T)*(G'*Joint_Cov*G));

        Delta = Make_Delta([Y,I,X],Set_Params, inv(I'*I));
        
        Moments = OLS_IV([Y,I,X],Delta,Set_Params);
        % Contemporaneous variance
    S = Moments'*Moments./Set_Params.T;
    % Transpose moments
    t_M=transpose(Moments);
    % Initialize kernel
   L= 10;
    weight = zeros(1,L);
    % Loop through NW lags
    for k = 1:L
        % Initialize j-th auto-covariance matrix
        Om_j = zeros(size(Moments,2),size(Moments,2));
        % j-th kernel weight
        weight(k)=1-(k/(L+1));
        % Loop through all t used to calculate j-th auto-cov
        for r = (k+1):Set_Params.T
            % j-th auto-covariance
            Om_j = Om_j + t_M(:,r).*t_M(:,r-k)'./Set_Params.T;
        end
        % NW cov mat
        S=S+weight(k)*(Om_j+Om_j');
    end
    
Gradient = (1/Set_Params.T)*[-I'*X, zeros(KI,KX); zeros(KX,KX), -X'*X];

Joint_Cov = inv(Gradient'*inv(S)*Gradient);

G = zeros(length(Delta),1);
G(2) = -1;
G(KX+2) = 1;


Save_SEs_Diff(j,h) =sqrt( (1/Set_Params.T)*(G' * Joint_Cov * G));

Delta1(j,h) = Delta(2);
Delta2(j,h) = Delta(KX + 2);



Save_Betas_Diff(j,h) = Delta2(j,h) - Delta1(j,h);

        
        % Iterate j 2 forward (since we save 2 variables)
        j = j + 1;
    end
    
end


% j starts at one for GR
j=1;

% Figure
Fig = figure('Color',[1 1 1],'Units','inches','Position',[1 1 11 8.5]);
% Loop over LHS
for i = 1 : length(Names)
    % Subplot per LHS var
    subplot1 = subplot(3,3,i,'Parent',Fig,'YGrid','on');
    % Put in box
    box(subplot1,'on');
    % Keep plots on
    hold(subplot1,'on');
    % First plot is GR + CI
    plot(1:H, Save_Betas(j,:),'LineWidth',3,'color',[1 0 0])
    plot1 = boundedline(1:H, Save_Betas(j,:), 1.96*Save_SEs(j,:),'alpha','transparency',0.2,'cmap',[1 0 0]);
    % Second plot is r + CI
     plot(1:H, Save_Betas_Ins(j,:),'LineWidth',3,'color',[0 0 1])
    plot2 =boundedline(1:H,Save_Betas_Ins(j,:),1.96*Save_SEs_Ins(j,:),'alpha','transparency',0.2,'cmap',[0 0 1]);
%     plot(1:H, Save_Betas_Diff(j,:),'LineWidth',3,'color',[0 .4 0])
%      plot3 = boundedline(1:H, Save_Betas_Diff(j,:), 1.96*Save_SEs_Diff(j,:),'alpha','transparency',0.2,'cmap',[0 .4 0]);
%     % Tight axis
    axis tight
    % 0 Line
    plot(1:H,zeros(H,1),'Color',[0,0,0],'LineStyle','-','LineWidth',1.5)
    % Iterate j and k forward by 2 (
    j = j+1;
      title(strcat('Panel',{' '}, num2str(i), ':',{' '},Names{i}))
    xlabel('Horizon')
    if i == 5 || i == 6 || i==8 || i==9
        ylabel('Standard Deviations')
    else
        ylabel('Percentage Change')
    end
    if i == 9
%         legend([plot1(1),plot2(1),plot3(1)],'OLS','IV','OLS-IV')
        legend([plot1(1),plot2(1)],'OLS','IV')
    end
    
end
orient(gcf,'landscape');
print(gcf,'-dpdf','IRFs_Ins_Thicker_NoDiff.pdf');
close(gcf);



% 
% % j starts at one for GR
% j=1;
% 
% % Figure
% Fig1 = figure('Color',[1 1 1],'Units','inches','Position',[1 1 11 8.5]);
% % Loop over LHS
% for i = 1 : length(Names)
%     % Subplot per LHS var
%     subplot1 = subplot(3,3,i,'Parent',Fig1,'YGrid','on');
%     % Put in box
%     box(subplot1,'on');
%     % Keep plots on
%     hold(subplot1,'on');
%     % First plot is GR + CI
%     plot1 = boundedline(1:H, Save_Betas_Diff(j,:), 1.96*Save_SEs_Diff(j,:),'alpha','transparency',0.2,'cmap',[0 0 1]);
%     % Tight axis
%     axis tight
%     % 0 Line
%     plot(1:H,zeros(H,1),'Color',[0,0,0],'LineStyle','-','LineWidth',1.5)
%     % Iterate j and k forward by 2 (
%     j = j+1;
%     title(strcat('Panel',{' '}, num2str(i), ':',{' '},Names{i}))
%     xlabel('Horizon')
%     
%     if i == 5 || i == 6 || i == 8 || i==9
%         ylabel('Standard Deviations')
%     else
%         ylabel('Precentage Change')
%     end
%     
%     
% end
% orient(gcf,'landscape');
% print(gcf,'-dpdf','IRFs_Ins_Diff.pdf');

