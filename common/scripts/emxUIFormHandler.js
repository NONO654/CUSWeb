var HashMap = function () {
	this._container = {};
}

HashMap.prototype =  { 

	Get : function (key) { 
		return this.Contains(key) ? this._container[key] : null; 
	} 
	, 
	Put : function(key,value) { 
		this._container[key] = value; 
	} 
	, 
	Contains : function(key) { 
		return key in this._container; 
	} 
	, 
	Remove : function(key) { 
		return this.Contains(key) ? delete this._container[key] : false; 
	} 
	, 
	ToString : function(sep) {
		var tostring = []; 
		sep = sep || ","; 
		for(var key in this._container) { 
			tostring.push("[ " + key + " = " + this._container[key] + " ]"); 
		} 
		return tostring.join(sep);
	}
	,
	IsValid : function(key) {
		return typeof this.Get(key) != "function";
	}
	,
	ToArray : function() {
		var arry = [];
		
		for(var key in this._container) {		
			if(this.IsValid(key)) {
				arry.push(this.Get(key));
			}
		}
		return arry;
	}
}

function Range(label,value)
{
	this.Label = label || null;
	this.Value = value || null;
}

Range.prototype = {
	
	IsValid : function() {
		return this.Value != null && this.Label != null;
	}
	,
	GetLabel : function() {
		return this.Label;
	}
	,
	GetValue : function() {
		return this.Value;
	}
}

function Setting(name,value) 
{
	this.Name  = name  || null;
	this.Value = value || null;
}

Setting.prototype = {
	
	IsValid : function() {
		return this.Name != null && this.Name != "";
	}
	,
	GetName : function() {
		return this.Name;
	}
	,
	GetValue : function() {
		return this.Value;
	}
}


var FieldFactory = function() {}

FieldFactory.Create = function() {

	return 	function (name,fieldType,inputtype,format)
	{		
		this.Name 		  	  = name || "";
		this.FieldType    	  = fieldType || "";
		this.InputType		  = inputtype || "";
		this.Format			  = format || "";		
		this.DisplayName  	  = this.Name + "Display";		
		this.OIDName		  = this.Name + "OID";
	    this.RefreshProgram   = null;
		this.RefreshFunction  = null;
		this.ChangeHandlers   = null;
		this.FocusHandlers	  = null;
		this.ActualValue  	  = null;
		this.DisplayValue 	  = null;
		this.IsEditable   	  = null;
	    this.ReadOnly		  = null;	    
		this.ActualField  	  = null;
		this.DisplayField 	  = null;				
		this.HandlerField     = null;
		this.ChooserField     = null;
		this.OIDField         = null;
		this.PreviousValue    = null;
		this.IsEditting		  = false;
		this.Validating		  = false;
		this.Settings		  = new HashMap();
		this.RangeValues      = [];
		this.FieldName		  = this.Name;
		this.FieldId		  = null;
		this.ConstructorExt();
	}
}

FieldFactory.CreateField = function (name,fieldType,inputtype,format,isUOMAttribute) {

	inputtype = ((inputtype && inputtype) != "" ? inputtype :  "textbox");
	fieldType = fieldType || "expression";
	format	  = format    || null;
	var field = null;
	var type  = "default";
	
	if(fieldType == "basic" || fieldType == "businessobject" || fieldType == "relationship" || fieldType == "attribute" || fieldType == "expression" || fieldType == "program" || fieldType == "Dynamic Attributes")
		type  = inputtype;
	else if (fieldType == "programHTMLOutput")
		type  = "htmloutput";
	
	if (format == "date" && inputtype == "textbox")
		type  = "date";
		
	if (isUOMAttribute == "true")
		type  = "units";
		
	if(type == "default" && inputtype == "textbox")
		type  = inputtype;
	
	switch(type)
	{
		case "textbox" :
		    field = new TextBoxField(name,fieldType,inputtype,format);
		    break;
		
		case "textarea" :
			 field = new TextAreaField(name,fieldType,inputtype,format);
		    break;
		
		case "dynamictextarea" : 
			field = new DynamicTextAreaField(name,fieldType,inputtype,format);
		    break;
		    
		case "checkbox" :
			 field = new CheckBoxField(name,fieldType,inputtype,format);
		    break;
		    
		case "radiobutton" :
			 field = new RadioButtonField(name,fieldType,inputtype,format);
		    break;
		    
		case "combobox" :
			 field = new ComboBoxField(name,fieldType,inputtype,format);
		    break;
		case "listbox" :
			 field = new ListBoxField(name,fieldType,inputtype,format);
		    break;
		case "htmloutput" :
			 field = new HtmlField(name,fieldType,inputtype,format);
		    break;
		    
		case "date" :
			 field = new DateField(name,fieldType,inputtype,format);
		    break;
		
		case "units" : 
			 field = new UOMAttributeField(name,fieldType,inputtype,format);
		    break;
		    
		default :
			field = new Field(name,fieldType,inputtype,format);
			break;
	}
	
	return field;
}

FieldFactory.Extend = function(destination, source) {
		
	var derived  = {};
	for (property in destination) {
		derived[property] = destination[property];
	}
	for (property in source) {
	    derived[property] = source[property];
	}
	return derived;
}

var Field = FieldFactory.Create();

