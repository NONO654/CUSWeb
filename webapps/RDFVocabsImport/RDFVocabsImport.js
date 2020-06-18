/*global define*/

define('DS/RDFVocabsImport/utils/Utils', [
    'UWA/Core'
], function (Core) {
    'use strict';

    var exports;

    exports = {
        result: function (object, property) {
            var value;
            if (!object) {
                return null;
            }
            value = object[property];
            if ((Core.typeOf(value)) === 'function') {
                return value.call(object);
            }
            return value;
        }
    };

    return exports;

});

/*global define*/

define('DS/RDFVocabsImport/model/Debuggable', [
    'UWA/Core',
    'UWA/Class/Debug'
], function (Core, Debug) {
    'use strict';

    var Debuggable;

    Debuggable = Debug.extend({

        log: function (message) {
            return this._parent(String.prototype.format.apply('{0}: {1}'.format(Core.is(this.name, 'string') ? this.name : '[UNKNOWN]', message),
                                [].slice.call(arguments, 1)));
        }
    });

    return Debuggable;
});

/*global
    define
*/

define('DS/RDFVocabsImport/view/CollaborativeStoragesView', [
    'UWA/Core',
    'UWA/Class/Listener',
    'DS/UIKIT/Input/Select',
    'DS/RDFVocabsImport/model/Debuggable',
    'DS/RDFVocabsImport/utils/Utils'
], function (Core, Listener, Select, Debuggable, Utils) {

    'use strict';

    var CollaborativeStoragesView;

    //////////////////////////////////////
    //
    // Extension of UWA's Input.Select
    // to list the available Collaborative Storages
    //
    //////////////////////////////////////

    CollaborativeStoragesView = Select.extend(Debuggable, Listener, {

        // the _UWA_ Class Name, used by Debuggable mixin for logging :
        name: 'CollaborativeStoragesView',

        defaultOptions: {
            placeholder: false
        },

        // LIFECYCLE
        //
        ////////////

        init: function (options) {
            this._parent({
                events: {
                    onChange: this._onChangeOfCollabStorage
                }
            });

            //SGA5: IR-506846: The tenant should not be displayed directly in the widget 
            //this.getContent().setStyle('max-width', '700px');

            // This line of code to constraint the dropdown to a maximum height
            // of 150px. TODO: This should not be here (access to "private" DOM
            // of the Select component) and the computation should be done by
            // the Select component itself !
            /* this.getContent().getElement('.select-results').setStyle('max-height', '150px');*/

            this.debugMode = Utils.result(options, 'debugMode');
            this.collabStorages = options.collabStorages;
            this.listenTo(this.collabStorages, 'onReset', this.render);
        },

        destroy: function () {
            this.stopListening();
            this._parent();
        },

        // CALLBACKS FOR MODEL EVENTS
        //
        /////////////////////////////

        render: function () {
            this.remove().add(this.collabStorages.map(function (collabStorage) {
                return {
                    label: collabStorage.get('displayName'),
                    value: collabStorage.id
                };
            }, this));
        },

        // CALLBACKS FOR DOM EVENTS
        //
        ///////////////////////////

        _onChangeOfCollabStorage: function () {
            var selectedCollabStorage = this.collabStorages.get(this.getValue()[0]);
            this.log('Collab Storage "{0}" selected', selectedCollabStorage.get('displayName'));
            this.dispatchEvent('onChangeOfCollabStorage', [selectedCollabStorage]);
        }
    });

    return CollaborativeStoragesView;
});

/*global define*/

define('DS/RDFVocabsImport/model/CollabStorage', [
    'DS/RDFVocabsImport/model/Debuggable',
    'UWA/Class/Model',
    'UWA/Core'
], function (Debuggable, Model, Core) {
    'use strict';

    var CollabStorage;

    CollabStorage = Model.extend(Debuggable, {
        // the _UWA_ Class Name, used by Debuggable mixin for logging :
        name: 'CollabStorage'
    });

    return CollabStorage;
});

/*global define*/

'use strict';

