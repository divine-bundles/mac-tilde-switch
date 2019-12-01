#!/usr/bin/env bash

#
# Mapping 'tilde' and 'plus-minus' buttons back onto themselves
#
# Source:
# http://homeowmorphism.com/articles/17/Remap-CapsLock-Backspace-Sierra
#

hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000035,"HIDKeyboardModifierMappingDst":0x700000035},{"HIDKeyboardModifierMappingSrc":0x700000064,"HIDKeyboardModifierMappingDst":0x700000064}]}'
