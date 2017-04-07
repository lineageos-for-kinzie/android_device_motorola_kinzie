#!/system/bin/sh

################################################################################
# helper functions to allow Android init like script

function write() {
    echo -n $2 > $1
}

function copy() {
    cat $1 > $2
}

function get-set-forall() {
    for f in $1 ; do
        cat $f
        write $f $2
    done
}

################################################################################

# take the A57s offline when thermal hotplug is disabled
write /sys/devices/system/cpu/cpu5/online 0
write /sys/devices/system/cpu/cpu6/online 0
write /sys/devices/system/cpu/cpu7/online 0

# disable thermal bcl hotplug to switch governor
write /sys/module/msm_thermal/core_control/enabled 0
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode disable
bcl_hotplug_mask=`get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_mask 0`
bcl_hotplug_soc_mask=`get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask 0`
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode enable

# some files in /sys/devices/system/cpu are created after the restorecon of
# /sys/. These files receive the default label "sysfs".
# Restorecon again to give new files the correct label.
restorecon -R /sys/devices/system/cpu

# ensure at most one A57 is online when thermal hotplug is disabled
write /sys/devices/system/cpu/cpu5/online 0
write /sys/devices/system/cpu/cpu6/online 0
write /sys/devices/system/cpu/cpu7/online 0

# Best effort limiting for first time boot if msm_performance module is absent
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq 960000

# Limit A57 max freq from msm_perf module in case CPU 4 is offline
write /sys/module/msm_performance/parameters/cpu_max_freq "4:960000 5:960000 6:960000 7:960000"

# Setup Little interactive settings
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu # must restore after interactive
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load 85
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay "30000 600000:35000 672000:10000 768000:35000 960000:55000"
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate 40000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq 460800
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack -1
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads "79 384000:61 460800:51 600000:46 672000:58 787200:54 864000:72 960000:74 1248000:83 1344000:97 1478000:100 1555200:100"
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time 40000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/boost 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/align_windows 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif 1
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis 70000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration 0
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 384000

# Make sure CPU 4 is only to configure big settings
write /sys/devices/system/cpu/cpu4/online 1

# Setup Big interactive settings
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor interactive
restorecon -R /sys/devices/system/cpu # must restore after interactive
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor interactive
write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 633600
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load 45
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay "20000 633600:70000 768000:30000 864000:20000 960000:50000"
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate 30000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq 636000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_slack -1
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads "80 384000:60 633600:58 768000:61 864000:62 960000:78 1248000:67 1344000:86 1440000:81 1536000:92 1632000:95 1689600:98 1728000:99 1824000:100 1958400:100"
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time 50000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/boost 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/align_windows 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_migration_notif 1
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/use_sched_load 0
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/max_freq_hysteresis 90000
write /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration 0

# restore A57's max
copy /sys/devices/system/cpu/cpu4/cpufreq/cpuinfo_max_freq /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq

# Restore CPU 4 max freq from msm_performance
write /sys/module/msm_performance/parameters/cpu_max_freq "4:4294967295 5:4294967295 6:4294967295 7:4294967295"

# Configure core_ctl
write /sys/devices/system/cpu/cpu4/core_ctl/min_cpus 2
write /sys/devices/system/cpu/cpu4/core_ctl/max_cpus 4
write /sys/devices/system/cpu/cpu4/core_ctl/busy_up_thres 70
write /sys/devices/system/cpu/cpu4/core_ctl/busy_down_thres 20
write /sys/devices/system/cpu/cpu4/core_ctl/offline_delay_ms 300
write /sys/devices/system/cpu/cpu4/core_ctl/task_thres 4
write /sys/devices/system/cpu/cpu4/core_ctl/is_big_cluster 1
write /sys/devices/system/cpu/cpu4/core_ctl/not_preferred "0 1 1 1" # Make sure core 4 always on

# plugin remaining A57s
write /sys/devices/system/cpu/cpu5/online 1
write /sys/devices/system/cpu/cpu6/online 1
write /sys/devices/system/cpu/cpu7/online 1
restorecon_recursive /sys/devices/system/cpu # must restore after online

# Available Freqs in stock kernel
# Little: 384000 460800 600000 672000 768000 864000 960000 1248000 1344000 1478400 1555200
# Big: 384000 480000 633600 768000 864000 960000 1248000 1344000 1440000 1536000 1632000 1728000 1824000 1958400
# write /sys/module/cpu_boost/parameters/boost_ms 20
# write /sys/module/cpu_boost/parameters/sync_threshold 960000
write /sys/module/cpu_boost/parameters/input_boost_freq "0:600000 1:600000 2:600000 3:600000 4:0 5:0 6:0 7:0"
write /sys/module/cpu_boost/parameters/input_boost_ms 150

# b.L scheduler parameters
write /proc/sys/kernel/sched_migration_fixup 1
write /proc/sys/kernel/sched_small_task 30
write /proc/sys/kernel/sched_mostly_idle_load 20
write /proc/sys/kernel/sched_mostly_idle_nr_run 3
write /proc/sys/kernel/sched_upmigrate 95
write /proc/sys/kernel/sched_downmigrate 85
write /proc/sys/kernel/sched_freq_inc_notify 400000
write /proc/sys/kernel/sched_freq_dec_notify 400000
write /proc/sys/kernel/sched_boost 0

# enable rps static configuration
write /sys/class/net/rmnet_ipa0/queues/rx-0/rps_cpus 8

# devfreq
get-set-forall /sys/class/devfreq/qcom,cpubw*/governor bw_hwmon
restorecon -R /sys/class/devfreq/qcom,cpubw*
get-set-forall /sys/class/devfreq/qcom,mincpubw*/governor cpufreq

# set GPU default power level to 5 (180MHz) instead of 4 (305MHz)
write /sys/class/kgsl/kgsl-3d0/default_pwrlevel 5

# android background processes are set to nice 10. Never schedule these on the a57s.
write /proc/sys/kernel/sched_upmigrate_min_nice 9

# set GPU default governor to msm-adreno-tz
write /sys/class/devfreq/fdb00000.qcom,kgsl-3d0/governor msm-adreno-tz

# re-enable thermal and BCL hotplug
write /sys/module/msm_thermal/core_control/enabled 1
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode disable
get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_mask $bcl_hotplug_mask
get-set-forall /sys/devices/soc.0/qcom,bcl.*/hotplug_soc_mask $bcl_hotplug_soc_mask
get-set-forall /sys/devices/soc.0/qcom,bcl.*/mode enable

# allow CPUs to go in deeper idle state than C0
write /sys/module/lpm_levels/parameters/sleep_disabled 0
