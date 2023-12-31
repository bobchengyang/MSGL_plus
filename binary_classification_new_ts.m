function [error_classifier,method_time,error_classifier_0] = ...
    binary_classification_new_ts(dataset_i,n_beta, ...
    feature, ...
    class, ...
    train, ...
    test, ...
    class_i, ...
    class_j, ...
    classifier_i,...
    learning_i,...
    adjacency_matrix,m,n)

% class(class~=class_i) = class_j; % turn ground truth labels to a binary one

train_index = train;
test_index = test;

% % feature_train = feature(train_index,:);
% % 
% % mean_TRAIN_set_0 = mean(feature_train);
% % std_TRAIN_set_0 = std(feature_train);
% % 
% % mean_TRAIN_set = repmat(mean_TRAIN_set_0,size(feature_train,1),1);
% % std_TRAIN_set = repmat(std_TRAIN_set_0,size(feature_train,1),1);
% % 
% % feature_train = (feature_train - mean_TRAIN_set)./std_TRAIN_set;
% % 
% % if length(find(isnan(feature_train)))>0
% %     error('features have NaN(s)');
% % end
% % 
% % feature_train_l2=sqrt(sum(feature_train.^2,2));
% % for i=1:size(feature_train,1)
% %     feature_train(i,:)=feature_train(i,:)/feature_train_l2(i);
% % end
% % 
% % feature_test = feature(test_index,:);
% % 
% % mean_TEST_set = repmat(mean_TRAIN_set_0,size(feature_test,1),1);
% % std_TEST_set = repmat(std_TRAIN_set_0,size(feature_test,1),1);
% % 
% % feature_test = (feature_test - mean_TEST_set)./std_TEST_set;
% % 
% % feature_test_l2=sqrt(sum(feature_test.^2,2));
% % for i=1:size(feature_test,1)
% %     feature_test(i,:)=feature_test(i,:)/feature_test_l2(i);
% % end
% % 
% % feature_REFORM = feature;
% % 
% % feature_REFORM(train_index,:) = feature_train;
% % feature_REFORM(test_index,:) = feature_test;
% % feature_REFORM(~(train_index|test_index),:) = [];

class_test = class(test_index);

feature_train_test = feature;

% class_train_test = class(train_index|test_index);
% class_train_test(class_train_test==class_i) = 1;
% class_train_test(class_train_test==class_j) = -1;
% 
% initial_label = zeros(size(class,1),1);
% initial_label(train_index&class==class_i) = 1;
% initial_label(train_index&class==class_j) = -1;
% initial_label(~train_index&~test_index) = [];
% initial_label_index = initial_label ~= 0;


class_train_test = class(train_index|test_index);
% class_train_test = [feature(train_index);class(test_index)];
initial_label_index = train;

% %=====
% feature_train_test=feature_train_test(1:100,:);
% class_train_test=class_train_test(1:100);
% initial_label_index=initial_label_index(1:100);
% class_test=class(1:100);
% class_test=class_test(~initial_label_index);
% %=====


M=eye(size(feature,2));
% M=diag([0.2 0.8 1 1 1 1 1 1]);

% % disp('%%%%% beta %%%%%');
% % [error_classifier,beta_0_current,x_valid] = ...
% %     beta_binary_classification( dataset_i,n_beta,class_test, ...
% %     feature_train_test, ...
% %     initial_label_index, ...
% %     class_train_test, ...
% %     classifier_i,...
% %     M);
ldp=1;
beta_0_current=ones(1,n_beta);
% for net_iter=1:1
    [error_classifier_0,x_valid] = classifier_ts(dataset_i,n_beta,class_test, ...
        feature_train_test, ...
        initial_label_index, ...
        class_train_test, ...
        classifier_i,...
        M,...
        beta_0_current,...
        learning_i,...
        adjacency_matrix,m,n);
    disp(['classifier before MSGL ' num2str(classifier_i) ' | accuracy: ' num2str((1-error_classifier_0)*100)]);
%     disp(['error at iter ' num2str(net_iter) ': ' num2str(error_classifier)]);
%     tol_beta_M=Inf;
%     ttt=1;
%     while ttt<3%tol_beta_M>1e-4  
%         [M,final_term1_M] = ...
%             PDcone_obj_run_time_custom( feature_train_test, ...
%             initial_label_index, ...
%             class_train_test,...
%             1,...
%             n_beta,...
%             beta_0_current,...
%             x_valid,...
%             M);    
%     [M,~,~] = ...
%     Cholesky_Decomposition_obj_run_time( feature_train_test, ...
%     initial_label_index, ...
%     class_train_test);
if learning_i==1
%     beta_0_current=zeros(1,n_beta);
        [beta_0_current,method_time] = ...
            beta_binary_classification_no_classifier_update_ts( ldp,beta_0_current,dataset_i,n_beta, ...
            feature_train_test, ...
            x_valid, ...
            M,adjacency_matrix);         
%         [beta_0_current,method_time] = ...
%             beta_binary_classification_no_classifier_update( ldp,beta_0_current,dataset_i,n_beta, ...
%             feature_train_test, ...
%             x_valid, ...
%             M);               
elseif learning_i==2
    [M,~,method_time] = ...
    Cholesky_Decomposition_obj_run_time( feature_train_test, ...
    initial_label_index, ...
    class_train_test);
elseif learning_i==3
    [M,~,method_time] = ...
    PDcone_usethis_obj_run_time( feature_train_test, ...
    initial_label_index, ...
    class_train_test);
elseif learning_i==4
    [M,method_time] = ...
    SGML_binary_classification( feature_train_test, ...
    initial_label_index, ...
    class_train_test,...
    dataset_i);
else
    [M,method_time] = ...
    HBNB_obj_run_time( feature_train_test, ...
    initial_label_index, ...
    class_train_test);
end
% % % % % [error_classifier,x_valid] = classifier(dataset_i,n_beta,class_test, ...
% % % % %     feature_train_test, ...
% % % % %     initial_label_index, ...
% % % % %     class_train_test, ...
% % % % %     classifier_i,...
% % % % %     M,...
% % % % %     beta_0_current);
% % % % % error_classifier
                               
%         tol_beta_M=norm(initial_term1-final_term1_M);
%         ttt=ttt+1;
%     end
% end

[error_classifier] = classifier_ts(dataset_i,n_beta,class_test, ...
    feature_train_test, ...
    initial_label_index, ...
    class_train_test, ...
    classifier_i,...
    M,...
    beta_0_current,...
    learning_i,...
        adjacency_matrix,m,n);
disp(['classifier after MSGL ' num2str(classifier_i) ' | accuracy: ' num2str((1-error_classifier)*100)]);
% error_classifier
% % 
% % % [M] = ...
% % %     SGML_binary_classification_GSKR( feature_train_test, ...
% % %     initial_label_index, ...
% % %     class_train_test, ...
% % %     n_beta,...
% % %     beta_0_current);
% % 
% [error_classifier] = classifier(dataset_i,n_beta,class_test, ...
%     feature_train_test, ...
%     initial_label_index, ...
%     class_train_test, ...
%     classifier_i,...
%     M,...
%     beta_0_current);

% disp('%%%%% beta %%%%%');
% [error_classifier,beta_0_current,~] = ...
%     beta_binary_classification( dataset_i,n_beta,class_test, ...
%     feature_train_test, ...
%     initial_label_index, ...
%     class_train_test, ...
%     classifier_i, ...
%     M);
% disp(['error with bo+ML: ' num2str(error_classifier) ' | beta: ' num2str(beta_0_current) ' | dataset: ' num2str(dataset_i)]);

end