Field.prototype =  {
	
	Type : "defaultField"
	,
	Settings : null
	,
	RangeValues : null	
	,
	ConstructorExt : function() { /* Not Implemented */ }
	,
	InitBegins     : function () { /* Not Implemented */ }
	,
	InitHandlers   : function () { /* Not Implemented */ }
	,
	InitValues     : function () { /* Not Implemented */ }
	,
	InitEnds       : function () { /* Not Implemented */ }
	,
	GetValue 	   : function(control,flag) { /* Not Implemented */ return null }
	,
	SetValue 	   : function(control,value,flag) { /* Not Implemented */ }
	,
	SetActualValue : function(actual) {
		this.ActualValue = actual || "";
	}
	,
	SetFieldName : function(name) {
		this.FieldName = name;
	}
	,
	SetFieldId : function(id) {
		this.FieldId = id;
	}
	,
	SetDisplayValue : function(display) {
		this.DisplayValue = display || "";
	}
	,	
	ValidateObject : function(valid) {
		return valid != null && valid.IsValid && valid.IsValid();
	}
	,
	AddSetting : function(setting) {
		if(this.ValidateObject(setting)) {
			this.Settings.Put(setting.GetName(),setting);
		}
	}
	,
	SetSettings : function(settings) {
		this.Settings = settings;
	}
	,
	GetSetting : function(name) {
		return this.Settings.Get(name);
	}
	,
	GetSettingValue : function(name) {
		var setting = this.GetSetting(name);
		return setting != null ? setting.GetValue() : null;
	}	
	,
	AddRange : function(range) {
		if(this.ValidateObject(range)) {
			this.RangeValues.push(range);
		}
	}
	,
	GetActualField : function()
	{
		return FormHandler.GetDOMField(this.Name);
	}
	,
	GetDisplayField : function()
	{
		return FormHandler.GetDOMField(this.DisplayName);
	}
	,
	GetOIDField : function()
	{
		return FormHandler.GetDOMField(this.OIDName);
	}
	,
	Init : function() {
		
		this.InitBegins();
		
		this.FillProperties();
		
		var actualField = this.GetActualField();
		if(actualField){
			this.ActualField = actualField;
		}
		
		var displayField = this.GetDisplayField();
		if(displayField){
			this.DisplayField  = displayField;
		}
		
		var oidField = this.GetOIDField();
		if(oidField){
			this.OIDField = oidField;
		}
		
		if(displayField){
			this.HandlerField  = displayField;
		}else if(actualField){
			this.HandlerField  = actualField;
		}
		
		this.InitHandlers();
		
		this.EventHandlers(this);
				
		this.InitValues();
		
		if(this.ActualValue == null) {
			var actualValue = this.GetActualValue();
			if(actualValue){
				this.ActualValue = actualValue; 
			}
		}
		if(this.DisplayValue == null) {
			var displayValue = this.GetDisplayValue();
			if(displayValue){
				this.DisplayValue = displayValue;
			} 
		}
		
		if(this.HandlerField){
			this.PreviousValue = this.GetValue(this.HandlerField,true);
		}
		
		this.UpdateState();
		
		this.InitEnds();
	}
	,	
	FillProperties : function() {
		var refreshProgram = this.GetSettingValue("Reload Program");
		var refreshFunction = this.GetSettingValue("Reload Function");
		
		if(refreshProgram && refreshProgram.length != 0){
			this.RefreshProgram   = refreshProgram;
			this.RefreshFunction  = refreshFunction;
		}
		
		var changeHandlers    = this.GetHandlers("OnChange Handler", ";");
		changeHandlers = changeHandlers.length == 0 ? this.GetHandlers("On Change Handler", ":") : changeHandlers;
		if(changeHandlers.length != 0){
			this.ChangeHandlers = changeHandlers;
		}
		
		var focusHandlers	  = this.GetHandlers("OnFocus Handler", ";");
		focusHandlers = focusHandlers.length == 0 ? this.GetHandlers("On Focus Handler", ":") : focusHandlers;
		if(focusHandlers.length != 0){
			this.FocusHandlers = focusHandlers;
		}
		
		var isEditable = this.GetSettingValue("Editable");
		if(isEditable){
			this.IsEditable = isEditable;
		}
		
		var readOnly = this.GetSettingValue("readonly");
		if(readOnly){
			this.ReadOnly = readOnly;
		}
		this.IsEditable   	  = !!this.IsEditable;
	}
	,
	ToValue : function (value) {
		return value == null || typeof value == "undefined" ? "" : value;
	},
	
	IsNullOrEmpty : function(value) {
		return this.ToValue(value) == "";
	}
	,
	GetHandlers : function (key , sep) {
		var handlers  = this.GetSettingValue(key);
		return !this.IsNullOrEmpty(handlers) ? handlers.split(sep) : [];
	}
	,
	EventHandlers : function (handler) {
		
		if(this.HandlerField == null) return;
	
		if(this.ChangeHandlers && this.ChangeHandlers.length > 0 && this.ValidateHandlers("Change",this.ChangeHandlers)) {
			this.ChangeHandlers = FormHandler.ConvertMethods(this.ChangeHandlers);
		}
		if(!(this.Settings && this.Settings._container["Type Ahead Validate"] && this.Settings._container["Type Ahead Validate"].Value)){
		emxUICore.addEventHandler(this.HandlerField,"change",function () { handler.HandleChangeEvent()});
		}
		
		if(this.FocusHandlers && this.FocusHandlers.length > 0 && this.ValidateHandlers("Focus",this.FocusHandlers)) {
			this.FocusHandlers  = FormHandler.ConvertMethods(this.FocusHandlers);
			emxUICore.addEventHandler(this.HandlerField,"focus",function() {handler.HandleFocusEvent()});
		}
		if(this.ChangeHandlers && this.ChangeHandlers.length > 0) {
			emxUICore.addEventHandler(this.HandlerField,"focus",function() {handler.FieldFocusEvent()});
			emxUICore.addEventHandler(this.HandlerField,"blur",function() {handler.FieldBlurEvent()});
		}
	}
	,
	FieldFocusEvent : function () {
	   this.IsEditting = true;
	}
	,
	FieldBlurEvent : function () {
	   this.IsEditting = false;
	}
	,
	HasChangeHandler : function () {
		return ( this.ChangeHandlers && this.ChangeHandlers.length > 0 );
	}
	,
	HandleFocusEvent : function () {
	   FormHandler.InvokeMethods( this.FocusHandlers, this.HandlerField, this.GetArgs(), "OnFocus", this.Name );
	}
	,
	GetArgs : function() {
	
		return [ this.FieldName, this.GetFieldValue(), this.FieldId ];
	}
	,
	HandleChangeEvent : function () {
		/* IR-078547V6R2012,IR-078959V6R2012 */
		//if(this.Validate() && this.HasChangeHandler())
		if(this.HasChangeHandler())
		{
			this.PreviousValue	=	this.GetValue(this.HandlerField,true);
			FormHandler.InvokeMethods(this.ChangeHandlers,this.HandlerField, this.GetArgs(), "OnChange", this.Name );
			this.Validating = false;
		} else {
			this.Validating = true;
		}
	}
	,
	FireChangeEvent : function() {
		if(this.HasChangeHandler() && this.HasFieldChanged()) 
		{
			this.FieldFocusEvent();
			this.HandleChangeEvent();
			this.FieldBlurEvent();
		}		
	}	
	,
	TrackChange : function () {
		return false;
	}
	,
	HasFieldChanged : function () {
		return !this.IsEditting && !this.Validating  && !this.IsEquals(this.PreviousValue,this.GetValue(this.HandlerField,true));
	}
	,
	IsEquals : function(prev,current) {
		return prev == current;
	}
	,
	GetPreviousValue : function () {
		return this.PreviousValue;
	}
	,
	ValidateHandlers : function (type,handlers) {
		var message = type + " Handler for Field : " + this.Name + " is not defined!!?";
		return FormHandler.ValidateJSHandlers(handlers,message);
	}
	,
	Validate : function() {
		return validateField(this.HandlerField);
	}	
	,
	GetActualValue : function () {
		return this.GetValue(this.ActualField,true);
	}
	,
	GetOIDValue : function () {
		return this.OIDField != null ? this.GetValue(this.OIDField,true) : null;
	}
	,
	GetDisplayValue : function () {
		return this.DisplayField != null ? this.GetValue(this.DisplayField,false) : null;
	}
	,	
	GetFieldValue : function () {
	
		var value 			  = {};
		value.current  		  = {};
		value.old	  		  = {};
		value.current.actual  = this.GetActualValue();
		value.current.display = this.GetDisplayValue();
		value.old.actual 	  = this.ActualValue;
		value.old.display 	  = this.DisplayValue;
		
		return value;
	}
	,	
	SetFieldValue : function (fieldValue,fieldDisplayValue) {
		fieldValue 		  = fieldValue || "";
		fieldDisplayValue = fieldDisplayValue || "";
		this.Validating   = false;
		this.SetValue(this.ActualField,fieldValue,true);
		if(this.DisplayField != null) this.SetValue(this.DisplayField,fieldDisplayValue,false);
		this.FireChangeEvent();
	}	
	,	
	GetHandler : function () {
		return this.DisplayField != null ? this.DisplayField : this.ActualField;
	}
	,
	CanEdit : function () {
	
		var editable = (this.HasChooser) ? (!this.HasAttribute(this.ChooserField,"disabled")) :  ((this.DisplayField != null && this.DisplayField.type != "hidden"
				&& !this.HasAttribute(this.DisplayField,"readOnly")) || (this.ActualField != null && this.ActualField.type != "hidden" && !this.HasAttribute(this.ActualField,"readOnly")));
	
		return this.IsEditable && (editable);
	}
	,
	HasAttribute : function(elm,atr) {
		var has = false;
		if(elm != null && atr != null) {
			var atrNode = elm.getAttribute(atr);
			has = (atrNode != null && atrNode != "undefined" && atrNode != false) ;
		}
		return has;
	}
	,
	UpdateState : function() {
		if(this.ReadOnly != null) {
			this.MakeEditable(!(this.ReadOnly.toLowerCase()== "true"));
		}
	}
	,
	MakeEditable : function (flag) {
		
		var field = null;
		if(this.DisplayField != null && this.DisplayField.type != "hidden")
		{
			field = this.DisplayField;
		}
		else if (this.ActualField != null && this.ActualField.type != "hidden")
		{
			field = this.ActualField;
		}
		this.IsEditable = flag;
		
		if(field != null) {
			this.ChangeAttributes(field,flag);
		}
	}
	,
	ChangeAttributes : function(field,flag) {
	
		if(flag) {
			if(field.className == "rte"){
				field.enableRTE();
			}
			else{
				 field.removeAttribute("readOnly");
				   field.style.backgroundColor = "";
				   if(this.ChooserField != null) {
					 this.ChooserField.removeAttribute("disabled");
				   }
			}	  
		} else {
			if(field.className == "rte"){
				field.disableRTE();
			}
			else{
				 field.setAttribute("readOnly","readOnly");
				   field.style.backgroundColor = "#EBEBE4";
				   if(this.ChooserField != null) {
					  this.ChooserField.setAttribute("disabled","true");
				   }
			}
		}
	}
	,
	GetRefreshData : function () {
		return this.CanRefresh() ? { Program : this.RefreshProgram,
			   Function : this.RefreshFunction,
			   Field : this.FieldName } : null;
	}
	,
	SetRefreshedValue : function(refresh) {
		this.SetFieldValue(refresh.SelectedValues,refresh.SelectedDisplayValues);
	}
	,
	RefreshFieldValue : function(refresh) {
		
		
		if(refresh != null)
		{
			refresh.SelectedValues        = refresh.SelectedValues == null ? "" : refresh.SelectedValues;
			refresh.SelectedDisplayValues = refresh.SelectedDisplayValues == null ? "" : refresh.SelectedDisplayValues;
			
			for(var i = 0 ; i < refresh.RangeValues.length; i++) {
				refresh.RangeValues[i] = refresh.RangeValues[i] == null ? "" : refresh.RangeValues[i];
		    }
		    
		    for(var i = 0 ; i < refresh.RangeDisplayValue.length; i++) {
				refresh.RangeDisplayValue[i] = refresh.RangeDisplayValue[i] == null ? "" : refresh.RangeDisplayValue[i];
		    }
		}
		
		this.SetRefreshedValue(refresh);
	}
	,
	CanRefresh : function() {
	
		return (this.RefreshProgram != null && this.RefreshProgram != "" &&
				this.RefreshFunction != null && this.RefreshFunction != "");
	}	
	,
	GetPostValue : function () {
		return [ { Name : this.Name, Value : this.GetActualValue() } ];
	}
}


