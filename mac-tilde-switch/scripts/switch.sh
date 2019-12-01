#!/usr/bin/env bash

#
# Cross-mapping 'tilde' and 'plus-minus' buttons onto each other
# This script should be run at startup
#
# Source:
# http://homeowmorphism.com/articles/17/Remap-CapsLock-Backspace-Sierra
#

hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000035,"HIDKeyboardModifierMappingDst":0x700000064},{"HIDKeyboardModifierMappingSrc":0x700000064,"HIDKeyboardModifierMappingDst":0x700000035}]}'
