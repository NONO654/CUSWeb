// Copyright 2016 Dassault Systemes Simulia Corp.
/* TO use this component edit your store informatuin to DB_STRUCTURE and update DB version
DB_STRUCTURE = [
        {
            STORE_NAME : 'XS_TEMPLATES',
            KEY_PATH : 'uid'
        },{
             STORE_NAME : 'NEW STRORE name',
             KEY_PATH : 'key in objects going to be saved'
          }
    ];

//Passing Store index key is compulsary before calling for any operation
//if no store id is passed then store id zero is considered
<xs-local-data-store id="indexDB" store-id="2"></xs-local-data-store>


// Initialize and Close database from a single instance only
// Multiple instance of xs-local-data-store to point to same worker instance
<xs-local-data-store id="indexDB" ></xs-local-data-store>
// Initialize by this.$.indexDB.initStore();
//Close by this.$.indexDB.closeStore();


//To fetch data
this.$.indexDB.get('someuid').then(function(value){
    console.log(value);
}).error(function(error){
    console.log(error);
});

//to update data
// Its a batched call so for multiple calls, DB call will be made only once
this.$.indexDB.set('data').then(function(keys,updatedvalues){
    //It will revert all keys updated in operation and there updated value
}).error(function(error){
    console.log(error);
});

//if operation to be done on single key than it can be done using its attributes
<xs-local-data-store
        id="indexDB"
        store-id="2"
        key="somekey"
        value=""></xs-local-data-store>
Update the key to and read the value from value property using binding

//TODO: change value should update that info to db
Seems risky as binding value "{{}}" affects observers. Changing update value won't update data

//TODO:
Multiple get for same key or different key's should also be batched

//TODO:
Implement clearing of not accessed/updated records after year (time can change)
Implement method to remove OLD_DBNAMES, currently its blank to no issue. Implement it when it has some info in it

*/

