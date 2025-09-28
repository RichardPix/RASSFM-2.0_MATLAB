function [Correlated_3m, Corr_id] = SpecCorr(S2_20m, PS_3m)

[h, w, B] = size(S2_20m);
[H, W, b] = size(PS_3m);

PS_20m = imresize(PS_3m, [h w], 'box');

CC = zeros(1,b);
Correlated_3m = zeros(H, W, B);
Corr_id = zeros(B,1);

for i = 1 : B 
    for j = 1:b
        cc = corrcoef( S2_20m(:,:,i), PS_20m(:,:,j));
        CC(j) = cc(1,2);
    end
    
    [~, id_maxR] = max(CC);
    
    Correlated_3m(:,:,i) = PS_3m(:,:,id_maxR);

    Corr_id(i) = id_maxR;
end

end