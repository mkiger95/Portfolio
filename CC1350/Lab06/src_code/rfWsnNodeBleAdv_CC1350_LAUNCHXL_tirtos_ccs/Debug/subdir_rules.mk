################################################################################
# Automatically-generated file. Do not edit!
################################################################################

SHELL = cmd.exe

# Each subdirectory must supply rules for building sources it contributes
CC1350_LAUNCHXL.obj: ../CC1350_LAUNCHXL.c $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: ARM Compiler'
	"C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/bin/armcl" -mv7M3 --code_state=16 --float_support=vfplib -me --include_path="C:/CCSWorkspace/ECG603/rfWsnNodeBleAdv_CC1350_LAUNCHXL_tirtos_ccs" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/boards/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/inc/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/controller/cc26xx/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common/cc13xx" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/osal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/posix/ccs" --include_path="C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/include" --define=BOARD_DISPLAY_USE_LCD=1 --define=FEATURE_BROADCASTER --define=FEATURE_ADVERTISER --define=CC13XX_LAUNCHXL --define=RF_MULTI_MODE --define=FEATURE_BLE_ADV --define=DeviceFamily_CC13X0 --define=CCFG_FORCE_VDDR_HH=0 -g --diag_warning=225 --diag_warning=255 --diag_wrap=off --display_error_number --gen_func_subsections=on --preproc_with_compile --preproc_dependency="CC1350_LAUNCHXL.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

CC1350_LAUNCHXL_fxns.obj: ../CC1350_LAUNCHXL_fxns.c $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: ARM Compiler'
	"C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/bin/armcl" -mv7M3 --code_state=16 --float_support=vfplib -me --include_path="C:/CCSWorkspace/ECG603/rfWsnNodeBleAdv_CC1350_LAUNCHXL_tirtos_ccs" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/boards/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/inc/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/controller/cc26xx/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common/cc13xx" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/osal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/posix/ccs" --include_path="C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/include" --define=BOARD_DISPLAY_USE_LCD=1 --define=FEATURE_BROADCASTER --define=FEATURE_ADVERTISER --define=CC13XX_LAUNCHXL --define=RF_MULTI_MODE --define=FEATURE_BLE_ADV --define=DeviceFamily_CC13X0 --define=CCFG_FORCE_VDDR_HH=0 -g --diag_warning=225 --diag_warning=255 --diag_wrap=off --display_error_number --gen_func_subsections=on --preproc_with_compile --preproc_dependency="CC1350_LAUNCHXL_fxns.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

NodeRadioTask.obj: ../NodeRadioTask.c $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: ARM Compiler'
	"C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/bin/armcl" -mv7M3 --code_state=16 --float_support=vfplib -me --include_path="C:/CCSWorkspace/ECG603/rfWsnNodeBleAdv_CC1350_LAUNCHXL_tirtos_ccs" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/boards/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/inc/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/controller/cc26xx/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common/cc13xx" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/osal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/posix/ccs" --include_path="C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/include" --define=BOARD_DISPLAY_USE_LCD=1 --define=FEATURE_BROADCASTER --define=FEATURE_ADVERTISER --define=CC13XX_LAUNCHXL --define=RF_MULTI_MODE --define=FEATURE_BLE_ADV --define=DeviceFamily_CC13X0 --define=CCFG_FORCE_VDDR_HH=0 -g --diag_warning=225 --diag_warning=255 --diag_wrap=off --display_error_number --gen_func_subsections=on --preproc_with_compile --preproc_dependency="NodeRadioTask.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

