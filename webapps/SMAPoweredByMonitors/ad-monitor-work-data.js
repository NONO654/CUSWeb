/*!  Copyright 2017 Dassault Systemes. All rights reserved. */
define(["DS/Redux/Redux","DS/SMAPoweredByMonitors/ad-monitor-manager","DS/SMAPoweredByState/ad-state-store","DS/SMAPoweredByState/ad-state-domain-work-data/actions","DS/SMAPoweredByState/ad-state-domain-work-data/selectors","DS/SMAPoweredByState/ad-state-domain-jobs/selectors","DS/SMAPoweredByState/ad-state-wc-adapter","DS/SMAPoweredByState/ad-state-defs","DS/SMAPoweredByState/ad-state-redux-observer"],function(a,k,d,j,l,f,r,b,e){var q={};var p="execdir",c="tail",h=null,t=null,g=null,n=null,o=null;function m(y){var v=d.getStore(),x=false,u=new e(),z=function(A){var B;if(A===b.PersistenceOperation.READING){x=true}else{if(x){x=false;y.execDirUnsubscribe();y.execDirUnsubscribe=null;h=null;o=y.execDirID;if(n){B=n;n=null;q.stopExecDirMonitor(B)}}}},w=l.workDataWithID(v.getState(),y.execDirID);if(w){h=y.execDirID;y.execDirUnsubscribe=u.observeStore({store:v,select:function(B){var A=l.workDataWithID(B,y.execDirID);return(A&&A.persistenceOperation)?A.persistenceOperation:null},onChange:z,compareFunc:function(C,A){var B=C?C:null;return B===A}});a.bindActionCreators(j,v.dispatch).refreshWorkData(y.execDirID,y.credentials)["catch"](function(){if(g&&g.execDirID===y.execDirID){g=null}q.stopExecDirMonitor(y.execDirID)})}else{q.stopExecDirMonitor(y.execDirID)}}function i(y){var u=d.getStore(),v=l.workDataWithID(u.getState(),y.execDirID),x=function(){var B;a.bindActionCreators(j,u.dispatch).clearExecDirFileMonitor(y.execDirID);t=null;if(o===y.execDirID){o=null}if(g){B=g;g=null;q.startExecDirMonitor(B.execDirID,B.interval)}},A=function(){a.bindActionCreators(j,u.dispatch).clearExecDirFileMonitor(y.execDirID);t=null;if(o===y.execDirID){o=null}},z=function(){x()},w=function(){A()};if(v){t=y.execDirID;r.callStopFileMonitor({execDir:v,onComplete:z,onFailure:w})}}function s(v){var w=function(x){if(v.credentials&&v.execDir){a.bindActionCreators(j,d.getStore().dispatch).setExecDirCredentials(v.execDir.id,v.credentials)}if(v.onComplete){v.onComplete(x)}},u=function(x){if(v.onFailure){v.onFailure((x===r.ErrorCodes.COS_RUNAS_CREDENTIALS_ERROR)?b.ErrorCodes.RUNAS_CREDENTIALS_ERROR:x)}};r.callTail({execDir:v.execDir,filePath:v.filePath,credentials:v.credentials,start:v.start,numLines:v.numLines,onComplete:w,onFailure:u})}q.startExecDirMonitor=function(z,v,w){var x=null,y=(typeof v!=="undefined")&&(v!==null)?v:60,u=(typeof w!=="undefined")?w:null;if(!g||(g.execDirID!==z)){if(!h){if(!t){if(n===z){n=null}if(o!==z){n=o;g=null;x=k.startMonitor(p,z,{execDirID:z,credentials:u},m,i,y)}}else{g={execDirID:z,credentials:u,interval:y}}}else{if(h!==z){n=h;g={execDirID:z,credentials:u,interval:y}}}}return x};q.stopExecDirMonitor=function(u){if((n!==u)&&o){if(!t){if(!h){n=null;k.stopMonitor(p,u)}else{n=u}}else{if(t!==u){n=u}}}};q.stopAllExecDirMonitors=function(){k.stopMonitorsOfType(p)};q.startTailMonitor=function(y,z,w,x,u,v,A){var B,C;B=l.workDataExecDir(d.getStore().getState(),y.id);C=l.workDataRelPath(d.getStore().getState(),y.id);return k.startMonitor(c,y.id,{execDir:B,credentials:(typeof A!=="undefined")?A:null,filePath:C,start:((typeof v!=="undefined")&&v)?v:0,numLines:((typeof u!=="undefined")&&(u||(u===0)))?u:50,onComplete:z,onFailure:w},s,null,x)};q.stopTailMonitor=function(u){k.stopMonitor(c,u.id)};q.stopAllTailMonitors=function(){k.stopMonitorsOfType(c)};return q});