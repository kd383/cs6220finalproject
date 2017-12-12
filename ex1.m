%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This reproduce the experiment in section 6.1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc
close all

load('nips.mat');
Cbar = bsxfun(@rdivide,C6,sum(C6));

% number of anchors
k = 6;

K = FastConicalHull(C6,k);
J = FastSepNMF(Cbar,k);
drawPCA(Cbar',{K,J});
set(gca, 'FontSize', 40,'FontWeight','bold');