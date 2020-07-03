%Compare relevance profiles
%local vs global
%2 class problem vs all class problem

dt5L = load('L_LBS_5.mat');
dt5G = load('G_LBS_5.mat');
dt2L = load('L_LBS_2.mat');
dt2G = load('G_LBS_2.mat');
dat = load('galaxy_datasets_for_reseach_internship/Sersic_VIKING.mat');
R1=  dat.columns';

R2L=[dt2L.meanmat dt2G.mean];
R3L=[dt2L.maxerr dt2G.maxerr];
R4L=[dt2L.minerr dt2G.minerr];
R2G=[dt5L.mean dt5G.mean];
R3G=[dt5L.maxerr dt5G.maxerr];
R4G=[dt5L.minerr dt5G.minerr];

f=figure(...%'WindowState', 'fullscreen', ...
       'MenuBar', 'none', ...
       'ToolBar', 'none');

   subplot(2,1,1);
    hold on;
    hL= bar(R2L,'grouped');
    %set(br,'facecolor',[ 0.9843 0.9157 0.9882])
    set(gca, 'XTickLabel',R1, 'XTick',1:numel(R1))
    set(gca,'TickLabelInterpreter','none')
    
    
    xtickangle(90)
    
    nbarsL= size(R2L, 2);
    ngroupsL = size(R2L, 1);
    conL=[R2L(:,1);R2L(:,2)]; 
    groupwidthL = min(0.8, nbars/(nbars + 1.5));
    for i = 1:nbarsL
        xL = (1:ngroupsL) - groupwidthL/2 + (2*i-1) * groupwidthL / (2*nbarsL);
        erL = errorbar(xL,R2L(:,i),R4L(:,i),R3L(:,i));     
        erL.Color = [0 0 0];                            
        erL.LineStyle = 'none';  
    end
    ylabel('2 class Relevance profile - VIKING', ... 
        'FontName','LucidaSans', 'FontWeight','bold'); 
    %xlabel('features'); 
    grid on;  axis 'auto y'; box on;
    %axis([0.3 LGMLVQparams.dim+0.7 0 (0.01+max(meanmat))]); 
    axis([0.3 ngroupsL+0.7 0 (0.01+max(conL))]);  
    lgd= legend('LBS local','global');
    lgd.Location ='north';
    lgd.Orientation = 'horizontal';
    hold off;
    
    
    subplot(2,1,2); 
    hold on;
    h= bar(R2G,'grouped');
    %set(br,'facecolor',[ 0.9843 0.9157 0.9882])
    set(gca, 'XTickLabel',R1, 'XTick',1:numel(R1))
    set(gca,'TickLabelInterpreter','none')
    
    
    xtickangle(90)
    
    nbars= size(R2G, 2);
    ngroups = size(R2G, 1);
    con=[R2G(:,1);R2G(:,2)]; 
    groupwidth = min(0.8, nbars/(nbars + 1.5));
    for i = 1:nbars
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        er = errorbar(x,R2G(:,i),R4G(:,i),R3G(:,i));     
        er.Color = [0 0 0];                            
        er.LineStyle = 'none';  
    end
    ylabel('5 class Relevance profile - VIKING', ... 
        'FontName','LucidaSans', 'FontWeight','bold'); 
    %xlabel('features'); 
    grid on;  axis 'auto y'; box on;
    %axis([0.3 LGMLVQparams.dim+0.7 0 (0.01+max(meanmat))]); 
    axis([0.3 ngroups+0.7 0 (0.01+max(con))]);  
    lgd= legend('LBS local','global');
    lgd.Location ='northeast';
    lgd.Orientation = 'horizontal';
    hold off;