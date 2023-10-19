%=================================================================
% Signed Graph Metric Learing (SGML) via Gershgorin Disc Alignment
% **get the indices of the diagonals
%
% author: Cheng Yang
% email me any questions: cheng.yang@ieee.org
% date: June 16th, 2020
% please kindly cite the paper:
% ['Signed Graph Metric Learning via Gershgorin Disc Alignment',
% Cheng Yang, Gene Cheung, Wei Hu,
% https://128.84.21.199/abs/2006.08816]
%=================================================================
function [ diag_idx3_full,...
    diag_idx3_diaoffdia,...
    diag_idx3_dia,...
    diag_idx3_offdia ] = diag_idx( N, n )

diag_idx3_full=[];
diag_idx3_diaoffdia=[];
diag_idx3_dia=[];
diag_idx3_offdia=[];

diag_idx0=1:N+1:N^2;
for i=1:n^2
    diag_idx3_full=[diag_idx3_full ((N^2)*(i-1))+diag_idx0];
end
for i=1:2*n-1
    diag_idx3_diaoffdia=[diag_idx3_diaoffdia ((N^2)*(i-1))+diag_idx0];
end
for i=1:n
    diag_idx3_dia=[diag_idx3_dia ((N^2)*(i-1))+diag_idx0];
end
for i=1:n-1
    diag_idx3_offdia=[diag_idx3_offdia ((N^2)*(i-1))+diag_idx0];
end

end

