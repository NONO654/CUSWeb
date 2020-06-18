//Copyright 2016 Dassault Systemes Simulia Corp.
/*  @module SMAProcXSWidgets.mweb
	@submodule xs-wg-media

	@description
				This Polymer webcomponent is used to show the images associated to
				chooser type like Documents

	@example
	<xs-wg-media size="Large" value="{{xs_wg_plm_data_1}}"></xs-wg-image>

*/
/* global DS, Polymer*/

(function (window) {
	'use strict';
	var FORMATS = {
		IMAGE: ['jpg', 'jpeg', 'png'],
		VIDEO: ['mp4', 'avi']
	};
	var URL_IMAGE_CACHE = {},
		URL_VIDEO_CACHE = {},
		URL_VIDEO_TYPE_CACHE = {};

	//Prototype
	Polymer({ // jshint ignore:line
		is: 'xs-wg-media',
		properties: {
			value: {
				type: String
			},
			rawvalue: {
				type: Object,
				notify: true,
				observer: '_rawvalueChanged'
			},
			label: {
				type: String,
				notify: true
			},
			size: {
				type: String,
				notify: true,
				value: 'Medium'
			},
			_objectId: {
				type: String,
				observer: '_objectIdChanged'
			},
			_activeElement: {
				type: Object
			},
			_allElements: {
				type: Array,
				value: []
			}


		},

		attached: function () {
			this._adp = this.XS();
			this._isDesignMode = this._adp.whichMode() === 'design';
		},

		//observer on value Change to send the webservice call to get all the images url
		_rawvalueChanged: function () {
			if (this.rawvalue && this.rawvalue.chooser_physicalid) { // jshint ignore:line
				this._objectId = this.rawvalue.chooser_physicalid; // jshint ignore:line
			}

		},

		_objectIdChanged: function () {
			this._removeAllMedia();
			this.$.updpnl.update();
			this._callWhenAttached(this.$.fileContent, function () {
				this.$.fileContent.getContentInfo(this._objectId, this._isDesignMode).then(function (info) {
					this._fetchContent(info);
				}.bind(this)).catch(function (info) {
					this._removeAllMedia();
					this.$.errormsg.innerHTML = 'Unable to fetch file info' + info;
				}.bind(this));
			}.bind(this));
		},

		maximize: function () {
			this.$.container.classList.add('maximized');
		},

		restore: function () {
			this.$.container.classList.remove('maximized');
		},

		/**
		 * TO call some function after component is attached
		 * @param  {Node} node - node for which we are waiting to get attached
		 * @param  {Function} callback - Function which is to be called after component is attached
		 */
		_callWhenAttached: function (node, callback) {
			if (node.isAttached) {
				callback();
			} else {
				node.addEventListener(node.tagName.toLowerCase() + '-attached', function onAttached() {
					node.removeEventListener(node.tagName.toLowerCase() + '-attached', onAttached);
					callback();
				});
			}
		},

		_fetchContent: function (info) {
			var response = JSON.parse(info), filteredresponse;
			this.error = false;
			this.first = true;
			filteredresponse = this._getValidItemList(response);
			if (filteredresponse.length === 0) {
				this.$.updpnl.done();
			}
			this.continueFetching = true;

			filteredresponse.forEach(function (content) {
				var name = content.basics.name;
				var re = /(?:\.([^.]+))?$/;
				var ext = re.exec(name)[1];

				if (ext && this._isDesignMode && (URL_IMAGE_CACHE[this._objectId + name] !== undefined || URL_VIDEO_CACHE[this._objectId + name] !== undefined)) {
					if (URL_IMAGE_CACHE[this._objectId + name] !== undefined) {
						var image = this._addImage(URL_IMAGE_CACHE[this._objectId + name]);
						this._changeActiveElement(undefined, image);
						this.continueFetching = false;
					} else if (URL_VIDEO_CACHE[this._objectId + name]) {
						var video = this._addVideo(URL_VIDEO_CACHE[this._objectId + name], URL_VIDEO_TYPE_CACHE[this._objectId + name]);
						this._changeActiveElement(undefined, video);
						this.continueFetching = false;
					}
				} else if (ext && FORMATS.IMAGE.indexOf(ext.toLowerCase()) !== -1 && this.continueFetching) {
					//Its a image
					if (this._isDesignMode) {
						this.continueFetching = false;
					}
					this.$.fileContent.getFileContent(this._objectId, name, 'blob').then(function (info) {
						var blob = new Blob([info.response]);
						var tempUrlImage = window.URL.createObjectURL(blob);
						URL_IMAGE_CACHE[this._objectId + name] = tempUrlImage;
						var image = this._addImage(tempUrlImage);
						if (this.first && !this.error) {
							this._changeActiveElement(undefined, image);
							this.first = false;
						} else if (!this.first) {
							this.$.container.classList.add('show-navigate');
						}
					}.bind(this)).catch(function () {
						this._removeAllMedia();
						this.error = true;
						this.$.errormsg.innerHTML = "Unable to fetch image";
					});

				} else if (ext && FORMATS.VIDEO.indexOf(ext.toLowerCase()) !== -1 && this.continueFetching) {
					//Its a video
					if (this._isDesignMode) {
						this.continueFetching = false;
					}

					this.$.fileContent.getFileContent(this._objectId, name, 'blob').then(function (info) {
						var blob = new Blob([info.response]);
						var tempUrlVideo = window.URL.createObjectURL(blob);
						URL_VIDEO_CACHE[this._objectId + name] = tempUrlVideo;
						URL_VIDEO_TYPE_CACHE[this._objectId + name] = info.response.type;
						var video = this._addVideo(tempUrlVideo, info.response.type);
						if (this.first) {
							this._changeActiveElement(undefined, video);
							this.first = false;
						} else if (!this.first) {
							this.$.container.classList.add('show-navigate');
						}
					}.bind(this)).catch(function () {
						this._removeAllMedia();
						this.error = true;
						this.$.errormsg.innerHTML = "Unable to fetch video";
					});
				}
			}.bind(this));
		},

		_getValidItemList: function (contentlist) {
			 return contentlist.filter(function (content) {
				var re = /(?:\.([^.]+))?$/;
				var ext = re.exec(content.basics.name)[1];
				if (ext && ((FORMATS.IMAGE.indexOf(ext.toLowerCase()) !== -1) || (FORMATS.VIDEO.indexOf(ext.toLowerCase()) !== -1))) {
					return true;
				}
				return false;
			});
		},
		previous: function () {
			this._changeActiveElement(this._activeElement, this._getPreviousMedia());
		},

		next: function () {
			this._changeActiveElement(this._activeElement, this._getNextMedia());
		},

		_removeAllMedia: function () {
			this.$.updpnl.done();
			this._allElements.forEach(function (media) {
				media.parentNode.removeChild(media);
			});
			this.$.container.classList.add('no-media');
			this.$.updpnl.classList.add('no-media');
			this._allElements = [];
			this._activeElement = undefined;
		},

		_addImage: function (url) {
			var image = document.createElement('img');
			image.src = url;
			image.className = "content style-scope xs-wg-media";
			this.$.container.appendChild(image);
			this._allElements.push(image);
			return image;
		},

		_addVideo: function (url, type) {
			var video = document.createElement("video");
			video.controls = true;
			video.className = "content style-scope xs-wg-media";
			var source = document.createElement("source");
			source.type = type;
			source.src = url;
			video.appendChild(source);
			this.$.container.appendChild(video);
			this._allElements.push(video);
			return video;
		},

		_getNextMedia: function () {
			if (this._allElements.length === 1) {
				return this._allElements[0];
			} else if (this._allElements.length === 0) {
				return undefined;
			}

			if (this._allElements[this._allElements.length - 1] === this._activeElement) {
				return this._allElements[0];
			} else {
				return this._activeElement.nextSibling;
			}
		},

		_getPreviousMedia: function () {
			if (this._allElements.length === 1) {
				return this._allElements[0];
			} else if (this._allElements.length === 0) {
				return undefined;
			}

			if (this._allElements[0] === this._activeElement) {
				return this._allElements[this._allElements.length - 1];
			} else {
				return this._activeElement.previousSibling;
			}
		},

		_changeActiveElement: function (oldElement, nextElement) {
			if (oldElement) {
				//To Pause Video if user moves to next element
				if (oldElement.nodeName === "VIDEO") {
					oldElement.pause();
				}
				oldElement.classList.remove('content-active');
			}

			if (nextElement) {
				nextElement.classList.add('content-active');
				this.$.container.classList.remove('no-media');
				this.$.updpnl.classList.remove('no-media');
				this.$.updpnl.done();
				this._activeElement = nextElement;
			}
		},


		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(this));
