/*!  Copyright 2015 Dassault Systemes. All rights reserved. */
(function(){var a,c,b,e={valuechange:"valuechange"},d;b=function(){this._valueMap={};this._callbacks=[]};b.prototype.get=function(f){return this._valueMap.hasOwnProperty(f)?this._valueMap[f]:undefined};b.prototype.set=function(f,j){this._valueMap[f]=j;var h={name:f,value:j};for(var g=0;g<this._callbacks.length;g++){this._callbacks[g].func.call(this._callbacks[g].that,h)}};b.prototype.subscribe=function(f){this._callbacks.push(f)};b.prototype.unsubscribe=function(){};d=new b();a=function(f){if(f.name===this.name){this.fire(e.valuechange,{name:this.name,value:f.value})}};c=function(){var g=null,h=null;var i=this.attributes.getNamedItem("name");var f=this.attributes.getNamedItem("value");if(i){g=i.value}if(f){h=f.value}if(g&&h){d.set(g,h)}d.subscribe({func:a.bind(this),that:this});if(g&&h){this.fire(e.valuechange,{name:g,value:h})}};window.SPVariable=Polymer({is:"sp-variable",properties:{name:{type:String,value:""},value:{notify:true,observer:"valueChanged"}},ready:function(){return c.apply(this,arguments)},getValue:function(){return d.get(this.name)},setValue:function(f){this.value=f;d.set(this.name,f)},valueChanged:function(f){if(this.getValue()!==f){d.set(this.name,f)}}});window.DS.SMAProcSP.SPVariableHelper={properties:{globals:{type:Object,value:function(){return{}}}},ready:function(){var f=this;f.DOM(f).find(window.SPVariable.prototype.is).forEach(function(g){f.set("globals."+g.name,g.getValue())})},onVariableValueChange:function(f){if(f&&f.detail&&f.detail.name&&this.globals){this.set("globals."+f.detail.name,f.detail.value)}}}}(this));