%Alternate program to run GMLVQ algorithm
%Written to run comparisons between local and global version

%save('52subset.mat','labA','datA');

%dat = load('52subset.mat');
%datA= dat.datA;
%labA = dat.labA;


    % train test split
    nb_samples_per_class=210;
    nb_folds = 10;
    indices = nFoldCrossValidation(datA,'labels',labA,'splits','random','nb_samples',nb_samples_per_class,'nb_folds',nb_folds,'comparable',1);
    %actset = 10;
    trainSet = cell(1,nb_folds);
    trainLab = cell(1,nb_folds);
    testSet = cell(1,nb_folds);
    testLab = cell(1,nb_folds);
    zscore_model = cell(1,nb_folds);
    estimatedTrainLabels = cell(1,nb_folds);
    estimatedTestLabels = cell(1,nb_folds);
    conf = zeros(length(unique(labA)));
    trainError = []; testError=[];
    LGMLVQ_results = cell(1,nb_folds);
    
    iqr1 =iqr(datA,'all');
    for actset=1:nb_folds
        % extract the training set
        trainSet{actset} = datA(indices{actset},:);
        trainLab{actset} = labA(indices{actset});
        % extract the test set
        testIdx = 1:length(labA);
        testIdx(indices{actset}) = [];
        testSet{actset} = datA(testIdx,:);
        testLab{actset} = labA(testIdx);

        disp('preprocess the data using zscore');
        [trainSet{actset}, zscore_model{actset}] = zscoreTransformation(trainSet{actset});
        testSet{actset} = zscoreTransformation(testSet{actset}, 'parameter', zscore_model{actset});

        %Train GMLVQ algorithm
        %GMLVQ_model=GMLVQ_train(data,labels);
        GMLVQ_result = struct('GMLVQ_model',{},'GMLVQ_setting',{},'zscore_model',{},'trainError',{},'testError',{});
        projectionDimension = size(trainSet{actset},2);
        %sgd ='sgd';
        GMLVQparams = struct('PrototypesPerClass',1,'dim',projectionDimension,'regularization',0);
        
        %[GMLVQ_model,GMLVQ_setting, TRN_err, TST_err, Cost_op] = GMLVQ_train(trainSet{actset}, trainLab{actset},'dim',GMLVQparams.dim,...
        [GMLVQ_model,GMLVQ_setting, TRN_err, TST_err] = GMLVQ_train(trainSet{actset}, trainLab{actset},'dim',GMLVQparams.dim,...        
            'PrototypesPerClass',GMLVQparams.PrototypesPerClass,'regularization',GMLVQparams.regularization);
        estimatedTrainLabels{actset} = GMLVQ_classify(trainSet{actset}, GMLVQ_model);
        trainError = [trainError; mean( trainLab{actset} ~= estimatedTrainLabels{actset})];
        fprintf('GMLVQ: avg error on the train set: %f\n',mean(trainError));
        estimatedTestLabels{actset} = GMLVQ_classify(testSet{actset}, GMLVQ_model);
        testError = [testError; mean( testLab{actset} ~= estimatedTestLabels{actset})];
        fprintf('GMLVQ: avg error on the test set: %f\n',mean(testError));
        lambda = GMLVQ_model.omega'*GMLVQ_model.omega;
        
        GMLVQ_result{1}.GMLVQ_model = GMLVQ_model;
        GMLVQ_result{1}.GMLVQ_setting = GMLVQ_setting;
        GMLVQ_result{1}.zscore_model = zscore_model;
        GMLVQ_result{1}.trainError = TRN_err;
        GMLVQ_result{1}.testError = TST_err;
        %LGMLVQ_result{1}.cost = Cost_op;
        LGMLVQ_results{actset} = GMLVQ_result;
        
        
    end
    
    
    