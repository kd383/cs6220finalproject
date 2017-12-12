function drawPCA(C, K)

    % row normalize if not already
    if abs(sum(C(1,:))-1)> 1e-8
        C = bsxfun(@rdivide, C, sum(C,2));
    end
    % centralized to column mean 0
    C = bsxfun(@minus, C, mean(C));
    
    % principal component
    [~,~,V] = svds(C, 2, 'largest');
    w = C*V;
    
    f = figure;
    hold on;
    set(f,'units','points','position',[0,0,900,900]);
    scatter(w(:,1),w(:,2),20,'filled')
    
    % find the convex hull of S
    c = {'r','g'};
    for i = 1:length(K)
        S = K{i};
        k = convhull(w(S,1),w(S,2));
        scatter(w(S,1),w(S,2),400,c{i},'filled');
        plot(w(S(k),1),w(S(k),2),c{i},'LineWidth',5);
    end
end