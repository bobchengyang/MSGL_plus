function [ lml,obj_term1 ] = log_marginal_likelihood_instant(ldp,data_label,beta_0,v,l_matrix,eig_tol,n_sample, ...
    beta_p_const)
% B=pinv(B*B');
% B_inv=inv(B);
lambda=sum(repmat(beta_0,[n_sample 1]).*l_matrix,2)+beta_p_const+eig_tol;
% lambda(lambda<0)=eig_tol;
% lambda=lambda/max(lambda);

% % % % B=v*diag(lambda)*v';

% B_inv=v*diag(1./lambda)*v';
% B_inv=(B_inv+B_inv')/2;
% lml=-0.5*data_label'*B*data_label...
%     -0.5*log(det(B_inv));
obj_term1=0;
    lml=obj_term1...
        -ldp*sum(log(lambda));
% factor=10;
% power=0;
% while prod(lambda)==Inf
%     power=power+1;
%     lambda=lambda/factor;
% end
% count=0;
% while prod(lambda)==0
%     count=count+1;
%     lambda=lambda*2;
% end
% total2=2*count*n_sample;
% 
% if power==0 && count==0
%     lml=-0.5*data_label'*B*data_label...
%         +0.5*log(prod(lambda));
% elseif power==0 && count~=0
%     lml=-0.5*data_label'*B*data_label...
%         +0.5*(log(prod(lambda))-log(total2));
% elseif power~=0 && count==0
%     lml=-0.5*data_label'*B*data_label...
%         +0.5*(log(prod(lambda))+(power*n_sample)*log(10));
% else % power~=0 && count~=0
%     lml=-0.5*data_label'*B*data_label...
%         +0.5*(log(prod(lambda))-log(total2)+(power*n_sample)*log(10));    
% end
end

