## gaia side
###   /apps/system/src/temperature_monitor.js

```
CHECK_TIME_INTERVAL = 60000;
HIGHEST_TEMPTERATURE = 63;
LOWEST_TEMPTERATURE = -23;
  
this.clearInterval();
this._turnOffTimer = window.setInterval(() => {
  var temperature = this._battery.temperature;
  if (temperature >= this.HIGHEST_TEMPTERATURE ||
      temperature <= this.LOWEST_TEMPTERATURE) {
    Service.request('startPowerOff', false);
  }
}, this.CHECK_TIME_INTERVAL);
}
  
```
```
40    var powerSupplyOnline = this._powersupply.powerSupplyOnline;
41    if (this._battery.health === 'Overheat') {
42      if (powerSupplyOnline) {
43        this.showWarningMessage('battery-temperature-high-stop-charging');
44      } else {
45        this.showWarningMessage('battery-temperature-high');
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

```
/sys/class/power_supply/battery/health

597GetCurrentBatteryHealth()
598{
599  char health[16] = {0};
600  bool success;
601
602  // Get battery health and set to "Unknown" if read fails
603  success = ReadSysFile("/sys/class/power_supply/battery/health",
604                        health, sizeof(health));
605  if (success) {
606    if (!strcmp(health, "Good")) {
607      return BatteryHealth::Good;
608    } else if (!strcmp(health, "Overheat")) {
609      return BatteryHealth::Overheat;
610    } else if (!strcmp(health, "Cold")) {
611      return BatteryHealth::Cold;
612    } else if (!strcmp(health, "Warm")) {
613      return BatteryHealth::Warm;
614    } else if (!strcmp(health, "Cool")) {
615      return BatteryHealth::Cool;
616    } else {
617      return BatteryHealth::Unknown;
618    }
619  } else {
620    return dom::battery::kDefaultHealth;
621  }
622}

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
