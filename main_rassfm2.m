%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Source code of the Robust and Adaptive Spatial-Spectral image Fusion Model 2.0 (RASSFM 2.0) 
%   - Yongquan Zhao, Nanjing Institute of Geography and Limnology, Chinese Academy of Sciences, Nanjing.
%
% Code summary: this code package is for blending the 5 PlanetScope (PSB.SD) 3-m bands (Blue, Green, Red, Red Edge, NIR)
% and the 10 Sentinel-2 (S2) 10–20-m bands (Blue, Green, Red, RE1, RE2, RE3, NIR, NNIR, SWIR1, SWIR2) to generate the 10 synthetic 3-m bands.
% 
% Last revision date: September 28, 2025.
% 
% References:
% RASSFM 1.0: Yongquan Zhao, Desheng Liu. 2022. A robust and adaptive spatial-spectral fusion model 
%               for PlanetScope and Sentinel-2 imagery. GIScience & Remote Sensing, 59(1), 520-546.
% RASSFM 2.0: Yongquan Zhao, Desheng Liu, Xiaolin Zhu, Ming Luo, Bo Huang, Chunqiao Song, Xuejun Duan. RASSFM 2.0: An 
%               enhanced M2Msharpening model for blending PlanetScope and Sentinel-2 imagery across broad landscapes at 3-m resolution. Under Review.
% 
% 
% Inputs from RASSFM_Path.txt:
% (1) fname_PS:  The file name of input PS bands (Blue, Green, Red, Red Edge, NIR);
% (2) fname_S2_10m: The file name of input S2 10-m bands (Blue, Green, Red, NIR);
% (3) fname_S2_20m: The file name of input S2 20-m bands (RE1, RE2, RE3, NNIR, SWIR1, SWIR2);
% (4) fname_fusion: The file name of fusion result image.
%
% Input data requirements:
% (1) the 3m PS bands are stacked in the order of: Blue, Green, Red, Red Edge, NIR;
% (2) the 10m S2 bands are stacked in the order of: Blue, Green, Red, NIR;
% (3) the 20m S2 bands are stacked in the order of: RE1, RE2, RE3, NNIR, SWIR1, SWIR2;
% (4) the surface reflectance value ranges of PS and S2 images are 0 - 10000.
% (5) the PS and S2 images should have the same geographic coverage and projection (e.g., UTM). 
% (6) the PS and S2 images should be geometrically matched. 
% (7) This code package is for spatial-spectral fusion, so the PS and S2 images
%       should be acquired on the same or very close date(s).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

%%%%%%%%%%%%%%%%%%%%%%%%%% Load PS and S2 data.  %%%%%%%%%%%%%%%%%%%%%%%%%%
% 3m PS image path.
[fname_PS ] = textread('RASSFM2_Path.txt', '%s', 1); % read one line. 
fname_PS = char(fname_PS); % cell to char.

% 10m S2 image path.
[fname_S2_10m ] = textread('RASSFM2_Path.txt', '%s', 1, 'headerlines',1); % read one line and skip one line.
fname_S2_10m = char(fname_S2_10m); % cell to char.

% 20m S2 image path.
[fname_S2_20m ] = textread('RASSFM2_Path.txt', '%s', 1, 'headerlines',2); % read one line and skip two lines.
fname_S2_20m = char(fname_S2_20m); % cell to char.

% Fused image path.
[fname_fusion ] = textread('RASSFM2_Path.txt', '%s', 1, 'headerlines',3); % read one line and skip three lines.
fname_fusion = char(fname_fusion); % cell to char.

% Check whether inputs exist and outputs are specified.
if strcmp(fname_PS, '')
    error('Could not find the PlanetScope image. \n');
end
if strcmp(fname_S2_10m, '')
    error('Could not find the 10m Sentinel-2 bands. \n');
end
if strcmp(fname_S2_20m, '')
    error('Could not find the 20m Sentinel-2 bands. \n');
end
if strcmp(fname_fusion, '')
    error('Please specify the output image name.\n');
end

