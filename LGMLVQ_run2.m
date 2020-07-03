%Run LGMLVQ algorithm for 2 class classfication
%Input: Select Data catlogue and the class 
%Others class is formed by concatenating equal records from unselected
%classes to form seconf class

addpath(genpath('.'));

prompt = 'Which Catalgoue you want to execute? (1-GFS : 2- Lam : 3-Mag : 4-UKI : 5-VIK : 6-comb2: 7-combothr): ';
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
    otherwise
        %#########sersic_VIKING catalogue#########
        actData = 'Sersic VIKING';
        dat = load('galaxy_datasets_for_reseach_internship/Sersic_VIKING.mat');
        data = double(dat.data);
        label = double(dat.labels');
        labels = label;

         
end
    fprintf('Load the %s data set containing %i samples with %i features.\n',actData,size(data,1),size(data,2));

    classes =["Ellipticals" ; "Little Blue Speriods" ; "Eearly Type Spirals" ; "Intermediate Type Spirals" ; "Late Type Spirals"];

    prompt2 = 'Which Class you want to classify against the rest? (1-ELP : 2- LBS : 3-ETS : 4-ITS : 5-LTS): ';   
    class = input(prompt2);
    datA=[];labA=[]; datB=[];labB=[]; 
    for k=1:length(data)
        if labels(k) == class
            datA = [datA;data(k,:)] ;
            labA = [labA;1] ;
        else
            datB = [datB;data(k,:)] ;
            labB = [labB;labels(k)] ;
        end
    end


    unlabels = unique(labB);
    indexs = cell(1,length(unlabels));
    for k=1:length(unlabels)
        indexs{k}= find(labB==unlabels(k));
    end
    idx = [];
    for i=1:length(unlabels)
        msize = numel(indexs{i});  
        idx = [idx; indexs{i}(randperm(msize, 65))]; 

    end
    for j=1:length(idx)
        labA = [labA;2] ; 
    end
        datA = [datA;datB(idx,:)] ;

        fprintf('Load the %s data set containing %i samples with %i features for class %s vs rest.\n',actData,size(datA,1),size(datA,2),classes(class));
    
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

        %Train LGMLVQ algorithm
        %LGMLVQ_model=LGMLVQ_train(data,labels);
        LGMLVQ_result = struct('GMLVQ_model',{},'GMLVQ_setting',{},'zscore_model',{},'trainError',{},'testError',{});
        projectionDimension = size(trainSet{actset},2);
        %sgd ='sgd';
        LGMLVQparams = struct('PrototypesPerClass',1,'dim',projectionDimension,'regularization',0,'optimization','sgd');
        
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
    
    %confusion matrix plot
    f1= figure;
    cf = confusionchart(conf,'RowSummary','row-normalized','ColumnSummary','column-normalized');
    cf.title (['Confusion Matrix for '  actData]);
   
    
f2= figure; 
lambda = cell(1,length(LGMLVQ_model.c_w));

 for k=1:2
    lambda{k} = LGMLVQ_model.psis{k}'*LGMLVQ_model.psis{k};
    % display diagonal matrix elements as bar plot
    subplot(3,2,k);
    hold on;
    bar(svd(lambda{k})); 
    if k ==1
        title(['eigenvalues of class', classes(class)],... 
            'FontName','LucidaSans', 'FontWeight','bold'); 
    else
        title('eigenvalues of others',... 
            'FontName','LucidaSans', 'FontWeight','bold'); 
    end
    xlabel('feature number'); 
    grid on;  axis 'auto y'; box on;
    axis([0.3 LGMLVQparams.dim+0.7 0 (0.01+max(diag(lambda{k})))]); 
    hold off;
    
    subplot(3,2,k+2);
    hold on;
    bar(diag(lambda{k})); 
    title('diag rel mat', ... 
        'FontName','LucidaSans', 'FontWeight','bold'); 
    xlabel('feature number'); 
    grid on;  axis 'auto y'; box on;
    axis([0.3 LGMLVQparams.dim+0.7 0 (0.01+max(diag(lambda{k})))]); 
    hold off;
        
    % display off-diagonal matrix elements as matrix
    subplot(3,2,k+4);
    lambdaoff = lambda{k}.*(1-eye(LGMLVQparams.dim));     % zero diagonal 
    imagesc(lambdaoff); box on;title('relevance matrix diag');colorbar;
    axis square; 
    xlabel('off-diag el', ... 
        'FontName','LucidaSans', 'FontWeight','bold');     
    hold off; 
 end
 

 
    

    
    