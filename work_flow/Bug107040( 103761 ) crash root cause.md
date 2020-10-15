
## Bug 107040 - [FIH][BTV][Auto test][Call]Phone lag and then power cycle when review more than 550 missed call logs

### 1. mini dump stack
```
Crash reason:  SIGSEGV
Crash address: 0x0
Process uptime: not available

Thread 0 (crashed)
 0  libmozglue.so!mozalloc_abort [mozalloc_abort.cpp : 33 + 0x2]
     r0 = 0x000000a3    r1 = 0xbef2f190    r2 = 0xd847ee90    r3 = 0x00000000
     r4 = 0xbef2f6c4    r5 = 0xbef2f6a0    r6 = 0xbef2f6ac    r7 = 0xbef2f6b8
     r8 = 0x00000001    r9 = 0xb48e241c   r10 = 0x00000000   r12 = 0xbef2f1b8
     fp = 0xb48e445f    sp = 0xbef2f690    lr = 0xb514fb83    pc = 0xb514fb84
    Found by: given as instruction pointer in context
 1  libxul.so!NS_DebugBreak [nsDebugImpl.cpp : 447 + 0x5]
     r3 = 0x00000002    r4 = 0xbef2f6c4    r5 = 0xbef2f6a0    r6 = 0xbef2f6ac
     r7 = 0xbef2f6b8    r8 = 0x00000001    r9 = 0xb48e241c   r10 = 0x00000000
     fp = 0xb48e445f    sp = 0xbef2f698    pc = 0xb2e7d6cf
    Found by: call frame info
 2  libxul.so!mozilla::ipc::LogicError [ProtocolUtils.cpp : 465 + 0xb]
     r4 = 0x9f4c14f0    r5 = 0xa36a1a40    r6 = 0xbef2fafc    r7 = 0xa05d2630
     r8 = 0xa05d263c    r9 = 0xb3be6777   r10 = 0x00000000    fp = 0x00000000
     sp = 0xbef2fad8    pc = 0xb30a1043
    Found by: call frame info
 3  libxul.so!mozilla::dom::telephony::PTelephonyRequest::Transition [PTelephonyRequest.cpp : 44 + 0x7]
     r4 = 0x9f4c14f0    r5 = 0xa36a1a40    r6 = 0xbef2fafc    r7 = 0xa05d2630
     r8 = 0xa05d263c    r9 = 0xb3be6777   r10 = 0x00000000    fp = 0x00000000
     sp = 0xbef2fae8    pc = 0xb3158b0f
    Found by: call frame info
 4  libxul.so!mozilla::dom::telephony::PTelephonyRequestParent::Send__delete__ [PTelephonyRequestParent.cpp : 103 + 0x9]
     r4 = 0x9f4c14f0    r5 = 0xa36a1a40    r6 = 0xbef2fafc    r7 = 0xa05d2630
     r8 = 0xa05d263c    r9 = 0xb3be6777   r10 = 0x00000000    fp = 0x00000000
     sp = 0xbef2faf8    pc = 0xb315bcd7
    Found by: call frame info
 5  libxul.so!mozilla::dom::telephony::TelephonyRequestParent::SendResponse [TelephonyParent.cpp : 562 + 0x7]
     r4 = 0x9f4c14f0    r5 = 0xbef2fb78    r6 = 0xbef2fb78    r7 = 0xa05d2630
     r8 = 0xa05d263c    r9 = 0xb3be6777   r10 = 0x00000000    fp = 0x00000000
     sp = 0xbef2fb20    pc = 0xb3be664f
    Found by: call frame info
 6  libxul.so!mozilla::dom::telephony::TelephonyRequestParent::DialCallback::NotifyDialCallSuccess [TelephonyParent.cpp : 717 + 0x7]
     r3 = 0x00000004    r4 = 0xbef2fb54    r5 = 0xbef2fbac    r6 = 0xbef2fb78
     r7 = 0xa05d2630    r8 = 0xa05d263c    r9 = 0xb3be6777   r10 = 0x00000000
     fp = 0x00000000    sp = 0xbef2fb30    pc = 0xb3be675d
    Found by: call frame info
 7  telephony.so!nsTelephonyService::NotifyDialSuccess [nsTelephonyService.cpp : 1225 + 0x27]
     r4 = 0x9f4c2468    r5 = 0xbef2fc70    r6 = 0xbef2fc74    r7 = 0x00000001
     r8 = 0xa05d263c    r9 = 0xb3be6777   r10 = 0x00000000    fp = 0x00000000
     sp = 0xbef2fc58    pc = 0xaf561923
    Found by: call frame info
 8  telephony.so!Connection::NotifyDialSuccess [Connection.cpp : 1165 + 0x1f]
     r4 = 0x9f5b7a10    r5 = 0x00000001    r6 = 0x00000000    r7 = 0x9f4c2468
     r8 = 0x00000000    r9 = 0x00000000   r10 = 0x00000000    fp = 0x00000000
     sp = 0xbef2fca0    pc = 0xaf54e89d
    Found by: call frame info
 9  telephony.so!CallTracker::HandlePollCalls [CallTracker.cpp : 1881 + 0x9]
     r4 = 0xadcd0880    r5 = 0x00000000    r6 = 0x00000000    r7 = 0x00000002
     r8 = 0xadcd08d8    r9 = 0xaf5d4090   r10 = 0xbef2fd28    fp = 0x00000002
     sp = 0xbef2fce8    pc = 0xaf5478fb
    Found by: call frame info
10  telephony.so!CallTracker::HandleGetCurrentCalls [CallTracker.cpp : 445 + 0x13]
     r4 = 0x00000001    r5 = 0xbef2fd10    r6 = 0xbef2fd84    r7 = 0xbef2fda0
     r8 = 0xbef30100    r9 = 0x00000001   r10 = 0xbef2fe4c    fp = 0x00000000
     sp = 0xbef2fd78    pc = 0xaf547be9
    Found by: call frame info
11  telephony.so!RILHelper::ResponseCallList [RILHelper.cpp : 789 + 0x3]
     r4 = 0xaf53220b    r5 = 0x00000000    r6 = 0xbef30210    r7 = 0xbef30220
     r8 = 0xbef30288    r9 = 0x00000009   r10 = 0xadcd0880    fp = 0x00000001
     sp = 0xbef301b8    pc = 0xaf56d895
    Found by: call frame info
12  telephony.so!RIL::ProcessSolicited [RIL.cpp : 1115 + 0x13]
     r4 = 0xad7eca20    r5 = 0xadcd0880    r6 = 0xbef30348    r7 = 0xaf56d541
     r8 = 0x9f1e1e34    r9 = 0x0000000c   r10 = 0x00000009    fp = 0xb17e91b8
     sp = 0xbef30338    pc = 0xaf566ff7
    Found by: call frame info
13  telephony.so!RIL::ProcessResponse [RIL.cpp : 1078 + 0x7]
     r4 = 0x9fafad30    r5 = 0x9f1e1e34    r6 = 0xad7eca20    r7 = 0xbef303c4
     r8 = 0x00000001    r9 = 0x00000001   r10 = 0xbef30510    fp = 0xb17e91b8
     sp = 0xbef30370    pc = 0xaf56706b
    Found by: call frame info
14  telephony.so!ResponseRunnable::Run [RIL.cpp : 121 + 0x3]
     r4 = 0x9fafad30    r5 = 0x00000000    r6 = 0xbef303b8    r7 = 0xbef303c4
     r8 = 0x00000001    r9 = 0x00000001   r10 = 0xbef30510    fp = 0xb17e91b8
     sp = 0xbef30380    pc = 0xaf56bca3
    Found by: call frame info
15  libxul.so!mozilla::tasktracer::TracedRunnable::Run [TracedTaskCommon.cpp : 114 + 0x3]
     r3 = 0xaf56bc91    r4 = 0x9fafad30    r5 = 0x00000000    r6 = 0xbef303b8
     r7 = 0xbef303c4    r8 = 0x00000001    r9 = 0x00000001   r10 = 0xbef30510
     fp = 0xb17e91b8    sp = 0xbef30388    pc = 0xb3f732ff
    Found by: call frame info
16  libxul.so!nsThread::ProcessNextEvent [nsThread.cpp : 994 + 0x3]
     r3 = 0xb3f73317    r4 = 0xb17e9160    r5 = 0x00000000    r6 = 0xbef303b8
     r7 = 0xbef303c4    r8 = 0x00000001    r9 = 0x00000001   r10 = 0xbef30510
     fp = 0xb17e91b8    sp = 0xbef30398    pc = 0xb2ea8d13
    Found by: call frame info
17  libxul.so!NS_InvokeByIndex [xptcinvoke_arm.cpp : 169 + 0x11]
     r4 = 0xb2ea8ae1    r5 = 0x00000002    r6 = 0xbef30408    r7 = 0xbef30410
     r8 = 0x0000000a    r9 = 0xbef304c0   r10 = 0x00000002    fp = 0xbef3046c
     sp = 0xbef303f8    pc = 0xb2eae76b
    Found by: call frame info
18  libxul.so!XPCWrappedNative::CallMethod [XPCWrappedNative.cpp : 2083 + 0xf]
     r3 = 0xbef30500    r4 = 0xbef30510    r5 = 0x00000002    r6 = 0x00000010
     r7 = 0x00000001    r8 = 0x0000000a    r9 = 0xbef304c0   r10 = 0x00000002
     fp = 0xbef3046c    sp = 0xbef30430    pc = 0xb3227f93
    Found by: call frame info
19  libxul.so!XPC_WN_CallMethod [XPCWrappedNativeJSOps.cpp : 1128 + 0x7]
     r4 = 0x00000001    r5 = 0xbef3060c    r6 = 0xbef306a8    r7 = 0xb4ec5250
     r8 = 0xa7d5c100    r9 = 0xbef306b8   r10 = 0x00000001    fp = 0xbef306c0
     sp = 0xbef305c0    pc = 0xb322baff
    Found by: call frame info
20  0xb0d0eeb2
     r4 = 0xa7d5afd0    r5 = 0xffffff88    r6 = 0xa928dfe0    r7 = 0xffffff88
     r8 = 0x00001844    r9 = 0xa1d5b3b0   r10 = 0x00000000    fp = 0xbef306c0
     sp = 0xbef30688    pc = 0xb0d0eeb4
    Found by: call frame info
```
	
	
### 2. Match to code
```
==>gecko/dom/telephony/ipc/TelephonyParent.cpp
626  nsresult TelephonyRequestParent::Callback::SendResponse(const IPCTelephonyResponse& aResponse)
627  {
628    return mParent.SendResponse(aResponse);
                      ^^^^^^^^^
629  }

==>/gecko/dom/telephony/ipc/TelephonyParent.cpp 

518  TelephonyRequestParent::SendResponse(const IPCTelephonyResponse& aResponse)
519  {
520    NS_ENSURE_TRUE(!mActorDestroyed, NS_ERROR_FAILURE);
521  
522    return Send__delete__(this, aResponse) ? NS_OK : NS_ERROR_FAI
                                               ^^^^^^
523  }

==>objdir-gecko/ipc/ipdl/PTelephonyRequest.cpp

bool
Transition(
        State from,
        mozilla::ipc::Trigger trigger,
        State* next)
{
   ...
    switch (from) {
    case __Dead:
        mozilla::ipc::LogicError("__delete__()d actor");
        return false;
```
### 3. root cause

