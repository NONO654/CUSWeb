/*global define*/
define('DS/Foundation/CsvParser', [],
/**
 * returns an object with a function taking a csv string as input and outputting an array of arrays
 * 
 * csv here means that the fields are separated by commas.
 * @module Foundation/CsvParser
 *
 */

function () {
    'use strict';
    var CsvParser = {
        /**
         *  a function taking a csv string as input and outputting an array of arrays.
         *  fields can be quoted strings or simple strings.  Quoted strings are mandatory if the field contains a , a \r a \n or starts with a "
         *  " in a quoted strings are escaped by doubling them
         *  @param iInputString the string to parse
         *  @return array of array each internal element is a field
         */
        parse: function (iInputString) {
            var lineArray = [];
            var lCurrentIndexInString = 0;
            var lTotalInputStringSize = iInputString.length;
            /**
             * @private
             * @return true if there is more to do false if finished
             */

            function parseLine() {
                var curLine = [];
                /**
                 * @private
                 * @return true if there is more to do false if finished
                 */
                function parseField() {
                    //at start of a field, we need to look at the first character to see if it is a quoted string
                    var curString = iInputString.substring(lCurrentIndexInString);
/**
 * parses a quoted string taking into account escaped " characters.
 * @return the parsed string
 * this can throw exceptions!
 */
                    function parseQuotedString() {
                        var quotedString = "";
                        //quoted string, look for the next "
                        var lIndexOfNextQuote;
                        for (;;) {
                            lIndexOfNextQuote = curString.indexOf('"');
                            if (lIndexOfNextQuote === -1) {
                                //error 
                                throw new Error('expecting closing "');
                            }
                            quotedString += curString.substring(0, lIndexOfNextQuote);
                            lCurrentIndexInString += lIndexOfNextQuote + 1;
                            curString = iInputString.substring(lCurrentIndexInString);
                            if (curString.length === 0 || curString[0] !== '"') {
                                //we got our string we are done
                                return quotedString;
                            }
                            //there is a following quote after
                           
                                quotedString += '"';
                                lCurrentIndexInString++;
                                curString = iInputString.substring(lCurrentIndexInString);
                            
                        }

                    }
                    
                    if (iInputString[lCurrentIndexInString] === '"') {
                        //skip the quote
                        lCurrentIndexInString++;
                        curString = iInputString.substring(lCurrentIndexInString);
                        var quotedString = parseQuotedString();
                        curLine.push(quotedString);
                        //we could be at the end of our string to parse
                        if (lCurrentIndexInString < lTotalInputStringSize) {
                            //next character should be the end of field
                            var endOfFieldMatch = curString.match(/,|[\r\n]+/);
                            if (endOfFieldMatch === null || endOfFieldMatch.index !== 0) {
                                //left over stuff in our field
                                throw new Error('expecting ",", \\r, \\n or end of file');
                            } else {
                                //we have our end of field consume it
                                if (endOfFieldMatch[0] === ',') { //field separator
                                    //continue happily
                                } else { //line separator
                                    if (curLine.length) {
                                        lineArray.push(curLine);
                                    curLine = [];
                                    }
                                   
                                }
                                lCurrentIndexInString += endOfFieldMatch[0].length;
                                curString = iInputString.substring(lCurrentIndexInString);
                                return true;
                            }
                        }
                    } else {
                        //look for the end of the field
                        var endOfFieldMatch = curString.match(/,|[\r\n]+/);
                        if (endOfFieldMatch === null) { //end of string
                            // no more lines, we are done
                            lCurrentIndexInString = iInputString.length;
                            if (curString.length) {
                                curLine.push[curString];
                            }
                            if (curLine.length) {
                                lineArray.push(curLine);
                            }
                            return false;
                        } else {
                            //found a field or line separator
                            //add the field
                            curLine.push(curString.substring(0, endOfFieldMatch.index));
                            lCurrentIndexInString += endOfFieldMatch.index;
                            if (endOfFieldMatch[0] === ',') { //field separator
                                //continue happily
                            } else { //line separator
                                lineArray.push(curLine);
                                curLine = [];
                            }
                            //skip the separator
                            lCurrentIndexInString += endOfFieldMatch[0].length;
                            return true;
                        }
                    }

                }

                for (; parseField();) {

                }


                //we are done
                return false;
            }
            for (; parseLine();) {

            }
            return lineArray;
        }
    };
    return CsvParser;
});

/*global define*/
/**
 * @module Foundation/Collections/FoundationRelatedDataCollection
 *  define a base class for foundation relateddata collections.  This will be used to represent the content of related data attributes.
 *  This collections should delegate the creation of new object to the relevant collection for their type.
 *  
 *  @options  masterCollection:  the collection to be used to create new models
 *  @options relationshipName: the name of the relationship used to point to object in this collection.  When parsing a foundation service result, model objects which belongs to the 
 *  parent collection will create Models for all the relateddata.  If the relationship is the same as the one provided by this collection the model will be created in this collection.
 *  Only one child collection should exist for a given parentCollection/relationshipName pair.
 *     
 * @require UWA/Core
 * @require UWA/Class/Collection
 * @require DS/Foundation/Models/FoundationData
 *
 * @extend DS/Foundation/Models/FoundationData
 */
define('DS/Foundation/Collections/FoundationRelatedDataCollection', //define module 
['UWA/Core', 'UWA/Class/Collection', 'UWA/Class/Model'], //prereqs 

function (UWA, Collection/*, Model*/) {
    'use strict';


    var FoundationRelatedDataCollection = Collection.extend({
        _uwaClassName: 'FoundationRelatedDataCollection',
       

        
        setup: function FoundationChildCollectionSetup(models, options) {
            var args = Array.prototype.slice.call(arguments, 0);
            
            if (options) {
                this._masterCollection = options.masterCollection;
                this._relationshipName = options.relationshipName;
            }
            //add the models to the master
            if (this._masterCollection) {
                this._masterCollection.add(models);
            }
            return this._parent.apply(this, args);
        },

        /**
         * CRUD operations will be ignored.
         * 
         */
        sync: function (/*method, collection, options*/) {
        },
        add: function(){
            this._masterCollection.add.apply(this._masterCollection, arguments);
        }
        
    });
    return FoundationRelatedDataCollection;
});

define('DS/Foundation/FoundationAjax', ['UWA/Core', 'DS/WAFData/WAFData', 'DS/PlatformAPI/PlatformAPI'], function(UWA, WAFData, PlatformAPI) {//eslint-disable-line strict
  ''; // workaround for a bug in yui Compressor(https://github.com/yui/yuicompressor/issues/71)
'use strict';

    var FoundationAjax = {
      widgetization: 'ENOVIA_Application_Widget',
      /**
       * @method getParams
       * @returns {String} url parameter string
       */
      getParams: function() {
          var paramString = '';
          if (this.tenant && this.tenant.length > 0) {
              paramString += '&tenant=' + this.tenant;
          }
          // if (this.space && this.space.length > 0) {
          //     //SC must be encoded to support special characters like +, etc.
          //     paramString += '&SecurityContext=' + encodeURIComponent(this.space);
          // }
          if (this.rows && this.rows.length > 0) {
              paramString += '&e6w-objLimit=' + this.rows;
          }
          if (this.language && this.language.length > 0) {
              //TODO validate that server fix works and remove this
              var lLang = this.language;
              lLang = lLang === 'zh' ? 'zh_CN' : lLang;
              paramString += '&e6w-lang=' + lLang;
          }
          if (this.timezone) {
              paramString += '&e6w-timezone=' + this.timezone;
          }
          var hasOwn = Object.prototype.hasOwnProperty;
          var prefs = this.preferences;
          for (var key in prefs) {
              if (hasOwn.call(prefs, key)) {
                  paramString += '&' + key + '=' + prefs[key];
              }
          }
          if (this.params && this.params !== '') {
              paramString += '&' + this.params;
          }
          if (paramString !== '') {
              paramString = paramString.substring(1);
          }
          return paramString;
      },
      /**
       * @method getParamsAsJSON
       * @returns {Object} url parameters as a JSON object
       */
      getParamsAsJSON: function() {
          var paramObj = {};
          if (this.tenant && this.tenant.length > 0) {
              paramObj.tenant = this.tenant;
          }
          if (this.space && this.space.length > 0) {
              paramObj.SecurityContext = this.space;
          }
          if (this.rows && this.rows.length > 0) {
              paramObj['e6w-objLimit'] = this.rows;
          }
          if (this.language && this.language.length > 0) {
              paramObj['e6w-lang'] = this.language;
          }
          if (this.timezone) {
              paramObj['e6w-timezone'] = this.timezone;
          }
          var hasOwn = Object.prototype.hasOwnProperty;
          var prefs = this.preferences;

          for (var key in prefs) {
              if (hasOwn.call(prefs, key)) {
                  paramObj[key] = prefs[key];
              }
          }
          return paramObj;
      },
      setupEnoviaServer: function setupEnoviaServer() {
          var e6wUrl, runYourApp, myAppsUrl, lang, showSpace;
          if (window.widget) {
              e6wUrl = window.widget.getUrl();
              runYourApp = window.widget.getUrl().match(/[?&]runYourApp=([^&]*)?/);
              //override myapps url.
              myAppsUrl = PlatformAPI.getApplicationConfiguration('app.urls.myapps');
              e6wUrl = e6wUrl.substring(0, e6wUrl.indexOf('/webapps'));
              lang = window.widget.lang;
              showSpace = window.widget.getValue('showSpace') || window.widget.getValue('widgetName') === FoundationAjax.widgetization || 'false';
              window.widget.setValue('showSpace', showSpace);
          } else {
              e6wUrl = window.location.origin;
              showSpace = '';
          }
          if (!myAppsUrl || runYourApp) {
              myAppsUrl = e6wUrl;
          }
          window.WidgetConstants = {
              str: {}
          };
          var date = new Date();
          var timezone = date.getTimezoneOffset();
          var user = PlatformAPI.getUser();
          if (user && user.login) {
              user = user.login;
          }
          window.enoviaServer = {
              params: '',
              sRealURL: e6wUrl,
              showSpace: showSpace,
              objectId: '',
              widgetName: '',
              taggerContextId: 'auto',
              appName: '',
              tenant: '',
              space: null,
              rows: null,
              preferences: {},
              storageUrl: myAppsUrl,
              language: lang,
              timezone: timezone,
              _getUrl: function() {
                  return this.storageUrl || this.sRealURL;
              },
              getParams: FoundationAjax.getParams,
              getParamsAsJSON: FoundationAjax.getParamsAsJSON,
              computeUrl: function(suffix) { //bcc: for better testing please do not access getUrl directly but use this method
                  return this._getUrl() + suffix;
              },
              user: user
          };
          window.enoviaServer.storageUrl = window.enoviaServer.storageUrl.replace(':443', '');
      },

        /**
         * Calculate final URL with params etc.
         * @param {String} url the partial url (no query no hostname)
         * @param {String} noParamsExceptTenant do not add other parameters than tenant
         * @return {String} the url string post process
         */
        calculateFinalUrl: function _calculateFinalUrl(url, noParamsExceptTenant) {
            var ajaxURL = url;
            var parseURL = UWA.Utils.parseUrl(url);
            if (parseURL.protocol) {
                return ajaxURL;
            }

            ajaxURL = window.enoviaServer.computeUrl(ajaxURL);
            ajaxURL += (ajaxURL.indexOf('?') === -1) ? '?' : '&';
            var enoviaServerParams = window.enoviaServer.getParams();
            if (enoviaServerParams && enoviaServerParams.length > 0 && !noParamsExceptTenant) {
                ajaxURL += enoviaServerParams;
            } else {
                ajaxURL += 'tenant=' + window.enoviaServer.tenant;
            }

            return ajaxURL;
        },
        /**
         * makes an ajax request to the enoviaserver.
         * uses WAFData
         * @param {Object} ajaxRequestObject  an object of the form
         * {url: 'URL', type: 'post', dataType: 'json', data: 'postData', callback: 'loadTagDataDone'}
         * @param {Boolean} noParamsExceptTenant: [optional] do not add parameters to the url (except for Tenants). Special flag for retrieving cspaces
         * @return {Object}  an object with a cancel method to cancel the request if possible
         */
        ajaxRequest: function(ajaxRequestObject, noParamsExceptTenant) {
            var ajaxURL = FoundationAjax.calculateFinalUrl(ajaxRequestObject.url, noParamsExceptTenant);
            var headers = UWA.clone(ajaxRequestObject.headers || {}, false);
            !headers['Accept-Language'] && window.widget && window.widget.lang && (headers['Accept-Language'] = window.widget.lang);
            //error will be assumed to come from Foundation if the return value is valid json and if it has success == false and an error string

            var collabSpace = window.enoviaServer.space;
            if (!headers.SecurityContext &&  collabSpace &&  collabSpace.length > 0) {
              // if (this.space && this.space.length > 0) {
              //     //SC must be encoded to support special characters like +, etc.
              //     paramString += '&SecurityContext=' + encodeURIComponent(this.space);
              // }
               headers.SecurityContext =  encodeURIComponent(collabSpace);
            }
            var errorCallback = ajaxRequestObject.onFailure ||
                function(errorMsg, data) {
                    var resp = data || {};
                    if (!(resp.success === false && resp.error)) {
                        resp = {
                            error: 'Network Error: Unable to load widget due to network or authentication error.'
                        };
                    }
                    ajaxRequestObject.callback.call(this, resp);

                };
            var timeoutCallback = ajaxRequestObject.onTimeout ||
                function() {
                    ajaxRequestObject.callback.call(this, {
                        error: 'Network Error: Unable to load widget due to timeout error.'
                    });
                };
            var cancelCallback = ajaxRequestObject.onCancel ||
                function() {
                    ajaxRequestObject.callback.call(this, {
                        error: 'Application Error: Request canceled.'
                    });
                };
            //should not encode the URI as certain elements like SC is already encoded.
            //                return UWA.Data.request(ajaxURL, {
            //                    method: ajaxRequestObject.type,
            //                    type: ajaxRequestObject.dataType,
            //                    proxy: 'passport',
            //                    timeout: 500000,
            //                    cache: 3600,
            //                    data: ajaxRequestObject.data,
            //                    onComplete: ajaxRequestObject.callback,
            //                    onFailure: errorCallback,
            //                    onCancel: cancelCallback,
            //                    onTimeout: timeoutCallback,
            //                    headers: ajaxRequestObject.headers
            //                });
            var xhr = WAFData.authenticatedRequest(ajaxURL, {
                method: ajaxRequestObject.type,
                type: ajaxRequestObject.dataType,
                proxy: 'passport',
                timeout: 500000,
                cache: 3600,
                data: ajaxRequestObject.data,
                onComplete: ajaxRequestObject.callback,
                onFailure: errorCallback,
                onCancel: cancelCallback,
                onTimeout: timeoutCallback,
                headers: headers
            });
            xhr = xhr || {
                cancel: Function.prototype
            }; //bcc WAFData is not returning the xhr yet
            return xhr;

        },
        _newTempId: function() {
            // Math.random gives a number between 0 and 1 which concatenates a decimal
            //creating issues in query selector so using math floor on it
            return 'temp_' + new Date().getTime() + Math.floor((Math.random() * 10000));
        }

    };

    return FoundationAjax;

});

/*global define*/
/**
 * a module returning an object deriving from UWA/Class/Store which is meant to be used in conjunction with a 
 * remote server.
 * 
 */
define('DS/Foundation/Models/CacheStore', ['UWA/Core', 'UWA/Class', 'UWA/Class/Store', 'UWA/Utils', ], function (UWA, Class, Store, Utils) {
    'use strict';
    var CacheStore = Store.extend({
        init: function () {
            //silence the init method from our parent
            var log = UWA.log;
            UWA.log = function () {};
            this._parent.apply(this, arguments);
            UWA.log = log;
           
        },

        /**
         * sync method, mostly does the same thing as the sync method in Store but in case of local create,
         * if the object doesn't exists it will create it
         */
        sync: function (method, model, options) {
            options = options; //fool jshint
            var args = Array.prototype.slice.call(arguments, 0);
            if (method === 'update') {
                //check if the object needs to be created
                var toUpdate = this._find(model.id);
                if (!toUpdate) {
                    args[0] = 'create';
                }
            }
            this._parent.apply(this, args);
        },
        /**
         * overwrite the _insert function to not create an id when one already exists
         */
        _insert: function (attrs, idAttrName) {

            var id = attrs[idAttrName];
            if (!id) {
                id = Utils.getUUID();
                attrs[idAttrName] = id;
            }
            if (this._set(id, attrs)) {
                this._records.push(id);
                if (!this._save()) {
                    this.log('failed to insert model in cache');
                } else {
                    this.log('Successfully inserted model "{0}"', id);
                }
            }
            return this._find(id);
        }
    });
    return CacheStore;
});

/**
Utility functions for Widgets
@since 1.0
@version 1.1
@author tws
*/

/**
@module widget
*/
/*global define*/
//use the one in E6WCommonUI to avoid duplication

define('DS/Foundation/WidgetUtils', [ 'DS/E6WCommonUI/WidgetUtils'], function (WidgetUtils) {
    'use strict';
      return WidgetUtils;
});

/*
 * Configurable templates for drawing BPS widgets
 * WidgetTemplate.js
 * version 0.2
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 * WidgetTemplate Object
 * this file contains all the HTML templates for widgets
 *
 * Requires:
 * jQuery v1.6.2 or later
 *
 */
/*global WidgetEngine, WidgetPreferences, WidgetConstants*/   //need to fix circular dependencies to stop relying on globals
/*global isIFWE*/
/*global define*/

define('DS/Foundation/WidgetTemplate', ['DS/ENO6WPlugins/jQuery_3.3.1'],  //prereqs
        function (jQuery) {
    'use strict';
    var WidgetTemplate = {
        generic: function () {
            return jQuery('<div />');
        },
        list: function (obj) {
            return jQuery('<table />', {
                'id': obj.config.id,
                'class': 'simple-list',
                'width': '100%'
            }).append('<tbody />');
        },
        table: function () {
            return jQuery('<table />', {
                'class': 'table',
                'width': '100%'
            }).append('<tbody />');
        },
        listRowHeader: function () {
            return jQuery('<tr />', {
                'class': 'list-row'
            });
        },
        listRow: function (obj) {
            return jQuery("<tr />", {
                'data-type': obj.type,
                'data-objectId': obj.oid,
                'data-pid': obj.pid,
                'class': 'list-row',
                click: function (event) {
                        WidgetEngine.processSelection.call(this, event, obj.widgetId);
                       }
            });
        },
        listCellHeader: function (obj) {
            if (obj.size) {
                return jQuery('<th />', {
                    'width': obj.size
                });
            }
            return jQuery('<th />');
        },
        listCell: function (obj) {
            if (obj.size) {
                return jQuery('<td />', {
                    'width': obj.size
                });
            }
            return jQuery('<td />');
        },
        view: function (obj) {
            return jQuery('<div />', {
                'class': 'ds-group ' + obj.layout.toLowerCase()
            });
        },
        experience: function (obj) {
            var $experience = jQuery('<div />', {
                'data-name': obj.config.name,
                'class': 'experience'
            });
            if (obj.showLabel && obj.config.label) {
                var $settings = jQuery(WidgetPreferences.buildPreferences(obj)),
                    $header = jQuery('<div />', {
                        'class': 'moduleHeader'
                    }),
                    $actions = jQuery('<span />', {
                        'class': 'right-actions'
                    }),
                    sectionDir = "fonticon-down-dir";
                var $refresh = this.refresh(obj);

                if (obj.config.collapsed) {
                    $actions.hide();
                    sectionDir = "fonticon-right-dir";
                }

                $experience.append($header);
                var $span = jQuery('<span class="left-actions section-toggle" "><span class="btn fonticon ' + sectionDir + '"/></span>');
                $span[0].onclick = function () {
                    WidgetEngine.toggleSection(this);
                };
                $header.append($span); //append expand/collapse arrow.
                $header.append(jQuery('<span class="title">' + obj.config.label.text + '</span>')); //append label.
                $header.append($actions);
                $actions.append($refresh);
                $actions.append($settings);
            }
            return $experience;
        },
        location: function (obj) {
            return jQuery('<div class="iframe-container" />').height(obj.height).append(jQuery('<iframe frameborder="0" mimetype="text/html" src="' + obj.path +
                '" style="width:100%" />'));
        },
        container: function (obj) {
            return jQuery('<div />', {
                'class': obj.type
            });
        },
        group: function (obj) {
            var $group = jQuery('<div class="ds-' + obj.type + ' ' + obj.layout.toLowerCase() + '"></div>');
            return $group;
        },
        chartgroup: function (obj) {
            return jQuery('<div />', {
                'class': 'ds-group ' + obj.layout.toLowerCase() + ' ' + obj.type
            });
        },
        widget: function (obj) {
            return jQuery('<div class="ds-widget"><div class="widget-label">' + obj.type + '</div></div>');
        },
        channel: function (obj) {
            return jQuery('<div id="' + obj.config.id + '" class="' + obj.type + '"></div>');
        },
        text: function (txt, field) {
            return jQuery('<span />', {
                'field-name': field,
                html: txt
            });
        },
        textboxEditable: function (txt, field, obj) {
            var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
            editable.css("cursor", "pointer");
            WidgetEngine.addEditEvent(editable, field, obj, "textbox");
            return editable;
        },
        textareaEditable: function (txt, field, obj) {
            var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
            editable.css("cursor", "pointer");
            WidgetEngine.addEditEvent(editable, field, obj, "textarea");
            return editable;
        },
        comboboxEditable: function (txt, field, obj) {
            var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
            editable.css("cursor", "pointer");
            WidgetEngine.addEditEvent(editable, field, obj, "combo");
            return editable;
        },
        radiobuttonEditable: function (txt, field, obj) {
            var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
            editable.css("cursor", "pointer");
            WidgetEngine.addEditEvent(editable, field, obj, "radio");
            return editable;
        },
        checkboxEditable: function (txt, field, obj) {
            var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
            editable.css("cursor", "pointer");
            WidgetEngine.addEditEvent(editable, field, obj, "checkbox");
            return editable;
        },
        listboxEditable: function (txt, field, obj) {
            var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
            editable.css("cursor", "pointer");
            WidgetEngine.addEditEvent(editable, field, obj, "listbox");
            return editable;
        },
        dateEditable: function (txt, field, obj) {
            var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
            editable.css("cursor", "pointer");
            WidgetEngine.addEditEvent(editable, field, obj, "date");
            return editable;
        },
        numericEditable: function (txt, field, obj) {
            var editable = jQuery('<span class="editable-field" is-editable="true" field-name="' + field + '">' + txt + '</span>');
            editable.css("cursor", "pointer");
            WidgetEngine.addEditEvent(editable, field, obj, "numerictextbox");
            return editable;
        },
        message: function (txt) {
            return jQuery('<span />', {
                'class': 'message',
                text: txt
            });
        },
        error: function (txt) {
            if (typeof isIFWE !== "undefined" && isIFWE === true) {
                return this.container({
                    type: "ds-widget"
                }).append(this.message(txt));
            } else {
                return this.container({
                    type: "ds-widget"
                }).append(this.container({
                    type: "experience"
                }).append(this.container({
                    type: "widget-label"
                }).append(this.text(WidgetConstants.str.WidgetLabel))).append(this.message(txt)));
            }
        },
        field: function (obj) {
            return jQuery('<div />', {
                'class': (obj.config.ui && obj.config.ui.type === 'TITLE') ? 'title' : 'field'
            });
        },
        image: function (obj) {
            if ((obj.size && obj.size !== "ICON") && (obj.height && obj.height === "16px")) {
                return jQuery('<div class="image-container ' + obj.size.toLowerCase() + '" ><div class="icon-frame"><img src="' + obj.url + '" /></div></div>');
            } else {
                return jQuery('<div class="image-container ' + obj.size.toLowerCase() + '"><img src="' + obj.url + '" /></div>');
            }
        },
        badge: function (obj) {
            return jQuery('<div />', {
                'class': 'badge ' + obj.status,
                'title': obj.hovertext
            });
        },
        label: function (lbl) {
            return jQuery('<label />', {
                text: lbl
            });
        },
        progress: function (obj) {
            return jQuery('<span class="progress ' + obj.state + '"><span class="bar"><label>' + obj.percent + '%</label><span style="width:' + obj.percent +
                '%"></span></span></span>');
        },
        link: function (obj) {
            return jQuery("<a />", {
                'href': obj.url,
                'target': obj.target
            });
        },
        refresh: function (obj) {
            return jQuery('<span />', {
                'class': 'fonticon fonticon-cw',
                'title': WidgetConstants.str.Refresh,
                click: function () {
                    WidgetEngine.refresh(obj.config);
                }
            });
        }
    };
    if (typeof window !== 'undefined') {
        window.WidgetTemplate = WidgetTemplate;
    }

    return WidgetTemplate;

});

/*global define*/
/*global  WidgetConstants*/

/**
 * an object containing all the method necessary to manipulate the data models returned by Foundation services
 * list of maintenance attributes
 * ids should be by ordered : relId || physicalId || objectId || tempId
 * all ids should be indexed.
 * Client can access the basics but if it wants to find an object back reliably it should use the getId method.
 * Client should not hold on to the data object but only to the root of the structure and to the ids
 *
 * _relationshipParentObject
 * _relationship
 * _parentObject
 * _modifiedObjectList
 * _parentRecords
 * leaf
 * ...
 *
 * list of update actions
 * MODIFY : modifyObject change an existing object's attribute values
 * CREATE : addObject, addRelatedObject create a new object and add it to the hierarchy
 * DISCONNECT : disconnectObject remove an object from the hierarchy (without deleting it)
 * DELETE : deleteObject delete an object (will be removed from everywhere by the server)
 * CONNECT : connectObject, connectRelatedObject add an existing object into the hierarchy
 *
 */