/* global Polymer*/
window.require(['UWA/Class/Promise'], function (UWAPromise) {
	'use strict';

    // global variables
	var DB_NAME, DB_VERSION, DB_STRUCTURE, MESSAGE_ID, WORKER_URL, WORKER, EVENT_TYPE, Promise;

	Promise = window.Promise || UWAPromise;
    // If DB_NAME is changed then add old db name here. So that it can be removed
    // This operation only to be done if earlier name change is delivered to customer or released
	// OLD_DB_NAMES = [];
    // DB_NAME : Do not change it as it will create multiple database on client machine
    // Make sure this name is unique for given domain
	DB_NAME = 'DS_SMAPROC';
    // Update DB Version when DB_STRUCTURE is updated
    // This operation only to be done if earlier DB_Structure is delivered to customer or released
	DB_VERSION = '1';
    // Object Structure
    // If Store/DB_Structure is updated for any existing strore than all information stored will be lost
	DB_STRUCTURE = [{
		STORE_NAME: 'XS_TEMPLATES',
		KEY_PATH: 'uid'
	}];

    // Message id to be incremented to seprate all get and put/post operations on index db
	MESSAGE_ID = 0;
	WORKER_URL = 'xs-local-data-worker.js';

	EVENT_TYPE = {
		GET: {
			REQUEST: 'xs-local-data-get',
			SUCCESS: 'xs-local-data-get-result',
			ERROR: 'xs-local-data-get-result-error'
		},
		PUT: {
			REQUEST: 'xs-local-data-put',
			SUCCESS: 'xs-local-data-put-result',
			ERROR: 'xs-local-data-put-result-error'
		},
		DELETE: {
			REQUEST: 'xs-local-data-delete',
			SUCCESS: 'xs-local-data-delete-result',
			ERROR: 'xs-local-data-delete-result-error'
		},
		CLOSE: {
			REQUEST: 'xs-local-data-close-db',
			SUCCESS: 'xs-local-data-db-closed',
			ERROR: 'xs-local-data-db-closed-error'
		}
	};

	Polymer({ // jshint ignore:line
		is: 'xs-local-data-store',

		properties: {
            // By default first store is picked
			storeId: {
				type: Number,
				value: 0
			},
            // Key value to fetch your data
			key: {
				reflectToAttribute: true,
				observer: '__keyChanged',
				notify: true
			},

			value: {
				notify: true
			},

			_worker: {
				type: Object
			},

			_context: {
				type: Object,
				computed: '_getContext(storeId)'
			}
		},

		ready: function () {
			this.__dataPending = false;
            // Updating database should be a batched call to prevent multiple calls for same data
			this.__pendingUpdates = null;
			this.__pendingPromises = null;
            // Get/Put on same key multiple times should not fetch it from database
			this.__dataChache = {};
            // While doing async operation
			this.__dataInvalid = false;
		},

        // Whenever there is a change in key then it is fecthed from DB and value property is updated
        // Value will always be an object hence not reflecting it back to attribute for now.
        // Set value to attribute if it's not risky
		__keyChanged: function () {
			if (this.key && this.key !== '') {
				this.get(this.key).then(function (result) {
					this.value = result;
				}.bind(this)).catch(function (err) {
					this.fire(EVENT_TYPE.GET.ERROR, err);
				});
			}
		},

        /**
         * Initializes the web worker. Also sets the STORE to be used for get/set operations
         *
         * @param {Number} storeId of your store in static DATA_STRUCTURE
         */
		initStore: function (storeId) {
			if (!WORKER) {
				WORKER = WORKER || new window.Worker(this.resolveUrl(WORKER_URL));
				this._worker = WORKER;
			}
			this.storeId = storeId || this.storeId;
		},

        /**
         * Close the database connection. Terminates the Web worker
         *
         * @return {Promise} Resolved on successful completion of given action, Rejects when there is error with error object
         */
		closeStore: function () {
			if (!this._worker) {
				return Promise.reject(new Error('Invalid Call to Close'));
			}
			return new Promise(function (resolve, reject) {
				var message = {}, id;
				MESSAGE_ID += 1;
				id = MESSAGE_ID;
				WORKER.addEventListener('message', function onMessage(event) {
					if (event.data && event.data['id'] === id) {
						WORKER.removeEventListener('message', onMessage);
						this._worker && this._worker.terminate();
						this._worker = undefined;
						WORKER = undefined;
						if (event.data['type'] === EVENT_TYPE.CLOSE.ERROR) {
							reject(event.data['error']);
						} else {
							resolve();
						}
					}
				}.bind(this));
				message['id'] = id;
				message['context'] = this._context;
				message['type'] = EVENT_TYPE.CLOSE.REQUEST;
				WORKER.postMessage(message);
			}.bind(this));
		},

        /**
         * Serches for data in Index DB, if found data is returned else undfined is returned
         *
         * @param {string} key to fetch data from Index DB
         * @return {Promise} Resolved on successful completion of given action, Rejects when there is error with error object
         */
		getData: function (key) {
			if (!WORKER) {
				return Promise.reject(new Error('Worker not Initialized'));
			}
            // if data can be fetched from __data cache or Pending Updates
			if (this.__pendingUpdates && this.__pendingUpdates[key]) {
				return Promise.resolve(this.__pendingUpdates[key]);
			}

			if (this.__dataChache && this.__dataChache[key]) {
				return Promise.resolve(this.__dataChache[key]);
			}

			return new Promise(function (resolve, reject) {
				var message = {}, id;
				MESSAGE_ID += 1;
				id = MESSAGE_ID;
				WORKER.addEventListener('message', function onMessage(event) {
					if (event.data && event.data['id'] === id) {
						WORKER.removeEventListener('message', onMessage);
						if (event.data['type'] === EVENT_TYPE.GET.ERROR) {
							reject(event.data['error']);
						} else {
							this.__dataChache[key] = event.data['result'];
							resolve(event.data['result']);
						}
					}
				}.bind(this));
				message['id'] = id;
				message['type'] = EVENT_TYPE.GET.REQUEST;
				message['context'] = this._context;
				message['key'] = key;

				WORKER.postMessage(message);
			}.bind(this));
		},

        /**
         * Updates/ADD new data in index db. data.[KEY_PATH] identifies the data
         *
         * @param {Object} value to be saved in index db and it should have KEY_PATH as a property uniquely identyfying the the data instance
         * @return {Promise} Resolved on successful completion of given action, Rejects when there is error with error object
         */
		setData: function (value) {
			var promiseToResolve, promise;
			if (!WORKER) {
				return Promise.reject(new Error('Worker not Initialized'));
			}
			promiseToResolve = {
				resolve: function () {},
				reject: function () {}
			};
			promise = new Promise(function (resolve, reject) {
				promiseToResolve.resolve = resolve;
				promiseToResolve.reject = reject;
			});

			this._setPendingUpdate(value, promiseToResolve);
			this._invalidateUpdate();
			return promise;
		},

        /**
         * Add the update operation in cache to be called as a single operation
         * and enqueues a Promise resolve event
         *
         * @param {Object} value Object to be updated
         * @param {Promise} promise to be resolved when that data opeartion is complete
         * @protected
         */
		_setPendingUpdate: function (value, promise) {
			var keyValue = this._getKeyValueFromActualvalue(value);
			if (!this.__pendingUpdates) {
				this.__pendingUpdates = {};
				this.__pendingPromises = {};
			}
			this.__pendingUpdates[keyValue] = value;
			this.__pendingPromises[keyValue] = promise;
			this.__dataPending = true;
		},

        /**
         * enqueues async opeartion to call update for given data to Database
         *
         * @protected
         */
		_invalidateUpdate: function () {
			if (!this.__dataInvalid) {
				this.__dataInvalid = true;

				this.async(function () {
					if (this.__dataInvalid) {
						this.__dataInvalid = false;
						this._flushUpdate();
					}
				}.bind(this), 100);
			}
		},

        /**
         * Update is comitted for all pending operation and all Promises is resolved
         *
         * @protected
         */
		_flushUpdate: function () {
			if (this.__pendingUpdates) {
				var pendingUpdates = this.__pendingUpdates;
				var pendingPromise = this.__pendingPromises;
				this.__pendingUpdates = null;
				this.__pendingPromises = null;
				this.__dataPending = false;
				this._updateValuesToDB(pendingUpdates).then(function (result) {
					for (var key in pendingPromise) {
						if (pendingPromise.hasOwnProperty(key)) {
                            // Promise.resolve(pendingPromise[key], result[key]);
							pendingPromise[key].resolve(result[key]);
							this.__dataChache[key] = result[key];
						}
					}
				}.bind(this)).catch(function (error) {
					for (var key in pendingPromise) {
						if (pendingPromise.hasOwnProperty(key)) {
							pendingPromise[key].reject(error[key]);
                            // Promise.reject(pendingPromise[key], error);
						}
					}
				});
			}
		},

        /**
         * Update is comitted for all pending operation and all Promises is resolved
         *
         * @param {Object} Object having key as key_path for value to be updated and value is that data
         */
		_updateValuesToDB: function (pendingUpdates) {
			return new Promise(function (resolve, reject) {
				var message = {};
				var id = MESSAGE_ID++;
				WORKER.addEventListener('message', function onMessage(event) {
					if (event.data && event.data['id'] === id) {
						WORKER.removeEventListener('message', onMessage);
						if (event.data['type'] === EVENT_TYPE.PUT.ERROR) {
							reject(event.data['error']);
						} else {
							resolve(event.data['result']);
						}
					}
				});
				message['id'] = id;
				message['type'] = EVENT_TYPE.PUT.REQUEST;
				message['context'] = this._context;
				message['value'] = pendingUpdates;

				WORKER.postMessage(message);
			}.bind(this));
		},

        /**
         * Serches for data in Index DB, if data is found then it is deleted
         *
         * @param {string} key to delete data from Index DB
         * @return {Promise} Resolved on successful completion of given action, Rejects when there is error with error object
         */
		deleteData: function (key) {
			if (!WORKER) {
				return Promise.reject(new Error('Worker not Initialized'));
			}
			return new Promise(function (resolve, reject) {
				var message = {};
				var id = MESSAGE_ID++;
				WORKER.addEventListener('message', function onMessage(event) {
					if (event.data && event.data['id'] === id) {
						WORKER.removeEventListener('message', onMessage);
						if (event.data['type'] === EVENT_TYPE.DELETE.ERROR) {
							reject(event.data['error']);
						} else {
							resolve(event.data['result']);
						}
					}
				});
				message['id'] = id;
				message['type'] = EVENT_TYPE.DELETE.REQUEST;
				message['context'] = this._context;
				message['key'] = key;

				WORKER.postMessage(message);
			}.bind(this));
		},

		getLoggedInUserInfo: function () {
			if (this._userDataPromise === undefined) {
				this._userDataPromise = new Promise(function (resolve, reject) {
					this.$.userinfo.addEventListener('response', function onUserResponse(event) {
						this.$.userinfo.removeEventListener('response', onUserResponse);
						resolve(event);
					}.bind(this));
					this.$.userinfo.addEventListener('error', function onUserError(event) {
						this.$.userinfo.removeEventListener('error', onUserError);
						reject(event);
					}.bind(this));
					this.$.userinfo.getData();
				}.bind(this));
			}
			return this._userDataPromise;
		},

        // Fetches key name from DB_STRUCTURE
		_getKeyValueFromActualvalue: function (value) {
			return value[DB_STRUCTURE[this.storeId].KEY_PATH];
		},

        // Creates a context object to interact with database
		_getContext: function (storeId) {
			return {
				DB_NAME: DB_NAME,
				DB_VERSION: DB_VERSION,
				DB_STRUCTURE: DB_STRUCTURE,
				storeName: DB_STRUCTURE[storeId].STORE_NAME
			};
		},

        // Is initStore is called to initialize worker or not
		isActive: function () {
			return WORKER !== undefined;
		}

	});
});
