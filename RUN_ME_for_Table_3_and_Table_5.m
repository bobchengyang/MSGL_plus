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

addpath('datasets\'); %dataset

disp('1. Australian; 14 features.');
disp('2. Breast-cancer; 10 features.');
disp('3. Diabetes; 8 features.');
disp('4. Fourclass; 2 features.');
disp('5. German; 24 features.');
disp('6. Haberman; 3 features.');
disp('7. Heart; 13 features.');
disp('8. ILPD; 10 features.');
disp('9. Liver-disorders; 5 features.');
disp('10. Monk1; 6 features.');
disp('11. Pima; 8 features.');
disp('12. Planning; 12 features.');
disp('13. Voting; 16 features.');
disp('14. WDBC; 30 features.');
disp('15. Sonar; 60 features.');
disp('16. Madelon; 500 features.');
disp('17. Colon-cancer; 2000 features.');
% dataset_i = eval(input('please enter number 1-17 (# of the above datasets) to run: ', 's'));
learning_i=1;
acc_time=zeros(23,3);
for n_beta=3:3
    for dataset_i=1:23
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

        if dataset_i<16 || dataset_i>17

            % disp('1. 3-NN classifier.');
            % disp('2. Mahalanobis classifier.');
            % disp('3. GLR-based classifier.');
            % classifier_i = eval(input('please kindly choose 1 out of the above 3 classifiers to run:', 's'));
            classifier_i=3;

            % n_beta = eval(input('n_beta:', 's'));
            %     n_beta=2;

            obj_i=0;
            number_of_runs=10;
            accuracy_temp0=zeros(number_of_runs,1);
            accuracy_temp=zeros(number_of_runs,1);
            time_temp=zeros(number_of_runs,1);

            feature = read_data(:,1:end-1); % data features
            feature(isnan(feature))=0;
            label = read_data(:,end); % data labels

            K=5; % for classification 60% training 40% test

            for rngi = 0:9
                obj_i=obj_i+1;
                disp(['=====current random seed===== ' num2str(rngi)]);

                rng(rngi); % for re-producibility
                indices = crossvalind('Kfold',label,K); % K-fold cross-validation

                for fold_i = 1:1
                    for fold_j = 2:2
                        if fold_i<fold_j
                            disp('==========================================================================');
                            disp(['dataset ' num2str(dataset_i) '; classifier ' num2str(obj_i) '; folds ' num2str(fold_i) ' and ' num2str(fold_j)]);
                            test = (indices == fold_i | indices == fold_j); % these are indices for test data

                            train = ~test; % the remaining indices are for training data

                            % binary classification
                            [error_classifier,method_time,error_classifier0] = ...
                                binary_classification_new(dataset_i,n_beta, ...
                                feature, ...
                                label, ...
                                train, ...
                                test, ...
                                1, ...
                                -1, ...
                                classifier_i,...
                                learning_i);

                            %                         [error_classifier] = ...
                            %                             SGML_binary_classification( dataset_i, length(find(test)), ...
                            %                             feature, ...
                            %                             train, ...
                            %                             label, ...
                            %                             classifier_i);

                            accuracy_temp0(obj_i)=1-error_classifier0;
                            accuracy_temp(obj_i)=1-error_classifier;
                            time_temp(obj_i)=method_time;
                            disp(['classifier ' num2str(obj_i) ' | accuracy: ' num2str(accuracy_temp(obj_i)*100)]);

                        end
                    end
                end
            end

        else
            accuracy_temp=0;
            time_temp=0;
        end

        disp(['acc: ' num2str(mean(accuracy_temp)*100,'%.2f') char(177) num2str(std(accuracy_temp)*100,'%.2f')]);
        acc_time(dataset_i,1)=mean(accuracy_temp0)*100;
        acc_time(dataset_i,2)=mean(accuracy_temp)*100;
        acc_time(dataset_i,3)=mean(time_temp);
    end
end

clearvars -except acc_time
% save electronics_MSGL_multi.mat % MSGL
% save electronics_Cholesky_multi.mat % Cholesky
% save electronics_PDcone_multi.mat % PDcone
% save electronics_SGML_multi.mat % SGML
% save electronics_PGML_multi.mat % PGML
% save electronics_MSGL_binary.mat % MSGL
% save electronics_MSGL_new_binary_multi.mat % MSGL_new
% save electronics_Cholesky_binary.mat % Cholesky
% save electronics_PDcone_binary.mat % PDcone
% save electronics_SGML_binary.mat % SGML
% save electronics_PGML_binary.mat % PGML
% save electronics_HBNB_binary.mat % HBNB

















