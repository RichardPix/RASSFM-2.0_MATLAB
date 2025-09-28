function [ Sharp_10m ] = InterbandSharpenS2( S2_10m, S2_20m, Res10m, Res20m )

[H_10m, W_10m, ~] = size(S2_10m);
[~, ~, Bd_20m] = size(S2_20m);

H_20m = H_10m*Res10m/Res20m;
W_20m = W_10m*Res10m/Res20m;

S2_20mTo10m = imresize(S2_20m, [H_10m W_10m], 'bicubic');

%%% Spectral transformation.
[ Trans_10m] = SpecTrans_S2( S2_20m, S2_10m );

%%% Spectral correlation. Only for REs and NNIR bands.
Corr_10m_4bds = SpecCorr(S2_20m(:,:,1:4), S2_10m);

%%% Band combination. Only for REs and NNIR bands.
Sim_10m_Combine = BandCombine(Trans_10m(:,:,1:4), Corr_10m_4bds, S2_20m(:,:,1:4));
Sim_10m = Trans_10m;
Sim_10m(:,:,1:4) = Sim_10m_Combine; 

Sim_20m = imresize(Sim_10m, [H_20m W_20m], 'box');
Sim_20m_Usp = imresize(Sim_20m, [H_10m W_10m], 'bicubic');

Sharp_10m = zeros(H_10m, W_10m, Bd_20m);
for i=1:Bd_20m
    Sharp_10m(:,:,i) = Sim_10m(:,:,i) + (S2_20mTo10m(:,:,i) - Sim_20m_Usp(:,:,i));
end

end

