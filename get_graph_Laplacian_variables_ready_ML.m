%=================================================================
% Signed Graph Metric Learing (SGML) via Gershgorin Disc Alignment
% **get some GLR objective function's variable ready
%
% author: Cheng Yang
% email me any questions: cheng.yang@ieee.org
% date: June 16th, 2020
% please kindly cite the paper: 
% ['Signed Graph Metric Learning via Gershgorin Disc Alignment', 
% Cheng Yang, Gene Cheung, Wei Hu, 
% https://128.84.21.199/abs/2006.08816]
%=================================================================
function [c] = get_graph_Laplacian_variables_ready_ML(feature,x,N,n)
%% graph smoothness
% y=(x-x.').^2;
% y=reshape(y,[N^2 1]);
a=reshape(feature,[N 1 n]);
c=reshape(a-permute(a,[2 1 3]),[N^2 n]);

%% graph polynomial
% y=x*x'; % (N x 1) x (1 x N) = N x N
% a=reshape(feature,[N 1 n]);
% c=reshape(a-permute(a,[2 1 3]),[N^2 n]);
end

