(function(GLOBAL) {
    var ChartParameterLibrary = function() {
        this.parameterTemplates = {};
        this.attributeObjectTemplates = {};
    };

    ChartParameterLibrary.prototype.addAttributeObject = function(
        objectName,
        objectTemplate
    ) {
        this.attributeObjectTemplates[objectName] = objectTemplate;
    };

    ChartParameterLibrary.prototype.addChartParameter = function(
        objectName,
        objectTemplate
    ) {
        this.parameterTemplates[objectName] = objectTemplate;
    };

    var AttributeObjectTemplate = function(
        name,
        label,
        defaultAttributes,
        defaultAttributeObjects,
        library
    ) {
        this.name = name;
        this.label = label;
        
        this.type = 'attributeObject';

        this.objectConstructor = AttributeObject;

        this.baseObjects = [];

        this.defaultAttributes = defaultAttributes;
        this.defaultAttributeObjects = defaultAttributeObjects;

        this.library = library;

        this.libraryType = 'attributeObjectTemplates';

        library.addAttributeObject(name, this);
    };

    AttributeObjectTemplate.prototype.extends = function(baseObjects) {
        // Base objects are provided as template objects, either attribute object
        // tempaltes or chart parameter tempaltes,  depending on what's being
        // extended.

        // Make base objects an array if it isn't already. This allows for extends
        // to take a single  tempalte instead of an array.
        if (!(baseObjects instanceof Array)) {
            baseObjects = [baseObjects];
        }

        // add any base objects that are not duplicates
        var i, j, add;
        for (i = 0; i < baseObjects.length; i++) {
            add = true;
            for (j = 0; j < this.baseObjects.length; j++) {
                if (baseObjects[i].name === this.baseObjects[j].name) {
                    add = false;
                    break;
                }
            }
            if (add) {
                this.baseObjects.push(baseObjects[i]);
            }
        }
        // this.baseObjects.push(baseObject);
    };

    AttributeObjectTemplate.prototype.getDefaultAttributes = function() {
        var defaultAttributes = {};
        var key, objectAttributes;

        for (var i = 0; i < this.baseObjects.length; i++) {
            objectAttributes = this.baseObjects[i].getDefaultAttributes();
            for (key in objectAttributes) {
                defaultAttributes[key] = objectAttributes[key];
                defaultAttributes[key].value =
                    defaultAttributes[key]['default'];
            }
        }

        for (key in this.defaultAttributes) {
            defaultAttributes[key] = Object.assign(
                {},
                this.defaultAttributes[key]
            );
            defaultAttributes[key].value = defaultAttributes[key]['default'];
        }

        return defaultAttributes;
    };

    AttributeObjectTemplate.prototype.getDefaultAttributeObjects = function() {
        var defaultAttributeObjects = {};
        var key, objectAttributeObjects;

        for (var i = 0; i < this.baseObjects.length; i++) {
            objectAttributeObjects = this.baseObjects[
                i
            ].getDefaultAttributeObjects();
            for (key in objectAttributeObjects) {
                defaultAttributeObjects[key] = objectAttributeObjects[key];
            }
        }

        for (key in this.defaultAttributeObjects) {
            // Nothing contains parameters, so this is always an attribute object.
            defaultAttributeObjects[
                key
            ] = this.library.attributeObjectTemplates[
                this.defaultAttributeObjects[key]
            ].create();
        }

        return defaultAttributeObjects;
    };

    AttributeObjectTemplate.prototype.create = function(label) {
        // Option for setting label is used by parameter template, which inherits
        // this.
        var AttributeObject = new this.objectConstructor(
            this.type,
            label || this.label,
            this.getDefaultAttributes(),
            this.getDefaultAttributeObjects(),
            this.name
        );

        return AttributeObject;
    };

    var AttributeObject = function(
        objectType,
        label,
        defaultAttributes,
        defaultAttributeObjects,
        templateName
    ) {
        this.attributes = {};
        this.attributeObjects = {};

        this.type = objectType;
        this.label = label;
        this.setAttributes(defaultAttributes);
        this.setAttributeObjects(defaultAttributeObjects);
        
        this.templateName = templateName;
    };

    AttributeObject.prototype.update = function(requirement) {
        //
        var key;

        // Differs from import in that undefined attributes are not deleted.
        // Used to update a subset of the data.

        var key, objectKey;
        for (key in this.attributes) {
            if (requirement && typeof requirement !== 'undefined') {
                if (
                    typeof requirement[key] === 'object' &&
                    !(requirement instanceof Array)
                ) {
                    // For now, this overwrites the entire object.
                    this.attributes[key] = requirement[key];
                } else if (requirement[key]) {
                    // Attribute values should never be objects, unless they're
                    // arrays. If we receive a suitable  attribute, we assume it's the
                    // value.
                    this.attributes[key] = this.attributes[key] || {}; // Make sure it exists.
                    this.attributes[key].value = requirement[key];
                }
            }
        }

        for (key in this.attributeObjects) {
            if (requirement[key]) {
                this.attributeObjects[key].update(requirement[key]);
            }
        }
    };
    
    AttributeObject.prototype._getIdFunction = function(){};
    
    AttributeObject.prototype.id = function(fn){
    	if(typeof fn === 'function'){
    		this._getIdFunction = fn;
    	}
    	
    	return this._getIdFunction();
    };

    AttributeObject.prototype.setAttributes = function(attributes) {
        // Sets the attributes contained in the argument object.

        for (var key in attributes) {
            this.attributes[key] = attributes[key];
        }
    };

    AttributeObject.prototype.setAttributeObjects = function(attributeObjects) {
        for (var key in attributeObjects) {
            this.attributeObjects[key] = attributeObjects[key];
        }
    };

    // Extends moved to template.
    /*AttributeObject.extends = function(baseObject){
    this.setAttributes(baseObject.attributes);
    this.setAttributeObjects(baseObject.AttributeObjects);
};*/

    AttributeObject.prototype.checkToggle = function(attribute) {
        // Check to see if the appropriate attribute is set and has the same value.
        if (typeof attribute.toggleAttribute === 'undefined') {
            // Return true if there is no toggle value.
            return true;
        }

        // Define some convenience variables
        var toggle = attribute.toggleAttribute;
        var toggleAttribute = toggle.attribute,
            toggleValue = toggle.value;

        // Check if the toggle condition is met
        if (
            this.attributes[toggleAttribute] &&
            this.attributes[toggleAttribute].value === toggleValue
        ) {
            return true;
        }

        // Return false if it's not met
        return false;
    };

    AttributeObject.prototype.getTweakerJSON = function() {
        var tweakerJSON = {
            label: this.label,
            attributes: {},
            attributeObjects: {}
        };

        // Add attributes
        var key, attr;
        for (key in this.attributes) {
            attr = this.attributes[key];

            if (attr.tweaker && this.checkToggle(attr)) {
                tweakerJSON.attributes[key] = {
                    label: attr.tweaker.label,
                    typePath: attr.tweaker.typePath,
                    value: attr.value,
                    semantics: attr.tweaker.semantics,
                    displayStyle: attr.tweaker.displayStyle
                };
            }
        }

        // Add attribute objects
        var attrJSON;
        for (key in this.attributeObjects) {
            attrJSON = this.attributeObjects[key].getTweakerJSON();

            if (
                Object.keys(attrJSON.attributes) !== 0 ||
                (Object.keys(attrJSON.attributeObjects) !== 0 &&
                    this.checkToggle(this.attributeObjects[key]))
            ) {
                tweakerJSON.attributeObjects[key] = attrJSON;
            }
        }

        return tweakerJSON;
    };

    AttributeObject.prototype.getRequestJSON = function() {
        // Request JSON looks different from the tweaker JSON, so we should handle
        // it separately.

        var requestJSON = {};

        var key;

        // Add attributes
        for (key in this.attributes) {
            if (this.checkToggle(this.attributes[key])) {
                requestJSON[key] = this.attributes[key].value;
            }
        }

        // Add attribute objects
        for (key in this.attributeObjects) {
            if (this.checkToggle(this.attributeObjects[key])) {
                requestJSON[key] = this.attributeObjects[key].getRequestJSON();
            }
        }

        return requestJSON;
    };

    AttributeObject.prototype.importFromRequirement = function(requirement) {
        // This will import everything in a requirement object into the
        // AttributeObject.  All attributes are imported as values, after which all
        // attribute objects are  recursively imported.
        var key;
        for (key in this.attributes) {
            this.attributes[key].value = requirement[key];
        }

        for (key in this.attributeObjects) {
            if (requirement[key]) {
                this.attributeObjects[key].importFromRequirement(
                    requirement[key]
                );
            }
        }
    };

    AttributeObject.prototype.updateFromRequirement = function(requirement) {
        // Similar to import, but will not remove undefined attributes.
        var key;
        for (key in this.attributes) {
            if (typeof requirement[key] !== 'undefined') {
                this.attributes[key].value = requirement[key];
            }
        }

        for (key in this.attributeObjects) {
            if (requirement[key]) {
                this.attributeObjects[key].updateFromRequirement(
                    requirement[key]
                );
            }
        }
    };

    var ChartParameterTemplate = function(
        name,
        defaultSettings,
        defaultAttributeObjects,
        library,
        options
    ) {
        // We don't want to call the initialization block from the attribute
        // object.  This is because that block adds the object to the library,
        // but we want to keep  attribute objects and chart parameters separate
        // in the library and use a different  method to add them.
        // AttributeObjectTemplate.call(this);

        // Chart parameter templates don't have labels, since they're given
        // labels upon instantiation.  this is done because the same chart
        // parameter can be used in different roles, such as 'X' and 'Y',  which
        // make more sense as labels in the tweaker object than default object
        // labels.

        // Chart parameter and chart parameter templates extend the
        // functionality of the  attribute object. This is because they need to
        // replicate all of the functionality of the  attribute objects in terms
        // of library interaction, templating, and inheritance, but they  also
        // need to be able to insert themselves into the requirements object.

        var temp;

        if (typeof name === 'object') {
            temp = name;
            library = defaultSettings;
            options = defaultAttributeObjects;
            this.defaultAttributes = temp.attributes;
            defaultAttributeObjects = temp.attributeObjects;
            defaultSettings = temp.settings;
            name = temp.name;
        }

        // Specify the object constructor so the template creates
        // ChartParameter objects instead of AttributeObjects.
        this.objectConstructor = ChartParameter;

        // We need to initialize base objects since we don't run the
        // constructor on AttributeObject.
        this.baseObjects = [];

        this.defaultSettings = defaultSettings;
        this.defaultAttributeObjects = defaultAttributeObjects;
        
        this.type = 'chartParameter';
        	
        this.name = name;

        this.libraryType = 'parameterTemplates';

        this.library = library;

        library.addChartParameter(name, this);
    };

    ChartParameterTemplate.prototype = Object.create(
        AttributeObjectTemplate.prototype
    );
    ChartParameterTemplate.constructor = ChartParameterTemplate;

    ChartParameterTemplate.prototype.getDefaultSettings = function() {
        var defaultSettings = {};
        var key, objectSettings;

        for (var i = 0; i < this.baseObjects.length; i++) {
            objectSettings = this.baseObjects[i].getDefaultSettings();
            for (key in objectSettings) {
                defaultSettings[key] = objectSettings[key];
                defaultSettings[key].value = defaultSettings[key]['default'];
            }
        }

        for (key in this.defaultSettings) {
            defaultSettings[key] = Object.assign({}, this.defaultSettings[key]);
            defaultSettings[key].value = defaultSettings[key]['default'];
        }

        return defaultSettings;
    };

    ChartParameterTemplate.prototype.create = function(label, attributes) {
        // Option for setting label is used by parameter template, which inherits
        // this.
        var chartParameter = new this.objectConstructor(
            this.type,
            label || this.label,
            this.getDefaultAttributes(),
            this.getDefaultSettings(),
            this.getDefaultAttributeObjects(),
            this.name
        );
        
        if(typeof attributes !== 'undefined'){
        	chartParameter.update(attributes);
        }

        return chartParameter;
    };

    /*
 * AttributeObjectTemplate.prototype.create = function(label){
    //Option for setting label is used by parameter template, which inherits
this. var AttributeObject = new this.objectConstructor(this.type, (label ||
this.label), this.getDefaultAttributes(), this.getDefaultAttributeObjects());

    return AttributeObject;
};

var AttributeObject = function(objectType, label, defaultAttributes,
defaultAttributeObjects){ this.attributes = {}; this.attributeObjects = {};

    this.type = objectType;
    this.label = label;
    this.setAttributes(defaultAttributes);
    this.setAttributeObjects(defaultAttributeObjects);
};
 */

    var ChartParameter = function(
        objectType,
        label,
        defaultAttributes,
        defaultSettings,
        defaultAttributeObjects,
        templateName
    ) {
        AttributeObject.call(
            this,
            objectType,
            label,
            defaultAttributes,
            defaultAttributeObjects,
            templateName
        );

        this.settings = defaultSettings;
    };

    ChartParameter.prototype = Object.create(AttributeObject.prototype);
    ChartParameter.constructor = ChartParameter;
    
    ChartParameter.prototype._getIdFunction = function(){
    	if(this.settings.guid){
    		return this.settings.guid.value;
    	} else if (this.attributes.guid){
    		return this.attributes.guid.value;
    	}
    };

    ChartParameter.prototype.getRequestJSON = function() {
        // Request JSON looks different from the tweaker JSON, so we should handle
        // it separately.

        var that = this;

        var requestJSON = { data: {} };

        var key;

        // Add settings
        for (key in this.settings) {
            if (this.checkToggle(this.settings[key])) {
                requestJSON.data[key] = this.settings[key].value;
            }
        }

        // Add attribute objects
        for (key in this.attributeObjects) {
            if (this.checkToggle(this.attributeObjects[key])) {
                requestJSON[key] = this.attributeObjects[key].getRequestJSON();
            }
        }

        //Add attributes
        for (key in this.attributes) {
            if (this.checkToggle(this.attributes[key])) {
                requestJSON[key] = this.attributes[key].value;
            }
        }

        return requestJSON;
    };

    ChartParameter.prototype.setID = function(id) {
        this.id = id;
    };

    ChartParameter.prototype.getTweakerJSON = function() {
        var tweakerJSON = AttributeObject.prototype.getTweakerJSON.call(this);
        tweakerJSON.id = this.id;

        // Add attributes
        var key, attr;
        /*for(key in this.attributes){
        attr = this.attributes[key];

        if(attr.tweaker && this.checkToggle(attr)){
            tweakerJSON.attributes[key] = {
                label : attr.tweaker.label,
                typePath : attr.tweaker.typePath,
                value : attr.value,
                semantics : attr.tweaker.semantics,
                displayStyle : attr.tweaker.displayStyle
            };
        }
    }*/

        return tweakerJSON;
    };

    ChartParameter.prototype.importFromRequirement = function(requirement) {
        // Parameter attributes are in requirement.data. Otherwise, this is the same
        // as importing for an AttributeObject.
        var key;
        for (key in this.attributes) {
            if (requirement[key]) {
                this.attributes[key].value = requirements.data[key];
            }
        }

        for (key in this.attributeObjects) {
            if (requirement[key]) {
                this.attributeObjects[key].importFromRequirement(
                    requirement[key]
                );
            }
        }

        for (key in this.settings) {
            if (requirement.data[key]) {
                this.settings[key].value = requirements.data[key];
            }
        }
    };
    
    ChartParameter.prototype.getGuids = function(){
    	if(this.settings.guid && this.settings.guid.value){
    		return [this.settings.guid.value];
    	} else {
    		return [];
    	}
    };
    
    ChartParameter.prototype.getUpdateJSON = function(){
    	var updateJson = {
    		data : {}
    	};
    	
    	var key
    	
    	for(key in this.settings){
    		if(typeof this.settings[key].value !== 'undefined'){
    			updateJson.data[key] = this.settings[key].value;
    		}
    	}
    	
    	for(key in this.attributes){
    		if(typeof this.attributes[key].value !== 'undefined'){
    			updateJson[key] = this.attributes[key].value;
    		}
    	}
    	
    	for(key in this.attributeObjects){
    		updateJson[key] = this.attributeObjects[key].getRequestJSON();
    	}
    	
    	return updateJson;
    };

    ChartParameter.prototype.update = function(requirement) {
        // Differs from import in that undefined attributes are not deleted.
        // Used to update a subset of the data.

        // attributes for a chart parameter always need to be passed in this way so
        // that we can have base attributes.
        var settings = requirement.data;

        var key, objectKey;
        for (key in this.settings) {
            if (typeof settings !== 'undefined') {
                if (
                    typeof settings[key] === 'object' &&
                    !(settings[key] instanceof Array)
                ) {
                    // For now, this overwrites the entire object.
                    this.settings[key] = settings[key];
                } else if (typeof settings[key] !== 'undefined') {
                    // Attribute values should never be objects, unless they're
                    // arrays. If we receive a suitable  attribute, we assume it's the
                    // value.  this.settings[key] = this.settings[key] || {}; //Make
                    // sure it exists.
                    this.settings[key].value = settings[key];
                }
            }
        }

        for (key in this.attributeObjects) {
            if (requirement[key]) {
                this.attributeObjects[key].update(requirement[key]);
            }
        }

        for (key in this.attributes) {
            if (requirement[key]) {
                this.attributes[key].value = requirement[key];
            }
        }
    };

    var ArrayChartParameter = function(
        //objectType,
        label//,
        //defaultAttributes,
        //defaultSettings,
        //defaultAttributeObjects
    ) {
        /*ChartParameter.call(
            this,
            objectType,
            label,
            defaultAttributes,
            defaultSettings,
            defaultAttributeObjects
        );*/
    	
    	this.label = label;
        
        this.arrayParameterIDs = [];
        this.arrayParametersObject = {};
        
        this.type = 'arrayParameter';
    };
    ArrayChartParameter.prototype = Object.create(ChartParameter.prototype);
    ArrayChartParameter.constructor = ArrayChartParameter;

    ArrayChartParameter.prototype.update = function() {
        // This function differs from the equivalent function within the chart
        // parameter in that we need to be able to update  an array of sub-parameters
        // within the parameter that can vary in length, in addition to a fixed set
        // of things describing  the parameter itself.
        // For example, a "Y" parameter can be a spatial parameter, which can
        // contain "cost" and "value" as sub parameters.
        // Update will updat any existing subparameters, or add them if not present,
        // but can't be used to remove existing subparameters
    };
    
    ArrayChartParameter.prototype._getIdFunction = function(){
    	return this.label;
    }
    
    ArrayChartParameter.prototype.getGuids = function(){
    	var that = this;
    	
    	var guids = [];
    	this.arrayParameterIDs.forEach(function(id){
    		var paramGuids = that.arrayParametersObject[id].getGuids();
    		paramGuids.forEach(function(guid){
    			if(guids.indexOf(guid) === -1){
    				guids.push(guid);
    			}
    		});
    	});
    	
    	return guids;
    };
    
    ArrayChartParameter.prototype.getParameters = function(){
    	return this.arrayParametersObject;
    };
    
    ArrayChartParameter.prototype.addArrayParameter = function(el){
    	if(this.arrayParameterIDs.indexOf(el.id()) !== -1){
    		this.removeArrayParameter(el.id());
    	}
    	this.arrayParameterIDs.push(el.id());
    	this.arrayParametersObject[el.id()] = el;
    };

    ArrayChartParameter.prototype.removeArrayParameter = function(paramGuid) {
        // This is used to remove an element from the array.
    	var i = this.arrayParameterIDs.indexOf(paramGuid);
    	if(i !== -1){
    		delete this.arrayParametersObject[this.arrayParameterIDs[i]];
    		this.arrayParameterIDs.splice(i, 1);
    	}
    };

    ArrayChartParameter.prototype.getTweakerJSON = function() {
    	var that = this;
    	
    	var tweakerObject = {
    		id : this.id(),
    		label : this.label,
    		attributeObjects : {},
    		attributes : {}
    	};
    	
    	this.arrayParameterIDs.forEach(function(id){
    		
    		tweakerObject.attributeObjects[id] = that.arrayParametersObject[id].getTweakerJSON();
    	});
    	
    	return tweakerObject;
    };
    
    ArrayChartParameter.prototype.update = function(data){
    	var that = this;
    	
    	//Note: This can only update existent parameters that have already been added to the array.
    	//This is because the array parameter currently doesn't have a template, which would be
    	//used to populate new parameters. This could be changed in the future, in which case a new
    	//parameter would be added to the array and updated with any new data not corresponding
    	//to any already added parameters.
    	
    	//data should be an object containing elements keyed by ID. There's a few additional objects,
    	//like the 'data' object that isn't used (for now?) and an 'id' field.
    	Object.keys(data).forEach(function(key){
    		if (typeof that.arrayParametersObject[key] !== 'undefined'){
    			that.arrayParametersObject[key].update(data[key]);
    		}
    	});
    };

    ArrayChartParameter.prototype.getRequestJSON = function() {
    	var requestJson = [];
    	for(var i = 0; i < this.arrayParameterIDs.length; i++){
    		requestJson.push(this.arrayParametersObject[this.arrayParameterIDs[i]].getRequestJSON());
    	}
    	
    	return requestJson;
    };

    GLOBAL.DS.RAConstructors.ChartParameter = ChartParameter;
    GLOBAL.DS.RAConstructors.ChartParameterTemplate = ChartParameterTemplate;
    GLOBAL.DS.RAConstructors.AttributeObject = AttributeObject;
    GLOBAL.DS.RAConstructors.AttributeObjectTemplate = AttributeObjectTemplate;
    GLOBAL.DS.RAConstructors.ArrayChartParameter = ArrayChartParameter;
    GLOBAL.DS.RAConstructors.ChartParameterLibrary = ChartParameterLibrary;
})(this);
