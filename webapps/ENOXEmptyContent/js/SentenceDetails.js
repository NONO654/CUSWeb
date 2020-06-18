define('DS/ENOXEmptyContent/js/SentenceDetails',
[
    'DS/CoreEvents/ModelEvents',
    'i18n!DS/ENOXEmptyContent/assets/nls/ENOXEmptyContent'
],
function (ModelEvents, NLS) {
    'use strict';

    var SentenceDetails = function (param, fontSize, align, modelEvents) {
        this._init(param, fontSize, align, modelEvents);
    };

    /***************************************************PUBLIC METHODS**********************************************************/

    SentenceDetails.prototype.inject = function (parentElement) {
        parentElement.appendChild(this._container);
    };

    SentenceDetails.prototype.destroy = function () {
        this._modelEventsParent.unsubscribe(this._changeAlign);
        this._fontSize = null;
        this._hasEvents = null;
        this._fonticon = null;
        this._sizeicon = null;
        this._src = null;
        this._sentenceText = null;
        this._domElement = null;
        this._containerIcon = null;
        this._containerSentence = null;
        this._container = null;
    };

    /***************************************************INITIALIZATION************************************************************/

    SentenceDetails.prototype._init = function (param, fontSize, align, modelEvents) {
        this._modelEventsParent = modelEvents ? modelEvents : new ModelEvents();
        this._fontSize = fontSize ? fontSize : null;
        this._align = align ? align : 'center';
        this._hasEvents = param.events ? true : false;
        
        this._loadParamSentenceWithType(param);
        this._initDiv();
        if (this._hasEvents) {
            this._addEvents(param.events);
        }
        this._subscribeToEvents();
    };

    SentenceDetails.prototype._initDiv = function () {
        this._container = document.createElement('div');
        this._container.classList.add('sentence-details');
        this._container.classList.add('align-' + this._align);

        if (this._domElement != null) {
            if (this._domElement == 'dom') {
                console.log('No DOMelement');
                this._container.innerHTML = this._sentenceText;
            } else {
                this._container.appendChild(this._domElement);
            }
        } else {
            this._containerIcon = document.createElement('div');
            this._containerIcon.classList.add('sentence-icon');
            this._containerIcon.classList.add('wux-icon-gray');

            if (this._fonticon === null && this._src !== null) {
                this._icon = document.createElement('img');
                this._icon.src = this._src;
                this._icon.classList.add('tile-image');
                this._icon.setAttribute("draggable", false);
            } else if (this._src === null) {
                this._icon = document.createElement('i');
                this._icon.classList.add('wux-ui-3ds');
                if(this._sizeicon !== null) {
                    this._icon.style.fontSize = this._sizeicon;
                } else {
                    this._icon.classList.add('wux-ui-3ds-2x');
                }
				if(this._fonticon !== ' ') {
                    this._icon.classList.add("wux-ui-3ds-"+this._fonticon);
				}
            }
            this._containerIcon.appendChild(this._icon);

            this._containerSentence = document.createElement('div');
            this._containerSentence.classList.add('sentence-text');
            this._containerSentence.classList.add('wux-icon-gray');
            if (this._fontSize !== null) {
                this._containerSentence.style.fontSize = this._fontSize;
            }
            this._containerSentence.innerHTML = this._sentenceText;

            this._container.appendChild(this._containerIcon);
            this._container.appendChild(this._containerSentence);
        }
    };
    
    SentenceDetails.prototype._loadParamSentenceWithType = function (sentence) {
        switch (sentence.type) {
            case 'search':
                this._fonticon = sentence.fonticon ? sentence.fonticon : 'search';
                this._sizeicon = sentence.sizeicon ? sentence.sizeicon : null;
                this._src = null;
                this._sentenceText = sentence.text ? sentence.text : NLS.defaultSearchText;
                this._domElement = null;
                break;
            case 'drop':
                this._fonticon = sentence.fonticon ? sentence.fonticon : 'drag-drop';
                this._sizeicon = sentence.sizeicon ? sentence.sizeicon : null;
                this._src = null;
                this._sentenceText = sentence.text ? sentence.text : NLS.defaultDropText;
                this._domElement = null;
                break;
            case 'icon':
                this._fonticon = sentence.fonticon ? sentence.fonticon : ' ';
                this._sizeicon = sentence.sizeicon ? sentence.sizeicon : null;
                this._src = null;
                this._sentenceText = sentence.text;
                this._domElement = null;
                break;
            case 'img':
                this._fonticon = null;
                this._sizeicon = null;
                this._src = sentence.src ? sentence.src : ' ';
                this._sentenceText = sentence.text;
                this._domElement = null;
                break;
            case 'dom':
                this._fonticon = null;
                this._sizeicon = null;
                this._src = null;
                this._sentenceText = sentence.text ? sentence.text : null;
                this._domElement = sentence.DOMelement && sentence.DOMelement instanceof HTMLElement ? sentence.DOMelement : sentence.type;
                break;
            default:
                this._fonticon = null;
                this._sizeicon = null;
                this._src = null;
                this._sentenceText = null;
                this._domElement = null;
        }
    };

    /***************************************************EVENTS************************************************************/

    SentenceDetails.prototype._addEvents = function (events) {
        var that = this;
        if (Object.keys(events).toString() == "onclick") {
            that._container.onclick = events.onclick;
            that._container.onmouseover = function () {
                that._container.style.cursor = "pointer";
            };
        }
    };

    SentenceDetails.prototype._subscribeToEvents = function () {
        var that = this;
        this._changeAlign = this._modelEventsParent.subscribe({ event: 'empty-content-change-align' }, function (data) {
            that._container.classList.remove('align-' + that._align);
            that._align = data;
            that._container.classList.add('align-' + that._align);
        })
    };

    return SentenceDetails;
});
