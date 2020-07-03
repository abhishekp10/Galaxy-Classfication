%Program to concatenate most relevant features from each catalogue

addpath(genpath('.'));


con11 = load('concat/cass5_1.mat');
con12 = load('concat/cass5_2.mat');
con13 = load('concat/cass5_3.mat');
con14 = load('concat/cass5_4.mat');
con15 = load('concat/cass5_5.mat');
columns = [con11.os.columns,con12.os.columns,con13.os.columns,con14.os.columns,con15.os.columns];
%idxs = [con11.os.idxs,con12.os.idxs,con13.os.idxs,con14.os.idxs,con15.os.idxs];
data = [con11.os.data,con12.os.data,con13.os.data,con14.os.data,con15.os.data];
labels =con11.os.labels;


save('LTS_combined_full_no_petro50','columns','data','labels');

