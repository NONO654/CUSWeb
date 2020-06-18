/*!  Copyright 2017 Dassault Systemes. All rights reserved. */
define(["DS/SMAPoweredByTracker/ad-tracker/selectors","DS/SMAPoweredByTracker/ad-tracker/ad-usage","DS/SMAPoweredByState/ad-state-app/selectors","DS/SMAPoweredByState/ad-state-domain-jobs/selectors","DS/SMAPoweredByState/ad-state-domain-job-types/selectors","text!DS/SMAPoweredByTracker/assets/alerts_to_track.json"],function(k,h,e,j,n,c){var g={},f="START_JOB_FULFILLED",b=JSON.parse(c),l="SMAPoweredBy.usageStats.",i={abaqus:"Abaqus"},a=".",p={abaqus:"ABAQUS",custom:"CUSTOM"};function o(s,u){var r=null,q=null,t=p.custom;r=j.jobTypeId(s,u);q=n.jobTypeWithID(s,r);if(q&&q.title&&q.title===i.abaqus){t=p.abaqus}return t}function d(s,r){var t=null,q=l+r.type+a;if(b.indexOf(r.code)!==-1){t=q+r.code}else{if(r.type===f&&r.payload&&r.payload.jobID){t=q+o(s,r.payload.jobID)}}return t}function m(q){return function(r){return function(v){var s,w,u,t;t=k.isTrackingEnabled();if(t){w=d(q.getState(),v);if(w){u=h.getCounterTracker({item:w,tenant:e.currentPlatformID(q.getState())});if(u&&u.inc){u.inc()}}}s=r(v);return s}}}g["default"]=m;return g});