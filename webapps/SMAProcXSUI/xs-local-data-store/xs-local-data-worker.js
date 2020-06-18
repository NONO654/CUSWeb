// Copyright 2016 Dassault Systemes Simulia Corp.
/**
    This web worker is a dedicated worker for xs-local-data-store to perform operations on given database
*/

(function (global) {
	'use strict';

	var XSIndexDB;


	XSIndexDB = function () {
		this._dbInstance = '';
	};

    /**
     * Migrates index db to new version, creates new store after removing old stores
     * This function can only be called from onupgradeneeded callback while opening the databse
     *
     * @param {IDBDatabase} database refrence on which migration needs to be performed
     * @param {Array} datastructure array of stores which this database will contain after migration
     */
	XSIndexDB.prototype.migrate = function (database, datastructure) {
        // Looping over all object Store names and deleting them on migration
        // TODO: Check that if it is available in new data structure.
        // If present and there is no change then do not remove the store

		[].every.call(database.objectStoreNames, function (oldStore) {
			database.deleteObjectStore(oldStore);
		});

		datastructure.forEach(function (store) {
			var storeOptions;
			if (store.KEY_PATH) {
				storeOptions = {
					keyPath: store.KEY_PATH
				};
			}
            // TODO: Remove below var if no need for that
			database.createObjectStore(store.STORE_NAME, storeOptions);
		});
	};

    /**
     * Opens the database for given information and return IDBDatabase object
     *
     * @param {Object} context Object having database name, version and its structure.
     * @param {Function} success - success callback
     * @param {Function} error - error callback
     */
	XSIndexDB.prototype.openDb = function (context, success, error) {
		if (this._dbInstance) {
			success(this._dbInstance);
		} else {
			var request = global.self.indexedDB.open(context.DB_NAME, parseInt(context.DB_VERSION, 10));

			request.onupgradeneeded = function () {
                // console.log('XS-LOCAL-DATA-STORE Upgrade needed:', event.oldVersion, '=>', event.newVersion);
				this.migrate(request.result, context.DB_STRUCTURE);
			}.bind(this);

			request.onsuccess = function () {
				this._dbInstance = request.result;
                // console.log('XS-LOCAL-DATA-STORE Database opened.');
				success(request.result);
			};
			request.onerror = function () {
                // console.log('XS-LOCAL-DATA-STORE Database Error.' + request.error);
				error(request.error);
			};
		}
	};

    /**
     * Closed the database connection for given information.
     *
     * @param {Object} context Object having database name, version and its structure.
     * @param {Function} success - success callback
     * @param {Function} error - error callback
     */
	XSIndexDB.prototype.closeDb = function (context, success, error) {
		if (this._dbInstance === null) {
			success();
		}
		this.openDb(context, function (db) {
			this._dbInstance = null;
            // console.log('XS-LOCAL-DATA-STORE Closing database..');
			db.close();
			success();
		}.bind(this), error);
	};


    /**
     * Fetches object corresponding to given key
     *
     * @param {Object} context Object having database name, version and storeName to be used for operation.
     * @param {String} key value which will be used to fetch information from index db.
     * @param {Function} success - success callback
     * @param {Function} error - error callback
     */
	XSIndexDB.prototype.get = function (context, key, success, error) {
		this.openDb(context, function (db) {
			console.log('XS-LOCAL-DATA-STORE - GET Store operation:' + key + '  ' + context);
			var transaction, store, request;
			try {
				transaction = db.transaction(context.storeName, 'readonly');
				store = transaction.objectStore(context.storeName);
				request = store.get(key);
			} catch (e) {
				error(e);
			}
			transaction.oncomplete = function () {
				success(request.result);
			};
			transaction.onabort = function () {
				error(transaction.error);
			};
		}, error);
	};


    /**
     * ADD(if not present) or Updates(if present) the object to index db database
     *
     * @param {Object} context Object having database name, version and storeName to be used for operation.
     * @param {Object} value that needs to be updated/added to database. it must have key path as its property
     * @param {Function} success - success callback
     * @param {Function} error - error callback
     */
	XSIndexDB.prototype.put = function (context, value, success, error) {
		this.openDb(context, function (db) {
            // console.log('XS-LOCAL-DATA-STORE - SET Store operation:' + context + '  ' + value);
			var transaction, store, key;
			try {
				transaction = db.transaction(context.storeName, 'readwrite');
				store = transaction.objectStore(context.storeName);
				for (key in value) {
					if (value.hasOwnProperty(key)) {
						store.put(value[key]);
					}
				}
			} catch (e) {
				error(e);
			}

			transaction.oncomplete = function () {
				success(value);
			};
			transaction.onabort = function () {
				error(transaction.error);
			};
		}, error);
	};

    /**
     * deletes object corresponding to given key
     *
     * @param {Object} context Object having database name, version and storeName to be used for operation.
     * @param {String} key value which will be used to delete information from index db.
     * @param {Function} success - success callback
     * @param {Function} error - error callback
     */
	XSIndexDB.prototype.delete = function (context, key, success, error) {
		this.openDb(context, function (db) {
			console.log('XS-LOCAL-DATA-STORE - SET Store operation:' + key + '  ' + context);
			var transaction, request, store;
			try {
				transaction = db.transaction(context.storeName, 'readwrite');
				store = transaction.objectStore(context.storeName);
				request = store.delete(key);
			} catch (e) {
				error(e);
			}

			transaction.oncomplete = function () {
				success(request.result);
			};
			transaction.onabort = function () {
				error(transaction.error);
			};
		}, error);
	};


    // Entry point to this web worker. Add a event listener to message event
	global.self.addEventListener('message', function (event) {
        // Instance is not creates again if already present
		var id, context, xsIndexDBInstance;
		global.self.xsIndexDBInstance = global.self.xsIndexDBInstance ? global.self.xsIndexDBInstance : new XSIndexDB();
		xsIndexDBInstance = global.self.xsIndexDBInstance;
        // Message id and context is must as it defines the transaction
		id = event.data['id'];
		context = event.data['context'];

        // Based on given event type specific operations are performed on database
		switch (event.data['type']) {
		case 'xs-local-data-close-db':
			xsIndexDBInstance.closeDb(context, function () {
				global.self.postMessage({
					type: 'xs-local-data-db-closed',
					id: id,
					context: context
				});
			}, function (error) {
				global.self.postMessage({
					type: 'xs-local-data-db-closed-error',
					id: id,
					context: context,
					error: error
				});
			});
			break;
		case 'xs-local-data-get':
			xsIndexDBInstance.get(context, event.data['key'], function (result) {
				global.self.postMessage({
					type: 'xs-local-data-get-result',
					id: id,
					context: context,
					result: result
				});
			}, function (error) {
				global.self.postMessage({
					type: 'xs-local-data-get-result-error',
					id: id,
					context: context,
					error: error
				});
			});
			break;
		case 'xs-local-data-put':
			xsIndexDBInstance.put(context, event.data['value'], function (result) {
				global.self.postMessage({
					type: 'xs-local-data-put-result',
					id: id,
					context: context,
					result: result
				});
			}, function (error) {
				global.self.postMessage({
					type: 'xs-local-data-put-result-error',
					id: id,
					context: context,
					error: error
				});
			});
			break;
		case 'xs-local-data-delete':
			xsIndexDBInstance.delete(context, event.data['key'], function (result) {
				global.self.postMessage({
					type: 'xs-local-data-delete-result',
					id: id,
					context: context,
					result: result
				});
			}, function (error) {
				global.self.postMessage({
					type: 'xs-local-data-delete-result-error',
					id: id,
					context: context,
					error: error
				});
			});
			break;
		default:
			break;
		}
	}, false);
})(this);
