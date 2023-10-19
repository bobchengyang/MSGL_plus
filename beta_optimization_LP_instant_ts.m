function [ beta_0 ] = beta_optimization_LP_instant_ts( ldp,n_beta,beta_0,v,l_matrix,data_label,n_sample,eig_tol,tol_set,mo,L,...
    beta_p_const,options)

a=1e3;
iter=Inf;
while iter>200

    %     L_beta=cell(1,n_beta);
    L_beta=0;

    lambda=sum(repmat(beta_0,[n_sample 1]).*l_matrix,2)+beta_p_const+eig_tol; % N x 1 (sum P)

    if mo==1

    else
        gradient_0=zeros(1,n_beta-1);
        for i=1:n_beta-1
            gradient_0(i)=ldp*sum(l_matrix(:,i)./lambda);%-trace(data_label'*L_beta{i}*data_label);
            %             gradient_0(i)=ldp*sum((l_matrix(:,i)-l_i_p(:,i))./lambda);
        end
    end
    %%=======================================
    %% FW starts
    LP_A=-l_matrix;

    LP_b=zeros(n_sample,1)+beta_p_const+eig_tol;


    %     options = optimoptions('linprog','Algorithm','interior-point'); % linear program (LP) setting for Frank-Wolfe algorithm
    options.OptimalityTolerance = 1e-8; % LP optimality tolerance
    options.ConstraintTolerance = 1e-8; % LP interior-point constraint tolerance

    f=-gradient_0;
    %     FW_beta_direction = linprog(f,LP_A,LP_b,LP_Aeq,LP_beq,LP_lb,LP_ub,options); %LP
    FW_beta_direction = linprog(f,LP_A,LP_b,[],[],[],[],options); %LP

    while isempty(FW_beta_direction) == 1
        disp('===trying with larger OptimalityTolerance===');
        options.OptimalityTolerance = options.OptimalityTolerance*1e1;
        options.ConstraintTolerance = options.ConstraintTolerance*1e1;
        %         FW_beta_direction = linprog(f,LP_A,LP_b,LP_Aeq,LP_beq,LP_lb,LP_ub,options); %LP
        FW_beta_direction = linprog(f,LP_A,LP_b,[],[],[],[],options); %LP
    end
    FW_beta_direction=FW_beta_direction';

    obj_net=Inf;
    [obj_first_round,obj_term1]=log_marginal_likelihood_instant(ldp,data_label,beta_0+0*(FW_beta_direction-beta_0),v,l_matrix,eig_tol,n_sample, ...
        beta_p_const);
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
                [obj_first_round,obj_term1]=log_marginal_likelihood_instant(ldp,data_label,beta_0+0*(FW_beta_direction-beta_0),v,l_matrix,eig_tol,n_sample, ...
                    beta_p_const);
                GD_NR=1;%try gradient descent to get alpha_0 instead of NR
                break
            else
                beta_0=zeros(1,n_beta);
                a=a/1e1;
                break
            end
        end

        [ alpha_0 ] = GSL_LP_stepsize_instant_ts(ldp, ...
            beta_0,...
            FW_beta_direction,...
            l_matrix,...
            eig_tol,...
            L_beta,...
            data_label,...
            n_beta,...
            GD_NR, ...
            beta_p_const);

        %         alpha_0
        beta_0_temp=beta_0+alpha_0*(FW_beta_direction-beta_0);
        lambda_check=sum(repmat(beta_0_temp,[n_sample 1]).*l_matrix,2)+beta_p_const+eig_tol;

        check_times=0;
        while length(find(lambda_check>0))<n_sample
            alpha_0=alpha_0*(1-1e-5);
            beta_0_temp=beta_0+alpha_0*(FW_beta_direction-beta_0);
            lambda_check=sum(repmat(beta_0_temp,[n_sample 1]).*l_matrix,2)+beta_p_const+eig_tol;
            check_times=check_times+1;
        end

        beta_0=beta_0+alpha_0*(FW_beta_direction-beta_0);

        [obj_second_round,obj_term1]=log_marginal_likelihood_instant(ldp,data_label,beta_0,v,l_matrix,eig_tol,n_sample, ...
            beta_p_const);


        obj_net=norm(obj_second_round-obj_first_round);
        obj_first_round=obj_second_round;
        lambda=sum(repmat(beta_0,[n_sample 1]).*l_matrix,2)+beta_p_const+eig_tol; % N x 1 (sum P)
        %         lambda=lambda/max(lambda); % not used in ICASSP submission
        gradient_0=zeros(1,n_beta-1);
        for i=1:n_beta-1
            gradient_0(i)=sum(l_matrix(:,i)./lambda);%-trace(data_label'*L_beta{i}*data_label);
        end
        f=-gradient_0;
        FW_beta_direction = linprog(f,LP_A,LP_b,[],[],[],[],options); %LP

        while isempty(FW_beta_direction) == 1
            disp('===trying with larger OptimalityTolerance===');
            options.OptimalityTolerance = options.OptimalityTolerance*1e1;
            options.ConstraintTolerance = options.ConstraintTolerance*1e1;
            FW_beta_direction = linprog(f,LP_A,LP_b,[],[],[],[],options); %LP
        end

        FW_beta_direction=FW_beta_direction';
    end


end

%% FW ends
%%=======================================
%beta_0=FW_beta_direction;
[lml0,obj_term1]=log_marginal_likelihood_instant(ldp,data_label,beta_0,v,l_matrix,eig_tol,n_sample, ...
    beta_p_const);
% disp(['converged at iter: ' num2str(iter) ' | beta: ' num2str(beta_0) ' | obj: ' num2str(lml0) '/' num2str(obj_term1)]);
disp(['converged at iter: ' num2str(iter) ' | obj: ' num2str(lml0) '/' num2str(obj_term1)]);
end