define('DS/RDFVocabsImport/model/Vocabulary', [
  'DS/RDFVocabsImport/utils/Utils',
  'DS/RDFVocabsImport/model/Debuggable',
  'UWA/Class/Model',
  'UWA/Core',
  'UWA/Utils',
  'DS/WAFData/WAFData',
  'DS/FedDictionaryAccess/RequestUtils'
], function (Utils, Debuggable, Model, Core, UWAUtils, WAFData, RequestUtils) {
  var Vocabulary;

  Vocabulary = Model.extend(Debuggable, {
    // the _UWA_ Class Name, used by Debuggable mixin for logging :
    name: 'Vocabulary',

    idAttribute: 'name',

    convertResultTo2018x: function (result) {
      if (result.curi) {
        result.name = result.curi.substring(0, result.curi.length - 1);
      } else {
        result.name = result.uri;
      }
      result.nlsName = result.label;
      return result;
    },

    convertMessageToError: function (errMessage) {
      var errCode = 500;
      var pos = errMessage.indexOf('ResponseCode with value "');
      if (pos > -1) {
        errCode = errMessage.substring(pos + 25, pos + 28);
      }
      return { error: { code: errCode } };
    },

    destroy: function (options) {
      var tagsURL = this.collection.Tagsurl(),
        SpaceURL = this.collection.url();

      if (tagsURL !== '' && tagsURL !== SpaceURL) {
        var that = this;

        var url =
          this.collection.Tagsurl() +
          '/CustomVocabulary?' +
          UWAUtils.toQueryString(this.pick(this.idAttribute)) +
          '&' +
          UWAUtils.toQueryString({
            tenant: this.collection.collabSpaceId
          });

        var request = function (response) {
          var res = JSON.parse(response);
          var headers = {};
          headers[res.csrf.name] = res.csrf.value;
          headers['Content-Type'] = 'text/plain';

          that.collection.requestWAFData(
            url,
            'DELETE',
            headers,
            '',
            options,
            function () {
              // console.log('deletion tags OK');
            },
            function () {
              // console.log('deletion tags KO');
            }
          );
        };

        var csrf = this.collection.setCSRF(this.collection.getTagUrl(), request);

        WAFData.authenticatedRequest(csrf.url, csrf);
      }
      return this._parent(Core.merge({ operation: 'delete' }, options));
    },

    save: function (dummy, options) {
      var tagsURL = this.collection.Tagsurl(),
        SpaceURL = this.collection.url();

      if (tagsURL !== '' && tagsURL !== SpaceURL) {
        var that = this;

        var url =
          this.collection.Tagsurl() +
          '/CustomVocabulary?' +
          UWAUtils.toQueryString({
            tenant: this.collection.collabSpaceId
          });

        var request = function (response) {
          var res = JSON.parse(response);
          var headers = {};
          headers[res.csrf.name] = res.csrf.value;
          headers['Content-Type'] = 'text/plain';

          that.collection.requestWAFData(
            url,
            'POST',
            headers,
            '',
            options,
            function () {
              // console.log('creation tags OK');
            },
            function () {
              // console.log('creation tags KO');
            }
          );
        };
        var csrf = this.collection.setCSRF(this.collection.getTagUrl(), request);

        WAFData.authenticatedRequest(csrf.url, csrf);
      }
      return this._parent(null, Core.merge({ operation: this.isNew() ? 'create' : 'update' }, options));
    },

    sync: function (method, model, options) {
      var that = this;
      var request = function (response) {
        var res = JSON.parse(response);
        var headers = {};
        headers[res.csrf.name] = res.csrf.value;
        headers['Content-Type'] = 'application/xml';
        switch (method) {
          case 'create':
          case 'update':
            var createURL = that.collection.url() + '/CustomVocabulary?' + UWAUtils.toQueryString({ tenant: that.collection.collabSpaceId });

            // SGA5: first, call RDF deploy
            if (that.collection.hardcodedRDFBaseURL || (that.collection.isRDF && that.collection.rdfBaseURl)) {
              var baseRDFURL = that.collection.hardcodedRDFBaseURL;
              if (!baseRDFURL) {
                baseRDFURL = that.collection.rdfBaseURl + '/' + that.collection.RDFPilar + '/' + that.collection.wsRDFVersion + '/invoke/';
              }

              var fileNameNoExt = options.filename;
              if (options.filename && options.filename.lastIndexOf('.') > -1) {
                fileNameNoExt = options.filename.substring(0, options.filename.lastIndexOf('.'));
              }

              RequestUtils.sendRequest(
                baseRDFURL + 'dsbase:deployVocabulary',
                {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
                  timeout: 30000,
                  type: 'json',
                  data: JSON.stringify([options.data, fileNameNoExt, true]),
                  onFailure: function (error) {
                    // stop execution here, display error message
                    // console.log('creation RDF KO');
                    options.onFailure(that.convertMessageToError(error.message));
                  },
                  onComplete: function (result) {
                    // console.log('creation RDF OK');
                    // try to call 3DSpace/6W now
                    that.collection.requestWAFData(
                      createURL,
                      'POST',
                      headers,
                      'json',
                      options,
                      function () {
                        // console.log('creation 3DSpace/6W OK');
                        // everything's fine! Call callback
                        options.onComplete(that.convertResultTo2018x(result['@result']));
                      },
                      function (model) {
                        // console.log('creation 3DSpace/6W KO');
                        if (model.message.contains(409)) {
                          // vocabulary is already created on 3DSpace/6W, it is ok!
                          // console.log('a vocabulary already exists on 3DSpace/6W');
                          options.onComplete(that.convertResultTo2018x(result['@result']));
                        } else {
                          // 3DSpace/6W creation KO --> undeploy vocab from RDF
                          RequestUtils.sendRequest(
                            baseRDFURL + 'dsbase:undeployVocabulary',
                            {
                              method: 'POST',
                              headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
                              timeout: 30000,
                              type: 'json',
                              data: JSON.stringify([result['@result'].vocabulary]),
                              onFailure: function () {
                                // console.log('deletion RDF KO');
                              },
                              onComplete: function () {
                                // console.log('deletion RDF OK');
                              }
                            },
                            that.collection.isRDFWithoutAuth
                          );
                          options.onFailure(that.convertMessageToError(model.message));
                        }
                      }
                    );
                  }
                },
                that.collection.isRDFWithoutAuth
              );
            } else {
              that.collection.requestWAFData(
                createURL,
                'POST',
                headers,
                'json',
                options,
                function (result) {
                  options.onComplete(result);
                },
                function (error) {
                  options.onFailure(that.convertMessageToError(error.message));
                }
              );
            }
            break;
          case 'delete':
            var deleteURL =
              that.collection.url() + '/CustomVocabulary?' + UWAUtils.toQueryString(that.pick(that.idAttribute)) + '&' + UWAUtils.toQueryString({ tenant: that.collection.collabSpaceId });

            if (that.collection.hardcodedRDFBaseURL || (that.collection.isRDF && that.collection.rdfBaseURl)) {
              var vocab = '';
              if (that.get('namespace')) {
                vocab = '<' + that.get('namespace') + '>';
              } else {
                vocab = that.get('uri');
              }

              baseRDFURL = that.collection.hardcodedRDFBaseURL;
              if (!baseRDFURL) {
                baseRDFURL = that.collection.rdfBaseURl + '/' + that.collection.RDFPilar + '/' + that.collection.wsRDFVersion + '/invoke';
              }
              RequestUtils.sendRequest(
                baseRDFURL + 'dsbase:undeployVocabulary',
                {
                  method: 'POST',
                  headers: {
                    'Content-Type': 'application/json',
                    Accept: 'application/json'
                  },
                  timeout: 30000,
                  type: 'json',
                  data: JSON.stringify([vocab]),
                  onFailure: function (error) {
                    // console.log('deletion RDF KO');
                    options.onFailure(that.convertMessageToError(error.message));
                  },
                  onComplete: function (result) {
                    // console.log('deletion RDF OK');
                    // try to call 3DSpace/6W now
                    that.collection.requestWAFData(
                      deleteURL,
                      'DELETE',
                      headers,
                      '',
                      options,
                      function () {
                        // console.log('deletion 3DSpace/6W OK');
                        // everything's fine! Call callback
                        options.onComplete(result['@result']);
                      },
                      function () {
                        // console.log('deletion 3DSpace/6W KO');
                        // 3DSpace call was KO but we cannot undo the operation in RDF
                        options.onComplete(result['@result']);
                      }
                    );
                  }
                },
                that.collection.isRDFWithoutAuth
              );
            } else {
              that.collection.requestWAFData(
                deleteURL,
                'DELETE',
                headers,
                '',
                options,
                function (result) {
                  // console.log('deletion 3DSpace/6W OK');
                  options.onComplete(result);
                },
                function (error) {
                  // console.log('deletion 3DSpace/6W KO');
                  if (error.message.includes('timedout')) {
                    options.onFailure('Timeout');
                  } else {
                    options.onFailure(that.convertMessageToError(error.message));
                  }
                }
              );
            }
            break;
          default:
            return that._parent(
              method,
              model,
              Core.merge(
                {
                  proxy: 'passport'
                },
                options
              )
            );
        }
      };
      var csrf = this.collection.setCSRF(this.collection.baseUrl, request);
      WAFData.authenticatedRequest(csrf.url, csrf);
    }
  });

  return Vocabulary;
});

/*global
    define, window
*/

