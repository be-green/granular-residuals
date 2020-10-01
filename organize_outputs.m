
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
