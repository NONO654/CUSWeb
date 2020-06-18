/**
 * CAT3DExpFilesLinkContext
 * @category LinkContext
 * @name DS/CAT3DExpLinkContext/CAT3DExpFilesLinkContext
 * @constructor
 * @augments DS/CAT3DExpLinkContext/CAT3DExpLinkContext
 */
define('DS/CAT3DExpLinkContext/CAT3DExpFilesLinkContext',
[
	'UWA/Core',
	'UWA/Class/Promise',
	'DS/CAT3DExpLinkContext/CAT3DExpLinkContext'
],
function (UWA, Promise, CAT3DExpLinkContext) {
	'use strict';

	var CAT3DExpFilesLinkContext = CAT3DExpLinkContext.extend(
	/** @lends DS/CAT3DExpLinkContext/CAT3DExpFilesLinkContext.prototype **/
    {

		init: function (iFiles) {
		    this._links = [];
		    this._files = iFiles;
			for (var i = 0 ; i < iFiles.length; i++) {
			    this._links.push({
			        StreamName: this._files[i].name
			    });
			}
		},

		getLinkDescriptionByType: function (iType) {
		    for (var i = 0; i < this._links.length; i++) {
		        if (this._getLinkType(this._links[i]) === iType) {
		            return UWA.Promise.resolve(this._links[i]);
		        }
		    }
		    return UWA.Promise.reject();
		},

		_typeExtMap: {
		    '.json': 'CXPExperience_Spec',
		    '.cgr': 'Model_VPMReference_Spec',
		    '.3dxml': 'Model_VPMReference_Spec',
		    '.3dx': 'Model_VPMReference_Spec',
		    '.jpg': 'CXPPictureResource_Spec',
		    '.bmp': 'CXPPictureResource_Spec',
		    '.png': 'CXPPictureResource_Spec'
		},

		_getLinkType: function (iLink) {
		    for (var ext in this._typeExtMap) {
		        if (iLink.StreamName.endsWith(ext)) {
		            return this._typeExtMap[ext];
		        }
		    }
		    console.error('unknown link');
		    return undefined;
		},

		retrieveLinkDescriptions: function () {
			return Promise.resolve(this._links);
		},

		resolveLinkAsStream: function (iLinkDescription) {
		    for (var i = 0; i < this._files.length;i++){
		        if (this._files[i].name === iLinkDescription.StreamName) {
		            this._files[i].format = this._getLinkFormat(iLinkDescription);
		            return UWA.Promise.resolve(this._files[i]);
		        }
		    }
		    return UWA.Promise.reject('Unknown Link');
		},
        
		_formatExtMap: {
		    '.cgr': 'cgr',
		    '.3dxml': 'xmlv43',
		    '.3dx': '3dx',
		},

		_getLinkFormat: function (iLink) {
		    for (var ext in this._formatExtMap) {
		        if (iLink.StreamName.endsWith(ext)) {
		            return this._formatExtMap[ext];
		        }
		    }
		    return undefined;
		},

		getNameForLinkDescription: function (iLinkDescription) {
		    var dotPos = iLinkDescription.StreamName.lastIndexOf('.');
		    return (dotPos !== -1) ? iLinkDescription.StreamName.substr(0, dotPos) : iLinkDescription.StreamName;
        },

	});

	return CAT3DExpFilesLinkContext;

});
