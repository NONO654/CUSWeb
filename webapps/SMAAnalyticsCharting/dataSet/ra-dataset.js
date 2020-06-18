(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAObjects.datasets === 'undefined') {
        GLOBAL.DS.RAObjects.datasets = {};
    }

    var DataSet = function(datasetObject) {
        this.metadata = {};

        this.columns = {};

        this.generateId();

        if (typeof datasetObject !== 'undefined') {
            this.setData(datasetObject);
        }

        GLOBAL.DS.RAObjects.datasets[this.id] = this;
    };

    DataSet.prototype.generateId = function() {
        // Build a random 20 characer ID
        this.id = 'dataset';

        for (var i = 0; i < 20; i++) {
            this.id += Math.floor(Math.random() * 10);
        }
    };

    DataSet.prototype.setData = function(datasetObject) {
        if (typeof datasetObject.metadata !== 'undefined') {
            this.setMetadata(datasetObject.metadata);
        }

        var key;
        for (key in datasetObject.data) {
            datasetObject.data.id = key;

            this.setColumn(key, datasetObject.data[key]);
        }
    };

    DataSet.prototype.sort = function(key, comparator) {
        var that = this;

        if (typeof this.columns[key] === 'undefined') {
            return;
        }

        comparator =
            comparator ||
            function(a, b) {
                return Number(b) - Number(a);
            };

        // Sorts ALL columns according to the values of a single column.
        Object.keys(this.columns).forEach(function(colKey) {
            if (colKey === key) {
                return;
            }

            var sortColumn = that.columns[colKey].values.map(function(d, i) {
                return {
                    sortVal: that.columns[key].values[i],
                    val: that.columns[colKey].values[i]
                };
            });

            sortColumn = sortColumn.sort(function(a, b) {
                return comparator(a.sortVal, b.sortVal);
            });

            var values = sortColumn.map(function(d) {
                return d.val;
            });

            that.updateColumn(colKey, values);
        });

        var values = this.columns[key].values.sort(comparator);
        this.updateColumn(key, values);
    };

    DataSet.prototype.setMetadata = function(metadata) {
        this.metadata = metadata;
    };

    DataSet.prototype.setColumn = function(columnId, columnObject) {
        columnObject.id = columnId;
        var column = new GLOBAL.DS.RAConstructors.DataColumn(columnObject);
        this.columns[columnObject.id] = column;
    };

    DataSet.prototype.getColumns = function() {
        return this.columns;
    };

    DataSet.prototype.getColumn = function(id) {
        return this.columns[id];
    };

    DataSet.prototype.hasColumn = function(id) {
        if (typeof this.columns[id] !== 'undefined') {
            return true;
        }

        return false;
    };

    DataSet.prototype.updateColumn = function(columnId, columnData) {
        if (typeof this.columns[columnId] !== 'undefined') {
            this.columns[columnId].updateData(columnData);
        } else {
            this.setColumn(columnId, columnData);
        }
    };

    DataSet.prototype.getDataSetObject = function(keys) {
        var dataSetObj = { id: this.id, data: {}, metadata: this.metadata };

        if (typeof keys === 'undefined') {
            keys = Object.keys(this.columns);
        }

        var i, key;
        for (i = 0; i < keys.length; i++) {
            key = keys[i];
            dataSetObj.data[key] = this.columns[key].getColumnObject();
        }
        return dataSetObj;
    };

    DataSet.prototype.getJson = function(keys) {
        // Returns the part of or the entire data set as a JSON object
        var dataSetObj = this.getDataSetObject(keys);

        return JSON.stringify(dataSetObj);
    };

    GLOBAL.DS.RAConstructors.DataSet = DataSet;
})(this);
