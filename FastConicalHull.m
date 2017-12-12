function K = FastConicalHull(M,r)

% FastConicalHull - Fast Conical Hull Algorithm for Near-separable 
% Non-negative Matrix Factorization
% 
% a.k.a. XRAY
%
% *** Description ***
% It recursively extracts r columns of the input matrix M:  at each step, 
% it selects a column of M corresponding to an extreme ray of the cone 
% generated by the columns of M, and then projects all the columns of M 
% on the cone generated by the columns of M extracted so far. 
%
% This is our implementation of XRAY(max) from A. Kumar, V. Sindhwani, and 
% P. Kambadur, Fast Conical Hull Algorithms for Near-separable Non-negative 
% Matrix Factorization, International Conference on Machine Learning, 2013 
% (ICML '13) (see also arXiv:1210.1190). 
% 
% K = FastConicalHull(M,r) 
%
% ****** Input ******
% M = WH + N : a noisy separable matrix, that is, W >=0, H = [I,H']P where 
%              I is the identity matrix, H'>= 0, P is a permutation matrix, 
%              and N is sufficiently small. 
% r          : number of columns to be extracted. 
%
% ****** Output ******
% K        : index set of the extracted columns corresponding to extreme
%            rays of cone(M)

[m,n] = size(M); 
R = M; % residual 
p = ones(m,1); % as suggested in arXiv:1210.1190
K = []; 
Mobj = M; 

for k = 1 : r
    % Extract an extreme ray
    normR = sum(R.^2); 
    [pipi,i] = max(normR); 
     
    [pipi,j] = max( (R(:,i)'*Mobj)./(p'*Mobj+1e-6) ); 
    K = [K; j]; 
    Mobj(:,j) = 0; 
    
    % Update residual 
    if k == 1
        H = nnlsHALSupdt(M,M(:,K)); 
        %H = fcnnls(M(:,K),M); 
    else
        h = zeros(1,n); h(j) = 1; 
        H = [H; h]; 
        H = nnlsHALSupdt(M,M(:,K),H); 

                % H = fcnnls(M(:,K),M); 
    end
    R = M - M(:,K)*H; 
    
    
    % !Warning! R should not be computed explicitely in the sparse case.
    % We do it here for simplicity but this version is impractical for
    % large-scale sparse datasets (such as document datasets); but 
    % see arXiv:1210.1190. 
end

end % of function FastConicalHull

function V = nnlsHALSupdt(M,U,V)

% Computes an approximate solution of the following nonnegative least 
% squares problem (NNLS)  
%
%           min_{V >= 0} ||M-UV||_F^2 
% 
% with an exact block-coordinate descent scheme (max 500 iterations). 
%
% See N. Gillis and F. Glineur, Accelerated Multiplicative Updates and 
% Hierarchical ALS Algorithms for Nonnegative Matrix Factorization, 
% Neural Computation 24 (4): 1085-1105, 2012.
% 
%
% ****** Input ******
%   M  : m-by-n matrix 
%   U  : m-by-r matrix
%   V  : r-by-n initialization matrix 
%        default: one non-zero entry per column corresponding to the 
%        clostest column of U of the corresponding column of M 
%
%   *Remark. M, U and V are not required to be nonnegative. 
%
% ****** Output ******
%   V  : an r-by-n nonnegative matrix \approx argmin_{V >= 0} ||M-UV||_F^2


[m,n] = size(M); 
[m,r] = size(U); 
if nargin <= 2 
    V = zeros(r,n); 
    for i = 1 : n
        % Distance between ith column of M and columns of U
        disti = sum( (U - repmat(M(:,i),1,r)).^2 ); 
        [a,b] = min(disti); 
        V(b,i) = 1; 
    end
end

UtU = U'*U; 
UtM = U'*M; 
delta = 1e-6; % Stopping condition depending on evolution of the iterate V: 
              % Stop if ||V^{k}-V^{k+1}||_F <= delta * ||V^{0}-V^{1}||_F 
              % where V^{k} is the kth iterate. 
eps0 = 0; cnt = 1; eps = 1; 
while eps >= (delta)^2*eps0 && cnt <= 500 %Maximum number of iterations
    nodelta = 0; if cnt == 1, eit3 = cputime; end
        for k = 1 : r
            deltaV = max((UtM(k,:)-UtU(k,:)*V)/(UtU(k,k)+1e-16),-V(k,:));
            V(k,:) = V(k,:) + deltaV;
            nodelta = nodelta + deltaV*deltaV'; % used to compute norm(V0-V,'fro')^2;
            if V(k,:) == 0, V(k,:) = 1e-16*max(V(:)); end % safety procedure
        end
    if cnt == 1
        eps0 = nodelta; 
    end
    eps = nodelta; 
    cnt = cnt + 1; 
end

end % of function nnlsHALSupdt