var TextBoxField = FieldFactory.Create();

TextBoxField.prototype = FieldFactory.Extend( Field.prototype,  {
	
	Type : "TextBoxField"
	,
	ConstructorExt : function () {
		this.HasChooser = false;
		this.ChooserName = "btn" + this.Name;
	}
	,
	InitBegins : function() {
		this.ChooserField = FormHandler.GetDOMField(this.ChooserName);
		this.HasChooser   = this.ChooserField != null;
	}
	,
	GetValue : function(control,flag) {
		var value = null;
		
		return control != null ? control.value : null;
	}
	,
	SetValue : function(control,value,flag) {
		
		if(control != null) {
			if(control.className == "rte"){
				control.updateRTE(value);
			}else{
				control.value = value;
			}
			
		}
	}
	,
    // The following code is to call saveFieldObj function
    // when a chooser field is modified in emxTableEdit.jsp
    InitValues : function()
    {
        if(this.HasChooser && FormHandler.GetFormType() == "emxTable" )
        {
            var oThis = this;
            this.ChangeHandlers.push( function () {
                                      saveFieldObj(oThis.GetActualField());
                                      });
        }
    }
    ,
	TrackChange : function() {
		return this.HasChangeHandler() && this.HasChooser;
	}	
	,
	GetPostValue : function () {
		return [ { Name : this.DisplayName, Value :  this.GetDisplayValue() }, 
		         { Name : this.Name, Value :  this.GetActualValue()},
		         { Name : this.OIDName, Value : this.GetOIDValue() } ];
	}
});

