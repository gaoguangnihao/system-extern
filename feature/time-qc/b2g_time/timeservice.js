/*
 * Copyright (c) 2013 Qualcomm Technologies, Inc.  All Rights Reserved.
 * Qualcomm Technologies Proprietary and Confidential.
 */

'use strict';

const {classes: Cc, interfaces: Ci, utils: Cu, results: Cr} = Components;

Cu.import('resource://gre/modules/XPCOMUtils.jsm');
Cu.import('resource://gre/modules/Services.jsm');
Cu.import('resource://gre/modules/ctypes.jsm');

const CID = Components.ID('{276e9542-d226-45e5-9ac7-31e1a8d96b28}');

function timeservice() {
  Services.obs.addObserver(this, 'system-clock-change', false);
  Services.obs.addObserver(this, 'xpcom-shutdown', false);
}

timeservice.prototype = {
  classID: CID,
  classInfo: XPCOMUtils.generateCI({classID: CID,
                                    classDescription: 'timeservice',
                                    interfaces: [Ci.nsIObserver]}),
  QueryInterface: XPCOMUtils.generateQI([Ci.nsIObserver]),

  observe: function(subject, topic, data) {
    switch (topic) {
    case 'xpcom-shutdown':
      Services.obs.removeObserver(this, 'xpcom-shutdown');
      Services.obs.removeObserver(this, 'system-clock-change');
      break;
    case 'system-clock-change':
      var deltaMs = parseInt(data, 10);
          dump('dhcui enter /timeservice.js status system-clock-change');
      try {
          var library = ctypes.open('/vendor/lib/libtime_genoff.so');
      } catch (e) {
          dump('dhcui libtime_genoff.so not found. ' + e);
      }

      const ATS_USER = 2;
      const TIME_MSEC = 1;
      const T_SET = 0;
      const T_GET = 1;
      let time_genoff_info = ctypes.StructType(
                               'time_genoff_info',
                               [{'time_bases_type': ctypes.int},
                                {'ts_val': ctypes.void_t.ptr},
                                {'time_unit_type': ctypes.int},
                                {'time_genoff_opr_type': ctypes.int}
                               ]);
      let time_genoff_operation = library.declare(
                                    'time_genoff_operation',
                                    ctypes.default_abi, ctypes.int,
                                    time_genoff_info.ptr
                                    );

      // Read current system time
      var time_set = new time_genoff_info;
      time_set.time_bases_type = ctypes.int(ATS_USER);
      time_set.ts_val = ctypes.cast(
                                    ctypes.int64_t(0).address(),
                                    ctypes.void_t.ptr
                                   );
      time_set.time_unit_type = TIME_MSEC;
      time_set.time_genoff_opr_type = T_GET;
      if (time_genoff_operation(time_set.address())) {
        dump('Error reading system time');
        dump('Error unable to set time. ' +
             'Time will be lost after reboot');
        return;
      }

      // Calculate new time
      var currentTime = ctypes.cast(time_set.ts_val,
                                    ctypes.int64_t.ptr).contents;
      var currentTimeJSInt = parseInt(currentTime.toString(), 10) +
                                      deltaMs;

      // Set system time
      time_set.time_bases_type = ctypes.int(ATS_USER);
      time_set.ts_val = ctypes.cast(
                                    ctypes.int64_t(currentTimeJSInt).address(),
                                    ctypes.void_t.ptr
                                   );
      time_set.time_unit_type = TIME_MSEC;
      time_set.time_genoff_opr_type = T_SET;
      if (time_genoff_operation(time_set.address())) {
        dump('Error setting generic offset:' + deltaMs);
        dump('Error unable to set time. ' +
             'Time will be lost after reboot');
      }
      break;
    }
  }
};

// JSDoc Inherited NSGetFactory XPCOM uses this to create components.
this.NSGetFactory = XPCOMUtils.generateNSGetFactory([timeservice]);