//bcc ugly fix for IE compatibility
window.location.origin = window.location.origin || window.location.protocol + "//" + window.location.hostname + (window.location.port ? ':' + window.location.port : '');
define('DS/Foundation/FoundationData', [
        'UWA/Core', 'UWA/Array', 'UWA/Data', 'UWA/Storage', 'DS/ENO6WPlugins/jQuery_3.3.1', 'DS/Foundation/FoundationAjax'
    ],
    function(UWA, UWAArray, Data, Storage, jQuery, FoundationAjax) { //eslint-disable-line strict
        ''; //  workaround for a bug in yui Compressor (https://github.com/yui/yuicompressor/issues/71) 
        'use strict';
        var idNames = ["objectId", "relId", "_tempRelId", "physicalId", "tempId"];
        UWAArray = null; //to make jshint happy
        var FoundationData;
        /**
         * @private
         * compute and return a temp rel id
         */
        var __computeTempRelId = function(iObject, iUseObjectId) {
            var lParent = iObject._parentObject || iObject._relationshipParentObject;
            var lRelationship = lParent && (iObject._relationship || "children");
            if (lParent) {
                var lParentId = (lParent.tempId || lParent.relId || //line too long
                    lParent._tempRelId || FoundationData.getId(lParent)); //the case where neither relId or _tempRelId exist should be for root objects only
                //several of our algorithm for sync rely on rel id, ensure it is there
                var lChildId = FoundationData.getId(iObject);
                if (iUseObjectId) {
                    lChildId = iObject.objectId;
                }
                return lParentId + "." + lRelationship + "." + lChildId;
            }
        };

        FoundationData = {

            /**
             * returns an object containing all the field value of the dataelements of the row object
             * NOTE: does not support multivaluated field data yet
             * @param iRowObject a row object
             * @param simple optional, if true will try to return simple values instead of objects when there is no real needs
             * @return a javascript object with one property but dataelement, that property contain the corresponding field value
             */
            getFieldValues: function getFieldValues(iRowObject, simple) {
                var retValue = {};

                var hasOwn = Object.prototype.hasOwnProperty;
                for (var key in iRowObject.dataelements) {
                    if (hasOwn.call(iRowObject.dataelements, key)) {
                        retValue[key] = FoundationData.getFieldValue(iRowObject, key, true, simple);
                    }
                }
                return retValue;
            },
            /**
             * returns the relId for a rowObject
             * @param rowObject object from which you need the relId
             * @return the relId or temporary relId
             */
            getRelId: function(rowObject) {
                var relId = rowObject.relId || rowObject._tempRelId;
                if (!relId) {
                    relId = "" + new Date().getTime();
                    FoundationData._setInternalProperty(rowObject, "_tempRelId", relId);
                    //rowObject._tempRelId = relId;
                }
                return relId;
            },

            /**
             * when there is no relId on an object make one based on the parent rel id the child id and the relationship name
             */
            __makeRelId: function(iObject) {
                //var lParent = iObject._parentObject || iObject._relationshipParentObject;
                // var lRelationship = lParent && (iObject._relationship || "children");
                if (!iObject.relId) {
                    FoundationData._setInternalProperty(iObject, "_tempRelId", __computeTempRelId(iObject));
                    // iObject._tempRelId = __computeTempRelId(iObject);
                }
            },
            /**
             * returns the field value for an object.
             * @param objectData, either the dataElement of interest or a Foundation RowObject
             * @param fieldName, optional, if objectData is an object this is mandatory and is the name of the field of interest
             * @param support multiValues, optional default false if true the return is either one object or an array depending on the number of values
             * @param simple, optional default false, if true when there is no actualValue or displayValue or when they are both equals returns the
             * @return an object of the form {actualValue: XXX, displayValue: XXX} or an array of such if there are multiple values
             */
            getFieldValue: function(objectData, fieldName, supportMultiValues, simple) { //get value by field name.
                var retValue = {},
                    dataelement = objectData ? objectData.dataelements[fieldName] : null;
                if (dataelement) {
                    var values = dataelement.value;

                    if (values.length === 1 || (values.length > 0 && !supportMultiValues)) {
                        if (simple) {
                            if ((values[0].actualValue === null || typeof values[0].actualValue === 'undefined') && //line too long
                                !values[0].imageSize && !values[0].imageValue) {
                                retValue = values[0].value;
                            } else {
                                retValue.displayValue = values[0].value;
                                retValue.actualValue = values[0].actualValue;

                                // the following is the list of possible attributes in a field
                                // we may need to handle some of the other
                                //                                         <xs:attribute name="status" type="ds:status" />
                                //                                         <xs:attribute name="badgeStatus" type="ds:badgeStatus" />
                                //                                         <xs:attribute name="badgeTitle" type="ds:string" />
                                //                                         <xs:attribute name="actualValue" type="ds:string" />
                                //                                         <xs:attribute name="exportValue" type="ds:string" />
                                //                                         <xs:attribute name="sortValue" type="ds:string" />
                                //                                         <xs:attribute name="printValue" type="ds:string" />
                                //                                         <xs:attribute name="imageValue" type="ds:string" />
                                //                                         <xs:attribute name="imageSize" type="ds:imageSize" />
                                //                                         <xs:attribute name="urlValue" type="ds:string" />
                                //                                         <xs:attributeGroup ref="ds:colorPreference"></xs:attributeGroup>
                                //                                         <xs:attribute name="prevDisplay" type="ds:string" />
                                //                                         <xs:attribute name="prevActual" type="ds:string" />
                                if (values[0].imageSize) {
                                    retValue.imageSize = values[0].imageSize;
                                }
                                if (values[0].imageValue) {
                                    retValue.imageValue = values[0].imageValue;
                                }
                            }
                        } else {
                            retValue.displayValue = values[0].value;
                            retValue.actualValue = values[0].actualValue;
                            if (values[0].imageSize) {
                                retValue.imageSize = values[0].imageSize;
                            }
                            if (values[0].imageValue) {
                                retValue.imageValue = values[0].imageValue;
                            }
                        }
                    } else if (supportMultiValues && values.length > 1) {
                        retValue = [];
                        for (var lCurValueIdx = 0; lCurValueIdx < values.length; lCurValueIdx++) {
                            retValue.push({
                                displayValue: values[lCurValueIdx].value,
                                actualValue: values[lCurValueIdx].actualValue
                            });
                        }
                    }
                }
                return retValue;
            },
            /**
             * utility method to merge two objects
             * this is used to treat the return values from the server.  The client side data is overwritten except if it contains pending changes.
             * @param target  target to merge with source.  Attributes will be overwritten if they do not have pending changes
             * @param source  object to copy data from.  This is normally a return value from the server.
             */
            appendFieldData: function(target, source, hidden) { //combine field data.
                for (var key in source.dataelements) {
                    if (source.dataelements.hasOwnProperty(key)) {
                        var dataToOverwrite = FoundationData.getFieldData(key, target);
                        if (dataToOverwrite && dataToOverwrite[0]) {
                            if ((dataToOverwrite[0].pendingActual !== undefined && dataToOverwrite[0].pendingActual !== dataToOverwrite[0].actualValue) || //pending (in flight) modification
                                //exists for actual value
                                (dataToOverwrite[0].pendingDisplay !== undefined && dataToOverwrite[0].pendingDisplay !== dataToOverwrite[0].value) || //pending (in flight) modification
                                //exists for display value
                                (dataToOverwrite[0].prevActual !== undefined && dataToOverwrite[0].prevActual !== dataToOverwrite[0].actualValue) || //unsaved modification exists for actual value
                                (dataToOverwrite[0].prevDisplay !== undefined && dataToOverwrite[0].prevDisplay !== dataToOverwrite[0].value)) { //unsaved modification exists for displayValue
                                //case where the field was modified locally since the call to the server, don't overwrite
                                continue;
                            }
                        }
                        if (hidden) {
                            FoundationData._setInternalProperty(target.dataelements, key, source.dataelements[key]);
                        } else {
                            target.dataelements[key] = source.dataelements[key];
                        }
                    }
                }

            },
            /**
             * makes a Foundation webservice call asynchronously.
             * @param widgetName the name of the service to call.  Each service is defined by a page on the server.
             * @param callback the function which will be called once the service is loaded.
             * Only the first element of the widgets property will be passed in.
             * @return an object with a cancel method
             */
            loadWidget: function(widgetName, callback, isPost, postData, headers) { //loads widget from server asynchronously.
                var thisRequest = {
                    callbackFunction: callback
                };
                //     var that = this;
                var tempURI = this._serviceURL || this.tempURI || FoundationData.tempURI;
                var buildIndexCache = this.__buildIndexCache || FoundationData.__buildIndexCache;
                var request = {
                    url: tempURI(widgetName), //use this so it is either FoundationV2 or V1
                    type: isPost ? 'post' : 'get',
                    dataType: 'json',
                    callback: function(data) {
                        if (!data.success) {
                            var strError = data.error;
                            //                        strError = WidgetConstants.str[strError] || WidgetConstants.str["NetworkError"] || data.error;
                            console.error(strError + " :: " + widgetName);
                        }
                        buildIndexCache(data);
                        thisRequest.callbackFunction.call(this, data);
                    }
                };
                if (postData) {
                    request.data = postData;
                    request.headers = {
                        "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
                    };
                }
                if (headers) {
                    request.headers = request.headers || {};
                    UWA.extend(request.headers, headers);
                }
                return this.ajaxRequest(request);
            },
            /**
             * save into the local storage a cached value for a widget call.
             * @param the storage to save from (instance of UWA/Storage)
             * @param widgetName the name of the service which has been called.
             */
            saveCachedData: function(storage, widgetName, data) {

                try {

                    var widgetToSave = storage.safeStore(data);
                    storage.set(widgetName, widgetToSave);
                } catch (e) {
                    console.error(e); //usually quota exceeded exception
                }
            },
            /**
             * retrieve from the local storage a cached value for a widget call.
             * @param the storage to load from (instance of UWA/Storage)
             * @param widgetName the name of the service to call.  Each service is defined by a page on the server.
             * @return the saved data
             */
            loadCachedData: function(storage, widgetName) { //loads widget from server asynchronously.
                return storage.safeResurrect(storage.get(widgetName));
            },
            /**
             * retrieve the values (an array) of an attribute for an object.
             * @param itemConfig a javascript object with a property name or a string which is the name
             * @param objectData a foundation object
             * @return the values for the field itemConfig.name in objectData
             */
            getFieldData: function(itemConfig, objectData) {
                var lItemConfig = UWA.typeOf(itemConfig) === 'string' ? {
                    name: itemConfig
                } : itemConfig;
                var values = null;
                var dataelement = this.getDataElement(lItemConfig, objectData);
                if (dataelement) {
                    values = dataelement.value;
                }
                return values;
            },
            /**
             * retrieve list of data element
             */
            /**
             * retrieve a data element for an object.
             * dataelement is a field wrapper, it contains the name of the field its values
             * @param itemConfig  a javascript object with a property "name" or the string directly
             * @param objectData  a foundation object
             * @return the dataElement with the name itemConfig.name in objectData
             */
            getDataElement: function(itemConfig, objectData) {
                if (!objectData || !objectData.dataelements) {
                    return null;
                }
                var fieldName = UWA.is(itemConfig, "string") ? itemConfig : itemConfig.name;
                var dataelement = objectData.dataelements[fieldName];
                return dataelement;
            },
            /**
             * retrieve the children (potentially recursively) of an object.
             * @param parentObj the object to retrieve the children from
             * @param args and object of the form
             * {checkFiltered: (true)/false, allLevels: true/(false), fixedLevels: true/(false)}
             *         checkFiltered  default true, if set to true objects which are flagged as filtered will not be returned (nor their descendant)
             *         allLevels default true, if set to true all the descendants (not just first level children) will be returned
             *         fixedLevels:  default false unclear
             * @return an array of children (or descendant) of parentObj
             */
            getChildren: function(parentObj, args /* {checkFiltered: (true)/false, allLevels: true/(false), fixedLevels: true/(false)} */ ) { //get object children
                var checkFiltered = true,
                    allLevels = false,
                    fixedLevels = false,
                    subItems = [],
                    objects = parentObj.children;

                if (typeof args === "object") {
                    checkFiltered = args.checkFiltered ? args.checkFiltered : checkFiltered;
                    allLevels = args.allLevels;
                    fixedLevels = args.fixedLevels;
                }
                if (objects && objects.length > 0) {
                    for (var i = 0; i < objects.length; i++) {
                        var object = objects[i];
                        if (checkFiltered === false || !object.filtered) {
                            //FoundationData._setInternalProperty(object, "_parentObject", parentObj);  //bcc: should be already done in the iterateOverDatastructure which is called
                            // in loadWidget among other places
                            //object._parentObject = parentObj;
                            subItems.push(object);
                            if (allLevels) {
                                var children = FoundationData.getChildren(object, args);
                                subItems = subItems.concat(children);
                            }
                        }
                    }
                } else if (fixedLevels) {
                    parentObj.leaf = true;
                }
                return subItems;
            },
            /**
             * get a related object with a given id from its parent.
             * note that if an id is passed for the parent it will only be found if it could be found by getObject
             * @param inMemoryData the in memory data structure
             * @param relationship the name of the relationship to follow
             * @param node_parent either the id or the object
             * @param id id of the object to find
             * @return the row object related to nodeParent with id
             */
            getRelatedObject: function(inMemoryData, relationship, nodeParent /*id or object*/ , id) {
                var containerType = null,
                    checkFiltered = true,
                    allLevels = true,
                    parentObject = this.getObject(inMemoryData, nodeParent),
                    rows = this.getContainerData({
                        name: relationship
                    }, containerType, parentObject, checkFiltered, allLevels),
                    relatedObject = FoundationData.__findObject(rows, id);
                if (relatedObject) {
                    // relatedObject._relationship = relationship;
                    FoundationData._setInternalProperty(relatedObject, "_relationshipParentObject", parentObject);
                    FoundationData._setInternalProperty(relatedObject, "_relationship", relationship);
                    //relatedObject._relationshipParentObject = parentObject;
                }
                return relatedObject;
            },
            /**
             * retrieves an object.
             * an object can be passed in which case it will be returned as is.  This is convenient to implement methods which take as an
             * input either an object or its id.  Just start by calling getObject.
             * The id can be objectId, physicalId, relId or tempId
             * note that all objects cannot be found by id. Only those which are in the return of getContainerData
             * @param inMemoryData the in memory data structure
             * @param id the id of the object to find
             */
            getObject: function(inMemoryData, id /*id or object*/ ) {
                if (!id) {
                    return null;
                } else if (typeof id === "object") {
                    return id;
                }
                if (inMemoryData._indexCache) {
                    var retVal = inMemoryData._indexCache[id];
                    if (retVal) { //not needed when the index is correctly kept up to date by sync
                        return retVal;
                    }
                }
                var containerType = null,
                    objectData = null,
                    checkFiltered = true,
                    allLevels = true,
                    rows = this.getContainerData(inMemoryData, containerType, objectData, checkFiltered, allLevels);
                return FoundationData.__findObject(rows, id);

            },
            /**
             * Calculate final URL with params etc.
             * @param {String} url the partial url (no query no hostname)
             * @param {String} noParamsExceptTenant do not add other parameters than tenant
             * @return {String} the url string post process
             */
            calculateFinalUrl: FoundationAjax.calculateFinalUrl,
            /**
             * makes an ajax request to the enoviaserver.
             * uses jQuery or UWA as necessary
             * @param {Object} ajaxRequestObject  an object of the form
             * {url: 'URL', type: 'post', dataType: 'json', data: 'postData', callback: 'loadTagDataDone'}
             * @param {Boolean} noParamsExceptTenant: [optional] do not add parameters to the url (except for Tenants). Special flag for retrieving cspaces
             * @return {Object}  an object with a cancel method to cancel the request if possible
             */
            ajaxRequest: function(ajaxRequestObject, noParamsExceptTenant) {
                if (window.isIFWE) {
                    return FoundationAjax.ajaxRequest.apply(FoundationAjax, arguments);
                } else {
                    var ajaxURL = FoundationData.calculateFinalUrl(ajaxRequestObject.url, noParamsExceptTenant);
                    var headers = UWA.clone(ajaxRequestObject.headers || {}, false);
                    !headers['Accept-Language'] && window.widget && window.widget.lang && (headers['Accept-Language'] = window.widget.lang);
                    var jQueryRequest = jQuery.ajax({
                        url: ajaxURL,
                        type: ajaxRequestObject.type,
                        dataType: ajaxRequestObject.dataType,
                        data: ajaxRequestObject.data,
                        success: ajaxRequestObject.callback,
                        error: function( /*data*/ ) {
                            ajaxRequestObject.callback.call(this, {
                                error: 'Network Error: Unable to load widget due to network or authentication error.'
                            });
                        },
                        cache: false
                    });
                    var ret = {
                        cancel: function() {
                            return jQueryRequest.abort();
                        }
                    };
                    return ret;
                }
            },
            /**
             * retrieve the most pertinent id for an object.
             * in order either the physicalid, objectid or tempid.
             * Note that it should really never return the objectId so I don't know of a case where we would have an objectid and no physicalid
             * @param rowObject
             *          the object
             * @return a string to be used as id for the object
             */
            getId: function(rowObject) {
                return rowObject.physicalId || rowObject.objectId || rowObject.tempId;
            },

            /**
             * Save changes to the database.
             * if a modification is dependant on a previously pending modification, we will wait for the reply by the server before sending a new save request.
             * @param inMemoryData  the data to be saved
             * @param callback a callback function to be called once the server replied
             * @param showError a boolean if true errors will be displayed as alert if false they will not
             * @param saveId to only save one object out of the modified objects in the data
             */
            applyUpdates: function(inMemoryData, callback, showError, saveId) {
                if (!inMemoryData._modifiedObjectList) { //nothing modified, nothing to do
                    if (typeof callback === 'function') {
                        callback.call(this, false, {
                            error: "nothing to save"
                        });
                    }
                    return;
                }

                var modifiedObjectList = inMemoryData._modifiedObjectList;
                //start a new list after each apply.
                delete inMemoryData._modifiedObjectList;

                //prepare message containing updated objects and their context to be sent to the server.
                var modifiedInfo = FoundationData.__generateUpdateWidget(inMemoryData, modifiedObjectList, saveId);

                if (!modifiedInfo) { //case when the currently modified objects are dependent on a pending update.
                    if (!inMemoryData._pendingUpdates) {
                        FoundationData._setInternalProperty(inMemoryData, "_pendingUpdates", []);
                        //inMemoryData._pendingUpdates = [];
                    }
                    //mark the _updateActionStatus of all objects in this batch as queued
                    FoundationData.__changeUpdateActionStatusForBatch(modifiedObjectList, "QUEUED");
                    inMemoryData._pendingUpdates.push({
                        _modifiedObjectList: modifiedObjectList,
                        _callback: callback,
                        _showError: showError,
                        _saveId: saveId
                    });
                    return; //data not ready to be saved.
                }
                var updateWidget = modifiedInfo.updateWidget;
                var widgetPostData = "updateWidget=" + encodeURIComponent(JSON.stringify(updateWidget));

                var thisRequest = {
                    showError: showError,
                    callbackFunction: callback
                };

                //callback
                var applyUpdatesDone = function(data) {
                    if (!data.success) {
                        if (showError) {
                            alert(data.error);
                        }
                        //     if (typeof data.widgets === "undefined") { //TODO this is not a good test anymore, widgets is not part of the answers in some cases
                        if (typeof data.datarecords === "undefined") { //TODO this is not a good test anymore, widgets is not part of the answers in some cases
                            //case of a network error, we will remove the PENDING status on the objects
                            //which failed to be updated and we will add them back to the _modifiedObjectList
                            if (!inMemoryData._modifiedObjectList) {
                                FoundationData._setInternalProperty(inMemoryData, "_modifiedObjectList", []);
                                //inMemoryData._modifiedObjectList = [];
                            }
                            var clonedObjects = modifiedInfo.clonedObjects;
                            var hasOwn = Object.prototype.hasOwnProperty; //shortcut
                            for (var key in clonedObjects) {
                                if (hasOwn.call(clonedObjects, key)) {
                                    var clonedObject = clonedObjects[key];

                                    if (clonedObject.item.updateAction !== undefined) { //we check the updateActionPending on item which is what was sent to the server
                                        //with this batch.  In case where this object was in fact just context
                                        if (!clonedObject.source.updateAction || //line too long
                                            (clonedObject.source.updateAction === "MODIFY" && clonedObject.item.updateAction === "CREATE") || //line too long
                                            (clonedObject.source.updateAction === "MODIFY" && clonedObject.item.updateAction === "MODIFY") || //line too long
                                            clonedObject.item.updateAction === 'DISCONNECT' || clonedObject.item.updateAction === 'DELETE') { //it could have
                                            //been modified afterward and have pending for another queued modification.
                                            //however this should work for most case (if you modify after a create or if you modify after a modify it works.
                                            //Things will get lost when delete, connect or disconnect are involved.  But we are already in a fringe case.
                                            clonedObject.source.updateAction = clonedObject.item.updateAction;
                                        } else {
                                            throw "Network error and pending modifications";
                                        }
                                        delete clonedObject.source.updateActionPending;
                                        delete clonedObject.source._updateActionStatus;
                                        var parentObject = clonedObject.source._parentObject; //BCC: there could be cases where this is incorrectly not set we can't do much though
                                        FoundationData.__addToModifiedList(inMemoryData, parentObject, clonedObject.source);
                                        //    inMemoryData._modifiedObjectList.push(clonedObject.source);
                                    }
                                }
                            }
                        }
                    }
                    if (data.success || data.datarecords) { //bcc: I think the second condition is sufficient
                        //copy ids of newly created objects.
                        if (data.success) {
                            FoundationData.__synchronizeInMemoryDataWithServerReturn(inMemoryData, data, modifiedInfo.clonedObjects);


                        } else {
                            FoundationData.__postprocessServerFailureMessage(inMemoryData, data.datarecords, updateWidget.datarecords, modifiedInfo.clonedObjects, data.success);
                        }
                        inMemoryData.datarecords.csrf = data.datarecords.csrf;
                    }

                    if (thisRequest.callbackFunction) {
                        try {
                            thisRequest.callbackFunction.call(this, data.success, data, modifiedInfo.clonedObjects);
                        } catch (err) {
                            console.error(err.message);
                        }
                    }

                    //process pending updates.
                    //WARNING if we have somethings in the _modifiedObjectList which can happen in case of a network error (see above), it will be lost.
                    //However in that case chances are we will get another network error immediately
                    if (inMemoryData._pendingUpdates) {
                        var pendingUpdates = inMemoryData._pendingUpdates;
                        delete inMemoryData._pendingUpdates;
                        for (var i = 0; i < pendingUpdates.length; i++) {
                            FoundationData._setInternalProperty(inMemoryData, "_modifiedObjectList", pendingUpdates[i]._modifiedObjectList);
                            //inMemoryData._modifiedObjectList = pendingUpdates[i]._modifiedObjectList;
                            //reset the status of the current batch since we pulled them from the queue to recheck dependencies
                            FoundationData.__changeUpdateActionStatusForBatch(inMemoryData._modifiedObjectList, null);
                            FoundationData.applyUpdates(inMemoryData, pendingUpdates[i]._callback, pendingUpdates[i]._showError, pendingUpdates[i]._saveId);
                        }
                    }
                };

                FoundationData.ajaxRequest({
                    url: "/resources/e6w/service",
                    type: 'POST',
                    data: widgetPostData,
                    dataType: 'json',
                    callback: applyUpdatesDone,
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
                    }
                });
            },

            /**
             * mark a related object as deleted.
             * this is a shortcut to call getRelatedObject and deleteObject.  See this methods for documentation
             */
            deleteRelatedObject: function(inMemoryData, relationship, parent /*id or object*/ , id) {
                var object = FoundationData.getRelatedObject(inMemoryData, relationship, parent, id);
                return FoundationData.deleteObject(inMemoryData, object);
            },
            /**
             * returns true if an object has updates to be applied to the server marked on it.
             * this indicates that the server hasn't confirmed the updates yet.  They could have been sent already or not.
             */
            isDirty: function(rowObject) {
                var dirty = false;
                if (rowObject && rowObject.updateAction) {
                    dirty = true;
                }
                return dirty;
            },
            /**
             * mark an object to be deleted.
             * the delete will be applied during the next applyUpdates
             * @param inMemoryData the in memory datastructure
             * @param iToDelete the object (or its id) to delete.
             * @return the object to be deleted
             */
            deleteObject: function(inMemoryData, iToDelete /*id or object*/ ) {
                var object = FoundationData.getObject(inMemoryData, iToDelete);
                var lUpdateAction = object.updateAction;
                object.updateAction = "DELETE";
                if (!lUpdateAction) {
                    FoundationData.__addToModifiedList(inMemoryData, null, object);
                }
                var lRelationship = iToDelete._relationship;
                if (!lRelationship && iToDelete._parentObject) {
                    lRelationship = "children";
                }

                if (lRelationship) {
                    var lParentObject = iToDelete._relationshipParentObject || iToDelete._parentObject;
                    if (lParentObject._mvcModel) {
                        lParentObject._mvcModel._fireRelationshipChangeEvents(lRelationship, {});
                    }
                }
                return object;
            },
            /**
             * cancel pending changes on an object.
             * This will cancel the changes that have not yet been committed to the server.
             * An exception is thrown if there are changes that have already been sent to the server but not acknowledged yet
             * @param inMemoryData the in memory data structure
             * @param iToCancel the object or its id.  Note that if an id is used it will only work on first level object
             */
            cancelObject: function(inMemoryData, iToCancel /*id or object*/ ) {
                var object = FoundationData.getObject(inMemoryData, iToCancel);
                if (object._updateActionStatus === "PENDING") {
                    throw ("cannot cancel changes on this objects they have already been sent to the server");
                }
                //cleanup
                var updateAction = object.updateAction || object.updateActionPending || object.updateActionFailed;
                if (updateAction === "MODIFY") {
                    FoundationData.__deletePrevValues(object, true);
                } else if (updateAction === "CREATE" || updateAction === "CONNECT") {
                    FoundationData.__deleteObject(inMemoryData, object);
                }
                delete object.updateAction;
                delete object.updateActionPending;
                delete object.updateActionFailed;
                delete object._updateActionStatus;

            },
            /**
             * rollback an object.
             * changes marked with updateActionFailed will be rolled back.
             * If a newer change was made (if there is an updateAction) the object may or may not be rolledback.
             *
             * in case of
             *  updateActionFailed: CREATE   ==> everything is rolledback
             *  updateActionFailed: DELETE   ==> everything is rolledback (and there really shouldn't be any udpateAction)
             *  updateActionFailed: MODIFY   ==> rollback if updateAction is not MODIFY if it is the case no rollback just keep all changes and remove the updateActionFailed
             *  updateActionFailed: DISCONNECT ==> rollback
             *  updateActionFailed: CONNECT ==> rollback
             *
             * @param inMemoryData the data to rollback
             */
            rollbackFailedObject: function(inMemoryData, iRowObject) {

                //cleanup
                var updateAction = iRowObject.updateActionFailed;

                switch (updateAction) {
                    case "CONNECT":
                    case "CREATE":
                        FoundationData.__deleteObject(inMemoryData, iRowObject);
                        break;
                    case "MODIFY":
                        if (iRowObject.updateActionPending !== "MODIFY" && iRowObject.updateAction !== "MODIFY") {
                            FoundationData.__deletePrevValues(iRowObject, true);
                        }
                        break;
                    case "DELETE":
                    case "DISCONNECT":
                        //not much to do really apart from removing the flag
                        break;
                }
                //fire mvc event if necessary
                if (updateAction === "CONNECT" || updateAction === "CREATE" || updateAction === "DELETE" || updateAction === "DISCONNECT") {
                    var parentObject = iRowObject._parentObject || iRowObject._relationshipParentObject;
                    parentObject && parentObject._mvcModel && parentObject._mvcModel._fireRelationshipChangeEvents(iRowObject._relationship || "children");

                }
                delete iRowObject.updateActionFailed;
                delete iRowObject.updateMessage;
            },
            /**
             * rollback any data marked with an updateActionFailed.
             * this will remove the marking and cancel the updateActionFailed on the object.
             * see rollbackFailedObject for the details about what will be rolled back exactly
             * @param inMemoryData the data to rollback
             * @param iForce if true force the rollback of objects modified since they faileed
             */
            rollbackFailedData: function(inMemoryData) {
                FoundationData.iterateOverDataStructure(inMemoryData, function(iObject) {
                    FoundationData.rollbackFailedObject(this, iObject);
                });
            },
            /**
             * modify a related object.
             * finds a related object then modify it.  See modifyObject and getRelatedObject
             */
            modifyRelatedObject: function(inMemoryData, relationship, parent /*id or object*/ , id, updatedFields /* [{name: "owner", value: {displayValue: "value", actualValue: "value"}},]*/ ) {
                var object = null;
                if (typeof id === "object") {
                    object = id;
                } else {
                    object = FoundationData.getRelatedObject(inMemoryData, relationship, parent, id);
                }
                FoundationData.modifyObject(inMemoryData, object, updatedFields);
            },
            /**
             * Modify an object.
             * The previous values will be stored on the object for cancelation purpose until the change is confirmed by the server.
             * Note that multiple value fields are not supported
             * TODO need to take into account the case of a PENDING modification
             * @param inMemoryData the in memory data structure
             * @param iToModify object to modify, can be an id but only for first level objects
             * @param updateFields the information about the fields to modify.  Non existing fields will be created if necessary.
             *                      the format for fields should be:
             *                      [{name: "owner", value: {displayValue: "value", actualValue: "value"}},]
             * @return the modified rowObject
             */
            modifyObject: function(inMemoryData, iToModify /*id or object*/ , updatedFields) {
                var object = FoundationData.getObject(inMemoryData, iToModify);
                if (!object) {
                    return;
                }
                var dependency;
                //bcc: let's only make change if something is different from what we currently have
                var reallyChangedSomething = false;
                //in case the object has some modifications which are in flight (updateActionPending)
                //we will need to store the actual value of those attribute which have a previous value
                //to a third property: pendingValue
                for (var i = 0; i < updatedFields.length; i++) {
                    dependency = undefined;
                    var field = updatedFields[i];
                    if (field.value === null || typeof field.value === "undefined") {
                        field.value = {
                            actualValue: ""
                        };
                    }
                    if (typeof field.value.actualValue === "object") {
                        dependency = field.value.actualValue;
                        field.value.actualValue = FoundationData.getId(dependency);
                        delete field.value.displayValue; //no good value today
                    }
                    var currentvalues = FoundationData.getFieldData(field, object);
                    if (!currentvalues || currentvalues.length === 0) {
                        //add an empty value object to hold the multiple values.
                        currentvalues = [{}];
                        object.dataelements[field.name] = {
                            value: currentvalues
                        };
                        reallyChangedSomething = true; //bcc: I know this is an approximation,
                        //the field could also be undefined but this would be pushing it
                    }
                    if (field.value.displayValue !== undefined && field.value.displayValue !== currentvalues[0].value) { //need to handle multi-value scenarios.
                        if (currentvalues[0].prevDisplay === undefined) {
                            currentvalues[0].prevDisplay = currentvalues[0].value || "";
                        } else {
                            //check if we have changes pending a return from the server
                            if (object.updateActionPending) {
                                currentvalues[0].pendingDisplay = currentvalues[0].value || "";
                            }
                        }
                        currentvalues[0].value = field.value.displayValue;
                        reallyChangedSomething = true;
                    }
                    if (field.value.actualValue !== undefined && field.value.actualValue !== currentvalues[0].actualValue) { //need to handle multi-value scenarios.
                        if (currentvalues[0].prevActual === undefined) {
                            currentvalues[0].prevActual = currentvalues[0].actualValue || "";
                        } else {
                            //check if we have changes pending a return from the server
                            if (object.updateActionPending) {
                                currentvalues[0].pendingActual = currentvalues[0].actualValue || "";
                            }
                        }
                        currentvalues[0].actualValue = field.value.actualValue;
                        reallyChangedSomething = true;
                    }
                    if (dependency) {
                        FoundationData._setInternalProperty(currentvalues[0], "_dependency", dependency);
                        //currentvalues[0]._dependency = dependency;
                        object.dataelements[field.name].isDependency = true;
                    }
                }

                if (reallyChangedSomething && object.updateAction === undefined) {
                    object.updateAction = "MODIFY";
                    FoundationData.__addToModifiedList(inMemoryData, null, object);
                }
                return object;
            },
            /**
             * Disconnect an object.
             * mark an object (so a branch of the tree) for removal.  The actual removal happens when applyUpdates is called.
             * Only works for children can be disconnected. Use disconnectRelatedObject for relatedData.
             * a prereq for this to work is that the _parentObject backpointer has been computed (usually by iterateOverDataStructure when computing the index)
             * @param inMemoryData the in memory data structure
             * @param iToDisconnect either the object to disconnect or an id (relId, objectId, ...).
             *      Note that if an id is passed only the first level objects can be disconnected so relId may not work
             */
            disconnectObject: function(inMemoryData, iToDisconnect /* object or relId or objectId*/ ) {
                var childObject = FoundationData.getObject(inMemoryData, iToDisconnect);
                if (!childObject || !childObject._parentObject || !childObject.relId) {
                    throw new Error("Invalid ID for disconnection.");
                }
                FoundationData.__disconnectObject(inMemoryData, childObject);
            },
            /**
             * Disconnect a related object.
             * mark an object (so a branch of the tree) for removal.  The actual removal happens when applyUpdates is called.
             * Only works on relatedData use disconnectObject for children
             * @param inMemoryData the in memory data structure
             * @param iToDisconnect either the object to disconnect or an id (relId, objectId, ...).
             *      Note that if an id is passed only the first level objects can be disconnected so relId may not work
             * @param iParentObject optional.  When an object is related to several parents, it may not be advisable to rely on _relationshipParentObject or on relId.
             *        in this case it is safer for the clien to provide the explicit parent object which should be disconnected.
             * @param iRelationship optional.  When an object is related to several parents, potentially with several relationships,
             *                                 it is preferable to provide the explicit relationship to be disconnected
             *
             */
            disconnectRelatedObject: function(inMemoryData, iToDisconnect /* object or relId or objectId*/ , iParentObject, iRelationship) {
                var childObject = FoundationData.getObject(inMemoryData, iToDisconnect);
                var lParentObject = iParentObject || childObject._relationshipParentObject;
                var lRelationship = iRelationship || childObject._relationship;
                if (!childObject || !lParentObject) {
                    throw (new Error("Invalid ID for disconnection."));
                }

                FoundationData.__disconnectObject(inMemoryData, childObject, lParentObject, lRelationship);
            },
            /**
             * connects an existing object (based on an object id or physical id ) to the in memory structure.
             * a new object placeholder is created, attributes will only be available after applyUpdates (except for those provided in fields).
             * If fields are provided id can be null in this case the fields will be used to build a where clause.  If the id is provided the fields
             * will be ignored by the back end but can be used in the front end while it is waiting for the server refresh
             * @param inMemoryData the in memory data structure
             * @parem relationship the name of the relationship to use
             * @param parent id or object where to insert the existing object
             * @param id  id of the object to connect (typically comming from a search) or object (case where the object is attached again, typically
             *                                                                                      we got information about this object from a different service call)
             * @param fields array of objects of the following format:
             *                      [{name: "owner", value: {displayValue: "value", actualValue: "value"}},]
             *                      those are attributes which will be set on the object they typically come from a form filled in by the user
             *                      they will be used to build a where clause to find the object to attach in case of no id
             * @param index where to insert it
             */
            connectRelatedObject: function(inMemoryData, relationship, parent /*id or object*/ , child /* child id or object*/ , fields, index) {
                var lFields = fields ? fields : [];
                var lChild = child;
                var parentObject = FoundationData.getObject(inMemoryData, parent);
                var lId;
                if (UWA.is(lChild, "object")) {
                    //if the object is not attached to a structure, attach it.  If it is already attached somewhere else create a new object and update the ids
                    if (lChild._relationshipParentObject || lChild._parentObject || lChild._parentRecords) {
                        var lNewChild = FoundationData.__newObject(lFields);
                        lNewChild.objectId = lChild.objectId;
                        lNewChild.physicalId = lChild.physicalId;
                        lNewChild.tempId = lChild.tempId;
                        lChild = lNewChild;
                    }
                } else { //child is either a string (the id) or undefined or null
                    lId = child;
                    lChild = FoundationData.__newObject(lFields);
                    lChild.physicalId = lId; //set the physicalId
                    lChild.objectId = lId; //also set the objectId the passed in id should be one of them
                }
                if (!parentObject || !relationship) {
                    throw new Error("Relationship, parent and child IDs are required for connection.");
                }
                FoundationData.__connectObject(inMemoryData, relationship, parentObject, lChild, index);
                return lChild;
            },
            /**
             * connects an existing object (based on an object id or physical id ) to the in memory structure as a relatedObject.
             * a new object placeholder is created, attributes will only be available after applyUpdates (except for those provided in fields).
             * @param inMemoryData the in memory data structure
             * @param parent id or object where to insert the existing object
             * @param id  id of the object to connect (typically comming from a search)
             * @param fields array of objects of the following format:
             *                      [{name: "owner", value: {displayValue: "value", actualValue: "value"}},]
             *                      those are attributes which will be set on the object they typically come from a form filled in by the user
             * @param index where to insert it
             */
            connectObject: function(inMemoryData, parent /*id or object*/ , id /* child id*/ , fields, index) {
                var lFields = fields ? fields : [];
                var newObject = FoundationData.__newObject(lFields),
                    parentObject = FoundationData.getObject(inMemoryData, parent);
                newObject.objectId = id;
                if (!parentObject || !newObject.objectId) {
                    throw ("Parent and child IDs are required for connection.");
                }
                FoundationData.__connectObject(inMemoryData, null, parentObject, newObject, index);
                return newObject;
            },
            /**
             * adds a an object to the structure as a child object.
             * The object is temporary until applyUpdates is called
             * @param inMemoryData the in memory data structure
             * @param parent, id or parent object on which to attach the new object.
             * @param fields array of objects of the following format:
             *                      [{name: "owner", value: {displayValue: "value", actualValue: "value"}},]
             *                      those are attributes which will be set on the object they typically come from a form filled in by the user
             * @param index, optional where to insert the new object
             * @return the newly created object
             */
            addObject: function(inMemoryData, parent /*id or object*/ , fields, index) {
                var newObject = FoundationData.__newObject(fields),
                    parentObject = FoundationData.getObject(inMemoryData, parent);
                FoundationData.__addObject(inMemoryData, undefined, parentObject, newObject, index);
                return newObject;

            },

            /**
             * adds a an object to the structure as a related object.
             * @param inMemoryData the in memory data structure
             * @param relationship, mandatory (use addObject if you don't have a relationship and you want to add a child. The name of the relationship to use to add the object.
             * @param parent, id or parent object on which to attach the new object.   Beware that passing an id might fail as of today only first level objects are reliably found by Id
             * @param fields array of objects of the following format:
             *                      [{name: "owner", value: {displayValue: "value", actualValue: "value"}},]
             *                       those are attributes which will be set on the object they typically come from a form filled in by the user
             * @param index, optional where to insert the new object
             * @param iMVCModel, optional mvcModel which will have to be updated prior to firing events
             * @return the newly created object
             */
            addRelatedObject: function(inMemoryData, relationship, parent /*id or object*/ , fields /* [{name: "owner", value: {displayValue: "value", actualValue: "value"}},]*/ , index,
                iMVCModel) {
                if (!relationship) {
                    throw ("a relationship should be specified");
                }
                var newObject = FoundationData.__newObject(fields),
                    parentObject = FoundationData.getObject(inMemoryData, parent);
                FoundationData.__addObject(inMemoryData, relationship, parentObject, newObject, index, iMVCModel);
                return newObject;
            },
            /**
             * retrieves an array corresponding to the relateddata of this object for a given relation name.
             * also set correctly the _relationshipParentObject and _relationshipParentObject
             * @param iObject  the object
             * @param iRel the name of the relation
             * @return empty array or the corresponding relateddata
             */
            getRelatedObjects: function getRelatedObjects(iObject, iRel) {
                if (iObject && iRel && iObject.relateddata && iObject.relateddata[iRel] && iObject.relateddata[iRel].datagroups) {
                    var lRet = iObject.relateddata[iRel].datagroups;
                    lRet.forEach(function(element) {
                        FoundationData._setInternalProperty(element, "_relationshipParentObject", iObject);
                        //element._relationshipParentObject = iObject;
                        FoundationData._setInternalProperty(element, "_relationship", iRel);
                        //   element._relationship = iRel;
                    });
                    return lRet;
                } else {
                    return [];
                }

            },
            /**
             * retrieves the list of names for related data for a given object.
             * @param iObject object you want to get the relateddata names for
             * @return arrays of name
             */
            getRelatedDataNames: function getRelatedDataNames(iObject) {
                if (!iObject.relateddata) {
                    return [];
                }

                var keys = Object.keys(iObject.relateddata);
                return keys;
            },
            /**
             * remove root objects from the in memory data structure.
             *
             * This will throw an exception if there are pending modifications on the objects to remove
             */
            //TODO make it work when there are pending modifications
            unloadObjects: function(inMemoryData, idList /* list of ids or objects*/ ) {
                var i, id, object, index, rows = inMemoryData.datarecords.datagroups;
                //check if there are any pending modifications in the tree to be removed.
                //first we put all our ids in a hash.
                var lIdH = {};
                idList.forEach(function(element) {
                    lIdH[element] = element;
                });
                //now check the modified list
                var modifiedlist = inMemoryData._modifiedObjectList;
                if (modifiedlist) {
                    modifiedlist.forEach(function(element) {
                        var modifiedObject = element.child;
                        var lIsInList = {
                            inList: false
                        };
                        FoundationData.eachAncestor(modifiedObject, function() {
                            if (lIdH[this.objectId] || lIdH[this.physicalId] || lIdH[this.tempId]) {
                                lIsInList.inList = true;
                                return false;
                            }
                            return true;
                        });
                        if (lIsInList.inList) {
                            throw ("cannot unload object while it contain pendind modifications");
                        }
                    });
                }
                for (i = 0; i < idList.length; i++) {
                    id = idList[i];
                    object = FoundationData.getObject(inMemoryData, id);
                    index = rows.indexOf(object);
                    //remove object from rows array.
                    if (index !== -1) {
                        rows.splice(index, 1); //remove 1 item at index.
                    }
                }
                //needs to update the indexCache.  It is complicated to remove just the correct one as objects can be attached in multiple place so recompute the full index
                //this can be optimized later
                FoundationData.__refreshIndexCache(inMemoryData);
            },
            /**
             * loads a list of object by ids and add them to the in memory data.
             *
             * @param inMemoryData  in memory datas tructure
             * @param idList  an array of object ids to load
             * @param index where in the structure to load those ids
             * @param callback function to be called when the load operation finishes.  It is passed the objects which have been added.
             *
             */
            loadObjects: function(inMemoryData, idList, index, callback) {
                var ids = idList.join(),
                    widgetName = inMemoryData._parentExperience ? inMemoryData._parentExperience.name : inMemoryData.name,
                    loadObjectDone = function(data) {
                        //get new loaded objects.
                        var objects = inMemoryData._parentExperience ? data.widget.datarecords.datagroups : data.datarecords.datagroups,
                            //add new objects to current data based on index.
                            rows = inMemoryData.datarecords.datagroups;
                        if (index !== 0 && !index) {
                            inMemoryData.datarecords.datagroups = rows.concat(objects);
                        } else {
                            //insert object in list.
                            inMemoryData.datarecords.datagroups = rows.slice(0, index).concat(objects, rows.slice(index, rows.length));
                        }
                        //merge the index
                        FoundationData.__mergeIndexCache(inMemoryData, data._indexCache);
                        if (callback) {
                            callback.call(this, objects);
                        }
                    };
                widgetName += "?objectIds=" + ids;
                FoundationData.loadWidget(widgetName, loadObjectDone);
            },
            /**
             * TODO fill in info here
             */
            getContainerData: function(containerConfig, containerType, objectData, checkFiltered, allLevels) {
                var listData = null;
                if (!containerConfig) {
                    return listData;
                }
                var data = containerConfig.datarecords,
                    fixedLevels = false;
                if (data) {
                    listData = data.datagroups;
                    FoundationData._setInternalProperty(listData, "_container", containerConfig);
                    fixedLevels = containerConfig.datarecords.fixedLevels;
                    if (!listData) {
                        listData = [];
                    }
                } else if (objectData && objectData.relateddata) {
                    var relationship = containerConfig.name;
                    var datarecords = objectData.relateddata[relationship];
                    if (datarecords) {
                        listData = datarecords.datagroups;
                        fixedLevels = datarecords.fixedLevels;
                    }
                }
                if (listData) {
                    var expandedList = [];
                    for (var i = 0; i < listData.length; i++) {
                        var item = listData[i];
                        if (checkFiltered && item.filtered) {
                            continue;
                        }
                        // item._parentRecords = listData;
                        FoundationData._setInternalProperty(item, "_parentRecords", listData);
                        expandedList.push(item);
                        if (allLevels) {
                            var subObjects = FoundationData.getChildren(item, {
                                checkFiltered: checkFiltered,
                                allLevels: true,
                                fixedLevels: fixedLevels
                            });
                            expandedList = expandedList.concat(subObjects);
                        }
                    }
                    listData = expandedList;
                }
                if (data && !containerConfig.countSummary) {
                    //initially assume all data coming from server is not filtered.
                    containerConfig.countSummary = {
                        total: listData.length,
                        shown: listData.length
                    };
                }
                return listData;
            },
            tempURI: function(widgetName) {
                return "/resources/e6w/service/json/" + widgetName;
            },
            /**
             * retrieve items underneath a container      (bcc: but what is a container?)
             * optionally takes into accound hidden or collapsed objects
             * @param containerConfig, the container
             * @param includeHidden, if not true will not return hidden objects
             * @param includCollapsed, if not true will not return collapsed objects
             */
            getContainerItems: function(containerConfig, includeHidden, includeCollapsed) {
                var list = [],
                    tempList = [],
                    view = containerConfig.displayview;
                if (containerConfig.widget) {
                    FoundationData._setInternalProperty(containerConfig.widget, "_parentExperience", containerConfig);
                    if (includeCollapsed || !containerConfig.collapsed) {
                        tempList.push(containerConfig.widget);
                    }
                } else if (containerConfig.widgets) {
                    tempList = containerConfig.widgets;
                }
                for (var i = 0; i < tempList.length; i++) {
                    if (includeHidden || ((view === tempList[i].view || !tempList[i].view) && !tempList[i].hidden)) {
                        list.push(tempList[i]);
                    }
                }
                return list;
            },
            /**
             * retrieve the widgets underneath a container
             */
            getContainerWidgets: function(containerConfig) {
                return FoundationData.getContainerItems(containerConfig, true, true);
            },
            /**
             * return a hash with all the fields in widgetRoot (including defined lower in the tree).
             * the keys are the field names the values the fields themselves.
             * if 2 fields have the same name only one will be in the index.
             * @param inMemoryData  the data to scan
             * @param fieldIndexCache optional a partially filled index.  This is used by the recursion.
             * @return an index of all fields by their name
             */
            getAllFields: function(inMemoryData, fieldIndexCache) { //returns an object indexed by field name and value is the field itself.
                if (!inMemoryData) {
                    return {};
                }
                if (!fieldIndexCache) {
                    fieldIndexCache = inMemoryData._fieldIndexCache;
                    if (fieldIndexCache) {
                        return fieldIndexCache;
                    }
                    fieldIndexCache = {};
                    FoundationData._setInternalProperty(inMemoryData, "_fieldIndexCache", fieldIndexCache);

                    // inMemoryData._fieldIndexCache = fieldIndexCache; //cache index.
                }
                var items = FoundationData.getContainerWidgets(inMemoryData);
                for (var i = 0; i < items.length; i++) {
                    var itemConfig = items[i];
                    var itemType = itemConfig["widgetType"];
                    if (itemType === "field") {
                        if (!fieldIndexCache[itemConfig.name]) { //cache first field instance.
                            fieldIndexCache[itemConfig.name] = itemConfig; //index field name.
                        }
                    } else { //container.
                        FoundationData.getAllFields(itemConfig, fieldIndexCache);
                    }
                }
                return fieldIndexCache;
            },
            /**
             * retrieve the constants for a given widget.
             * Interpret the widget return to build the string table of the WidgetConstants global object.
             * Create that object if it doesn't exist.
             * The newly retrieved constants will be merged with previously existing ones (offline case).
             * A local storage instance can be passed in in which case the storage will be used to retrieve the constants first.
             * A server call will still be made regardless of whether the constants are found in cache.  When the server call returns the
             * cache will be updated. The callback function will only be called once, either immediately if the data is found in the cache or
             * at the return of the server call after the cache has been updated.
             * @param constantsServiceName: name of the service sending the constants
             * @param callback: callback to be called when constants are loaded
             * @param iLocalStorage: optional a localstorage instance
             */
            getWidgetConstants: function(constantsServiceName, callback /*, iLocalStorage*/ ) { //load constants from a widget.
                if (!window.WidgetConstants) { //this is normally done in setupEnoviaServer in WidgetUWAUtils.  TODO need to factorize
                    window.WidgetConstants = {
                        str: {}
                    };
                }
                var lConstantData;
                //            var saveData = function(data) {
                //                    if (iLocalStorage) {
                //                        FoundationData.saveCachedData(iLocalStorage, constantsServiceName, data);
                //                    }
                //                };
                var processConstantsData = function(data) {
                    lConstantData = data;
                    var field, allFieldsObj = FoundationData.getAllFields(data);
                    var hasOwn = Object.prototype.hasOwnProperty;
                    for (var key in allFieldsObj) {
                        if (hasOwn.call(allFieldsObj, key)) {
                            field = allFieldsObj[key];

                            WidgetConstants.str[field.name] = field.label.text;
                        }
                    }
                    WidgetConstants.str.platformVersion = lConstantData.version;
                    if (typeof callback === 'function') {
                        callback.call(this);
                    }

                    //         saveData(data);
                };
                //if provided with a local storage instance, attempts to load from it
                //            if (iLocalStorage) {
                //                lConstantData = FoundationData.loadCachedData(iLocalStorage, constantsServiceName);
                //            }
                //if constants loaded from the local storage, process them
                //            if (lConstantData) {
                //                processConstantsData(lConstantData);
                //                //now replace the processing method so it just stores the return from the service in local storage
                //                processConstantsData = saveData;
                //            }

                //load the constants from the server and either save in cache or call the callback
                FoundationData.loadWidget(constantsServiceName, processConstantsData);
            },
            /**
             * retrieve a specific constant by name.
             * takes a string name and a default value.
             * will return the requested string or the provided default value.
             * If no default value is provided and no string found it will return undefined
             * @param iConstantName the name of the string to retrieve
             * @param iDefault a default value if this string is not found
             */
            getWidgetConstant: function(iConstantName, iDefault) { // assumes that widget constants are already initialized
                if (!iConstantName) {
                    return "";
                }
                var ret;
                if (!window.WidgetConstants || !window.WidgetConstants.str) {
                    console.error('getWidgetConstant called too early (prior to constants initialization) ');
                }
                ret = window.WidgetConstants && window.WidgetConstants.str ? window.WidgetConstants.str[iConstantName] : null;
                return ret || iDefault;
            },
            /**
             * used to set a widget constant, specially usefull when the NLS strings come from different sources
             * @param iConstantName the constant key
             * @param iValue the value
             * @return the previous value
             */
            setWidgetConstant: function(iConstantName, iValue) {
                if (!window.WidgetConstants) {
                    window.WidgetConstants = {
                        str: {}
                    };
                }
                var oldValue = window.WidgetConstants.str[iConstantName];
                window.WidgetConstants.str[iConstantName] = iValue;
                return oldValue;
            },
            /**
             * iterator pattern.
             * will walk up the ancestor chain and call the callback on each element.
             * this suppose that the _parentObject or _relationshipParentObject information has been computed.
             * this is normally done by iterateOverDataStructure, one way to ensure that it happened is to make sure the index is computed
             * @param iWidget  the in memory data structure
             * @param iObject the start of the iteration the callback will be called at least for that element
             * @param iCallback a function which will be called on object and each of its ancestors, if it returns false the iteration stops.
             *                  the callback will be passed one parameters: context.
             *                  the callback will be called with object as the "this"
             * @param iContext optional, object to be passed to the callback
             * @param iNoRelatedData optional, if true we will not navigate relatedData relationships
             * @param iNoChildren optional, if true we will not navigate children relationships
             */
            eachAncestor: function eachAncestor(iObject, iCallback, iContext, iNoRelatedData, iNoChildren) {
                if (!iObject || typeof iCallback !== "function") {
                    return false;
                }
                if (!iCallback.call(iObject, iContext)) {
                    return false;
                }

                //iterate
                if (!iNoRelatedData && iObject._relationshipParentObject) {
                    return this.eachAncestor(iObject._relationshipParentObject, iCallback, iContext, iNoRelatedData, iNoChildren);
                } else if (!iNoChildren && iObject._parentObject) {
                    return this.eachAncestor(iObject._parentObject, iCallback, iContext, iNoRelatedData, iNoChildren);
                }
                return true;
            },
            CULL_BRANCH: {},
            /**
             * access each object one by one.
             * The callback will be called with the iterated other object as a parameter and the data as this.
             * The function also populates _relationship _parentObject and _relationshipParentObject if necessary
             * @param data the complete structure
             * @param callback to call.  The iteration is stopped if it returns false it continues if it returns nothing, it stops for this branch but continue others if
             * the callbacks returns FoundationData.CULL_BRANCH
             */
            iterateOverDataStructure: function interateOverDataStructure(data, callback, iNoRelatedData, iNoChildren) {
                //get the rows
                var rows = FoundationData.getContainerData(data);

                if (rows) {
                    var lNbRows = rows.length;
                    for (var lCurRowIdx = 0; lCurRowIdx < lNbRows; lCurRowIdx++) {
                        //each row is an object first call the callback
                        var lCurRow = rows[lCurRowIdx];
                        //now we need to iterate other the related data and the children
                        //start with the children
                        if (this.iterateOverObject(data, lCurRow, callback, iNoRelatedData, iNoChildren) === false) {
                            return false;
                        }
                    }
                }


            },
            /**
             * access each object one by one.
             * calls the callback once for the current object and once for each descendant or related data
             * The callback will be called with the iterated other object as a parameter and the data as this.
             * @param data the complete structure
             * @param callback to call.  The iteration is stopped if it returns false it continues if it returns anything else
             */
            iterateOverObject: function iterateOverObject(data, object, callback, iNoRelatedData, iNoChildren) {
                var lCallbackRet = true;
                if (UWA.is(callback, "function")) {
                    lCallbackRet = callback.call(data, object);
                }

                if (lCallbackRet === false) {
                    return false;
                } else if (lCallbackRet === FoundationData.CULL_BRANCH) {
                    return;
                }
                if (!iNoChildren) {
                    //get the children
                    var children = object.children;
                    if (children) {
                        var lNbChildren = children.length;
                        for (var lCurChildIdx = 0; lCurChildIdx < lNbChildren; lCurChildIdx++) {
                            var lCurChild = children[lCurChildIdx];
                            //take advantage to set the _ prop if they are not there
                            if (!lCurChild._parentObject) {
                                FoundationData._setInternalProperty(lCurChild, "_parentObject", object);
                            }
                            FoundationData.__makeRelId(lCurChild);
                            //maybe parent record but it is less useful
                            if (this.iterateOverObject(data, lCurChild, callback, iNoRelatedData, iNoChildren) === false) {
                                return false;
                            }
                        }
                    }
                }
                if (!iNoRelatedData) {
                    var relateddata = object.relateddata;
                    var hasOwn = Object.prototype.hasOwnProperty;
                    for (var key in relateddata) {
                        if (hasOwn.call(relateddata, key)) {
                            var lCurRelatedData = relateddata[key];
                            var rows = UWA.clone(lCurRelatedData.datagroups, false); //bcc: shallow clone of the array so nobody removes anything from it (or add) while I iterate
                            if (rows) {
                                var lNbRows = rows.length;
                                for (var lCurRowIdx = 0; lCurRowIdx < lNbRows; lCurRowIdx++) {
                                    var lCurRow = rows[lCurRowIdx];
                                    //take advantage to set the _ prop if they are not there
                                    if (!lCurRow._relationshipParentObject) {
                                        FoundationData._setInternalProperty(lCurRow, "_relationshipParentObject", object);
                                    }
                                    if (!lCurRow._relationship) {
                                        FoundationData._setInternalProperty(lCurRow, "_relationship", key);
                                        //  lCurRow._relationship = key;
                                    }
                                    FoundationData.__makeRelId(lCurRow);

                                    if (this.iterateOverObject(data, lCurRow, callback, iNoRelatedData, iNoChildren) === false) {
                                        return false;
                                    }
                                }
                            }
                        }
                    }
                }
            },
            /**
             * udpate the _indexCache of the this object
             * (this method has to be called with an inMemoryData as this as it is intended for use with the iterate methods)
             * @param iObject the object which needs to be added to the index
             *
             */
            __updateIndexCacheWithOneObject: function(iObject) {
                var lNbIdNames = idNames.length;
                //if relId is missing a _tempRelId should have been computed by the iterateOver method
                for (var lCurIdNamesIdx = 0; lCurIdNamesIdx < lNbIdNames; lCurIdNamesIdx++) {
                    var lCurId = iObject[idNames[lCurIdNamesIdx]];
                    if (lCurId && lCurId.length) {
                        this._indexCache[lCurId] = iObject;
                    }
                }

            },
            /**
             * builds or rebuilds the index
             */
            __refreshIndexCache: function __refreshIndexCache(inMemoryData, iNoRelatedData, iNoChildren) {
                var lInMemoryData = inMemoryData;
                if (lInMemoryData.widgetType === "experience") {
                    var widgetRoots = FoundationData.getContainerItems(lInMemoryData);
                    lInMemoryData = widgetRoots[0];
                }
                FoundationData._setInternalProperty(lInMemoryData, "_indexCache", {}); //reset the index

                FoundationData.iterateOverDataStructure(lInMemoryData, FoundationData.__updateIndexCacheWithOneObject, iNoRelatedData, iNoChildren);
            },
            /**
             * merges an index to the existing one.  this is to avoid a costly refresh.
             */
            __mergeIndexCache: function __mergeIndexCache(inMemoryData, iIndexToMerge) {
                if (iIndexToMerge) {
                    if (!inMemoryData._indexCache) {
                        FoundationData.__buildIndexCache(inMemoryData);
                    } else {
                        UWA.extend(inMemoryData._indexCache, iIndexToMerge);
                    }
                }
            },
            /**
             * buid the index for the in memory data if it doesn't already exist.
             * this function will not refresh an existing index.
             * @param inMemoryData the data to build the index for
             */
            __buildIndexCache: function __buildIndex(inMemoryData) {
                if (inMemoryData && !inMemoryData._indexCache) {
                    FoundationData.__refreshIndexCache(inMemoryData);
                }
            },
            /**
             * for one batch of modifiedobjects, reset the update action status to something else.
             * @param modifiedObjectList  the batch of object to treat
             * @param newStatus, the status to set
             */
            __changeUpdateActionStatusForBatch: function __changeUpdateActionStatusForBatch(modifiedObjectList, newStatus) {
                var lNbModifiedObjects = modifiedObjectList.length;
                for (var lCurModifiedObjectIdx = 0; lCurModifiedObjectIdx < lNbModifiedObjects; lCurModifiedObjectIdx++) {
                    var lCurModifiedObject = modifiedObjectList[lCurModifiedObjectIdx];
                    lCurModifiedObject.child._updateActionStatus = newStatus;
                }
            },


            /**
             * deletes an object by removing it from the structure.
             * this is really removing from the local memory data structure.
             * It is called after a successful call to the service or after a cancelation of the creation of an object
             * @param iObject the object to be deleted
             */
            __deleteObject: function(inMemoryData, iObject) {
                var index;
                if (iObject._relationshipParentObject) {
                    index = iObject._relationshipParentObject.relateddata[iObject._relationship].datagroups.indexOf(iObject);
                    if (index !== -1) {
                        iObject._relationshipParentObject.relateddata[iObject._relationship].datagroups.splice(index, 1); //remove 1 item at index.
                    }
                }
                if (iObject._parentObject) {
                    index = iObject._parentObject.children.indexOf(iObject);
                    if (index !== -1) {
                        iObject._parentObject.children.splice(index, 1); //remove 1 item at index.
                    }
                }
                if (iObject._parentRecords) {
                    index = iObject._parentRecords.indexOf(iObject);
                    if (index !== -1) {
                        iObject._parentRecords.splice(index, 1); //remove 1 item at index.
                    }
                }
                //remove from index
                var lNbIdNames = idNames.length;
                //if relId is missing a _tempRelId should have been computed by the iterateOver method
                var lIndexCache = inMemoryData._indexCache;
                if (lIndexCache) {
                    for (var lCurIdNamesIdx = 0; lCurIdNamesIdx < lNbIdNames; lCurIdNamesIdx++) {

                        var lCurId = iObject[idNames[lCurIdNamesIdx]];
                        if (lCurId && lCurId.length) {
                            delete lIndexCache[lCurId];
                        }
                    }
                }

            },
            /**
             * generate the update message for the web service based on the current in memory data.
             * this function generates two things:
             * 1 a cache of objects to be updated which is indexed by object id and which contains both the object in our in memory form and the copy which will be sent to the server.
             * 2 the message for the server which contains all the copied objects that were in the cache in 1 and their context (branch up to the root)
             * @param inMemoryData  the in memory form of our data.  This contains informations on what has been modified (as annotations)
             * @param saveId  if this is set only changes to objects having this id will be taken into account
             * @return either:
             *          an object with 2 entries clonedObjects and updateWidget corresponding to the items 1 and 2 described previously
             *          null if _addModifiedObject return null, i.e. if the current modified objects have an ancestor which is
             */
            __generateUpdateWidget: function(inMemoryData, modifiedList, saveId) {
                var updateWidget = {
                        datarecords: {
                            datagroups: []
                        }
                    },
                    clonedObjects = {},
                    parent, child, relationship, id;

                updateWidget.datarecords.name = inMemoryData.datarecords.name;
                updateWidget.datarecords.csrf = inMemoryData.datarecords.csrf;
                updateWidget.name = inMemoryData._parentExperience ? inMemoryData._parentExperience.name : inMemoryData.name;

                for (var i = 0; i < modifiedList.length; i++) {
                    parent = modifiedList[i].parent;
                    child = modifiedList[i].child;
                    relationship = modifiedList[i].relationship;

                    if (typeof child.updateAction === "undefined" /* || child._updateActionStatus === "PENDING"*/ ) { //no modification
                        continue;
                    } else if (child._updateActionStatus === "PENDING") {
                        //wait until the server sends its reply before sending a second change?   It would prevent the 2 changes from telescoping in the server
                        return null;
                    }

                    id = FoundationData.getId(child);
                    if (saveId !== undefined && id !== saveId) {
                        continue;
                    }

                    if (this.__addModifiedObject(updateWidget, clonedObjects, parent, relationship, child) === null) {
                        //not ready to send data to server.
                        return null;
                    }
                }
                //mark all updated objects with PENDING status.
                var hasOwn = Object.prototype.hasOwnProperty; //shortcut
                for (var key in clonedObjects) {
                    if (hasOwn.call(clonedObjects, key)) {
                        child = clonedObjects[key].source;

                        //TODO copy to another attribute
                        if (child.updateAction !== undefined) {
                            child._updateActionStatus = "PENDING";
                            child.updateActionPending = child.updateAction; //so we can add a new one.  We need to diferentiate between when an object has an
                            //update action in the queue vs when it has one which has been sent to the server
                            delete child.updateAction;
                        }
                    }

                }
                delete updateWidget._ids;
                return {
                    "updateWidget": updateWidget,
                    "clonedObjects": clonedObjects
                };
            },
            /**
             * adds an object to the message sent to the server in case of an update.
             * This adds a simplified clone of the object both to the hash of sent objects and to the message itself.
             * This method calls itself recursively until all the parents of the passed in objects are in the message.
             * This method will not modify the message and return null if there is a pending modification on one of the ancestors.
             * In this case the modifications on child will have to be sent to the server once the pending ones are resolved
             *
             * @param udpateWidget  the message which is in construction see 2 in the documentation for __generateUpdateWidget
             * @param clonedObjects the hash containing the cloned objects and their originals see 1 in the documentation for __generateUpdateWidget
             * @returned either the cloned child or null if a pending update prevents us from sending the update to the server
             */
            __addModifiedObject: function __addModifiedObject(updateWidget, clonedObjects, parent, relationship, child) {
                var clonedParent = null,
                    clonedChild = null,
                    childId = FoundationData.getId(child);
                var hasOwn = Object.prototype.hasOwnProperty;

                if (child.updateAction === "CREATE") { //check if our dependencies are pending or in the queue
                    //if our parent has a pending update, return null we need to queue this modification we are not ready to send it to the server yet
                    if (parent && parent._updateActionStatus) { //parent is pending or in the queue
                        return null;
                    }
                }
                if (child.updateAction === "CREATE" || child.updateAction === "MODIFY") { //case of modify we should also check for dependencies
                    var dataElements = child.dataelements;
                    for (var key in dataElements) {
                        if (hasOwn.call(dataElements, key) && dataElements[key].value.length && dataElements[key].value[0]._dependency) {
                            if (dataElements[key].value[0]._dependency._updateActionStatus) {
                                //if a dependency has a PENDING status or a QUEUED we need ot queue the modification
                                return null;
                            }
                            //otherwise update actual value based on latest id.
                            dataElements[key].value[0].actualValue = FoundationData.getId(dataElements[key].value[0]._dependency);
                            delete dataElements[key].value[0]._dependency;
                        }
                    }
                }

                if (parent) {
                    var parentId = FoundationData.getId(parent),
                        found = clonedObjects[parentId];


                    //recursion to make sure we detect pendings in our grandparents and we give enough context to the server
                    if (!found) {
                        found = this.__addModifiedObject(updateWidget, clonedObjects, parent._parentObject || parent._relationshipParentObject, parent._relationship, parent);
                        if (!found) {
                            return null;
                        }
                    }
                    clonedParent = found.item;
                }
                //check that we don't already have this object in the list of modified ones
                clonedChild = clonedObjects[childId];
                if (!clonedChild) {
                    clonedChild = {};
                    clonedObjects[childId] = { //add to temp cache;
                        item: clonedChild,
                        source: child
                    };
                    this.__copyModifiedObject(child, clonedChild); //clone some object properties.
                    if (relationship) {
                        if (clonedParent.relateddata === undefined) {
                            clonedParent.relateddata = {};
                        }
                        if (clonedParent.relateddata[relationship] === undefined) {
                            clonedParent.relateddata[relationship] = {
                                name: relationship,
                                datagroups: []
                            };
                        }
                        clonedParent.relateddata[relationship].datagroups.push(clonedChild);
                    } else if (clonedParent) {
                        if (clonedParent.children === undefined) {
                            clonedParent.children = [];
                        }
                        clonedParent.children.push(clonedChild);
                    } else {
                        //make sure we don't put the same child twice
                        if (updateWidget._ids && updateWidget._ids[FoundationData.getId(clonedChild)]) {
                            //object is already in the updateWidget
                            //should not happen since we should have already found it in the clonedObjects cache
                        } else {
                            if (!updateWidget._ids) {
                                FoundationData._setInternalProperty(updateWidget, "_ids", {});
                            }
                            updateWidget.datarecords.datagroups.push(clonedChild);
                            updateWidget._ids[FoundationData.getId(clonedChild)] = true;
                        }
                    }
                }


                return clonedObjects[childId];
            },
            /**
             * copy shallow copy of a modified object in order to prepare a message for the server.
             * Note: this also deletes the updateMessage and updateSuccessful properties of the source so
             * there can be no confusions between the information from an eventual previous modification.
             * This should only be called during applyUpdates.  The name of the method is also misleading as
             * it is not only copying the modified object but also mutating it.
             * @param source modified object to copy
             * @param target empty object which will contain the copy of the source
             */
            __copyModifiedObject: function(source, target) {
                var propertyList = ["objectId", "physicalId", "relId", "tempId", "updateAction", "dataelements", "cestamp"];
                for (var i = 0; i < propertyList.length; i++) {
                    target[propertyList[i]] = source[propertyList[i]];
                }
                delete source.updateMessage;
                delete source.updateSuccessful;

            },
            /**
             * utility method to initialize a new object correctly.
             * take some fields as an input.  fields should be of the form
             * {name: XXX, value:{displayValue: YYY, actualValue: ZZZ}}
             */
            __newObject: function(fields) {
                var newObject = {
                    children: [],
                    dataelements: {}
                };
                var dependency;
                for (var i = 0; i < fields.length; i++) {
                    var field = fields[i];
                    dependency = undefined;
                    if (field.value) { //case the field is undefined, shouldn't happen but lets be prudent
                        if (typeof field.value.actualValue === "object") {
                            dependency = field.value.actualValue;
                            field.value.actualValue = FoundationData.getId(dependency);
                            delete field.value.displayValue; //no good value today
                        }
                        newObject.dataelements[field.name] = {
                            //"name": field.name,
                            "value": [{
                                "value": field.value.displayValue,
                                "actualValue": field.value.actualValue
                            }]
                        };
                        if (dependency) {
                            FoundationData._setInternalProperty(newObject.dataelements[field.name].value[0], "_dependency", dependency);
                            newObject.dataelements[field.name].isDependency = true;
                        }
                    }
                }
                return newObject;
            },
            /**
             * delete all the prev Values store on any field of an object.  Optionally restore that prev Value.
             * handles both the display and actual values.
             * @param object the object to handle
             * @param restorePrevValue if true before deleting the prevValue we will restore it.
             *      True is used when a modification needs to be canceled, usually due to a server call returning an error.
             *      False is used when the server confirmed that the modification has been applied.
             */
            __deletePrevValues: function(object, restorePrevValue) {
                var dataElements = object.dataelements;
                var hasOwn = Object.prototype.hasOwnProperty;
                for (var key in dataElements) { //one key per attribute
                    if (hasOwn.call(dataElements, key)) {
                        var fieldvalues = dataElements[key].value;
                        if (fieldvalues && fieldvalues.length > 0) { //if there is an actual value
                            if (typeof fieldvalues[0].prevDisplay !== "undefined") { //we only care about the first value for some reason.
                                if (restorePrevValue) {
                                    fieldvalues[0].value = fieldvalues[0].prevDisplay;
                                }
                                delete fieldvalues[0].prevDisplay;
                            }
                            if (typeof fieldvalues[0].prevActual !== "undefined") {
                                if (restorePrevValue) {
                                    fieldvalues[0].actualValue = fieldvalues[0].prevActual;
                                }
                                delete fieldvalues[0].prevActual;
                            }
                        }
                    }
                }
            },
            /**
             * utility method for syncing.
             * try to find the corresponding client object from a server one.
             * seems simple but not so much in fact. Due to all the temp Id shennanigans
             *
             * @param inMemoryData the client data
             * @param iObject the server object
             * @param iFromServerParent
             * @param iRelation
             * @return the object if found
             */
            __getSourceObjectFromServerObject: function(inMemoryData, iObject, iFromServerParent, iRelation) {
                var lId = iObject.relId || iObject._tempRelId || FoundationData.getId(iObject); //important to use the relId for children object in case of multi-instanciation
                var source = inMemoryData._indexCache[lId];
                var lUpdateAction = iObject.updateAction;
                var lTriedPhysicalId = lId === iObject.physicalId;
                if (!source && (lUpdateAction === "CREATE" || lUpdateAction === "CONNECT")) {
                    //CREATED object or CONNECTED object from search like assignees by trig
                    lId = iObject.tempId;
                    source = inMemoryData._indexCache[lId];
                    if (!source) { //still haven't found it. Case of Connect with no tempId, compute tempRelId
                        //need to make sure that the back pointers are set
                        if (iFromServerParent) {
                            if (iRelation === "children") {


                                FoundationData._setInternalProperty(iObject, "_parentObject", iFromServerParent);
                            } else {
                                FoundationData._setInternalProperty(iObject, "_relationshipParentObject", iFromServerParent);
                                FoundationData._setInternalProperty(iObject, "_relationship", iRelation);
                                //iObject._relationship = iRelation;
                            }

                        }

                        lId = __computeTempRelId(iObject);

                        source = inMemoryData._indexCache[lId];

                    }
                    if (!source) { //still haven't found it. Case of Connect with no tempId, compute tempRelId but with objectId in case the reference was added with an objectId
                        lId = __computeTempRelId(iObject, true);
                        source = inMemoryData._indexCache[lId];
                    }
                }

                //additional case in DPG where no relid is there and a weird tempRelId exists but tempId is still there
                if (!source) {
                    lId = iObject.tempId;
                    source = inMemoryData._indexCache[lId];

                }
                if (!source && !lTriedPhysicalId) {
                    //try physicalId, case like documents where we inserted an object without relid in the structure.
                    lId = iObject.physicalId;
                    source = inMemoryData._indexCache[lId];
                }

                return source;
            },
            /**
             * Used by applyUpdates to reconcile in case of success the return values of the server with what was sent and with the in memory version of the data model.
             * recursively synchronize the data sent by the server with the in memory form.
             *  @param inMemoryData the data to sync
             *  @param modifiedUpdateWidget   the data returned by the server after a successful update call
             *  @param masterReference the hash which was built by __generateUpdateWidget which contains the object pair (cloned copies sent and original) indexed by their id
             */
            __synchronizeInMemoryDataWithServerReturn: function(inMemoryData, modifiedUpdateWidget, masterReference) {
                //step 1 check for the index existence (it should always be there but the test is cheap)
                FoundationData.__buildIndexCache(inMemoryData);
                //step 2 scan the list of updates sent to the server for DELETE and DISCONNECT.  This list is the masterReference
                var lKeys = Object.keys(masterReference);
                var lNbKeys = lKeys.length;
                for (var lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                    var lCurKey = lKeys[lCurKeyIdx];
                    var lCurCloneInfo = masterReference[lCurKey];
                    var lCurObjectSentToServer = lCurCloneInfo.item;
                    var lCurMaster = lCurCloneInfo.source;
                    //check the updateAction
                    if (lCurObjectSentToServer.updateAction === "DELETE" || lCurObjectSentToServer.updateAction === "DISCONNECT") {
                        FoundationData.__deleteObject(inMemoryData, lCurMaster);
                        delete lCurMaster.updateActionPending; //bcc: is this really necessary after we removed the object from the structure
                        //nothing to do with regards to the MVC model as this has been done prior
                        FoundationData.__removeObjectAnnotation(lCurMaster);
                    }
                }
                //step 3 iterate over the update data structure and perform a merge
                FoundationData.iterateOverDataStructure(modifiedUpdateWidget, function(iObject) {
                    var lUpdateAction = iObject.updateAction;
                    if (lUpdateAction === "DELETE" || lUpdateAction === "DISCONNECT") {
                        //handled already in step 2
                        return FoundationData.CULL_BRANCH;
                    }
                    //lookup the corresponding object
                    var lSource = FoundationData.__getSourceObjectFromServerObject(inMemoryData, iObject);
                    FoundationData.__synchronizeSourceObjectFromServerObject(inMemoryData, iObject, lSource);

                });
            },
            /**
             * syncrhonize 2 row objects one from the server one from the client.
             * used for the generic sync as well as for the fetch from mvc objects.
             * @param inMemoryData the in Memory data structure
             * @param iFromServer data coming from the server
             * @param iSource the data from the inMemoryData
             * @param iDontResetUpdates [optional] if true the updateActionPending ans _updateActionStatus won't be reset.
             *        This is to be used if the message from the server is not an update message (case for instance of request for info on an object)
             * @param iExactRelatedData [optional] if true consider that the related data are exact values, meaning that if there are missing entries they should be removed
             * @return true if it made a change
             */
            __synchronizeSourceObjectFromServerObject: function(inMemoryData, iFromServer, iSource, iDontResetUpdates, iExactRelatedData) {
                var lChange = false;
                if (iSource) {
                    if (iSource !== iFromServer) {
                        FoundationData.__synchronizeObjectAttributes(inMemoryData, iFromServer, iSource);
                        lChange = FoundationData.__synchronizeObjectArrays(inMemoryData, iFromServer.children, iSource.children, iFromServer, "children");
                        if (lChange && iSource._mvcModel) {
                            //children have been updated need to fire an event on mvc
                            //do not fire the change event for the whole object we want to fire only one for children and relateddata
                            iSource._mvcModel._fireRelationshipChangeEvents("children", {}, true);
                        }
                        var lSyncChanges = FoundationData.__synchronizeRelatedData(inMemoryData, iFromServer, iSource, iExactRelatedData);
                        lChange = lChange || lSyncChanges;
                        if (lChange && iSource._mvcModel) { //either relatedData or children modified, fire a change event for the object
                            iSource._mvcModel._fireRelationshipChangeEvents(undefined, undefined, false, true);
                        }
                        if (!iDontResetUpdates) {
                            delete iSource._updateActionStatus;
                            delete iSource.updateActionPending;
                        }

                    }
                    return lChange;
                }


            },
            /**
             * synchronizes to arrays of subobject (related data, children, ...).
             * @param inMemoryData: the foundation in memory data
             * @param iFromServer: array of objects from the server to sync
             * @param iSource: array of objects from the memory to sync
             * @param iFromServerParent: parent object from the server (usefull since the backpointer _parentObject and _relationParentObject aren't set yet)
             * @param iRelation: relationship
             * @param iExactArray: [optional] if this is true the server side will be considered complete and if it is missing some entries they will be removed from the client side
             * @return true if it made a change
             *
             */
            __synchronizeObjectArrays: function(inMemoryData, iFromServer, iSource, iFromServerParent, iRelation, iExactArray) {
                var lRet = false;
                if (iFromServer) {
                    //index the client array
                    var clientIndex = {};
                    iSource.forEach(function(rowObject) {
                        if (rowObject.physicalId) {
                            clientIndex[rowObject.physicalId] = rowObject; //assume there is a physicalId
                        } else if (rowObject.tempId) {
                            clientIndex[rowObject.tempId] = rowObject;
                        }

                    });
                    //cleanup excess
                    if (iExactArray) {
                        //index the stuff from the server
                        var serverIndex = {};
                        iFromServer.forEach(function(rowObject) {
                            serverIndex[rowObject.physicalId] = rowObject; //assume there is a physicalId
                        });

                        //remove any element in the source array not in the server one
                        iSource.forEach(function(model, index) {
                            if (!serverIndex[model.physicalId]) { //assume there is a physicalId
                                iSource.splice(index, 1);
                                lRet = true;
                            }
                        });
                    }
                    var lNbObjects = iFromServer.length;
                    for (var lCurObjectIdx = 0; lCurObjectIdx < lNbObjects; lCurObjectIdx++) {
                        var lCurObject = iFromServer[lCurObjectIdx];
                        var lUpdateAction = lCurObject.updateAction;
                        if (lUpdateAction === "DELETE" || lUpdateAction === "DISCONNECT") {
                            //don't add the deleted or disconnected objects back in
                            continue;
                        }
                        var lSourceObject = FoundationData.__getSourceObjectFromServerObject(inMemoryData, lCurObject, iFromServerParent, iRelation);
                        var lClientObject = clientIndex[lCurObject.physicalId] || clientIndex[lCurObject.tempId];
                        if (!lClientObject) {
                            iSource.push(lCurObject);
                            FoundationData.__updateIndexCacheWithOneObject.call(inMemoryData, lCurObject);
                            FoundationData.iterateOverObject(inMemoryData, iSource); //replug the parents back pointer to the source
                            lRet = true;
                        }
                        if (lSourceObject) { /*   lRet = */
                            FoundationData.__synchronizeSourceObjectFromServerObject(inMemoryData, lCurObject, lSourceObject);
                            //check if the object was on the client array (it is possible we found it because it was in the structure with a different parent)
                        }

                    }
                }
                return lRet;
            },
            /**
             * synchronize related data between an object coming from the server and the one in the in memory datastructure
             * return true if it made a change
             * @param {Object} inMemoryData in Memory Data
             * @param {Object} iFromServer object from the server
             * @param {Object} iSource object from the client
             * @param {Object} iExactRelatedData tbdocumented
             * @returns {Boolean} true if it made a change
             */
            __synchronizeRelatedData: function(inMemoryData, iFromServer, iSource, iExactRelatedData) { //eslint-disable-line
                var lRet = false;
                var lFromServerRelData = iFromServer.relateddata;
                var lSourceRelData = iSource.relateddata;
                var lKeys;
                var lNbKeys;
                var lCurKeyIdx;
                var lCurKey;
                if (lFromServerRelData) {
                    if (!lSourceRelData) {
                        iSource.relateddata = lFromServerRelData;
                        //now we index them all
                        FoundationData.iterateOverObject(inMemoryData, iSource, FoundationData.__updateIndexCacheWithOneObject);
                        lRet = true;
                        //fire events for each related data separately
                        if (iSource._mvcModel) {
                            lKeys = Object.keys(lFromServerRelData);
                            lNbKeys = lKeys.length;
                            for (lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                                lCurKey = lKeys[lCurKeyIdx];
                                //bcc: Fire a change event for the relationship but not for the object as a whole.
                                //That is consolidated in __synchronizeInMemoryDataWithServerReturn
                                iSource._mvcModel._fireRelationshipChangeEvents(lCurKey, undefined, true);
                            }
                        }

                    } else {
                        lKeys = Object.keys(lFromServerRelData);
                        lNbKeys = lKeys.length;
                        var lNeedToIndexChildren = false;
                        for (lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                             lCurKey = lKeys[lCurKeyIdx];
                            var lCurServerArray = FoundationData.getRelatedObjects(iFromServer, lCurKey);
                            var lCurSourceArray = FoundationData.getRelatedObjects(iSource, lCurKey);
                            if (!lCurSourceArray || !lCurSourceArray.length) {
                                var lNbServerRelData = lCurServerArray.length - 1;
                                for (var lCurServerRelDataIdx = lNbServerRelData; lCurServerRelDataIdx >= 0; lCurServerRelDataIdx--) {
                                    //reverse loop since we will delete stuff
                                    var lCurServerRelData = lCurServerArray[lCurServerRelDataIdx];
                                    var lUpdateAction = lCurServerRelData.updateAction;
                                    if (lUpdateAction === 'DELETE' || lUpdateAction === 'DISCONNECT') {
                                        //remove from the server data
                                        lCurServerArray.splice(lCurServerRelDataIdx, 1);
                                    }
                                }
                                if (lCurServerArray.length > 0) {
                                    lSourceRelData[lCurKey] = lFromServerRelData[lCurKey];
                                    //need to index those new children
                                    lNeedToIndexChildren = true;
                                    lRet = true;
                                    if (iSource._mvcModel) {
                                        iSource._mvcModel._fireRelationshipChangeEvents(lCurKey, undefined, true);
                                    }

                                }

                            } else {
                                var lCurRet = FoundationData.__synchronizeObjectArrays(inMemoryData, lCurServerArray, lCurSourceArray, iFromServer, lCurKey, iExactRelatedData);
                                lRet = lRet || lCurRet;
                                if (lCurRet && iSource._mvcModel) {
                                    //bcc: Fire a change event for the relationship but not for the object as a whole.
                                    //That is consolidated in __synchronizeInMemoryDataWithServerReturn
                                    iSource._mvcModel._fireRelationshipChangeEvents(lCurKey, undefined, true);
                                }
                            }

                        }
                        if (lNeedToIndexChildren) {
                            //add code to index children
                            FoundationData.iterateOverObject(inMemoryData, iSource, FoundationData.__updateIndexCacheWithOneObject);
                        }
                    }

                }
                if (iExactRelatedData && lSourceRelData) {

                    //remove all excess source related data
                    lKeys = Object.keys(lSourceRelData);
                    lNbKeys = lKeys.length;
                    for (lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                        lCurKey = lKeys[lCurKeyIdx];
                        if (!lFromServerRelData[lCurKey]) {
                            delete lSourceRelData[lCurKey];
                            lRet = true;
                        }

                    }
                }

                return lRet;

            },
            /**
             * synchronizes the attributes of 2 objects one coming from the server (iObject) and one from the client (iSource).
             * This overwrite all attributes except if the source has updateAction === "MODIFY" in which case it only overwrite those which do not
             * have a prevValue
             * @param {Object} inMemoryData the inMemoryData
             * @param {Object} iObject object coming from the server
             * @param {Object} iSource the object from the client
             */
            __synchronizeObjectAttributes: function(inMemoryData, iObject, iSource) {

                //optimization checking for ceStamp equality
                //WARNING this may cause an issue in DPG which may not return an updated stamp for each service
                //keep the code here so we can activate it once we have reviewed the DPG services
                //DON'T REMOVE THIS COMMENTED OUT CODE JOHN!
                //            if (iObject.cestamp && iSource.cestamp && iObject.cestamp === iSource.cestamp) {
                //                //no changes nothing to do
                //                return;
                //            }
                if (iSource) {
                    //go through each dataelement individually
                    if (iSource.updateAction !== 'MODIFY') { //no local changes erase previous values
                        FoundationData.__deletePrevValues(iSource, false);
                    }
                    FoundationData.appendFieldData(iSource, iObject);

                    if (!iSource.objectId || !iSource.physicalId || (!iSource.relId && iObject.relId)) {

                        iSource.objectId = iObject.objectId;
                        iSource.physicalId = iObject.physicalId;

                        if (iObject.relId && (iSource._parentObject || iSource._relationshipParentObject)) { //only create a relId if there is a reason to
                            iSource.relId = iObject.relId;
                        }
                        //update the index
                        FoundationData.__updateIndexCacheWithOneObject.call(inMemoryData, iSource);
                    }
                    if (iObject.busType && iObject.busType !== iSource.busType) {
                        iSource.busType = iObject.busType;
                    }

                    iSource.cestamp = iObject.cestamp;
                    iSource.updateSuccessful = iObject.updateSuccessful;
                    if (iSource._mvcModel) {
                        iSource._mvcModel.applyUpdatesFromServer();
                    }

                }
            },
            /**
             * remove object annotation which could artificially maintain other objects alive
             * @param {Object} iObject the object to remove annotation from
             */
            __removeObjectAnnotation: function(iObject) {
                delete iObject._mvcModel; //should have been done earlier
                delete iObject._parentObject;
                delete iObject._relationshipParentObject;
                delete iObject._parentRecords;
            },
            /**
             * Used by applyUpdates to reconcile in case of success the return values of the server with what was sent and with the in memory version of the data model.
             * recursively applies to the local in memory forms the changes sent back by the server.
             * TODO Need to be re-thought as part of the generic refresh redesign
             *  @param modifiedUpdateWidget   the data returned by the server after a successful update call
             *  @param updateWidget  the data which was sent to the server during the update call
             *  @param masterReference the hash which was built by __generateUpdateWidget which contains the object pair (cloned copies sent and original) indexed by their id
             *  @param success the code which was returned by the server
             */
            //TODO: rename
            __postprocessServerFailureMessage: function(inMemoryData, modifiedUpdateWidget, updateWidget, masterReference, success) {
                //copy new object ids of newly created objects into master data (target).
                var id, master;
                var hasOwn = Object.prototype.hasOwnProperty; //shortcut
                for (var key in modifiedUpdateWidget) {
                    if (hasOwn.call(modifiedUpdateWidget, key)) {
                        if (key === 'datagroups' || key === 'children' || key === 'relateddata') {
                            var sourceItems = modifiedUpdateWidget[key];
                            var targetItems = updateWidget[key];
                            if (!targetItems) {
                                if (success && (key === 'relateddata' || sourceItems.length > 0)) { //case where we find some related data in the results which were not in the sent information
                                    //new structure sent by server during update.  add new structure to master data.
                                    id = FoundationData.getId(updateWidget);
                                    master = masterReference[id].source;
                                    //TODO  bcc to check with GQH if this is correct
                                    master[key] = sourceItems; //bcc: this is replacing rather than adding.
                                    //The assumption is that if the server sent new data it is complete?
                                    //I think there should be a merge here
                                }
                                continue;
                            }
                            if (key === 'relateddata') {
                                for (var rel in sourceItems) {
                                    if (hasOwn.call(sourceItems, rel)) {
                                        //recursively calls ourselves
                                        FoundationData.__postprocessServerFailureMessage(inMemoryData, sourceItems[rel], targetItems[rel], masterReference, success);
                                    }
                                }
                            } else {
                                //this is assuming that the length are the same between the 2 lists.  Couldn't we have new children not present in the source as in relateddata
                                for (var i = 0; i < sourceItems.length; i++) {
                                    FoundationData.__postprocessServerFailureMessage(inMemoryData, sourceItems[i], targetItems[i], masterReference, success);
                                }
                            }
                        } else if (key === 'updateAction') {
                            id = FoundationData.getId(updateWidget);
                            master = masterReference[id].source;
                            if (modifiedUpdateWidget.updateMessage) {
                                master.updateMessage = modifiedUpdateWidget.updateMessage;
                            }
                            if (modifiedUpdateWidget.updateSuccessful) {
                                master.updateSuccessful = modifiedUpdateWidget.updateSuccessful;
                            }
                            delete master._updateActionStatus; //delete pending status.
                            //never happens anymore
                            //                        if (success) {
                            //                            if (modifiedUpdateWidget[key] === "CREATE" || modifiedUpdateWidget[key] === "CONNECT") {
                            //                                master.objectId = modifiedUpdateWidget.objectId;
                            //                                master.physicalId = modifiedUpdateWidget.physicalId;
                            //
                            //                                if (modifiedUpdateWidget.relId) { //only create a relId if there is a reason to
                            //                                    master.relId = modifiedUpdateWidget.relId;
                            //                                }
                            //                                FoundationData.appendFieldData(master, modifiedUpdateWidget);
                            //                            } else if (modifiedUpdateWidget[key] === "MODIFY") {
                            //                                //We need to merge the values which have changed on the server (modified date is a good example).
                            //                                //however how do we know what to overwrite or not?  I think we should assume that the value from the server is most up to date.
                            //                                //the risk here is if we have a value which was changed in memory.  We could be overwriting it.
                            //                                //we can guess that this happens if there is an updateAction === "MODIFY" on the master since the updateAction was copied
                            //                                //to updateActionPending while waiting for the server.  But at this point we would just know that there is a conflict.
                            //                                FoundationData.appendFieldData(master, modifiedUpdateWidget);
                            //                                //modify succeeded, delete the previous value information.
                            //                                FoundationData.__deletePrevValues(master, false);
                            //
                            //
                            //                            } else if (modifiedUpdateWidget[key] === "DELETE" || modifiedUpdateWidget[key] === "DISCONNECT") {
                            //                                try {
                            //                                    //remove object from array.
                            //                                    FoundationData.__deleteObject(inMemoryData, master);
                            //                                } catch (err) {
                            //                                    console.error(err.message);
                            //                                }
                            //                            }
                            //                        } else {
                            //keep track of the last failed action
                            master.updateActionFailed = master.updateActionPending;
                            //}
                            delete master.updateActionPending; //delete update action.
                        }
                    }
                }
            },
            /**
             * adds an object to the inMemoryData's list of modified objects which will need.
             * if parentObject and relationship are not supplied, they will be deduced from the object which was modified.
             * @param {Object} inMemoryData, the in memory data structure
             * @param {Object} parentObject, optional, the parent object of the modified object.  If this is not specified it must be possible to deduce it from the object.
             * @param {Object} childObject, mandatory, the object to add to the list
             * @param {String} relationship, optional, the relationship between the parent and child object,
             *                          if null and the child object do not carry a _relationship value,
             *                          it is assumed the object should be created is a child
             */
            __addToModifiedList: function(inMemoryData, parentObject, childObject, relationship) {
                var modifiedList = inMemoryData._modifiedObjectList;
                if (!modifiedList) {
                    modifiedList = [];
                    FoundationData._setInternalProperty(inMemoryData, "_modifiedObjectList", modifiedList);
                    //                //inMemoryData._modifiedObjectList = modifiedList;
                }
                if (!parentObject) {
                    relationship = childObject._relationship;
                    parentObject = childObject._relationshipParentObject || childObject._parentObject;
                }
                modifiedList.push({
                    parent: parentObject,
                    child: childObject,
                    relationship: relationship
                });
            },
            /**
             * marks an object for disconnection.
             * disconnecting an object removes it from the structure.
             * @param {Object} inMemoryData  the in memory data store
             * @param {Object} childObject  the object to disconnect
             * @param {Object} iParentObject optional.  When an object is instantiated in several place it is safer to provide the explicit parent to be disconnected.
             * @param {String} iRelationship optional.  When an object is instanciated in several place, potentially with several relations it is safer to ecplicitly provide the one to disconnect.
             *
             * NOTE: server side the service may be relying heavily on the relationship id for disconnecting so even if iParentObject and relationship are set correctly if the
             *       childObject which is used is one with an incorrect relId it will not function correctly
             */
            __disconnectObject: function(inMemoryData, childObject, iParentObject, iRelationship) {
                //var relationship = undefined,
                var parentObject = iParentObject || childObject._parentObject; //undefined is fine for related data as __addToModifiedList reads the record itself
                var lUpdateAction = childObject.updateAction;
                childObject.updateAction = "DISCONNECT";
                if (!lUpdateAction) {
                    //this means that in case of a MODIFY then DISCONNECT the MODIFY gets lost
                    FoundationData.__addToModifiedList(inMemoryData, parentObject, childObject, iRelationship);

                }
                if (parentObject._mvcModel) {
                    parentObject._mvcModel._fireRelationshipChangeEvents(iRelationship || "children", {});
                }
            },
            /**
             * Helper method to connect an object as a new child of the parent object.
             * this can apply to children or to relatedData.  The newObject can be an existing one (case of __connectObject) or a new one (case of __addObject).
             * This will add the object to the structure. This will not mark the object with the appropriate updateAction nor will it add a temp_id, that step should have
             * happened prior.
             * It will on the other hand update the _indexCache
             * @param inMemoryData the in memory data model
             * @param relationship, optional, the name of the relationship to use when adding the object to is parent.  If present a relatedData object is created
             * @param parentObject the existing object on which a new child is added.  This should exist in the in memory data model.
             * @param newObject the object to connect this is typically an object pre-existing on the server, the id of which was retrieved by one mean or another.
             *                  the newObject is typically just an empty wrapper around that id
             * @param index optional, where in the list of children to insert this one.
             * @param iMVCModel, optional mvcModel which will have to be updated prior to firing events
             * @return the newObject
             */
            __addOrConnectObjectToStructure: function(inMemoryData, relationship, parentObject, newObject, index, iMVCModel) {
                var rows;
                var lRelationship = relationship;
                if (!parentObject) {
                    rows = inMemoryData.datarecords.datagroups;
                } else {
                    if (lRelationship) {
                        if (parentObject.relateddata === undefined) {
                            parentObject.relateddata = {};
                        }
                        if (parentObject.relateddata[lRelationship] === undefined) {
                            parentObject.relateddata[lRelationship] = {
                                name: lRelationship,
                                datagroups: []
                            };
                        }

                        rows = parentObject.relateddata[lRelationship].datagroups;
                        FoundationData._setInternalProperty(newObject, "_relationshipParentObject", parentObject);
                        FoundationData._setInternalProperty(newObject, "_relationship", lRelationship);
                        // newObject._relationship = lRelationship;
                    } else {
                        if (parentObject.children === undefined) {
                            parentObject.children = [];
                        }
                        rows = parentObject.children;
                        FoundationData._setInternalProperty(newObject, "_parentObject", parentObject);
                        lRelationship = "children";
                        //newObject._parentObject = parentObject;
                    }

                }


                if (index !== 0 && !index) { // first condition because 0 would be a valid place to insert at and would also be falsy for js
                    rows.push(newObject);
                } else {
                    //insert object in list.
                    rows.splice(index, 0, newObject);
                }

                newObject.widgetType = "datagroup";
                FoundationData._setInternalProperty(newObject, "_parentRecords", rows);
                if (inMemoryData._indexCache) {
                    FoundationData.__makeRelId(newObject);
                    FoundationData.__updateIndexCacheWithOneObject.call(inMemoryData, newObject);

                }
                if (iMVCModel) {
                    //update the model and rowObject links
                    if (!iMVCModel._rowObjects) {
                        iMVCModel._rowObjects = [newObject];
                    } else {
                        if (iMVCModel._rowObjects.indexOf(newObject) === -1) {
                            iMVCModel._rowObjects.push(newObject);
                        }
                    }

                    FoundationData._setInternalProperty(newObject, "_mvcModel", iMVCModel);
                }
                if (parentObject && parentObject._mvcModel) {
                    parentObject._mvcModel._fireRelationshipChangeEvents(lRelationship, {});
                }
                //newObject._parentRecords = rows;

                return newObject;
            },
            /**
             * internal method to set an object's parent internal property.
             * this is used mostly when the value is an object and this could cause the structure to become a graph.
             * the property will be defined as being not enumerable so it will not show up when using JSON.stringify
             * @param iObject, object to enrich
             * @param iName, name of the property
             * @param iValue, value of the property
             */
            _setInternalProperty: function(iObject, iName, iValue) {
                Object.defineProperty(iObject, iName, {
                    value: iValue,
                    enumerable: false,
                    configurable: true,
                    writable: true
                });

            },
            /**
             * Connects an object as a new child of the parent object.
             * this can apply to children or to relatedData.  The newObject is supposed to be pre-existing (otherwise see __addObject).
             * This will add the object to the structure and will mark it as such so that the new connection can be persisted during the
             * next applyUpdates.
             * @param inMemoryData the in memory data model
             * @param relationship, optional, the name of the relationship to use when adding the object to is parent.  If present a relatedData object is created
             * @param parentObject the existing object on which a new child is added.  This should exist in the in memory data model.
             * @param newObject the object to connect this is typically an object pre-existing on the server, the id of which was retrieved by one mean or another.
             *                  the newObject is typically just an empty wrapper around that id
             * @param index optional, where in the list of children to insert this one.
             * @return the newObject
             */
            __connectObject: function(inMemoryData, relationship, parentObject, newObject, index) {
                if (!parentObject) {
                    throw "parentObject is mandatory";
                }
                newObject.updateAction = "CONNECT";
                if (!FoundationData.getId(newObject)) {
                    //add a tempId, this is typically the case when we have an object that is being searched.
                    //the tempId is necessary otherwise we can't reconcile after saving the searched object with the stub
                    newObject.tempId = this._newTempId();
                }
                this.__addOrConnectObjectToStructure(inMemoryData, relationship, parentObject, newObject, index);
                FoundationData.__addToModifiedList(inMemoryData, parentObject, newObject, relationship);
                return newObject;
            },
            /**
             * generate tempId, keep that as a separate function so it can be use in tests
             */
            _newTempId: FoundationAjax._newTempId,

            /**
             * create a new object and add it in the data model.
             * this is meant to be called when a new object needs to be added to the structure at any level
             * (depending on the parameters this will be added at the root or as a child or related data of another object).
             * The added object will be marked as created and added to the list of modified objects to be persisted during
             * the next applyUpdates.
             * @param inMemoryData, the in memory data structure
             * @param relationship, optional, the name of the relationship to use when adding the object to is parent.  If present a relatedData object is created
             * @param parentObject, optional, the parentObject to add the new object to. If it is not present the object is added as a new root
             * @param newObject, mandatory the row object to add
             * @param index optional where among the parent's children or the relatedData array should the new object be added
             * @param iMVCModel, optional mvcModel which will have to be updated prior to firing events
             */
            __addObject: function(inMemoryData, relationship, parentObject, newObject, index, iMVCModel) {

                newObject.updateAction = "CREATE";
                newObject.tempId = this._newTempId();
                this.__addOrConnectObjectToStructure(inMemoryData, relationship, parentObject, newObject, index, iMVCModel);
                FoundationData.__addToModifiedList(inMemoryData, parentObject, newObject, relationship);
                return newObject.tempId;
            },
            /**
             * utility method to find an object by id among rows.
             * @param rows the rows to be searched
             * @param id either an objectid a relid a physicalid or a tempid
             */
            __findObject: function(rows, id) {
                var retobject = null;
                if (rows) {
                    for (var i = 0; i < rows.length; i++) {
                        if (id === rows[i].objectId || id === rows[i].relId || id === rows[i]._tempRelId || id === rows[i].physicalId || id === rows[i].tempId) {
                            retobject = rows[i];
                            break;
                        }
                    }
                }
                return retobject;
            },
            /**
             * update inMemoryData csrf from another return from the server.
             * used when we call multiple separated REST APIs
             */
            __updateCsrf: function(inMemoryData, newData) {
                if (newData.datarecords && newData.datarecords.csrf) {
                    inMemoryData.datarecords.csrf = newData.datarecords.csrf;
                }

            },
            /**
             * getCsrf structure from inMemoryData
             */
            getCsrf: function(inMemoryData) {
                return inMemoryData.datarecords && inMemoryData.datarecords.csrf;
            },
            /**
             * setCsrf structure in inMemoryData
             */
            setCsrf: function(inMemoryData, csrf) {
                if (inMemoryData.datarecords) {
                    inMemoryData.datarecords.csrf = csrf;
                }
            }

        };
        return FoundationData;
    });