var TextAreaField = FieldFactory.Create();
TextAreaField.prototype = FieldFactory.Extend( TextBoxField.prototype, {Type : "TextAreaField"});

var DynamicTextAreaField = FieldFactory.Create();
DynamicTextAreaField.prototype = FieldFactory.Extend( TextBoxField.prototype, {

	Type : "DynamicTextAreaField"
	,
	EventHandlers : function (handler) {

		if(this.HandlerField == null) return;

		if(this.ChangeHandlers && this.ChangeHandlers.length > 0 && this.ValidateHandlers("Change",this.ChangeHandlers)) {
			this.ChangeHandlers = FormHandler.ConvertMethods(this.ChangeHandlers);
		}
		
		emxUICore.addEventHandler(this.HandlerField,"change",function () { handler.HandleChangeEvent()});
		
		if(this.FocusHandlers && this.FocusHandlers.length > 0 && this.ValidateHandlers("Focus",this.FocusHandlers)) {
			this.FocusHandlers = FormHandler.ConvertMethods(this.FocusHandlers);
			emxUICore.addEventHandler(this.HandlerField,"focus",function() {handler.HandleFocusEvent()});
		}
	}
	,
	TrackChange : function() {
		return false;
	}
});

var UOMAttributeField = FieldFactory.Create();
UOMAttributeField.prototype = FieldFactory.Extend( Field.prototype, {
	
	Type : "UOMAttributeField"
	,
	ConstructorExt : function () {
		this.UnitField	= null;
		this.UnitName   = "units_"+this.Name;		
	}
	,
	InitBegins : function () {
		this.UnitField = FormHandler.GetDOMField(this.UnitName);
	}
	,
	InitHandlers : function() {
		var oThis = this;
		if(this.ChangeHandlers && this.ChangeHandlers.length > 0 && this.ValidateHandlers("Change",this.ChangeHandlers) && this.UnitField != null) {
			emxUICore.addEventHandler(this.UnitField,"change",function () { oThis.HandleChangeEvent()});
		}
	}
	,
	GetValue : function(control,flag) {
		var unitvalue = { value : null , unit : null};
		if(control != null) {
			unitvalue.value = control.value;
			if (this.UnitField != null){
				unitvalue.unit  = this.UnitField.value;
			}
			
		}
		return unitvalue;
	}
	,
	SetValue : function(control,unitvalue,flag) {
		
		if(control != null && unitvalue != null) {
			control.value = unitvalue.value;
			if(unitvalue.unit != null && unitvalue.unit != "undefined")
				this.UnitField.value = unitvalue.unit;
		}
	}
	,
	IsEquals : function(prev,current) {
		return prev != null && current != null && prev.value == current.value && prev.unit == current.unit;
	}
	,
	GetPostValue : function () {
		var unitvalue = this.GetActualValue();
		return [ { Name : this.Name, Value : unitvalue.value },{ Name : this.UnitName, Value : unitvalue.unit } ];
	}
	,
	ChangeAttributes : function(field,flag) {
	
		if(flag) {
		   field.removeAttribute("readOnly");
		   field.style.backgroundColor = "";
		   this.UnitField.removeAttribute("disabled");
		}
		else {
		   field.setAttribute("readOnly","readOnly");
		   field.style.backgroundColor = "#EBEBE4";
		   this.UnitField.setAttribute("disabled","true");
		}
	}
});

