
% Set start index to one that matches your choice above
Start = find(Dates == Subsample);
% Risk-free rate
RF = RF_1(Start:end);
% Clean data
Ports = Ports_Start(Start:end, :);
% These are number of portfolios in each sort
Port_Size = [10 * ones(1,12), 25 * ones(1,4), 10, 25 10, 25,10,25 35, 25, 25]';
% j indexes the FF "sort" (eg 10 sorted on size, 5x5 on blah blah
j=1;
% Pre-allocate
Ports_Comb = cell(length(Names),1);
% Loop through each sort (their identities are in Names above)
for i = 1 : length(Names)
    % Each cell in Ports_Comb is a sort
    Ports_Comb{i} = Ports(:,j:Port_Size(i) + j - 1);
    % Iterate
    j = j + Port_Size(i);
end
% Select the sizes from Start date on
FF_Size = FF_Size_1(Start:end, :);
% j indexes the FF "sort" (eg 10 sorted on size, 5x5 on blah blah
j=1;
% Pre-allocate
Ports_Comb_Size = cell(length(Names),1);
% Loop through each sort (their identities are in Names above)
for i = 1 : length(Names)
    % Each cell in Ports_Comb is a sort
    Ports_Comb_Size{i} = FF_Size(:,j:Port_Size(i) + j - 1);
    % Iterate
    j = j + Port_Size(i);
end
% Need to shorten series, because FF data starts a bit later
Rets = RetsM_1(Start: end, :);
Price = Price_1(Start: end, :);

% Excess market return, SMB, HML, UMD
Ex_Mkt = Ex_Mkt_1(Start : end);
HML = HML_1(Start: end);
SMB = SMB_1(Start : end);
% Length of time series
T = size(Rets, 1);

Dates_1 = Dates(Start:end);
Dates_Temp = {};

% j will track the index for each window
j = 1;
% Pre-allocate
Explained = zeros(Lag - 1, T - Lag + 1);
X_Main = cell(T - Lag + 1,1);
X_OLS = cell(T - Lag + 1,1);
Mkt_Mean = zeros(T - Lag + 1,1);
% Loop starts at length of window, naturally
tic;
for t = Lag : T
    % Rets for one span
    Dates_Temp{j} = Dates_1(t -  Lag + 1 : t);
    Temp_Ret = Rets(t -  Lag + 1 : t, :);
    % Prices for one span (we will use these to determine which stocks are
    % truly "missing"
    Temp_Price = Price(t -  Lag + 1 : t, :);
    % rows and columns with missing returns
    [r,c] = find(Temp_Price==0);
    % Unique columns (stocks) with missing values
    C = unique(c);
    % Remove them
    Temp_Ret(:, C) = [];
    % PCA
    [Coef,scores, ~, ~,exp] = pca(Temp_Ret);
    % Percent variance explained
    Explained(:,j) = exp;
    % Select first k
    Coef = Coef(:, 1 : K);
    % Factors
    F = Temp_Ret * Coef;
    Save_PCs{j} = F;
    % Market return for period
    Temp_Mkt_Ret =  Ex_Mkt(t -  Lag + 1 : t, :);
    Save_Mkt{j} = Temp_Mkt_Ret;
    % Regressor matrix
    X =  [ones(Lag, 1) F];
    % Coeffients of regression
    B1 = (X' * X)^(-1) * X' * Temp_Mkt_Ret;
    % Fitted value
    Fitted = X(:,2:end) * B1(2:end);
    % Regressor matrix for Factors on IV
    X_2 = [ones(Lag,1), Fitted];
    % If yes to orthogonalize
    if Orth == 1
        % HML
        H_Temp = HML(t -  Lag + 1 : t);
        F_New = H_Temp;
        % Betas from regression
        F_ti_beta = (X_2' * X_2) ^(-1) * X_2' *F_New;
        % Residuals
        F_ti = F_New - repmat(Fitted,1,1).*F_ti_beta(2,:);
        % Regressor matrix for Factors on Mkt
        X_3 = [ones(Lag,1), Temp_Mkt_Ret];
        % HML
        H_Temp =  HML(t -  Lag + 1 : t);
        % Group factors
        F_New =  H_Temp;
        % Betas from regression
        F_ti_beta = (X_3' * X_3) ^(-1) * X_3' *F_New;
        % Residuals
        F_ti_OLS = F_New - repmat(Temp_Mkt_Ret,1,1).*F_ti_beta(2,:);
        % Save resids for OLS
        X_OLS{j} = [  ones(Lag, 1), F_ti_OLS, Temp_Mkt_Ret];
        % Regressor matrix
        X_Main{j} = [ones(Lag, 1), F_ti, Fitted];
    else
        % Save resids for OLS
        X_OLS{j} = [  ones(Lag, 1),Temp_Mkt_Ret];
        % Regressor matrix
        X_Main{j} = [ones(Lag, 1), Fitted];
    end
    % Mean market return over window
    Mkt_Mean(j) = mean(Temp_Mkt_Ret);
    j = j + 1;
    disp(['Iteration: ',num2str(j)]);
end
toc;

% for k = 1 : length(Dates_1)
%     D1 = Dates_1(k);
%     F_Save = [];
% for i = 1 : length(Dates_Temp)
%     D = Dates_Temp{i};
%     F = X_Main{i}(:,3);
% F = Save_PCs{i};
%     Inds = (D==D1);
%     F_Save = [F_Save; F(Inds,:)];
% end
% if k == 1 || k == length(Dates_1)
%     Mean_PCs(k,:) = F_Save;
% else
%   Mean_PCs(k,:) = median(F_Save);  
% end
% 
% end
% 
% Moving_Ave = movmean(Mean_PCs,[2,0]);
% PC_Q = Moving_Ave(3:3:end, :);
% 
% Test_Mkt = movmean(Ex_Mkt,[2,0]);
% Test_Mkt = Test_Mkt(3 : 3 : end);
% 
% 
% corr(Test_Mkt,PC_Q)

% Pre-allocate
Betas = cell(length(P_Select), 1);
Betas_OLS = cell(length(P_Select), 1);
Means = cell(length(P_Select), 1);
Means_OLS = cell(length(P_Select), 1);
Mean_Size = cell(length(P_Select), 1);

% Loop over sorts
for k = P_Select
    % Ports_1 is FF sort number k
    Ports_1 = Ports_Comb{k};
    
    Ports_Size_1 = Ports_Comb_Size{k};
    
    % j again tracks the window
    j = 1;
    % Pre-allocate
    Beta = zeros(T - Lag + 1,size(Ports_1, 2));
    M_Ret = zeros(T - Lag + 1,size(Ports_1, 2));
    M_Ret_OLS = zeros(T - Lag + 1,size(Ports_1, 2));
    Beta_OLS = zeros(T - Lag + 1,size(Ports_1, 2));
    Mean_Sizes = zeros(T - Lag + 1,size(Ports_1, 2));
    % Loop over time
    for t = Lag : T
        
        % Get ports of appropriate window length
        Temp_Port = Ports_1(t -  Lag + 1 : t, :);
        Temp_Port_Size = Ports_Size_1(t -  Lag + 1 : t, :);
        
        
        % Loop over stocks in each portfolio
        for i = 1 : size(Temp_Port, 2)
            % Call it P
            P =Temp_Port(:, i);
            
            P_Size =   Temp_Port_Size(:, i);
            
            
            % For ports with missing/NaN, just set Beta to NaN and mean return
            % to NaN as well
            if sum(isnan(P)) > 0
                Beta(j, i) = NaN;
                M_Ret(j,i) = NaN;
                M_Ret_OLS(j,i) = NaN;
                Beta_OLS(j, i) = NaN;
            else
                % Collect Betas for IV and OLS
                B = (X_Main{j}' * X_Main{j}) ^ (-1) * X_Main{j}' * P;
                % Save beta (ignore intercept)
                Beta(j, i) = B(end);
                % Regressor matrix
                X_Temp = X_Main{j};
                % Subtract fitted values and get mean
                if Orth ==1
                    M_Ret(j,i) = mean(P - X_Temp(:,2:end-1) * B(2: end - 1));
                    % New_P is portfolio with fitted values subtracted
                    New_P = P - X_Temp(:,2:end-1) * B(2: end - 1);
                    % Run OLS with New_P
                    B_OLS = (X_OLS{j}' * X_OLS{j}) ^ (-1) * X_OLS{j}' * New_P;
                    M_Ret_OLS(j,i) = mean(New_P);
                    
                else
                    M_Ret(j,i) = mean(P);
                    M_Ret_OLS(j,i) = mean(P);
                    B_OLS = (X_OLS{j}' * X_OLS{j}) ^ (-1) * X_OLS{j}' * P;
                end
                   % Save ols beta (ignore intercept)
                    Beta_OLS(j, i) = B_OLS(end);
                
            end
         
            
            Mean_Sizes(j,i) = mean(P_Size);
            
        end
        j = j + 1;
        
    end
    
    % Save IV beta in cell
    Betas{k} = Beta;
    % Save OLS beta in cell
    Betas_OLS{k} = Beta_OLS;
    % Save window mean return in cell
    Means{k} = M_Ret;
    Means_OLS{k} = M_Ret_OLS;
    Mean_Size{k} = Mean_Sizes;
end

% What are the names of portfolios which you wish to plot?
Names_Select = Names(P_Select);

% k indexes total subplots
k = 1;
j=1;
X = cell(length(Names_Select), 1);
Y = cell(length(Names_Select), 1);
Z = cell(length(Names_Select), 1);
W = cell(length(Names_Select), 1);
Line_1 = cell(length(Names_Select), 1);
Line_2 = cell(length(Names_Select), 1);




% Recall k will index total subplots = number of sorts to plot
while k <= length(Names_Select)
    % Each figure will have 6 plots
    %     figure('Color',[1 1 1],'Units','inches','Position',[1 1 11 8.5]);
    %     % Title at the top of all subplots
    %     suptitle(strcat(Title,'-FittingLine-','LAD'));
    %
    %     % Reset p
    %     p = 1;
    %     % For each subplot with in the figure
    % %     for i = 1 : 6
    %         % 3 by 2, can be changed
    %         subplot(3,1,p)
    % X axis is mean beta
    X{j} = nanmean(Betas{P_Select(k)});
    % Y axis is 1200 times mean return
    Y{j} = 1200 .* nanmean(Means{P_Select(k)});
    % Alternative X axis is ols beta
    Z{j} = nanmean(Betas_OLS{P_Select(k)});
    W{j} = 1200 .* nanmean(Means_OLS{P_Select(k)});
    % For the fitted lines:
    Line_1{j} = lad(Y{j}', [ones(length(X{j}), 1) X{j}']);
    Line_2{j} = lad(W{j}', [ones(length(Z{j}), 1) Z{j}']);
%     Line_1_Betas = Line_1.beta;
%     Line_2_Betas = Line_2.beta;
    
    %         % Axis is tight, can be changed
    %         axis([min([X,Z]), max([X,Z]), min([Y,W]), max([Y,W])])
    %         % For the double sorts, we will use an nm numbering system, instead
    %         % of just counting the portfolio
    %         if size(Betas{P_Select(k)},2) == 25
    %             % d indexes the portfolio (25 total)
    %             d = 1;
    %             % n is the first sorting variable
    %             Port_N = zeros(25, 1);
    %             for n = 1 : 5
    %                 % m is the second
    %                 for m = 1 : 5
    %                     % In Port_N we just save numbers of form nm
    %                     Port_N(d) = str2double(strcat([num2str(n),num2str(m)]));
    %                     d = d + 1;
    %                 end
    %             end
    %             % for length of number of betas
    %             for v=1:length(X)
    %                 % Plot the actual number stored in Port_N of the portfolio in X-Y coordinate
    %                 text(X(v),Y(v),num2str(Port_N(v)),'Color','blue','FontSize',7)
    %             end
    %             % Also do this for OLS betas
    %             for v=1:length(X)
    %                 text(Z(v),W(v),num2str(Port_N(v)),'Color','red','FontSize',7)
    %             end
    %             % One sort as 35 ports, so do fix like
    %             % 25 above
    %         elseif   size(Betas{P_Select(k)},2) == 35
    %
    %             % d indexes the portfolio (35 total)
    %             d = 1;
    %             % n is the first sorting variable
    %             Port_N = zeros(35, 1);
    %             for n = 1 : 5
    %                 % m is the second
    %                 for m = 1 : 7
    %                     % In Port_N we just save numbers of form nm
    %                     Port_N(d) = str2double(strcat([num2str(n),num2str(m)]));
    %                     d = d + 1;
    %                 end
    %             end
    %             % for length of number of betas
    %             for v=1:length(X)
    %                 % Plot the actual number stored in Port_N of the portfolio in X-Y coordinate
    %                 text(X(v),Y(v),num2str(Port_N(v)),'Color','blue','FontSize',7)
    %             end
    %             % Also do this for OLS betas-- only X axis number is different of
    %             % course
    %             for v=1:length(X)
    %                 text(Z(v),W(v),num2str(Port_N(v)),'Color','red','FontSize',7)
    %             end
    %         else
    %             % If portfolio is not a double sort, just plot the portfolio number
    %             for v=1:length(X)
    %                 text(X(v),Y(v),num2str(v),'Color','blue','FontSize',7)
    %             end
    %             % Same for OLS betas
    %             for v=1:length(X)
    %                 text(Z(v),W(v),num2str(v),'Color','red','FontSize',7)
    %             end
    %         end
    %
    %
    %
    %         % for the first subplot
    %         if i == 1
    %             % Put a legend to the right
    %             annotation('textbox',[.9 .5 .1 .2],'String',{'\color{red} OLS','\color{blue} IV',...
    %                 '\color{black} - CAPM Implied'},...
    %                 'EdgeColor','none')
    %         end
    %
    %         % Title of each subplot will just be the portfolio sort
    %         title(Names_Select{k});
    %         % Add a CAPM line
    %         hline = refline([1200 .* mean(Mkt_Mean), 0]);
    %         % Color black for the line
    %         hline.Color ='black';
    %         % Add other fitted lines
    %         hline_1 = refline([Line_1(2), Line_1(1)]);
    %         hline_1.Color = 'blue';
    %         hline_1.LineStyle = '--';
    %         hline_2 = refline([Line_2(2), Line_2(1)]);
    %         hline_2.Color = 'red';
    %         hline_2.LineStyle = '--';
    %         % X axis
    %         xlabel('Mean Beta');
    %         % Y axis
    %         ylabel('Mean Excess Return');
    %         p = p + 1;
    %         % Once k is bigger than the number sorts you selected, stop
    %         % plotting
    %         k = k + 1; if  k > length(Names_Select)
    %             break; end
    %     end
    %     % landscape looks better
    %     orient(gcf,'landscape');
    %     % Save in graphs folder with appropriate filename to distinguish
    %     if j ==1
    %         export_fig(strcat(pwd,Title,'.pdf'));
    %     else
    %         export_fig(strcat(pwd,Title,'.pdf'),'-append');
    %     end
    %     close(gcf);
    j=j+1;
    k = k + 1;
end

