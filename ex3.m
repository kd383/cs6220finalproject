%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This reproduce the experiment in section 6.3
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc
close all

n = [1e-8 2e-8];
for i = 1:length(n)
    load('nips.mat');
    C6 = C6 + n(i)*rand(5000,5000);
    Cbar = bsxfun(@rdivide,C6,sum(C6));

    % number of anchors
    k = 6;

    K = FastConicalHull(C6,k);
    J = FastSepNMF(Cbar,k);
    drawPCA(Cbar',{K,J});
    set(gca, 'FontSize', 40,'FontWeight','bold');
end