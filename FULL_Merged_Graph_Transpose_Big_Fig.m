%%%%%%%%%%
clc
close all

% Load FF factors
FF = xlsread('FF_Monthly.csv');
% Load FF factors size
FF_Size_1 = xlsread('monthly_cap_merged_v4.csv');
% Collect dates
Dates = FF(:, 1);
% Turn them into strings
StrDates = num2str(Dates);
% Extract the first four elements of the string (year)
Years = str2double(cellstr(StrDates(:, 1 : 4)));
% Extract last two elements (month)
Months = str2double(cellstr(StrDates(:, 5 : 6)));


% Load FF portfolios
Ports_1 = xlsread('monthly_merged_v4.csv');
% Load EW FF portfolios
RetsEW_1 = xlsread('monthly_ew_merged_v4.csv');
% Risk-free rate
RF_1 = FF(:, end) ./ 100;
% Clean data
Ports_Start = Ports_1./ 100 - RF_1;


% Load prices
load('priceM.mat');
% Load Returns
load('retM.mat');
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

% Sample
for Subsample = [196301]
    % Orth or not
    for Orth = [1 0]
        % Title of file
        Title = strcat('Subsample-',num2str(Subsample),'-Orth-',num2str(Orth));
        % Run main file
       run Main_Spec

        Main_Data.X{id} = X; clear X;
        Main_Data.Y{id} = Y; clear Y;
        Main_Data.Z{id} = Z; clear Z;
        Main_Data.W{id} = W; clear W;
        Main_Data.Line_1{id} = Line_1; clear Line_1;
        Main_Data.Line_2{id} = Line_2; clear Line_2;
        Main_Data.MktMean{id} = Mkt_Mean;
        id = id + 1;
    end
end


Mkt_Mean = Main_Data.MktMean{1};

Titles = {'1963 Orth.', '1963 NoOrth', '1927 Orth', '1927 NoOrth'};


%%% IV Betas
% Size IV Betas
IV_Betas_Size = zeros(10, 2);
for i = 1 : 2
    IV_Betas_Size(:, i) = Main_Data.X{i}{1};
end

% Size x BM IV Betas
IV_Betas_SBM = zeros(25, 2);
for i = 1 : 2
    IV_Betas_SBM(:, i) = Main_Data.X{i}{2};
end

% Beta IV Betas
IV_Betas_Beta = zeros(10, 2);
for i = 1 : 2
    IV_Betas_Beta(:, i) = Main_Data.X{i}{3};
end

% Size x Beta IV Betas
IV_Betas_SBT = zeros(25, 2);
for i = 1 : 2
    IV_Betas_SBT(:, i) = Main_Data.X{i}{4};
end

%%% IV Means
% Size IV Means
IV_Means_Size = zeros(10, 2);
for i = 1 : 2
    IV_Means_Size(:, i) = Main_Data.Y{i}{1};
end

% Size x BM IV Means
IV_Means_SBM = zeros(25, 2);
for i = 1 : 2
    IV_Means_SBM(:, i) = Main_Data.Y{i}{2};
end

% Beta IV Means
IV_Means_Beta = zeros(10, 2);
for i = 1 : 2
    IV_Means_Beta(:, i) = Main_Data.Y{i}{3};
end

% Size x Beta IV Means
IV_Means_SBT = zeros(25, 2);
for i = 1 : 2
    IV_Means_SBT(:, i) = Main_Data.Y{i}{4};
end

%%% OLS Betas
% Size OLS Betas
OLS_Betas_Size = zeros(10, 2);
for i = 1 : 2
    OLS_Betas_Size(:, i) = Main_Data.Z{i}{1};
end

% Size x BM OLS Betas
OLS_Betas_SBM = zeros(25, 2);
for i = 1 : 2
    OLS_Betas_SBM(:, i) = Main_Data.Z{i}{2};
end

% Beta OLS Betas
OLS_Betas_Beta = zeros(10, 2);
for i = 1 : 2
    OLS_Betas_Beta(:, i) = Main_Data.Z{i}{3};
end

% Size x Beta OLS Betas
OLS_Betas_SBT = zeros(25, 2);
for i = 1 : 2
    OLS_Betas_SBT(:, i) = Main_Data.Z{i}{4};
end

%%% OLS Means
% Size OLS Means
OLS_Means_Size = zeros(10, 2);
for i = 1 : 2
   OLS_Means_Size(:, i) = Main_Data.W{i}{1};
end

% Size x BM OLS Means
OLS_Means_SBM = zeros(25, 2);
for i = 1 : 2
    OLS_Means_SBM(:, i) = Main_Data.W{i}{2};
end

% Beta OLS Means
OLS_Means_Beta = zeros(10, 2);
for i = 1 : 2
    OLS_Means_Beta(:, i) = Main_Data.W{i}{3};
end

% Size x Beta OLS Means
OLS_Means_SBT = zeros(25, 2);
for i = 1 : 2
    OLS_Means_SBT(:, i) = Main_Data.W{i}{4};
end

% IV Intercepts
IV_Line_Intercepts = zeros(4,2);
for i = 1 : 2
    for j = 1 : 4
    IV_Line_Intercepts(j,i) = Main_Data.Line_1{i}{j}.beta(1);
    end
end

% OLS Intercepts
OLS_Line_Intercepts = zeros(4,2);
for i = 1 : 2
    for j = 1 : 4
    OLS_Line_Intercepts(j,i) = Main_Data.Line_2{i}{j}.beta(1);
    end
end
% IV Slope
IV_Line_Slopes = zeros(4,2);
for i = 1 : 2
    for j = 1 : 4
    IV_Line_Slopes(j,i) = Main_Data.Line_1{i}{j}.beta(2);
    end
end

% OLS slopes
OLS_Line_Slopes = zeros(4,2);
for i = 1 : 2
    for j = 1 : 4
    OLS_Line_Slopes(j,i) = Main_Data.Line_2{i}{j}.beta(2);
    end
end



