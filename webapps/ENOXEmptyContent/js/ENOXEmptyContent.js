define('DS/ENOXEmptyContent/js/ENOXEmptyContent',
[
    'DS/CoreEvents/ModelEvents',
    'DS/ENOXEmptyContent/js/SentenceDetails',
    'i18n!DS/ENOXEmptyContent/assets/nls/ENOXEmptyContent',
    'css!DS/Core/wux-3ds-fonticons.css',
    'css!DS/Core/wux.css',
    'css!DS/ENOXEmptyContent/css/ENOXEmptyContent.css'
],
function (ModelEvents, SentenceDetails, NLS, css_wux_fonticons, css_wux, css_ENOXEmptyContent) {
    'use strict';

    var ENOXEmptyContent = function (param) {
        this._init(param);
    };

    ENOXEmptyContent.prototype.inject = function (parentElement) {
        parentElement.appendChild(this._containerEmptyContent);
    };

    ENOXEmptyContent.prototype.destroy = function () {
        this._modelEventsEmptyContent.unsubscribe(this._changeOrderedStyle);
        this._hasSentences = null;
        this._disableDialogPart = null;
        this._containerEmptyContent = null;
    };

    ENOXEmptyContent.prototype._init = function (param) {
        this._modelEventsEmptyContent = param && param.modelEvents ? param.modelEvents : new ModelEvents();
        this._hasSentences = param && param.sentences ? true : false;
        
        this._fontSizeSentences = param && param.fontSize ? param.fontSize : null;
        this._alignSentences = param && param.align ? param.align : 'center';
        this._orderedListType = param && param.orderedListType ? param.orderedListType : 'none';
        this._disableDialogPart = param && param.dialogLine && param.dialogLine.hasOwnProperty('disable') ? param.dialogLine.disable : true;
        this._bottomSentence = param && param.dialogLine && param.dialogLine.bottomSentence ? param.dialogLine.bottomSentence : NLS.defaultBottomSentence;
        this._fontSizeBottomSentence = param && param.dialogLine && param.dialogLine.fontSize ? param.dialogLine.fontSize : null;
        if (typeof param === 'string' || param instanceof String) {
            this._defaultText = param;
        } else {
            this._defaultText = param && param.defaultEmptyContentText ? param.defaultEmptyContentText : null;
        }

        this._initDiv(param);
        this._subscribeToEvents();
    };

    ENOXEmptyContent.prototype._initDiv = function (param) {
        this._containerEmptyContent = document.createElement('div');
        this._containerEmptyContent.classList.add('empty-content');

        this._container = document.createElement('div');
        this._container.classList.add('main-frame');
        this._containerEmptyContent.appendChild(this._container);

        if (this._hasSentences) {
            this._initDivSentences(param.sentences);
        } else {
            this._initDivDefault(this._defaultText);
        }
    };

    ENOXEmptyContent.prototype._initDivDefault = function (defaultText) {
        var divDefaultBack = document.createElement('div');
        divDefaultBack.classList.add('default-back');
        divDefaultBack.classList.add('align-center');

        var defaultBackText = document.createElement('div');
        defaultBackText.classList.add('default-back-text');
        defaultBackText.classList.add('wux-icon-gray');
        if (defaultText != null) {
            defaultBackText.innerHTML = defaultText;
        } else {
            defaultBackText.innerHTML = NLS.emptyPage;
        }

        var defaultBackBackground = document.createElement('div');
        defaultBackBackground.classList.add('default-back-background');
        defaultBackBackground.classList.add('wux-light-steel');

        var icon = document.createElement('i');
        icon.classList.add('wux-ui-3ds');
        icon.classList.add('wux-ui-3ds-code');
        defaultBackBackground.appendChild(icon);

        divDefaultBack.appendChild(defaultBackText);
        divDefaultBack.appendChild(defaultBackBackground);
        this._container.appendChild(divDefaultBack);
    };

    ENOXEmptyContent.prototype._initDivSentences = function (sentences) {
        var container = this._container;
        var olElement = null;
        var that = this;
        if (this._orderedListType != null) {
            olElement = document.createElement('ol');
            container.appendChild(olElement);
        }

        for (var i = 0; i < sentences.length; i++) {
            if (that._orderedListType != null && olElement != null) {
                var ilElement = document.createElement('li');
                ilElement.style.listStyle = that._orderedListType;
                container = ilElement;
                olElement.appendChild(ilElement);
            }
            var sentenceDetails = new SentenceDetails(sentences[i], that._fontSizeSentences, that._alignSentences, that._modelEventsEmptyContent);
            if (i != (sentences.length-1)) {
                var divSplitDetails = document.createElement('div');
                divSplitDetails.classList.add('split-details');
                that._initSplitDetails(divSplitDetails);
                sentenceDetails._container.appendChild(divSplitDetails);
            }
            sentenceDetails.inject(container);
        }
        
        if (!this._disableDialogPart) {
            this._initDialogDetails(this._bottomSentence);
        }
    };

    ENOXEmptyContent.prototype._initSplitDetails = function (container) {
        var splitLineLeft = document.createElement('div');
        splitLineLeft.classList.add('split-line-left');

        var splitOr = document.createElement('div');
        splitOr.classList.add('split-or');
        splitOr.classList.add('wux-light-steel');
        splitOr.innerHTML = NLS.or;

        var splitLineRight = document.createElement('div');
        splitLineRight.classList.add('split-line-right');

        if (container) {
            container.appendChild(splitLineLeft);
            container.appendChild(splitOr);
            container.appendChild(splitLineRight);
        }
    }

    ENOXEmptyContent.prototype._initDialogDetails = function (sentence) {
        var divDialogDetails = document.createElement('div');
        divDialogDetails.classList.add('dialog-details');
        
        var dialogLine = document.createElement('div');
        dialogLine.classList.add('dialog-line');
        this._drawLine(dialogLine);

        var bottomSentence = document.createElement('div');
        bottomSentence.classList.add('bottom-sentence');
        bottomSentence.classList.add('align-center');
        bottomSentence.classList.add('wux-icon-gray');
        if (this._fontSizeBottomSentence !== null) {
            bottomSentence.style.fontSize = this._fontSizeBottomSentence;
        }
        bottomSentence.innerHTML = sentence;

        divDialogDetails.appendChild(dialogLine);
        divDialogDetails.appendChild(bottomSentence);
        this._container.appendChild(divDialogDetails);
    };

    ENOXEmptyContent.prototype._drawLine = function (container) {
        var rightLine = document.createElement('div');
        rightLine.classList.add('right-line');

        var middleLines = document.createElement('div');
        middleLines.classList.add('middle-lines');

        var turnBorderTop = document.createElement('div');
        turnBorderTop.classList.add('turn-border-top');
        middleLines.appendChild(turnBorderTop);

        var turnBorderRight = document.createElement('div');
        turnBorderRight.classList.add('turn-border-right');
        middleLines.appendChild(turnBorderRight);

        var leftLine = document.createElement('div');
        leftLine.classList.add('left-line');

        var clearFloat = document.createElement('div');
        clearFloat.classList.add('clear-float');

        if (container) {
            container.appendChild(rightLine);
            container.appendChild(middleLines);
            container.appendChild(leftLine);
            container.appendChild(clearFloat);
        }
    };

    ENOXEmptyContent.prototype._subscribeToEvents = function () {
        //var that = this;
        //this._changeOrderedStyle = this._modelEventsEmptyContent.subscribe({ event: 'empty-content-change-ordered-list-style' }, function (data) {
        //    that._orderedListType = data;
        //    var listElements = document.getElementsByTagName('li');
        //    if (listElements) {
        //        for (var i = 0; i < listElements.length; i++) {
        //            listElements[i].style.listStyle = that._orderedListType;
        //        }
        //    }
        //})
    };

    return ENOXEmptyContent;
});
