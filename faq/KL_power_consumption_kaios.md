# power consumption issues

## 1. Check Bottom current first

* Screen off should be about 2ma
* Airplane mode and screen on always (bringhtness)
* adb shell "cat /sys/class/leds/lcd-backlight/brightness"



## 2. wakeup

```
/sys/kernel/debug/wakeup_sources
sys/power

```

## 3. RPM

* cat  sys/power/system_sleep/stats

```
RPM Mode:xosd
count:0
time in last mode(msec):0
time since last mode(sec):1275
actual last sleep(msec):0
client votes: 0x03030303

RPM Mode:vmin
count:0 //有计数则说明系统进入最低功耗状态
time in last mode(msec):0
time since last mode(sec):1275
actual last sleep(msec):0
client votes: 0x00000000

```
## 4. extern wake up apss

```
echo 1 >/sys/module/msm_show_resume_irq/parameters/debug_mask

echo "8 8 8 8">/proc/sys/kernel/printk

```

## get wakeup source 

```
root@gflip3_tf:/ # cat /sys/kernel/debug/wakeup_sources                        
name					active_count	event_count	wakeup_count	expire_count	active_since	total_time	max_time	last_change	prevent_suspend_time
[timerfd]                       	0		0		0		0		0		0		0		210131		0
gecko                           	3		3		0		0		0		4373		4003		77048		0
vm_bms                          	6		6		0		0		0		112		27		294921		0
ipc00000097_1432_netmgrd        	2		2		0		0		0		0		0		28292		0
ipc00000096_1432_netmgrd        	2		2		0		0		0		0		0		28258		0
ipc00000093_1432_netmgrd        	5		5		0		0		0		0		0		28351		0
ipc0000008d_1432_netmgrd        	5		5		0		0		0		1		0		28350		0
ipc0000008b_1432_netmgrd        	2		2		0		0		0		0		0		28049		0
ipc0000008a_604_qti             	0		0		0		0		0		0		0		27999		0
ipc00000089_604_qti             	9		9		0		0		0		3		0		151081		0
ipc00000088_604_qti             	0		0		0		0		0		0		0		27999		0
ipc00000087_1432_netmgrd        	2		2		0		0		0		0		0		28006		0
ipc00000086_1432_netmgrd        	5		5		0		0		0		0		0		28349		0
ipc00000085_1432_netmgrd        	5		5		0		0		0		0		0		28348		0
ipc00000084_1432_netmgrd        	2		2		0		0		0		0		0		27843		0
ipc00000083_1432_netmgrd        	2		2		0		0		0		0		0		27797		0
ipc00000082_1432_netmgrd        	5		5		0		0		0		0		0		28347		0
ipc00000081_1432_netmgrd        	5		5		0		0		0		1		0		28346		0
ipc00000080_1432_netmgrd        	2		2		0		0		0		0		0		27593		0
ipc0000007f_1432_netmgrd        	2		2		0		0		0		0		0		27556		0
ipc0000007e_619_netmgrd         	2		3		0		0		0		0		0		27543		0
ipc0000007d_1432_netmgrd        	5		5		0		0		0		1		1		28344		0
ipc0000007c_1432_netmgrd        	5		5		0		0		0		0		0		28343		0
ipc0000007b_1432_netmgrd        	2		2		0		0		0		0		0		27358		0
ipc0000007a_1432_netmgrd        	2		2		0		0		0		0		0		27286		0
ipc00000079_1432_netmgrd        	5		5		0		0		0		1		0		28342		0
ipc00000078_1432_netmgrd        	5		5		0		0		0		0		0		28341		0
ipc00000077_1432_netmgrd        	2		2		0		0		0		0		0		27117		0
ipc00000076_1432_netmgrd        	2		2		0		0		0		0		0		27077		0
ipc00000075_1432_netmgrd        	5		5		0		0		0		1		0		28339		0
ipc00000074_1432_netmgrd        	5		5		0		0		0		1		0		28339		0
ipc00000073_1432_netmgrd        	2		2		0		0		0		0		0		26906		0
ipc00000072_1432_netmgrd        	2		2		0		0		0		0		0		26859		0
ipc00000071_1432_netmgrd        	5		5		0		0		0		2		1		28338		0
ipc00000070_1432_netmgrd        	5		5		0		0		0		1		0		28336		0
ipc0000006f_1432_netmgrd        	2		2		0		0		0		0		0		26679		0
ipc0000006e_1432_netmgrd        	2		2		0		0		0		0		0		26633		0
ipc0000006d_1432_netmgrd        	5		5		0		0		0		1		0		28335		0
ipc0000006c_1432_netmgrd        	5		5		0		0		0		0		0		28332		0
ipc0000006b_1432_netmgrd        	2		2		0		0		0		0		0		26472		0
ipc0000006a_1432_netmgrd        	2		2		0		0		0		0		0		26435		0
ipc00000069_1432_netmgrd        	5		5		0		0		0		0		0		28331		0
ipc00000068_1432_netmgrd        	5		5		0		0		0		0		0		28331		0
ipc00000067_1432_netmgrd        	5		5		0		0		0		0		0		26250		0
ipc00000066_1432_netmgrd        	5		5		0		0		0		0		0		26199		0
ipc00000065_1432_netmgrd        	5		5		0		0		0		1		0		26127		0
ipc00000064_1432_netmgrd        	5		5		0		0		0		1		0		26081		0
ipc00000063_1432_netmgrd        	5		5		0		0		0		0		0		25980		0
ipc00000062_1432_netmgrd        	5		5		0		0		0		0		0		25938		0
ipc00000061_1432_netmgrd        	5		5		0		0		0		0		0		25865		0
ipc00000060_1432_netmgrd        	5		5		0		0		0		0		0		25820		0
ipc0000005f_1432_netmgrd        	5		5		0		0		0		0		0		25745		0
ipc0000005e_1432_netmgrd        	5		5		0		0		0		1		0		25704		0
ipc0000005d_1432_netmgrd        	5		5		0		0		0		0		0		25621		0
ipc0000005c_1432_netmgrd        	5		5		0		0		0		0		0		25585		0
ipc0000005b_1432_netmgrd        	5		5		0		0		0		1		0		25508		0
ipc0000005a_1432_netmgrd        	5		5		0		0		0		0		0		25470		0
KeyEvents                       	1		1		0		0		0		127		127		25388		0
ipc00000056_1432_netmgrd        	5		5		0		0		0		0		0		25248		0
ipc00000055_1432_netmgrd        	5		5		0		0		0		1		0		25201		0
ipc00000054_619_netmgrd         	1		1		0		0		0		0		0		25157		0
wcnss_IPCRTR                    	1		4		0		0		0		12		12		25002		0
ipc00000053_613_rild            	2		2		0		0		0		0		0		24399		0
ipc00000052_613_rild            	5		5		0		0		0		7		7		24395		0
ipc00000051_613_rild            	5		5		0		0		0		13		9		31077		0
ipc00000050_613_rild            	3		3		0		0		0		4		2		24380		0
ipc0000004f_613_rild            	1		1		0		0		0		4		4		24337		0
ipc0000004e_1395_rild           	1		1		0		0		0		13		13		24306		0
ipc0000004d_613_rild            	3		3		0		0		0		1		0		24281		0
wcnss                           	1		1		0		0		0		644		644		24880		0
ipc0000004c_613_rild            	3		3		0		0		0		0		0		24263		0
radio-interface                 	3		12		0		0		0		838		424		27874		0
eventpoll                       	2		2		0		0		0		0		0		210129		0
qcril                           	13		13		0		0		0		410		344		65654		0
ipc0000004b_1117_Loc_hal_worker 	2		3		0		0		0		1		0		24104		0
ipc0000004a_613_rild            	0		0		0		0		0		0		0		23989		0
ipc00000049_1117_Loc_hal_worker 	1		1		0		0		0		0		0		24045		0
ipc00000048_525_thermal-engine  	4		4		0		0		0		0		0		24002		0
ipc00000044_613_rild            	12		12		0		0		0		4		1		151082		0
ipc00000043_1117_Loc_hal_worker 	40		66		0		0		0		29		13		150645		0
ipc00000042_1117_Loc_hal_worker 	0		0		0		0		0		0		0		23782		0
ipc00000041_1117_Loc_hal_worker 	12		12		0		0		0		6		1		151082		0
ipc00000040_480_cnd             	1		1		0		0		0		0		0		23769		0
ipc0000003f_480_cnd             	1		1		0		0		0		5		5		23683		0
ipc0000003e_545_imsdatadaemon   	12		12		0		0		0		5		1		151082		0
ipc0000003d_545_imsdatadaemon   	0		0		0		0		0		0		0		23518		0
ipc0000003c_545_imsdatadaemon   	12		12		0		0		0		4		1		151081		0
qmuxd_port_wl_0                 	585		585		0		0		0		484		13		65299		0
ipc0000003b_619_netmgrd         	2		2		0		0		0		6		6		23230		0
ipc0000003a_619_netmgrd         	12		12		0		0		0		5		1		151081		0
ipc00000039_619_netmgrd         	0		0		0		0		0		0		0		23220		0
ipc00000038_613_rild            	0		0		0		0		0		0		0		18767		0
qcril_pre_client_init           	1		1		0		0		0		5110		5110		23838		0
rmt_storage_-1297381072         	1		1		0		0		0		30		30		18295		0
msm_digital_codec               	0		0		0		0		0		0		0		18214		0
ipc00000037_551_time_daemon     	1		1		0		0		0		0		0		18167		0
video1                          	1		1		0		0		0		1489		1489		21575		0
200f000.qcom,spmi:qcom,pm8909@1:analog-codec@f100	0		0		0		0		0		0		0		17945		0
ipc0000002e_52_kworker/0:2      	48		51		0		0		0		40		9		151080		0
ipc0000002d_52_kworker/0:2      	4		4		0		0		0		0		0		17989		0
tftp_server_wakelock            	6		6		0		0		0		277		86		28197		0
rmt_storage_-1293190864         	2		2		0		0		0		197		196		18587		0
rmt_storage_-1292134096         	3		3		0		0		0		341		295		151078		0
ipc0000002b_593_rmt_storage     	60		65		0		0		0		28		3		151081		0
ipc0000002a_593_rmt_storage     	13		13		0		0		0		6		5		150777		0
ipc00000029_480_cnd             	0		0		0		0		0		0		0		17629		0
ipc00000028_480_cnd             	62		65		0		0		0		30		3		151081		0
ipc00000027_545_imsdatadaemon   	0		0		0		0		0		0		0		17485		0
ipc00000026_551_time_daemon     	0		0		0		0		0		0		0		17109		0
ipc00000025_551_time_daemon     	61		65		0		0		0		28		3		151080		0
ipc00000024_527_thermal-engine  	0		0		0		0		0		0		0		16927		0
ipc00000023_527_thermal-engine  	63		65		0		0		0		13		4		151080		0
ipc00000022_482_tftp_server     	0		0		0		0		0		0		0		16726		0
ipc00000021_482_tftp_server     	0		0		0		0		0		0		0		16723		0
ipc00000020_482_tftp_server     	0		0		0		0		0		0		0		16721		0
ipc0000001f_482_tftp_server     	0		0		0		0		0		0		0		16718		0
ipc0000001e_482_tftp_server     	0		0		0		0		0		0		0		16716		0
ipc0000001d_482_tftp_server     	17		17		0		0		0		3		1		28186		0
modem_IPCRTR                    	381		494		0		0		0		207		58		151079		0
spkr-prot                       	0		0		0		0		0		0		0		10383		0
ipc0000001b_380_pm-service      	62		66		0		0		0		39		4		151080		0
ipc0000001a_380_pm-service      	0		0		0		0		0		0		0		10084		0
soc:gpio_keys                   	0		0		0		0		0		0		0		6237		0
bam_dmux_wakelock               	1		1		0		0		0		3001		3001		26225		0
battery                         	3		5		0		0		0		69		29		294947		0
usb                             	7		11		0		0		0		52		45		105524		0
bms                             	3		3		0		0		0		19		7		294934		0
vbms_soc_wake                   	9		9		0		0		0		102		14		315377		0
vbms_cv_wake                    	0		0		0		0		0		0		0		5983		0
vbms_lv_wake                    	0		0		0		0		0		0		0		5983		0
200f000.qcom,spmi:qcom,pm8909@0:qcom,vmbms	6		12		0		6		0		2977		499		295410	0
ssr(modem)                      	0		0		0		0		0		0		0		5902		0
pil-modem                       	1		1		0		0		0		997		997		11200		0
ssr(wcnss)                      	0		0		0		0		0		0		0		5840		0
pil-wcnss                       	1		1		0		0		0		668		668		24930		0
ipc00000018_5_kworker/u8:0      	63		66		0		0		0		46		10		151080		0
ipc00000017_5_kworker/u8:0      	0		0		0		0		0		0		0		5673		0
ipc00000016_5_kworker/u8:0      	0		0		0		0		0		0		0		5673		0
ipc00000015_5_kworker/u8:0      	0		0		0		0		0		0		0		5672		0
ipc00000014_5_kworker/u8:0      	0		0		0		0		0		0		0		5672		0
ipc00000013_5_kworker/u8:0      	0		0		0		0		0		0		0		5671		0
ipc00000012_5_kworker/u8:0      	0		0		0		0		0		0		0		5671		0
ipc00000011_5_kworker/u8:0      	0		0		0		0		0		0		0		5670		0
ipc00000010_5_kworker/u8:0      	0		0		0		0		0		0		0		5669		0
ipc0000000f_5_kworker/u8:0      	0		0		0		0		0		0		0		5669		0
ipc0000000e_5_kworker/u8:0      	0		0		0		0		0		0		0		5668		0
ipc0000000d_5_kworker/u8:0      	0		0		0		0		0		0		0		5668		0
ipc0000000c_5_kworker/u8:0      	0		0		0		0		0		0		0		5667		0
ipc0000000b_5_kworker/u8:0      	0		0		0		0		0		0		0		5666		0
ipc0000000a_5_kworker/u8:0      	0		0		0		0		0		0		0		5666		0
ipc00000009_5_kworker/u8:0      	0		0		0		0		0		0		0		5665		0
ipc00000008_5_kworker/u8:0      	0		0		0		0		0		0		0		5665		0
ipc00000007_5_kworker/u8:0      	0		0		0		0		0		0		0		5664		0
ipc00000006_5_kworker/u8:0      	0		0		0		0		0		0		0		5663		0
ipc00000005_1_swapper/0         	63		66		0		0		0		44		10		151080		0
200f000.qcom,spmi:qcom,pm8909@0:vadc@3100	0		0		0		0		0		0		0		5143	0
200f000.qcom,spmi:qcom,pm8909@0:qcom,charger	7		7		0		0		0		31		5		306275	0
200f000.qcom,spmi:qcom,pm8909@0:qcom,pm8909_rtc	0		0		0		0		0		0		0		4971	0
2-0058                          	0		0		0		0		0		0		0		4953		0
78d9000.usb                     	2		2		0		0		313810		314022		313810		6046		0
ipc00000004_45_kworker/0:1      	63		66		0		0		0		51		10		151080		0
ipc00000003_45_kworker/0:1      	1		1		0		0		0		0		0		17780		0
DIAG_WS                         	49		102		0		0		0		34		5		105174		0
smd_pkt_loopback                	0		0		0		0		0		0		0		3671		0
apr_apps2                       	0		0		0		0		0		0		0		3671		0
at_mdm0                         	0		0		0		0		0		0		0		3670		0
smdcntl8                        	0		0		0		0		0		0		0		3670		0
smd22                           	0		0		0		0		0		0		0		3670		0
smdcntl0                        	566		980		0		0		0		767		22		65298		0
SMDTTY_READ_IN_SUSPEND          	0		0		0		0		0		0		0		3669		0
ssr(venus)                      	0		0		0		0		0		0		0		1359		0
pil-venus                       	1		1		0		0		0		152		152		23510		0
ipc00000002_46_kworker/1:1      	62		66		0		0		0		74		16		151081		0
ipc00000001_46_kworker/1:1      	2		2		0		0		0		2		2		18681		0
alarmtimer                      	0		0		0		0		0		0		0		1223		0
200f000.qcom,spmi:qcom,pm8909@0:qcom,power-on@800	0		0		0		0		0		0		0		901		0
smsm_snapshot                   	7		7		0		0		0		13		8		26225		0
autosleep                       	0		0		0		0		0		0		0		438		0
deleted                         	28		28		0		0		0		36		10		0		0

```
