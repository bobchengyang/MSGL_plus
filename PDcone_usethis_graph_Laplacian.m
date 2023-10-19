%=================================================================
% Signed Graph Metric Learing (SGML) via Gershgorin Disc Alignment
% **set a graph Laplacian matrix L
%
% author: Cheng Yang
% email me any questions: cheng.yang@ieee.org
% date: June 16th, 2020
% please kindly cite the paper: 
% ['Signed Graph Metric Learning via Gershgorin Disc Alignment', 
% Cheng Yang, Gene Cheung, Wei Hu, 
% https://128.84.21.199/abs/2006.08816]
%=================================================================
function [ L ] = PDcone_usethis_graph_Laplacian( N, c, M)
W=exp(-sum(c*M.*c,2));
W=reshape(W, [N N]);
W(1:N+1:end) = 0;

D=diag(sum(W));
L=D-W;
L=D^(-0.5)*L*D^(-0.5);
L=(L+L')/2;
% L = diag(sum(W))-W;

end

