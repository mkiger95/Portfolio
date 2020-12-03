/*
 * Morgan Kiger - 5002411760 - Lab 3
 */

#include <stdint.h>
#include <stdbool.h>
#include "inc/hw_memmap.h"
#include "inc/hw_types.h"
#include "driverlib/sysctl.h"
#include "driverlib/gpio.h"

uint8_t ui8PinData=2;
double divisor = 7.059;

int main(void)
{
    SysCtlClockSet(SYSCTL_SYSDIV_5|SYSCTL_USE_PLL|SYSCTL_XTAL_16MHZ|SYSCTL_OSC_MAIN);

    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3);

    while(1)
    {
        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, ui8PinData);

        // store delay in variable for debugging
        uint32_t my_delay = SysCtlClockGet()/divisor;
        // change delay to what we calculated
        SysCtlDelay(SysCtlClockGet()/divisor);

        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, 0x00);

        // change delay to what we calculated
        SysCtlDelay(SysCtlClockGet()/divisor);

        if(ui8PinData==8)
        {
            ui8PinData=2;
        }
        else
        {
            ui8PinData=ui8PinData*2;
        }
    }
}
