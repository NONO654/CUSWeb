/*!  Copyright 2017 Dassault Systemes. All rights reserved. */
define(["UWA/Promise","DS/Redux/Redux"],function(b,a){var f=function(){this._unsubscribeList=[]};f.ERROR_CODES={TIMED_OUT:"TIMED_OUT"};var e=window.Promise||b;function g(i,h){var j=null;if(typeof i==="undefined"&&typeof h==="undefined"){j=true}else{if(typeof i==="undefined"||typeof h==="undefined"){j=false}else{if(i&&h&&i.length===0&&h.length===0){j=true}else{if(i&&h&&i.length!==h.length){j=false}else{j=JSON.stringify(i)===JSON.stringify(h)}}}}return j}function d(i){var j,k=null,h=function(){var m=[i.store.getState()].concat(i.selectArguments),n=i.select.apply(null,m),l=false;if(i.unSubScribeCriteria){var o=i.unSubScribeCriteria(i.store.getState());if(o){k()}}if(i.compareFunc){if(!i.compareFunc(j,n)){l=true}}else{if(i.arrayCompare){if(!g(j,n)){l=true}}else{if(n!==j){l=true}}}if(l){j=n;i.onChange(j);l=false}};k=i.store.subscribe(h);h();return k}function c(h){return new e(function(n,m){var l=null,k,p=null,j=h.isResolved?h.isResolved:function(q){return q===null},i=function(q){if(h.checkError){k=h.checkError(h.store.getState());if(k!==null){if(p!==null){window.clearTimeout(p)}if(l){l()}m(k)}}if(j(q)){if(p!==null){window.clearTimeout(p)}if(l){l()}n()}};if(j(h.select(h.store.getState()))){n()}else{if(h.timeout){var o=function(){if(l){l()}k={code:f.ERROR_CODES.TIMED_OUT};m(k)};p=window.setTimeout(o,h.timeout)}l=d({store:h.store,select:h.select,onChange:i})}})}f.prototype.observeStore=function(h){var i=d(h);this._unsubscribeList.push({unsubscribe:i,callbackName:h.onChange.name});return i};f.prototype.waitFor=function(h){return c.apply(this,[h])};f.prototype.unsubscribeAll=function(){this._unsubscribeList.forEach(function(h){h.unsubscribe()});this._unsubscribeList.splice(0,this._unsubscribeList.length)};f.prototype.getBoundActions=function(i,h){return a.bindActionCreators(i,h)};return f});