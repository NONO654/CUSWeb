/*--------------------------------------------------------------------
[xs-widget-binder Javascript Document]

Project:		xs
Version:		1.0
Last change:    Wed, 11 Nov 2015 15:46:13 GMT
Assigned to:	Aravind Mohan
Description:    Executes the bindings on UI elements
Connects with:  xs-canvas, xs-wg-item, xs-wg-plm-data
---------------------------------------------------------------------*/
/**
	@module SMAProcXSUI

	@example
		TODO: Provide example on how to use this element
*/
/* global DS, Polymer*/
(function (window) {
	'use strict';
	var XS_WG_PLM_DATA = 'xs-wg-plm-data';
	//Prototype
	window.Polymer({ // jshint ignore:line
		is: 'xs-widget-binder',
		properties: {
        	hostid: {
        		type: String
        	}
		},
		//Private Methods
		//Evaluates the bindings and assigns it to the ui
		_doBinding: function (elem, bindings, rawValue, access) {
			var instance = this, forcedProps = {};
			var error, componentWithErrorList=[];
			bindings.forEach(function (binding) {
				var expr, force, reflect, splitted, lhs, lhsProp, rhs, XS, hasBindings;
				//Set the context
				XS = {
					Data: rawValue,
					Access: access
				};
				expr = binding.expr;
				force = binding.force;
				reflect = binding.reflect;
				splitted = expr.split('=');
				lhsProp = splitted[0].replace('this.', '').trim();
				lhs = elem[lhsProp];
				//Check if this property has bindings as part of the layout ({{ plm_data }})
				if (elem.getAttribute(lhsProp)) {
					hasBindings = !elem.getAttribute(lhsProp).search(/^{{\s*\w*\s*}}$/);
				}
				try {
					//Its known that eval is evil so dont get shocked seeing this.
					//But this is a legitimate use case
					//Still solve this later by using a custom parser
					//TODO: Custom parser
					rhs = eval(splitted[1]); // jshint ignore:line
					//If rhs is defined and ( its forced execution or if lhs is undefined )
					if (!instance.JS.isEmpty(rhs) && (force || (lhs===undefined)) && !hasBindings) {
						//if (!instance.JS.isEmpty(rhs) && (force || instance.JS.isEmpty(lhs)) && !hasBindings) {
						//Remove associations if any
						//elem.removeAttribute(lhsProp);
						//Set the forced evaluation
						elem[lhsProp] = rhs;
						//If this property was meant to be reflected
						if (reflect) {
							Polymer.dom(elem).setAttribute(lhsProp, rhs);
						}
						if (force) {
							//Add it to the list of forced properties
							forcedProps[lhsProp] = true;
						}
					}
				} catch (ex) {
					//console.warn(ex.message);
					//console.trace(this);
					//console.log(this.__data__._adp.widget);
					error = {};
					error.description = 'component association is broken.';
					var id='';
					//for boolean param, this.__data__._adp is not availble.
					if (this.__data__ && this.__data__._adp && this.__data__._adp.widget.id){
						id= this.__data__._adp.widget.id;
					} else {
						id= this.id;
					}
					if (componentWithErrorList.indexOf(id)===-1){
						componentWithErrorList.push(id);
						this.fire('associationBroken');
					}
					//this.__data__._adp.widget.haserror = true;
				}
			}, elem);
			return forcedProps;
		},
		//Removes the binding and the data element from the view if no ui element is bounded to it
		_safelyRemoveBinding: function (view, dataid, widget, preserveVal) {
			var dataInstance, layout, match;
			try {
				if (dataid) {
					//Find the data instance in the view and return
					dataInstance = this.DOM(view).find('#' + dataid).elements()[0];
				}

				if (dataInstance) {
					//If preserve val is not empty
					if (!this.JS.isEmpty(preserveVal)) {
						dataInstance.value = preserveVal;
					}
					//Prepare the layout
					layout = Polymer.dom(view).innerHTML;
					//If widget content has to be ignored
					if (widget) {
						layout = layout.replace(widget.outerHTML, '');
					}
					//Get the match
					match = layout.match(new RegExp('{{' + dataid + '}}', 'g'));
					//Check if there are no other property which has binding on this data
					//d6u Length 2 - One for the widget's attribute binding and the other for the PLM data instance
					if (match && match.length === 1) {
						//Remove the data instance
						dataInstance.parentNode.removeChild(dataInstance);
					}
				}
			} catch (ex) {
				console.warn('Error while trying to remove binding');
				console.error(ex);
			}
		},
		relayLayoutBindings: function (view) {
			var DATA_INSTANCE_TAG_MARKER = XS_WG_PLM_DATA.replace(/\-/g, '_'),
				dataHost;

			if (view) {
				dataHost = Polymer.dom(this.dataHost.root).querySelector('#' + this.hostid);

				if (dataHost && dataHost._notes) {
					dataHost._notes.forEach(function (note) {
						var elem = this.DOM(view).find('#' + note.id).elements()[0];
						if (elem) {
							note.bindings.forEach(function (binding) {
								//If its bounded to a PLM Data
								if (binding.value.search(DATA_INSTANCE_TAG_MARKER) > -1) {
									//set binding only when binding is changed.
									if (elem.getAttribute(binding.name) !== ('{{'+ binding.value +'}}')){
										elem.setAttribute(binding.name, '{{' + binding.value + '}}');
									}
								}
							}, this);
						}
					}, this);
				}
			}
		},
		_removeBinding: function (elem, propName) {
        	var bindings, binding,
        		length, index;

        	bindings = this._extractBindings(elem);

        	if (bindings) {
        		length = bindings.length;

				//Find the matching binding and remove it
        		for	(index = 0; index < length; index++) {
        			binding = bindings[index];

        			//If this is the binding to be removed
        			if (binding.name === propName) {
						break;
        			}
        		}
        	}

        	//If the binding was found
        	if (index !== undefined) {
        		bindings.splice(index, 1);
        	}
			this.fire('associationChanged', {
				'id' : elem.id
			});
		},
		//Gets the bindings noted on a given element
		_extractBindings: function (elem) {
        	var bindings, dataHost;
			dataHost = Polymer.dom(this.dataHost.root).querySelector('#' + this.hostid);
        	//Get the binding notes for the element
			dataHost._notes.every(function (note) {
				//Check if the note is for this element
				if (elem.id === note.id) {
					bindings = note.bindings;
					return false;
				} else {
					return true;
				}
			});

			return bindings;
		},
		checkForBinding: function (widget, propName) {
			var isBinded = false,
				bindings = this._extractBindings(widget);

			if (bindings) {
				//Check if the givne property is bounded
				bindings.every(function (binding) {
					//Check if its bounded
					isBinded = binding.name === propName;

					if (isBinded) {
						return false;
					} else {
						return true;
					}
				});
			}

			return isBinded;
		},

		//Check that for this property is there any rule present
		checkForRules: function(item, propName){
			//TODO: search for children name only
			var rulesPresent = false;
			var allChildren = Polymer.dom(item).children;
			//remove each item and then remove the layout
			allChildren.forEach(function (children) {
				if (children.tagName && children.tagName === 'XS-WG-RULE') {
					if (children.prop === propName) {
						rulesPresent = true;
					}
				}

			}, this);
			return rulesPresent;
		},

		//Public Methods
		//https://github.com/Polymer/polymer/blob/master/src/standard/annotations.html
		//Executes the bindings specified in the view from the meta information
		execute: function (view, meta) {
			//this._notes

			var bindingUIs;
			//Get all the UI elements which has a binding definition
			bindingUIs = Object.keys(meta).filter(function (key) {
				var hasBindings = false;
				if (meta[key].props) {
					hasBindings = meta[key].props.some(function (prop) {
						return prop.bindings;
					});
				}
				return hasBindings;
			}, this);
			//For each ui element which has one or more binding on its properties
			bindingUIs.forEach(function (tag) {
				var DOM, bindingProps;
				//Get all the elements of this type from the view
				DOM = this.DOM(view).find(tag);
				//Check if this ui is present in the view
				if (DOM.elements().length) {
					//Get the bindable properties
					bindingProps = meta[tag].props.filter(function (prop) {
						return prop.bindings;
					});
				}
				DOM.forEach(function (elem) {
					bindingProps.forEach(function (prop) {
						var rawValue,
							dataElem, access;

						//If the Prop has a value and is bound to a PLM data instance,
						//Get the associated id and then (Note: Has deep dependency on Polymer)
						//Get the matching data element
						//Find the PLM data instance this property is bound to
						dataElem = this.getBoundData(view, elem, prop.name);
						//If PLM data instance is found, derive its values
						if (dataElem) {
							//Get its raw value and the access associated for that data
							if (dataElem.oid) {
								access = dataElem.getAccess();
								rawValue = dataElem.getRawValue(function(rawValue){
									Polymer.dom(elem).parentNode.forcedProps = this._doBinding(elem, prop.bindings, rawValue, access);
								}.bind(this));
							} else {
								rawValue = dataElem.getRawValue();
								access = dataElem.getAccess();
								Polymer.dom(elem).parentNode.forcedProps = this._doBinding(elem, prop.bindings, rawValue, access);

							}

						}
					}, this);
				}, this);
			}, this);
		},

		//Public Methods
		//https://github.com/Polymer/polymer/blob/master/src/standard/annotations.html
		//Executes the bindings specified in the view from the meta information
		executeBinding: function (view, meta, items) {
			//this._notes
			if (!(items && items.length > 0)) {
				this.execute(view, meta);
			} else {
				var bindingUIs = [], dataElements = [];

				//Step 1: Get all the UI elements which has a binding definition
				Object.keys(meta).forEach(function (key) {
					if (meta[key].props) {
						meta[key].props.forEach(function (prop) {
							if (prop.bindings) {
								bindingUIs.push({tag: key,
									prop: prop.name,
									bindings: prop.bindings
								});
							}

						});
					}
				}, this);

				//Step 2: Get All Data Elements
				items.forEach(function(item){
					var tempDataItem = this.getDataInstaceByKindUidPath(view, item.kind, item.uid, item.path);
					// Skip parent data item
					if (tempDataItem) {
						dataElements.push(tempDataItem);
					}
				}.bind(this));

				//For each ui element which has one or more binding on its properties
				bindingUIs.forEach(function (bindingInfo) {
					dataElements.forEach(function(dataelem){
						var elementsForDataid;
						//Get all the elements of this connected to this data element
						elementsForDataid = view && view.querySelectorAll(bindingInfo.tag + '['+bindingInfo.prop+'="{{'+dataelem.id+'}}"]');
						//Check if this ui is present in the view
						if (elementsForDataid) {
							var elementsForDataidArray = [];
							//for fixing IE11 specific issue as elementsForDataid.forEach() is not supported in IE11
							for (var i=-1, l=elementsForDataid.length;++i!==l;elementsForDataidArray[i]=elementsForDataid[i]){}
							elementsForDataidArray.forEach(function (elem) {
								var rawValue, access;
								//Get its raw value and the access associated for that data
								if (dataelem) {
									if (dataelem.oid) {
										access = dataelem.getAccess();
										dataelem.getRawValue(function(rawValue){
											Polymer.dom(elem).parentNode.forcedProps = this._doBinding(elem, bindingInfo.bindings, rawValue, access);
										}.bind(this));
									} else {
										rawValue = dataelem.getRawValue();
										access = dataelem.getAccess();
										Polymer.dom(elem).parentNode.forcedProps = this._doBinding(elem, bindingInfo.bindings, rawValue, access);
									}
								}
							}.bind(this));
						}
					}.bind(this));
				}, this);
			}
		},

		//provide meta info to xs-wg-rules and also executes also triggers
		executeRules: function (view, meta) {
			//Give relevant meta info xs-wg-rules
			var rules = this.DOM(view).find('xs-wg-rule');
			if (rules.root.length >=1 ){
				rules.root[0].clearRuleStack();
			}
			rules.forEach(function (rule) {
				rule.setMetaInfo(meta);
			}, this);

			//Evaluate all conditions
			var items = this.DOM(view).find('xs-wg-item');
			items.forEach(function (item) {
				item.executeAllConditions();
			}, this);
		},
		//Associates the data(e.g. xs-wg-plm-data) to the ui
		/*
        	args = {
        		widget, kind, uid, path, prop
        	}
        */
		associate: function (view, args) {
			var widget, prop, kind, uid, path,
				DATA_INSTANCE_TAG = XS_WG_PLM_DATA, dataInstance;
			//Get the required information
			widget = args.widget;
			kind = args.association.kind;
			uid = args.association.uid || '';
			path = args.association.path;
			prop = args.prop;
			//Find if there are any data instance with this kind, uid, path
			dataInstance = this.getDataInstaceByKindUidPath(view, kind, uid, path);
			//If data instance is not yet available then create it
			if (!dataInstance) {
				//Create the data instance and set its properties
				dataInstance = window.document.createElement(DATA_INSTANCE_TAG);
				dataInstance.id = DATA_INSTANCE_TAG.replace(/\-/g, '_') + '_' + dataInstance.identity;
				Polymer.dom(dataInstance).setAttribute('uid', uid);
				Polymer.dom(dataInstance).setAttribute('kind', kind);
				Polymer.dom(dataInstance).setAttribute('path', path);
				Polymer.dom(dataInstance).setAttribute('value', '{{' + dataInstance.id + '}}');
				//Add it to the DOM
				Polymer.dom(view).appendChild(dataInstance);
			}
			//Set association on this widget for this property
			Polymer.dom(widget).setAttribute(prop, dataInstance.getAttribute('value'));
			widget[prop] = dataInstance.value;
		},
		//Removes association between data and the ui
		disassociate: function (view, args) {
			var widget, prop, val, binding;
			//Get the required information
			widget = args.widget;
			prop = args.prop;

			//Relayout
			this.relayLayoutBindings(view);

			//Get the binding
			binding = widget.getAttribute(prop);

			//Preserve the value to reassign it
			val = widget[prop];
			//Safe removal (To avoid deserialization error)
			if (val === undefined) {
				widget[prop] = null;
			}
			//Remove the binding from this widget
			Polymer.dom(widget).removeAttribute(prop);
			this._removeBinding(widget, prop);

			//If there is a binding
			if (binding) {
            	//Get the data id
            	binding = binding.replace(/^\{{|}}$/g, '');
				//Safely remove the binding
				this._safelyRemoveBinding(view, binding, null, val);
			} else {
				//If its a raw value
				widget[prop] = null;
			}
		},
		//Clears all the bindings in the view for a given ui element
		clearBindings: function (view, widget) {
			var DATA_INSTANCE_TAG_MARKER = XS_WG_PLM_DATA.replace(/\-/g, '_'),
            	bindings;

			//Relayout
			this.relayLayoutBindings(view);

			//Get the bindings on the widget
			bindings = this._extractBindings(widget);

			if (bindings) {
				bindings.forEach(function (binding) {
					var val;

					//Check for plm data association for each attribute of the widget
					if (binding.value && binding.value.search(DATA_INSTANCE_TAG_MARKER) > -1) {
						val = widget[binding.name];

						//Remove the binding on the widget
						Polymer.dom(widget).removeAttribute(binding.name);

						//Safely remove the plm data instance if it is not bound to any
						//other item's property in the canvas except for this one(attr)
						this._safelyRemoveBinding(view, binding.value, widget, val);
					}
				}, this);
			}
		},

		/**
         * Searches view for data instance by kind, uid and path
         * @param {HTMLElement} view Complete view tag
         * @param {String} kind Kind of data instance
         * @param {String} uid uid of data instance
         * @param {String} path path of data instance
         * @returns {HTMLElement} XS-WG-PLM-DATA instace
         */
		getDataInstaceByKindUidPath: function(view, kind, uid, path) {
			var dataInstance, query, DATA_SEARCH_PATTERN = '[kind="{kind}"][path="{path}"][uid="{uid}"]';
			query = DATA_SEARCH_PATTERN.replace('{kind}', kind).replace('{path}', path).replace('{uid}', uid);
			dataInstance = this.DOM(view).find(query).elements();
			dataInstance = dataInstance.length ? dataInstance[0] : null;
			return dataInstance;
		},

		/**
         * Get PLM data instance that is bound to the specified property of an item
         * @param   {Object}     view   - the view of the canvas which contains the layout
         * @param   {Object}   elem   - the widget on which the binding is retrieved
         * @param   {String} propName - Property name for which association needs to be determined
         * @returns {Object} - data instance (e.g. wg-plm-data instance)
         */
		getBoundData: function (view, elem, propName) {
			var dataId, data, bindings;

			//Get the elements bindings
			bindings = this._extractBindings(elem);

			if (bindings) {
				bindings.every(function (binding) {
					if (binding.name === propName) {
						dataId = binding.value;
						return false;
					} else {
						return true;
					}
				});

				if (dataId) {
					data = this.DOM(view).find('#' + dataId).elements()[0];
				}
			}

			return data;
		},
		behaviors: [DS.SMAProcSP.SPBase]
	});
}(this));

/*
polyup:
 1. Constructor if required needs to be explicitly set window object
 2. Mixins are converted to behaviors
*/
