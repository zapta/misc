/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.h
  * @brief          : Header for main.c file.
  *                   This file contains the common defines of the application.
  ******************************************************************************
  * @attention
  *
  * <h2><center>&copy; Copyright (c) 2020 STMicroelectronics.
  * All rights reserved.</center></h2>
  *
  * This software component is licensed by ST under BSD 3-Clause license,
  * the "License"; You may not use this file except in compliance with the
  * License. You may obtain a copy of the License at:
  *                        opensource.org/licenses/BSD-3-Clause
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32f4xx_hal.h"
#include "stm32f4xx_hal.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Exported types ------------------------------------------------------------*/
/* USER CODE BEGIN ET */

/* USER CODE END ET */

/* Exported constants --------------------------------------------------------*/
/* USER CODE BEGIN EC */

/* USER CODE END EC */

/* Exported macro ------------------------------------------------------------*/
/* USER CODE BEGIN EM */

/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define LED0_Pin GPIO_PIN_13
#define LED0_GPIO_Port GPIOC
#define LED1_Pin GPIO_PIN_14
#define LED1_GPIO_Port GPIOC
#define LED2_Pin GPIO_PIN_15
#define LED2_GPIO_Port GPIOC
#define TFT_D0_Pin GPIO_PIN_0
#define TFT_D0_GPIO_Port GPIOA
#define TFT_D1_Pin GPIO_PIN_1
#define TFT_D1_GPIO_Port GPIOA
#define TFT_D2_Pin GPIO_PIN_2
#define TFT_D2_GPIO_Port GPIOA
#define TFT_D3_Pin GPIO_PIN_3
#define TFT_D3_GPIO_Port GPIOA
#define TFT_D4_Pin GPIO_PIN_4
#define TFT_D4_GPIO_Port GPIOA
#define TFT_D5_Pin GPIO_PIN_5
#define TFT_D5_GPIO_Port GPIOA
#define TFT_D6_Pin GPIO_PIN_6
#define TFT_D6_GPIO_Port GPIOA
#define TFT_D7_Pin GPIO_PIN_7
#define TFT_D7_GPIO_Port GPIOA
#define AIN0_Pin GPIO_PIN_0
#define AIN0_GPIO_Port GPIOB
#define AIN1_Pin GPIO_PIN_1
#define AIN1_GPIO_Port GPIOB
#define TFT_RST_Pin GPIO_PIN_12
#define TFT_RST_GPIO_Port GPIOB
#define TFT_BL_Pin GPIO_PIN_13
#define TFT_BL_GPIO_Port GPIOB
#define TFT_DC_Pin GPIO_PIN_14
#define TFT_DC_GPIO_Port GPIOB
#define TFT_CS_Pin GPIO_PIN_15
#define TFT_CS_GPIO_Port GPIOB
#define TFT_WR_Pin GPIO_PIN_9
#define TFT_WR_GPIO_Port GPIOA
#define LED3_Pin GPIO_PIN_15
#define LED3_GPIO_Port GPIOA
/* USER CODE BEGIN Private defines */

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
