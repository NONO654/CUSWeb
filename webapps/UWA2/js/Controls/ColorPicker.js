define("UWA/Controls/ColorPicker",["UWA/Core","UWA/Event","UWA/Color","UWA/Controls/Picker","UWA/Controls/Drag","UWA/Controls/Input"],function(c,h,a,f,g,e){var b=function(l,j){var k=l&&l.match(j?/^\s*#?([0-9a-f]{0,6})/i:/^\s*#?(|[0-9a-f]{3}|[0-9a-f]{6})\s*$/i);return k?k[1]:""};var i=g.extend({defaultOptions:{touchSnap:0,mouseSnap:0},start:function(j){this.move(j,{distance:0,x:0,y:0})},move:function(j,o){var m=this.element.getOffsets(),l=this.element.getSize();var k={x:j.x-m.x,y:j.y-m.y};k.x=Math.max(0,Math.min(l.width,k.x));k.y=Math.max(0,Math.min(l.height,k.y));var n={x:k.x/l.width,y:k.y/l.height};this.options.pickCallback(n,k);if(this.options.hideCursorWhileDragging&&o.distance>0&&!this.injectedStylesheet){this.injectedStylesheet=c.createElement("style",{html:"* { cursor: none !important; }"}).inject(document.body)}},reset:function(){if(this.injectedStylesheet){this.injectedStylesheet.remove();this.injectedStylesheet=null}this._parent()}});var d=f.extend({name:"uwa-colorpicker",previouslyDisplayedHue:null,options:{button:{tag:"div","class":"uwa-colorpicker-well"},dropdownOptions:{},defaultValue:null},init:function(j){this._parent(j);if(/\bdark\b/.test(this.options.className)&&!this.options.dropdownOptions.className){this.options.dropdownOptions.className="dark"}this.elements.well=this.elements.button.getElement(".uwa-colorpicker-well");this._updateWell();this.syncInput()},_getColor:function(){var k=this.getValue()||this.options.defaultValue||"ffffff";if(this._color){var l=a.parse(k);var j=this._color;if(!c.equals(j.toRGBString(),l.toRGBString())){this._color=null}else{return this._color}}return a.parse(k)},_setColor:function(j){this.setValue(j.toHSLString())},setValue:function(j){if(typeof(j)==="string"){j=a.parse(j)}if(!j){return}this._color=j;this._parent(j.toHexString().substring(1))},buildContent:function(){var j=this,l=/\bdark\b/.test(this.options.className);var k=c.createElement("div",{html:[this.elements.slPicker=c.createElement("div",{"class":this.getClassNames("-sl-picker"),html:[this.elements.slPickerCanvas=c.createElement("canvas",{"class":this.getClassNames("-sl-picker-canvas"),width:220,height:220}),this.elements.slPickerCursor=c.createElement("div",{"class":this.getClassNames("-sl-picker-cursor")})]}),this.elements.huePicker=c.createElement("div",{"class":this.getClassNames("-hue-picker"),html:[this.elements.huePickerArrows=c.createElement("div",{"class":this.getClassNames("-hue-picker-arrows")}),this.elements.huePickerCanvas=c.createElement("canvas",{"class":this.getClassNames("-hue-picker-canvas"),width:26,height:220})]}),this.elements.hexField=c.createElement("div",{"class":this.getClassNames("-hex-field"),html:[this.elements.hexFieldInput=new e.Text({_root:false,className:this.getClassNames("-hex-field-input")}),c.createElement("span",{"class":this.getClassNames("-hex-field-icon"),text:"#"})]}),this.elements.clearButton=c.createElement("div",{"class":this.getClassNames("-clear-button")+" uwa-icon","data-icon":"p",events:{mousedown:function(m){h.preventDefault(m)},click:function(m){h.preventDefault(m);j.setValue(j.options.defaultValue)}}}),new e.Button({_root:false,value:"Done",className:this.getClassNames("-done-button")+(l?" extra-dark-grey":" dark-grey"),events:{onMouseDown:function(m){h.preventDefault(m)},onClick:function(){j.toggle(false)}}})]});new i({element:this.elements.slPicker,hideCursorWhileDragging:true,pickCallback:function(q){var p=q.x,n=(1-q.y);var m=(2-p)*n;var o;if(n>0){o=p*n;o/=m<=1?m:2-m;o=o||0;m/=2}else{o=q.x}m*=100;o*=100;j._setColor(j._getColor().cloneWith({l:m,s:o}))}});new i({element:this.elements.huePicker,pickCallback:function(m){j._setColor(j._getColor().cloneWith({h:(1-m.y)*360}))}});this.elements.hexField.getElement(".uwa-input-hex-field input").addEvents({keyup:function(){j._readInputFieldValue()},input:function(){j._readInputFieldValue()},change:function(){j._readInputFieldValue()}});this.elements.dropdown.elements.inner.addEvent("mousedown",function(m){if(m.target===this){h.preventDefault(m)}});this._renderHuePicker();this.syncInput();return k},_renderHuePicker:function(){var o=37;var l=this.elements.huePickerCanvas,m=this.elements.huePickerCanvas.getContext("2d");var p=m.createLinearGradient(0,0,0,l.height);for(var k=0;k<o;k++){var n=k/(o-1);var j=a.parse("hsl("+((1-n)*360)+", "+100+"%, "+50+"%)");p.addColorStop(n,j.toHSLString())}m.fillStyle=p;m.fillRect(0,0,l.width,l.height)},_updateWell:function(){this.elements.well.setStyle("background",this._getColor().toHSLString())},_updateSlPicker:function(){var k=this.elements.slPickerCanvas;var j=this.elements.slPickerCanvas.getContext("2d");var o=this._getColor();var s=o.toObject();if(this.previouslyDisplayedHue!==s.h){this.previouslyDisplayedHue=s.h;var u=j.createLinearGradient(0,0,k.width,0);var p=a.parse("hsl("+s.h+", "+100+"%, "+50+"%)");u.addColorStop(0,"white");u.addColorStop(1,p.toHSLString());j.fillStyle=u;j.fillRect(0,0,k.width,k.height);var r=j.createLinearGradient(0,0,0,k.height);r.addColorStop(0,"transparent");r.addColorStop(1,"black");j.fillStyle=r;j.fillRect(0,0,k.width,k.height)}var m=this.elements.slPickerCursor,q,t,n,l;q=s.l/100*2;t=s.s/100*((q<=1)?q:2-q);l=(q+t)/2;if(q>0){n=(2*t)/(q+t)}else{n=s.s/100}n=Math.round(n*this.elements.slPickerCanvas.width);l=Math.round((1-l)*this.elements.slPickerCanvas.height);m.setStyle("left",n+"px");m.setStyle("top",l+"px");m.setStyle("background",o.toHexString())},_updateHuePicker:function(){var k=this.elements.huePickerArrows;var j=(360-this._getColor().toObject().h)/360;var l=j*this.elements.huePickerCanvas.height;k.setStyle("top",Math.round(l)+"px")},_updateHexField:function(){var j=this.elements.hexFieldInput;if(this.getValue()){var l=this._getColor();var k=a.parse(j.getValue());if(!k||!c.equals(l.toRGBString(),k.toRGBString())){j.setValue(l.toHexString().substring(1))}}else{j.setValue("")}},_updateDefaultButton:function(){this.elements.clearButton.toggle(c.is(this.options.defaultValue)&&this.options.defaultValue!==this.getValue())},syncInput:function(){if(this.elements.well){this._updateWell()}if(this.elements.slPicker){this._updateSlPicker();this._updateHuePicker();this._updateHexField();this._updateDefaultButton()}if(this.elements.value){var j=this.getValue();j=j?j.toLowerCase():"";this.elements.value.setText(j)}},_readInputFieldValue:function(){var l=this.elements.hexFieldInput.getValue();var m=b(l,true);if(m!==l){this.elements.hexFieldInput.setValue(m)}if(m.length===3||m.length===6){var k=m.replace(/\-/g,"Z");var j=a.parse(k);this.setValue(j)}},toggle:function(j){this._parent.apply(this,arguments);if(j===false){this._dispatchOnChange()}}});return c.namespace("Controls/ColorPicker",d,c)});