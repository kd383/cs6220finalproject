%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This reproduce the experiment in section 6.2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc
close all

load('nips.mat');
Cbar = bsxfun(@rdivide,C6,sum(C6));

% number of anchors
k = [3 4];
for i = 1:length(k)
    K = FastConicalHull(C6,k(i));
    J = FastSepNMF(Cbar,k(i));
    drawPCA(Cbar',{K,J});
    set(gca, 'FontSize', 40,'FontWeight','bold');
end