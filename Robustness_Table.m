%%%%%%%%%%%%% Robustness Table

clc
close all

Results_Tab = [];
for Subsample = 192701
    for Lag = [60 48 36]
       for K = [3 4 5]
          for Orth = [1 0]
              if Orth == 0
                  Orth_OLS = 1;
              else 
                  Orth_OLS = 2;
              end
              Title = strcat('Subsample-',num2str(Subsample),'-Window-',num2str(Lag),'-PCs-',num2str(K),...
                        '-Orth-',num2str(Orth),'-Option-',num2str(Orth_OLS));
                    load(strcat(Title,'-Boot','.mat'));
                    
                    Alphas = [];
                    Alphas_OLS= [];
                    Line_1 = [];
                    Line_2 = [];
                    IV_Line = [];
                    OLS_Line = [];
                    Size_Line = [];
                    for i = 1 : length(Alphas_Save)
                        Alphas = [Alphas, -1200 .* Alphas_Save{i}{1}];
                         Alphas_OLS = [Alphas_OLS, -1200 .* Alphas_OLS_Save{i}{1}];
                         Line_1 = [Line_1, Line_1_Save{i}{1}.beta(2)];
                         Line_2 = [Line_2, Line_2_Save{i}{1}.beta(2)];
                         IV_Line=[IV_Line, IV_Line_Save{i}(2)];
                         OLS_Line = [OLS_Line, OLS_Line_Save{i}(2)];
                         Size_Line = [Size_Line, Size_Line_Save{i}(2)];
                    end
                    
                    
                    Results_Tab = horzcat(Results_Tab,[var(Alphas);var(Alphas_OLS);...
                        var(Line_1); var(Line_2);...
                        var(IV_Line); var(OLS_Line); var(Size_Line)]);
          end
       end
    end
    
end
 
SDs = sqrt(Results_Tab);

Results_Tab = [];
for Subsample = 192701
    for Lag = [60 48 36]
       for K = [3 4 5]
          for Orth = [1 0]
              if Orth == 0
                  Orth_OLS = 1;
              else 
                  Orth_OLS = 2;
              end
              Title = strcat('Subsample-',num2str(Subsample),'-Window-',num2str(Lag),'-PCs-',num2str(K),...
                        '-Orth-',num2str(Orth),'-Option-',num2str(Orth_OLS));
                    load(strcat(Title,'.mat'));
                    
                    
                    Results_Tab = horzcat(Results_Tab,[-1200 .* Alphas{1};-1200 .* Alphas_OLS{1};...
                        Line_1{1}.beta(2); Line_2{1}.beta(2);...
                        IV_Line(2); OLS_Line(2); Size_Line(2)]);
          end
       end
    end
    
end
Ests = Results_Tab;
Point_Est = [];
for i = 1 : 2 : size(Ests, 1)

    if i == size(Ests, 1)
%%%% IV Alphas
Temp_Est_1 = Ests(i,:);
Temp = Temp_Est_1;
Temp_Orth = Temp(1 : 2 : end - 1);
Temp_Orth = reshape(Temp_Orth, 3,3)';
Temp_NoOrth = Temp(2 : 2 : end);
Temp_NoOrth = reshape(Temp_NoOrth, 3,3)';
Temp_1 = interleave2(Temp_Orth,Temp_NoOrth,'col');
Point_Est = [Point_Est ; Temp_1];
    else
%%%% IV Alphas
Temp_Est_1 = Ests(i,:);
Temp = Temp_Est_1;
Temp_Orth = Temp(1 : 2 : end - 1);
Temp_Orth = reshape(Temp_Orth, 3,3)';
Temp_NoOrth = Temp(2 : 2 : end);
Temp_NoOrth = reshape(Temp_NoOrth, 3,3)';
Temp_1 = interleave2(Temp_Orth,Temp_NoOrth,'col');
%%%% OLS Alphas
Temp_Est_2 = Ests(i+1,:);
Temp = Temp_Est_2;
Temp_Orth = Temp(1 : 2 : end - 1);
Temp_Orth = reshape(Temp_Orth, 3,3)';
Temp_NoOrth = Temp(2 : 2 : end);
Temp_NoOrth = reshape(Temp_NoOrth, 3,3)';
Temp_2 = interleave2(Temp_Orth,Temp_NoOrth,'col');
%%%%%%%%%%%%%%% HERE
Point_Est = [Point_Est ; interleave2(Temp_1, Temp_2,'row')];
    end
end

SD = [];
for i = 1 : 2 : size(SDs, 1)

    if i == size(SDs, 1)
%%%% IV Alphas
Temp_Est_1 = SDs(i,:);
Temp = Temp_Est_1;
Temp_Orth = Temp(1 : 2 : end - 1);
Temp_Orth = reshape(Temp_Orth, 3,3)';
Temp_NoOrth = Temp(2 : 2 : end);
Temp_NoOrth = reshape(Temp_NoOrth, 3,3)';
Temp_1 = interleave2(Temp_Orth,Temp_NoOrth,'col');
SD = [SD ; Temp_1];
    else
%%%% IV Alphas
Temp_Est_1 = SDs(i,:);
Temp = Temp_Est_1;
Temp_Orth = Temp(1 : 2 : end - 1);
Temp_Orth = reshape(Temp_Orth, 3,3)';
Temp_NoOrth = Temp(2 : 2 : end);
Temp_NoOrth = reshape(Temp_NoOrth, 3,3)';
Temp_1 = interleave2(Temp_Orth,Temp_NoOrth,'col');
%%%% OLS Alphas
Temp_Est_2 = SDs(i+1,:);
Temp = Temp_Est_2;
Temp_Orth = Temp(1 : 2 : end - 1);
Temp_Orth = reshape(Temp_Orth, 3,3)';
Temp_NoOrth = Temp(2 : 2 : end);
Temp_NoOrth = reshape(Temp_NoOrth, 3,3)';
Temp_2 = interleave2(Temp_Orth,Temp_NoOrth,'col');
%%%%%%%%%%%%%%% HERE
SD = [SD ; interleave2(Temp_1, Temp_2,'row')];
    end
end

TABLE = interleave2(Point_Est, SD, 'row');
% Table = mat2cell(TABLE, ones(size(TABLE,1),1),ones(size(TABLE,2),1));
% 
% for i = 2 : 2 : size(Table,1)
%     for j = 1 : size(Table, 2)
%         Table{i,j} = strcat('(',num2str(Table{i,j}),')');
%     end
% end


