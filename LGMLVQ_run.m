%Run LGMLVQ algorithm for 2 class classfication
%Input: Select Data catlogue

addpath(genpath('.'));

prompt = 'Which Catalgoue you want to execute? (1-GFS : 2- Lam : 3-Mag : 4-UKI : 5-VIK : 6-Combined): ';
cat = input(prompt);
switch cat
    case 1
        %#########GFS catalogue#########
        actData = 'GFS';
        dat = load('galaxy_datasets_for_reseach_internship/GFS.mat');
        data = double(dat.data);
        label = double(dat.labels');
        labels = label;
    case 2
        %#########Lambdar catalogue#########
        actData = 'Lambdar';
        dat = load('galaxy_datasets_for_reseach_internship/Lambdar.mat');
        data = double(dat.data);
        label = double(dat.labels');
        labels = label;
    case 3
        %#########MagPhys catalogue#########
        actData = 'MagPhys';
        dat = load('galaxy_datasets_for_reseach_internship/MagPhys.mat');
        data = double(dat.data);
        label = double(dat.labels');
        labels = label;
    case 4
        %#########sersic_UKIDSS catalogue#########
        actData = 'Sersic UKIDSS';
        dat = load('galaxy_datasets_for_reseach_internship/Sersic_UKIDSS.mat');
        data = double(dat.data);
        label = double(dat.labels');
        labels = label;
    case 5
        %#########sersic_VIKING catalogue#########
        actData = 'Sersic VIKING';
        dat = load('galaxy_datasets_for_reseach_internship/Sersic_VIKING.mat');
        data = double(dat.data);
        label = double(dat.labels');
        labels = label;
    otherwise
        %#########combined catalogue#########
        actData = 'Combined';
        dat = load('galaxy_datasets_for_reseach_internship/all5_combined_full_no_petro50.mat');
        data = double(dat.data);
        label = double(dat.labels');
        labels = label;
end
    fprintf('Load the %s data set containing %i samples with %i features.\n',actData,size(data,1),size(data,2));

    % train test split
    nb_samples_per_class=209;
    nb_folds = 10;
    indices = nFoldCrossValidation(data,'labels',labels,'splits','random','nb_samples',nb_samples_per_class,'nb_folds',nb_folds,'comparable',1);
    %actset = 1;
    trainSet = cell(1,nb_folds);
    trainLab = cell(1,nb_folds);
    testSet = cell(1,nb_folds);
    testLab = cell(1,nb_folds);
    LGMLVQ_results = cell(1,nb_folds);
    zscore_model = cell(1,nb_folds);
    estimatedTrainLabels = cell(1,nb_folds);
    estimatedTestLabels = cell(1,nb_folds);
    conf = zeros(length(unique(labels)));
    trainError = []; testError=[];
    for actset=1:nb_folds
        % extract the training set
        trainSet{actset} = data(indices{actset},:);
        trainLab{actset} = labels(indices{actset});
        % extract the test set
        testIdx = 1:length(labels);
        testIdx(indices{actset}) = [];
        testSet{actset} = data(testIdx,:);
        testLab{actset} = labels(testIdx);

        disp('preprocess the data using zscore');
        [trainSet{actset}, zscore_model{actset}] = zscoreTransformation(trainSet{actset});
        testSet{actset} = zscoreTransformation(testSet{actset}, 'parameter', zscore_model{actset});

        %Train LGMLVQ algorithm
        %LGMLVQ_model=LGMLVQ_train(data,labels);
        
        LGMLVQ_result = struct('LGMLVQ_model',{},'LGMLVQ_setting',{},'zscore_model',{},'trainError',{},'testError',{});
        %LGMLVQ_result = struct('LGMLVQ_model',{},'LGMLVQ_setting',{},'zscore_model',{},'trainError',{},'testError',{},'cost',{});
        projectionDimension = size(trainSet{actset},2);
        %sgd ='sgd';
        LGMLVQparams = struct('PrototypesPerClass',1,'dim',projectionDimension,'regularization',0,'optimization','fminlbfgs');
        
        %[LGMLVQ_model,LGMLVQ_setting, TRN_err, TST_err, Cost_op] = LGMLVQ_train(trainSet{actset}, trainLab{actset},'dim',LGMLVQparams.dim,...
        [LGMLVQ_model,LGMLVQ_setting, TRN_err, TST_err] = LGMLVQ_train(trainSet{actset}, trainLab{actset},'dim',LGMLVQparams.dim,...        
            'PrototypesPerClass',LGMLVQparams.PrototypesPerClass,'testSet',[testSet{actset},testLab{actset}],'classwise',0,'regularization',LGMLVQparams.regularization);
        estimatedTrainLabels{actset} = LGMLVQ_classify(trainSet{actset}, LGMLVQ_model);
        trainError = [trainError; mean( trainLab{actset} ~= estimatedTrainLabels{actset})];
        fprintf('LGMLVQ: avg error on the train set: %f\n',mean(trainError));
        estimatedTestLabels{actset} = LGMLVQ_classify(testSet{actset}, LGMLVQ_model);
        testError = [testError; mean( testLab{actset} ~= estimatedTestLabels{actset})];
        fprintf('LGMLVQ: avg error on the test set: %f\n',mean(testError));
        
        LGMLVQ_result{1}.LGMLVQ_model = LGMLVQ_model;
        LGMLVQ_result{1}.LGMLVQ_setting = LGMLVQ_setting;
        LGMLVQ_result{1}.zscore_model = zscore_model;
        LGMLVQ_result{1}.trainError = TRN_err;
        LGMLVQ_result{1}.testError = TST_err;
        %LGMLVQ_result{1}.cost = Cost_op;
        LGMLVQ_results{actset} = LGMLVQ_result;
        
        %compute confusion matrix over 10 validation runs
        conf=conf + confusionmat(testLab{actset}',estimatedTestLabels{actset}');
    end
    f1= figure;
    cf = confusionchart(conf,'RowSummary','row-normalized','ColumnSummary','column-normalized');
    cf.title (['Confusion Matrix for '  actData]);
    
    %f2 = figure;
    %plot(1:length(cost_op),cost_op,':.','MarkerSize',msize); 
    %        title('cost fct. w/o penalty term (training)',...
    %            'FontName','LucidaSans', 'FontWeight','bold');
    %        xlabel('gradient steps');
    %        axis tight; axis 'auto y'; 
    %        hold on; box on;
    %        hold off;
    
    
   
    
f3= figure; 
lambda = cell(1,length(LGMLVQ_model.c_w));

 for k=1:max(LGMLVQ_model.c_w)
    lambda{k} = LGMLVQ_model.psis{k}'*LGMLVQ_model.psis{k};
    % display diagonal matrix elements as bar plot
    subplot(3,max(LGMLVQ_model.c_w),k);
    hold on;
    bar(svd(lambda{k})); 
    title(['eigenvalues class', num2str(k)],... 
        'FontName','LucidaSans', 'FontWeight','bold'); 
    xlabel('feature number'); 
    grid on;  axis 'auto y'; box on;
    axis([0.3 LGMLVQparams.dim+0.7 0 (0.01+max(diag(lambda{k})))]);   
    hold off;
    
    subplot(3,max(LGMLVQ_model.c_w),k+5);
    hold on;
    bar(diag(lambda{k})); 
    title('diag rel mat', ... 
        'FontName','LucidaSans', 'FontWeight','bold'); 
    xlabel('feature number'); 
    grid on;  axis 'auto y'; box on;
    axis([0.3 LGMLVQparams.dim+0.7 0 (0.01+max(diag(lambda{k})))]);  
    hold off;
        
    % display off-diagonal matrix elements as matrix
    subplot(3,max(LGMLVQ_model.c_w),k+10);
    lambdaoff = lambda{k}.*(1-eye(LGMLVQparams.dim));     % zero diagonal 
    imagesc(lambdaoff); box on;title('relevance matrix diag');colorbar;
    axis square; 
    xlabel('off-diag el', ... 
        'FontName','LucidaSans', 'FontWeight','bold');     
    hold off; 
 end

%{
U = cell(1,length(LGMLVQ_model.c_w));
A = cell(1,length(LGMLVQ_model.c_w));
mins = cell(1,length(LGMLVQ_model.c_w));
maxs = cell(1,length(LGMLVQ_model.c_w));
projection = cell(1,length(LGMLVQ_model.c_w));
 for k=1:max(LGMLVQ_model.c_w)
    if size(model.omega,1)>dim        
        [U{k},~,~] = svd(lambda{k});
        A{k} = U(:,1:dim)';
    else
        A{k} = LGMLVQ_model.psis{k};
    end
projection = trainSet*A{k}';
mins = min(projection);
maxs = max(projection);
gscatter(projection(:,1),projection(:,2),[trainLab;testLab],'','o',4,'off','dim 1','dim 2');box on;title('2 dim projection of the data');
xlim([mins(1) maxs(1)]);ylim([mins(2) maxs(2)]);hold on;
my_voronoi2(rank2protsproj(:,1),rank2protsproj(:,2),GMLVQ_model_rank2.c_w,'k');
end
 %}