var DateField = FieldFactory.Create();
DateField.prototype = FieldFactory.Extend( Field.prototype, {
	
	Type : "DateField"
	,
	ConstructorExt : function() {
		this.DateChooser = null;
		this.CanKeyIn	 = false;
		this.DateHref    = null;
		this.DateAmPm    = null;
	}
	,
	CanEdit : function () {
		return this.IsEditable && ((this.DateChooser != null && this.HasAttribute(this.DateChooser,"href")));
	}
	,
	InitBegins : function() {
		this.DisplayName = this.Name;
		this.DateChooser = FormHandler.GetDOMField(this.Name + "_date");
		this.DateAmPm    = FormHandler.GetDOMField(this.Name + "AmPm");
		this.DateHref    = this.DateChooser != null ? this.DateChooser.getAttribute("href") : null;
		this.Name		 = this.DisplayName + "_msvalue";
	}
	,
	InitEnds : function() {		
		this.Name 		 = this.DisplayName;
		this.DisplayName += "_msvalue";
		this.CanKeyIn    = this.DisplayField != null ? !this.HasAttribute(this.DisplayField,"readOnly") : false;
		
		if(this.DateAmPm == null && this.DisplayField != null) {
			this.DateAmPm = document.createElement("input");
			this.DateAmPm.type  = "hidden";
			this.DateAmPm.name  = this.Name + "AmPm";
			this.DateAmPm.id    = this.Name + "AmPm";
		    this.DisplayField.parentNode.insertBefore(this.DateAmPm,this.DisplayField);
		}
	}
	,	
	GetValue : function (control,flag) {
		return control != null ? control.value : null ;
	}
	,
	SetValue : function (control,value,flag) {
		if(control != null) {
			control.value = value;
			
			if(flag) {
			   this.DateAmPm.value = value;
			}
		}
	}
	,
	GetPostValue : function () {
		return [ { Name : this.DisplayName, Value : this.GetActualValue() }, { Name : this.Name, Value : this.GetDisplayValue() } ];
	}
	,
	ChangeAttributes : function(field,flag) {
	
		if(flag) {
			if(this.CanKeyIn) {
		   		field.removeAttribute("readOnly");
		   		field.style.backgroundColor = "";
		   	}
		    if(this.DateChooser != null) {
		   	   this.DateChooser.setAttribute("href",this.DateHref);
		    }
		}
		else {
			if(this.CanKeyIn) {
		   		field.setAttribute("readOnly","readOnly");
		   		field.style.backgroundColor = "#EBEBE4";
		   	}
		   	if(this.DateChooser != null) {
		   	   this.DateChooser.removeAttribute("href");
		    }
		}
	}
	,
	TrackChange : function() {
		return this.HasChangeHandler() && this.DateChooser != null;
	}
});

var SelectionField = FieldFactory.Create();
SelectionField.prototype = FieldFactory.Extend( Field.prototype, {

	Type : "SelectionField"
	,	
	Init : function() {
			
		this.FillProperties();
		
		this.ActualField   = FormHandler.GetDOMFields(this.Name);
		this.DisplayField  = FormHandler.GetDOMFields(this.DisplayName);
		this.HandlerField  = this.DisplayField != null ? this.DisplayField : this.ActualField;
		
		this.EventHandlers(this);
		
		this.ActualValue  	  = this.GetActualValue();
		this.DisplayValue 	  = this.GetDisplayValue();
		this.PreviousValue	  = this.HandlerField != null ? this.GetValue(this.HandlerField,true) : null;
	}
	,
	EventHandlers : function(handler) {
		
		if(this.HandlerField == null) return;
		
		if(this.ChangeHandlers && this.ChangeHandlers.length > 0 && this.ValidateHandlers("Change",this.ChangeHandlers)) {
			this.ChangeHandlers = FormHandler.ConvertMethods(this.ChangeHandlers);
		}
		
		for(var i = 0 ; i < this.HandlerField.length ; i++) {
			emxUICore.addEventHandler(this.HandlerField[i],"click",function () { handler.FireChangeEvent()});
		}
		
		if(this.FocusHandlers && this.FocusHandlers.length > 0 &&  this.ValidateHandlers("Focus",this.FocusHandlers)) {
			this.FocusHandlers = FormHandler.ConvertMethods(this.FocusHandlers);
			for(var i = 0 ; i < this.HandlerField.length ; i++) {
				emxUICore.addEventHandler(this.HandlerField[i],"focus",function() {handler.HandleFocusEvent()});
			}
		}
	}
	,	
	ChangeAttributes : function(fields,flag) {
	
		if(flag) {
		  for(var i = 0 ; i < fields.length ; i++) {
		   	fields[i].removeAttribute("disabled");
		   }
		}
		else {
		  for(var i = 0 ; i < fields.length ; i++) {
		    fields[i].setAttribute("disabled","true");
		 }
		}
	}
	,
	HasAttribute : function(fields,atr) {
		var has = false;
		if(fields != null && fields.length > 0 && atr != null) {
			var atrNode = fields[0].getAttribute(atr);
			has = (atrNode != null && atrNode != "undefined");
		}
		return has;
	}
});

var CheckBoxField = FieldFactory.Create();
CheckBoxField.prototype = FieldFactory.Extend( SelectionField.prototype, {

	Type : "CheckBoxField"	
	,
	GetValue : function(control,flag) {
		var values = null;
		if(control != null) {
			values = [];
			for(var i = 0 ; i < control.length ; i++) {
				 if(control[i].checked){
				 	values.push(control[i].value);
				 }
			}
		}
		
		return values != null && values.length > 0 ? values.join(",") : null;
	}
	,
	SetValue : function(control,value,flag) {
		
		if(control != null && value != null) {
		
			values = [];
			try { values = eval("("+ value + ")"); } catch(e) {}
			
			for(var i = 0 ; i < control.length ; i++) {
				 
				 for(var l = 0 ; l < values.length ; l++) {
				 	
				 	if(control[i].value == values[l].value) {
				 		control[i].value = values[l].value;
				 		control[i].checked = values[l].checked || false;
				 	}
				 }
			}
		}
	}
});

