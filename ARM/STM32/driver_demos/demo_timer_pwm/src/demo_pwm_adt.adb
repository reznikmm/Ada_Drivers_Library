------------------------------------------------------------------------------
--                                                                          --
--                    Copyright (C) 2016, AdaCore                           --
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
--     3. Neither the name of STMicroelectronics nor the names of its       --
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

--  This demonstration illustrates the use of PWM to control the brightness of
--  an LED. The effect is to make the LED increase and decrease in brightness,
--  iteratively, for as long as the application runs. In effect the LED light
--  waxes and wanes. See http://visualgdb.com/tutorials/arm/stm32/fpu/ for the
--  inspiration.
--
--  The demo uses an abstract data type PWM_Modulator to control the power to
--  the LED via pulse-width-modulation. A timer is still used underneath, but
--  the details are hidden.  For direct use of the timer see the other demo.

with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);

with STM32.Board;  use STM32.Board;
with STM32.Device; use STM32.Device;
with STM32.PWM;    use STM32.PWM;
with STM32.GPIO;   use STM32.GPIO;
with STM32.Timers; use STM32.Timers;

procedure Demo_PWM_ADT is  -- demo the higher-level PWM abstract data type

   PWM_Timer : STM32.Timers.Timer renames Timer_4;
   --  NOT arbitrary!
   --  We drive the on-board LEDs that are tied to the channels of Timer_4.

   Timer_AF : constant STM32.GPIO_Alternate_Function := GPIO_AF_2_TIM4;
   --  Note that this value MUST match the corresponding timer selected!

   Output_Channel : constant Timer_Channel := Channel_2; -- arbitrary
   --  The LED driven by this example is determined by the channel selected.
   --  That is so because each channel of Timer_4 is connected to a specific
   --  LED in the alternate function configuration on this board. We will
   --  initialize all of the LEDs to be in the AF mode. The
   --  particular channel selected is completely arbitrary, as long as the
   --  selected GPIO port/pin for the LED matches the selected channel.
   --
   --  Channel_1 is connected to the green LED.
   --  Channel_2 is connected to the orange LED.
   --  Channel_3 is connected to the red LED.
   --  Channel_4 is connected to the blue LED.
   LED_For : constant array (Timer_Channel) of User_LED :=
               (Channel_1 => Green,
                Channel_2 => Orange,
                Channel_3 => Red,
                Channel_4 => Blue);

   Requested_Frequency : constant Hertz := 30_000;  -- arbitrary

   Power_Control : PWM_Modulator;

   procedure Configure_LEDs;
   --  initialize all of the LEDs to be in the AF mode

   --------------------
   -- Configure_LEDs --
   --------------------

   procedure Configure_LEDs is
      Configuration : GPIO_Port_Configuration;
   begin
      Enable_Clock (GPIO_D);

      Configuration.Mode        := Mode_AF;  -- essential
      Configuration.Output_Type := Push_Pull;
      Configuration.Speed       := Speed_50MHz;
      Configuration.Resistors   := Floating;

      Configure_IO (All_LEDs, Configuration);
   end Configure_LEDs;

   --  The SFP run-time library for these boards is intended for certified
   --  environments and so does not contain the full set of facilities defined
   --  by the Ada language. The elementary functions are not included, for
   --  example. In contrast, the Ravenscar "full" run-times do have these
   --  functions.
   function Sine (Input : Long_Float) return Long_Float;

   --  Therefore there are four choices: 1) use the "ravescar-full-stm32f4"
   --  runtime library, 2) pull the sources for the language-defined elementary
   --  function package into the board's run-time library and rebuild the
   --  run-time, 3) pull the sources for those packages into the source
   --  directory of your application and rebuild your application, or 4) roll
   --  your own approximation to the functions required by your application.

   --  In this demonstration we roll our own approximation to the sine function
   --  so that it doesn't matter which runtime library is used.

   function Sine (Input : Long_Float) return Long_Float is
      Pi : constant Long_Float := 3.14159_26535_89793_23846;
      X  : constant Long_Float := Long_Float'Remainder (Input, Pi * 2.0);
      B  : constant Long_Float := 4.0 / Pi;
      C  : constant Long_Float := (-4.0) / (Pi * Pi);
      Y  : constant Long_Float := B * X + C * X * abs (X);
      P  : constant Long_Float := 0.225;
   begin
      return P * (Y * abs (Y) - Y) + Y;
   end Sine;

   --  We use the sine function to drive the power applied to the LED, thereby
   --  making the LED increase and decrease in brightness. We attach the timer
   --  to the LED and then control how much power is supplied by changing the
   --  value of the timer's output compare register. The sine function drives
   --  that value, thus the waxing/waning effect.

begin
   Configure_LEDs;

   Initialize_PWM_Modulator
     (Power_Control,
      Generator => PWM_Timer'Access,
      Frequency => Requested_Frequency,
      Configure_Generator => True);

   Attach_PWM_Channel
     (Power_Control,
      Output_Channel,
      LED_For (Output_Channel),
      Timer_AF);

   Enable_PWM (Power_Control);

   declare
      Arg       : Long_Float := 0.0;
      Value     : Percentage;
      Increment : constant Long_Float := 0.00003;
      --  The Increment value controls the rate at which the brightness
      --  increases and decreases. The value is more or less arbitrary, but
      --  note that the effect of optimization is observable.
   begin
      loop
         Value := Percentage (50.0 * (1.0 + Sine (Arg)));
         Set_Duty_Cycle (Power_Control, Value);
         Arg := Arg + Increment;
      end loop;
   end;
end Demo_PWM_ADT;
