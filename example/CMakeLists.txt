# SPDX-FileCopyrightText: 2023 Rafael G. Martins <rafael@rafaelmartins.eng.br>
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.17)

include(../cmake/stm32g4-ll.cmake)

project(example C ASM)

add_executable(example
    main.c
)

target_link_libraries(example PRIVATE
    stm32g4_ll_gpio
    stm32g4_ll_rcc
    stm32g4_ll_utils
)

target_compile_definitions(example PRIVATE
    USE_HSI=1
)

target_compile_options(example PRIVATE
    -Wall
    -Wextra
    -Werror
)

set_property(TARGET example
    PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE
)

stm32g4_target_set_mcu(example stm32g431kb)
stm32g4_target_generate_map(example)
stm32g4_target_generate_ihex(example)
stm32g4_target_generate_dfu(example)
stm32g4_target_show_size(example)
stm32g4_target_set_linker_script(example ${CMAKE_CURRENT_SOURCE_DIR}/STM32G431KBTx_FLASH.ld)
stm32g4_target_set_hsi_clock(example 16000000)
stm43g4_add_st_flash_target(example)
