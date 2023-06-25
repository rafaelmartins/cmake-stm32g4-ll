# SPDX-FileCopyrightText: 2023 Rafael G. Martins <rafael@rafaelmartins.eng.br>
# SPDX-License-Identifier: BSD-3-Clause

set(CMAKE_ASM_COMPILER_FORCED ON)
set(CMAKE_C_COMPILER_FORCED   ON)
set(CMAKE_CXX_COMPILER_FORCED ON)

set(CMAKE_SYSTEM_NAME      Generic-ELF)
set(CMAKE_SYSTEM_PROCESSOR arm-none-eabi)
set(CMAKE_ASM_COMPILER     arm-none-eabi-gcc)
set(CMAKE_C_COMPILER       arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER     arm-none-eabi-g++)

find_program(ARM_SIZE    arm-none-eabi-size    REQUIRED)
find_program(ARM_OBJCOPY arm-none-eabi-objcopy REQUIRED)
find_program(ARM_OBJDUMP arm-none-eabi-objdump REQUIRED)

# as the elf is not transferred directly to the microncontroller, we can always have debug symbols included
set(CMAKE_ASM_FLAGS_INIT "-ggdb3 -fdata-sections -ffunction-sections")
set(CMAKE_C_FLAGS_INIT   "-ggdb3 -fdata-sections -ffunction-sections")
set(CMAKE_CXX_FLAGS_INIT "-ggdb3 -fdata-sections -ffunction-sections")

set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
