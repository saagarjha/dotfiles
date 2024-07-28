#!/usr/bin/env osascript -l JavaScript

$.NSBundle.bundleWithPath("/System/Library/PrivateFrameworks/UniversalAccess.framework/").load
ObjC.bindFunction("UAScrollZoomSetEnabled", ["void", ["BOOL"]])
$.UAScrollZoomSetEnabled(true)
