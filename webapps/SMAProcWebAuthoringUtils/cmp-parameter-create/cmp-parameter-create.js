define("DS/SMAProcWebAuthoringUtils/cmp-parameter-create/cmp-parameter-create",["DS/SMAProcWebCommonControls/Polymer","DS/SMAProcWebCommonControls/utils","UWA/Core","DS/SMAProcWebCMMUtils/SMAJSCMMUtils","DS/SMAProcWebContents/WUXControlUtil","DS/SMAProcWebAuthoringUtils/ParameterUIUtil","DS/SMAProcWebCMMUtils/SMAJSCMMDataFlowUtils","DS/Utilities/KeyboardUtils","DS/SMAProcWebCMMUtils/SMAJSCMMDataFlowUtilsNLSUtils","DS/Controls/TooltipModel","text!DS/SMAProcWebAuthoringUtils/cmp-parameter-create/cmp-parameter-create.html","i18n!DS/SMAProcWebCMMUtils/assets/nls/SMAJSCMMDataFlowUtilsNLS","DS/SMAProcWebCommonControls/import!DS/SMAProcSPUI/sp-notification/sp-notification.html","css!DS/SMAProcWebAuthoringUtils/cmp-parameter-create/cmp-parameter-create.css"],function(a,j,l,b,g,c,i,n,m,k,e,h){j.registerDomModule(e);var d,f="Multiline";d=window.Polymer;return d({is:"cmp-parameter-create",properties:{_dataContainer:{type:Object},datatypes:{type:Array,value:[]},maxArrayDims:{type:Number,value:4},modes:{type:Array},structures:{type:Array},parameterToModify:{type:Object,value:null},_modifyMode:{type:Boolean,value:false},_parameterCount:{type:Number,value:1},multiMode:{type:Boolean,value:false},deletedDataFlows:{type:Array},_parameter:{type:Object,value:{parameterCount:1,name:"",structure:"",datatype:"",value:"",plmObject:undefined,dimensions:1,resizableDims:false,mode:"",choices:[],expression:"",description:"",arraySize1:1,arraySize2:1,arraySize3:1,arraySize4:1,dataSubType:1}},_controls:{type:Object,value:{nameControl:undefined,modeControl:undefined,dataTypeControl:undefined,valueControl:undefined,choicesControl:undefined,expressionControl:undefined,arraySize1Control:undefined,arraySize2Control:undefined,arraySize3Control:undefined,arraySize4Control:undefined,multilineControl:undefined}}},destroy:function(){},setDataContainer:function(q,p){this.addEventListener("sp-error",function(r){if(r.detail.message){this.$.notification.logMessage({type:"error",text:r.detail.message,autoRemove:false})}}.bind(this));this.deletedDataFlows=[];var o;if(p&&p.length===1){this._modifyMode=true;this.parameterToModify=p[0];o=this.setParameterToModify(p[0]);this._parameter=o;this._buildView(o)}else{if(p&&p.length>1){this._parameters=p;this._buildModeEditView()}else{this._reset(q,true);o=this._parameter;this._buildView(o)}}this._dataContainer=q},_buildModeEditView:function(){this.$.containercreate.dataset.mode="multi";var o=c.getValidModes();this._multiMode=c.getDefaultMode(o);this._controls.modeControl=this._createControl("ComboBox",this._multiMode,{choices:o},"mode",{location:this.$.mode,customClass:"control-container"},this.setMultiModeMode.bind(this))},_buildView:function(v){this.$.containercreate.dataset.mode="single";var p,s,u,r="";if(this.multiMode&&!this._modifyMode){this._createControl("spinBoxEditor",v.parameterCount,{choices:"",type:"Integer",minValue:1,maxValue:1000},"parameterCount",{location:this.$.count,customClass:"control-container"},this.onCountChange.bind(this));var t=new l.Element("span",{styles:{"padding-left":"10px","font-size":"16px",color:"gray"}});t.classList.add("fonticon");t.classList.add("fonticon-info");t.tooltipInfos=new k({title:m.translate("Parameter.AddMultipleParameters.Limit"),allowUnsafeHTMLTitle:false,allowUnsafeHTMLLongHelp:false});t.tooltipInfos.initialDelay=0;t.inject(this.$.count)}else{this.$.count.classList.add("hidden")}this._createControl("lineEditor",v.name,{},"name",{location:this.$.name,customClass:"control-container"},this.onNameChange.bind(this));p=c.getValidStructures();this._createControl("ComboBox",v.structure,{choices:p,readonly:this._modifyMode},"structure",{location:this.$.structure,customClass:"control-container"},this.onStructureChange.bind(this));this._controls.modeControl=this._createControl("ComboBox",v.mode,{choices:c.getValidModes()},"mode",{location:this.$.mode,customClass:"control-container"},this.onModeChange.bind(this));s=c.getValidTypes(v.structure);this._controls.dataTypeControl=this._createControl("ComboBox",v.datatype,{choices:s},"datatype",{location:this.$.datatype,customClass:"control-container"},this.onDataTypeChange.bind(this));u=this._parameter.dataSubType===0;this._controls.multilineControl=this._createControl("toggle",u,{},f,{location:this.$.multiline,customClass:"toggle-container"},this.onMultilineChange.bind(this));this.createValueControl(v.structure,v.datatype);this._createControl("editor",v.description,{},"description",{location:this.$.description,customClass:"control-container"});if(this._modifyMode&&this._parameter.structure!=="Array"||!this._modifyMode){this._controls.expressionControl=this._createControl("lineEditor",v.expression,{},"expression",{location:this.$.expression,customClass:"control-container"},this.onExpressionChange.bind(this));if(this._modifyMode&&this._parameter.choices){if(this._parameter.choices.length>0){for(var q=0;q<this._parameter.choices.length;q++){r=r+this._parameter.choices[q]+"\n"}}}else{r=this._parameter.choices}var o=h["Parameter.choice.tooltip"];this._controls.choicesControl=this._createControl("editor",r,{tooltip:o},"choices",{location:this.$.choices,customClass:"control-container"},this.onChoicesChange.bind(this))}this._clearUI(this._parameter.structure,this._parameter.datatype)},_createControl:function(s,t,o,p,u,r){var q;q=g.createControl(undefined,s,t,o,u);q.addEventListener("onChange",function(w){var v;if(r){v=w.options?w.options.value:w.detail.newObject;r&&r(v,q)}else{this.set("_parameter."+p,w.options.value)}}.bind(this));q.addEventListener("onClear",function(v){v.preventDefault();v.stopImmediatePropagation();this._parameter.plmObject=undefined}.bind(this));return q},onModeChange:function(s){var o=[];var p={name:"Mode",value:s};if(this.parameterToModify){o=this._getModeChangeDataFlowErrorMessage([this.parameterToModify],p)}if(this.parameterToModify&&o.length>0){var r=m.translate("Dataflow.ModeChangeDeleteMapping",this.parameterToModify.getName())+"\n";for(var q=0;q<o.length;q++){r+="\n\t"+o[q]}r+="\n\n"+m.translate("Dataflow.ModeChangeConfirmation",this.parameterToModify.getName());this.$.modifyMessage.innerText=r;this.$.mappedParameterDialog.show();this.$.mappedParameterDialog.modifiedParameter={updateOptions:p}}else{this.setMode(s)}},onResizableDimensionChange:function(u){var q=0,t="[",v=[];var p={name:"resizableDims",value:u};if(this.parameterToModify){var o=this.parameterToModify.isSizable();for(q=0;q<this._parameter.dimensions;q++){t+=this._parameter["arraySize"+(q+1)];if(q<(this._parameter.dimensions-1)){t+=","}}t+="]";this.parameterToModify.setSizable(u);v=this._getSizableChangeDataFlowErrorMessage([this.parameterToModify],p,t);this.parameterToModify.setSizable(o)}if(this.parameterToModify&&v.length>0){var s=m.translate("Dataflow.SizableChangeDeleteMapping",this.parameterToModify.getName())+"\n";for(var r=0;r<v.length;r++){s+="\n\t"+v[r]}s+="\n\n"+m.translate("Dataflow.SizableChangeConfirmation",this.parameterToModify.getName());this.$.modifyMessage.innerText=s;this.$.mappedParameterDialog.show();this.$.mappedParameterDialog.modifiedParameter={updateOptions:p}}else{this.setResizable(u)}},onArraySizeOneChange:function(o){this.onArraySizeChange(1,o)},onArraySizeTwoChange:function(o){this.onArraySizeChange(2,o)},onArraySizeThreeChange:function(o){this.onArraySizeChange(3,o)},onArraySizeFourChange:function(o){this.onArraySizeChange(4,o)},onArraySizeChange:function(p,s){var t=[];var o={name:"arraySize",index:p,value:s};if(this.parameterToModify&&!this._parameter.resizableDims){t=this._getSizableChangeDataFlowErrorMessage([this.parameterToModify],o)}if(this.parameterToModify&&t.length>0){var r=m.translate("Dataflow.DimensionChangeDeleteMapping",p,this.parameterToModify.getName())+"\n";for(var q=0;q<t.length;q++){r+="\n\t"+t[q]}r+="\n\n"+m.translate("Dataflow.DimensionChangeConfirmation",p,this.parameterToModify.getName());this.$.modifyMessage.innerText=r;this.$.mappedParameterDialog.show();this.$.mappedParameterDialog.modifiedParameter={updateOptions:o}}else{this.setArraySizes("arraySize"+p,s)}},_getModeChangeDataFlowErrorMessage:function(t,q){var s=t[0].getId();var p=t[0].getName();var r,o=[];if(b.Mode.client[q.value]!==b.Mode.InOut){r=i.getInValidDataFlowsForParameters(q,t);r.fromSide.error.forEach(function(u){this.deletedDataFlows.push(u);var x=u._fromParameter.getId()===s?p:u._fromParameter.getName();var v=u._toParameter.getId()===s?p:u._toParameter.getName();var w=u._toParameter.getParent().getName();o.push(x+" -> "+w+"."+v)}.bind(this));r.toSide.error.forEach(function(u){this.deletedDataFlows.push(u);var x=u._fromParameter.getId()===s?p:u._fromParameter.getName();var v=u._toParameter.getId()===s?p:u._toParameter.getName();var w=u._fromParameter.getParent().getName();o.push(v+" <- "+w+"."+x)}.bind(this))}return o},_getSizableChangeDataFlowErrorMessage:function(u,r,q){var s,o=[];var t=u[0].getId();var p=u[0].getName();s=i.getInValidDataFlowsForParameters(r,u,undefined,q);s.fromSide.error.forEach(function(v){this.deletedDataFlows.push(v);var y=v._fromParameter.getId()===t?p:v._fromParameter.getName();var w=v._toParameter.getId()===t?p:v._toParameter.getName();var x=v._toParameter.getParent().getName();o.push(y+" -> "+x+"."+w)}.bind(this));s.toSide.error.forEach(function(v){this.deletedDataFlows.push(v);var y=v._fromParameter.getId()===t?p:v._fromParameter.getName();var w=v._toParameter.getId()===t?p:v._toParameter.getName();var x=v._fromParameter.getParent().getName();o.push(w+" <- "+x+"."+y)}.bind(this));return o},onMultiModeChange:function(s,t){var o=[];var p={name:"Mode",value:s};o=this._getModeChangeDataFlowErrorMessage(this._parameters,p);if(o.length>0){var r=m.translate("Dataflow.MultiModeChangeDeleteMapping")+"\n";for(var q=0;q<o.length;q++){r+="\n\t"+o[q]}r+="\n\n"+m.translate("Dataflow.MultiModeChangeConfirmation");this.$.modifyMessage.innerText=r;this.$.mappedParameterDialog.show();this.$.mappedParameterDialog.modifiedParameter={updateOptions:p,callback:t}}else{t(true)}},setMultiModeMode:function(o){this._multiMode=o},changeParameterProperties:function(){var o=this.$.mappedParameterDialog.modifiedParameter.updateOptions;var p=this.$.mappedParameterDialog.modifiedParameter.callback;if(o.name==="Mode"&&this._parameters&&this._parameters.length>1){p&&p(true);this.$.mappedParameterDialog.modifiedParameter.callback=undefined}else{if(o.name==="Mode"){this.setMode(o.value)}else{if(o.name==="Type"){this.setDataType(o.value)}else{if(o.name==="resizableDims"){this.setResizable(o.value)}else{if(o.name==="arraySize"){this.setArraySizes(o.name+String(o.index),o.value)}else{if(o.name==="dataSubType"){this.setDataSubType(b.DataSubType.client[o.value])}}}}}}this.$.mappedParameterDialog.hide()},onCancelConfirmation:function(p){var o=this.$.mappedParameterDialog.modifiedParameter.updateOptions;var q=this.$.mappedParameterDialog.modifiedParameter.callback;p.stopImmediatePropagation();if(this._parameters&&this._parameters.length>1){q&&q(false);this.$.mappedParameterDialog.modifiedParameter.callback=undefined}else{if(o.name==="dataSubType"){if(o.value===""||o.value===false||o.value===b.DataSubType.client.None){this.set("_parameter.dataSubType",b.DataSubType.client.Multiline);this._controls.multilineControl.checkFlag=true}else{this.set("_parameter.dataSubType",b.DataSubType.client.None);this._controls.multilineControl.checkFlag=false}}else{this._controls.modeControl.value=this._parameter.mode;this._controls.dataTypeControl.value=this._parameter.datatype;this._controls.resizableDims&&(this._controls.resizableDims.checkFlag=this._parameter.resizableDims);this._controls.arraySize1&&(this._controls.arraySize1.value=this._parameter.arraySize1);this._controls.arraySize2&&(this._controls.arraySize2.value=this._parameter.arraySize2);this._controls.arraySize3&&(this._controls.arraySize3.value=this._parameter.arraySize3);this._controls.arraySize4&&(this._controls.arraySize4.value=this._parameter.arraySize4)}}this.$.mappedParameterDialog.hide()},setMode:function(o){this.set("_parameter.mode",o)},setResizable:function(o){this.set("_parameter.resizableDims",o)},setArraySizes:function(p,o){this.set("_parameter."+p,o)},setDataSubType:function(o){this.set("_parameter.dataSubType",o);if(o===b.DataSubType.client.Multiline){this._controls.multilineControl.checkFlag=true}else{if(o===""||o===b.DataSubType.client.None){this._controls.multilineControl.checkFlag=false}}this._createValueTag(o)},setDataType:function(o){this.set("_parameter.datatype",o);this.set("_parameter.value",c.getDefaultValueByType(this._parameter.datatype));this.set("_parameter.expression","");this.set("_parameter.choices",[]);this._resetChoicesExpression();if(this._parameter.structure==="Scalar"){this._createValueTag()}this._clearUI(this._parameter.structure,o);this._reset(this._dataContainer,false,false,true)},onPreserveCloseConfirmation:function(o){o.stopPropagation();this._controls.dataTypeControl.value=this._parameter.datatype},onPreserveMappings:function(p){p.stopPropagation();var o=this.$.preserveMappingDialog.modifiedParameter.updateOptions;if(o.name==="Type"){this.setDataType(o.value)}this.$.preserveMappingDialog.hide()},onPreserveModify:function(p){p.stopPropagation();var o=this.$.preserveMappingDialog.modifiedParameter.updateOptions;if(o.name==="Type"){this.setDataType(o.value)}this.$.preserveMappingDialog.hide()},onCountChange:function(p){p=Math.round(p);var o=this._parameter.name.replace(/\d+$/,"");this._parameter.parameterCount=p;if(p>1){this._parameter.name=o;this.$.name.querySelector("span").textContent="Prefix: ";this.$.name.querySelector("input").value=this._parameter.name}else{if(p===1){this._parameter.name=c.getNextName(this._dataContainer,o);this.$.name.querySelector("span").textContent="Name: ";this.$.name.querySelector("input").value=this._parameter.name}}},setNextParameterName:function(){var p=this._parameter.name.replace(/\d+$/,"")?this._parameter.name.replace(/\d+$/,""):this.$.name.querySelector("input").value;var o=this._parameter.parameterCount;if(o===1){this._parameter.name=c.getNextName(this._dataContainer,p);this.$.name.querySelector("input").value=this._parameter.name}else{this._parameter.name=p}},onNameChange:function(s,q){var p,o=c.validateParameterName(this._dataContainer,s,this._parameter.name);p=s;if(!o.isValid){var r=!(this.parameterToModify&&(this.parameterToModify._name===s));if(r){this.error=true;this.$.notification.logMessage({type:"error",text:o.errorMsg,autoRemove:true})}p=o.validValue}q.value=p;this.set("_parameter.name",p)},onStructureChange:function(r){var o,s,q=[],p;this.set("_parameter.structure",r);this.set("_parameter.expression","");this.set("_parameter.choices",[]);this._resetChoicesExpression();s=c.getValidTypes(r);for(p=0;p<s.length;p+=1){q.push({labelItem:s[p],valueItem:s[p]});if(s[p]===this._parameter.datatype){o=p}}this._controls.dataTypeControl.elementsList=q;this._controls.dataTypeControl.selectedIndex=o;this._reset(this._dataContainer,false,true);this._clearUI(this._parameter.structure,this._parameter.datatype);this.createValueControl(this._parameter.structure,this._parameter.datatype)},createValueControl:function(o){if(o==="Scalar"){this.$.arrayValues.classList.add("hidden");this._createValueTag()}else{if(o==="Array"){this._createDimensionsTag()}}},onValueChange:function(p){var o;if(this._parameter.datatype==="Object"){o=p;this.updateObjectParameter(p)}else{if(this._parameter.datatype==="Real"||this._parameter.datatype==="Integer"){o=Number(p)}else{o=p}this.set("_parameter.value",o)}},updateObjectParameter:function(o){if(o){this._parameter.plmObject=o}else{this._parameter.plmObject=undefined}},onDataTypeChange:function(x){if(this.parameterToModify){var v=[],z=[],w=[],A="",q={name:"Type",value:x},u=this;var p=this.parameterToModify.getDataType();var y=this.parameterToModify.getValue();this.parameterToModify.setDataType(b.DataType.client[x]);v=i.getInValidDataFlowsForParameters(q,[this.parameterToModify]);this.parameterToModify.setDataType(p);this.parameterToModify.setValue(y);var r=this.parameterToModify.getId();var o=this.parameterToModify.getName();v.fromSide.error.forEach(function(B){this.deletedDataFlows.push(B);var E=B._fromParameter.getId()===r?o:B._fromParameter.getName();var C=B._toParameter.getId()===r?o:B._toParameter.getName();var D=B._toParameter.getParent().getName();z.push("\n"+E+" -> "+D+"."+C)}.bind(this));v.fromSide.warning.forEach(function(B){var E=B._fromParameter.getId()===r?o:B._fromParameter.getName();var C=B._toParameter.getId()===r?o:B._toParameter.getName();var D=B._toParameter.getParent().getName();w.push("\n"+E+" -> "+D+"."+C)});v.toSide.error.forEach(function(B){this.deletedDataFlows.push(B);var E=B._fromParameter.getId()===r?o:B._fromParameter.getName();var C=B._toParameter.getId()===r?o:B._toParameter.getName();var D=B._fromParameter.getParent().getName();z.push("\n"+C+" <- "+D+"."+E)}.bind(this));v.toSide.warning.forEach(function(B){var E=B._fromParameter.getId()===r?o:B._fromParameter.getName();var C=B._toParameter.getId()===r?o:B._toParameter.getName();var D=B._fromParameter.getParent().getName();w.push("\n"+C+" <- "+D+"."+E)});if(z.length>0){A=m.translate("Dataflow.DatatypeChangeDeleteMappingError",u.parameterToModify.getName())+"\n";for(var t=0;t<z.length;t++){A+="\t"+z[t]}this.$.modifyMessage.innerText=A;this.$.mappedParameterDialog.modifiedParameter={updateOptions:q};this.$.mappedParameterDialog.show()}else{if(w.length>0){A=m.translate("Dataflow.DatatypeChangeDeleteMappingWarning",u.parameterToModify.getName())+"\n";for(var s=0;s<w.length;s++){A+="\t"+w[s]}this.$.preserveMessage.innerText=A;this.$.preserveMappingDialog.show();this.$.preserveMappingDialog.modifiedParameter={updateOptions:q}}else{this.setDataType(x)}}}else{this.setDataType(x)}},getChoicesArray:function(r){var p=r.trim().split("\n");var q=[];if(r.trim()){for(var o=0;o<p.length;o++){q.push(c.parseValueByType(this._parameter.datatype,p[o].trim()))}}return q},getChoicesString:function(o){return o.join("\n")},onChoicesChange:function(p){var q,o,r;r=this.getChoicesArray(p);q=c.validateChoicesOption(r,this._parameter.datatype);if(!q.isValid){this.error=true;this.$.notification.logMessage({type:"error",text:q.errorMsg,autoRemove:true})}if(q.validArrayValue&&q.validArrayValue.length>=1){if(this._parameter.value&&q.validArrayValue.indexOf(this._parameter.value.toString())!==-1){o=this._parameter.value}else{o=q.validArrayValue[0]}this.set("_parameter.value",o);this.set("_parameter.choices",q.validArrayValue)}else{this.set("_parameter.choices",[])}this._controls.choicesControl.value=this.getChoicesString(this._parameter.choices);this.createValueControl(this._parameter.structure,this._parameter.datatype)},onArrayDimensionChange:function(p){var o,q;if(!this._modifyMode){this._parameter.arraySize1=1;this._parameter.arraySize2=1;this._parameter.arraySize3=1;this._parameter.arraySize4=1}this.set("_parameter.dimensions",p);this.$.dimensionsControls.innerHTML="";for(o=1;o<=p;o++){if(o===1){this._controls.arraySize1=this._createControl("spinBoxEditor",this._parameter.arraySize1,{choices:"",type:"Integer",minValue:1,maxValue:1000},"arraySize1",{location:this.$.dimensionsControls,customClass:""},this.onArraySizeOneChange.bind(this))}else{q=new l.Element("span",{"class":"multiplier",text:" X "});this.$.dimensionsControls.appendChild(q);if(o===2){this._controls.arraySize2=this._createControl("spinBoxEditor",this._parameter.arraySize2,{choices:"",type:"Integer",minValue:1,maxValue:1000},"arraySize2",{location:this.$.dimensionsControls,customClass:""},this.onArraySizeTwoChange.bind(this))}if(o===3){this._controls.arraySize3=this._createControl("spinBoxEditor",this._parameter.arraySize3,{choices:"",type:"Integer",minValue:1,maxValue:1000},"arraySize3",{location:this.$.dimensionsControls,customClass:""},this.onArraySizeThreeChange.bind(this))}if(o===4){this._controls.arraySize4=this._createControl("spinBoxEditor",this._parameter.arraySize4,{choices:"",type:"Integer",minValue:1,maxValue:1000},"arraySize4",{location:this.$.dimensionsControls,customClass:""},this.onArraySizeFourChange.bind(this))}}}},_createValueTag:function(){var q,v,o,w,y;this.$.scalarValues.innerHTML="";w=new l.Element("span",{"class":"custom-header",text:"Value:"});this.$.scalarValues.appendChild(w);o={Type:this._parameter.datatype,Choices:this._parameter.choices,Expression:this._parameter.expression,Value:this._parameter.value,Multiline:this._parameter.dataSubType};q=g.decideEditor(o,false,"parameterCreate");if(this._parameter.datatype==="Real"||this._parameter.datatype==="Integer"){v=Number(this._parameter.value)}else{v=this._parameter.value}if(this._modifyMode&&q==="contentchooser"){var r,s,p,x,u,t=this.parameterToModify;if(t.getValue()&&t.getValue()._data){r=t.getValue()._data.busType;if(r===undefined){r=t.getValue()._data.objectTypeValue}s=t.getValue()._data.dataelements&&t.getValue()._data.dataelements.title&&t.getValue()._data.dataelements.title.value[0].value;p=t.getValue()._data.dataelements&&t.getValue()._data.dataelements.name&&t.getValue()._data.dataelements.name.value[0].value;x=t.getValue()._data.displayName;u=t.getValue()._data.objectId}if(s===""){s=p}else{if(s===undefined){s=x}}y={displayName:s,busType:r,objectId:u}}else{y={choices:this._parameter.choices,type:this._parameter.datatype}}this._controls.valueControl=this._createControl(q,v,y,"value",{location:this.$.scalarValues,customClass:"control-container"},this.onValueChange.bind(this));this.updateValueFieldForExpression(this._parameter.expression)},_reset:function(r,q,o,p){if(q){this._modifyMode=false;this._parameters=undefined;this.parameterToModify=undefined;this._parameter.parameterCount=1;this._parameter.name=c.getNextName(r);this._parameter.structure=c.getDefaultStructure();this._parameter.mode=c.getDefaultMode(c.getValidModes());this._parameter.datatype=c.getDefaultType(c.getValidTypes(this.datatypes));this._parameter.description="";this._parameter.dataSubType=1}if(q||o){this._parameter.dimensions="1";this._parameter.arraySize1=1;this._parameter.arraySize2=1;this._parameter.arraySize3=1;this._parameter.arraySize4=1;this._parameter.resizableDims=false;this._parameter.value=c.getDefaultValueByType(this._parameter.datatype);this._parameter.plmObject=c.getDefaultValueByType(this._parameter.datatype);this._parameter.expression="";this._parameter.choices=[];this._parameter.dataSubType=1}if(q||p){this._parameter.value=c.getDefaultValueByType(this._parameter.datatype);this._parameter.plmObject=c.getDefaultValueByType(this._parameter.datatype);this._parameter.expression="";this._parameter.choices=[];this._parameter.dataSubType=1}},setParameterToModify:function(o){var p,q=[];q.name=o.getName();q.description=o.getDescription();q.expression=o.getExpression();q.structure=o._getStructureName();q.mode=o._getModeName();q.datatype=o._getDataTypeName();if(q.structure==="Array"){p=o.getDimensions();q.dimensions=p.length;q.resizableDims=o.isSizable();q.arraySize1=Number(p[0]);q.arraySize2=p.length>1?Number(p[1]):0;q.arraySize3=p.length>2?Number(p[2]):0;q.arraySize4=p.length>3?Number(p[3]):0}else{if(q.structure==="Scalar"){q.choices=o.getLimits();q.value=o.getValue();if(q.datatype==="Object"){q.plmObject=c.getContentChooserObjectByPLMObject(o.getValue());if(q.plmObject){q.value=q.plmObject.displayName}else{q.value=""}}if(o.getDataSubType()===b.DataSubType.client.Multiline){q.dataSubType=b.DataSubType.client.Multiline}}}return q},_createDimensionsTag:function(){var p=[],o;this.$.arrayValues.classList.remove("hidden");this.$.scalarValues.innerHTML="";for(o=1;o<=this.maxArrayDims;o++){p.push(o)}this.$.dimensions.removeChild(this.$.dimensions.lastChild);this._createControl("ComboBox",this._parameter.dimensions,{choices:p,readonly:this._modifyMode},"dimensions",{location:this.$.dimensions,customClass:"control-container"},this.onArrayDimensionChange.bind(this));this.$.resizableDims.removeChild(this.$.resizableDims.lastChild);this._controls.resizableDims=this._createControl("toggle",this._parameter.resizableDims,{},"resizableDims",{location:this.$.resizableDims,customClass:"toggle-container"},this.onResizableDimensionChange.bind(this));this.onArrayDimensionChange(this._parameter.dimensions)},onExpressionChange:function(){if(this._controls.expressionControl){var o=this._controls.expressionControl.value;this._parameter.expression=o;this.updateValueFieldForExpression(o)}},updateValueFieldForExpression:function(q){var o=this._parameter.datatype;if(q){var p=h["Parameter.expression.tooltip"];if(o==="Timestamp"){this._controls.valueControl.hide();this._controls.valueControl.setAttribute("title",p)}else{this._controls.valueControl.elements.container.setAttribute("title",p);this._controls.valueControl.disabled=true;this._controls.valueControl.value=null}}else{if(o==="Timestamp"){this._controls.valueControl.setAttribute("title","");this._controls.valueControl.show()}else{this._controls.valueControl.elements&&this._controls.valueControl.elements.container.setAttribute("title","");this._controls.valueControl.disabled=false}}},onMultilineChange:function(t){var u,q,w,v=[];var p=t?b.DataSubType.client.Multiline:b.DataSubType.client.None;this.setDataSubType(p);if(this.parameterToModify){var r=this.parameterToModify.getId();var o=this.parameterToModify.getName();q={name:"dataSubType",value:p};u=i.getInValidDataFlowsForParameters(q,[this.parameterToModify]);u.fromSide.error.forEach(function(x){this.deletedDataFlows.push(x);var A=x._fromParameter.getId()===r?o:x._fromParameter.getName();var y=x._toParameter.getId()===r?o:x._toParameter.getName();var z=x._toParameter.getParent().getName();v.push(A+" -> "+z+"."+y)}.bind(this));u.toSide.error.forEach(function(x){this.deletedDataFlows.push(x);var A=x._fromParameter.getId()===r?o:x._fromParameter.getName();var y=x._toParameter.getId()===r?o:x._toParameter.getName();var z=x._fromParameter.getParent().getName();v.push(y+" <- "+z+"."+A)}.bind(this));if(v.length>0){w=m.translate("Dataflow.MultilineChangeDeleteMapping",this.parameterToModify.getName())+"\n";for(var s=0;s<v.length;s++){w+="\n\t"+v[s]}w+="\n\n"+m.translate("Dataflow.MultilineChangeConfirmation",this.parameterToModify.getName());this.$.modifyMessage.innerText=w;this.$.mappedParameterDialog.show();this.$.mappedParameterDialog.modifiedParameter={updateOptions:q}}else{this._parameter.dataSubType=p}}else{this._parameter.dataSubType=p}},onKeyUp:function(o){switch(o.keyCode){case n.ENTER:case n.ESCAPE:o.preventDefault();o.stopImmediatePropagation();break;default:}},createParameter:function(){var o=1;if(!isNaN(this._parameter.parameterCount)&&parseInt(this._parameter.parameterCount)>=1){o=parseInt(this._parameter.parameterCount)}if(o===1){return c.createParameter(this._dataContainer,this._parameter)}return c.createParameters(this._dataContainer,this._parameter,this._parameter.parameterCount,this._parameter.name)},modifyParameters:function(q){var p;if(this._parameters&&this._parameters.length>1){this.onMultiModeChange(this._multiMode,function(r){if(r){q(c.modifyParameters(this._parameters,{Mode:this._multiMode}),this.deletedDataFlows)}else{q(false)}}.bind(this))}else{var o=this.parameterToModify.getName()===this._parameter.name||!c.isParameterWithNameExists(this._dataContainer,this._parameter.name,false);if(this._dataContainer&&o){p=c.modifyParameter(this.parameterToModify,this._parameter);q([p],this.deletedDataFlows)}else{if(!o){this.set("_parameter.name",this.parameterToModify.getName());q(false)}}}},_isExpressionAllowed:function(o,p){if(o==="Scalar"&&c.getDataTypeExpressionAllowed().indexOf(p)!==-1){return true}return false},_isChoicesAllowed:function(o,p){if(o==="Scalar"&&c.getDataTypeChoicesAllowed().indexOf(p)!==-1){return true}return false},_isDataSubTypeAllowed:function(o,p){if(o==="Scalar"&&p==="String"){return true}return false},_clearUI:function(o,p){if(o&&p){if(this._isChoicesAllowed(o,p)){this.$.choices.classList.remove("hidden")}else{this.$.choices.classList.add("hidden")}if(this._isExpressionAllowed(o,p)){this.$.expression.classList.remove("hidden")}else{this.$.expression.classList.add("hidden")}if(this._isDataSubTypeAllowed(o,p)){this.$.multiline.classList.remove("hidden");this._controls.multilineControl.checkFlag=this._parameter.dataSubType===b.DataSubType.client.Multiline}else{this.$.multiline.classList.add("hidden")}}},_resetChoicesExpression:function(){if(this._controls.choicesControl){this._controls.choicesControl.value=this.getChoicesString(this._parameter.choices)}if(this._controls.expressionControl){this._controls.expressionControl.value=this._parameter.expression}}})});