% Each figure will have 6 plots
figure('Color',[1 1 1],'Units','inches','Position',[1 1 11 8.5]);

    subplot(4,2,1)
    title('Panel 1: 10 Size Ports.')
    X = IV_Betas_Size(:,2);
    % Y axis is 1200 times mean return
    Y = IV_Means_Size(:,2);
    % Alternative X axis is ols beta
    Z = OLS_Betas_Size(:,2);
    W = OLS_Means_Size(:,2);
    % For the fitted lines:
    Line_1 = [IV_Line_Slopes(1,2), IV_Line_Intercepts(1,2)];
    Line_2 = [OLS_Line_Slopes(1,2), OLS_Line_Intercepts(1,2)];
    % Axis is tight, can be changed
    axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
    
    % If portfolio is not a double sort, just plot the portfolio number
    for v=1:length(X)
        text(X(v),Y(v),num2str(v),'Color','blue','FontSize',7)
    end
    % Same for OLS betas
    for v=1:length(X)
        text(Z(v),W(v),num2str(v),'Color','red','FontSize',7)
    end
    
        % Put a legend to the right
        annotation('textbox',[.9 .5 .1 .2],'String',{'\color{red} OLS','\color{blue} IV',...
            '\color{black} - CAPM Implied'},...
            'EdgeColor','none')
    % Add a CAPM line
    hline = refline([1200 .* mean(Mkt_Mean), 0]);
    % Color black for the line
    hline.Color ='black';
    % Add other fitted lines
    hline_1 = refline([Line_1(1), Line_1(2)]);
    hline_1.Color = 'blue';
    hline_1.LineStyle = '--';
    hline_2 = refline([Line_2(1), Line_2(2)]);
    hline_2.Color = 'red';
    hline_2.LineStyle = '--';
    % X axis
    xlabel('Mean Beta');
    % Y axis
    ylabel('Mean Excess Return');
    
     subplot(4,2,2)
    title('Panel 2: 10 Size Ports. (Orth.)')
    X = IV_Betas_Size(:,1);
    % Y axis is 1200 times mean return
    Y = IV_Means_Size(:,1);
    % Alternative X axis is ols beta
    Z = OLS_Betas_Size(:,1);
    W = OLS_Means_Size(:,1);
    % For the fitted lines:
    Line_1 = [IV_Line_Slopes(1,1), IV_Line_Intercepts(1,1)];
    Line_2 = [OLS_Line_Slopes(1,1), OLS_Line_Intercepts(1,1)];
    % Axis is tight, can be changed
    axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
    
    % If portfolio is not a double sort, just plot the portfolio number
    for v=1:length(X)
        text(X(v),Y(v),num2str(v),'Color','blue','FontSize',7)
    end
    % Same for OLS betas
    for v=1:length(X)
        text(Z(v),W(v),num2str(v),'Color','red','FontSize',7)
    end
    
        % Put a legend to the right
        annotation('textbox',[.9 .5 .1 .2],'String',{'\color{red} OLS','\color{blue} IV',...
            '\color{black} - CAPM Implied'},...
            'EdgeColor','none')
    % Add a CAPM line
    hline = refline([1200 .* mean(Mkt_Mean), 0]);
    % Color black for the line
    hline.Color ='black';
    % Add other fitted lines
    hline_1 = refline([Line_1(1), Line_1(2)]);
    hline_1.Color = 'blue';
    hline_1.LineStyle = '--';
    hline_2 = refline([Line_2(1), Line_2(2)]);
    hline_2.Color = 'red';
    hline_2.LineStyle = '--';
    % X axis
    xlabel('Mean Beta');
    % Y axis
    ylabel('Mean Excess Return');
    
   
    
     subplot(4,2,3)
    title('Panel 3: 25 Size by Book-to-Market Ports.')
    X = IV_Betas_SBM(:,2);
    % Y axis is 1200 times mean return
    Y = IV_Means_SBM(:,2);
    % Alternative X axis is ols beta
    Z = OLS_Betas_SBM(:,2);
    W = OLS_Means_SBM(:,2);
    % For the fitted lines:
    Line_1 = [IV_Line_Slopes(2,2), IV_Line_Intercepts(2,2)];
    Line_2 = [OLS_Line_Slopes(2,2), OLS_Line_Intercepts(2,2)];
    % Axis is tight, can be changed
    axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
    
   % d indexes the portfolio (25 total)
    d = 1;
    % n is the first sorting variable
    Port_N = zeros(25, 1);
    for n = 1 : 5
        % m is the second
        for m = 1 : 5
            % In Port_N we just save numbers of form nm
            Port_N(d) = str2double(strcat([num2str(n),num2str(m)]));
            d = d + 1;
        end
    end
    % for length of number of betas
    for v=1:length(X)
        % Plot the actual number stored in Port_N of the portfolio in X-Y coordinate
        text(X(v),Y(v),num2str(Port_N(v)),'Color','blue','FontSize',7)
    end
    % Also do this for OLS betas
    for v=1:length(X)
        text(Z(v),W(v),num2str(Port_N(v)),'Color','red','FontSize',7)
    end
    
    % Add a CAPM line
    hline = refline([1200 .* mean(Mkt_Mean), 0]);
    % Color black for the line
    hline.Color ='black';
    % Add other fitted lines
    hline_1 = refline([Line_1(1), Line_1(2)]);
    hline_1.Color = 'blue';
    hline_1.LineStyle = '--';
    hline_2 = refline([Line_2(1), Line_2(2)]);
    hline_2.Color = 'red';
    hline_2.LineStyle = '--';
    % X axis
    xlabel('Mean Beta');
    % Y axis
    ylabel('Mean Excess Return');
    
     subplot(4,2,4)
    title('Panel 4: 25 Size by Book-to-Market Ports. (Orth.)')
    X = IV_Betas_SBM(:,1);
    % Y axis is 1200 times mean return
    Y = IV_Means_SBM(:,1);
    % Alternative X axis is ols beta
    Z = OLS_Betas_SBM(:,1);
    W = OLS_Means_SBM(:,1);
    % For the fitted lines:
    Line_1 = [IV_Line_Slopes(2,1), IV_Line_Intercepts(2,1)];
    Line_2 = [OLS_Line_Slopes(2,1), OLS_Line_Intercepts(2,1)];
    % Axis is tight, can be changed
    axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
    
   % d indexes the portfolio (25 total)
    d = 1;
    % n is the first sorting variable
    Port_N = zeros(25, 1);
    for n = 1 : 5
        % m is the second
        for m = 1 : 5
            % In Port_N we just save numbers of form nm
            Port_N(d) = str2double(strcat([num2str(n),num2str(m)]));
            d = d + 1;
        end
    end
    % for length of number of betas
    for v=1:length(X)
        % Plot the actual number stored in Port_N of the portfolio in X-Y coordinate
        text(X(v),Y(v),num2str(Port_N(v)),'Color','blue','FontSize',7)
    end
    % Also do this for OLS betas
    for v=1:length(X)
        text(Z(v),W(v),num2str(Port_N(v)),'Color','red','FontSize',7)
    end
    
    % Add a CAPM line
    hline = refline([1200 .* mean(Mkt_Mean), 0]);
    % Color black for the line
    hline.Color ='black';
    % Add other fitted lines
    hline_1 = refline([Line_1(1), Line_1(2)]);
    hline_1.Color = 'blue';
    hline_1.LineStyle = '--';
    hline_2 = refline([Line_2(1), Line_2(2)]);
    hline_2.Color = 'red';
    hline_2.LineStyle = '--';
    % X axis
    xlabel('Mean Beta');
    % Y axis
    ylabel('Mean Excess Return');

 subplot(4,2,5)
    title('Panel 5: 10 Beta Ports.')
    X = IV_Betas_Beta(:,2);
    % Y axis is 1200 times mean return
    Y = IV_Means_Beta(:,2);
    % Alternative X axis is ols beta
    Z = OLS_Betas_Beta(:,2);
    W = OLS_Means_Beta(:,2);
    % For the fitted lines:
    Line_1 = [IV_Line_Slopes(3,2), IV_Line_Intercepts(3,2)];
    Line_2 = [OLS_Line_Slopes(3,2), OLS_Line_Intercepts(3,2)];
    % Axis is tight, can be changed
    axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
    
    % If portfolio is not a double sort, just plot the portfolio number
    for v=1:length(X)
        text(X(v),Y(v),num2str(v),'Color','blue','FontSize',7)
    end
    % Same for OLS betas
    for v=1:length(X)
        text(Z(v),W(v),num2str(v),'Color','red','FontSize',7)
    end
    
        % Put a legend to the right
        annotation('textbox',[.9 .5 .1 .2],'String',{'\color{red} OLS','\color{blue} IV',...
            '\color{black} - CAPM Implied'},...
            'EdgeColor','none')
    % Add a CAPM line
    hline = refline([1200 .* mean(Mkt_Mean), 0]);
    % Color black for the line
    hline.Color ='black';
    % Add other fitted lines
    hline_1 = refline([Line_1(1), Line_1(2)]);
    hline_1.Color = 'blue';
    hline_1.LineStyle = '--';
    hline_2 = refline([Line_2(1), Line_2(2)]);
    hline_2.Color = 'red';
    hline_2.LineStyle = '--';
    % X axis
    xlabel('Mean Beta');
    % Y axis
    ylabel('Mean Excess Return');
    
    subplot(4,2,6)
    title('Panel 6: 10 Beta Ports. (Orth.)')
    X = IV_Betas_Beta(:,1);
    % Y axis is 1200 times mean return
    Y = IV_Means_Beta(:,1);
    % Alternative X axis is ols beta
    Z = OLS_Betas_Beta(:,1);
    W = OLS_Means_Beta(:,1);
    % For the fitted lines:
    Line_1 = [IV_Line_Slopes(3,1), IV_Line_Intercepts(3,1)];
    Line_2 = [OLS_Line_Slopes(3,1), OLS_Line_Intercepts(3,1)];
    % Axis is tight, can be changed
    axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
    
    % If portfolio is not a double sort, just plot the portfolio number
    for v=1:length(X)
        text(X(v),Y(v),num2str(v),'Color','blue','FontSize',7)
    end
    % Same for OLS betas
    for v=1:length(X)
        text(Z(v),W(v),num2str(v),'Color','red','FontSize',7)
    end
    
        % Put a legend to the right
        annotation('textbox',[.9 .5 .1 .2],'String',{'\color{red} OLS','\color{blue} IV',...
            '\color{black} - CAPM Implied'},...
            'EdgeColor','none')
    % Add a CAPM line
    hline = refline([1200 .* mean(Mkt_Mean), 0]);
    % Color black for the line
    hline.Color ='black';
    % Add other fitted lines
    hline_1 = refline([Line_1(1), Line_1(2)]);
    hline_1.Color = 'blue';
    hline_1.LineStyle = '--';
    hline_2 = refline([Line_2(1), Line_2(2)]);
    hline_2.Color = 'red';
    hline_2.LineStyle = '--';
    % X axis
    xlabel('Mean Beta');
    % Y axis
    ylabel('Mean Excess Return');
    
       subplot(4,2,7)
    title('Panel 7: 25 Size by Beta Ports.')
    X = IV_Betas_SBT(:,2);
    % Y axis is 1200 times mean return
    Y = IV_Means_SBT(:,2);
    % Alternative X axis is ols beta
    Z = OLS_Betas_SBT(:,2);
    W = OLS_Means_SBT(:,2);
    % For the fitted lines:
    Line_1 = [IV_Line_Slopes(4,2), IV_Line_Intercepts(4,2)];
    Line_2 = [OLS_Line_Slopes(4,2), OLS_Line_Intercepts(4,2)];
    % Axis is tight, can be changed
    axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
    
   % d indexes the portfolio (25 total)
    d = 1;
    % n is the first sorting variable
    Port_N = zeros(25, 1);
    for n = 1 : 5
        % m is the second
        for m = 1 : 5
            % In Port_N we just save numbers of form nm
            Port_N(d) = str2double(strcat([num2str(n),num2str(m)]));
            d = d + 1;
        end
    end
    % for length of number of betas
    for v=1:length(X)
        % Plot the actual number stored in Port_N of the portfolio in X-Y coordinate
        text(X(v),Y(v),num2str(Port_N(v)),'Color','blue','FontSize',7)
    end
    % Also do this for OLS betas
    for v=1:length(X)
        text(Z(v),W(v),num2str(Port_N(v)),'Color','red','FontSize',7)
    end
    
    % Add a CAPM line
    hline = refline([1200 .* mean(Mkt_Mean), 0]);
    % Color black for the line
    hline.Color ='black';
    % Add other fitted lines
    hline_1 = refline([Line_1(1), Line_1(2)]);
    hline_1.Color = 'blue';
    hline_1.LineStyle = '--';
    hline_2 = refline([Line_2(1), Line_2(2)]);
    hline_2.Color = 'red';
    hline_2.LineStyle = '--';
    % X axis
    xlabel('Mean Beta');
    % Y axis
    ylabel('Mean Excess Return');
    
  
    
     subplot(4,2,8)
    title('Panel 8: 25 Size by Beta Ports. (Orth.)')
    X = IV_Betas_SBT(:,1);
    % Y axis is 1200 times mean return
    Y = IV_Means_SBT(:,1);
    % Alternative X axis is ols beta
    Z = OLS_Betas_SBT(:,1);
    W = OLS_Means_SBT(:,1);
    % For the fitted lines:
    Line_1 = [IV_Line_Slopes(4,1), IV_Line_Intercepts(4,1)];
    Line_2 = [OLS_Line_Slopes(4,1), OLS_Line_Intercepts(4,1)];
    % Axis is tight, can be changed
    axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
    
   % d indexes the portfolio (25 total)
    d = 1;
    % n is the first sorting variable
    Port_N = zeros(25, 1);
    for n = 1 : 5
        % m is the second
        for m = 1 : 5
            % In Port_N we just save numbers of form nm
            Port_N(d) = str2double(strcat([num2str(n),num2str(m)]));
            d = d + 1;
        end
    end
    % for length of number of betas
    for v=1:length(X)
        % Plot the actual number stored in Port_N of the portfolio in X-Y coordinate
        text(X(v),Y(v),num2str(Port_N(v)),'Color','blue','FontSize',7)
    end
    % Also do this for OLS betas
    for v=1:length(X)
        text(Z(v),W(v),num2str(Port_N(v)),'Color','red','FontSize',7)
    end
    
    % Add a CAPM line
    hline = refline([1200 .* mean(Mkt_Mean), 0]);
    % Color black for the line
    hline.Color ='black';
    % Add other fitted lines
    hline_1 = refline([Line_1(1), Line_1(2)]);
    hline_1.Color = 'blue';
    hline_1.LineStyle = '--';
    hline_2 = refline([Line_2(1), Line_2(2)]);
    hline_2.Color = 'red';
    hline_2.LineStyle = '--';
    % X axis
    xlabel('Mean Beta');
    % Y axis
    ylabel('Mean Excess Return');


