/*!  Copyright 2016 Dassault Systemes. All rights reserved. */
window.require(["DS/SMAProcADUI/ad-execdir/ADExecDir"],function(b){var a=window.Polymer,f=window.DS;var e=null,c=null,d=null;e=function(){if(this.model){a.dom(this.$.lastModifiedDate).textContent=this.formatDate(this.model.lastModified)}else{a.dom(this.$.lastModifiedDate).textContent=""}};c=function(){var h={id:this.model.modelID,type:"folder",name:this.model.name,lastModified:this.model.lastModified,path:this.model.path,relativePath:this.model.relativePath,station:this.model.station};if(typeof this.model.mdType!=="undefined"&&this.model.mdType){h.mdType=this.model.mdType}var g=this.model;while(typeof g!=="undefined"&&g&&!(g instanceof b.ADExecDir)){g=g.parent}if(g instanceof b.ADExecDir){h.credentials=g.credentials}var i={modelSource:this.modelSource,model:h};return i};d=function(){this._modelChangedFunction=e.bind(this);this._dragDataFunction=c.bind(this)};f.SMAProcADUI=f.SMAProcADUI||{};f.SMAProcADUI.ADMultiviewFolder=a({is:"ad-multiview-folder",ready:function(){return d.apply(this,arguments)},_computeTitle:function(g){var h="";if(g){if(g.name){h+=g.name}if(g.description){h+=":"+g.description}}return h},behaviors:[f.SMAProcSP.SPBase,f.SMAProcADUI.ADMultiviewItem,f.SMAProcADUI.FormatUtilities]})});