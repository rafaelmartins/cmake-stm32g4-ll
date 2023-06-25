/*
 * SPDX-FileCopyrightText: 2023 Rafael G. Martins <rafael@rafaelmartins.eng.br>
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <stm32g4xx_ll_cortex.h>
#include <stm32g4xx_ll_bus.h>
#include <stm32g4xx_ll_gpio.h>
#include <stm32g4xx_ll_pwr.h>
#include <stm32g4xx_ll_rcc.h>
#include <stm32g4xx_ll_system.h>
#include <stm32g4xx_ll_utils.h>


void
SysTick_Handler(void)
{
    static int counter = 0;
    if ((++counter % 1000) == 0)
        LL_GPIO_TogglePin(GPIOB, LL_GPIO_PIN_8);
}


void
clock_init(void)
{
    LL_FLASH_SetLatency(LL_FLASH_LATENCY_4);
    while(LL_FLASH_GetLatency() != LL_FLASH_LATENCY_4);

    LL_PWR_EnableRange1BoostMode();

#ifndef USE_HSI
    LL_RCC_HSE_Enable();
    while(LL_RCC_HSE_IsReady() != 1);
#else
    LL_RCC_HSI_Enable();
    while(LL_RCC_HSI_IsReady() != 1);

    LL_RCC_HSI_SetCalibTrimming(64);
#endif

    LL_RCC_HSI48_Enable();
    while(LL_RCC_HSI48_IsReady() != 1);

    LL_RCC_PLL_ConfigDomain_SYS(
#ifndef USE_HSI
        LL_RCC_PLLSOURCE_HSE, LL_RCC_PLLM_DIV_6,
#else
        LL_RCC_PLLSOURCE_HSI, LL_RCC_PLLM_DIV_4,
#endif
        85, LL_RCC_PLLR_DIV_2);
    LL_RCC_PLL_EnableDomain_SYS();
    LL_RCC_PLL_Enable();
    while(LL_RCC_PLL_IsReady() != 1);

    LL_RCC_SetSysClkSource(LL_RCC_SYS_CLKSOURCE_PLL);
    LL_RCC_SetAHBPrescaler(LL_RCC_SYSCLK_DIV_2);
    while(LL_RCC_GetSysClkSource() != LL_RCC_SYS_CLKSOURCE_STATUS_PLL);

    for (__IO uint32_t i = (170 >> 1); i != 0; i--);

    LL_RCC_SetAHBPrescaler(LL_RCC_SYSCLK_DIV_1);
    LL_RCC_SetAPB1Prescaler(LL_RCC_APB1_DIV_1);
    LL_RCC_SetAPB2Prescaler(LL_RCC_APB2_DIV_1);

    LL_Init1msTick(170000000);
    LL_SetSystemCoreClock(170000000);
}


int
main(void)
{
    NVIC_SetPriorityGrouping(0x03U);

    clock_init();

    LL_AHB2_GRP1_EnableClock(LL_AHB2_GRP1_PERIPH_GPIOB);

    LL_GPIO_InitTypeDef GPIO_InitStruct = {
        .Pin = LL_GPIO_PIN_8,
        .Mode = LL_GPIO_MODE_OUTPUT,
        .Speed = LL_GPIO_SPEED_FREQ_LOW,
        .OutputType = LL_GPIO_OUTPUT_PUSHPULL,
    };
    LL_GPIO_Init(GPIOB, &GPIO_InitStruct);

    SysTick_Config(SystemCoreClock / 1000);

    while (1);

    return 0;
}