NodeTask.obj: ../NodeTask.c $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: ARM Compiler'
	"C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/bin/armcl" -mv7M3 --code_state=16 --float_support=vfplib -me --include_path="C:/CCSWorkspace/ECG603/rfWsnNodeBleAdv_CC1350_LAUNCHXL_tirtos_ccs" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/boards/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/inc/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/controller/cc26xx/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common/cc13xx" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/osal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/posix/ccs" --include_path="C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/include" --define=BOARD_DISPLAY_USE_LCD=1 --define=FEATURE_BROADCASTER --define=FEATURE_ADVERTISER --define=CC13XX_LAUNCHXL --define=RF_MULTI_MODE --define=FEATURE_BLE_ADV --define=DeviceFamily_CC13X0 --define=CCFG_FORCE_VDDR_HH=0 -g --diag_warning=225 --diag_warning=255 --diag_wrap=off --display_error_number --gen_func_subsections=on --preproc_with_compile --preproc_dependency="NodeTask.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

SceAdc.obj: ../SceAdc.c $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: ARM Compiler'
	"C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/bin/armcl" -mv7M3 --code_state=16 --float_support=vfplib -me --include_path="C:/CCSWorkspace/ECG603/rfWsnNodeBleAdv_CC1350_LAUNCHXL_tirtos_ccs" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/boards/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/inc/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/controller/cc26xx/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common/cc13xx" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/osal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/posix/ccs" --include_path="C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/include" --define=BOARD_DISPLAY_USE_LCD=1 --define=FEATURE_BROADCASTER --define=FEATURE_ADVERTISER --define=CC13XX_LAUNCHXL --define=RF_MULTI_MODE --define=FEATURE_BLE_ADV --define=DeviceFamily_CC13X0 --define=CCFG_FORCE_VDDR_HH=0 -g --diag_warning=225 --diag_warning=255 --diag_wrap=off --display_error_number --gen_func_subsections=on --preproc_with_compile --preproc_dependency="SceAdc.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

ccfg.obj: ../ccfg.c $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: ARM Compiler'
	"C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/bin/armcl" -mv7M3 --code_state=16 --float_support=vfplib -me --include_path="C:/CCSWorkspace/ECG603/rfWsnNodeBleAdv_CC1350_LAUNCHXL_tirtos_ccs" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/boards/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/inc/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/controller/cc26xx/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common/cc13xx" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/osal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/posix/ccs" --include_path="C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/include" --define=BOARD_DISPLAY_USE_LCD=1 --define=FEATURE_BROADCASTER --define=FEATURE_ADVERTISER --define=CC13XX_LAUNCHXL --define=RF_MULTI_MODE --define=FEATURE_BLE_ADV --define=DeviceFamily_CC13X0 --define=CCFG_FORCE_VDDR_HH=0 -g --diag_warning=225 --diag_warning=255 --diag_wrap=off --display_error_number --gen_func_subsections=on --preproc_with_compile --preproc_dependency="ccfg.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

rfWsnNode.obj: ../rfWsnNode.c $(GEN_OPTS) | $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: ARM Compiler'
	"C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/bin/armcl" -mv7M3 --code_state=16 --float_support=vfplib -me --include_path="C:/CCSWorkspace/ECG603/rfWsnNodeBleAdv_CC1350_LAUNCHXL_tirtos_ccs" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/boards/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/inc/" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/controller/cc26xx/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/target/_common/cc13xx" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/hal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/blestack/osal/src/inc" --include_path="C:/ti/simplelink_cc13x0_sdk_2_30_00_20/source/ti/posix/ccs" --include_path="C:/ti/ccsv7/tools/compiler/ti-cgt-arm_16.9.9.LTS/include" --define=BOARD_DISPLAY_USE_LCD=1 --define=FEATURE_BROADCASTER --define=FEATURE_ADVERTISER --define=CC13XX_LAUNCHXL --define=RF_MULTI_MODE --define=FEATURE_BLE_ADV --define=DeviceFamily_CC13X0 --define=CCFG_FORCE_VDDR_HH=0 -g --diag_warning=225 --diag_warning=255 --diag_wrap=off --display_error_number --gen_func_subsections=on --preproc_with_compile --preproc_dependency="rfWsnNode.d" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '


