%Plot ROC curve for GMLVQ

% Initialization
costFunction = 0;
rocClass = 1;
margins = zeros(1, length(trainLab{1}));
scorez = zeros(1, length(trainLab{1}));
crispOut = zeros(1, length(trainLab{1}));

%omegaMatrix = GMLVQ_model.psis / norm(GMLVQ_model.psis,'fro');

prototypes = GMLVQ_model.w; 
%omegaMatrix = cell(1,length(unique(trainLab{10})));

% Loop through all examples to find the cost of each
omegaMatrix = GMLVQ_model.omega ;
for i=1:length(trainLab{1})
    currentFV = trainSet{1}(i,:);
    currentLabel = trainLab{1}(i);
    dist = nan(length(unique(trainLab{1})), 1);
    
    
        
        for jk = 1:max(GMLVQ_model.c_w)
        dist(jk) = norm(omegaMatrix * (currentFV-prototypes(jk,:))')^2;
        end

    
    % Find the winning prototypes for this example
    correct = find(GMLVQ_model.c_w == currentLabel);
    incorrect = find(GMLVQ_model.c_w ~= currentLabel);
    [dJJ,JJJ] = min(dist(correct));
    [dKK,KKK] = min(dist(incorrect));
    JJ = correct(JJJ); KK = incorrect(KKK);
    
    margins(i) = (dJJ-dKK)/(dJJ+dKK);
    %costFunction = costFunction + margins(i) / dataPair.nFeatureVectors;
    
    % Non-normalized difference of distances
    if currentLabel == rocClass
        scorez(i) = dKK - dJJ;
    else
        scorez(i) = dJJ - dKK;
    end
end
%-----------------------------------------------------------------------------------------------------------

%
            score = scorez;
%{
            nThresholds = 5000;
            target = (trainLab{10} ~= rocClass)';
            %target = trainLab{10}';
            tu = unique(target);
            t1 = tu(1);
            t2 = tu(2);
            scorez = 1 ./ (1 + exp(scorez/2));
            % For proper "threshold-averages" ROC (see paper by Fawcett) we use "nthresh" equi-distant
            % thresholds between 0 and 1

            if length(target) > 1250; nThresholds = 4*length(target); end
            if mod(nThresholds, 2) == 1; nThresholds = nThresholds - 1; end % Make sure it is even
            thresholds = linspace(0, 1, nThresholds + 1);

            fpr = zeros(1, nThresholds + 1);
            tpr = fpr;
            tpr(1) = 1; fpr(1) = 1;

            for i = 1:nThresholds - 1
                % Count true positives, false positives
                tp = sum(target(score > thresholds(i+1)) == t2);
                fp = sum(target(score > thresholds(i+1)) == t1);
                fn = sum(target(score <= thresholds(i+1)) == t2);
                tn = sum(target(score <= thresholds(i+1)) == t1);

                % Compute corresponding rates
                tpr(i+1) = tp / (tp + fn);
                fpr(i+1) = fp / (tn + fp);
            end

            % Simple numerical integration
            %auroc = -trapz(fpr, tpr);
 %}
 
 f3= figure; 
 [X,Y,T,AUC] = perfcurve(trainLab{1},score',1);
 plot(X,Y,'LineWidth',2);
 title(['ROC curve      ',strcat( 'AUC: ',num2str(AUC))]);