% landscape looks better
orient(gcf,'landscape');
export_fig(strcat('Merged','.pdf'));
close(gcf);

%%%%%%%%%%%%%%%%% Second plot
% 
% figure('Color',[1 1 1],'Units','inches','Position',[1 1 11 8.5]);
% % Title at the top of all subplots
%    
%     subplot(2,2,1)
%     title('Panel 1: 10 Beta Ports.')
%     X = IV_Betas_Beta(:,2);
%     % Y axis is 1200 times mean return
%     Y = IV_Means_Beta(:,2);
%     % Alternative X axis is ols beta
%     Z = OLS_Betas_Beta(:,2);
%     W = OLS_Means_Beta(:,2);
%     % For the fitted lines:
%     Line_1 = [IV_Line_Slopes(3,2), IV_Line_Intercepts(3,2)];
%     Line_2 = [OLS_Line_Slopes(3,2), OLS_Line_Intercepts(3,2)];
%     % Axis is tight, can be changed
%     axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
%     
%     % If portfolio is not a double sort, just plot the portfolio number
%     for v=1:length(X)
%         text(X(v),Y(v),num2str(v),'Color','blue','FontSize',7)
%     end
%     % Same for OLS betas
%     for v=1:length(X)
%         text(Z(v),W(v),num2str(v),'Color','red','FontSize',7)
%     end
%     
%         % Put a legend to the right
%         annotation('textbox',[.9 .5 .1 .2],'String',{'\color{red} OLS','\color{blue} IV',...
%             '\color{black} - CAPM Implied'},...
%             'EdgeColor','none')
%     % Add a CAPM line
%     hline = refline([1200 .* mean(Mkt_Mean), 0]);
%     % Color black for the line
%     hline.Color ='black';
%     % Add other fitted lines
%     hline_1 = refline([Line_1(1), Line_1(2)]);
%     hline_1.Color = 'blue';
%     hline_1.LineStyle = '--';
%     hline_2 = refline([Line_2(1), Line_2(2)]);
%     hline_2.Color = 'red';
%     hline_2.LineStyle = '--';
%     % X axis
%     xlabel('Mean Beta');
%     % Y axis
%     ylabel('Mean Excess Return');
%     
%      subplot(2,2,2)
%     title('Panel 2: 25 Size by Beta Ports.')
%     X = IV_Betas_SBT(:,2);
%     % Y axis is 1200 times mean return
%     Y = IV_Means_SBT(:,2);
%     % Alternative X axis is ols beta
%     Z = OLS_Betas_SBT(:,2);
%     W = OLS_Means_SBT(:,2);
%     % For the fitted lines:
%     Line_1 = [IV_Line_Slopes(4,2), IV_Line_Intercepts(4,2)];
%     Line_2 = [OLS_Line_Slopes(4,2), OLS_Line_Intercepts(4,2)];
%     % Axis is tight, can be changed
%     axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
%     
%    % d indexes the portfolio (25 total)
%     d = 1;
%     % n is the first sorting variable
%     Port_N = zeros(25, 1);
%     for n = 1 : 5
%         % m is the second
%         for m = 1 : 5
%             % In Port_N we just save numbers of form nm
%             Port_N(d) = str2double(strcat([num2str(n),num2str(m)]));
%             d = d + 1;
%         end
%     end
%     % for length of number of betas
%     for v=1:length(X)
%         % Plot the actual number stored in Port_N of the portfolio in X-Y coordinate
%         text(X(v),Y(v),num2str(Port_N(v)),'Color','blue','FontSize',7)
%     end
%     % Also do this for OLS betas
%     for v=1:length(X)
%         text(Z(v),W(v),num2str(Port_N(v)),'Color','red','FontSize',7)
%     end
%     
%     % Add a CAPM line
%     hline = refline([1200 .* mean(Mkt_Mean), 0]);
%     % Color black for the line
%     hline.Color ='black';
%     % Add other fitted lines
%     hline_1 = refline([Line_1(1), Line_1(2)]);
%     hline_1.Color = 'blue';
%     hline_1.LineStyle = '--';
%     hline_2 = refline([Line_2(1), Line_2(2)]);
%     hline_2.Color = 'red';
%     hline_2.LineStyle = '--';
%     % X axis
%     xlabel('Mean Beta');
%     % Y axis
%     ylabel('Mean Excess Return');
%     
%     subplot(2,2,3)
%     title('Panel 3: 10 Beta Ports. (Orth.)')
%     X = IV_Betas_Beta(:,1);
%     % Y axis is 1200 times mean return
%     Y = IV_Means_Beta(:,1);
%     % Alternative X axis is ols beta
%     Z = OLS_Betas_Beta(:,1);
%     W = OLS_Means_Beta(:,1);
%     % For the fitted lines:
%     Line_1 = [IV_Line_Slopes(3,1), IV_Line_Intercepts(3,1)];
%     Line_2 = [OLS_Line_Slopes(3,1), OLS_Line_Intercepts(3,1)];
%     % Axis is tight, can be changed
%     axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
%     
%     % If portfolio is not a double sort, just plot the portfolio number
%     for v=1:length(X)
%         text(X(v),Y(v),num2str(v),'Color','blue','FontSize',7)
%     end
%     % Same for OLS betas
%     for v=1:length(X)
%         text(Z(v),W(v),num2str(v),'Color','red','FontSize',7)
%     end
%     
%         % Put a legend to the right
%         annotation('textbox',[.9 .5 .1 .2],'String',{'\color{red} OLS','\color{blue} IV',...
%             '\color{black} - CAPM Implied'},...
%             'EdgeColor','none')
%     % Add a CAPM line
%     hline = refline([1200 .* mean(Mkt_Mean), 0]);
%     % Color black for the line
%     hline.Color ='black';
%     % Add other fitted lines
%     hline_1 = refline([Line_1(1), Line_1(2)]);
%     hline_1.Color = 'blue';
%     hline_1.LineStyle = '--';
%     hline_2 = refline([Line_2(1), Line_2(2)]);
%     hline_2.Color = 'red';
%     hline_2.LineStyle = '--';
%     % X axis
%     xlabel('Mean Beta');
%     % Y axis
%     ylabel('Mean Excess Return');
%     
%      subplot(2,2,4)
%     title('Panel 4: 25 Size by Beta Ports. (Orth.)')
%     X = IV_Betas_SBT(:,1);
%     % Y axis is 1200 times mean return
%     Y = IV_Means_SBT(:,1);
%     % Alternative X axis is ols beta
%     Z = OLS_Betas_SBT(:,1);
%     W = OLS_Means_SBT(:,1);
%     % For the fitted lines:
%     Line_1 = [IV_Line_Slopes(4,1), IV_Line_Intercepts(4,1)];
%     Line_2 = [OLS_Line_Slopes(4,1), OLS_Line_Intercepts(4,1)];
%     % Axis is tight, can be changed
%     axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
%     
%    % d indexes the portfolio (25 total)
%     d = 1;
%     % n is the first sorting variable
%     Port_N = zeros(25, 1);
%     for n = 1 : 5
%         % m is the second
%         for m = 1 : 5
%             % In Port_N we just save numbers of form nm
%             Port_N(d) = str2double(strcat([num2str(n),num2str(m)]));
%             d = d + 1;
%         end
%     end
%     % for length of number of betas
%     for v=1:length(X)
%         % Plot the actual number stored in Port_N of the portfolio in X-Y coordinate
%         text(X(v),Y(v),num2str(Port_N(v)),'Color','blue','FontSize',7)
%     end
%     % Also do this for OLS betas
%     for v=1:length(X)
%         text(Z(v),W(v),num2str(Port_N(v)),'Color','red','FontSize',7)
%     end
%     
%     % Add a CAPM line
%     hline = refline([1200 .* mean(Mkt_Mean), 0]);
%     % Color black for the line
%     hline.Color ='black';
%     % Add other fitted lines
%     hline_1 = refline([Line_1(1), Line_1(2)]);
%     hline_1.Color = 'blue';
%     hline_1.LineStyle = '--';
%     hline_2 = refline([Line_2(1), Line_2(2)]);
%     hline_2.Color = 'red';
%     hline_2.LineStyle = '--';
%     % X axis
%     xlabel('Mean Beta');
%     % Y axis
%     ylabel('Mean Excess Return');
% 
% 
% 
% % landscape looks better
% orient(gcf,'landscape');
% export_fig(strcat('SizeAndBeta','.pdf'));
% close(gcf);

