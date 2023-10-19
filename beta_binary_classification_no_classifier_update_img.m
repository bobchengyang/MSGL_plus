function [beta_0_test,method_time] = ...
    beta_binary_classification_no_classifier_update_img(ldp,beta_0_current,dataset_i,n_beta, ...
    feature_train_test, ...
    x_valid, ...
    M,adjacency_matrix)

[n_sample_full, n_feature]= size(feature_train_test); %get the number of samples and the number of features
[ x_valid,~ ] = class_num_to_vec( x_valid,n_sample_full );
% n_sample_test=length(class_test);
options = optimoptions('linprog','Display','none','Algorithm','interior-point'); % linear program (LP) setting for Frank-Wolfe algorithm

t_orig=tic;

% M = eye(n_feature);
tol_set=1e-2;
mo=2;
% flag=0;
[ L ] = graph_Laplacian_train_test( dataset_i,feature_train_test, M ); % full observation

%% get eigen pairs starts
[v,d]=eig(L); % eigen-decomposition of L
l1=diag(d); % get the eigen-values (make sure that L is symmetric)
l1(1)=0; % set the first eigenvalue to 0

%% get eigen pairs ends
% tol_compare=-Inf;
% beta_0_current=zeros(1,n_beta)+1; % initial beta's


yly=zeros(1,n_beta);
for i=1:n_beta
    yly(i)=trace(x_valid'*(L^i)*x_valid);
end

yly_1tonbeta1=yly(1:end-1);
yly_last_one=yly(n_beta);

beta_p_const=n_sample_full/yly_last_one;


l_matrix_0=zeros(n_sample_full,n_beta);
l_i_p=zeros(n_sample_full,n_beta-1);
for i=1:n_beta
    l_matrix_0(:,i)=l1.^i; % l_matrix stores lambda_k^i
    if i<=n_beta-1
        l_i_p(:,i)=yly(i)*(l1.^n_beta)/yly_last_one;
    end
end

l_matrix=l_matrix_0(:,1:end-1)-l_i_p;
beta_p_const_l_matrix_last=beta_p_const*l_matrix_0(:,n_beta);

eig_tol=1e-8;

beta_0_current=beta_0_current(1:end-1); % n-1
[ beta_0_test ] = beta_optimization_LP_instant_img(ldp,n_beta,beta_0_current,v,l_matrix,x_valid,n_sample_full,eig_tol,tol_set,mo,L, ...
    beta_p_const_l_matrix_last,options); % n-1

% [ beta_0_test ] = beta_optimization_LP_instant_no_beta_lb_ub(ldp,n_beta,beta_0_current,v,l_matrix,x_valid,n_sample_full,eig_tol,tol_set,mo,L );
beta_last_one=beta_p_const;
beta_last_one=beta_last_one-sum(beta_0_test.*yly_1tonbeta1)/yly_last_one;
beta_0_test=[beta_0_test beta_last_one];

method_time=toc(t_orig);

lambda=sum(repmat(beta_0_test,[n_sample_full 1]).*l_matrix_0,2)+eig_tol;
lambda(lambda<0)=eig_tol;
% cL=0;
% for i=1:n_beta
%     cL=cL+beta_0_test(i)*L^i;
% end
obj_term1=n_sample_full;
obj_term2=-ldp*sum(log(lambda));
disp(['obj right after beta learning: ' num2str(obj_term1) '/' num2str(obj_term2)]);
% % % obj_term1=trace(x_valid'*cL*x_valid);
% % % obj_term2=-ldp*sum(log(lambda));
disp(['beta: ' num2str(beta_0_test)]);
% % % disp(['obj right after beta learning: ' num2str(obj_term1) '/' num2str(obj_term1+obj_term2)]);
end