/* COPYRIGHT DASSAULT SYSTEMES 2017
 * -----------------------------------------------------------------
 *
 *   Description :
 *   ------------
 *     Subject: This file is used to manage the properties panel component.
 *
 * -----------------------------------------------------------------
 *
 *   Story :
 *   -------
 *    Revision    /          Date      /        Author(s)    / Reasons for change
 *     0.1         /     Nov 01 2017   /       vlh2        / Initial revision.
 *     0.2         /     May 27 2018   /       mah2        / To manage 'editable' attribute
 *     0.3         /     Oct 31 2018   /       ruu1        / _lazyRender method modified to update all attr changed
 */

/**
 * @overview IDCard
 * @licence Copyright 2017 Dassault Systemes company. All rights reserved.
 * @version 1.0.
 * @access private
 */
define('DS/ENOXIDCard/js/IDCard', [
    'UWA/Class/View',
    'DS/Handlebars/Handlebars',
    'DS/ResizeSensor/js/ResizeSensor',
    'DS/UIKIT/DropdownMenu',
    'text!DS/ENOXIDCard/html/IDCard.html',
    'text!DS/ENOXIDCard/html/AttributesPartial.html',
    'text!DS/ENOXIDCard/html/MinifiedAttributesPartial.html',
    'text!DS/ENOXIDCard/html/AttributeSectionPartial.html',
    'i18n!DS/ENOXIDCard/assets/nls/ENOXIDCard',
    'css!DS/ENOXIDCard/css/IDCard.css',
    'css!DS/UIKIT/UIKIT.css'
], function(UWAView, Handlebars, ResizeSensor, DropdownMenu, IDCardTemplate, AttributesPartial, MinifiedAttributesPartial, AttributeSectionPartial, NLSKeys) {
    'use strict';

    var idCardTemplate = Handlebars.compile(IDCardTemplate);
    var attributesTemplate = Handlebars.compile(AttributesPartial);
    var minifiedAttributesTemplate = Handlebars.compile(MinifiedAttributesPartial);
    Handlebars.registerPartial('Attributes', AttributesPartial);
    Handlebars.registerPartial('MinifiedAttributes', MinifiedAttributesPartial);
    Handlebars.registerPartial('AttributeSection', AttributeSectionPartial);

    var ENOXIDCard = UWAView.extend({

        name: 'xapp-id-card',

        className: function () {
            return this.getClassNames('-container');
        },

        domEvents: {
            'click .sidebar-home-icon': '_triggerHomeIconEvent',
            'click .sidebar-back-icon': '_triggerBackIconEvent',
            'click .sidebar-expand-collapse-icon': '_triggerExpandCollapseIconEvent',
            'click .version': '_triggerVersionExplorerEvent',
            'click .configuration': '_triggerConfigurationEvent',
            'click .actions-menu-icon': '_triggerOpenActionsMenuIconEvent',
            'click .information-icon': '_triggerInformationIconEvent',
            'click .toggle-minified-icon': 'toggleMinified',
            'click .attribute-value': '_triggerClickOnAttributeEvent',
            'click .thumbnail': '_triggerClickOnThumbnail'
        },

        setup: function () {
            var that = this; 

            // Get model events object
            that.modelEvents = that.model.get('modelEvents');
            that.modelEventsTokens = [];

            // Check if attributes were passed and parsed it into two columns
            var attributesByColumn = that._parseAttributes(that.model.get('attributes'));

            // Create options object for handlebars template
            that.templateOptions = {
                withHomeButton: (that.model.get('withHomeButton') !== undefined) ? that.model.get('withHomeButton') : false,
                withExpandCollapseButton: (that.model.get('withExpandCollapseButton') !== undefined) ? that.model.get('withExpandCollapseButton') : false,
                withActionsButton: (that.model.get('withActionsButton') !== undefined) ? that.model.get('withActionsButton') : true,
                withInformationButton: (that.model.get('withInformationButton') !== undefined) ? that.model.get('withInformationButton') : false,
                withToggleMinifiedButton: (that.model.get('withToggleMinifiedButton') !== undefined) ? that.model.get('withToggleMinifiedButton') : false,
                showBackButton: (that.model.get('showBackButton') !== undefined) ? that.model.get('showBackButton') : false,
                thumbnail: that.model.get('thumbnail'),
                name: that.model.get('name'),
                version: that.model.get('version'),
                configuration: that.model.get('configuration'),
                attributes: attributesByColumn,
                dropdown: (that.model.get('dropdown') !== undefined) ? that.model.get('dropdown') : false,
                freezones: that.model.get('freezones'),
                minified: that.model.get('minified'),
                nls: NLSKeys
            };

            // if no customEvents object passed, create empty one in the model
            if (that.model.get('customEvents') === undefined) {
                that.model.set('customEvents', {});
            }

            // Listen on model change and and 'lazy render' the changes (have to used and store a named function to remove the listener during destroy)
            that.modelOnChangeListener = function (e) {
                that._lazyRender(e._changed);
            };
            that.model.addEvent('onChange', that.modelOnChangeListener);

            // Listen on minify, expand and toggle events
            that.modelEventsTokens.push(that.modelEvents.subscribe({event: 'idcard-minify'}, function () {
                that.minify();
            }));
            that.modelEventsTokens.push(that.modelEvents.subscribe({event: 'idcard-expand'}, function () {
                that.expand();
            }));
            that.modelEventsTokens.push(that.modelEvents.subscribe({event: 'idcard-toggle-minified-view'}, function () {
                that.toggleMinified();
            }));
            that.modelEventsTokens.push(that.modelEvents.subscribe({event: 'idcard-toggle-information-icon'}, function (data) {
                that.toggleInformationIcon(data);
            }));
            that.modelEventsTokens.push(that.modelEvents.subscribe({event: 'idcard-change-thumbnail'}, function (src) {
                that.changeThumbnail(src);
            }));

            // Listen on triptych 'show' and 'hide' panel and toggle information icon active status
            that.modelEventsTokens.push(that.modelEvents.subscribe({event: 'triptych-panel-visible'}, function (data) {
                if (data === 'right') {
                    that.toggleInformationIcon(true);
                }
            }));
            that.modelEventsTokens.push(that.modelEvents.subscribe({event: 'triptych-panel-hidden'}, function (data) {
                if (data === 'right') {
                    that.toggleInformationIcon(false);
                }
            }));
        },

        render: function () {
            var that = this;

            // Create basic HTML structure from template
            that.container.setHTML(idCardTemplate(that.templateOptions));

            // If no home button and no expand / collapse button, hide the related container
            if (!that.templateOptions.withHomeButton && !that.templateOptions.withExpandCollapseButton) {
                that.container.addClassName('no-sidebar-buttons');
                that.container.getElement('.sidebar-buttons').addClassName('hidden');
            }

            // If dropdown has been passed (and withActions button is at true), create a UIKIT dropdown menu on the action button element
            if (that.templateOptions.withActionsButton && that.templateOptions.dropdown) {
                that.templateOptions.dropdown.target = that.container.getElement('.actions-menu-icon');
                new DropdownMenu(that.templateOptions.dropdown);
            }

            // Rendering freezones
            var freezones = that.model.get('freezones');
            if (freezones !== undefined && freezones.length > 0) {
                freezones.forEach(function (freezone, idx) {
                    var freezoneElt = that.container.getElement('.free-zone-' + idx);

                    if (typeof freezone === 'string') {
                        freezoneElt.innerHTML = freezone;    // User has passed plain HTML : we use innerHTML
                    } else if (freezone instanceof HTMLElement) {
                        freezoneElt.appendChild(freezone);    // User has passed an HTML element : we use appendChild
                    } else if (freezone.render !== undefined) {
                        freezone.render().inject(freezoneElt);    // User has passed an UWA.Class.View (TODO : better way to detect UWA.Class.View?) : we inject it and call render
                    }
                });
            }

            // Apply responsive design
            this.requestID =   window.requestAnimationFrame(function () {
                that.resize();
            });

            // Apply minified at render if corresponding option is set to true
            if (that.model.get('minified')) {
                that.container.addClassName('minified');
            }

            return that;
        },

        _lazyRender: function (attributesChanged) {
            var that = this, keys = Object.keys(attributesChanged), elt;
            keys.forEach(function(key){
                var value = attributesChanged[key];

                if (key === 'name' || key === 'version' || key === 'configuration') {
                    elt = that.container.getElement('.' + key);
                    elt.textContent = value;
                    elt.title = value;
                } else if (key === 'thumbnail') {
                    that.container.getElement('.thumbnail').src = value;
                } else if (key === 'attributes') {
                    var attributesByColumn = that._parseAttributes(value);
                    that.container.getElement('.attributes-placeholder').innerHTML = attributesTemplate({attributes: attributesByColumn});
                    that.container.getElement('.attributes-section-when-minified-container').innerHTML = minifiedAttributesTemplate({attributes: attributesByColumn});
                } else if (key === 'freezones') {
                    that.container.getElement('.free-zone-0').innerHTML = value[0];
                } else if (key === 'showBackButton') {
                    if (value) {
                        that.container.getElement('.sidebar-back-icon').removeClassName('hidden');
                    } else {
                        that.container.getElement('.sidebar-back-icon').addClassName('hidden');
                    }
                }
            });
        },

        attachResizeSensor: function () {
            var that = this;
            that.resizeSensor = new ResizeSensor(that.container, function () {
                that.resize();
            });

            // Text-overflow CSS strange behavior across browsers so we do it post-render using offsetWidth
            that.container.getElements('.attributes-placeholder .attribute-section').forEach(function (elt) {
                // Add a CSS-defined width on 'attribute-value' then apply text-overflow on it
                var attrValueElt = elt.getElement('.attribute-value');
                attrValueElt.style.width = (elt.offsetWidth - elt.getElement('.attribute-name').offsetWidth - 21) + 'px';
                attrValueElt.style.overflow = 'hidden';
                attrValueElt.style.textOverflow = 'ellipsis';
            });
        },

        resize: function () {
            var that = this;
            var width = that.container.offsetWidth;

            // If minified, check overflow for attributes
            if (that.container.hasClassName('minified')) {
                that._checkMinifiedAttributesOverflow();
            }
            
            // Hide first freezone at 1080px
            if (width < 1180) {
                that.container.getElement('.free-zone-1').addClassName('hidden');
            } else {
                that.container.getElement('.free-zone-1').removeClassName('hidden');
            }

            // Hide second freezone at 850px
            if (width < 950) {
                that.container.getElement('.free-zone-0').addClassName('hidden');
            } else {
                that.container.getElement('.free-zone-0').removeClassName('hidden');
            }

            // Hide thumnail at 768px
            if (width < 868) {
                that.container.addClassName('no-image-placeholder');
                that.container.getElement('.image-placeholder').addClassName('hidden');
            } else {
                that.container.removeClassName('no-image-placeholder');
                that.container.getElement('.image-placeholder').removeClassName('hidden');
            }

            // Hide second column of attributes at 500px (check before using addClassName / removeClassName for edge case when IDCard init with no attributes)
            var attributesFirstColumn = that.container.getElement('.attribute-columns[data-column-index="1"]');
            if (attributesFirstColumn !== null) {
                if (width < 500) {
                    that.container.getElement('.attribute-columns[data-column-index="1"]').addClassName('hidden');
                } else {
                    that.container.getElement('.attribute-columns[data-column-index="1"]').removeClassName('hidden');
                }
            }
        },

        minify: function () {
            if (!this.container.hasClassName('minified')) {
                this.container.addClassName('minified');
                this.modelEvents.publish({event: 'idcard-minified'});
            }
        },

        expand: function () {
            if (this.container.hasClassName('minified')) {
                this.container.removeClassName('minified');
                this.modelEvents.publish({event: 'idcard-expanded'});
            }
        },

        toggleMinified: function () {
            var toggleMinifiedIcon = this.container.querySelector('.toggle-minified-icon');
            if (this.container.hasClassName('minified')) {
                this.expand();
                if (toggleMinifiedIcon !== null) {
                    toggleMinifiedIcon.classList.remove('fonticon-expand-down');
                    toggleMinifiedIcon.classList.add('fonticon-expand-up');
                    toggleMinifiedIcon.title = NLSKeys.collapse;
                }
            } else {
                this.minify();
                if (toggleMinifiedIcon !== null) {
                    toggleMinifiedIcon.classList.remove('fonticon-expand-up');
                    toggleMinifiedIcon.classList.add('fonticon-expand-down');
                    toggleMinifiedIcon.title = NLSKeys.expand
                    ;
                }

            }
        },

        toggleInformationIcon: function (active) {
            var informationIcon = this.container.getElement('.information-icon');

            if (informationIcon !== null) {
                if (active === undefined || active === null) {
                    informationIcon.classList.toggle('active');
                } else if (active) {
                    informationIcon.classList.add('active');
                } else {
                    informationIcon.classList.remove('active');
                }
            }
        },

        changeThumbnail: function (srcimage) {
            if (this.container.getElement('.thumbnail')) {
                this.container.getElement('.thumbnail').src = srcimage;
                this.modelEvents.publish({event: 'idcard-thumbnail-changed', data: srcimage});
            }
        },

        destroy: function () {
            var that = this;

            // Clean all listeners, remove ResizeSensor and then call this._parent()
            that.model.removeEvent('onChange', that.modelOnChangeListener);
            that.modelEventsTokens.forEach(function (token) {
            	that.modelEvents.unsubscribe(token);
            });
            if (that.resizeSensor) {
                that.resizeSensor.detach(this.container);
            }
            window.cancelAnimationFrame(this.requestID);
            this._parent();
        },

        /**
         * Check (in Javascript), how many minified attributes we can display witout overflow
         * Didn't find a way to make it with pure CSS (even with Flexbox), at least it'll work same way on Chrome, Firefox and IE
         */
        _checkMinifiedAttributesOverflow: function () {
            var that = this;

            var minifiedAttributeSectionsContainer = that.container.getElement('.attributes-section-when-minified-container');
            var minifiedAttributeSections = minifiedAttributeSectionsContainer.getElements('.attribute-section');

            // Remove all previously added 'hidden' classes
            for (var k = 0; k < minifiedAttributeSections.length; k++) {
                minifiedAttributeSections[k].removeClassName('hidden');
            }

            // Check if there is an overflow; early exit if not
            if (minifiedAttributeSectionsContainer.scrollWidth <= minifiedAttributeSectionsContainer.offsetWidth) {
                return;
            }

            // Now, select all attributes section and check how many we can display before overflowing
            var addedAttributeSectionsWidth = 0;
            for (var i = 0; i < minifiedAttributeSections.length; i++) {
                addedAttributeSectionsWidth += minifiedAttributeSections[i].offsetWidth;
                if (addedAttributeSectionsWidth > minifiedAttributeSectionsContainer.offsetWidth) {
                    minifiedAttributeSections[i].addClassName('hidden');
                }
            }
        },

        _triggerHomeIconEvent: function () {
            this.modelEvents.publish(this.model.get('customEvents').homeIconClick || {event: 'idcard-show-landing-page'});
        },

        _triggerConfigurationEvent: function () {
            this.modelEvents.publish(this.model.get('customEvents').configurationLabelClick || {event: 'idcard-open-configuration-selector'});
        },

        _triggerBackIconEvent: function () {
            this.modelEvents.publish(this.model.get('customEvents').backIconClick || {event: 'idcard-back'});
        },

        _triggerExpandCollapseIconEvent: function () {
            this.modelEvents.publish(this.model.get('customEvents').expandCollapseIconClick || {event: 'welcome-panel-toggle'});
        },

        _triggerVersionExplorerEvent: function () {
            this.modelEvents.publish(this.model.get('customEvents').versionLabelClick || {event: 'idcard-open-version-explorer', data: {id: this.model.get('id')}});
        },

        _triggerOpenActionsMenuIconEvent: function () {
            this.modelEvents.publish(this.model.get('customEvents').actionsMenuClick || {event: 'idcard-open-actions-menu'});
        },

        _triggerInformationIconEvent: function () {
            this.modelEvents.publish(this.model.get('customEvents').informationIconClick || {event: 'triptych-toggle-panel', data: 'right'});
        },

        _triggerClickOnAttributeEvent: function (e) {
            this.modelEvents.publish({
                event : 'idcard-attributes-clicked',
                data : {
                    index : parseInt(e._uwaTarget.parentElement.getAttribute('data-attribute-index'), 10),
                    attributeName : e._uwaTarget.parentElement.querySelector('.attribute-name').innerHTML
                }
            });
        },

        _triggerClickOnThumbnail: function () {
            this.modelEvents.publish({ event: 'idcard-thumbnail-clicked', data: null});
        },

        /**
         * Parse attributes, split into two columns and add a unique index
         */
        _parseAttributes: function (attrs) {
            // Check if attributes were passed and parsed it into two columns
            var attributesByColumn = [], uniqueIDAttribute = 0;
            if (attrs !== undefined) {
                attributesByColumn = [attrs.slice(0, 3), attrs.slice(3, 6)];
                attributesByColumn.forEach(function (attrColumn) {
                    attrColumn.forEach(function (attr) {
                        attr.index = uniqueIDAttribute++;
                    });
                });
            }
            return attributesByColumn;
        }
    });

    return ENOXIDCard;
});
