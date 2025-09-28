function [ Trans_10m] = SpecTrans_S2( S2_20m, S2_10m )

[H_10m, W_10m, ~] = size(S2_10m);
[H_20m, W_20m, ~] = size(S2_20m);

S2_10mTo20m = imresize(S2_10m, [H_20m W_20m], 'box'); 

M_20m = SpecReg( S2_20m, S2_10mTo20m ); 

S2_10m_Vec = Mat2Vec(S2_10m, H_10m, W_10m, size(S2_10m,3)); % Matrix to Vector.
Trans_10m_Vec = M_20m * S2_10m_Vec;
Trans_10m = Vec2Mat(Trans_10m_Vec, H_10m, W_10m, size(S2_20m,3)); % Vector to matrix.

end
