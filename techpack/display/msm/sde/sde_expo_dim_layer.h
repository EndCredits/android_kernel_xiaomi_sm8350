/*
 * A new exposure driver based on SDE dim layer for OLED devices
 *
 * Copyright (C) 2012-2014, The Linux Foundation. All rights reserved.
 * Copyright (C) 2019, Devries <therkduan@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 and
 * only version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 */

#ifndef SDE_EXPO_DIM_LAYER_H
#define SDE_EXPO_DIM_LAYER_H

#define DIM_THRES_LEVEL 440
#define BACKLIGHT_DIM_SCALE 1

enum {
	BRIGHTNESS = 0,
	ALPHA = 1,
	LUT_MAX,
};

static const uint16_t brightness_alpha_lut[][LUT_MAX] = {
/* {brightness, alpha} */
	{0, 0xFF},
	{1, 0xF2},
	{4, 0xE6},
	{9, 0xD9},
	{18, 0xCC},
	{29, 0xBF},
	{43, 0xB3},
	{60, 0xA6},
	{81, 0x99},
	{106, 0x8C},
	{132, 0x80},
	{163, 0x73},
	{198, 0x66},
	{237, 0x59},
	{277, 0x4D},
	{323, 0x40},
	{373, 0x33},
	{428, 0x26},
	{481, 0x1A},
	{544, 0xD},
	{610, 0x0}
};

uint32_t expo_map_dim_level(uint32_t level, struct dsi_display *display);

#endif /* SDE_EXPO_DIM_LAYER_H */
