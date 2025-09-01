with HAL.Bitmap;
with HAL.Framebuffer;
with STM32.Sensor;
with STM32.Board;
with STM32.DCMI;
with Interfaces;
with System;
with Buffers;
procedure Cam is
   VRAM : Interfaces.Unsigned_16
     with
       Import,
       Address => System'To_Address (16#6C00_0080#),
       Volatile;

   Dummy : aliased Interfaces.Unsigned_32 := 16#1234#;
begin
   STM32.Board.Display.Initialize;
--   STM32.Board.Display.Set_Orientation (HAL.Framebuffer.Landscape);

   STM32.Board.TFT_Bitmap.Set_Source (HAL.Bitmap.Dark_Cyan);
   STM32.Board.TFT_Bitmap.Fill;

   for J in 1 .. 240 * 320 loop
      VRAM := Interfaces.Unsigned_16'Mod (J);
   end loop;

   STM32.Sensor.Initialize;

   loop
      STM32.Board.Display.To_Zero;
      STM32.Sensor.Snapshot (Buffers.Buffer'Address);

      for Item of Buffers.Buffer loop
         VRAM := Item;
      end loop;

--      delay 1.0;
   end loop;
end Cam;