/*
 * Widget APIs
 * WidgetAPIs.js
 * version 2.4.1
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 *
 */
/* global define */
/* global WidgetConstants */
/* global enoviaServer */
/* global require */
/* global isIFWE */

define('DS/Foundation/WidgetAPIs', ['UWA/Core', 'DS/ENO6WPlugins/jQuery_3.3.1',
        'DS/Foundation/FoundationData', 'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
        'DS/Foundation/WidgetTemplate'
    ],

    function(UWA, jQuery, FoundationData, i3DXCompassPlatformServices, WidgetTemplate) {
        'use strict';
        var WidgetAPIs = {
            appendFieldData: FoundationData.appendFieldData,
            loadWidget: FoundationData.loadWidget,
            getFieldData: FoundationData.getFieldData,
            getDataElement: FoundationData.getDataElement,
            getChildren: FoundationData.getChildren,
            getRelatedObject: FoundationData.getRelatedObject,
            getObject: FoundationData.getObject,
            ajaxRequest: function() {
                return FoundationData.ajaxRequest.apply(FoundationData, arguments);
            },
            //bcc enable overloading WidgetAPIs and FoundationData's ajaxRequest at the same time
            getId: FoundationData.getId,
            getContainerData: FoundationData.getContainerData,
            getContainerItems: FoundationData.getContainerItems,
            getFieldValue: FoundationData.getFieldValue,
            getRelId: FoundationData.getRelId,
            getWidgetConstants: FoundationData.getWidgetConstants,
            getWidgetConstant: FoundationData.getWidgetConstant,
            //initial function to initiate processing of JSON data for UI presentation.
            drawWidget: function(containerConfig) { //containerConfig: JSON data from service
                this.engine = containerConfig;
                return this.__drawWidget(containerConfig.data);
            },
            getWidgetViews: function(widgetRoot) {
                var userViews = [];
                if (widgetRoot.availableViews) {
                    var views = widgetRoot.availableViews.view;
                    for (var i = 0; i < views.length; i++) {
                        var viewpref = {
                            displayName: WidgetConstants.str[views[i]],
                            value: views[i]
                        };
                        userViews.push(viewpref);
                    }
                }
                return userViews;
            },
            setWidgetViewPreference: function(widgetRoot, view) {
                widgetRoot.displayview = view;
            },
            getWidgetViewPreference: function(widgetRoot) {
                return (widgetRoot.displayview);
            },
            getWidgetTitle: function(widgetRoot, objectId) { //check if the widget data con
                var title = null;
                while (widgetRoot && (typeof widgetRoot.widgetType === 'undefined' || widgetRoot.widgetType === 'view' || widgetRoot.widgetType === 'experience')) {

                    var dataWidgets = WidgetAPIs.getContainerItems(widgetRoot, true); //include hidden.
                    if (dataWidgets.length > 0) {
                        widgetRoot = dataWidgets[0];
                    } else {
                        break;
                    }
                }
                if (widgetRoot) {
                    var rootObject = WidgetAPIs.getObject(widgetRoot, objectId);
                    title = WidgetAPIs.getFieldValue(rootObject, 'title').displayValue;
                }
                return title;
            },
            drawContainerHTML: function(containerConfig, widgetTypeHierachy, containerHTMLItems, containerData, objectData) {
                var containerType = containerConfig.widgetType || 'ds-widget';
                var containerLayout = this.getContainerLayout(containerConfig, containerType) || '';
                var objData = {
                    config: containerConfig,
                    data: containerData,
                    objectData: objectData,
                    type: containerType,
                    layout: containerLayout,
                    children: containerHTMLItems
                };
                return this.engine.createView(objData);
            },

            //bcc: can't find where this is used
            drawFieldHTML: function(itemConfig, widgetTypeHierachy, objectData, widget, keepTableFieldLabel) {
                var fieldContext = this.getItemContext(itemConfig, widgetTypeHierachy);
                var labelSettings = null;
                if (!keepTableFieldLabel && fieldContext === 'table') {
                    labelSettings = itemConfig.label;
                    itemConfig.label = null;
                }
                var values = this.getFieldData(itemConfig, objectData);
                var objData = {
                    config: itemConfig,
                    data: objectData,
                    objectData: objectData,
                    context: fieldContext,
                    type: 'field',
                    values: values,
                    widget: widget
                };
                var HTMLField = this.engine.createFieldView(objData);
                if (labelSettings) {
                    itemConfig.label = labelSettings;
                }
                return HTMLField;
            },
            isObjectContainer: function(testString) {
                return (this.__findInArray(this._dataContainers, testString) !== -1);
            },
            getItemContext: function(item, widgetTypeHierachy) {
                var itemContext = item._itemContext;
                if (!itemContext) {
                    var len = widgetTypeHierachy.length;
                    for (var i = len - 1; i >= 0; i--) {
                        var found = false;
                        itemContext = widgetTypeHierachy[i];
                        switch (itemContext) {
                            case 'table':
                            case 'list':
                            case 'form':
                            case 'channel':
                                found = true;
                                break;
                            default:
                                break;
                        }
                        if (found) {
                            break;
                        }
                    }
                    item._itemContext = itemContext;
                }
                return itemContext;
            },
            drawTableHeaderHTML: function(itemConfig, widgetTypeHierachy) {
                //for now, call standard field handling.
                return (this.drawFieldHTML(itemConfig, widgetTypeHierachy, null, itemConfig, true));
            },
            getTableHeaders: function(containerConfig, widgetTypeHierachy) {
                if (!widgetTypeHierachy) {
                    widgetTypeHierachy = ['table'];
                }
                var containerItems = this.getContainerItems(containerConfig); //get sub-widgets.
                var containerHTMLItems = [];
                for (var j = 0; j < containerItems.length; j++) { //sub-widgets.
                    var itemConfig = containerItems[j];
                    var itemType = itemConfig.widgetType;
                    if (itemType === 'field') {
                        containerHTMLItems.push(this.drawTableHeaderHTML(itemConfig, widgetTypeHierachy));
                    } else { //container.
                        var subContainerHTMLItems = this.getTableHeaders(itemConfig, widgetTypeHierachy);
                        var htmlStr = this.drawContainerHTML(containerConfig, [], subContainerHTMLItems);
                        containerHTMLItems.push(htmlStr);
                    }
                }
                return containerHTMLItems;
            },
            getContainerLayout: function(containerConfig /*, containerType*/ ) {
                var layout = null;
                var style = containerConfig.style;
                if (style) {
                    layout = style.layout;
                }
                if (!layout) {
                    layout = 'VERTICAL';
                }
                return layout;
            },
            getWidgetData: function(containerConfig, options /* checkFiltered (true), allLevels (false) */ ) {
                options = options || {};
                var checkFiltered = options.checkFiltered || true,
                    allLevels = options.allLevels || false;

                return this.getContainerData(containerConfig, null, null, checkFiltered, allLevels);
            },
            getField: function(widgetRoot, fieldName) { //get field by name.
                return this.__getField(widgetRoot, fieldName);
            },

            // bcc since the dataelements is an object, not an array I don't see how this can work and since it is not used, lets just remove it for now
            //        getDataElementByIndex: function (objectData, index) {
            //            var dataelement = null;
            //            var dataelements = objectData.dataelements;
            //            if (index < dataelements.length) {
            //                dataelement = dataelements[index];
            //            } else { // need to create element.
            //                for (var i = dataelements.length; i <= index; i++) { //append place holders.
            //                    dataelement = {
            //                        'value': []
            //                    };
            //                    dataelements.push(dataelement);
            //                }
            //            }
            //            return dataelement;
            //        },
            getAutoFilterFields: function(containerConfig) {
                return this.__getAutoFilterFields(containerConfig);
            },
            destroyTNProxies: function(widgetRoot) {
                var items;
                if (widgetRoot.widgetType === 'experience') {
                    items = this.getContainerItems(widgetRoot);
                    widgetRoot = items[0];
                }
                if (widgetRoot.tnProxy) {
                    widgetRoot.tnProxy.die();
                    widgetRoot.tnProxy = null;
                    jQuery(window.WidgetTagNavInit.tnWin.document).unbind('.' + widgetRoot.id);
                }
            },
            getCollaborativeStorages: function(callbackFunction) { //returns a list of cstorages with URL and displayName as properties.

                i3DXCompassPlatformServices.getPlatformServices({
                    onComplete: function(data) {
                        var cstorage;
                        if (data) {
                            cstorage = UWA.clone(data); //deep copy, only strings
                        }
                        if (!cstorage || cstorage.length === 0) {
                            // if zero length use existing url.
                            cstorage = [];
                            cstorage.push({
                                displayName: 'ENOVIA',
                                url: enoviaServer.computeUrl('')
                            });
                        }
                        callbackFunction.call(this, cstorage);
                    }
                });
            },
            processUrl: function(urlFieldConfig, object, fieldValue) {
                var param, tmpUrl, arrParam = [];
                if (fieldValue && fieldValue.values && fieldValue.values[0] && fieldValue.values[0].urlValue) {
                    tmpUrl = fieldValue.values[0].urlValue;
                } else {
                    tmpUrl = urlFieldConfig.url.path;
                }
                // cleanup relative paths
                if (tmpUrl.indexOf('?') === 0) {
                    tmpUrl = enoviaServer.computeUrl(tmpUrl);
                } else if (tmpUrl.indexOf('../') === 0) {
                    tmpUrl = enoviaServer.computeUrl(tmpUrl.substring(2));
                } else if (tmpUrl.indexOf('/') === 0) {
                    tmpUrl = enoviaServer.computeUrl(tmpUrl);
                } else if (tmpUrl.indexOf('javascript') === 0) {
                    return tmpUrl;
                }
                if (typeof isIFWE !== 'undefined' && isIFWE === true) {
                    //tmpUrl = tmpUrl.replace('emxTree.jsp', 'emxSecurityContextSelection.jsp');
                    tmpUrl = tmpUrl.replace('common/emxTree.jsp', 'emxLogin.jsp');
                    tmpUrl = tmpUrl.replace('common/emxSecurityContextSelection.jsp', 'emxLogin.jsp');
                } else {
                    tmpUrl = tmpUrl.replace('emxSecurityContextSelection.jsp', 'emxTree.jsp');
                }
                //parameters
                if (object) {
                    if (tmpUrl.indexOf('objectId=') === -1 && tmpUrl.indexOf('physicalId=') === -1) {
                        if (object.objectId) {
                            arrParam.push('objectId=' + object.objectId);
                        }
                        if (object.physicalId) {
                            arrParam.push('physicalId=' + object.physicalId);
                        }
                    }
                }
                if (enoviaServer.taggerContextId && enoviaServer.taggerContextId.length > 0) {
                    arrParam.push('tabId=' + enoviaServer.taggerContextId);
                }
                if (enoviaServer.appName && enoviaServer.appName.length > 0) {
                    arrParam.push('appName=' + enoviaServer.appName);
                }
                // Removing widgetId setting as it causes Tagger to break when launching BPS apps from List widget (IR-523930-3DEXPERIENCER2018x)
                //if (enoviaServer.widgetId && enoviaServer.widgetId.length > 0) {
                //    arrParam.push('widgetId=' + enoviaServer.widgetId);
                //}
                if (enoviaServer.objectId && enoviaServer.objectId.length > 0) {
                    arrParam.push('objectId=' + enoviaServer.objectId);
                }
                if (enoviaServer.targetOrigin && enoviaServer.targetOrigin.length > 0) {
                    arrParam.push('targetOrigin=' + enoviaServer.targetOrigin);
                }
                if (arrParam.length > 0) {
                    param = (tmpUrl.indexOf('?') !== -1) ? '&' : '?';
                    param += arrParam.join('&');
                    //add params to url
                    tmpUrl += param;
                }
                var params = enoviaServer.getParams();
                if (params !== '') {
                    tmpUrl += '&' + params;
                }
                return tmpUrl;
            },
            getCollaborativeSpaces: function(callbackFunction) { //returns a list of cspaces.
                var thisRequest = {
                    callbackFunction: callbackFunction
                };
                var getCSpacesDone = function(data) {
                    var cspaces = data.cspaces;
                    if (!cspaces || cspaces.length === 0) {
                        // if zero length use existing space
                        cspaces = [];
                        cspaces.push({
                            displayName: 'Default',
                            name: 'default'
                        });
                    }
                    thisRequest.callbackFunction.call(this, cspaces);
                };
                var cspaceURL = '/resources/bps/cspaces';
                FoundationData.ajaxRequest({
                    url: cspaceURL,
                    type: 'GET',
                    dataType: 'json',
                    data: '',
                    callback: getCSpacesDone
                }, /*noParamsExceptTenant*/ true); //disable enoviaServer params for cspace to workaround CORS bugs
            },
            /**
             * sorts the datarecords of a widget based on a list of fields.
             * @param {Object} widgetRoot the in memory data
             * @param {Object[]} sortList an array of objects each containing a name and a direction.  The name should be that of a sortable field and the direction should be ascending or descending
             *  [{name: 'field name', direction: 'ascending/descending'}, ...]
             */
            sortWidget: function(widgetRoot, sortList) {
                var widgetType = widgetRoot.widgetType;
                if (widgetType === 'experience') {
                    var containerItems = this.getContainerItems(widgetRoot); //get main widget.
                    widgetRoot = containerItems[0];
                }
                if (widgetRoot._parentExperience) { //save sort pref. in case of refresh.
                    widgetRoot._parentExperience._sortList = sortList;
                }
                this.__sortWidget(widgetRoot, sortList);
            },
            getSortableFields: function(widgetRoot) { //returns a list of field objects that are defined as sortable.
                var widgetType = widgetRoot.widgetType;
                if (widgetType === 'experience') {
                    var containerItems = this.getContainerItems(widgetRoot); //get main widget.
                    widgetRoot = containerItems[0];
                }
                var sortfields = this.__getSortableFields(widgetRoot);
                var sorts = [];
                for (var i = 0; i < sortfields.length; i++) {
                    var sortpref = {
                        displayName: sortfields[i].label.text,
                        value: sortfields[i].name
                    };
                    if (sortfields[i].sort.order === '1') {
                        sortpref.defaultValue = sortfields[i].name;
                        sortpref.sortdir = !sortfields[i].sort.direction ? 'ascending' : sortfields[i].sort.direction;
                    }
                    sorts.push(sortpref);
                }
                return sorts;
            },
            //TODO document and move to FoundationData
            expandObject: function(widget, id, callback /*, levels*/ ) {
                var object = this.getObject(widget, id);
                if (object.children.length > 0) { //already have the children; return it.
                    callback.call(this, object.children);
                } else if (object.leaf || widget.datarecords.fixedLevels) { //leaf or already has been expanded to all levels.
                    //leaf object; no children; send empty list.
                    callback.call(this, []);
                } else { //retrieve the children from server.
                    var thisRequest = {
                            object: object,
                            callbackFunction: callback
                        },
                        widgetName = widget._parentExperience ? widget._parentExperience.name : widget.name,
                        url = FoundationData.tempURI(widgetName);
                    url += '?e6wAction=expand&expandId=' + object.objectId;
                    FoundationData.ajaxRequest({
                        url: url,
                        type: 'get',
                        dataType: 'json',
                        callback: function(data) {
                            if (!data.success) {
                                var strError = data.error;
                                throw (strError);
                            } else {
                                var children;
                                if (widget._parentExperience) { //when an experience/list is being expanded.
                                    children = data.widget.datarecords.datagroups;
                                    thisRequest.object.children = children;
                                    //needed to establish parent/child references.
                                    WidgetAPIs.getChildren(thisRequest.object, {
                                        checkFiltered: false,
                                        allLevels: true,
                                        fixedLevels: data.widget.datarecords.fixedLevels
                                    });
                                } else { //when a service is being expanded.
                                    children = data.datarecords.datagroups;
                                    thisRequest.object.children = children;
                                    //needed to establish parent/child references.
                                    WidgetAPIs.getChildren(thisRequest.object, {
                                        checkFiltered: false,
                                        allLevels: true,
                                        fixedLevels: data.datarecords.fixedLevels
                                    });
                                }
                                thisRequest.object.leaf = true; //mark object that we have already checked.
                                if (thisRequest.callbackFunction) {
                                    thisRequest.callbackFunction.call(this, thisRequest.object.children);
                                }
                            }
                        }
                    });
                }
            },
            getPreferenceValue: function(data, pref) {
                if (data.parentObj && data.parentObj.uwaWidget) {
                    return data.parentObj.uwaWidget.getValue(pref);
                }
                return false;
            },
            getPreference: function(data, pref) {
                if (data.parentObj && data.parentObj.uwaWidget) {
                    return data.parentObj.uwaWidget.getPreference(pref);
                }
                return false;
            },
            //        addPreference: function (data, prefObj) {
            //            if (data.parentObj && data.parentObj.uwaWidget) {
            //                prefObj.onchange = 'onForceRefresh';
            //                data.parentObj.uwaWidget.addPreference(prefObj);
            //                data.parentObj.uwaWidget.setValue(prefObj.name, prefObj.defaultValue);
            //                data.parentObj.uwaWidget.setValue('e6w-preference_' + prefObj.name, JSON.stringify(prefObj));
            //                data.parentObj.uwaWidget.addPreference({
            //                    name: 'e6w-preference_' + prefObj.name,
            //                    type: 'hidden',
            //                    value: JSON.stringify(prefObj)
            //                });
            //
            //                data.parentObj.uwaWidget.MyWidget.onForceRefresh(true);
            //            }
            //        },

            //start of private variables & functions.
            _dataContainers: ['list', 'channel', 'table', 'form'],
            __processCustomDraw: function(itemConfig, widgetTypeHierachy, objectData) {
                var result, errMessage = null;
                try {
                    if (typeof itemConfig.custom.scriptPath === 'string') {
                        errMessage = 'eval failed';
                        if (itemConfig.custom.scriptPath.indexOf('DS/') === 0) {
                            var elem = jQuery('<div></div>');
                            require([itemConfig.custom.scriptPath], function(myObj) {
                                elem.append(myObj.draw(itemConfig));
                            });
                            return elem;
                        } else { /* jshint evil: true */
                            itemConfig.custom.scriptSource = eval('(' + itemConfig.custom.scriptSource + ')');
                        }
                    }
                    errMessage = 'draw failed';
                    result = itemConfig.custom.scriptSource.draw(itemConfig, widgetTypeHierachy, objectData);
                } catch (err) {
                    result = '<span class="message">Error: ' + errMessage + '</span>';
                    if (errMessage === 'eval failed') {
                        itemConfig.custom.scriptSource = {
                            draw: function() {
                                return result;
                            }
                        };
                    }
                }
                if (typeof result === 'string') {
                    result = jQuery(result);
                }
                return jQuery('<div></div>').append(result);
            },
            hasOwn: Object.prototype.hasOwnProperty,
            //filter out prototype in 'for in' loops
            __drawWidget: function(containerConfig, widgetTypeHierachy, objectData, view, currentObjectContainer) { //containerConfig: json data from service;
                var firstrun = 200;

                var containerType = containerConfig.widgetType;
                if (!widgetTypeHierachy) {
                    widgetTypeHierachy = [];
                }
                if (view && this.isObjectContainer(containerType)) {
                    if (this.isObjectContainer(view.toLowerCase())) {
                        containerType = view.toLowerCase();
                    } else {
                        containerType = 'list';
                    }
                    containerConfig.widgetType = containerType;
                }
                widgetTypeHierachy.push(containerType);
                if (containerConfig.availableViews) {
                    var itemview = containerConfig.displayview;
                    if (!itemview) {
                        itemview = view;
                    }
                    if (!itemview || this.__findInArray(containerConfig.availableViews.view, itemview) === -1) {
                        view = containerConfig.availableViews.view[0];
                    } else {
                        view = itemview;
                    }
                }
                if (view) {
                    containerConfig.displayview = view;
                } else {
                    view = containerConfig.displayview;
                }
                var allLevels = !(containerType === 'table' || containerType === 'table_expand');
                var containerItems = this.getContainerItems(containerConfig); //get sub-widgets.
                var containerData = this.getContainerData(containerConfig, containerType, objectData, true, allLevels);
                var dataloop = 1;
                var htmlContainer = null;

                /**
                 * @param {Integer} start start
                 */
                function postInsertRows(start) {
                    var chunk = 10,
                        i = start || 0,
                        othis = this,
                        containerHTMLItems = [],
                        partialData = null;
                    //define a function for the dom.bind fall later on.  Avoid defining
                    var domBindCallback = function(event, data) {
                        var intRegex = /^\d+$/;
                        var size = parseInt(data.size, 10);
                        if (size && intRegex.test(size)) {
                            this.height(Math.min(size, parent.document.body.clientHeight - 35));
                        }
                    };
                    for (; i < Math.min((start + chunk), dataloop); i++) { //data loop.
                        objectData = containerData ? containerData[i] : objectData;
                        var containerObjectItems = [];
                        containerHTMLItems.push(containerObjectItems);
                        for (var j = 0; j < containerItems.length; j++) { //sub-widgets.
                            var itemConfig = containerItems[j];
                            var itemType = itemConfig.widgetType;
                            if (itemType === 'field') {
                                if (itemConfig.custom) {
                                    var returnObj = this.__processCustomDraw(itemConfig, widgetTypeHierachy, objectData);
                                    containerObjectItems.push(returnObj);
                                } else {
                                    containerObjectItems.push(this.drawFieldHTML(itemConfig, widgetTypeHierachy, objectData, currentObjectContainer));
                                }
                            } else if (itemType === 'location') { //location
                                var path = WidgetAPIs.processUrl(itemConfig, itemConfig);
                                var height = '';
                                //enoviaServer.widgetHeight = enoviaServer.widgetHeight || {};
                                if (itemConfig.style && itemConfig.style.height) {
                                    height = parseInt(itemConfig.style.height, 10);
                                }
                                if (enoviaServer.scMode) {
                                    path = path.replace('&SCMode=false', '&SCMode=true');
                                }
                                var locationDom = WidgetTemplate[itemType]({
                                    height: height,
                                    path: path
                                });
                                locationDom.bind('resize_me', domBindCallback);
                                containerObjectItems.push(locationDom);
                            } else { //container.
                                if (itemType === 'truecondition' || itemType === 'falsecondition') {
                                    if (!this.__checkTrueFalseCondition(currentObjectContainer, itemConfig, objectData, itemType === 'truecondition')) {
                                        continue;
                                    }
                                }
                                containerObjectItems.push(this.__drawWidget(itemConfig, widgetTypeHierachy, objectData, view, currentObjectContainer));
                            }
                        }
                    }
                    if (containerData && containerData.length > 0) {
                        partialData = containerData.slice(start, i);
                    }
                    htmlContainer = this.drawContainerHTML(containerConfig, widgetTypeHierachy, containerHTMLItems, partialData, objectData);
                    if (i < dataloop) {
                        containerConfig._timeout = setTimeout(function() {
                            postInsertRows.call(othis, i);
                        }, firstrun);
                        firstrun = 1;
                    }
                }



                if (containerData) {
                    dataloop = containerData.length;
                }

                if (this.isObjectContainer(containerType)) { //register as a widget
                    containerConfig.parentObj = this.engine;
                    containerConfig.parentObj.registerTN(containerConfig);
                    if (!currentObjectContainer) {
                        currentObjectContainer = containerConfig;
                    }
                }

                if (containerConfig.custom) {
                    htmlContainer = this.__processCustomDraw(containerConfig, widgetTypeHierachy, containerData);
                } else if (containerItems.length > 0) {
                    clearTimeout(containerConfig._timeout);
                    delete containerConfig._domElem; //remove pagination elem declared in WidgetEngine
                    postInsertRows.call(this, 0);
                } else if (containerType === 'experience') {
                    htmlContainer = WidgetTemplate[containerType]({
                        showLabel: this.engine.showLabel,
                        config: containerConfig
                    });
                } else {
                    htmlContainer = WidgetTemplate.generic();
                }

                if (containerData && containerConfig.charts.length > 0) {
                    var charts = this.__drawCharts(containerConfig, containerData, containerConfig.charts, containerConfig.displayview);
                    if (charts.length > 0) {
                        var dom = WidgetTemplate.chartgroup({
                            type: 'chartgroup',
                            layout: 'vertical'
                        });
                        for (var j = 0; j < charts.length; j++) {
                            dom.append(charts[j]);
                        }
                        htmlContainer = dom.append(htmlContainer);
                    }
                }

                if (this.isObjectContainer(containerType)) { //pointer to this widget's container
                    if (containerConfig.parentObj.uwaWidget && !containerConfig.custom && (this.__findInArray(['list', 'table'], containerType) !== -1)) {
                        htmlContainer = WidgetTemplate.container({
                            type: 'table-container'
                        }).append(htmlContainer);
                    }
                    var origElem = htmlContainer;
                    htmlContainer = WidgetTemplate.generic().append(htmlContainer);
                    if (!containerConfig.custom) {
                        if (containerConfig.parentObj.uwaWidget) {
                            if (containerType === 'channel') {
                                origElem.css('overflow', 'visible');
                            }
                            UWA.extendElement(origElem[0]);
                            var scrollParams = {};
                            new UWA.Controls.Scroller(origElem[0], scrollParams);
                            setTimeout(function() {
                                //throws exception if require fails synchronous load
                                var WidgetUwaUtils = require('DS/Foundation/WidgetUwaUtils');
                                WidgetUwaUtils.setWidgetHeight();
                            }, 1);
                        } else {
                            if (containerType !== 'channel' && containerConfig.style && containerConfig.style.height) {
                                htmlContainer.addClass('table-scroll');
                                htmlContainer.css('height', containerConfig.style.height);
                            }
                            if (containerType !== 'channel' && parseInt(htmlContainer.css('height'), 10) === 0) {
                                htmlContainer.css({
                                    position: 'relative',
                                    height: '300px',
                                    overflow: 'auto'
                                });
                            }
                        }
                    }
                }
                containerConfig.container = htmlContainer; //needed for re-draw/refresh.
                widgetTypeHierachy.pop();
                return htmlContainer;
            },
            __checkTrueFalseCondition: function(widget, ifconfig, objectData, condition) {
                var iffield = ifconfig.field,
                    ifvalue = ifconfig.value,
                    ifcheck = false,
                    fieldConfig = WidgetAPIs.getField(widget, iffield);
                if (fieldConfig) {
                    var values = WidgetAPIs.getFieldData(fieldConfig, objectData);
                    if (values.length === 0 && !condition) {
                        ifcheck = true;
                    }
                    for (var k = 0; k < values.length; k++) {
                        var fieldvalue = values[k].actualValue || values[k].value;
                        if (ifvalue) {
                            if ((ifvalue !== fieldvalue && !condition) || //for false condition, we may need to check all values.
                                (ifvalue === fieldvalue && condition)) {
                                ifcheck = true;
                                break;
                            }
                        } else {
                            if (((!fieldvalue || fieldvalue === '' || fieldvalue.toLowerCase() === 'false') && !condition) || //line too long
                                ((fieldvalue && fieldvalue !== '' && fieldvalue.toLowerCase() !== 'false') && condition)) {
                                ifcheck = true;
                                break;
                            }
                        }
                    }
                }
                return ifcheck;
            },
            //what is the difference with the built in indexOf
            //TODO replace by indexOf
            __findInArray: function(arr, item) { //find an item in an array
                return arr.indexOf(item);
                //            var len = arr.length;
                //            for (var i = 0; i < len; i++) {
                //                if (arr[i] === item) {
                //                    return i;
                //                }
                //            }
                //            return -1;
            },
            __getAutoFilterFields: function(objJson, autoFilterFields) {
                if (!objJson) {
                    return [];
                }
                var topStack = false;
                if (!autoFilterFields) {
                    autoFilterFields = objJson._autoFilterFields;
                    if (autoFilterFields) {
                        return autoFilterFields;
                    }
                    topStack = true;
                    autoFilterFields = [];
                }
                var items = this.getContainerItems(objJson, true);
                for (var i = 0; i < items.length; i++) {
                    var itemConfig = items[i];
                    var itemType = itemConfig.widgetType;
                    if (itemType === 'field' || itemType === 'tag') {
                        if (itemConfig.selectable && itemConfig.selectable.filterable && itemConfig.selectable.sixw) {
                            autoFilterFields.push(itemConfig);
                        }
                    } else { //container.
                        this.__getAutoFilterFields(itemConfig, autoFilterFields);
                    }
                }
                if (topStack) {
                    objJson._autoFilterFields = autoFilterFields; //cache fields
                }
                return autoFilterFields;
            },
            __appendTagData: function(object, tagObject) { //combine tag data from service to widget data.
                this.appendFieldData(object, tagObject, true);
            },
            __appendTagConfig: function(containerConfig, TagConfig) { //combine tag data from service to widget data.
                var widgetItems = this.getContainerItems(containerConfig, true);
                var tagItems = this.getContainerItems(TagConfig, true);
                widgetItems = widgetItems.concat(tagItems);
                delete containerConfig.widget;
                containerConfig.widgets = widgetItems;
            },
            __setRowFilter: function(widgetRoot, row, bAutoFiltered, bSearchFiltered) {
                var isRowFiltered = Boolean(row.filtered);
                row.autoFiltered = bAutoFiltered === false || bAutoFiltered ? bAutoFiltered : row.autoFiltered;
                row.bSearchFiltered = bSearchFiltered === false || bSearchFiltered ? bSearchFiltered : row.bSearchFiltered;
                if (row.autoFiltered || row.bSearchFiltered) {
                    if (!isRowFiltered) {
                        row.filtered = true;
                        widgetRoot.countSummary && widgetRoot.countSummary.shown--;
                    }
                } else {
                    if (isRowFiltered) {
                        row.filtered = false;
                        widgetRoot.countSummary && widgetRoot.countSummary.shown++;
                    }
                    this.__showParent(widgetRoot, row);
                }
            },
            __showParent: function(widgetRoot, childObject) {
                if (childObject._parentObject && childObject._parentObject.filtered) {
                    childObject._parentObject.filtered = false;
                    widgetRoot.countSummary && widgetRoot.countSummary.shown++;
                    this.__showParent(widgetRoot, childObject._parentObject);
                }
            },
            __getSortableFields: function(widgetRoot, clearSortPreference) { //returns a list of sort fields.
                var sortFieldList = [];
                var fieldIndexCache = this.__getAllFields(widgetRoot);
                for (var key in fieldIndexCache) {
                    if (WidgetAPIs.hasOwn.call(fieldIndexCache, key)) {
                        var field = fieldIndexCache[key];
                        if (field.sort && field.sort.sortable) {
                            if (field.sort.type) {
                                field.sort.type = field.sort.type.toLowerCase();
                            } else {
                                field.sort.type = 'string';
                            }
                            if (clearSortPreference) {
                                delete field.sort.order;
                            }
                            if (!field.label || !field.label.text) {
                                field.label = {
                                    text: field.name,
                                    show: 'none'
                                };
                            }
                            sortFieldList.push(field);
                        }
                    }
                }
                return sortFieldList;
            },
            __getField: function(widgetRoot, fieldName) { //get field by name.
                var fieldIndexCache = this.__getAllFields(widgetRoot);
                return fieldIndexCache[fieldName];
            },
            __getAllFields: FoundationData.getAllFields,
            __sortWidget: function(widgetRoot, sortList /* {name: 'field name', direction: 'ascending/descending'}, */ ) {
                if (!widgetRoot || !sortList) {
                    return;
                }
                //clear previous sort preference.
                this.__getSortableFields(widgetRoot, true); //clear previous sort preference.
                var fieldList = [];
                for (var i = 0; i < sortList.length; i++) {
                    var field = this.__getField(widgetRoot, sortList[i].name);
                    if (field && field.sort && field.sort.sortable) {
                        var dir = sortList[i].direction && sortList[i].direction.toLowerCase() === 'descending' ? -1 : 1; //1=ascending; -1=descending.
                        fieldList.push(field);
                        field.sort.direction = sortList.direction;
                        field.sort.dir = dir;
                        field.sort.order = fieldList.length;
                    }
                }
                if (fieldList.length === 0) {
                    return;
                }
                var rows = [];
                var data = widgetRoot.datarecords;
                if (data) {
                    rows = data.datagroups;
                }
                this.__sortDatarecords(fieldList, rows);
            },
            __sortDatarecords: function(fieldList, rows) {
                if (!rows || rows.length === 0) {
                    return;
                }
                for (var i = 0; i < rows.length; i++) {
                    var children = rows[i].children;
                    this.__sortDatarecords(fieldList, children);
                }
                var thisSortPref = {
                    fieldList: fieldList
                };
                var sortObjects = function(dataObjectA, dataObjectB) {
                    return WidgetAPIs.__compareObjects(dataObjectA, dataObjectB, thisSortPref);
                };
                rows.sort(sortObjects);
            },
            __compareObjects: function(dataObjectA, dataObjectB, thisSortPref) {
                var fieldList = thisSortPref.fieldList;
                var direction = 0;
                var difference = 0;
                for (var i = 0; i < fieldList.length; i++) {
                    var field = fieldList[i];
                    var values1 = this.getFieldData(field, dataObjectA);
                    var values2 = this.getFieldData(field, dataObjectB);

                    var lenA = values1 ? values1.length : 0;
                    var lenB = values2 ? values2.length : 0;

                    if (lenA === 0 && lenB === 0) {
                        continue;
                    } else if (lenA === 0) {
                        difference = -1;
                    } else if (lenB === 0) {
                        difference = 1;
                    } else { //check values.
                        var loop = lenA > lenB ? lenA : lenB;
                        for (var j = 0; j < loop; j++) {
                            var valueObj1 = values1[j];
                            var valueObj2 = values2[j];
                            var value1 = valueObj1.sortValue;
                            var value2 = valueObj2.sortValue;
                            if (!value1) {
                                value1 = field.sort.type !== 'date' ? valueObj1.value : valueObj1.actualValue;
                                value1 = value1 ? value1 = value1.toLowerCase() : '';
                            }
                            if (!value2) {
                                value2 = field.sort.type !== 'date' ? valueObj2.value : valueObj2.actualValue;
                                value2 = value2 ? value2 = value2.toLowerCase() : '';
                            }
                            if (field.sort.type === 'string') {
                                if (value1 !== value2) {
                                    difference = value1 > value2 ? 1 : -1;
                                }
                            } else if (field.sort.type === 'stringpad') {
                                difference = value1.length() - value2.length();
                                if (difference === 0) {
                                    difference = value1 > value2 ? 1 : -1;
                                }
                            } else {
                                if (value1 !== value2) {
                                    difference = parseFloat(value1) > parseFloat(value2) ? 1 : -1;
                                }
                            }
                            if (difference !== 0) {
                                break;
                            }
                        }
                    }
                    if (difference !== 0) {
                        direction = field.sort.dir;
                        break;
                    }
                }
                return difference * direction;
            },
            __drawCharts: function dummyDrawChartUntilWidgetChartIsLoaded() {
                return [];
            },

            isObjectEditable: function(widget, id /*id or object*/ ) {
                if (widget.datarecords && widget.datarecords.editLink) {
                    var object = WidgetAPIs.getObject(widget, id);
                    if (!object.editable) {
                        return false;
                    } else {
                        return true;
                    }
                }
                return false;
            }

        };
        //alias this method as it really is retrieving security contexts not collabspaces.  But keep the old one for compatibility
        WidgetAPIs.getSecurityContexts = WidgetAPIs.getCollaborativeSpaces;
        require(['DS/Foundation/WidgetChart'], function defineDrawChart(WidgetChart) {
            WidgetAPIs.__drawCharts = function replacedDrawChart(widget, widgetData, chartsConfig, view) {
                var containerHTMLCharts = [];

                for (var i = 0; i < chartsConfig.length; i++) {
                    var itemConfig = chartsConfig[i];
                    var itemType = itemConfig.widgetType;
                    var itemView = itemConfig.view;
                    if ((view === itemView || !itemView) && !itemConfig.hidden) {
                        if (itemType === 'chart') {
                            containerHTMLCharts.push(WidgetChart.drawChart(widget, widgetData, itemConfig));
                        } else { //chart container.
                            var containerList = this.__drawCharts(widget, widgetData, itemConfig.charts, view);
                            containerHTMLCharts.push(this.drawContainerHTML(itemConfig, [], containerList, null));
                        }
                    }
                }

                return containerHTMLCharts;
            };
        });
        window.WidgetAPIs = WidgetAPIs; //bcc: for now we still have to do this to get around circular dependencies with WidgetEngine
        return WidgetAPIs;
    });

