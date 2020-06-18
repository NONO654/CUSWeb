define('DS/CollectionViewSample/ENOXCollectionViewConfigurableAttributes/ENOXCollectionViewConfigurableAttributes', [
    'DS/CoreEvents/ModelEvents',
    'DS/Handlebars/Handlebars',
    'DS/UIKIT/Modal',
    'text!DS/CollectionViewSample/ENOXCollectionViewConfigurableAttributes/ENOXCollectionViewConfigurableAttributes.html'
], function (ModelEvents, Handlebars, UIKITModal, Template) {

    var TEMPLATES = {
        main: Handlebars.compile(Template),
    };

    var ConfigurableAttributes = function (container) {
        var that = this;

        // Get container from init params or use widget.body
        if (container !== null && container !== undefined) {
            that.container = container;
        } else {
            that.container = widget.body;
        }

        that.init = function (allAttributes) {
            // Create a model events that will be returned to the caller
            that.modelEvents = new ModelEvents();

            // Create the modal containing the main template
            that.modal = new UIKITModal({
                className: 'site-reset',
                closable: true,
                header: '<h4>Attributes selector</h4>',
                body:   TEMPLATES.main({attributes: allAttributes}),
                footer: '<button type="button" class="btn btn-primary">Ok</button><button type="button" class="btn btn-default">Annuler</button>'
            }).inject(that.container);
            that.modal.show();

            // Create listeners on buttons
            that.modal.getContent().getElement('.btn-default').addEvent('click', function () {
                that.modal.hide();
            });
            that.modal.getContent().getElement('.btn-primary').addEvent('click', function () {
                // Get primary and secondary attribute
                var primaryOptElt = that.modal.getContent().getElement('#enox-collectionview-select-primary-attribute');
                var secondaryOptElt = that.modal.getContent().getElement('#enox-collectionview-select-secondary-attribute');

                var selectedItems = [{
                    name: primaryOptElt.value,
                    index: parseInt(primaryOptElt.options[primaryOptElt.selectedIndex].getAttribute('data-index'), 10),
                    hideAttributeName: that.modal.getContent().getElement('#checkbox4primary').checked 
                }, {
                    name: secondaryOptElt.value,
                    index: parseInt(secondaryOptElt.options[secondaryOptElt.selectedIndex].getAttribute('data-index'), 10),
                    hideAttributeName: that.modal.getContent().getElement('#checkbox4secondary').checked
                }];

                // Get list of attributes
                var attributes = [];
                that.modal.getContent().getElements('.other-attributes-selector input[type="checkbox"]').forEach(function (elt) {
                    if (elt.checked) {
                        attributes.push(parseInt(elt.getAttribute('data-index'), 10));
                    }
                });
                selectedItems.push(attributes);

                that.modelEvents.publish({event: 'attributes-selected', data: selectedItems});
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

    return ConfigurableAttributes;
});
