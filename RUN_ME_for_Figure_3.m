clear;
clc;
close all;
addpath('results\');
addpath('datasets\');
n_dataset=6;
% n_results=7;
n_method=4;
font_size=12;
% results_mean=zeros(n_dataset+1,n_results);

acc_time_all=zeros(6,4);

load electronics_Cholesky_multi.mat
acc_time_all(:,1)=acc_time(:,end);
load electronics_PDcone_multi.mat
acc_time_all(:,2)=acc_time(:,end);
% load electronics_HBNB_binary.mat
% acc_time_all(:,3)=acc_time(:,end);
% load electronics_SGML_binary.mat
% acc_time_all(:,4)=acc_time(:,end);
% load electronics_PGML_binary.mat
% acc_time_all(:,5)=acc_time(:,end);
load electronics_MSGL_multi.mat
acc_time_all(:,3)=acc_time(:,end);
load electronics_MSGL_new_binary_multi.mat
acc_time_all(:,4)=acc_time(18:23,end);
acc_time_all=[acc_time_all;mean(acc_time_all)];
%             results(result_seq_i,:)=[error_count_sedumi t_sedumi...
%                                      error_count_mosek  t_mosek...
%                                      error_count_cdcs8  t_cdcs8...
%                                      error_count_bcr    t_bcr...
%                                      error_count_sdcut  t_sdcut...
%                                      error_count_cdcs20 t_cdcs20...
%                                      err_count_gdpa     t_gdpa...
%                                      err_count_glrbox   t_glrbox...
%                                      err_count_glr      t_glr...
%                                      error_count_sns t_sns];

% % % for dataset_i=1:n_dataset
% % %     [dataset_str] = get_dataset_name(dataset_i);
% % %     result_str=['results_' dataset_str '_min_max_scaling_aaai23_I.mat'];
% % %     load(result_str);
% % %     results_mean(dataset_i,:)=mean(results);   
% % % end
% % % results_mean(dataset_i+1,:)=mean(results_mean(1:dataset_i,:));
% % % 
% % % 
% % % results_mean=results_mean(:,[1:16 19:20]); % remove GLR


% results_err=results_mean(:,1:2:end-1);
% results_time=results_mean(:,2:2:end);
results_time=acc_time_all*1000;

size_temp=zeros(6,1);
    for dataset_i=18:23
        if dataset_i==1
            read_data = importdata('australian.csv');
        elseif dataset_i==2
            read_data = importdata('breast-cancer.csv');
        elseif dataset_i==3
            read_data = importdata('diabetes.csv');
        elseif dataset_i==4
            read_data = importdata('fourclass.csv');
        elseif dataset_i==5
            read_data = importdata('german.csv');
        elseif dataset_i==6
            read_data = importdata('haberman.csv');
        elseif dataset_i==7
            read_data = importdata('heart.dat');
        elseif dataset_i==8
            read_data = importdata('Indian Liver Patient Dataset (ILPD).csv');
        elseif dataset_i==9
            read_data = importdata('liver-disorders.csv');
        elseif dataset_i==10
            read_data = importdata('monk1.csv');
        elseif dataset_i==11
            read_data = importdata('pima.csv');
        elseif dataset_i==12
            read_data = importdata('planning.csv');
        elseif dataset_i==13
            read_data = importdata('voting.csv');
        elseif dataset_i==14
            read_data = importdata('WDBC.csv');
        elseif dataset_i==15
            read_data = importdata('sonar.csv');
        elseif dataset_i==16
            read_data = importdata('madelon.csv');
        elseif dataset_i==17
            read_data = importdata('colon-cancer.csv');
        elseif dataset_i==18
            read_data = importdata('cleveland.data');
        elseif dataset_i==19
            read_data = importdata('glass.data');
        elseif dataset_i==20
            read_data = importdata('iris.data');
        elseif dataset_i==21
            read_data = importdata('new-thyroid.data');
        elseif dataset_i==22
            read_data = importdata('tae.data');
        elseif dataset_i==23
            read_data = importdata('winequality-red.csv');
        end
        size_temp(dataset_i-17)=size(read_data,1);
    end
% datasize_order=zeros(n_dataset,1);
% for dataset_i=1:17
%     [dataset_str,read_data] = get_data_quiet(dataset_i);
%     label=read_data(:,end);
%     if dataset_i~=17
%     K=5; % 5-fold
%     else
%     K=1;   
%     end
%     rng(0);
%     indices = crossvalind('Kfold',label,K); % K-fold cross-validation
%     read_data_i=read_data(indices==1,:);
%     datasize_order(dataset_i)=size(read_data_i,1);
% end
% 
[datasize_order_value,datasize_order_idx]=sort(size_temp);
datasize_order_idx=[datasize_order_idx; 7];
% 
% results_err=results_err(datasize_order_idx,:);
results_time=results_time(datasize_order_idx,:);

method_name=["Cholesky" ...
    'PDcone' ...
    'MSGL' ...
    '\color{black}\bfMSGL+'];

%         str='cameraman';str1=[str '.tif'];
%         str='saturn';str1=[str '.png'];
%         str='moon';str1=[str '.tif'];
%         str='spine';str1=[str '.tif'];
%         str='tire';str1=[str '.tif'];
%         str='rice';str1=[str '.png'];
%         str='testpat1';str1=[str '.png'];
%         str='canoe';str1=[str '.tif'];
%         str='AT3_1m4_02';str1=[str '.tif'];
%         str='fabric';str1=[str '.png'];
%         str='gantrycrane';str1=[str '.png'];
%         str='eight';str1=[str '.tif'];
%         str='circuit';str1=[str '.tif'];
%         str='mri';str1=[str '.tif'];
%         str='paper1';str1=[str '.tif'];
%         str='football';str1=[str '.jpg'];
%         str='glass';str1=[str '.png'];
%         str='pears';str1=[str '.png'];
%         str='concordaerial';str1=[str '.png'];
%         str='autumn';str1=[str '.tif'];

% names = {'cameraman'; 
%     'saturn'; 
%     'moon';...
%     'spine'; 
%     'tire'; 
%     'rice';...
%     'testpat1'; 
%     'canoe'; 
%     'AT3\_1m4\_02';...
%     'fabric'; 
%     'gantrycrane'; 
%     'eight';...
%     'circuit'; 
%     'mri'; 'paper1';...
%     'football';
%     'glass';
%     'pears'; 'concordaerial'; 'autumn';
%     '\color{black}\bfavg.'};

% names = {'australian'; 'breast-cancer'; 'diabetes';...
%     'fourclass'; 'german'; 'haberman';...
%     'heart'; 'ILPD'; 'liver-disorders';...
%     'monk1'; 'pima'; 'planning';...
%     'voting'; 'WDBC'; 'sonar'; '\color{black}\bfavg.'};

names = {'cleveland'; 'glass'; 'iris';...
    'new-thyroid'; 'tae'; 'winequality-red';...
   '\color{black}\bfavg.'};


% names=names(datasize_order_idx);

ncolors = distinguishable_colors(6);
method_ii=[1 2 3 4];
% figure();hold on;
% for i=1:n_method
%     if i<=4
%         plot(results_err(:,method_ii(i)),...
%             'LineStyle','none',...
%             'LineWidth',1,...
%             'Marker','+',...
%             'color',ncolors(method_ii(i),:),'DisplayName',num2str(method_name(method_ii(i))));
%     elseif i==5
%         plot(results_err(:,method_ii(i)),...
%             'LineStyle','none',...
%             'LineWidth',1,...
%             'Marker','s',...
%             'color',ncolors(method_ii(i),:),'DisplayName',num2str(method_name(method_ii(i))));
%     elseif i==6
%         plot(results_err(:,method_ii(i)),...
%             'LineStyle','none',...
%             'LineWidth',1,...
%             'Marker','p',...
%             'color',ncolors(method_ii(i),:),'DisplayName',num2str(method_name(method_ii(i))));
%     elseif i==9
%         plot(results_err(:,method_ii(i)),...
%             'LineStyle','none',...
%             'LineWidth',1,...
%             'Marker','x',...
%             'color',ncolors(method_ii(i),:),'DisplayName',num2str(method_name(method_ii(i))));
%     else
%         plot(results_err(:,method_ii(i)),...
%             'LineStyle','none',...
%             'LineWidth',1,...
%             'Marker','o',...
%             'color',ncolors(method_ii(i),:),'DisplayName',num2str(method_name(method_ii(i))));
%     end
% end
% 
% ylabel('error rate (%)', 'FontSize', font_size);
% set(gca,'fontname','times', 'FontSize', font_size) 
% xlim([1 n_dataset+1]);
% set(gca,'xtick',(1:n_dataset+1),'xticklabel',names);xtickangle(90);
% ylim([min(vec(results_err)) max(vec(results_err))]);
% grid on;
% legend;
% title('Fig.3 left');

figure();hold on;
for i=1:n_method 
    if i<=2
        plot(results_time(:,method_ii(i)),...
            'LineStyle','none',...
            'LineWidth',1,...
            'Marker','+',...
            'color',ncolors(method_ii(i),:),'DisplayName',num2str(method_name(method_ii(i))));
    elseif i==5
        plot(results_time(:,method_ii(i)),...
            'LineStyle','none',...
            'LineWidth',1,...
            'Marker','s',...
            'color',ncolors(method_ii(i),:),'DisplayName',num2str(method_name(method_ii(i))));
    elseif i==3
        plot(results_time(:,method_ii(i)),...
            'LineStyle','none',...
            'LineWidth',1,...
            'Marker','p',...
            'color',ncolors(6,:),'DisplayName',num2str(method_name(method_ii(i))));
    elseif i==9
        plot(results_err(:,method_ii(i)),...
            'LineStyle','none',...
            'LineWidth',1,...
            'Marker','x',...
            'color',ncolors(method_ii(i),:),'DisplayName',num2str(method_name(method_ii(i))));
    else
        plot(results_time(:,method_ii(i)),...
            'LineStyle','none',...
            'LineWidth',1,...
            'Marker','o',...
            'color',ncolors(method_ii(i),:),'DisplayName',num2str(method_name(method_ii(i))));
    end
end

ylabel('runtime (ms)', 'FontSize', font_size);
set(gca,'fontname','times', 'FontSize', font_size)  % Set it to times
xlim([1 n_dataset+1]);
set(gca,'xtick',(1:n_dataset+1),'xticklabel',names);xtickangle(90);
ylim([min(vec(results_time)) max(vec(results_time))]);
grid on;
set(gca, 'YScale', 'log')
legend;
% title('Fig.4 left');