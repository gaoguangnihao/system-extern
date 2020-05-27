## gaia side
###   /apps/system/src/temperature_monitor.js

```
   CHECK_TIME_INTERVAL = 60000;
   HIGHEST_TEMPTERATURE = 63;
   LOWEST_TEMPTERATURE = -23;
```
## gonk/kernel side
### /gecko/hal/gonk/GonkHal.cpp

```
  GetBatteryTemperature()
  {
    int temperature;
    bool success = ReadSysFile("/sys/class/power_supply/battery/temp", &temperature);
  
    return success ? (double) temperature / 10.0 : dom::battery::kDefaultTemperature;;
  }
```

## mmitest 
### /gecko/proprietary/engmodeEx/engmodeExtension.js

```
     'batterycapacity': '/sys/class/power_supply/battery/capacity',
     'health': '/sys/class/power_supply/battery/health',
     'plug': '/sys/class/power_supply/usb/online',
     'batterycurrent_now': '/sys/class/power_supply/battery/current_now',
     'batteryvoltage_now': '/sys/class/power_supply/battery/voltage_now',
     'battery_present': '/sys/class/power_supply/battery/present',
     'battery_id': '/sys/class/power_supply/battery/batt_id',
```
