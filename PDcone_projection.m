function [ M,...
    time_eig] = PDcone_projection(partial_feature,x,...
    partial_sample,...
    n_feature,...
    c,...
    y,...
    M,...
    S_upper,...
    time_eig,...
    time_i,...
    lr,...
    beta_0,...
    diag_idx3_full,...
    inv_cL)

    [ G1 ] = PDcone_compute_gradient(partial_feature,x,partial_sample, n_feature, c, M, y,beta_0,diag_idx3_full,inv_cL);
%     L_constant = sqrt(max(eig(G2'*G2)));
%     M = M - (1/L_constant) * G1;
%      M = M - lr *G1;
    M = M - lr * extractdata(G1);
    %t_PDcone=tic;
    teig=tic;
    [PDcone_v, PDcone_d] = eig(M); % eigen-decomposition of M
    time_eig(time_i)=time_eig(time_i)+toc(teig);
    
    ind=find(diag(PDcone_d)>0);
    M=PDcone_v(:,ind) * PDcone_d(ind,ind) * PDcone_v(:,ind)';
    M=(M+M')/2;
%     M=M/max(eig(M));
    %toc(t_PDcone);
    
%     if sum(diag(M))>S_upper
        factor_for_diag = sum(diag(M))/S_upper;
        M = M/factor_for_diag;
%     end

end

















