require(["DS/UIKIT/Mask"],function(b){var a;a={is:"ra-loading",properties:{progress:{type:Number,value:0,observer:"_progressObserver",notify:true},showUI:{type:Boolean,value:false},message:{type:String,value:"Loading",observer:"_progressObserver",notify:true},lastUpdate:{type:Number,value:0},updateInterval:{type:Number,value:100}},_startProgress:function(){if(this.parent!==null&&!b.isMasked(this.parent)){this.showUI=true;b.mask(this.parentElement,{message:this.message+" ... "+this.progress+"%"})}},_endProgress:function(){if(this.parent!==null&&b.isMasked(this.parent)){b.unmask(this.parent);this.showUI=false}},_progressObserver:function(g,f){if(typeof this.parent==="undefined"||this.parent===null){this.parent=UWA.Element.getParent.call(this)}if(this.parent!==null){var c=Date.now();if(this.lastUpdate+this.updateInterval<c){this.lastUpdate=c;var e=b.isMasked(this.parent);if(!this.showUI&&!e){this._startProgress()}else{if(this.showUI&&e){var d=this.parentElement.querySelector(".mask-content .text");if(d!==null){d.textContent=this.message+" ... "+Math.ceil(this.progress*100)+"%"}if(this.progress>=1){this._endProgress()}}}}else{this.debounce("finalUpdate",function(){var i=b.isMasked(this.parent);if(!this.showUI&&!i){this._startProgress()}else{if(this.showUI&&i){var h=this.parentElement.querySelector(".mask-content .text");if(h!==null){h.textContent=this.message+" ... "+Math.ceil(this.progress*100)+"%"}if(this.progress>=1){this._endProgress()}}}},this.updateInterval)}}},_throttle:function(d,c){return function(){}}};window.Polymer(a)});