/*
 * Widget Save APIs
 * WidgetSave.js
 * version 1.4
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 *
 */
/*global define*/
define("DS/Foundation/WidgetSave", ["DS/Foundation/WidgetAPIs", 'DS/ENO6WPlugins/jQuery_3.3.1', 'DS/Foundation/FoundationData'], function (WidgetAPIs, jQuery, FoundationData) {
    'use strict';
    var WidgetSave = {
        loadObjects: FoundationData.loadObjects,
        //external functions are stubbed out
        unloadObjects: FoundationData.unloadObjects,
        addObject: FoundationData.addObject,
        addRelatedObject: FoundationData.addRelatedObject,
        connectObject: FoundationData.connectObject,
        disconnectObject: FoundationData.disconnectObject,
        modifyObject: FoundationData.modifyObject,
        modifyRelatedObject: FoundationData.modifyRelatedObject,
        cancelObject: FoundationData.cancelObject,
        deleteObject: FoundationData.deleteObject,
        isDirty: FoundationData.isDirty,
        deleteRelatedObject: FoundationData.deleteRelatedObject,
        applyUpdates: FoundationData.applyUpdates,
        connectRelatedObject: FoundationData.connectRelatedObject,
        disconnectRelatedObject: FoundationData.disconnectRelatedObject
    };


    jQuery.extend(WidgetAPIs, WidgetSave);
    return WidgetSave;
});

