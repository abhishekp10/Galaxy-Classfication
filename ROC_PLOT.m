%Plot multiple ROC curves with AUC for comparison
dat1 = load('roc_results1_2.mat');
lab1 = dat1.A1{1};
sco1= dat1.B1;

[X1,Y1,T1,AUC1] = perfcurve(lab1,sco1,1);

dat2 = load('roc_results2_2.mat');
lab2 = dat2.A1{1};
sco2= dat2.B1;

[X2,Y2,T2,AUC2] = perfcurve(lab2,sco2,1);

dat3 = load('roc_results3_2.mat');
lab3 = dat3.A1{1};
sco3= dat3.B1;

[X3,Y3,T3,AUC3] = perfcurve(lab3,sco3,1);

dat4 = load('roc_results4_2.mat');
lab4 = dat4.A1{1};
sco4= dat4.B1;

[X4,Y4,T4,AUC4] = perfcurve(lab4,sco4,1);

dat5 = load('roc_results5_2.mat');
lab5 = dat5.A1{1};
sco5= dat5.B1;

[X5,Y5,T5,AUC5] = perfcurve(lab5,sco5,1);

dat6 = load('results6_2.mat');
lab6 = dat6.A1{1};
sco6= dat6.B1;

[X6,Y6,T6,AUC6] = perfcurve(lab6,sco6,1);

f2= figure; 
plot(X1,Y1,'LineWidth',1);
hold on;
plot(X2,Y2,'LineWidth',1);
plot(X3,Y3,'LineWidth',1);
plot(X4,Y4,'LineWidth',1);
plot(X5,Y5,'LineWidth',1);
plot(X6,Y6,'LineWidth',1);
lgd= legend(['GFS       ',strcat( 'AUC: ',num2str(AUC1))],['Lambdar   ',strcat('AUC: ',num2str(AUC2))],['MagPhys   ',strcat('AUC: ',num2str(AUC3))],['Ukidss   ',strcat('AUC: ',num2str(AUC4))],['Viking   ',strcat('AUC: ',num2str(AUC5))],['Combined   ',strcat('AUC: ',num2str(AUC6))]);
lgd.Location ='southeast';
xlabel('False positive rate'); ylabel('True positive rate');
title('ROC Curves for Little blue speriods vs others');
hold off;

