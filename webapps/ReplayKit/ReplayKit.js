define("DS/ReplayKit/ReplayKit",["UWA/Core","DS/HybridInfraCore/HybridApp","DS/CoreEvents/Events"],function(d,c,a){var b=d.Class.extend({init:function(e){window.ReplayKitDelegate=null;var f=this;c.onDeviceReady(function(g){c.addDelegate("ReplayKitDelegate").then(function(h){window.ReplayKitDelegate=h;window.ReplayKitDelegate.addJsonWatch(f.onReceivedJson)},console.error)})},onReceivedJson:function(e){if("RECORD_STOPPED" in e){a.publish({event:"/HybridInfra/onRecordStopped",data:{previewInfo:e.RECORD_STOPPED,}})}},startRecordScreen:function(){window.ReplayKitDelegate.execute("startRecordScreen",null).then(function(e){},console.error)},stopRecordScreen:function(){window.ReplayKitDelegate.execute("stopRecordScreen",null).then(function(e){},console.error)},showPreview:function(){window.ReplayKitDelegate.execute("showPreview",null).then(function(e){},console.error)}});return b});