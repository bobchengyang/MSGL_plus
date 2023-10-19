%=================================================================
% MSGL+
%
% author: Cheng Yang
% email me any questions: cheng.yang@shiep.edu.cn
% date: Oct 19th 2023
%=================================================================


clear;
clc;
close all;
addpath('graphLearning_datasets\'); %dataset
addpath('datasets\'); %dataset


% CanadaVehicle
% ftor=1e0;
% data_lasso=importdata('CanadaVehicle.xlsx')/ftor; % brand x month
% label=sum(data_lasso,2); % car sale total
% label(label<5e4/ftor)=1; % 50000  K=10
% label(label>5e4/ftor)=-1; % 50000
% data_lasso=[data_lasso label];

% USvote
% load USsenate_partial.mat
% data_lasso=us_vote_dataset_partial; %K=100
% data_lasso=[data_lasso(:,2:end) data_lasso(:,1)];

% Canadavote
load CanadaHouse_partial.mat
data_lasso=canada_vote_dataset_partial;
data_lasso=[data_lasso(:,2:end) data_lasso(:,1)];
data_lasso=data_lasso(1:50,[1:500 size(data_lasso,2)]); % 50 500 K = 10

% dataset_i = eval(input('please enter number 1-17 (# of the above datasets) to run: ', 's'));
learning_i=1;
acc_time=zeros(10,3);
for n_beta=3:3
    for dataset_i=1:1
%         img=imread('saturn.png');
%         imgbw=imbinarize(im2gray(img));
%         read_data=double(imresize(imgbw,1/16));
%         figure(1);subplot(3,1,1);imshow(read_data);
        
        [data_m,data_n]=size(data_lasso(:,1:end-1));
        groundtruthdata=data_lasso(:,1:end-1);
        groundtruthlabel=data_lasso(:,end);
        groundtruthlabel(groundtruthlabel==-1)=2;
        totalobservation=data_m;
        %build 4-connected graph
        
        adjacency_matrix=zeros(totalobservation,totalobservation);
        
        for graph_i=1:totalobservation
            if graph_i-1>0 && mod(graph_i-1,data_m)~=0 % graph_i-1
                adjacency_matrix(graph_i,graph_i-1)=1;
                adjacency_matrix(graph_i-1,graph_i)=1;
            end
            if  mod(graph_i+1,data_m)~=1 % graph_i+1
                adjacency_matrix(graph_i,graph_i+1)=1;
                adjacency_matrix(graph_i+1,graph_i)=1;
            end
            if graph_i-data_m>0 % graph_i-data_m
                adjacency_matrix(graph_i,graph_i-data_m)=1;
                adjacency_matrix(graph_i-data_m,graph_i)=1;
            end
            if graph_i+data_m<totalobservation % graph_i+data_m
                adjacency_matrix(graph_i,graph_i+data_m)=1;
                adjacency_matrix(graph_i+data_m,graph_i)=1;
            end
        end

        noise_level=1;
        rng(1);
        noisydata=groundtruthdata+randn(totalobservation,1)*noise_level;
%         figure(1);subplot(3,1,2);imshow(reshape(noisydata,[data_m data_n]));
        
%         full_data=[noisydata repmat((1:data_m)',data_n,1) vec(repmat((1:data_n)',1,data_m)')];
        noisydata=sign(noisydata);
        noisydata(noisydata==-1)=2;
%         if dataset_i<16 || dataset_i>17
% 
            % disp('1. 3-NN classifier.');
            % disp('2. Mahalanobis classifier.');
            % disp('3. GLR-based classifier.');
            % classifier_i = eval(input('please kindly choose 1 out of the above 3 classifiers to run:', 's'));
            classifier_i=3;

%             % n_beta = eval(input('n_beta:', 's'));
%             %     n_beta=2;
% 
%             obj_i=0;
%             number_of_runs=10;
%             accuracy_temp=zeros(number_of_runs,1);
%             time_temp=zeros(number_of_runs,1);
% 
%             feature = read_data(:,1:end-1); % data features
%             feature(isnan(feature))=0;
%             label = read_data(:,end); % data labels

            K=10; % for classification 60% training 40% test
                

                for fold_i=1:10
                rng(fold_i); % for re-producibility
                indices = crossvalind('Kfold',groundtruthlabel,K); % K-fold cross-validation
                    %                         if fold_i<fold_j
                    disp('==========================================================================');
                    disp(['dataset ' num2str(dataset_i) '; classifier ' num2str(classifier_i) '; folds ' num2str(fold_i)]);
                    train = (indices == 1); % these are indices for test data

                    test = ~train; % the remaining indices are for training data

                    % binary classification
                    [error_classifier,method_time,error_classifier_0] = ...
                        binary_classification_new_ts(dataset_i,n_beta, ...
                        groundtruthdata, ...
                        groundtruthlabel, ...
                        train, ...
                        test, ...
                        1, ...
                        -1, ...
                        classifier_i,...
                        learning_i,...
                        adjacency_matrix,...
                        data_m,...
                        data_n);

                    %                         [error_classifier] = ...
                    %                             SGML_binary_classification( dataset_i, length(find(test)), ...
                    %                             feature, ...
                    %                             train, ...
                    %                             label, ...
                    %                             classifier_i);

                    %                             accuracy_temp(obj_i)=1-error_classifier;
                    %                             time_temp(obj_i)=method_time;
                    %                             disp(['classifier ' num2str(obj_i) ' | accuracy: ' num2str(accuracy_temp(obj_i)*100)]);

                    %                         end
                    %                     end
                    %                 end
                            acc_time(fold_i,1)=(1-error_classifier_0)*100;
        acc_time(fold_i,2)=(1-error_classifier)*100;
        acc_time(fold_i,3)=method_time;
                end
%             end
% 
%         else
%             accuracy_temp=0;
%             time_temp=0;
%         end

        disp(['acc before: ' num2str(mean(acc_time(:,1)))  ' acc after: ' num2str(mean(acc_time(:,2))) ' time: ' num2str(mean(acc_time(:,3)))]);
%         acc_time(dataset_i,1)=mean(accuracy_temp)*100;
%         acc_time(dataset_i,2)=mean(time_temp);
    end
end

clearvars -except acc_time
% save electronics_proposed_binary.mat % proposed
% save electronics_Cholesky_binary.mat % Cholesky
% save electronics_PDcone_binary.mat % PDcone
% save electronics_SGML_binary.mat % SGML
% save electronics_PGML_binary.mat % PGML
% save electronics_HBNB_binary.mat % HBNB

