var RadioButtonField = FieldFactory.Create();
RadioButtonField.prototype = FieldFactory.Extend( SelectionField.prototype, {

	Type : "RadioButtonField"
	,
	GetValue : function(control,flag) {
		var value = null;
		if(control != null) {			
			for(var i = 0 ; i < control.length ; i++) {
				 if(control[i].checked){
				 	value = control[i].value;
				 	break;
				 }
			}
		}		
		return value;
	}
	,
	SetValue : function(control,value,flag) {
		
		if(control != null && value != null) {	
			
			for(var i = 0 ; i < control.length ; i++) {
				
			  	if(control[i].value == value) {
			 		control[i].value = value;
			 		control[i].checked = true;
			 	}			
			}
		}
	}	
});

var HtmlField 		= FieldFactory.Create();
HtmlField.prototype = FieldFactory.Extend( Field.prototype, {
	
	Type : "HtmlField"
	,
	GetActualField : function()
	{
		return FormHandler.GetDOMField(this.Name + "_html");
	}
	,
	GetValue : function(control,flag) {
		
		if(control != null) {
			if(control.tagName.toLowerCase() == "input")			
				return control.value;
			else
			return control.innerHTML;
		}
		
		return null;
	}
	,
	SetValue : function(control,value,flag) {
		
		if(control != null && value != null) {
			if(control.tagName.toLowerCase() == "input"){
				control.value = value;
			}else
				{
				control.innerHTML = value;
				}	
		}
	}
	,
	ChangeAttributes : function(field,flag) {
	
		if(flag) {
		   field.removeAttribute("disabled");
		}
		else {
		   field.setAttribute("disabled","true");
		}
	}
	,
	TrackChange : function() {
		return this.HasChangeHandler() && this.DisplayField != null;
	}
});

var ComboBoxField = FieldFactory.Create();
ComboBoxField.prototype = FieldFactory.Extend( Field.prototype, {
	
	Type : "ComboBoxField"
	,
	
	GetValue : function(control,flag) {
		
		if(control != null) {
			var index = control.selectedIndex;
			if(index > -1) {
			   return flag ? control.options[index].value : control.options[index].text;
			}
		}
		
		return null;
	}
	,
	SetValue : function(control,value,flag) {
		
		if(control != null) {
			for(var i = 0 ; i < control.options.length; i++)
		    {
        		if( flag ? control.options[i].value == value : control.options[i].text == value)
        		{
        			control.options[i].selected = true;
        			break;
        		}
		    }
		}
	}
	,
	GetDisplayValue : function () {
		return this.GetValue(this.ActualField,false);
	}
	,
	RefreshOptions : function (rangeValues,rangeDisplayValue){
		
		if(rangeValues.length > 0) {
			var disValues = rangeValues;
			this.ActualField.options.length = 0;
			if(rangeValues.length == rangeDisplayValue.length) {
				disValues	= rangeDisplayValue;
			}
			this.isEditting = true;	
			for(var i = 0 ; i < rangeValues.length ; i++) {			
				this.ActualField.options[this.ActualField.options.length] = new Option(disValues[i],rangeValues[i]);
			}
			this.isEditting = false;	
		}
		
	}
	,
	SetRefreshedValue : function(refresh) {
		this.RefreshOptions(refresh.RangeValues,refresh.RangeDisplayValue);
		this.SetFieldValue(refresh.SelectedValues,refresh.SelectedDisplayValues);
	}
	,	
	SetFieldValue : function (fieldValue,fieldDisplayValue) {
		fieldValue 		  = fieldValue || "";
		fieldDisplayValue = fieldDisplayValue || "";
		this.Validating   = false;
		this.SetValue(this.ActualField,fieldValue,true);
		this.SetValue(this.DisplayField,fieldDisplayValue,false);
		this.FireChangeEvent();
	}
	,
	ChangeAttributes : function(field,flag) {
	
		if(flag) {
		   field.removeAttribute("disabled");
		}
		else {
		   field.setAttribute("disabled","true");
		}
	}
});

var ListBoxField = FieldFactory.Create();
ListBoxField.prototype = FieldFactory.Extend( Field.prototype, {
	
	Type : "ListBoxField"
	,
	
	GetValue : function(control,flag) {
		var values = [];
		if(control != null) {
			for (var i = 0; i < control.options.length; i++) {
		      var opt = control.options[i];
		      if (opt.selected) values.push( flag ? opt.value : opt.text);
		    }		 
		}		
		return values;
	}
	,
	SetValue : function(control,values,flag) {
		
		if(control != null && values != null) {
		
			values = values.split(",");
			for(var i = 0 ; i < control.options.length; i++)
            {
            	for(var j = 0 ; j < values.length; j++)
        		{
	        		if( flag ? control.options[i].value == values[j] : control.options[i].text == values[j])
	        		{
	        			control.options[i].selected = true;
	        			break;
	        		}
        		}
            }
		}
	}
	,
	IsEquals : function (prevs,current) {
		
		if(prevs.length == current.length) {
			prevs.sort();
			current.sort();
			return prevs.toString() == current.toString();	
		}
		return false;
	}
	,
	GetActualValue : function () {
		var values = this.GetValue(this.ActualField,true);
		return values != null ? values.join(",") : null;
	}
	,
	GetDisplayValue : function () {
		var values = this.GetValue(this.ActualField,false);
		return values != null ? values.join(",") : null;
	}
	,
	RefreshOptions : function (rangeValues,rangeDisplayValue){
		
		if(rangeValues.length > 0) {
			var disValues = rangeValues;
			this.ActualField.options.length = 0;
			if(rangeValues.length == rangeDisplayValue.length) {
				disValues	= rangeDisplayValue;
			}
			this.isEditting = true;
			for(var i = 0 ; i < rangeValues.length ; i++) {
				this.ActualField.options[this.ActualField.options.length] = new Option(disValues[i],rangeValues[i]);				
			}			
			this.isEditting = false;
		}
	}
	,
	SetRefreshedValue : function(refresh) {
		this.RefreshOptions(refresh.RangeValues,refresh.RangeDisplayValue);
		this.SetFieldValue(refresh.SelectedValues,refresh.SelectedDisplayValues);
	}
	,	
	SetFieldValue : function (fieldValue,fieldDisplayValue) {
		fieldValue 		  = fieldValue || "";
		fieldDisplayValue = fieldDisplayValue || "";
		this.Validating   = false;
		this.SetValue(this.HandlerField, fieldValue,true);
		this.SetValue(this.HandlerField, fieldDisplayValue,false);
		this.FireChangeEvent();
	}
	,
	ChangeAttributes : function(field,flag) {
	
		if(flag) {
		   field.removeAttribute("disabled");
		}
		else {
		   field.setAttribute("disabled","true");
		}
	}
});

