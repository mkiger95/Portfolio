/*
 * Morgan Kiger - 5002411760
 */

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include "inc/tm4c123gh6pm.h"
#include "inc/hw_memmap.h"
#include "inc/hw_types.h"
#include "driverlib/sysctl.h"
#include "driverlib/interrupt.h"
#include "driverlib/gpio.h"
#include "driverlib/timer.h"

void buttonDown(void);
void buttonUp(void);

int main(void)
{
    uint32_t ui32Period;
    double my_duty = 1.33;

    // configure the system clock
    SysCtlClockSet(SYSCTL_SYSDIV_5|SYSCTL_USE_PLL|SYSCTL_XTAL_16MHZ|SYSCTL_OSC_MAIN);
    // enable periphery and set pins 1-3 for output
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3);
    // enable Timer 0
    SysCtlPeripheralEnable(SYSCTL_PERIPH_TIMER0);
    TimerConfigure(TIMER0_BASE, TIMER_CFG_PERIODIC);
    // PF4 as input
    GPIOPinTypeGPIOInput(GPIO_PORTF_BASE, GPIO_PIN_4);
    // Enable weak pullup resistor
    GPIOPadConfigSet(GPIO_PORTF_BASE, GPIO_PIN_4, GPIO_STRENGTH_2MA, GPIO_PIN_TYPE_STD_WPU);

    // Interrupt setup

    // Disable interrupt for PF4
    GPIOIntDisable(GPIO_PORTF_BASE, GPIO_PIN_4);
    // Clear pending interrupts
    GPIOIntClear(GPIO_PORTF_BASE, GPIO_PIN_4);
    // Register our handler function
    GPIOIntRegister(GPIO_PORTF_BASE, buttonDown);
    // Configure PF4 for falling edge trigger
    GPIOIntTypeSet(GPIO_PORTF_BASE, GPIO_PIN_4, GPIO_FALLING_EDGE);
    // Enable interrupt
    GPIOIntEnable(GPIO_PORTF_BASE, GPIO_PIN_4);

    IntEnable(INT_GPIOF);

    // compute the period
    ui32Period = (SysCtlClockGet() / 10) / my_duty;
    TimerLoadSet(TIMER0_BASE, TIMER_A, ui32Period -1);
    // enable interrupt
    IntEnable(INT_TIMER0A);
    TimerIntEnable(TIMER0_BASE, TIMER_TIMA_TIMEOUT);
    IntMasterEnable();
    // enable Timer 0
    TimerEnable(TIMER0_BASE, TIMER_A);

    while(1)
    {
    }
}


void buttonDown(void)
{
    if (GPIOIntStatus(GPIO_PORTF_BASE, false) & GPIO_PIN_4)
    {
        // PF4 was interrupt cause
        printf("Button Pressed Down\n");
        // Register for port F
        GPIOIntRegister(GPIO_PORTF_BASE, buttonUp);
        // Configure for rising edge trigger
        GPIOIntTypeSet(GPIO_PORTF_BASE, GPIO_PIN_4, GPIO_RISING_EDGE);
        // clear interuppt flag
        GPIOIntClear(GPIO_PORTF_BASE, GPIO_PIN_4);
    }
}

void buttonUp(void)
{
    if (GPIOIntStatus(GPIO_PORTF_BASE, false) & GPIO_PIN_4)
    {
        // PF4 was interrupt cause
        printf("Button Pressed Up\n");
        // Register for port F
        GPIOIntRegister(GPIO_PORTF_BASE, buttonUp);
        // Configure for rising edge trigger
        GPIOIntTypeSet(GPIO_PORTF_BASE, GPIO_PIN_4, GPIO_FALLING_EDGE);
        // clear interuppt flag
        GPIOIntClear(GPIO_PORTF_BASE, GPIO_PIN_4);
    }
}

void PortFPin0IntHandler(void)
{
    // Clear the GPIO interrupt
    GPIOIntClear(GPIO_PORTF_BASE, GPIO_INT_PIN_0);

    if (GPIOIntStatus(GPIO_PORTF_BASE, false) & GPIO_PIN_4)
    {
        // PF4 was interrupt cause
        printf("Button Pressed Down\n");
        // Register for port F
        GPIOIntRegister(GPIO_PORTF_BASE, buttonUp);
        // Configure for rising edge trigger
        GPIOIntTypeSet(GPIO_PORTF_BASE, GPIO_PIN_4, GPIO_RISING_EDGE);
        // clear interuppt flag
        GPIOIntClear(GPIO_PORTF_BASE, GPIO_PIN_4);
    }

    if (GPIOIntStatus(GPIO_PORTF_BASE, false) & GPIO_PIN_4)
    {
        // PF4 was interrupt cause
        printf("Button Pressed Up\n");
        // Register for port F
        GPIOIntRegister(GPIO_PORTF_BASE, buttonUp);
        // Configure for rising edge trigger
        GPIOIntTypeSet(GPIO_PORTF_BASE, GPIO_PIN_4, GPIO_FALLING_EDGE);
        // clear interuppt flag
        GPIOIntClear(GPIO_PORTF_BASE, GPIO_PIN_4);
    }

    if(GPIOPinRead(GPIO_PORTF_BASE, GPIO_PIN_2))
    {
        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, 0);
    }
    else
    {
        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_2, 4);
    }
}

void Timer0IntHandler(void)
{

    // Clear the timer interrupt
    TimerIntClear(TIMER0_BASE, TIMER_TIMA_TIMEOUT);

    // Read the current state of the GPIO pin and
    // write back the opposite state
    if(GPIOPinRead(GPIO_PORTF_BASE, GPIO_PIN_2))
    {
        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, 0);
    }
    else
    {
        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_2, 4);
    }

}
