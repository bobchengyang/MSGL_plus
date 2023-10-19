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

%            AT3_1m4_01.tif            AT3_1m4_02.tif
%            AT3_1m4_03.tif            AT3_1m4_04.tif
%            AT3_1m4_05.tif            AT3_1m4_06.tif
%            AT3_1m4_07.tif            AT3_1m4_08.tif
%            AT3_1m4_09.tif            AT3_1m4_10.tif
%                autumn.tif                   bag.png
%                 blobs.png                 board.tif
%             cameraman.tif                 canoe.tif
%                  cell.tif                circbw.tif
%               circles.png               circuit.tif
%                 coins.png         concordaerial.png
%     concordorthophoto.png                 eight.tif
%                fabric.png              football.jpg
%                forest.tif           gantrycrane.png
%                 glass.png                greens.jpg
%               hestain.png                  kids.tif
%           liftingbody.png                  logo.tif
%                   m83.tif                 mandi.tif
%                  moon.tif                   mri.tif
%              office_1.jpg              office_2.jpg
%              office_3.jpg              office_4.jpg
%              office_5.jpg              office_6.jpg
%                 onion.png                paper1.tif
%                 pears.png               peppers.png
%              pillsetc.png                  pout.tif
%                  rice.png                saturn.png
%                shadow.tif            snowflakes.png
%                 spine.tif                  tape.png
%              testpat1.png                  text.png
%                  tire.tif                tissue.png
%                 trees.tif     westconcordaerial.png
% westconcordorthophoto.png

% dataset_i = eval(input('please enter number 1-17 (# of the above datasets) to run: ', 's'));
learning_i=1;
acc_time=zeros(20,3);
acc_time0=zeros(10,3);
for n_beta=3:3
    for dataset_i=1:20
        if dataset_i==1
        str='cameraman';str1=[str '.tif'];
        elseif dataset_i==2
        str='saturn';str1=[str '.png'];
        elseif dataset_i==3
        str='moon';str1=[str '.tif'];
        elseif dataset_i==4
        str='spine';str1=[str '.tif'];
        elseif dataset_i==5
        str='tire';str1=[str '.tif'];
        elseif dataset_i==6
        str='rice';str1=[str '.png'];
        elseif dataset_i==7
        str='testpat1';str1=[str '.png'];
        elseif dataset_i==8
        str='canoe';str1=[str '.tif'];
        elseif dataset_i==9
        str='AT3_1m4_02';str1=[str '.tif'];
        elseif dataset_i==10
        str='fabric';str1=[str '.png'];
        elseif dataset_i==11
        str='gantrycrane';str1=[str '.png'];
        elseif dataset_i==12
        str='eight';str1=[str '.tif'];
        elseif dataset_i==13
        str='circuit';str1=[str '.tif'];
        elseif dataset_i==14
        str='mri';str1=[str '.tif'];
        elseif dataset_i==15
        str='lena_std';str1=[str '.tif'];
        elseif dataset_i==16
        str='football';str1=[str '.jpg'];
        elseif dataset_i==17
        str='glass';str1=[str '.png'];
        elseif dataset_i==18
        str='pears';str1=[str '.png'];
        elseif dataset_i==19
        str='concordaerial';str1=[str '.png'];
        elseif dataset_i==20
        str='autumn';str1=[str '.tif'];
        end



        img=imread(str1);
        imgbw=imbinarize(im2gray(img));
        [data_m,data_n]=size(imgbw);
        read_data=double(imresize(imgbw,sqrt(1000/(data_m*data_n)))); % saturn.png

