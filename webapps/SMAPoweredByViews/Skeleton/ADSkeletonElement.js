/*!  Copyright 2018 Dassault Systemes. All rights reserved. */
define("DS/SMAPoweredByViews/Skeleton/ADSkeletonElement",["UWA/Core","WebappsUtils/WebappsUtils","DS/SMAPoweredByState/ad-state-loading-utils","DS/W3DXComponents/Skeleton","DS/W3DXComponents/ContentSet","DS/SMAPoweredByViews/Skeleton/Renderers/ADJobRenderer","DS/SMAPoweredByViews/Skeleton/Renderers/ADFileRenderer","css!DS/SMAPoweredByViews/Skeleton/ADSkeletonElement"],function(i,e,f,b,o,c,p){var j={};var a={JOBS:"jobs",FILES:"files"},k,h,g=function(){return new Promise(function(q){f.loadWebComponents([e.getWebappsBaseUrl()+"SMAPoweredByViews/ad-tail-log-view/ad-tail-log-view.html",e.getWebappsBaseUrl()+"SMAPoweredByViews/ad-ace-editor/ad-ace-editor.html",e.getWebappsBaseUrl()+"SMAPoweredByViews/ad-credentials-dialog/ad-credentials-dialog.html",e.getWebappsBaseUrl()+"SMAPoweredByViews/ad-file-history/ad-file-history.html"],["DS.SMAPoweredByViews.ADTailLogView",null,null,"DS.SMAPoweredByViews.ADFileHistory"],function(){q("loaded")})})},n=function(q){if(k){k.setHeight(q)}},l=function(){var s=document.documentElement,r=document.querySelector(".appHeaderContainer"),q=null;if(!r){q=79}else{q=r.clientHeight}n(s.clientHeight-q-2)},d=function(){if(!h){h=setTimeout(function(){h=null;l()},10)}},m=function(){var s={jobs:c.getRenderer(),files:p.getRenderer()},r={};var q=b.extend({buildPanelContent:function(u){var v=u.node;var t=v.get("assignedModel");if(t){this.listenTo(t,{onItemRemoved:function(){this.slideBack()}})}return this._parent.apply(this,arguments)}});k=new q(s,r);window.addEventListener("resize",d,false)};j._getSkeleton=function(){return k};j.renderSkeleton=function(r,q){k.render().inject(r);g();if(q){k.setHeight(q)}k.container.style.opacity=1};j.switchCollection=function(r){var q=null;if(r===0){q=a.JOBS}else{if(r===1){q=a.FILES}}k.setRoute("/"+q+"/")};j.slideBack=function(){k.slideBack()};j.refresh=function(){k.refresh()};j.destroy=function(){k.destroy()};j.onLoad=function(){m()};return j});