LOCAL_PATH := $(call my-dir)


include $(CLEAR_VARS)


LOCAL_SRC_FILES += src/cjson.c \
    src/dscp.c \
    src/iperf_api.c \
    src/iperf_auth.c \
    src/iperf_client_api.c \
    src/iperf_error.c \
    src/iperf_locale.c \
    src/iperf_sctp.c \
    src/iperf_server_api.c \
    src/iperf_tcp.c \
    src/iperf_time.c \
    src/iperf_udp.c \
    src/iperf_util.c \
    src/main.c \
    src/net.c \
    src/tcp_info.c \
    src/timer.c \
    src/units.c 


LOCAL_C_INCLUDES += \
    $(LOCAL_PATH) \
    $(LOCAL_PATH)/include


LOCAL_CFLAGS += -Wno-format-security


LOCAL_CFLAGS += -DHAVE_CONFIG_H


LOCAL_SHARED_LIBRARIES := libc libm libcutils libnetutils


LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := iperf


include $(BUILD_EXECUTABLE)
