#include <stdint.h>
#include <stdbool.h>
//math functions
#include <math.h>
#include "inc/hw_memmap.h"
#include "inc/hw_types.h"
//for floating points
#include "driverlib/fpu.h"
#include "driverlib/sysctl.h"
//access to ROM
#define TARGET_IS_BLIZZARD_RB1
#include "driverlib/rom.h"

//value of pi
#ifndef M_PI
#define M_PI                    3.14159265358979323846
#endif

//100 calcs
#define SERIES_LENGTH 100
//holds data
float gSeriesData[SERIES_LENGTH];
//start count
int32_t i32DataCount = 0;

int main(void)
{
    //holds 2 pi
    float fRadians;
    //enable lazy stack
    ROM_FPULazyStackingEnable();
    //enable fpu
    ROM_FPUEnable();
    //clock to 50 MHz
    ROM_SysCtlClockSet(SYSCTL_SYSDIV_4 | SYSCTL_USE_PLL | SYSCTL_XTAL_16MHZ | SYSCTL_OSC_MAIN);

    fRadians = ((2 * M_PI) / SERIES_LENGTH);

    while(i32DataCount < SERIES_LENGTH)
    {
        //calc sine value
        gSeriesData[i32DataCount] = sinf(fRadians * i32DataCount);
        //increment count (get new sine value)
        i32DataCount++;
    }

    while(1){}
}
