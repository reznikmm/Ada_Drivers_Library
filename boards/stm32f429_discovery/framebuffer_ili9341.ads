with HAL;             use HAL;
with HAL.Framebuffer; use HAL.Framebuffer;
with HAL.Bitmap;

private with ILI9341;
private with STM32.DMA2D_Bitmap;
private with STM32.LTDC;
private with STM32.GPIO;
private with STM32.Device;

package Framebuffer_ILI9341 is

   type Frame_Buffer is limited
     new HAL.Framebuffer.Frame_Buffer_Display with private;

   overriding function Get_Max_Layers
     (Display : Frame_Buffer) return Positive;

   overriding function Is_Supported
     (Display : Frame_Buffer;
      Mode    : HAL.Framebuffer.FB_Color_Mode) return Boolean;

   overriding procedure Initialize
     (Display     : in out Frame_Buffer;
      Orientation : HAL.Framebuffer.Display_Orientation := Default;
      Mode        : HAL.Framebuffer.Wait_Mode := Interrupt);

   overriding function Initialized
     (Display : Frame_Buffer) return Boolean;

   overriding function Get_Width
     (Display : Frame_Buffer) return Positive;

   overriding function Get_Height
     (Display : Frame_Buffer) return Positive;

   overriding function Is_Swapped
     (Display : Frame_Buffer) return Boolean;

   overriding procedure Set_Background
     (Display : Frame_Buffer; R, G, B : Byte);

   overriding procedure Initialize_Layer
     (Display : in out Frame_Buffer;
      Layer   : Positive;
      Mode    : HAL.Framebuffer.FB_Color_Mode;
      X       : Natural := 0;
      Y       : Natural := 0;
      Width   : Positive := Positive'Last;
      Height  : Positive := Positive'Last);
   --  All layers are double buffered, so an explicit call to Update_Layer
   --  needs to be performed to actually display the current buffer attached
   --  to the layer.
   --  Alloc is called to create the actual buffer.

   overriding function Initialized
     (Display : Frame_Buffer;
      Layer   : Positive) return Boolean;

   overriding procedure Update_Layer
     (Display   : in out Frame_Buffer;
      Layer     : Positive;
      Copy_Back : Boolean := False);
   --  Updates the layer so that the hidden buffer is displayed.
   --  If Copy_Back is set, then the newly displayed buffer will be copied back
   --  the the hidden buffer

   overriding procedure Update_Layers
     (Display : in out Frame_Buffer);
   --  Updates all initialized layers at once with their respective hidden
   --  buffer

   overriding function Get_Color_Mode
     (Display : Frame_Buffer;
      Layer   : Positive) return HAL.Framebuffer.FB_Color_Mode;

   overriding function Get_Hidden_Buffer
     (Display : Frame_Buffer;
      Layer   : Positive) return HAL.Bitmap.Bitmap_Buffer'Class;
   --  Retrieves the current hidden buffer for the layer.

   overriding function Get_Pixel_Size
     (Display : Frame_Buffer;
      Layer   : Positive) return Positive;

private

   --  Chip select and Data/Command select fot the LCD screen
   LCD_CSX      : STM32.GPIO.GPIO_Point renames STM32.Device.PC2;
   LCD_WRX_DCX  : STM32.GPIO.GPIO_Point renames STM32.Device.PD13;
   LCD_RESET    : STM32.GPIO.GPIO_Point renames STM32.Device.PD12;

   type FB_Array is array (STM32.LTDC.LCD_Layer, 1 .. 2) of
     STM32.DMA2D_Bitmap.DMA2D_Bitmap_Buffer;
   type Buffer_Idx is range 0 .. 2;
   type FB_Current is array (STM32.LTDC.LCD_Layer) of Buffer_Idx;

   type Frame_Buffer
   is limited new HAL.Framebuffer.Frame_Buffer_Display with record
      Display : ILI9341.ILI9341_Device (STM32.Device.SPI_5'Access,
                                        Chip_Select => LCD_CSX'Access,
                                        WRX         => LCD_WRX_DCX'Access,
                                        Reset       => LCD_RESET'Access);
      Swapped : Boolean;
      Buffers : FB_Array :=
                  (others => (others => STM32.DMA2D_Bitmap.Null_Buffer));
      Current : FB_Current := (others => 0);
   end record;

end Framebuffer_ILI9341;
