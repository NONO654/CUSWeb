define('DS/CollectionViewSample/ENOXCollectionViewAdvancedFilter/ENOXCollectionViewAdvancedFilter', [
    'DS/CoreEvents/ModelEvents',
    'DS/Handlebars/Handlebars',
    'DS/UIKIT/Modal',
    'text!DS/CollectionViewSample/ENOXCollectionViewAdvancedFilter/ENOXCollectionViewAdvancedFilter.html',
    'text!DS/CollectionViewSample/ENOXCollectionViewAdvancedFilter/Partial.html'
], function (ModelEvents, Handlebars, UIKITModal, Template, PartialTemplate) {

    var _states = ['Study', 'In Work', 'Released', 'Obsolete'];
    var _instanceNames = ['Right Front Propeller', 'Left Front Propeller', 'Rear Right Propeller', 'Rear Left Propeller'];
    var _variants = ['Variant A', 'Variant B', 'Variant C', 'Variant D', 'Variant E', 'Variant F', 'Variant G', 'Variant H'];

    var TEMPLATES = {
        main: Handlebars.compile(Template),
        partial: Handlebars.compile(PartialTemplate)
    };

    var ENOXCollectionViewAdvancedFilter = function (container) {
        var that = this;

        // Get container from init params or use widget.body
        if (container !== null && container !== undefined) {
            that.container = container;
        } else {
            that.container = widget.body;
        }

        that.init = function () {
            // Create a model events that will be returned to the caller
            that.modelEvents = new ModelEvents();

            // Create the modal containing the main template
            that.modal = new UIKITModal({
                className: 'site-reset',
                closable: true,
                header: '<h4>Advanced filter</h4>',
                body:   TEMPLATES.main(),
                footer: '<button type="button" class="btn btn-primary">Ok</button><button type="button" class="btn btn-default">Annuler</button>'
            }).inject(that.container);
            that.modal.show();

            // Create listeners on buttons
            that.modal.getContent().getElement('.btn-default').addEvent('click', function () {
            	that.modal.hide();
            });
            that.modal.getContent().getElement('.btn-primary').addEvent('click', function () {
            	var checkboxes = that.modal.getContent().querySelectorAll('input[type="checkbox"]');
            	var selectedValues = [];
            	checkboxes.forEach(function (elt, idx) {
            		if (elt.checked) {
            			selectedValues.push(elt.nextElementSibling.textContent);
            		}
            	});
            	that.modelEvents.publish({event: 'advanced-filtering-criteria-changed', data: selectedValues});
            });

            // Create listeners on select element change
            that.modal.getContent().getElement('#enox-collectionview-advanced-filter-select-attribute').addEventListener('change', function () {
            	var elt = that.modal.getContent().getElement('#enox-collectionview-advanced-filter-value-selector');
            	elt.empty();

            	if (this.selectedIndex === 1) {
            		elt.innerHTML = TEMPLATES.partial({values: _instanceNames});
            	} else if (this.selectedIndex === 2) {
            		elt.innerHTML = TEMPLATES.partial({values: _states});
            	} else if (this.selectedIndex === 3) {
            		elt.innerHTML = TEMPLATES.partial({values: _variants});
            	}
            });

            return that.modelEvents;
        };

        that.show = function () {
            that.modal.show();
        };

        that.hide = function () {
            that.modal.hide();
        };

        that.destroy = function () {
            that.modal.destroy();
        };
    };

    return ENOXCollectionViewAdvancedFilter;
});