define('DS/RDFVocabsImport/view/RDFImportView', [
    'i18n!DS/RDFVocabsImport/assets/nls/RDFVocabsImport',
    'UWA/Core',
    'DS/UIKIT/Input/Button',
    'UWA/Class/View',
    'DS/RDFVocabsImport/model/Debuggable',
    'DS/RDFVocabsImport/utils/Utils'
], function (NLSKeys, Core, Button, View, Debuggable, Utils) {

    'use strict';

    var RDFImportView, readerEventToCbMapping;

    readerEventToCbMapping = {
        error: '_onError',
        load: '_onLoad',
        loadstart: '_onLoadStart',
        progress: '_onProgress'
    };

    function humanFileSize(bytes) {
        var units, u;
        if (1024 > bytes) {
            return bytes + ' B';
        }
        units = ['kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
        u = -1;
        do {
            bytes /= 1024;
            ++u;
        } while (1024 <= bytes);
        return bytes.toFixed() + ' ' + units[u];
    }

    // A temporary utility function to iterate over an object.
    // The iterator is bound to the context object, if one is passed.
    // Each invocation of iterator is called with three arguments: (value, key, obj).
    function forEach(obj, iterator, context) {
        
        var i, length, keys;
        if (!Core.is(obj, 'object')) {
            return obj;
        }
        keys = Object.keys(obj);
        for (i = 0, length = keys.length; i < length; i++) {
            iterator.call(context, obj[keys[i]], keys[i], obj);
        }
        return obj;
    }

    RDFImportView = View.extend(Debuggable, {

        // the _UWA_ Class Name, used by Debuggable mixin for logging :
        name: 'RDFImportView',

        filename: '',

        // BINDINGS TO DOM EVENTS :
        //
        //////////////////////////////

        domEvents: {
            'click button.choose': '_onBrowse',
            'click input[type=text]': '_onBrowse',
            'click button.import': '_import',
            'change input[id=RDFFileInput]': '_onRDFFileSelected'
        },

        // LIFECYCLE : SETUP, TEARDOWN
        //
        //////////////////////////////

        setup: function (options) {
            
            var that = this;

            // Enable or disable debug mode
            that.debugMode = Utils.result(options, 'debugMode');

            that.appView = options.appView;

            // Totally disable the UI if the browser does not support the File API :
            if (window.File && window.FileList && window.FileReader) {

                that._reader = new window.FileReader(); // Core.is(that._reader) means that FileReader API is supported ...

                // register listeners of events emitted by the FileReader :
                forEach(readerEventToCbMapping, function (cbName, evtName) {
                    this.addEventListener(evtName, that[cbName].bind(that));
                }, that._reader);
            }
        },

        destroy: function () {
            
            var that = this;

            // remove listeners of events emitted by the FileReader :
            forEach(readerEventToCbMapping, function (cbName, evtName) {
                this.removeEventListener(evtName, that[cbName].bind(that));
            }, that._reader);

            that._reader = null;

            that.appView = null;

            that._parent();
        },

        // RENDERING
        //
        ///////

        render: function () {
            
            //SGA5: IR-506846: The tenant should not be displayed directly in the widget 
            if (!this.getElement('button.import')) {
                var importBtn = new Button({
                    value: NLSKeys.import_btn_label,
                    'className': 'default import',
                    icon: 'upload',
                    attributes: {
                        styles: {
                            'margin-left': '20px'
                        }
                    }
                });
                importBtn.inject(this.container);
            }

            // keep references on some elements :
            forEach({
                fileinput: 'input[id=RDFFileInput]',
                filename: 'input[type=text]',
                importBtn: 'button.import',
                browseBtn: 'button.choose'
            }, function (cssSelector, elemRefName) {
                this['$' + elemRefName] = this.getElement(cssSelector);
            }, this);

            // i18n :
            this.$filename.placeholder = NLSKeys.rdf_file_import_btn_label_alt;
            this.$browseBtn.setText(NLSKeys.choose_btn_label);

            this.reset();

            return this;
        },

        // RESETTING
        //
        ///////

        reset: function () {
            
            this.$importBtn.disabled = true;
            if (this._reader) {
                this.$filename.value = null;
                try {
                    this.$fileinput.value = null;
                } catch (ignore) { }
                if (this.$fileinput.value) {
                    this.$fileinput.parentNode.replaceChild(this.$fileinput.cloneNode(true), this.$fileinput);
                }
                this._file = null;
            } else {
                // FileReader API not supported :
                this.log('the browser doesn\'t support the FileReader API');
                this.$browseBtn.disabled = true;
                this.$filename.disabled = true;
            }
            return this;
        },

        // CALLBACKS FOR DOM EVENTS
        //
        ///////////////////////////

        _onBrowse: function () {
            
            this.reset();
            this.$fileinput.click();
        },

        _import: function () {
            
            if (this._file) {
                this._reader.readAsText(this._file); // encoding is UTF-8 by default.
                this.reset();
            }
        },

        _onRDFFileSelected: function () {
            
            var files, file, that = this;

            files = that.$fileinput.files; // FileList object
            if (files) {
                file = files[0];
                if (file) {
                    this.filename = file.name;
                    if (0 < file.size) {
                        that._file = file;
                        this.$filename.value = this.filename;
                        this.$importBtn.disabled = false;
                    } else {
                        this.appView.warn(NLSKeys.import_fail_cause_empty);
                    }
                }
            }
        },

        //
        // INTERNAL CALLBACK
        //
        ////////////////////

        _onImportEnd: function () {
            
            if (this._timerId) { // not yet masked, prevent masking from happening !
                window.clearTimeout(this._timerId);
                this._timerId = null;
            } else {
                this.appView.unmask();
            }
        },

        // CALLBACKS FOR FILEREADER EVENTS
        //
        //////////////////////////////////

        // Called each time the reading operation encounter an error :
        _onError: function () {
            
            this._reader.abort();
            this._onImportEnd();
        },

        // Called each time the reading operation is successfully completed :
        _onLoad: function () {
            
            var that = this;
            var startTime = Date.now();
            that.collection.create({}, {
                at: that.collection.length, // so that the new vocabulary is imported
                // at the end of the cached collection
                parse: false, // A temporary workaround until fix https://ops.netvibes.com/issues/16595
                // is in SCM (UWAClient)
                data: that._reader.result,
                filename: that.filename,
                merge: true, // so that existing Vocabs in that.collection can be updated !
                wait: true, // of course. Otherwise one could delete a resource
                // that has not yet been created...
                onComplete: that._onImportEnd.bind(that),
                onFailure: function (vocab, error, options) {
                    that._onImportEnd();

                    if(Date.now() - startTime > 29500){
                        that.collection.dispatchEvent('onTimeout', [vocab, error, options]);                     
                    } else {
                        that.collection.dispatchEvent('onError', [vocab, error, options]);  
                    }
                }
            });
        },

        // Called each time the reading is starting :
        _onLoadStart: function () {
            
            var that = this;
            that._timerId = window.setTimeout(function () {
                that.appView.mask(NLSKeys.plz_wait_while_importing);
                that._timerId = null;
            }, 1000); // no special visual feedback (loading indicator)
            // is necessary during delays less than one second.
        },

        // Regularly called while reading a Blob content :
        _onProgress: function (progressEvent) {
            
            if (progressEvent.lengthComputable) {
                this.log('{0}% of blob loaded...', Math.round(100 * progressEvent.loaded / progressEvent.total));
            }
        }
    });

    return RDFImportView;

});

/*global define, UWA, widget*/

'use strict';

define('DS/RDFVocabsImport/model/Vocabularies', [
  'DS/RDFVocabsImport/utils/Utils',
  'DS/PlatformAPI/PlatformAPI',
  'DS/RDFVocabsImport/model/Vocabulary',
  'UWA/Class/Collection',
  'DS/RDFVocabsImport/model/Debuggable',
  'UWA/Core',
  'UWA/Utils',
  'text!DS/FedDictionaryAccess/assets/FedDicoSettings.json',
  'DS/FedDictionaryAccess/FedDictionaryAccessAPI',
  'DS/WAFData/WAFData'
], function(Utils, PlatformAPI, Vocabulary, Collection, Debuggable, Core, UWAUtils, Settings, FedDictionaryAccessAPI, WAFData) {
  var Vocabularies;

  Vocabularies = Collection.extend(Debuggable, {
    // the _UWA_ Class Name, used by Debuggable
    // mixin for logging :
    name: 'Vocabularies',

    // this is a Collection of Vocabulary models :
    model: Vocabulary,

    // vocabularies are alphabetically sorted based
    // on their names.
    comparator: 'name',

    // SGA5: add RDF URL
    rdfBaseURl: '',

    isRDF: false,

    wsRDFVersion: 'v0',

    RDFPilar: '3drdfpersist',

    hardcodedRDFBaseURL: '',

    isRDFWithoutAuth: false,

    settings: {},

    init: function() {
      this.settings = JSON.parse(Settings);
      this._parent.apply(this, arguments);
      if (this.settings.RDFFedVocabulariesOn3DSpace && this.settings.RDFFedVocabulariesOn3DSpace === 'false') {
        this.isRDF = true;
        if (this.settings.RDFPPVersion) {
          this.wsRDFVersion = this.settings.RDFPPVersion;
        }
        /*if (this.settings.RDFPilar) {
						this.RDFPilar = this.settings.RDFPilar;
					}*/
        if (this.settings.RDFServerURL) {
          this.hardcodedRDFBaseURL = this.settings.RDFServerURL;
        }
        if (this.settings.isRDFWithAuth && this.settings.isRDFWithAuth === 'false') {
          this.isRDFWithoutAuth = true;
        }
      }
    },

    // Remember this is called by Model.url()
    // default implementation, used
    // by Vocabulary class consequently ! :
    url: function() {
      if (!this.baseUrl) {
        throw new Error('No base Url');
      }
      return this.baseUrl + '/resources/6WVocab/access';
    },
    Tagsurl: function() {
      if (!this.base6WTagsUrl) {
        return this.baseUrl + '/resources/6WVocab/access';
      }
      return this.base6WTagsUrl + '/resources/6WVocab/access';
    },
    getTagUrl: function() {
      if (!this.base6WTagsUrl) {
        return this.baseUrl;
      }
      return this.base6WTagsUrl;
    },
    setCSRF: function(url, request) {
      var csrf = {};
      csrf.url = url + '/resources/v1/application/CSRF';

      csrf.onComplete = request;
      csrf.onFailure = function() {
        // console.log('csrf token KO');
      };
      return csrf;
    },
    requestWAFData: function(url, method, headers, type, opt, complete, failure) {
      WAFData.authenticatedRequest(url, {
        method: method,
        headers: headers,
        timeout: '30000',
        type: type,
        proxy: 'passport',
        data: opt.data,
        onComplete: complete,
        onFailure: failure
      });
    },
    fetch: function(options) {
      var url, is6W, collabSpaceId;

      url = Utils.result(options, 'url');
      is6W = Utils.result(options, 'is6W');
      collabSpaceId = Utils.result(options, 'collabSpaceId');

      // SGA5: RDF base URL
      this.rdfBaseURl = Utils.result(options, 'baseRDFUrl');

      // SGA5: IR-626810 base6WTagsUrl needs to be set
      this.base6WTagsUrl = Utils.result(options, 'base6WTagsUrl');

      // change some instance values only if valid
      // :
      if (UWAUtils.isValidUrl(url) && collabSpaceId) {
        if (!is6W) {
          this.baseUrl = UWAUtils.composeUrl(UWAUtils.parseUrl(url)); // this
          url = this.url();
        } else {
          this.base6WTagsUrl = UWAUtils.composeUrl(UWAUtils.parseUrl(url)); // this
          url = this.Tagsurl();
        }
        this.collabSpaceId = collabSpaceId;
      }

      // SGA5: if OnPremise environment without hardcoded RDF URL --> no RDF usage
      if (this.isRDF && 'OnPremise' === this.collabSpaceId && !this.hardcodedRDFBaseURL) {
        this.isRDF = false;
      }

      /*
       * if (UWAUtils.isValidUrl(base6WTagsUrl))
       * this.base6WTagsUrl = UWAUtils.composeUrl(UWAUtils
       * .parseUrl(base6WTagsUrl)); // this
       */
      /*return this._parent(Core.merge({
					operation : 'read',
					proxy : 'passport', // The usual stuff.
					url : url + '/Vocabularies', // This is needed because Vocabulary Modeler Team does not provide a real RESTful API.
					// This will throw an Error if no (or unvalid) base URL was passed.
					reset : false, // empty the collection before fetch&fill
					type : 'json', // TODO: Will not be needed anymore after upcoming fix in UWA.
					headers : {
						'Accept' : 'application/json',
						'Cache-Control' : 'no-cache',
						'Pragma' : 'no-cache',
						'Accept-Language' : widget.lang
					},
					validate : true, // TODO: This is probably not needed.
					data : { // for the url query parameters...
						filter : 'all',
						tenant : this.collabSpaceId
					}
				}, options));*/
      this._parent({ reset: false, operation: 'read' });
    },

    parse: function(serverJSONResponse) {
      return serverJSONResponse.vocabularyInfo;
    },

    sync: function(method, model, options) {
      var that = this;
      var callbackObj = {
        onComplete: function(result) {
          UWA.log('retrieval vocabs OK');
          options.onComplete(result);
        },
        onFailure: function() {
          UWA.log('retrieval vocabs KO');
          options.onFailure('retrieval vocabs KO');
          return {
            cancel: function() {}
          };
        },
        tenantId: that.collabSpaceId,
        lang: widget.lang,
        apiVersion: 'R2018x'
      };
      if (that.hardcodedRDFBaseURL) {
        callbackObj.RDFServiceURL = that.hardcodedRDFBaseURL;
        callbackObj.OnPremiseWith3DRDF = 'true';
      }
      FedDictionaryAccessAPI.getFedVocabularies(callbackObj);
    }
  });

  return Vocabularies;
});

/*global
    define, document
 */

define(
	'DS/RDFVocabsImport/view/VocabularyView',
	['i18n!DS/RDFVocabsImport/assets/nls/RDFVocabsImport', 'DS/UWPClientCode/I18n',
		'UWA/Class/View', 'DS/RDFVocabsImport/model/Debuggable',
		'DS/UIKIT/Input/Button', 'DS/UIKIT/SuperModal'],
	function (NLSKeys, i18n, View, Debuggable, Button, SuperModal) {

		'use strict';

		var cachedRegExp, VocabularyView, ds6wVocabHTML, vocabHTML;

		cachedRegExp = /\{(\w+)\}/g;

		// Let's i18n and cache only once the HTML :
		ds6wVocabHTML = '<td>{nlsName}</td><td>{description}</td><td></td>';
		vocabHTML = '<td>{nlsName}</td><td>{description}</td>'
			+ '<td><button type="button" class="delete btn btn-warning btn-xs">'
			+ '<span class="fonticon fonticon-trash"></span>{0}</button></td>';
		vocabHTML = vocabHTML.format(NLSKeys.delete_btn_label);

		// ///////////////////////////////////////////////////
		//
		// The View for a vocabulary
		//
		// ///////////////////////////////////////////////////

		VocabularyView = View
			.extend(
				Debuggable,
				{

					// the _UWA_ Class Name, used by Debuggable
					// mixin for logging :
					name: 'VocabularyView',

					// the root container element for this view will
					// be a <tr> tag :
					tagName: 'tr',

					// hash mapping scoped DOM events to callbacks
					// in this view :
					domEvents: {
						'click button.delete': '_onDelete'
					},

					// the method to render this instance of view :
					render: function () {
						var html, that = this;
						if (that.model.get('nlsName') === undefined) {
							vocabHTML = '<td>{name}</td><td>{description}</td>'
								+ '<td><button type="button" class="delete btn btn-warning btn-xs">'
								+ '<span class="fonticon fonticon-trash"></span>{0}</button></td>';
							vocabHTML = vocabHTML
								.format(NLSKeys.delete_btn_label);
						}
						html = ('ds6w' === that.model.id
							|| 'pno' === that.model.id
							|| 'swym' === that.model.id || 'dsmer' === that.model.id) ? ds6wVocabHTML
							: vocabHTML;
						this.container.setHTML(html.replace(
							cachedRegExp,
							function (m, attrName) {
								return that.model
									.escape(attrName)
									|| '';
							}));
						return this; // by convention.
					},

					_onDelete: function () {
						var superModal, vocabName, that = this;

						// let's cache the vocab name:
						vocabName = that.model.get('name');

						superModal = new SuperModal(
							{
								closable: false,
								renderTo: document.body, // that'd
								// be
								// better
								// if
								// the
								// Platform
								// provided a PlatformModal,
								// this way we wouldn't have to
								// access
								// to the document.body...
								koButtonText: NLSKeys.delete_warning_no,
								okButtonText: NLSKeys.delete_warning_yes
							});

						superModal
							.confirm(
								NLSKeys.delete_warning_text,
								i18n
									.replace(
										NLSKeys.delete_warning_title,
										{
											vocab_name: vocabName
										}),
								function (result) {
									if (true === result) {
										// this call will
										// cause the
										// collection of
										// vocabs to emit a
										// onRemove event,
										// caught by
										// the parent
										// VocabulariesView
										// that will
										// eventually
										// destroy this
										// subview...
										// So no hara kiri
										// and call to
										// this.destroy()
										// here ....
										that.timerId = window
											.setTimeout(
												function () {
													that.options.appView
														.mask(NLSKeys.plz_wait_while_deleting);
													that.timerId = null;
												},
												1000);

										that.model
											.destroy({
												onComplete: function () {
													if (that.timerId) { // not
														// yet
														// masked,
														// prevent
														// masking
														// from
														// happening
														// !
														window
															.clearTimeout(that.timerId);
														that.timerId = null;
													} else {
														that.options.appView
															.unmask();
													}

													that
														.log(
															'vocab "{0}" successfully destroyed on the server',
															vocabName);
													that.model = null; // unecessary,
													// but
													// can
													// help
													// to
													// detect
													// bad
													// code.
												},
												onFailure: function () {
													if (that.timerId) { // not
														// yet
														// masked,
														// prevent
														// masking
														// from
														// happening
														// !
														window
															.clearTimeout(that.timerId);
														that.timerId = null;
													} else {
														that.options.appView
															.unmask();
													}
													that
														.log(
															'Failed to delete vocab "{0}" on the server',
															vocabName);
												},
												wait: true
												// Optimistic
												// reactive
												// UI does
												// not way
												// for
												// Server
												// response
												// to update
												// itself
											});
									}
								});
					}
				});

		return VocabularyView;
	});

/*global
    define
 */

define(
	'DS/RDFVocabsImport/view/VocabulariesView',
	[
		'i18n!DS/RDFVocabsImport/assets/nls/RDFVocabsImport',
		'UWA/Class/View',
		'DS/RDFVocabsImport/model/Debuggable',
		'DS/RDFVocabsImport/view/VocabularyView',
		'DS/RDFVocabsImport/utils/Utils',
		'DS/UIKIT/Scroller'
	],
	function (NLSKeys, View, Debuggable, VocabularyView, Utils, Scroller) {

		'use strict';

		var VocabulariesView, headerHTML;

		headerHTML = '<tr><th>{0}</th><th>{1}</th><th>{2}</th></tr>'
			.format(NLSKeys.vocab_name, NLSKeys.vocab_description,
				NLSKeys.vocab_actions);

		// ///////////////////////////////////////////////////
		//
		// The View for the list of vocabularies.
		//
		// ///////////////////////////////////////////////////

		VocabulariesView = View
			.extend(
				Debuggable,
				{
					// the _UWA_ Class Name, used by Debuggable
					// mixin for logging :
					name: 'VocabulariesView',

					setup: function (options) {

						this
							.listenTo(
								this.collection,
								{
									onReset: this.render,
									onAdd: this._renderVocab,
									onRemove: this._onVocabDeleted,
									onSync: this._notifySuccessfulSyncWithBackend,
									onError: this._notifySyncErrorInBackend,
									onTimeout: this._notifyTimeoutOver
								});
						this.vocabsViews = []; // should make usage
						// of Babysitter
						this.debugMode = Utils.result(options,
							'debugMode');
						this.appView = options.appView;
						this.$header = this.getElement('thead');
						this.$body = this.getElement('tbody');

						var scroll = document.getElementsByClassName("AppView")[0];
						var containerScroll = document.getElementsByClassName("moduleContent")[0];
						scroll.style.height = "100%";
						new Scroller({
							element: scroll
						}).inject(containerScroll);

					},

					render: function () {

						// In any case, clear the vocabs views :
						this._destroyVocabsViews();
						// and eventually render all the vocabs !
						this.collection.forEach(this._renderVocab,
							this);
					},

					_renderVocab: function (vocab) {

						var vocabView = new VocabularyView({
							model: vocab,
							appView: this.appView
						});
						vocabView.render().inject(this.$body);
						this.vocabsViews.push(vocabView);
						if (1 === this.vocabsViews.length) {
							this.container
								.addClassName('table-bordered');
							this.$header.setHTML(headerHTML);
						}
					},

					// Destroy the child views that this collection
					// view
					// is holding on to, if any :
					_destroyVocabsViews: function () {

						this.vocabsViews.invoke('destroy');
						this.vocabsViews = [];
						this._showEmptyHeader();
					},

					// Remove & Destroy a child view given its id
					// :
					_destroyVocabView: function (id) {

						// SGA5 5/14/2018 IR-595440
						// The way to base on model index is incorrect to remove the view, 
						// the view's model id needs to be checked to verify what view needs to be removed.
						var idx = -1;
						for (var i = 0; i < this.vocabsViews.length; i++) {
							var element = this.vocabsViews[i];
							if (element.model.id === id) {
								idx = i;
								break;
							}
						}
						if (idx > -1) {
							this.vocabsViews.splice(idx, 1).shift().destroy();
						}
						if (0 === this.vocabsViews.length) {
							this._showEmptyHeader();
						}
					},

					_showEmptyHeader: function () {

						this.container
							.removeClassName('table-bordered');
						this.$header.setHTML(NLSKeys.no_vocabs);
					},

					destroy: function () {

						// first destroy the subviews :
						this._destroyVocabsViews().vocabsViews = null;

						// then stop listening to the collection of
						// vocabularies :
						this.stopListening(this.collection);
						this.collection = null;

						// eventually call the parent implementation
						// :
						this._parent();
					},

					_onVocabDeleted: function (vocab, vocabs,
						options) {

						// listen one last time to synchro-related
						// events
						// Because when a vocab has been removed
						// from the collection of vocabularies, the
						// collection cannot relay anymore the
						// 'onSync' or 'onError' events emitted
						// by the vocab when (successfully or not)
						// destroyed in the backend, since this
						// vocab
						// is not in the collection anymore,
						// consequently not listened to anymore by
						// the collec.
						// (see
						// https://github.com/jashkenas/backbone/issues/935
						// and
						// https://github.com/jashkenas/backbone/issues/2692
						// for longer discussions about this).
						vocab
							.addEventOnce(
								'onSync',
								this._notifySuccessfulSyncWithBackend,
								this);
						vocab.addEventOnce('onError',
							this._notifySyncErrorInBackend,
							this);

						// note : The vocab's index before removal
						// is available as options.index
						this._destroyVocabView(vocab.id);
					},

					// _notifySyncErrorInBackend: Makes uses of
					// this.appView to notify
					// the user in the platform of failed CRUD
					// operations regarding Vocabularies :
					_notifySyncErrorInBackend: function (vocab,
						backendError, options) {
						var nlsKeyPrefix, nlsKeyPrefixFor, operation, notif, cause = '';

						if (backendError === 'Timeout') {
							this.appView.warn(NLSKeys.delete_fail_cause_504);
						} else {
							nlsKeyPrefixFor = {
								create: 'import',
								read: 'vocabs_fetch',
								'delete': 'delete'
							};

							operation = options.operation;

							if ('delete' === operation) {
								// silently (*) put the vocab back in
								// the collection, since we've
								// been too optimistic :
								// (*) anyway, due to a "bug" in UWA,
								// even without { silent: true },
								// no 'onAdd' event will be emitted !
								// ...
								this.collection.push(vocab, {
									silent: true
								});
								// Need to manually call _renderVocab
								// since no 'onAdd' event is fired...
								// TODO : Create unit test in UWA and
								// open ticket if necessary !!
								this._renderVocab(vocab);
							}

							// Get notification main msg & cause msg :
							nlsKeyPrefix = nlsKeyPrefixFor[operation];
							if (nlsKeyPrefix) {
								notif = NLSKeys['{0}_fail_msg'
									.format(nlsKeyPrefix)]
									.format(vocab.get('name'));
								cause = NLSKeys['{0}_fail_cause_{1}'
									.format(
										nlsKeyPrefix,
										backendError.error
										&& backendError.error.code)]
									|| NLSKeys['{0}_fail_cause_{1}'
										.format(nlsKeyPrefix, 'other')]
									;
								this.appView.error('{0}. {1}'.format(
									notif, cause.format(widget.title)));
							} else {
								throw new Error('Unexpected operation');
							}
						}
					},

					// _notifySuccessfulSyncWithBackend: Makes uses
					// of this.appView to notify
					// the user in the platform of successful CRUD
					// operations regarding Vocabularies :
					_notifySuccessfulSyncWithBackend: function (
						vocab, backendResponse, options) {

						var msg;
						switch (options.operation) {
							case 'create':
								msg = NLSKeys.import_ack_msg
									.format(vocab.get('name'));
								break;
							case 'read':
								// no notif if vocabularies are
								// successfully fetched.
								break;
							case 'delete':
								msg = NLSKeys.delete_ack_msg
									.format(vocab.get('name'));
								break;
							default:
								throw new Error('Unexpected operation');
						}
						if (msg) {
							this.appView.info(msg);
						}
					},
					_notifyTimeoutOver: function (vocab, backendResponse, options) {
						var msg;
						this.appView.warn(NLSKeys.import_fail_cause_504);
					}
				}
			);

		return VocabulariesView;
	});

/*global
    define
*/

define('DS/RDFVocabsImport/view/AppView', [
    'i18n!DS/RDFVocabsImport/assets/nls/RDFVocabsImport',
    'UWA/Class/View',
    'DS/RDFVocabsImport/model/Debuggable',
    'DS/RDFVocabsImport/view/CollaborativeStoragesView',
    'DS/RDFVocabsImport/view/VocabulariesView',
    'DS/RDFVocabsImport/view/RDFImportView',
    'DS/RDFVocabsImport/utils/Utils',
    'DS/UWPClientControls/PlatformNotify',
    'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
    'DS/UIKIT/Mask'
], function (NLSKeys, View, Debuggable, CollaborativeStoragesView, VocabulariesView,
    RDFImportView, Utils, PlatformNotify, i3DXCompassPlatformServices, Mask) {

        'use strict';

        var AppView;

        function notify(type) {
            return function (msg) {
                PlatformNotify[type](msg);
                return this;
            };
        }

        /////////////////////////////////////////////////////
        //
        // Our overall AppView : the top-level piece of UI
        //
        /////////////////////////////////////////////////////

        AppView = View.extend(Debuggable, {

            // the _UWA_ Class Name, used by Debuggable mixin for logging :
            name: 'AppView',

            // LIFECYCLE : SETUP, TEARDOWN
            //
            //////////////////////////////

            setup: function (options) {
                // enable or not debugging :
                this.debugMode = Utils.result(options, 'debugMode');

                // keep a reference on the app :
                this.app = Utils.result(options, 'app');
                // and listen to changes on its currentCollabSpaceId attr :
                //SGA5: IR-506846: The tenant should not be displayed directly in the widget 
                //this.listenTo(this.app, 'onChange:currentCollabSpaceId', this._selectCollabSpace)

                this.tenantId = widget.getValue('x3dPlatformId');
                var that = this;
                //SGA5: IR-615260: tenant name could differ from tenantId
                i3DXCompassPlatformServices.getPlatformConfig({
                    onComplete: function (platformsInfo) {
                        var tenantDisplayName = "";
                        for (var i = 0; i < platformsInfo.length; i++) {
                            var model = platformsInfo[i];
                            if (model.platformId === that.tenantId) {
                                tenantDisplayName = model.displayName;
                                break;
                            }
                        };
                        widget.setTitle(tenantDisplayName);

                    }
                });
                this.app.save('currentCollabSpaceId', this.tenantId);

                //SGA5: IR-506846: The tenant should not be displayed directly in the widget 
                // subview for the list of Collab Storages :
                /*this.collabStoragesView = new CollaborativeStoragesView({
                    collabStorages: this.app.collaborativeStorages,
                    debugMode: this.debugMode
                });*/


                // subview for the list of vocabularies of currently
                // selected Collab Storage :
                this.vocabulariesView = new VocabulariesView({
                    collection: this.app.vocabularies,
                    debugMode: this.debugMode,
                    appView: this,
                    container: this.getElement('table.vocabularies') // progressive
                    // enhancement of
                    // existing widget's
                    // HTML.
                });

                // subview to upload a RDF file :
                this.rdfImportView = new RDFImportView({
                    collection: this.app.vocabularies,
                    debugMode: this.debugMode,
                    appView: this,
                    container: this.getElement('div.RDFImportView') // progressive
                    // enhancement of
                    // existing widget's
                    // HTML.
                });

                //SGA5: IR-506846: The tenant should not be displayed directly in the widget 
                // Listen to some events of my subViews :
                //this.listenTo(this.collabStoragesView, 'onChangeOfCollabStorage', this._onChangeOfCollabStorage);         
            },

            destroy: function () {
                // 1) stop listening to the app ...
                this.stopListening(this.app);

                //SGA5: IR-506846: The tenant should not be displayed directly in the widget 
                // 2) stop listening to child views ...
                //this.stopListening(this.collabStoragesView);

                // 3) destroy child views
                //this.collabStoragesView.destroy();
                this.vocabulariesView.destroy();
                this.rdfImportView.destroy();

                // 4) destroy yourself.
                this._parent();
            },

            // RENDERING
            //
            ////////////

            render: function () {
                // this.getElement('.vocabs_for_tenant').setText(NLSKeys.vocabs_list_header + " " + this.tenantId);
                // RMI10: IR-645878 platform name update 
                this.getElement('.vocabs_for_tenant').setText("List of available vocabularies");

                //SGA5: IR-506846: The tenant should not be displayed directly in the widget 
                //this.collabStoragesView.inject(this.getElement('.tenant_select')); // cannot call render() since CollaborativeStoragesView is an UWA Control.
                this.rdfImportView.render(); // this will render the 'Import' button.

                return this;
            },
            // CALLBACKS FOR SUBVIEWS EVENTS :
            //
            //////////////////////////////////
            //SGA5: IR-506846: The tenant should not be displayed directly in the widget 
            // _onChangeOfCollabStorage: function (currentCollabSpace) {
            //     this.app.save('currentCollabSpaceId', currentCollabSpace.id);
            //     widget.setTitle(currentCollabSpace.get('displayName'));
            // },

            // CALLBACKS FOR APP EVENTS :
            //
            //////////////////////////////////
            //SGA5: IR-506846: The tenant should not be displayed directly in the widget 
            /*_selectCollabSpace: function (app, newCurrentCollabSpaceId) {
                this.collabStoragesView.select(newCurrentCollabSpaceId); // _most_ of the time, this will have no effect.
            },*/

            // APIS TO DISPLAY NOTIFICATIONS IN THE PLATFORM :
            //
            //////////////////////////////////////////////////

            info: notify('success'),
            warn: notify('warn'),
            error: notify('error'),

            // APIS TO MASK AND UNMASK THE APPVIEW :
            //
            ////////////////////////////////////////

            mask: function (message) {
                Mask.mask(this.container, message);
            },

            unmask: function () {
                Mask.unmask(this.container);
            }

        });

        return AppView;
    });

/*global define*/

define('DS/RDFVocabsImport/model/CollabStorages', [
	'DS/PlatformAPI/PlatformAPI', 'UWA/Class/Collection',
	'DS/RDFVocabsImport/model/CollabStorage',
	'DS/RDFVocabsImport/model/Debuggable', 'UWA/Core',
	'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
	'DS/RDFVocabsImport/view/AppView'],
	function (PlatformAPI, Collection, CollabStorage, Debuggable, Core,
		i3DXCompassPlatformServices) {
		'use strict';

		var CollaborativeStorages, myAppsBaseUrl, platformsCSV = [];

		myAppsBaseUrl = PlatformAPI
			.getApplicationConfiguration('app.urls.myapps');
		
		PlatformAPI.subscribe('PlatformManagement.renamePlatformName', function (newNamePlatform) {
			widget.setTitle(newNamePlatform);
		});

		i3DXCompassPlatformServices.getGrantedRoles(function (roles) {
			for (var i = 0; i < roles.length; i++) {
				if (roles[i].id == 'CSV') {
					var platCSV = roles[i].platforms;
					for (var j = 0; j < platCSV.length; j++) {
						platformsCSV.push(platCSV[j]);
					}
				}
			}
		});

		CollaborativeStorages = Collection.extend(Debuggable, {

			// the _UWA_ Class Name, used by Debuggable mixin for logging :
			uwaClassName: 'CollaborativeStorages',

			model: CollabStorage,

			url: myAppsBaseUrl + '/resources/AppsMngt/platform/list',

			parse: function (serverJSONResponse) {
				this.log('Parsing server JSON response "{0}"',
					serverJSONResponse);
				var platform, i, platforms = [];
				for (i = 0; i < serverJSONResponse.platforms.length; i++) {
					platform = serverJSONResponse.platforms[i];

					if (platform.platform) {
						if ('OnPremise' === platform.id) {
							// don't know if I can mutate the original
							// platform object
							// so i clone it :
							platform = Core.extend({ // When the platform
								// is "OnPremise",
								// it's cstorage
								// URL is indeed MyApps base URL itself :
								cstorage: myAppsBaseUrl
							}, platform);
						}
						if (platformsCSV.indexOf(platform.id) != -1)
							platforms.push(platform);
					}

				}
				if ((UWA.is(widget.getValue('x3dPlatformId'))) &&
					(widget.getValue('x3dPlatformId') !== '') && platformsCSV.indexOf(widget.getValue('x3dPlatformId')) != -1) {

					platforms.push(widget.getValue('x3dPlatformId'));
				}
				return platforms;
			},

			// TODO: Not needed anymore with latest UWAClient to come ...
			sync: function (method, model, options) {
				return this._parent(method, model, Core.extend({
					type: 'json'
				}, options));
			}
		});

		return CollaborativeStorages;
	});

/*global define, UWA, widget*/

'use strict';

define('DS/RDFVocabsImport/model/VocabsApp', [
  'DS/RDFVocabsImport/utils/Utils',
  'DS/RDFVocabsImport/model/Debuggable',
  'UWA/Core',
  'UWA/Class/Model',
  'DS/RDFVocabsImport/model/Vocabularies',
  'DS/RDFVocabsImport/model/CollabStorages',
  'DS/PlatformAPI/PlatformAPI',
  'DS/UWPClientCode/PublicAPI',
  'DS/i3DXCompassPlatformServices/i3DXCompassPlatformServices',
  'text!DS/FedDictionaryAccess/assets/FedDicoSettings.json'
], function(Utils, Debuggable, Core, Model, Vocabularies, CollaborativeStorages, PlatformAPI, PublicAPI, i3DXCompassPlatformServices, Settings) {
  var VocabsApp;

  // ////////////////////////////////////
  //
  // THE DEFINITION OF THE APP SINGLETON
  //
  // ////////////////////////////////////

  /*
   * The global App singleton. This object will be used to fetch our
   * original data and hold the bootstrapping code of our App (in the
   * implementation of the init API)
   */
  VocabsApp = Model.singleton(Debuggable, {
    name: 'VocabsApp',

    version: '1.0.0',

    uninitializedCalls: 'initialize',

    ontologyRDFService: '',

    setup: function(options) {
      // create the app's main data :
      this.collaborativeStorages = new CollaborativeStorages();
      this.vocabularies = new Vocabularies();

      // listen to changes made to the name of
      // current collab storage.

      this.addEvent('onChange:currentCollabSpaceId', this._fetchVocabs, this);

      this.debugMode = Utils.result(options, 'debugMode');

      var settings = JSON.parse(Settings);

      if (settings.CloudOntologyService) {
        this.ontologyRDFService = settings.CloudOntologyService;
        this.RDFPilar = settings.RDFPilar;
        this.RDFPPVersion = settings.RDFPPVersion;
      }
    },

    reset: function() {
      var that = this;

      // fetch the Collabstorages (having reset
      // the collection meanwhile), this will
      // start up the rendering of the view :
      that.collaborativeStorages.fetch({
        proxy: 'passport',
        reset: true, // Suppresses
        // 'add' events
        // with {reset:
        // true} and
        // prevents the app view from
        // being re-rendered for
        // every collab storage added.
        // Only renders when the 'reset'
        // event is triggered at the end
        // of the fetch.
        onComplete: function() {
          // when collab
          // spaces/storages have been
          // re-fetched, they may have
          // changed,
          // and currentCollabSpaceId
          // attr no longer valid.
          // Let's check this and
          // default
          // currentCollabSpaceId to
          // the first CS if necessary
          var currentCollabStorageId;
          if (that.collaborativeStorages.size()) {
            // 1) silently unset the
            // 'currentCollabSpaceId'
            // attr :
            that.unset('currentCollabSpaceId', {
              silent: true
            });
            // 2) fetch the last
            // userProp saved :
            currentCollabStorageId = PublicAPI.getUserProperty('{0}_currentCollabSpaceId'.format(that.name));
            // 3) Check if it can be
            // found in the returned
            // list of Platforms or
            // not :
            if (!that.collaborativeStorages.get(currentCollabStorageId)) {
              // could not be
              // found, default to
              // the id of the
              // first CS :
              currentCollabStorageId = that.collaborativeStorages.first().id;
            }
            // 3bis) Check if the global tenant pref is ofund in the list:
            if (UWA.is(widget.getValue('x3dPlatformId')) && widget.getValue('x3dPlatformId') !== '') {
              currentCollabStorageId = widget.getValue('x3dPlatformId');
            }
            ////
            // 4) set && save the
            // current collab space
            // id (an
            // onChange:currentCollabSpaceId
            // event will be
            // emitted)
            that.save('currentCollabSpaceId', currentCollabStorageId);
          }
        }
      });
    },

    _fetchVocabs: function(vocabsApp, currentCollabSpaceId) {
      var that = this;
      i3DXCompassPlatformServices.getPlatformServices({
        platformId: currentCollabSpaceId,
        onComplete: function(data) {
          that.baseUrl = data['3DSpace'];

          // SDM: redirect URL to 3DDrive, before 6WTags
          if (Core.is(data['3DDrive'], 'string') && data['3DDrive'] !== undefined) {
            that.base6WTagsUrl = data['3DDrive'];
          } else {
            that.base6WTagsUrl = that.baseUrl;
          }
          if (Core.is(data[that.ontologyRDFService], 'string') && data[that.ontologyRDFService] !== undefined) {
            that.baseRDFUrl = data[that.ontologyRDFService] + '/' + that.RDFPilar + '/' + that.RDFPPVersion + '/invoke/';
          }

          // SGA5: when fetching vocabularies, url should be filled
          var url;
          if (that.baseUrl) {
            url = that.baseUrl;
          } else if (that.base6WTagsUrl) {
            url = that.base6WTagsUrl;
          } else if (that.baseRDFUrl) {
            url = that.baseRDFUrl;
          }

          that.vocabularies.fetch({
            url: url,
            is6W: false,
            collabSpaceId: currentCollabSpaceId,
            baseRDFUrl: that.baseRDFUrl,
            base6WTagsUrl: that.base6WTagsUrl // SGA5: IR-626810 base6WTagsUrl needs to be set
          });
          // SGA5: no need to fetch data from both 3DSpace and 6Wtag services
          /*if (that.base6WTagsUrl !== that.baseUrl)
										that.vocabularies.fetch({
											url : that.base6WTagsUrl,
											is6W: true,
											collabSpaceId : currentCollabSpaceId,
											baseRDFUrl : that.baseRDFUrl
										});*/
        }
      });
    },
    // Only handles the backup of the app data.
    sync: function(method, model, options) {
      var currentCollabSpaceId, resp, errorMessage;

      try {
        switch (method) {
          case 'create':
            currentCollabSpaceId = this.get('currentCollabSpaceId');
            if (Core.is(currentCollabSpaceId)) {
              PublicAPI.setUserProperty('{0}_currentCollabSpaceId'.format(this.name), currentCollabSpaceId);
              resp = {
                currentCollabSpaceId: currentCollabSpaceId
              };
            }
            break;
          default:
            throw new Error('Unsupported method "{0}"'.format(method));
        }
      } catch (error) {
        errorMessage = error.message;
      }

      if (resp) {
        if (options && options.onComplete) {
          options.onComplete(resp);
        }
      } else {
        if (options && options.onFailure) {
          options.onFailure(errorMessage || 'Unknown error');
        }
      }

      // return a dummy obj with a cancel() method
      // :
      return {
        cancel: function() {}
      };
    }
  });

  return VocabsApp;
});

