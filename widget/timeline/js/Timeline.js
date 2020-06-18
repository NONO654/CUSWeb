/**
The Timeline class
@since 0.0.1
@version 1.1
@author tws, lkd, gqh
*/

/**
Timeline shows gates and other time managed objects as interactive pieces on the timeline

    var myTimeline = new Timeline(jsonData);
    myTimeline.draw(jQueryDOMElement);
    //OR
    new Timeline(jsonData).draw(jQuery('#someId'));

 
@class Timeline
@module timeline
@constructor
@param {Object} data The data in JSON format for this Timeline instance
@return {Object} Timeline
*/

var Timeline = function (data) {
	this.template = {
		ds_timeline: function () { return jQuery('<div class="ds-timeline"></div>') },
		timeline_main: function () { return jQuery('<div class="timeline-main"></div>') },
		divider: function () { return jQuery('<div class="divider"><div class="inner"></div></div>') },
		dateline_container: function () { return jQuery('<div class="dateline-container"></div>') },
		dates: function () { return jQuery('<div class="dates"></div>') },
		timeline_container: function () { return jQuery('<div class="timeline-container"></div>') },
		legend: function (str) { return jQuery('<div class="legend">' + str +'</div>') },
		timeline: function () { return jQuery('<div class="timeline"></div>') },
		timeline_tools: function () { return jQuery('<div class="timeline-tools"></div>') },
		timeline_tools_tree: function () { return jQuery('<div class="timeline-tools-tree"><div class="timeline-tool tree"></div><div class="timeline-tool tree-p"></div></div>') },
		timeline_tools_lanes: function () { return jQuery('<div class="timeline-tools-lanes"><div class="timeline-tool lanes"></div><div class="timeline-tool gate"></div><div class="timeline-tool objective"></div><div class="timeline-tool realized"></div></div>') },
		timeline_tools_save: function () { return jQuery('<div class="timeline-tool-button timeline-tools-save" title="Save deliverable as template"></div>') },
		timeline_tools_activate: function () { return jQuery('<div class="timeline-tool-button timeline-tools-activate" title="Activate plan"></div>') },
		timeline_tools_lock: function () { return jQuery('<div class="timeline-tool-button timeline-tools-unlock" title="Lock or unlock edit feature."></div>') },
		timeline_tools_search: function () { return jQuery('<div class="timeline-tool-button timeline-tools-search" title="Search"></div>') },
		timeline_tools_remove_item: function () { return jQuery('<div class="timeline-tool-button timeline-tools-remove-item" title="Remove item"></div>') },
		timeline_tools_people: function () { return jQuery('<div class="timeline-tool-button timeline-tools-people" title="Assign access"></div>') },
		timeline_tools_status: function () { return jQuery('<div class="timeline-tool-button timeline-tools-show-status" title="Show/hide status "></div>') },
		timeline_tools_version: function () { return jQuery('<div class="timeline-tool-button timeline-tools-version" title="Make new version of plan"></div>') },
		timeline_tools_small_font: function () { return jQuery('<div class="timeline-tool-button timeline-tools-small-font"></div>') },
		timeline_tools_large_font: function () { return jQuery('<div class="timeline-tool-button timeline-tools-large-font"></div>') },
		timeline_tools_position: function () { return jQuery('<div class="timeline-tools-position"><div class="timeline-tool-button timeline-tools-expand"></div><div class="timeline-tool-button scroll-today"></div><div class="timeline-tool-button zoom-viewall"></div><div class="timeline-tool-button set-dates"></div><div class="timeSlider"></div></div>') },
        label: function (str) { return jQuery('<label>' + str +'</label>') },
		lane_item: function () {return jQuery('<span class="td"><div class="datebar"><div class="versionbar"></div></div></span>')},
		lane_gate: function (obj, editMode, showStatus) {return jQuery('<div class="lane-gate context-menu-gate' + (obj.isReference ? ' reference ' : ' ') + (obj.status ? (obj.status.isLate ? 'late' : obj.status.value) : '')+ '" data-id="' + obj._objectId + '" title="' + (obj.mEDate || "") +'"><div class="lane-gate-title  sizable-text'+ (obj.canEdit ? ' editable' : '') + '" data-pid="' + obj._physicalId + '">' + (obj.mName || "") +'</div><div class="arrow-up"></div></div>')},
		lane_start: function (obj) {return jQuery('<div class="lane-gate"><div class="arrow-down" title="' + (obj.startDate.value || "") +'"></div></div>')}, 
		lane_end: function (obj) {return jQuery('<div class="lane-gate"><div class="arrow-down" title="' + (obj.endDate.value || "") +'"></div></div>')}, 
		lane_version: function (obj, i) {return jQuery('<div class="lane-gate"><div class="arrow-down ss-' + i + '" title="' + (obj.effectivityStartDate || "") +'"></div></div>')}, 
		deliverable_popup: function (obj) {return jQuery('<div class="dialog-box"><form class="popup-form"><fieldset><legend>New Deliverable</legend><div class="input-wrapper"><label>Name:</label><input type="text" id="deliverable_name" /></div><div class="input-wrapper" id="select-list"><label>Template:</label></div><div class="input-wrapper"><input type="button" id="ok" value="Ok" /><input type="button" id="cancel" value="' + bpsWidgetConstants.str.Cancel + '" /></div></fieldset></form></div>')}, 
		objective_popup: function (obj) {return jQuery('<div class="dialog-box"><form class="popup-form"><fieldset><legend>New Objective</legend><div class="input-wrapper" id="select-list"><label>Name:</label></div><div class="input-wrapper" id="dynamic-field"><label>Value:</label></div><div class="input-wrapper"><input type="button" id="ok" value="Ok" /><input type="button" id="cancel" value="Cancel" /></div></fieldset></form></div>')}, 
		realized_popup: function (obj) {return jQuery('<div class="dialog-box"><form class="popup-form"><fieldset><legend>New Realized</legend><div class="input-wrapper"><label>Name:</label><input type="text" id="gate_name" readonly/></div><div class="input-wrapper"><label>Date:</label><input type="text" id="gate_date"/></div><div class="input-wrapper"><label>Value:</label><div class="dynamic-field"></div></div><div class="input-wrapper"><input type="button" id="ok" value="Ok" /><input type="button" id="cancel" value="Cancel" /></div></fieldset></form></div>')}, 
		gate_popup: function (obj) {return jQuery('<div class="dialog-box"><form class="popup-form"><fieldset><legend>New Gate</legend><div class="input-wrapper"><label>Name:</label><input type="text" id="gate_name"/></div><div class="input-wrapper"><label>Date:</label><input type="text" id="gate_date"/></div><div class="input-wrapper" id="select-list"><label>Status:</label></div><div class="input-wrapper" id="gate_comment_div"><label>Comment:</label><textarea id="gate_comment" rows="3" /></div><div class="input-wrapper"><input type="button" id="ok" value="Ok" /><input type="button" id="cancel" value="Cancel" /></div></fieldset></form></div>')}, 
		template_popup: function (obj) {return jQuery('<div class="dialog-box"><form class="popup-form"><fieldset><legend>New Template</legend><div class="input-wrapper"><label>Deliverable:</label><input type="text" id="deliverable_name" readonly/></div><div class="input-wrapper"><label>Name:</label><input type="text" id="template_name" /></div><div class="input-wrapper"><input type="button" id="ok" value="Ok" /><input type="button" id="cancel" value="Cancel" /></div></fieldset></form></div>')}, 
		edit_deliverable_popup: function (obj) {return jQuery('<div class="dialog-box"><form class="popup-form"><fieldset><legend>Edit Deliverable</legend><div class="input-wrapper"><label>Name:</label><input type="text" id="deliverable_name"/></div><div class="input-wrapper"><input type="button" id="ok" value="Ok" /><input type="button" id="cancel" value="Cancel" /><input type="button" id="delete" value="Delete" /></div></fieldset></form></div>')}, 
		edit_gate_popup: function (obj) {return jQuery('<div class="dialog-box"><form class="popup-form"><fieldset><legend>Edit Gate</legend><div class="input-wrapper"><label>Name:</label><input type= "text" id="gate_name"/></div><div class="input-wrapper"><label>Date:</label><input type="text" id="gate_date" /></div><div class="input-wrapper" id="select-list"><label>Status:</label></div><div class="input-wrapper" id="gate_comment_div"><label>Comment:</label><textarea id="gate_comment" rows="3" /></div><div class="input-wrapper"><input type="button" id="ok" value="Ok" /><input type="button" id="cancel" value="Cancel" /><input type="button" id="delete" value="Delete" /></div></fieldset></form></div>')}, 
		view_gate_popup: function (obj) {return jQuery('<div class="dialog-box"><form class="popup-form"><fieldset><legend>View Gate</legend><div class="input-wrapper"><label>Name:</label><input type= "text" id="gate_name" readonly/></div><div class="input-wrapper"><label>Date:</label><input type="text" id="gate_date" readonly/></div><div class="input-wrapper" id="select-list"><label>Status:</label></div><div class="input-wrapper" id="gate_comment_div"><label>Comment:</label><textarea id="gate_comment" rows="3" readonly/></div><div class="input-wrapper"><input type="button" id="cancel" value="Ok" /></div></fieldset></form></div>')}, 
		edit_objective_popup: function (obj) {return jQuery('<div class="dialog-box"><form class="popup-form"><fieldset><legend>Edit Objective</legend><div class="input-wrapper"><label>Name:</label><input type= "text" id="gate_name" readonly/></div><div class="input-wrapper"><label>Value:</label><input type="text" id="gate_value" /></div><div class="input-wrapper"><input type="button" id="ok" value="Ok" /><input type="button" id="cancel" value="' + bpsWidgetConstants.str.Cancel + '" /><input type="button" id="delete" value="Delete" /></div></fieldset></form></div>')}, 
		view_objective_popup: function (obj) {return jQuery('<div class="dialog-box"><form class="popup-form"><fieldset><legend>View Objective</legend><div class="input-wrapper"><label>Name:</label><input type= "text" id="gate_name" readonly/></div><div class="input-wrapper"><label>Value:</label><input type="text" id="gate_value" readonly/></div><div class="input-wrapper"><input type="button" id="cancel" value="Ok" /></div></fieldset></form></div>')}, 
		edit_realized_popup: function (obj) {return jQuery('<div class="dialog-box"><form class="popup-form"><fieldset><legend>Edit Realized</legend><div class="input-wrapper"><label>Name:</label><input type= "text" id="gate_name" readonly/></div><div class="input-wrapper"><label>Value:</label><input type="text" id="gate_value" /></div><div class="input-wrapper"><input type="button" id="ok" value="Ok" /><input type="button" id="cancel" value="' + bpsWidgetConstants.str.Cancel + '" /><input type="button" id="delete" value="Delete" /></div></fieldset></form></div>')}, 
		view_realized_popup: function (obj) {return jQuery('<div class="dialog-box"><form class="popup-form"><fieldset><legend>View Realized</legend><div class="input-wrapper"><label>Name:</label><input type= "text" id="gate_name" readonly/></div><div class="input-wrapper"><label>Value:</label><input type="text" id="gate_value" readonly/></div><div class="input-wrapper"><input type="button" id="cancel" value="Ok" /></div></fieldset></form></div>')}, 
		set_date_offset_popup: function (obj) {return jQuery('<div class="dialog-box"><form class="popup-form"><fieldset><legend>Set Dates</legend><div class="input-wrapper"><label>Begin:</label><input type="text" id="date_begin" /></div><div class="input-wrapper"><label>End:</label><input type="text" id="date_end" /></div><div class="input-wrapper"><input type="button" id="ok" value="Ok" /><input type="button" id="cancel" value="' + bpsWidgetConstants.str.Cancel + '" /></div></fieldset></form></div>')}, 
		date_helper_popup: function (obj) {return jQuery('<div class="date-helper-popup"></div>')},
		error_popup: function (obj) {return jQuery('<div class="dialog-box"><label>Oops!</label><br><p id="error_text"></p><input type="button" id="ok" value="Ok" /></div>')}, 
		where_used_popup: function () {return jQuery('<div class="dialog-box"><div class="input-wrapper"><input type="button" id="cancel" value="Ok" /></div></div>')},
		time_machine_begin: function () {return jQuery('<div class="dt-begin time-machine"/>')},
		time_machine_end: function () {return jQuery('<div class="dt-end time-machine"/>')},
		timeline_overlay: function () {return jQuery('<div class="timeline-overlay"></div>')},
		gate_status_list: function () {
			var list = [{value: "complete", display: "Complete"}, {value: "no_risk", display: "No Risk"}, {value: "low_risk", display: "Low Risk"}, {value: "high_risk", display: "High Risk"}];
			return (this.option_list(list));
		}, 
		option_list: function (arrList) {
			var othis = this, select = jQuery('<select></select>');
			arrList.forEach(function (item) {
				select.append(othis.option(item));
			});
			return select;
		},
		option:  function (obj) {return jQuery('<option value="'+ obj.value +'">'+ obj.display +'</option>')},
		input: function (obj) {
			var input = jQuery('<input />');
			for (var key in obj) {
				input.attr(key, obj[key]);
			}
			return input}
	};
	
	var preference;
	this.data = data;
	this.one_day = 60*60*24*1000;
	this.range = this.getDateRange();
	this.edit = false;
	preference = this.getPreference(Timeline.PREFERENCE_EDIT);
	if (preference) {
    	this.edit = JSON.parse(preference);
	}
	this.showStatus = false;
	preference = this.getPreference(Timeline.PREFERENCE_STATUS);
	if (preference) {
    	this.showStatus = JSON.parse(preference);
	}
	this.expandList = {};
	var preference = this.getPreference(Timeline.PREFERENCE_EXPAND_LIST);
	if (preference) {
    	this.expandList = JSON.parse(preference);
	}
	this.clipboard = null;
	return this;
};

Timeline.OBJECTIVE_CLASS = 'objective-icon';
Timeline.REALIZED_CLASS = 'realized-icon';
Timeline.TEMPLATE_CLASS = 'template-icon';
Timeline.DATEPICKER_FORMAT = 'M d, yy';
Timeline.PREFERENCE_DATE_RANGE = 'timeline-daterange';
Timeline.PREFERENCE_DIVIDER = 'timeline-divider';
Timeline.PREFERENCE_EDIT = 'timeline-edit';
Timeline.PREFERENCE_FONT_SIZE = 'timeline-fontsize';
Timeline.PREFERENCE_STATUS = 'timeline-status';
Timeline.PREFERENCE_ZOOM = 'timeline-zoom';
Timeline.PREFERENCE_EXPAND_LIST = 'timeline-expand-list';
Timeline.PREFERENCE_SCROLL_TOP = 'timeline-scroll-top';
Timeline.PREFERENCE_TIME_MACHINE = 'timeline-time-machine';

