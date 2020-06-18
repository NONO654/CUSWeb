/*
 * Widget Preferences
 * bpsWidgetPreferences.js
 * version 1.0
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 * bpsWidgetPreferences Object
 * this file contains all the runtime logic for BPS widget preferences
 *
 * Requires:
 * jQuery v1.8.3 or later
 *
 */

var bpsWidgetPreferences = {

	template: {
		container: function () { 
			return jQuery('<div class="pref-form"></div>');
		},
		gear: function (obj) { 
			var othis = this;
			return jQuery('<div class="settings-button preferences" title="' + bpsWidgetConstants.str.Preferences + '"></div>').click(function(e) {
				e.stopPropagation();
				var parent = jQuery(this).parent();
				var prefPane = jQuery('.pref-form', parent);

				if (prefPane.length == 0) {
					prefPane = othis.container();
					if (obj.config.widget.widgetType == 'channel' || obj.config.widget.widgetType == 'list') {
						var userViews = bpsWidgetAPIs.getWidgetViews(obj.config);
						var sortFields = bpsWidgetAPIs.getSortableFields(obj.config.widget);
						prefPane.append(othis.buildPreferences(obj, userViews, sortFields)).hide();							
			        }
					parent.prepend(prefPane);
				}

				prefPane.css({
					'left': jQuery(this).offset().left - prefPane.children('.preference-menu').width(),
					'top': jQuery(this).height()
				});
				prefPane.toggle();
			});
		},
		menu:function() {
			return jQuery('<div class="preference-menu"></div>');
		},
		head:function(){
			return jQuery('<div class="preference-menu-head"></div>');
		},
		body:function(obj, views, sorts){
			return jQuery('<div class="preference-menu-body"></div>').append(this.bodyContent(obj, views, sorts));
		},
		bodyContent:function(obj, views, sorts) {
			return jQuery('<div class="preference-menu-body-content"></div>')
							.append(this.viewContent(views, bpsWidgetAPIs.getWidgetViewPreference(obj.config)))
							.append(this.sortingHeader(sorts))
							.append(this.sortingContent(sorts));
		},
		viewContent:function(views, displayView) {
			var viewContent;
			
			if (views.length > 0) {
				viewContent = jQuery('<div class="preference-attr"></div>');
//				viewContent.append(jQuery('<div class="preference-attr-head"><div class="attr-title">' + bpsWidgetConstants.str.Views + '</div></div>'));
				viewContent.append(this.viewOptions(views, displayView));
			}
			
			return (viewContent);
		},
		viewOptions:function(views, displayView){
			var viewOptions = jQuery('<div class="preference-attr-body">' + bpsWidgetConstants.str.Views + '</div>');
			var viewSelect = jQuery('<select class="select_view"></select>');
			for (var i = 0; i < views.length; i++) {
				viewSelect.append('<option value="' + views[i].value + '">' + eval('bpsWidgetConstants.str.' + views[i].value)+ '</option>');
			}
			
			if (displayView) {
				viewSelect.val(displayView);
			}
			
			return (viewOptions.append(viewSelect));
		},
		sortingHeader:function(sorts) {
			var sortHeader;
			
			if (sorts.length > 0) {
				sortHeader = jQuery('<div class="menu-title">' + bpsWidgetConstants.str.Sorts + '</div>');
			}
			
			return (sortHeader);
		},
		sortingContent:function(sorts) {
			var sortContent;
			
			if (sorts.length > 0) {
				sortContent = jQuery('<div class="preference-attr"></div>');
				var sortField = jQuery('<select class="select_sortfield"></select>');
				for (var i = 0; i < sorts.length; i++) {
					sortField.append('<option value="' + sorts[i].value + '">' + sorts[i].displayName + '</option>');
				}
				
				sortContent.append(sortField).append(this.sortOptions(sorts[0]));
			}
			return (sortContent);
		},
		sortOptions:function(sort){
//			var sortOptions = jQuery('<div class="preference-attr-body"></div>');
			var sortOptions = jQuery('<select class="select_sortdirection"></select>');
			var direction = sort.sortdir;
			sortOptions.append('<option value="ascending">' + bpsWidgetConstants.str.SortAscending + '</option>');
			sortOptions.append('<option value="descending">' + bpsWidgetConstants.str.SortDescending + '</option>');
			if (direction) {
				sortOptions.val(direction);
			}
			
			return (sortOptions);
		},
		footer: function(){
			var apply = jQuery('<button class="apply">' + bpsWidgetConstants.str.Apply + '</button>');
			var cancel = jQuery('<button class="cancel">' + bpsWidgetConstants.str.Cancel + '</button>');
			return jQuery('<div class="preference-menu-foot"></div>').append(apply).append(cancel);
		},
		noPreferences:function (obj, views, sorts){
			var cancel = jQuery('<button class="cancel">' + bpsWidgetConstants.str.Cancel + '</button>');
			return jQuery('<div class="preference-menu"></div>')
									.append(bpsWidgetConstants.str.NoPreferences)
									.append(jQuery('<div class="preference-menu-foot"></div>').append(cancel));
		},
		buildPreferences:function(obj, userViews, sortFields){
			var oobj = obj;
			var menu;
			
			if ((userViews && userViews.length > 0) || (sortFields && sortFields.length > 0)) {
				menu = this.menu();
				menu.append(this.head());
				menu.append(this.body(obj, userViews, sortFields));
				menu.append(this.footer());
			} 
			else {
				menu = this.noPreferences();
			}
			
			jQuery(".apply", menu).click(function (e) {
				var view;
				var sortField;
				var sortDirection;
				jQuery('select', menu).each(function() {
					var name = jQuery(this).attr('class');
					var value = jQuery(this).val();
					if (name == "select_view") {
						view = value;
					}
					else if (name == "select_sortfield") {
						sortField = value;
					}
					else if (name == "select_sortdirection") {
						sortDirection = value;
					} 
				});

				if (view) {
					bpsWidgetAPIs.setWidgetViewPreference(oobj.config, view);
				}
					
				if (sortField && sortDirection) {
					var sorts = [];
					sorts.push({'name': sortField, 'direction': sortDirection});
					bpsWidgetAPIs.sortWidget(oobj.config.widget, sorts);
				}
				
				menu.parent().toggle();
				bpsWidgetEngine.reDrawWidget(oobj.config.widget, view);
			});
			jQuery(".cancel", menu).click(function (e) {
				menu.parent().toggle();
			});

			return (menu);
		}
	},
	buildPreferences: function(obj) {
		return (this.template.gear(obj));
	}
};

// Register window event to close the preference menus if clicked anywhere else
jQuery(window).click(function(e) {
	var menu = jQuery(e.target).closest('.pref-form');
	if (menu.size() == 0) {
		jQuery('div.pref-form:visible').hide();
	}
});

