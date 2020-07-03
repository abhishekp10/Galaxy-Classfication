%Program to plot relevance profiles with variance across 10 runs


%save('dt2206_LBS_2class.mat','LGMLVQ_results','dat');

opt = 2;
%{
LBSR1=  diag(LGMLVQ_results{1}{1}.LGMLVQ_model.psis{opt}'*LGMLVQ_results{1}{1}.LGMLVQ_model.psis{opt});
LBSR2=  diag(LGMLVQ_results{2}{1}.LGMLVQ_model.psis{opt}'*LGMLVQ_results{2}{1}.LGMLVQ_model.psis{opt});
LBSR3=  diag(LGMLVQ_results{3}{1}.LGMLVQ_model.psis{opt}'*LGMLVQ_results{3}{1}.LGMLVQ_model.psis{opt});
LBSR4=  diag(LGMLVQ_results{4}{1}.LGMLVQ_model.psis{opt}'*LGMLVQ_results{4}{1}.LGMLVQ_model.psis{opt});
LBSR5=  diag(LGMLVQ_results{5}{1}.LGMLVQ_model.psis{opt}'*LGMLVQ_results{5}{1}.LGMLVQ_model.psis{opt});
LBSR6=  diag(LGMLVQ_results{6}{1}.LGMLVQ_model.psis{opt}'*LGMLVQ_results{6}{1}.LGMLVQ_model.psis{opt});
LBSR7=  diag(LGMLVQ_results{7}{1}.LGMLVQ_model.psis{opt}'*LGMLVQ_results{7}{1}.LGMLVQ_model.psis{opt});
LBSR8=  diag(LGMLVQ_results{8}{1}.LGMLVQ_model.psis{opt}'*LGMLVQ_results{8}{1}.LGMLVQ_model.psis{opt});
LBSR9=  diag(LGMLVQ_results{9}{1}.LGMLVQ_model.psis{opt}'*LGMLVQ_results{9}{1}.LGMLVQ_model.psis{opt});
LBSR10= diag(LGMLVQ_results{10}{1}.LGMLVQ_model.psis{opt}'*LGMLVQ_results{10}{1}.LGMLVQ_model.psis{opt});
%}
LBSR1=  diag(LGMLVQ_results{1}{1}.GMLVQ_model.omega'*LGMLVQ_results{1}{1}.GMLVQ_model.omega);
LBSR2=  diag(LGMLVQ_results{2}{1}.GMLVQ_model.omega'*LGMLVQ_results{2}{1}.GMLVQ_model.omega);
LBSR3=  diag(LGMLVQ_results{3}{1}.GMLVQ_model.omega'*LGMLVQ_results{3}{1}.GMLVQ_model.omega);
LBSR4=  diag(LGMLVQ_results{4}{1}.GMLVQ_model.omega'*LGMLVQ_results{4}{1}.GMLVQ_model.omega);
LBSR5=  diag(LGMLVQ_results{5}{1}.GMLVQ_model.omega'*LGMLVQ_results{5}{1}.GMLVQ_model.omega);
LBSR6=  diag(LGMLVQ_results{6}{1}.GMLVQ_model.omega'*LGMLVQ_results{6}{1}.GMLVQ_model.omega);
LBSR7=  diag(LGMLVQ_results{7}{1}.GMLVQ_model.omega'*LGMLVQ_results{7}{1}.GMLVQ_model.omega);
LBSR8=  diag(LGMLVQ_results{8}{1}.GMLVQ_model.omega'*LGMLVQ_results{8}{1}.GMLVQ_model.omega);
LBSR9=  diag(LGMLVQ_results{9}{1}.GMLVQ_model.omega'*LGMLVQ_results{9}{1}.GMLVQ_model.omega);
LBSR10= diag(LGMLVQ_results{10}{1}.GMLVQ_model.omega'*LGMLVQ_results{10}{1}.GMLVQ_model.omega);



R1=  dat.columns';
mean = (LBSR1 + LBSR2 + LBSR3 + LBSR4 + LBSR5 + LBSR6 + LBSR7 + LBSR8 + LBSR9 + LBSR10)/10;

[meanmat , midx] = sort(mean,'descend');
maxer= []; miner= []; maxerr= []; minerr= [];R2= [];


for i=1:length(LBSR1)
    %R2 = [ R2 ; R1(midx)];
    maxval = max([LBSR1(i) LBSR2(i) LBSR3(i) LBSR4(i) LBSR5(i) LBSR6(i) LBSR7(i) LBSR8(i) LBSR9(i) LBSR10(i)]) - mean(i);
    minval = mean(i) - min([LBSR1(i) LBSR2(i) LBSR3(i) LBSR4(i) LBSR5(i) LBSR6(i) LBSR7(i) LBSR8(i) LBSR9(i) LBSR10(i)]);
    maxer = [ maxer ; maxval];
    miner = [ miner; minval];
end


    R2 = [ R2 ; R1(midx)];
    %R2= R1;
    %maxerr =maxer; minerr=miner;
    maxerr = [ maxerr ; maxer(midx)];
    minerr = [ minerr; miner(midx)];


f=figure;

    h= bar(meanmat);
    %set(br,'facecolor',[ 0.9843 0.9157 0.9882])
    set(gca, 'XTickLabel',R2, 'XTick',1:numel(R2))
    set(gca,'TickLabelInterpreter','none')
    h.FaceColor = 'flat';
    sum =0;
    
    for i= 1: length(meanmat)
        sum = sum + meanmat(i);
        if sum >= 0.5         
            pointer= i;
            h.CData(pointer,:) = [.9 0.1 .1];
            disp(i)
        end
    end
    
    xtickangle(90)
    hold on;
    
    er = errorbar(1:65,meanmat,minerr,maxerr);     
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    ylabel('Local Relevance profile for LBS VIKING catalogue- 5 class problem', ... 
        'FontName','LucidaSans', 'FontWeight','bold'); 
    xlabel('features'); 
    grid on;  axis 'auto y'; box on;
    %axis([0.3 LGMLVQparams.dim+0.7 0 (0.01+max(meanmat))]); 
    axis([0.3 GMLVQparams.dim+0.7 0 (0.01+max(mean))]);  
    hold off;
    
    
    %save('L_LBS_5.mat','LGMLVQ_results','dat','mean','minerr','maxerr');
    

