adb root
adb remount
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_gpubusy/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_pwr_request_state/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_pwr_set_state/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_pwrstats/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_buslevel/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_pwrlevel/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_clk/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_bus/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_rail/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/adreno_cmdbatch_queued/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/adreno_cmdbatch_submitted/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/adreno_cmdbatch_retired/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_user_pwrlevel_constraint/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/kgsl/kgsl_constraint/enable"

adb shell "echo 1 > /sys/kernel/debug/tracing/events/msm_bus/bus_update_request/enable"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/msm_bus/bus_agg_bw/enable"

adb shell "echo 1 > /sys/kernel/debug/tracing/tracing_on"

adb shell cat /sys/kernel/debug/tracing/trace_pipe > traces_kgsl.txt
