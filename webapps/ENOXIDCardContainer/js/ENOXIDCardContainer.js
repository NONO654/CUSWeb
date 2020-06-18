/**
* Component to handle the IDCard and the content of a given object, wrapped for ease of use of the 'collapsed' mode of the IDCard
*/
define('DS/ENOXIDCardContainer/js/ENOXIDCardContainer', [
    'DS/ENOXSplitViewVertical/js/ENOXSplitViewVertical',
    'DS/ENOXIDCard/js/IDCard',
    'DS/CoreEvents/ModelEvents',
    'DS/Handlebars/Handlebars',
    'text!DS/ENOXIDCardContainer/html/ENOXIDCardContainer.html',
    'css!DS/ENOXIDCardContainer/css/ENOXIDCardContainer.css'
],

function (
    ENOXSplitViewVertical,
    IDCard,
    ModelEvents,
    Handlebars,
    html_ENOXIDCardContainer,
    css_ENOXIDCardContainer
    ) {
    'use strict';

    /* Fetching the panel template through Handlebars */
    var panelTemplate = Handlebars.compile(html_ENOXIDCardContainer);
    var IDCARD_MAX_HEIGHT = 110;
    var IDCARD_MIN_HEIGHT = 40;

    var ENOXIDCardContainer = function () {
        this._options = {};
    };

    ENOXIDCardContainer.prototype.init = function (options, idCardModel) {
        this._options.withtransition = options && options.withtransition !== undefined ? options.withtransition : true;
        this._options.withoverflowhidden = options && options.withoverflowhidden !== undefined ? options.withoverflowhidden : true;

        this._options.large_idcard = idCardModel.get('minified') !== undefined ? idCardModel.get('minimifed') : true;

        this._modelEvents = options && options.modelEvents ? options.modelEvents : new ModelEvents();
        this._modelEvents = idCardModel.get('modelEvents') ? idCardModel.get('modelEvents') : this._modelEvents;

        this._idCardModel = idCardModel;
        this._idCard = new IDCard({ model: idCardModel });
        this._subscribeToEvents();
        this._initDivs();
    };

    ENOXIDCardContainer.prototype._initDivs = function () {
        this._container = document.createElement('div');

        var ENOXSplitViewVertical_options = {};
        ENOXSplitViewVertical_options.withtransition = this._options.withtransition;
        ENOXSplitViewVertical_options.withoverflowhidden = true;
        ENOXSplitViewVertical_options.sizeType = 'px';
        ENOXSplitViewVertical_options.originalTop = this._options.large_idcard ? IDCARD_MAX_HEIGHT : IDCARD_MIN_HEIGHT;
        ENOXSplitViewVertical_options.modelEvents = this._modelEvents;
        this._ENOXSplitViewVertical = new ENOXSplitViewVertical();
        this._ENOXSplitViewVertical.init(ENOXSplitViewVertical_options);

        var container = panelTemplate(this._options);
        this._container.innerHTML = container;
        this._container = this._container.firstChild;
        this._container.appendChild(this._ENOXSplitViewVertical.getContent());

        this._idCardContainer = this._ENOXSplitViewVertical.getContent().querySelector('.top-container');
        this._contentContainer = this._ENOXSplitViewVertical.getContent().querySelector('.bot-container');
    };

    ENOXIDCardContainer.prototype.inject = function (container) {
        this._idCard.render().inject(this._idCardContainer);
        container.appendChild(this._container);
        this._idCard.attachResizeSensor();
    };

    ENOXIDCardContainer.prototype.getContent = function () { // should not be used, actually
        return this._container;
    };

    ENOXIDCardContainer.prototype.getMainContent = function () { // retrieve the bottom content , i.e. the "main content" of the IDCardContainer composite
        return this._contentContainer;
    };

    ENOXIDCardContainer.prototype.getIDCard = function () {
        return this._idCard;
    };

    ENOXIDCardContainer.prototype._subscribeToEvents = function () {
        var that = this;
        this._listSubscription = [];
        this._listSubscription.push(this._modelEvents.subscribe({ event: 'idcard-container-minimize-idcard' }, function () {
            that._modelEvents.publish({ event: 'splitview-vertical-set-top-size', data: IDCARD_MIN_HEIGHT });
            that._modelEvents.publish({ event: 'idcard-minify' });
        }));
        this._listSubscription.push(this._modelEvents.subscribe({ event: 'idcard-container-maximize-idcard' }, function () {
            that._modelEvents.publish({ event: 'splitview-vertical-set-top-size', data: IDCARD_MAX_HEIGHT });
            that._modelEvents.publish({ event: 'idcard-expand' });
        }));

        this._listSubscription.push(this._modelEvents.subscribe({ event: 'idcard-minified' }, function () {
            that._modelEvents.publish({ event: 'splitview-vertical-set-top-size', data: IDCARD_MIN_HEIGHT });
            that._modelEvents.publish({ event: 'idcard-minify' });
        }));

        this._listSubscription.push(this._modelEvents.subscribe({ event: 'idcard-expanded' }, function () {
            that._modelEvents.publish({ event: 'splitview-vertical-set-top-size', data: IDCARD_MAX_HEIGHT });
            that._modelEvents.publish({ event: 'idcard-expand' });
        }));

        this._listSubscription.push(this._modelEvents.subscribe({ event: 'splitview-vertical-resized' }, function (data) {
            if (data === IDCARD_MIN_HEIGHT) {
                that._modelEvents.publish({ event: 'idcard-container-minified' });
            }
            else if (data === IDCARD_MAX_HEIGHT) {
                that._modelEvents.publish({ event: 'idcard-container-maximized' });
            }
        }));
    };

    ENOXIDCardContainer.prototype.destroy = function () { // would be great to have destroy/init/subscribeToEvents/initDiv/getContent shared prototype...
        // destroy DOM
        this._container = null;
        
        // destroy listener
        var i = 0;
        var len = this._listSubscription.length;
        for (i = 0; i < len; i++) {
            this._modelEvents.unsubscribe(this._listSubscription[i]);
        }

        this._idCard.destroy();
        this._ENOXSplitViewVertical.destroy();

        // destroy remaining objects
        var keys = Object.keys(this); // will return an array of own properties
        // remove the _modelEvents from keys
        var idx = keys.indexOf('_modelEvents'); // remove all members but modelEvents.. Note that it could be removed if not-passed by parent callee...
        if (idx > -1) {
            keys.splice(idx, 1);
        }
        for (i = 0; i < keys.length; i++) {
            this[keys[i]] = undefined;
        }
    };

    return ENOXIDCardContainer;
});
