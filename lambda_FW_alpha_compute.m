function [lambda_FW_alpha_0,lambda_FW_alpha] = lambda_FW_alpha_compute(...
    beta_0, ...
    alpha_0, ...
    FW_beta_direction, ...
    l_matrix, ...
    eig_tol)
%LAMBDA_FW_ALPHA 此处显示有关此函数的摘要
%   此处显示详细说明
lambda_FW_alpha_0=(beta_0+alpha_0*(FW_beta_direction-beta_0)).*l_matrix+eig_tol; % N x P
lambda_FW_alpha=(FW_beta_direction-beta_0).*l_matrix; % N x P
end