%         imwrite(imadjust(img),['matlab_img_' str '.png'],'png');
%         imwrite(read_data,['matlab_img_' str '_binary.png'],'png');
        figure(1);subplot(3,1,1);imshow(img);

        [data_m,data_n]=size(read_data);
        groundtruthdata=vec(read_data);
        groundtruthlabel=groundtruthdata;
        groundtruthlabel(groundtruthlabel==0)=2;
        totalobservation=length(groundtruthdata);
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
        noise_level=1;

        
        if dataset_i~=16
            K=2; % for classification 60% training 40% test
        rng(0); % for re-producibility
        else
            K=2; % for classification 60% training 40% test
            rng(0);
        end
        indices = crossvalind('Kfold',groundtruthlabel,K); % K-fold cross-validation
        for fold_i=1:10

        rng(fold_i);
        noisydata=groundtruthdata+randn(totalobservation,1)*noise_level;
        noisydata_img=reshape(noisydata,[data_m data_n]);
        imwrite(noisydata_img,['matlab_img_' str '_binary_noisy.png'],'png');
        figure(1);subplot(3,1,2);imshow(noisydata_img);

        full_data=[noisydata repmat((1:data_m)',data_n,1) vec(repmat((1:data_n)',1,data_m)')];

            %         noisydata=sign(noisydata);
            %         noisydata(noisydata==-1)=2;
            %                         if fold_i<fold_j
            disp('==========================================================================');
            disp(['dataset ' num2str(dataset_i) '; classifier ' num2str(classifier_i) '; folds ' num2str(fold_i)]);
            train = (indices == 1); % these are indices for test data

            test = ~train; % the remaining indices are for training data

            % binary classification
            [error_classifier,method_time,error_classifier_0] = ...
                binary_classification_new_img(dataset_i,n_beta, ...
                full_data, ...
                groundtruthlabel, ...
                train, ...
                test, ...
                1, ...
                -1, ...
                classifier_i,...
                learning_i,...
                adjacency_matrix,...
                data_m,...
                data_n,str);

            %                         [error_classifier] = ...
            %                             SGML_binary_classification( dataset_i, length(find(test)), ...
            %                             feature, ...
            %                             train, ...
            %                             label, ...
            %                             classifier_i);

            %                             accuracy_temp(obj_i)=1-error_classifier;
            %                             time_temp(obj_i)=method_time;
            %                             disp(['classifier ' num2str(obj_i) ' | accuracy: ' num2str(accuracy_temp(obj_i)*100)]);

            acc_time0(fold_i,1)=(1-error_classifier_0)*100;
            acc_time0(fold_i,2)=(1-error_classifier)*100;
            acc_time0(fold_i,3)=method_time;
        end
        %             end
        %
        %         else
        %             accuracy_temp=0;
        %             time_temp=0;
        %         end
        mean_acc_before=mean(acc_time0(:,1));
        mean_acc_after=mean(acc_time0(:,2));
        mean_time=mean(acc_time0(:,3));
        acc_time(dataset_i,:)=[mean_acc_before mean_acc_after mean_time];
        disp(['acc before: ' num2str(mean_acc_before)  ' acc after: ' num2str(mean_acc_after) ...
            ' time: ' num2str(mean_time)]);
        %         acc_time(dataset_i,1)=mean(accuracy_temp)*100;
        %         acc_time(dataset_i,2)=mean(time_temp);
    end
end

clearvars -except acc_time acc_time0
% save electronics_MSGL_img_16_20.mat % MSGL
% save electronics_Cholesky_img_16_20.mat % Cholesky
% save electronics_PDcone_img_16_20.mat % PDcone
% save electronics_SGML_img_16_20.mat % SGML
% save electronics_PGML_img_16_20.mat % PGML
% save electronics_HBNB_img_16_20.mat % HBNB
% save electronics_MSGL_new_img_binary.mat % MSGL_new
% save electronics_proposed_binary.mat % proposed
% save electronics_Cholesky_binary.mat % Cholesky
% save electronics_PDcone_binary.mat % PDcone
% save electronics_SGML_binary.mat % SGML
% save electronics_PGML_binary.mat % PGML
% save electronics_HBNB_binary.mat % HBNB

















