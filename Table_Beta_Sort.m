%%%%%%%%%%%%% Robustness Table

clc
close all

Results_Tab = [];
for Subsample = 196301
    for Lag = 60
       for K = 3
          for Orth = 0
              if Orth == 0
                  Orth_OLS = 1;
              else 
                  Orth_OLS = 2;
              end
              Title = strcat('Subsample-',num2str(Subsample),'-Window-',num2str(Lag),'-PCs-',num2str(K),...
                        '-Orth-',num2str(Orth),'-Option-',num2str(Orth_OLS));
                    load(strcat(Title,'-Boot','.mat'));
                    
                   Betas = zeros(200,25);
                   LS_Beta = zeros(200, 5);
                   LS_Size = zeros(200, 5);
                    for i = 1 : length(Betas)
                        Betas(i,1:25) =Z_Save{i}{24}-X_Save{i}{24};
                        LS_Beta(i, 1 : 5) =(Z_Save{i}{24}([5, 10, 15, 20, 25])-...
                            Z_Save{i}{24}([1, 6, 11, 16, 21])) - (X_Save{i}{24}([5, 10, 15, 20, 25])-...
                            X_Save{i}{24}([1, 6, 11, 16, 21]));
                        LS_Size(i, 1 : 5) =(Z_Save{i}{24}(1:5)-...
                            Z_Save{i}{24}(21:25))-(X_Save{i}{24}(1:5)-...
                            X_Save{i}{24}(21:25));

                    end
                    
                    
                    Results_Tab = horzcat(Results_Tab,[std(Betas), std(LS_Beta), std(LS_Size)]);
          end
       end
    end
    
end
 
SDs =Results_Tab;

Results_Tab = [];
for Subsample = 196301
    for Lag = 60
       for K = 3
          for Orth = 0
              if Orth == 0
                  Orth_OLS = 1;
              else 
                  Orth_OLS = 2;
              end
              Title = strcat('Subsample-',num2str(Subsample),'-Window-',num2str(Lag),'-PCs-',num2str(K),...
                        '-Orth-',num2str(Orth),'-Option-',num2str(Orth_OLS));
                    load(strcat(Title,'.mat'));
                    
                     Betas =Z{24}-X{24};
                        LS_Beta =(Z{24}([5, 10, 15, 20, 25])-...
                            Z{24}([1, 6, 11, 16, 21])) - (X{24}([5, 10, 15, 20, 25])-...
                            X{24}([1, 6, 11, 16, 21]));
                        LS_Size =(Z{24}(1:5)-...
                            Z{24}(21:25))-(X{24}(1:5)-...
                            X{24}(21:25));

                    
                    Results_Tab = horzcat(Results_Tab,[Betas, LS_Beta, LS_Size]);
          end
       end
    end
    
end
Ests = Results_Tab;

Main_Sorts = Ests(1 : 25);
Main_Sorts = reshape(Main_Sorts, 5, 5);
Beta_LS = Ests(26:30);
Size_LS = Ests(31:end);
Main_Sorts = vertcat(horzcat(Main_Sorts, Size_LS'),[Beta_LS,0]);

Main_Sorts_SD = SDs(1 : 25);
Main_Sorts_SD = reshape(Main_Sorts_SD, 5, 5);
Beta_LS = SDs(26:30);
Size_LS = SDs(31:end);
Main_Sorts_SD = vertcat(horzcat(Main_Sorts_SD, Size_LS'),[Beta_LS,0]);

Beta_Table = interleave2(Main_Sorts, Main_Sorts_SD, 'row');