define('DS/GroupByView/js/GroupingTile', [
    'DS/Handlebars/Handlebars',
    // 'DS/ENOXCollectionViewCommons/RefInstView/RefInstView',
    'DS/ENOXCollectionViewCommons/InstanceView/InstanceView',
    'text!DS/GroupByView/html/GroupByTileTemplate.html'
], function (Handlebars, RefInstView, GroupByTileTemplate) {

	var groupByTileTemplate = Handlebars.compile(GroupByTileTemplate);

	var GroupingTile = function (container, name, data, expandByDefault) {
		this.container = container;
		this.name = name;
		this.data = data;
		this.expand = false;
		this.expandByDefault = expandByDefault;
	};

	GroupingTile.prototype.render = function (modelEvents,viewsOptions) {
		var that = this;

		// Create the new grouping tile
		var tmp = document.createElement('div');
		tmp.innerHTML = groupByTileTemplate({name: that.name, quantity: that.data.childrens.length});
		that.groupingTileInfos = tmp.children[0];
		that.groupingTileContainer = tmp.children[1];
		that.container.appendChild(that.groupingTileInfos);
		that.container.appendChild(that.groupingTileContainer);

		// Render the childrens as a CollectionView of RefInstanceTileView
    	var refInstView = new RefInstView(that.groupingTileContainer);
        refInstView.init(that.data.childrens,modelEvents,viewsOptions);

        // refInstView.container.style.height = '200px';
		
		if(that.expandByDefault !== true) {
		  that.groupingTileContainer.classList.toggle('hidden');
		  that.groupingTileContainer.style.height = "60px";
		  that.expand = false;
		  // that.groupingTileInfos.querySelector('.arrow-mark').classList.replace('arrow-mark', 'arrow-up');
		  var arrowMark = that.groupingTileInfos.querySelector('.arrow-mark');
		  arrowMark.classList.remove('arrow-mark');
		  arrowMark.classList.add('arrow-up');
		  
		} else {
		  that.expand = true;
		  //DONT USE classList.replace, it is not supported on IE11
		  var arrowMark = that.groupingTileInfos.querySelector('.arrow-mark');
		  arrowMark.classList.remove('arrow-mark');
		  arrowMark.classList.add('arrow-down');

		  refInstView.grid.onPostUpdateViewOnce(function(){
				setTimeout(function(){
				  refInstView.resize();
				  var size = refInstView.grid.elements.poolContainer.getSize().height + 25;
				  refInstView.container.style.height = size+'px';
				},10);
		  });
		}
		
		// Expand on click
		that.groupingTileInfos.addEventListener('click', function () {
      refInstView.grid.onPostUpdateViewOnce(function(){
            setTimeout(function(){
              refInstView.resize();
              var size = refInstView.grid.elements.poolContainer.getSize().height + 25;
              refInstView.container.style.height = size+'px';
            },10);
      });
			if (that.expand) {
				//DONT USE classList.replace, it is not supported on IE11
				var arrowMark = that.groupingTileInfos.querySelector('.arrow-down');
				arrowMark.classList.remove('arrow-down');
				arrowMark.classList.add('arrow-up');
			} else {
				//DONT USE classList.replace, it is not supported on IE11
				var arrowMark = that.groupingTileInfos.querySelector('.arrow-up');
				arrowMark.classList.remove('arrow-up');
				arrowMark.classList.add('arrow-down');
			}
			that.expand = !that.expand;
			that.groupingTileContainer.classList.toggle('hidden');
		});

		return that;
	};

	return GroupingTile;
});
