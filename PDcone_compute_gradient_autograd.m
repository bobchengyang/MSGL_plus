function [ G ] = PDcone_compute_gradient(partial_feature, x,N, n, c, M, y ,beta_0,diag_idx3_full,inv_cL)
% e=exp(-sum(c*M.*c,2));
% % e=exp(-sum(abs(M.*c),2)); % Laplacian Kernel
% % e=reshape(e, [N N]);
% e(1:N+1:end) = 0;
% % e=knn_check(e,100);
% % e=reshape(e, [N^2 1]);
% 
% c=reshape(c', [n 1 N^2]);
% 
% d=-reshape(c.*reshape(c,[1 n N^2]), [n^2 N^2])';
% G_core=e.*y.*d;
% G=reshape(sum(G_core,1), [n n]);

%%======trying autograd begins====
x0=dlarray(M);
[~,G]=dlfeval(@rosenbrock,x0);

% disp(['gradient at point(' num2str(x0(:)') '): ' num2str(G(:)')]);

%%======trying autograd ends======

    function [f,grad]=rosenbrock(variable_x)
%         c=dlarray(c); % feature difference
%         x=dlarray(x); % label (can be a vector or a matrix)
        D=dlarray(zeros(N));
        D_sqrt=dlarray(zeros(N));
        
        W=exp(-sum(c*variable_x.*c,2));
        W(1:N+1:end) = 0;
        W=reshape(W, [N N]);
        sum_W=sum(W);
        sum_W_sqrt=1./sqrt(sum_W);
        
        D(1:N+1:end)=sum_W;
        D_sqrt(1:N+1:end)=sum_W_sqrt;
        
        L=D-W;
        L=D_sqrt*L*D_sqrt;
        L=(L+L')/2;
%         L0=(L+L')/2;
        noc=size(x,2);
        cL=beta_0(1)*L+beta_0(2)*L*L+beta_0(3)*L*L*L;
        f_=x'*cL*x;

        f=sum(f_(1:noc+1:end));
        
        grad=dlgradient(f,variable_x);
    end

% d=zeros(n);
% for i=1:N^2
%     d=d-e(i)*y(i)*c(:,:,i).*c(:,:,i)';
% end
%
% d=-reshape(c.*reshape(c,[1 n N^2]), [n^2 N^2]);
% % d=e'.*y'.*d;
% % G=reshape(sum(d,2), [n n]);
% G=d;

% % % %G2=sum(permute(reshape(G_core,[N^2 1 n^2]),[3 2 1]).*reshape(d',[1 n^2 N^2]),3);
% % %
% % % % o1=permute(reshape(G_core,[N^2 1 n^2]),[3 2 1]);
% % % o1=reshape(d,[n^2 1 N^2]);
% % % % o2=reshape(d',[1 n^2 N^2]);
% % % o2=permute(o1,[2 1 3]);
% % % G2=zeros(n^2);
% % % for i=1:N^2
% % %     G2=G2+o1(:,:,i).*o2(:,:,i);
% % % end

% % % % % %% graph polynomial
% % % % % e=exp(-sum(c*M.*c,2));
% % % % % W=reshape(e, [N N]);
% % % % % W(1:N+1:end) = 0;
% % % % % % L = diag(sum(W))-W;
% % % % % D=diag(sum(W));
% % % % % L=D-W;
% % % % % L=D^(-0.5)*L*D^(-0.5);
% % % % % % L=(L+L')/2;
% % % % % % y=y; % L
% % % % % % y=y*L+L*y; % L*L
% % % % % % y=y*L*L+L*y*L+L*L*y; % L*L*L
% % % % % % y=y+y*L+L*y; % L+L*L
% % % % % y=beta_0(1)*y+...
% % % % %   beta_0(2)*(y*L+L*y)+...
% % % % %   beta_0(3)*(y*L*L+L*y*L+L*L*y); % L+L*L+L*L*L
% % % % % % y=y+y*L+L*y+y*L*L+L*y*L+L*L*y+y*L*L*L+L*y*L*L+L*L*y*L+L*L*L*y; % L+L*L+L*L*L+L*L*L*L
% % % % % y=reshape(y,[N^2 1]);
% % % % %
% % % % % c=reshape(c', [n 1 N^2]);
% % % % % %G=reshape(sum(e.*y.*-reshape(c.*reshape(c,[1 n N^2]), [n^2 N^2])',1), [n n]);
% % % % % Go=-e.*-reshape(c.*reshape(c,[1 n N^2]), [n^2 N^2])'; % N^2 x n^2
% % % % % Go=reshape(Go, [N N n^2]); % N x N x n^2
% % % % % Go_diag=sum(Go); % 1 x N x n^2
% % % % % Go(diag_idx3_full)=-Go_diag; % N x N x n^2
% % % % % % G=reshape(sum(y.*reshape(Go,[N^2 n^2]),1),[n n]); % n x n
% % % % %
% % % % % naked=beta_0(1)*inv_cL+...
% % % % %   beta_0(2)*(inv_cL*L+L*inv_cL)+...
% % % % %   beta_0(3)*(inv_cL*L*L+L*inv_cL*L+L*L*inv_cL); % L+L*L+L*L*L
% % % % % naked=reshape(naked,[N^2 1]);
% % % % %
% % % % % G=reshape(sum((y-naked).*reshape(Go,[N^2 n^2]),1),[n n]); % n x n
end

