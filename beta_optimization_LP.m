function [ beta_0 ] = beta_optimization_LP( ldp,n_beta,beta_0,v,l_matrix,data_label,n_sample,eig_tol,tol_set,mo )

a=1e2;
iter=Inf;
while iter>200
    
    L_beta=cell(1,n_beta);
    for i=1:n_beta
        L_beta{i}=v*diag(l_matrix(:,i))*v';
    end
    lambda=sum(repmat(beta_0,[n_sample 1]).*l_matrix,2)+eig_tol; % N x 1 (sum P)
%     lambda=lambda/max(lambda); % not used in ICASSP submission
    if mo==1
        cL_inv=v*diag(1./lambda)*v'; % inverse of cL
        gradient_0=zeros(1,n_beta);
        for i=1:n_beta
            gradient_0(i)=ldp*trace(L_beta{i}*cL_inv)-trace(data_label'*L_beta{i}*data_label);
        end
    else
        gradient_0=zeros(1,n_beta);
        for i=1:n_beta
            gradient_0(i)=ldp*sum(l_matrix(:,i)./lambda)-trace(data_label'*L_beta{i}*data_label);
        end
    end
    %%=======================================
    %% FW starts
    LP_A=-l_matrix;
    LP_b=zeros(n_sample,1)+eig_tol;
    LP_lb=zeros(n_beta,1)-a;
    LP_ub=zeros(n_beta,1)+a;
    options = optimoptions('linprog','Display','none','Algorithm','interior-point'); % linear program (LP) setting for Frank-Wolfe algorithm
    % options = optimoptions('linprog','Algorithm','interior-point'); % linear program (LP) setting for Frank-Wolfe algorithm
    f=-gradient_0;
    FW_beta_direction = linprog(f,LP_A,LP_b,[],[],LP_lb,LP_ub,options); %LP
    % while isempty(FW_beta_direction)
    %     LP_b=LP_b*1e1;
    %     FW_beta_direction = linprog(f,LP_A,LP_b,[],[],LP_lb,LP_ub,options); %LP
    % end
    while isempty(FW_beta_direction) == 1
        disp('===trying with larger OptimalityTolerance===');
        options.OptimalityTolerance = options.OptimalityTolerance*1e1;
        FW_beta_direction = linprog(f,LP_A,LP_b,[],[],LP_lb,LP_ub,options); %LP
    end
    FW_beta_direction=FW_beta_direction';
    % lll=zeros(length(0:0.01:1),1);
    % counter=0;
    % for value_try=0:0.01:1
    %     counter=counter+1;
    % lll(counter)=log_marginal_likelihood(data_label,beta_0+value_try*(FW_beta_direction-beta_0),v,l_matrix,eig_tol,n_sample); % log marginal likelihood
    % end
    % plot(1:length(0:0.01:1),lll);
    obj_net=Inf;
    [obj_first_round,obj_term1]=log_marginal_likelihood(ldp,data_label,beta_0+0*(FW_beta_direction-beta_0),v,l_matrix,eig_tol,n_sample);
    iter=0;
    GD_NR=2;
    while obj_net>1e-2
        iter=iter+1;
        if iter>200
            if GD_NR==2
                iter=0;
                options.OptimalityTolerance = 1e-5;
                obj_net=Inf;
                alpha_0=0;
                [obj_first_round,obj_term1]=log_marginal_likelihood(ldp,data_label,beta_0+0*(FW_beta_direction-beta_0),v,l_matrix,eig_tol,n_sample);
                GD_NR=1;%try gradient descent to get alpha_0 instead of NR
                %break
            else
                beta_0=zeros(1,n_beta);
                a=a/1e1;
                break
            end
        end
        
        [ alpha_0 ] = GSL_LP_stepsize(ldp, ...
            beta_0,...
            FW_beta_direction,...
            l_matrix,...
            eig_tol,...
            L_beta,...
            data_label,...
            n_beta,...
            GD_NR);
        
        beta_0_temp=beta_0+alpha_0*(FW_beta_direction-beta_0);
        lambda_check=sum(repmat(beta_0_temp,[n_sample 1]).*l_matrix,2)+eig_tol;
        
        while length(find(lambda_check>0))<n_sample
            alpha_0=alpha_0*(1-1e-5);
            beta_0_temp=beta_0+alpha_0*(FW_beta_direction-beta_0);
            lambda_check=sum(repmat(beta_0_temp,[n_sample 1]).*l_matrix,2)+eig_tol;
        end
        
% %         net=zeros(100,1);
% %         obj_term1_list=zeros(100,1);
% %         counter=0;
% %         for iiiii=0.001:0.001:0.1
% %             counter=counter+1;
% %             beta_011111=beta_0+iiiii*(FW_beta_direction-beta_0);
% %             [obj_second_round,obj_term1]=log_marginal_likelihood(ldp,data_label,beta_011111,v,l_matrix,eig_tol,n_sample);
% %         net(counter)=obj_second_round;
% %         obj_term1_list(counter)=obj_term1;            
% %         end
% %         figure();plot(1:100,net,'r');hold on;plot(1:100,obj_term1_list,'b');
        
        beta_0=beta_0+alpha_0*(FW_beta_direction-beta_0);
%         if mod(iter,100)==0
        disp(['iter: ' num2str(iter) ' | beta: ' num2str(beta_0) ' | obj: ' num2str(obj_first_round) '/' num2str(obj_term1) ' | gradient: ' num2str(gradient_0) ' | step_size: ' num2str(alpha_0)]);
%         end
        [obj_second_round,obj_term1]=log_marginal_likelihood(ldp,data_label,beta_0,v,l_matrix,eig_tol,n_sample);
        
%         %=====
%         if obj_second_round>obj_first_round
%             break
%         end
%         %=====
        
        obj_net=norm(obj_second_round-obj_first_round);
        obj_first_round=obj_second_round;
        lambda=sum(repmat(beta_0,[n_sample 1]).*l_matrix,2)+eig_tol; % N x 1 (sum P)
%         lambda=lambda/max(lambda); % not used in ICASSP submission
        gradient_0=zeros(1,n_beta);
        for i=1:n_beta
            gradient_0(i)=sum(l_matrix(:,i)./lambda)-trace(data_label'*L_beta{i}*data_label);
        end
        f=-gradient_0;
        FW_beta_direction = linprog(f,LP_A,LP_b,[],[],LP_lb,LP_ub,options); %LP
        %     while isempty(FW_beta_direction)
        %         LP_b=LP_b*1e1;
        %         FW_beta_direction = linprog(f,LP_A,LP_b,[],[],LP_lb,LP_ub,options); %LP
        %     end
        while isempty(FW_beta_direction) == 1
            disp('===trying with larger OptimalityTolerance===');
            options.OptimalityTolerance = options.OptimalityTolerance*1e1;
            FW_beta_direction = linprog(f,LP_A,LP_b,[],[],LP_lb,LP_ub,options); %LP
        end
        
        FW_beta_direction=FW_beta_direction';
    end
    
end
%% FW ends
%%=======================================
[lml0,obj_term1]=log_marginal_likelihood(ldp,data_label,beta_0,v,l_matrix,eig_tol,n_sample);
disp(['converged at iter: ' num2str(iter) ' | beta: ' num2str(beta_0) ' | obj: ' num2str(lml0) '/' num2str(obj_term1)]);
end