/** @returns array(result.X_min,result.Y_min,result.X_max,result.Y_max) */
Timeline.getBoundaries = function($elem) {
	var result = {};
	var extOffset = $elem.offset();
	// Initial values​​, but the content overflows in general
	result.X_min = extOffset.left;
	result.Y_min = extOffset.top;
	result.X_max = result.X_min + $elem.outerWidth() +11;//add width of arrow
	result.Y_max = result.Y_min + $elem.outerHeight();
	// This div can contain other wider than him ..
	$elem.find('.lane-gate-title:visible').each(function(index) {
		offset = jQuery(this).offset();
		result.X_min = Math.min(result.X_min, offset.left);
		result.Y_min = Math.min(result.Y_min, offset.top);
		result.X_max = Math.max(result.X_max, offset.left + jQuery(this).outerWidth());
		result.Y_max = Math.max(result.Y_max, offset.top + jQuery(this).outerHeight());
	});
	// result.X_min/Ymin rounded to the nearest whole
	result.X_min = Math.floor(result.X_min);
	result.Y_min = Math.floor(result.Y_min);
	// result.X_max/result.Y_max rounded to the next whole
	result.X_max = Math.ceil(result.X_max);
	result.Y_max = Math.ceil(result.Y_max);
	// tables of coordinate reference min/max
	return result;
};
/** @returns void
	@param {HTMLElement || jQueryElement} cart
*/
Timeline.cascadeGates = function(cart) {
	var Ymaximus = -10000000;
	// set the Y span so they do not overlap
	var list = jQuery(cart).find('.lane-gate-title:visible, .arrow-down');
	list.parent().css('top', '-5px');//sets top gate 5px from top of lane
	var contour = Timeline.getBoundaries(jQuery(cart));
	for(var i = 0; i < list.length; i++) {
		var iMin = 0;
		var target = list[i];
		var dim2move = Timeline.getBoundaries(jQuery(target));
		var newY = contour.Y_min;
		var height = dim2move.Y_max - dim2move.Y_min;
		if (!jQuery(target).hasClass('arrow-down')) {
			// Not really clean, we add few pixels to account for gate symbol
			newY = newY + 15;			
		} else {
			height = 0; //all arrows need to be left on the line
		}
		var encore = true;
		while(encore) {
			var counter = 0;
			for(var j = iMin; j < i; j++) {
				var prev = list[j];
				var dimAncien = Timeline.getBoundaries(jQuery(prev));
				if(dim2move.X_min >= dimAncien.X_max) {
					continue; // too left
				}
				if(dim2move.X_max <= dimAncien.X_min) {
					continue; // too right
				}
				// a prior 2 overlap, remains to be seen if it is not already one below the other
				if(newY >= dimAncien.Y_max) {
					continue; // already below
				}
				if((newY + height) <= dimAncien.Y_min) {
					continue; // already above
				}
				// it should be shifted under the old
				newY = Math.max(newY, dimAncien.Y_max + 1); // without this +1 = overlap = loop share !
				counter += 1;
			}
			encore = (counter > 0);
		}
		// It moves vertically gate
		jQuery(target).parent().css('top', Math.round(newY - jQuery(target).offset().top) + 'px');
		// And there are plans to expand the lane
		Ymaximus = Math.max(newY + height, Ymaximus);
	}
	// must contain the lane AND fill its parent
	var newH = Math.max(22,Ymaximus - contour.Y_min + 10); // +5 adds a little space for padding below lowest gate
	jQuery(cart).parent().height(newH); // because it is often too large after vertical "compaction"
	jQuery(cart).height(newH); // For the background to make the whole height
	jQuery(cart).closest('li').children(':first').css('line-height', newH + 'px');

};
Timeline.wrapTreeControls = function (nodeSpan) {
	var encapsulator = jQuery(nodeSpan).find('.encapsulator');
	jQuery(encapsulator.prevAll().toArray().reverse()).appendTo(encapsulator);
};
Timeline.getObjects = function(data) {
	var objects = bpsWidgetAPIs.getWidgetData(data),
		children = null,
		hideRootNode = false; // bpsWidgetAPIs.getPreference(data, "hideRootNode");
	if(hideRootNode) {
		if(objects.length == 1) {
			children = bpsWidgetAPIs.getChildren(objects[0]);
			if(children.length > 0) {
				objects = children;
			}
		}
	}

	return(objects);
};
Timeline.preProcessObjects = function (params) {
	var data = [];
	
	if (params.expandList) {
		Timeline.applyExpandObjects(params);
	}
		
	if (params.filter && params.filter == true) {
		Timeline.filterObjects(params);
	}
		
	params.data.forEach(function (obj) {
		var childParams = {data: obj, dateRange: params.dateRange, ignoreFilter: params.ignoreFilter};
		if (obj.busType == "Deliverable Template") {
			childParams.addClass = Timeline.TEMPLATE_CLASS;
		}
		data = data.concat(Timeline.getChild(childParams));
	});
	
	return (data);
};
Timeline.applyExpandObjects = function (params) {
	if (params.expandList) {
		params.data.forEach(function (obj) {
			Timeline.applyExpandObject({data: obj, expandList: params.expandList});
		});
	}
};
Timeline.applyExpandObject = function (params) {
	var obj = params.data, expandKey = obj.objectId;

	if (params.expandList) {
		if (params.expandList[expandKey]) {
			obj._expand = true;
		}
		
		// check children
		Timeline.applyExpandObjects({data: bpsWidgetAPIs.getChildren(obj), expandList: params.expandList});

		// check plans
		if (obj.relateddata && obj.relateddata.plans) {
			obj.relateddata.plans.datagroups.forEach( function(item, index) {
				if (params.expandList[expandKey + item.objectId]) {
					item._expand = true;
				}
			}); 
		}
	}
};
Timeline.filterObjects = function (params) {
	var show = false;
	
	params.data.forEach(function (obj) {
		if (Timeline.filterObject({data: obj, dateRange: params.dateRange})) {
			show = true;
		}
	});
	
	return (show);
};
Timeline.filterObject = function (params) {
	var obj = params.data, show = true;
	var withinDateRange = function (dateRange) {
		if (params.dateRange) {
			return (rangesOverlap(params.dateRange, dateRange));
		}
		
		return (true);
	};
	var rangesOverlap = function (range1, range2) {
		if (range1 && range2) {
			return ((range1.start < range2.end) && (range1.end > range2.start));
		}

		return (true);
	};
	var getStartDate = function (data) {
		var value = bpsWidgetAPIs.getFieldValue(data, "effectivityStartDate");
		return ((value && value.actualValue) ? value.actualValue : 0);
	};
	var getEndDate = function (data) {
		var value = bpsWidgetAPIs.getFieldValue(data, "effectivityEndDate");
		return ((value && value.actualValue) ? value.actualValue : Number.MAX_VALUE);
	};
		
	// filter object
	show = withinDateRange({start: getStartDate(obj), end: (params.endDate) ? params.endDate : Number.MAX_VALUE});
	
	// if any children shown, then show parent
	if (Timeline.filterObjects({data: bpsWidgetAPIs.getChildren(obj), dateRange: params.dateRange})) {
		show = true;
	}
	
	// filter plans
	if (obj.relateddata && obj.relateddata.plans) {
		obj.relateddata.plans.datagroups.forEach( function(item, index) {
           item._show = withinDateRange({start: getStartDate(item), end: getEndDate(item)});
           if (item._show == true) {
        	   show = true;
           }
        }); 
	}
	else {
		// show if there are no plans
		show = true
	}

	obj._show = show;
	return (show);
};
Timeline.getFieldBoolean = function (data, defaultValue) {
	if (data && data.displayValue) {
		return (data.displayValue != "FALSE");
	}
	return (defaultValue != undefined ? defaultValue : true);
};
Timeline.getGate = function (data, canEdit) {
	var gate = {}, risk, decision, status = "no_risk", comment = "", isLate = false;
	gate._objectId = data.objectId;
	gate._physicalId = data.physicalId;
	
	value = bpsWidgetAPIs.getFieldValue(data, "shadowId");
	if (value) {
		gate.shadowId = value.displayValue;
	}
	
	gate.isReference = (gate.shadowId && gate.shadowId.length > 0) ? true : false;
	gate.mEDate = bpsWidgetAPIs.getFieldValue(data, "mEDate").displayValue;
	gate.mEDate_actual = bpsWidgetAPIs.getFieldValue(data, "mEDate").actualValue;
	gate.mName = bpsWidgetAPIs.getFieldValue(data, "mName").displayValue;
	gate.status = {};
	
	value = Timeline.getFieldBoolean(bpsWidgetAPIs.getFieldValue(data, "isComplete"), false);
	if (value == true) {
		status = "complete";

		value = bpsWidgetAPIs.getFieldValue(data, "approvalComment");
		if (value) {
			comment = value.displayValue;
		}
	}
	else {
		isLate = (gate.mEDate_actual < (new Date).getTime());

		if (data.relateddata && data.relateddata.risks && 
				data.relateddata.risks.datagroups && data.relateddata.risks.datagroups.length > 0) {
			
			risk = data.relateddata.risks.datagroups[0];
			gate.status.riskId = risk.objectId;
			value = bpsWidgetAPIs.getFieldValue(risk, "rpnValue");
			if (value) {
				status = value.displayValue;
			} 
			else {
				status = "low_risk";
			}

			value = bpsWidgetAPIs.getFieldValue(risk, "description");
			if (value) {
				comment = value.displayValue;
			}
		}
	}

	gate.status.isLate = isLate;
	gate.status.value = status;
	gate.status.comment = comment;
	gate.canEdit = canEdit;
	return (gate);
};
Timeline.getChild = function (params) {
	var child, results = Timeline.getPlans(params);
	
	// if no plans then use the deliverable as the child
	if (results.length == 0) {
		child = Timeline.__getChild(params);
		if (child) {
			results.push(child);
			if (params.expandAll == true || (child.expand && child.expand == true)) {
				child.children = Timeline.getChildren({parent: params.data, expandAll: true, dateRange: params.dateRange, canEdit: child.canEdit});
			}
			else if (bpsWidgetAPIs.getChildren(params.data).length > 0) {
				child.isLazy = true;
			}
		}
	}
	
	return (results);
};
Timeline.__getChild = function (params) {
	var child, value;
	
	if ((params.ignoreFilter && params.ignoreFilter == true) || (params.data._show && params.data._show == true)) {
		child = {};
		if (params.data._expand && params.data._expand == true) {
			child.expand = true;
		}
		
		child._objectId = params.data.objectId;
		child._physicalId = params.data.physicalId;
		child.canEdit = (params.isEditable == undefined) ? true : params.isEditable;
		
		// not editable if child is a snapshot, now check access
		if (child.canEdit) {
			child.canEdit = Timeline.getFieldBoolean(bpsWidgetAPIs.getFieldValue(params.data, "modifyAccess"));
			child.canDelete = Timeline.getFieldBoolean(bpsWidgetAPIs.getFieldValue(params.data, "deleteAccess"));
			child.canChangeName = Timeline.getFieldBoolean(bpsWidgetAPIs.getFieldValue(params.data, "changenameAccess"));
		}
		else {
			child.canEdit = false;
			child.canDelete = false;
			child.canChangeName = false;
		}
		
		// parent id represents deliverable for the plan
		if (params.parentId) {
			child._parentId = params.parentId;
		}

		// physical id should be that of the deliverable
		if (params.physicalId) {
			child._physicalId = params.physicalId;
		}

		if (params.title) {
			child.title = params.title;
		}
		else {
			value = bpsWidgetAPIs.getFieldValue(params.data, "title");
			if (value) { 
				child.title = value.displayValue;
			}
		}
		
		if (params.addClass) {
			child.addClass = params.addClass;
		}

		child.info = {};
		value = bpsWidgetAPIs.getFieldValue(params.data, "effectivityStartDate");
		if (value) {
			child.info.effectivityStartDate = value.displayValue;
			child.info.effectivityStartDate_actual = value.actualValue;
		}
		else {
			child.info.effectivityStartDate = "";
			child.info.effectivityStartDate_actual = 0;
		}

		value = bpsWidgetAPIs.getFieldValue(params.data, "effectivityEndDate");
		if (value) {
			child.info.effectivityEndDate = value.displayValue;
			child.info.effectivityEndDate_actual = value.actualValue;
		}
		else {
			child.info.effectivityEndDate = "";
			child.info.effectivityEndDate_actual = Number.MAX_VALUE;
		}

		value = bpsWidgetAPIs.getFieldValue(params.data, "originated");
		if (value) {
			child.info.originatedDate = value.displayValue;
			child.info.originatedDate_actual = value.actualValue;
		}
		else {
			child.info.originatedDate = "";
			child.info.originatedDate_actual = 0;
		}

		value = bpsWidgetAPIs.getFieldValue(params.data, "lOwner");
		if (value) {
			child.info.lOwner = value.displayValue;
			child.info.lOwner_actual = value.actualValue;
		}

		child.gates = [];
		if (params.data.relateddata && params.data.relateddata.gates) {
			params.data.relateddata.gates.datagroups.forEach(function (gateData) {
				child.gates.push(Timeline.getGate(gateData, child.canEdit));
			});
		}
		
		child.isActivePlan = (child.info.effectivityStartDate_actual != 0 && child.info.effectivityEndDate_actual != Number.MAX_VALUE);
	}
		
	return (child);
};
Timeline.getChildren = function (params) {
	var children = [];

	bpsWidgetAPIs.getChildren(params.parent).forEach(function (child) {
		children = children.concat(Timeline.getChild({data: child, expandAll: params.expandAll, dateRange: params.dateRange}));
	});

	return (children);
};
Timeline.getKPIs = function (params) {
	var value, kpis = [];
	var findNameForId = function (id) {
		var i, gateName;
		if (params.gates) {
			for (i = 0; i < params.gates.length; i++) {
				if (id == params.gates[i]._objectId) {
					gateName = params.gates[i].mName;
					break;
				}
			}
		}

		return (gateName);
	};
	
	if (params.data.relateddata && params.data.relateddata.kpis) {
		params.data.relateddata.kpis.datagroups.forEach(function (objData) {
			var kpi = {};
			kpi._objectId = objData.objectId;
			kpi._physicalId = objData.physicalId;
			kpi.canEdit = params.canEdit;
			
			value = bpsWidgetAPIs.getFieldValue(objData, "kpiDate");
			if (value) {
				kpi.kpiDate = value.displayValue;
				kpi.kpiDate_actual = value.actualValue;
			}
		
			value = bpsWidgetAPIs.getFieldValue(objData, "kpiGateId");
			if (value) {
				kpi.kpiGateId = value.displayValue;
				kpi.kpiGateName = findNameForId(kpi.kpiGateId);
			}
			
			value = bpsWidgetAPIs.getFieldValue(objData, "kpiKind");
			if (value) {
				kpi.kpiKind = value.displayValue;
			}
			
			value = bpsWidgetAPIs.getFieldValue(objData, "kpiType");
			if (value) {
				kpi.kpiType = value.displayValue;
			}
			
			value = bpsWidgetAPIs.getFieldValue(objData, "kpiValue");
			if (value) {
				kpi.kpiValue = value.displayValue;
			}
		
			kpis.push(kpi);
		});
	}

	return (kpis);
};

