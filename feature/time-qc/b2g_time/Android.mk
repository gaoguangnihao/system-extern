LOCAL_PATH:= $(call my-dir)

ifdef BUILD_XPCOM
include $(CLEAR_XPCOM_VARS)
LOCAL_MODULE := b2g_time
LOCAL_MODULE_TAGS := optional

# Notice to put at the top of minimized .js files
LOCAL_JS_NOTICE := Copyright (c) 2013 Qualcomm Technologies, Inc.  All Rights Reserved. Qualcomm Technologies Proprietary and Confidential.

LOCAL_SRC_FILES := \
	timeservice.js \

include $(BUILD_XPCOM)
endif
