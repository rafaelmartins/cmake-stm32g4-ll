#!/bin/bash

set -e -o pipefail

STM32CUBEG4_VERSION="v1.5.1"

REPODIR="$(mktemp -d)"
trap 'rm -rf "${REPODIR}"' EXIT

git clone \
    -c advice.detachedHead=false \
    --depth=1 \
    --branch="${STM32CUBEG4_VERSION}" \
    https://github.com/STMicroelectronics/STM32CubeG4.git \
    "${REPODIR}"

rm -rf ./vendor/
mkdir -p ./vendor/{cmsis_core,cmsis_device_g4}
mkdir -p ./vendor/ll_drivers/{src,include}

wget \
    --output-document=./vendor/ll_drivers/LICENSE \
    https://raw.githubusercontent.com/STMicroelectronics/stm32g4xx_hal_driver/master/LICENSE.md

cp \
    --verbose \
    "${REPODIR}"/Drivers/CMSIS/LICENSE.txt \
    ./vendor/cmsis_core/LICENSE

cp \
    --verbose \
    "${REPODIR}"/Drivers/CMSIS/LICENSE.txt \
    ./vendor/cmsis_device_g4/LICENSE

cp \
    --recursive \
    --verbose \
    "${REPODIR}"/Drivers/CMSIS/Core/Include \
    ./vendor/cmsis_core/include

cp \
    --recursive \
    --verbose \
    "${REPODIR}"/Drivers/CMSIS/Device/ST/STM32G4xx/Include \
    ./vendor/cmsis_device_g4/include

cp \
    --recursive \
    --verbose \
    "${REPODIR}"/Drivers/CMSIS/Device/ST/STM32G4xx/Source/Templates/gcc \
    ./vendor/cmsis_device_g4/src

cp \
    --verbose \
    "${REPODIR}"/Drivers/CMSIS/Device/ST/STM32G4xx/Source/Templates/system_stm32g4xx.c \
    ./vendor/cmsis_device_g4/src/

cp \
    --recursive \
    --verbose \
    "${REPODIR}"/Drivers/STM32G4xx_HAL_Driver/Inc/stm32g4xx_ll_* \
    ./vendor/ll_drivers/include/

cp \
    --recursive \
    --verbose \
    "${REPODIR}"/Drivers/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_* \
    ./vendor/ll_drivers/src/

# FMC and USB drivers depend on HAL
rm \
    --verbose \
    ./vendor/ll_drivers/{src,include}/*_{fmc,usb}.*