Low memory lead to  `calllog`(pid 13355) abnormal terminated,  nsTelephonyService from Ril  use DialCallback to notify gecko. DialCallback hold TelephonyRequestParent(mParent) as reference,  
but at this moment,  TelephonyRequestParent had already being dealloced because of `calllog` terminated.

##### a. `Calllog` terminate because of memory over.
```
Line 3856443: 10-08 08:42:13.317 I/GonkMemoryPressure(13355): Checking to see if memory pressure is over.
Line 3856444: 10-08 08:42:13.317 I/GonkMemoryPressure(13355): Memory pressure is over.

10-08 08:42:17.816 I/GeckoConsole(  498): Content JS LOG: [PaymentManager][24193433.295] handling appterminated 

10-08 08:42:17.920 E/Gecko   (  498): mozalloc_abort: [Parent 498] ###!!! ABORT: __delete__()d actor: file /work/workspace/workspace/BTV_Release_Build/gecko/ipc/glue/ProtocolUtils.cpp, line 465
```

##### b. mParent (TelephonyRequestParent) alloc when init.
[========]


     TelephonyParent::AllocPTelephonyRequestParent    
                                   |                                                                                                                     new  TelephonyRequestParent                              nsTelephonyService
								   |                                                                    | 
	new TelephonyRequestParent::DialCallback         <-----  NotifyDialCallSuccess           
	(TelephonyRequestParent& mParent)
