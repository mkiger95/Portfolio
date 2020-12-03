#include <stdint.h>
#include <stdbool.h>
#include "inc/hw_ints.h"
#include "inc/hw_memmap.h"
#include "inc/hw_types.h"
#include "driverlib/gpio.h"
#include "driverlib/interrupt.h"
#include "driverlib/pin_map.h"
#include "driverlib/sysctl.h"
#include "driverlib/uart.h"
#include "driverlib/adc.h"
#include "driverlib/timer.h"
#include "string.h"

uint32_t ui32ADC0Value[4];
volatile uint32_t ui32TempAvg;
volatile uint32_t ui32TempValueC;
volatile uint32_t ui32TempValueF;

char temp[10];

void UARTIntHandler(void)
{
    uint32_t ui32Status;

    ui32Status = UARTIntStatus(UART0_BASE, true); //get interrupt status

    UARTIntClear(UART0_BASE, ui32Status); //clear the asserted interrupts

    if(UARTCharsAvail(UART0_BASE)) //loop while there are chars
    {
        char user_input = UARTCharGet(UART0_BASE);
        UARTCharPut(UART0_BASE, user_input);
        printMessage("\r\n");

        // clear ADC interrupt and set processor trigger to sequence 2
                ADCIntClear(ADC0_BASE, 2);
                ADCProcessorTrigger(ADC0_BASE, 2);

                // while busy, keep looping
                while(!ADCIntStatus(ADC0_BASE, 2, false))
                {}

                // grab ADC data and compute the avg value and temps for F and C
                ADCSequenceDataGet(ADC0_BASE, 2, ui32ADC0Value);
                ui32TempAvg = (ui32ADC0Value[0] + ui32ADC0Value[1] + ui32ADC0Value[2] + ui32ADC0Value[3] + 2)/4;
                ui32TempValueC = (1475 - ((2475 * ui32TempAvg)) / 4096)/10;
                ui32TempValueF = ((ui32TempValueC * 9) + 160) / 5;

                    // turn on RED LED
                    if(user_input == 'R')
                    {
                        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, GPIO_PIN_1);
                        printMessage("Red LED has been turned on.");
                        printMessage("\r\n");
                    }

                    // if capital R is pressed, turn off RED LED
                    if(user_input == 'r')
                    {
                        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, !GPIO_PIN_1);
                        printMessage("Red LED has been turned off");
                        printMessage("\r\n");
                    }

                    // if capital G is pressed, turn on GREEN LED
                    if(user_input == 'G')
                    {
                        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, GPIO_PIN_3);
                        printMessage("Green LED has been turned on");
                        printMessage("\r\n");
                    }

                    // if capital G is pressed, turn off GREEN LED
                    if(user_input == 'g')
                    {
                        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, !GPIO_PIN_3);
                        printMessage("Green LED has been turned off");
                        printMessage("\r\n");
                    }

                    // if capital B is pressed, turn on BLUE LED
                    if(user_input == 'B')
                    {
                        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, GPIO_PIN_2);
                        printMessage("Blue LED has been turned on");
                        printMessage("\r\n");
                    }

                    // if capital B is pressed, turn off BLUE LED
                    if(user_input == 'b')
                    {
                        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, !GPIO_PIN_2);
                        printMessage("Blue LED has been turned off");
                        printMessage("\r\n");
                    }

                    // if capital T is pressed
                    if(user_input == 'T')
                    {
                        // indicate temperature command
                        printMessage("Temperature (F): ");
                        // convert integer to string
                        itoa(ui32TempValueF, temp);
                        // print temperature value
                        printMessage(temp);
                        printMessage("\r\n");
                    }

                }
}


int main(void) {

    SysCtlClockSet(SYSCTL_SYSDIV_4 | SYSCTL_USE_PLL | SYSCTL_OSC_MAIN | SYSCTL_XTAL_16MHZ);

    SysCtlPeripheralEnable(SYSCTL_PERIPH_UART0);
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOA);

    GPIOPinConfigure(GPIO_PA0_U0RX);
    GPIOPinConfigure(GPIO_PA1_U0TX);
    GPIOPinTypeUART(GPIO_PORTA_BASE, GPIO_PIN_0 | GPIO_PIN_1);

    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF); //enable GPIO port for LED
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_1 | GPIO_PIN_2 | GPIO_PIN_3); //enable pin for LED PF2

    UARTConfigSetExpClk(UART0_BASE, SysCtlClockGet(), 115200,
        (UART_CONFIG_WLEN_8 | UART_CONFIG_STOP_ONE | UART_CONFIG_PAR_NONE));

    IntMasterEnable(); //enable processor interrupts
    IntEnable(INT_UART0); //enable the UART interrupt
    UARTIntEnable(UART0_BASE, UART_INT_RX | UART_INT_RT); //only enable RX and TX interrupts

    SysCtlPeripheralEnable(SYSCTL_PERIPH_ADC0);

    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3);

    //ADC Sample
    ADCHardwareOversampleConfigure(ADC0_BASE, 64);

    //Configure the ADC sequencer
    ADCSequenceConfigure(ADC0_BASE, 3, ADC_TRIGGER_PROCESSOR, 0);

    //Configure the ADC sequence
    ADCSequenceStepConfigure(ADC0_BASE, 2, 0, ADC_CTL_TS);
    ADCSequenceStepConfigure(ADC0_BASE, 2, 1, ADC_CTL_TS);
    ADCSequenceStepConfigure(ADC0_BASE, 2, 2, ADC_CTL_TS);
    //Sample the temp
    ADCSequenceStepConfigure(ADC0_BASE, 2, 3, ADC_CTL_TS|ADC_CTL_IE|ADC_CTL_END);

    //Enable the Sequencer
    ADCSequenceEnable(ADC0_BASE, 2);

    printMessage("UART and LED Demo");
    printMessage("\r\n");
    printMessage("R: turn on RED LED | r: turn off RED LED");
    printMessage("\r\n");
    printMessage("B:turn on BLUE LED | b: turn off BLUE LED");
    printMessage("\r\n");
    printMessage("G: turn on GREEN LED | g: turn off GREEN LED");
    printMessage("\r\n");
    printMessage("T: return temperature");
    printMessage("\r\n");

    while(1)
    {
        //if (UARTCharsAvail(UART0_BASE)) UARTCharPut(UART0_BASE, UARTCharGet(UART0_BASE));
    }

}

void printMessage(char *str)
{
    while(*str != '\0')
    {
        UARTCharPut(UART0_BASE,*str);
        ++str;
    }
}

void helper(char s[])
{
    int i, j;
    char c;

    for (i = 0, j = strlen(s)-1; i<j; i++, j--)
    {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}

void itoa(int n, char s[])
{
    int i, sign;

    if ((sign = n) < 0)
    {
        n = -n;
    }
    i = 0;
    do
    {
        s[i++] = n % 10 + '0';
    }
    while ((n /= 10) > 0);

    if (sign < 0)
    {
        s[i++] = '-';
    }

    s[i] = '\0';
    helper(s);
}