Timeline.getPlans = function (params) {
	var i, j, data, startDate, title, displayTitle, plan, isEditable, plans = [], planStartDates = [], lastVisible = -1;
	var hasEndDate = function (data) {
		var value = bpsWidgetAPIs.getFieldValue(data, "effectivityEndDate");
		return (value && value.actualValue);
	};
	var getStartDate = function (data) {
		var value, startDate = {};
		value = bpsWidgetAPIs.getFieldValue(data, "effectivityStartDate");
		startDate.effectivityStartDate = value ? value.displayValue : "";
		startDate.effectivityStartDate_actual = value ? value.actualValue : 0;
		return (startDate);
	};

	if (params.data.relateddata && params.data.relateddata.plans && params.data.relateddata.plans.datagroups.length > 0) {
		title = bpsWidgetAPIs.getFieldValue(params.data, "title");
		if (title) { 
			title = title.displayValue;
		}
		
		data = params.data.relateddata.plans.datagroups;

		// find the last visible and the plan start dates
		for (i = 0; i < data.length; i++) {
			if (data[i]._show && data[i]._show == true) { 
				lastVisible = i;
			}
			
			startDate = getStartDate(data[i]);
			if (startDate.effectivityStartDate_actual > 0) {
				planStartDates.push(startDate);
			}
		}
		
		for (i = 0; i < data.length; i++) {
			if (data[i]._show && data[i]._show == true) { 
				isEditable = !hasEndDate(data[i]);
				displayTitle = title;
				if (data.length > 1) {
					displayTitle += ' v' + (i + 1);
				}
				plan = Timeline.__getChild({data: data[i],
												addClass: !isEditable ? 'snapshot-icon' : null,
												title: displayTitle,
												dateRange: params.dateRange,
												expandAll: true, // gets kpis so no lazy load
												parentId: params.data.objectId, // need parent id for lookup
												physicalId: params.data.physicalId,
												isEditable: isEditable});
				plans = plans.concat(plan);
				
				kpis = Timeline.getKPIs({data: data[i], canEdit: plan.canEdit, gates: plan.gates});
				// add in kpis from deliverable
				if (plan.isActivePlan) {
					kpis = kpis.concat(Timeline.getKPIs(params));
				}
				
				if (params.expandAll == true || (plan.expand && plan.expand == true)) {
					plan.children = Timeline.processItems(Timeline.mergeCommonItems(kpis));
					plan.children = plan.children.concat(Timeline.getChildren({parent: params.data, expandAll: true, dateRange: params.dateRange, canEdit: plan.canEdit}));
				}
				else if ((data[i].relateddata.kpis && data[i].relateddata.kpis.datagroups.length > 0) ||
						((i == lastVisible) && (bpsWidgetAPIs.getChildren(params.data).length > 0))) {
					plan.kpis = Timeline.processItems(Timeline.mergeCommonItems(kpis));
					plan.isLazy = true;
				}
				
				// need this info to draw the grey line and version markers on plan
				plan.versions = planStartDates;
			}
		}
	}
	
	return (plans);
};
Timeline.mergeCommonItems = function (items) {
	var result = {};
	items.forEach(function (item) {
		result[item.kpiType] = result[item.kpiType] || [];
		result[item.kpiType][item.kpiKind] = result[item.kpiType][item.kpiKind] || [];
		result[item.kpiType][item.kpiKind].push(item);
	});
	return result;
};
Timeline.processItems = function (items) {
	var result = [];
	for (var key in items) {
		if (items.hasOwnProperty(key)) {
			for (var key2 in items[key]) {
				if (items[key].hasOwnProperty(key2)) {
					result.push(Timeline.createChild(items[key][key2], key, key2));
				}
			}
		}
	}
	return result;
};
Timeline.createChild = function (obj, key, key2) {
	var cName = key2.toLowerCase() == "objective" ? Timeline.OBJECTIVE_CLASS : Timeline.REALIZED_CLASS,
	result = {
		"title": key,
		addClass: cName,
		"info": {},
		"gates": [],
		"_objectId": "1",
		"_level": "1",
		"children": []
	};
	obj.forEach(function (gate) {
		result.gates.push({
			"type": gate.kpiKind,
			"mName": gate.kpiValue,
			"mEDate": gate.kpiDate,
			"mEDate_actual": gate.kpiDate_actual,
			"_objectId": gate._objectId,
			"kpiGateId": gate.kpiGateId,
			"kpiGateName": gate.kpiGateName,
			"canEdit" : gate.canEdit
		});
	});
	
	return result;
};
Timeline.getGateIndex = function (gates, id) {
	var index;
	
	for (index = 0; index < gates.length; index++) {
		if (gates[index]._objectId == id) {
			return (index);
		}
	}
	return (-1);
};
Timeline.findGate = function (gates, id) {
	var gate, index = Timeline.getGateIndex(gates, id);
	
	if (index != -1) {
		gate = gates[index];
	}
	
	return (gate);
};
Timeline.findNode = function (parent, type, name) {
	var index, node, children = parent.getChildren();
	
	for (index = 0; index < children.length; index++) {
		if (children[index].data.addClass == type && children[index].data.title == name) {
			node = children[index];
			break;
		}
	}
	
	return (node);
};
Timeline.getGates = function (obj) {
	var i = 0, len, cl = obj.node.childList;
	len = (cl) ? cl.length : 0;
	for (; i < len; i++) {
		if (cl[i].data.addClass === obj.type && cl[i].data.title === obj.name) {
			return cl[i].data.gates;
		}
	}
	return [];
};
Timeline.getToday = function () {
	var today = new Date();
	today.setHours(12, 0, 0, 0);
	return (today);
};
Timeline.getTodayStart = function () {
	var today = new Date();
	today.setHours(0, 0, 0, 0);
	return (today);
};
Timeline.getTodayEnd = function () {
	var today = new Date();
	today.setHours(23, 59, 59, 0);
	return (today);
};
Timeline.days_between = function (date1, date2) {
	date1.setHours(12, 0, 0, 0);
	date2.setHours(12, 0, 0, 0);
	return Math.round(Math.abs(date1.getTime() - date2.getTime()) / (1000 * 60 * 60 * 24));
};
Timeline.__closeDialog = function ($popup) {
	$popup.fadeOut(function() {
		$popup.remove();
	});
};
Timeline._confirmDelete = function ($button) {
	var result = $button.hasClass('confirm');
	if (!result) {
		$button.addClass('confirm');
		$button.prop('value', 'Confirm');
	}
	return (result);
};
Timeline.getPlanId = function (node) {
	var deliverableNode = node;
	if (Timeline.isRealized(node) || Timeline.isObjective(node)) {
		deliverableNode = node.getParent();
	}
		
	return (deliverableNode.data._parentId ? deliverableNode.data._objectId : null);
};
Timeline.getPhysicalId = function (node) {
	return (node.data._physicalId ? node.data._physicalId : null);
};
Timeline.getDeliverableId = function (node) {
	var deliverableNode = node;
	if (Timeline.isRealized(node) || Timeline.isObjective(node)) {
		deliverableNode = node.getParent();
	}
		
	return (deliverableNode.data._parentId ? deliverableNode.data._parentId : deliverableNode.data._objectId);
};
Timeline.getDeliverableTitle = function (deliverableObj) {
	var title, value = bpsWidgetAPIs.getFieldValue(deliverableObj, "title");
	if (value) { 
		title = value.displayValue;
	}
	
	return (title);
};
Timeline.isDeliverable = function (node) {
	return (node && !node.data.addClass);
};
Timeline.isTemplate = function (node) {
	return (node && (node.data.addClass == Timeline.TEMPLATE_CLASS));
};
Timeline.isObjective = function (node) {
	return (node && (node.data.addClass == Timeline.OBJECTIVE_CLASS));
};
Timeline.isRealized = function (node) {
	return (node && (node.data.addClass == Timeline.REALIZED_CLASS));
};
Timeline.prototype.renameNodes = function(deliverableId, oldName, newName) {
	var redrawNodes = [];
	this.__getRootNode().visit(function(node) {
		if (deliverableId == Timeline.getDeliverableId(node)) {
			node.data.title = node.data.title.replace(oldName, newName);
			redrawNodes.push(node);
		}
		redrawNodes.forEach(function (node) {
			node.render();
		});
	});
};
Timeline.prototype.removeNodes = function(deliverableId, planId) {
	var removeNodes = [];
	this.__getRootNode().visit(function(node) {
		if (Timeline.isDeliverable(node) && deliverableId && (deliverableId == Timeline.getDeliverableId(node))) {
			if (planId) {
				if (planId == Timeline.getPlanId(node)) {
					removeNodes.push(node);
				}
			}
			else {
				removeNodes.push(node);
			}
		}
	});
	removeNodes.forEach(function (node) {
		node.remove();
	});
};
Timeline.prototype.getActivePlanNodes = function(deliverableId) {
	var nodes = [];
	this.__getRootNode().visit(function(node) {
		if (Timeline.isDeliverable(node) && deliverableId && (deliverableId == Timeline.getDeliverableId(node))) {
			if (node.data && node.data.info && node.data.info.isActivePlan == true) {
				nodes.push(node);
			}
		}
	});
	
	return (nodes);
};
Timeline.prototype.renumberPlans = function(deliverableId) {
	var deliverableObj = bpsWidgetAPIs.getObject(this.data, deliverableId),
		title = Timeline.getDeliverableTitle(deliverableObj),
		plans = deliverableObj.relateddata.plans.datagroups,
		redrawNodes = [];
	var getPlanIndex = function (planId) {
		var i;
		for (i = 0; i < plans.length; i++) {
			if (planId == plans[i].objectId) {
				return (i + 1);
			}
		}
		return (-1);
	};
	this.__getRootNode().visit(function(node) {
		var index, planId = Timeline.getPlanId(node);
		if (Timeline.isDeliverable(node) && deliverableId && (deliverableId == Timeline.getDeliverableId(node))) {
			node.data.title = title;
			if (planId && plans.length > 1) {
				node.data.title += " v" + getPlanIndex(planId);
			}
			redrawNodes.push(node);
		}
	});
	redrawNodes.forEach(function (node) {
		node.render();
	});
};
Timeline.prototype.isEditable = function (node) {
	var allowEdit = this.edit;
	if (allowEdit && node) {
		// switch to parent node for objective and realized
		if (node.data.addClass && node.data.addClass != "snapshot-icon") {
			node = node.getParent();
		}
		
		allowEdit = Timeline.isDeliverable(node) && node.data.canEdit;
	}
	
	return (allowEdit);
}; 
Timeline.prototype.creatFormfield = function (dynamicField, data) {

	var dataType, formfield, privateinfo;
	privateinfo = data.privateinfo.split("|");
	dataType = privateinfo[0] || "";
	switch (dataType.toLowerCase()) {
		case "string":
		  formfield = this.template.input({type:"text", name: data.value, value: privateinfo.slice(1)});
		  break;
		case "real":
		  formfield = this.template.input({type:"number", name: data.value, value: privateinfo.slice(1)});
		  break;
		case "range":
		  formfield = this.template.input({type:"range", name: data.value, min: privateinfo[1], max: privateinfo[2]});
		  break;
		default:
		//TODO same as string for now, if no different lets remove test for string (future TODO)
		  formfield = this.template.input({type:"text", value: privateinfo.slice(1)});
	}
	
	dynamicField.children(":not('label')").remove();
	dynamicField.append(formfield);
};
Timeline.prototype.draw = function ($elm) {
	var overlay = new Image();
	overlay.src = "../widget/timeline/img/Spinning_Loader.gif";
	
	this.$context_node 		 = $elm;//used for assigning events
	this.$ds_timeline 		 = this.template.ds_timeline();
	this.$timeline_main 	 = this.template.timeline_main();
	this.$divider 			 = this.template.divider();
	this.$dateline_container = this.template.dateline_container();
	this.$dates 			 = this.template.dates();
	this.$timeline_container = this.template.timeline_container();
	this.$legend			 = this.template.legend("Deliverables");//TODO i18n
	this.$timeline 			 = this.template.timeline();
	this.$timeline_tools 	 = this.template.timeline_tools();
	this.$date_helper_popup  = this.template.date_helper_popup();
	this.$tools_lock		 = this.template.timeline_tools_lock();
	this.$tools_search		 = this.template.timeline_tools_search();
	this.$tools_remove_item	 = this.template.timeline_tools_remove_item();
	this.$tools_people		 = this.template.timeline_tools_people();
	this.$tools_status		 = this.template.timeline_tools_status();
	this.$tools_small_font   = this.template.timeline_tools_small_font();
	this.$tools_large_font   = this.template.timeline_tools_large_font();
	this.$timeline_overlay	 = this.template.timeline_overlay();
	
	//build structure
	this.$ds_timeline
		.append(this.$timeline_overlay)
		.append(this.$timeline_main
					.append(this.$legend)
					.append(this.$divider)
					.append(this.$dateline_container
								.append(this.$dates))
					.append(this.$timeline_container
								.append(this.$timeline)))
		.append(this.$timeline_tools
					.append(this.template.timeline_tools_tree())
					.append(this.template.timeline_tools_lanes())
					.append(this.template.timeline_tools_version())
					.append(this.template.timeline_tools_activate())
					.append(this.template.timeline_tools_save())
					.append(this.$tools_lock)
					.append(this.$tools_search)
					.append(this.$tools_remove_item)
					.append(this.$tools_people)
					.append(this.$tools_status)
					.append(this.$tools_small_font)
					.append(this.$tools_large_font)
					.append(this.template.timeline_tools_position()))
		.append(this.$date_helper_popup);
	
	// initialize editing setting, template generates "not editing"
	if (this.edit) {
		this.$timeline.toggleClass("editing");
		this.$tools_lock.toggleClass("timeline-tools-lock timeline-tools-unlock");
	}

	// initialize status setting, template generates "do not show"
	if (this.showStatus) {
		this.$timeline.toggleClass("show-status");
		this.$tools_status.toggleClass("timeline-tools-show-status timeline-tools-hide-status");
	}

	// must load this preference before dynatree draws
	var preference = this.getPreference(Timeline.PREFERENCE_TIME_MACHINE);
	if (preference) {
		this.time_machine_range = JSON.parse(preference);
	}
	else {
		this.time_machine_range = {start: Timeline.getTodayStart(), end: Timeline.getTodayEnd()}
	}

    // add touch event mappings
    touchify(this.$ds_timeline);

	// hide the date helper popup
	this.$date_helper_popup.hide();
	
	//add dynatree to it
	this.drawDynaTree(this.$timeline);
	//add dateline
	this.drawDates(this.$dates);
	//add it to $elm
	$elm.append(this.$ds_timeline);
	//initialize interactions and layouts
	this.initialize();	
	//disable selection
	this.$ds_timeline.disableSelection();
	// sync the slider after component is rendered
	var othis = this;
	//TODO use event bind and trigger to replace timeouts
	setTimeout(function(){
		othis.finalize();
	},1000);
};
Timeline.prototype.finalize = function () {
	var preference;
	this.$days = this.$dates.find('.day');
	
	preference = this.getPreference(Timeline.PREFERENCE_LEFT_MARGIN);
	if (preference) {
		this.setLeftMargin(JSON.parse(preference));
		this.syncSlider();
	}
	else {
	this.today();
	}
	
	preference = this.getPreference(Timeline.PREFERENCE_TIME_MACHINE);
	this.setTimeMachine((preference) ? JSON.parse(preference) : preference);
	
	preference = this.getPreference(Timeline.PREFERENCE_SCROLL_TOP);
	if (preference) {
		this.$timeline_container.scrollTop(JSON.parse(preference));
	}
	this.$timeline_overlay.fadeOut();
};
Timeline.prototype.cropTreeItems = function () {
	var dividerLeftPos = this.$divider.offset().left;
    this.$timeline.find('ul:visible').each(function(){
    	var enc = jQuery(this).find('.encapsulator');
    	var width = dividerLeftPos - enc.offset().left + 5;
    	enc.width(width);
    });
};
Timeline.prototype.increaseFont = function () {
	this.setFontSize(((this.metrics.font_size*100)+10)/100);
	this.updateFontSizeRule();
	this.setPreference(Timeline.PREFERENCE_FONT_SIZE, JSON.stringify(this.metrics.font_size));
};
Timeline.prototype.decreaseFont = function () {
	this.setFontSize(((this.metrics.font_size*100)-10)/100);
	this.updateFontSizeRule();
	this.setPreference(Timeline.PREFERENCE_FONT_SIZE, JSON.stringify(this.metrics.font_size));
};
Timeline.prototype.getFontSize = function () {
	return this.metrics.font_size +'em';
};
Timeline.prototype.setFontSize = function (size) {
	this.metrics.font_size = size;
};
Timeline.prototype.updateFontSizeRule = function () {
	this.rule_font_size.html(this.elmId +" div.timeline div.lane-gate-title, "+ this.elmId +" div.timeline span.td {font-size: " + this.getFontSize() + "}");
};
Timeline.prototype.initialize = function() {
	var othis = this, preference;
	// make lanes container as wide as dates container
	this.width = (this.range.days * 50);
	// store day width for later scaling
	this.day_width = 50; //TODO calculate this 
	this.min_day_width = 2;
	this.current_day_width = 50;

	// set initial zoom level
	preference = this.getPreference(Timeline.PREFERENCE_ZOOM);
	if (preference) {
		this.current_day_width = this.day_width = JSON.parse(preference);
		this.width = this.range.days * this.day_width;
		this._adjustDateline(this.current_day_width)
	} 

	//setup an updatable style
	this.elmId = "#" + this.$context_node.attr('id');
	this.rule_font_size = jQuery('<style></style>');
	this.$context_node
			.append(this.rule_font_size)


	this.metrics = {
			dates_width: this.width,
			dates_margin_left: 0,
			dateline_container_left: 170,
			lane_left: 170,
			lane_width: this.width,
			cart_width: this.width,
			cart_margin_left: 0,
			day_width: this.day_width,
			font_size: '1.3'
	};
	

	// set initial font size
	preference = this.getPreference(Timeline.PREFERENCE_FONT_SIZE);
	if (preference) {
		this.metrics.font_size = JSON.parse(preference);
	}
	this.setFontSize(this.metrics.font_size);
	this.updateFontSizeRule();

	// set initial divider position
	preference = this.getPreference(Timeline.PREFERENCE_DIVIDER);
	if (preference) {
		preference = JSON.parse(preference);
		this.metrics.lane_left = this.metrics.dateline_container_left = Math.round(preference + 7);
		var offset = this.$divider.offset();
		offset.left = preference;
		this.$divider.offset(offset);
	} 

	this.$dateline_container.css('left', this.metrics.dateline_container_left);
	this.$timeline_container.find('.lane').css({'left': this.metrics.lane_left, 'width': this.metrics.lane_width});
	this.$timeline_container.find('.cart').css({'width': this.metrics.cart_width, 'margin-left': this.metrics.cart_margin_left});
	this.$dateline_container.find('.dates').css({'width': this.metrics.dates_width, 'margin-left': this.metrics.dates_margin_left});
	this.$dateline_container.find('.dates .day').css('width', this.metrics.day_width);

	//add the time machine control #timemachine
	this.$time_machine_begin = this.template.time_machine_begin();
	this.$time_machine_end = this.template.time_machine_end();
	this.$dates.append(this.$time_machine_begin).append(this.$time_machine_end);
	this.$dates.find('.time-machine').draggable({
				axis: 'x',
				start: function(event, ui) {

				},
				drag: function(event, ui) {
					var date = new Date(othis.getDragDropDate(ui, 0));
					othis.$date_helper_popup.text(jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, date));
					othis.$date_helper_popup.offset({
						top: (jQuery(ui.helper).offset().top),
						left: ui.offset.left +20
					}).show();
					othis.highlightSelectedDays();
				},
				stop: function(event, ui) {
					var date = new Date(othis.getDragDropDate(ui, 0)),
						days = Timeline.days_between(new Date(othis.range.startDate.ms), new Date(date)),
						left;
					othis.$date_helper_popup.hide();
					if (ui.helper.hasClass('dt-end')) {
						left = (days + 1) / othis.range.days * 100;
						// if the end is before the start, place it on same day as start
						if (left <= parseFloat(othis.$time_machine_begin[0].style.left)) {
							days = Timeline.days_between(new Date(othis.range.startDate.ms), new Date(othis.getTimeMachineRange().start));
							left = (days + 1) / othis.range.days * 100;
						}
					} else {
						left = days / othis.range.days * 100;
						// if the start is after the end, place it on the same day as end
						if (left >= parseFloat(othis.$time_machine_end[0].style.left)) {
							days = Timeline.days_between(new Date(othis.range.startDate.ms), new Date(othis.getTimeMachineRange().end));
							left = days / othis.range.days * 100;
						} 
					}
					
					ui.helper.css('left', left + "%");
//					othis.highlightSelectedDays();
//					othis.reload();
//					othis.cropTreeItems();
					
					// save time machine values as preference
					othis.setPreference(Timeline.PREFERENCE_TIME_MACHINE, JSON.stringify(othis.getTimeMachineRange()));
					bpsWidgetEngine.reDrawWidget(othis.data);
				}
			})
	.css({ position: 'absolute'});

	// initialize templates
	this.__updateTemplates();
	
	// so we can drop on dynatree from outside
	this.$timeline.droppable();
	
	this.$divider.draggable({
		axis: "x",
		stop: function(event, ui) {
			var lf = Math.round(ui.position.left + 7); // + "px";
			othis.$timeline_container.find('.lane').css('left', lf);
			othis.$dateline_container.css('left', lf);
			othis.metrics.lane_left = lf;
			othis.metrics.dateline_container_left = lf;
			othis.cropTreeItems();
			othis.setPreference(Timeline.PREFERENCE_DIVIDER, JSON.stringify(ui.position.left));
		}
	})
	.css('position', 'absolute');


	this.$ds_timeline.find('.tree-p').draggable({
		helper: "clone",
		zIndex: 1,
		delay:0,
		connectToDynatree: true,
		revert: "invalid",
		cursorAt: { top: 5, left:-5 },
		start: function (event, ui) {
			return (othis.edit);
		}
	});

	this.$ds_timeline.find('.gate, .realized').draggable({
		helper: "clone",
		zIndex: 5,
		delay:0,
		connectToDynatree: true,
		revert: "invalid",
		cursorAt: { top: 5, left:-5 },
		drag: function (event, ui) {
			var node = othis.__getNode(jQuery(event.toElement));
			if (node) {
				var date = new Date(othis.getDragDropDate(ui));
				othis.$date_helper_popup.text(jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, date));
				othis.$date_helper_popup.offset({
					top: (jQuery(ui.helper).offset().top - othis.$date_helper_popup.height() - jQuery(this).height()),
					left: ui.offset.left
				}).show();
			}
			else {
				othis.$date_helper_popup.hide();
			}
		},
		start: function (event, ui) {
			return (othis.edit);
		},
		stop: function (event, ui) {
			othis.$date_helper_popup.hide();
		}
	});

	this.$ds_timeline.find('.objective').draggable({
		helper: "clone",
		zIndex: 5,
		delay:0,
		connectToDynatree: true,
		revert: "invalid",
		cursorAt: { top: 5, left:-5 },
		drag: function (event, ui) {
			var date, gate, node = othis.__getNode(jQuery(event.toElement));
			if (Timeline.isObjective(node)) {
				date = jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, new Date(othis.getDragDropDate(ui)));
				node = node.getParent();
				if (node.data.gates) {
					for (index = 0; index < node.data.gates.length; index++) {
						if (date == node.data.gates[index].mEDate) {
							gate = node.data.gates[index];
							break;
						}
					}
				}
				
				if (gate) {
					othis.$date_helper_popup.text("Gate: " + gate.mName);
					othis.$date_helper_popup.offset({
						top: (jQuery(ui.helper).offset().top - othis.$date_helper_popup.height() - jQuery(this).height()),
						left: ui.offset.left
					}).show();
				}
				else {
					othis.$date_helper_popup.hide();
				}
			}
			else {
				othis.$date_helper_popup.hide();
			}
		},
		start: function (event, ui) {
			return (othis.edit);
		},
		stop: function (event, ui) {
			othis.$date_helper_popup.hide();
		}
	});

	this.$ds_timeline.find('.scroll-today').click(
		function (event) {
			othis.today();
		}
	);

	this.$ds_timeline.find('.zoom-viewall').click(function (event) {
		var selected = othis.__getActiveNode();
		if (!selected) {
			othis._frame(othis.range.startDate.ms, othis.range.endDate.ms);
			othis.syncSlider();
		}
		else {
			othis.$ds_timeline.trigger({
				type: "frameDeliverable",
				node: selected
			});
		}
	});

	this.$ds_timeline.find('.timeline-tools-version').click( function (event) {
		var node = othis.__getActiveNode();
		if (Timeline.isDeliverable(node)) {
			othis.$ds_timeline.trigger({
				type: "createVersion",
				node: node
			});
		}
	});

	this.$ds_timeline.find('.timeline-tools-save').click( function (event) {
		var node = othis.__getActiveNode();
		if (Timeline.isDeliverable(node)) {
			othis.$ds_timeline.trigger({
				type: "createTemplate",
				node: node
			});
		}
	});

	this.$ds_timeline.find('.set-dates').click( function (event) {
		othis.$ds_timeline.trigger({
			type: "setDates",
			position:  {left: event.clientX-50, top: event.clientY-150}
		});
	});

	this.$ds_timeline.find('.timeline-tools-activate').click( function(event) {
		var node = othis.__getActiveNode();
		if (Timeline.isDeliverable(node)) {
			othis.$ds_timeline.trigger({
				type: "activatePlan",
				targetNode: node
			});
		}
	});

	this.$ds_timeline.find('.timeline-tools-expand').click( function (event) {
		var selected = othis.__getActiveNode();
		othis.$ds_timeline.trigger({
			type: "expandNode",
			node: selected
		});
	});
	
	this.$tools_lock.click( function (event) {
		othis.edit = !othis.edit;
		othis.$timeline.toggleClass("editing");
		jQuery(this).toggleClass("timeline-tools-lock timeline-tools-unlock");
		othis.setPreference(Timeline.PREFERENCE_EDIT, JSON.stringify(othis.edit));
	});

	this.$tools_status.click( function (event) {
		othis.showStatus = !othis.showStatus;
		othis.$timeline.toggleClass("show-status");
		jQuery(this).toggleClass("timeline-tools-show-status timeline-tools-hide-status");
		othis.setPreference(Timeline.PREFERENCE_STATUS, JSON.stringify(othis.showStatus));
	});

	this.$tools_small_font.click( function (event) {
		othis.decreaseFont();
		othis.$timeline.find('.cart').each(function(){Timeline.cascadeGates(jQuery(this))});
	});

	this.$tools_large_font.click( function (event) {
		othis.increaseFont();
		othis.$timeline.find('.cart').each(function(){Timeline.cascadeGates(jQuery(this))});
	});

	this.$tools_search.click( function (event) {
		var redir = "../../common/emxFullSearch.jsp?fromExt=true&field=TYPES=type_DeliverableIntent,type_DeliverableTemplate&table=AEFGeneralSearchResults&cancelLabel=Close&selection=multiple&submitURL=../programcentral/emxProgramCentralCreateSession.jsp&showInitialResults=true";
			
		var searchWin = window.open(enoviaServer.getUrl() + 
			"/resources/bps/openpage?" + enoviaServer.getParams() + "&bps_url="+redir,
			"widgetSearch",
			"width=1000, height=500, top=200, left=200");
		function reFreshWidget() {
			if (searchWin && !searchWin.closed) {
				setTimeout(reFreshWidget, 1000);
			} else {
		    	othis.$timeline_overlay.show();
				bpsWidgetEngine.refresh(othis.data._parentExperience);
			}
		}
		setTimeout(reFreshWidget, 1000);
	});

	this.$tools_people.click( function (event) {
		othis.$ds_timeline.trigger({
			type: "assignAccess",
			node: othis.__getActiveNode()
		});
	});

	this.$tools_remove_item.click( function (event) {
		var aWidgetOids = [], objId;
        othis.data.container.find(".selected").each(function() {
                                    aWidgetOids.push(jQuery(this).attr("data-pid"));
                                });
        objId = aWidgetOids.join(",");
		if (objId) {
			var redir = encodeURIComponent("../../programcentral/emxProgramCentralCreateSession.jsp?emxTableRowId=" + objId +
		 		"&bps_action=remove");//&fromExt=true
			var searchWin = window.open(enoviaServer.getUrl() + 
				"/resources/bps/openpage?" + enoviaServer.getParams() + "&bps_url="+redir,
				"widgetRemove",
				"width=1000, height=500, top=200, left=200");
		} else {
			othis.$ds_timeline.trigger({
		    				  type: "showError",
		    				  message: "Please select a deliverable first."
		    			  });
		}
		function reFreshWidget() {
			if (searchWin && !searchWin.closed) {
				setTimeout(reFreshWidget, 1000);
			} else {
		    	othis.$timeline_overlay.show();
				bpsWidgetEngine.refresh(othis.data._parentExperience);
			}
		}
		setTimeout(reFreshWidget, 1000);
	});
	
	this.$ds_timeline.on("dblclick", ".lane-gate", "", function (event) {
		event.stopPropagation();
		var type, node = othis.__getNode(jQuery(event.target)), canEdit = othis.isEditable(node);
		
		if (Timeline.isRealized(node)) {
			type = "editRealized";
		} else if (Timeline.isObjective(node)) {
			type = "editObjective";
		} else {
			type = "editGate";
		}

		othis.$ds_timeline.trigger({
			type: type,
			node: node,
			edit: canEdit, 
			id: jQuery(event.target.offsetParent).attr('data-id'),
			position: {left: event.clientX, top: event.clientY}
		});
	});

	this.$ds_timeline.on("dblclick", ".lane", "", function (event) {
		var type, position = {left: event.clientX, top: event.clientY},
			ui = {offset: position}, node = othis.__getNode(jQuery(event.target));
		if (othis.isEditable(node)) {
			if (Timeline.isRealized(node)) {
				type = "createRealized";
			} else if (Timeline.isObjective(node)) {
				type = "createObjective";
			} else {
				type = "createGatePopup";
			}

			othis.$ds_timeline.trigger({
				type: type,
				position: {left: event.clientX, top: event.clientY},
				targetNode: node,
				date: othis.getDragDropDate(ui)
			});
		}
	});

	this.$ds_timeline.on("click", ".tree-p", "", function (event) {
		var node = null; //othis.__getActiveNode();
		if (othis.isEditable(node)) {
			othis.$ds_timeline.trigger({
				type: "createDeliverable",
				// position: {left: event.clientX, top: event.clientY},
				targetNode: node,
				hitMode: "over"
			});
		}
	});

	// map double click event for touch
	if(is_touch_device()) {
		this.$timeline.hammer({prevent_default:false}).on("doubletap", "", function(event) {
			var touches = event.gesture.srcEvent.changedTouches,
				first = touches[0],
				type = "dblclick";


			var simulatedEvent = document.createEvent("MouseEvent");
			simulatedEvent.initMouseEvent(type, true, true, window, 1, first.screenX, first.screenY, first.clientX, first.clientY, false, false, false, false, 0 /*left*/ , null);

			first.target.dispatchEvent(simulatedEvent);
		});
	}

	// touch and scroll
	this.$dateline_container.mousedown(function (event) {
		if (jQuery(event.target).hasClass('time-machine')) {
			jQuery.data(this, 'timeMachine', true);
		}
		event.preventDefault();
		jQuery.data(this, 'down', true);
		jQuery.data(this, 'x', event.clientX);
		jQuery.data(this, 'marginLeft', othis.getLeftMargin());
		jQuery.data(this, 'movables', othis.__getMovables());
	});
	this.$dateline_container.mouseup(function (event) {
		jQuery.data(this, 'down', false);
		jQuery.data(this, 'timeMachine', false);
	});
	this.$dateline_container.mousemove(function (event) {
		if (jQuery.data(this, 'timeMachine') == true) {
			return;
		}
		if (jQuery.data(this, 'down') == true) {
			var lf = (jQuery.data(this, 'marginLeft') + (event.clientX - jQuery.data(this, 'x'))),
				visibleWidth = othis.getVisibleWidth(),
				width = othis.getWidth();
		    
			// don't let it go beyond the left edge
			if (lf > 0) {
		    	lf = 0;
		    }
			// or the right edge
			else if (visibleWidth - lf > width) {
				lf = visibleWidth - width;
			}
		    
		    othis.setLeftMargin(lf, jQuery.data(this, 'movables'));
		    othis.syncSlider();
			jQuery.data(this, 'x', event.clientX);
			jQuery.data(this, 'marginLeft', othis.getLeftMargin());
		}
	});
	this.$dateline_container.bind('mousewheel DOMMouseScroll', function(event) {
        event.preventDefault();
        var dir = 0;
        var delta = event.originalEvent.wheelDelta || -event.originalEvent.detail;
        
        if (delta) {
        	dir = (delta > 0) ? 1 : -1;
        }

		othis.zoom(dir);
	});
	this.$timeline_container.mousedown(function (event) {
		var $target = jQuery(event.target);
		if ($target.hasClass("cart") || $target.hasClass("td") || $target.hasClass("selection-box")) {
			event.preventDefault();
			jQuery.data(this, 'marginLeft', othis.getLeftMargin());
			jQuery.data(this, 'scrollTop', othis.$timeline_container.scrollTop());
			jQuery.data(this, 'movables', othis.__getMovables());
			//TODO should probably change cursor with a class change
			jQuery(this).css('cursor', 'all-scroll');
			
			// if we don't have a selection box then save position
			if (!jQuery.data(this, '$selection')) {
				jQuery.data(this, 'x', event.clientX);
				jQuery.data(this, 'y', event.clientY);
				jQuery.data(this, 'down', true);
				jQuery.data(this, 'shift', event.shiftKey);

			if (event.shiftKey) {
			    var $selection = jQuery('<div>').addClass('selection-box');
			    othis.$timeline_container.append($selection);
			    jQuery.data(this, '$selection', $selection);
				jQuery(this).css('cursor', 'auto');
			}
		}
		}
	});
	this.$timeline_container.mouseup(function (event) {
		jQuery.data(this, 'down', false);
		var $target = jQuery(event.target);
		if ($target.hasClass("cart") || $target.hasClass("td") || $target.hasClass("selection-box")) {
			//TODO should probably change cursor with a class change
			jQuery(this).css('cursor', 'auto');
            
			if (jQuery.data(this, 'shift')) {
				jQuery.data(this, 'shift', false);
				jQuery.data(this, '$selection').remove();
				jQuery.data(this, '$selection', null);
			
				var children = jQuery(this).find('.lane-gate-title');
				var x = jQuery.data(this, 'x'), y = jQuery.data(this, 'y');
				var left = (event.clientX < x) ? event.clientX : x, top = (event.clientY < y) ? event.clientY : y;
				var right = left + Math.abs(event.clientX - x), bottom = top + Math.abs(event.clientY - y);	
				jQuery(this).find('.lane-gate-title').each(function(index, elem) {
				  	var $elem = jQuery(elem);
				  	if ($elem.attr('data-pid') && $elem.attr('data-pid') !== "undefined" && !$elem.parent().hasClass('reference')) {
				  		var offset = $elem.offset();
				  		if ((offset.left >= left && offset.left <= right) && (offset.top >= top && offset.top <= bottom)) {
				  			$elem.addClass('selected');
				  		}
				  	}
				});
			}
		}
	});
	this.$timeline_container.mousemove(function (event) {
		var $selection = jQuery.data(this, '$selection'), $target = jQuery(event.target);
		if (jQuery.data(this, 'down') == true && ($target.hasClass("cart") || $target.hasClass("td") || $target.hasClass("selection-box"))) {
			if (jQuery.data(this, 'shift') == false) {
				var lf = (jQuery.data(this, 'marginLeft') + (event.clientX - jQuery.data(this, 'x'))),
					visibleWidth = othis.getVisibleWidth(),
					width = othis.getWidth();
		    
			// don't let it go beyond the left edge
			if (lf > 0) {
		    	lf = 0;
		    }
			// or the right edge
			else if (visibleWidth - lf > width) {
				lf = visibleWidth - width;
			}
		    
		    othis.setLeftMargin(lf, jQuery.data(this, 'movables'));
		    othis.syncSlider();
		    
		    var st = (jQuery.data(this, 'scrollTop') - (event.clientY - jQuery.data(this, 'y')));
		    othis.$timeline_container.scrollTop(st);

			jQuery.data(this, 'x', event.clientX);
			jQuery.data(this, 'y', event.clientY);
			jQuery.data(this, 'marginLeft', othis.getLeftMargin());
			jQuery.data(this, 'scrollTop', othis.$timeline_container.scrollTop());
		}
			else {
				var vTop, left, x = jQuery.data(this, 'x'), y = jQuery.data(this, 'y');
				left = (event.clientX < x) ? event.clientX : x;
				vTop = (event.clientY < y) ? event.clientY : y;
					
				$selection.offset({top: vTop, left: left});
				$selection.css({
					'width': Math.abs(event.clientX - x),
					'height': Math.abs(event.clientY - y)
				});
			}
		}
	});
	this.$timeline_container.scroll(function (event) {
		othis.setPreference(Timeline.PREFERENCE_SCROLL_TOP, JSON.stringify(jQuery(this).scrollTop()));
	});
	
	this.$timeline_container.bind('mousewheel', function(event, delta) {
        //TODO use jquery mousewheel plugin
		event.preventDefault();
        var dir = 0;
        if (!delta) {
        	delta = event.originalEvent.wheelDelta;
        }
        
        if (delta) {
        	dir = (delta > 0) ? 1 : -1;
        }

		othis.zoom(dir);
	});

	this.$ds_timeline.on("expandNode", function (event) {
		var node = event.node;
		if (node) {
			node.data.expandAll = true;
			node.expand(true);
		} else {
			node = othis.__getRootNode();
		}

		if (node) {
			node.visit(function(child) {
				// let node know we want to load all the children
				child.data.expandAll = true;
				child.expand(true);
			});
		}
	});

	this.$ds_timeline.on("assignAccess", function (event) {
		var node = event.node,
		objId = Timeline.getDeliverableId(node);
		if (objId) {
			var redir = encodeURIComponent("../../common/emxIndentedTable.jsp?fromExt=true&objectId=" + objId + "&program=emxDomainAccess:getObjectAccessList&table=DomainAccess&editLink=true&selection=multiple&toolbar=DomainAccessToolBar&header=emxFramework.DomainAccess.AccessView&expandLevelFilter=true&editRootNode=false&objectBased=false&hideRootSelection=true&displayView=details&showClipboard=false&HelpMarker=emxhelpmultipleownershipaccess&massUpdate=false");

			window.open(enoviaServer.getUrl() + 
					"/resources/bps/openpage?" + enoviaServer.getParams() + "&bps_url="+redir,
					"widgetPeople",
			"width=1000, height=500, top=200, left=200");
		} else {
			othis.$ds_timeline.trigger({
				type: "showError",
				message: "Please select a deliverable first."
			});
		}
	});
	
	this.$ds_timeline.on("editLifecycle", function (event) {
		var node = event.node,
		objId = (node && node.data)? node.data._objectId :null;
		if (objId) {
			var redir = encodeURIComponent("../../common/emxLifecycle.jsp?mode=advanced&showPageHeader=false?&objectId=" + objId);

			window.open(enoviaServer.getUrl() + 
					"/resources/bps/openpage?" + enoviaServer.getParams() + "&bps_url="+redir,
					"widgetLifecycle",
			"width=1000, height=500, top=200, left=200");
		} else {
			othis.$ds_timeline.trigger({
				type: "showError",
				message: "Please select a deliverable first."
			});
		}
	});
	
	this.$ds_timeline.on("setDates", function (event) {
		event.preventDefault();
		var $popup = othis.template.set_date_offset_popup(),
			$bdate = $popup.find('#date_begin'), $edate = $popup.find('#date_end'),
			preference;
		othis.__initDialog($popup, event.position);
		$bdate.datepicker({ dateFormat: Timeline.DATEPICKER_FORMAT});
		$edate.datepicker({ dateFormat: Timeline.DATEPICKER_FORMAT});
		$bdate.datepicker('setDate', new Date(othis.range.startDate.ms));
		$edate.datepicker('setDate', new Date(othis.range.endDate.ms));
		$popup.find('input:text:visible:first').blur();
		$popup.find('#ok').click(function () {
			var bdateObj = $bdate.datepicker('getDate'),
				edateObj = $edate.datepicker('getDate'),
				preference = JSON.stringify({start: bdateObj.getTime(), end: edateObj.getTime()});
			
			othis.setPreference(Timeline.PREFERENCE_DATE_RANGE, preference);
				bpsWidgetEngine.reDrawWidget(othis.data);
		});
	});
	
	this.$ds_timeline.on("createTemplate", function (event) {
		event.preventDefault();
		var $popup = othis.template.template_popup(), node = event.node;
		othis.__initDialog($popup, event.position);
		$popup.find('#deliverable_name').val(node.data.title);
		
		$popup.find('#ok').click(function () {
			var name = $popup.find('#template_name').val(), fields = [];
            Timeline.__closeDialog($popup);
            
            if (name) {
            	fields.push({name: "templateName", value: {displayValue: name, actualValue: name}});
            	bpsWidgetAPIs.addRelatedObject(othis.data, "templates", Timeline.getDeliverableId(node), fields);
                othis.__applyUpdates(othis.data, function() {
                	othis.__updateTemplates();
                });
            }
		});
	});

	this.$ds_timeline.on("createVersion", function (event) {
		event.preventDefault();
		var tmpId, fields = [], node = event.node,
			today = new Date(),
			deliverableId = Timeline.getDeliverableId(node),
			planId = Timeline.getPlanId(node),
			changedObjects = [];
		if (node && planId) {
        	fields.push({name: "sourcePlanId", value: {displayValue: planId, actualValue: planId}});
			fields.push({name: "originated", value: {displayValue: jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, today), actualValue: today.getTime()}});
			tmpId = bpsWidgetAPIs.addRelatedObject(othis.data, "plans", deliverableId, fields);
			changedObjects.push(bpsWidgetAPIs.getObject(othis.data, deliverableId));
			changedObjects.push(bpsWidgetAPIs.getRelatedObject(othis.data, "plans", deliverableId, tmpId));
			othis.__applyUpdates(othis.data, function() {			
				var plan, kpis, 
					planObj = bpsWidgetAPIs.getRelatedObject(othis.data, "plans", deliverableId, tmpId),
					deliverableObj = bpsWidgetAPIs.getObject(othis.data, deliverableId);
				planObj._show = true;
				plan = Timeline.__getChild({data: planObj,
					title: Timeline.getDeliverableTitle(deliverableObj),
					parentId: deliverableId, // need parent id for lookup
					physicalId: Timeline.getPhysicalId(node),
					isEditable: true});

				plan.title = plan.title + " v" + deliverableObj.relateddata.plans.datagroups.length; 
				kpis = Timeline.getKPIs({data: planObj, canEdit: plan.canEdit, gates: plan.gates});
				if (kpis.length > 0) {
					plan.kpis = Timeline.processItems(Timeline.mergeCommonItems(kpis));
					plan.isLazy = true;
				}
				
				// redraw the node
				othis.__addNodes(node.parent, plan, node.getNextSibling());
			}, changedObjects);
		}
	});

	this.$ds_timeline.on("activatePlan", function (event) {
		event.preventDefault();
		var node = event.targetNode,
			deliverableId = Timeline.getDeliverableId(node),
			planId = Timeline.getPlanId(node),
			fields = [], changedObjects = [], today = new Date();
		fields.push({name: "effectivityStartDate", value: {displayValue: jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, today), actualValue: today.getTime()}});
    	bpsWidgetAPIs.modifyRelatedObject(othis.data, "plans", deliverableId, planId, fields);
        changedObjects.push(bpsWidgetAPIs.getRelatedObject(othis.data, "plans", deliverableId, planId));
        othis.__applyUpdates(othis.data, function() {
			var planObj = bpsWidgetAPIs.getRelatedObject(othis.data, "plans", deliverableId, planId),
				activeNodes = othis.getActivePlanNodes(deliverableId);
			node.data.info.effectivityStartDate = jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, today);
			node.data.info.effectivityStartDate_actual = today.getTime();
			node.data.info.isActivePlan = true;
			node.render();
			
			activeNodes.forEach(function (active) {
				active.data.info.effectivityEndDate = jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, today);
				active.data.info.effectivityEndDate_actual = today.getTime();
				active.data.info.isActivePlan = false;
				active.render();

			});
        }, changedObjects);
	});

	this.$ds_timeline.on("createDeliverable", function (event) {
		event.preventDefault();
		var options, $popup = othis.template.deliverable_popup(), node = event.targetNode;
		othis.__initDialog($popup, event.position);
		options = othis.__getTemplateOptions();
		options.unshift({display: "Select", value: "select"});
		var optList = othis.template.option_list(options);
		$popup.find('#select-list').append(optList);
		
		$popup.find('#ok').click(function () {
			var templateId, newNode, parentId, name = $popup.find('#deliverable_name').val();
			if (name) {
				if (node) {
					if (event.hitMode == "over") {
						parentId = Timeline.getDeliverableId(node);
					} else if (event.hitMode == "before") {
						parentId = Timeline.getDeliverableId(node.parent);
					} else if (event.hitMode == "after") {
						parentId = Timeline.getDeliverableId(node.parent);
					}
				}
				else {
					parentId = null;
				}

				templateId = $popup.find('select').val();
				if (templateId == "select") {
					templateId = null;
				}

				Timeline.__closeDialog($popup);

				var fields = [], changedObjects = [];
				fields.push({name: "title", value: {displayValue: name, actualValue: name}});
				if (templateId) {
					fields.push({name: "templateId", value: {displayValue: templateId, actualValue: templateId}});
				} 
				var tmpId = bpsWidgetAPIs.addObject(othis.data, parentId, fields);
				changedObjects.push(bpsWidgetAPIs.getObject(othis.data, tmpId));
				othis.__applyUpdates(othis.data, function() {
					var data = bpsWidgetAPIs.getObject(othis.data, tmpId);
					var objects = [];
					objects.push(data);
					data = Timeline.preProcessObjects({data: objects, filter: true, dateRange: othis.getTimeMachineRange()});

					if (templateId) {
						newNode = data[0];
					} else {
						newNode = {title: data[0].title, gates: [], _objectId: data[0]._objectId, _physicalId: data[0]._physicalId, canEdit: data[0].canEdit, 
								canDelete: data[0].canDelete, canChangeName: data[0].canChangeName,
								info: {effectivityStartDate_actual: 0, effectivityStartDate: ""}};
					}

					if (node) {
						if (event.hitMode == "over") {
							othis.__addNodes(node, newNode);
							node.expand(true);
						} else if (event.hitMode == "before") {
							othis.__addNodes(node.parent, newNode, node);
						} else if (event.hitMode == "after") {
							othis.__addNodes(node.parent, newNode, node.getNextSibling());
						}
					}
					else {
						othis.__addNodes(othis.__getRootNode(), newNode);
					}
				}, changedObjects);
			}
		});
	});
	
	this.$ds_timeline.on("editDeliverable", function (event) {
		event.preventDefault();
		var $popup = othis.template.edit_deliverable_popup(),
			node = event.node,
			deliverableId = Timeline.getDeliverableId(node),
			deliverableObj = bpsWidgetAPIs.getObject(othis.data, deliverableId),
			deliverableTitle = Timeline.getDeliverableTitle(deliverableObj);
		othis.__initDialog($popup, event.position);
		$popup.find('#deliverable_name').val(deliverableTitle.htmlDecode());
		$popup.find('#ok').click(function () {
			var name = $popup.find('#deliverable_name').val(), changedObjects = [];
			if (name && deliverableId && (name != deliverableTitle)) {
				var fields = [];
				fields.push({name: "title", value: {displayValue: name, actualValue: name}});
            	changedObjects.push(deliverableObj);
            	bpsWidgetAPIs.modifyObject(othis.data, deliverableId, fields);
	            othis.__applyUpdates(othis.data, function() {
	    			deliverableObj = bpsWidgetAPIs.getObject(othis.data, deliverableId);
					othis.renameNodes(deliverableId, deliverableTitle, Timeline.getDeliverableTitle(deliverableObj));
	            }, changedObjects);
			}
			
			Timeline.__closeDialog($popup);
		});
		$popup.find('#delete').click(function () {
			var deliverableId = Timeline.getDeliverableId(node), 
				planId = Timeline.getPlanId(node),
				changedObjects = [], deliverableObj;
			if (Timeline._confirmDelete(jQuery(this))) {
				if (deliverableId || planId) {
					deliverableObj = bpsWidgetAPIs.getObject(othis.data, deliverableId);
					
					if (planId && deliverableObj.relateddata && deliverableObj.relateddata.plans && deliverableObj.relateddata.plans.datagroups.length > 1) {
						changedObjects.push(bpsWidgetAPIs.getRelatedObject(othis.data, "plans", deliverableId, planId));
						bpsWidgetAPIs.deleteRelatedObject(othis.data, "plans", deliverableId, planId);
					}
					else {
						changedObjects.push(deliverableObj);
						bpsWidgetAPIs.deleteObject(othis.data, deliverableId); 
					}
					othis.__applyUpdates(othis.data, function() {
						othis.removeNodes(deliverableId, planId);
						othis.renumberPlans(deliverableId);
					}, changedObjects);
				}

				Timeline.__closeDialog($popup);
			}
		});
	});
	
	this.$ds_timeline.on("frameDeliverable", function (event) {
		var node = event.node;
		var earliestStartDate = Number.MAX_VALUE;
		var latestEndDate = Number.MIN_VALUE;
		var testBeginAndEnd = function (date) {
			if (date < earliestStartDate && date > othis.range.startDate.ms) {
				earliestStartDate = date;
			}
			
			if (date > latestEndDate && date < othis.range.endDate.ms) {
				latestEndDate = date;
			}
		}
		
		if (node.data.info.effectivityStartDate_actual) {
			testBeginAndEnd(parseInt(node.data.info.effectivityStartDate_actual));
		}
		else {
			if (node.data.info.originatedDate_actual) {
				testBeginAndEnd(parseInt(node.data.info.originatedDate_actual));
			}
		}
		
		if (node.data.info.effectivityEndDate_actual) {
			testBeginAndEnd(parseInt(node.data.info.effectivityEndDate_actual));
		}
		
		
		if (node.data.gates) {
			node.data.gates.forEach(function (gate) {
				if (gate.mEDate_actual) {
					testBeginAndEnd(parseInt(gate.mEDate_actual));
				}
			});
		}
		
		if (node.data.versions) {
			node.data.versions.forEach(function (version) {
				if (version.effectivityStartDate_actual) {
					testBeginAndEnd(parseInt(version.effectivityStartDate_actual));
				}
			});
		}
		
		if (earliestStartDate == latestEndDate) {
			latestEndDate = othis.range.endDate.ms;
		}
			
		if (earliestStartDate == Number.MAX_VALUE) {
			earliestStartDate = othis.range.startDate.ms;
		}
		
		if (latestEndDate == Number.MIN_VALUE) {
			latestEndDate = othis.range.endDate.ms;
		}
		
		var margin = othis.one_day * 7;
		earliestStartDate = Math.max(earliestStartDate - margin, othis.range.startDate.ms);
		latestEndDate = Math.min(latestEndDate + margin, othis.range.endDate.ms);
		
		othis._frame(earliestStartDate, latestEndDate);
		othis.syncSlider();
	});
	
	this.$ds_timeline.on("createGatePopup", function (event) {
		event.preventDefault();
		var $popup = othis.template.gate_popup(),
			$date = $popup.find('#gate_date'),
			node = event.targetNode;
		othis.__initDialog($popup, event.position);
		$date.datepicker({ dateFormat: Timeline.DATEPICKER_FORMAT });
		$date.datepicker('setDate', new Date(event.date));
		var optList = othis.template.gate_status_list();
		optList.val("no_risk");
		$popup.find('#select-list').append(optList);
		$popup.find('#gate_comment_div').hide();
		$popup.find('#select-list select').change(function() {
			var status = jQuery(this).val();
			$popup.find('#gate_comment_div').toggle(status == 'complete' || status == 'low_risk' || status == 'high_risk');
		})
		
		$popup.find('#ok').click(function () {
			othis.$ds_timeline.trigger({
				type: "createGate",
				targetNode: node,
				gate: {
					name: $popup.find('#gate_name').val(),
					status: $popup.find('#select-list select').val(), 
					comment: $popup.find('#gate_comment').val(), 
					date: $date.val(), 
					date_actual: $date.datepicker('getDate').getTime()
				}
			});
			
			Timeline.__closeDialog($popup);
		});
	});

	this.$ds_timeline.on("createGate", function (event) {
		event.preventDefault();
		var node = event.targetNode,
			today = new Date(),
			planId = Timeline.getPlanId(node),
			deliverableId = Timeline.getDeliverableId(node),
			gateObj, planObj, gateId,
			fields = [], planFields = [], changedObjects = [];

		if (event.gate && event.gate.name && event.gate.date) {
			// add an empty plan to the deliverable if there isn't one already
			if (!planId) {
				planFields.push({name: "originated", value: {displayValue: jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, today), actualValue: today.getTime()}});
				planId = bpsWidgetAPIs.addRelatedObject(othis.data, "plans", deliverableId, planFields);
			}
			planObj = bpsWidgetAPIs.getRelatedObject(othis.data, "plans", deliverableId, planId);
			
			// if we are doing a paste link of a regular gate then use the object id of the gate as the shadow
			if (event.createLink && event.gate.objectId) {
				fields.push({name: "shadowId", value: {displayValue: event.gate.objectId, actualValue: event.gate.objectId}});
			}
			// if we are doing a paste of a reference gate then use the object id of the reference's shadow
			else if (event.gate.shadowId) {
				fields.push({name: "shadowId", value: {displayValue: event.gate.shadowId, actualValue: event.gate.shadowId}});
			}
				
			fields.push({name: "mName", value: {displayValue: event.gate.name, actualValue: event.gate.name}});
			fields.push({name: "mEDate", value: {displayValue: event.gate.date, actualValue: event.gate.date_actual}});
			gateId = bpsWidgetAPIs.addRelatedObject(othis.data, "gates", planObj, fields);
			gateObj = bpsWidgetAPIs.getRelatedObject(othis.data, "gates", planObj, gateId);
			changedObjects.push(gateObj);
			changedObjects.push(planObj);
	
			// update changes to status
			if (event.gate.status == 'complete') {
				fields.length = 0;
				fields.push({name: "isComplete", value: {displayValue: true, actualValue: true}});
				fields.push({name: "approvalComment", value: {displayValue: event.gate.comment, actualValue: event.gate.comment}});
				bpsWidgetAPIs.modifyRelatedObject(othis.data, "gates", planObj, gateId, fields);
			}
			else if (event.gate.status == 'low_risk' || event.gate.status == 'high_risk') {
				fields.length = 0;
				fields.push({name: "title", value: {displayValue: event.gate.status, actualValue: event.gate.status}});
				fields.push({name: "description", value: {displayValue: event.gate.comment, actualValue: event.gate.comment}});
				bpsWidgetAPIs.addRelatedObject(othis.data, "risks", gateObj, fields);
			}
	
			othis.__applyUpdates(othis.data, function(retValue) {
				planObj = bpsWidgetAPIs.getRelatedObject(othis.data, "plans", deliverableId, planId);
				gateObj = bpsWidgetAPIs.getRelatedObject(othis.data, "gates", planObj, gateId);
				// update node data
				if (!(node.data.gates && node.data.gates.push)) {
					node.data.gates = [];
				}
	
				// save this in case plan was created here
				node.data._objectId = planObj.objectId;
				node.data._parentId = deliverableId;
				
				// must set the originated date for the dashed line to draw
				if (planFields.length > 0) { 
					node.data.info.originatedDate = planFields[0].value.displayValue;
					node.data.info.originatedDate_actual = planFields[0].value.actualValue;
				}
				
				node.data.gates.push(Timeline.getGate(gateObj, true));
				node.render();
	        }, changedObjects);
		};
	});

	this.$ds_timeline.on("deleteGate", function (event) {
		event.preventDefault();
		var node = event.node, gates = node.data.gates, gate = event.gate, index = Timeline.getGateIndex(gates, gate._objectId),
			planObj = bpsWidgetAPIs.getRelatedObject(othis.data, "plans", Timeline.getDeliverableId(node), Timeline.getPlanId(node)),
			changedObjects = [];
		
		changedObjects.push(planObj);
		changedObjects.push(bpsWidgetAPIs.getRelatedObject(othis.data, "gates", planObj, gate._objectId));
		bpsWidgetAPIs.deleteRelatedObject(othis.data, "gates", planObj, gate._objectId); 
		othis.__applyUpdates(othis.data, function() {
			// on success remove associated objectives from the timeline
			var objective, objectiveNode, objectiveIndex,
			objectives = jQuery(node.li).find('.m-id-' + gate._objectId.replace(/\./g, '-')),
			redrawNodes = [], deleteNodes = [];
			objectives.each(function () {
				objectiveNode = othis.__getNode(jQuery(this));
				objectiveIndex = Timeline.getGateIndex(objectiveNode.data.gates, jQuery(this).attr('data-id'));
				objective = objectiveNode.data.gates[objectiveIndex];
				objectiveNode.data.gates.splice(objectiveIndex, 1);
				objectiveNode.data.gates.length > 0 ? redrawNodes.push(objectiveNode) : deleteNodes.push(objectiveNode);
			});
			redrawNodes.forEach(function (redrawNode) {
				redrawNode.render();
			});
			deleteNodes.forEach(function (deleteNode) {
				deleteNode.remove();
			});

			gates.splice(index, 1);
			node.render();
		}, changedObjects);
	});
			
	this.$ds_timeline.on("whereUsed", function (event) {
		event.preventDefault();
		var node = event.node, 
			gate = event.gate, 
			gateId = gate.shadowId ? gate.shadowId : gate._objectId,
			$popup = othis.template.where_used_popup();
		
		
		bpsWidgetAPIs.loadWidget("DPG_Reference_Gate?objectId=" + gateId, function(data) {
			$popup.prepend(bpsWidgetAPIs.__drawWidget(data));
			othis.__initDialog($popup, event.position);

		});
	});
			
	this.$ds_timeline.on("editGate", function (event) {
		var node = event.node,
			gates = event.node.data.gates,
			index = Timeline.getGateIndex(gates, event.id),
			gate, $popup, $date, $name;
		
		if (index != -1) {
			gate = gates[index];
			event.preventDefault();
			$popup = event.edit ? othis.template.edit_gate_popup() : othis.template.view_gate_popup();
			othis.__initDialog($popup, event.position);
			$date = $popup.find('#gate_date');
			$name = $popup.find('#gate_name');
			$name.val(gate.mName.htmlDecode());
			$popup.find('input:text:visible:first').focus();
			$popup.find('#gate_comment').val(gate.status.comment.htmlDecode());
			$popup.find('#select-list').append(othis.template.gate_status_list().val(gate.status.value));
			$popup.find('#gate_comment_div').toggle(gate.status.value == 'complete' || gate.status.value == 'low_risk' || gate.status.value == 'high_risk');
			$popup.find('#select-list select').change(function() {
				var status = jQuery(this).val();
				$popup.find('#gate_comment_div').toggle(status == 'complete' || status == 'low_risk' || status == 'high_risk');
			})
			
			if (event.edit) {
				// don't allow editing of name or date for reference gate
				if (gate.isReference == true) {
					$date.val(jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, new Date(parseInt(gate.mEDate_actual))));
					$date.prop('readonly', true);
					$name.prop('readonly', true);
				}
				else {
				$date.datepicker({ dateFormat: Timeline.DATEPICKER_FORMAT });
				$date.datepicker('setDate', new Date(parseInt(gate.mEDate_actual)));
			}
			}
			else {
				$date.val(jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, new Date(parseInt(gate.mEDate_actual))));				
				$popup.find('#select-list select').attr('disabled', true);
			}
			
			$popup.find('#ok').click(function () {
				var name = $popup.find('#gate_name').val(),
					comment = $popup.find('#gate_comment').val(),
					status = $popup.find('#select-list select').val(),
					date = $date.val(),
					planId = Timeline.getPlanId(node),
					deliverableId = Timeline.getDeliverableId(node),
					dateObj = $date.datepicker('getDate'),
					planObj = bpsWidgetAPIs.getRelatedObject(othis.data, "plans", deliverableId, planId),
					gateObj = bpsWidgetAPIs.getRelatedObject(othis.data, "gates", planObj, gate._objectId),
					fields = [], riskFields = [], changedObjects = [];
				
				if (name && date) {
					changedObjects.push(gateObj);
					
					if (name != gate.mName.htmlDecode()) {
					fields.push({name: "mName", value: {displayValue: name, actualValue: name}});
					}
					if (date != gate.mEDate) {
					fields.push({name: "mEDate", value: {displayValue: date, actualValue: dateObj.getTime()}});
					}
	            	
					// update changes to status
					if (status != gate.status.value) {
						if (status == 'complete') {
							fields.push({name: "isComplete", value: {displayValue: true, actualValue: true}});
							fields.push({name: "approvalComment", value: {displayValue: comment, actualValue: comment}});
						}
						else {
							if (gate.status.value == 'complete') {
								fields.push({name: "isComplete", value: {displayValue: false, actualValue: false}});
							}
							
							if (status == 'no_risk') {
								// remove risk if there is one
								if (gate.status.riskId) {
					        		changedObjects.push(bpsWidgetAPIs.getRelatedObject(othis.data, "risks", gateObj, gate.status.riskId));
									bpsWidgetAPIs.deleteRelatedObject(othis.data, "risks", gateObj, gate.status.riskId);
								} 
								
							}
							else if (status == 'low_risk' || status == 'high_risk') {
								riskFields.push({name: "rpnValue", value: {displayValue: status, actualValue: status}});
								riskFields.push({name: "description", value: {displayValue: comment, actualValue: comment}});
					        	if (gate.status.riskId) {
					        		changedObjects.push(bpsWidgetAPIs.getRelatedObject(othis.data, "risks", gateObj, gate.status.riskId));
					        		bpsWidgetAPIs.modifyRelatedObject(othis.data, "risks", gateObj, gate.status.riskId, riskFields);
					        	}
					        	else {
					        		var tmpId = bpsWidgetAPIs.addRelatedObject(othis.data, "risks", gateObj, riskFields);
					        		changedObjects.push(bpsWidgetAPIs.getRelatedObject(othis.data, "risks", gateObj, tmpId));
					        	}
							}
						}
					}
					else {
						if (status == 'complete') {
							fields.push({name: "approvalComment", value: {displayValue: comment, actualValue: comment}});
						}
						else if (status == 'low_risk' || status == 'high_risk') {
			        		changedObjects.push(bpsWidgetAPIs.getRelatedObject(othis.data, "risks", gateObj, gate.status.riskId));
							riskFields.push({name: "description", value: {displayValue: comment, actualValue: comment}});
			        		bpsWidgetAPIs.modifyRelatedObject(othis.data, "risks", gateObj, gate.status.riskId, riskFields);
						}
					}
					
					var redrawNodes = othis.__updateGate(node, gate, fields);
	            	othis.__applyUpdates(othis.data, function() {
						planObj = bpsWidgetAPIs.getRelatedObject(othis.data, "plans", deliverableId, planId);
						gateObj = bpsWidgetAPIs.getRelatedObject(othis.data, "gates", planObj, gate._objectId);
						// rebuild gate from new data
	            		gates[index] = Timeline.getGate(gateObj, gate.canEdit);
	            		othis.__redrawNodes(redrawNodes);
	            	}, changedObjects);

				};
	
				Timeline.__closeDialog($popup);
			});
			$popup.find('#delete').click(function () {
				if (Timeline._confirmDelete(jQuery(this))) {
					othis.$ds_timeline.trigger({
						type: "deleteGate",
						node: node,
						gate: gate
					});

					Timeline.__closeDialog($popup);
				}
			});
		}
	});
	
	this.$ds_timeline.on("createObjective", function(event) {
		event.preventDefault();
		var index, gateId = event.id, 
			arrList = jQuery.extend(true, [], bpsWidgetAPIs.getField(othis.data, 'kpiType').range.item), 
			$popup = othis.template.objective_popup(), date = jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, new Date(event.date)),
			node = event.targetNode,
			planObj = bpsWidgetAPIs.getRelatedObject(othis.data, "plans", Timeline.getDeliverableId(node), Timeline.getPlanId(node));

		if (!gateId) {
			node = node.getParent();
			if (node.data.gates) {
				for (index = 0; index < node.data.gates.length; index++) {
					if (date == node.data.gates[index].mEDate) {
						gateId = node.data.gates[index]._objectId;
						break;
					}
				}
			}
		} 
			
		if (!gateId) {
			othis.$ds_timeline.trigger({
				type: "showError",
				position: event.position,
				message: "Drop objective icon on gate or objective lane below gate."
			});
			return;
		} 
			
		othis.__initDialog($popup, event.position);
		if (Timeline.isObjective(event.targetNode)) {
			for (index = 0; index < arrList.length; index++) {
				if (event.targetNode.data.title == arrList[index].display) {
					var optList = othis.template.option_list(arrList);
					optList.val(arrList[index].display.htmlDecode());
					optList.attr("disabled", true);
					$popup.find('#select-list').append(optList);
					othis.creatFormfield($popup.find('#dynamic-field'), arrList[index]);
					$popup.find('input:not(:button):visible:first').focus();
					break;
				}
			}
		}
		else {
			if(arrList.length) {
				arrList.unshift({
					display: "Select",
					value: ""
				}); //add first option
				var optList = othis.template.option_list(arrList);
				optList.on('change', function() {
					othis.creatFormfield($popup.find('#dynamic-field'), arrList[this.selectedIndex])
					$popup.find('input:not(:button):visible:first').focus();
				});
				$popup.find('#select-list').append(optList);
			}
			
			$popup.find('select').focus();
		}
			
		$popup.find('#ok').click(function() {
			var value, input, name, firstChild, info, fields, newNode, gates, newGate, targetGate, tmpId = "", tmpGateId;
			input = $popup.find('input:not(:button)');
			name = input.attr('name');
			value = input.val();

			if (value) {
				// test if an objective of the given type already exists for the gate
				tmpGateId = gateId;
				if (gateId.indexOf("temp_") != -1) {
					tmpGateId = bpsWidgetAPIs.getRelatedObject(othis.data, "gates", planObj, gateId).objectId;
				}
	            
	            //update
				fields = [];
				fields.push({name: "kpiKind", value: {displayValue: "Objective", actualValue: "Objective"}});
				fields.push({name: "kpiType", value: {displayValue: name, actualValue: name}});
				fields.push({name: "kpiValue", value: {displayValue: value, actualValue: value}});
				fields.push({name: "kpiGateId", value: {displayValue: tmpGateId, actualValue: tmpGateId}});
	        	tmpId = bpsWidgetAPIs.addRelatedObject(othis.data, "kpis", planObj, fields);
	            othis.__applyUpdates(othis.data, function() {	
	            	// add node to tree
	            	gates = Timeline.getGates({node: node, name: name, type: Timeline.OBJECTIVE_CLASS});

	            	targetGate = Timeline.findGate(node.data.gates, gateId);
	            	newGate = {mName: value, 
	            			mEDate: targetGate.mEDate,
	            			mEDate_actual: targetGate.mEDate_actual,
	            			_objectId: tmpId, kpiGateId: gateId,
	            			canEdit: true};
	            	gates.push(newGate);

	            	info = {effectivityStartDate_actual: 0, effectivityStartDate: ""};
	            	newNode = {title: name, gates: gates, info: info, addClass: Timeline.OBJECTIVE_CLASS};
	            	firstChild = (node.childList) ? node.childList[0] : null;
	            	if (gates.length > 1) {
	            		node.render();
	            	} else {
	            		othis.__addNodes(node, newNode, firstChild);
	            	}
	            	node.expand(true);
	            });
			}
			
			Timeline.__closeDialog($popup);

		});
	});
	
	this.$ds_timeline.on("editObjective", function (event) {
		var node = event.node,
			gates = event.node.data.gates,
			index = Timeline.getGateIndex(gates, event.id),
			planObj = bpsWidgetAPIs.getRelatedObject(othis.data, "plans", Timeline.getDeliverableId(node), Timeline.getPlanId(node)),
			gate, changedObjects = [];
	
		if (index != -1) {
			gate = gates[index];
			event.preventDefault();
			changedObjects.push(planObj);
			var $popup = event.edit ? othis.template.edit_objective_popup() : othis.template.view_objective_popup();
			othis.__initDialog($popup, event.position);
			$popup.find('#gate_name').val(node.data.title.htmlDecode());
			$popup.find('#gate_value').val(gate.mName.htmlDecode());
			$popup.find('input:not(:button):visible:last').focus();
			$popup.find('#ok').click(function () {
				var value = $popup.find('#gate_value').val();
				if (value) {
					var fields = [];
					fields.push({name: "kpiValue", value: {displayValue: value, actualValue: value}});
	            	bpsWidgetAPIs.modifyRelatedObject(othis.data, "kpis", planObj, gate._objectId, fields); 
	            	othis.__applyUpdates(othis.data, function() {
						gate.mName = value;
						node.render();
	            	}, changedObjects);
				};
	
				Timeline.__closeDialog($popup);
			});
			$popup.find('#delete').click(function () {
				if (Timeline._confirmDelete(jQuery(this))) {
					bpsWidgetAPIs.deleteRelatedObject(othis.data, "kpis", planObj, gate._objectId); 
					othis.__applyUpdates(othis.data, function() {
						gates.splice(index, 1);
						gates.length > 0 ? node.render() : node.remove();
					}, changedObjects);
					Timeline.__closeDialog($popup);
				}
			});
		}
	});
	
	this.$ds_timeline.on("createRealized", function (event) {
		event.preventDefault();
		var types = bpsWidgetAPIs.getField(othis.data, 'kpiType').range.item,
			$popup = othis.template.realized_popup(),
			$name = $popup.find('#gate-name'),
			$date = $popup.find('#gate_date'),
			node = event.targetNode,
			name = event.targetNode.data.title,
			changedObjects = [];

		if (types.length == 0 || Timeline.isDeliverable(node) || Timeline.isTemplate(node) || Timeline.isTemplate(node.parent)) {
			return;
		}
		
		$popup.find('#gate_name').val(name.htmlDecode());
		$date.datepicker({ dateFormat: Timeline.DATEPICKER_FORMAT });
		$date.datepicker('setDate', new Date(event.date));
		for (var i = 0; i < types.length; i++) {
			if (name == types[i].display) {
				othis.creatFormfield($popup.find('.dynamic-field'), types[i]);
				break;
			}
		}
			
		othis.__initDialog($popup, event.position);
		$popup.find('input:not(:button):visible:last').focus();

		$popup.find('#ok').click(function() {
			var $input = $popup.find("[name='" + name + "']"),
				value = $input.val(),
				date = $date.val(),
				dateObj = $date.datepicker('getDate'),
				fields = [],
				info, newNode, tmpId;

			//update
			fields.push({name: "kpiKind", value: {displayValue: "Measure", actualValue: "Measure"}});
			fields.push({name: "kpiType", value: {displayValue: name, actualValue: name}});
			fields.push({name: "kpiValue", value: {displayValue: value, actualValue: value}});
			fields.push({name: "kpiDate", value: {displayValue: date, actualValue: dateObj.getTime()}});
        	tmpId = bpsWidgetAPIs.addRelatedObject(othis.data, "kpis", Timeline.getDeliverableId(node), fields);
            othis.__applyUpdates(othis.data, function() {	
            	if (Timeline.isObjective(node)) {
            		newNode = Timeline.findNode(node.parent, Timeline.REALIZED_CLASS, name);

            		if (!newNode) {
            			info = {effectivityStartDate_actual: 0, effectivityStartDate: ""};
            			newNode = othis.__addNodes(node.parent, {title: name, gates: [], info: info, addClass: Timeline.REALIZED_CLASS}, node.getNextSibling());
            			node.parent.expand(true);
            		}

            		node = newNode;
            	} 

            	// update node data
            	if (!(node.data.gates && node.data.gates.push)) {
            		node.data.gates = [];
            	}

            	node.data.gates.push({mName: value,
            		mEDate: date,
            		mEDate_actual: dateObj.getTime(),
            		_objectId: tmpId,
            		canEdit: true});
            	node.render();
            }, changedObjects);
			
			Timeline.__closeDialog($popup);
		});
	});
	
	this.$ds_timeline.on("editRealized", function (event) {
		var node = event.node,
			gates = event.node.data.gates,
			index = Timeline.getGateIndex(gates, event.id),
			deliverableId = Timeline.getDeliverableId(node),
			gate, changedObjects = [];
	
		if (index != -1) {
			gate = gates[index];
			event.preventDefault();
			changedObjects.push(bpsWidgetAPIs.getObject(othis.data, deliverableId));
			changedObjects.push(bpsWidgetAPIs.getRelatedObject(othis.data, "kpis", deliverableId, gate._objectId));
			var $popup = event.edit ? othis.template.edit_realized_popup() : othis.template.view_realized_popup();
			othis.__initDialog($popup, event.position);
			$popup.find('#gate_name').val(node.data.title.htmlDecode());
			$popup.find('#gate_value').val(gate.mName.htmlDecode());
			$popup.find('input:not(:button):visible:last').focus();
			$popup.find('#ok').click(function () {
				var value = $popup.find('#gate_value').val();
				if (value) {
					var fields = [];
					fields.push({name: "kpiValue", value: {displayValue: value, actualValue: value}});
	            	bpsWidgetAPIs.modifyRelatedObject(othis.data, "kpis", deliverableId, gate._objectId, fields); 
	            	othis.__applyUpdates(othis.data, function() {
						gate.mName = value;
						node.render();
	            	}, changedObjects);
				};
	
				Timeline.__closeDialog($popup);
			});
			$popup.find('#delete').click(function () {
				if (Timeline._confirmDelete(jQuery(this))) {
					bpsWidgetAPIs.deleteRelatedObject(othis.data, "kpis", deliverableId, gate._objectId); 
					othis.__applyUpdates(othis.data, function() {
						gates.splice(index, 1);
						gates.length > 0 ? node.render() : node.remove();
					}, changedObjects);
					Timeline.__closeDialog($popup);
				}
			});
		}
	});

	this.$ds_timeline.on("showError", function (event) {
		event.preventDefault();
		var $popup = othis.template.error_popup();
		othis.__initDialog($popup, event.position);
		$popup.find('#error_text').append(event.message);
		$popup.find('#ok').click(function () {
            Timeline.__closeDialog($popup);
		});
	});
	
	/** ========== INTERACTION TIME-SLIDER ========== **/
	//Ajouter le time-slider  
	this.$ds_timeline.find(".timeSlider")[0].slide = null;
	this.$ds_timeline.find(".timeSlider").slider({
		handle: '.handle',
		range: true,
		animate:false,
		min: 0,
		max: 100,
		values: [ 0,0 ],
		step: 1,
		create: function() {
			var pognote = jQuery(this).children('.ui-slider-range').append('<div class="pognote"><a></a></div>');
			pognote.draggable({
				axis: 'x',
				containment: 'parent',
				start: function(event, ui) {

				},
				drag: function(event, ui) {
					var values = othis.$context_node.find(".timeSlider" ).slider('values');
					var diff = values[1] - values[0];
					var left = Math.ceil(ui.position.left / 2);
						values[0] = left;
						values[1] = left + diff;
						othis.$context_node.find(".timeSlider" ).slider('values', values);
					othis.scroll(diff == 100 ? 0 : Math.ceil((left / (100 - diff)) * 100));
				},
				stop: function(event, ui) {

				}
			});
			// add class to handles to identify as left and right
			jQuery(this).children('.ui-slider-handle:first').addClass('ui-slider-left');
			jQuery(this).children('.ui-slider-handle:last').addClass('ui-slider-right');
		},
		start: function(event, ui) {

		},
		slide: function(event, ui) {
			var diff = ui.values[1] - ui.values[0];
			othis.scale(diff, diff == 100 ? 0 : Math.ceil((ui.values[0] / (100 - diff)) * 100));
		},
		change: function(event, ui) {

		},
		stop: function(event, ui) {
		}
	});

	jQuery.contextMenu({
		selector: '.context-menu-tree-node',
		zIndex: 10,
		autoHide: true,
		events: {
			show: function(opt) { 
				var node = othis.__getNode(jQuery(this));
				return (Timeline.isDeliverable(node));
			}
		},
		items: {
			"new": {name: "New", items: {
				"newDeliverable": {name: "Deliverable...", icon: "", callback: function () {
					othis.$ds_timeline.trigger({
						type: "createDeliverable",
						targetNode: othis.__getNode(jQuery(this)),
						hitMode: "over"
					});
				}, disabled: function () {return (!othis.isEditable(othis.__getNode(jQuery(this))))}},
				"newTemplate": {name: "Template...", icon: "", callback: function () {
					othis.$ds_timeline.trigger({
						type: "createTemplate",
						node: othis.__getNode(jQuery(this))
					});
				}},
				"newVersion": {name: "Version", icon: "", callback: function () {
					othis.$ds_timeline.trigger({
						type: "createVersion",
						node: othis.__getNode(jQuery(this))
					});
				}, disabled: function () {return (!othis.isEditable(othis.__getNode(jQuery(this))))}}
			}},
			"access": {name: "Access", icon: "", callback: function() {
				othis.$ds_timeline.trigger({
					type: "assignAccess",
					node: othis.__getNode(jQuery(this))
				});
			}},
			"lifecycle": {name: "Lifecycle", icon: "", callback: function() {
				othis.$ds_timeline.trigger({
					type: "editLifecycle",
					node: othis.__getNode(jQuery(this))
				});
			}},
			"expandDeliverable": {name: "Expand", icon: "", callback: function() {
				othis.$ds_timeline.trigger({
					type: "expandNode",
					node: othis.__getNode(jQuery(this))
				});
			}},
			"frameDeliverable": {name: "Reframe", icon: "", callback: function() {
				var node = othis.__getNode(jQuery(this));
				othis.$ds_timeline.trigger({
					type: "frameDeliverable",
					node: node
				});
			}}
		}
	});
	jQuery.contextMenu({
		selector: '.lane',
		zIndex: 1,
		events: {
			show: function(opt) { 
				var node = othis.__getNode(jQuery(this));
				return (othis.isEditable(node) && Timeline.isDeliverable(node));
			}
		},
		items: {
			"new": {name: "New", items: {
				"newDeliverable": {name: "Gate...", icon: "", callback: function () {
					othis.$ds_timeline.trigger({
						type: "createGatePopup",
						targetNode: othis.__getNode(jQuery(this))
					});
				}}
			}},
			"paste": {name: "Paste", icon: "paste", 
				callback: function(key, options) {
					var node = othis.__getNode(this);
					var clipboard = othis.__getClipboard();
					
					othis.$ds_timeline.trigger({
						type: "createGate",
						targetNode: node,
						gate: clipboard
					});
				},
				disable: function(key, options) {
					var clipboard = othis.__getClipboard();
					return !(clipboard && clipboard.type == "gate");
				}
			},
			"pastelink": {name: "Paste Link", icon: "", 
				callback: function(key, options) {
					var node = othis.__getNode(this);
					var clipboard = othis.__getClipboard();
					
					othis.$ds_timeline.trigger({
						type: "createGate",
						targetNode: node,
						gate: clipboard,
						createLink : true
					});
				},
				disable: function(key, options) {
					var clipboard = othis.__getClipboard();
					return !(clipboard && clipboard.type == "gate" && clipboard.isReference == true);
			}
		}
			
		}
	});
	jQuery.contextMenu({
		selector: '.context-menu-gate',
		zIndex: 1,
		autoHide: true,
		events: {
			show: function(opt) { 
				var node = othis.__getNode(jQuery(this));
				return (othis.isEditable(node) && Timeline.isDeliverable(node));
			}
		},
		items: {
			"new": {name: "New", items: {
				"newobjective": {name: "Objective...", icon: "", 
					callback: function () {
						othis.$ds_timeline.trigger({
							type: "createObjective",
							id: jQuery(this).attr('data-id'),
							position: this.offset(),
							targetNode: othis.__getNode(this)
						});
					},
					disabled: function () {return (!othis.isEditable(othis.__getNode(jQuery(this))))}
				}
			}},
			"edit": {name: "Edit", icon: "edit", callback: function (key, options) {
				var type, node = othis.__getNode(this), canEdit = othis.isEditable(node);
				
				if (Timeline.isRealized(node)) {
					type = "editRealized";
				} else if (Timeline.isObjective(node)) {
					type = "editObjective";
				} else {
					type = "editGate";
				}

				othis.$ds_timeline.trigger({
					type: type,
					node: node,
					edit: canEdit, 
					id: this.attr('data-id'),
					position: this.offset()
				});
			}},
			"copy": {name: "Copy", icon: "copy", callback: function (key, options) {
				var node = othis.__getNode(this),
					gate = Timeline.findGate(node.data.gates, this.attr('data-id')),
					copy = {};
				copy.type = "gate";
				copy.name = gate.mName.htmlDecode();
				copy.status = gate.status.value;
				copy.comment = gate.status.comment.htmlDecode();
				copy.date = gate.mEDate;
				copy.date_actual = gate.mEDate_actual;
				copy.objectId = gate._objectId;
				copy.isReference = gate.isReference;
				if (copy.isReference) {
					copy.shadowId = gate.shadowId;
				}
				othis.__setClipboard(copy);
			}},
			"delete": {name: "Delete", icon: "delete", 
				callback: function (key, options) {
					var node = othis.__getNode(this), gate = Timeline.findGate(node.data.gates, this.attr('data-id'));
	
					if (confirm("Delete gate " + gate.mName.htmlDecode() + ".  Are you sure?")) {
						othis.$ds_timeline.trigger({
							type: "deleteGate",
							node: node,
							gate: gate
						});
					}
				},
				disabled: function () {
					var $this = jQuery(this);
					return (!othis.isEditable(othis.__getNode($this)));
				}
			},
			"whereused": {name: "Where Used", icon: "", 
				callback: function (key, options) {
					var node = othis.__getNode(this),
						gate = Timeline.findGate(node.data.gates, this.attr('data-id'));
					othis.$ds_timeline.trigger({
						type: "whereUsed",
						node: node,
						gate: gate,
						position: this.offset()
					});
				}
			}
		}
	});
};
Timeline.prototype.setTimeMachine = function (range) {
	// if no date range then use today
	var startDate = (range && range.start) ? new Date(range.start) : new Date(),
		endDate = (range && range.end) ? new Date(range.end) : new Date(),
		daysBetween = Timeline.days_between(new Date(this.range.startDate.ms), startDate),
		beginLeft = (daysBetween) / this.range.days * 100, 
		daysBetween = Timeline.days_between(new Date(this.range.startDate.ms), endDate),
		endLeft = (daysBetween + 1) / this.range.days  * 100;
	
	this.$time_machine_begin.css('left', beginLeft + '%');
	this.$time_machine_end.css('left', endLeft + '%');
//	this.getTimeMachineRange();
	this.highlightSelectedDays();
};
Timeline.prototype.drawDynaTree = function ($elm) {
	var othis = this;
	this.$timeline.dynatree({
	  debugLevel: 0,  //0-quiet, 1-normal, 2-debug
      onActivate: function(node) {
      },
      onCustomRender: function(node) {
        // Render title as columns
        if(!node.data.gates){
          // Default rendering
          return false;
        }
        var html = "<a class='dynatree-title context-menu-tree-node' href='#'>\
        			<span class='td " + (node.data.canEdit ? 'editable' : '') + "' data-pid='" + node.data._physicalId + "'>" + node.data.title + "</span></a>\
        			<span class='encapsulator'></span>\
        			<span class='lane'><div class='cart'><div class='dashed'></div>";
        var $elm = jQuery('<div></div>');
        var lane = othis.makeLane(node.data);
        othis.drawLaneItem($elm, lane);
        html += $elm.html();
        return html + "</div></span>";
      },
      onLazyRead: function(node) {
    	  var deliverableId = Timeline.getDeliverableId(node), planId = Timeline.getPlanId(node), 
    	  	  expandKey = deliverableId, object = bpsWidgetAPIs.getObject(othis.data, deliverableId);
    	  if (planId) {
    		  bpsWidgetAPIs.getRelatedObject(othis.data, "plans", deliverableId, planId)._expand = true;
    		  expandKey += planId;
    	  }
    	  object._expand = true;
          othis.__addNodes(node, node.data.kpis);
          othis.__addNodes(node, Timeline.getChildren({parent: object, expandAll: node.data.expandAll, dateRange: othis.getTimeMachineRange(), canEdit: node.data.canEdit}));

    	  othis.expandList[expandKey] = true;
    	  othis.setPreference(Timeline.PREFERENCE_EXPAND_LIST, JSON.stringify(othis.expandList));
          return (true);
      },
      onExpand: function(flag, node) {
    	  var deliverableId = Timeline.getDeliverableId(node), planId = Timeline.getPlanId(node), 
    	  	  expandKey = deliverableId, object = bpsWidgetAPIs.getObject(othis.data, deliverableId);
    	  if (planId) {
    		  bpsWidgetAPIs.getRelatedObject(othis.data, "plans", deliverableId, planId)._expand = flag;
    		  expandKey += planId;
    	  }
    	  object._expand = flag;
    	  
    	  if (flag) {
    		  othis.expandList[expandKey] = true;
    	  }
    	  else {
    		  delete othis.expandList[expandKey];
    	  }
    	  
    	  othis.setPreference(Timeline.PREFERENCE_EXPAND_LIST, JSON.stringify(othis.expandList));
      },
      onRender: function(node, nodeSpan) {
      	  Timeline.wrapTreeControls(nodeSpan);
    	  if (othis.metrics) {
    		jQuery(nodeSpan).find('.lane').css({'left': othis.metrics.lane_left, 'width': othis.metrics.lane_width});
    		jQuery(nodeSpan).find('.cart').css({'margin-left': othis.metrics.cart_margin_left, 'width': othis.metrics.cart_width});
    	  }
    	  
    	  if (!Timeline.isObjective(node)) {
    		  jQuery(nodeSpan).find(".lane-gate").draggable({
	    		  axis: "x",
	    		  cursor: "pointer",
	    		  zIndex: 5,
	    		  delay: 0,
	    		  revert: "invalid",
	    		  greedy: true,
	    		  drag: function (event, ui) {
	    			  var date, draggable = this, node = othis.__getNode(jQuery(this));
	    			  if (node) {
	    				  date = new Date(othis.getDragDropDate(ui));
	    				  othis.$date_helper_popup.text(jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, date));
	    				  othis.$date_helper_popup.offset({
	    					  top: (jQuery(this).offset().top - othis.$date_helper_popup.height() - jQuery(this).height() - 18 /* lane-gate-title lineheight */),
	    					  left: ui.offset.left
	    				  }).show();
	    				  
	    				  if (!node.addClass) {
	    					  var delta = event.clientX - jQuery.data(this, 'left');
	    					  jQuery.data(this, 'left', event.clientX);
	    					  jQuery.data(this, 'dragAlong').css({left: jQuery(this).css('left')});
	    					  jQuery.data(this, 'selected').each(function(index, item) {
	    						  var $item = jQuery(item);
	    						  if (item != draggable) {
		    						  $item.css({left: parseInt($item.css('left')) + delta + "px"});
	    						  }
	    					  });
	    				  }
	    			  }
	    		  },
	    		  start: function (event, ui) {
	    			  var $this = jQuery(this), node = othis.__getNode($this);
	    			  var canEdit = othis.isEditable(node) && !$this.hasClass('reference');
    				  if (canEdit && Timeline.isDeliverable(node)) {
    					  var $objectives, $elements;
    					  var $selected = othis.$ds_timeline.find('div.selected').parent();
    					  $selected.each(function (index, item) {
    						  var $item = jQuery(item), node = othis.__getNode($item);
    						  $elements = jQuery(node.li).find('.m-id-' + $item.attr('data-id').replace(/\./g, '-'));
    						  if ($objectives && $objectives.length > 0) {
    							  $objectives = $objectives.add($elements);
    						  }
    						  else {
    							  $objectives = $elements;
    						  }
    					  });
    					  $selected = $selected.add($objectives);
    					  jQuery.data(this, 'dragAlong', jQuery(node.li).find('.m-id-' + jQuery(this).attr('data-id').replace(/\./g, '-')));
    					  jQuery.data(this, 'selected', $selected);
    					  jQuery.data(this, 'left', event.clientX);
    				  }
    				  //TODO find other gates that should move too
	    			  return (canEdit);
	    		  },
	    		  stop: function (event, ui) {
	    			  othis.$date_helper_popup.hide();
	    		  }
    		  });
    	  }
    	  jQuery(nodeSpan).find(".cart").droppable({
    		  accept: function (draggable) {
    			  if (draggable.hasClass("lane-gate")) {
    				  var node = othis.__getNode(draggable);
    				  return (!Timeline.isObjective(node));
    			  }
    			  
    			  return (false);
    		  },
    		  drop: function (event, ui) {
    			  othis.$date_helper_popup.hide();
    			  var node = othis.__getNode(ui.draggable);
    			  if (node) {
    				  if (Timeline.isObjective(node)) {
    					  return (false);
    				  }
    	
    				  var gate = Timeline.findGate(node.data.gates, jQuery(ui.draggable[0]).attr('data-id'));
    				  var delta = ui.offset.left - parseInt(jQuery(ui.draggable[0]).css('left'));
    				  
    				  if (gate) {
    					  var msDate = othis.getDragDropDate(ui), fields = [], gates = [];
    					  gate.mEDate = jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, new Date(msDate));
    					  gate.mEDate_actual = msDate;

    					  if (Timeline.isDeliverable(node)) {
    						  fields.push({name: "mEDate", value: {displayValue: gate.mEDate, actualValue: gate.mEDate_actual}});
    						  var redrawNodes = othis.__updateGate(node, gate, fields);

    						  // update other gates that may have been selected
    						  var gates = jQuery.data(ui.draggable[0], 'selected');
	    					  gates.each(function(index, item) {
	    						  var gate, $item = jQuery(item), gateNode = othis.__getNode($item);
	    						  if (item != ui.draggable[0]) {
	    		    				  gate = Timeline.findGate(gateNode.data.gates, $item.attr('data-id'));
	    		    				  if (gate && Timeline.isDeliverable(gateNode)) {
	    		    					  ui.offset.left = parseInt($item.css('left')) + delta;
	    		    					  msDate = othis.getDragDropDate(ui);
	    		    					  gate.mEDate = jQuery.datepicker.formatDate(Timeline.DATEPICKER_FORMAT, new Date(msDate));
	    		    					  gate.mEDate_actual = msDate;
	    		    					  fields.length = 0;
	    		    					  fields.push({name: "mEDate", value: {displayValue: gate.mEDate, actualValue: gate.mEDate_actual}});
	    		    					  redrawNodes = othis.__updateGate(gateNode, gate, fields, redrawNodes);
	    		    				  }
	    						  }
	    					  });
    						  
	    					  othis.__applyUpdates(othis.data, function() {
		    					  var planObj = bpsWidgetAPIs.getRelatedObject(othis.data, "plans", Timeline.getDeliverableId(node), Timeline.getPlanId(node));
		    					  // replace the old gate info in the node with the updated info
	    						  node.data.gates[Timeline.getGateIndex(node.data.gates, gate._objectId)] = 
		    						  Timeline.getGate(bpsWidgetAPIs.getRelatedObject(othis.data, "gates", planObj, gate._objectId), gate.canEdit);
		    					  gates.each(function(index, item) {
		    						  var gate, $item = jQuery(item), gateNode = othis.__getNode($item);
		    						  if (item != ui.draggable[0]) {
		    		    				  gate = Timeline.findGate(gateNode.data.gates, $item.attr('data-id'));
		    		    				  if (gate && Timeline.isDeliverable(gateNode)) {
		    		    					  planObj = bpsWidgetAPIs.getRelatedObject(othis.data, "plans", Timeline.getDeliverableId(gateNode), Timeline.getPlanId(gateNode));
		    		    					  gateNode.data.gates[Timeline.getGateIndex(gateNode.data.gates, gate._objectId)] = 
		    		    						  Timeline.getGate(bpsWidgetAPIs.getRelatedObject(othis.data, "gates", planObj, gate._objectId), gate.canEdit);
		    		    				  }
		    						  }
		    					  });
		    					  othis.__redrawNodes(redrawNodes);
	    					  });
    					  
    					  } else if (Timeline.isRealized(node)) {
    						  fields.push({name: "kpiDate", value: {displayValue: gate.mEDate, actualValue: gate.mEDate_actual}});
    						  bpsWidgetAPIs.modifyRelatedObject(othis.data, "kpis", Timeline.getDeliverableId(node), gate._objectId, fields); 
	    					  othis.__applyUpdates(othis.data, function() {
	    						  node.render();
	    					  });
    					  }
    				  }
    			  }
    		  }
    	  });
    	  if (Timeline.isDeliverable(node)) {
    		  jQuery(nodeSpan).find(".lane-gate-title").droppable({
    			  accept: ".objective",
    			  tolerance: "pointer",
    			  hoverClass: "over-gate",
    			  drop: function(event, ui) {
    				  othis.$ds_timeline.trigger({
    					  type: "createObjective",
    					  id: jQuery(event.target).parent().attr('data-id'),
    					  position: ui.position,
    					  targetNode: othis.__getNode(jQuery(event.target))
    				  });
    			  }
    		  });
    	  }
    	  clearTimeout(Timeline.cropTimeout);
    	  Timeline.cropTimeout = setTimeout(function(){othis.cropTreeItems();},200);
          setTimeout(function () { jQuery(node.span).find('.cart').each(function(){Timeline.cascadeGates(jQuery(this))});}, 200);
      },
      dnd: {
    	  autoExpandMS: 1000,
    	  preventVoidMoves: true,
    	  onDragEnter: function (targetNode, sourceNode, hitMode) {
    		  // sourceNode may be null for non-dynatree droppables.
    		  //  Return false to disallow dropping on node. In this case
    		  //  onDragOver and onDragLeave are not called.
    		  //  Return 'over', 'before, or 'after' to force a hitMode.
    		  //  Any other return value will calc the hitMode from the cursor position.
    		  return ('over');
    	  },
    	  onDragOver: function (targetNode, sourceNode, hitMode) {
    		  if (hitMode == 'over') {
    			  jQuery(targetNode.li).find('.lane').filter(':first').addClass("drag-over");
    		  }
    		  else {
    			  jQuery(targetNode.li).find('.lane').filter(':first').removeClass("drag-over");
    		  }
    	  },
    	  onDrop: function (targetNode, sourceNode, hitMode, ui, draggable) {
    		  //This function MUST be defined to enable dropping of items on the tree.
    		  // sourceNode may be null, if it is a non-Dynatree droppable.
    		  if (!sourceNode) {
    			  var $helper = jQuery(ui.helper[0]);
    			 
    			  if ($helper.hasClass('tree-p')) {
    				  if (Timeline.isDeliverable(targetNode)) {
    				  othis.$ds_timeline.trigger({
	    				  type: "createDeliverable",
	    				  position: ui.position,
	    				  targetNode: targetNode,
	    				  hitMode: hitMode
	    			  });
    				  }
    				  else {
	    				  othis.$ds_timeline.trigger({
		    				  type: "showError",
		    				  position: ui.position,
		    				  message: "Can't add deliverable to objective or realized node."
		    			  });
    				  }
    			  } else if (hitMode == 'over') {
    				  var type;
    				  if ($helper.hasClass('gate')) {
        				  if (Timeline.isDeliverable(targetNode)) {
    					  type = "createGatePopup";
        				  }
        				  else {
    	    				  othis.$ds_timeline.trigger({
    		    				  type: "showError",
    		    				  position: ui.position,
    		    				  message: "Can't place gate on objective or realized lane."
    		    			  });
        				  }
    				  } else if ($helper.hasClass('realized')) {
    					  type = "createRealized";
    				  } else if ($helper.hasClass('objective')) {
    					  if (Timeline.isObjective(targetNode)) {
    						  type = "createObjective";
    					  }
    				  }
    				  
    				  if (type) {
    					  othis.$ds_timeline.trigger({
    						  type: type,
    						  position: ui.position,
    						  targetNode: targetNode,
    						  date: othis.getDragDropDate(ui)
    					  });
    				  }
    			  }
				  else {
					  othis.$ds_timeline.trigger({
						  type: "showError",
						  position: ui.position,
						  message: "Missed the lane."
					  });
    		  }
    		  }
    	  },
    	  onDragLeave: function (targetNode, sourceNode, hitMode) {
    		  jQuery(targetNode.li).find('.lane').filter(':first').removeClass("drag-over");
    	  }
      },
	  onDblClick: function (node, event) {
		  if (Timeline.isDeliverable(node) && node.data.canEdit && othis.edit == true && jQuery(event.target).parent().hasClass('dynatree-title')) {
			  othis.$ds_timeline.trigger({
				  type: "editDeliverable",
				  node: node,
				  position: {left: event.clientX, top: event.clientY}
			  });
		  }
	  },
	  onClick: function(node, event) {
	  	var $elem = jQuery(event.target);
	  	if ($elem.attr('data-pid') && $elem.attr('data-pid') !== "undefined") {
	  		var win = bpsTagNavConnector.getTNWindow();
			$elem.toggleClass("selected");
		    if(win){
			    jQuery(win.document).trigger("widget_selection_changed." + othis.data.id + ".bps_widget");
			}
	  	}
	  	else {
	  		othis.$ds_timeline.find('.selected').removeClass("selected");
	  	}
	  },
	  children: Timeline.preProcessObjects({data: Timeline.getObjects(othis.data), expandList: othis.expandList, filter: true, dateRange: othis.time_machine_range})
	});
};
Timeline.prototype.makeLane = function (obj) {
	var startDate, endDate, 
		effectivityStartDate = parseInt(obj.info.effectivityStartDate_actual),
		originatedDate = parseInt(obj.info.originatedDate_actual),
		onceActive = (effectivityStartDate > 0);
	
	startDate = {'ms': effectivityStartDate, 'value': obj.info.effectivityStartDate};
	if (effectivityStartDate == 0 && originatedDate > 0) {
		startDate = {'ms': originatedDate, 'value': obj.info.originatedDate};
	}
	
	if (obj.info.effectivityEndDate_actual) {
		endDate = {'ms': obj.info.effectivityEndDate_actual, 'value': obj.info.effectivityEndDate};
	}
	else {
		endDate = {'ms': parseInt(this.range.endDate.ms), 'value': this.range.endDate.value};
	}
	return {'name': obj.title, 'startDate': startDate, 'endDate': endDate, 'gates': obj.gates, 'versions': obj.versions, 'onceActive': onceActive};
};
Timeline.prototype.drawLaneItem = function ($elm, item) {
	var $laneItem = this.template.lane_item(item), othis = this, gates = item.gates;
	
	// start date should be the earliest of the original plan, any of it's versions or the start of timeline range.
	// objective and realized lanes won't have a start date.
	if (item.startDate.value && item.startDate.value.length > 0) {
		var i, startDate = Math.max(item.startDate.ms, this.range.startDate.ms), endDate = this.range.endDate.ms;
		if (item.versions && item.onceActive) {
			for (i = 0; i < item.versions.length; i++) {
				startDate = Math.min(startDate, parseInt(item.versions[i].effectivityStartDate_actual));
			}
			
			startDate = Math.max(startDate, this.range.startDate.ms);
		}
		
		// if the start date is after the end of the timeline range then don't bother drawing
		if (startDate < this.range.endDate.ms) {
			var days, width, left, $version, $datebar, $versionbar, startDateVersion, endDateVersion;
			
			$datebar = $laneItem.find('.datebar');
			days = Timeline.days_between(new Date(startDate), new Date(this.range.endDate.ms));
			width = days / this.range.days * 100;
			days = Timeline.days_between(new Date(this.range.startDate.ms), new Date(startDate));
			left = days / this.range.days * 100;
			$datebar.css('width', width + "%");
			$datebar.css('left', left + "%");

			startDateVersion = Math.max(item.startDate.ms, this.range.startDate.ms);
			endDateVersion = Math.min(item.endDate.ms, this.range.endDate.ms);

			if (item.onceActive) { 
				// the version bar is a child of the date bar so its left and width are relative to the date bar
				$versionbar = $laneItem.find('.versionbar');
				days = Timeline.days_between(new Date(startDateVersion), new Date(endDateVersion));
				width = days / Timeline.days_between(new Date(startDate), new Date(this.range.endDate.ms)) * 100;
				days = Timeline.days_between(new Date(startDate), new Date(startDateVersion));
				left = days / Timeline.days_between(new Date(startDate), new Date(endDate)) * 100;
				$versionbar.css('width', width + "%");
				$versionbar.css('left', left + "%");
			}

			if (startDateVersion > this.range.startDate.ms && startDateVersion < this.range.endDate.ms) {
				days = Timeline.days_between(new Date(this.range.startDate.ms), new Date(startDateVersion));
				left = days / this.range.days * 100;
				var $start = this.template.lane_start(item);
				$laneItem.append($start);
				$start.css('left', left + "%");
			}
			
			if (endDateVersion > this.range.startDate.ms && endDateVersion < this.range.endDate.ms) {
				days = Timeline.days_between(new Date(this.range.startDate.ms), new Date(endDateVersion));
				left = days / this.range.days * 100;
				var $end = this.template.lane_end(item);
				$laneItem.append($end);
				$end.css('left', left + "%");
			}
			
			// draw version down arrows for versions before this one
			if (item.versions && item.onceActive) {
				for (i = 0; i < item.versions.length; i++) {
					if (startDateVersion > parseInt(item.versions[i].effectivityStartDate_actual)) { 
						days = Timeline.days_between(new Date(this.range.startDate.ms), new Date(parseInt(item.versions[i].effectivityStartDate_actual)));
						left = days / this.range.days * 100;
						$version = this.template.lane_version(item.versions[i], i);
						$laneItem.append($version);
						$version.css('left', left + "%");
					}
				}
			}
		}
	}
	this.drawLaneGates($laneItem, gates);
	$elm.append($laneItem);
};
Timeline.prototype.drawLaneGates = function ($elm, items) {
	var othis = this;
	jQuery(items).each(function(index, item) {
		othis.drawLaneGate($elm, item);
	});
};
Timeline.prototype.drawLaneGate = function ($elm, item) {
	try {
		if (item.mName) {
			var date = parseInt(item.mEDate_actual);
			if (date > this.range.startDate.ms && date < this.range.endDate.ms) {
				var $gate = this.template.lane_gate(item, this.edit, this.showStatus), othis = this;
				var days = Timeline.days_between(new Date(this.range.startDate.ms), new Date(date));
				var left = days / this.range.days * 100;
				$gate.css('left', left + "%");
				
                if (item.kpiGateId) {
					$gate.addClass('m-id-' + item.kpiGateId.replace(/\./g, '-'));
				}
                if (item.kpiGateName) {
                	$gate.attr('title', 'gate: ' + item.kpiGateName + '\n' + $gate.attr('title'));
                }
				$elm.append($gate);
			}
		}
	} catch (e) {
		//do nothing. this is for gate-less nodes
	}
};
Timeline.prototype.drawDates = function ($elm) {
    var myDateline = new Dateline(this.range.startDate.ms, this.range.endDate.ms);
	myDateline.draw($elm);
};
Timeline.prototype.today = function () {
	if (this.$days.filter('.today')) {
		var today = new Date(),
			daysBetween = Timeline.days_between(new Date(this.range.startDate.ms), today),
			visibleWidth = this.getVisibleWidth(),
			timelineWidth = this.getWidth(),
			lf = -((daysBetween * this.current_day_width) - (visibleWidth / 2));
		
		if (lf > 0 || (visibleWidth - lf) > timelineWidth) {
			lf = 0;
		}
	    this.setLeftMargin(lf);
	    this.syncSlider();
	}
};
Timeline.prototype.syncSlider = function () {
	var $slider = this.$ds_timeline.find(".timeSlider");
	var timelineWidth = this.getWidth();
	var leftMargin = -this.getLeftMargin();
	var visibleWidth = this.getVisibleWidth();
	
	// calculate scale
	var diff = Math.ceil((visibleWidth/timelineWidth) * 100); 
	// calculate left position
	var scrollPercent = Math.round((leftMargin / (timelineWidth - visibleWidth) * 100));
	var left = Math.ceil((scrollPercent * (100 - diff)) / 100);
	$slider.slider('values', [left, left + diff]);
};
Timeline.prototype.zoom = function (direction) {
	//TODO edge testing
	var visibleWidth = this.getVisibleWidth(),
		leftMargin = this.getLeftMargin(),
		width = this.getWidth(),
		scrollPct = scrollPct = (-leftMargin + visibleWidth/2) / width; //-leftMargin / width;
	
	if (((this.current_day_width + direction) * this.range.days) > visibleWidth) {
		this.current_day_width += direction;
		this.setDayWidth(this.current_day_width);
		width = this.current_day_width * this.range.days;
		this.setWidth(width);
		
		leftMargin = -Math.round(width * scrollPct - visibleWidth/2); //-Math.round(width * scrollPct);
		if (width + leftMargin < visibleWidth) {
			leftMargin = visibleWidth - width;
		}
        if (leftMargin > 0) {
        	leftMargin = 0;
        }
		this.setLeftMargin(leftMargin);
		this._adjustDateline(this.current_day_width);
		this.syncSlider();
		this.$timeline.find('.cart').each(function(){Timeline.cascadeGates(jQuery(this))});
	}
};
Timeline.prototype._frame = function (msStartDate, msEndDate) {
	var days_between = Timeline.days_between(new Date(msStartDate), new Date(msEndDate)) + 1;
	var leftMargin;
	
    this.current_day_width = Math.max(Math.round((this.getVisibleWidth()) / days_between), this.min_day_width);
    this.setDayWidth(this.current_day_width);
	this.setWidth(this.current_day_width * this.range.days);

    if (msStartDate == this.range.startDate.ms) {
		leftMargin = 0;
	}
	else {
		days_between = Timeline.days_between(new Date(this.range.startDate.ms), new Date(msStartDate)) + 1;
		leftMargin = -days_between * this.current_day_width;
	}

	if (leftMargin > 0 || (this.getVisibleWidth() - leftMargin) > this.getWidth()) {
		leftMargin = 0;
	}
	this.setLeftMargin(leftMargin);
	this._adjustDateline(this.current_day_width);
	this.$timeline.find('.cart').each(function(){Timeline.cascadeGates(jQuery(this))});
};
Timeline.prototype.scale = function (value, scrollValue) {
	var pct = ((value == 0) ? 1 : value) / 100;
	this.current_day_width = Math.max(Math.ceil(this.getVisibleWidth() / (pct * this.range.days)), this.min_day_width);
	this.setDayWidth(this.current_day_width);
	this.setWidth(this.range.days * this.current_day_width);
	this.scroll(scrollValue);
	this._adjustDateline(this.current_day_width);
	this.$timeline.find('.cart').each(function(){Timeline.cascadeGates(jQuery(this))});
};
Timeline.prototype._adjustDateline = function (width) {
	if (width >= 10) {
		this.__showDayLines();
	}
	if (width < 10) {
		this.__showNoText(this.$context_node.find('.day'));
		this.__showSmallText(this.$context_node.find('.week, .month'));
		this.__hideDayLines();
	}
	else if (width < 25) {
		this.__showNoText(this.$context_node.find('.day'));
		this.__showMediumText(this.$context_node.find('.week, .month'));
	}
	else if (width < 45) {
		this.__showSmallText(this.$context_node.find('.day'));
		this.__showLargeText(this.$context_node.find('.week'));
		this.__showMediumText(this.$context_node.find('.month'));
	}
	else if (width < 90) {
		this.__showMediumText(this.$context_node.find('.day'));
		this.__showLargeText(this.$context_node.find('.week, month'));
	}
	else {
		this.__showLargeText(this.$context_node.find('.day, .week, .month'));
	}
};
Timeline.prototype.scroll = function (value) {
	// width of the timeline minus the visible part
	var scrollWidth = this.getWidth() - this.getVisibleWidth();
	this.setLeftMargin(-Math.round((value / 100) * scrollWidth));
};
Timeline.prototype.getDateRange = function () {
	var today = Timeline.getToday(),
		startDate = {actualValue: (today.getTime() - (this.one_day * 300)), value: ""},  // minus about six months
		endDate = {actualValue: (today.getTime() + (this.one_day * 365)), value: ""}, // plus about one year
		range = {},
		preference;
	var makeDate = function (date) {
		if (date) {
			return ({'ms': parseInt(date.actualValue), 'value': date.value});
		}
		else {
			return (undefined);
		}
	}
	
	preference = this.getPreference(Timeline.PREFERENCE_DATE_RANGE);
	if (preference) {
    	preference = JSON.parse(preference);
		startDate = {actualValue: parseInt(preference.start), value: ""};
		endDate = {actualValue: parseInt(preference.end), value: ""};
	}

	range.startDate = makeDate(startDate);
	range.endDate = makeDate(endDate);
	range.days = Timeline.days_between(new Date(range.startDate.ms), new Date(range.endDate.ms));
	return (range);
}
Timeline.prototype.getPreference = function (name) {
	var value;
	
	if (isIFWE) {
        if (this.data.parentObj && this.data.parentObj.uwaWidget) {
            value = this.data.parentObj.uwaWidget.getValue(name);
        }
	}
	// check for date range in local storage
	else if (typeof(Storage) !== "undefined") {
		value = localStorage[name];
	}
	
	return (value);
};
Timeline.prototype.setPreference = function (name, value) {
	if (isIFWE) {
		if (this.data.parentObj && this.data.parentObj.uwaWidget) { 
            this.data.parentObj.uwaWidget.setValue(name, value);
            this.data.parentObj.uwaWidget.addPreference(
					{name: name, 
					type: "hidden", 
					value: value});
		}
	} 
	else if (typeof(Storage) !== "undefined")
	{
		localStorage[name] = value;
	}
};
Timeline.prototype.__showDayLines = function () {
	this.$context_node.find('.bg-off').removeClass('bg-off');
}
Timeline.prototype.__hideDayLines = function () {
	this.$context_node.find('.day:not(.monday), .month').addClass('bg-off');
}