/*
 * Widget Preferences
 * WidgetPreferences.js
 * version 1.2
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 * WidgetPreferences Object
 * this file contains all the runtime logic for BPS widget preferences
 *
 * Requires:
 * jQuery v1.8.3 or later
 *
 */
/* global define */
/* global WidgetConstants */
/* global WidgetEngine */
define('DS/Foundation/WidgetPreferences', ['DS/Foundation/WidgetAPIs', 'DS/ENO6WPlugins/jQuery_3.3.1'], function (WidgetAPIs, jQuery) {
    "use strict";
    var WidgetPreferences = {

        template: {
            container: function () {
                return jQuery('<div class="pref-form"></div>');
            },
            gear: function (obj) {
                var othis = this,
                    userViews = WidgetAPIs.getWidgetViews(obj.config),
                    sortFields = WidgetAPIs.getSortableFields(obj.config.widget);
                if (userViews.length === 0 && sortFields.length === 0) {
                    return;
                }
                return jQuery('<span class="fonticon handler fonticon-down-open" title="' + WidgetConstants.str.Preferences + '"/>').click(

                    function (e) {
                        e.stopPropagation();
                        var parent = jQuery(this).parent().parent().parent(),
                            prefPane = jQuery('.pref-form', parent);

                        if (prefPane.length === 0) {
                            prefPane = othis.container();
                            prefPane.append(
                                othis.buildPreferences(obj, userViews, sortFields)).hide();
                            parent.append(prefPane); // add to
                            // end as
                            // initial
                            // child is
                            // the
                            // sectional
                            // expand/collapse.
                        }

                        prefPane.css({
                            'left': jQuery(this).offset().left - prefPane.children('.preference-menu').width(),
                            'top': jQuery(this).height()
                        });
                        prefPane.toggle();
                    });
            },
            menu: function () {
                return jQuery('<div class="preference-menu"></div>');
            },
            head: function () {
                return jQuery('<div class="preference-menu-head"></div>');
            },
            body: function (obj, views, sorts) {
                return jQuery('<div class="preference-menu-body"></div>').append(this.bodyContent(obj, views, sorts));
            },
            bodyContent: function (obj, views, sorts) {
                return jQuery('<div class="preference-menu-body-content"></div>').append(
                    this.viewContent(
                        views, WidgetAPIs.getWidgetViewPreference(obj.config))).append(this.sortingHeader(sorts)).append(
                    this.sortingContent(sorts));
            },
            viewContent: function (views, displayView) {
                var viewContent;

                if (views.length > 0) {
                    viewContent = jQuery('<div class="preference-attr"></div>');
                    viewContent.append(this.viewOptions(views, displayView));
                }

                return (viewContent);
            },
            viewOptions: function (views, displayView) {
                var viewOptions = jQuery('<div class="preference-attr-body">' + WidgetConstants.str.Views + '</div>');
                var viewSelect = jQuery('<select class="select_view"></select>');
                for (var i = 0; i < views.length; i++) {
                    viewSelect.append('<option value="' + views[i].value + '">' + WidgetConstants.str[views[i].value] + '</option>');
                }

                if (displayView) {
                    viewSelect.val(displayView);
                }

                return (viewOptions.append(viewSelect));
            },
            sortingHeader: function (sorts) {
                var sortHeader;

                if (sorts.length > 0) {
                    sortHeader = jQuery('<div class="menu-title">' + WidgetConstants.str.Sorts + '</div>');
                }

                return (sortHeader);
            },
            sortingContent: function (sorts) {
                var sortContent;

                if (sorts.length > 0) {
                    sortContent = jQuery('<div class="preference-attr"></div>');
                    var sortField = jQuery('<select class="select_sortfield"></select>');
                    for (var i = 0; i < sorts.length; i++) {
                        sortField.append('<option value="' + sorts[i].value + '">' + sorts[i].displayName + '</option>');
                    }

                    sortContent.append(sortField).append(
                        this.sortOptions(sorts[0]));
                }
                return (sortContent);
            },
            sortOptions: function (sort) {
                var sortOptions = jQuery('<select class="select_sortdirection"></select>');
                var direction = sort.sortdir;
                sortOptions.append('<option value="ascending">' + WidgetConstants.str.SortAscending + '</option>');
                sortOptions.append('<option value="descending">' + WidgetConstants.str.SortDescending + '</option>');
                if (direction) {
                    sortOptions.val(direction);
                }

                return (sortOptions);
            },
            footer: function () {
                var apply = jQuery('<button class="apply">' + WidgetConstants.str.Apply + '</button>');
                var cancel = jQuery('<button class="cancel">' + WidgetConstants.str.Cancel + '</button>');
                return jQuery('<div class="preference-menu-foot"></div>').append(apply).append(cancel);
            },
            noPreferences: function () {
                var cancel = jQuery('<button class="cancel">' + WidgetConstants.str.Cancel + '</button>');
                return jQuery('<div class="preference-menu"></div>').append(WidgetConstants.str.NoPreferences).append(
                    jQuery('<div class="preference-menu-foot"></div>').append(cancel));
            },
            buildPreferences: function (obj, userViews, sortFields) {
                var oobj = obj;
                var menu;

                if ((userViews && userViews.length > 0) || (sortFields && sortFields.length > 0)) {
                    menu = this.menu();
                    menu.append(this.head());
                    menu.append(this.body(obj, userViews, sortFields));
                    menu.append(this.footer());
                } else {
                    menu = this.noPreferences();
                }

                jQuery(".apply", menu).click(

                    function () {
                        var view,
                            sortField,
                            sortDirection;
                        jQuery('select', menu).each(

                            function () {
                                var name = jQuery(
                                    this).attr('class');
                                var value = jQuery(
                                    this).val();
                                if (name === "select_view") {
                                    view = value;
                                } else if (name === "select_sortfield") {
                                    sortField = value;
                                } else if (name === "select_sortdirection") {
                                    sortDirection = value;
                                }
                            });

                        if (view) {
                            WidgetAPIs.setWidgetViewPreference(
                                oobj.config, view);
                        }

                        if (sortField && sortDirection) {
                            var sorts = [];
                            sorts.push({
                                'name': sortField,
                                'direction': sortDirection
                            });
                            WidgetAPIs.sortWidget(
                                oobj.config.widget, sorts);
                        }

                        menu.parent().toggle();
                        WidgetEngine.reDrawWidget(
                            oobj.config.widget, view);
                    });
                jQuery(".cancel", menu).click(function () {
                    menu.parent().toggle();
                });

                return (menu);
            }
        },
        buildPreferences: function (obj) {
            // Register window event to close the preference menus if clicked
            // anywhere else
            if(!window.initializedWidgetPreferences) {
        	jQuery(window).click(function (e) {
                    var menu = jQuery(e.target).closest('.pref-form');
                    if (menu.length === 0) {
                        jQuery('div.pref-form:visible').hide();
                    }
                });
                window.initializedWidgetPreferences = true;
            }
            return (this.template.gear(obj));
        }
    };


    //breaking circular dependencies with WidgetTemplate
    window.WidgetPreferences = WidgetPreferences;
    return WidgetPreferences;
});

/*
 * Widget chart APIs
 * WidgetChart.js
 * version 1.0
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 *
 */
/* global define */
/* global WidgetConstants */
define("DS/Foundation/WidgetChart", [
    //"DS/ENO6WPlugins/Highcharts", //bcc for demo
    'DS/3DXHighcharts/3DXHighcharts',
    "DS/Foundation/WidgetAPIs",
    "DS/ENO6WPlugins/jQuery"
], function(Highcharts, WidgetAPIs, jQuery) {
    "use strict";
    var WidgetChart = {
        drawChart: function (widget, objects, chartConfig) {
            var groupByFields = chartConfig.groupBy;

            if (typeof chartConfig._validatedFields === "undefined") {
                for (var j = 0; j < groupByFields.length; j++) { //ensure all fields are valid.
                    var groupBy = groupByFields[j];
                    var fieldConfig = WidgetAPIs.getField(widget, groupBy);
                    if (!fieldConfig) {
                        if (j + 1 === groupByFields.length) {
                            groupByFields = groupByFields.slice(0, j);
                        } else {
                            var temp = groupByFields.slice(0, j).concat(groupByFields.slice(j + 1));
                            groupByFields = temp;
                            j--;
                        }
                        continue;
                    }
                }
                chartConfig.groupBy = groupByFields;
                // check to see the validity of calculation field if defined/specified
                var nlsCalculationField = null,
                    calculationObj = chartConfig.calculation,
                    calculationFieldConfig = null;

                if (typeof calculationObj !== "undefined") {
                    calculationFieldConfig = WidgetAPIs.getField(widget, calculationObj.field);
                    if (!calculationFieldConfig || !calculationObj.type) {
                        delete chartConfig.calculation;
                    } else {
                        nlsCalculationField = calculationFieldConfig.label.text;
                        chartConfig.calculation._field = calculationFieldConfig;
                        chartConfig.calculation._tipCalculationFieldName = nlsCalculationField;
                    }
                }
                chartConfig._validatedFields = true;
            }

            var chartData = {},
                uniqueCategories2 = {};

            //loop through all objects and start grouping field values.
            for (var i = 0; i < objects.length; i++) {
                var category = chartData;
                var objectData = objects[i];
                var calFieldConfigValue = null;

                if (chartConfig.calculation) {
                    var calFieldConfigValues = WidgetAPIs.getFieldData(chartConfig.calculation._field, objectData);
                    calFieldConfigValue = parseFloat(calFieldConfigValues[0].value);
                }

                for (var j = 0; j < groupByFields.length; j++) {
                    var increment = null;
                    if (j + 1 === groupByFields.length) {
                        increment = 1;
                    }
                    var groupBy = groupByFields[j];
                    var fieldConfig = WidgetAPIs.getField(widget, groupBy);
                    var values = WidgetAPIs.getFieldData(fieldConfig, objectData);

                    for (var k = 0; k < values.length; k++) {
                        var value = values[k].value;
                        if (!value) {
                            value = "Unspecified";
                        }
                        if (increment) {
                            if (j !== 0 && typeof uniqueCategories2[value] === "undefined") {
                                uniqueCategories2[value] = value;
                            }
                            if (typeof category[value] === "undefined") {
                                category[value] = {};
                                category[value].count = increment;
                                if (typeof chartConfig.calculation !== "undefined") {
                                    category[value].SUM = calFieldConfigValue;
                                    category[value].MINIMUM = calFieldConfigValue;
                                    category[value].MAXIMUM = calFieldConfigValue;
                                }
                            } else {
                                category[value].count += increment;

                                if (typeof chartConfig.calculation !== "undefined") {
                                    category[value].SUM = category[value].SUM + calFieldConfigValue;
                                    category[value].MINIMUM = (category[value].MINIMUM > calFieldConfigValue) ? calFieldConfigValue : category[value].MINIMUM;
                                    category[value].MAXIMUM = (category[value].MAXIMUM < calFieldConfigValue) ? calFieldConfigValue : category[value].MAXIMUM;
                                }
                            }
                        } else {
                            if (typeof category[value] === "undefined") {
                                category[value] = {};
                            }
                            category = category[value];
                        }
                    }
                }
            }

            var series = [];
            var categoryItems1 = this.getKeys(chartData);
            var categoryItems2 = this.getKeys(uniqueCategories2);

            var getColor = {
                'past due': '#FF0000',
                'due today': '#FFFF00',
                'due tomorrow': '#0000FF',
                'due this week': '#00FFFF',
                'due future': '#00FF00',
                'no date': '#000000'
            };

            if (categoryItems2.length === 0) {
                var data = [];
                for (var i in chartData) {
                    if (chartData.hasOwnProperty(i)) {
                        var value = {};
                        value.name = i;

                        if (typeof chartConfig.calculation !== "undefined") {
                            chartData[i].AVERAGE = chartData[i].SUM / chartData[i].count;
                            value.y = chartData[i][chartConfig.calculation.type];
                            value.count = chartData[i].count;
                            value.calculationData = this.setCalculationFieldData(chartConfig, chartData[i]);
                        } else {
                            value.y = chartData[i].count;
                        }
                        // start - for specifying specific color to each pie
                        if (typeof getColor[i.toLowerCase()] !== "undefined") {
                            value.color = getColor[i.toLowerCase()];
                        }
                        data.push(value);
                    }
                }

                var seriesName = WidgetConstants.str.Items; 
                if (typeof chartConfig.calculation !== "undefined") {
                	seriesName = chartConfig.calculation._field.label.text + " (" + WidgetConstants.str[chartConfig.calculation.type] + ")";
                }                	
                series.push({
                    name: seriesName,
                    data: data
                });
            } else {
                for (var i = 0; i < categoryItems2.length; i++) {
                    var category2 = categoryItems2[i];
                    var data = [];
                    for (var j = 0; j < categoryItems1.length; j++) {
                        var category1 = categoryItems1[j];
                        var value = {};
                        value.name = category1;

                        if (typeof chartData[category1][category2] === "undefined") {
                            value.y = 0;
                            value.count = 0;
                        } else {
                            if (typeof chartConfig.calculation !== "undefined") {
                                chartData[category1][category2].AVERAGE = chartData[category1][category2].SUM / chartData[category1][category2].count;
                                value.y = chartData[category1][category2][chartConfig.calculation.type];
                                value.count = chartData[category1][category2].count;
                                value.calculationData = this.setCalculationFieldData(chartConfig, chartData[category1][category2]);
                            } else {
                                value.y = chartData[category1][category2].count;
                            }
                        }
                        data.push(value);
                    }

                    series.push({
                        name: category2,
                        data: data
                    });
                }
            }
            return this.draw(categoryItems1, series, chartConfig, widget);
        },
        setCalculationFieldData: function (chartConfig, chartData) {
            var calculationData = {};
            if (typeof chartConfig.calculation !== "undefined") {
                calculationData.SUM = this.setCalculationField(chartConfig, chartData, "SUM");
                calculationData.AVERAGE = this.setCalculationField(chartConfig, chartData, "AVERAGE");
                calculationData.MINIMUM = this.setCalculationField(chartConfig, chartData, "MINIMUM");
                calculationData.MAXIMUM = this.setCalculationField(chartConfig, chartData, "MAXIMUM");
            } else {
                calculationData = null;
            }

            return calculationData;
        },
        setCalculationField: function (chartConfig, chartData, type) {
            var calculationDataType = {};
            calculationDataType.label = WidgetConstants.str[type];
            calculationDataType.value = chartData[type];
            calculationDataType.selected = (chartConfig.calculation.type === type) ? "true" : "false";
            return calculationDataType;
        },
        getMainTitle: function (chartConfig) {
            var mainTitle = null;
            if (typeof chartConfig.label !== "undefined") {
                mainTitle = chartConfig.label.text;
            }
            return mainTitle;
        },
        getSubTitle: function (chartConfig) {
            var subHeader = null;
            if (typeof chartConfig.subHeader !== "undefined") {
                subHeader = chartConfig.subHeader.text;
            }
            return subHeader;
        },
        getXaxisTitle: function (chartConfig, widget) {
            var xAxisTitle = "";
            var groupByFields = chartConfig.groupBy;
            for (var j = 0; j < groupByFields.length; j++) {
                var groupBy = groupByFields[j];
                var fieldConfig = WidgetAPIs.getField(widget, groupBy);
                if (j === 0) {
                    xAxisTitle = fieldConfig.label.text;
                } else {
                    xAxisTitle += " / " + fieldConfig.label.text;
                }
            }
            return xAxisTitle;
        },
        getYaxisTitle: function (chartConfig) {
            var yAxisTitle = WidgetConstants.str.Items;
            if (typeof chartConfig.calculation !== "undefined") {
                yAxisTitle = chartConfig.calculation._field.label.text + " <B>(" + WidgetConstants.str[chartConfig.calculation.type] + ")</B>";
            }
            return yAxisTitle;
        },
        getKeys: function (object) {
            var list = [];
            for (var key in object) {
                if (object.hasOwnProperty(key)) {
                    list.push(key);
                }
            }
            //sort list.
            // list = list.sort();
            return list;
        },
        html: function () {
            return jQuery('<div id="' + this.getId() + '"/>').width("100%");
        },
        getId: function () {
            return "dsCHART_" + Math.random();
        },
        draw: function (categories, series, chartConfig, widget) {

            var chartData = {
                chart: {
                    type: chartConfig.type.toLowerCase(),
                },
                title: {
                    text: this.getMainTitle(chartConfig)
                },
                subtitle: {
                    text: this.getSubTitle(chartConfig)
                },
                tooltip: {
                    useHTML: true,
                    borderWidth: 0,
                    style: {
                        padding: 0
                    },
                    formatter: function () {
                        var tip = null;

                        if (typeof chartConfig.calculation !== "undefined") {
                            tip = "<div style='padding: 2px; border-bottom: 2px solid #000000'>";
                            tip += this.series.name + ":<b>" + this.point.y + "</b>";
                            tip += "<br>" + WidgetConstants.str.Items + ":<b>" + this.point.count + "</b>";
                            tip += "</div>";

                            if (this.point.calculationData) {
                                tip += "<div style='padding: 2px;'>";
                                if (this.point.calculationData.SUM.selected === "false") {
                                    tip += "<div>" + chartConfig.calculation._tipCalculationFieldName + "  (" + this.point.calculationData.SUM.label + ") <b>" + this.point.calculationData
                                        .SUM.value + "</b></div>";
                                }
                                if (this.point.calculationData.AVERAGE.selected === "false") {
                                    tip += "<div>" + chartConfig.calculation._tipCalculationFieldName + "  (" + this.point.calculationData.AVERAGE.label + ") <b>" + this.point
                                        .calculationData.AVERAGE.value + "</b></div>";
                                }
                                if (this.point.calculationData.MAXIMUM.selected === "false") {
                                    tip += "<div>" + chartConfig.calculation._tipCalculationFieldName + "  (" + this.point.calculationData.MAXIMUM.label + ") <b>" + this.point
                                        .calculationData.MAXIMUM.value + "</b></div>";
                                }
                                if (this.point.calculationData.MINIMUM.selected === "false") {
                                    tip += "<div>" + chartConfig.calculation._tipCalculationFieldName + "  (" + this.point.calculationData.MINIMUM.label + ") <b>" + this.point
                                        .calculationData.MINIMUM.value + "</b></div>";
                                }
                                tip += "</div>";
                            }
                        } else {
                            tip = "<div style='padding: 2px;'>";
                            tip += this.point.name + "<br>";
                            tip += this.series.name + ":" + this.point.y;
                            tip += "</div>";
                        }
                        return tip;
                    }
                },
                xAxis: {
                    categories: categories,
                    labels: {
                        rotation: categories.length > 5 ? -45 : undefined //rotate labels when there are too many so they don't overlap.
                    },
                    title: {
                        text: this.getXaxisTitle(chartConfig, widget)
                    }
                },
                yAxis: {
                    title: {
                        text: this.getYaxisTitle(chartConfig)
                    }
                },
                plotOptions: {
                    column: {
                        allowPointSelect: true,
                        cursor: 'pointer',
                        dataLabels: {
                            enabled: true //when there is a large scale difference in size, it is best to display labels.
                        },
                        states: {
                            hover: {
                                borderColor: '#000000',
                                borderWidth: 2
                            }
                        }
                    },
                    bar: {
                        allowPointSelect: true,
                        cursor: 'pointer',
                        dataLabels: {
                            enabled: true //when there is a large scale difference in size, it is best to display labels.
                        },
                        states: {
                            hover: {
                                borderColor: '#000000',
                                borderWidth: 2
                            }
                        }
                    },
                    pie: {
                        allowPointSelect: true,
                        cursor: 'pointer',
                        dataLabels: {
                            enabled: false,
                            color: '#000000',
                            format: '<b>{point.name}</b>: {point.percentage:.1f} %'

                        },
                        states: {
                            hover: {
                                borderColor: '#000000',
                                borderWidth: 2
                            }
                        },
                        showInLegend: true
                    }
                },
                credits: {
                    enabled: false
                }, // to suppress highcharts.com display on right bottom
                series: series
            };

            var ctnr = this.html();
            chartData.chart.renderTo = ctnr[0];
            setTimeout(function () {
                new Highcharts.Chart(chartData);
            }, 1);
            return ctnr;

        }
    };
    if (typeof window !== 'undefined') {
        window.WidgetChart = WidgetChart;
    }
    return WidgetChart;
});

/**
 * Implementation of the Tag Navigator component for BPS widgets
 * WidgetTagNavInit.js version 0.0.8
 *
 * Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved. This program
 * contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only and does not evidence any actual or
 * intended publication of such program
 * ------------------------------------------------------------------------
 * WidgetTagNavInit Object Controls filtering of widget data via 6W tagger
 *
 * Requires: jQuery v2.0 or newer
 */
/*global define, require*/
/*global enoviaServer*/
define(
    'DS/Foundation/WidgetTagNavInit', ['DS/E6WCommonUI/WidgetUtils', 'DS/ENO6WPlugins/jQuery_3.3.1', 'DS/Foundation/FoundationData', 'DS/Foundation/WidgetAPIs'],
    function(WidgetUtils, jQuery, FoundationData, WidgetAPIs) {
        'use strict'; //need to know if tags should be a local or global variable
        var WidgetTagNavInit = {
            tnWin: null,
            loadTagData: function(widgetRoot) {
                if (!this.tnWin) {
                    return;
                }

                var rows = WidgetAPIs.getContainerData(widgetRoot, null,
                    null, false, true);
                var postData = this.getTagPostData(widgetRoot, rows);
                if (!postData && postData === "") {
                    return;
                }

                var thisTagRequest = {
                    widgetRoot: widgetRoot,
                    rows: rows
                };

                var loadTagDataDone = function(data) {
                    var tagData = data ? data.widgets : null;
                    if (!tagData || tagData.length === 0) {
                        return;
                    }
                    require(
                        ['DS/TagNavigatorProxy/TagNavigatorProxy', 'DS/Foundation/WidgetEngine'],
                        function(TagNavigatorProxy, WidgetEngine) {
                            WidgetTagNavInit.register(
                                thisTagRequest.widgetRoot,
                                TagNavigatorProxy);
                            WidgetTagNavInit.processTagData(
                                thisTagRequest.widgetRoot,
                                tagData[0], thisTagRequest.rows);
                            if (postData.indexOf("isPhysicalIds=false") !== -1) {
                                // if data does not contain physicalids,
                                // then refresh view to enable rows
                                // selections based on physical ids.
                                WidgetEngine.reDrawWidget(widgetRoot);
                            }
                            WidgetTagNavInit.drawTags(thisTagRequest.widgetRoot);
                        });
                };

                var tagURL = "/resources/e6w/servicetagdata";
                FoundationData.ajaxRequest({
                    url: tagURL,
                    type: 'post',
                    dataType: 'json',
                    data: postData,
                    callback: loadTagDataDone
                });
            },
            keywordSearch: function(widgetRoot, searchStr,
                callbackFunction) {
                var rows = WidgetAPIs.getContainerData(widgetRoot, null,
                    null, false, true); // get all data records
                // regardless of filter.
                // undo previous search.
                WidgetTagNavInit.__undoFilters(widgetRoot, rows);
                if (searchStr && searchStr !== "") {
                    var postData = WidgetTagNavInit.getTagPostData(
                        widgetRoot, rows);
                    if (postData && postData === "") {
                        widgetRoot.nonObjectBased = true;
                        return;
                    }
                    postData += "&searchStr=" + searchStr;
                    var thisTagRequest = {
                        callbackFunction: callbackFunction,
                        widgetRoot: widgetRoot
                    };

                    var keywordSearchDone = function(data) {
                        // check for data existence
                        if (data && data.widgets) {
                            data = data.widgets[0];
                        }
                        WidgetTagNavInit.processSearchResults(
                            thisTagRequest.widgetRoot, data, rows);
                        WidgetTagNavInit.drawTags(thisTagRequest.widgetRoot);
                        WidgetTagNavInit.WidgetEngine.reDrawWidget(widgetRoot);
                        // require(['DS/Foundation/WidgetEngine'],
                        //     function(WidgetEngine) {
                        //         WidgetEngine.reDrawWidget(widgetRoot);
                        //     });
                    };

                    var searchURL = "/resources/e6w/servicetagdata/search";
                    FoundationData.ajaxRequest({
                        url: searchURL,
                        type: 'post',
                        dataType: 'json',
                        data: postData,
                        callback: keywordSearchDone
                    });
                } else if (!widgetRoot.nonObjectBased) {
                    WidgetTagNavInit.drawTags(widgetRoot);
                    WidgetTagNavInit.WidgetEngine.reDrawWidget(widgetRoot);
                    // require(['DS/Foundation/WidgetEngine'],
                    //     function(WidgetEngine) {
                    //         WidgetEngine.reDrawWidget(widgetRoot);
                    //     });
                }
            },
            processSearchResults: function(widgetRoot, searchData, rows) {
                // Mark returned ids from search results.
                var bAutoFiltered = null,
                    foundIds = [];
                var searchWidget = searchData;
                var searchRows = WidgetAPIs.getContainerData(searchWidget);
                for (var i = 0; i < searchRows.length; i++) {
                    var id = WidgetAPIs.getId(searchRows[i]);
                    foundIds.push(id);
                }
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    var id = WidgetAPIs.getId(row);
                    var bSearchFiltered = true;
                    if (WidgetAPIs.__findInArray(foundIds, id) !== -1) {
                        bSearchFiltered = false;
                    }
                    WidgetAPIs.__setRowFilter(widgetRoot, row,
                        bAutoFiltered, bSearchFiltered);
                }
            },
            __undoFilters: function(widgetRoot, objects) {
                // remove search filter the objects - loop through each row
                // and reset search filter.
                var bAutoFiltered = false,
                    bSearchFiltered = false;
                for (var i = 0; i < objects.length; i++) {
                    WidgetAPIs.__setRowFilter(widgetRoot, objects[i],
                        bAutoFiltered, bSearchFiltered);
                }
            },
            processTagData: function(widgetRoot, tagRoot, rows) {
                // merge tag data into widget data.
                var tagrows = WidgetAPIs.getContainerData(tagRoot);
                if (tagrows) { //TODO understand the following and fix it since tagRoot seems to have the wrong thing passed in it
                    for (var i = 0; i < tagrows.length; i++) {
                        var tagrow = tagrows[i];
                        WidgetAPIs.__appendTagData(rows[i], tagrow);
                        rows[i].physicalId = tagrow.physicalId;
                    }
                }

                WidgetAPIs.__appendTagConfig(widgetRoot, tagRoot); // append
                // tag
                // fields
                // to
                // widget
                // fields.
            },
            buildTagObjectData: function(widgetRoot) {
                var tagData = {};
                var fields = WidgetAPIs.getAutoFilterFields(widgetRoot);
                var rows = WidgetAPIs.getContainerData(widgetRoot, null,
                    null, true, true); // get filtered records.
                for (var i = 0; i < rows.length; i++) {
                    var object = rows[i];
                    var tags = [];

                    for (var fieldIndex = 0; fieldIndex < fields.length; fieldIndex++) {
                        var field = fields[fieldIndex];
                        var dataelement = WidgetAPIs.getDataElement(field,
                            object);
                        var values = dataelement ? dataelement.value :
                            null;
                        if (!values) {
                            continue;
                        }
                        for (var j = 0; j < values.length; j++) {
                            var value = values[j];
                            var label = this.getTagLabel(value);
                            if (label && label === "") {
                                continue;
                            }
                            var tag = {
                                "object": label,
                                "dispValue": label,
                                "sixw": field.selectable.sixw,
                                "field": field.name
                            };
                            tags.push(tag);
                        }
                    }
                    var objectId = "pid://" + WidgetAPIs.getId(object);
                    tagData[objectId] = tags;
                }
                return tagData;
            },
            getTagLabel: function(value) {
                var label = "";
                if (value.printValue) {
                    label += value.printValue;
                } else if (value.value) {
                    label += value.value;
                }
                return label;
            },
            getTagPostData: function(widgetRoot, objects) {
                var postData = "";
                if (objects) {
                    var isPhysicalIds = true;
                    var aObjectsIds = [];
                    for (var i = 0; i < objects.length; i++) {
                        var row = objects[i];
                        if (row.physicalId) {
                            aObjectsIds.push(row.physicalId);
                        } else if (row.objectId) {
                            aObjectsIds.push(row.objectId);
                            isPhysicalIds = false;
                        } else {
                            aObjectsIds = []; // some objects with no ids;
                            // for now, this is not
                            // valid.
                            WidgetAPIs.destroyTNProxies(widgetRoot);
                            break;
                        }
                    }
                    if (aObjectsIds.length > 0) {
                        postData = "oid_list=" + aObjectsIds.join(",");
                        postData += "&isPhysicalIds=" + isPhysicalIds;
                    }
                }
                return postData;
            },
            drawTags: function(widget) {
                if (widget.tnProxy) {
                    var tnDataObj = this.buildTagObjectData(widget);
                    widget.tnProxy.setSubjectsTags(tnDataObj);

                    /*
                        // if there are tags, the tagger will call showObjects which in turn will reDraw.
                        // WidgetEngine.reDrawWidget(widget);
                        // let tagger refresh the widget first since
                        // hasFilters is not functional now.
						if (widget.parentObj) {
                        	require(['DS/Foundation/WidgetEngine'],
                            	function(WidgetEngine) {
                                	WidgetEngine.reDrawWidget(widget);
                            	});
						}
						*/
                }
            },
            showObjects: function(widgetRoot, filteredSubjectList) {
                var bSearchFiltered = null;
                var rows = WidgetAPIs.getContainerData(widgetRoot, null,
                    null, false, true); // get all data records
                // regardless of filter.
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    var objectId = "pid://" + WidgetAPIs.getId(row);
                    var filter = true;
                    if (WidgetAPIs.__findInArray(filteredSubjectList,
                            objectId) !== -1) {
                        filter = false;
                    }
                    WidgetAPIs.__setRowFilter(widgetRoot, row, filter,
                        bSearchFiltered);
                }
            },
            handleFilter: function(objSelection) { // "this" is scoped to
                // the widget that
                // invoked this method
                WidgetTagNavInit.showObjects(this,
                    objSelection.filteredSubjectList);
                //only do this for configurable widgets
                if (this.parentObj) {
                    this.parentObj.reDrawWidget(this);
                }
                //apply filter on collection
                if (this._mvcCollection) {
                    this._mvcCollection._applyFilter();
                }
            },
            handleTagCollect: function() {
                var aWidgetOids = [];
                if (this.tnProxy) {
                    this.container.find(".selected").each(
                        function() {
                            aWidgetOids.push("pid://" + jQuery(this).attr("data-pid"));
                        });
                    try {
                        if (aWidgetOids.length > 0) {
                            this.tnProxy.focusOnSubjects(aWidgetOids);
                        } else {
                            this.tnProxy.unfocus();
                        }
                    } catch (e) {
                        // do nothing
                        console.log(e.message);
                    }
                }
            },
            register: function(widget, TagNavigatorProxy) {
                if (widget.tnProxy) {
                    if (widget._mvcCollection) { //reset for mvc based apps
                        widget.tnProxy.addFilterSubjectsListener(this.handleFilter, widget);
                    }
                    return;
                }
                var location = WidgetUtils.getTopWindow().location;
                var paramWidgetId = location.search
                    .match(/[?&]widgetId=([^&]*)?/),
                    paramTenant = location.search
                    .match(/[?&]tenant=([^&]*)?/),
                    oThis = this,
                    win = this.tnWin,
                    options;

                paramWidgetId = (!paramWidgetId ? enoviaServer.widgetId :
                    paramWidgetId[1] || enoviaServer.widgetId);
                paramTenant = (!paramTenant ? enoviaServer.tenant :
                    paramTenant[1] || enoviaServer.tenant);
                options = {

                    widgetId: paramWidgetId,
                    contextId: !paramWidgetId ? "context1" : undefined,
                    tenant: paramTenant === "onpremise" ? undefined : paramTenant,
                    filteringMode: 'WithFilteringServices',
                    pod: "6WTags"
                };

                FoundationData._setInternalProperty(widget, "tnProxy", TagNavigatorProxy.createProxy(options));

                // setup listeners
                // when a tag is clicked in TN
                widget.tnProxy.addFilterSubjectsListener(
                    oThis.handleFilter, widget);

                // non TN event bindings
                // widget.id is to fire events on this widget only
                // .e6w-widget is to unregister all events with one
                // namespace
                jQuery(win.document).bind(
                    "widget_selection_changed." + widget.id +
                    ".e6w-widget",
                    function(e, data) {
                        oThis.handleTagCollect.call(widget, data);
                    });

                window.onunload  = function() {
                    jQuery(win.document).unbind(".e6w-widget");
                    if (widget.tnProxy) {
                        widget.tnProxy.die();
                    }
                };
            },
            init: function() {
                var oThis = this;
                this.tnWin = WidgetUtils.getTopWindow();
                if (this.tnWin) {
                    this.tnWin.hasWidget = true; // to enable TN button
                    // on toolbar
                    window.onunload = function() {
                        oThis.tnWin.hasWidget = false;
                    };
                }
            }
        };

        jQuery(function() { // onload initialization
            WidgetTagNavInit.init();
        });

        if (typeof window.console === "undefined") { // prevent IE from throwing
            // errors. This is just a
            // debug utility
            window.console = {
                log: function() {},
                warn: function() {},
                dir: function() {}
            };
        }
        // make a global for legacy's sake
        if (typeof window !== 'undefined') {
            window.WidgetTagNavInit = WidgetTagNavInit;
        } else {
            //                // case of node if we need it one day
            //                if (typeof GLOBAL !== 'undefined') {
            //                    GLOBAL.WidgetTagNavInit = WidgetTagNavInit;
            //                }
        }
        return WidgetTagNavInit;
    });

