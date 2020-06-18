/*--------------------------------------------------------------------
[xs-wg-document-manager Javascript Document]
Project:        xs
Version:        1.0
Description:    TODO: Write Description
---------------------------------------------------------------------*/
/* global DS, Polymer*/

(function () {
	'use strict';

	// global variables
	var STATE, DROPTYPE, EVENT;
	var VALID_TYPE = ['Simulation Document', 'Simulation Document - Versioned', 'Simulation Document - NonVersioned', 'Document'];
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
	DROPTYPE = {
		chrome: 'Files',
		firefox: 'application/x-moz-file',
		ie: 'Files'
	};
	EVENT = {
		loaded: 'xs-wg-document-manger-loaded'
	};
	// Prototype
	window.Polymer({
		is: 'xs-wg-document-manager',
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
			// Policy of the newly created document
			isversioned: {
				type: Boolean,
				notify: true,
				value: false
			},
			createtype: {
				notify: true,
				value: 'Owned'
			},
			// Newly created document's mode
			iomode: {
				notify: true,
				value: 'Input'
			},
			attrgroupid: {
				notify: true
			},
			selectattributegroup: {
				notify: true,
				value: 'Disable'
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
					tempItem.objectTitle = this.decodeHtml(item.dataelements.title.value[0].value);
					if (tempItem.objectTitle === '') {
						tempItem.objectTitle = item.dataelements.name.value[0].value;
					}
					tempItem.revision = item.dataelements.revision.value[0].value;
					tempItem.isLocked = item.dataelements.isLocked.value[0].value;
					tempItem.hasModifyAccess = String(item.dataelements['hasModifyAccess'].value[0].value).toLowerCase() === 'true';
					tempItem.lastModified = item.dataelements.lastModified.value[0].actualValue;
					tempItem.lastModifiedDisplay = item.dataelements.lastModified.value[0].value;
					tempItem.ioMode = item.dataelements.ioMode.value[0].value;
					tempItem.description = item.dataelements.description.value[0].value;
				  tempItem.isreferenced = String(item.dataelements.isReferenced.value[0].value).toLowerCase() === 'true';
					//tempItem.isreferenced = false;
					tempItem.imageURL = item.dataelements.image.value[0].imageValue;
					tempItem.expanded = false;
					if (this._isValidType(tempItem.busType)) {
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
			this.attrgroupid = undefined;
			this.attributeGroupCallback = undefined;
			this.rawvalueChanged();
			this.currentPage = 0;
		},

		/* Common API Functions -- End ------------------------------------------- */


		// ----------------Progress bar code start--------------------
		/**
         * Removes the progress bar for given file
         * @param  {String} name name of file
         */
		removeProgressBar: function (name) {
			var index = this._getFileIndex(this._filtereddocumets, name);
			if (index !== -1) {
				this._filtereddocumets[index].uploaded = 100;
				Polymer.Base.set('_filtereddocumets.' + index + '.uploaded', 100, this);
				this.notifyPath('_filtereddocumets.' + index + '.uploaded', 100);
			}
			if (this._uploadFileCount && this._uploadFileCount > 1) {
				this._uploadFileCount -= 1;
			} else {
				if (this._uploadFileCount) {
					this._uploadFileCount -= 1;
				}
				this.disabled = false;
				this.refresh();
			}
		},

		toggleCollapse: function (event) {
			var instance = event.model[this.$.fileList.as];
			var index = this._getFileIndexById(this._filtereddocumets, instance.objectId);
			var isExpanded = this._filtereddocumets[index].expanded;
			if (index !== -1) {
				Polymer.Base.set('_filtereddocumets.' + index + '.expanded', !isExpanded, this);
				this.notifyPath('_filtereddocumets.' + index + '.expanded', !isExpanded);
			}
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

		editTitle: function(event){
			if (this.disabled || this.readonly) {
				return;
			}
			var _title = event.target.textContent;
			var instance = event.model[this.$.fileList.as];
			if (instance.objectId) {
				var input = document.createElement('input');
				input.setAttribute('type', 'text');
				input.setAttribute('value', _title);
				input.dataset.id = instance.objectId;
				input.setAttribute('spellcheck', false);
				input.addEventListener('blur', this.changeTitle.bind(this));
				event.target.style.display = 'none';
				event.target.parentElement.insertBefore(input, event.target);
				input.focus();
			}
		},

		changeTitle: function(event){
			var _divNode, _changedTitle, msg, _documentId, _originalTitle, index;
			_divNode = event.target.parentElement.getElementsByClassName('doc-title')[0];
			_changedTitle = event.target.value;
			if (_changedTitle.length === 0){
				msg = 'Title cannot be empty, Please provide some valid title.';
				this._adp.notify({
					text: msg,
					type: 'error',
					autoRemove: true
				});
			} else if (this.hasBadCharecter(_changedTitle) && _changedTitle.length > 0){
				msg = 'Title contains forbidden characters like  " # $ @ % * , ? \\ < > [ ] | :';
				this._adp.notify({
					text: msg,
					type: 'error',
					autoRemove: true
				});
			} else if (!this.hasBadCharecter(_changedTitle) && _changedTitle.length > 0){
				_documentId = event.target.dataset.id;
				_originalTitle = event.target.defaultValue;
				index = this._getFileIndexById(this._filtereddocumets, _documentId);
				this.disabled = true;
				this.$.spFileContent.updateDocumentTitle(_documentId, _changedTitle).then(function () {
					this.disabled = false;
					if (_changedTitle !== _originalTitle){
					  this.state = STATE.updating;
						this.refresh();
					}
				}.bind(this))['catch'](function () {

					this._adp.notify({
						text: 'Unable to update title',
						type: 'error',
						autoRemove: true
					});
					this.disabled = false;
					this.refresh();
				}.bind(this));
				Polymer.Base.set('_filtereddocumets.' + index + '.objectTitle', _changedTitle, this);
				this.notifyPath('_filtereddocumets.' + index + '.objectTitle', _changedTitle);
			}
			_divNode.style.display = 'inline-block';
			event.target.parentElement.removeChild(event.target);
		},

		hasBadCharecter: function(_changedTitle){
			var titlePattern = new RegExp("^((?!#)(?!,)(?!\\|)(?!\\[)(?!\\$)(?!\\])(?!@)(?!%)(?!:)(?!')(?!\")(?!\\\\)(?!\\*)(?!\\?)(?!<)(?!>).)*$");
			if (!titlePattern.test(_changedTitle)){
				return true;
			}
			return false;
		},
		/**
         * Calculates style for progress bar based on progress
         * @param  {Number} uploaded percentage of file upload
         * @return {String} background style which has to applied to file entry while upload
         */
		getStyleForProgress: function (uploaded) {
			var uploadedNum;
			if (Number(uploaded) !== isNaN && Number(uploaded) < 100 && Number(uploaded) > 0) {
				uploadedNum = Number(uploaded);
				return 'background-image: linear-gradient(to right,#57B847, #57B847 ' + uploadedNum + '%, #e2e4e3 ' + uploadedNum + '%,#e2e4e3 ' + (100 - uploadedNum) + '%)';
			}
			return 'background-image: none';
		},

		/**
         * updates the progress bar
         * @param  {Event} event Update event having upload progress info
         */
		updateProgress: function (event) {
			// Set current page to one is available to show progress bar as those items will move to top
			var data = event.detail;
			var index = this._getFileIndex(this._filtereddocumets, data.fileInfo.fileName);
			if (index !== -1) {
				this._filtereddocumets[index].uploaded = data.uploaded;
				Polymer.Base.set('_filtereddocumets.' + index + '.uploaded', data.uploaded, this);
				this.notifyPath('_filtereddocumets.' + index + '.uploaded', data.uploaded);
			}
		},
		// ----------------Progress bar code Ends--------------------

		// ----Drop Handlers----//

		/**
         * Validates and adds drop class to container
         * @param  {Event} event Dragenter event
         */
		onDragEnter: function (event) {
			var dataTransfer = event.dataTransfer;
			if (this._containerId && !this.readonly && !this.disabled && this.state !== STATE.error && this._isValidDropData(event)) {
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
			if (this._containerId && !this.readonly && !this.disabled && this.state !== STATE.error && this._isValidDropData(event)) {
				this._stopPropogation(event);
				this.onDragEnter(event);
			}
		},

		/**
         * Removes the drop class from container
         * @param  {Event} event dragleave event
         */
		onDragLeave: function (event) {
			if (this._containerId && !this.readonly && !this.disabled && this.state !== STATE.error && this._isValidDropData(event)) {
				this._stopPropogation(event);
				this.DOM(this.$.dropOverlay).removeClass(STATE.dropping);
			}
		},

		/**
         * Files/Files which are dropped are uploaded to server
         * @param  {Event} event drop event
         */
		onDrop: function (event) {
			this.onDragLeave(event);
			if (this._isValidDropData(event, true) && event.dataTransfer.files) {
				this._uploadMultipleDocuments(event.dataTransfer.files);
				this._stopPropogation(event);
			} else {
				this._onDropError(event);
			}
		},

		_onDropError: function (event) {
			if (!this.readonly && !this.disabled) {
				this._adp.notify({
					text: 'Upload Error: Reason: Invalid Files(HTML/HTM) or Folder dropped. Please drop valid files',
					type: 'error',
					autoRemove: true
				});
			}
			this._stopPropogation(event);
			this.DOM(this.$.dropOverlay).removeClass(STATE.dropping);
		  },

		/**
         * stops propogation and prevent defaults to the event passed
         * @param  {Event} event any event
         */
		_stopPropogation: function (event) {
			event.preventDefault();
			event.stopPropagation();
		},

		/**
         * Validates the drop done from local disk
         * @param  {Event} event event having file info
         * @param  {Boolean} folderCheck need to check folders or not
         * @return {Boolean} is drop valid or not
         */
		_isValidDropData: function (event, folderCheck) {
			var browser, typeCheck, isValidType, prop, browserType;
			var types = event.dataTransfer.types;
			if (!this.readonly && !this.disabled) {
				browser = navigator.userAgent;
				typeCheck = browser.contains('Chrome') ? DROPTYPE.chrome : '';
				if (typeCheck === '') {
					typeCheck = browser.contains('Firefox') ? DROPTYPE.firefox : DROPTYPE.ie;
				}
				if (browser.contains('Chrome')) {
					browserType = 'chrome';
				} else if (browser.contains('Firefox')) {
					browserType = 'firefox';
				} else {
					browserType = 'ie';
				}
				isValidType = false;
				for (prop in types) {
					if (types[prop] === typeCheck) {
						isValidType = true;
						break;
					}
				}
				if (isValidType && folderCheck) {
					isValidType = !this.containsHTMLFiles(event.dataTransfer.files);
					if (isValidType && browserType === 'chrome') {
						if (event.dataTransfer.items && event.dataTransfer.items.length) {
							[].forEach.call(event.dataTransfer.items, function (item) {
								var entry = item.webkitGetAsEntry();
								if (entry && entry.isDirectory) {
									isValidType = false;
								}
							});
						}
					} else if (isValidType && browserType === 'ie') {
						if (folderCheck && isValidType && event.dataTransfer.files && event.dataTransfer.files.length === 0) {
							isValidType = false;
						}
					} else if (browserType === 'firefox') {
						if (isValidType && this.containsFFFolder(event.dataTransfer.files)) {
							isValidType = false;
						}
					}
				}
				return isValidType;
			}
			return false;
		},

		/**
		 * containsFFFolder is used here only for firefox case
		 * This will only break when the file size is multiple of 4096
		 * Also please do not name your Folder with a dot(.) anywhere in it
		 * @param {Array} fileList list of files slected by user
		 * @returns {Boolean} if it has folder then true else false
		 */
		containsFFFolder: function (fileList) {
			var hasFolder = false;
			[].forEach.call(fileList, function (file) {
				if (file.type === '' && file.name.indexOf('.') === -1 && file.size % 4096 === 0) {
					hasFolder = true;
				}
			});
			return hasFolder;
		},
		containsHTMLFiles: function (fileList) {
			var hasHTMLFile = false;
			[].forEach.call(fileList, function (file) {
				if (file.type === 'text/html')	{ hasHTMLFile = true; }
			});
			return hasHTMLFile;
		},

		/**
         * click handler for upload button
         * @param  {Event} event Uploading/Updating multiple files - will open a multi file selector
         */
		create: function () {
			if (!this.disabled) {
				this.uploadModel = undefined;
				this.$.uploadBtnMultiple.click();
			}
		},

		/**
         * Fetch files from disk and call upload multiple files button
         * @param  {Event} event event has user selected multiple files
         */
		_fetchMultipleFileFromDisk: function (event) {
			var target = event.target;
			if (target.files.length > 0) {
				if (!this.containsHTMLFiles(target.files)) {
					this._uploadMultipleDocuments(target.files);
				} else {
					this._onDropError(event);
				}
			}
			target.value = '';
		},

		/**
         * Fetch files from disk and call upload multiple files button
         * @param  {Array} files list of files read from user directory
         */
		_uploadMultipleDocuments: function (files) {
			var newFile = '';
			var validFileList = [];
			var updateUIList = [];
			var i = 0, j = 0;
			for (i = 0; i < files.length; i += 1) {
				newFile = files[i];
				validFileList.push(newFile);
				updateUIList.push({
					objectId: '',
					objectTitle: newFile.name,
					lastModified: new Date(),
					objectType: this.isversioned ? 'Simulation Document - Versioned' : 'Simulation Document - NonVersioned',
					ioMode: this.iomode,
					imageURL: '',
					expanded: false,
					busType: ''
				});
			}
			this._documentlist = updateUIList;
			this._uploadFileCount = validFileList.length;
			this.attrgroupid = '';
			this._getAttributeGroupUserInput(function(){
				for (j = 0; j < validFileList.length; j += 1) {
					this._create(validFileList[j]);
				}
			}.bind(this));
		},

		_isValidType: function (type) {
			return (VALID_TYPE.indexOf(type) !== -1);
		},
		/**
         * Uploads the file to Server
         * @param  {File} fileDropped File to be updated or uploaded
         */
		_create: function (fileDropped) {
			var errorMsg;
			var uploadOptions = {
				documentid: undefined,
				policy: 'Simulation Document',
				fileName: fileDropped.name,
				file: fileDropped,
				simulationId: this.rawvalue.objectId,
				containerId: this._containerId,
				documentType: this.isversioned ? 'Simulation Document - Versioned' : 'Simulation Document - NonVersioned',
				documentTitle: fileDropped.name,
				createType: this.createtype,
				ioMode: this.iomode,
				attributeGroupId: this.attrgroupid
			};

			// showing the loading spinner
			this.state = STATE.updating;
			this.disabled = true;
			this.$.spFileContent.createDocumentAndUploadFile(uploadOptions).then(function () {
				this.removeProgressBar(uploadOptions.fileName);
			}.bind(this))['catch'](function (info) {
				try {
					errorMsg = JSON.parse(info.response).datarecords.datagroups[0].dataelements.error.value[0].value;
				} catch (err) { /* Fail Silently is not error message found*/ }
				this._adp.notify({
					text: errorMsg,
					type: 'error',
					autoRemove: true
				});
				this.removeProgressBar(uploadOptions.fileName);
			}.bind(this));
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
         * Gives the index of file in the given array
         * @param  {Array} filesArray List of files
         * @param  {String} name name of file to be searched
         * @return {Number} index of file in given index
         */
		_getFileIndex: function (filesArray, name) {
			var index = -1;
			filesArray.forEach(function (fileInfo) {
				if (fileInfo.objectTitle === name) {
					index = filesArray.indexOf(fileInfo);
				}
			});
			return index;
		},

		/**
         * Gives the index of file in the given array
         * @param  {Array} filesArray List of files
         * @param  {String} objectId name of file to be searched
         * @return {Number} index of file in given index
         */
		_getFileIndexById: function (filesArray, objectId) {
			var index = -1;
			filesArray.forEach(function (fileInfo) {
				if (fileInfo.objectId === objectId) {
					index = filesArray.indexOf(fileInfo);
				}
			});
			return index;
		},

		/**
		 * fetch attribute group connected to Process or Activity then ask user to select one
		 * @param {any} callback callback to be called to upload files
		 */
		_getAttributeGroupUserInput: function(callback) {
			if (this.selectattributegroup === 'Disable') {
				callback();
			} else if (this._attributeList && this._attributeList.length > 0) {
				this.attributeGroupCallback = callback;
				this._showAtrributeGroupSelection();
			} else if (this._attributeGroupLoaded !== true){
				this.$.spFileContent.getRelatedAttributeGroup(this.rawvalue.objectId).then(function(response){
					if (this._isValidAttributes(response)) {
						this.attributeGroupCallback = callback;
						this._showAtrributeGroupSelection();
					} else {
						this._attributeGroupLoaded = true;
						callback();
					}
				}.bind(this))['catch'](function(error){
					this._resetTOError(JSON.stringify(error));
				}.bind(this));
			} else {
				callback();
			}
		},

		_showAtrributeGroupSelection: function() {
			if (this._attributeList && this._attributeList.length > 0) {
				this.$.attributeGroupSelector.value = this.attrgroupid || this._attributeList[0].value;
				this.$.attributeSelector.classList.add('block-display');
			}
		},

		_hideAtrributeGroupSelection: function() {
			this.$.attributeSelector.classList.remove('block-display');
		},

		_isValidAttributes: function(response) {
			var data = JSON.parse(response), validAttributes = [];
			data.datarecords.datagroups[0].children.forEach(function(attribute){
				if (attribute.dataelements.associatedtypes.value[0].value === '&#x2a;' || attribute.dataelements.associatedtypes.value[0].value === '') {
					validAttributes.push({
						label: attribute.dataelements.title.value[0].value,
						value: attribute.physicalId
					});
				}
			});
			if (validAttributes && validAttributes.length > 0) {
				this._attributeList = validAttributes;
				return true;
			}
			return false;
		},

		_onAttributeGroupSelectApply: function(event){
			event.stopPropagation();
			this._hideAtrributeGroupSelection();
			this.attrgroupid = this.$.attributeGroupSelector.value;
			this.attributeGroupCallback && this.attributeGroupCallback();
		},

		_onAttributeGroupSelectSkip: function(event){
			event.stopPropagation();
			this._hideAtrributeGroupSelection();
			this.attrgroupid = undefined;
			this.attributeGroupCallback && this.attributeGroupCallback();
		},

		_onAttributeGroupSelectCancel: function(event){
			event.stopPropagation();
			this._hideAtrributeGroupSelection();
			this.refresh();
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

		_computeCollapseClass: function (expanded) {
			var collapseIcon = 'fonticon collapse-icon';
			if (!expanded) {
				collapseIcon += ' is-collapsed';
			}
			return collapseIcon;
		},

		_comuputeReadOnly: function(readonly, hasModifyAccess) {
			return readonly || !hasModifyAccess;
		},

		decodeHtml: function (html) {
			var txt = document.createElement('textarea');
			txt.innerHTML = html;
			return txt.value;
		},

		notifyCanvas: function (e) {
			var details = e.detail;
			var operation = details.operation.charAt(0).toUpperCase() + details.operation.substr(1).toLowerCase();
			var msg = operation + ' ' + details.status + ': ' + details.filename;
			if (details.msg && details.msg !== '') {
				msg += '\n Reason: ' + details.msg.trim();
			}
			this._adp.notify({
				text: msg,
				type: details.type,
				autoRemove: true
			});
			e.stopPropagation && e.stopPropagation();
		},
		// Inheritance
		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(this));
