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

with HAL;     use HAL;
with HAL.I2C; use HAL.I2C;

package OV7670 is

   OV7670_PID : constant := 16#76#;

   type Pixel_Format is (Pix_RGB565, Pix_YUV422, Pix_JPEG);

   type Frame_Size is (QQCIF, QQVGA, QQVGA2, QCIF, HQVGA, QVGA, CIF, VGA,
                       SVGA, SXGA, UXGA);

   type Frame_Rate is (FR_2FPS, FR_8FPS, FR_15FPS, FR_30FPS, FR_60FPS);

   type Resolution is record
     Width, Height : UInt16;
   end record;

   Resolutions : constant array (Frame_Size) of Resolution :=
     ((88,    72),   --  /* QQCIF */
      (160,   120),  --  /* QQVGA */
      (128,   160),  --  /* QQVGA2*/
      (176,   144),  --  /* QCIF  */
      (240,   160),  --  /* HQVGA */
      (320,   240),  --  /* QVGA  */
      (352,   288),  --  /* CIF   */
      (640,   480),  --  /* VGA   */
      (800,   600),  --  /* SVGA  */
      (1280,  1024), --  /* SXGA  */
      (1600,  1200)  --  /* UXGA  */
     );

   type OV7670_Camera (I2C : not null Any_I2C_Port) is private;

   procedure Initialize (This : in out OV7670_Camera;
                         Addr : I2C_Address);

   function Get_PID (This : OV7670_Camera) return UInt8;

private

   type OV7670_Camera (I2C  : not null Any_I2C_Port) is record
      Addr : UInt10;
   end record;

end OV7670;
