/**
 * CAT3DExpLocalStorageLinkContext
 * @category LinkContext
 * @name DS/CAT3DExpLinkContext/CAT3DExpLocalStorageLinkContext
 * @constructor
 * @augments DS/CAT3DExpLinkContext/CAT3DExpLinkContext
 */
define('DS/CAT3DExpLinkContext/CAT3DExpLocalStorageLinkContext',
[
	'UWA/Core',
	'UWA/Class/Promise',
	'DS/CAT3DExpLinkContext/CAT3DExpLinkContext',
	'UWA/Storage/Adapter/Dom'
],
function (UWA, Promise, LinkContext) {

	'use strict';

	var CAT3DExpLocalStorageLinkContext = LinkContext.extend(
	/** @lends DS/CAT3DExpLinkContext/CAT3DExpLocalStorageLinkContext.prototype **/
    {
		init: function (iOptions) {
		    this._parent();

			this._dataBaseName = iOptions.databaseName;
			this._storage = new UWA.Storage({
				adapter: 'Dom',
				database: 'uwaLocalStorage-' + this._dataBaseName
			});

			this._storage.currentAdapter.options.duration = 100;			
		},

		getLinkDescriptionByType: function (iType) {
		    var allStoredObject = this._storage.getAll();
		    for (var id in allStoredObject) {
		        if (allStoredObject.hasOwnProperty(id) && allStoredObject[id].type === iType) {
		            return UWA.Promise.resolve(id);
		        }
		    }
		    return UWA.Promise.fail();
		},

		retrieveLinkDescriptions: function () {
		    var links = [];
		    var allStoredObject = this._storage.getAll();
		    for (var id in allStoredObject) {
		        if (allStoredObject.hasOwnProperty(id)) {
		            links.push(id);
		        }
		    }
		    return UWA.Promise.resolve(links);
		},

		pushStream: function (iStream) {
		    var deferred = UWA.Promise.deferred();
		    var id = UWA.Utils.getUUID();

		    var self = this;
		    var fileReader = new FileReader();
		    fileReader.onload = function () {
		        self._storage.set(id, {
		            data: self._arrayBufferToBase64(this.result),
		            format: iStream.format,
		            type: self._getStreamType(iStream) //impossible to retrieve type when stream is convert to base64 
		        });
		        deferred.resolve(id);
		    };
		    fileReader.readAsArrayBuffer(iStream);
		    return deferred.promise;
		},

		_typeMap: {
            //add Product?
		    'application/json': 'CXPExperience_Spec',
		    'image/jpeg': 'CXPPictureResource_Spec'
		},

		_getStreamType:function(iStream){
		    for (var streamType in this._typeMap) {
		        if (iStream.type === streamType) {
		            return this._typeMap[streamType];
		        }
		    }
		    return undefined;
		},

		resolveLinkAsStream: function (iLinkDescription) {
		    var storedItem = this._storage.get(iLinkDescription);
		    if (!storedItem) {
		        return UWA.Promise.reject(iLinkDescription + ' Object not find');
		    }
		    if (UWA.is(storedItem.data)) {
		        var blob = new Blob([this._base64ToArrayBuffer(storedItem.data)], { type: 'application/octet-binary' });
		        blob.format = storedItem.format;
		        return UWA.Promise.resolve(blob);
		    }
		    else {
		        return UWA.Promise.reject('cannot read that');
		    }
		},

		_base64ToArrayBuffer: function (ibase64) {
			var binaryString = window.atob(ibase64);
			var bytes = new Uint8Array(binaryString.length);
			for (var i = 0; i < binaryString.length; i++) {
				bytes[i] = binaryString.charCodeAt(i);
			}
			return bytes.buffer;
		},

		_arrayBufferToBase64: function (buffer) {
			var binary = '';
			var bytes = new Uint8Array(buffer);
			for (var i = 0; i < bytes.byteLength; i++) {
				binary += String.fromCharCode(bytes[i]);
			}
			return window.btoa(binary);
		},

		getJSONDescription: function () {
			return {
			    objectType: "CAT3DExpLocalStorage",
				databaseName: this._dataBaseName
			};
		}

	});

	return CAT3DExpLocalStorageLinkContext;

});