[========]

###### c.Dealloc when `calllog` terminate.
```
\#0  mozilla::dom::telephony::PTelephonyParent::DeallocSubtree (this=0xa034d7f0)
    at /local/code/quoin/objdir-gecko/ipc/ipdl/PTelephonyParent.cpp:1054
\#1  0xacd70a6a in mozilla::dom::PContentParent::DeallocSubtree (this=this@entry=0x9cc65800)
    at /local/code/quoin/objdir-gecko/ipc/ipdl/PContentParent.cpp:9689
\#2  0xacd7a50c in mozilla::dom::PContentParent::OnChannelClose (this=0x9cc65800)
    at /local/code/quoin/objdir-gecko/ipc/ipdl/PContentParent.cpp:8924
\#3  0xacc48cc0 in mozilla::ipc::MessageChannel::NotifyChannelClosed (this=this@entry=0x9cc65838)
    at /local/code/quoin/gecko/ipc/glue/MessageChannel.cpp:2240
\#4  0xacc48e40 in mozilla::ipc::MessageChannel::Close (this=this@entry=0x9cc65838)
    at /local/code/quoin/gecko/ipc/glue/MessageChannel.cpp:2227
\#5  0xacc5b2ce in mozilla::ipc::PBackgroundChild::Close (this=this@entry=0x9cc65800)
    at /local/code/quoin/objdir-gecko/ipc/ipdl/PBackgroundChild.cpp:130
\#6  0xad739f20 in mozilla::dom::ContentParent::ShutDownProcess (this=0x9cc65800, 
    aMethod=aMethod@entry=mozilla::dom::ContentParent::CLOSE_CHANNEL) at /local/code/quoin/gecko/dom/ipc/ContentParent.cpp:1802
\#7  0xad739fe8 in mozilla::dom::ContentParent::RecvFinishShutdown (this=<optimized out>)
    at /local/code/quoin/gecko/dom/ipc/ContentParent.cpp:1852
\#8  0xacd88990 in mozilla::dom::PContentParent::OnMessageReceived (this=0x9cc65800, msg__=...)
    at /local/code/quoin/objdir-gecko/ipc/ipdl/PContentParent.cpp:6433
\#9  0xacc42b42 in mozilla::ipc::MessageChannel::DispatchAsyncMessage (this=0x9cc65838, aMsg=...)
    at /local/code/quoin/gecko/ipc/glue/MessageChannel.cpp:1672
\#10 0xacc48140 in mozilla::ipc::MessageChannel::DispatchMessage (this=this@entry=0x9cc65838, aMsg=...)
    at /local/code/quoin/gecko/ipc/glue/MessageChannel.cpp:1607
\#11 0xacc48b0e in mozilla::ipc::MessageChannel::OnMaybeDequeueOne (this=0x9cc65838)
    at /local/code/quoin/gecko/ipc/glue/MessageChannel.cpp:1571
\#12 0xadb24d62 in mozilla::tasktracer::TracedTask::Run (this=0x9ccbc160)
    at /local/code/quoin/gecko/tools/profiler/tasktracer/TracedTaskCommon.cpp:145
\#13 0xacc30c6a in MessageLoop::RunTask (this=0xab61f320, task=0x9ccbc184)
    at /local/code/quoin/gecko/ipc/chromium/src/base/message_loop.cc:349
\#14 0xacc33ace in MessageLoop::DeferOrRunPendingTask (this=<optimized out>, pending_task=...)
    at /local/code/quoin/gecko/ipc/chromium/src/base/message_loop.cc:357
\#15 0xacc33b58 in MessageLoop::DoWork (this=0xab61f320) at /local/code/quoin/gecko/ipc/chromium/src/base/message_loop.cc:444
\#16 0xacc3f22a in mozilla::ipc::DoWorkRunnable::Run (this=<optimized out>) at /local/code/quoin/gecko/ipc/glue/MessagePump.cpp:227
\#17 0xadb24d26 in mozilla::tasktracer::TracedRunnable::Run (this=0x9d06cc40)
    at /local/code/quoin/gecko/tools/profiler/tasktracer/TracedTaskCommon.cpp:114
\#18 0xaca49652 in nsThread::ProcessNextEvent (this=0xaa1830c0, aMayWait=<optimized out>, aResult=0xbe8a6607)
```
### 4.  Solution.
   Replace mParent from reference to pointer and check it vaild before sendResponse. 
   
   See: https://git.kaiostech.com/KaiOS/gecko48/-/commit/4ebec9393da846432b0bf0a2f3a3938610aa9ba0
 

***A simple test, Reference still can be called after the memory free***

```c
 class A {
public:
	A(){
		printf("constructor!\n");
	};
	~A(){
		printf("destructor!!\n");
	};
	bool mParam = false;
private:
	char* pStr;
};

int main() {
  A* pA = new A();
  pA->mParam = true;
  A& refA = *pA;
  printf("%p, %d\n", &refA, refA.mParam);
  delete pA;
  printf("%p, %d\n", &refA, refA.mParam);
  return 0;
}
```
##### print:

constructor!
0x564cd899ae70, 1
destructor!!
0x564cd899ae70, 0
