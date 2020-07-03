%Plot relevance plots for different classes

A1=trainLab(10);
%B1=score';
%R1=[diag(lambda{1}) diag(lambda{2}) diag(lambda{3}) diag(lambda{4}) diag(lambda{5})];
R1=[diag(lambda{1}) diag(lambda{2})];
R2=dat.columns' ;
%R1a = R1(121:177,:);
%R2a = R2(121:177);
%save('results6_2.mat','A1','B1','R1','R2');

f1= figure;
bar(R1,'grouped')
set(gca, 'XTickLabel',R2, 'XTick',1:numel(R2))
set(gca,'TickLabelInterpreter','none')
%set(gcf,'Position',[10 10 500 5000])
%lgd= legend('Class 1','Class 2','Class 3','Class 4','Class 5');
lgd= legend('LTS','others');
lgd.Location ='north';
%ylim([0 0.05])
title([actData, ' field relevances - 2 class ']);
xtickangle(90)