/**
Implementation of the WidgetEngine component
Copyright (c) 1992-2018 Dassault Systemes.
All Rights Reserved.
This program contains proprietary and trade secret information of Dassault Systemes
Copyright notice is precautionary only
and does not evidence any actual or intended publication of such program
<a href="http://www.3ds.com/products/enovia/">www.3ds.com/products/enovia/</a>

@module widget-infra
@version 0.4
@since 0.0.1
@author TWS
@requires jQuery 2+
 */
/**
 * WidgetEngine contains the business logic for building widgets
 *
 * @namespace
 * @static
 */
/* global define */
/* global WidgetConstants */
/* global enoviaServer */
define('DS/Foundation/WidgetEngine', [
    'DS/ENO6WPlugins/jQuery_3.3.1',
    'DS/Foundation/WidgetAPIs',
    'DS/Foundation/WidgetTemplate',
    'DS/Foundation/FoundationData',
    'DS/Foundation/WidgetTagNavInit',
    //  'DS/Foundation/WidgetPreferences',
    'DS/E6WCommonUI/WidgetUtils' //needs to be required here so it is ready for WidgetTemplate without having to prereq it from there to avoid the APIs -> Template -> Preference -> APIs cycle
], function(jQuery, WidgetAPIs, WidgetTemplate, FoundationData, WidgetTagNavInit, /* WidgetPreferences,*/ WidgetUtils) {
    "use strict";
    //    WidgetPreferences = null;
    var WidgetEngine = {
        widgets: [],
        str: {
            TABLELAYOUT: "tablelayout",
            PROGRESSBAR: "PROGRESSBAR"
        },
        progBarStates: {
            WARNING: "overdue",
            INFO: "impending",
            OKAY: "",
            ERROR: "overdue"
        },
        callback: null,
        id: null,
        tnProxy: null,
        showLabel: true,
        jsonPath: "/resources/e6w/service/json/",
        widgetName: null,
        targetDiv: null,
        dom: null,
        params: "",
        cspaceKey: "SecurityContext=",
        cspace: "",
        data: null,
        viewpref: null,
        sortpref: null,
        sortdirpref: null,
        tempURI: function(widgetName) {
            widgetName = widgetName || this.widgetName;
            return this.jsonPath + widgetName;
        },
        getCspace: function() {
            return (!this.cspace || this.cspace.length === 0 || this.cspace === "default") ? "" : this.cspaceKey + this.cspace;
        },
        processSelection: function(event, widgetId) {
            var targetElem = jQuery(event.target);
            if (targetElem[0].nodeName.toLowerCase() === 'a' || targetElem.parents('a').length) {
                //Unselect-all first since clicked on a link.
                jQuery(this).closest(".ds-widget").find(".selected").removeClass("selected");
            }
            var win = WidgetUtils.getTopWindow();
            jQuery(this).toggleClass("selected");
            if (win) {
                jQuery(win.document).trigger("widget_selection_changed." + widgetId + ".e6w-widget");
            }
        },
        init: function(widgetData) {
            var othis = this;
            if (widgetData) {
                this.processJSON(widgetData);
            } else {
                FoundationData.loadWidget(this.widgetName, othis.processJSON.bind(othis));
                /*
                FoundationData.ajaxRequest({
                    url: this.tempURI(),
                    type: 'get',
                    dataType: 'json',
                    callback: function(data) {
                        othis.processJSON(data);
                    }
                });
                */
            }

        },
        widget: function(initObj) {
            this.targetDiv = initObj.div;
            this.widgetName = initObj.name;
            this.uwaWidget = initObj.uwaWidget;
            this.callback = initObj.callback;
            this.cspace = initObj.cspace;
            this.viewpref = initObj.viewpref;
            this.sortpref = initObj.sortpref;
            this.sortdirpref = initObj.sortdirpref;
            this.tenant = initObj.tenant;
            //return copy of WidgetEngine
            var obj = {},
                hasOwn = Object.prototype.hasOwnProperty;
            for (var key in this) {
                if (hasOwn.call(this, key)) {
                    obj[key] = this[key];
                }
            }
            return obj;
        },
        setLabel: function(bln) {
            this.showLabel = bln;
        },
        processJSON: function(data) {
            if (!data.success) {
                var strError = data.error;
                //            strError = WidgetConstants.str[strError] || WidgetConstants.str["NetworkError"] || strError;
                this.dom = WidgetTemplate.error(strError);
            } else {
                this.data = data;
                enoviaServer.version = data.version;
                WidgetAPIs.setWidgetViewPreference(data, this.viewpref);
                if (this.sortpref) {
                    WidgetAPIs.sortWidget(data, [{
                        name: this.sortpref,
                        direction: this.sortdirpref
                    }]);
                }
                //now that the widgets have one less level we need to create a dom container (using getTemplate ) for the UI to work
                this.dom = WidgetEngine.getTemplate({
                    type: "ds-widget"
                }).append(WidgetAPIs.drawWidget(this));

            }
            this.drawUI();
        },
        createFieldView: function(obj) {
            var domElem = this.getTemplate(obj);
            this.processField(obj, domElem);
            return domElem;
        },
        registerTN: function(obj) {
            if (obj.id) {
                return;
            }
            obj.id = "wdg_" + Math.random();
            WidgetTagNavInit.loadTagData(obj);
        },
        /*nodeExpandEvent: function(widget, table, node) {
            var childNodes = node.children;
            if (childNodes.length === 0) {
                var relId = node.id,
                    thisRequest = {
                        widget: widget,
                        table: table,
                        node: node
                    },
                    expandObjectCallback = function(children) {
                        WidgetEngine.processNewChildren(thisRequest.widget, thisRequest.table, thisRequest.node, children);
                    };
                WidgetAPIs.expandObject(widget, relId, expandObjectCallback);
            } else { //show leaf nodes with minus icon.
                jQuery.each(childNodes, function(i, childNode) {
                    if (childNode.row.attr("data-leaf") === "true") {
                        table.treetable("reveal", childNode.id);
                    }
                });
            }
        },
        processNewChildren: function(widget, table, node, children) {
            if (children.length > 0) {
                var tempWidget = {
                    datarecords: {
                        datagroups: children
                    },
                    charts: [],
                    widgets: widget.widgets,
                    view: widget.view,
                    _table: table,
                    _node: node,
                    id: widget.id,
                    widgetType: "table_expand" //special type for custom rendering.
                };
                WidgetAPIs.__drawWidget(tempWidget, null, null, null);
            }
        },*/
        refreshRow: function(widget, data, actions, obj) {
            var tempWidget = {
                datarecords: {
                    editLink: widget.datarecords.editLink,
                    datagroups: [obj]
                },
                charts: [],
                widgets: widget.widgets,
                view: widget.view,
                displayview: widget.displayview,
                _dataTr: data,
                _actionsTr: actions,
                _widget: widget,
                id: widget.id,
                widgetType: "row_refresh"
            };
            WidgetAPIs.__drawWidget(tempWidget, null, null, null, widget);
        },
        /*createTableActionsRow: function (object, config, cells, treeMode, colspan) {
				return WidgetTemplate.editActionRow(object, config, cells, treeMode, colspan);
			},*/
        createTableRow: function(object, config, cells, cellDefinitions, widgetId, treeMode) {
            var rowAttributes = {
                    type: object.busType || "",
                    oid: object.objectId || "",
                    pid: object.physicalId || "",
                    widgetId: widgetId,
                    editMode: object._editMode
                },
                row = WidgetTemplate.listRow(rowAttributes);
            if (treeMode) {
                row.attr("data-tt-id", WidgetAPIs.getRelId(object));
                row.attr("data-tt-branch", true);
                if (object._parentObject) {
                    row.attr("data-tt-parent-id", WidgetAPIs.getRelId(object._parentObject));
                }
                if (object.leaf !== undefined) {
                    row.attr("data-leaf", "true");
                }
            }
            for (var j = 0; j < cells.length; j++) {
                var settings = {},
                    td;
                if (cellDefinitions[j].style && cellDefinitions[j].style.width) {
                    settings.size = cellDefinitions[j].style.width;
                }
                td = WidgetTemplate.listCell(settings);
                td.append(cells[j]);
                row.append(td);
            }
            if (object.selected) {
                row.addClass("selected");
            }
            return row;
        },
        createView: function(obj) {
            var isContainer = WidgetAPIs.isObjectContainer(obj.type),
                domElem = null,
                treeTable = false,
                widgetId = obj.config.id || "",
                containerItems = WidgetAPIs.getContainerItems(obj.config);
            // NMA5: We don't need table cases as we don't support it anymore
            /*if (obj.type === "table_expand") {
                treeTable = true;
                jQuery.each(obj.children, function(i, child) {
                    row = WidgetEngine.createTableRow(obj.data[i], obj.config, child, containerItems, widgetId, treeTable);
                    obj.config._table.treetable("loadBranch", obj.config._node, row[0]);
                });
                setTimeout(function() {
                    WidgetEngine.nodeExpandEvent(obj.config, obj.config._table, obj.config._node);
                }, 1); //expand leaf items.
            } else if (obj.type === "row_refresh") {
                var dataRow = WidgetEngine.createTableRow(obj.data[0], obj.config._widget, obj.children[0], containerItems, widgetId, treeTable);
                obj.config._dataTr.replaceWith(dataRow);
                var colspan = dataRow.find("td").length;
                dataRow.addClass("editable");
                var actionRow = WidgetEngine.createTableActionsRow(obj.data[0], obj.config._widget, obj.children[0], treeTable, colspan);
                if (actionRow) {
                    obj.config._actionsTr.replaceWith(actionRow);
                }
            } else {*/
            //store a pointer to the domElem for pagination
            //this is destroyed in WidgetAPIs __drawWidget
            if (obj.type === "list" || obj.type === "channel" || obj.type === "table") {
                if (obj.config._domElem) {
                    domElem = obj.config._domElem;
                } else {
                    domElem = this.getTemplate(obj);
                    obj.config._domElem = domElem;
                }
            } else {
                domElem = this.getTemplate(obj);
            }
            if (obj.type === "list" || obj.type === "table") {
                var tbodyElem = domElem.find('tbody'),
                    row = null,
                    rootCounter = 0;

                /*
                var tbodyElem = domElem.find('tbody'),
                    row = null,
                    td, settings, rootCounter = 0;
                if (obj.type === "table") {
                    if (obj.children.length !== 0 && obj.data[0].level !== undefined) {
                        treeTable = true;
                    }
                    //draw table header in the same table.
                    var headers = WidgetAPIs.getTableHeaders(obj.config);
                    row = WidgetTemplate.listRowHeader();
                    tbodyElem.append(row);
                    for (var j = 0; j < headers.length; j++) {
                        settings = {};
                        if (containerItems[j].style && containerItems[j].style.width) {
                            settings.size = containerItems[j].style.width;
                        }
                        td = WidgetTemplate.listCellHeader(settings);
                        td.append(headers[j]);
                        row.append(td);
                    }
                }*/
                jQuery.each(obj.children, function(i, child) {
                    row = WidgetEngine.createTableRow(obj.data[i], obj.config, child, containerItems, widgetId, treeTable);
                    if (treeTable && !obj.data[i]._parentObject) {
                        rootCounter++;
                    }
                    if (!treeTable && WidgetAPIs.isObjectEditable(obj.config, child)) {
                        var colspan = row.find("td").length;
                        var actionRow = WidgetEngine.createTableActionsRow(obj.data[i], obj.config, child, treeTable, colspan);
                        if (actionRow) {
                            tbodyElem.append(actionRow);
                            row.addClass("editable");
                        }
                    }
                    var strVal = WidgetAPIs.getFieldValue(obj.data[i], "name").displayValue || "";
                    row.attr("data-title", strVal);
                    tbodyElem.append(row);
                });
                if (treeTable) {
                    var tableDom = domElem,
                        tableWidget = obj.config,
                        processExpand = true;
                    domElem.treetable({
                        expandable: true,
                        clickableNodeNames: false,
                        onNodeExpand: function() {
                            if (processExpand) {
                                processExpand = false;
                                WidgetEngine.nodeExpandEvent(tableWidget, tableDom, this);
                                processExpand = true;
                            }
                        }
                    });
                    if (rootCounter === 1) {
                        domElem.treetable("expandNode", WidgetAPIs.getRelId(obj.data[0]));
                    }
                }
            } else {
                //domElem = this.getTemplate(obj);
                jQuery.each(obj.children, function(i, child) {
                    var parentDom = domElem;
                    if (obj.data) {
                        var domElemChild;
                        if (child.length > 1) {
                            domElemChild = WidgetTemplate.group({
                                type: 'group',
                                layout: obj.layout
                            });
                            domElem.append(domElemChild);
                            parentDom = domElemChild;
                        } else {
                            domElemChild = child[0];
                        }
                        if (obj.type === "channel") {
                            domElemChild.attr("data-objectId", obj.data[i].objectId || "");
                            domElemChild.attr("data-type", obj.data[i].busType || "");
                            domElemChild.attr("data-pid", obj.data[i].physicalId || "");
                            domElemChild.attr("data-title", WidgetAPIs.getFieldValue(obj.data[i], "name").displayValue || "");
                            //add click to domElemChild here
                            domElemChild.click(function(event) {
                                WidgetEngine.processSelection.call(this, event, obj.config.id);
                            });
                        }
                    }
                    for (var j = 0; j < child.length; j++) {
                        if (containerItems[j] && containerItems[j].style) {
                            if (containerItems[j].style.width) {
                                child[j].css("width", containerItems[j].style.width);
                            }
                            if (obj.type !== "experience" && containerItems[j].style.height) {
                                child[j].css("height", containerItems[j].style.height);
                            }
                        }
                        parentDom.append(child[j]);
                    }
                });
            }
            if (obj.children.length === 0 && domElem) {
                var noObjectsElem = parseInt(obj.config.countSummary.total, 10) === 0 ? WidgetTemplate.message(WidgetConstants.str.NoObjectsFound) :
                    WidgetTemplate.message(WidgetConstants.str.AllObjectsFiltered);
                //domElem.append(noObjectsElem);
                domElem = noObjectsElem;
            }
            if (!isContainer) {
                if (obj.config.style && obj.config.style.height) {
                    domElem.css({
                        height: obj.config.style.height,
                        overflow: "hidden"
                    });
                    if (obj.type === "experience") {
                        enoviaServer.widgetHeight.small = obj.config.style.height;
                    }
                }
                // linked container.
                if (obj.type === "group") {
                    this.checkLink(obj, domElem);
                }
            }
            //}
            return domElem;
        },
        getTemplate: function(obj) {
            var dom;
            obj.showLabel = this.showLabel;
            if (WidgetTemplate[obj.type]) {
                dom = WidgetTemplate[obj.type](obj);
            } else {
                dom = WidgetTemplate.container(obj);
            }
            if (obj.config && obj.config.style && obj.config.style.cssClass) {
                dom.addClass(obj.config.style.cssClass);
            }
            return dom;
        },
        drawUI: function() {
            if (this.callback && typeof this.callback === "function") {
                this.callback(this.dom);
            } else {
                jQuery('#' + this.targetDiv).append(this.dom);
            }
        },
        emptyContainer: function($elem) {
            if ($elem && $elem.length) {
                $elem[0].innerHTML = "";
            }
        },
        reDrawWidget: function(widget, view) {
            if (widget.container) {
                this.emptyContainer(widget.container);
                widget.container.append(WidgetAPIs.__drawWidget(widget, null, null, view));
                widget.container.unwrap();
            }
        },
        refresh: function(experienceObj) {
            var othis = this;
            //call service with widget name
            FoundationData.ajaxRequest({
                url: this.jsonPath + experienceObj.name,
                type: 'get',
                dataType: 'json',
                callback: function(data) {
                    if (!data.success) {
                        var strError = data.error;
                        //                    strError = WidgetConstants.str[strError] || WidgetConstants.str["NetworkError"];
                        experienceObj.widget.container.html(WidgetTemplate.message(strError));
                    } else {
                        if (data.widget.datarecords) { //not a location widget.
                            experienceObj.widget.datarecords = data.widget.datarecords; //swapping out data records.
                            experienceObj.widget.widgets = data.widget.widgets; //swapping out widget definition.
                            if (experienceObj._sortList) {
                                WidgetAPIs.sortWidget(experienceObj, experienceObj._sortList);
                            }

                            WidgetTagNavInit.loadTagData(experienceObj.widget);
                        }
                        if (experienceObj.widget.container) {
                            othis.emptyContainer(experienceObj.widget.container);
                            experienceObj.widget.container.append(WidgetAPIs.__drawWidget(experienceObj.widget));
                            experienceObj.widget.container.unwrap();
                        } else {
                            othis.emptyContainer(experienceObj.container);
                            experienceObj.collapsed = false;
                            experienceObj.container.append(WidgetAPIs.__drawWidget(experienceObj));
                            experienceObj.container.unwrap();
                        }
                    }
                }
            });
        },
        processField: function(obj, fld) {
            //The nested if tests ORDER is important, please keep tests nested correctly
            var drawData = true;
            if (obj.config) {
                if (obj.config.style) {

                    // field align attribute
                    if (obj.config.style.align) {
                        fld.addClass(obj.config.style.align.toLowerCase());
                    }

                } //end:if (obj.config.style)

                if (obj.config.ui) {
                    // specific formats like progress, dates etc.
                    if (obj.config.ui.type) {
                        switch (obj.config.ui.type) {
                            case this.str.PROGRESSBAR:
                                if (!isNaN(obj.values[0].value)) {
                                    var objProg = {
                                        percent: obj.values[0].value,
                                        state: this.progBarStates[obj.values[0].status] || ""
                                    };
                                    fld.append(WidgetTemplate.progress(objProg));
                                    //fld.css('width', '100%');
                                    fld.addClass('progress-bar');
                                    drawData = false;
                                }
                                break;

                            default:
                                break;
                        }
                    }
                } //end:if (obj.cofig.ui)

                // Text Label for field
                if (obj.config.label) {
                    var lbl = obj.config.label.text;
                    if (lbl) {
                        var lblDom = WidgetTemplate.label(lbl);
                        if (obj.config.label.show) {
                            lblDom.addClass(obj.config.label.show.toLowerCase());
                        }
                        fld.append(lblDom);
                    }
                }

            } //end:if (obj.config)

            var defaultImage = (obj.config && obj.config.image) ? obj.config.image["default"] : null;
            var iSize;
            if ((obj.values && obj.values[0]) || defaultImage) {
                var iUrl;
                if (obj.values && obj.values[0] && obj.values[0].imageValue) {
                    iUrl = obj.values[0].imageValue;
                    iSize = obj.values[0].imageSize;
                } else {
                    iUrl = defaultImage;
                }

                // Image field
                if (iUrl) {
                    var iWidth, iHeight, iAttr, imgObj, iStatus, iStatusText, objStatus;
                    if (iUrl.indexOf("../") === 0) { // cleanup relative paths
                        iUrl = enoviaServer.computeUrl(iUrl.substring(2));
                    } else if (iUrl.indexOf("/") === 0) { // cleanup relative paths
                        iUrl = enoviaServer.computeUrl(iUrl);
                    }
                    if (!iSize) {
                        iAttr = (obj.config && obj.config.image) ? obj.config.image : {};
                        iWidth = iAttr.width;
                        iHeight = iAttr.height;
                        iSize = iAttr.size;
                        //set image and container heights
                        switch (iSize) {
                            case "THUMBNAIL":
                                iHeight = "60px";
                                break;
                            case "SMALL":
                                iHeight = "62px";
                                break;
                            case "MEDIUM":
                                iHeight = "108px";
                                break;
                            case "LARGE":
                                iHeight = "480px";
                                break;
                            default:
                                break;
                        }
                    } else {
                        if (iSize === "ICON") {
                            iHeight = "16px";
                            iAttr = (obj.config && obj.config.image) ? obj.config.image : {};
                            iSize = iAttr.size;
                        }
                    }
                    imgObj = WidgetTemplate.image({
                        url: iUrl,
                        width: iWidth,
                        height: iHeight,
                        size: iSize
                    });
                    if (obj.values && obj.values[0]) {
                        iStatus = obj.values[0].badgeStatus || null;
                        iStatusText = obj.values[0].badgeTitle || "";
                        if (iStatus !== null) {
                            objStatus = WidgetTemplate.badge({
                                status: iStatus.toLowerCase(),
                                hovertext: iStatusText
                            });
                            imgObj.append(objStatus);
                        }
                    }
                    fld.append(imgObj);
                    drawData = false;
                }
                if (drawData) {
                    // check if this field is editable
                    var isFieldEditable = false;
                    if (obj.config.selectable && obj.config.selectable.editable) {
                        //check if specific object is not editable for this field.
                        if (obj.data.dataelements[obj.config.name].editable !== false) {
                            isFieldEditable = obj.config.selectable.editable;
                        }
                    }
                    var displayValue = obj.values[0].value;
                    var fieldName = obj.config.name;
                    fld.append(WidgetTemplate.text(displayValue, fieldName));
                }
            }
            // linked field
            this.checkLink(obj, fld);
        },
        checkLink: function(obj, domElem) {
            var inEditMode = false;
            if (obj.objectData && obj.objectData._editMode) {
                inEditMode = true;
            }
            if (!inEditMode && obj.config && obj.config.url) {
                var objUrl, tmpUrl;
                tmpUrl = WidgetAPIs.processUrl(obj.config, obj.objectData, obj);
                objUrl = {
                    url: tmpUrl,
                    target: obj.config.url.target /*|| obj.config.widget.id*/
                };
                domElem.wrapInner(WidgetTemplate.link(objUrl));
            }
        },
        addEditEvent: function(editable, field, obj, controlType) {
            editable.click(function() {
                WidgetEngine.__editFieldClickHandler(editable, field, obj, controlType);
            });
        },
        __clearMsg: function(field) {
            var tr = field.parents("tr:first");
            var oid = tr.attr("data-objectid");
            var table = field.parents("table:first");
            var actionTr = table.find('tr.editable-actions[data-objectid="' + oid + '"]');
            var divMsg = actionTr.find('div.messages');
            divMsg.removeClass('info warn error');
            this.emptyContainer(divMsg);
            field.removeClass('info warn error');
        },
        toggleSection: function(section) {
            var collapsed = false,
                experienceView = jQuery(section).closest(".experience").children()[1];
            if (!experienceView) {
                //trigger refresh event.
                jQuery(jQuery(section).parent().children()[2]).children('.fonticon-cw').click();
            } else {
                jQuery(experienceView).toggle(); //collapse/expand view.
                collapsed = experienceView.style.display === "none" ? true : false;
            }
            jQuery(section.children[0]).removeClass('fonticon-down-dir  fonticon-right-dir'); //remove left side arrow.
            if (collapsed) {
                jQuery(section.children[0]).addClass('fonticon-right-dir');
            } else {
                jQuery(section.children[0]).addClass('fonticon-down-dir');
            }
            jQuery(jQuery(section).parent().children()[2]).toggle(); //right-side tool bar icons.
        }
    };
    window.WidgetEngine = WidgetEngine;
    WidgetTagNavInit.WidgetEngine = WidgetEngine; //to get rid of circular reference
    return WidgetEngine;
});

