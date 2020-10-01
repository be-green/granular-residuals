function[Params_Final,CovMatGMM] = GMM_Mazi(Moments, Data, Params_Init,Set_Params)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% Moments = Moment function (MATLAB function)
% Data (Obs x variables)
% Params_Init = guess

% Options for optimization
myopts = optimset('TolFun',10^-15, 'MaxFunEvals',100000000,'MaxIter',100000);
% Number of moments
Num_Moments = Set_Params.Num_Moments;
% Number of obersvations
T = Set_Params.T;
% Initial weight matrix
Weight=eye(Num_Moments);
% Lags for Newey-West
lags = round(T^(1/3));
% Tolerance for gradient
eps=10E-6;
% If the problem is exactly identified, don't need to use GMM, just do MM
% one step
if Num_Moments == length(Params_Init)
    % Find zeros of moments
    Params_Final = fsolve(@(Params) mean(Moments(Data,Params,Set_Params)), Params_Init,myopts);
    % Otherwise, need to do GMM
else
    % Initialize gradient
    Grad = zeros(Num_Moments, length(Params_Init));
    % Loop through parameters
    for i = 1: length(Params_Init)
        % Plus eps
        Param_P = Params_Init(i)+eps;
        % Minus eps
        Param_M = Params_Init(i)-eps;
        % All other parameters unchanged for plus
        Params_Grad_P = Params_Init;
        %... and for minus
        Params_Grad_M = Params_Init;
        % Replace ith parameter in plus with P+eps
        Params_Grad_P(i)=Param_P;
        % ... and in minus with p - eps
        Params_Grad_M(i)=Param_M;
        % Calculate symmetric numerical gradient
        Grad(:,i) = mean((Moments(Data,Params_Grad_P,Set_Params)-Moments(Data,Params_Grad_M,Set_Params))./(2*eps));
    end
    % First pass of finding zero of quadratic form deriv (use deriv to go
    % faster)
    Params_First_Pass = fsolve(@(Params_Init) First_Pass_GMM(Moments,Data,Params_Init,Weight,Set_Params,Grad),Params_Init,myopts);
    % Moments at init params
    Moments_First = Moments(Data,Params_First_Pass,Set_Params);
    % Contemporaneous variance
    S = Moments_First'*Moments_First./T;
    % Transpose moments
    t_M=transpose(Moments_First);
    % Initialize kernel
    weight = zeros(1,lags);
    % Loop through NW lags
    for j = 1:lags
        % Initialize j-th auto-covariance matrix
        Om_j = zeros(Num_Moments,Num_Moments);
        % j-th kernel weight
        weight(j)=1-(j/(lags+1));
        % Loop through all t used to calculate j-th auto-cov
        for i = (j+1):T
            % j-th auto-covariance
            Om_j = Om_j + t_M(:,i).*t_M(:,i-j)'./T;
        end
        % NW cov mat
        S=S+weight(j)*(Om_j+Om_j');
    end
    % Re-create gradient at new params
    Grad = zeros(Num_Moments, length(Params_First_Pass));
    
    for i = 1: length(Params_First_Pass)
        Param_P = Params_First_Pass(i)+eps;
        Param_M = Params_First_Pass(i)-eps;
        Params_Grad_P = Params_First_Pass;
        Params_Grad_M = Params_First_Pass;
        Params_Grad_P(i)=Param_P;
        Params_Grad_M(i)=Param_M;
        Grad(:,i) = mean((Moments(Data,Params_Grad_P,Set_Params)-Moments(Data,Params_Grad_M,Set_Params))./(2*eps));
    end
    
    % Second pass GMM with S^(-1) weighting mat
    Params_Final = fsolve(@(Params_First_Pass) First_Pass_GMM(Moments,Data,Params_First_Pass,inv(S),Set_Params,Grad),Params_First_Pass,myopts);
end
% Re-do grad again with final params
Grad = zeros(Num_Moments, length(Params_Final));

for i = 1: length(Params_Final)
    Param_P = Params_Final(i)+eps;
    Param_M = Params_Final(i)-eps;
    Params_Grad_P = Params_Final;
    Params_Grad_M = Params_Final;
    Params_Grad_P(i)=Param_P;
    Params_Grad_M(i)=Param_M;
    Grad(:,i) = mean((Moments(Data,Params_Grad_P,Set_Params)-Moments(Data,Params_Grad_M,Set_Params))./(2*eps));
end


% Re-do NW cov-mat
Moments_Final = Moments(Data,Params_Final,Set_Params);

S = Moments_Final'*Moments_Final./T;
t_M=transpose(Moments_Final);
weight = zeros(1,lags);
for j = 1:lags
    Om_j = zeros(Num_Moments,Num_Moments);
    weight(j)=1-(j/(lags+1));
    for i = (j+1):T
        Om_j = Om_j + t_M(:,i).*t_M(:,i-j)'./T;
    end
    S=S+weight(j)*(Om_j+Om_j');
end

% Optimal cov mat
CovMatGMM = inv(Grad'*inv(S)*Grad);