% 
% %%%% First plot is size
% 
% IV_Betas = zeros(10, 4);
% for i = 1 : 4
%     IV_Betas(:, i) = Main_Data.X{i}{2};
% end
% 
% IV_Means = zeros(10, 4);
% for i = 1 : 4
%     IV_Means(:, i) = Main_Data.Y{i}{2};
% end
% 
% OLS_Betas = zeros(10, 4);
% for i = 1 : 4
%     OLS_Betas(:, i) = Main_Data.Z{i}{2};
% end
% 
% OLS_Means = zeros(10, 4);
% for i = 1 : 4
%     OLS_Means(:, i) = Main_Data.W{i}{2};
% end
% 
% IV_Line_Intercept = zeros(4,1);
% for i = 1 : 4
%     IV_Line_Intercept(i) = Main_Data.Line_1{i}{2}.beta(1);
% end
% 
% OLS_Line_Intercept = zeros(4,1);
% for i = 1 : 4
%     OLS_Line_Intercept(i) = Main_Data.Line_2{i}{2}.beta(1);
% end
% 
% IV_Line_Slope = zeros(4,1);
% for i = 1 : 4
%     IV_Line_Slope(i) = Main_Data.Line_1{i}{2}.beta(2);
% end
% 
% OLS_Line_Slope = zeros(4,1);
% for i = 1 : 4
%     OLS_Line_Slope(i) = Main_Data.Line_2{i}{2}.beta(2);
% end
% 
% 
% 
% % Each figure will have 6 plots
% figure('Color',[1 1 1],'Units','inches','Position',[1 1 11 8.5]);
% % Title at the top of all subplots
% suptitle('BM');
% 
% for p = 1 : 4
%     
%     % 3 by 2, can be changed
%     subplot(2,2,p)
%     %                                     % X axis is mean beta
%     X = IV_Betas(:,p);
%     % Y axis is 1200 times mean return
%     Y = IV_Means(:,p);
%     % Alternative X axis is ols beta
%     Z = OLS_Betas(:,p);
%     W = OLS_Means(:,p);
%     % For the fitted lines:
%     Line_1 = [IV_Line_Slope(p), IV_Line_Intercept(p)];
%     Line_2 = [OLS_Line_Slope(p), OLS_Line_Intercept(p)];
%     % Axis is tight, can be changed
%     axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
%     
%     % If portfolio is not a double sort, just plot the portfolio number
%     for v=1:length(X)
%         text(X(v),Y(v),num2str(v),'Color','blue','FontSize',7)
%     end
%     % Same for OLS betas
%     for v=1:length(X)
%         text(Z(v),W(v),num2str(v),'Color','red','FontSize',7)
%     end
%     
%     
%     
%     
%     % for the first subplot
%     if p == 1
%         % Put a legend to the right
%         annotation('textbox',[.9 .5 .1 .2],'String',{'\color{red} OLS','\color{blue} IV',...
%             '\color{black} - CAPM Implied'},...
%             'EdgeColor','none')
%     end
%     
%     % Title of each subplot will just be the portfolio sort
%     title(Titles{p});
%     % Add a CAPM line
%     hline = refline([1200 .* mean(Mkt_Mean{p}), 0]);
%     % Color black for the line
%     hline.Color ='black';
%     % Add other fitted lines
%     hline_1 = refline([Line_1(1), Line_1(2)]);
%     hline_1.Color = 'blue';
%     hline_1.LineStyle = '--';
%     hline_2 = refline([Line_2(1), Line_2(2)]);
%     hline_2.Color = 'red';
%     hline_2.LineStyle = '--';
%     % X axis
%     xlabel('Mean Beta');
%     % Y axis
%     ylabel('Mean Excess Return');
% end
% % landscape looks better
% orient(gcf,'landscape');
% export_fig(strcat('BM','.pdf'));
% close(gcf);
% 
% % Final is 5x5
% 
% 
% IV_Betas = zeros(25, 4);
% for i = 1 : 4
%     IV_Betas(:, i) = Main_Data.X{i}{3};
% end
% 
% IV_Means = zeros(25, 4);
% for i = 1 : 4
%     IV_Means(:, i) = Main_Data.Y{i}{3};
% end
% 
% OLS_Betas = zeros(25, 4);
% for i = 1 : 4
%     OLS_Betas(:, i) = Main_Data.Z{i}{3};
% end
% 
% OLS_Means = zeros(25, 4);
% for i = 1 : 4
%     OLS_Means(:, i) = Main_Data.W{i}{3};
% end
% 
% IV_Line_Intercept = zeros(4,1);
% for i = 1 : 4
%     IV_Line_Intercept(i) = Main_Data.Line_1{i}{3}.beta(1);
% end
% 
% OLS_Line_Intercept = zeros(4,1);
% for i = 1 : 4
%     OLS_Line_Intercept(i) = Main_Data.Line_2{i}{3}.beta(1);
% end
% 
% IV_Line_Slope = zeros(4,1);
% for i = 1 : 4
%     IV_Line_Slope(i) = Main_Data.Line_1{i}{3}.beta(2);
% end
% 
% OLS_Line_Slope = zeros(4,1);
% for i = 1 : 4
%     OLS_Line_Slope(i) = Main_Data.Line_2{i}{3}.beta(2);
% end
% 
% 
% 
% % Each figure will have 6 plots
% figure('Color',[1 1 1],'Units','inches','Position',[1 1 11 8.5]);
% % Title at the top of all subplots
% suptitle('Size by BM');
% 
% for p = 1 : 4
%     
%     % 3 by 2, can be changed
%     subplot(2,2,p)
%     %                                     % X axis is mean beta
%     X = IV_Betas(:,p);
%     % Y axis is 1200 times mean return
%     Y = IV_Means(:,p);
%     % Alternative X axis is ols beta
%     Z = OLS_Betas(:,p);
%     W = OLS_Means(:,p);
%     % For the fitted lines:
%     Line_1 = [IV_Line_Slope(p), IV_Line_Intercept(p)];
%     Line_2 = [OLS_Line_Slope(p), OLS_Line_Intercept(p)];
%     % Axis is tight, can be changed
%     axis([min([X;Z]), max([X;Z]), min([Y;W]), max([Y;W])])
%     
%     % d indexes the portfolio (25 total)
%     d = 1;
%     % n is the first sorting variable
%     Port_N = zeros(25, 1);
%     for n = 1 : 5
%         % m is the second
%         for m = 1 : 5
%             % In Port_N we just save numbers of form nm
%             Port_N(d) = str2double(strcat([num2str(n),num2str(m)]));
%             d = d + 1;
%         end
%     end
%     % for length of number of betas
%     for v=1:length(X)
%         % Plot the actual number stored in Port_N of the portfolio in X-Y coordinate
%         text(X(v),Y(v),num2str(Port_N(v)),'Color','blue','FontSize',7)
%     end
%     % Also do this for OLS betas
%     for v=1:length(X)
%         text(Z(v),W(v),num2str(Port_N(v)),'Color','red','FontSize',7)
%     end
%     
%     
%     
%     % for the first subplot
%     if p == 1
%         % Put a legend to the right
%         annotation('textbox',[.9 .5 .1 .2],'String',{'\color{red} OLS','\color{blue} IV',...
%             '\color{black} - CAPM Implied'},...
%             'EdgeColor','none')
%     end
%     
%     % Title of each subplot will just be the portfolio sort
%     title(Titles{p});
%     % Add a CAPM line
%     hline = refline([1200 .* mean(Mkt_Mean{p}), 0]);
%     % Color black for the line
%     hline.Color ='black';
%     % Add other fitted lines
%     hline_1 = refline([Line_1(1), Line_1(2)]);
%     hline_1.Color = 'blue';
%     hline_1.LineStyle = '--';
%     hline_2 = refline([Line_2(1), Line_2(2)]);
%     hline_2.Color = 'red';
%     hline_2.LineStyle = '--';
%     % X axis
%     xlabel('Mean Beta');
%     % Y axis
%     ylabel('Mean Excess Return');
% end
% % landscape looks better
% orient(gcf,'landscape');
% export_fig(strcat('SB','.pdf'));
% close(gcf);