var FormHandler = {

	Fields      : new HashMap()
	,
	TimeStamp   : null
	,
	FormType    : null
	,
	RefershURL  : "../common/emxFormRefresh.jsp"
	,
	PreProcess  : []
	,
	ChangeFields: []
	,
	EventStack  : []
	,
	CacheSettings : new HashMap()
	,
	PushEvent  : function(type,target) {
		this.EventStack.push(this.GetEvent(type,target));
	}
	,
	PutSettings : function(name,settings) {
		this.CacheSettings.Put(name,settings);
	}
	,
	GetSettings : function(name) {
		return this.CacheSettings.Get(name);
	}
	,
	PopEvent  : function() {
		return this.HasEvent() ? this.EventStack.pop() : this.GetUnKnownEvent();
	}
	,
	HasEvent : function() {
		return this.EventStack.length > 0;
	}
	,
	GetEvent : function(type,target) {
		type   = type   || "Unknown";
		target = target || "Unknown";
		return { Type : type, Target : target };
	}
	,
	GetUnKnownEvent : function() {
		return this.GetEvent();
	}
	,
	NowEvent : function() {
		return this.HasEvent() ? this.EventStack[this.EventStack.length - 1] : this.GetUnKnownEvent();
	}
	,
	Init : function() {
		this.TimeStamp  = document.getElementById("timeStamp").value;
		var fields = this.Fields.ToArray();
		for(var i = 0; i < fields.length; i++){
			fields[i].Init();
			if(fields[i].TrackChange()){
				this.ChangeFields.push(fields[i]);
			}
		}
		if(this.ChangeFields.length > 0) {
			this.TrackFieldsChange();
		}
	
		this.InvokeMethods(this.GetPreProcess(), window, [] , "OnPreProcess", "Form");
	}
	,
	InvokeMethod : function(method,caller,args) {
		caller  = caller  || window;
		args    = args    || [];
		if(this.ValidJSMethod(method)) {
			method.apply(caller,args);
		}
	}
	,
	ValidJSMethod : function(method) {
		return method != null && typeof method == "function";
	}
	,
	InvokeMethods : function(methods,caller,args,type,target) {
		methods = methods || [];
		this.PushEvent(type,target);
		for(var i = 0 ; i < methods.length ; i++) {
			this.InvokeMethod(methods[i],caller,args);
		}
		this.PopEvent();
	}
	,
	ConvertMethod : function(method) {
		var jsMethod = null;
		// IR-182849V6R2013x ZAPSECURITY + XSS: method consists of the name of the function passed to URL Parameter preProcessJavascript. 
		// This method is called from emxCreateFooter.xsl and is found to be the affected  parameter for XSS.
		// The name of the method is escaped for special characters.
		// Digits, Latin letters and the characters + - * / . _ @ remain unchanged
		// All other characters in the original string are replaced by escape-sequences %XX, where XX is the ASCII code of the original character 
		method =  escape(method);
		try { jsMethod = eval(method); } catch (e) {}
		return jsMethod;
	}
	,
	ConvertMethods : function(methods) {
		methods       = methods || [];
		var jsMethods = [];
		
		for(var i = 0 ; i < methods.length ; i++) {
			var jsMethod = this.ConvertMethod(methods[i]);
			if(this.ValidJSMethod(jsMethod)) {
				jsMethods.push(jsMethod);
			}
		}
		return jsMethods;
	}
	,	
	SetFormType : function(formType) {
		this.FormType = formType;
	}
	,
	GetFormType : function() {
		return this.FormType;
	}	
	,
	SetPreProcess : function (ppscript) {
		if(this.ValidProperty(ppscript)) {
			ppscript = ppscript.indexOf(";") != -1 ? ppscript.split(";") : ppscript.split(":");
			this.PreProcess = this.PreProcess.concat(this.ConvertMethods(ppscript));
		}
	}
	,
	GetPreProcess : function () {
		return this.PreProcess;
	}
	,
	ValidateJSHandler : function(handler,message) {
		
		var valid = false;
		if(this.ValidProperty(handler))
		{
			message = message || (handler + " is Not a javascript function");
			try	
			{
				handler = eval(handler);
				if(!(typeof handler == "function")) {
					alert(message);
				} else {
					valid = true;
				}
			}
			catch(e) {
				alert(message);
			}
		}
		return valid;
	}
	,
	ValidateJSHandlers : function(handlers,message) {
		handlers  = handlers || [];
		var valid = false;
		for(var i = 0 ; i < handlers.length ; i++ ) {
			valid = this.ValidateJSHandler(handlers[i],message);
			if(!valid) break;
		}
		return valid;
	}	
	,
	TrackFieldsChange : function () {
	
		for(var i = 0; i < this.ChangeFields.length ; i++)
		{
			if(this.ChangeFields[i].HasFieldChanged()) {
				this.ChangeFields[i].HandleChangeEvent.call(this.ChangeFields[i],null);
			}
		}
		setTimeout("FormHandler.TrackFieldsChange()", 250);
	}
	,
	NotifyFieldChange : function(fieldName) {
		var field = this.GetField(fieldName);
		if(field != null) {
			field.FireChangeEvent();
		}
	}
	,
	AddField : function (field) {
		this.Fields.Put(field.Name,field);
	}
	,
	GetField : function (fieldName) {
		return this.Fields.Get(fieldName);
	}
	,
	RemoveField : function (fieldName) {
		this.Fields.Remove(field.Name);
	}
	,
	ValidateField  : function (fieldName) {
		var field = this.GetField(fieldName);
		if(field != null) {
			return field.Validate();
		}
		return true;
	}
	,	
	ValidProperty : function (fieldName) {
		if(fieldName != "undefined" && fieldName != null && typeof fieldName == "string" && fieldName != "") {
			return true;
		} else  {
			return false;
		}
	}	
	,
	GetPostData : function() {
	
		return { TimeStamp   : this.TimeStamp,
   				 FormType    : this.FormType,
				 Event       : this.NowEvent(),
				 FieldValues : [],
				 Refresh     : null };
	}
	,
	GetPostJson : function(field) {
		
		var post = this.GetPostData();		
		post.FieldValues = this.GetFieldValues();
		post.Refresh     = field.GetRefreshData();
		return emxUICore.toJSONString(post);
	}
	,
	GetFieldValues : function() {
		
		var fields      = this.Fields.ToArray();
		var fieldValues = [];
		for(var i = 0; i < fields.length; i++){
			fieldValues = fieldValues.concat(fields[i].GetPostValue());
		}
		return fieldValues;
	}
	,
	GetDOMField : function (fieldName) {
		var fields = this.GetDOMFields(fieldName);
		return fields != null && fields.length > 0 ? fields[0] : null;
	}
	,
	GetDOMFields : function (fieldName) {
		var fields = null;
		if(this.ValidProperty(fieldName)) {
			fields = document.getElementsByName(fieldName);
			fields = fields.length > 0 ? fields : null;
		}
		return fields;
	}
	,
	GetFieldValue : function (fieldName) {
		var field = this.GetField(fieldName);
		return field != null ? field.GetFieldValue() : null;
	}
	,
	SetFieldValue : function (fieldName,fieldValue,fieldDisplayValue) {
		var field = this.GetField(fieldName);
		if(field != null) {
			field.SetFieldValue(fieldValue,fieldDisplayValue);
		}
	}
	,
	GetFieldDOM : function (fieldName) {
		var field = this.GetField(fieldName);
		return field != null ? field.GetHandler() : null;
	}
	,
	IsFieldEditable : function (fieldName) {
		var field = this.GetField(fieldName);
		return field != null ? field.CanEdit() : null;
	}
	,
	MakeFieldEditable : function (fieldName,flag) {
		var field = this.GetField(fieldName);
		if(field != null) {
			 field.MakeEditable(flag == "true" || flag == true);
		}
	}
	,
	RefreshField : function (fieldName) {
		var field = this.GetField(fieldName);
		if(field != null && field.CanRefresh()) {
		
			var postJson =	this.GetPostJson(field);
	    	var refresh  = eval('(' + this.RequestJson(this.RefershURL,postJson) + ')');
	    	
	    	if(refresh.Status == "success") {
	    		field.RefreshFieldValue(refresh);
	    	} else if(refresh.Status == "error") {
	    		alert(emxUIConstants.STR_JS_RefreshFailed+ " " + refresh.Message);
	    	}
		}
	}
	,
	RequestJson : function(url,json) {		
		 var xHttp = emxUICore.createHttpRequest();
	     xHttp.open("post", url, false);
	     xHttp.setRequestHeader("Content-type","text/plain; charset=UTF-8");
	     xHttp.send(json);
	     return xHttp.responseText;
	}
}

