/*
 * Morgan Kiger - 5002411760 - Lab 3
 */

#include <stdint.h>
#include <stdbool.h>
#include "inc/hw_memmap.h"
#include "inc/hw_types.h"
#include "driverlib/sysctl.h"
#include "driverlib/gpio.h"

// stores LED pin data
uint8_t ui8PinData;

// LED array for R, G, B, RG, RB, GB, RGB
uint8_t array[7]={2,8,4,10,6,12,14};

double divisor = 7.059;
uint8_t i;

int main(void)
{
    SysCtlClockSet(SYSCTL_SYSDIV_5|SYSCTL_USE_PLL|SYSCTL_XTAL_16MHZ|SYSCTL_OSC_MAIN);

    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3);

    while(1)
    {
        for(i=0; i<7; i++)
        {
            GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, ui8PinData);

            // store delay in variable for debugging
            uint32_t my_delay = SysCtlClockGet()/divisor;
            // change delay to what we calculated
            SysCtlDelay(SysCtlClockGet()/divisor);

            GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, 0x00);

            // change delay to what we calculated
            SysCtlDelay(SysCtlClockGet()/divisor);;

            // assign pin values through predefined array for LED colors
            ui8PinData = array[i];
        }
    }
}