Timeline.prototype.__showNoText = function (ctx) {
	ctx.removeClass('large medium small');
}
Timeline.prototype.__showSmallText = function (ctx) {
	ctx.removeClass('large medium').addClass('small');
}
Timeline.prototype.__showMediumText = function (ctx) {
	ctx.removeClass('large small').addClass('medium');
}
Timeline.prototype.__showLargeText = function (ctx) {
	ctx.removeClass('small medium').addClass('large');
}
Timeline.prototype.getVisibleWidth = function () {
	return (this.$timeline_container.width() - parseInt(this.$dateline_container.css('left')));
};
Timeline.prototype.getWidth = function () {
	return (this.$timeline_container.find('.cart:first').width());
};
Timeline.prototype.setWidth = function (width, $applyTo) {
	if ($applyTo && $applyTo.length > 0) {
		$applyTo.css('width', width);
	}
	else {
		this.$timeline_container.find('.cart').css('width', width);
		this.$dateline_container.find('.dates').css('width', width);
	}
	this.metrics.cart_width = width;
	this.metrics.dates_width = width;
};
Timeline.prototype.setLeftMargin = function (leftMargin, $applyTo) {
	if ($applyTo && $applyTo.length > 0) {
		$applyTo.css('margin-left', leftMargin);
	}
	else {
		this.$timeline_container.find('.cart').css('margin-left', leftMargin);
		this.$dateline_container.find('.dates').css('margin-left', leftMargin);
	}
	this.metrics.dates_margin_left = leftMargin,
	this.metrics.cart_margin_left = leftMargin;
	this.setPreference(Timeline.PREFERENCE_LEFT_MARGIN, JSON.stringify(leftMargin));
};
Timeline.prototype.getLeftMargin = function () {
	return this.metrics.cart_margin_left;
};
Timeline.prototype.setDayWidth = function (width) {
	this.$days.css('width', width);
	this.metrics.day_width = width;
	this.setPreference(Timeline.PREFERENCE_ZOOM, JSON.stringify(width));
};
Timeline.prototype.getDragDropDate = function (ui, cursorOffset) {
	var left = this.$dateline_container.offset().left;

	if (cursorOffset == undefined) {
		cursorOffset = 5;
	}

	return (this.range.startDate.ms + (Math.floor((ui.offset.left - cursorOffset - left - this.getLeftMargin()) / this.current_day_width) * this.one_day)); 
};
Timeline.prototype.getTimeMachineRange = function () {
	var start = this.getDragDropDate({offset:{left:parseInt(this.$time_machine_begin.offset().left + 7 /* margin-left is -6px plus another for good measure */)}}, 0),
		end = this.getDragDropDate({offset:{left:parseInt(this.$time_machine_end.offset().left - 1)}}, 0);
	return {start: start, end: end};
};
Timeline.prototype.highlightSelectedDays = function () {
	var range = this.getTimeMachineRange(),
		date = new Date(new Date(this.range.startDate.ms)),
		startIndex = Timeline.days_between(date, new Date(range.start)),
		endIndex = Timeline.days_between(date, new Date(range.end));
	this.$days.filter('.time-machine-range').removeClass('time-machine-range');
	this.$days.slice(startIndex, endIndex + 1).addClass('time-machine-range');
};
Timeline.prototype.reload = function () {
	var othis = this, preference = this.getPreference(Timeline.PREFERENCE_SCROLL_TOP);

	this.$timeline.hide();
	this.__getRootNode().removeChildren();
	this.__getRootNode().addChild(Timeline.preProcessObjects({data: Timeline.getObjects(this.data), filter: true, dateRange: this.getTimeMachineRange()}));
	
	// reset the scroll bar after dynatree draws
	if (preference) {
		setTimeout(function(){
			othis.$timeline_container.scrollTop(JSON.parse(preference));;
			othis.$timeline.show();
		}, 100);
	}
	else {
		this.$timeline.show();
	}
};
Timeline.prototype.__initDialog = function ($popup, position) {
	this.$ds_timeline.append($popup);
	var $parent = $popup.parent();
	
	if (!position) {
		position = {top: this.$ds_timeline.height() / 2, left: this.$ds_timeline.find('.divider').offset().left};
	}
	
	if (position.top + $popup.outerHeight() > $parent.offset().top + $parent.height()) {
		position.top = $parent.offset().top + $parent.height() - $popup.outerHeight();
	}
	if (position.left + $popup.outerWidth() > $parent.offset().left + $parent.width()) {
		position.left = $parent.offset().left + $parent.width() - $popup.outerWidth();
	}
	
	
	$popup.hide();
	$popup.offset(position);
	$popup.fadeIn();
	$popup.find('input:text:visible:first').focus();
	$popup.on("keypress", "input:not(:button),select", "", function (event) {	
		if (event.which == 13) {
			event.preventDefault();
			$popup.find('#ok').click();
			return (false);
		}
		return (true);
	});
	$popup.on("keyup", "input:not(:button),select", "", function (event) {	
		if (event.which == 27) {
			event.preventDefault();
			$popup.find('#cancel').click();
			return (false);
		}
		return (true);
	});
	$popup.draggable({
	  containment: "parent",
	  delay: 0
	}); 
	$popup.find('#cancel').click(function () {
		Timeline.__closeDialog($popup);
	});
};
Timeline.prototype.__updateGate = function (node, gate, fields, redrawNodes) {
	// save gate changes to database, which also updates dates of objectives
	var planObj = bpsWidgetAPIs.getRelatedObject(this.data, "plans", Timeline.getDeliverableId(node), Timeline.getPlanId(node));
	bpsWidgetAPIs.modifyRelatedObject(this.data, "gates", planObj, gate._objectId, fields); 
	if (!redrawNodes) {
		redrawNodes = {};
	}
	// redraw the objectives on new date
	var othis = this, objectiveNode, objective, objectives = jQuery(node.li).find('.m-id-' + gate._objectId.replace(/\./g, '-'));
	objectives.each(function () {
		objectiveNode = othis.__getNode(jQuery(this));
		objective = Timeline.findGate(objectiveNode.data.gates, jQuery(this).attr('data-id'));
		objective.mEDate = gate.mEDate;
		objective.mEDate_actual = gate.mEDate_actual;
		redrawNodes[objectiveNode.data._objectId] = objectiveNode;
	});

	redrawNodes[node.data._objectId] = node;
	return (redrawNodes);
};
Timeline.prototype.__redrawNodes = function (nodes) {
	for (var node in nodes) {
		nodes[node].render();
	}
};
Timeline.prototype.__getTemplateOptions = function () {
	var options = [];
	if (this.template_data.datarecords && this.template_data.datarecords.datagroups) {
		this.template_data.datarecords.datagroups.forEach(function (template) {
			options.push({display: bpsWidgetAPIs.getFieldValue(template, "title").displayValue, value: template.objectId});
		});
	}
	return (options);
};
Timeline.prototype.__updateTemplates = function () {
	var othis = this,
	callback = function(data) {
		othis.template_data = data;
	}
	bpsWidgetAPIs.loadWidget("PRG_LIST_DELIVERABLE_TEMPLATES_RANGE", callback);
};
Timeline.prototype.__addNodes = function (parent, children, beforeNode) {
	var scrollTop = this.$timeline_container.scrollTop(),
		tree = this.$timeline.find('ul.dynatree-container').detach(),
		node = parent.addChild(children, beforeNode);
	this.$timeline.append(tree);
	this.$timeline_container.scrollTop(scrollTop);
	//this.cropTreeItems();
	return (node);
};
Timeline.prototype.__getMovables = function () {
	return (this.$timeline_container.find('.cart').add(this.$dateline_container.find('.dates')));
};
Timeline.prototype.__applyUpdates = function (data, callback, changedObjects) {
    var othis = this;
    var timer = setTimeout(function() {othis.$timeline_overlay.show();}, 2000);
    var success = true;
    bpsWidgetAPIs.applyUpdates(data, function() {
    	clearTimeout(timer);
    	othis.$timeline_overlay.fadeOut();
    	
    	if (changedObjects) {
    		changedObjects.forEach(function (obj) {
				if (obj.updateMessage && obj.updateMessage.length > 0) {
					success = false;
					othis.$ds_timeline.trigger({
						type: "showError",
						message: obj.updateMessage
					});
				}
			});
    	}
    		
    	if (!success) {
    		changedObjects.forEach(function (obj) {
				bpsWidgetAPIs.cancelObject(data, obj);
			});
    	}
    		
    	if (success && callback) {
    		callback();
    	}
    }, (!changedObjects));
};
Timeline.prototype.__getRootNode = function () {
	return (this.$timeline.dynatree("getRoot"));
}; 
Timeline.prototype.__getNode = function (elem) {
	return (jQuery.ui.dynatree.getNode(elem));
};
Timeline.prototype.__getActiveNode = function () {
	return (this.$timeline.dynatree("getActiveNode"));
};
Timeline.prototype.__setClipboard = function (object) {
	this.clipboard = object;
};
Timeline.prototype.__getClipboard = function () {
	return (this.clipboard);
};