%%%%%%%%%%%%%%% Big Figs, 1963

P_Select = 1:length(Names);
clear Line_1 Line_2 Main_Data
id=1;
% Sample
Subsample = 196301;
for Orth = [1 0]
% Title of file
Title = strcat('Subsample-',num2str(Subsample),'-Orth-',num2str(Orth));
% Run main file
run Main_Spec_Big_Fig_MAZI_NEWEST
Main_Data.X{id} = X; clear X;
Main_Data.Y{id} = Y; clear Y;
Main_Data.Z{id} = Z; clear Z;
Main_Data.W{id} = W; clear W;
Main_Data.Line_1{id} = Line_1; clear Line_1;
Main_Data.Line_2{id} = Line_2; clear Line_2;
Main_Data.MktMean{id} = Mkt_Mean;
Main_Data.Sizes{id} = S;
id = id + 1;
end
%%%%%%%%%%%%%%%%%% Orth
IV_Betas_Orth = cell2mat(Main_Data.X{1}');
IV_Means_Orth = cell2mat(Main_Data.Y{1}');
OLS_Betas_Orth = cell2mat(Main_Data.Z{1}');
OLS_Means_Orth = cell2mat(Main_Data.W{1}');
Sizes_Orth = cell2mat(Main_Data.Sizes{1}');
LS_Orth = log(Sizes_Orth);
L_Diff_Beta_Orth = log(OLS_Betas_Orth) - log(IV_Betas_Orth);




IV_Line_Orth  = lad(IV_Means_Orth', [ones(length(IV_Means_Orth),1), IV_Betas_Orth']);
OLS_Line_Orth  = lad(OLS_Means_Orth', [ones(length(OLS_Means_Orth),1), OLS_Betas_Orth']);
Size_Line_Orth  = lad(L_Diff_Beta_Orth', [ones(length(LS_Orth),1),LS_Orth']);

IV_Line_Fit_Orth = polyval([IV_Line_Orth.beta(2), IV_Line_Orth.beta(1)], IV_Betas_Orth');
OLS_Line_Fit_Orth = polyval([OLS_Line_Orth.beta(2), OLS_Line_Orth.beta(1)], OLS_Betas_Orth');
Size_Line_Fit_Orth = polyval([Size_Line_Orth.beta(2), Size_Line_Orth.beta(1)], LS_Orth');

load Boot_Big_Fig_Orth.mat

Slopes_Diff_Orth = zeros(length(Size_Line),1);
for i = 1 :length(Size_Line)
   Slopes_Diff_Orth(i) = Size_Line{i}(2);
end

Int_Diff_Orth = zeros(length(Size_Line),1);
for i = 1 :length(Size_Line)
   Int_Diff_Orth(i) = Size_Line{i}(1);
end

Diff_Cov_Orth = cov([Int_Diff_Orth,Slopes_Diff_Orth]);
Sort_LS_Orth= sort(LS_Orth);
for i = 1 : length(LS_Orth)
  SE_Diff_Orth(i) = sqrt([1, Sort_LS_Orth(i)] * Diff_Cov_Orth *[1 ; Sort_LS_Orth(i)]);
end
%%%%%%%%%%%%%%%%%%%%%%%%
Slopes_IV_Orth = zeros(length(IV_Line),1);
for i = 1 :length(IV_Line)
   Slopes_IV_Orth(i) = IV_Line{i}(2);
end

Int_IV_Orth = zeros(length(IV_Line),1);
for i = 1 :length(IV_Line)
   Int_IV_Orth(i) = IV_Line{i}(1);
end

IV_Cov_Orth = cov([Int_IV_Orth,Slopes_IV_Orth]);

Sort_IV_Betas_Orth = sort(IV_Betas_Orth);
for i = 1 : length(IV_Betas_Orth)
  SE_IV_Orth(i) = sqrt([1, Sort_IV_Betas_Orth(i)] * IV_Cov_Orth *[1 ; Sort_IV_Betas_Orth(i)]);
end

%%%%%%%%%%%
Slopes_OLS_Orth = zeros(length(OLS_Line),1);
for i = 1 :length(OLS_Line)
   Slopes_OLS_Orth(i) = OLS_Line{i}(2);
end

Int_OLS_Orth = zeros(length(OLS_Line),1);
for i = 1 :length(OLS_Line)
   Int_OLS_Orth(i) = OLS_Line{i}(1);
end

OLS_Cov_Orth = cov([Int_OLS_Orth,Slopes_OLS_Orth]);

Sort_OLS_Betas_Orth = sort(OLS_Betas_Orth);
for i = 1 : length(OLS_Betas_Orth)
  SE_OLS_Orth(i) = sqrt([1, Sort_OLS_Betas_Orth(i)] * OLS_Cov_Orth *[1 ; Sort_OLS_Betas_Orth(i)]);
end




b = 49/(max(Sizes_Orth)-min(Sizes_Orth));
a = 1 - b*min(Sizes_Orth);

Normalized_Size_Orth = a + b .* Sizes_Orth;

MX_Orth = max([IV_Betas_Orth,OLS_Betas_Orth]);
mX_Orth = min([IV_Betas_Orth,OLS_Betas_Orth]);
MY_Orth = max([1200 .* IV_Means_Orth,1200 .* OLS_Means_Orth]);
mY_Orth = min([1200 .* IV_Means_Orth,1200 .* OLS_Means_Orth]);

Upper_Diff_Orth = Size_Line_Orth.beta(1) +Size_Line_Orth.beta(2)*Sort_LS_Orth + 1.96 *SE_Diff_Orth;
Lower_Diff_Orth = Size_Line_Orth.beta(1) +Size_Line_Orth.beta(2)*Sort_LS_Orth - 1.96 *SE_Diff_Orth;

Upper_IV_Orth = IV_Line_Orth.beta(1) +IV_Line_Orth.beta(2)*Sort_IV_Betas_Orth + 1.96 *SE_IV_Orth;
Lower_IV_Orth = IV_Line_Orth.beta(1) +IV_Line_Orth.beta(2)*Sort_IV_Betas_Orth - 1.96 *SE_IV_Orth;

Upper_OLS_Orth = OLS_Line_Orth.beta(1) +OLS_Line_Orth.beta(2)*Sort_OLS_Betas_Orth + 1.96 *SE_OLS_Orth;
Lower_OLS_Orth = OLS_Line_Orth.beta(1) +OLS_Line_Orth.beta(2)*Sort_OLS_Betas_Orth - 1.96 *SE_OLS_Orth;

Zero_Line_Orth = 0 * linspace(mX_Orth, MX_Orth, length(IV_Means_Orth));
CAPM_Line_Orth = (1200 .* nanmean(Mkt_Mean)) *  linspace(mX_Orth, MX_Orth, length(IV_Means_Orth));


%%%%%%%%%%%%%%%%%% No Orth
IV_Betas_NoOrth = cell2mat(Main_Data.X{2}');
IV_Means_NoOrth = cell2mat(Main_Data.Y{2}');
OLS_Betas_NoOrth = cell2mat(Main_Data.Z{2}');
OLS_Means_NoOrth = cell2mat(Main_Data.W{2}');
Sizes_NoOrth = cell2mat(Main_Data.Sizes{2}');
LS_NoOrth = log(Sizes_NoOrth);
L_Diff_Beta_NoOrth = log(OLS_Betas_NoOrth) - log(IV_Betas_NoOrth);

IV_NoOrth_Hist = ksdensity(IV_Betas_NoOrth,linspace(min([IV_Betas_NoOrth,OLS_Betas_NoOrth,OLS_Betas_Orth]),...
    max([IV_Betas_NoOrth,OLS_Betas_NoOrth,OLS_Betas_Orth]),1000));
OLS_NoOrth_Hist = ksdensity(OLS_Betas_NoOrth,linspace(min([IV_Betas_NoOrth,OLS_Betas_NoOrth,OLS_Betas_Orth]),...
    max([IV_Betas_NoOrth,OLS_Betas_NoOrth,OLS_Betas_Orth]),1000));
[OLS_Orth_Hist,Xi] = ksdensity(OLS_Betas_Orth,linspace(min([IV_Betas_NoOrth,OLS_Betas_NoOrth,OLS_Betas_Orth]),...
    max([IV_Betas_NoOrth,OLS_Betas_NoOrth,OLS_Betas_Orth]),1000));

IV_Pctile = prctile(IV_Betas_NoOrth,[5,50,95]);
OLS_Pctile =prctile(OLS_Betas_NoOrth,[5,50,95]);

figure('Color',[1 1 1],'Units','inches','Position',[1 1 9 5]);
plot(Xi,IV_NoOrth_Hist,'LineWidth',2,'LineStyle','-.')
hold on
plot(Xi,OLS_NoOrth_Hist,'LineWidth',2)
for i = 1:size(IV_Pctile,2)
hold on
plot([IV_Pctile(i),IV_Pctile(i)],[0,max([IV_NoOrth_Hist,OLS_NoOrth_Hist])],...
    'Color','b','LineStyle','-.','LineWidth',1)
hold on
plot([OLS_Pctile(i),OLS_Pctile(i)],[0,max([IV_NoOrth_Hist,OLS_NoOrth_Hist])],...
    'Color','r','LineStyle','--','LineWidth',1)
end
legend('IV Beta','OLS Beta')
xlim([0.4,2])
xlabel('Market Beta')
ylabel('Density')
orient(gcf,'landscape');
export_fig(strcat('BetaHist','.pdf'));
close(gcf);

IV_Pctile = prctile(IV_Betas_NoOrth,[1,5:5:95,99]);
OLS_Pctile =prctile(OLS_Betas_NoOrth,[1,5:5:95,99]);

PCT = [1, 5:5:95,99;IV_Pctile;OLS_Pctile];


IV_Line_NoOrth  = lad(IV_Means_NoOrth', [ones(length(IV_Means_NoOrth),1), IV_Betas_NoOrth']);
OLS_Line_NoOrth  = lad(OLS_Means_NoOrth', [ones(length(OLS_Means_NoOrth),1), OLS_Betas_NoOrth']);
Size_Line_NoOrth  = lad(L_Diff_Beta_NoOrth', [ones(length(LS_NoOrth),1),LS_NoOrth']);

IV_Line_Fit_NoOrth = polyval([IV_Line_NoOrth.beta(2), IV_Line_NoOrth.beta(1)], IV_Betas_NoOrth');
OLS_Line_Fit_NoOrth = polyval([OLS_Line_NoOrth.beta(2), OLS_Line_NoOrth.beta(1)], OLS_Betas_NoOrth');
Size_Line_Fit_NoOrth = polyval([Size_Line_NoOrth.beta(2), Size_Line_NoOrth.beta(1)], LS_NoOrth');

load Boot_Big_Fig_NoOrth.mat

Slopes_Diff_NoOrth = zeros(length(Size_Line),1);
for i = 1 :length(Size_Line)
   Slopes_Diff_NoOrth(i) = Size_Line{i}(2);
end

Int_Diff_NoOrth = zeros(length(Size_Line),1);
for i = 1 :length(Size_Line)
   Int_Diff_NoOrth(i) = Size_Line{i}(1);
end

Diff_Cov_NoOrth = cov([Int_Diff_NoOrth,Slopes_Diff_NoOrth]);
Sort_LS_NoOrth= sort(LS_NoOrth);
for i = 1 : length(LS_NoOrth)
  SE_Diff_NoOrth(i) = sqrt([1, Sort_LS_NoOrth(i)] * Diff_Cov_NoOrth *[1 ; Sort_LS_NoOrth(i)]);
end
%%%%%%%%%%%%%%%%%%%%%%%%
Slopes_IV_NoOrth = zeros(length(IV_Line),1);
for i = 1 :length(IV_Line)
   Slopes_IV_NoOrth(i) = IV_Line{i}(2);
end

Int_IV_NoOrth = zeros(length(IV_Line),1);
for i = 1 :length(IV_Line)
   Int_IV_NoOrth(i) = IV_Line{i}(1);
end

IV_Cov_NoOrth = cov([Int_IV_NoOrth,Slopes_IV_NoOrth]);

Sort_IV_Betas_NoOrth = sort(IV_Betas_NoOrth);
for i = 1 : length(IV_Betas_NoOrth)
  SE_IV_NoOrth(i) = sqrt([1, Sort_IV_Betas_NoOrth(i)] * IV_Cov_NoOrth *[1 ; Sort_IV_Betas_NoOrth(i)]);
end

%%%%%%%%%%%
Slopes_OLS_NoOrth = zeros(length(OLS_Line),1);
for i = 1 :length(OLS_Line)
   Slopes_OLS_NoOrth(i) = OLS_Line{i}(2);
end

Int_OLS_NoOrth = zeros(length(OLS_Line),1);
for i = 1 :length(OLS_Line)
   Int_OLS_NoOrth(i) = OLS_Line{i}(1);
end

OLS_Cov_NoOrth = cov([Int_OLS_NoOrth,Slopes_OLS_NoOrth]);

Sort_OLS_Betas_NoOrth = sort(OLS_Betas_NoOrth);
for i = 1 : length(OLS_Betas_NoOrth)
  SE_OLS_NoOrth(i) = sqrt([1, Sort_OLS_Betas_NoOrth(i)] * OLS_Cov_NoOrth *[1 ; Sort_OLS_Betas_NoOrth(i)]);
end




b = 49/(max(Sizes_NoOrth)-min(Sizes_NoOrth));
a = 1 - b*min(Sizes_NoOrth);

Normalized_Size_NoOrth = a + b .* Sizes_NoOrth;

MX_NoOrth = max([IV_Betas_NoOrth,OLS_Betas_NoOrth]);
mX_NoOrth = min([IV_Betas_NoOrth,OLS_Betas_NoOrth]);
MY_NoOrth = max([1200 .* IV_Means_NoOrth,1200 .* OLS_Means_NoOrth]);
mY_NoOrth = min([1200 .* IV_Means_NoOrth,1200 .* OLS_Means_NoOrth]);

Upper_Diff_NoOrth = Size_Line_NoOrth.beta(1) +Size_Line_NoOrth.beta(2)*Sort_LS_NoOrth + 1.96 *SE_Diff_NoOrth;
Lower_Diff_NoOrth = Size_Line_NoOrth.beta(1) +Size_Line_NoOrth.beta(2)*Sort_LS_NoOrth - 1.96 *SE_Diff_NoOrth;

Upper_IV_NoOrth = IV_Line_NoOrth.beta(1) +IV_Line_NoOrth.beta(2)*Sort_IV_Betas_NoOrth + 1.96 *SE_IV_NoOrth;
Lower_IV_NoOrth = IV_Line_NoOrth.beta(1) +IV_Line_NoOrth.beta(2)*Sort_IV_Betas_NoOrth - 1.96 *SE_IV_NoOrth;

Upper_OLS_NoOrth = OLS_Line_NoOrth.beta(1) +OLS_Line_NoOrth.beta(2)*Sort_OLS_Betas_NoOrth + 1.96 *SE_OLS_NoOrth;
Lower_OLS_NoOrth = OLS_Line_NoOrth.beta(1) +OLS_Line_NoOrth.beta(2)*Sort_OLS_Betas_NoOrth - 1.96 *SE_OLS_NoOrth;


Zero_Line_NoOrth = 0 * linspace(mX_NoOrth, MX_NoOrth, length(IV_Means_NoOrth));
CAPM_Line_NoOrth = (1200 .* nanmean(Mkt_Mean)) *  linspace(mX_NoOrth, MX_NoOrth, length(IV_Means_NoOrth));


Fig =figure('Color',[1 1 1],'Units','inches','Position',[1 1 11 8.5]);
% Title at the top of all subplots
%%%%%%%%%%%%%%
ax1= subplot(2,3,1);
axis([mX_NoOrth MX_NoOrth mY_NoOrth MY_NoOrth])

scatter(OLS_Betas_NoOrth,OLS_Means_NoOrth,Normalized_Size_NoOrth)
hold on
plot(OLS_Betas_NoOrth, OLS_Line_Fit_NoOrth,'Color','red')
hold on
plot(linspace(mX_NoOrth, MX_NoOrth, length(OLS_Betas_NoOrth)), CAPM_Line_NoOrth, 'k')
hold on
plot((linspace(mX_NoOrth, MX_NoOrth, length(OLS_Betas_NoOrth))), Zero_Line_NoOrth,'LineStyle', ':','Color','k')
hold on
plot(Sort_OLS_Betas_NoOrth, Upper_OLS_NoOrth,'LineStyle', '--','Color','red')
hold on
plot(Sort_OLS_Betas_NoOrth, Lower_OLS_NoOrth,'LineStyle', '--','Color','red')
legend({'Data',strcat('Slope = ',...
    num2str(OLS_Line_NoOrth.beta(2))),'CAPM Implied'},'Location','best')
title('Panel 1: SML - OLS')


xlabel('Mean Beta')
ylabel('Mean Excess Return')

%%%%%%%%%%%%
ax2= subplot(2,3,2);
axis([mX_NoOrth MX_NoOrth mY_NoOrth MY_NoOrth])

scatter(IV_Betas_NoOrth,IV_Means_NoOrth,Normalized_Size_NoOrth)
hold on
plot(IV_Betas_NoOrth, IV_Line_Fit_NoOrth,'Color','red')
hold on
plot(linspace(mX_NoOrth, MX_NoOrth, length(IV_Betas_NoOrth)), CAPM_Line_NoOrth, 'k')
hold on
plot((linspace(mX_NoOrth, MX_NoOrth, length(IV_Betas_NoOrth))), Zero_Line_NoOrth,'LineStyle', ':','Color','k')
hold on
plot(Sort_IV_Betas_NoOrth, Upper_IV_NoOrth,'LineStyle', '--','Color','red')
hold on
plot(Sort_IV_Betas_NoOrth, Lower_IV_NoOrth,'LineStyle', '--','Color','red')
legend({'Data',strcat('Slope = ',...
    num2str(IV_Line_NoOrth.beta(2))),'CAPM Implied'},'Location','best')
title('Panel 2: SML - IV')
linkaxes([ax2,ax1],'xy')
xlabel('Mean Beta')
ylabel('Mean Excess Return')
%%%%%%%%%%%%%%%%%%%%%%%%%
ax3= subplot(2,3,3);
axis([mX_Orth MX_Orth mY_Orth MY_Orth])

scatter(OLS_Betas_Orth,OLS_Means_Orth,Normalized_Size_Orth)
hold on
plot(OLS_Betas_Orth, OLS_Line_Fit_Orth,'Color','red')
hold on
plot(linspace(mX_Orth, MX_Orth, length(OLS_Betas_Orth)), CAPM_Line_Orth, 'k')
hold on
plot((linspace(mX_Orth, MX_Orth, length(OLS_Betas_Orth))), Zero_Line_Orth,'LineStyle', ':','Color','k')
hold on
plot(Sort_OLS_Betas_Orth, Upper_OLS_Orth,'LineStyle', '--','Color','red')
hold on
plot(Sort_OLS_Betas_Orth, Lower_OLS_Orth,'LineStyle', '--','Color','red')
legend({'Data',strcat('Slope = ',...
    num2str(OLS_Line_Orth.beta(2))),'CAPM Implied'},'Location','best')
title('Panel 3: SML - OLS (Orth.)')


xlabel('Mean Beta')
ylabel('Mean Excess Return')

%%%%%%%%%%%%%%%%%%%%%%%%
ax4= subplot(2,3,4);
axis([mX_Orth MX_Orth mY_Orth MY_Orth])

scatter(IV_Betas_Orth,IV_Means_Orth,Normalized_Size_Orth)
hold on
plot(IV_Betas_Orth, IV_Line_Fit_Orth,'Color','red')
hold on
plot(linspace(mX_Orth, MX_Orth, length(IV_Betas_Orth)), CAPM_Line_Orth, 'k')
hold on
plot((linspace(mX_Orth, MX_Orth, length(IV_Betas_Orth))), Zero_Line_Orth,'LineStyle', ':','Color','k')
hold on
plot(Sort_IV_Betas_Orth, Upper_IV_Orth,'LineStyle', '--','Color','red')
hold on
plot(Sort_IV_Betas_Orth, Lower_IV_Orth,'LineStyle', '--','Color','red')
legend({'Data',strcat('Slope = ',...
    num2str(IV_Line_Orth.beta(2))),'CAPM Implied'},'Location','best')
title('Panel 4: SML - IV (Orth.)')
linkaxes([ax2,ax4],'xy')
xlabel('Mean Beta')
ylabel('Mean Excess Return')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(2,3,5)
Zero_Line = 0 * linspace(min(LS_NoOrth), max(LS_NoOrth), length(LS_NoOrth));
scatter(LS_NoOrth,L_Diff_Beta_NoOrth,15)
hold on
plot(LS_NoOrth, Size_Line_Fit_NoOrth,'Color','red')
hold on
plot(sort(LS_NoOrth), Upper_Diff_NoOrth,'LineStyle', '--','Color','red')
hold on
plot(sort(LS_NoOrth), Lower_Diff_NoOrth,'LineStyle', '--','Color','red')
hold on
plot(linspace(min(LS_NoOrth), max(LS_NoOrth), length(LS_NoOrth)), Zero_Line,'LineStyle', ':','Color','k')

title('Panel 5: Difference Between OLS and IV Betas')
legend({'Data',strcat('Slope = ',...
    num2str(Size_Line_NoOrth.beta(2)))},'Location','best')

xlabel('Log Size')
ylabel('log\beta_{OLS}-log\beta_{IV}')

subplot(2,3,6)
Zero_Line = 0 * linspace(min(LS_Orth), max(LS_Orth), length(LS_Orth));
scatter(LS_Orth,L_Diff_Beta_Orth,15)
hold on
plot(LS_Orth, Size_Line_Fit_Orth,'Color','red')
hold on
plot(sort(LS_Orth), Upper_Diff_Orth,'LineStyle', '--','Color','red')
hold on
plot(sort(LS_Orth), Lower_Diff_Orth,'LineStyle', '--','Color','red')
hold on
plot(linspace(min(LS_Orth), max(LS_Orth), length(LS_Orth)), Zero_Line,'LineStyle', ':','Color','k')

title('Panel 6: Difference Between OLS and IV Betas (Orth.)')
legend({'Data',strcat('Slope = ',...
    num2str(Size_Line_Orth.beta(2)))},'Location','best')

xlabel('Log Size')
ylabel('log\beta_{OLS}-log\beta_{IV}')

orient(gcf,'landscape');
export_fig(strcat('Big_Fig_T','.pdf'));
close(gcf);

