% run main spec

% Sample
for Subsample = [196301]
    % Orth or not
    for Orth = [1 0]
        % Title of file
        Title = strcat('Subsample-',num2str(Subsample),'-Orth-',num2str(Orth));
        % Run main file
       run main

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