/*global define, require*/
define('DS/Foundation/Models/FoundationBaseModel', ['UWA/Core', 'UWA/Class/Model', 'UWA/Class/Collection', //UWA Prereqs
        'DS/Foundation/FoundationData'
    ],
    /**
     * @module Foundation/Model/FoundationBaseModel
     *
     * @require UWA/Core
     * @require UWA/Class/Model
     *
     * @extend UWA/Class/Model
     * we are keeping a backpointer toward the foundation rowObject (_rowObjects) this is a multi-instanciated object
     */

    function(UWA, Model, Collection, FoundationData) {
        'use strict';

        var FoundationBaseModel = Model.extend({
            _uwaClassName: 'FoundationBaseModel',
            idAttribute: 'physicalId',
            getInMemoryData: function(iRowObject) {
                var data = this.collection && this.collection.data && this.collection.data();
                if (!data) {
                    var lCurrentObject = iRowObject;
                    if (!lCurrentObject && this._rowObjects && this._rowObjects.length) {
                        lCurrentObject = this._rowObjects[0];
                    }
                    if (lCurrentObject) {
                        var lParentObject = lCurrentObject._parentObject || lCurrentObject._relationshipParentObject;
                        for (; lParentObject; lParentObject = lCurrentObject._parentObject || lCurrentObject._relationshipParentObject) {
                            lCurrentObject = lParentObject;
                        }
                        if (lCurrentObject._parentRecords) {
                            data = lCurrentObject._parentRecords._container;
                        }
                    }
                }
                return data;
            },
            getServiceName: function() {
                //look at the collection first
                var lServiceName = this.collection && this.collection._serviceName;
                if (!lServiceName) {
                    //look at the inMemoryData
                    var lInMemoryData = this.getInMemoryData();

                    lServiceName = lInMemoryData && lInMemoryData.name;
                }
                return lServiceName;
            },
            /**
             * override of get for the children value.
             * for other attribute names the regular get will be called
             * @param {String} iAttrName the attribute to retreive
             * @return {Object} the retrieved value
             */
            get: function FoundationBaseModelGet(iAttrName) {
                //are we asking for children?
                var getResultFromRowObjectArray = function(iChildRowObjects, iCollection, ModelConstructor) {
                    var lRet = [];
                    var lNbChildRowObjects = iChildRowObjects.length;
                    for (var lCurChildRowObjectsIdx = 0; lCurChildRowObjectsIdx < lNbChildRowObjects; lCurChildRowObjectsIdx++) {
                        var lCurChildRowObject = iChildRowObjects[lCurChildRowObjectsIdx];
                        var lCurUpdateAction = lCurChildRowObject.updateAction || lCurChildRowObject.updateActionPending;
                        if (lCurUpdateAction === "DISCONNECT" || lCurUpdateAction === "DELETE") {
                            //objects are in the process of being removed from the structure, do not count them in
                            continue;
                        }
                        if (!lCurChildRowObject._mvcModel) {
                            //convert the child
                            // var lJSONForMVC =this.convertFromFoundationToMVC(lCurChildRowObject);
                            var lMVCModel;
                            if (iCollection) {
                                lMVCModel = iCollection.add(lCurChildRowObject);
                                //if the child existed already it will be found in the collection and not attached to the rowObject
                                //this is a case of multiple instance of the same model in one structure.  relId will be incorrect.  Need to review this later
                                if (lMVCModel && !lCurChildRowObject._mvcModel) {
                                    FoundationData._setInternalProperty(lCurChildRowObject, "_mvcModel", lMVCModel);
                                }
                            } else { //should this really happen?
                                lMVCModel = new ModelConstructor(lCurChildRowObject); //the constructor will actually valuate lCurChildRowObject._mvcModel
                                //as a side effect which is why we won't need to use lMVCModel
                            }

                        }
                        //_mvcModel should now have a value
                        lRet.push(lCurChildRowObject._mvcModel);

                    }
                    return lRet;
                };
                if (iAttrName === "children" && this._rowObjects && this._rowObjects.length) {
                    //get the children using Foundation.  Here we get the ones from the first of our rowObjects.
                    //Foundation should have returned the same set of children for all of them
                    //TODO we may have to make a union later on or add code  in the foundation sync to ensure that this is true
                    var lChildRowObjects = FoundationData.getChildren(this._rowObjects[0]);
                    //using this.constructor to build an object of the correct subtype of FoundationBaseModel
                    //since we are dealing with children they should be same type as this
                    //http://www.ecma-international.org/ecma-262/5.1/#sec-15.2.4.1
                    //https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/constructor
                    return getResultFromRowObjectArray(lChildRowObjects, this.collection, this.constructor);
                } else {
                    //relations are explicitly declared so we can return an empty array for a valid relation which is not present in the dataset
                    var lRelation;
                    if (this._relations) {
                        lRelation = this._relations.detect(function(iCurRelation) {
                            return iCurRelation.key === iAttrName;
                        });
                    }

                    if (lRelation) { //we are manipulating some related data
                        if (this._rowObjects && this._rowObjects.length) {
                            //get the related data using Foundation
                            var lRelatedDataCollection = this.collection && this.collection.getChildCollection && this.collection.getChildCollection(iAttrName);

                            var lModelType = lRelation.relatedModel;
                            lModelType = lModelType ? lModelType : FoundationBaseModel;
                            //same comment as for the children, all instances in foundation should have the same related data so take the first one.
                            var lRelatedDataRowObjects = FoundationData.getRelatedObjects(this._rowObjects[0], iAttrName);
                            var lRet = getResultFromRowObjectArray(lRelatedDataRowObjects, lRelatedDataCollection, lModelType);
                            lRet.relationshipName = iAttrName;
                            return lRet;
                        } else {
                            return [];
                        }

                    }
                }
                if (iAttrName === 'tempId') {
                    if (this._rowObjects) {
                        return this._rowObjects[0].tempId;
                    }
                }
                return this._parent.apply(this, arguments);
            },
            /**
             * files upload method
             * @param {Array} files the files array object
             * @param {String} iRelName the relationship name
             * @param {Object} iOptions the options object for passing options
             */
            uploadFiles: function _uploadFiles(files, iRelName, iOptions) {
                for (var i = files.length - 1; i >= 0; i--) {
                    this.uploadFile(files[i], iRelName, iOptions);
                }
            },
            /**
             * file upload method
             * @param  {File} file the file object
             * @param {String} iRelName relationship to attach the file to
             * @param {Options} iOptions the options.  In particular
             *                   iOptions.collabspace to specify a collabspace
             *                   iOptions.onComplete, iOptions.onFailure standard callbacks
             */
            uploadFile: function _uploadFile(file, iRelName, iOptions) { //TODO: add callback to make reusable and move to Foundation
                var that = this;
                var lOptions = UWA.clone(iOptions || {}, false);
                lOptions.isImage = true;
                if (!this.id) {
                    throw new Error("Invalid object, cannot upload file on a model not saved yet");
                }
                lOptions.csrf = this.csrf;
                var onComplete = lOptions.onComplete;
                lOptions.onComplete = function(resp) {
                    var lV1Document = FoundationBaseModel.convertFoundationV2toV1(resp.data[0]);
                    lV1Document.dataelements.hasfiles = {
                        value: [{
                            value: 'TRUE'
                        }]
                    };
                    lV1Document.dataelements.image = {
                        value: [{
                            imageValue: window.URL.createObjectURL(file)
                        }]
                    };
                    if (iRelName) {
                        that.updateRelatedObjectWithNewEntry(lV1Document, iRelName);
                    }

                    if (UWA.is(onComplete, 'function')) {
                        onComplete(lV1Document);
                    }
                };
                var onFailure = lOptions.onFailure;
                lOptions.onFailure = function() {

                    if (UWA.is(onFailure, "function")) {
                        onFailure();
                    }
                };
                var relDescription = {
                    // parentDirection: "these are set from the fromDictionary",
                    // parentRelName: "these are set from the fromDictionary",
                    parentId: this.id
                };
                var fromDictionary;
                if (iRelName) {
                    fromDictionary = this.collection && this.collection.getRelationDescription(iRelName);
                    UWA.merge(relDescription, fromDictionary);
                }


                var documentInfo = {
                    fileInfo: {
                        file: file
                    },
                    relInfo: relDescription
                };
                lOptions.collabspace && (documentInfo.collabspace = lOptions.collabspace);
                var createDocument = function() {
                    FoundationBaseModel.DocumentManagement.createDocument(documentInfo, lOptions);
                };
                if (!FoundationBaseModel.DocumentManagement) {
                    require(['D' + 'S/DocumentManagement/DocumentManagement'], function(iDocumentManagement) {
                        FoundationBaseModel.DocumentManagement = iDocumentManagement;
                        createDocument();
                    });
                } else {
                    createDocument();
                }

            },
            /**
             * utility method taking as input a json object returned by a foundation service and
             * returning a simpler but equivalent json object fit for creating a Model object
             * @param {RowObject} iRowObject an object to convert
             * @return {Object} plain js object suitable to be parsed by UWA/Model
             */
            convertFromFoundationToMVC: function convertFromFoundationToMVC(iRowObject) {
                var retObject = FoundationData.getFieldValues(iRowObject, true);


                //copy the rest of the keys
                var keys = ["objectId", "physicalId", "tempId", "busType", "cestamp"];
                var lNbKeys = keys.length;
                for (var lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                    var lCurKey = keys[lCurKeyIdx];
                    retObject[lCurKey] = iRowObject[lCurKey];
                }
                return retObject;

            },
            /**
             * translate the Foundation objects to a json object more compatible with UWA/Class/Model.
             * we will assume with have a FoundationObject if witgetType is set to datagroup
             * @param {Object} iJSON the input from the constructor
             * @param {Object} options the options
             */
            init: function FoundationBaseModelConstructor(iJSON, options) {
                var args = Array.prototype.slice.call(arguments, 0);
                //overriding the constructor will let us translate arguments which are in the Foundation services format to our simpler format
                if (iJSON && iJSON.dataelements && !(options && options.parse)) {
                    this.collection = options && options.collection;
                    var modelJSON = this.convertFromFoundationToMVC(iJSON);
                    args[0] = modelJSON;

                    this._rowObjects = [iJSON]; //we are in a constructor so we know that _rowObjects doesn't exist yet
                    FoundationData._setInternalProperty(iJSON, "_mvcModel", this);
                }

                Object.defineProperty(this, "csrf", {
                    get: function() {
                        var lRet;
                        if (this.collection && typeof this.collection.data === "function") {
                            var data = this.getInMemoryData();
                            lRet = data.datarecords ? data.datarecords.csrf : data.csrf;
                        }
                        return lRet;
                    }
                });

                this._parent.apply(this, args);

            },
            /**
             * @override
             * override the parent setup.
             * will turn the relatedData attribute Values into collections
             * @param {Object} iJSON the parsed data to be used to create the object
             * @param {Object} options the options
             */
            setup: function FoundationBaseModelSetup(iJSON, options) {
                //          var that = this;
                if (options && options.existingObject) {
                    this.existingObject = true;
                }
                this._parent.apply(this, arguments);
            },
            /**
             * remove a related data model by index.
             * @param {String} iAttributeName:  name of the attribute to remove the model from
             * @param {Number} iToRemove: index of the model to remove or the model itself
             * @return {FoundationBaseModel} the removed model
             */
            removeObject: function(iAttributeName, iToRemove) {
                var lModelToRemove;
                var lRet;
                if (UWA.is(iToRemove, "number")) {
                    var lRelDatas = this.get(iAttributeName);
                    lModelToRemove = lRelDatas[iToRemove];
                } else {
                    //is it a model
                    if (!(iToRemove instanceof Model)) {
                        throw new Error("invalid object to remove " + iToRemove);
                    }
                    lModelToRemove = iToRemove;
                }

                var data = this.getInMemoryData();
                //remove from the first rowObject, otherwise we would be sending multiple calls to the server.
                //we need to make sure to remove the correct row object
                var lRowObject = this._rowObjects[0];
                //for the current row object find the instance that we want to remove
                var lRelatedObjects = FoundationData.getRelatedObjects(lRowObject, iAttributeName);
                var lNbRelatedObjects = lRelatedObjects.length;
                var toRemoveId = lModelToRemove._rowObjects && lModelToRemove._rowObjects.length ? FoundationData.getId(lModelToRemove._rowObjects[0]) : lModelToRemove.id;
                var toRemove = null;
                for (var lCurRelatedObjectIdx = 0; lCurRelatedObjectIdx < lNbRelatedObjects; lCurRelatedObjectIdx++) {
                    var lCurRelatedObject = lRelatedObjects[lCurRelatedObjectIdx];
                    if (FoundationData.getId(lCurRelatedObject) === toRemoveId) {
                        //we found it
                        toRemove = lCurRelatedObject;
                        break;
                    }
                }
                if (toRemove) {
                    FoundationData.disconnectRelatedObject(data, toRemove, lRowObject, iAttributeName);

                    lRet = lModelToRemove;

                }
                return lRet;
            },
            /**
             * update the related objects to take into account newly connected object when the addition was done from server side.
             * this will add the object to the underlying foundation data but it will not mark it as needing to be connected.
             * which means that even after saving no order will be sent to the server to connect it.
             * normally used if an unrelated service call returned information which lets us know that a new object was added server side
             * @param {RowObject} iObject object to add, this should be a row object
             * @param {String} iRelationshipName the relationship to use
             * @return {RowObject} the added object
             */
            updateRelatedObjectWithNewEntry: function(iObject, iRelationshipName) {
                var data = this.getInMemoryData();
                var rowObjects = this._rowObjects;
                var lRet;
                if (data && rowObjects) {
                    FoundationData.__updateIndexCacheWithOneObject.call(data, iObject);
                    lRet = FoundationData.__addOrConnectObjectToStructure(data, iRelationshipName, rowObjects[0], iObject);
                }
                return lRet;
            },
            /**
             * add a related object.
             * this will add the object to the underlying foundation data but it will not save them
             * @param {Object} iObject object to add, can be a Model or a row object
             * @param {String} iRelationshipName the relationship to use
             * @param {Object} options  options to pass down.  In our case we are interested by existingObject which if true will
             * force a connect even if we don't know the model id
             */
            addRelatedObject: function(iObject, iRelationshipName, options) {
                //  this should be either a connect or an add depending on whether the object is new or not.
                //handle the case of connect for now
                //the difference between the two should be based on the isNew from the object
                var data = this.getInMemoryData();
                var lAddedRowObject; //the output
                var rowObjects = this._rowObjects;
                //data could be a json model or an MVCOne
                //case of an MVC model
                if (iObject instanceof Model) {
                    var foundationData;

                    if (data && iRelationshipName) {


                        if (this.isNew()) {
                            if (!rowObjects) { //case where this is the first time we add to the related data for this new object
                                rowObjects = [this.collection.updateModelInFoundation("create", this)];
                            } else {
                                // the object is still new since it hasn't been successfully saved yet but this is not the first time we are adding a related data to it.
                                // a temp_id was already affected and we need to be careful
                                this.collection.updateModelInFoundation("update", this);
                            }


                        }

                        var lCollectionForConvertion;
                        if (iObject.isNew() && !(options && options.existingObject) && !(iObject._rowObjects && iObject._rowObjects.length)) {
                            //do an AddRelatedObject
                            //should use the collection from the object to add for the conversion as it will know what are relationship vs attributes
                            lCollectionForConvertion = iObject.collection || this.collection;
                            foundationData = lCollectionForConvertion._convertToFoundationData(iObject.toJSON());

                            //add to our first rowObject
                            lAddedRowObject = FoundationData.addRelatedObject(data, iRelationshipName, rowObjects[0], foundationData, undefined, iObject);
                        } else {
                            //do a ConnectRelatedObject to our first rowObject
                            var lConnectedObjectId = iObject.id;
                            var lConnectedRowObjects = iObject._rowObjects;
                            var toConnect;
                            if (!lConnectedRowObjects || !lConnectedRowObjects.length) {
                                lCollectionForConvertion = iObject.collection || this.collection;
                                foundationData = lCollectionForConvertion._convertToFoundationData(iObject.toJSON());
                                toConnect = lConnectedObjectId;
                            } else {
                                toConnect = lConnectedRowObjects[0];
                            }

                            //only do the connect on one.  by using the Id we do it on the one in the index maybe we should have used the first one in our array
                            lAddedRowObject = FoundationData.connectRelatedObject(data, iRelationshipName, rowObjects[0], toConnect, foundationData);
                        }
                        if (lAddedRowObject) {
                            if (!iObject._rowObjects) {
                                iObject._rowObjects = [lAddedRowObject];
                            } else {
                                if (iObject._rowObjects.indexOf(lAddedRowObject) === -1) {
                                    iObject._rowObjects.push(lAddedRowObject);
                                }
                            }

                            FoundationData._setInternalProperty(lAddedRowObject, "_mvcModel", iObject);
                        }
                    }
                } else { //case of a row object
                    //is it new?
                    if (iObject.physicalId) {
                        //existing object
                        FoundationData.connectRelatedObject(data, iRelationshipName, rowObjects[0], iObject);
                    } else {
                        //TODO new object, not treated yet
                    }
                }

            },
            /**
             * adds objects by relationship name
             * @param {Object} iObject object to add
             * @param {String} iRelationshipName the relationship to use
             * @param {Object} options the options
             * @return {FoundationBaseModel} the new added model
             */
            addNewObject: function(iObject, iRelationshipName, options) {
                var collection = this.collection.getChildCollection(iRelationshipName);
                var newModel = collection.add(iObject);
                this.addRelatedObject(newModel, iRelationshipName, options);
                return newModel;
            },
            /**
             * adds objects by id
             * @param {Array} iIds  should be an array of string.  If it is a single string it will be encapsulated as an array.
             *              those should be physical ids, could be another if the iIDAttributeToUse is set
             * @param {String} iAttributeName name of the relateddata attribute to use to add the object
             * @param {String} iIDAttributeToUse optional, uses id (physicalid) by default but for assignees uses name
             * @param {Object} options the options
             * @return {Array} the created objects
             */
            addObjects: function(iIds, iAttributeName, iIDAttributeToUse, options) {
                var lIDAttributeToUse = iIDAttributeToUse || "physicalId";
                var lArrayOfObjectIds = iIds;
                var returnValue = [];
                if (UWA.is(lArrayOfObjectIds, "string")) {
                    lArrayOfObjectIds = [iIds];
                }
                var lNbObjects = lArrayOfObjectIds.length;
                if (lNbObjects) {
                    // var objectsCollection = this.get(iAttributeName);
                    if (this.collection) {
                        var childCollection = this.collection.getChildCollection(iAttributeName);
                        for (var lCurObjectIdx = 0; lCurObjectIdx < lNbObjects; lCurObjectIdx++) {
                            var lCurObjectId = lArrayOfObjectIds[lCurObjectIdx];
                            if (lCurObjectId && lCurObjectId.length) {

                                var newObject;
                                if (lIDAttributeToUse === "physicalId") {
                                    newObject = this.collection.getRelatedObject(iAttributeName, lCurObjectId);
                                } else {
                                    var lCurInputObject = {};
                                    lCurInputObject[lIDAttributeToUse] = lCurObjectId;
                                    if (options && options.type) {
                                      lCurInputObject.type = options.type;
                                    }
                                    newObject = childCollection.add(lCurInputObject, {
                                        existingObject: true
                                    });
                                }

                                //TODO, the call bellow actually fires the relation ship change event, we shoudl try to silence it so we can fire only once for the whole list
                                this.addRelatedObject(newObject, iAttributeName, options);
                                returnValue.push(newObject);

                            }
                        }
                        //TODO fire relationship change events once here. check if we can use _fireRelationshipEvent instead
                        //this.set(iAttributeName, objectsCollection);
                    }

                }
                return returnValue;
            },
            /**
             * @override Model.isNew .
             * Model.isNew is based on the presence of an id.  Since we want to be able to add existing objects for which we don't know the id (case of assigneesByName)
             * one can explicitly set on an object that it is not new.
             * @return {Boolean} is it new
             */
            isNew: function() {
                return !this.existingObject && this._parent.apply(this, arguments);
            },
            /**
             * @override the toJSON  method
             */
            toJSON: function() {
                var lRet = this._parent.apply(this, arguments);
                var lKeys = Object.keys(lRet);
                var lNbKeys = lKeys.length;
                var lCurKeyIdx;
                var lCurKey;
                for (lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                    lCurKey = lKeys[lCurKeyIdx];
                    var lCurVal = lRet[lCurKey];
                    if (lCurVal instanceof Model) {
                        var lCurJSONVal = lCurVal.toJSON();
                        var lFoundationData;
                        if (lCurVal._rowObjects && lCurVal._rowObjects.length) {
                            lFoundationData = lCurVal._rowObjects[0];
                        }
                        lRet[lCurKey] = {
                            actualValue: lFoundationData,
                            displayValue: lCurJSONVal
                        };
                    }
                }
                //bcc: should we add children?  there is a potential for uselessly deep recursion.  Already with related data...
                //add the related data
                if (this._relations) {
                    lKeys = this._relations.map(function(iCurRelation) {
                        return iCurRelation.key;
                    });
                    lNbKeys = lKeys.length;
                    for (lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                        lCurKey = lKeys[lCurKeyIdx];
                        var lRelatedData = this.get(lCurKey); //this is an array of model which each should be jsonified
                        var lConvertedRelatedData = [];
                        var lNbRelatedData = lRelatedData.length;
                        for (var lCurRelatedDataIdx = 0; lCurRelatedDataIdx < lNbRelatedData; lCurRelatedDataIdx++) {
                            var lCurRelatedDataObject = lRelatedData[lCurRelatedDataIdx];
                            lConvertedRelatedData.push(lCurRelatedDataObject.toJSON());

                        }
                        lRet[lCurKey] = lConvertedRelatedData;
                    }
                }
                return lRet;
            },
            _fireRelationshipChangeEvents: function(iRelationshipName, options, iOnlyRelation, iNoRelation) {
                if (!iNoRelation) {
                    this.dispatchEvent("onChange:" + iRelationshipName, [this, options]);

                }
                if (!iOnlyRelation) {
                    var lOptions = UWA.clone(options || {}, false);
                    lOptions.relationshipChanged = iRelationshipName;
                    this.dispatchEvent("onChange", [this, lOptions]);
                }

            },

            // now parse will be passed the C/R/U/D operation type in options,
            // allowing you to deal with heterogeneous response formats from
            // your annoying back-end :
            /**
             * @override parse
             */
            parse: function(response /*, options*/ ) {
                var args = Array.prototype.slice.call(arguments, 0);
                if (response && response.dataelements) {
                    if (!this._rowObjects) {
                        this._rowObjects = [response];
                    } else {
                        if (this._rowObjects.indexOf(response) === -1) {
                            this._rowObjects.push(response);
                        }
                    }
                    FoundationData._setInternalProperty(response, "_mvcModel", this);
                    var modelJSON = this.convertFromFoundationToMVC(response);

                    args[0] = modelJSON;
                }
                return this._parent.apply(this, args);
            },
            _syncRead: function syncRead(method, object, options) {
                var lRet;
                var lOptions = options;
                var that = this;
                var args = Array.prototype.slice.call(arguments, 0);
                var store = this.collection ? this.collection._localStore : null;
                if (lOptions.server || !store) {
                    //server call
                    var lServiceName = this.getServiceName();
                    if (lServiceName) {
                        var lPhysicalId = this.get("physicalId");
                        lServiceName += "?objectId=" + lPhysicalId;
                        lRet = FoundationData.loadWidget(lServiceName, function(data) {
                            //retrieve the datagroup
                            var lRowObject = FoundationData.getObject(data, lPhysicalId);
                            //update our object with the corresponding information.
                            //2 cases:
                            //1) we already have some rowObjects.  Sync them
                            var lInMemoryData = that.getInMemoryData();
                            if (that._rowObjects && lInMemoryData) {
                                var lNbRowObjects = that._rowObjects.length;
                                for (var lCurRowObjectIdx = 0; lCurRowObjectIdx < lNbRowObjects; lCurRowObjectIdx++) {
                                    var lCurRowObject = that._rowObjects[lCurRowObjectIdx];
                                    if (lRowObject) {
                                        FoundationData.__synchronizeSourceObjectFromServerObject(lInMemoryData, lRowObject, lCurRowObject, true);
                                    }

                                }
                            } else { //2) we don't have a rowObject
                                // the object we got will become our rowObject.  What is tricky is how we add it back to the foundation data structure
                                that._rowObjects = [lRowObject]; //need to make sure that object is not considered to be connected yet
                                if (lRowObject) {
                                    delete lRowObject._parentObject;
                                    delete lRowObject._relationshipParentObject;
                                    delete lRowObject._parentRecords;
                                }
                                that.applyUpdatesFromServer();
                            }
                            if (lInMemoryData) {
                                FoundationData.__updateCsrf(lInMemoryData, data);
                            }

                        });

                    }

                } else {
                    lRet = store.sync.apply(store, args);
                }
                return lRet;
            },
            /**
             * @override sync
             * CUD operations are pass through (server and local) per default, this can be overriden by setting the localOnly:true option.
             * Read operation will be local only by default, this can be overriden by setting the server:true option
             */
            sync: function(method, object, options) {

                var store = this.collection ? this.collection._localStore : null;
                var lOptions = UWA.clone(options || {}, false);
                var args = Array.prototype.slice.call(arguments, 0);
                var that = this;
                var lRet;
                if (method === "read") {

                    lRet = this._syncRead(method, object, lOptions);
                } else if (method === "create" || method === 'update' || method === 'patch' || method === 'delete') {
                    if (!store || !lOptions.localOnly || lOptions.server) {
                        //Foundation call is delegated to the collection since the collection has the "data" element
                        if (this.collection) {
                            if (!lOptions.wait) {
                                var oldOnFailure = lOptions.onFailure;
                                var onComplete = lOptions.onComplete;
                                lOptions.onComplete = function( /*rowObject, data*/ ) {
                                    if (onComplete) {
                                        onComplete.apply(this, arguments);
                                    }
                                };
                                switch (method) {
                                    case 'delete':
                                        //store the collection in another variable for future reinsertion in case of error
                                        var collectionBeforeDelete = this.collection;
                                        lOptions.onFailure = function( /*rowObject, data*/ ) {
                                            //TODO think about using getInMemoryData in this case.  If we have a model not based on a collection but still on inMemoryData it should be able to rollback
                                            if (collectionBeforeDelete && UWA.is(collectionBeforeDelete.data, "function")) {
                                                var lData = collectionBeforeDelete.data();
                                                lData && FoundationData.rollbackFailedData(lData);
                                            }
                                            //add back to the collection
                                            //bug in UWA prevents the onAdd event from being called.
                                            //we will call it manually.
                                            collectionBeforeDelete.push(that);

                                            if (oldOnFailure) {
                                                oldOnFailure.apply(this, arguments);
                                            }
                                        };
                                        break;
                                    case 'create':
                                        lOptions.onFailure = function( /*rowObject, data*/ ) {
                                            if (that.collection && UWA.is(that.collection.data, "function")) {
                                                var lData = that.getInMemoryData();
                                                lData && FoundationData.rollbackFailedData(lData);
                                            }
                                            that.destroy({
                                                localOnly: true
                                            });

                                            if (oldOnFailure) {
                                                oldOnFailure.apply(this, arguments);
                                            }
                                        };

                                        break;
                                    case 'update':
                                    case 'patch':
                                        lOptions.onFailure = function(rowObject /*, dataFromServer, options*/ ) {
                                            //restore the objects in data
                                            if (that.collection && UWA.is(that.collection.data, "function")) {
                                                var lData = that.getInMemoryData();
                                                lData && FoundationData.rollbackFailedData(lData);
                                            }

                                            //restore the object based on its now canceled rowObject
                                            //we could use the changedAttributes and previousAttributes from UWA/Model but for now I prefer to use the Foundation data as a reference
                                            //also if this makes for too brutal a UI refresh we can set only those attributes which were modified and can be retrieved using
                                            //that.changedAttributes()
                                            var modelJSON = that.convertFromFoundationToMVC(rowObject);
                                            that.set(modelJSON);
                                            if (oldOnFailure) {
                                                oldOnFailure.apply(this, arguments);
                                            }


                                        };
                                        break;
                                }
                            }
                            lRet = this.collection.sync(method, object, lOptions);
                            this.dispatchEvent('onRequest', [this, lRet, lOptions]);


                        }
                        //in case we have both a server and a local storage sync we don't want the local storage to send onComplete and onFailure messages
                        args[2] = UWA.clone(options, false);  //new clone, we can't reuse the lOptions as we will need to remove onFailure and onComplete
                        delete args[2].onComplete;
                        delete args[2].onFailure;
                    }
                    if (store) {
                        var ret2 = store.sync.apply(store, args);
                        lRet = lRet ? lRet : ret2;
                    }
                }


                return lRet;
            },
            /**
             * received an updated rowObject.
             * make sure it is taken into account
             * @param {RowObject} rowObject  the data to apply. optional, if not present will use _rowObjects[0]
             * @param {Object} options passthrough options for events
             */
            applyUpdatesFromServer: function(rowObject, options) {
                var lRowObject = rowObject || ((this._rowObjects && this._rowObjects.length) ? this._rowObjects[0] : undefined);
                if (lRowObject) {
                    var serverAttrs = this.parse(lRowObject, options);

                    this.set(serverAttrs, {});
                    this.dispatchEvent('onSync', [this, lRowObject, options]);

                }

            },
            /**
             * override destroy
             */
            destroy: function() {
                //destroyed model should be removed from related data and children

                this.stopListening();
                this._parent.apply(this, arguments);
            },
            defaults: {}

        });
        //We need to do this here because toJSON is not defined till now
        FoundationBaseModel.prototype.dataForRendering = function() {
            return this.toJSON();
        };
        FoundationBaseModel.convertFoundationV2toV1 = function(iV2Object) {
            //somebasics changed name
            var lV1Object = {
                tempId: iV2Object.tempId,
                cestamp: iV2Object.cestamp,
                physicalId: iV2Object.id,
                busType: iV2Object.type,
                objectId: iV2Object.id //this is wrong but needed for some V1 services

            };
            //don't convert related data and children for now
            var lKeys = Object.keys(iV2Object.dataelements);
            var lNbKeys = lKeys.length;
            var lDataElements = {};
            for (var lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                var lCurKey = lKeys[lCurKeyIdx];
                if (lCurKey === "image") {

                    lDataElements[lCurKey] = {
                        value: [{
                            imageValue: iV2Object.dataelements[lCurKey],
                            imageSize: 'ICON'
                        }]
                    };
                } else {

                    lDataElements[lCurKey] = {
                        value: [{
                            value: iV2Object.dataelements[lCurKey]
                        }]
                    };
                }
            }
            lV1Object.dataelements = lDataElements;
            return lV1Object;
        };
        return FoundationBaseModel;
    });

/*global define*/
/**
 * @module Foundation/Collections/FoundationBaseCollection
 *  define a base class for foundation collections.  This will be responsible for accessing the Foundation APIs and services.
 *  this is a class for collections which corresponds to objects directly returned by our service.
 *  Collections managing model objects which are related data will need ot use FoundationChildCollection as a supertype
 * @options  serviceName  the name of the service to use to fetch data.  This can be set by options, the setup of a derived class should call
 *  its parent setup so the serviceName can be maintained.
 * @require UWA/Core
 * @require UWA/Class/Collection
 * @require DS/Foundation/Models/FoundationData
 *
 * @extend DS/Foundation/Models/FoundationData
 */
define('DS/Foundation/Collections/FoundationBaseCollection', //define module
    ['UWA/Core', 'UWA/Class/Collection', 'UWA/Class/Model', 'DS/Foundation/FoundationData', 'DS/Foundation/Models/FoundationBaseModel', 'DS/Foundation/WidgetTagNavInit'], //prereqs

    function(UWA, Collection, Model, FoundationData, FoundationBaseModel, WidgetTagNavInit) {
        'use strict';
        var basicsNotFields = ['objectId', 'physicalId', 'cestamp', 'relId', 'tempId', 'busType']; //add more, those won't be converted back to fields
        var FoundationChildCollection;
        var FoundationBaseCollection = Collection.extend({
            _uwaClassName: 'FoundationBaseCollection',
            data: function() {
                var lRet;
                if (this._data) {
                    lRet = this._data;
                } else if (this._parentCollection && UWA.is(this._parentCollection.data, 'function')) {
                    lRet = this._parentCollection.data();
                }

                return lRet;
            },
            // Reference to this collection's model.
            model: FoundationBaseModel,
            /**
             * register a FoundationChildCollection for a relationshipname.
             * Any relationship of this name will point to object which should be managed by that collection
             * @param {String} relationshipName name of the relationshipName
             * @param {Collection} child collection to register as child
             */
            registerChildCollection: function(relationshipName, child) {
                if (!this._childrenMap) {
                    this._childrenMap = {};
                }
                this._childrenMap[relationshipName] = child;
            },
            /**
             * get a FoundationChildCollection for a relationshipname.
             * Any relationship of this name will point to object which should be managed by that collection
             * @param {String} relationshipName the name of the relationship
             * @return {Collection} the child collection
             */
            getChildCollection: function(relationshipName) {
                var lRet;
                if (this._childrenMap) {
                    lRet = this._childrenMap[relationshipName];
                }
                return lRet;

            },
            /**
             * empty a collection and recursively all its children.
             * does not trigger events
             */
            __emptyCompletely: function() {
                this.reset([], {
                    silent: true
                });
                if (this._childrenMap) {
                    var lKeys = Object.keys(this._childrenMap);
                    var lNbKeys = lKeys.length;
                    for (var lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                        var lCurKey = lKeys[lCurKeyIdx];
                        var lCurChildCollection = this._childrenMap[lCurKey];
                        lCurChildCollection.__emptyCompletely();

                    }
                }

            },
            /**
             * translate the Foundation objects to a json object more compatible with UWA/Class/Collection.
             * we will assume with have a FoundationObject if widgets is set to an array
             * @param {Object} iJSON the input from the constructor
             */
            init: function FoundationCollectionConstructor(iJSON) {
                //overwriding the constuctor will let us translate arguments which are in the Foundation services format to our simpler format
                var args = Array.prototype.slice.call(arguments, 0);
                //  this.data = data;
                if (iJSON && iJSON.datarecords) {
                    var modelsJSON = this._convertFoundationData(iJSON);
                    args[0] = modelsJSON;
                }
                this._parent.apply(this, args);

            },
            /**
             * override setup:
             * @param {Array} models the models for the new collections
             * @param {Object} options the options
             * @return {Object} the return from the parent method.  Normally undefined
             */
            setup: function FoundationCollectionSetup(models, options) {
                if (options) {
                    this._serviceName = options.serviceName;
                    this._partialRefreshServiceName = options.partialRefreshServiceName;
                    this._localStore = options.localStore; //bcc: TODO should hide local store but still used by model
                }
                var lRelations = this.model.prototype._relations;
                if (this.model && lRelations) {
                    //iterate over the relationships
                    //create the child collections
                    var lNbRelations = lRelations.length;
                    for (var lCurRelIdx = 0; lCurRelIdx < lNbRelations; lCurRelIdx++) {
                        var lCurRel = lRelations[lCurRelIdx];
                        var ChildCollectionType = lCurRel.collectionType || FoundationChildCollection; /*var lCurChildCollection =*/
                        new ChildCollectionType(null, { //eslint-disable-line no-new
                            parentCollection: this,
                            relationshipName: lCurRel.key,
                            serviceName: lCurRel.serviceName,
                            model: lCurRel.relatedModel
                        }); //as part of the creation this will be registered
                    }
                }
                return this._parent.apply(this, arguments);
            },
            /**
             * converts a json object in particular one like would be returned by UWA.Model.toJSON to a field array like what is expected by foundation.
             * for each key in the attrs json object a field entry will be created.
             * A field entry has a property name which correspond to the key in the json object and a property value which is an object with either just actualValue
             * or an actualValue and a displayValue
             * the expected result for {owner:{displayValue:'displayOwner', actualValue:'actualOwner'}, attr:'attrValue} is
                 [{
                        name: 'owner',
                        value: {
                            displayValue: 'displayOwner',
                            actualValue: 'actualOwner'
                        }
                    }, {
                        name: 'attr',
                        value: {
                            actualValue: 'attrValue'
                        }
                    }]
                    @param {Object} attrs data to convert
                    @return {Object} converted data

             */
            _convertToFoundationData: function(attrs) {
                //the expected format is an array of fields
                var hasOwn = Object.prototype.hasOwnProperty;
                var ret = [];
                var relations = this.model.prototype._relations;

                var relationNames = relations ? relations.map(function(rel) {
                    return rel.key;
                }) : [];
                for (var key in attrs) {

                    if (hasOwn.call(attrs, key) && basicsNotFields.indexOf(key) === -1 && relationNames.indexOf(key) === -1) {

                        var value = attrs[key];

                        //                    if (value === undefined || value._isCollection) {
                        //                        continue;
                        //                    }
                        var fieldObject = {
                            name: key
                        };
                        /*
                                            if (typeof value === 'undefined') {
                                                continue;
                                            }
                                            */
                        if (UWA.is(value, 'string')) {
                            value = {
                                displayValue: value
                            };
                        } else if (UWA.is(value, 'number')) {
                            value = {
                                displayValue: value.toString(10)
                            };
                        }
                        fieldObject.value = value;
                        ret.push(fieldObject);
                    }
                }
                return ret;
            },
            /**
             * converts to a json model for the MVC.  Return null in case of errors.
             * @param {Object} data object in the foundation format
             * @param {boolean} checkFiltered whether we should check for filters
             * @return {Object} the converted data
             */
            _convertFoundationData: function _convertFoundationData(data, checkFiltered) {
                var modelsJSON = data;
                if (data) {
                    if (modelsJSON.datarecords && (data.success === undefined || data.success)) { //if we are not in this case we are screwed I guess
                        FoundationData._setInternalProperty(modelsJSON, '_mvcCollection', this);
                        this._data = modelsJSON;
                        modelsJSON = FoundationData.getContainerData(modelsJSON, null, null, checkFiltered, true /*allLevels*/ ); //the all levels argument
                        //will flatten the data into the list
                        //of all first level and their children
                    } else {
                        return null;
                    }
                }
                return modelsJSON;
            },
            /**
             * method to apply tag navigator filters
             */
            _applyFilter: function _applyFilter() {
                var models, modelsJSON, checkFiltered = true;
                //loop through objects
                if (this._data) {
                    modelsJSON = this._convertFoundationData(this._data, checkFiltered);
                    models = modelsJSON.map(function(obj) {
                        return obj._mvcModel;
                    });
                    this.reset(models);
                }
            },
            /**
             * checks if a read request corresponds to a read from the server or from the local store.
             * @param {Collection} collection unused the collection being fetched.  Should be the same as this
             * @param {options} options the options
             * @return {boolean} is it a server call
             */
            isServerFetch: function(collection, options) {
                var that = this;
                var store = that._localStore;
                return options && options.server || !store;
            },
            /**
             * retrieves the associated storage.
             * @return {Storage} storage for this collection
             */
            _getStorage: function() {

                return this._localStore && this._localStore._storage;
            },
            /**
             * update a model in the foundation in memory structure depending on what was done to it.
             * set the _rowObjects variable on the model in case of a create
             * @param {String} method what type of update "create" "update" "patch" "delete" @see Model.prototype.sync method
             * @param {Model} model the model to update
             * @return {Object} the updated row object
             */
            updateModelInFoundation: function(method, model /*, options*/ ) {
                // var that = this;
                var attrs = model.toJSON();
                var lCollectionForConvertion = model.collection || this; //need to use the right collection for convertion or we will not have the correct relations
                var foundationData = lCollectionForConvertion._convertToFoundationData(attrs);
                var rowObjects = model._rowObjects;
                var modelOrId = rowObjects && rowObjects.length === 1 ? rowObjects[0] : model.id; //use the id as _rowObjects contains an array in case of multiinstanciation
                //we should not try to apply the change multiple times, some would work (update) but some wouldn't
                //we need when the server sends back the success to update all the instances though.
                var actualMethod = method === 'create' && rowObjects && rowObjects.length ? 'update' : method; //in case of several calls to create just update the attributes
                //this can happen if we do a save on an object which is new and on which related data were added.
                //when adding related data on a new object we update the foundation data, however the object isn't really
                //saved yet and will still look like new to backbone

                var rowObject;
                var lInMemoryData = this.data();
                if (lInMemoryData) {
                    switch (actualMethod) {
                        case 'create':
                            //create is supposed to be a real creation, we add the object to foundation and we will initiate _rowObjects
                            rowObject = FoundationData.addObject(lInMemoryData, null, foundationData);
                            model._rowObjects = [rowObject];
                            FoundationData._setInternalProperty(rowObject, '_mvcModel', model);
                            break;
                        case 'update':
                        case 'patch':
                            rowObject = FoundationData.modifyObject(lInMemoryData, modelOrId, foundationData);
                            break;
                        case 'delete':
                            if (rowObjects && rowObjects.length) {
                                //get the first _rowObject
                                var lRowObject = rowObjects[0];
                                //check if it is a related data or a child
                                //                        if (lRowObject._relationship && lRowObject._relationshipParentObject) {
                                //                            //need to delete a related data
                                //                            rowObject = FoundationData.deleteRelatedObject(lInMemoryData,
                                //lRowObject._relationship, lRowObject._relationshipParentObject /*id or object*/ , lRowObject);
                                //                        } else  {
                                rowObject = FoundationData.deleteObject(lInMemoryData, lRowObject);
                                //      }
                                for (var lCurRowObjectIdx = 1, len = rowObjects.length; lCurRowObjectIdx < len; lCurRowObjectIdx++) {
                                    //remove
                                    lRowObject = rowObjects[lCurRowObjectIdx];
                                    var lRelationship = lRowObject._relationship;
                                    if (!lRelationship && lRowObject._parentObject) {
                                        lRelationship = 'children';
                                    }
                                    var lParentObject;
                                    if (lRelationship) {
                                        lParentObject = lRowObject._relationshipParentObject || lRowObject._parentObject;

                                    }
                                    FoundationData.__deleteObject(lInMemoryData, lRowObject);
                                    if (lRelationship && lParentObject && lParentObject._mvcModel) {
                                        lParentObject._mvcModel._fireRelationshipChangeEvents(lRelationship, {});
                                    }
                                }

                            } else {
                                rowObject = FoundationData.deleteObject(lInMemoryData, modelOrId);
                            }
                            break;
                        default:
                            break;
                    }
                }
                return rowObject;
            },
            /**
             * retrieves a relationship description
             * @param {String} iRelName the name of the relationship to retrieve
             * @return {Object} relationship description
             */
            getRelationDescription: function getRelationDescription(iRelName) { //the result of this could be cached, we would need to update when states are changed
                var lRet;
                if (this.model.prototype._relations) {
                    //get the corresponding relationship meta info
                    var lRel = this.model.prototype._relations.filter(function(iObject) {
                        return iObject.key === iRelName;
                    });
                    lRel = lRel.length ? lRel[0] : undefined;
                    if (lRel) {
                        var lSchema = lRel.schema;
                        if (!lSchema) {
                            //read data from foundation
                            if (this.data() && this.data().widgetType) { //we have data from Foundation, lets read it
                                //there should be a widgets entry with an array of one element with name info
                                var fieldDictionary = FoundationData.getAllFields(this.data());
                                var attrDefinition = fieldDictionary[iRelName + 'Relationship'];
                                if (attrDefinition) {
                                    var rangeDef = attrDefinition.range.item;
                                    //scan it
                                    var lNbRangeDefItem = rangeDef.length;
                                    lSchema = lRel.schema = {};
                                    for (var lCurRangeDefItemIdx = 0; lCurRangeDefItemIdx < lNbRangeDefItem; lCurRangeDefItemIdx++) {
                                        var lCurRangeDefItem = rangeDef[lCurRangeDefItemIdx];
                                        if (lCurRangeDefItem.value === 'parentDirection') {
                                            lRel.schema.parentDirection = lCurRangeDefItem.display;
                                            continue;
                                        }
                                        if (lCurRangeDefItem.value === 'parentRelName') {
                                            lRel.schema.parentRelName = lCurRangeDefItem.display;
                                            continue;
                                        }
                                    }


                                }

                            }
                        }
                        lRet = lSchema;
                    }

                }
                return lRet;
            },
            /**
             * retrieves a related object by physicalid.
             * this will either retrieve an existing object based on the requested relationship (object could come from any parent) or it will create a new one and fetch data from the server.
             * @param {String} iRelationName the name of the related data ('assignees' for instance)
             * @param {String} iPhysicalId the id of the related data to retrieve.  This should be a physicalId, not an objectId
             * @param {Boolean} iDontFetch if the fetch call shouldn't be sent
             * @param {Boolean} iDontCreate if we shouldn't create a placeholder in case the object is not found (only works in conjunction with iDontFetch
             * @param {Object} options the options object
             * @return {Model} the related object
             */
            getRelatedObject: function(iRelationName, iPhysicalId, iDontFetch, iDontCreate, options) {
                var lChildCollection = this.getChildCollection(iRelationName);
                var lRetObject;
                if (lChildCollection) {
                    lRetObject = lChildCollection.get(iPhysicalId);
                }
                if (!lRetObject && lChildCollection && !iDontCreate) {
                    //not found in the collection create a placeholder
                    var lInputObject = {};
                    lInputObject.physicalId = iPhysicalId;
                    lRetObject = lChildCollection.add(lInputObject, {
                        existingObject: true
                    });
                    if (!iDontFetch) {
                        lRetObject.fetch(options);
                    }

                }
                return lRetObject;
            },
            /**
             * @override fetch.
             * if the options do not explicitly have a merge: false add merge: true so that rowObjects of multiinstanciated models are correctly set
             * @param {Object} options the options
             * @return {Object} object with cancel method
             */
            fetch: function(options) {
                var lOptions = options || {};
                if (lOptions.merge !== false) {
                    lOptions.merge = true;
                }
                return this._parent(lOptions);
            },
            /**
             * @override sync
             * on collection a fetch will by default be local unless the server:true option is set.
             * CUD operation should be both server and local by default.
             * TODO: should return a cancelable object
             */
            sync: function(method, collection, options) {
                var lOptions = options || {};
                var that = this;
                var lStorage = that._getStorage();

                if (method === 'read') {

                    if (that.isServerFetch(collection, options)) {
                        //call the server side code

                        FoundationData.loadWidget(this._serviceName, function(data) { //bcc: note no syncrhonization between client and server here, we just eraze all.  Maybe a bit violent.
                            //do a systematic reset since we need to make sure that we will not keep objects pointing to the old data structure
                            //                       // options.reset = true;
                            //also reset all our children Collection otherwise there may be some old MVC models pointing to the previous data
                            //we will erase whatever is in our collection and in our children collection
                            if (lOptions.remove !== false) {
                                that.__emptyCompletely();
                            }
                            //initialize the tags
                            if (that._data) {
                                FoundationData._setInternalProperty(data, 'tnProxy', that._data.tnProxy);
                            }
                            if (!lOptions.noTag) {
                                WidgetTagNavInit.init();
                                WidgetTagNavInit.loadTagData(data);
                            }
                            //             setTimeout(WidgetTagNavInit.loadTagData.bind(WidgetTagNavInit, data), 5000);

                            var modelsJSON = that._convertFoundationData(data);
                            var lastReadFrom = that.lastReadFrom;
                            that.lastReadFrom = 'server';
                            if (modelsJSON === null) {
                                typeof options.onFailure === 'function' && options.onFailure(data);
                            } else {
                                options.onComplete(modelsJSON);
                            }
                            if (lStorage) {
                                try {
                                    FoundationData.saveCachedData(lStorage, that._serviceName, data);
                                } catch (e) {
                                    console.error(e); //usually quota exceeded exception
                                }

                            }

                            if (that.lastReadFrom !== lastReadFrom) {
                                that.dispatchEvent('onChange:lastReadFrom', [that, that.lastReadFrom, options]);
                            }
                        });
                    } else {
                        var data = FoundationData.loadCachedData(lStorage, that._serviceName);
                        FoundationData.__buildIndexCache(data);
                        var modelsJSON = that._convertFoundationData(data);
                        var lastReadFrom = that.lastReadFrom;
                        that.lastReadFrom = 'local';
                        if (that.lastReadFrom !== lastReadFrom) {
                            that.dispatchEvent('onChange:lastReadFrom', [that, that.lastReadFrom, options]);
                        }
                        if (options.onComplete) {
                            options.onComplete(modelsJSON);
                        }
                    }
                } else if (method === 'create' || method === 'update' || method === 'patch' || method === 'delete') {
                    if (!options.localOnly || options.server) {
                        if (collection instanceof Model) {
                            var model = collection; //in this case it is not a collection
                            var rowObject = that.updateModelInFoundation(method, model, options);

                            var applyUpdatesCallback = function applyUpdatesCallback(success, data, clonedInfo) {
                                if (success) { //bcc: code below may not be needed anymore as the sync from foundation would have updated the models
                                    //rowObject should have been updated, send it to the callback which should in turn call the model's parse
                                    if (options && options.onComplete) {
                                        options.onComplete(rowObject, data, options);
                                    }
                                } else {
                                    options.clonedInfo = clonedInfo;
                                    options.onFailure(rowObject, data, options); //TODO put the real error message
                                }
                            };
                            var lData = this.data();
                            if (!options.delayedSave) {
                                if (lData) {
                                    FoundationData.applyUpdates(lData, applyUpdatesCallback, false); //for now save everything, we will see about the saveId later
                                }
                                //local storage saves the complete data set
                                if (lStorage) {
                                    FoundationData.saveCachedData(lStorage, this._serviceName, lData);
                                }
                            }

                        }
                    }
                }
            },
            save: function(options) {
                var lData = this.data();
                var applyUpdatesCallback = function applyUpdatesCallback(success, data, clonedInfo) {
                    if (success) { //bcc: code bellow may not be needed anymore as the sync from foundation would have updated the models
                        //rowObject should have been updated, send it to the callback which should in turn call the model's parse
                        if (options && options.onComplete) {
                            options.onComplete(lData, options);
                        }
                    } else {
                        var lOptions = UWA.clone(options, false);
                        lOptions.clonedInfo = clonedInfo;
                        options.onFailure(lData, lOptions); //TODO put the real error message
                    }
                };

                if (lData) {
                    FoundationData.applyUpdates(lData, applyUpdatesCallback, false); //for now save everything, we will see about the saveId later
                }
            }
        });
        FoundationChildCollection = FoundationBaseCollection.extend({
            _uwaClassName: 'FoundationChildCollection',
            // Reference to this collection's model.
            model: FoundationBaseModel,


            setup: function FoundationChildCollectionSetup(models, options) {
                if (options) {
                    this._parentCollection = options.parentCollection;
                    if (this._parentCollection && options.relationshipName) {
                        this._parentCollection.registerChildCollection(options.relationshipName, this);
                    }
                }

                return this._parent.apply(this, arguments);
            },

            /**
             * retrieves the associated storage.
             * @return {Storage} storage for this collection
             */
            _getStorage: function() {

                return this._parentCollection._getStorage();
            },
            /**
             * CRUD operations will have to be done on the parentCollection.
             *
             */
            sync: function( /*method, collection, options*/ ) {
                var that = this;
                that._parentCollection.sync.apply(that._parentCollection, arguments);
            }
        });
        FoundationBaseCollection.childCollection = FoundationChildCollection;
        return FoundationBaseCollection;
    });

