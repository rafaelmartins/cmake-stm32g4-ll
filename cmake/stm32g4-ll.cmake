# SPDX-FileCopyrightText: 2023 Rafael G. Martins <rafael@rafaelmartins.eng.br>
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.17)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/stm32-gcc.cmake")

function(stm32g4_target_set_mcu target mcu)
    if(TARGET _stm32g4_target_set_mcu_${target})
        message(WARNING "stm32g4_target_set_mcu(${target}) already called, ignoring.")
        return()
    endif()
    add_library(_stm32g4_target_set_mcu_${target} INTERFACE)

    string(SUBSTRING ${mcu} 0 9 mcu_prefix)
    string(TOLOWER ${mcu_prefix} mcu_lower)
    string(TOUPPER ${mcu_prefix} mcu_upper)

    if(NOT ${mcu_lower} MATCHES "^stm32g4(a1|31|41|71|73|74|83|84|91)$")
        message(FATAL_ERROR "Unsupported STM32G4 microcontroller: ${mcu}")
    endif()

    target_sources(${target} PRIVATE
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../vendor/cmsis_device_g4/src/startup_${mcu_lower}xx.s
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../vendor/cmsis_device_g4/src/system_stm32g4xx.c
    )

    target_compile_definitions(${target} PRIVATE
        ${mcu_upper}xx=1
    )
endfunction()

function(stm32g4_target_generate_map target)
    if(TARGET _stm32g4_target_generate_map_${target})
        message(WARNING "stm32g4_target_generate_map(${target}) already called, ignoring.")
        return()
    endif()
    add_library(_stm32g4_target_generate_map_${target} INTERFACE)

    target_link_options(${target} PRIVATE
        "-Wl,-Map,$<TARGET_FILE:${target}>.map"
    )

    set_property(TARGET ${target}
        APPEND
        PROPERTY ADDITIONAL_CLEAN_FILES "$<TARGET_FILE:${target}>.map"
    )
endfunction()

function(stm32g4_target_generate_ihex target)
    if(TARGET ${target}-ihex)
        message(WARNING "stm32g4_target_generate_ihex(${target}) already called, ignoring.")
        return()
    endif()

    add_custom_command(
        OUTPUT ${target}.hex
        COMMAND ${ARM_OBJCOPY} -O ihex $<TARGET_FILE:${target}> ${target}.hex
        DEPENDS $<TARGET_FILE:${target}>
    )

    add_custom_target(${target}-ihex
        ALL
        DEPENDS ${target}.hex
    )
endfunction()

function(stm32g4_target_show_size target)
    if(TARGET _stm32g4_target_show_size_${target})
        message(WARNING "stm32g4_target_show_size(${target}) already called, ignoring.")
        return()
    endif()
    add_library(_stm32g4_target_show_size_${target} INTERFACE)

    add_custom_command(
        TARGET ${target}
        POST_BUILD
        COMMAND ${ARM_SIZE} --format=berkeley "$<TARGET_FILE:${target}>"
    )
endfunction()

function(stm32g4_target_set_linker_script target script)
    if(TARGET _stm32g4_target_set_linker_script_${target})
        message(WARNING "stm32g4_target_set_linker_script(${target}) already called, ignoring.")
        return()
    endif()
    add_library(_stm32g4_target_set_linker_script_${target} INTERFACE)

    target_link_options(${target} PRIVATE
        "-T${script}"
    )
endfunction()

function(stm32g4_target_set_lse_clock target frequency timeout)
    if(TARGET _stm32g4_target_set_lse_clock_${target})
        message(WARNING "stm32g4_target_set_lse_clock(${target}) already called, ignoring.")
        return()
    endif()
    add_library(_stm32g4_target_set_lse_clock_${target} INTERFACE)

    target_compile_definitions(${target} PRIVATE
        LSE_VALUE=${frequency}
        LSE_STARTUP_TIMEOUT=${timeout}
    )
endfunction()

function(stm32g4_target_set_hse_clock target frequency timeout)
    if(TARGET _stm32g4_target_set_hse_clock_${target})
        message(WARNING "stm32g4_target_set_hse_clock(${target}) already called, ignoring.")
        return()
    endif()
    add_library(_stm32g4_target_set_hse_clock_${target} INTERFACE)

    target_compile_definitions(${target} PRIVATE
        HSE_VALUE=${frequency}
        HSE_STARTUP_TIMEOUT=${timeout}
    )
endfunction()

function(stm32g4_target_set_lsi_clock target frequency)
    if(TARGET _stm32g4_target_set_lsi_clock_${target})
        message(WARNING "stm32g4_target_set_lsi_clock(${target}) already called, ignoring.")
        return()
    endif()
    add_library(_stm32g4_target_set_lsi_clock_${target} INTERFACE)

    target_compile_definitions(${target} PRIVATE
        LSI_VALUE=${frequency}
    )
endfunction()

function(stm32g4_target_set_hsi_clock target frequency)
    if(TARGET _stm32g4_target_set_hsi_clock_${target})
        message(WARNING "stm32g4_target_set_hsi_clock(${target}) already called, ignoring.")
        return()
    endif()
    add_library(_stm32g4_target_set_hsi_clock_${target} INTERFACE)

    target_compile_definitions(${target} PRIVATE
        HSI_VALUE=${frequency}
    )
endfunction()

if(NOT TARGET stm32g4)
    add_library(stm32g4 INTERFACE)

    target_include_directories(stm32g4 INTERFACE
        ${CMAKE_CURRENT_LIST_DIR}/../vendor/cmsis_core/include
        ${CMAKE_CURRENT_LIST_DIR}/../vendor/cmsis_device_g4/include
        ${CMAKE_CURRENT_LIST_DIR}/../vendor/ll_drivers/include
    )

    target_compile_definitions(stm32g4 INTERFACE
        USE_FULL_LL_DRIVER=1
        STM32G4=1
        STM32G4xx=1
    )

    target_compile_options(stm32g4 INTERFACE
        -mcpu=cortex-m4
        -mthumb
        -mfpu=fpv4-sp-d16
        -mfloat-abi=hard
    )

    target_link_options(stm32g4 INTERFACE
        -mcpu=cortex-m4
        -mthumb
        -mfpu=fpv4-sp-d16
        -mfloat-abi=hard
        -specs=nano.specs
        -Wl,--gc-sections
        -Wl,--no-warn-rwx-segments
    )
endif()

foreach(driver adc comp cordic crc crs dac dma exti fmac gpio hrtim i2c
        lptim lpuart opamp pwr rcc rnc rtc spi tim ucpd usart utils)
    if(TARGET stm32g4_ll_${driver})
        continue()
    endif()

    add_library(stm32g4_ll_${driver} INTERFACE)

    target_sources(stm32g4_ll_${driver} INTERFACE
        ${CMAKE_CURRENT_LIST_DIR}/../vendor/ll_drivers/src/stm32g4xx_ll_${driver}.c
    )

    target_link_libraries(stm32g4_ll_${driver} INTERFACE
        stm32g4
    )
endforeach()
