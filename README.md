# RASSFM 2.0_MATLAB
This repository provides the official MATLAB implementation of RASSFM 2.0, an enhanced spatial–spectral fusion model for multispectral imagery to generate fine-and-rich images that simultaneously have fine spatial details and rich spectral information.

[![DOI](https://zenodo.org/badge/1065591619.svg)](https://doi.org/10.5281/zenodo.19046911) https://doi.org/10.5281/zenodo.19046912

Code Version 1.0: March 16, 2026.

Overview
===================================================================================================================================================================
The model is designed for multispectral-to-multispectral sharpening (newly defined as M2Msharpening), enabling the fusion of fine-but-limited imagery (e.g., PlanetScope) with coarse-but-rich imagery (e.g., Sentinel-2) to produce fine-and-rich imagery.
Beyond traditional image fusion evaluation, this work demonstrates that M2Msharpening can enhance downstream Earth observation tasks, such as very-high-resolution (3-m) land cover classification. Moreover, RASSFM 2.0-based land cover classification outperforms single-sensor, band-stacking, and our earlier RASSFM 1.0 results.

Tutorial
===================================================================================================================================================================
Run the script "main_rassfm2.m" to generate fine-and-rich imagery. This script reads image paths from "RASSFM2_Path.txt", including source PlanetScope (PSB.SD), Sentinel-2 10-/20-m bands, and the fused result image. Please follow the guidelines in "main_rassfm2.m" to ensure correct operations. 
If users are using PS2 or PS2.SD, please adjust the code accordingly because they don't have the red edge band. Users may refer to RASSFM 1.0, https://github.com/RichardPix/RASSFM_MATLAB. Additionally, note that the NIR band of PS2 and PS2.SD/PSB corresponds to the NIR and NNIR bands of Sentinel-2, respectively.

Should you have any questions or find any bugs, please feel free to contact Yongquan Zhao (yongquanzhao181@gmail.com). We will keep maintaining the code. Welcome feedback!

References:
===================================================================================================================================================================
1. Yongquan Zhao, Desheng Liu, Xiaolin Zhu, Ming Luo, Bo Huang, Chunqiao Song, Xuejun Duan. 2026. RASSFM 2.0: An enhanced M2Msharpening model for blending PlanetScope and Sentinel-2 imagery across broad landscapes and improved land cover classification. Remote Sensing of Environment, 338, 115371. doi: 10.1016/j.rse.2026.115371
2. Yongquan Zhao, Desheng Liu. 2022. A robust and adaptive spatial-spectral fusion model for PlanetScope and Sentinel-2 imagery. GIScience & Remote Sensing, 59(1), 520-546. doi: 10.1080/15481603.2022.2036054

Copyright and License
===================================================================================================================================================================
Copyright (c) 2026 Yongquan Zhao, Ningjing Institute of Geography and Limnology, Chinese Academy of Sciences (NIGLAS).

This repository is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) license.

