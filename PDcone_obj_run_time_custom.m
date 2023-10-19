function [M,current_objective] = ...
    PDcone_obj_run_time_custom( feature_train_test, ...
    initial_label_index, ...
    class_train_test,...
    factorsc,...
    n_beta,...
    beta_0_current,...
    x_valid_previous,...
    M)

beta_0=ones(n_beta,1);
tol_main=1e-5;

% partial_feature = feature_train_test(initial_label_index,:);
% partial_observation = class_train_test(initial_label_index);
partial_feature = feature_train_test;
% partial_observation = class_train_test;
partial_observation = x_valid_previous;
[partial_sample,n_feature]=size(partial_feature);
[partial_observation]=class_num_to_vec(partial_observation,partial_sample);
% partial_observation=partial_observation(:,1);
[ diag_idx3_full,...
    diag_idx3_diaoffdia,...
    diag_idx3_dia,...
    diag_idx3_offdia ] = diag_idx( partial_sample, n_feature );

S_upper=n_feature*factorsc;

run_t=1;
time_vec=zeros(run_t,1);
obj_vec=zeros(run_t,1);
time_eig=zeros(run_t,1);
max_iter=1e4;
for time_i=1:run_t
    
    tStart=tic;
    %M=initial_M(n_feature,1);
%     M=eye(n_feature)*factorsc;
    %     M=ones(1,n_feature)*factorsc;
    [c] = get_graph_Laplacian_variables_ready_ML(partial_feature,partial_observation,partial_sample,n_feature);
    lr=1e-2;%finding a good choice of a step size is out of the scope of the paper
    
    counter_diag_nondiag = 0;
    
    tol_diag_nondiag = Inf;
    
    while tol_diag_nondiag > tol_main
        
        if counter_diag_nondiag == 0
            
            [L,y,x] = graph_Laplacian( partial_sample, c, M,partial_observation);
%             cL=0;
%             for i_power=1:n_beta
%                 cL=cL+beta_0_current(i_power)*L^i_power;
%             end
            
            [Lv,Ld]=eig(L);
            l1=diag(Ld);
            l1(1)=0;
            l_matrix=zeros(partial_sample,n_beta);
            for i=1:n_beta
                l_matrix(:,i)=l1.^i;
            end
            eig_tol=1e-8;
            lambda=sum(repmat(beta_0_current,[partial_sample 1]).*l_matrix,2)+eig_tol;
%             lambda=lambda/max(lambda);
            cL=Lv*diag(lambda)*Lv';
 
%             initial_objective = trace(partial_observation' * cL * partial_observation) - sum(log(lambda));
            initial_objective = trace( partial_observation' * cL * partial_observation);
            disp(['initial = ' num2str(initial_objective)]);
            
        end
        
        inv_cL=Lv*diag(1./lambda)*Lv';
        min_cL_eig=-Inf;
        first_time=0;
        while min_cL_eig<0
            if first_time~=0
               lr=lr/2;
            end
            [ M_updated,...
                time_eig] = PDcone_projection(partial_feature,partial_observation,...
                partial_sample,...
                n_feature,...
                c,...
                y,...
                M,...
                S_upper,...
                time_eig,...
                time_i,...
                lr,...
                beta_0_current,...
                diag_idx3_full,...
                inv_cL);
            
            [ L,y,x ] = graph_Laplacian( partial_sample, c, M_updated,partial_observation);
            %                 cL=0;
            %                 for i_power=1:n_beta
            %                     cL=cL+beta_0_current(i_power)*L^i_power;
            %                 end
            
            [Lv,Ld]=eig(L);
            l1=diag(Ld);
            l1(1)=0;
            l_matrix=zeros(partial_sample,n_beta);
            for i=1:n_beta
                l_matrix(:,i)=l1.^i;
            end
            eig_tol=1e-8;
            lambda=sum(repmat(beta_0_current,[partial_sample 1]).*l_matrix,2)+eig_tol;
            min_cL_eig=min(lambda(:));
            first_time=1;
        end
%         lambda=lambda/max(lambda);
        cL=Lv*diag(lambda)*Lv';
        
%         current_objective = trace(partial_observation' * cL * partial_observation) - sum(log(lambda));
        current_objective = trace(partial_observation' * cL * partial_observation);
        if mod(counter_diag_nondiag,10)==0
        disp(['current obj: ' num2str(current_objective)]);
        end
        
        if current_objective>initial_objective
            lr=lr/2;
        else
            lr=lr*(1+1e-1);
        end
        
        %%===========================================================
        %                 while current_objective>initial_objective
        %                     lr=lr/2;
        %                 [ M_updated,...
        %                     time_eig] = PDcone_projection(...
        %                     partial_sample,...
        %                     n_feature,...
        %                     c,...
        %                     y,...
        %                     M,...
        %                     S_upper,...
        %                     time_eig,...
        %                     time_i,...
        %                     lr,...
        %                     diag_idx3_full,...
        %                     W_n0);
        %                 [ L ] = graph_Laplacian( partial_sample, c, M_updated, W_n0);
        %
        %                 current_objective = partial_observation' * (L + L*L) * partial_observation;
        %                 disp(['trying obj: ' num2str(current_objective)]);
        %                 end
        %
        %                 disp(['current obj: ' num2str(current_objective)]);
        %%===========================================================
        
        M = M_updated;
        
        tol_diag_nondiag = norm(current_objective - initial_objective);
        
        initial_objective = current_objective;
        
        counter_diag_nondiag = counter_diag_nondiag + 1;
        if counter_diag_nondiag==max_iter
            %         if counter_diag_nondiag==10
            break
        end
        
    end
    disp(['converged = ' num2str(current_objective)]);
    
    time_vec(time_i)=toc(tStart);
    obj_vec(time_i)=current_objective;
end

% disp(['time_vec mean: ' num2str(mean(time_vec)) ' std:' num2str(std(time_vec))]);
% disp(['obj_vec mean: ' num2str(mean(obj_vec)) ' std:' num2str(std(obj_vec))]);
end