clear; 
close all; 
clc; 

%%%%%%%%%%
%%Part1:Pre-processing
%%%%%%%%%%

% loads 9296 handwritten 16x16 images X dim(X)=[9296x256] and the lables t in [0:9] dim(t)=[9298x1]
% Here we get t[9298*1] and X[9296*256]
load 'USPS_dataset9296.mat' X t;
[Ntot,D] =      size(X);         % Ntot = number of total dataset samples. D =256=input dimension


% Define some useful anonymous functions
show_vec_as_image16x16 =    @(row_vec)      imshow(-(reshape(row_vec,16,16)).');    % shows the image of a row vector with 256 elements. For matching purposes, a negation and rotation are needed.
sigmoid =                   @(x)            1./(1+exp(-x));                         % overwrites the existing sigmoid, in order to avoid the toolbox
LSsolver =                  @(Xmat,tvec)    ( Xmat.' * Xmat ) \ Xmat.' * tvec;      % Least Square solver


% Focus only on the digits 3 and 8.
ind_t3 =        (t==3);                             % indices of the total data set, labelled t=3
ind_t8 =        (t==8);                             % indices of the total data set, labelled t=4

N3tot =         sum(ind_t3);                        % total number of points labelled t=3;
N8tot =         sum(ind_t8);                        % total number of points labelled t=8;
% Split the data set into 80% training and 20% testing
N3 =            round(0.8*N3tot);                   % training size for t=3
N8 =            round(0.8*N8tot);                   % training size for t=8
N =             N3 + N8;                            % total training set size
N3va =          N3tot - N3;                         % validation  set size for t=3
N1va =          N8tot - N8;                         % validation  set size for t=8
Nva =           N3va + N1va;                        % total test set size

X3tot =         X    ( ind_t3        , : );         % stacking all x's with t=3
X8tot =         X    ( ind_t8        , : );         % stacking all x's with t=8
X3 =            X3tot(    1 : N3     , : );         % forming the training   x's labelled t=3 by slicing the first 80% data points
X8 =            X8tot(    1 : N8     , : );         % "           training   "            t=8 "              first 80% "
X3va =          X3tot( N3+1 : N3tot  , : );         % "           validation "            t=3 "              last  20% "
X8va =          X8tot( N8+1 : N8tot  , : );         % "           validation "            t=8 "              last  20% "

X_D =           [ X3              ; X8            ];% the x for the training   set. dim=[N   x 256]
t_D =           [ zeros([N3,1])   ; ones([N8,1])  ];% the t for the training   set. dim=[N   x 256]

X_D_va =        [ X3va            ; X8va          ];% the x for the validation set. dim=[Nva x 256]
t_D_va =        [ zeros([N3va,1]) ; ones([N1va,1])];% the t for the validation set. dim=[Nva x 256]


PLOT_DATASET = 0;
if PLOT_DATASET % more visualizations
    figure(9);  sgtitle('The first 24 training inputs labelled as t=0 (number 3)');
    for n=1:4*6
        subplot(4,6,n);
        show_vec_as_image16x16(X_D(n,:));
        title(['t_{',num2str(n),'}=0   x_{',num2str(n),'}=']);
    end
    figure(10);  sgtitle('The first 24 training inputs labelled as t=1 (number 8)');
    for n=1:4*6
        subplot(4,6,n);
        show_vec_as_image16x16(X_D(N3+n,:));
        title(['t_{',num2str(N3+n),'}=1   x_{',num2str(N3+n),'}=']);
    end
end

%Add a bias pixel to form the feature u(x)=[1,x]
X_D_Sec1 =                  [ones(N  ,1) , X_D   ]; % adding the freedom for bias for the training set
X_D_Sec1_va =               [ones(Nva,1) , X_D_va]; % adding the freedom for bias for the test     set


%%%%%%%%%%
%%Part2:Least Squares
%%%%%%%%%%


error  = zeros(1,257);
error_va  = zeros(1,257);
for n=1:257
    theta_M = LSsolver(X_D_Sec1(:,1:n),t_D);
    t_D_hat = X_D_Sec1(:,1:n) * theta_M;
    t_D_va_hat = X_D_Sec1_va(:,1:n) * theta_M;
    error(n) = 1/N     * sum((t_D    - t_D_hat     ).^2);
    error_va(n) = 1/Nva   * sum((t_D_va - t_D_va_hat).^2);
end

figure(1); hold on;
% error = reshape(error,256,1);

title('Section 2:Training and validation quadratic errors of the predictor');
plot(error,'b','DisplayName','Training loss');
plot(error_va   , 'r','DisplayName','Valadation loss');
xlabel('Number of components M'); ylabel('Quadratic errors of the predictor');
legend();




%%%%%%%%%%
%%Part3:PCA
%%%%%%%%%%

%Calculate the PCA dictionary full 256x256 matrix 
[pcaData,PCA_dictionary,eigVal] = PCA(X_D,256);
[pcaData_va,PCA_dictionary_va,eigVal_va] = PCA(X_D_va,256);

error  = zeros(1,256);
error_va  = zeros(1,256);
for n=1:256
    theta_M = LSsolver(pcaData(:,1:n),t_D);
    t_D_hat = pcaData(:,1:n) * theta_M;
    t_D_va_hat = pcaData_va(:,1:n) * theta_M;
    error(n) = 1/N     * sum((t_D    - t_D_hat     ).^2);
    error_va(n) = 1/Nva   * sum((t_D_va - t_D_va_hat).^2);
end

figure(2); hold on;
% error = reshape(error,256,1);

title('Section 3:Training and validation quadratic errors of the PCA predictor');
plot(error,'b','DisplayName','PCA Training loss');
plot(error_va   , 'r','DisplayName','PCA Valadation loss');
xlabel('Number of components M'); ylabel('Quadratic errors of the predictor');
legend();
display('Without the bias pixel, thw over all performance of PCA is worse than normal least squares.')
display('In the case of using a small number of features, PCA performs better because it can express the more meaning of all pixels')



%%%%%%%%%%
%%Part4:Logistic Regression with one layer
%%%%%%%%%%
[X_D_Sec1,PCA_dictionary,eigVal] = PCA(X_D_Sec1,3);
[X_D_Sec1_va,PCA_dictionary_va,eigVal_va] = PCA(X_D_Sec1_va,3);

MaxIter = 25; % maximal number of Logistic regression iterations
Svec =                      [10];       % Options for batches sizes
gamma_vec =                 [0.1];   % Options for learning rate

trainingloss_Sec2 =         NaN(MaxIter,length(Svec),length(gamma_vec));
validationloss_Sec2 =       NaN(MaxIter,length(Svec),length(gamma_vec));
train_detection_error_loss = NaN(MaxIter,1);
val_detection_error_loss = NaN(MaxIter,1);

D =2;
for Sind=1:length(Svec)
    S =                         Svec(Sind);
    for gamma_ind=1:length(gamma_vec)
        gamma =                 gamma_vec(gamma_ind);
        % init theta
        theta_Sec2 =              [1/sqrt(D+1)*randn(D+1,1),NaN(D+1,MaxIter)];
        for ii=1:MaxIter
            batch_ind =         randperm(N,S);
            total_sum =         0;
            for n=1:S
                u_of_x_n =      ( X_D_Sec1( batch_ind(n) , : ) ).';
                t_n =           t_D       ( batch_ind(n) );
                sigmoid_n =     sigmoid( (theta_Sec2(:,ii)).' * u_of_x_n );
                total_sum =     total_sum + ( sigmoid_n - t_n ) * u_of_x_n; % scalar x vector
            end
            theta_Sec2(:,ii+1) =  theta_Sec2(:,ii) - gamma/S * total_sum;
            % evaluate logits
            logit_lr_D =        X_D_Sec1    * theta_Sec2(:,ii) ; % logits of the training set
            logit_lr_D_va =     X_D_Sec1_va * theta_Sec2(:,ii) ; % logits of the test     set
            % detection-error loss
            logit_D_sigmoid = sigmoid(logit_lr_D) > 0.5;
            logit_D_va_sigmoid = sigmoid(logit_lr_D_va) > 0.5;
            train_detection_error_loss(ii) = sum(logit_D_sigmoid ~= t_D)/N;
            val_detection_error_loss(ii) = sum(logit_D_va_sigmoid ~= t_D_va)/N;

            % evaluate training and validation losses. In logistic regression, we evaluate the log loss
            trainingloss_Sec2(ii,Sind,gamma_ind) =    1/N     * sum( log( 1 + exp( -(2*t_D   -1) .* logit_lr_D    )));
            validationloss_Sec2(ii,Sind,gamma_ind) =  1/Nva   * sum( log( 1 + exp( -(2*t_D_va-1) .* logit_lr_D_va )));
        end
    end
end

figure(3); hold on;

title('Section 4:Logistic Regression with one layer');
plot(trainingloss_Sec2,'b','DisplayName','Training log loss');
plot(validationloss_Sec2   , 'r','DisplayName','Valadation log loss');
plot(train_detection_error_loss,'y','DisplayName','Training detection error loss');
plot(val_detection_error_loss,'g','DisplayName','Vraining detection error loss');
xlabel('Iteration index'); ylabel('Loss');
legend();




function [pcaData,projectionVectors,eigVal] = PCA(data, featuresToExtract)
    
    % Check the arguments
    if ~exist('data', 'var')
        error('Data argument required.');
    end
    % Convert data to double
    data = double(data);
    
    % Get the number of features and examples of the data
    [numberOfExamples,numberOfFeatures] = size(data);
    
    if exist('featuresToExtract', 'var')
        if( featuresToExtract > numberOfFeatures)
            error('Number of features to extract is bigger than the features the data has');
        end
    else 
        featuresToExtract = round(numberOfFeatures / 2);
    end
    
    % Step 1: normalize the data
    
    % Get the mean for each feature on the data
    dataMean = mean(data,1);
    
    % Allocate the space for normalizedData
    normalizedData = zeros(numberOfExamples,numberOfFeatures);
    
    % For each example subtract the dataMean
    for i = 1 : numberOfExamples
        normalizedData(i,:) = data(i,:) - dataMean;
    end
    
    % Step 2: Find the covariance matrix of the normalized data 
    covarianceMatrix = cov(normalizedData);
    
    % Step 3: Calculate the eigenvectors and eigenvalues 
    [eigVec, eigVal] = eig(covarianceMatrix);
    % Get the eigenvalues 
    eigVal = diag(eigVal);
    % Find the best eigenvalues
    bestEigVal = sortrows(eigVal,-1);
    
    for i = 1 : featuresToExtract 
        projectionVectors(:,i) = eigVec(:,eigVal == bestEigVal(i));
    end
    
    eigVal = bestEigVal;
    % Step 4: Get the new data 
    pcaData = normalizedData * projectionVectors;
    
end