//empty

/* global define, enoviaServer */
/**
 * a module to share code use by many independent V2 services such as DocumentManagement and ImageManagement
 * this is meant to be extended.
 * It is expected that the new service defines a SERVICE_ROOT_URL.  That URL should end with a /
 * This is in particular useful for services which support the FCS checkin 3 step operations.
 * Intent is for developers of services to call the '_' methods.  They should be considered protected
 */
define('DS/Foundation2/IndependentServiceBase', ['UWA/Core', 'UWA/Class', 'UWA/Utils', 'DS/Foundation/FoundationAjax'], //short line
    function(UWA, Class, Utils, FoundationAjax) { //eslint-disable-line strict
        ''; // workaround for a bug in yui Compressor(https://github.com/yui/yuicompressor/issues/71)
        'use strict';
        //SERVICE_ROOT_URL = '/resources/v2/e6w/service/documents/';
        var IndependentServiceBase = Class.extend({
            /**
             * @protected
             * utility method to delete non objects
             * @param {String} url the url of the object resource to delete
             * @param {Object} options, options to be passed in
             * @returns {Object} a cancelabled object
             */
            _deleteObject: function(url, options) {
                var that = this;
                var lOptions = UWA.clone(options || {}, false);
                var headers = UWA.clone(lOptions.additionalHeaders || {}, false);
                headers['content-type'] = 'application/json';
                lOptions.requestType = 'delete';

                var prepareServiceRet = this._prepareService(this._deleteObject.bind(this, url, options), lOptions);
                if (prepareServiceRet) { //we need to wait to get the csrf
                    return prepareServiceRet;
                }

                return FoundationAjax.ajaxRequest({
                    url: url,
                    type: 'delete',
                    dataType: 'json',
                    data: JSON.stringify({
                        csrf: this.getCsrf(lOptions.tenantUrl)
                    }),
                    callback: function(resp) {
                        if (resp && resp.csrf) {
                            that.setCsrf(resp.csrf, lOptions.tenantUrl);
                        }
                        if (resp && resp.success && UWA.is(options.onComplete, 'function')) {
                            options.onComplete(resp, options);
                        } else {
                            if (UWA.is(options.onFailure, 'function')) {
                                options.onFailure(resp);
                            }
                        }
                    },
                    headers: headers
                });
            },
            /**
             * @protected
             * delete a root object of this service based on id
             * @param {String} id the id of the object
             * @param {Object} options can be provided (callback in case of  success).  onComplete and onFailure, tenant, tenantUrl and securityContext can be used
             * @return {Object} cancelable object
             */
            _deleteRootObject: function(id, options) {
                return this._deleteObject(this.SERVICE_ROOT_URL + id, options);
            },
            /**
             * @protected
             * retrieve the root objects of the service based on ids.
             * @param {Array} idList list of ids
             * @param {Object} options options for the call.  One to be noted:  additionalURLParams can be used to add parameters such as $include=versions to the url
             * standard options such as onComplete and onFailure apply
             */
            _getObjects: function(idList, options) {
                var that = this;
                var lOptions = UWA.clone(options || {}, false);
                var headers = UWA.clone(lOptions.additionalHeaders || {}, false);
                headers['Content-Type'] = 'application/x-www-form-urlencoded';
                lOptions.requestType = 'get';
                lOptions.csrf = lOptions.csrf || 'notNeeded';
                /* var prepareServiceRet =*/
                this._prepareService(this._getObjects.bind(this, idList, options), lOptions);
                //            if (prepareServiceRet) { //we need to wait to get the csrf
                //                return prepareServiceRet;
                //            }

                FoundationAjax.ajaxRequest({
                    //url: SERVICE_ROOT_URL + '?$ids=' + idList.join() + (options.getVersions ? '&$include=all' : ''),
                    url: this.SERVICE_ROOT_URL + (options.additionalURLParams ? '?' + options.additionalURLParams : ''),
                    type: 'post',
                    dataType: 'json',
                    data: '$ids=' + idList.join(),
                    callback: function(resp) {
                        if (resp && resp.csrf) {
                            that.setCsrf(resp.csrf, lOptions.tenantUrl);

                        }
                        if (resp && resp.success && UWA.is(options.onComplete, 'function')) {
                            options.onComplete(resp, options);
                        } else {
                            if (UWA.is(options.onFailure, 'function')) {
                                options.onFailure(resp);
                            }
                        }
                    },
                    headers: headers
                });
            },
            /**
             * @protected
             * prepare for calling a service.
             * @param {Function} callback a callback to call after csrf is retrieved if it wasn't available
             * @param  {Object} iOptions options (including csrf, tenant, securityContext, tenantUrl)
             * @return {Object} undefined if no extra call to retrieve the csfr a cancelable object if we are retrieving the csrf
             */
            _prepareService: function(callback, iOptions) {
                window.isIFWE = true;
                var lRet;
                var lOptions = iOptions || {};
                if (!window.enoviaServer) {  //this will be already set in case of 3dplan and collabtasks
                    FoundationAjax.setupEnoviaServer();    //initialize with default values
                }
                if (lOptions.tenant) {
                    enoviaServer.tenant = lOptions.tenant;
                }
                if (lOptions.securityContext) {
                    var securityContext = lOptions.securityContext;
                    if (securityContext.indexOf('ctx::') !== 0) {
                        securityContext = 'ctx::' + securityContext;
                    }
                    enoviaServer.space = securityContext;
                }
                if (lOptions.tenantUrl) {
                    enoviaServer.storageUrl = lOptions.tenantUrl;
                }

                if (!this.getCsrf(lOptions.tenantUrl) || lOptions.csrf) {
                    if (lOptions.csrf) {
                        if (lOptions.csrf !== 'notNeeded') {
                            this.setCsrf(lOptions.csrf, lOptions.tenantUrl);
                        }

                    } else {
                        //request csrf token then call ourself again
                        lRet = this._getCsrf(callback, iOptions);
                    }
                }
                return lRet;
            },
            /**
             * @protected
             * second step in a checkin mechanism, handle the FCS ticket received.
             * @param {Object} response, the response from the server
             * @param {Object} iOptions, options   onFailure will be called if we failed to retrieve the ticket
             */
            _handleTicket: function _handleTicket(response, iOptions) {
                var that = this;
                if (response && response.success) {
                    var ticket = response.data[0].dataelements; //we only get back one ticket, even when we eventually support multiple uploads
                    this.setCsrf(response.csrf, iOptions && iOptions.tenantUrl);

                    //        var myTicket = that._parseTicket(ticket);
                    var options = UWA.clone(iOptions || {}, false);
                    var onComplete = options.onComplete;
                    options.onComplete = function(resp, options) {
                        var lOptions = UWA.clone(options || {}, false);
                        lOptions.onComplete = onComplete;
                        that._handleFCSReceipt(resp, lOptions);
                    };
                    //copy the ticket to the options
                    options = UWA.extend(options, ticket);
                    //call the FCS to actually upload the file
                    that._checkinToFCS(options);
                } else {
                    if (UWA.is(iOptions && iOptions.onFailure, 'function')) {
                        iOptions.onFailure(response);
                    }
                }
            },
            /**
             * @private
             * retrieve a csrf token asynchronously.
             * once the callback is called this.csrf should be valuated if the call was successful
             * @param {Function} callback: callback to be called once the csrf has been retrieved
             * @param {Object} options options object.  In particular tenantUrl can be useful
             * @returns {Object} a cancelable object
             */
            _getCsrf: function(callback, options) {
                var csrfService = '/resources/v1/application/E6WFoundation/CSRF';
                var that = this;
                var lAjaxRequestObject = {
                    url: csrfService,
                    type: 'get',
                    dataType: 'json',
                    callback: function(response) {
                        if (response && response.csrf) {
                            that.setCsrf(response.csrf, options && options.tenantUrl);

                            callback();
                        }
                    },
                    headers: {
                        'content-type': 'application/json'
                    }
                };
                return FoundationAjax.ajaxRequest(lAjaxRequestObject);

            },
            /**
             * retrieves the csrf token for a specific url or for the default one
             * @param {String} url the url for which the csrf is necessary
             * @returns {String} a csrf
             */
            getCsrf: function(url) {
                var lUrl = url || enoviaServer.storageUrl;
                return this.csrf && this.csrf[lUrl];
            },
            /**
             * set the csrf for a specific url or for the default one
             * @param {String} csrf the csrf to set
             * @param {String} url the url for which to set set it
             * @returns {String} the csrf
             */
            setCsrf: function(csrf, url) {
                var lUrl = url || enoviaServer.storageUrl;
                this.csrf = this.csrf || {};
                return (this.csrf[lUrl] = csrf);
            },
            /**
             * @private
             * performs the actual upload to the FCS.
             * @param {Object} iOptions options which should contain the onComplete and onFailure callbacks at least
             * @returns {Object} a cancelable object
             */
            _checkinToFCS: function(iOptions) {
                var lOptions = iOptions || {};
                var url = lOptions.ticketURL;
                var formData = this._getFCSFormData(lOptions);


                var request = new XMLHttpRequest();
                request.upload.onprogress = lOptions.onProgress; //this.onProgressBOCreation.bind(this);
                request.open('POST', url, true);
                var errorCallback = function() {
                    if (UWA.is(lOptions.onFailure, 'function')) {
                        lOptions.onFailure(request.responseText, lOptions);
                    }
                };
                request.onload = function() {
                    //BCC the code below should not be needed but jasmine.mock-ajax fires the wrong event in case of http errors
                    if (request.status === 200) {
                        lOptions.onComplete(request.responseText, lOptions);
                    } else {
                        errorCallback();
                    }
                };
                request.onabort = errorCallback;
                request.onerror = errorCallback;
                request.ontimeout = errorCallback;
                request.send(formData);
                return request;
            },
            /**
             * @private
             * prepare a form for uploading to FCS.
             * @param {Object} options should have a fileInfo or a documentInfo with a fileInfo in it.
             * the fileInfo should have a file parameter
             * @return {FormData} a FormData for uploading to FCS
             */
            _getFCSFormData: function(options) {
                options = options || {};
                // /!\
                // /!\ Does not work if the jobTicket is not in the first position
                // /!\
                var fileInfo = options.fileInfo || (options.documentInfo && options.documentInfo.fileInfo);
                var file = fileInfo && fileInfo.file;
                var fileName = fileInfo && fileInfo.fileName; //case of overwritten file name
                var formData = new FormData();
                formData.append(options.ticketparamname, options.ticket);
                formData.append('file_0', file, fileName);

                return formData;
            },
            /**
             * download an fcs url using a POST
             * @param {String} resp: an fcs url containing the ticket as a query parameter, this ticket will be extracted to be passed in a POST request to avoid
             * issues with url length
             * @param {Object} iOptions options.  The onComplete will be called after the request is sent (but before it is finished).  If options.notAsAttachment is set to true the
             *    __fcs__attachment will not be set and in turn the fcs will not set the header Content-Disposition=attachment.  The result being that the browser decides what
             * to do with the downloaded file.
             */
            downloadWithPost: function(resp, iOptions) {
                var doc = document;

                // in case of ios, download the file in a new window
                if (Utils.Client.Platform.ios) {
                    var newWindow = window.open(require.toUrl('DS/DocumentManagement/assets/blankForm.html'), '_blank');
                    // issues occur if user has popup blocker
                    if (newWindow === null || typeof newWindow === 'undefined') {
                        iOptions.onFailure && iOptions.onFailure();
                        return;
                    } else {
                        doc = newWindow.document;
                    }
                }

                // For the moment, resp is basically the url return by DocumentManagement.downloadDocument
                if (UWA.is(resp, 'string')) {
                    // 1. Decompose the URL
                    var parsedUrl = Utils.parseUrl(resp);
                    // 2. Parse query part of the url
                    var params = parsedUrl.query.length ? Utils.parseQuery(parsedUrl.query) : {};
                    // 3. Force fcs attachement mode
                    if (!iOptions || !iOptions.notAsAttachment) {
                        params.__fcs__attachment = true;
                    }
                    // 4. Reconstruct post URL by removing the query part
                    delete parsedUrl.query;
                    var postUrl = Utils.composeUrl(parsedUrl);
                    // 5. Create a temporary form and prepare inputs
                    var tempForm = doc.createElement('form');
                    tempForm.style.display = 'none';
                    tempForm.method = 'POST';
                    tempForm.action = postUrl;

                    Object.keys(params).forEach(function(key) {
                        var newInput = doc.createElement('input');
                        newInput.setAttribute('name', key);
                        newInput.setAttribute('value', params[key]);
                        tempForm.appendChild(newInput);
                    });

                    // 6. Attach temporary form to current document
                    doc.body.appendChild(tempForm);
                    // 7. Submit it
                    this.submitForm(tempForm); //so we can skip the submin in the case of an odt

                    // 8. We're done, remove the temporary form
                    doc.body.removeChild(tempForm);
                }

                if (iOptions.onComplete) {
                    iOptions.onComplete(resp, iOptions);
                }
            },
            submitForm: function(form) {
                return form.submit();
            },
            /**
             * @protected
             * to be overloaded by each service.  At this point based on the receipt and the options, an object can be created,
             * modified or even several objects created (documents and files)
             * handle the receipt from FCS.
             * @param {String} fcsReceipt the response from the fcs (a receipt)
             * @param {Object} options (handed down from the first call, contrarily to its name this is mandatory)
             *
             */
            _handleFCSReceipt: function _handleFCSReceipt( /*fcsReceipt, options*/ ) {}

        });
        return IndependentServiceBase;
    });

