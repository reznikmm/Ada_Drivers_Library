------------------------------------------------------------------------------
--                                                                          --
--                     Copyright (C) 2015-2016, AdaCore                     --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------

--  Based on ov7670.c from OpenMV
--
--  This file is part of the OpenMV project.
--  Copyright (c) 2013/2014 Ibrahim Abdelkader <i.abdalkader@gmail.com>
--  This work is licensed under the MIT license, see the file LICENSE for
--  details.
--
--  OV7670 driver.
--

with Bit_Fields; use Bit_Fields;

package body OV7670 is

   REG_GAIN : constant := 16#00#;  --  AGC gain bits 7:0 (9:8 in VREF)
   REG_BLUE : constant := 16#01#;  --  AWB blue channel gain
   REG_RED : constant := 16#02#;  --  AWB red channel gain
   REG_VREF : constant := 16#03#;  --  Vert frame control bits
   REG_COM1 : constant := 16#04#;  --  Common control 1
   COM1_R656 : constant := 16#40#;  --  COM1 enable R656 format
   REG_BAVE : constant := 16#05#;  --  U/B average level
   REG_GbAVE : constant := 16#06#;  --  Y/Gb average level
   REG_AECHH : constant := 16#07#;  --  Exposure value - AEC 15:10 bits
   REG_RAVE : constant := 16#08#;  --  V/R average level
   REG_COM2 : constant := 16#09#;  --  Common control 2
   COM2_SSLEEP : constant := 16#10#;  --  COM2 soft sleep mode
   REG_PID : constant := 16#0A#;  --  Product ID MSB (read-only)
   REG_VER : constant := 16#0B#;  --  Product ID LSB (read-only)
   REG_COM3 : constant := 16#0C#;  --  Common control 3
   COM3_SWAP : constant := 16#40#;  --  COM3 output data MSB/LSB swap
   COM3_SCALEEN : constant := 16#08#;  --  COM3 scale enable
   COM3_DCWEN : constant := 16#04#;  --  COM3 DCW enable
   REG_COM4 : constant := 16#0D#;  --  Common control 4
   REG_COM5 : constant := 16#0E#;  --  Common control 5
   REG_COM6 : constant := 16#0F#;  --  Common control 6
   REG_AECH : constant := 16#10#;  --  Exposure value 9:2
   REG_CLKRC : constant := 16#11#;  --  Internal clock
   CLK_EXT : constant := 16#40#;  --  CLKRC Use ext clock directly
   CLK_SCALE : constant := 16#3F#;  --  CLKRC Int clock prescale mask
   REG_COM7 : constant := 16#12#;  --  Common control 7
   COM7_RESET : constant := 16#80#;  --  COM7 SCCB register reset
   COM7_SIZE_MASK : constant := 16#38#;  --  COM7 output size mask
   COM7_PIXEL_MASK : constant := 16#05#;  --  COM7 output pixel format mask
   COM7_SIZE_VGA : constant := 16#00#;  --  COM7 output size VGA
   COM7_SIZE_CIF : constant := 16#20#;  --  COM7 output size CIF
   COM7_SIZE_QVGA : constant := 16#10#;  --  COM7 output size QVGA
   COM7_SIZE_QCIF : constant := 16#08#;  --  COM7 output size QCIF
   COM7_RGB : constant := 16#04#;  --  COM7 pixel format RGB
   COM7_YUV : constant := 16#00#;  --  COM7 pixel format YUV
   COM7_BAYER : constant := 16#01#;  --  COM7 pixel format Bayer RAW
   COM7_PBAYER : constant := 16#05#;  --  COM7 pixel fmt proc Bayer RAW
   COM7_COLORBAR : constant := 16#02#;  --  COM7 color bar enable
   REG_COM8 : constant := 16#13#;  --  Common control 8
   COM8_FASTAEC : constant := 16#80#;  --  COM8 Enable fast AGC/AEC algo,
   COM8_AECSTEP : constant := 16#40#;  --  COM8 AEC step size unlimited
   COM8_BANDING : constant := 16#20#;  --  COM8 Banding filter enable
   COM8_AGC : constant := 16#04#;  --  COM8 AGC (auto gain) enable
   COM8_AWB : constant := 16#02#;  --  COM8 AWB (auto white balance)
   COM8_AEC : constant := 16#01#;  --  COM8 AEC (auto exposure) enable
   REG_COM9 : constant := 16#14#;  --  Common control 9 - max AGC value
   REG_COM10 : constant := 16#15#;  --  Common control 10
   COM10_HSYNC : constant := 16#40#;  --  COM10 HREF changes to HSYNC
   COM10_PCLK_HB : constant := 16#20#;  --  COM10 Suppress PCLK on hblank
   COM10_HREF_REV : constant := 16#08#;  --  COM10 HREF reverse
   COM10_VS_EDGE : constant := 16#04#;  --  COM10 VSYNC chg on PCLK rising
   COM10_VS_NEG : constant := 16#02#;  --  COM10 VSYNC negative
   COM10_HS_NEG : constant := 16#01#;  --  COM10 HSYNC negative
   REG_HSTART : constant := 16#17#;  --  Horiz frame start high bits
   REG_HSTOP : constant := 16#18#;  --  Horiz frame end high bits
   REG_VSTART : constant := 16#19#;  --  Vert frame start high bits
   REG_VSTOP : constant := 16#1A#;  --  Vert frame end high bits
   REG_PSHFT : constant := 16#1B#;  --  Pixel delay select
   REG_MIDH : constant := 16#1C#;  --  Manufacturer ID high byte
   REG_MIDL : constant := 16#1D#;  --  Manufacturer ID low byte
   REG_MVFP : constant := 16#1E#;  --  Mirror / vert-flip enable
   MVFP_MIRROR : constant := 16#20#;  --  MVFP Mirror image
   MVFP_VFLIP : constant := 16#10#;  --  MVFP Vertical flip
   REG_LAEC : constant := 16#1F#;  --  Reserved
   REG_ADCCTR0 : constant := 16#20#;  --  ADC control
   REG_ADCCTR1 : constant := 16#21#;  --  Reserved
   REG_ADCCTR2 : constant := 16#22#;  --  Reserved
   REG_ADCCTR3 : constant := 16#23#;  --  Reserved
   REG_AEW : constant := 16#24#;  --  AGC/AEC upper limit
   REG_AEB : constant := 16#25#;  --  AGC/AEC lower limit
   REG_VPT : constant := 16#26#;  --  AGC/AEC fast mode op region
   REG_BBIAS : constant := 16#27#;  --  B channel signal output bias
   REG_GbBIAS : constant := 16#28#;  --  Gb channel signal output bias
   REG_EXHCH : constant := 16#2A#;  --  Dummy pixel insert MSB
   REG_EXHCL : constant := 16#2B#;  --  Dummy pixel insert LSB
   REG_RBIAS : constant := 16#2C#;  --  R channel signal output bias
   REG_ADVFL : constant := 16#2D#;  --  Insert dummy lines MSB
   REG_ADVFH : constant := 16#2E#;  --  Insert dummy lines LSB
   REG_YAVE : constant := 16#2F#;  --  Y/G channel average value
   REG_HSYST : constant := 16#30#;  --  HSYNC rising edge delay
   REG_HSYEN : constant := 16#31#;  --  HSYNC falling edge delay
   REG_HREF : constant := 16#32#;  --  HREF control
   REG_CHLF : constant := 16#33#;  --  Array current control
   REG_ARBLM : constant := 16#34#;  --  Array ref control - reserved
   REG_ADC : constant := 16#37#;  --  ADC control - reserved
   REG_ACOM : constant := 16#38#;  --  ADC & analog common - reserved
   REG_OFON : constant := 16#39#;  --  ADC offset control - reserved
   REG_TSLB : constant := 16#3A#;  --  Line buffer test option
   TSLB_NEG : constant := 16#20#;  --  TSLB Negative image enable
   TSLB_YLAST : constant := 16#04#;  --  TSLB UYVY or VYUY, see COM13
   TSLB_AOW : constant := 16#01#;  --  TSLB Auto output window
   REG_COM11 : constant := 16#3B#;  --  Common control 11
   COM11_NIGHT : constant := 16#80#;  --  COM11 Night mode
   COM11_NMFR : constant := 16#60#;  --  COM11 Night mode frame rate mask
   COM11_HZAUTO : constant := 16#10#;  --  COM11 Auto detect 50/60 Hz
   COM11_BAND : constant := 16#08#;  --  COM11 Banding filter val select
   COM11_EXP : constant := 16#02#;  --  COM11 Exposure timing control
   REG_COM12 : constant := 16#3C#;  --  Common control 12
   COM12_HREF : constant := 16#80#;  --  COM12 Always has HREF
   REG_COM13 : constant := 16#3D#;  --  Common control 13
   COM13_GAMMA : constant := 16#80#;  --  COM13 Gamma enable
   COM13_UVSAT : constant := 16#40#;  --  COM13 UV saturation auto adj
   COM13_UVSWAP : constant := 16#01#;  --  COM13 UV swap, use w TSLB[3]
   REG_COM14 : constant := 16#3E#;  --  Common control 14
   COM14_DCWEN : constant := 16#10#;  --  COM14 DCW & scaling PCLK enable
   REG_EDGE : constant := 16#3F#;  --  Edge enhancement adjustment
   REG_COM15 : constant := 16#40#;  --  Common control 15
   COM15_RMASK : constant := 16#C0#;  --  COM15 Output range mask
   COM15_R10F0 : constant := 16#00#;  --  COM15 Output range 10 to F0
   COM15_R01FE : constant := 16#80#;  --  COM15              01 to FE
   COM15_R00FF : constant := 16#C0#;  --  COM15              00 to FF
   COM15_RGBMASK : constant := 16#30#;  --  COM15 RGB 555/565 option mask
   COM15_RGB : constant := 16#00#;  --  COM15 Normal RGB out
   COM15_RGB565 : constant := 16#10#;  --  COM15 RGB 565 output
   COM15_RGB555 : constant := 16#30#;  --  COM15 RGB 555 output
   REG_COM16 : constant := 16#41#;  --  Common control 16
   COM16_AWBGAIN : constant := 16#08#;  --  COM16 AWB gain enable
   REG_COM17 : constant := 16#42#;  --  Common control 17
   COM17_AECWIN : constant := 16#C0#;  --  COM17 AEC window must match COM4
   COM17_CBAR : constant := 16#08#;  --  COM17 DSP Color bar enable
   REG_AWBC1 : constant := 16#43#;  --  Reserved
   REG_AWBC2 : constant := 16#44#;  --  Reserved
   REG_AWBC3 : constant := 16#45#;  --  Reserved
   REG_AWBC4 : constant := 16#46#;  --  Reserved
   REG_AWBC5 : constant := 16#47#;  --  Reserved
   REG_AWBC6 : constant := 16#48#;  --  Reserved
   REG_REG4B : constant := 16#4B#;  --  UV average enable
   REG_DNSTH : constant := 16#4C#;  --  De-noise strength
   REG_MTX1 : constant := 16#4F#;  --  Matrix coefficient 1
   REG_MTX2 : constant := 16#50#;  --  Matrix coefficient 2
   REG_MTX3 : constant := 16#51#;  --  Matrix coefficient 3
   REG_MTX4 : constant := 16#52#;  --  Matrix coefficient 4
   REG_MTX5 : constant := 16#53#;  --  Matrix coefficient 5
   REG_MTX6 : constant := 16#54#;  --  Matrix coefficient 6
   REG_BRIGHT : constant := 16#55#;  --  Brightness control
   REG_CONTRAS : constant := 16#56#;  --  Contrast control
   REG_CONTRAS_CENTER : constant := 16#57#;  --  Contrast center
   REG_MTXS : constant := 16#58#;  --  Matrix coefficient sign
   REG_LCC1 : constant := 16#62#;  --  Lens correction option 1
   REG_LCC2 : constant := 16#63#;  --  Lens correction option 2
   REG_LCC3 : constant := 16#64#;  --  Lens correction option 3
   REG_LCC4 : constant := 16#65#;  --  Lens correction option 4
   REG_LCC5 : constant := 16#66#;  --  Lens correction option 5
   REG_MANU : constant := 16#67#;  --  Manual U value
   REG_MANV : constant := 16#68#;  --  Manual V value
   REG_GFIX : constant := 16#69#;  --  Fix gain control
   REG_GGAIN : constant := 16#6A#;  --  G channel AWB gain
   REG_DBLV : constant := 16#6B#;  --  PLL & regulator control
   REG_AWBCTR3 : constant := 16#6C#;  --  AWB control 3
   REG_AWBCTR2 : constant := 16#6D#;  --  AWB control 2
   REG_AWBCTR1 : constant := 16#6E#;  --  AWB control 1
   REG_AWBCTR0 : constant := 16#6F#;  --  AWB control 0
   REG_SCALING_XSC : constant := 16#70#;  --  Test pattern X scaling
   REG_SCALING_YSC : constant := 16#71#;  --  Test pattern Y scaling
   REG_SCALING_DCWCTR : constant := 16#72#;  --  DCW control
   REG_SCALING_PCLK_DIV : constant := 16#73#;  --  DSP scale control clock divide
   REG_REG74 : constant := 16#74#;  --  Digital gain control
   REG_REG76 : constant := 16#76#;  --  Pixel correction
   REG_SLOP : constant := 16#7A#;  --  Gamma curve highest seg slope
   REG_GAM_BASE : constant := 16#7B#;  --  Gamma register base (1 of 15)
   GAM_LEN              : constant := 15;  --  Number of gamma registers
   R76_BLKPCOR : constant := 16#80#;  --  REG76 black pixel corr enable
   R76_WHTPCOR : constant := 16#40#;  --  REG76 white pixel corr enable
   REG_RGB444 : constant := 16#8C#;  --  RGB 444 control
   R444_ENABLE : constant := 16#02#;  --  RGB444 enable
   R444_RGBX : constant := 16#01#;  --  RGB444 word format
   REG_DM_LNL : constant := 16#92#;  --  Dummy line LSB
   REG_LCC6 : constant := 16#94#;  --  Lens correction option 6
   REG_LCC7 : constant := 16#95#;  --  Lens correction option 7
   REG_HAECC1 : constant := 16#9F#;  --  Histogram-based AEC/AGC ctrl 1
   REG_HAECC2 : constant := 16#A0#;  --  Histogram-based AEC/AGC ctrl 2
   REG_SCALING_PCLK_DELAY : constant := 16#A2#;  --  Scaling pixel clock delay
   REG_BD50MAX : constant := 16#A5#;  --  50 Hz banding step limit
   REG_HAECC3 : constant := 16#A6#;  --  Histogram-based AEC/AGC ctrl 3
   REG_HAECC4 : constant := 16#A7#;  --  Histogram-based AEC/AGC ctrl 4
   REG_HAECC5 : constant := 16#A8#;  --  Histogram-based AEC/AGC ctrl 5
   REG_HAECC6 : constant := 16#A9#;  --  Histogram-based AEC/AGC ctrl 6
   REG_HAECC7 : constant := 16#AA#;  --  Histogram-based AEC/AGC ctrl 7
   REG_BD60MAX : constant := 16#AB#;  --  60 Hz banding step limit
   REG_ABLC1 : constant := 16#B1#;  --  ABLC enable
   REG_THL_ST : constant := 16#B3#;  --  ABLC target
   REG_SATCTR : constant := 16#C9#;  --  Saturation control

   type Addr_And_Data is record
      Addr, Data : UInt8;
   end record;

   type Command_Array is array (Natural range <>) of Addr_And_Data;

   Setup_Commands : constant Command_Array :=
     (
        --  OV7670_set_fps
        --  Bypass PLL, use external clock directly
        (REG_DBLV, 0),
        (REG_CLKRC, 16#40#),
        --  set RGB
        (REG_COM7, COM7_RGB),
        (REG_RGB444, 0),
        (REG_COM15, COM15_RGB565 + COM15_R00FF),

      --  init
        (REG_TSLB, TSLB_YLAST),    -- No auto window
        (REG_COM10, COM10_VS_NEG), -- -VSYNC (req by SAMD PCC)
        (REG_SLOP, 16#20#),
        (REG_GAM_BASE, 16#1C#),
        (REG_GAM_BASE + 1, 16#28#),
        (REG_GAM_BASE + 2, 16#3C#),
        (REG_GAM_BASE + 3, 16#55#),
        (REG_GAM_BASE + 4, 16#68#),
        (REG_GAM_BASE + 5, 16#76#),
        (REG_GAM_BASE + 6, 16#80#),
        (REG_GAM_BASE + 7, 16#88#),
        (REG_GAM_BASE + 8, 16#8F#),
        (REG_GAM_BASE + 9, 16#96#),
        (REG_GAM_BASE + 10, 16#A3#),
        (REG_GAM_BASE + 11, 16#AF#),
        (REG_GAM_BASE + 12, 16#C4#),
        (REG_GAM_BASE + 13, 16#D7#),
        (REG_GAM_BASE + 14, 16#E8#),
        (REG_COM8,
         COM8_FASTAEC + COM8_AECSTEP + COM8_BANDING),
        (REG_GAIN, 16#00#),
        (COM2_SSLEEP, 16#00#),
        (REG_COM4, 16#00#),
        (REG_COM9, 16#20#), -- Max AGC value
        (REG_BD50MAX, 16#05#),
        (REG_BD60MAX, 16#07#),
        (REG_AEW, 16#75#),
        (REG_AEB, 16#63#),
        (REG_VPT, 16#A5#),
        (REG_HAECC1, 16#78#),
        (REG_HAECC2, 16#68#),
        (16#A1#, 16#03#),              -- Reserved register?
        (REG_HAECC3, 16#DF#), -- Histogram-based AEC/AGC setup
        (REG_HAECC4, 16#DF#),
        (REG_HAECC5, 16#F0#),
        (REG_HAECC6, 16#90#),
        (REG_HAECC7, 16#94#),
        (REG_COM8, COM8_FASTAEC + COM8_AECSTEP +
                              COM8_BANDING + COM8_AGC +
                              COM8_AEC),
        (REG_COM5, 16#61#),
        (REG_COM6, 16#4B#),
        (16#16#, 16#02#),            -- Reserved register?
        (REG_MVFP, 16#07#), -- 16#07#,
        (REG_ADCCTR1, 16#02#),
        (REG_ADCCTR2, 16#91#),
        (16#29#, 16#07#), -- Reserved register?
        (REG_CHLF, 16#0B#),
        (16#35#, 16#0B#), -- Reserved register?
        (REG_ADC, 16#1D#),
        (REG_ACOM, 16#71#),
        (REG_OFON, 16#2A#),
        (REG_COM12, 16#78#),
        (16#4D#, 16#40#), -- Reserved register?
        (16#4E#, 16#20#), -- Reserved register?
        (REG_GFIX, 16#5D#),
        (REG_REG74, 16#19#),
        (16#8D#, 16#4F#), -- Reserved register?
        (16#8E#, 16#00#), -- Reserved register?
        (16#8F#, 16#00#), -- Reserved register?
        (16#90#, 16#00#), -- Reserved register?
        (16#91#, 16#00#), -- Reserved register?
        (REG_DM_LNL, 16#00#),
        (16#96#, 16#00#), -- Reserved register?
        (16#9A#, 16#80#), -- Reserved register?
        (16#B0#, 16#84#), -- Reserved register?
        (REG_ABLC1, 16#0C#),
        (16#B2#, 16#0E#), -- Reserved register?
        (REG_THL_ST, 16#82#),
        (16#B8#, 16#0A#), -- Reserved register?
        (REG_AWBC1, 16#14#),
        (REG_AWBC2, 16#F0#),
        (REG_AWBC3, 16#34#),
        (REG_AWBC4, 16#58#),
        (REG_AWBC5, 16#28#),
        (REG_AWBC6, 16#3A#),
        (16#59#, 16#88#), -- Reserved register?
        (16#5A#, 16#88#), -- Reserved register?
        (16#5B#, 16#44#), -- Reserved register?
        (16#5C#, 16#67#), -- Reserved register?
        (16#5D#, 16#49#), -- Reserved register?
        (16#5E#, 16#0E#), -- Reserved register?
        (REG_LCC3, 16#04#),
        (REG_LCC4, 16#20#),
        (REG_LCC5, 16#05#),
        (REG_LCC6, 16#04#),
        (REG_LCC7, 16#08#),
        (REG_AWBCTR3, 16#0A#),
        (REG_AWBCTR2, 16#55#),
        (REG_MTX1, 16#80#),
        (REG_MTX2, 16#80#),
        (REG_MTX3, 16#00#),
        (REG_MTX4, 16#22#),
        (REG_MTX5, 16#5E#),
        (REG_MTX6, 16#80#), -- 16#40#?
        (REG_AWBCTR1, 16#11#),
        (REG_AWBCTR0, 16#9F#), -- Or use 16#9E# for advance AWB
        (REG_BRIGHT, 16#00#),
        (REG_CONTRAS, 16#40#),
        (REG_CONTRAS_CENTER, 16#80#), -- 16#40#?

      --  frame_control {10, 174, 4, 2}, // SIZE_DIV2=1  320x240 QVGA
      (REG_COM3, COM3_DCWEN),  --  // Enable downsampling if sub-VGA
      (REG_COM14, 16#19#), --  Enable PCLK division if sub-VGA 2,4,8,16 = 0x19,1A,1B,1C
      (REG_SCALING_DCWCTR, 16#11#),  --  Horiz/vert downsample ratio, 1:8 max
      (REG_SCALING_PCLK_DIV, 16#F1#), --  Pixel clock divider if sub-VGA
      --  Window size is scattered across multiple registers.
      --  Horiz/vert stops can be automatically calc'd from starts.
      (REG_HSTART, 174 / 8),
      (REG_HSTOP, Uint8 ((174 + 640) mod 784 / 8)),
      (REG_HREF, (4 * 2**6)
       + Uint8 ((174 + 640) mod 784 mod 8) * 2**3
       + 174 mod 8),
      (REG_VSTART, 10 / 4),
      (REG_VSTOP, UInt8 ((10+480) / 4)),
      (REG_VREF, UInt8 ((10+480) mod 4 * 4) + 10 mod 4),
      (REG_SCALING_PCLK_DELAY, 2)
   );
   --  ((16#11#,     16#01#),
     --   (16#12#,     16#00#),
     --   (16#0C#,     16#04#),
     --   (16#3E#,     16#19#),
     --   (16#70#,     16#3A#),
     --   (16#71#,     16#36#),
     --   (16#72#,     16#11#),
     --   (16#73#,     16#F1#),
     --   (16#A2#,     16#02#));

   procedure Write (This : OV7670_Camera; Addr, Data : UInt8);
   function Read (This : OV7670_Camera; Addr : UInt8) return UInt8;

   -----------
   -- Write --
   -----------

   procedure Write (This : OV7670_Camera; Addr, Data : UInt8) is
      Status : I2C_Status;
   begin
      This.I2C.Mem_Write (Addr          => This.Addr,
                          Mem_Addr      => UInt16 (Addr),
                          Mem_Addr_Size => Memory_Size_8b,
                          Data          => (1 => Data),
                          Status        => Status);
      if Status /= Ok then
         raise Program_Error;
      end if;

      delay 0.001;
   end Write;

   ----------
   -- Read --
   ----------

   function Read (This : OV7670_Camera; Addr : UInt8) return UInt8 is
      Data : I2C_Data (1 .. 1);
      Status : I2C_Status;
   begin
      This.I2C.Mem_Read (Addr          => This.Addr,
                         Mem_Addr      => UInt16 (Addr),
                         Mem_Addr_Size => Memory_Size_8b,
                         Data          => Data,
                         Status        => Status);
      if Status /= Ok then
         raise Program_Error;
      end if;
      return Data (Data'First);
   end Read;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (This : in out OV7670_Camera;
      Addr : UInt10)
   is
   begin
      This.Addr     := Addr;

      for Elt of Setup_Commands loop
         Write (This, Elt.Addr, Elt.Data);
      end loop;
   end Initialize;

   -------------
   -- Get_PID --
   -------------

   function Get_PID (This : OV7670_Camera) return UInt8 is
   begin
      return Read (This, REG_PID);
   end Get_PID;

end OV7670;
