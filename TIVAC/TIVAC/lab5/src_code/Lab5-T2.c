#include <stdint.h>
#include <stdbool.h>
#include "inc/hw_memmap.h"
#include "inc/hw_types.h"
#include "inc/tm4c123gh6pm.h"
#include "driverlib/debug.h"
#include "driverlib/sysctl.h"
#include "driverlib/adc.h"
#define TARGET_IS_BLIZZARD_RB1
#include "driverlib/rom.h"
#include "driverlib/gpio.h"
#include "driverlib/timer.h"
#include "driverlib/interrupt.h"

/*
#ifdef DEBUG
void_error_(char *pcFilename, uint32_t ui32Line){}
#endif
*/

//my variables
uint32_t ui32ADC0Value[4];
volatile uint32_t ui32TempAvg;
volatile uint32_t ui32TempValueC;
volatile uint32_t ui32TempValueF;

int main(void)
{
    ROM_SysCtlClockSet(SYSCTL_SYSDIV_5|SYSCTL_USE_PLL|SYSCTL_XTAL_16MHZ|SYSCTL_OSC_MAIN);

    ROM_SysCtlPeripheralEnable(SYSCTL_PERIPH_ADC0);

    ROM_SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);
    ROM_GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3);

    ROM_ADCHardwareOversampleConfigure(ADC0_BASE, 32);

    //step up adc sequencer 2
    ROM_ADCSequenceConfigure(ADC0_BASE, 1, ADC_TRIGGER_PROCESSOR, 0);
    ROM_ADCSequenceStepConfigure(ADC0_BASE, 1, 0, ADC_CTL_TS);
    ROM_ADCSequenceStepConfigure(ADC0_BASE, 1, 1, ADC_CTL_TS);
    ROM_ADCSequenceStepConfigure(ADC0_BASE, 1, 2, ADC_CTL_TS);
    ROM_ADCSequenceStepConfigure(ADC0_BASE, 1, 3, ADC_CTL_TS|ADC_CTL_IE|ADC_CTL_END);
    ROM_ADCSequenceEnable(ADC0_BASE, 1);
    //enable timer1
    ROM_SysCtlPeripheralEnable(SYSCTL_PERIPH_TIMER1);
    //config timer 1 for overflow every half second
    ROM_TimerConfigure(TIMER1_BASE, TIMER_CFG_PERIODIC);
    ROM_TimerLoadSet(TIMER1_BASE, TIMER_A, (SysCtlClockGet()/2)-1);
    //enable interrupt and timer 1
    ROM_TimerEnable(TIMER1_BASE, TIMER_A);
    ROM_IntEnable(INT_TIMER1A);
    ROM_TimerIntEnable(TIMER1_BASE, TIMER_TIMA_TIMEOUT);
    //enable masters
    IntMasterEnable();

    while(1){}

}

void Timer1IntHandler(void)
{
    //clear timer interrupt
    ROM_TimerIntClear(TIMER1_BASE, TIMER_TIMA_TIMEOUT);

    //clear adc interrupt and set processor trig to 2
    ROM_ADCIntClear(ADC0_BASE, 1);
    ROM_ADCProcessorTrigger(ADC0_BASE, 1);
    // continue to loop while calculations are taking place
    while(!ROM_ADCIntStatus(ADC0_BASE, 1, false)){}
    // here we grab all the adc data and calculate the C and F
    ROM_ADCSequenceDataGet(ADC0_BASE, 1, ui32ADC0Value);
    ui32TempAvg = (ui32ADC0Value[0]+ui32ADC0Value[1]+ui32ADC0Value[2]+ui32ADC0Value[3] + 2)/4;
    ui32TempValueC = (1475 - ((2475 * ui32TempAvg)) / 4096) / 10;
    ui32TempValueF = ((ui32TempValueC * 9) + 160) / 5;
    // i picked 62 because I could only get the temp up to 64 but
    // still wanted to show LED turn on and it always initialized at 62
    if(ui32TempValueF > 64){GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, 4);}
    else{GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3, 0);}
}