% Read images.
[Img_PS, W_3m, H_3m, BandNum_PS, ~, ~]=freadenvi(fname_PS);
[Img_S2_10m, W_S2_10m, H_S2_10m, BandNum_S2_10m, ~, ~]=freadenvi(fname_S2_10m);
[Img_S2_20m, W_S2_20m, H_S2_20m, BandNum_S2_20m, ~, ~]=freadenvi(fname_S2_20m);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%% Setting information for the fusion result. %%%%%%%%%%%%%%%
[filepath_PS, name_PS, ~] = fileparts(fname_PS);
info_PS = read_envihdr(strcat(filepath_PS, '\', name_PS, '.hdr'));

info = info_PS;
BandNum_S2 = BandNum_S2_10m + BandNum_S2_20m; 
info.bands = BandNum_S2; 
FusionBandName = {'Blue', 'Green', 'Red', 'RE1', 'RE2', 'RE3', 'NIR', 'NNIR', 'SWIR1', 'SWIR2'};

fillV = 0.00000000e+000; % Fill value for outliers.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Fusion parametrization.
WinRadius = 5; % Radius of the moving window for similar neighbor searching.
NumPatch = 25; % Number of similar patches.

% Get the image sizes of 10m and 20m S2 bands.
H_10m = H_3m*3/10; W_10m = W_3m*3/10;
H_20m = H_3m*3/20; W_20m = W_3m*3/20;

fprintf('Fusion started. \n');


%% Radiometric harmonization.
% Harmonize the 5 PS bands based on their S2 equivalents at 10-m and 20-m resoluitons.
Img_PS_hm = zeros(H_3m, W_3m, BandNum_PS);

% B, G, R of PS.
Img_PS_10m = imresize(Img_PS(:,:, 1:3), [H_10m W_10m], 'box'); 
rho_10m = RadHm(Img_PS_10m, Img_S2_10m(:,:,1:3)); 
n_10m = size(Img_PS_10m,3);
for i = 1:n_10m
    Img_PS_hm(:,:,i) = Img_PS(:,:,i) .* rho_10m(i,2) + rho_10m(i,1);
end

% RE, NIR of PS.
Img_PS_20m = imresize(Img_PS(:,:, 4:5), [H_20m W_20m], 'box'); 
rho_20m = RadHm(Img_PS_20m, Img_S2_20m(:,:,[1,4])); 
for i = 1:size(Img_PS_20m,3)
    Img_PS_hm(:,:,i+n_10m) = Img_PS(:,:,i+n_10m) .* rho_20m(i,2) + rho_20m(i,1);
end
Img_PS = Img_PS_hm;

clear Img_PS_10m Img_PS_20m Img_PS_hm


%% Inter-band sharpening for S2.
[ Img_S2_20To10m ] = InterbandSharpenS2( Img_S2_10m, Img_S2_20m, 10, 20 );
Img_S2_Sharp = zeros(H_10m, W_10m, BandNum_S2);
Img_S2_Sharp(:, :, [1:3,7]) = Img_S2_10m;
Img_S2_Sharp(:,:,[4:6,8:10]) = Img_S2_20To10m;
Img_S2_Sharp = imresize(Img_S2_Sharp, [H_3m W_3m], 'bicubic');
clear Img_S2_20To10m


%% Band combination of spectral transformation and spectral correlation.
%%%%%% Spectral transformation at 10-m and 20-m resolutions for the 4 S2 10-m and 6 S2 20-m bands, respectively.
Sim_3m_Trans = SpecTrans_PS_S2( Img_S2_10m, Img_S2_20m, Img_PS );
fprintf('Spectral transformation completed. \n');
clear Img_S2_10m

%%%%%% Spectral correlation between PS and S2.
band_20m_id_combine = [1:3,4]; % Band combination for 20-m S2 RE1&2&3 and NNIR bands. It's for the 6-band variable: Img_S2_20m.
band_id_combine = [4:6,8]; % Band combination for 20-m S2 RE1&2&3 and NNIR bands. It's for 10-band image variables.
Sim_3m_Corr = SpecCorr(Img_S2_20m(:,:,band_20m_id_combine), Img_PS);
fprintf('Spectral correlation completed. \n');
clear Img_PS

%%%%%% "Band combination": combine "Spectral transformation" and "Spectral correlation". Only for RE1&2&3 and NNIR bands.
Sim_3m_Combine = BandCombine(Sim_3m_Trans(:,:,band_id_combine), Sim_3m_Corr, Img_S2_20m(:,:,band_20m_id_combine));
Sim_3m = Sim_3m_Trans;
Sim_3m(:,:,band_id_combine) = Sim_3m_Combine;
fprintf('Band combination completed. \n');
clear Sim_3m_Trans Sim_3m_Corr Sim_3m_Combine Img_S2_20m


%% Blending PS and S2.
% Resampling the 3-m spectrally upsampled image for M2Msharpening.
Sim_10m = imresize(Sim_3m, [H_10m W_10m], 'box');
Sim_10m_UpRsp = imresize(Sim_10m, [H_3m W_3m], 'bicubic');
clear Sim_10m

% All-band fusion.
fprintf('M2Msharpening running... \n');
FusionImg = SSF_PS_S2( Sim_10m_UpRsp, Img_S2_Sharp, Sim_3m, WinRadius, NumPatch, 'bicubic' );
fprintf('M2Msharpening completed. \n');
clear Img_S2_Sharp Sim_3m Sim_10m_UpRsp

% Write M2Msharpened image.
rs_imwrite_bands(single(FusionImg), fname_fusion, info, FusionBandName, fillV); % Save results as single to save storage.
fprintf('Fusion result saved. Done! \n');

