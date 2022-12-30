# FanWith8051Assembly
A program be written in assembly language for a fan
 The desired features of the fan are as follows:
- The fan should be able to turn on and off at any time according to the information coming from the serial 
port. For example; When the 'A' character is received, the fan can be turned on and when 'K' is received, it 
can be turned off. The fan should be set to default values when a shutdown request is made. (Note: Use 
interrupt for serial port.)
- When the fan operates, the fan should rotate at a default speed, and the speed of the fan should be adjusted 
with a button that can change the speed in 3 stages (For example: 1st stage can be adjusted at 30% speed, 
2nd stage at 60% speed, and 3rd stage at 90% speed.)
- Timer setting is also provided by a button and each press of the button must start the countdown timer in 30 
minute increments and the fan must be turned off when the timer resets. (It can be set to a maximum of 120 
minutes and if the button is pressed again while the time-set is at 120 minutes, the timer should be cancelled.)
- As a motor, you can use the stepper motor application 