function emxFormGetValue(fieldName)
{
	return FormHandler.GetFieldValue(fieldName);
}

function emxFormGetFieldHTMLDOM(fieldName)
{
	return FormHandler.GetFieldDOM(fieldName);
}

function emxFormIsFieldEditable(fieldName)
{
	return FormHandler.IsFieldEditable(fieldName);
}

function emxFormSetFieldEditable(fieldName,editable)
{
	FormHandler.MakeFieldEditable(fieldName,editable);
}

function emxFormDisableField(fieldName,editable)
{
	FormHandler.MakeFieldEditable(fieldName,editable);
}

function emxFormSetValue(fieldName,fieldValue,fieldDisplayValue)
{
	FormHandler.SetFieldValue(fieldName,fieldValue,fieldDisplayValue);
}

function emxFormReloadField(fieldName)
{
	FormHandler.RefreshField(fieldName);
}

//Table Connected Controls
function emxTableGetValue(columnName,rowid)
{
	return FormHandler.GetFieldValue(columnName + rowid);
}

function emxTableGetFieldHTMLDOM(columnName,rowid)
{
	return FormHandler.GetFieldDOM(columnName + rowid);
}

function emxTableIsFieldEditable(columnName,rowid)
{
	return FormHandler.IsFieldEditable(columnName + rowid);
}

function emxTableSetFieldEditable(columnName,rowid,editable)
{
	FormHandler.MakeFieldEditable(columnName + rowid,editable);
}

function emxTableDisableField(columnName,rowid,editable)
{
	FormHandler.MakeFieldEditable(columnName + rowid,editable);
}

function emxTableSetValue(columnName,rowid,fieldValue,fieldDisplayValue)
{
	FormHandler.SetFieldValue(columnName + rowid,fieldValue,fieldDisplayValue);
}

function emxTableReloadField(columnName,rowid)
{
	FormHandler.RefreshField(columnName + rowid);
}

