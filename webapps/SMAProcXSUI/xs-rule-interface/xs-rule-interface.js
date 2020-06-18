//TODO add example
/* global Polymer*/
(function(window) {
	'use strict';

	var xsRuleInterface;

	//Prototype
	xsRuleInterface = {
		is: 'xs-rule-interface',
		properties: {
			//item for which this rule interface is opened
			item: {
				type: Object
			},

			//Current PropModel
			propModel: {
				type: Object,
				value: {}
			},

			//list of all rules
			allRules: {
				type: Array,
				value: [],
				computed: '_computeRuleList(item,propModel,toogle)'
			},

			//meta information about properties
			meta: {
				type: Object
			},

			//complete view info
			viewData: {
				type: Object,
				notify: true
			},

			toogle: {
				type: Boolean,
				value: false
			},

			viewInfo: {
				type: Array,
				value: [],
				notify: true
			},
			/**
			 * property to block editing of rules definition
			 */
			disabled: {
				type: Boolean,
				value: false
			},
			templateState:{
				type: Array
			}


		},

		updateViewInfo: function(view){
			this.viewInfo = this._computeViewInfo(view);
		},

		attached: function() {
			//sp modal throwing close. that time reset the form
			this.listen(this, 'close', 'closeRule');
			this.listen(this, 'refreshrepeat', 'refreshrepeat');
		},

		dettached: function() {
			this.unlisten(this, 'close', 'closeRule');
		},

		launch: function(item, propModel, closeCallback) {
			this.item = item;
			this.closeCallback = closeCallback;
			this.propModel = propModel;
			//before launching the UI, we should set the new data to the interface
			this.toogle = !this.toogle;
			this.async(function() {
				this.$.modalcontainer.show();
			}.bind(this));
		},

		_computeHeading: function(item, propModel){
			return 'Rules Editor : '+ item.name +' : ' + propModel.caption;
		},


		refreshrepeat: function(event) {
			event.stopPropagation();
			this.async(function() {
				this.toogle = !this.toogle;
			}.bind(this), 100);

		},
		/**
		 * creates new rule and inserts inside correct xs-wg-item
		 */
		addNewRule: function() {
			var propName = this.propModel.name;
			var propValue = '';
			if (this.propModel.choices) {
				propValue = String(this.propModel.choices[0]);
			} else if (this.propModel.type === 'multichoice') {
				propValue = '[]';
			}
			this.item.addNewRule(propName, propValue, this.allRules.length);
			this.async(function() {
				this.toogle = !this.toogle;
			}.bind(this), 100);
		},

		_computeViewInfo: function(viewData) {
			var itemList = Polymer.dom(viewData).querySelectorAll('xs-wg-item');
			var layoutList = Polymer.dom(viewData).querySelectorAll('xs-wg-layout');
			var sectionList = Polymer.dom(viewData).querySelectorAll('xs-wg-section');
			var tempViewInfo = [];
			itemList.forEach(function(item) {
				if (item.widget){
					var itemViewInfo = {
						cname: item.name,
						widgetname: item.widget.tagName,
						displayname: item.widget.label ? item.widget.label.substring(0, 50).trim() + ' ('+item.name+')' : item.name,
						displaytitle: item.widget.label ? item.widget.label.trim() + ' ('+item.name+')' : item.name,
						datatype: item.widget.datatype ? item.widget.datatype : 'na'
					};
					if (item.widget.choices && item.widget.choices.length > 0){
						itemViewInfo.choices = [];
						for (var index = 0; index < item.widget.choices.length; index++){
							itemViewInfo.choices.push({
								choices: item.widget.choices[index],
								choices_display: item.widget.choices_display ? item.widget.choices_display[index] : item.widget.choices[index]// jshint ignore:line
							});
						}
					}
					tempViewInfo.push(itemViewInfo);
				}
			});

			sectionList.forEach(function(layout){
				if (layout._isTopLayout !== true){
					tempViewInfo.push({
						cname: layout.name,
						widgetname: 'XS-WG-SECTION',
						displayname: layout.label ? layout.label.substring(0, 50).trim() + ' ('+layout.name+')' : layout.name,
						displaytitle: layout.label ? layout.label.trim() + ' ('+layout.name+')' : layout.name,
                    	datatype: layout.datatype ? layout.datatype : 'na'
					});
				}
			});
			layoutList.forEach(function(layout){
				if (layout._isTopLayout !== true){
					tempViewInfo.push({
						cname: layout.name,
						widgetname: 'XS-WG-LAYOUT',
						displayname: layout.label ? layout.label.substring(0, 50).trim() + ' ('+layout.name+')' : layout.name,
						displaytitle: layout.label ? layout.label.trim() + ' ('+layout.name+')' : layout.name,
                    	datatype: layout.datatype ? layout.datatype : 'na'
					});
				}
			});
			return tempViewInfo;
		},

		//as this is a modal dialog so needs to reset UI fields before it is closed
		closeRule: function() {
			if (this.closeCallback) {
				this.closeCallback(this.allRules.length);
			}
			this.closeCallback = null;
			this.item = '';
			this.$.modalcontainer.hide();
		},

		_computeRuleList: function(item, propModel) {
			var test = [];
			if (typeof item === 'object' && typeof propModel === 'object') {
				var temp = item.getAllRules(propModel.name);
				var i = 0;
				/*
					with reference to IR-635601-3DEXPERIENCER2019x, firing event to check if template is in read mode, iy true then not allowing priority to update
					as it was happening in read mode also. thus solving the issue. See IR for detail description.
					*/
				if (! this.templateState){
					this.fire('getTemplateState');
				}

				//console.log(this.);
				[].forEach.call(temp, function (ruleItem) {
					if (! this.templateState.indexOf('read')){
						ruleItem.priority = i;
					}

					test.push(ruleItem);
					i++;
				}.bind(this));
			}
			return test;
		}
	};


	window.Polymer(xsRuleInterface);

}(this));
