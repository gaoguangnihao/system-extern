## Bug 107872 - 老化测试过程中出现死机和重启定屏 

### 1. dump stack

```
A409-28 16:54:02.990   238   238 F DEBUG   : Native Crash TIME: 3585579
A409-28 16:54:02.990   238   238 F DEBUG   : *** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
A409-28 16:54:02.990   238   238 F DEBUG   : Build fingerprint: 'SPRD/sp9820e_1h20_project/sp9820e_1h20:6.0/KTU84P/20200928:user/release-keys'
A409-28 16:54:02.990   238   238 F DEBUG   : Revision: '0'
A409-28 16:54:02.990   238   238 F DEBUG   : ABI: 'arm'
A409-28 16:54:02.990   238   238 F DEBUG   : pid: 239, tid: 1920, name: rd.h264.decoder  >>> /system/bin/mediaserver <<<
A409-28 16:54:02.990   238   238 F DEBUG   : signal 11 (SIGSEGV), code 1 (SEGV_MAPERR), fault addr 0x8
A409-28 16:54:03.270   238   238 F DEBUG   :     r0 00000008  r1 af8bf6a0  r2 00000001  r3 00000000
A409-28 16:54:03.270   238   238 F DEBUG   :     r4 b60619e0  r5 00000000  r6 ffffffff  r7 af8bf6a0
A409-28 16:54:03.270   238   238 F DEBUG   :     r8 00000001  r9 00000008  sl b24619b0  fp af8bf6a0
A409-28 16:54:03.271   238   238 F DEBUG   :     ip b64997e0  sp af8bf668  lr b647e9f1  pc b6aa32ce  cpsr 00000030
A409-28 16:54:03.287   238   238 F DEBUG   : 
A409-28 16:54:03.287   238   238 F DEBUG   : backtrace:
A409-28 16:54:03.290   238   238 F DEBUG   :     #00 pc 0003f2ce  /system/lib/libc.so (pthread_mutex_lock+3)
A409-28 16:54:03.290   238   238 F DEBUG   :     #01 pc 000169ed  /system/lib/libstagefright_omx.so (_ZN7android3OMX18CallbackDispatcher4postERKNS_11omx_messageEb+16)
A409-28 16:54:03.290   238   238 F DEBUG   :     #02 pc 00017d15  /system/lib/libstagefright_omx.so (_ZN7android3OMX17OnEmptyBufferDoneEjjP20OMX_BUFFERHEADERTYPEi+40)
A409-28 16:54:03.290   238   238 F DEBUG   :     #03 pc 00019035  /system/lib/libstagefright_omx.so (_ZN7android15OMXNodeInstance17OnEmptyBufferDoneEPvS1_P20OMX_BUFFERHEADERTYPE+60)
A409-28 16:54:03.290   238   238 F DEBUG   :     #04 pc 00009de0  /system/vendor/lib/libstagefright_sprd_h264dec.so
A409-28 16:54:03.290   238   238 F DEBUG   :     #05 pc 00007743  /system/vendor/lib/libstagefrighthw.so (_ZN7android22SprdSimpleOMXComponent17onMessageReceivedERKNS_2spINS_8AMessageEEE+250)
A409-28 16:54:03.290   238   238 F DEBUG   :     #06 pc 0000792b  /system/vendor/lib/libstagefrighthw.so
A409-28 16:54:03.290   238   238 F DEBUG   :     #07 pc 0000b351  /system/lib/libstagefright_foundation.so (_ZN7android8AHandler14deliverMessageERKNS_2spINS_8AMessageEEE+16)
A409-28 16:54:03.290   238   238 F DEBUG   :     #08 pc 0000d333  /system/lib/libstagefright_foundation.so (_ZN7android8AMessage7deliverEv+54)
A409-28 16:54:03.290   238   238 F DEBUG   :     #09 pc 0000bd5d  /system/lib/libstagefright_foundation.so (_ZN7android7ALooper4loopEv+224)
A409-28 16:54:03.290   238   238 F DEBUG   :     #10 pc 00010115  /system/lib/libutils.so (_ZN7android6Thread11_threadLoopEPv+112)
A409-28 16:54:03.290   238   238 F DEBUG   :     #11 pc 0003e8d3  /system/lib/libc.so (_ZL15__pthread_startPv+30)
A409-28 16:54:03.290   238   238 F DEBUG   :     #12 pc 00018dcd  /system/lib/libc.so (__start_thread+6)
```

