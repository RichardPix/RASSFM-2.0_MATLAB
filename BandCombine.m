function [Sim, Syn_id] = BandCombine(Sim1, Sim2, S2)

[h, w, B] = size(S2);

Sim1_LR = imresize(Sim1, [h w], 'box');
Sim2_LR = imresize(Sim2, [h w], 'box');

Sim = zeros(size(Sim1));
Syn_id = zeros(B,1);

for i=1:B
    CCMat1 = corrcoef(Sim1_LR(:,:,i), S2(:,:,i));
    CCMat2 = corrcoef(Sim2_LR(:,:,i), S2(:,:,i));

    [~, max_id] = max([CCMat1(2,1) CCMat2(2,1)]);
    if max_id == 1
        Sim(:,:,i) = Sim1(:,:,i);
    elseif max_id == 2
        Sim(:,:,i) = Sim2(:,:,i);
    end

    Syn_id(i) = max_id;
end

end