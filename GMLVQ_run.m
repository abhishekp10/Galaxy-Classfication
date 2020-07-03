%Run GMLVQ algorithm

addpath(genpath('.'));

prompt = 'Which Catalgoue you want to execute? (1-GFS : 2- Lam : 3-Mag : 4-UKI : 5-VIK : 6-comb2): ';
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
        dat = load('galaxy_datasets_for_reseach_internship/LBS_combined_full_no_petro50.mat');
        data = double(dat.data);
        label = double(dat.labels');
        labA = label;
        datA = data;
        class = 2;
           
end
    fprintf('Load the %s data set containing %i samples with %i features.\n',actData,size(data,1),size(data,2));

    classes =["Ellipticals" ; "Little Blue Speriods" ; "Eearly Type Spirals" ; "Intermediate Type Spirals" ; "Late Type Spirals"];
if cat ~= 6
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
end    
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
    GMLVQ_results = cell(1,nb_folds);
    
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
        GMLVQ_results = struct('GMLVQ_model',{},'GMLVQ_setting',{},'zscore_model',{},'trainError',{},'testError',{});
        projectionDimension = size(trainSet{actset},2);
        %sgd ='sgd';
        GMLVQparams = struct('PrototypesPerClass',1,'dim',projectionDimension,'regularization',0);
        
        %[GMLVQ_model,GMLVQ_setting, TRN_err, TST_err, Cost_op] = GMLVQ_train(trainSet{actset}, trainLab{actset},'dim',GMLVQparams.dim,...
        [GMLVQ_model,GMLVQ_setting] = GMLVQ_train(trainSet{actset}, trainLab{actset},'dim',GMLVQparams.dim,...        
            'PrototypesPerClass',GMLVQparams.PrototypesPerClass,'regularization',GMLVQparams.regularization);
        estimatedTrainLabels{actset} = GMLVQ_classify(trainSet{actset}, GMLVQ_model);
        trainError = [trainError; mean( trainLab{actset} ~= estimatedTrainLabels{actset})];
        fprintf('GMLVQ: avg error on the train set: %f\n',mean(trainError));
        estimatedTestLabels{actset} = GMLVQ_classify(testSet{actset}, GMLVQ_model);
        testError = [testError; mean( testLab{actset} ~= estimatedTestLabels{actset})];
        fprintf('GMLVQ: avg error on the test set: %f\n',mean(testError));
        
    end
    
    lambda = GMLVQ_model.omega'*GMLVQ_model.omega;
    R1=diag(lambda);
    R2=dat.columns' ;
    [B,I] = sort(R1,'descend') ;
    sum=0;
    idxs = [];
    for i=1:length(B)
        if sum <=0.5
            sum= sum+B(i);
            idxs = [idxs; I(i)];
        end
    end
    
    os=struct;
    os.idxs =idxs;
    os.columns = R2(idxs)';
    os.labels= labA;
    os.data = datA(:, [idxs]);
    %save('concat/cass1_4.mat','os');

    

    R1=diag(lambda);
    %R1a= R1(61:120,:);
    R2=dat.columns' ;
    %R2a = R2(61:120);
    f1= figure;
    subplot(2,1,1)
    hold on;
    bar(svd(lambda))
    title('eigenvalues',... 
            'FontName','LucidaSans', 'FontWeight','bold');
    subplot(2,1,2)
    xlabel('feature number'); 
    grid on;  axis 'auto y'; box on;
    axis([0.3 GMLVQparams.dim+0.7 0 (0.01+max(diag(lambda)))]); 
    hold off;
bar(R1)
set(gca, 'XTickLabel',R2, 'XTick',1:numel(R2))
set(gca,'TickLabelInterpreter','none')
%set(gcf,'Position',[10 10 500 5000])
%lgd= legend('Class 1','Class 2','Class 3','Class 4','Class 5');
%lgd= legend('class 1','others');
%lgd.Location ='north';
%ylim([0 0.15])
title([actData, ' field relevances - class 2 vs others ']);
xtickangle(90);
hold off;
      