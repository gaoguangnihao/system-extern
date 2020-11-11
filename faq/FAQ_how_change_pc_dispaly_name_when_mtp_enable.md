## README

```
1.long time no fix on mater branch
2.more customer need this feature on kai device
3.bug list
	46988
	59215
	71059
	97094
	108600
	109049
4.sdcard and sdcard1 are the storage name.
  actually it's original design that sdcard is 
  internal storage and sdcard1 is the physical sd card.
  more customer need this feature for kai devices , 
  we can define the rule on Kaios
  
```

## gecko patch
```

diff --git a/dom/system/gonk/MozMtpStorage.cpp
b/dom/system/gonk/MozMtpStorage.cpp
index 9c358a1..c4a6828 100644
--- a/dom/system/gonk/MozMtpStorage.cpp
+++ b/dom/system/gonk/MozMtpStorage.cpp
@@ -100,7 +100,8 @@ MozMtpStorage::StorageAvailable()

   mMtpStorage.reset(new MtpStorage(mStorageID,                           // id
                                    mountPoint.get(),                     //
filePath
-                                   mVolume->NameStr(),                   //
description
+                                   strcmp(mVolume->NameStr(), "sdcard") ?
+                                   "SD card" : "Internal Storage",       //
description
                                    1024uLL * 1024uLL,                    //
reserveSpace
                                    mVolume->IsHotSwappable(),            //
removable
                                    2uLL * 1024uLL * 1024uLL * 1024uLL)); //
maxFileSize

```
## BSP

```
look fine 
change is in volume.cfg

volume.cfg
create sdcard /data/usbmsc_mnt

```