/*global define*/
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
 * _container
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
window.location.origin = window.location.origin || window.location.protocol + '//' + window.location.hostname + (window.location.port ? ':' + window.location.port : '');
define('DS/Foundation2/FoundationV2Data', //module name
    ['UWA/Core', 'UWA/Array', 'UWA/Data', 'UWA/Storage',  'DS/WAFData/WAFData', 'DS/Foundation/FoundationData', 'DS/Foundation/WidgetAPIs'], //prereq

    function(UWA, UWAArray, Data, Storage, WAFData, FoundationData, WidgetAPIs) { //eslint-disable-line strict
        ''; //workaround for a bug in yui Compressor (https://github.com/yui/yuicompressor/issues/71)
        'use strict';
        var idNames = ['id', 'tempId'];
        UWAArray = null; //to make jshint happy
        var dataHelper = {};

        var FoundationV2Data = {
            //             pictureAPIConfig: {
            //                 defaultSwym: 'https://dsext001-eu1-215dsi0708-3dswym.3dexperience.3ds.com',
            //                 pictureAPIPrefix: '/api/user/getpicture/login/',
            //                 pictureAPISuffix: '/format/mini'
            //             },
            getWidgetConstant: function() {
                return FoundationData.getWidgetConstant.apply(FoundationData, arguments);
            },
            getWidgetConstants: function(constantsServiceName, callback /*, iLocalStorage*/ ) { //load constants from a widget.
                window.WidgetConstants = window.WidgetConstants || {
                    str: {}
                };
                var lConstantData;
                //            var saveData = function(data) {
                //                    if (iLocalStorage) {
                //                        FoundationData.saveCachedData(iLocalStorage, constantsServiceName, data);
                //                    }
                //                };
                var processConstantsData = function(data) {
                    lConstantData = data;
                    var field, allFieldsObj = FoundationV2Data.getAllFields(data);
                    var hasOwn = Object.prototype.hasOwnProperty;
                    for (var key in allFieldsObj) {
                        if (hasOwn.call(allFieldsObj, key)) {
                            field = allFieldsObj[key];

                            window.WidgetConstants.str[field.name] = field.label;
                        }
                    }
                    window.WidgetConstants.str.platformVersion = lConstantData.version;
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
                FoundationV2Data.loadServiceData( /*widgetName*/ constantsServiceName, /*callback*/ processConstantsData,
                    /*isPost*/
                    false, /*postData*/ null, /*iContentType*/ null,
                    /*iUrlParams*/
                    '$definition=true');

            },
            setWidgetConstant: function() {
                return FoundationData.setWidgetConstant.apply(FoundationData, arguments);
            },
            /**
             * returns an object containing all the field value of the dataelements of the row object
             * NOTE: does not support multivaluated field data yet
             * @param iRowObject a row object
             * @param simple optional, if true will try to return simple values instead of objects when there is no real needs
             * @return a javascript object with one property but dataelement, that property contain the corresponding field value
             */

            getFieldValues: function getFieldValues(iRowObject) {
                var retValue = {};

                var hasOwn = Object.prototype.hasOwnProperty;
                for (var key in iRowObject.dataelements) {
                    if (hasOwn.call(iRowObject.dataelements, key)) {
                        retValue[key] = FoundationV2Data.getFieldValue(iRowObject, key, true);
                    }
                }
                return retValue;
            },
            //         /**
            //          * returns the relId for a rowObject
            //          * @param rowObject object from which you need the relId
            //          * @return the relId or temporary relId
            //          */
            //         getRelId: function(rowObject) {
            //             var relId = rowObject.relId ;
            //             return relId;
            //         },
            /**
             * returns the field value for an object.
             * @param {Object} objectData either the dataElement of interest or a Foundation RowObject
             * @param {String} [fieldName] optional, if objectData is an object this is mandatory and is the name of the field of interest
             * @param {boolean} [supportMultiValues=false] optional default false if true the return is either one object or an array depending on the number of values
             * @param {boolean} [defaultToNull=false] optional default false, if true when there is no value returns null instead of {}
             * @return {String|Array} the value string or an array of such if there are multiple values
             */
            getFieldValue: function(objectData, fieldName, supportMultiValues, defaultToNull) { //get value by field name.
                var retValue = defaultToNull ? null : {},
                    values = objectData && objectData.dataelements && objectData.dataelements[fieldName];
                if (values) {
                    retValue = values;
                }
                return retValue;
            },
            /**
             * utility method to merge two objects
             * this is used to treat the return values from the server.  The client side data is overwritten except if it contains pending changes.
             * @param {Object} target  target to merge with source.  Attributes will be overwritten if they do not have pending changes
             * @param {Object} source  object to copy data from.  This is normally a return value from the server.
             */
            appendFieldData: function(target, source) { //combine field data.
                for (var key in source.dataelements) {
                    if (source.dataelements.hasOwnProperty(key)) {
                        var dataElements = target.dataelements;
                        if ((dataElements._previousValues && (typeof dataElements._previousValues[key] !== 'undefined') && //too long
                                dataElements._previousValues[key] !== dataElements[key]) || //we have a previous value, unsaved modification exists
                            (dataElements._pendingValues && (typeof dataElements._pendingValues[key] !== 'undefined') && //too long
                                dataElements._pendingValues[key] !== dataElements[key])) //we have a pending value, in flight modification exists
                        {
                            continue;
                        }
                        //safe to overwrite
                        dataElements[key] = source.dataelements[key];
                    }
                }

            },

            /**
             * retrieve the children (potentially recursively) of an object.
             * @param {Object} parentObj the object to retrieve the children from
             * @param {boolean} allLevels  if set to true all the descendants (not just first level children) will be returned
             * @param {boolean} checkFiltered if set to true the objects tagged as filtered will not be returned.  Used for tagger filtering.
             * @return {Array} an array of children (or descendant) of parentObj
             */
            getChildren: function(parentObj, allLevels, checkFiltered) { //get object children
                var subItems = [],
                    objects = parentObj.children;

                if (objects && objects.length > 0) {
                    for (var i = 0; i < objects.length; i++) {
                        var object = objects[i];

                        if (checkFiltered === false || !object.filtered) {
                            subItems.push(object);
                            if (allLevels) {
                                var children = FoundationV2Data.getChildren(object, allLevels);
                                subItems = subItems.concat(children);
                            }
                        }
                    }
                }
                return subItems;
            },
            /**
             * retrieves an object.
             * an object can be passed in which case it will be returned as is.  This is convenient to implement methods which take as an
             * input either an object or its id.  Just start by calling getObject.
             * The id can be the id received from the service or tempId in case of an object recently created
             * note that all objects cannot be found by id. Only those which are in the return of _getContainerData
             * @param {Object} inMemoryData the in memory data structure
             * @param {String} id the id of the object to find
             * @return {Object} object if found. null if no id. undefined if object not found.
             */
            getObject: function(inMemoryData, id /*id or object*/ ) {
                var ret;
                //The indexCache won't take filtered into account, should it be checked prior to returning.
                //Removing the restriction use in V1 for now
                if (!id) {
                    return null;
                } else if (typeof id === 'object') {
                    return id;
                }
                if (inMemoryData._indexCache) {
                    var retVal = inMemoryData._indexCache[id];
                    if (retVal) { //not needed when the index is correctly kept up to date by sync
                        ret = retVal;
                    }
                }
                return ret;
            },
            //ajaxRequest: FoundationData.ajaxRequest, //redirected
            /**
             * retrieve the most pertinent id for an object.
             * in order either the physicalid, objectid or tempid.
             * Note that it should really never return the objectId so I don't know of a case where we would have an objectid and no physicalid
             * @param {Object} rowObject the object
             * @return {String} a string to be used as id for the object
             */
            getId: function(rowObject) {
                return rowObject.id || rowObject.tempId;
            },
            /**
             * Save changes to the database.
             * if a modification is dependant on a previously pending modification, we will wait for the reply by the server before sending a new save request.
             * @param {Object} inMemoryData  the data to be saved
             * @param {function} callback a callback function to be called once the server replied
             * @param {boolean} showError a boolean if true errors will be displayed as alert if false they will not
             * @param {boolean} saveId to only save one object out of the modified objects in the data
             */
            applyUpdates: function(inMemoryData, callback, showError, saveId) {
                if (!inMemoryData._modifiedObjectList) { //nothing modified, nothing to do
                    if (typeof callback === 'function') {
                        callback.call(this, false, {
                            error: 'nothing to save'
                        });
                    }
                    return;
                }

                var modifiedObjectList = inMemoryData._modifiedObjectList;
                //start a new list after each apply.
                delete inMemoryData._modifiedObjectList;

                //prepare message containing updated objects and their context to be sent to the server.
                var modifiedInfo = FoundationV2Data.__generateUpdateWidget(inMemoryData, modifiedObjectList, saveId);
                if (!modifiedInfo) { //case when the currently modified objects are dependent on a pending update.
                    if (!inMemoryData._pendingUpdates) {
                        FoundationV2Data._setInternalProperty(inMemoryData, '_pendingUpdates', []);
                        //inMemoryData._pendingUpdates = [];
                    }
                    //mark the _updateActionStatus of all objects in this batch as queued
                    FoundationV2Data.__changeUpdateActionStatusForBatch(modifiedObjectList, 'QUEUED');
                    inMemoryData._pendingUpdates.push({
                        _modifiedObjectList: modifiedObjectList,
                        _callback: callback,
                        _showError: showError,
                        _saveId: saveId
                    });
                    return; //data not ready to be saved.
                }
                var updateWidget = modifiedInfo.updateWidget;
                var widgetPostData = JSON.stringify(updateWidget);

                var thisRequest = {
                    showError: showError,
                    callbackFunction: callback
                };

                //callback
                var applyUpdatesDone = function(data) {
                    if (!data.success) {
                        if (showError) {
                            alert(data.error); //eslint-disable-line no-alert
                        }
                        if (typeof data.data === 'undefined') {
                            //case of a network error, we will remove the PENDING status on the objects
                            //which failed to be updated and we will add them back to the _modifiedObjectList
                            if (!inMemoryData._modifiedObjectList) {
                                FoundationV2Data._setInternalProperty(inMemoryData, '_modifiedObjectList', []);
                                //inMemoryData._modifiedObjectList = [];
                            }
                            var clonedObjects = modifiedInfo.clonedObjects;
                            var hasOwn = Object.prototype.hasOwnProperty; //shortcut
                            for (var key in clonedObjects) {
                                if (hasOwn.call(clonedObjects, key)) {
                                    var clonedObject = clonedObjects[key];

                                    if (clonedObject.item.updateAction !== undefined && //line too long
                                        clonedObject.item.updateAction !== 'NONE') { //we check the updateActionPending on item which is what was sent to the server
                                        //with this batch.  In case where this object was in fact just context
                                        if (!clonedObject.source.updateAction || //line too long
                                            (clonedObject.source.updateAction === 'MODIFY' && clonedObject.item.updateAction === 'CREATE') || //line too long
                                            (clonedObject.source.updateAction === 'MODIFY' && clonedObject.item.updateAction === 'MODIFY') || //line too long
                                            clonedObject.item.updateAction === 'DISCONNECT' || clonedObject.item.updateAction === 'DELETE') { //it could have
                                            //been modified afterward and have pending for another queued modification.
                                            //however this should work for most case (if you modify after a create or if you modify after a modify it works.
                                            //Things will get lost when delete, connect or disconnect are involved.  But we are already in a fringe case.
                                            clonedObject.source.updateAction = clonedObject.item.updateAction;
                                        } else {
                                            throw new Error('Error and pending modifications');
                                        }
                                        delete clonedObject.source.updateActionPending;
                                        delete clonedObject.source._updateActionStatus;
                                        var parentObject = clonedObject.source._parentObject; //BCC: there could be cases where this is incorrectly not set we can't do much though
                                        FoundationV2Data.__addToModifiedList(inMemoryData, parentObject, clonedObject.source);
                                        //    inMemoryData._modifiedObjectList.push(clonedObject.source);
                                    }
                                }
                            }
                        }
                    }
                    if (data.success || data.data) { //bcc: I think the second condition is sufficient
                        //copy ids of newly created objects.
                        if (data.success) {
                            FoundationV2Data.__synchronizeInMemoryDataWithServerReturn(inMemoryData, data, modifiedInfo.clonedObjects);


                        } else {
                            FoundationV2Data.__postprocessServerFailureMessage(inMemoryData, data, updateWidget, modifiedInfo.clonedObjects);
                        }
                        FoundationV2Data.__updateCsrf(inMemoryData, data);
                    }

                    if (thisRequest.callbackFunction) {
                        try {
                            thisRequest.callbackFunction.call(this, data.success, data, modifiedInfo.clonedObjects);
                        } catch (err) {
                            console.error(err.message); //eslint-disable-line no-console
                        }
                    }

                    //process pending updates.
                    //WARNING if we have somethings in the _modifiedObjectList which can happen in case of a network error (see above), it will be lost.
                    //However in that case chances are we will get another network error immediately
                    if (inMemoryData._pendingUpdates) {
                        var pendingUpdates = inMemoryData._pendingUpdates;
                        delete inMemoryData._pendingUpdates;
                        for (var i = 0; i < pendingUpdates.length; i++) {
                            FoundationV2Data._setInternalProperty(inMemoryData, '_modifiedObjectList', pendingUpdates[i]._modifiedObjectList);
                            //inMemoryData._modifiedObjectList = pendingUpdates[i]._modifiedObjectList;
                            //reset the status of the current batch since we pulled them from the queue to recheck dependencies
                            FoundationV2Data.__changeUpdateActionStatusForBatch(inMemoryData._modifiedObjectList, null);
                            FoundationV2Data.applyUpdates(inMemoryData, pendingUpdates[i]._callback, pendingUpdates[i]._showError, pendingUpdates[i]._saveId);
                        }
                    }
                };
                var url = this._serviceURL(inMemoryData._serviceName);
                var verb = 'POST';
                //check if we have a single object changed in which case we will build a real rest path
                if (modifiedObjectList.length === 1 && !modifiedObjectList[0].parent) { //don't deal with path of ids yet'
                    //the action is already marked as Pending
                    var lUpdateAction = modifiedObjectList[0].child.updateActionPending;
                    if (lUpdateAction && lUpdateAction !== 'CREATE') {
                        verb = 'PUT';
                        url += '/' + modifiedObjectList[0].child.id;
                    }
                }
                FoundationV2Data.ajaxRequest({
                    url: url,
                    type: verb,
                    method: verb,
                    data: widgetPostData,
                    dataType: 'json',
                    callback: applyUpdatesDone,
                    headers: {
                        'content-type': 'application/json'
                    }
                });
            },
            /**
             * returns true if an object has updates to be applied to the server marked on it.
             * this indicates that the server hasn't confirmed the updates yet.  They could have been sent already or not.
             * @param {Object} rowObject ...
             * @return {boolean} dirty or not
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
             * @param {Object} inMemoryData the in memory datastructure
             * @param {String|Object} iToDelete the object (or its id) to delete.
             * @return {Object} the object to be deleted
             */
            deleteObject: function(inMemoryData, iToDelete /*id or object*/ ) {
                var object = FoundationV2Data.getObject(inMemoryData, iToDelete);
                var lUpdateAction = object.updateAction;
                object.updateAction = 'DELETE';
                if (!lUpdateAction) {
                    FoundationV2Data.__addToModifiedList(inMemoryData, null, object);
                }
                var lRelationship = iToDelete._relationship;
                if (!lRelationship && iToDelete._parentObject) {
                    lRelationship = 'children';
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
             * @param {Object} inMemoryData the in memory data structure
             * @param {String|Object} iToCancel the object or its id.  Note that if an id is used it will only work on first level object
             */
            cancelObject: function(inMemoryData, iToCancel /*id or object*/ ) {
                var object = FoundationV2Data.getObject(inMemoryData, iToCancel);
                if (object._updateActionStatus === 'PENDING') {
                    throw new Error('cannot cancel changes on this objects they have already been sent to the server');
                }
                //cleanup
                var updateAction = object.updateAction || object.updateActionPending || object.updateActionFailed;
                if (updateAction === 'MODIFY') {
                    FoundationV2Data.__deletePrevValues(object, true);
                } else if (updateAction === 'CREATE' || updateAction === 'CONNECT') {
                    FoundationV2Data.__deleteObject(inMemoryData, object);
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
             * @param {Object} inMemoryData the data to rollback
             * @param {String|Object} iRowObject ...
             */
            rollbackFailedObject: function(inMemoryData, iRowObject) {

                //cleanup
                var updateAction = iRowObject.updateActionFailed;

                switch (updateAction) {
                    case 'CONNECT':
                    case 'CREATE':
                        FoundationV2Data.__deleteObject(inMemoryData, iRowObject);
                        break;
                    case 'MODIFY':
                        if (iRowObject.updateActionPending !== 'MODIFY' && iRowObject.updateAction !== 'MODIFY') {
                            FoundationV2Data.__deletePrevValues(iRowObject, true);
                        }
                        break;
                    case 'DELETE':
                    case 'DISCONNECT':
                        break;
                    default:
                        //not much to do really apart from removing the flag
                        break;
                }
                //fire mvc event if necessary
                if (updateAction === 'CONNECT' || updateAction === 'CREATE' || updateAction === 'DELETE' || updateAction === 'DISCONNECT') {
                    var parentObject = iRowObject._parentObject || iRowObject._relationshipParentObject;
                    parentObject && parentObject._mvcModel && parentObject._mvcModel._fireRelationshipChangeEvents(iRowObject._relationship || 'children');

                }
                delete iRowObject.updateActionFailed;
                delete iRowObject.updateMessage;
            },
            /**
             * rollback any data marked with an updateActionFailed.
             * this will remove the marking and cancel the updateActionFailed on the object.
             * see rollbackFailedObject for the details about what will be rolled back exactly
             * @param {Object} inMemoryData the data to rollback
             * @param {boolean} iForce if true force the rollback of objects modified since they faileed
             */
            rollbackFailedData: function(inMemoryData) {
                FoundationV2Data.iterateOverDataStructure(inMemoryData, function(iObject) {
                    FoundationV2Data.rollbackFailedObject(this, iObject);
                });
            },
            /**
                  //          * modify a related object.
                  //          * finds a related object then modify it.  See modifyObject and getRelatedObject
                  //          */
            //         modifyRelatedObject: function(inMemoryData, relationship, parent /*id or object*/ , id, updatedFields
            // /* [{name: 'owner', value: {displayValue: 'value', actualValue: 'value'}},]*/ ) {
            //             var object = null;
            //             if (typeof id === 'object') {
            //                 object = id;
            //             } else {
            //                 object = FoundationV2Data.getRelatedObject(inMemoryData, relationship, parent, id);
            //             }
            //             FoundationV2Data.modifyObject(inMemoryData, object, updatedFields);
            //         },
            /**
             * Modify an object.
             * The previous values will be stored on the object for cancelation purpose until the change is confirmed by the server.
             * Note that multiple value fields are not supported
             * @param {Object} inMemoryData the in memory data structure
             * @param {String|Object} iToModify object to modify, can be an id but only for first level objects
             * @param {Object} updatedFields the information about the fields to modify.  Non existing fields will be created if necessary.
             *                      the format for fields should be:
             *                      [{name: 'owner', value:  'value'},]
             * @return {Object} the modified rowObject
             */
            modifyObject: function(inMemoryData, iToModify /*id or object*/, updatedFields) {
                var object = FoundationV2Data.getObject(inMemoryData, iToModify);
                if (!object) {
                    return object;
                }
                var dependency;
                var dataElements = object.dataelements;
                var dependencies = dataElements._dependencies;
                //bcc: let's only make change if something is different from what we currently have
                var reallyChangedSomething = false;
                //in case the object has some modifications which are in flight (updateActionPending)
                //we will need to store the actual value of those attribute which have a previous value
                //to a third property: pendingValue
                for (var i = 0; i < updatedFields.length; i++) {
                    dependency = undefined;
                    var field = updatedFields[i];
                    if (field.value === null || typeof field.value === 'undefined') {
                        field.value = '';
                    }
                    if (UWA.is(field.value, 'object')) {
                        dependency = field.value;
                        field.value = FoundationV2Data.getId(dependency);
                    }
                    var currentvalues = dataElements[field.name];

                    if (field.value !== undefined && field.value !== currentvalues) { //need to handle multi-value scenarios.
                        //with the V2 format each value is not necessarily an object so we can't store the previousValue directly.  Store an array
                        // in // to the array of values
                        if (!dataElements._previousValues) {
                            FoundationV2Data._setInternalProperty(dataElements, '_previousValues', {});
                        }
                        var previousValues = dataElements._previousValues;
                        // if (!previousValue[field.name]) {
                        //     previousValues[field.name] = [];
                        // }
                        if (typeof previousValues[field.name] === 'undefined') {
                            previousValues[field.name] = currentvalues || '';
                        } else {
                            //check if we have changes pending a return from the server
                            if (object.updateActionPending) {
                                if (!dataElements._pendingValues) {
                                    FoundationV2Data._setInternalProperty(dataElements, '_pendingValues', {});
                                }
                                dataElements._pendingValues[field.name] = currentvalues || '';
                            }
                        }
                        dataElements[field.name] = field.value;
                        reallyChangedSomething = true;
                    }
                    if (dependency) {
                        if (!dependencies) {
                            dependencies = {};
                            FoundationV2Data._setInternalProperty(dataElements, '_dependencies', dependencies);
                        }
                        dependencies[field.name] = dependency;

                    }
                }

                if (reallyChangedSomething && object.updateAction === undefined) {
                    object.updateAction = 'MODIFY';
                    FoundationV2Data.__addToModifiedList(inMemoryData, null, object);
                }
                return object;
            },
            /**
             * Disconnect an object.
             * mark an object (so a branch of the tree) for removal.  The actual removal happens when applyUpdates is called.
             * Only works for children can be disconnected. Use disconnectRelatedObject for relatedData.
             * a prereq for this to work is that the _parentObject backpointer has been computed (usually by iterateOverDataStructure when computing the index)
             * @param {Object} inMemoryData the in memory data structure
             * @param {Object|String} iToDisconnect either the object to disconnect or an id.
             */
            disconnectObject: function(inMemoryData, iToDisconnect /* object or id*/ ) {
                var childObject = FoundationV2Data.getObject(inMemoryData, iToDisconnect);
                if (!childObject || !childObject._parentObject) {
                    throw new Error('Invalid ID for disconnection.');
                }
                FoundationV2Data.__disconnectObject(inMemoryData, childObject);
            },
            /**
             * Disconnect a related object.
             * mark an object (so a branch of the tree) for removal.  The actual removal happens when applyUpdates is called.
             * Only works on relatedData use disconnectObject for children
             * @param {Object} inMemoryData the in memory data structure
             * @param {Object|String} iToDisconnect either the object to disconnect or an id .
             *
             * @param {Object} [iParentObject] optional.  When an object is related to several parents, it may not be advisable to rely on _relationshipParentObject.
             *        in this case it is safer for the clien to provide the explicit parent object which should be disconnected.
             * @param {String} [iRelationship] optional.  When an object is related to several parents, potentially with several relationships,
             *                                 it is preferable to provide the explicit relationship to be disconnected
             *
             */
            disconnectRelatedObject: function(inMemoryData, iToDisconnect /* object or id*/, iParentObject, iRelationship) {
                var childObject = FoundationV2Data.getObject(inMemoryData, iToDisconnect);
                var lParentObject = iParentObject || childObject._relationshipParentObject;

                var lRelationship = iRelationship || childObject._relationship;
                if (!childObject || !lParentObject) {
                    throw new Error(new Error('Invalid ID for disconnection.'));
                }

                FoundationV2Data.__disconnectObject(inMemoryData, childObject, lParentObject, lRelationship);
            },
            /**
             * connects an existing object (based on an object id ) to the in memory structure.
             * a new object placeholder is created, attributes will only be available after applyUpdates (except for those provided in fields).
             * If fields are provided id can be null in this case the fields will be used to build a where clause.  If the id is provided the fields
             * will be ignored by the back end but can be used in the front end while it is waiting for the server refresh
             * @param {Object} inMemoryData the in memory data structure
             * @parem relationship the name of the relationship to use
             * @param {String} relationship ...
             * @param {Object|String} parent id or object where to insert the existing object
             * @param {Object|String} child ...
             * @param {Object} fields array of objects of the following format:
             *                      [{name: 'owner', value: 'value'},]
             *                      those are attributes which will be set on the object they typically come from a form filled in by the user
             *                      they will be used to build a where clause to find the object to attach in case of no id
             * @param {integer} index where to insert it
             * @param {integer} options options array object
             *                  additionalAttributes: additional array of attributes we need on the child object in comparision to basics data list
             *                              that will passed in the payload
             * @return {Object} child
             */
            connectRelatedObject: function(inMemoryData, relationship, parent /*id or object*/, child /* child id or object*/, fields, index, options) {
                var lFields = fields ? fields : [];
                var lChild = child;
                var parentObject = FoundationV2Data.getObject(inMemoryData, parent);
                var lId;
                if (UWA.is(lChild, 'object')) {
                    //if the object is not attached to a structure, attach it.  If it is already attached somewhere else create a new object and update the ids
                    if (lChild._relationshipParentObject || lChild._parentObject || lChild._parentRecords) {
                        var lNewChild = FoundationV2Data.__newObject(lFields);
                        lNewChild.id = lChild.id;
                        lNewChild.cestamp = lChild.cestamp;
                        lNewChild.type = lChild.type;
                        lNewChild.tempId = lChild.tempId;
                        lNewChild.dataelements = UWA.clone(lChild.dataelements); //deep clone
                        lChild = lNewChild;
                    }
                } else { //child is either a string (the id) or undefined or null
                    lId = child;
                    lChild = FoundationV2Data.__newObject(lFields);
                    lChild.id = lId; //set the physicalId
                }
                if (options && options.additionalAttributes){
                    UWA.merge(lChild, options.additionalAttributes);
                }
                if (!parentObject || !relationship) {
                    throw new Error('Relationship, parent and child IDs are required for connection.');
                }
                FoundationV2Data.__connectObject(inMemoryData, relationship, parentObject, lChild, index);
                return lChild;
            },
            /**
             * connects an existing object (based on an object id or physical id ) to the in memory structure as a relatedObject.
             * a new object placeholder is created, attributes will only be available after applyUpdates (except for those provided in fields).
             * @param {Object} inMemoryData the in memory data structure
             * @param {Object|String} parent id or object where to insert the existing object
             * @param {String} id  id of the object to connect (typically comming from a search)
             * @param {Object} fields array of objects of the following format:
             *                      [{name: 'owner', value:'value'},]
             *                      those are attributes which will be set on the object they typically come from a form filled in by the user
             * @param {integer} index where to insert it
             * @return {Object} new object
             */
            connectObject: function(inMemoryData, parent /*id or object*/, id /* child id*/, fields, index) {
                var lFields = fields ? fields : [];
                var newObject = FoundationV2Data.__newObject(lFields),
                    parentObject = FoundationV2Data.getObject(inMemoryData, parent);
                newObject.id = id;
                if (!parentObject || !newObject.id) {
                    throw new Error('Parent and child IDs are required for connection.');
                }
                FoundationV2Data.__connectObject(inMemoryData, null, parentObject, newObject, index);
                return newObject;
            },
            /**
             * adds a an object to the structure as a child object.
             * The object is temporary until applyUpdates is called
             * @param {Object} inMemoryData the in memory data structure
             * @param {Object|String} parent, id or parent object on which to attach the new object.
             * @param {Object} fields array of objects of the following format:
             *                      [{name: 'owner', value:'value'},]
             *                      those are attributes which will be set on the object they typically come from a form filled in by the user
             * @param {integer} index, optional where to insert the new object
             * @return {Object} the newly created object
             */
            addObject: function(inMemoryData, parent, fields, index) {
                var newObject = FoundationV2Data.__newObject(fields),
                    parentObject = FoundationV2Data.getObject(inMemoryData, parent);
                FoundationV2Data.__addObject(inMemoryData, undefined, parentObject, newObject, index);
                return newObject;

            },

            /**
             * adds a an object to the structure as a related object.
             * @param {Object} inMemoryData the in memory data structure
             * @param {String} relationship, mandatory (use addObject if you don't have a relationship and you want to add a child. The name of the relationship to use to add the object.
             * @param {Object|String} parent, id or parent object on which to attach the new object.
             *                              Beware that passing an id might fail as of today only first level objects are reliably found by Id
             * @param {Object} fields array of objects of the following format:
             *                      [{name: 'owner', value:'value'},]
             *                       those are attributes which will be set on the object they typically come from a form filled in by the user
             * @param {integer} index, optional where to insert the new object
             * @param {Object} [iMVCModel] optional mvcModel which will have to be updated prior to firing events
             * @return {Object} the newly created object
             */
            addRelatedObject: function(inMemoryData, relationship, parent, fields, index, iMVCModel) {
                if (!relationship) {
                    throw new Error('a relationship should be specified');
                }
                var newObject = FoundationV2Data.__newObject(fields),
                    parentObject = FoundationV2Data.getObject(inMemoryData, parent);
                FoundationV2Data.__addObject(inMemoryData, relationship, parentObject, newObject, index, iMVCModel);
                return newObject;
            },
            /**
             * retrieves an array corresponding to the relateddata of this object for a given relation name.
             * @param {Object} iObject  the object
             * @param {String} iRel the name of the relation
             * @return {Object|Array} empty array or the corresponding relateddata
             */
            getRelatedObjects: function getRelatedObjects(iObject, iRel) {
                var lRet;
                if (iObject && iRel && iObject.relateddata && iObject.relateddata[iRel]) {
                    lRet = iObject.relateddata[iRel];

                }
                return lRet;
            },
            /**
             * retrieves the list of names for related data for a given object.
             * @param {Object} iObject object you want to get the relateddata names for
             * @return {Array} arrays of name
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
                var i, id, object, index, rows = inMemoryData.data;
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
                        FoundationV2Data.eachAncestor(modifiedObject, function() {
                            if (lIdH[this.id] || lIdH[this.tempId]) {
                                lIsInList.inList = true;
                                return false;
                            }
                            return true;
                        });
                        if (lIsInList.inList) {
                            throw new Error('cannot unload object while it contain pendind modifications');
                        }
                    });
                }
                for (i = 0; i < idList.length; i++) {
                    id = idList[i];
                    object = FoundationV2Data.getObject(inMemoryData, id);
                    index = rows.indexOf(object);
                    //remove object from rows array.
                    if (index !== -1) {
                        rows.splice(index, 1); //remove 1 item at index.
                    }
                }
                //needs to update the indexCache.  It is complicated to remove just the correct one as objects can be attached in multiple place so recompute the full index
                //this can be optimized later
                FoundationV2Data.__refreshIndexCache(inMemoryData);
            },
            /**
             * loads a list of object by ids and add them to the in memory data.
             *
             * @param {Object} inMemoryData  in memory datas tructure
             * @param {Array} idList  an array of object ids to load
             * @param {integer} index where in the structure to load those ids
             * @param {function} callback function to be called when the load operation finishes.  It is passed the objects which have been added.
             *
             */
            loadObjects: function(inMemoryData, idList, index, callback) {
                var ids = idList.join(),
                    widgetName = inMemoryData._serviceName;
                var that = this;
                var loadObjectDone = function(data) {
                    //get new loaded objects.
                    var objects = data.data,
                        //add new objects to current data based on index.
                        rows = inMemoryData.data;

                    if (index !== 0 && !index) {
                        //we shouldn't really be adding but syncing
                        that.__synchronizeObjectArrays(inMemoryData, objects, rows);
                        //inMemoryData.data = rows.concat(objects);
                        //no need to refresh the cache as the sync does it
                        //delete inMemoryData._indexCache;
                        //FoundationV2Data.__refreshIndexCache(inMemoryData);
                    } else {
                        //insert object in list.
                        //TODO verify that the object is not already in the list
                        //if it is do something about it
                        inMemoryData.data = rows.slice(0, index).concat(objects, rows.slice(index, rows.length));
                        //merge the index
                        FoundationV2Data.__mergeIndexCache(inMemoryData, data._indexCache);

                    }
                    if (callback) {
                        callback.call(this, objects);
                    }
                };
                // widgetName += '?objectIds=' + ids;
                FoundationV2Data.loadServiceData(widgetName, loadObjectDone, true, '$ids=' + ids, 'application/x-www-form-urlencoded; charset=utf-8');
            },
            /**
             * @private
             * retrieves a list of objects.
             * There are 2 main modes based on the content of containerConfig.
             * 1) if container config has a data attribute (typically if it is the return value from a service),
             *    it will return those objects and potentially their descendant (if allLevels is true).
             * 	  It can also optionally take into account the filtered items by not returning them (for tagger support)
             * 2) if container config does not have a data attribute but a name attribute and objectData is provided, the starting point will
             *    be the list of those related  data
             *
             *     In both case the list is expanded and filtered as required.
             *     In addition a countSummary property is added to the containerConfig
             *     @param {Object} containerConfig:  eithger an inMemoryData or an object with a name attribute corresponding to the relateddata to select
             *     from the objectData
             *     @param {Object} objectData used in conjunction with a containerConfig which is not an objectData
             *     @param {boolean} checkFiltered ignore objects tagged as filtered
             *     @param {boolean} allLevels expand all of the objects retrieved and add to the result
             *     @return {Array} the potentially expanded and filtered list of objects
             */
            _getContainerData: function(containerConfig, objectData, checkFiltered, allLevels) {
                var listData = null;
                if (!containerConfig) {
                    return listData;
                }
                var data = containerConfig.data;
                if (data) {
                    listData = data;
                    FoundationV2Data._setInternalProperty(listData, '_container', containerConfig);
                    if (!listData) {
                        listData = [];
                    }
                } else if (objectData && objectData.relateddata) {
                    var relationship = containerConfig.name;
                    var datarecords = objectData.relateddata[relationship];
                    if (datarecords) {
                        listData = datarecords;
                    }
                }
                if (listData) {
                    var expandedList = [];
                    for (var i = 0; i < listData.length; i++) {
                        var item = listData[i];
                        if (!checkFiltered || !item.filtered) {

                            // item._parentRecords = listData;
                            FoundationV2Data._setInternalProperty(item, '_parentRecords', listData);
                            expandedList.push(item);
                            if (allLevels) {
                                var subObjects = FoundationV2Data.getChildren(item, true, checkFiltered);
                                expandedList = expandedList.concat(subObjects);
                            }
                        }

                    }
                    listData = expandedList;
                }

                return listData;
            },
            //TODO: rename _serviceURL
            _serviceURL: function(widgetName) {
                if (widgetName && widgetName.indexOf('/resources') === -1) {
                    return '/resources/v2/e6w/service/' + widgetName;
                } else {
                    return widgetName;
                }

            },
            //redirected to WidgetAPIs for now
            // __setRowFilter: function(widgetRoot, row, bAutoFiltered, bSearchFiltered) {
            //     var isRowFiltered = !! row.filtered;
            //     row.autoFiltered = bAutoFiltered === false || bAutoFiltered ? bAutoFiltered : row.autoFiltered;
            //     row.bSearchFiltered = bSearchFiltered === false || bSearchFiltered ? bSearchFiltered : row.bSearchFiltered;
            //     if (row.autoFiltered || row.bSearchFiltered) {
            //         if (!isRowFiltered) {
            //             row.filtered = true;
            //             widgetRoot.countSummary && widgetRoot.countSummary.shown--;
            //         }
            //     } else {
            //         if (isRowFiltered) {
            //             row.filtered = false;
            //             widgetRoot.countSummary && widgetRoot.countSummary.shown++;
            //         }
            //         this.__showParent(widgetRoot, row);
            //     }
            // },
            // __showParent: function(widgetRoot, childObject) {
            //     if (childObject._parentObject && childObject._parentObject.filtered) {
            //         childObject._parentObject.filtered = false;
            //         widgetRoot.countSummary && widgetRoot.countSummary.shown++;
            //         this.__showParent(widgetRoot, childObject._parentObject);
            //     }
            // },
            //        /**
            //         * retrieve items underneath a container      (bcc: but what is a container?)
            //         * optionally takes into account hidden or collapsed objects
            //         * @param {Object} containerConfig, the container
            //         * @param includeHidden, if not true will not return hidden objects
            //         * @param includCollapsed, if not true will not return collapsed objects
            //         */
            //        getContainerItems: function(containerConfig, includeHidden, includeCollapsed) {
            //            var list = [],
            //                tempList = [],
            //                view = containerConfig.displayview;
            //            if (containerConfig.widget) {
            //                FoundationV2Data._setInternalProperty(containerConfig.widget, '_parentExperience', containerConfig);
            //                if (includeCollapsed || !containerConfig.collapsed) {
            //                    tempList.push(containerConfig.widget);
            //                }
            //            } else if (containerConfig.widgets) {
            //                tempList = containerConfig.widgets;
            //            }
            //            for (var i = 0; i < tempList.length; i++) {
            //                if (includeHidden || ((view === tempList[i].view || !tempList[i].view) && !tempList[i].hidden)) {
            //                    list.push(tempList[i]);
            //                }
            //            }
            //            return list;
            //        },
            //        /**
            //         * retrieve the widgets underneath a container
            //         */
            //        getContainerWidgets: function(containerConfig) {
            //            return FoundationV2Data.getContainerItems(containerConfig, true, true);
            //        },
            /**
             * return a hash with all the fields in widgetRoot (including defined lower in the tree).
             * the keys are the field names the values the fields themselves.
             * if 2 fields have the same name only one will be in the index.
             * @param {Object} inMemoryData  the data to scan
             * @param {integer} fieldIndexCache optional a partially filled index.  This is used by the recursion.
             * @param {String} parentName ...
             * @param {String} iCustomFieldsName ...
             * @return {Object} an index of all fields by their name
             */
            getAllFields: function(inMemoryData, fieldIndexCache, parentName, iCustomFieldsName) { //returns an object indexed by field name and value is the field itself.
                var lParentName = parentName || '';
                if (!inMemoryData) {
                    return {};
                }
                // if (!parentName) {
                //
                // }
                var lCustomFieldsName = iCustomFieldsName || FoundationV2Data._getCustomFieldsName(inMemoryData);
                if (!fieldIndexCache) {
                    fieldIndexCache = inMemoryData._fieldIndexCache;
                    if (fieldIndexCache) {
                        return fieldIndexCache;
                    }
                    fieldIndexCache = {};
                    fieldIndexCache[lCustomFieldsName] = {};
                    FoundationV2Data._setInternalProperty(inMemoryData, '_fieldIndexCache', fieldIndexCache);

                    // inMemoryData._fieldIndexCache = fieldIndexCache; //cache index.
                }
                var items = inMemoryData.definitions || inMemoryData.items;
                if (items) {
                    var lNbItems = items.length;
                    for (var i = 0; i < lNbItems; i++) {
                        var itemConfig = items[i];
                        var itemType = itemConfig.itemType;
                        if (itemType === 'field') {
                            var lKey = lParentName ? lParentName + '.' + itemConfig.name : itemConfig.name;
                            if (!fieldIndexCache[lKey]) { //cache first field instance.
                                fieldIndexCache[lKey] = itemConfig; //index field name.
                            }
                            if (lParentName === lCustomFieldsName) {
                                fieldIndexCache[lParentName][itemConfig.name] = itemConfig;
                                fieldIndexCache[itemConfig.name] = itemConfig;
                            }
                        } else { //container.

                            FoundationV2Data.getAllFields(itemConfig, fieldIndexCache, itemConfig.name, lCustomFieldsName);

                        }
                    }

                }
                return fieldIndexCache;
            },
            /**
             * retrieve customfields define for a service.
             * @param {Object} inMemoryData ...
             * @return {Array} custom fields
             */
            getCustomFields: function(inMemoryData) {
                var fields = FoundationV2Data.getAllFields(inMemoryData)[FoundationV2Data._getCustomFieldsName(inMemoryData)];
                var lKeys = Object.keys(fields);
                var lNbKeys = lKeys.length;
                for (var lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                    var lCurKey = lKeys[lCurKeyIdx];
                    var lCurField = fields[lCurKey];
                    try {
                        if (lCurField.viewConfig && UWA.is(lCurField.viewConfig, 'string')) {
                            lCurField.viewConfig = JSON.parse(lCurField.viewConfig);
                            if (lCurField.range && lCurField.range.item && lCurField.viewConfig.type === 'select') {
                                var lNbRangeItem = lCurField.range.item.length;
                                var lValues = [];
                                for (var lCurRangeItemIdx = 0; lCurRangeItemIdx < lNbRangeItem; lCurRangeItemIdx++) {
                                    var lCurRangeItem = lCurField.range.item[lCurRangeItemIdx];
                                    lValues.push({
                                        actualValue: lCurRangeItem.value,
                                        displayValue: lCurRangeItem.display
                                    });

                                }

                                lCurField.viewConfig.values = lValues;
                            }

                        }
                    } catch (e) {
                        console.log('error parsing viewConfig:\'' + lCurField.viewConfig + '\' for custom field: ' + lCurKey); //eslint-disable-line no-console
                    }
                }
                return fields;
            },
            _getCustomFieldsName: function(inMemoryData) {
                var lRet;
                var serviceName = inMemoryData._serviceName;
                if (serviceName) {
                    var lSplitName = serviceName.split('/');
                    serviceName = lSplitName.pop();
                    var lCustomFieldsName = serviceName + '-custom-fields';
                    lRet = lCustomFieldsName;
                }
                return lRet;
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
             * @param {function} callback: callback to be called when constants are loaded
             * @param iLocalStorage: optional a localstorage instance
             */
            //        getWidgetConstants: function(constantsServiceName, callback, iLocalStorage) { //load constants from a widget.
            //            if (!window.WidgetConstants) { //this is normally done in setupEnoviaServer in WidgetUWAUtils.  TODO need to factorize
            //                window.WidgetConstants = {
            //                    str: {}
            //                };
            //            }
            //            var lConstantData;
            //            var saveData = function(data) {
            //                    if (iLocalStorage) {
            //                        FoundationV2Data.saveCachedData(iLocalStorage, constantsServiceName, data);
            //                    }
            //                };
            //            var processConstantsData = function(data) {
            //                    lConstantData = data;
            //                    var field, allFieldsObj = FoundationV2Data.getAllFields(data);
            //                    var hasOwn = Object.prototype.hasOwnProperty;
            //                    for (var key in allFieldsObj) {
            //                        if (hasOwn.call(allFieldsObj, key)) {
            //                            field = allFieldsObj[key];
            //
            //                            WidgetConstants.str[field.name] = field.label.text;
            //                        }
            //                    }
            //                    WidgetConstants.str.platformVersion = lConstantData.version;
            //                    if (typeof callback === 'function') {
            //                        callback.call(this);
            //                    }
            //
            //                    saveData(data);
            //                };
            //            //if provided with a local storage instance, attempts to load from it
            //            if (iLocalStorage) {
            //                lConstantData = FoundationV2Data.loadCachedData(iLocalStorage, constantsServiceName);
            //            }
            //            //if constants loaded from the local storage, process them
            //            if (lConstantData) {
            //                processConstantsData(lConstantData);
            //                //now replace the processing method so it just stores the return from the service in local storage
            //                processConstantsData = saveData;
            //            }
            //
            //            //load the constants from the server and either save in cache or call the callback
            //            FoundationV2Data.loadServiceData(constantsServiceName, processConstantsData);
            //        },
            /**
             * retrieve a specific constant by name.
             * takes a string name and a default value.
             * will return the requested string or the provided default value.
             * If no default value is provided and no string found it will return undefined
             * @param iConstantName the name of the string to retrieve
             * @param iDefault a default value if this string is not found
             */
            //        getWidgetConstant: function(iConstantName, iDefault) { // assumes that widget constants are already initialized
            //            if (!iConstantName) {
            //                return '';
            //            }
            //            var ret;
            //            if (!window.WidgetConstants || !window.WidgetConstants.str) {
            //                console.error('getWidgetConstant called too early (prior to constants initialization) ');
            //            }
            //            ret = window.WidgetConstants && window.WidgetConstants.str ? window.WidgetConstants.str[iConstantName] : null;
            //            return ret || iDefault;
            //        },
            /**
             * iterator pattern.
             * will walk up the ancestor chain and call the callback on each element.
             * this suppose that the _parentObject or _relationshipParentObject information has been computed.
             * this is normally done by iterateOverDataStructure, one way to ensure that it happened is to make sure the index is computed
             * @param {Object} iObject the start of the iteration the callback will be called at least for that element
             * @param {function} iCallback a function which will be called on object and each of its ancestors, if it returns false the iteration stops.
             *                  the callback will be passed one parameters: context.
             *                  the callback will be called with object as the 'this'
             * @param {Object} [iContext] optional, object to be passed to the callback
             * @param {boolean} [iNoRelatedData] optional, if true we will not navigate relatedData relationships
             * @param {boolean} [iNoChildren] optional, if true we will not navigate children relationships
             * @return {boolean} ...
             */
            eachAncestor: function eachAncestor(iObject, iCallback, iContext, iNoRelatedData, iNoChildren) {
                if (!iObject || typeof iCallback !== 'function') {
                    return false;
                }
                if (!iCallback.call(iObject, iContext)) {
                    return false;
                }

                //iterate
                if (!iNoRelatedData && iObject._relationshipParentObject) {
                    return FoundationV2Data.eachAncestor(iObject._relationshipParentObject, iCallback, iContext, iNoRelatedData, iNoChildren);
                } else if (!iNoChildren && iObject._parentObject) {
                    return FoundationV2Data.eachAncestor(iObject._parentObject, iCallback, iContext, iNoRelatedData, iNoChildren);
                }
                return true;
            },

            //TODO use V1 object
            CULL_BRANCH: {},
            /**
             * access each object one by one.
             * The callback will be called with the iterated other object as a parameter and the data as this.
             * The function also populates _relationship _parentObject and _relationshipParentObject if necessary
             * @param {Object} data the complete structure
             * @param {function} callback to call.  The iteration is stopped if it returns false it continues if it returns nothing, it stops for this branch but continue others if
             * the callbacks returns FoundationV2Data.CULL_BRANCH
             * @param {boolean} iNoRelatedData do not iterate over related data
             * @param {Boolean} iNoChildren do not iterate over children
             * @return {boolean} not really meaningfull please ignore
             */
            iterateOverDataStructure: function interateOverDataStructure(data, callback, iNoRelatedData, iNoChildren) {
                //get the rows
                var rows = FoundationV2Data._getContainerData(data);
                var lRet;
                if (rows) {
                    var lNbRows = rows.length;
                    for (var lCurRowIdx = 0; lCurRowIdx < lNbRows; lCurRowIdx++) {
                        //each row is an object first call the callback
                        var lCurRow = rows[lCurRowIdx];
                        //now we need to iterate other the related data and the children
                        //start with the children
                        if (FoundationV2Data.iterateOverObject(data, lCurRow, callback, iNoRelatedData, iNoChildren, lCurRowIdx) === false) {
                            return false;
                        }
                    }
                }
                return lRet;

            },
            /**
             * access each object one by one.
             * calls the callback once for the current object and once for each descendant or related data
             * The callback will be called with the iterated other object as a parameter and the data as this.
             * @param {Object} data the complete structure
             * @param {Object} object object to iterate over
             * @param {function} callback to call.  The iteration is stopped if it returns false it continues if it returns anything else
             * @param {boolean} iNoRelatedData do not iterate over related data
             * @param {boolean} iNoChildren do not iterate over children
             * @param {integer} iParentIndex index of the object in the parent
             * @return {boolean} if false is returned this stops the iteration
             */
            iterateOverObject: function iterateOverObject(data, object, callback, iNoRelatedData, iNoChildren, iParentIndex) {
                var lCallbackRet = true;
                if (UWA.is(callback, 'function')) {
                    lCallbackRet = callback.call(data, object, iParentIndex);
                }

                if (lCallbackRet === false) {
                    return false;
                } else if (lCallbackRet === FoundationV2Data.CULL_BRANCH) {
                    return true;
                }
                if (!iNoChildren) {
                    //get the children
                    var children = object.children;
                    if (children) {
                        var lNbChildren = children.length;
                        for (var lCurChildIdx = 0; lCurChildIdx < lNbChildren; lCurChildIdx++) {
                            var lCurChild = children[lCurChildIdx];
                            //take advantage to set the _ prop if they are not there, and to make sure they are up to date if they are there
                            FoundationV2Data._setInternalProperty(lCurChild, '_parentObject', object);
                            FoundationV2Data._setInternalProperty(lCurChild, '_parentRecords', object.children);
                            //maybe parent record but it is less useful
                            if (FoundationV2Data.iterateOverObject(data, lCurChild, callback, iNoRelatedData, iNoChildren, lCurChildIdx) === false) {
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
                            var rows = UWA.clone(lCurRelatedData, false); //bcc: shallow clone of the array so nobody removes anything from it (or add) while I iterate
                            if (rows) {
                                var lNbRows = rows.length;
                                for (var lCurRowIdx = 0; lCurRowIdx < lNbRows; lCurRowIdx++) {
                                    var lCurRow = rows[lCurRowIdx];
                                    //take advantage to set the _ prop if they are not there, and to make sure they are up to date if they are there
                                    FoundationV2Data._setInternalProperty(lCurRow, '_relationshipParentObject', object);
                                    FoundationV2Data._setInternalProperty(lCurRow, '_relationship', key);
                                    FoundationV2Data._setInternalProperty(lCurRow, '_parentRecords', lCurRelatedData); //use the real live data not the clone
                                    if (FoundationV2Data.iterateOverObject(data, lCurRow, callback, iNoRelatedData, iNoChildren, lCurRowIdx) === false) {
                                        return false;
                                    }
                                }
                            }
                        }
                    }
                }
                return true;
            },
            /**
             * udpate the _indexCache of the this object
             * (this method has to be called with an inMemoryData as this as it is intended for use with the iterate methods)
             * @param {Object} iObject the object which needs to be added to the index
             *
             */
            __updateIndexCacheWithOneObject: function(iObject) {
                var lNbIdNames = idNames.length;
                for (var lCurIdNamesIdx = 0; lCurIdNamesIdx < lNbIdNames; lCurIdNamesIdx++) {
                    var lCurId = iObject[idNames[lCurIdNamesIdx]];
                    if (lCurId && lCurId.length) {
                        var existingObject = this._indexCache[lCurId];
                        if (!existingObject) {
                            this._indexCache[lCurId] = iObject;
                        } else {
                            //attempt merging attributes with those in the existing object returned by the indexCache
                            if (iObject.dataelements) { // non terse object reconnect it to the indexed one
                                FoundationV2Data.__synchronizeSourceObjectFromServerObject(this, iObject, existingObject);
                            } else {
                                iObject.dataelements = existingObject.dataelements;
                                iObject.relateddata = existingObject.relateddata;
                                iObject.type = existingObject.type;
                            }
                        }
                    }
                }
            },
            /**
             * builds or rebuilds the index
             * @param {Object} inMemoryData ...
             */
            __refreshIndexCache: function __refreshIndexCache(inMemoryData) {
                var lInMemoryData = inMemoryData;

                FoundationV2Data._setInternalProperty(lInMemoryData, '_indexCache', {}); //reset the index
                FoundationV2Data.iterateOverDataStructure(lInMemoryData, FoundationV2Data.__updateIndexCacheWithOneObject);
            },
            /**
             * merges an index to the existing one.  this is to avoid a costly refresh.
             * @param {Object} inMemoryData ...
             * @param {integer} iIndexToMerge ...
             */
            __mergeIndexCache: function __mergeIndexCache(inMemoryData, iIndexToMerge) {
                if (iIndexToMerge) {
                    if (!inMemoryData._indexCache) {
                        FoundationV2Data.__buildIndexCache(inMemoryData);
                    } else {
                        UWA.extend(inMemoryData._indexCache, iIndexToMerge);
                    }
                }
            },
            /**
             * buid the index for the in memory data if it doesn't already exist.
             * this function will not refresh an existing index.
             * @param {Object} inMemoryData the data to build the index for
             */
            __buildIndexCache: function __buildIndex(inMemoryData) {
                if (inMemoryData && !inMemoryData._indexCache) {
                    FoundationV2Data.__refreshIndexCache(inMemoryData);
                }
            },
            /**
             * for one batch of modifiedobjects, reset the update action status to something else.
             * @param {Object} modifiedObjectList  the batch of object to treat
             * @param {String} newStatus the status to set
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
             * @param {Object} inMemoryData ...
             * @param {Object} iObject the object to be deleted
             */
            __deleteObject: function(inMemoryData, iObject) {
                var index;
                if (iObject._relationshipParentObject) {
                    index = iObject._relationshipParentObject.relateddata[iObject._relationship].indexOf(iObject);
                    if (index !== -1) {
                        iObject._relationshipParentObject.relateddata[iObject._relationship].splice(index, 1); //remove 1 item at index.
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
             * @param {Object} inMemoryData  the in memory form of our data.  This contains informations on what has been modified (as annotations)
             * @param {Object} modifiedList ...
             * @param {Object} [saveId]  if this is set only changes to objects having this id will be taken into account
             * @return {Object} either:
             *          an object with 2 entries clonedObjects and updateWidget corresponding to the items 1 and 2 described previously
             *          null if _addModifiedObject return null, i.e. if the current modified objects have an ancestor which is
             */
            __generateUpdateWidget: function(inMemoryData, modifiedList, saveId) {
                var updateWidget = {
                        data: []
                    },
                    clonedObjects = {},
                    parent, child, relationship, id;

                updateWidget.csrf = inMemoryData.csrf;
                //   updateWidget.name = inMemoryData.name; //not necessary anymore as the name will now be part of the url.  This means that to compute the url for sending the updates
                //we need to save the initial service name on the client
                for (var i = 0; i < modifiedList.length; i++) {
                    parent = modifiedList[i].parent;
                    child = modifiedList[i].child;
                    relationship = modifiedList[i].relationship;

                    if (typeof child.updateAction === 'undefined' /* || child._updateActionStatus === 'PENDING'*/ ) { //no modification
                        continue;
                    } else if (child._updateActionStatus === 'PENDING') {
                        //wait until the server sends its reply before sending a second change?   It would prevent the 2 changes from telescoping in the server
                        return null;
                    }

                    id = FoundationV2Data.getId(child);
                    if (saveId !== undefined && id !== saveId) {
                        continue;
                    }

                    if (FoundationV2Data.__addModifiedObject(updateWidget, clonedObjects, parent, relationship, child) === null) {
                        //not ready to send data to server.
                        return null;
                    }
                }
                //mark all updated objects with PENDING status.
                var hasOwn = Object.prototype.hasOwnProperty; //shortcut
                for (var key in clonedObjects) {
                    if (hasOwn.call(clonedObjects, key)) {
                        child = clonedObjects[key].source;

                        if (child.updateAction !== undefined) {
                            child._updateActionStatus = 'PENDING';
                            child.updateActionPending = child.updateAction; //so we can add a new one.  We need to diferentiate between when an object has an
                            //update action in the queue vs when it has one which has been sent to the server
                            delete child.updateAction;
                        }
                    }

                }
                delete updateWidget._ids;
                return {
                    updateWidget: updateWidget,
                    clonedObjects: clonedObjects
                };
            },
            /**
             * adds an object to the message sent to the server in case of an update.
             * This adds a simplified clone of the object both to the hash of sent objects and to the message itself.
             * This method calls itself recursively until all the parents of the passed in objects are in the message.
             * This method will not modify the message and return null if there is a pending modification on one of the ancestors.
             * In this case the modifications on child will have to be sent to the server once the pending ones are resolved
             *
             * @param {String?} updateWidget the message which is in construction see 2 in the documentation for __generateUpdateWidget
             * @param {Object} clonedObjects the hash containing the cloned objects and their originals see 1 in the documentation for __generateUpdateWidget
             * @param {Object|String} parent the parent object for the object modified (only if the modified object is not a first level)
             * @param {String} relationship relationship between parent and child
             * @param {Object} child the object to save
             * @return {Object} either the cloned child or null if a pending update prevents us from sending the update to the server
             */
            __addModifiedObject: function __addModifiedObject(updateWidget, clonedObjects, parent, relationship, child) {
                var clonedParent = null,
                    clonedChild = null,
                    childId = FoundationV2Data.getId(child);
                var hasOwn = Object.prototype.hasOwnProperty;

                if (child.updateAction === 'CREATE') { //check if our dependencies are pending or in the queue
                    //if our parent has a pending update, return null we need to queue this modification we are not ready to send it to the server yet
                    if (parent && parent._updateActionStatus) { //parent is pending or in the queue
                        return null;
                    }
                }

                if (child.updateAction === 'CREATE' || child.updateAction === 'MODIFY') { //case of modify we should also check for dependencies
                    var dataElements = child.dataelements;
                    var dependencies = dataElements._dependencies;
                    for (var key in dataElements) {
                        if (hasOwn.call(dataElements, key) && dataElements[key] && dependencies && dependencies[key]) {
                            if (dependencies[key]._updateActionStatus) {
                                //if a dependency has a PENDING status or a QUEUED we need ot queue the modification
                                return null;
                            }
                            //otherwise update actual value based on latest id.
                            dataElements[key] = FoundationV2Data.getId(dependencies[key]);
                            delete dependencies[key];
                            if (Object.keys(dependencies).length === 0) {
                                delete dataElements._dependencies;
                            }
                        }
                    }
                }

                if (parent) {
                    var parentId = FoundationV2Data.getId(parent),
                        found = clonedObjects[parentId];


                    //recursion to make sure we detect pendings in our grandparents and we give enough context to the server
                    if (!found) {
                        found = FoundationV2Data.__addModifiedObject(updateWidget, clonedObjects, parent._parentObject || parent._relationshipParentObject, parent._relationship, parent);
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
                    FoundationV2Data.__copyModifiedObject(child, clonedChild); //clone some object properties.
                    if (relationship) {
                        if (clonedParent.relateddata === undefined) {
                            clonedParent.relateddata = {};
                        }
                        if (clonedParent.relateddata[relationship] === undefined) {
                            clonedParent.relateddata[relationship] = [];
                        }
                        clonedParent.relateddata[relationship].push(clonedChild);
                    } else if (clonedParent) {
                        if (clonedParent.children === undefined) {
                            clonedParent.children = [];
                        }
                        clonedParent.children.push(clonedChild);
                    } else {
                        //make sure we don't put the same child twice
                        if (updateWidget._ids && updateWidget._ids[FoundationV2Data.getId(clonedChild)]) {
                            //object is already in the updateWidget
                            //should not happen since we should have already found it in the clonedObjects cache
                        } else {
                            if (!updateWidget._ids) {
                                FoundationV2Data._setInternalProperty(updateWidget, '_ids', {});
                            }
                            updateWidget.data.push(clonedChild);
                            updateWidget._ids[FoundationV2Data.getId(clonedChild)] = true;
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
             * @param {Object} source modified object to copy
             * @param {Object} target empty object which will contain the copy of the source
             */
            __copyModifiedObject: function(source, target) {
                var propertyList = ['id', 'tempId', 'updateAction', 'cestamp', 'service', 'tenant'];
                for (var i = 0; i < propertyList.length; i++) {
                    target[propertyList[i]] = source[propertyList[i]];
                }
                if (source.updateAction === 'CREATE') {
                    target.dataelements = source.dataelements;
                } else if (source.updateAction === 'MODIFY') {
                    //copy only the modified dataelements
                    var previousValues = source.dataelements._previousValues;
                    if (previousValues) {
                        var lKeys = Object.keys(previousValues);
                        target.dataelements = {};
                        for (var lCurKeyIdx = lKeys.length - 1; lCurKeyIdx >= 0; lCurKeyIdx--) {
                            var lCurKey = lKeys[lCurKeyIdx];
                            var lCurDataElement = source.dataelements[lCurKey];
                            target.dataelements[lCurKey] = lCurDataElement;
                        }
                    }
                } else if (source.updateAction === 'CONNECT' && !source.id) { //case of connect by attribute value
                    target.dataelements = source.dataelements;
                } else if (!source.updateAction) {
                    target.updateAction = 'NONE';
                } else if (source.updateAction === 'CONNECT' && source.service === '3DDrive') {
                    // need to send data elements in case we are handling 3drive objects as backend has a weird requirement for that
                    target.dataelements = source.dataelements;
                }
                delete source.updateMessage;
                delete source.updateSuccessful;

            },
            /**
             * utility method to initialize a new object correctly.
             * take some fields as an input.  fields should be of the form
             * {name: XXX, value:'YYY'}
             * @param {Object} fields ...
             * @return {Object} ...
             */
            __newObject: function(fields) {
                var newObject = {
                    children: [],
                    dataelements: {}
                };
                var dependency;
                var dependencies;
                for (var i = 0; i < fields.length; i++) {
                    var field = fields[i];
                    dependency = undefined;
                    if (field.value) { //case the field is undefined, shouldn't happen but lets be prudent
                        if (typeof field.value === 'object') {
                            dependency = field.value;
                            field.value = FoundationV2Data.getId(dependency);
                        }
                        newObject.dataelements[field.name] = field.value;
                        if (dependency) {
                            if (!dependencies) {
                                dependencies = {};
                                FoundationV2Data._setInternalProperty(newObject.dataelements, '_dependencies', dependencies);
                            }
                            dependencies[field.name] = dependency;
                        }
                    }
                }
                return newObject;
            },
            /**
             * delete all the prev Values store on any field of an object.  Optionally restore that prev Value.
             * @param {Object} object the object to handle
             * @param {boolean} restorePrevValue if true before deleting the prevValue we will restore it.
             *      True is used when a modification needs to be canceled, usually due to a server call returning an error.
             *      False is used when the server confirmed that the modification has been applied.
             */
            __deletePrevValues: function(object, restorePrevValue) {
                var dataElements = object.dataelements;
                //  var hasOwn = Object.prototype.hasOwnProperty;
                if (restorePrevValue) {
                    var previousValues = dataElements._previousValues;
                    if (previousValues) {
                        UWA.extend(dataElements, previousValues, false);
                    }
                }
                delete dataElements._previousValues;
            },
            /**
             * utility method for syncing.
             * try to find the corresponding client object from a server one.
             * seems simple but not so much in fact. Due to all the temp Id shennanigans
             *
             * @param {Object} inMemoryData the client data
             * @param {Object} iObject the server object
             * @return {Object} the object if found
             */
            __getSourceObjectFromServerObject: function(inMemoryData, iObject) {
                var lId = FoundationV2Data.getId(iObject); //using the object id means that only the first instance of the object will effectively be updated
                var source = inMemoryData._indexCache[lId];
                var lUpdateAction = iObject.updateAction;
                //  var lTriedPhysicalId = lId === iObject.id;
                if (!source && (lUpdateAction === 'CREATE' || lUpdateAction === 'CONNECT')) {
                    //CREATED object or CONNECTED object from search like assignees by trig
                    lId = iObject.tempId;
                    source = inMemoryData._indexCache[lId];
                    //                if (!source) { //still haven't found it. Case of Connect with no tempId, compute tempRelId
                    //                    //need to make sure that the back pointers are set
                    //                    if (iFromServerParent) {
                    //                        if (iRelation === 'children') {
                    //
                    //
                    //                            FoundationV2Data._setInternalProperty(iObject, '_parentObject', iFromServerParent);
                    //                        } else {
                    //                            FoundationV2Data._setInternalProperty(iObject, '_relationshipParentObject', iFromServerParent);
                    //                            FoundationV2Data._setInternalProperty(iObject, '_relationship', iRelation);
                    //                            //iObject._relationship = iRelation;
                    //                        }
                    //
                    //                    }
                    //
                    //                    lId = __computeTempRelId(iObject);
                    //
                    //                    source = inMemoryData._indexCache[lId];
                    //
                    //                }
                    ////                if (!source) { //still haven't found it. Case of Connect with no tempId, compute tempRelId but with objectId in case the reference was added with an objectId
                    ////                    lId = __computeTempRelId(iObject, true);
                    ////                    source = inMemoryData._indexCache[lId];
                    ////                }
                }
                //additional case in DPG where no relid is there and a weird tempRelId exists but tempId is still there
                if (!source) {
                    lId = iObject.tempId;
                    source = inMemoryData._indexCache[lId];

                }

                return source;
            },
            /**
             * Used by applyUpdates to reconcile in case of success the return values of the server with what was sent and with the in memory version of the data model.
             * recursively synchronize the data sent by the server with the in memory form.
             *  @param {Object} inMemoryData the data to sync
             *  @param {Object} modifiedUpdateWidget   the data returned by the server after a successful update call
             *  @param {Object} masterReference the hash which was built by __generateUpdateWidget which contains the object pair (cloned copies sent and original) indexed by their id
             */
            __synchronizeInMemoryDataWithServerReturn: function(inMemoryData, modifiedUpdateWidget, masterReference) {
                //step 1 check for the index existence (it should always be there but the test is cheap)
                FoundationV2Data.__buildIndexCache(inMemoryData);
                //step 2 scan the list of updates sent to the server for DELETE and DISCONNECT.  This list is the masterReference
                var lKeys = Object.keys(masterReference);
                var lNbKeys = lKeys.length;
                for (var lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                    var lCurKey = lKeys[lCurKeyIdx];
                    var lCurCloneInfo = masterReference[lCurKey];
                    var lCurObjectSentToServer = lCurCloneInfo.item;
                    var lCurMaster = lCurCloneInfo.source;
                    //check the updateAction
                    if (lCurObjectSentToServer.updateAction === 'DELETE' || lCurObjectSentToServer.updateAction === 'DISCONNECT') {
                        FoundationV2Data.__deleteObject(inMemoryData, lCurMaster);
                        delete lCurMaster.updateActionPending; //bcc: is this really necessary after we removed the object from the structure
                        //nothing to do with regards to the MVC model as this has been done prior
                        FoundationV2Data.__removeObjectAnnotation(lCurMaster);
                    }
                }
                //step 3 iterate over the update data structure and perform a merge
                FoundationV2Data.iterateOverDataStructure(modifiedUpdateWidget, function(iObject) {
                    var lUpdateAction = iObject.updateAction;
                    var lRet;
                    if (lUpdateAction === 'DELETE' || lUpdateAction === 'DISCONNECT') {
                        //handled already in step 2
                        return FoundationV2Data.CULL_BRANCH;
                    }
                    //lookup the corresponding object
                    var lSource = FoundationV2Data.__getSourceObjectFromServerObject(inMemoryData, iObject);
                    FoundationV2Data.__synchronizeSourceObjectFromServerObject(inMemoryData, iObject, lSource);
                    return lRet;
                });
            },
            /**
             * syncrhonize 2 row objects one from the server one from the client.
             * used for the generic sync as well as for the fetch from mvc objects.
             * @param {Object} inMemoryData the in Memory data structure
             * @param {Object} iFromServer data coming from the server
             * @param {Object} iSource the data from the inMemoryData
             * @param {boolean} [iDontResetUpdates] [optional] if true the updateActionPending ans _updateActionStatus won't be reset.
             *        This is to be used if the message from the server is not an update message (case for instance of request for info on an object)
             * @param {boolean} [iExactRelatedData] [optional] if true consider that the related data are exact values, meaning that if there are missing entries they should be removed
             * @return {boolean} true if it made a change
             */
            __synchronizeSourceObjectFromServerObject: function(inMemoryData, iFromServer, iSource, iDontResetUpdates, iExactRelatedData) {
                var lChange = false;
                if (iSource) {
                    if (iSource !== iFromServer) {
                        FoundationV2Data.__synchronizeObjectAttributes(inMemoryData, iFromServer, iSource);
                        lChange = FoundationV2Data.__synchronizeObjectArrays(inMemoryData, iFromServer.children, iSource.children, iFromServer, 'children');
                        if (lChange && iSource._mvcModel) {
                            //children have been updated need to fire an event on mvc
                            //do not fire the change event for the whole object we want to fire only one for children and relateddata
                            iSource._mvcModel._fireRelationshipChangeEvents('children', {}, true);
                        }
                        var lSyncChanges = FoundationV2Data.__synchronizeRelatedData(inMemoryData, iFromServer, iSource, iExactRelatedData);
                        lChange = lChange || lSyncChanges;
                        if (lChange && iSource._mvcModel) { //either relatedData or children modified, fire a change event for the object
                            iSource._mvcModel._fireRelationshipChangeEvents(undefined, undefined, false, true);
                        }
                        if (!iDontResetUpdates) {
                            delete iSource._updateActionStatus;
                            delete iSource.updateActionPending;
                        }

                    }
                }
                return lChange;
            },
            /**
             * synchronizes to arrays of subobject (related data, children, ...).
             * @param {Object} inMemoryData: the foundation in memory data
             * @param {Object} iFromServer: array of objects from the server to sync
             * @param {Object} iSource: array of objects from the memory to sync
             * @param {Object} iFromServerParent: parent object from the server (usefull since the backpointer _parentObject and _relationParentObject aren't set yet)
             * @param {String} iRelation: relationship
             * @param {Array} [iExactArray] [optional] if this is true the server side will be considered complete and if it is missing some entries they will be removed from the client side
             * @return {boolean} true if it made a change
             *
             */
            __synchronizeObjectArrays: function(inMemoryData, iFromServer, iSource, iFromServerParent, iRelation, iExactArray) {
                var lRet = false;
                if (iFromServer) {
                    //cleanup excess
                    if (iExactArray) {
                        //index the stuff from the server
                        var serverIndex = {};
                        iFromServer.forEach(function(rowObject) {
                            serverIndex[rowObject.id] = rowObject; //assume there is a physicalId
                        });
                        iSource.forEach(function(model, index) {
                            if (!serverIndex[model.id]) { //assume there is a physicalId
                                iSource.splice(index, 1);
                                lRet = true;
                            }
                        });
                    }
                    var lNbObjects = iFromServer.length;
                    //used to find the corresponding source object
                    //intended to be called with the current server object as this
                    var comparator = function(iCurSourceObject) {
                        //compare ids
                        return (iCurSourceObject.tempId !== undefined && iCurSourceObject.tempId === this.tempId) || iCurSourceObject.id === this.id;
                    };
                    for (var lCurObjectIdx = 0; lCurObjectIdx < lNbObjects; lCurObjectIdx++) {
                        var lCurObject = iFromServer[lCurObjectIdx];
                        var lUpdateAction = lCurObject.updateAction;
                        if (lUpdateAction === 'DELETE' || lUpdateAction === 'DISCONNECT') {
                            //don't add the deleted or disconnected objects back in
                            continue;
                        }
                        //var lSourceObject = iSource.detect(iSource, comparator, lCurObject);  //for next UWA version
                        var lSourceObject = iSource.detect(comparator, lCurObject);
                        //var lSourceObject = FoundationV2Data.__getSourceObjectFromServerObject(inMemoryData, lCurObject, iFromServerParent, iRelation);
                        if (!lSourceObject) {
                            iSource.push(lCurObject);

                            //FoundationV2Data.__updateIndexCacheWithOneObject.call(inMemoryData, lCurObject);
                            //FoundationV2Data.iterateOverObject(inMemoryData, iSource); //replug the parents back pointer to the source
                            FoundationV2Data._setInternalProperty(lCurObject, '_parentRecords', iSource); //replug the parents back pointer to the source
                            FoundationV2Data.iterateOverObject(inMemoryData, lCurObject, FoundationV2Data.__updateIndexCacheWithOneObject); //update the index
                            lRet = true;
                        } else { /*lRet = */
                            FoundationV2Data.__synchronizeSourceObjectFromServerObject(inMemoryData, lCurObject, lSourceObject);
                            //still need to sync the main representative if it was not this one
                            var lMainSourceObject = FoundationV2Data.__getSourceObjectFromServerObject(inMemoryData, lCurObject, iFromServerParent, iRelation);
                            if (lSourceObject !== lMainSourceObject) {
                                FoundationV2Data.__synchronizeSourceObjectFromServerObject(inMemoryData, lCurObject, lMainSourceObject);
                            }
                        }

                    }
                }
                return lRet;
            },
            /**
             * synchronize related data between an object coming from the server and the one in the in memory datastructure
             * @param {Object} inMemoryData the in memory data
             * @param {Object} iFromServer the object from the server
             * @param {Object} iSource the object to synchronize (from the inMemoryData)
             * @param {Boolean} iExactRelatedData is the related data from the server exact (should we remove things)
             * @return {Boolean} true if it made a change
             */
            __synchronizeRelatedData: function(inMemoryData, iFromServer, iSource, iExactRelatedData) {
                var lRet = false;
                var lFromServerRelData = iFromServer.relateddata;
                var lSourceRelData = iSource.relateddata;
                var lCurKey;
                var lKeys, lNbKeys, lCurKeyIdx;
                if (lFromServerRelData) {
                    if (!lSourceRelData) {
                        iSource.relateddata = lFromServerRelData;
                        //now we index them all
                        FoundationV2Data.iterateOverObject(inMemoryData, iSource, FoundationV2Data.__updateIndexCacheWithOneObject);
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
                            var lCurServerArray = FoundationV2Data.getRelatedObjects(iFromServer, lCurKey);
                            var lCurSourceArray = FoundationV2Data.getRelatedObjects(iSource, lCurKey);
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
                                var lCurRet = FoundationV2Data.__synchronizeObjectArrays(inMemoryData, lCurServerArray, lCurSourceArray, iFromServer, lCurKey, iExactRelatedData);
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
                            FoundationV2Data.iterateOverObject(inMemoryData, iSource, FoundationV2Data.__updateIndexCacheWithOneObject);
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
             * This overwrite all attributes except if the source has updateAction === 'MODIFY' in which case it only overwrite those which do not
             * have a prevValue
             * @param {Object} inMemoryData the in memory data
             * @param {Object} iObject the object from the server
             * @param {Object} iSource the object to synchronize
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
                    if (iSource.updateAction === 'MODIFY') { //local changes need to be careful
                        //go through each dataelement individually
                        FoundationV2Data.appendFieldData(iSource, iObject);
                    } else {
                        if (iObject.dataelements) {
                            iSource.dataelements = iObject.dataelements;
                            FoundationV2Data.__deletePrevValues(iSource, false);
                        }
                    }
                    if (!iSource.id) {

                        iSource.id = iObject.id;
                        //update the index
                        FoundationV2Data.__updateIndexCacheWithOneObject.call(inMemoryData, iSource);
                    }
                    if (iObject.type && iObject.type !== iSource.type) {
                        iSource.type = iObject.type;
                    }

                    iSource.cestamp = iObject.cestamp;
                    // iSource.updateSuccessful = iObject.updateSuccessful;
                    if (iSource._mvcModel) {
                        iSource._mvcModel.applyUpdatesFromServer();
                    }

                }
            },
            /**
             * remove object annotation which could artificially maintain other objects alive
             * @param {Object} iObject the row object from which annotation needs to be removed
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
             * @param {Object} inMemoryData ...
             *  @param {Object} modifiedUpdateWidget   the data returned by the server after a successful update call
             *  @param {Object} updateWidget  the data which was sent to the server during the update call
             *  @param {Object} masterReference the hash which was built by __generateUpdateWidget which contains the object pair (cloned copies sent and original) indexed by their id
             */
            __postprocessServerFailureMessage: function(inMemoryData, modifiedUpdateWidget, updateWidget, masterReference) {
                //called in case of failure.
                //we need to:
                //1) scan the returned object and find the update Messages
                //  1.1) copy them on the relevant source object
                //2) mark all objects in the master reference as having failed, except if explicitly tagged by the server as having been updated successfuly

                //1) scan
                var hasOwn = Object.prototype.hasOwnProperty; //shortcut
                FoundationV2Data.iterateOverDataStructure(modifiedUpdateWidget, function(object) {
                    var id = FoundationV2Data.getId(object);
                    var master = masterReference[id].source;
                    //1.1) copy relevant information (message) from the server
                    if (hasOwn.call(object, 'updateSuccessful')) {
                        master.updateSuccessful = object.updateSuccessful;
                        if (master.updateSuccessful) { //partially successful return, shouldn't really happen
                            //try syncing
                            FoundationV2Data.__synchronizeSourceObjectFromServerObject(inMemoryData, object, master);
                        }
                    }
                    if (hasOwn.call(object, 'updateMessage')) {
                        master.updateMessage = object.updateMessage;
                    }
                });
                //2) mark objects as having failed
                for (var key in masterReference) {
                    if (hasOwn.call(masterReference, key)) {
                        var masterCouple = masterReference[key];
                        if (masterCouple.item.updateAction !== 'NONE') {

                            var master = masterCouple.source;
                            if (!master.updateSuccessful) {
                                delete master._updateActionStatus; //delete pending status.
                                //keep track of the last failed action
                                master.updateActionFailed = master.updateActionPending;
                                delete master.updateActionPending; //delete update action.
                            }

                        }

                    }
                }



                //             var id, master;
                //             var hasOwn = Object.prototype.hasOwnProperty; //shortcut
                //             for (var key in modifiedUpdateWidget) {
                //                 if (hasOwn.call(modifiedUpdateWidget, key)) {
                //                     if (key === 'data' || key === 'children' || key === 'relateddata') {
                //                         var sourceItems = modifiedUpdateWidget[key];
                //                         var targetItems = updateWidget[key];
                //                         if (!targetItems) {
                //                             continue;
                //                         }
                //                         if (key === 'relateddata') {
                //                             for (var rel in sourceItems) {
                //                                 if (hasOwn.call(sourceItems, rel)) {
                //                                     //recursively calls ourselves
                //                                     var lCurSourceItems = sourceItems[rel];
                //                                     var lNbSourceItems = lCurSourceItems.length;
                //                                     //like for children we will assume that in case of failure the 2 arrays are the same length.
                //                                     // we could scan the sourceItems and look for items with the same ids in the target

                //                                     FoundationV2Data.__postprocessServerFailureMessage(inMemoryData, sourceItems[rel], targetItems[rel], masterReference);
                //                                 }
                //                             }
                //                         } else {
                //                             //this is assuming that the length are the same between the 2 lists.  Couldn't we have new children not present in the source as in relateddata
                //                             for (var i = 0; i < sourceItems.length; i++) {
                //                                 FoundationV2Data.__postprocessServerFailureMessage(inMemoryData, sourceItems[i], targetItems[i], masterReference);
                //                             }
                //                         }
                //                     } else if (key === 'updateAction') {
                //                         if (modifiedUpdateWidget[key] !== 'NONE') {
                //                             id = FoundationV2Data.getId(updateWidget);
                //                             master = masterReference[id].source;
                //                             if (modifiedUpdateWidget.updateMessage) {
                //                                 master.updateMessage = modifiedUpdateWidget.updateMessage;
                //                             }
                //                             if (hasOwn.call(modifiedUpdateWidget, 'updateSuccessful')) {
                //                                 master.updateSuccessful = modifiedUpdateWidget.updateSuccessful;
                //                             }
                //                             delete master._updateActionStatus; //delete pending status.
                //                             //keep track of the last failed action
                //                             master.updateActionFailed = master.updateActionPending;
                //                             //}
                //                             delete master.updateActionPending; //delete update action.
                //                         }

                //                     }
                //                 }
                //             }
            },
            /**
             * adds an object to the inMemoryData's list of modified objects which will need.
             * if parentObject and relationship are not supplied, they will be deduced from the object which was modified.
             * @param {Object} inMemoryData, the in memory data structure
             * @param {Object|String} parentObject, optional, the parent object of the modified object.  If this is not specified it must be possible to deduce it from the object.
             * @param {Object} childObject, mandatory, the object to add to the list
             * @param {String} relationship, optional, the relationship between the parent and child object,
             *                          if null and the child object do not carry a _relationship value,
             *                          it is assumed the object should be created is a child
             */
            __addToModifiedList: function(inMemoryData, parentObject, childObject, relationship) {
                var modifiedList = inMemoryData._modifiedObjectList;
                if (!modifiedList) {
                    modifiedList = [];
                    FoundationV2Data._setInternalProperty(inMemoryData, '_modifiedObjectList', modifiedList);
                    //                //inMemoryData._modifiedObjectList = modifiedList;
                }
                if (!parentObject) {
                    relationship = childObject._relationship;
                    parentObject = childObject._relationshipParentObject;
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
             * @param {Object} [iParentObject] optional.  When an object is instantiated in several place it is safer to provide the explicit parent to be disconnected.
             * @param {String} iRelationship optional.  When an object is instanciated in several place, potentially with several relations it is safer to ecplicitly provide the one to disconnect.
             *
             * NOTE: server side the service may be relying heavily on the relationship id for disconnecting so even if iParentObject and relationship are set correctly if the
             *       childObject which is used is one with an incorrect relId it will not function correctly
             */
            __disconnectObject: function(inMemoryData, childObject, iParentObject, iRelationship) {
                //var relationship = undefined,
                var parentObject = iParentObject || childObject._parentObject; //undefined is fine for related data as __addToModifiedList reads the record itself
                var lUpdateAction = childObject.updateAction;
                childObject.updateAction = 'DISCONNECT';
                if (!lUpdateAction) {
                    //this means that in case of a MODIFY then DISCONNECT the MODIFY gets lost
                    FoundationV2Data.__addToModifiedList(inMemoryData, parentObject, childObject, iRelationship);

                }
                if (parentObject._mvcModel) {
                    parentObject._mvcModel._fireRelationshipChangeEvents(iRelationship || 'children', {});
                }
            },
            /**
             * Helper method to connect an object as a new child of the parent object.
             * this can apply to children or to relatedData.  The newObject can be an existing one (case of __connectObject) or a new one (case of __addObject).
             * This will add the object to the structure. This will not mark the object with the appropriate updateAction nor will it add a temp_id, that step should have
             * happened prior.
             * It will on the other hand update the _indexCache
             * @param {Object} inMemoryData the in memory data model
             * @param {String} relationship, optional, the name of the relationship to use when adding the object to is parent.  If present a relatedData object is created
             * @param {Object|String} parentObject the existing object on which a new child is added.  This should exist in the in memory data model.
             * @param {Object} newObject the object to connect this is typically an object pre-existing on the server, the id of which was retrieved by one mean or another.
             *                  the newObject is typically just an empty wrapper around that id
             * @param {integer} index optional, where in the list of children to insert this one.
             * @param {Object} [iMVCModel] optional mvcModel which will have to be updated prior to firing events
             * @return {Object} the newObject
             */
            __addOrConnectObjectToStructure: function(inMemoryData, relationship, parentObject, newObject, index, iMVCModel) {

                var rows;
                var lRelationship = relationship;
                if (!parentObject) {
                    rows = inMemoryData.data;
                } else {
                    if (lRelationship) {
                        if (parentObject.relateddata === undefined) {
                            parentObject.relateddata = {};
                        }
                        if (parentObject.relateddata[lRelationship] === undefined) {
                            parentObject.relateddata[lRelationship] = [];
                        }

                        rows = parentObject.relateddata[lRelationship];
                        FoundationV2Data._setInternalProperty(newObject, '_relationshipParentObject', parentObject);
                        FoundationV2Data._setInternalProperty(newObject, '_relationship', lRelationship);
                        // newObject._relationship = lRelationship;
                    } else {
                        if (parentObject.children === undefined) {
                            parentObject.children = [];
                        }
                        rows = parentObject.children;
                        FoundationV2Data._setInternalProperty(newObject, '_parentObject', parentObject);
                        lRelationship = 'children';
                        //newObject._parentObject = parentObject;
                    }

                }


                if (index !== 0 && !index) { // first condition because 0 would be a valid place to insert at and would also be falsy for js
                    rows.push(newObject);
                } else {
                    //insert object in list.
                    rows.splice(index, 0, newObject);
                }

                FoundationV2Data._setInternalProperty(newObject, '_parentRecords', rows);
                if (inMemoryData._indexCache) {
                    //FoundationV2Data.__makeRelId(newObject);
                    FoundationV2Data.iterateOverObject(inMemoryData, newObject, FoundationV2Data.__updateIndexCacheWithOneObject); //update the index
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
                    FoundationV2Data._setInternalProperty(newObject, '_mvcModel', iMVCModel);
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
             * @param {Object} iObject, object to enrich
             * @param {String} iName, name of the property
             * @param {String} iValue, value of the property
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
             * @param {Object} inMemoryData the in memory data model
             * @param {String} relationship, optional, the name of the relationship to use when adding the object to is parent.  If present a relatedData object is created
             * @param {Object|String} parentObject the existing object on which a new child is added.  This should exist in the in memory data model.
             * @param {Object} newObject the object to connect this is typically an object pre-existing on the server, the id of which was retrieved by one mean or another.
             *                  the newObject is typically just an empty wrapper around that id
             * @param {integer} index optional, where in the list of children to insert this one.
             * @return {Object} the newObject
             */
            __connectObject: function(inMemoryData, relationship, parentObject, newObject, index) {
                if (!parentObject) {
                    throw new Error('parentObject is mandatory');
                }
                newObject.updateAction = 'CONNECT';
                if (!FoundationV2Data.getId(newObject)) {
                    //add a tempId, this is typically the case when we have an object that is being searched.
                    //the tempId is necessary otherwise we can't reconcile after saving the searched object with the stub
                    newObject.tempId = FoundationV2Data._newTempId();
                }
                FoundationV2Data.__addOrConnectObjectToStructure(inMemoryData, relationship, parentObject, newObject, index);
                FoundationV2Data.__addToModifiedList(inMemoryData, parentObject, newObject, relationship);
                return newObject;
            },
            /**
             * generate tempId, keep that as a separate function so it can be use in tests
             * @return {String} a temp id
             */
            _newTempId: function() {
                // Math.random gives a number between 0 and 1 which concatenates a decimal
                //creating issues in query selector so using math floor on it
                return 'temp_' + new Date().getTime() + Math.floor((Math.random() * 10000));
            },

            /**
             * create a new object and add it in the data model.
             * this is meant to be called when a new object needs to be added to the structure at any level
             * (depending on the parameters this will be added at the root or as a child or related data of another object).
             * The added object will be marked as created and added to the list of modified objects to be persisted during
             * the next applyUpdates.
             * @param {Object} inMemoryData, the in memory data structure
             * @param {String} relationship, optional, the name of the relationship to use when adding the object to is parent.  If present a relatedData object is created
             * @param {Object|String} parentObject, optional, the parentObject to add the new object to. If it is not present the object is added as a new root
             * @param {Object} newObject, mandatory the row object to add
             * @param {integer} index optional where among the parent's children or the relatedData array should the new object be added
             * @param {Object} [iMVCModel], optional mvcModel which will have to be updated prior to firing events
             * @return {String} id
             */
            __addObject: function(inMemoryData, relationship, parentObject, newObject, index, iMVCModel) {

                newObject.updateAction = 'CREATE';
                newObject.tempId = FoundationV2Data._newTempId();
                FoundationV2Data.__addOrConnectObjectToStructure(inMemoryData, relationship, parentObject, newObject, index, iMVCModel);
                FoundationV2Data.__addToModifiedList(inMemoryData, parentObject, newObject, relationship);
                return newObject.tempId;
            },
            /**
                           * utility method to find an object by id among rows.
                           * @param rows the rows to be searched
                  //          * @param id either an objectid a relid a physicalid or a tempid
                  //          */
            //         __findObject: function(rows, id) {
            //             var retobject = null;
            //             if (rows) {
            //                 for (var i = 0; i < rows.length; i++) {
            //                     if (id === rows[i].id || id === rows[i].tempId || id === rows[i].relId  ) {
            //                         retobject = rows[i];
            //                         break;
            //                     }
            //                 }
            //             }
            //             return retobject;
            //         },
            /**
             * update inMemoryData csrf from another return from the server.
             * used when we call multiple separated REST APIs
             * @param {Object} inMemoryData the in memorydata which will have its csrf updated
             * @param {Object} newData the data from the server where the up to date csrf will come from
             */
            __updateCsrf: function(inMemoryData, newData) {
                if (newData && newData.csrf) {
                    inMemoryData.csrf = newData.csrf;
                }

            },
            _turnDataIntoObject: function(inMemoryData) {
                //TODO replace this by creating a new object and returning it
                var lRet;
                var newObject = Object.create(dataHelper);
                if (inMemoryData) {
                    UWA.merge(newObject, inMemoryData);
                    //UWA.merge(inMemoryData, dataHelper);
                    FoundationV2Data.__buildIndexCache(inMemoryData);
                    FoundationV2Data._setInternalProperty(newObject, '_indexCache', inMemoryData._indexCache);

                    //redirect the _container pointer
                    if (newObject.data) {
                        FoundationV2Data._setInternalProperty(newObject.data, '_container', newObject);
                    }
                    lRet = newObject;
                }
                return lRet;
            },
            /**
             * copy the definition from one response to another
             * @param {Object} inMemoryData the in memory data
             * @param {Object} resp response from the server
             */
            copyDefinition: function(inMemoryData, resp) {
                resp.definitions = inMemoryData.definitions;
                if (inMemoryData._fieldIndexCache) {
                    FoundationV2Data._setInternalProperty(resp, '_fieldIndexCache', inMemoryData._fieldIndexCache);
                }
            },
            /**
             * Foundation V2 load widget will add some functions directly on the in memory data for ease of manipulation.
             * @param  {String} widgetName widget name
             * @param  {Function} callback callback func
             * @param  {Boolean} isPost [description]
             * @param  {[type]} postData [description]
             * @param  {[type]} iContentType [description]
             * @param  {[type]} iUrlParams [description]
             * @return {[type]} [description]
             */
            loadServiceData: function(widgetName, callback, isPost, postData, iContentType, iUrlParams) {
                var lContentType = iContentType || 'application/json';
                var lWidgetUrl = this.buildUrl(widgetName, iUrlParams);
                //swizzle getParams to use the new v2 convention
                if (window.enoviaServer) {

                    var oldGetParams = window.enoviaServer.getParams && window.enoviaServer.getParams._parent ?
                        window.enoviaServer.getParams._parent : window.enoviaServer.getParams;

                    window.enoviaServer.getParams = this.getParams;
                    window.enoviaServer.getParams._parent = oldGetParams;
                }
                var ret = FoundationData.loadWidget.call(this, lWidgetUrl, function(data) {
                    var objectData = FoundationV2Data._turnDataIntoObject(data);

                    FoundationV2Data._setInternalProperty(objectData, '_serviceName', widgetName);
                    return callback(objectData);
                }, isPost, postData, {
                    'Content-Type': lContentType
                });
                if (window.enoviaServer) {
                    window.enoviaServer.getParams = window.enoviaServer.getParams._parent ? window.enoviaServer.getParams._parent : window.enoviaServer.getParams;
                }
                return ret;
            },
            /**
             * build a url from a base part and some params
             * @param  {[type]} base [description]
             * @param  {[type]} iParams [description]
             * @return {String} service name
             */
            buildUrl: function(base, iParams) {
                var lServiceName = base;
                if (iParams) {
                    // var parsedUrl = UWA.Utils.parseUrl(lServiceName);
                    // if (parsedUrl.query) {
                    //     parsedUrl.query += '&';
                    // }
                    // parsedUrl.query += iParams;
                    // lServiceName = UWA.Utils.composeUrl(parsedUrl);
                    var prependString = lServiceName.indexOf('?') !== -1 ? '&' : '?';
                    lServiceName = lServiceName + prependString + iParams;
                }
                return lServiceName;
            },
            loadCachedData: function(storage, widgetName) {
                var data = FoundationData.loadCachedData.apply(FoundationData, arguments);
                if (data) {
                    data = FoundationV2Data._turnDataIntoObject(data);
                    FoundationV2Data.__buildIndexCache(data);
                    FoundationV2Data._setInternalProperty(data, '_serviceName', widgetName);
                }
                return data;
            },
            /**
             * replacement getParams for enoviaServer to be used during calls to V2 services
             * it is expected that a _parent method exists on the this.getParams method containing the V1 version of getParams (normally from WidgetUwaUtils)
             * @return {String} the parameter portions of a url.
             */
            getParams: function() {
                var lParams = this.getParams._parent.apply(this, arguments);
                //replace e6w-lang & e6w-timezone
                var lParamsParsed = lParams.length ? UWA.Utils.parseQuery(lParams) : {};
                var e6wlang = lParamsParsed['e6w-lang'];
                delete lParamsParsed['e6w-lang'];
                var e6wtimezone = lParamsParsed['e6w-timezone'];
                delete lParamsParsed['e6w-timezone'];
                lParamsParsed.$language = e6wlang;
                lParamsParsed.$timezone = e6wtimezone;
                return UWA.Utils.toQueryString(lParamsParsed);
            },
            /**
             * @param {Object} inMemoryData in memory data
             * @return {Object} csrf structure
             * getCsrf structure from inMemoryData
             */
            getCsrf: function(inMemoryData) {
                return inMemoryData && inMemoryData.csrf && UWA.clone(inMemoryData.csrf);
            },
            /**
             * @param {Object} inMemoryData in memory data
             * @param {Object} csrf csrf structure
             * setCsrf structure in inMemoryData
             */
            setCsrf: function(inMemoryData, csrf) {
                if (inMemoryData) {
                    inMemoryData.csrf = csrf;
                }
            },
            /**
             * Checks to see if the passed in string has an invalid character defined in emxSystem.properties
             * @param  {String} string string to check for bad chars
             * @return {boolean} true if object has no invalid characters
             */
            containsBadChars: function(string) {
                //check if the name has any characters in the array
                return FoundationV2Data._invalidCharsRegExp.test(string);
            }
        };

        //build the regular expression for bad characters
        //FoundationV2Data._invalidCharRegExp;
        Object.defineProperty(FoundationV2Data, '_invalidCharsRegExp', {
            get: function() {
                //if the regular expression has not already been defined, define it now
                if (!FoundationV2Data._invalidCharsRegExpRaw) {
                    var defaultValue = '@';
                    //get the string from emxSystem.properties
                    var badCharsStr = this.getWidgetConstant('emxFramework.Javascript.NameBadChars', defaultValue);
                    //get rid of spaces
                    badCharsStr = badCharsStr.replace(/ /g, '');
                    //escape all characters that we need to escape when building a reg exp
                    badCharsStr = badCharsStr.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'); //eslint-disable-line no-useless-escape
                    badCharsStr += '\';'; // fixed for IR-605738-3DEXPERIENCER2019x
                    FoundationV2Data._invalidCharsRegExpRaw = new RegExp('[' + badCharsStr + ']');

                    if (badCharsStr === defaultValue) {
                        console.error('Bad chars not loaded from server.'); //eslint-disable-line no-console
                    }
                }
                return FoundationV2Data._invalidCharsRegExpRaw;
            }
        });

        /**
         * [redirectProperty description]
         * @param  {string} propName [description]
         * @param  {Object} iObject [description]
         */
        function redirectProperty(propName, iObject) {
            var lObject = iObject || FoundationData;
            Object.defineProperty(FoundationV2Data, propName, {
                get: function() {
                    return lObject[propName];
                },
                set: function(newValue) {
                    lObject[propName] = newValue;
                }
            });
        }

        /**
         * [redirectFunction description]
         * @param  {Object} object [description]
         * @param  {String} functionName [description]
         */
        function redirectFunction(object, functionName) {
            object[functionName] = function() {
                var args = Array.prototype.slice.call(arguments, 0);
                args.splice(0, 0, this);
                return FoundationV2Data[functionName].apply(FoundationV2Data, args);
            };
        }

        redirectProperty('calculateFinalUrl');
        redirectProperty('ajaxRequest');
        redirectProperty('saveCachedData');
        redirectProperty('pictureAPIConfig');
        redirectProperty('__setRowFilter', WidgetAPIs);
        redirectProperty('__showParent', WidgetAPIs);
        // redirectFunction(dataHelper, 'getRelatedObject');
        redirectFunction(dataHelper, 'getObject');
        redirectFunction(dataHelper, 'applyUpdates');
        // redirectFunction(dataHelper, 'deleteRelatedObject');
        redirectFunction(dataHelper, 'deleteObject');
        redirectFunction(dataHelper, 'cancelObject');
        redirectFunction(dataHelper, 'rollbackFailedObject');
        redirectFunction(dataHelper, 'rollbackFailedData');
        //redirectFunction(dataHelper, 'modifyRelatedObject');
        redirectFunction(dataHelper, 'modifyObject');
        redirectFunction(dataHelper, 'disconnectObject');
        redirectFunction(dataHelper, 'disconnectRelatedObject');
        redirectFunction(dataHelper, 'connectRelatedObject');
        redirectFunction(dataHelper, 'connectObject');
        redirectFunction(dataHelper, 'addObject');
        redirectFunction(dataHelper, 'addRelatedObject');
        redirectFunction(dataHelper, 'unloadObjects');
        redirectFunction(dataHelper, 'loadObjects');
        redirectFunction(dataHelper, 'getAllFields');
        redirectFunction(dataHelper, 'setCsrf');
        redirectFunction(dataHelper, 'getCsrf');
        redirectFunction(dataHelper, 'iterateOverDataStructure');
        redirectFunction(dataHelper, 'getCustomFields');

        return FoundationV2Data;
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
define('DS/Foundation2/Collections/FoundationRelatedDataCollection', //define module
    ['UWA/Core', 'UWA/Class/Collection', 'UWA/Class/Model'], //prereqs

    function(UWA, Collection /*, Model*/ ) {
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
            sync: function( /*method, collection, options*/ ) {},
            add: function() {
                this._masterCollection.add.apply(this._masterCollection, arguments);
            }

        });
        return FoundationRelatedDataCollection;
    });

/*global define*/
define(
    'DS/Foundation2/TaggerAggregator', ['UWA/Core', 'UWA/Class/Events', 'UWA/Class/Listener'],
    function(UWA, Events, Listener) {
        'use strict'; //need to know if tags should be a local or global variable
        var ALL_TAGS_DATA = {};
        var TaggerAggregator = Events.extend(Listener, {
            _uwaClassName: 'TaggerAggregator',
            init: function init(tnProxy) {
                this.tnProxy = tnProxy;
                this.listenTo(tnProxy, 'onFilterSubjectsChange', this.filterSubjectsChangeListener);
            },
            /**
             * function to redirect event to actual proxy from taggerAggrregator
             * filter example "OnFilterSubjectsChange":
               {
                 "filteredSubjectList": [
                      'subject-1-uri',
                      'subject-2-uri'
                  ]
               }
             */
            filterSubjectsChangeListener: function onFilterSubjectsChange() {
                this.dispatchEvent('onFilterSubjectsChange', arguments);
            },
            /**
             * builds the tagger datastructure and sends it to the tnproxy
             * @param {Object} taggerData the return from our tagger service
             * @param {String} taskTypeFlag the source of the tags
             */
            setSubjectsTags: function(taggerData, taskTypeFlag) {
                var mergedTaggerData = taskTypeFlag && this.mergeTags(taggerData, taskTypeFlag);
                if (this.tnProxy) {
                    //send to the proxy
                    this.tnProxy.setSubjectsTags(mergedTaggerData);
                }
            },
            addSubjectsTags: function addSubjectsTags(taggerData, taskTypeFlag) {
                // merge the old tags with the new ones we want to add
                ALL_TAGS_DATA[taskTypeFlag] = UWA.merge(ALL_TAGS_DATA[taskTypeFlag], taggerData);
                this.tnProxy.addSubjectsTags.apply(this.tnProxy, arguments);
            },
            /**
             * function to merge the ER and RDF tags
             * @param  {Object} taggerData   tags list
             * @param  {String} taskTypeFlag string to indicate its a foundation or rdf implicit/explicit tag
             * @return {Object}               merged tags
             */
            mergeTags: function(taggerData, taskTypeFlag) {
                var mergedTags = {};
                ALL_TAGS_DATA[taskTypeFlag] = taggerData;
                // merge rdf/foundation tags
                var keys = Object.keys(ALL_TAGS_DATA);
                var lNbKeys = keys.length;
                for (var idx = 0; idx < lNbKeys; idx++) {
                    var lTagsToMerge = ALL_TAGS_DATA[keys[idx]];
                    var lObjectIds = Object.keys(lTagsToMerge);
                    var lNbIds = lObjectIds.length;
                    for (var lCurIdIdx = 0; lCurIdIdx < lNbIds; lCurIdIdx++) {
                        var lCurId = lObjectIds[lCurIdIdx];
                        var lMergedTagsForCurId = mergedTags[lCurId];
                        if (!lMergedTagsForCurId) {
                            lMergedTagsForCurId = [];
                            mergedTags[lCurId] = lMergedTagsForCurId;
                        }
                        var lCurTagsToMergeForCurId = lTagsToMerge[lCurId];
                        // its an ER task
                        if (lCurId.indexOf('pid') !== -1) {
                            this.addTypeForERTag(lCurTagsToMergeForCurId);
                        }
                        lMergedTagsForCurId.push.apply(lMergedTagsForCurId, lCurTagsToMergeForCurId);
                    }
                }
                return mergedTags;
            },
            /**
             * function to add type of the field info to the ER tasks
             * @param  {Object} tags list of tags on a task
             */
            addTypeForERTag: function(tags) {
                for (var iTagIdx = 0; iTagIdx < tags.length; iTagIdx++) {
                    var tag = tags[iTagIdx];
                    var sixw = tag.sixw;
                    var objectValue = tag.object;
                    var regexp = /\d\d\d\d\/\d\d\/\d\d/;
                    // checking if this field is a date
                    if (sixw.indexOf('ds6w:when') !== -1 && regexp.exec(objectValue)) {
                        tag.type = 'date';
                    }
                }
            },
            emptyExistingTags: function() {
                // may be it should be this.ALL_TAGS_DATA = {};
                ALL_TAGS_DATA = {};
                this.tnProxy.setSubjectsTags({});
            },
            destroy: function() {
                this.stopListening();
                delete this.tnProxy;
            },
            die: function die() {
                this.tnProxy && this.tnProxy.die();
                this.destroy();
            },
            focusOnSubjects: function focusOnSubjects() {
                this.tnProxy.focusOnSubjects.apply(this.tnProxy, arguments);
            },
            unfocus: function unfocus() {
                this.tnProxy.unfocus.apply(this.tnProxy, arguments);
            },
            deactivate: function deactivate() {
                this.tnProxy.deactivate.apply(this.tnProxy, arguments);
            },
            activate: function deactivate() {
                this.tnProxy.activate.apply(this.tnProxy, arguments);
            },
            unsetTags: function() {
                this.tnProxy.unsetTags();
            }
        });
        TaggerAggregator.ALL_TAGS_DATA = ALL_TAGS_DATA;
        return TaggerAggregator;
    });

/*global define*/
define(
    'DS/Foundation2/TNProxyFilterOnServerHelper', ['UWA/Core', 'UWA/Class/Events', 'UWA/Class/Listener', 'DS/Foundation2/TaggerAggregator'],
    function(UWA, Events, Listener, TaggerAggregator) {
        'use strict'; //need to know if tags should be a local or global variable
        var TNProxyFilterOnServerHelper = TaggerAggregator.extend(Listener, {
            _uwaClassName: 'TNProxyFilterOnServerHelper',
            init: function init(tnProxy) {
                this.tnProxy = tnProxy;
                this.listenTo(tnProxy, 'onFilterChange', this.filterChangeListener);
            },
            /**
             * function to redirect event to actual proxy from taggerAggrregator
             * filter example "OnFilterChange":
               {
                  "allfilters": {
                      "ds6w:when/ds6w:starts": [
                          {
                              "object": "2013",
                              "type": "date"
                          }
                      ]
                  }
               }
             */
            filterChangeListener: function onFilterSubjectsChange() {
                this.dispatchEvent('onFilterChange', arguments);
            },
            /**
             * builds the tagger datastructure and sends it to the tnproxy
             * @param {Object} tagsdata Object json that represents the association between subjects and their 6WTags. (Set this parameter only if you want tag authoring.)
             * @param {Array} summaryData Summary of existing 6WTags
             */
            setTags: function(tagsdata, summaryData) {
                if (this.tnProxy) {
                    //send to the proxy
                    this.tnProxy.setTags(tagsdata, summaryData);
                }
            },
            emptyExistingTags: function() {
                this.tnProxy.setTags({}, []);
            }
        });
        return TNProxyFilterOnServerHelper;
    });

/*global define*/
define('DS/Foundation2/Models/FoundationV2Model', ['UWA/Core', 'UWA/Class/Model', //UWA Prereqs
        'DS/Foundation2/FoundationV2Data', 'DS/E6WCommonUI/UIHelper'
    ],
    /**
     * @module Foundation2/Models/FoundationV2Model
     *
     * @require UWA/Core
     * @require UWA/Class/Model
     *
     * @extend UWA/Class/Model
     *
     */

    function(UWA, Model, //eslint-disable-line strict
        FoundationV2Data, UIHelper) {
        ''; //bypass so minifier doesn't delete the 'use strict'
        'use strict';
        var FoundationData = FoundationV2Data;
        var basics = ['id', 'type', 'tempId', 'cestamp', 'service', 'tenant'];
        var FoundationV2Model = Model.extend({
            _uwaClassName: 'FoundationV2Model',

            defaults: {},
            /**
             * retrieve the data originally sent for this model.
             * this will follow the backpointers to the root.
             * can return undefined if there is no _rowObjects or if they don't have backpointers
             * @param {Object} iRowObject row object
             * @return {Object} in memory data
             */
            getInMemoryData: function(iRowObject) {
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
                        return lCurrentObject._parentRecords._container;
                    }
                }
                return undefined;
            },
            /**
             * translate the Foundation objects to a json object more compatible with UWA/Class/Model.
             * we will assume with have a FoundationObject if witgetType is set to datagroup
             * @param {Object} iJSON the input from the constructor
             * @param {Object} options options
             */
            init: function FoundationBaseModelConstructor(iJSON, options) {
                var args = Array.prototype.slice.call(arguments, 0);
                //overriding the constructor will let us translate arguments which are in the Foundation services format to our simpler format
                if (iJSON && iJSON.dataelements && !(options && options.parse)) {
                    this.collection = options && options.collection;
                    var modelJSON = this.parse(iJSON);
                    args[0] = modelJSON;
                }
                Object.defineProperty(this, 'csrf', {
                    get: function() {
                        var lInMemoryData = this.getInMemoryData();
                        if (lInMemoryData && lInMemoryData.csrf) {
                            return lInMemoryData.csrf;
                        }
                        //last ditch effort
                        return this.collection && this.collection._csrf;
                    }
                });
                this._parent.apply(this, args);

            },
            setup: function FoundationBaseModelSetup(iJSON, options) {
                //          var that = this;
                if (options && options.existingObject) {
                    this.existingObject = true;
                }

                this._parent.apply(this, arguments);

            },
            parse: function(response) {
                var args = Array.prototype.slice.call(arguments, 0);
                if (response && response.dataelements) {
                    if (!this._rowObjects) {
                        this._rowObjects = [response];
                        var lInMemoryData = this.getInMemoryData();
                        if (lInMemoryData) {
                            this.urlRoot = FoundationData._serviceURL(lInMemoryData._serviceName);
                        }
                    } else {
                        if (this._rowObjects.indexOf(response) === -1) {
                            this._rowObjects.push(response);
                        }
                    }
                    FoundationData._setInternalProperty(response, '_mvcModel', this);
                    var modelJSON = this.convertFromFoundationToMVC(response);
                    args[0] = modelJSON;
                }
                return this._parent.apply(this, args);
            },
            /**
             * basics are already in the correct format.
             * need to remove the dataelements part and remove the array which is around each dataelement
             * also remove the relateddata and children which are treated separately
             * @param {Object} iData data
             * @return {Object} converted data
             */
            convertFromFoundationToMVC: function(iData) {
                var lData = {}; //UWA.clone(iData, false);
                var lDataElements = iData.dataelements;
                //                 delete lData.dataelements;
                //                 delete lData.children;
                //                 delete lData.relateddata;
                //keep the other keys such as id, cestamp, type
                basics.forEach(function(iCurName) {
                    var curValue = iData[iCurName];
                    if (typeof curValue !== 'undefined') {
                        lData[iCurName] = curValue;
                    }

                });
                //copy the dataelements
                var lKeys = Object.keys(lDataElements);
                var lNbKeys = lKeys.length;
                var lInMemoryData = this.getInMemoryData();
                var lFieldsDef = lInMemoryData && lInMemoryData.getAllFields();
                lFieldsDef = lFieldsDef || {};
                for (var lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                    var lCurKey = lKeys[lCurKeyIdx];
                    var lCurVal = lDataElements[lCurKey];
                    //for now assume we don't have multivalued attributes (partial support only meaning a potentially multivalued attribute with a single value will not be shown as an array)

                    //                     switch (lCurVal.length) {
                    //                     case 0:
                    //                         lCurVal = undefined;
                    //                         break;
                    //                     case 1:
                    //                         lCurVal = lCurVal[0];
                    //                         break;
                    //                     }
                    //check for necessary conversions

                    var lFieldDef = lFieldsDef[lCurKey];
                    if (lFieldDef) {
                        if (lFieldDef.format === 'UTC' && lCurVal) {
                            lCurVal = new Date(lCurVal);
                            lDataElements[lCurKey] = lCurVal.toISOString(); //set date back in case of date without time zone.
                        } else if (lFieldDef.format === 'date') {
                            lCurVal = new Date(parseInt(lCurVal, 10));
                        }
                    }
                    lData[lCurKey] = lCurVal;
                }
                return lData;
            },
            /**
             * Handle related data
             * @override
             * @param {String} iAttrName attribute
             */
            get: function FoundationBaseModelGet(iAttrName) {
                //are we asking for children?
                var getResultFromRowObjectArray = function(iChildRowObjects, iCollection, iModelConstructor) {
                    var lRet = [];
                    var lNbChildRowObjects = iChildRowObjects.length;
                    for (var lCurChildRowObjectsIdx = 0; lCurChildRowObjectsIdx < lNbChildRowObjects; lCurChildRowObjectsIdx++) {
                        var lCurChildRowObject = iChildRowObjects[lCurChildRowObjectsIdx];
                        var lCurUpdateAction = lCurChildRowObject.updateAction || lCurChildRowObject.updateActionPending;
                        if (lCurUpdateAction === 'DISCONNECT' || lCurUpdateAction === 'DELETE') {
                            //objects are in the process of being removed from the structure, do not count them in
                            continue;
                        }
                        if (!lCurChildRowObject._mvcModel) {
                            //convert the child
                            // var lJSONForMVC =this.convertFromFoundationToMVC(lCurChildRowObject);
                            var lMVCModel;
                            if (iCollection) {
                                //bcc: important to merge as now Foundation services can be set to optimize the data returned by returning multi instantiated objects once fully and for all other
                                //instance abbreviated
                                lMVCModel = iCollection.add(lCurChildRowObject, {
                                    merge: true,
                                    parse: true
                                });
                                //if the child existed already it will be found in the collection and not attached to the rowObject
                                //this is a case of multiple instance of the same model in one structure.  relId will be incorrect.  Need to review this later
                                if (lMVCModel && !lCurChildRowObject._mvcModel) {
                                    FoundationData._setInternalProperty(lCurChildRowObject, '_mvcModel', lMVCModel);
                                }
                            } else { //should this really happen?
                                var ModelConstructor = iModelConstructor || FoundationV2Model;
                                lMVCModel = new ModelConstructor(lCurChildRowObject); //the constructor will actually valuate lCurChildRowObject._mvcModel
                                //as a side effect which is why we won't need to use lMVCModel
                            }

                        }
                        //_mvcModel should now have a value
                        lRet.push(lCurChildRowObject._mvcModel);

                    }
                    return lRet;
                };
                if (iAttrName === 'children' && this._rowObjects && this._rowObjects.length) {
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
                    //in V2 relatedData which have default true will always show up as empty array
                    //TODO treat the optional relateddata
                    //relations are explicitly declared so we can return an empty array
                    //for a valid relation which is not present in the dataset
                    //this should be done based on the definition in the future
                    var lRelation;
                    if (this._relations) {
                        lRelation = this._relations.detect(function(iCurRelation) {
                            return iCurRelation.key === iAttrName;
                        });
                    }
                    var lRet = [];
                    if (this._rowObjects && this._rowObjects.length) {
                        var lRelatedDataRowObjects = FoundationData.getRelatedObjects(this._rowObjects[0], iAttrName);
                        var lRelatedDataCollection = this.collection && this.collection.getChildCollection && this.collection.getChildCollection(iAttrName);
                        if (lRelatedDataRowObjects) {
                            lRet = getResultFromRowObjectArray(lRelatedDataRowObjects, lRelatedDataCollection);
                            lRet.relationshipName = iAttrName;
                            return lRet;
                        }
                    }
                    //check if we have a relationship defined with this name in which case we should return an empty array
                    if (this._relations) {
                        lRelation = this._relations.detect(function(iCurRelation) {
                            return iCurRelation.key === iAttrName;
                        });
                        if (lRelation) {
                            //we can be in this case either if there are no rowObjects or if we didn't return the related data as
                            //part of the row object
                            return lRet;
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
             * @override
             * Model.isNew is based on the presence of an id.  Since we want to be able to add existing objects for which we don't know the id (case of assigneesByName)
             * one can explicitly set on an object that it is not new.
             * @return {boolean} is object new
             */
            isNew: function() {
                return !this.existingObject && this._parent.apply(this, arguments);
            },

            convertToFoundationFields: function(iDataElements) {
                var dataelements = iDataElements ||
                    this.convertToFoundation(this.id).dataelements; //passing this.id to convertToFoundation so when the object has an id
                //only modified fields are used but when there are no ids all are used
                //the expected format is an array of fields
                var hasOwn = Object.prototype.hasOwnProperty;
                var ret = [];

                for (var key in dataelements) {

                    if (hasOwn.call(dataelements, key)) {

                        var value = dataelements[key];



                        //                    if (value === undefined || value._isCollection) {
                        //                        continue;
                        //                    }
                        var fieldObject = {
                            name: key
                        };
                        if (UWA.is(value, 'number')) { //TODO shouldn't that be in convertToFoundation
                            value = value.toString(10);
                        }
                        fieldObject.value = value;
                        ret.push(fieldObject);

                    }
                }
                return ret;
            },
            /**
             * update a model in the foundation in memory structure depending on what was done to it.
             * set the _rowObjects variable on the model in case of a create
             * @param {String} iMethod method
             * @return {Data} row object
             */
            updateModelInFoundation: function(iMethod /*, options*/ ) {
                // var that = this;

                var lFoundationData = this.convertToFoundationFields(); //this only contains the basics and datalements

                var lRowObjects = this._rowObjects;
                //use the first rowObject
                var lModelOrId = (lRowObjects && lRowObjects.length) ? lRowObjects[0] : this.id; //truly if there are no row objects there shouldn't be an id
                //we should not try to apply the change multiple times, some would work (update) but some wouldn't
                //we need when the server sends back the success to update all the instances though.
                var lActualMethod = iMethod === 'create' && lRowObjects && lRowObjects.length ? 'update' : iMethod; //in case of several calls to create just update the attributes
                //this can happen if we do a save on an object which is new and on which related data were added.
                //when adding related data on a new object we update the foundation data, however the object isn't really
                //saved yet and will still look like new to backbone
                var lRowObject; //the object coming back from foundation
                var lInMemoryData = this.getInMemoryData();
                if (lInMemoryData) {
                    switch (lActualMethod) {
                        case 'create':
                            //create is supposed to be a real creation, we add the object to foundation and we will initiate _rowObjects
                            lRowObject = lInMemoryData.addObject(null, lFoundationData);
                            this._rowObjects = [lRowObject]; //there will not be already one thanks to our switch from create to update
                            FoundationData._setInternalProperty(lRowObject, '_mvcModel', this);
                            break;
                        case 'update':
                            //really no difference between the 2 we always send only the changes at the foundation level
                        case 'patch':
                            lRowObject = lInMemoryData.modifyObject(lModelOrId, lFoundationData);

                            break;
                        case 'delete':
                            if (lRowObjects && lRowObjects.length) {
                                //get the first _rowObject
                                lRowObject = lRowObjects[0];
                                //check if it is a related data or a child
                                //                        if (lRowObject._relationship && lRowObject._relationshipParentObject) {
                                //                            //need to delete a related data
                                //                            rowObject = FoundationData.deleteRelatedObject(lInMemoryData,
                                //lRowObject._relationship, lRowObject._relationshipParentObject /*id or object*/ , lRowObject);
                                //                        } else  {
                                lRowObject = lInMemoryData.deleteObject(lRowObject);
                                //      }
                                for (var lCurRowObjectIdx = 1, len = lRowObjects.length; lCurRowObjectIdx < len; lCurRowObjectIdx++) {
                                    //remove
                                    lRowObject = lRowObjects[lCurRowObjectIdx];
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
                                lRowObject = FoundationData.deleteObject(lInMemoryData, lModelOrId);
                            }
                            break;
                        default:
                            break;
                    }
                }
                return lRowObject;
            },
            /**
             * sync this object with the version of the same object coming from the server.
             * @param {Object} data the response from the server to sync
             */
            syncFromServer: function(data) {
                //  this;
                //retrieve the datagroup
                var lRowObject = FoundationData.getObject(data, this.id);
                var lInMemoryData = this.getInMemoryData();
                if (lRowObject) {
                    //update our object with the corresponding information.
                    //2 cases:
                    //1) we already have some rowObjects.  Sync them
                    if (this._rowObjects && this._rowObjects[0] && lInMemoryData) { //should we really sync all! no just use the first one
                        //bcc: bellow code to sync every one of them to be removed when we are sure we don't need it
                        //                	 var lNbRowObjects = this._rowObjects.length;
                        //                     for (var lCurRowObjectIdx = 0; lCurRowObjectIdx < lNbRowObjects; lCurRowObjectIdx++) {
                        //                         var lCurRowObject = this._rowObjects[lCurRowObjectIdx];
                        //                         if (lRowObject) {
                        //                             FoundationData.__synchronizeSourceObjectFromServerObject(lInMemoryData, lRowObject, lCurRowObject, true);
                        //                         }
                        //
                        //                     }
                        FoundationData.__synchronizeSourceObjectFromServerObject(lInMemoryData, lRowObject, this._rowObjects[0], true);
                    } else { //2) we don't have a rowObject
                        // the object we got will become our rowObject.  What is tricky is how we add it back to the foundation data structure
                        this._rowObjects = [lRowObject]; //need to make sure this object is not considered to be connected yet
                        if (lRowObject) {
                            delete lRowObject._parentObject;
                            delete lRowObject._relationshipParentObject;
                            delete lRowObject._parentRecords;
                        }
                        //TODO somehow need to reconnect the object (through the collection?)
                        this.applyUpdatesFromServer();
                    }
                }

                if (lInMemoryData) {
                    FoundationData.__updateCsrf(lInMemoryData, data);
                }

            },
            syncRead: function(inMemoryData, iServiceName, options) {
                var urlParam = options && options.urlParam;
                var lInMemoryData = inMemoryData;
                var lServiceName = iServiceName || (lInMemoryData && lInMemoryData._serviceName); //if no memory data need to pass in the service name, passed in value takes precedence
                var lPhysicalId = this.id;
                lServiceName += '/' + lPhysicalId;
                FoundationData.loadServiceData(lServiceName, this.syncFromServer.bind(this), undefined, undefined, undefined, urlParam);
            },
            sync: function(method, object, options) {
                var lOptions = UWA.clone(options || {}, false);
                var lInMemoryData = this.getInMemoryData();
                if (!lInMemoryData) { //nice and sweet but should it happen?
                    //add attrs which will be the Foundation serialization to the options
                    var args = Array.prototype.slice.call(arguments, 0);
                    lOptions.attrs = object.convertToFoundation();
                    var ajax = this.ajax || (this.collection && this.collection.ajax);
                    lOptions.ajax = ajax;
                    args[2] = lOptions; //replace the 3rd argument, options
                    this._parent.apply(this, args);
                } else {
                    var onComplete = options.onComplete;
                    lOptions.onComplete = function( /*rowObject, data*/ ) {
                        if (onComplete) {
                            onComplete.apply(this, arguments);
                        }
                    };
                    if (method === 'read') {
                        this.syncRead(lInMemoryData);
                    } else if (method === 'create' || method === 'update' || method === 'patch' || method === 'delete') {

                        lOptions = this._setupOptionsForSync(method, lInMemoryData, lOptions);
                        //now do something for truth
                        var rowObject = this.updateModelInFoundation(method, this, options);

                        var applyUpdatesCallback = function applyUpdatesCallback(success, lInMemoryData, clonedInfo) {
                            if (success) { //bcc: code below may not be needed anymore as the sync from foundation would have updated the models
                                //rowObject should have been updated, send it to the callback which should in turn call the model's parse
                                if (options && options.onComplete) {
                                    options.onComplete(rowObject, lInMemoryData, options);
                                }
                            } else {
                                options.clonedInfo = clonedInfo;
                                options.onFailure(rowObject, lInMemoryData, options); //TODO put the real error message
                            }
                        };

                        if (!options.delayedSave) {
                            if (lInMemoryData) {
                                FoundationData.applyUpdates(lInMemoryData, applyUpdatesCallback, false); //for now save everything, we will see about the saveId later
                            }
                        }
                    }
                }
            },
            _setupOptionsForSync: function(method, inMemoryData, options) {
                var that = this;
                var lOptions = UWA.clone(options, false);
                var onFailure = options.onFailure;
                switch (method) {
                    case 'create':
                        lOptions.onFailure = function( /*rowObject, data*/ ) {
                            FoundationData.rollbackFailedData(inMemoryData);
                            that.destroy({
                                localOnly: true
                            });

                            if (onFailure) {
                                onFailure.apply(this, arguments);
                            }
                        };
                        break;
                    case 'update':
                    case 'patch':
                        lOptions.onFailure = function(rowObject /*, dataFromServer, options*/ ) {
                            //restore the objects in data
                            FoundationData.rollbackFailedData(inMemoryData);

                            //restore the object based on its now canceled rowObject
                            //we could use the changedAttributes and previousAttributes from UWA/Model but for now I prefer to use the Foundation data as a reference
                            //also if this makes for too brutal a UI refresh we can set only those attributes which were modified and can be retrieved using
                            //that.changedAttributes()
                            var modelJSON = that.convertFromFoundationToMVC(rowObject);
                            that.set(modelJSON);
                            if (onFailure) {
                                onFailure.apply(this, arguments);
                            }
                        };
                        break;
                    case 'delete':
                        //store the collection in another variable for future reinsertion in case of error
                        var collectionBeforeDelete = this.collection;
                        lOptions.onFailure = function( /*rowObject, data*/ ) {
                            FoundationData.rollbackFailedData(inMemoryData);

                            //add back to the collection
                            //bug in UWA prevents the onAdd event from being called.
                            //we will call it manually if it ends up being needed.
                            //it actually happens only on some cases, in particular delete a model fails, is rolledback then delete again
                            if (collectionBeforeDelete) {
                                collectionBeforeDelete.push(that);

                                if (onFailure) {
                                    onFailure.apply(this, arguments);
                                }

                            }
                        };
                        break;
                    default:
                        break;
                }
                return lOptions;
            },
            /**
             * received an updated rowObject.
             * make sure it is taken into account
             * @param {Object} rowObject  the data to apply. optional, if not present will use _rowObjects[0]
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
            /**
             * convert to the format needed by foundation
             * @param {Boolean} iOnlyUpdated only updated
             * @return {Object} converted data
             */
            convertToFoundation: function(iOnlyUpdated) {
                var lDataElements = this.toJSON({
                    noRelatedData: true,
                    onlyUpdated: iOnlyUpdated
                });
                //put the dateelements and the basics in their places
                var lKeys = Object.keys(lDataElements);
                var lNbKeys = lKeys.length;

                var lRet = {};
                var lInMemoryData = this.getInMemoryData();
                var lFieldsDef;
                if (lInMemoryData) {
                    lFieldsDef = lInMemoryData.getAllFields();
                }
                for (var lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                    var lCurKey = lKeys[lCurKeyIdx];
                    var lCurVal = lDataElements[lCurKey];

                    if (basics.indexOf(lCurKey) === -1) {
                        lDataElements[lCurKey] = lCurVal;
                    } else {
                        lRet[lCurKey] = lCurVal;
                        delete lDataElements[lCurKey];
                    }

                    if (lCurVal instanceof Date) {
                        //get the format

                        var lCurField = lFieldsDef[lCurKey];
                        if (lCurField && lCurField.format === 'date') { //assume UTC but support date
                            lDataElements[lCurKey] = lCurVal.getTime().toString();
                        }

                    }
                }
                lRet.dataelements = lDataElements;
                //is it really needed
                //          if (!options.noRelatedData) {
                //             //TODO need to add the children and the related data
                //             //easy with a row object
                //          }
                return lRet;
            },
            /**
             * function to get attributes presnt in basics list of this object
             * @return {Object} attribute list
             */
            getBasicsData: function() {
                var lAttributes = this.toJSON();
                //put the dateelements and the basics in their places
                var lKeys = Object.keys(lAttributes);
                var lNbKeys = lKeys.length;
                var lRet = {};
                for (var lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                    var lCurKey = lKeys[lCurKeyIdx];
                    var lCurVal = lAttributes[lCurKey];
                    if (basics.indexOf(lCurKey) !== -1) {
                        lRet[lCurKey] = lCurVal;
                    }
                }
                return lRet;
            },
            /**
             * make FoundationData.ajaxRequest have the same signature as UWA.Data.Request
             * @param {String} url url
             * @param {Object} options options
             * @return {Object} ajax request object
             */
            ajax: function(url, options) {
                var ajaxRequestObject = UWA.clone(options, false);
                delete ajaxRequestObject.ajax; //this is the current method not needed...
                ajaxRequestObject.url = url;
                ajaxRequestObject.dataType = options.type;
                ajaxRequestObject.type = options.method;
                delete options.method;
                ajaxRequestObject.data = options.data;
                ajaxRequestObject.callback = options.onComplete;
                return FoundationV2Data.ajaxRequest(ajaxRequestObject);

            },
            dateForJSON: function(iAttributeName, iAttributeValue, iFieldsDef, iOptions) {
                var lFormat = iFieldsDef && iFieldsDef[iAttributeName] && iFieldsDef[iAttributeName].format;
                return UIHelper.dateForJSON(iAttributeValue, lFormat, this.dateHelper, iOptions);
            },
            /**
             * override the toJSON  method
             * @param {Object} options if this contains noRelatedData:true  then related data won't be added
             * @return {Object} json data for object
             */
            toJSON: function(options) {

                var lRet;
                var that = this;
                var lInMemoryData = this.getInMemoryData();
                var lFieldsDef = lInMemoryData && lInMemoryData.getAllFields();
                var lCurKeyIdx, lCurKey, lCurVal, lKeys, lNbKeys;
                lFieldsDef = lFieldsDef || {};
                if (options && options.onlyUpdated && !this.isNew()) { //for new objects all attributes are updated
                    //changedAttributes does not really work if not passed what was the previous set of value.
                    //fortunately we have that in the form of the row object dataelements
                    var dataelements = this._rowObjects && this._rowObjects[0] && this._rowObjects[0].dataelements;
                    if (dataelements) {
                        var keys = this.keys();
                        lNbKeys = keys.length;
                        lRet = {};
                        for (lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                            lCurKey = keys[lCurKeyIdx];
                            lCurVal = this.get(lCurKey);
                            if (lCurVal instanceof Date) {
                                lCurVal = this.dateForJSON(lCurKey, lCurVal, lFieldsDef, {}); //force no data for rendering so that the check for changes
                                //is done based on json
                            }
                            if (!UWA.equals(lCurVal, dataelements[lCurKey]) && basics.indexOf(lCurKey) === -1) {
                                lRet[lCurKey] = lCurVal;
                            }

                        }
                    } else {
                        lRet = Model.prototype.toJSON.call(this);
                    }


                    //add the basics
                    basics.forEach(function(iCurName) {
                        var curValue = that.get(iCurName);
                        if (typeof curValue !== 'undefined') {
                            lRet[iCurName] = curValue;
                        }

                    });
                } else {
                    lRet = this._parent.apply(this, arguments);
                }
                var lOptions = options || {};

                lKeys = Object.keys(lRet);
                lNbKeys = lKeys.length;

                for (lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                    lCurKey = lKeys[lCurKeyIdx];
                    lCurVal = lRet[lCurKey];
                    if (lCurVal instanceof Model) { //case for dependencies
                        var lFoundationData;
                        if (lCurVal._rowObjects && lCurVal._rowObjects.length) {
                            lFoundationData = lCurVal._rowObjects[0];
                        }
                        lRet[lCurKey] = lFoundationData;
                    } else if (lCurVal instanceof Date) {
                        lRet[lCurKey] = lCurVal = this.dateForJSON(lCurKey, lCurVal, lFieldsDef, options);
                    }

                }
                //bcc: should we add children?  there is a potential for uselessly deep recursion.  Already with related data...
                if (!lOptions.noRelatedData) {
                    //add the related data
                    if (this._rowObjects && this._rowObjects.length) {
                        lKeys = this.getRelationsNames();
                        lNbKeys = lKeys.length;
                        for (lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                            lCurKey = lKeys[lCurKeyIdx];
                            var lRelatedData = this.get(lCurKey); //this is an array of model which each should be jsonified
                            var lConvertedRelatedData = [];
                            var lNbRelatedData = lRelatedData.length;
                            for (var lCurRelatedDataIdx = 0; lCurRelatedDataIdx < lNbRelatedData; lCurRelatedDataIdx++) {
                                var lCurRelatedDataObject = lRelatedData[lCurRelatedDataIdx];
                                var lCurJSON = options && options.dataForRendering ? lCurRelatedDataObject.dataForRendering(options) : lCurRelatedDataObject.toJSON(options);

                                lConvertedRelatedData.push(lCurJSON);
                            }
                            lRet[lCurKey] = lConvertedRelatedData;
                        }
                    }
                }
                return lRet;

            },
            getRelationsNames: function functionName() {
                var lKeys = FoundationData.getRelatedDataNames(this._rowObjects[0]);
                return lKeys;
            },
            dataForRendering: function() {
                return this.toJSON({
                    dataForRendering: true
                });
            },
            _fireRelationshipChangeEvents: function(iRelationshipName, options, iOnlyRelation, iNoRelation) {
                if (!iNoRelation) {
                    this.dispatchEvent('onChange:' + iRelationshipName, [this, options]);

                }
                if (!iOnlyRelation) {
                    var lOptions = UWA.clone(options || {}, false);
                    lOptions.relationshipChanged = iRelationshipName;
                    this.dispatchEvent('onChange', [this, lOptions]);
                }

            },
            set: function() {
                var args = UIHelper.setHelper.apply(this, arguments);
                var attrs = args.attrs;


                if (attrs) {
                    //now we have the {key: value} style arguments
                    var lKeys = Object.keys(attrs);
                    var lNbKeys = lKeys.length;
                    var lInMemoryData = this.getInMemoryData();
                    var lFieldsDef = lInMemoryData && lInMemoryData.getAllFields && lInMemoryData.getAllFields();
                    lFieldsDef = lFieldsDef || {};
                    for (var lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
                        var lCurKey = lKeys[lCurKeyIdx];
                        var lCurDef = lFieldsDef[lCurKey];
                        if (lCurDef && lCurDef.format && (lCurDef.format === 'UTC' || lCurDef.format === 'date')) {
                            var lCurVal = attrs[lCurKey];
                            if (UWA.is(lCurVal, 'number')) {
                                //make a date
                                attrs[lCurKey] = new Date(lCurVal);
                            }
                        }
                    }
                }
                return this._parent(attrs, args.options);
            },
            getCustomFields: function() {
                var lInMemoryData = this.getInMemoryData();
                return lInMemoryData.getCustomFields();
            }
        });



        return FoundationV2Model;
    });

/*global define*/
/**
 * @module Foundation2/Collections/FoundationV2Collection
 *  define a base class for foundation collections.  
 * @require UWA/Core
 * @require UWA/Class/Collection
 */
define('DS/Foundation2/Collections/FoundationV2Collection', //define module 
['UWA/Core', 'UWA/Class/Collection', 'UWA/Class/Model', 'DS/Foundation2/Models/FoundationV2Model'], //prereqs 

function (UWA, Collection, Model, FoundationV2Model) {
    'use strict';
    var FoundationV2Collection = Collection.extend({
        _uwaClassName: 'FoundationV2Collection',

        // Reference to this collection's model.
        model: FoundationV2Model,

        /**
         * override setup:
         */
        setup: function FoundationV2CollectionSetup(models, options) {
            if (options) {
                this._serviceName = options.serviceName;
                this.url = '/resources/v2/e6w/service/' + this._serviceName;
                this._dictionary = options.dictionary;
                this._objectType = options.objectType;
                
            }
            if (!this._dictionary) {
        	this._dictionary = {};
            }
            if (this._objectType) {
        	this._dictionary[this._objectType] = this;  //last one wins
            }
            return this._parent.apply(this, arguments);
        },
        /**
         * get the dictionary (which is mapping object types to collection)
         */
        getDictionary: function (){
            return this._dictionary;
        },
        /**
         * translate the Foundation objects to a json object more compatible with UWA/Class/Model.
         * we will assume with have a FoundationObject if widgetType is set to datagroup
         * @param {Object} iJSON the input from the constructor
         */
        init: function FoundationV2CollectionConstructor(iJSON, options) {
            var args = Array.prototype.slice.call(arguments, 0);
            //overriding the constructor will let us translate arguments which are in the Foundation services format to our simpler format
            if (iJSON && iJSON.data && !(options && options.parse)) {
                var modelJSON = this.parse(iJSON);
                args[0] = modelJSON;
            }
            this._parent.apply(this, args);

        },
        parse: function (response) {
            var args = Array.prototype.slice.call(arguments, 0);
            if (response && response.data) {
                //for now stick the relatedData in an internal attribute
                this._csrf = response.csrf;
                this._definition = response.definition;
                args[0] = response.data;

            }

            return this._parent.apply(this, args);
        },
        sync: function (method, model, options) {
            var lOptions = UWA.clone(options, false);
            lOptions.ajax = this.ajax || this.model.prototype.ajax;
            return this._parent.call(this, method, model, lOptions);
        }
    });
    return FoundationV2Collection;
});

/*global define, require*/
define('DS/Foundation2/Models/FoundationBaseModel', ['UWA/Core', 'UWA/Class/Model', 'UWA/Class/Collection', //UWA Prereqs
        'DS/Foundation2/FoundationV2Data', 'DS/Foundation2/Models/FoundationV2Model'
    ],
    /**
     * @module Foundation2/Models/FoundationBaseModel
     * this is building upon FoundationV2Model but it adds more related data support and relies on the collection for the sync.
     * @require UWA/Core
     * @require UWA/Class/Model
     *
     * @extend UWA/Class/Model
     * we are keeping a backpointer toward the foundation rowObject (_rowObjects) this is a multi-instanciated object
     */

    function(UWA, Model, Collection, FoundationData, FoundationV2Model) {
        'use strict';
        var FoundationBaseModel = FoundationV2Model.extend({
            _uwaClassName: 'DS/Foundation2/Models/FoundationBaseModel',

            getInMemoryData: function() {
                var data = this.collection && this.collection.data && this.collection.data();
                return data || this._parent.apply(this, arguments);
            },
            getTagPrefix: function(){
              return 'pid://';
            },

            /**
             * remove a related data model by index.
             * @param iAttributeName:  name of the attribute to remove the model from
             * @param iToRemove: index of the model to remove or the model itself
             * @return the removed model
             */
            removeObject: function(iAttributeName, iToRemove) {
                var lModelToRemove;
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

                var data = this.collection.data();
                //remove from the first rowObject, otherwise we would be sending multiple calls to the server.
                //we need to make sure to remove the correct row object
                var lRowObject = this._rowObjects[0];
                //for the current row object find the instance that we want to remove
                var lRelatedObjects = FoundationData.getRelatedObjects(lRowObject, iAttributeName);
                var lNbRelatedObjects = lRelatedObjects.length;
                //bcc: why not look at the lModelToRemove.id directly.  Why the monkeying with the rowObjects, is it for relId purpose?  If it is the code is wrong.
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

                    return lModelToRemove;

                }
            },
            /**
             * update the related objects to take into account newly connected object when the addition was done from server side.
             * this will add the object to the underlying foundation data but it will not mark it as needing to be connected.
             * which means that even after saving no order will be sent to the server to connect it.
             * normally used if an unrelated service call returned information which lets us know that a new object was added server side
             * @param iObject object to add, this should be a row object
             * @param iRelationshipName the relationship to use
             * @return the added object
             */
            updateRelatedObjectWithNewEntry: function(iObject, iRelationshipName) {
                var data = this.collection.data();
                var rowObjects = this._rowObjects;
                if (data && rowObjects) {
                    return FoundationData.__addOrConnectObjectToStructure(data, iRelationshipName, rowObjects[0], iObject);
                }
            },
            /**
             * add a related object.
             * this will add the object to the underlying foundation data but it will not save them
             * @param iObject object to add
             * @param iRelationshipName the relationship to use
             * @param options  options to pass down.  In our case we are interested by existingObject which if true will
             * force a connect even if we don't know the model id
             * @return the added object
             */
            addRelatedObject: function(iObject, iRelationshipName, options) {
                //  this should be either a connect or an add depending on whether the object is new or not.
                //handle the case of connect for now
                //the difference between the two should be based on the isNew from the object
                var data = this.collection.data();
                var lAddedRowObject; //the output
                //data could be a json model or an MVCOne
                //case of an MVC model
                if (iObject instanceof Model) {
                    var foundationData;

                    if (data && iRelationshipName) {

                        var rowObjects = this._rowObjects;
                        if (this.isNew()) {
                            if (!rowObjects) { //case where this is the first time we add to the related data for this new object
                                rowObjects = [this.updateModelInFoundation("create")];
                            } else {
                                // the object is still new since it hasn't been successfully saved yet but this is not the first time we are adding a related data to it.
                                // a temp_id was already affected and we need to be careful
                                this.updateModelInFoundation("update");
                            }
                        }

                        if (iObject.isNew() && !(options && options.existingObject) && !(iObject._rowObjects && iObject._rowObjects.length)) {
                            //do an AddRelatedObject
                            //should use the collection from the object to add for the conversion as it will know what are relationship vs attributes
                            foundationData = iObject.convertToFoundationFields();

                            //add to our first rowObject
                            lAddedRowObject = FoundationData.addRelatedObject(data, iRelationshipName, rowObjects[0], foundationData, undefined, iObject);
                        } else {
                            //do a ConnectRelatedObject to our first rowObject
                            var lConnectedObjectId = iObject.id;
                            var lConnectedRowObjects = iObject._rowObjects;
                            var toConnect;
                            if (!lConnectedRowObjects || !lConnectedRowObjects.length) {
                                foundationData = iObject.convertToFoundationFields();
                                toConnect = lConnectedObjectId;
                            } else {
                                toConnect = lConnectedRowObjects[0];
                            }
                            var basicsData;
                            // basics data info(service, tenant) to be sent to server only when service is 3ddrive
                            if (iObject.get('service') === '3DDrive') {
                                basicsData = iObject.getBasicsData();
                            }
                            //only do the connect on one.  by using the Id we do it on the one in the index maybe we should have used the first one in our array
                            lAddedRowObject = FoundationData.connectRelatedObject(data, iRelationshipName, rowObjects[0], toConnect, foundationData, undefined, {
                                additionalAttributes: basicsData
                            });
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
                }
            },
            /**
             * adds objects by relationship name
             * @param iObject object to add
             * @param iRelationshipName the relationship to use
             * @return the new added model
             */
            addNewObject: function(iObject, iRelationshipName, options) {
                var collection = this.collection.getChildCollection(iRelationshipName);
                //TODO check if we are not double firing the event when adding to the collection
                var newModel = collection.add(iObject);
                this.addRelatedObject(newModel, iRelationshipName, options);
                return newModel;
            },
            /**
             * adds objects by id
             * @param {Array} iIds  should be an array of string.  If it is a single string it will be encapsulated as an array.
             *              those should be physical ids, could be another if the iIDAttributeToUse is set
             * @param {String} iAttributeName name of the relateddata attribute to use to add the object
             * @param {String} [iIDAttributeToUse] optional, uses id (physicalid) by default but for assignees uses name
             * @param {Object} [options] the options
             * @param {Array} [options.values] objects actually being added, if this is present the iIds array will be ignored
             * @param {Array} [options.otherObjectAttributes] array of the same size as iIds which will contain objects with the other attributes which need to be initialized
             * @return {Array} the created objects
             */
            addObjects: function(iIds, iAttributeName, iIDAttributeToUse, options) {
                var lIDAttributeToUse = iIDAttributeToUse || "physicalId";
                var lArrayOfObjectIds = iIds;
                var returnValue = [];
                if (UWA.is(lArrayOfObjectIds, "string")) {
                    lArrayOfObjectIds = [iIds];
                }
                var lOptions = UWA.clone(options || {}, false);
                var lObjects = lOptions.values;
                var lCurObjectIdx, lNbObjects;
                if (lObjects) { //use the provided objects rather than creating new ones

                    lNbObjects = lObjects.length;
                    for ( lCurObjectIdx = 0; lCurObjectIdx < lNbObjects; lCurObjectIdx++) {
                        var lCurObject = lObjects[lCurObjectIdx];

                        //TODO, the call bellow actually fires the relation ship change event, we should try to silence it so we can fire only once for the whole list
                        this.addRelatedObject(lCurObject, iAttributeName, options);
                        returnValue.push(lCurObject);


                    }
                } else {
                    lNbObjects = lArrayOfObjectIds.length;
                    var lOtherObjectAttributes = options && options.otherObjectAttributes;
                    if (lNbObjects) {
                        // var objectsCollection = this.get(iAttributeName);
                        if (this.collection) {
                            var childCollection = this.collection.getChildCollection(iAttributeName);
                            for ( lCurObjectIdx = 0; lCurObjectIdx < lNbObjects; lCurObjectIdx++) {
                                var lCurObjectId = lArrayOfObjectIds[lCurObjectIdx];
                                if (lCurObjectId && lCurObjectId.length) {

                                    var newObject;
                                    if (lIDAttributeToUse === 'physicalId') {
                                        var iDontFetch, iDontCreate;
                                        newObject = this.collection.getRelatedObject(iAttributeName, lCurObjectId, iDontFetch, iDontCreate, options);
                                    } else {
                                        var lCurInputObject = lOtherObjectAttributes? lOtherObjectAttributes[lCurObjectIdx] : {};
                                        lCurInputObject[lIDAttributeToUse] = lCurObjectId;
                                        newObject = childCollection.add(lCurInputObject, {
                                            existingObject: true
                                        });
                                    }

                                    //TODO, the call bellow actually fires the relation ship change event, we should try to silence it so we can fire only once for the whole list
                                    this.addRelatedObject(newObject, iAttributeName, options);
                                    returnValue.push(newObject);

                                }
                            }
                            //TODO fire relationship change events once here. check if we can use _fireRelationshipEvent instead
                            //this.set(iAttributeName, objectsCollection);
                        }

                    }
                }

                return returnValue;
            },
            //        /**
            //         * override Model.isNew .
            //         * Model.isNew is based on the presence of an id.  Since we want to be able to add existing objects for which we don't know the id (case of assigneesByName)
            //         * one can explicitly set on an object that it is not new.
            //         */
            //        isNew: function () {
            //            return !this.existingObject && this._parent.apply(this, arguments);
            //        },
            /**
             * override the toJSON  method
             */
            //        toJSON: function () {
            //            var lRet = this._parent.apply(this, arguments);
            //            var lKeys = Object.keys(lRet);
            //            var lNbKeys = lKeys.length;
            //            for (var lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
            //                var lCurKey = lKeys[lCurKeyIdx];
            //                var lCurVal = lRet[lCurKey];
            //                if (lCurVal instanceof Model) {
            //                   var lCurJSONVal = lCurVal.toJSON();
            //                   var lFoundationData;
            //                   if (lCurVal._rowObjects && lCurVal._rowObjects.length) {
            //                           lFoundationData = lCurVal._rowObjects[0];
            //                   }
            //                    lRet[lCurKey] = {
            //                        actualValue: lFoundationData,
            //                        displayValue: lCurJSONVal
            //                    };
            //                }
            //            }
            //            //bcc: should we add children?  there is a potential for uselessly deep recursion.  Already with related data...
            //            //add the related data
            //            if (this._relations) {
            //                var lKeys = this._relations.map(function (iCurRelation) {
            //                    return iCurRelation.key;
            //                });
            //                var lNbKeys = lKeys.length;
            //                for (var lCurKeyIdx = 0; lCurKeyIdx < lNbKeys; lCurKeyIdx++) {
            //                    var lCurKey = lKeys[lCurKeyIdx];
            //                    var lRelatedData = this.get(lCurKey); //this is an array of model which each should be jsonified
            //                    var lConvertedRelatedData = [];
            //                    var lNbRelatedData = lRelatedData.length;
            //                    for (var lCurRelatedDataIdx = 0; lCurRelatedDataIdx < lNbRelatedData; lCurRelatedDataIdx++) {
            //                        var lCurRelatedDataObject = lRelatedData[lCurRelatedDataIdx];
            //                        lConvertedRelatedData.push(lCurRelatedDataObject.toJSON());
            //
            //                    }
            //                    lRet[lCurKey] = lConvertedRelatedData;
            //                }
            //            }
            //            return lRet;
            //        },


            // now parse will be passed the C/R/U/D operation type in options,
            // allowing you to deal with heterogeneous response formats from
            // your annoying back-end :
            //        /**
            //         * override parse
            //         */
            //        parse: function (response /*, options*/ ) {
            //            if (response && response.dataelements) {
            //                if (!this._rowObjects) {
            //                    this._rowObjects = [response];
            //                } else {
            //                    if (this._rowObjects.indexOf(response) === -1) {
            //                        this._rowObjects.push(response);
            //                    }
            //                }
            //                FoundationData._setInternalProperty(response, "_mvcModel", this);
            //
            //            }
            //            return this._parent.apply(this, arguments);
            //        },
            /**
             * override sync
             * CUD operations are pass through (server and local) per default, this can be overriden by setting the localOnly:true option.
             * Read operation will be local only by default, this can be overriden by setting the server:true option
             */
            //this is closer to the V1 implementation behavior, we delegate a lot to the collection compared to FoundationV2Model
            sync: function(method, object, options) {
                var ret;

                var store = this.collection ? this.collection._localStore : null;
                var args = Array.prototype.slice.call(arguments, 0);
                var that = this;
                if (method === 'read') {
                    if ((options && options.server) || !store) {
                        //server call
                        this.syncRead(this.collection.data(), this.collection._serviceName, options); //this.collection._serviceName specially useful when no data on the collection yet
                    } else {
                        return store.sync.apply(store, args);
                    }
                } else if (method === 'create' || method === 'update' || method === 'patch' || method === 'delete') {
                    //	var lData = this.getInMemoryData();
                    //Foundation call is delegated to the collection since the collection has the 'data' element
                    if (this.collection) {
                        if (!options.wait) {
                            var oldOnFailure = options.onFailure;
                            var onComplete = options.onComplete;
                            options.onComplete = function( /*rowObject, data*/ ) {
                                if (onComplete) {
                                    onComplete.apply(this, arguments);
                                }
                            };
                            switch (method) {
                                case 'delete':
                                    //store the collection in another variable for future reinsertion in case of error
                                    var collectionBeforeDelete = this.collection;
                                    options.onFailure = function( /*rowObject, data*/ ) {
                                        if (collectionBeforeDelete && UWA.is(collectionBeforeDelete.data, 'function')) {
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
                                    options.onFailure = function( /*rowObject, data*/ ) {
                                        if (that.collection && UWA.is(that.collection.data, 'function')) {
                                            var lData = that.collection.data();
                                            lData && FoundationData.rollbackFailedData(lData);
                                        }
                                        that.destroy({
                                            localOnly: true
                                        });

                                        if (oldOnFailure) {
                                            oldOnFailure.apply(this, arguments);
                                        }
                                    };
                                    options.onComplete = function(rowObject /*, data*/ ) {
                                        //Add this object the tagger.
                                        var tnProxy = that.collection && that.collection.getTNProxy();
                                        if (tnProxy) {
                                            var taggerSubject = {};
                                            taggerSubject['pid://' + rowObject.id] = [];
                                            tnProxy.addSubjectsTags(taggerSubject, 'foundation2');
                                        }
                                        if (onComplete) {
                                            onComplete.apply(this, arguments);
                                        }
                                    };
                                    break;
                                case 'update':
                                case 'patch':
                                    options.onFailure = function(rowObject /*, dataFromServer, options*/ ) {
                                        //restore the objects in data
                                        if (that.collection && UWA.is(that.collection.data, 'function')) {
                                            var lData = that.collection.data();
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
                                    default:
                            }
                        }
                        ret = this.collection.sync(method, object, options);
                        this.dispatchEvent('onRequest', [this, ret, options]);


                    }
                    //in case we have both a server and a local storage sync we don't want the local storage to send onComplete and onFailure messages
                    args[2] = UWA.clone(options, false);
                    delete args[2].onComplete;
                    delete args[2].onFailure;
                }

                return ret;
                //  return this._parent.apply(this, arguments);
            },
            /**
             * files upload method
             * @param {Array} files the files array object
             * @param {String} iRelName the relationship name
             * @param {Object} iOptions the options object
             */
            uploadFiles: function _uploadFiles(files, iRelName, iOptions) {
                for (var i = files.length - 1; i >= 0; i--) {
                    this.uploadFile(files[i], iRelName, iOptions);
                }
            },
            imageExtensions: ['.gif', '.jpg', '.png', '.gif', '.jpeg', '.3dxml', '.cgr', '.pdf', '.bpm', '.psd', '.ai'],
            /**
              * file upload method
              * @param  {File} file the file object
              * @param {String} iRelName relationship to attach the file to
              * @param {Options} iOptions the options.  In particular
              *                   iOptions.collabspace to specify a collabspace
              *                   iOptions.onComplete, iOptions.onFailure standard callbacks
              */
            uploadFile: function _uploadFile(file, iRelName, iOptions) {
                var that = this;
                var lOptions = UWA.clone(iOptions || {}, false);
                //check for image type files
                var lFileName = file.name;
                //To retrive file name from MSF object
                if (file.FileName) {
                    lFileName = file.FileName;
                }

                var lFileExtensionPosition = lFileName.lastIndexOf('.');
                if (lFileExtensionPosition !== -1) {
                    var lExtension = lFileName.substring(lFileExtensionPosition);
                    lOptions.isImage = this.imageExtensions.indexOf(lExtension) !== -1;
                }
                if (!this.id) {
                    throw new Error('Invalid object, cannot upload file on a model not saved yet');
                }
                lOptions.csrf = this.csrf;
                var onComplete = lOptions.onComplete;
                lOptions.onComplete = function(resp) {
                    var lDocument = resp.data[0];
                    lDocument.dataelements.hasfiles = 'TRUE';
                    if (lOptions.isImage && !file.FileName) {
                        lDocument.dataelements.image = window.URL.createObjectURL(file);
                    }
                    if (iRelName) {
                        that.updateRelatedObjectWithNewEntry(lDocument, iRelName);
                    }

                    if (UWA.is(onComplete, 'function')) {
                        onComplete(lDocument);
                    }
                };
                var onFailure = lOptions.onFailure;
                lOptions.onFailure = function() {

                    if (UWA.is(onFailure, 'function')) {
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
                    fromDictionary = this.collection.getRelationDescription(iRelName);
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
             * add to the parent relationship names the one declared on the model
             * @returns {Array} lKeys the Array of keys
             */
            getRelationsNames: function functionName() {
                var lKeys = this._parent.apply(this, arguments);
                var keysIndex = {};
                lKeys.forEach(function(key) {
                    keysIndex[key] = key;
                });
                if (this._relations) {
                    var lAdditionalKeys = this._relations.map(function(iCurRelation) {
                        return iCurRelation.key;
                    });
                    lAdditionalKeys.forEach(function(key) {
                        if (!keysIndex[key]) {
                            lKeys.push(key);
                        }
                    });
                }
                return lKeys;
            },
            defaults: {}

        });
        //We need to do this here because toJSON is not defined till now
        //    FoundationBaseModel.prototype.dataForRendering = function() {
        //        return this.toJSON();
        //    };
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
                            imageValue: iV2Object.dataelements[lCurKey][0],
                            imageSize: 'ICON'
                        }]
                    };
                } else {

                    lDataElements[lCurKey] = {
                        value: [{
                            value: iV2Object.dataelements[lCurKey][0]
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
define('DS/Foundation2/Models/ReferenceModel', ['UWA/Core', 'UWA/Utils', 'DS/Foundation2/FoundationV2Data',
        'DS/Foundation2/Models/FoundationBaseModel', 'DS/E6WCommonUI/UIHelper', 'DS/E6WCommonUI/Search'
    ],
    function(UWA, Utils, FoundationData, FoundationBaseModel, UIHelper, Search) {
        'use strict';
        var PERSON_REGEX = /^iam:|^people:/;
        var ReferenceModel = FoundationBaseModel.extend({
            _uwaClassName: 'Foundation2/ReferenceModel',
            /**
             * @override
             * read details from the server. Overridden for the specific case of people from swym
             * @method
             */
            syncRead: function() {
                if (this.serviceId === '3DSwym') { //case of a swym model
                    var personMatch = this.id.match(PERSON_REGEX);
                    if (personMatch) {
                        FoundationData.loadServiceData('PersonSearch?searchStr=' + this.id.substr(personMatch[0].length), this.syncFromServer.bind(this));
                    }
                } else {
                    this._parent.apply(this, arguments);
                }

            },
            /**
             * sync this object with the version of the same object coming from the server.
             * @override
             * in the case of person, make sure we get the correct one (the one where the name is the same as the id without the prefix).
             */
            syncFromServer: function(data) {
                if (this.serviceId === '3DSwym') { //case of a swym model
                    var personMatch = this.id.match(PERSON_REGEX);
                    var that = this;
                    data.data = data.data.filter(function(iObject) { //keep only the correct result in case someone else has the login in his searchable fields
                        return iObject.dataelements.name === that.id.substr(personMatch[0].length);
                    });
                    if (data.data.length === 1) {
                        this.set(this.parse(data.data[0]));
                    }

                } else {
                    this._parent.apply(this, arguments);
                }

            },
            /*
             * compute name differently for person in an artificial way
             */
            get: function(iAttrName, options) {
                if (iAttrName === 'name') {
                    if (this.get('type') === 'Person') {
                        if (options && options.noMapping) {
                            return this._parent.apply(this, arguments); //to still get the id when we need it
                        } else {
                            return this.get('firstname') + ' ' + this.get('lastname');
                        }

                    } else {
                        var lTitle = this.get('title');
                        if (lTitle && lTitle.length) {
                            return lTitle;
                        }
                    }

                } else if (iAttrName === 'image' && this.get('type') === 'Person') {
                    // no mapping passed so we dont get full name instead we get he right id
                    return UIHelper.userPictureURL(this.get('name', {
                        noMapping: true
                    }));

                } else if (iAttrName === 'image') {
                    var lM2Icon = this.get('dsM2:icon');
                    if (lM2Icon && UWA.is(lM2Icon, 'object')) {
                        return lM2Icon;
                    }
                    // var lImage = this._parent.apply(this, arguments);
                    // if (lImage) {
                    // 	var parsedUrl = Utils.parseUrl(lImage);
                    // }
                } else if (iAttrName === 'physicalId') {
                    return this.id;
                }

                return this._parent.apply(this, arguments);
            },
            toJSON: function() {
                var ret = this._parent.apply(this, arguments);
                // 	            if (ret.busType === 'Person') {
                // 	                if (!ret.image) {
                // 	                    ret.image = {};
                // 	                }
                // 	                ret.image.imageValue = FoundationData.userPictureURL(ret.name);

                // 	            }
                var lName = this.get('name');
                if (lName) {
                    ret.name = lName;
                }
                var lImage = this.get('image');
                if (lImage) {
                    ret.image = lImage;
                }
                return ret;
            },
            /*
             * while V2 and V1 are coexisting, need to have a physicalId
             * TODO remove this and change meta.html.handlebars when everything migrated
             */
            dataForRendering: function() {
                var ret = this.toJSON();
                ret.physicalId = ret.id;
                return ret;
            }
        });
        // nma5: I dont think we are using below code, we need to remove it
        ReferenceModel.typeAheadCallback = function(fieldConfig, term, callback, options) {
            //TODO filter out the people already part of the field
            var searchCriteria = '*';
            // depending on the source we need to change the query like for 3dplan it should be [ds6w:type]:
            var excludedSearchTypes = fieldConfig.excludeSearchTypes;
            if (excludedSearchTypes) {
                searchCriteria = '*  NOT ' + Search.buildSearchTypeQuery(excludedSearchTypes, {
                    source: fieldConfig.searchSource
                });
            }
            var searchParams = 'searchStr=' + encodeURIComponent(term) + searchCriteria;
            var typeStr;
            if (fieldConfig && fieldConfig.searchTypes) {
                typeStr = encodeURIComponent(fieldConfig.searchTypes);
            } else {
                typeStr = ((fieldConfig.type === 'person') ? 'Person' : '*');
            }
            searchParams += '&typeStr=' + typeStr;
            return FoundationData.ajaxRequest({
                url: '/resources/v2/e6w/service/ObjectSearch?' + searchParams,
                type: 'get',
                dataType: 'json',
                callback: function(resp) {
                    var callbackParam = [];
                    if (resp.success && resp.data && resp.data.length) {
                        var lNbData = resp.data.length;
                        for (var lCurDataIdx = 0; lCurDataIdx < lNbData; lCurDataIdx++) {
                            var lCurRowObject = resp.data[lCurDataIdx];
                            if (lCurRowObject.dataelements) {
                                var lType = lCurRowObject.type;
                                var lName = lCurRowObject.dataelements.name || '';
                                if (lType === 'Person') {
                                    var lFirst = lCurRowObject.dataelements.firstname || '';
                                    var lLast = lCurRowObject.dataelements.lastname || '';
                                    callbackParam.push({
                                        value: lCurRowObject.id,
                                        label: lFirst + ' ' + lLast,
                                        image: UIHelper.userPictureURL(lName),
                                        login: lName,
                                        sourceId: '3DSpace', //TODO check with Dave if this is correct, if not he needs to return the sourceId from the API
                                        rowObject: lCurRowObject
                                    });
                                } else {
                                    var lImage = lCurRowObject.dataelements.image || '';
                                    var lTitle = lCurRowObject.dataelements.title || '';
                                    callbackParam.push({
                                        value: lCurRowObject.id,
                                        label: lTitle || lName,
                                        image: lImage,
                                        sourceId: '3DSpace', //TODO check with Dave if this is correct, if not he needs to return the sourceId from the API
                                        rowObject: lCurRowObject
                                    });
                                }
                            }

                        }
                    }
                    callback(callbackParam, options);
                },
                headers: {
                    'content-type': 'application/json'
                }
            });
        };
        Object.defineProperty(ReferenceModel.prototype, 'serviceHosting', {
            get: function() {
                //  return '3DSwym'; //for launching properties
                if (this.get('type') === 'Person') {
                    return 'fedsearch'; //for launching properties
                } else {
                    return this.get('service') || '3DSpace';
                }
            }
        });
        //person is only kind of a result model, it really is a proxy for a person in swym
        Object.defineProperty(ReferenceModel.prototype, 'fedSearchIdQuery', {
            get: function() {
                //return this.id;
                if (this.get('type') === 'Person') {
                    return 'resourceid:"iam:' + this.get('name', {
                        noMapping: true
                    }) + '"'; //for launching properties
                } else {
                    return 'physicalid:"' + this.id + '"';
                }
            }
        });
        return ReferenceModel;
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
    'DS/Foundation2/WidgetTagNavInit', ['DS/ENO6WPlugins/jQuery_3.3.1', 'DS/Foundation2/FoundationV2Data'],
    function(jQuery, FoundationV2Data) {
        'use strict'; //need to know if tags should be a local or global variable
        var WidgetTagNavInit = {
            /**
             * call the tagger service to find out what should be the tags.
             * to be called after the initial service call filling in our inMemoryData
             * @param {Object} inMemoryData the inMemoryData
             */
            loadTagData: function(inMemoryData) {
                var rows = [];
                var ids = [];
                inMemoryData.iterateOverDataStructure(function(row) {
                    rows.push(row);
                    ids.push(row.id);
                }, /*no related data*/ true, /*no children*/ false);

                var postData = this.getTagPostData(inMemoryData, ids);
                if (!postData && postData === '') {
                    WidgetTagNavInit.drawTags(inMemoryData, []);
                }

                var loadTagDataDone = function(data) {
                    var tagData = data ? data.data : null;
                    var TagNavigatorProxy;
                    var setTNProxy = function setTNProxy(TagNavigatorProxy) {
                        //register the TN proxy
                        WidgetTagNavInit.register(inMemoryData, TagNavigatorProxy);

                        //sends the tag data to the proxy
                        if (tagData && tagData.length) {
                            WidgetTagNavInit.drawTags(inMemoryData, tagData);
                        }
                    };
                    //We need to make this syncronous for tests so try to get it directly first
                    try {
                        TagNavigatorProxy = require('DS/TagNavigatorProxy/TagNavigatorProxy');
                        setTNProxy(TagNavigatorProxy);
                    } catch (e) {
                        require(['DS/TagNavigatorProxy/TagNavigatorProxy'], setTNProxy);
                    }
                };

                //loadServiceData: function (widgetName, callback, isPost, postData, iContentType, iUrlParams)
                FoundationV2Data.loadServiceData(
                     /*widgetName*/  'Tags',
                     /*callback*/ loadTagDataDone,
                     /*isPost*/ true,
                    postData,
                    'application/x-www-form-urlencoded; charset=utf-8' /*iContentType*/
                );

            },
            /**
             * append tag data to the inMemoryData
             */
            // bcc: don't think that is necessary

            //             processTagData: function (inMemoryData, tagRoot, rows) {
            //                 // merge tag data into widget data.
            //                 var tagrows = FoundationV2Data.getContainerData(tagRoot);
            //                 if (tagrows) { //TODO understand the following and fix it since tagRoot seems to have the wrong thing passed in it
            //                      var lNbTagRows = tagrows.length;
            //                      //assumption here is that we received one tagrow per entry sent and that they correspond in term of ids
            //                     for (var i = 0; i < lNbTagRows; i++) {
            //                             //don't like the assumption, I'll check first and skip the corresponding row if the ids are wrong.
            //                             //maybe we should use getObject to look it up
            //                         var tagrow = tagrows[i];
            //                         var lCurRow = rows[i];
            //                         if (tagrow.physicalId === lCurRow.id) {
            //                            FoundationV2Data.__appendTagData(lCurRow, tagrow);
            //                         }
            //                     }
            //                 }

            //                 FoundationV2Data.__appendTagConfig(inMemoryData, tagRoot); // append
            //                 // tag
            //                 // fields
            //                 // to
            //                 // widget
            //                 // fields.
            //             },
            /**
             * build the data structure which is required by the tagger proxy.
             * @param {Object} taggerData the return from our tagger service (V2)
             * @return {Object} the format needed by the tagger
             */
            buildTagObjectData: function(taggerData) {
                var tagData = {};
                var hasOwn = Object.prototype.hasOwnProperty;
                var IMPLICIT_TAG_PREFIX = '_tag_implicit_';
                var IMPLICIT_TAG_PREFIX_LENGTH = IMPLICIT_TAG_PREFIX.length;
                var EXPLICIT_TAG_PREFIX = '_tag__';
                var EXPLICIT_TAG_PREFIX_LENGTH = EXPLICIT_TAG_PREFIX.length;
                taggerData.forEach(function(item /*, index*/ ) {
                    var tags = [];
                    try {
                        for (var key in item.dataelements) {
                            if (hasOwn.call(item.dataelements, key)) {
                                // we need to know if it is implicit or explicit so we can disect the string
                                // begin is the length of the prefix (IMPLICIT_TAG_PREFIX, or EXPLICIT_TAG_PREFIX)
                                // we need to start at this point
                                var begin;
                                var field = '';
                                if (key.indexOf(IMPLICIT_TAG_PREFIX) === -1) {
                                    begin = EXPLICIT_TAG_PREFIX_LENGTH;
                                } else {
                                    field = 'implicit';
                                    begin = IMPLICIT_TAG_PREFIX_LENGTH;
                                }
                                var val = item.dataelements[key];
                                var sixw = key.substr(begin);
                                var arrayLength = val.length;
                                for (var j = 0; j < arrayLength; j++) {
                                    var tag = {
                                        object: val[j],
                                        dispValue: val[j],
                                        sixw: sixw,
                                        field: field
                                    };
                                    tags.push(tag);
                                }
                            }
                        }
                    } catch (err) {
                        console.error("WidgetTagNavInit: loadTagDataDone" + err); //eslint-disable-line
                    }
                    var objectId = 'pid://' + item.id;
                    tagData[objectId] = tags;
                });

                return tagData;
            },
            /**
             * get the tag label based on V1 tagger service format
             * @param {Object} value a value as returned by the tagger
             * @return {String} the tag label
             */
            getTagLabel: function(value) {
                var label = '';
                if (value.printValue) {
                    label += value.printValue;
                } else if (value.value) {
                    label += value.value;
                }
                return label;
            },
            /**
             * build the post information to be sent to the tagger service (V1)
             * @param  {Object} inMemoryData the inMemoryData
             * @param  {Array} ids          Array of ids for which we need tags
             * @return {String}             data to send with the POST call to the serviceTagData service
             */
            getTagPostData: function(inMemoryData, ids) {
                var postData = '';

                if (ids.length > 0) {
                    postData = 'idList=' + ids;
                    //    postData += "&isPhysicalIds=true";
                }

                return postData;
            },
            /**
             * cleanup
             * @param {Object} inMemoryData the inMemoryData
             */
            destroyTNProxies: function(inMemoryData) {
                if (inMemoryData.tnProxy) {
                    inMemoryData.tnProxy.die && inMemoryData.tnProxy.die();
                    inMemoryData.tnProxy = null;
                }
            },
            /**
             * builds the tagger datastructure and sends it to the tnproxy
             * @param {Object} inMemoryData with the tnProxy set
             * @param {Object} taggerData the return from our tagger service
             */
            drawTags: function(inMemoryData, taggerData) {
                if (inMemoryData.tnProxy) {
                    //build the structure
                    var tnDataObj = this.buildTagObjectData(taggerData);
                    //send to the proxy
                    inMemoryData.tnProxy.setSubjectsTags(tnDataObj, 'foundation2');
                }
            },
            /**
             * When called by the tagger flag the rows which should be hidden as filtered and the others as non filtered
             * @param {Object} inMemoryData our data structure
             * @param {Array} filteredSubjectList the selection sent by the tagger based on the current refinements
             */
            showObjects: function(inMemoryData, filteredSubjectList) {
                var lFilteredIdsMap = {};
                if (!inMemoryData.iterateOverDataStructure) {
                    return; //
                }
                filteredSubjectList.forEach(function(id) {
                    lFilteredIdsMap[id] = true;
                });
                inMemoryData.iterateOverDataStructure(function(row) {
                    var objectId = 'pid://' + row.id;
                    var filter = !lFilteredIdsMap[objectId]; //if in the list we don't filter
                    //Foundation V1 and V2 format doesn't differ here.
                    FoundationV2Data.__setRowFilter(inMemoryData, row, filter, null /*bSearchFiltered need to be neither false nor truthy*/ );
                }, /*no related data*/ true, /*no children*/ false); // get all data records regardless of filter.
            },
            /**
             * callback for the tagger to call us with a list of ids when a refinement occured
             * @param  {Object} objSelection object passed by the tagger containing both the id to be filtered and the tags selected by the user
             */
            handleFilter: function(objSelection) { // "this" is scoped to the inMemoryData that invoked this method
                WidgetTagNavInit.showObjects(this,
                    objSelection.filteredSubjectList); //all rows which should not be shown will be tagged with filter===true by this method
                //only do this for configurable widgets
                if (this.parentObj) {
                    this.parentObj.reDrawWidget(this);
                }
                //apply filter on collection
                if (this._mvcCollection) {
                    this._mvcCollection._applyFilter();
                }
            },
            //bcc: kept for later, code to send info to the tagger when a specific object is selected
            //not supported in V2 as of now
            // handleTagCollect: function () {
            //     var aWidgetOids = [];
            //     if (this.tnProxy) {
            //         this.container.find(".selected").each(
            //             function () {
            //                 aWidgetOids.push("pid://" + jQuery(this).attr("data-pid"));
            //             });
            //         try {
            //             if (aWidgetOids.length > 0) {
            //                 this.tnProxy.focusOnSubjects(aWidgetOids);
            //             } else {
            //                 this.tnProxy.unfocus();
            //             }
            //         } catch (e) {
            //             // do nothing
            //             console.log(e.message);
            //         }
            //     }
            // },
            /**
             * register a proxy and store it on the inMemoryData
             * @param  {Object} inMemoryData      the inMemoryData (Foundation Data)
             * @param  {Module} TagNavigatorProxy The TagNavigatorProxy module
             */
            register: function(inMemoryData, TagNavigatorProxy) {
                if (inMemoryData.tnProxy) {
                    //bcc: why do this only when a proxy is already registered
                    //
                    //TWS, test this without this if statement to verify BCC's above comment
                    if (inMemoryData._mvcCollection) { //reset for mvc based apps
                        //inMemoryData.tnProxy.addFilterSubjectsListener(this.handleFilter, inMemoryData);
                        inMemoryData.tnProxy.removeEvent('onFilterSubjectsChange', this.handleFilter);
                        inMemoryData.tnProxy.addEvent('onFilterSubjectsChange', this.handleFilter, inMemoryData);
                    }
                    return;
                }
                var paramWidgetId = enoviaServer.widgetId || window.widget.id;
                var paramTenant = enoviaServer.tenant;
                var options = {
                    widgetId: paramWidgetId,
                    contextId: !paramWidgetId ? 'context1' : undefined,
                    tenant: paramTenant === 'onpremise' ? undefined : paramTenant,
                    filteringMode: 'WithFilteringServices'
                };

                FoundationV2Data._setInternalProperty(inMemoryData, 'tnProxy', TagNavigatorProxy.createProxy(options));

                // setup listeners
                // when a tag is clicked in TN
                //inMemoryData.tnProxy.addFilterSubjectsListener(this.handleFilter, inMemoryData);
                inMemoryData.tnProxy.addEvent('onFilterSubjectsChange', this.handleFilter, inMemoryData);
                window.onunload  = function() {
                    if (inMemoryData.tnProxy) {
                        inMemoryData.tnProxy.die && inMemoryData.tnProxy.die();
                    }
                };
            }
        };

        // if (typeof window.console === "undefined") {// prevent IE from throwing
        //                                         // errors. This is just a
        //                                         // debug utility
        //     window.console = {
        //         log : function() {
        //         },
        //         warn : function() {
        //         },
        //         dir : function() {
        //         }
        //     };
        // }
        // make a global for legacy's sake
        //             if (typeof window !== 'undefined') {
        //                 window.WidgetTagNavInit = WidgetTagNavInit;
        //             } else {
        // //                // case of node if we need it one day
        // //                if (typeof GLOBAL !== 'undefined') {
        // //                    GLOBAL.WidgetTagNavInit = WidgetTagNavInit;
        // //                }
        //             }
        return WidgetTagNavInit;
    });

/*global define*/
define('DS/Foundation2/Models/ProxyReferenceModel', ['UWA/Core', 'UWA/Utils',
        'DS/Foundation2/Models/ReferenceModel', 'DS/RDFFoundation/Models/ComponentProxyIndexModel',
        'DS/E6WCommonUI/UIHelper',
        'i18n!DS/E6WCommonUI/assets/nls/E6WCommonUINLS'
    ],
    function(UWA, Utils, ReferenceModel, ComponentProxyIndexModel, UIHelper, E6WCommonUINLS) {
        'use strict';
        var redispatchChangeEvent = function(attributeName) {
            return function() {
                //make sure the arguments of the change event are as described in the UWA/Class/Model documentation
                var lArgs = Array.prototype.slice.call(arguments, 1);
                lArgs[0] = this;
                return this.dispatchEvent('onChange' + (attributeName ? (':' + attributeName) : ''), lArgs);
            };
        };
        var ProxyReferenceModel = ReferenceModel.extend({
            _uwaClassName: 'ProxyReferenceModel',
            setup: function() {
                var that = this;
                // create component proxy index model which will be used to fetch document details from drive
                this.indexModel = new ComponentProxyIndexModel({
                    resourceid: this.id,
                    tenant: this.get('tenant'),
                    source: 'drive'
                });
                this.listenTo(this.indexModel, 'onChange:ds6w:label', redispatchChangeEvent('title'));
                this.listenTo(this.indexModel, 'onChange:type_icon_url', redispatchChangeEvent('image'));
                this.listenTo(this.indexModel, 'onChange:ds6w:type', redispatchChangeEvent('ds6w:type'));
                this.listenTo(this.indexModel, 'onChange', redispatchChangeEvent());
                // TODO: we dont need to fetch when we DnD as we already have the info so optimise
                this.indexModel.fetch({
                    onFailure: function( /*context, error*/ ) {
                        that.indexModel._noAccess = true;
                    }
                });
                this._parent.apply(this, arguments);
            },
            /**
             * function to get right title info in case user doesn't have access
             * @return {String} title
             */
            getTitle: function(){
                if (this.indexModel._noAccess) {
                    return E6WCommonUINLS.get('E6WCommonUI.Error.NoAccess') + E6WCommonUINLS.get('E6WCommonUI.Error.NotFound');
                } else {
                    return this.indexModel.get('ds6w:label');
                }
            },
            get: function(iAttrName) {
                var retVal = this._parent.apply(this, arguments);
                // check on the index model if not present return the proxy model result
                switch (iAttrName) {
                    case 'name':
                    case 'title':
                        return this.getTitle() || retVal;
                    case 'physicalId':
                        return this.indexModel.id;
                    case 'image':
                        return this.indexModel.get('preview_url') || this.indexModel.get('type_icon_url') || retVal;
                    case 'ds6w:type':
                    case 'type':
                        return this.indexModel.get('ds6w:type') || retVal;
                    case 'hasfiles':
                        return this.get('type') === 'DriveFile' || this.get('service') === '3DDrive';
                    case 'dscom:Tenant':
                    case 'tenant':
                        return this.indexModel && this.indexModel.get('tenant') || retVal;
                    case 'dscom:ServiceHosting':
                        return this.get('service');
                    default:
                }
                // redirect to index model if not available in ProxyReferenceModel
                if (!retVal) {
                    retVal = this.indexModel && this.indexModel.get(iAttrName);
                }
                return retVal;
            },
            /**
             * Get the draggable transfer object data for this model
             *
             * this should comply with the documented format as documented here:
             *  http://dsdoc/devdoc/3DEXPERIENCER20XXx/en/DSInternalDoc.htm?show=CAAWebAppsJSDragDropPro/CAAWebAppsQr3DXContent.htm
             *
             * @param {Object} options options that will overload the default options
             * @return {Object} to be used in DnD and related APIs, see link above (with the appropriate release number) for details of the format
             */
            getTransferObject: function(options) {
                var type = this.get('type');
                var lOptions = UWA.clone(options || {}, false);
                var transferData = UWA.merge(lOptions, {
                    source: window.widget.getValue('appId') || 'X3DCSMA_AP', //appId may not have a value in non cloud installations
                    envId: this.tenant || window.widget.getValue('x3dPlatformId'),
                    objectId: this.get('physicalId'),
                    objectType: type,
                    objectType_Internal: type,
                    displayName: this.get('title'),
                    serviceId: this.serviceHosting,
                    image: this.get('image')
                });
                return UIHelper.getTransferObject(transferData);
            }
        });
        Object.defineProperty(ProxyReferenceModel.prototype, 'tenant', {
            get: function() {
                return this.get('tenant');
            }
        });
        return ProxyReferenceModel;
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
//TODO deal with tagger
define('DS/Foundation2/Collections/FoundationBaseCollection', //define module
    ['UWA/Core', 'UWA/Class/Collection', 'UWA/Class/Model', 'DS/Foundation2/FoundationV2Data',
        'DS/Foundation2/Models/FoundationBaseModel', 'DS/Foundation2/WidgetTagNavInit', 'DS/TagNavigatorProxy/TagNavigatorProxy'
    ], //prereqs

    function(UWA, Collection, Model, FoundationData, FoundationBaseModel, WidgetTagNavInit, TagNavigatorProxy) {
        'use strict';

        //var basicsNotFields = ["id", "type", "cestamp", "relId", "tempId"]; //add more, those won't be converted back to fields
        var FoundationChildCollection;
        var FoundationBaseCollection = Collection.extend({
            _uwaClassName: 'FoundationBaseCollection',
            dataForRendering: function(options) {
                var objects = [];
                var length = this.length;
                for (var i = 0; i < length; i++) {
                    var mvcModel = this.at(i);
                    if (mvcModel) {
                        objects.push(mvcModel.dataForRendering(options));
                    }
                }
                return (objects);
            },
            /**
             * retrieves a relationship description
             */
            getRelationDescription: function getRelationDescription(iRelName) { //the result of this could be cached, we would need to update when states are changed
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
                            if (this.data()) { //we have data from Foundation, lets read it.  Not sure if this test is enough in V1 we were also testing for widgetType
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
                        return lSchema;
                    }

                }

            },
            getTNProxy: function() {
                var data = this.data() || this;
                var proxy = data.tnProxy ;
                if (proxy) {
                    return proxy;
                } else {
                    //register the TN proxy
                    WidgetTagNavInit.register(data, TagNavigatorProxy);
                    if (data) {
                        FoundationData._setInternalProperty(this, 'tnProxy', data.tnProxy);
                    } else {
                      //we don't really want to be listening to the onFilterSubjectsChange
                      this.tnProxy.removeEvent('onFilterSubjectsChange', undefined, this);
                    }
                    return this.tnProxy;
                }
            },
            setTNProxy: function setTNProxy(tnProxy){
              this.tnProxy = tnProxy;
              var data = this.data();
              data && FoundationData._setInternalProperty(data, 'tnProxy', tnProxy);
            },
            data: function() {
                var lRet;
                if (this._data) {
                    return this._data;
                }
                if (!this._parentCollection || !UWA.is(this._parentCollection.data, 'function')) {
                    return lRet;
                }
                return this._parentCollection.data();
            },
            /**
             * Resets the in memory data to an empty array. Does not modify definitions.
             */
            clearData: function() {
                if (!this._data && this._parentCollection) {
                    this._parentCollection.clearData();
                }
                this._data.data = [];
            },
            // Reference to this collection's model.
            model: FoundationBaseModel,
            /**
             * register a FoundationChildCollection for a relationshipname.
             * Any relationship of this name will point to object which should be managed by that collection
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
             */
            getChildCollection: function(relationshipName) {
                if (this._childrenMap) {
                    return this._childrenMap[relationshipName];
                }

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
            init: function FoundationCollectionConstructor(data) {
                //overwriding the constuctor will let us translate arguments which are in the Foundation services format to our simpler format
                var args = Array.prototype.slice.call(arguments, 0);
                //  this.data = data;
                if (data && data.data) {
                    var modelsJSON = this._convertFoundationData(data);
                    args[0] = modelsJSON;
                }
                this._parent.apply(this, args);

            },
            /**
             * override setup:
             */
            setup: function FoundationCollectionSetup(models, options) {
                if (options) {
                    this._serviceName = options.serviceName;
                    this._initialLoadOptions = options.initialLoadOptions;
                    this._completeOptions = options.completeOptions;
                    this._partialRefreshServiceName = options.partialRefreshServiceName || this._serviceName + '/autoRefresh';

                    this._localStore = options.localStore; //bcc: TODO should hide local store but still used by model
                }
                //TODO use the definitions which are part of the returns from the server to define those
                var lRelations = this.model.prototype._relations;
                if (this.model && lRelations) {
                    //iterate over the relationships
                    //create the child collections
                    var lNbRelations = lRelations.length;
                    for (var lCurRelIdx = 0; lCurRelIdx < lNbRelations; lCurRelIdx++) {
                        var lCurRel = lRelations[lCurRelIdx];
                        var ChildCollectionType = lCurRel.collectionType || FoundationChildCollection; /*var lCurChildCollection =*/
                        new ChildCollectionType(null, {
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
                     * the expected result for {owner:{displayValue:"displayOwner", actualValue:"actualOwner"}, attr:"attrValue} is
                         [{
                                name: "owner",
                                value: {
                                    displayValue: "displayOwner",
                                    actualValue: "actualOwner"
                                }
                            }, {
                                name: "attr",
                                value: {
                                    actualValue: "attrValue"
                                }
                            }]

                     */
            //         _convertToFoundationData: function (attrs) {
            //             //the expected format is an array of fields
            //             var hasOwn = Object.prototype.hasOwnProperty;
            //             var ret = [];
            //             var relations = this.model.prototype._relations;
            //
            //             var relationNames = relations ? relations.map(function (rel) {
            //                 return rel.key;
            //             }) : [];
            //             for (var key in attrs) {
            //
            //                 if (hasOwn.call(attrs, key) && basicsNotFields.indexOf(key) === -1 && relationNames.indexOf(key) === -1) {
            //
            //                     var value = attrs[key];
            //
            //                     //                    if (value === undefined || value._isCollection) {
            //                     //                        continue;
            //                     //                    }
            //                     var fieldObject = {
            //                         name: key
            //                     };
            // /*
            //                     if (typeof value === 'undefined') {
            //                         continue;
            //                     }
            //                     */
            //
            //                     fieldObject.value = value;
            //                     ret.push(fieldObject);
            //                 }
            //             }
            //             return ret;
            //         },
            /**
             * converts to a json model for the MVC.  Return null in case of errors.
             */
            _convertFoundationData: function _convertFoundationData(data, checkFiltered) {
                var modelsJSON = data;
                if (data) {
                    if (modelsJSON.data && (data.success === undefined || data.success)) { //if we are not in this case we are screwed I guess
                        FoundationData._setInternalProperty(modelsJSON, '_mvcCollection', this);
                        this._data = modelsJSON;
                        modelsJSON = FoundationData._getContainerData(modelsJSON, null, checkFiltered, true /*allLevels*/ ); //the all levels argument
                        if (this.tnProxy) {
                          FoundationData._setInternalProperty(this._data, 'tnProxy', this.tnProxy);
                          WidgetTagNavInit.register(this._data, this.tnProxy);
                        }
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
                var data = this.data();
                if (data) {
                    modelsJSON = FoundationData._getContainerData(data, null, checkFiltered, true /*allLevels*/ ); //the all levels argument

                    models = modelsJSON.map(function(obj) {
                        return obj._mvcModel;
                    });
                    this.reset(models);
                }
            },
            /**
             * checks if a read request corresponds to a read from the server or from the local store.
             */
            isServerFetch: function(collection, options) {
                var that = this;
                var store = that._localStore;
                return options && options.server || !store;
            },
            /**
             * retrieves the associated storage.
             * @return storage for this collection
             */
            _getStorage: function() {

                return this._localStore && this._localStore._storage;
            },
            /**
             * update a model in the foundation in memory structure depending on what was done to it.
             * set the _rowObjects variable on the model in case of a create
             */
            updateModelInFoundation: function(method, model /*, options*/ ) {
                return model.updateModelInFoundation(method);
            },
            //           // var that = this;
            //            var attrs = model.toJSON();
            //            var lCollectionForConvertion = model.collection || this;  //need to use the right collection for convertion or we will not have the correct relations
            //            var foundationData = lCollectionForConvertion._convertToFoundationData(attrs);
            //            var rowObjects = model._rowObjects;
            //            var modelOrId = rowObjects && rowObjects.length === 1 ? rowObjects[0] : model.id; //use the id as _rowObjects contains an array in case of multiinstanciation
            //            //we should not try to apply the change multiple times, some would work (update) but some wouldn't
            //            //we need when the server sends back the success to update all the instances though.
            //            var actualMethod = method === "create" && rowObjects && rowObjects.length ? "update" : method; //in case of several calls to create just update the attributes
            //            //this can happen if we do a save on an object which is new and on which related data were added.
            //            //when adding related data on a new object we update the foundation data, however the object isn't really
            //            //saved yet and will still look like new to backbone
            //
            //            var rowObject;
            //            var lInMemoryData = this.data();
            //            if (lInMemoryData) {
            //                switch (actualMethod) {
            //                case "create":
            //                    //create is supposed to be a real creation, we add the object to foundation and we will initiate _rowObjects
            //                    rowObject = FoundationData.addObject(lInMemoryData, null, foundationData);
            //                    model._rowObjects = [rowObject];
            //                    FoundationData._setInternalProperty(rowObject, "_mvcModel", model);
            //                    break;
            //                case 'update':
            //                case 'patch':
            //                    rowObject = FoundationData.modifyObject(lInMemoryData, modelOrId, foundationData);
            //                    break;
            //                case 'delete':
            //                    if (rowObjects && rowObjects.length) {
            //                        //get the first _rowObject
            //                        var lRowObject = rowObjects[0];
            //                        //check if it is a related data or a child
            //                        //                        if (lRowObject._relationship && lRowObject._relationshipParentObject) {
            //                        //                            //need to delete a related data
            //                        //                            rowObject = FoundationData.deleteRelatedObject(lInMemoryData,
            //                        //lRowObject._relationship, lRowObject._relationshipParentObject /*id or object*/ , lRowObject);
            //                        //                        } else  {
            //                        rowObject = FoundationData.deleteObject(lInMemoryData, lRowObject);
            //                        //      }
            //                        for (var lCurRowObjectIdx = 1, len = rowObjects.length; lCurRowObjectIdx < len; lCurRowObjectIdx++) {
            //                            //remove
            //                            lRowObject = rowObjects[lCurRowObjectIdx];
            //                            var lRelationship = lRowObject._relationship;
            //                            if (!lRelationship && lRowObject._parentObject) {
            //                                lRelationship = "children";
            //                            }
            //                            var lParentObject;
            //                            if (lRelationship) {
            //                                lParentObject = lRowObject._relationshipParentObject || lRowObject._parentObject;
            //
            //                            }
            //                            FoundationData.__deleteObject(lInMemoryData, lRowObject);
            //                            if (lRelationship && lParentObject && lParentObject._mvcModel) {
            //                                lParentObject._mvcModel._fireRelationshipChangeEvents(lRelationship, {});
            //                            }
            //                        }
            //
            //                    } else {
            //                        rowObject = FoundationData.deleteObject(lInMemoryData, modelOrId);
            //                    }
            //                    break;
            //                }
            //            }
            //            return rowObject;
            //        },
            /**
             * retrieves a related object by physicalid.
             * this will either retrieve an existing object based on the requested relationship (object could come from any parent)
             * or it will create a new one and fetch data from the server.
             * @param {String} iRelationName the name of the related data ('assignees' for instance)
             * @param {String} iPhysicalId the id of the related data to retrieve.  This should be a physicalId, not an objectId
             * @param {Boolean} iDontFetch if the fetch call shouldn't be sent
             * @param {Boolean} iDontCreate if we shouldn't create a placeholder in case the object is not found (only works in conjunction with iDontFetch
             * @param {Object} options the options object
             *                 options.attributes list of attributes to be included in the model when adding it to collection
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
                    var lInputObject = UWA.clone(options && options.attributes || {}, false);
                    lInputObject.id = iPhysicalId;
                    lRetObject = lChildCollection.add(lInputObject, {
                        existingObject: true
                    });
                    //TODO: now need to make a server call to get the actual object
                    if (!iDontFetch) {
                        lRetObject.fetch(options);
                    }

                }
                return lRetObject;
            },
            /**
             * override fetch.
             * if the options do not explicitly have a merge: false add merge: true so that rowObjects of multiinstanciated models are correctly set
             */
            fetch: function(options) {
                var lOptions = options || {};
                if (lOptions.merge !== false) {
                    lOptions.merge = true;
                }
                return this._parent(lOptions);
            },
            /**
             * override sync
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
                        //compute service url
                        //  var lServiceName = buildUrl(this._serviceName, this._initialLoadOptions);
                        //bcc: note no syncrhonization between client and server here, we just eraze all.  Maybe a bit violent.
                        FoundationData.loadServiceData(lOptions.url || this._serviceName, function(data) {
                            //do a systematic reset since we need to make sure that we will not keep objects pointing to the old data structure
                            //                       // options.reset = true;
                            //also reset all our children Collection otherwise there may be some old MVC models pointing to the previous data
                            //we will erase whatever is in our collection and in our children collection
                            if (lOptions.remove !== false) {
                                that.__emptyCompletely();
                            }
                            //initialize the tags
                            var lInMemoryData = that.data();
                            if (lInMemoryData) {
                                FoundationData._setInternalProperty(data, 'tnProxy', lInMemoryData.tnProxy);
                            }
                            if (!lOptions.noTag) {
                                WidgetTagNavInit.loadTagData(data);
                            }

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
                        }, /*isPost*/ lOptions.method === 'POST', /*postData*/ lOptions.data, /*iContentType*/ lOptions.contentType, /*iUrlParams*/ this._initialLoadOptions);
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
                            var rowObject = model.updateModelInFoundation(method, options);

                            var applyUpdatesCallback = function applyUpdatesCallback(success, data, clonedInfo) {
                                if (success) { //bcc: code bellow may not be needed anymore as the sync from foundation would have updated the models
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
            },
            /**
             * takes a list of models and complete them by calling the complete service
             */
            complete: function(iToComplete) {
                var lToComplete;
                if (UWA.is(iToComplete, 'object')) {
                    lToComplete = [iToComplete];
                } else {
                    lToComplete = iToComplete.filter(function(iElem) { //filter out non foundation models like RDF ones for instance
                        return iElem instanceof FoundationBaseModel;
                    });
                }
                //  var lServiceName = buildUrl(this._serviceName, this.completeOptions);
                if (this.lastReadFrom !== 'local') {
                    if (!this.completing) {
                        //add our list of ids
                        var lIdList = [];
                        for (var lToCompleteIdx = 0, len = lToComplete.length; lToCompleteIdx < len; lToCompleteIdx++) {
                            var lCurToComplete = lToComplete[lToCompleteIdx];
                            if (!lCurToComplete.completing && !lCurToComplete.completed) {
                                lCurToComplete.completing = true;
                                lIdList.push(lCurToComplete.id);
                            }
                        }
                        if (lIdList.length) {

                            var postData = '$ids=' + lIdList.join();
                            var that = this;
                            this.completing = true;
                            FoundationData.loadServiceData(this._serviceName, function(data) {
                                //retrieve the datagroups
                                var lInMemoryData = that.data();
                                //make a first level only index
                                FoundationData.__refreshIndexCache(data, true, true);
                                //bcc: complete objects in order so that when Foundation only returns the first of multi instanciated related data  as a full object we do read their attributes
                                var lNbObjectToComplete = lToComplete.length;
                                for (var lCurObjectToCompleteIdx = 0; lCurObjectToCompleteIdx < lNbObjectToComplete; lCurObjectToCompleteIdx++) {
                                    var lCurObjectToComplete = lToComplete[lCurObjectToCompleteIdx];
                                    lCurObjectToComplete.syncFromServer(data);
                                    delete lCurObjectToComplete.completing;
                                    lCurObjectToComplete.completed = true;
                                }
                                if (lInMemoryData) {
                                    FoundationData.__updateCsrf(lInMemoryData, data);
                                }

                                that.completing = false;
                                //if we had some complete operations buffered, treat them
                                if (that.toComplete && that.toComplete.length) {
                                    var toComplete = that.toComplete;
                                    delete that.toComplete;
                                    that.complete(toComplete);
                                }
                            }, /*isPost*/ true, /*postData*/ postData, /*iContentType*/ 'application/x-www-form-urlencoded', /*iUrlParams*/ this._completeOptions);
                        }
                    } else {
                        //queue the things to complete
                        if (!this.toComplete) {
                            this.toComplete = [];
                        }
                        Array.prototype.push.apply(this.toComplete, lToComplete);
                    }
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
             * @return storage for this collection
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

/*global define*/
define('DS/Foundation2/Collections/ProxyFoundationBaseCollection', //define module
    ['UWA/Core', 'UWA/Class/Model', 'DS/Foundation2/Collections/FoundationBaseCollection',
    'DS/Foundation2/Models/ProxyReferenceModel', 'DS/Foundation2/Models/ReferenceModel'], //prereqs

    function(UWA, Model, FoundationBaseCollection, ProxyReferenceModel, ReferenceModel) {
        'use strict';

        var ProxyFoundationBaseCollection = FoundationBaseCollection.childCollection.extend({
            _uwaClassName: 'ProxyFoundationBaseCollection',
            /**
             * Method ovveridden to customize the model constructor.
             * We need specialised model in case dealing with 3ddrive
             * @param  {Object} attrs   list of attributes to be added on the model being prepared
             * @param  {Object} options options object
             * @return {Boolean}         false
             */
            _prepareModel: function(attrs, options) {
                var model;
                if (attrs instanceof Model) {
                    if (!attrs.collection) {
                        attrs.collection = this;
                    }
                    return attrs;
                }
                options = UWA.is(options) ? UWA.clone(options, false) : {};
                options.collection = this;
                var ModelConstructor = attrs.service === '3DDrive' ? ProxyReferenceModel : ReferenceModel;
                model = new ModelConstructor(attrs, options);
                if (!model.validationError) {
                    return model;
                }
                this.dispatchEvent('onValidationFailure', [this, model.validationError, options]);
                return false;
            }
        });
        return ProxyFoundationBaseCollection;
    });

