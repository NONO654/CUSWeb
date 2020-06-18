/*--------------------------------------------------------------------
[xs-wg-reference-manager Javascript Document]
Project:        xs
Version:        1.0
Description:    TODO: Write Description
---------------------------------------------------------------------*/
/* global DS, Polymer*/

(function () {
	'use strict';

	// global variables
	var STATE, EVENT, ERROR_MSG;
	STATE = {
		noData: 'no-data',
		filesAvailable: 'files-available',
		noFiles: 'no-files',
		loading: 'is-loading',
		updating: 'is-updating',
		error: 'is-error',
		readonly: 'is-readonly',
		readwrite: 'is-read-write',
		dropping: 'is-dropping'
	};
	EVENT = {
		loaded: 'xs-wg-refernce-manager-loaded'
	};
	ERROR_MSG = {
		search : 'To perform a search, you must pin the Performance Study app to the dashboard.'
	};
	// Prototype
	Polymer({ // jshint ignore:line
		is: 'xs-wg-reference-manager',
		properties: {
			// Adapter Object
			_adp: {
				type: Object
			},
			// Object id which is binded
			value: {
				notify: true
			},
			// Complete data which for binded object
			rawvalue: {
				type: Object,
				observer: 'rawvalueChanged'
			},
			// Label for the component
			label: {
				notify: true
			},
			// Component will be in readonly mode
			readonly: {
				type: Boolean,
				value: false,
				notify: true,
				observer: '__readOnlyChanged'
			},

			// No interaction is allowed
			disabled: {
				type: Boolean,
				value: true,
				notify: true
			},
			// Simulation Category which is container
			category: {
				value: 'Internal Data',
				notify: true,
				observer: 'categoryChanged'
			},
			// Newly created document's mode
			iomode: {
				notify: true,
				value: 'Input'
			},
			// Search criteria for adding reference
			accept: {
				notify: true,
				value: 'Simulation Document,Simulation Document - Versioned,Simulation Document - NonVersioned,Document,' +
				'3DShape,Chapter,DesignSight,FEM,GenerativeStress,Material,' +
                'PLMCoreRepReference,PLMReference,Part,PlmParameter,Products,' +
                'Requirement,SpotFastener,Test Case,Use Case,VPMReference,XRep,DOCUMENTS,Approximation, Test Execution'
			},
			// list of all documents
			_documentlist: {
				type: Array,
				value: [],
				notify: true
			},
			// List if filtered documents shown on current page
			_filtereddocumets: {
				type: Array,
				value: [],
				notify: true
			},
			// container (Simulation Folder/ Category) whose contents are shown
			_containerId: {
				observer: '_containerIdChanged'
			},

			stateread: {
				notify: true,
				value: STATE.readwrite
			},
			// Page which is currently selected
			currentPage: {
				type: Number,
				value: 0,
				notify: true
			},
			// items from document list which will go in filtered documents
			_range: {
				type: Object,
				notify: true,
				value: {
					min: 0,
					max: 10
				},
				computed: '_cumputeRange(_documentlist, currentPage)'
			},
			_errorMsg: {
				notify: true
			},
			state: {
				notify: true,
				value: STATE.noData
			}
		},

		observers: [
			'computefilteredDocuments(_documentlist, _range, showPagebar)'
		],
		// Life cycle handlers
		ready: function () {
			this._adp = this.XS();
			this.disabled = this._isDisabled(this.rawvalue);
			this.pageSize = 10;
			this.fromCache = true;
			this.iconLoaded = true;
		},

		// Property Change Handlers -- Start ------------------------------------------- //
		rawvalueChanged: function () {
			if (this.rawvalue) {
				this.disabled = this._isDisabled(this.rawvalue);
				this._getContainerIdByCategory(this.rawvalue.objectId).then(function (containerID) {
					this._containerId = containerID;
					if (!this.fromCache) {
						this._containerIdChanged();
					}
				}.bind(this)).catch(function (error) {
					this._resetTOError(error.errorMsg);
				}.bind(this));
			}
		},

		/**
         * When container id is changed document list gets updated
         */
		_containerIdChanged: function () {
			var _data, tempList = [], tempItem;
			this.$.spFileContent.getSMAContentInfo(this.rawvalue.objectId, this._containerId, 1, this.fromCache, !this.fromCache).then(function (data) {
				this.fromCache = true;
				_data = JSON.parse(data);
				_data.datarecords.datagroups.forEach(function (item) {
					tempItem = item;
					tempItem.objectTitle = this.decodeHtml(item.dataelements['title'].value[0].value);
					if (tempItem.objectTitle === '') {
						tempItem.objectTitle = item.dataelements['name'].value[0].value;
					}
					tempItem.revision = item.dataelements['revision'].value[0].value;
					tempItem.isLocked = item.dataelements['isLocked'].value[0].value;
					tempItem.lastModified = item.dataelements['lastModified'].value[0].actualValue;
					tempItem.lastModifiedDisplay = item.dataelements['lastModified'].value[0].value;
					tempItem.ioMode = item.dataelements['ioMode'].value[0].value;
					tempItem.description = item.dataelements['description'].value[0].value;
					tempItem.imageURL = item.dataelements['image'].value[0].imageValue;
					tempItem.isreferenced = String(item.dataelements['isReferenced'].value[0].value).toLowerCase() === 'true';
					if (tempItem.busType !== 'Simulation Folder' && tempItem.isreferenced) {
						tempList.push(tempItem);
					}
				}.bind(this));
				this._documentlist = tempList;
				this.state = this._documentlist.length > 0 ? STATE.filesAvailable : STATE.noFiles;
				this.fire(EVENT.loaded);
			}.bind(this)).catch(function (error) {
				this._resetTOError(JSON.parse(error.response).error);
			}.bind(this));
		},

		categoryChanged: function () {
			this.refresh();
		},

		/**
         * Based on access if readonly property changes, we need to hide checkin/update operation
         */
		__readOnlyChanged: function () {
			if (this.readonly) {
				this.stateread = STATE.readonly;
			} else {
				this.stateread = STATE.readwrite;
			}
		},

		/**
         * Get current range of files to show in UI
         * @param  {Array} documents list of all documents
         * @param  {Number} currentPage current page number
         * @returns {Object} range - an object having min and max as property from files array
         */
		_cumputeRange: function (documents, currentPage) {
			var totalLength = documents.length;
			var startCounter = 0;
			var endCounter = 0;
			if ((totalLength / this.pageSize) > 1 && (currentPage < (totalLength / this.pageSize)) && currentPage >= 0) {
				startCounter = currentPage * this.pageSize;
				if ((startCounter + this.pageSize) >= totalLength) {
					this.lastPage = true;
					endCounter = totalLength;
				} else {
					this.lastPage = false;
					endCounter = (startCounter + this.pageSize);
				}
				this.showPagebar = true;
				return {
					min: startCounter,
					max: endCounter
				};
			}
			this.showPagebar = false;
			return {
				min: 0,
				max: totalLength
			};
		},


		/**
         * based on file list and range update
         * the list of files that is going to rendered on screen
		 * @param  {Array} documentlist Document list
		 * @param  {Object} range Object having min and max property
		 * @param  {Boolean} showPagebar show page bar yes/no
		 */
		computefilteredDocuments: function (documentlist, range, showPagebar) {
			if (showPagebar) {
				// range is used in filtering documents based on range
				this._filtereddocumets = documentlist.sort(this._computeSort).filter(this._computeFilter.bind(this));
			} else {
				this._filtereddocumets = documentlist.sort(this._computeSort);
			}
		},
		// Property Change Handlers -- End ------------------------------------------- //


		/* Private Functions -- Start ------------------------------------------- */
		/**
		 * if component is disabled
		 * @param  {Object} rawvalue Rawvalue
		 * @return {Boolean} is component disabled or not
		 */
		_isDisabled: function (rawvalue) {
			this._adp = this._adp || this.XS();
			if (this._adp && this._adp.whichMode() === 'preview' && rawvalue) {
				/* With respect to IR-635266-3DEXPERIENCER2019x, UI modification is made, it now will show on hovering on component about "No interaction",
				 instead of component. Since sp-nls is component and is not util so have to code it like this (Hard coded msg).
				 */
				this.setAttribute('style', 'cursor: no-drop;');
				this.setAttribute('title', 'All interactions are blocked in Preview mode.');

				return true;
			}
			return false;
		},

		/**
         * Fetch container id by category
         * @param  {String} simulationId - Object id for Simulation Activity or Simulation Process
         * @returns {Promise} - when resolved provided container id with respect to category name
         */
		_getContainerIdByCategory: function (simulationId) {
			var _data, _containerObject;
			return new Promise(function (resolve, reject) {
				this.$.spFileContent.getSMAContentInfo(simulationId, simulationId, 1, true).then(function (data) {
					_data = JSON.parse(data);
					_containerObject = _data.datarecords.datagroups.filter(function (item) {
						return item.busType === 'Simulation Category - ' + this.category;
					}.bind(this));
					if (_containerObject === undefined || _containerObject.length === 0) {
						reject({ errorMsg: 'Category not found. Use Properties panel to choose a different category.' });
					}
					resolve(_containerObject[0].physicalId);
				}.bind(this)).catch(reject);
			}.bind(this));
		},

		/**
         * Makes the component disabled and set error message passed to UI
		 * @param  {String} errorMsg error message to show on UI
		 */
		_resetTOError: function (errorMsg) {
			this.disabled = true;
			this.state = STATE.error;
			this._errorMsg = errorMsg;
			this._documentlist = [];
		},

		/* Private Functions -- End ------------------------------------------- */


		/* Common API Functions -- Start ------------------------------------------- */
		/**
         * Again fetch data from server and refresh it
         */
		refresh: function () {
			this.fromCache = false;
			this.rawvalueChanged();
		},

		/* Common API Functions -- End ------------------------------------------- */

		// ----Drop Handlers----//

		/**
         * Validates and adds drop class to container
         * @param  {Event} event Dragenter event
         */
		onDragEnter: function (event) {
			var dataTransfer = event.dataTransfer;
			if (this._containerId && !this.readonly && !this.disabled && this.state !== STATE.error) {
				dataTransfer.dropEffect = 'move';
				this.DOM(this.$.dropOverlay).addClass(STATE.dropping);
				this._stopPropogation(event);
			} else {
				dataTransfer.dropEffect = 'none';
			}
		},

		/**
         * Validates and add drop class to container
         * @param  {Event} event dragover event
         */
		onDragOver: function (event) {
			if (this._containerId && !this.readonly && !this.disabled && this.state !== STATE.error) {
				this._stopPropogation(event);
				this.onDragEnter(event);
			}
		},

		/**
         * Removes the drop class from container
         * @param  {Event} event dragleave event
         */
		onDragLeave: function (event) {
			if (this._containerId && !this.readonly && !this.disabled && this.state !== STATE.error) {
				this._stopPropogation(event);
				this.DOM(this.$.dropOverlay).removeClass(STATE.dropping);
			}
		},

		/**
         * Files/Files which are dropped are uploaded to server
         * @param  {Event} event drop event
         */
		onDrop: function (event) {
			var data, parsedData, count, invalidType = false, invalidTypes = [];
			this.onDragLeave(event);
			if (this._isValidDropRefrenceData(event)) {
				data = event.dataTransfer.getData('text');
				parsedData = JSON.parse(data);
				count = parsedData.data.items.length;
				this.addCount = 0;
				parsedData.data.items.forEach(function (item) {
					if (!this._isValidType(item.objectType)) {
						invalidType = true;
						invalidTypes.push(item.objectType);
					}
				}.bind(this));
				if (!invalidType) {
					parsedData.data.items.forEach(function (item) {
						this._addRefrence(item.objectId, item.displayName, count);
					}.bind(this));
				} else {
					this._adp.notify({
						text: 'Add Reference Error: Reason: Invalid object type dropped ( ' + invalidTypes.toString() + ' ). Please drop valid object types.',
						type: 'error',
						autoRemove: true
					});
				}
			} else {
				this._stopPropogation(event);
				this.DOM(this.$.dropOverlay).removeClass(STATE.dropping);
			}
		},

		/**
         * stops propogation and prevent defaults to the event passed
         * @param  {Event} event any event
         */
		_stopPropogation: function (event) {
			event.preventDefault();
			event.stopPropagation();
		},

		_isValidDropRefrenceData: function (event) {
			var data, value, parsedData;
			if (this._containerId && !this.readonly && !this.disabled && this.state !== STATE.error) {
				try {
					data = event.dataTransfer.getData('text');
					parsedData = JSON.parse(data);
				} catch (e) {
					parsedData = null;
				}
				if (parsedData && parsedData.data && parsedData.data.items) {
					value = parsedData.data.items[0];
					// && this.accept.split(/\s*,\s*/).contains(value.objectType)
					if (value && value.objectId !== undefined) {
						return true;
					}
				} else {
					return false;
				}
			}
			return false;
		},

		_isValidType: function (type) {
			return this.accept.split(',').indexOf(type) !== -1;
		},

		addRefrence: function () {
			this.$.spSearch.search();
		},

		showProperties: function (event) {
			var result, instance = event.model[this.$.fileList.as];
			result = this.showObjectProperties(instance.objectId, this.$.dashboard);
			if (result.success === false) {
				this._adp.notify({
					text: result.msg,
					type: 'error',
					autoRemove: true
				});
			}
		},

		onSearch: function (event) {
			var objectList, count;
			event.stopPropagation();
			objectList = event.detail.getSelectedObjects();
			count = objectList.length;
			this.addCount = 0;
			objectList.forEach(function (obj) {
				this._addRefrence(obj.objectId, obj.displayName, count);
			}.bind(this));
		},

		_addRefrence: function (contentid, title, totalCount) {
			this.state = STATE.loading;
			this.disabled = true;
			if (this._isObjectAlreadyPresent(contentid, this._documentlist)) {
				this._adp.notify({
					text: 'Warning: Object already available. Title: ' + title,
					type: 'warning',
					autoRemove: true
				});
				this._enableCompAfterRefAdd(totalCount);
			} else {
				this.$.spFileContent.addReferenceContent(this.rawvalue.objectId, this._containerId, contentid, this.iomode).then(function () {
					this._enableCompAfterRefAdd(totalCount);
				}.bind(this)).catch(function (error) {
					this._enableCompAfterRefAdd(totalCount);
					this._adp.notify({
						text: 'Error: Unable to add Refrence content - ' + title + '- ' + JSON.parse(error.response).error,
						type: 'error',
						autoRemove: true
					});
				}.bind(this));
			}
		},

		_removeRefrence: function (event) {
			var instance = event.model[this.$.fileList.as];
			this.state = STATE.updating;
			this.disabled = true;
			this.$.spFileContent.removeReferenceContent(this.rawvalue.objectId, this._containerId, instance.objectId).then(function () {
				this.refresh();
			}.bind(this)).catch(function (error) {
				this.refresh();
				this._adp.notify({
					text: 'Error: Unable to add Refrence content - ' + instance.objectTitle + '- ' + JSON.parse(error.response).error,
					type: 'error',
					autoRemove: true
				});
			}.bind(this));
		},

		_enableCompAfterRefAdd: function (totalCount) {
			this.addCount += 1;
			if (this.addCount === totalCount) {
				this.addCount = 0;
				this.refresh();
			}
		},

		_isObjectAlreadyPresent: function (contentid, documentlist) {
			var object;
			documentlist.forEach(function (doc) {
				if (doc.objectId === contentid || doc.physicalId === contentid) {
					object = doc;
				}
			});
			return (object !== undefined);
		},

		_computeMainClass: function (disabled) {
			var mainClass = 'main';
			if (disabled) {
				mainClass += ' is-disabled';
			}
			return mainClass;
		},
		/**
         * class that there are multiple pages ot not
         * @param  {Boolean} showPagebar page bar has to be shown or not
         * @return {String} one | multi
         */
		_getFileContainerPage: function (showPagebar) {
			if (showPagebar) {
				return 'multi';
			}
			return 'one';
		},

		/**
         * Go to Previous page
         * @param  {Event} event click event from previous page button
         */
		previousPage: function (event) {
			event.stopPropagation();
			if (this.currentPage !== 0) {
				this.currentPage = this.currentPage - 1;
			}
		},

		/**
         * Go to Next page
         * @param  {Event} event click event from previous next button
         */
		nextPage: function (event) {
			event.stopPropagation();
			if (!this.lastPage) {
				this.currentPage = this.currentPage + 1;
			}
		},

		/**
         * based on file sie and page size , claculates total number of files
         * @param  {Array} _files list of files
         * @param  {Number} currentPage currently opened page
         * @return {String} Page start of all
         */
		_getCurrentPageInfo: function (_files, currentPage) {
			var totalPage = Math.ceil(_files.length / this.pageSize);
			return 'Page ' + (currentPage + 1) + ' of ' + totalPage;
		},

		/**
         * Computes wheather previous page button is active or not
         * @param  {Number} currentPage currently active page
         * @return {Boolean} if previous button disabled or not
         */
		_isPreviousDisabled: function (currentPage) {
			if (currentPage <= 0) {
				return true;
			}
			return false;
		},

		/**
         * Computes wheather next page button is active or not
         * @param  {Number} lastPage lat page
         * @return {Boolean} if next button disabled or not
         */
		_isNextDisabled: function (lastPage) {
			return lastPage;
		},

		/**
         * sorting is done based on modified date, if dat is same then based on name
         * @param  {Object} a first object
         * @param  {Object} b second oject
         * @return {Number} -1,1,0 based on comparision
         */
		_computeSort: function (a, b) {
			var aDate = Number(a.lastModified);
			var bDate = Number(b.lastModified);
			if (aDate === bDate) {
				return a.objectTitle > b.objectTitle ? 1 : -1;
			}
			return aDate > bDate ? -1 : 1;
		},

		/**
         * Filters out file array to fall between range
         * @param  {Object} item file item
         * @param  {Number} index index of file
         * @return {Boolean} if index falls between range
         */
		_computeFilter: function (item, index) {
			return (index >= this._range.min && index < this._range.max);
		},

		decodeHtml: function (html) {
			var txt = document.createElement('textarea');
			txt.innerHTML = html;
			return txt.value;
		},

		spError: function(event) {
			this._adp.notify({
				text: event.detail.errorCode === 'SMAProcSP.SPSearch.1' ? ERROR_MSG.search : event.detail.message,
				type: 'error',
				autoRemove: true
			});
			event.stopPropagation();
		},
		// Inheritance
		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(this));