### 2. Pull out libstagefright_omx.so and disassable.

Crash for invalid memory at `d`, we can get a. r0 is 0x0 from `d` => `c` => `b` => `a`

```
(gdb) disassemble _ZN7android3OMX18CallbackDispatcher4postERKNS_11omx_messageEb
Dump of assembler code for function _ZN7android3OMX18CallbackDispatcher4postERKNS_11omx_messageEb:
   0x00016e58 <+0>: stmdb     sp!, {r4, r5, r6, r7, r8, r9, r11, lr}
   0x00016e5c <+4>: mov  r5, r0
                        ^^^^^^           //  a. r5 = r0 = 0x0
   0x00016e5e <+6>: add.w     r9, r5, #8
                            ^^^^^^^^^^   //  b. r9 = r5 + 0x8
   0x00016e62 <+10>:     mov  r8, r2
   0x00016e64 <+12>:     mov  r7, r1
   0x00016e66 <+14>:     mov  r0, r9        
                            ^^^^^^^   //  c. r0 = r9
   0x00016e68 <+16>:     blx  0x12580
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

(gdb) disassemble pthread_mutex_lock
Dump of assembler code for function pthread_mutex_lock:
   0x0004208a <+0>: push {r0, r1, r4, lr}
   0x0004208c <+2>: cbz  r0, 0x420aa <pthread_mutex_lock+32>
   0x0004208e <+4>: ldrh r3, [r0, #0]          
                                ^^^^^^^^^^^^^ //  d. r0 is 08

(SEGV_MAPERR), fault addr 0x8
r0 00000008  r1 af8bf6a0  r2 00000001  r3 00000000
^^^^^^^^^^^
r4 b60619e0  r5 00000000  r6 ffffffff  r7 af8bf6a0
r8 00000001  r9 00000008  sl b24619b0  fp af8bf6a0
ip b64997e0  sp af8bf668  lr b647e9f1  pc b6aa32ce  cpsr 00000030
```

### 2. Match to code

```
511  OMX_ERRORTYPE OMX::OnEmptyBufferDone(
512          node_id node, buffer_id buffer, OMX_IN OMX_BUFFERHEADERTYPE *pBuffer, int fenceFd) {
513      ALOGV("OnEmptyBufferDone buffer=%p", pBuffer);
514  
515      omx_message msg;
516      msg.type = omx_message::EMPTY_BUFFER_DONE;
517      msg.node = node;
518      msg.fenceFd = fenceFd;
519      msg.u.buffer_data.buffer = buffer;
520  
521      findDispatcher(node)->post(msg);
         ^^^^^^^^^^^^^^^^^^  //  findDispatcher(node) return is null here
522  
523      return OMX_ErrorNone;
524  }
```

```
117  void OMX::CallbackDispatcher::post(const omx_message &msg, bool realTime) {
118      Mutex::Autolock autoLock(mLock);
                                  ^^^^^^
119  
120      mQueue.push_back(msg);
121      if (realTime) {
122          mQueueChanged.signal();
123      }
124  }
```
```
63      class Autolock {
64      public:
65          inline Autolock(Mutex& mutex) : mLock(mutex)  { mLock.lock(); }
```
```
111  inline status_t Mutex::lock() {
112      return -pthread_mutex_lock(&mMutex);
113  }
```

### 3. Solution
 Check null before call post
 ```
 @@ -508,7 +512,12 @@ OMX_ERRORTYPE OMX::OnEmptyBufferDone(
     msg.fenceFd = fenceFd;
     msg.u.buffer_data.buffer = buffer;
 
-    findDispatcher(node)->post(msg);
+    sp<OMX::CallbackDispatcher> callbackDispatcher = findDispatcher(node);
+    if (callbackDispatcher != NULL) {
+        callbackDispatcher->post(msg);
+    } else {
+        ALOGW("OnEmptyBufferDone Callback dispatcher NULL, skip post");
+    }
```

####See:
https://bugzilla.kaiostech.com/attachment.cgi?id=157131