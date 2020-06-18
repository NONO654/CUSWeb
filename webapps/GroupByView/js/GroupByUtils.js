define('DS/GroupByView/js/GroupByUtils', [], function () {

	return {

		createGroupedByModel: function (data, attribute) {
	        var that = this;
			var groupedData = that.groupBy(data, attribute);

	        var rez = [];
	        for (var attr in groupedData) {
	            rez.push({
	                parent: attr,
	                childrens: groupedData[attr]
	            });
	        }

	        return rez;
		},

		groupBy: function(xs, key) {
			var that = this;

		    return xs.reduce(function(rv, x) {

		        var valueForGrouping;
		        if (key.indexOf('.') >= 0) {
		            // If key contains, find subproperties
		            valueForGrouping = that.getSubpropertyFromString(x, key);
		        } else {
		            // Else just use property passed as key
		            valueForGrouping = x.resolveAttributes(key);
		        }

		        (rv[valueForGrouping] = rv[valueForGrouping] || []).push(x);
		        return rv;
		  }, {});
		},

		getSubpropertyFromString: function(o, s) {
		    s = s.replace(/\[(\w+)\]/g, '.$1'); // convert indexes to properties
		    s = s.replace(/^\./, '');           // strip a leading dot
		    var a = s.split('.');
		    for (var i = 0, n = a.length; i < n; ++i) {
		        var k = a[i];
		        if (k in o) {
		            o = o[k];
		        } else {
		            return;
		        }
		    }
		    return o;
		}
	};
});
