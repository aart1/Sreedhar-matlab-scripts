function [channelmap6x10RC8x8]=channelmap6x10_RC8x8()
% creates a 6x10 matrix with electrode numbers from 1:60
% the electrode numbers reflect the SOURCECHANNELNUMBERs
% MEA:
%     21    31    41    51    61    71
%     33    44    43    53    54    63
%     12    32    42    52    62    82
%     13    23    22    72    73    83
%     14    24    34    64    74    84
%     15    25    35    65    75    85
%     16    26    27    77    76    86
%     17    37    47    57    67    87
%     36    45    46    56    55    66
%     28    38    48    58    68    78
%
% you can use colormap6x10_ch8x8_60 to create a colormap this MEA matrix 
%
% see also,
% colormap8x8_64,colormap8x8_60,colormap6x10_60,channelmap8x8_64,channelmap8x8_60,
% channelmap6x10_60colormap6x10_60,colormap6x10_ch8x8_60,channelmap6x10_ch8x8_60


channelmap6x10RC8x8 = [...
[    21    31    41    51    61    71];...
[    33    44    43    53    54    63];...
[    12    32    42    52    62    82];...
[    13    23    22    72    73    83];...
[    14    24    34    64    74    84];...
[    15    25    35    65    75    85];...
[    16    26    27    77    76    86];...
[    17    37    47    57    67    87];...
[    36    45    46    56    55    66];...
[    28    38    48    58    68    78]];