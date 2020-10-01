% generate plot

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
            '\color{black} - Theory Implied'},...
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
            '\color{black} - Theory Implied'},...
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
            '\color{black} - Theory Implied'},...
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
            '\color{black} - Theory Implied'},...
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
export_fig(strcat('outputs/merged','.pdf'));
close(gcf);
