%=================================================================
% Signed Graph Metric Learing (SGML) via Gershgorin Disc Alignment
% **Frank-Wolfe iterations when Node i's color is red
%
% author: Cheng Yang
% email me any questions: cheng.yang@ieee.org
% date: June 16th, 2020
% please kindly cite the paper: 
% ['Signed Graph Metric Learning via Gershgorin Disc Alignment', 
% Cheng Yang, Gene Cheung, Wei Hu, 
% https://128.84.21.199/abs/2006.08816]
%=================================================================
function [M,...
    scaled_M,...
    scaled_factors,...
    M_current_eigenvector,...
    min_objective,...
    bins,...
    num_list] = FW_iterations_red(current_node,league_vec,league_vec_temp,flip_number,...
    scaled_factors_h,...
    feature_N,...
    G,...
    M,...
    node_number,...
    remaining_idx,...
    M_current_eigenvector,...
    rho,...
    C,...
    scaled_M,...
    scaled_factors,...
    bins,...
    objective_previous,...
    tol_golden_search,...
    nv,...
    zz,...
    num_list,...
    partial_sample,...
    c,...
    y,...
    x,...
    LP_A_sparse_i,...
    LP_A_sparse_j,...
    LP_A_sparse_s,...
    LP_b,...
    LP_lb,...
    LP_ub,...
    LP_Aeq,...
    LP_beq,...
    zero_mask,...
    scaler_v,...
    lu_bound_idx,...
    options,...
    dia_idx,...
    tol_NR,...
    tol_GD,...
    GS_or_NR,...
    max_iter,...
    FW_dia_offdia_tol)

tol_offdia=Inf;
counter=0;
M_temp_best=M;
objective_previous_temp=objective_previous;

sign_vecdd = flip_number'*current_node*-1;

LP_A_sparse_s(1:feature_N-1)=sign_vecdd.*abs(scaled_factors_h);

for LP_A_i=1:feature_N-1
    temp_index=feature_N+(LP_A_i-1)*2+1;
    LP_A_sparse_s(temp_index)=sign_vecdd(1,LP_A_i)*scaler_v(LP_A_i);
end

LP_A = sparse(LP_A_sparse_i,LP_A_sparse_j,LP_A_sparse_s,1+feature_N,feature_N-1+feature_N);

LP_lb(sign_vecdd==-1)=-Inf;
LP_ub(sign_vecdd==-1)=0;
LP_lb(sign_vecdd==1)=0;
LP_ub(sign_vecdd==1)=Inf;

LP_lb(lu_bound_idx)=0;
LP_ub(lu_bound_idx)=0;

while tol_offdia>FW_dia_offdia_tol
    
    s_k = linprog(G,...
        LP_A,LP_b,...
        LP_Aeq,LP_beq,...
        LP_lb,LP_ub,options);
    
    while isempty(s_k) == 1
        disp('===trying with larger OptimalityTolerance===');
        options.OptimalityTolerance = options.OptimalityTolerance*10;
        options.ConstraintTolerance = options.ConstraintTolerance*10;
        s_k = linprog(G,...
            LP_A,LP_b,...
            LP_Aeq,LP_beq,...
            LP_lb,LP_ub,options);
    end
    %% set a step size
    if isequal(league_vec,league_vec_temp)==1
        
        M_previous=[M_temp_best(remaining_idx,node_number);diag(M_temp_best)];
        t_M21_solution_previous=s_k - M_previous;
        
        if GS_or_NR==1
            %% GS starts
            [gamma] = GS(...
                0,...
                1,...
                M_previous,...
                t_M21_solution_previous,...
                M_temp_best,...
                x,...
                feature_N,...
                node_number,...
                remaining_idx,...
                tol_golden_search,...
                zero_mask,...
                0,...
                0,...
                partial_sample,...
                c,...
                dia_idx,...
                nv);
            if counter==0 && gamma==0
                min_objective=objective_previous_temp;
                return
            end
            %% GS ends
        else
            %% NR starts
            [gamma] = NR(...
                M_previous,...
                t_M21_solution_previous,...
                zero_mask,...
                remaining_idx,...
                node_number,...
                feature_N,...
                M_temp_best,...
                zz,...
                nv,...
                partial_sample,...
                c,...
                y,...
                counter,...
                dia_idx,...
                tol_NR,...
                tol_GD,...
                0);
            if counter==0 && gamma==0
                min_objective=objective_previous_temp;
                return
            end
            %% NR ends
        end
        
        t_M21 = M_previous + gamma * t_M21_solution_previous;
        t_M21 = t_M21.*zero_mask;
        
        M_updated=M_temp_best;
        M_updated(node_number,remaining_idx)=t_M21(1:feature_N-1);
        M_updated(remaining_idx,node_number)=M_updated(node_number,remaining_idx);
        M_updated(dia_idx)=t_M21(feature_N-1+1:end);
    else
        
        M21_updated = s_k.*zero_mask;
        
        M_updated = M_temp_best;
        M_updated(remaining_idx,node_number)=M21_updated(1:feature_N-1);
        M_updated(node_number,remaining_idx)=M_updated(remaining_idx,node_number);
        M_updated(dia_idx)=M21_updated(feature_N-1+1:end);
        
        %=replace the following block if you run SGML on a different
        %objective function from GLR=======================================
        [ L_c ] = graph_Laplacian( partial_sample, c, M_updated );% replace this if you need to run SGML on a different objective function
        min_objective = x' * L_c * x;% replace this if you need to run SGML on a different objective function
        %==================================================================
        
        %% reject the result (reject the color change) if it is larger than previous
        if min_objective>=objective_previous_temp
            min_objective=objective_previous_temp;
            %disp('color update return');
            return
            %% there is no need to iterate, since the node color is changed
        else
            M_temp_best = M_updated;
            %disp('color update break');
            break % no need to iterate, not even once, otherwise it is wrong.
        end
    end
    
    %% evaluate the objective value
    
    %=replace the following block if you run SGML on a different
        %objective function from GLR=======================================
    [ L_c ] = graph_Laplacian( partial_sample, c, M_updated );% replace this if you need to run SGML on a different objective function
    min_objective = x' * L_c * x;% replace this if you need to run SGML on a different objective function
    %======================================================================
    
    if min_objective>=objective_previous_temp
        if counter>0
            min_objective=objective_previous_temp;
            break
        else
            min_objective=objective_previous_temp;
            %disp('early stop');
            return
        end
    end
    
    M_temp_best = M_updated;
    
    %% choose the M_temp_best that has not been thresholded to compute the gradient
    %=replace the following gradient function if you need to run SGML 
    %on a different objective function=====================================
    [ G ] = compute_gradient( ...
        partial_sample, ...
        feature_N, ...
        c, ...
        M_temp_best, ...
        y, ...
        nv, ...
        node_number, ...
        remaining_idx);
    %======================================================================
    
    tol_offdia=norm(min_objective-objective_previous_temp);
    
    objective_previous_temp=min_objective;
    
    counter=counter+1;
    if counter==max_iter
        break
    end
    
end

M_temp_best(abs(M_temp_best)<1e-5)=0;

%% detect subgraphs
bins_temp=bins;
M_current_eigenvector0=M_current_eigenvector;
num_list0=num_list;
if sum(abs(M_temp_best(node_number,remaining_idx)))==0 % disconnected
    if feature_N==max(bins_temp) % already disconnected
    else
        bins_temp(node_number)=max(bins_temp)+1; % assign a subgraph number
        M_current_eigenvector0(num_list0==node_number)=[]; % heuristicaly remove the 1st entry of M_current_eigenvector as the lobpcg warm start
        num_list0(num_list0==node_number)=[];
        M_current_eigenvector0=M_current_eigenvector0/sqrt(sum(M_current_eigenvector0.^2));
    end
end

%% evaluate the temporarily accepted result with temporary scaled_M and scaled_factors

[M_current_eigenvector0,scaled_M_,scaled_factors_] = scalars(M_temp_best,feature_N,1,M_current_eigenvector0,bins_temp);

lower_bounds = sum(abs(scaled_M_),2)-abs(scaled_M_(dia_idx))+rho;

%% reject the result if the lower_bounds are larger than C
if sum(lower_bounds) > C
    min_objective=objective_previous;
    %disp(['lower bounds sum:' num2str(sum(lower_bounds))]);
    %disp('========lower bounds sum larger than C!!!========');
    return
end

%% M_temp_best passes all tests, now update the results
bins=bins_temp;
M=M_temp_best;
scaled_M=scaled_M_;
scaled_factors=scaled_factors_;
M_current_eigenvector=M_current_eigenvector0;
num_list=num_list0;
end

