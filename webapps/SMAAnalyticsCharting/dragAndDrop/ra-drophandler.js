(function(GLOBAL) {
    if (typeof GLOBAL.DS.RAComponents.drophandler !== 'undefined') {
        return;
    }

    var dropHandlerPrototype = { is: 'ra-dropHandler' };

    dropHandlerPrototype.createdCallback = function() {
        this.hasCustomFilter = false;
        this.type = 'text';
    };

    dropHandlerPrototype.setType = function(type) {
        this.type = type;
        this.setDefaultFilter();
    };

    dropHandlerPrototype.defaultFilter = function(dropData) {
        if (dropData.type === this.type) {
            return true;
        }

        return false;
    };

    dropHandlerPrototype.setDefaultFilter = function() {
        if (this.hasCustomFilter !== true) {
            this.filter = this.defaultFilter;
        }
    };

    dropHandlerPrototype.setFilter = function(filterFn) {
        if (typeof filterFn === 'undefined') {
            this.hasCustomFilter = false;
            this.setDefaultFilter();
        }

        this.hasCustomFilter = true;
        this.filter = filterFn;
    };

    dropHandlerPrototype.setDropListener = function(callback) {
        this.dropListener = callback;
    };

    dropHandlerPrototype.setDragEnterListener = function(callback) {
        this.dragEnterListener = callback;
    };

    dropHandlerPrototype.setDragLeaveListener = function(callback) {
        this.dragLeaveListener = callback;
    };

    // returns true if filtered, false if not
    dropHandlerPrototype.checkFilter = function(data, requireFilter) {
        // no data, don't drop
        // if the filter function
        if (
            !data ||
            (typeof this.filter === 'function' && !this.filter(data)) ||
            (typeof this.filter !== 'function' && requireFilter)
        ) {
            return true;
        }
        return false;
    };

    dropHandlerPrototype.onDrop = function(e) {
        var data = this.getParsedData(e);

        if (this.checkFilter(data)) {
            return;
        }

        if (typeof this.dropListener === 'function') {
            this.dropListener(data, e);
        }
    };

    dropHandlerPrototype.getParsedData = function(e) {
        // Do not filter event on this. Filtering should be done before we reach
        // this point.

        var rawData = e.dataTransfer.getData('text');

        var data;
        try {
            // Parses data as JSON, if possible.
            data = JSON.parse(rawData);
        } catch (e) {
            // If not, return raw data.
            data = rawData;
        }

        return data;
    };

    Polymer(dropHandlerPrototype);
    GLOBAL.DS.RAComponents.drophandler = dropHandlerPrototype;
})(this);