/**
Implementation of the WidgetUwaUtils component
Copyright (c) 1992-2018 Dassault Systemes.
All Rights Reserved.
This program contains proprietary and trade secret information of Dassault Systemes
Copyright notice is precautionary only
and does not evidence any actual or intended publication of such program
<a href='http://www.3ds.com/products/enovia/'>www.3ds.com/products/enovia/</a>

@module widget-infra

@since 0.0.1
@author TWS
@requires jQuery 2+
 */

/**
 * WidgetUwaUtils contains the business logic for the configurable UWA widgets
 * Most of these methods are called via myFunc.call() and the scope of 'this' is passed in
 *
 * @namespace
 * @static
 */
/*global enoviaServer, widget*/
/*global define, require*/
/*global WidgetConstants, WidgetTagNavInit*/
define('DS/Foundation/WidgetUwaUtils', ['UWA/Core', 'DS/ENO6WPlugins/jQuery_3.3.1', 'UWA/Utils/Client', //too long
        'DS/Foundation/WidgetAPIs', 'DS/Foundation/WidgetEngine', 'DS/Foundation/FoundationData', 'DS/Foundation/FoundationAjax', 'DS/i3DXCompassServices/i3DXCompassPubSub'
    ],

    function(UWA, jQuery, UWAUtilsClient, WidgetAPIs, WidgetEngine, FoundationData, FoundationAjax, PubSub) {
        'use strict';
        var WidgetUwaUtils = {
            iconPath: '/widget/images/MyApps/iconENOVIA.png',
            widgetization: FoundationAjax.widgetization,

            /**
             * Sets up some preliminary values
             *
             * @method onLoad
             * @param {Object} widget The UWA widget instance
             */
            onLoad: function(widget, MyWidget) {
                var icon = widget.getValue('icon');
                if (icon) {
                    widget.setIcon(enoviaServer.computeUrl('/' + icon));
                } else {
                    var prefix = enoviaServer.widgetName.substring(0, 3);
                    if (prefix !== 'CSG') {
                        widget.setIcon(enoviaServer.computeUrl(WidgetUwaUtils.iconPath));
                    }
                }
                var title = widget.getValue('title');
                if (title) {
                    widget.setTitle(title);
                } else {
                    widget.setTitle('');
                }

                MyWidget.setupIntercomConnections();
                MyWidget.loadBPS();
            },
            /**
             * Sets up the UWA Intercom connections for compass BPS etc
             *
             * @method setupIntercomConnections
             * @param {Object} widget The UWA widget instance
             * @param {Object} MyWidget The UWA Widget Object
             * @param {String} randomName Random name for the sockets
             */
            setupIntercomConnections: function(widget, MyWidget) {
                //compass sockets
                //            MyWidget.compassSocketName = randomName + 'EventSocket';
                //            MyWidget.compassSocket = new MyWidget.InterCom.Socket(MyWidget.compassSocketName);
                //            MyWidget.compassSocket.subscribeServer('com.ds.compass', window.parent);
                //preference server
                MyWidget.prefIntercomServer = new MyWidget.InterCom.Server('bps.intercom.server', {
                    isPublic: true
                });
                MyWidget.prefIntercomServer.addListener('onAddPref', function(json) {
                    if (json.name === 'RefreshMe') {
                        MyWidget.onRefresh();
                        return;
                    }
                    var keys = json.name.split('e6w-preference_');
                    if (json.value) {
                        widget.setValue(json.name, json.value);
                        enoviaServer.preferences[keys[1]] = json.value;
                    } else {
                        widget.deleteValue(json.name);
                        delete enoviaServer.preferences[keys[1]];
                    }
                });
                MyWidget.prefIntercomServer.addListener('onSetTitle', function(json) {
                    widget.setTitle(json.title);
                    widget.setValue('title', json.title); //to get proper title upon widget load.
                });


                /**
                 * Register the selected object in SB or classic table in the compass
                 * onRegisteredId {Event} calls setObject with physicalID and security context
                 **/

                MyWidget.prefIntercomServer.addListener('onRegisteredId', function(json) {

                    var param = {
                        objectType: 'mime/type', //TODO let's put something real
                        objectId: json.physicalID,
                        envId: enoviaServer.tenant,
                        contextId: json.currentSecurityCtx
                    };
                    PubSub.publish('setObject', param);

                });

                /**
                 * Unregister the selected object in SB or classic table in the compass
                 * onUnregisteredId {Event} calls resetObject to reset the object
                 **/
                MyWidget.prefIntercomServer.addListener('onUnregisteredId', function() {
                    PubSub.publish('resetObject');
                });
            },
            /**
             * Gets BPS specific data like Storages, Spaces, Preferences
             *
             * @method loadBPS
             * @param {Object} widget The UWA widget instance
             * @param {String} showSpace Test for show/hide of Spaces in preferences
             */
            loadBPS: function(widget, showSpace, widgetConstantsName) {
                var storage = widget.getValue('collabstorage'),
                    othis = this;
                var processPreferences;
                var loading = WidgetConstants.str.Loading;
                if (loading) {
                    widget.setBody('<p>' + loading + '...</p>');
                }
                enoviaServer.rows = widget.getValue('totalrows');
                /**
                 * Process the storages, load constants and add then add them to the Storages preference
                 *
                 * @private
                 * @method processStorages
                 * @param {Object} data A list of storage objects
                 */

                function processStorages(data) {
                    othis.myAppsStorages = data;
                    WidgetUwaUtils.processStorages(data, storage);

                    enoviaServer.language = widget.lang;
                    //load widget constants now that we have a valid storage URL.
                    WidgetAPIs.getWidgetConstants(widgetConstantsName, function() {
                        //TODO: after we got the constants only the NLS of the preference has changed.  We should not go through the whole method as it leads to
                        //calling the call for the cspaces twice, once initially and the second time when the constants are there
                        processPreferences(widget, data);
                    });
                } //end function processStorages
                /**
                 * Add the storages preferences.
                 *
                 * @private
                 * @method processPreferences
                 * @param {Object} data A list of storage objects
                 */

                function processPreferences(widget, data) {
                    othis.setTitlePref();
                    WidgetUwaUtils.setStoragesPrefs(widget, data, storage, showSpace);
                    if (WidgetUwaUtils.widgetization !== widget.getValue('widgetName')) {
                        delete enoviaServer.selectedSpace;
                        othis.setRowPref();
                    } else if (enoviaServer.selectedSpace !== widget.getValue('collabspace')) {
                        delete enoviaServer.selectedSpace;
                    }
                    //othis.setSizePref();  //new 3dd allows height adjustments.

                    // try to get collab spaces
                    if (showSpace.toLowerCase() !== 'false') {
                        //get the collab spaces
                        othis.processStorageChange(storage);
                    } else if (!widget.isEdit) {
                        widget.setValue('collabstorage', enoviaServer.storageUrl);
                        othis.onAfterLoad();
                    }
                } //end function processStoragesPreferences
                if (this.myAppsStorages) {
                    processPreferences(widget, this.myAppsStorages);
                } else {
                    WidgetAPIs.getCollaborativeStorages(processStorages);
                }
            },
            /**
             * Initializes the Drag and Follow items
             *
             * @method initWidgetDnF
             */
            initWidgetDnF: function() {
                require(['UWA/Core', 'UWA/Utils/InterCom'], function(Core, InterCom) {
                    var fakeEl = null;
                    var socketForWidget = new InterCom.Socket('bps_dispatch_' + widget.id);
                    socketForWidget.subscribeServer('ifweServer', top);
                    socketForWidget.addListener('uwaSBRowDragLeaveEvent', function(json) {
                        var instances = parent.UWA.Widgets.instances,
                            i, instance, env;
                        //alert(json.url); // display message from socketBData
                        Core.log(widget.id + '-uwaSBRowDragLeaveEvent');

                        for (i = 0; i < instances.length; i += 1) {
                            instance = instances[i];
                            env = instance.environment;
                            if (instance.environment.embedded && instance.environment.embedded.id === widget.id) {
                                env = instance.environment;
                                break;
                            }
                        }
                        // Handle click on li here
                        if (!Core.is(fakeEl, 'element')) {
                            fakeEl = UWA.createElement('div', {
                                'class': 'create-widget',
                                styles: {
                                    display: 'none'
                                }
                            });
                            //console.dir(BPSUWAWidget.fakeEl);
                            top.document.body.getElement('.wi-' + env.widget.id).addContent(fakeEl);
                        }

                        var confData = {
                            defaultData: {
                                widgetName: WidgetUwaUtils.widgetization,
                                params: 'appName=ENOBUPS_AP',
                                objectId: json.objectId
                            }
                        };
                        fakeEl.setAttribute('data-url', enoviaServer.computeUrl('/webapps/Foundation/foundation.html'));
                        fakeEl.setAttribute('data-title', json.name);
                        fakeEl.setAttribute('data-data', JSON.stringify(confData.defaultData));
                        //fakeEl.setAttribute('data-icon', enoviaServer.sRealURL + '/common/images/iconSmallWorkspace.gif');
                        fakeEl.setAttribute('data-icon', enoviaServer.computeUrl('/common/' + json.icon));
                        console.dir(fakeEl);
                        Core.Event.dispatchEvent(fakeEl, 'mousedown', {});
                    });
                });
            },

            /**
             * Initializes the topbar proxy items
             *
             * @method initWidgetTopBar
             */
            initWidgetTopBar: function() {
                require(['UWA/Utils/InterCom', 'DS/TopBarProxy/TopBarProxy'], function(InterCom, TopBarProxy) {

                    var thisCommandProvider = {};

                    var callback = thisCommandProvider.callback = function(menuItem) {
                        var socketForWidget = new InterCom.Socket();
                        socketForWidget.setDebugMode(true);
                        console.dir(document.location);
                        socketForWidget.subscribeServer('ifweServer', top, document.location);
                        var jsonData = {
                            url: menuItem.get('url')
                        };
                        socketForWidget.dispatchEvent('uwaGlobalToolbarAddEvent', jsonData, 'bps_handle_' + widget.id);
                    };

                    var ajaxActionsURL = '/resources/bps/menu/Actions';
                    var ajaxProfileURL = '/resources/bps/menu/DashboardPersonMenu';
                    var ajaxHelpURL = '/resources/bps/menu/DashboardHelpMenu';

                    thisCommandProvider.topBarProxy = new TopBarProxy({
                        'id': widget.id
                    });
                    var addCallback = function(data) {
                        data.forEach(function(item) {
                            if (item.submenu) {
                                item.submenu.forEach(function(subItem) {
                                    if (subItem.submenu) {
                                        subItem.submenu.forEach(function(sub2Item) {
                                            sub2Item.onExecute = callback;
                                        });
                                    } else {
                                        subItem.onExecute = callback;
                                    }
                                });
                            } else {
                                item.onExecute = callback;
                            }
                        });
                        return data;
                    };
                    var topbarAjaxActionsComplete = function(data) {
                        var cbData = addCallback(data);
                        thisCommandProvider.topBarProxy.addContent({
                            add: cbData,
                            //share: [],
                            //home: [],
                            //help: []
                        });
                    };

                    var topbarAjaxProfileComplete = function(data) {
                        var cbData = addCallback(data);
                        thisCommandProvider.topBarProxy.addContent({
                            profile: cbData,
                        });
                    };

                    var topbarAjaxHelpComplete = function(data) {
                        var cbData = addCallback(data);
                        thisCommandProvider.topBarProxy.addContent({
                            help: cbData,
                        });
                    };

                    FoundationData.ajaxRequest({
                        url: ajaxActionsURL,
                        dataType: 'json',
                        callback: topbarAjaxActionsComplete
                    });
                    FoundationData.ajaxRequest({
                        url: ajaxProfileURL,
                        dataType: 'json',
                        callback: topbarAjaxProfileComplete
                    });
                    FoundationData.ajaxRequest({
                        url: ajaxHelpURL,
                        dataType: 'json',
                        callback: topbarAjaxHelpComplete
                    });
                });
            },
            /**
             * Sets how many rows to show in the widget (for lists)
             *
             * @method setRowPref
             */
            setRowPref: function() {
                var defaultValue = '100';
                widget.addPreference({
                    name: 'totalrows',
                    type: 'list',
                    defaultValue: defaultValue,
                    options: [{
                        label: '10',
                        value: '10'
                    }, {
                        label: '20',
                        value: '20'
                    }, {
                        label: '50',
                        value: '50'
                    }, {
                        label: '100',
                        value: '100'
                    }, {
                        label: '500',
                        value: '500'
                    }, {
                        label: '1000',
                        value: '1000'
                    }],
                    label: WidgetConstants.str.Rows,
                    onchange: 'onRowChange'
                });
                if (!enoviaServer.rows) {
                    enoviaServer.rows = defaultValue;
                }
            },
            /**
             * Sets small medium large view size for widget
             *
             * @method setSizePref
             * @param {Object} widget The UWA widget instance
             */
            setSizePref: function() {
                enoviaServer.widgetsize = widget.getValue('widgetsize');
                enoviaServer.widgetHeight = {
                    small: 300,
                    medium: 600,
                    large: 900
                };
                widget.addPreference({
                    name: 'widgetsize',
                    type: 'list',
                    defaultValue: 'small',
                    options: [{
                        label: WidgetConstants.str.Small,
                        value: 'small'
                    }, {
                        label: WidgetConstants.str.Medium,
                        value: 'medium'
                    }, {
                        label: WidgetConstants.str.Large,
                        value: 'large'
                    }],
                    label: WidgetConstants.str.Size,
                    onchange: 'onSizeChange'
                });
            },
            /**
             * Sets the widget title
             *
             * @method setTitlePref
             * @param {Object} widget The UWA widget instance
             */
            setTitlePref: function() {
                widget.addPreference({
                    name: 'title',
                    type: 'text',
                    defaultValue: '',
                    label: WidgetConstants.str.WidgetTitle,
                    onchange: 'onTitleChange'
                });
            },
            setStoragesPrefs: function(widget, data, storage, showSpace) {
                var myOpts = [];
                jQuery(data).each(function() {
                    if (storage === this.url) {
                        enoviaServer.storageUrl = this.url;
                        enoviaServer.tenant = this.id;
                    }
                    myOpts.push({
                        label: this.displayName,
                        value: this.url
                    });
                });

                widget.addPreference({
                    name: 'collabstorage',
                    type: 'list',
                    defaultValue: enoviaServer.storageUrl,
                    options: myOpts,
                    label: WidgetConstants.str.CollaborativeStorages,
                    onchange: 'onStorageChange'
                });

                if (showSpace.toLowerCase() !== 'false') {
                    widget.addPreference({
                        name: 'collabspace',
                        type: 'list',
                        defaultValue: '',
                        options: [{
                            label: '',
                            value: ''
                        }],
                        label: WidgetConstants.str.CollaborativeSpaces
                    });
                }
            },
            processStorages: function(data, iTenant) {
                var isInPrefs = false;
                var storage;
                var defTenant = iTenant ? undefined : widget.getValue('tenant') || widget.getValue('x3dPlatformId');
                var lNbStorages = data.length;
                for (var i = lNbStorages - 1; i >= 0; i--) {
                    storage = data[i];
                    storage.url = storage['3DSpace'];
                    //if storage doesn't have 3DSpace, remove it from data so we don't add it to tenant preference
                    if (!storage.url) {
                        data.splice(i, 1);
                        continue;
                    }
                    storage.id = storage.platformId;
                    storage.swym = storage['3DSwym'];
                    storage.searchUrl = storage['3DSearch'];
                    storage.url = storage.url.replace(':443', ''); //work-around config issue.
                    if (storage.url.charAt(storage.url.length - 1) === '/') { //remove slash from end of URL.
                        storage.url = storage.url.substring(0, storage.url.length - 1);
                    }
                    if (storage.id) {
                        storage.url = storage.url.replace(storage.id, storage.id.toLowerCase()); //ensure URL prefix is lower case for valid URL.
                    }
                    if (storage === storage.url || (defTenant && defTenant.toUpperCase() === storage.id.toUpperCase())) { //use preference storage or selected tenant on load.
                        isInPrefs = true;
                        if (defTenant && defTenant !== storage.id) { //changed only due to capitalization
                            widget.setValue('x3dPlatformId', storage.id);
                        }
                        enoviaServer.storageUrl = storage.url;
                        enoviaServer.tenant = storage.id;
                        //  enoviaServer.swym = storage.swym;
                        //  enoviaServer.searchUrl = storage.searchUrl;
                        UWA.merge(enoviaServer, storage);
                    }
                }
                if (!isInPrefs && !widget.isEdit) {
                    isInPrefs = true;
                    enoviaServer.storageUrl = data[0].url;
                    enoviaServer.tenant = data[0].id;
                    // enoviaServer.swym = data[0].swym;
                    // enoviaServer.searchUrl = data[0].searchUrl;
                    UWA.merge(enoviaServer, data[0]);
                }
                widget.setValue('x3dPlatformId', enoviaServer.tenant);
                widget.deleteValue('tenant');
            },
            /**
             * Generic interface to set any preference as a list
             *
             * @method setPref
             * @param {Object} widget The UWA widget instance
             * @param {String} label The preference label
             * @param {Object} data The name/value pairs for the list
             * @param {Function} changeEvent The function to execute onChange
             * @param {Boolean} isSortPref Is this a sort preference?
             * @param {Object} widget The UWA widget instance
             */
            setPref: function(name, label, data, changeEvent, isSortPref, widget) {
                var myOpts = [],
                    defaultValue = '',
                    sortdir = '';
                jQuery(data).each(function(index) {
                    myOpts.push({
                        label: this.displayName,
                        value: this.value
                    });
                    if (this.defaultValue || index === 0) {
                        defaultValue = this.defaultValue || this.value;
                        if (isSortPref) {
                            sortdir = this.sortdir;
                        }
                    }
                });

                widget.addPreference({
                    name: name,
                    type: 'list',
                    defaultValue: defaultValue,
                    options: myOpts,
                    label: label,
                    onchange: changeEvent ? changeEvent : 'onEditPrefChange'
                });

                if (isSortPref) {
                    var dirOptions = [{
                        displayName: WidgetConstants.str.OptionsSelect,
                        value: '',
                        defaultValue: sortdir
                    }, {
                        displayName: WidgetConstants.str.SortAscending,
                        value: 'ascending'
                    }, {
                        displayName: WidgetConstants.str.SortDescending,
                        value: 'descending'
                    }];
                    this.setPref('sortdir', WidgetConstants.str.SortDirection, dirOptions);
                }
            },
            /**
             * After the initial load we can now create the view
             *
             * @method onAfterLoad
             * @param {Object} widget The UWA widget instance
             */
            onAfterLoad: function(randomName) {
                var space = enoviaServer.space,
                    widgetName = enoviaServer.widgetName;

                if (widgetName === WidgetUwaUtils.widgetization) {
                    WidgetUwaUtils.initWidgetTopBar();
                    WidgetUwaUtils.initWidgetDnF();
                }

                //add custom preferences
                for (var key in widget.data) {
                    if (key.indexOf('e6w-preference_') !== -1) {
                        var prefValue;
                        try { /* jshint evil: true */
                            //var val = eval('(' + widget.getValue(key) + ')');
                            var val = JSON.parse(widget.getValue(key));
                            prefValue = widget.getValue(val.name);
                            widget.addPreference(val);
                            if (prefValue && prefValue !== '') {
                                enoviaServer.preferences[val.name] = prefValue;
                            }
                        } catch (e) {
                            prefValue = widget.getValue(key);
                            widget.addPreference(prefValue);
                            if (prefValue && prefValue !== '') {
                                var keys = key.split('e6w-preference_');
                                enoviaServer.preferences[keys[1]] = prefValue;
                            }
                        }
                    }
                }

                var initObj = {
                    name: widgetName,
                    div: randomName,
                    uwaWidget: widget,
                    viewpref: widget.getValue('view'),
                    sortpref: widget.getValue('sort'),
                    sortdirpref: widget.getValue('sortdir'),
                    callback: this.draw,
                    cspace: space,
                    params: enoviaServer.params,
                    tenant: enoviaServer.tenant
                };
                var data = (this.Widget) ? this.Widget.data : null;
                this.Widget = WidgetEngine.widget(initObj);
                this.Widget.setLabel(false);
                this.Widget.init(data);
            },
            /**
             * Draw the widget to the div
             *
             * @method draw
             * @param {Object} widget The UWA widget instance
             * @param {String} showSpace Test for show/hide of Spaces in preferences
             * @param {String} randomName Random name given to a div for uniqueness
             * @param {String} objectId The object if passed in
             */
            draw: function(widget, showSpace, randomName, objectId, MyWidget) {
                try {
                    var title = widget.getTitle(),
                        lbl = this.data.label;
                    //gqh: this is only needed for 3DSpace widget which does not use Foundation anymore.
                    //if (showSpace.toLowerCase() === 'true') {
                    //    title = MyWidget.spaceNames[widget.getValue('collabspace')] + ' ' + WidgetConstants.str.Content;
                    //} else {
                    if (!title) {
                        var objectLabel = '',
                            objId = widget.getValue('objectId') || objectId;
                        if (objId && objId !== '' && objId !== 'null') {
                            title = WidgetAPIs.getWidgetTitle(this.data, objId);
                            if (title) {
                                objectLabel = title;
                            }
                        } else if (lbl && lbl.text) {
                            var indexDash = lbl.text.lastIndexOf(' - ');
                            if (indexDash !== -1) {
                                objectLabel = lbl.text.substring(indexDash + 3);
                            } else {
                                objectLabel = lbl.text;
                            }
                        }
                        title = objectLabel;
                    }
                    //}
                    if (title && title !== '') {
                        widget.setTitle(title);
                        widget.setValue('title', title);
                    }
                    if (lbl && lbl.icon) {
                        widget.setIcon(enoviaServer.computeUrl('/' + lbl.icon));
                        widget.setValue('icon', lbl.icon);
                    }
                    //display user views.
                    var userviews = WidgetAPIs.getWidgetViews(this.data);
                    if (userviews.length > 0) {
                        MyWidget.setPref('view', WidgetConstants.str.Views, userviews);
                    }
                    //display sort options.
                    var sortfields = WidgetAPIs.getSortableFields(this.data);
                    if (sortfields.length > 0) {
                        sortfields = [{
                            displayName: WidgetConstants.str.OptionsSelect,
                            value: ''
                        }].concat(sortfields);
                        MyWidget.setPref('sort', WidgetConstants.str.Sorts, sortfields, null, true);
                    }
                } catch (e) {
                    console.log(e.message);
                    //do nothing
                }
                widget.setBody('<div id="' + randomName + '"></div>');
                jQuery('#' + randomName).empty().append(this.dom);
                jQuery('#' + randomName + ' .ds-widget').on('click', '[data-objectId]', MyWidget.onClickItem);
                widget.refreshing = false;

                WidgetUwaUtils.setWidgetHeight();
            },
            /**
             * Initiate a search of the widget data
             *
             * @method searchWidgets
             * @param {String} searchStr The value to search for
             */
            searchWidgets: function(searchStr) {
                if (this.Widget) {
                    var items = WidgetAPIs.getContainerItems(this.Widget.data),
                        i = 0,
                        len = items.length;
                    for (; i < len; i++) {
                        WidgetTagNavInit.keywordSearch(items[i], searchStr);
                    }

                }
            },
            /**
             * Wipe out all client side data and destroy the TagNavigator instance
             *
             * @method clearData
             */
            clearData: function() {
                //clear TN if exists
                if (this.Widget && this.Widget.data) {
                    WidgetAPIs.destroyTNProxies(this.Widget.data);
                    this.Widget.data = null;
                }
            },
            /**
             * @method onStorageChange
             */
            onStorageChange: function() {
                this.clearData();
                this.loadBPS();
            },
            /**
             * @method onSpaceChange
             */
            onSpaceChange: function() {
                this.clearData();
                //TODO: can't rely on widget.getValue in the onchange handler. Need to use onRefresh or onEndEdit
                enoviaServer.selectedSpace = widget.getValue('collabspace');
            },
            /**
             * @method onRowChange
             */
            onRowChange: function() {
                this.clearData();
            },
            /**
             * @method onSizeChange
             */
            onSizeChange: function() {
                enoviaServer.widgetsize = widget.getValue('widgetsize');
                this.onEdit();
            },
            /**
             * @method onTitleChange
             */
            onTitleChange: function(widget) {
                var title = widget.getValue('title');
                //temporary option to enable/disable sc enforcement on URL.
                if (title.toLowerCase().startsWith('sc:')) {
                    enoviaServer.scMode = true;
                    title = title.substring(3);
                } else {
                    enoviaServer.scMode = false;
                }
                if (widget.getTitle() !== title) {
                    widget.setTitle(title);
                }
            },
            /**
             * Changes the storages and retrieves your list of new spaces
             *
             * @method processStorageChange
             * @param {Object} widget The UWA widget instance
             * @param {String} storageUrl Where we find the storages
             */
            processStorageChange: function(storageUrl) { //bcc: I renamed the parameter so now the global widget is always used

                //    var space = widget.getValue('collabspace');
                var othis = this;

                /**
                 * Temp function so we can pass of processing asyncronously
                 *
                 * @method tmpFunc
                 * @private
                 * @param {Object} data Our storage objects
                 */

                function tmpFunc(data) {
                    WidgetUwaUtils.processUserCollabSpace(othis, data);
                    /*
                var defaultSpace = null,
                myOpts = [{
                    label: WidgetConstants.str.OptionsSelect,
                    value: ''
                }];

                if (!othis.spaceNames) {
                    othis.spaceNames = {};
                }
                othis.spaceNames[enoviaServer.storageUrl] = data; //save last retrieved storage spaces.
                jQuery(data).each(function () {
                    myOpts.push({
                        label: this.displayName,
                        value: this.name
                    });
                    othis.spaceNames[this.name] = this;

                    //if (space === this.name || (!isInSpace && !space && 'Common Space' === this.displayName)) {
                    if (space === this.name && space !== 'default') {
                        enoviaServer.space = this.name;
                    }
                    if (this.isDefault) { //this is the default SC for the user.
                    	othis.spaceNames['defaultSpace'] = this;
                    	defaultSpace = this.name;
                	}
                });
                //set default space if not specified yet.
                if (!enoviaServer.space) {
                	if (defaultSpace) {
                		enoviaServer.space = defaultSpace;
                	} else if (data[0].name !== 'default') {
                        enoviaServer.space = data[0].name;
                    }
                }

                widget.addPreference({
                    name: 'collabspace',
                    type: 'list',
                    defaultValue: enoviaServer.selectedSpace || defaultSpace,
                    options: myOpts,
                    label: WidgetConstants.str.CollaborativeSpaces,
                    onchange: 'onSpaceChange'
                });

                // Request edit to open/refresh
                if (widget.isEdit) {
                    widget.dispatchEvent('onEdit');
                }
                */

                    var widgetName = enoviaServer.widgetName;
                    if (!widget.isEdit) {
                        if (enoviaServer.space) {
                            if (widgetName === WidgetUwaUtils.widgetization) {
                                enoviaServer.space = enoviaServer.selectedSpace;
                                delete enoviaServer.selectedSpace;
                                widget.deleteValue('collabspace');
                                if (enoviaServer.space) {
                                    //fix cached cs data.
                                    if (othis.spaceNames['defaultSpace']) {
                                        delete othis.spaceNames['defaultSpace'].isDefault;
                                    }
                                    othis.spaceNames['defaultSpace'] = othis.spaceNames[enoviaServer.space];
                                    othis.spaceNames[enoviaServer.space].isDefault = true;
                                }
                            } else {
                                widget.setValue('collabspace', enoviaServer.space);
                            }
                        }
                        othis.onAfterLoad();
                    } else {
                        widget.setBody('<p>' + WidgetConstants.str.SpaceSelect + '</p>');
                    }
                }
                var cspaceData = this.spaceNames ? this.spaceNames[storageUrl] : null;
                if (cspaceData) {
                    tmpFunc(cspaceData);
                } else {
                    enoviaServer.space = null; //clear out existing space when getting spaces from a tenant.
                    WidgetAPIs.getCollaborativeSpaces(tmpFunc);
                }
            },

            processUserCollabSpace: function(MyWidget, data) {
                var organizations = [];
                var sameOrganization = false;

                var space = widget.getValue('collabspace'),
                    defaultSpace = null,
                    myOpts = [],
                    othis = MyWidget;

                if (!othis.spaceNames) {
                    othis.spaceNames = {};
                }
                othis.spaceNames[enoviaServer.storageUrl] = data; //save last retrieved storage spaces.

                // retrieve all organization names
                jQuery(data).each(function() {
                    var splitName = this.displayName.split('.');
                    if (splitName.length === 3) {
                        organizations.push(splitName[1]);
                    }
                });

                // determine if all belong to the same organization
                if (organizations.length === data.length && organizations.length > 1) {
                    sameOrganization = organizations.every(function(org) {
                        return (org === organizations[0])
                    });
                }

                jQuery(data).each(function() {
                    var displayName = this.displayName;
                    var splitName = this.displayName.split('.');

                    // display as collaborative space, organization, role
                    if (splitName.length === 3) {
                        displayName = splitName[2] + ' \u25CF ';
                        if (!sameOrganization) {
                            displayName += splitName[1] + ' \u25CF ';
                        }
                        displayName += splitName[0];
                    }

                    myOpts.push({
                        label: displayName,
                        value: this.name
                    });
                    othis.spaceNames[this.name] = this;

                    //if (space === this.name || (!isInSpace && !space && 'Common Space' === this.displayName)) {
                    if (space === this.name && space !== 'default') {
                        enoviaServer.space = this.name;
                    }
                    if (this.isDefault) { //this is the default SC for the user.
                        othis.spaceNames['defaultSpace'] = this;
                        defaultSpace = this.name;
                    }
                });
                //set default space if not specified yet.
                if (!enoviaServer.space) {
                    if (defaultSpace) {
                        enoviaServer.space = defaultSpace;
                    } else if (data[0].name !== 'default') {
                        enoviaServer.space = data[0].name;
                    }
                }

                widget.addPreference({
                    name: 'collabspace',
                    type: 'list',
                    defaultValue: enoviaServer.selectedSpace || defaultSpace,
                    options: myOpts,
                    label: enoviaServer.widgetName === WidgetUwaUtils.widgetization ?
                        WidgetConstants.str['emxFoundation.Widget.GlobalCollaborativeSpaces'] : WidgetConstants.str['emxFoundation.Widget.CollaborativeSpaces'],
                    onchange: 'onSpaceChange'
                });

                // Request edit to open/refresh
                if (widget.isEdit) {
                    widget.dispatchEvent('onEdit');
                }
            },

            /**
             * @method onRefresh
             * @param {Object} widget The UWA widget instance
             */
            onRefresh: function(widget) {
                var oldName, newName, oldParam, newParam;
                if (widget.refreshing) {
                    return;
                }
                oldName = enoviaServer.widgetName;
                newName = widget.getValue('widgetName') || oldName;
                oldParam = enoviaServer.params;
                newParam = widget.getValue('params') || oldParam;
                if (oldName !== newName) { //has the widgetName preference changed?
                    this.dontClear = false;
                    enoviaServer.widgetName = newName;
                }
                if (oldParam !== newParam) { //have the parameters changed?
                    this.dontClear = false;
                    enoviaServer.params = newParam;
                }
                widget.refreshing = true;
                if (!this.dontClear) {
                    this.clearData();
                    this.spaceNames = {};
                }
                this.dontClear = false;
                this.loadBPS();
            },
            /**
             * @method onForceRefresh
             * @param {Boolean} doReload reload switch
             */
            onForceRefresh: function(doReload) {
                this.clearData();
                if (doReload) {
                    this.loadBPS();
                }
                enoviaServer.preferences = {};
            },
            /**
             * @method onEditPrefChange
             */
            onEditPrefChange: function() {
                this.onEdit();
            },
            /**
             * @method onEdit
             * @param {Object} widget The UWA widget instance
             */
            onEdit: function(widget) { //prevent onRefresh from being called when editing preferences
                var othis = this;
                widget.refreshing = false;
                this.dontClear = true;

                var widgetName = enoviaServer.widgetName;
                if (widgetName === WidgetUwaUtils.widgetization) {
                    if (!widget.forcedEdit) {
                        widget.forcedEdit = true;
                        WidgetAPIs.getCollaborativeSpaces(function(data) {
                            widget.setValue('collabspace', '');
                            WidgetUwaUtils.processUserCollabSpace(othis, data);
                            widget.setValue('collabspace', othis.spaceNames['defaultSpace'].name);
                            WidgetUwaUtils.processUserCollabSpace(othis, data);
                            widget.dispatchEvent('onEdit');
                        });
                    } else {
                        widget.forcedEdit = false;
                    }
                }
            },
            /**
             * Set the widget to the viewable area
             *
             * @method setDimensions
             * @param {Object} widget The UWA widget instance
             */
            setDimensions: function() {
                var viewport = widget.getViewportDimensions();
                widget.body.setStyles({
                    width: viewport.width + 'px'
                });
                WidgetUwaUtils.setWidgetHeight();
            },
            /**
             * @method onViewChange
             * @param {Object} widget The UWA widget instance
             * @param {Object} conf The configuration object
             */
            onViewChange: function( /*widget, conf*/ ) {
                //WidgetUwaUtils.setWidgetHeight();  //taken care of by resize setdimensions.
            },
            /**
             * setHeight
             */
            setWidgetHeight: function() {
                if (widget.getValue('view') === 'CHANNEL') {
                  //force the scroller to recompute its height
                  //1) we need to remove the height style from it
                  jQuery('.uwa-scroller', widget.body).css('height', '');
                    return;
                }
                //var height = widget.body.getSize().height;
                var viewport = widget.getViewportDimensions();
                var height = viewport.height;
                //setTimeout(function () {
                jQuery('.uwa-scroller', widget.body).css({
                    height: height
                });
                jQuery('.iframe-container', widget.body).css({
                    height: height
                });
                //TODO move this to DPG, what is it doing in Foundation?
                jQuery('.timeline-main', widget.body).css({
                    height: height - 45
                });
                //}, 1);
            },

            /**
             * @method onClickItem
             * @param {Object} MyWidget The UWA Widget Object
             */
            onClickItem: function(MyWidget) {
                // Valid items have the following properties: item.objectType, item.objectId, item.cstorage, item.cspace.
                // No one of these properties is mandatory, however, if objectId is set, cstorage must be set and conversely.
                var item, oid, pid, busType, isSelected, space = enoviaServer.space,
                    jElem;
                jElem = jQuery(this);
                isSelected = jElem.hasClass('selected');
                oid = jElem.attr('data-objectId');
                pid = jElem.attr('data-pid');
                //oid is set to physicalId if it exists
                if (pid && pid.length > 0) {
                    oid = pid;
                } else if (!oid || oid.length === 0) {
                    return;
                }
                busType = jElem.attr('data-type');
                if (isSelected) { // add oid to top of stack
                    MyWidget.arrOid.push(oid);
                } else { //remove oid from anywhere in stack
                    for (var i in MyWidget.arrOid) {
                        if (MyWidget.arrOid[i] === oid) {
                            MyWidget.arrOid.splice(i, 1);
                            break;
                        }
                    }
                    // get last oid if it exists
                    if (MyWidget.arrOid.length === 0) {
                        oid = null;
                    } else {
                        oid = MyWidget.arrOid[MyWidget.arrOid.length - 1];
                    }
                }
                if (oid) {
                    item = {
                        objectType: busType,
                        objectId: oid,
                        envId: enoviaServer.tenant,
                        contextId: space ? space.replace('ctx::', '') : ''
                    };
                    PubSub.publish('setObject', item);
                    //MyWidget.compassSocket.dispatchEvent('onSetObject', item, MyWidget.compassSocketName); // Send the item to widgetNameEventSocket socket by
                    //the dispatchEvent 'onSetObject', it will be caught by the subscribed event server
                } else {
                    // MyWidget.compassSocket.dispatchEvent('onResetObject', {}, MyWidget.compassSocketName);
                    PubSub.publish('resetObject');
                }
            },
            setupEnoviaServer: FoundationAjax.setupEnoviaServer,
            /**
             * Method to initialize the UWA help system
             * Launches help in a new tab or window
             * @param {String} label the menu item label
             */
            initHelpSystem: function _initHelpSystem(helpURL, label) {
                require(['DS/TopBarProxy/TopBarProxy'], function initProxyMenu(TopBarProxy) {
                    var enoviaServer = window.enoviaServer;
                    // only do this once. There is an issue where this gets repeated if the widget is reinitialized
                    if (TopBarProxy[enoviaServer.widgetId]) {
                        return;
                    }
                    TopBarProxy[enoviaServer.widgetId] = new TopBarProxy({
                        'id': enoviaServer.widgetId
                    });
                    var initOnce = true,
                        url;
                    var callback = function _initHelpCallback() {
                        if (initOnce) {
                            var helpFolder = WidgetAPIs.getWidgetConstant('HelpURL'),
                                lang = WidgetAPIs.getWidgetConstant(widget.lang) || 'English',
                                ctxScope = enoviaServer.tenant.toLowerCase() === 'onpremise' ? 'onpremise' : 'cloud';

                            var isLocalHelp = helpFolder && helpFolder.indexOf('HelpDS.aspx') === -1;
                            if (ctxScope === 'onpremise' && isLocalHelp) {
                                url = enoviaServer.computeUrl('/'); //baseUrl
                                url += 'docv6/'; //dsdoc folder
                                url += lang + '/DSDoc.htm?'; //doc redirect file
                                url += 'contextscope=' + ctxScope; //on premise
                                url += '&show=' + helpURL; //help file
                            } else {
                                url = helpFolder; //baseUrl
                                url += '?P=11'; //add DSDOC
                                url += '&L=' + lang; //add language
                                url += '&F=' + helpURL; //add page
                                url += '&contextscope=' + ctxScope; //add context
                            }
                            initOnce = false;
                        }

                        if (url) {
                            window.open(url, '_blank');
                        } else {
                            alert('The help system is not available. Please contact your system administrator.');
                        }
                    };


                    // Set the commands through raw JSON object.
                    // label: what we be shown to end use, should be internationalized
                    // onExecute: define the callback to be called on when executing the command
                    // submenu: defines a menuitem as an entry to a submenu
                    TopBarProxy[enoviaServer.widgetId].setContent({
                        help: [{
                            'label': label,
                            'onExecute': callback
                        }]
                    });
                });
            },
            getContext: function() {
                return (enoviaServer.space || '').replace('ctx::', '');
            },
        };
        window.WidgetUwaUtils = WidgetUwaUtils;
        return WidgetUwaUtils;
    });

///*global define*/
// define('DS/Foundation/Foundation', ['DS/Foundation/WidgetEngine', 'DS/Foundation/WidgetUwaUtils' ], function (WidgetEngine, WidgetUwaUtils) {
//     "use strict";
//     WidgetEngine = WidgetUwaUtils = null; //bcc: to full jshint
//     return {};
// });

