define('DS/GroupByView/js/GroupByView', [
	'DS/GroupByView/js/GroupByUtils',
    'DS/GroupByView/js/GroupingTile',
    'css!DS/GroupByView/css/GroupByView.css'
], function (GroupByUtils, GroupingTile) {

	var GroupByView = function (container, expandByDefault) {
		this.container = container;
		this.container.classList.add('group-by-view');
		//By default the expansions will be in collapsed mode.
		this.expandByDefault = expandByDefault;
	};

	GroupByView.prototype.render = function (data,modelEvents,viewsOptions) {
		this.data = data;
				GroupByView.modelEvents=modelEvents;
				GroupByView.viewsOptions =viewsOptions;

	};

	GroupByView.prototype.groupByAttribute = function (attribute,modelEvents, viewsOptions) {
		var that = this;

		// Create the model of the group by view
		var groupByModel = GroupByUtils.createGroupedByModel(that.data, attribute);

		// Always rerender from scratch
		that.container.innerHTML = '';

		// Loop through the input data, and create grouping tiles
		groupByModel.forEach(function (d) {

			// If parent is a string, use it as name else use the 'name' attribute
			var groupName;
			if (typeof d.parent === 'string') {
				groupName = d.parent;
			} else {
				groupName = d.parent.name;
			}

			// Create the new grouping tile
			var groupingtile = new GroupingTile(that.container, groupName, d, that.expandByDefault);
			groupingtile.render(modelEvents,viewsOptions);
		});
	};

	return GroupByView;
});
