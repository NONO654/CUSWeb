(function(GLOBAL) {
    var DataColumn = function(columnData) {
        if (typeof columnData !== 'undefined') {
            this.setData(columnData);
        }

        this.setData(columnData);
    };

    DataColumn.prototype.setColumnState = function(state) {
        if (state === 'READY') {
            this._columnReady();
        }
    };

    DataColumn.prototype.setData = function(data) {
        if (typeof data.metadata !== 'undefined') {
            this.setMetadata(data.metadata);
        }

        if (typeof data.values !== 'undefined') {
            this.values = data.values;
        }
    };

    DataColumn.prototype.updateData = function(data) {
        if (data instanceof Array) {
            this.values = data;
            return;
        }

        if (typeof data.values !== 'undefined') {
            this.values = data.values;
        }

        if (typeof data.metadata !== 'undefined') {
            for (var key in data.metadata) {
                if (data.metadata.hasOwnProperty(key)) {
                    this.metadata[key] = data.metadata[key];
                }
            }
        }
    };

    DataColumn.prototype.getId = function() {
        return this.id;
    };

    DataColumn.prototype.setMetadata = function(metadata) {
        this.metadata = metadata;
    };

    DataColumn.prototype.onColumnReady = function(fn) {
        // Need deferreds for this, I think.
        this.columnReadyCallback = fn;
    };

    DataColumn.prototype._columnReady = function() {
        this.columnReadyCallback(this);
    };

    DataColumn.getColumnStats = function() {
        // TODO: This only makes sense for numeric values. Not sure what to do
        // for other column types, since columns don't have a type right now.
        // Maybe add this to utils?

        var min = this.vals[0],
            max = this.vals[0];

        this.values.forEach(function(val) {
            if (val < min) {
                min = val;
            } else if (val > max) {
                max = val;
            }
        });

        var values = { min: min, max: max };

        return values;
    };

    DataColumn.prototype.getColumnObject = function() {
        return {
            id: this.getId(),
            values: this.values,
            metadata: this.metadata
        };
    };

    GLOBAL.DS.RAConstructors.DataColumn = DataColumn;
})(this);
