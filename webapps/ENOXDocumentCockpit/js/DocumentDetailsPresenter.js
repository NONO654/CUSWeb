define(
	'DS/ENOXDocumentCockpit/js/DocumentDetailsPresenter',
	['DS/UIKIT/Mask', 'DS/CoreEvents/ModelEvents', 'UWA/Element',
		'UWA/Class/Model', 'DS/ENOXIDCardContainer/js/ENOXIDCardContainer',
		'DS/ENOXSplitView/js/ENOXSplitView', 'DS/ENOXTabs/js/ENOXTabs',
		'DS/DocumentManagement/DocumentManagement',
		'DS/ENOXDocumentCockpit/js/FileKPI',
		'DS/ENOXDocumentCockpit/js/util/DocCockpitIdCardAttributeEditor',
		'DS/ENOXDocumentCockpit/js/util/DocCockpitIdCardAttributeCreator',
		'DS/ENOXDocumentCockpit/js/FileDetailsPresenter',
		'i18n!DS/ENOXDocumentCockpit/assets/nls/DocumentCockpit',
		'css!DS/ENOXDocumentCockpit/css/DocumentDetails.css'],
	function (
		// Handlebars,
		Mask, ModelEvents, _uwa_element, _uwa_Model, ENOXIDCardContainer,
		ENOXSplitView, ENOXTabs, DocumentManagement, FileKPI,DocCockpitIdCardAttributeEditor,
		DocCockpitIdCardAttributeCreator,FileDetailsPresenter, Document_NLS,_css_modelDetails) {

	var debug_DocumentDetailsPresenter = false; // = window.localStorage.XMODEL_BROWSER_LOG_DEBUG;

	var DocumentDetailsPresenter = function () {
		this.EVENTOUT_MANAGE_VERSION = "enoxdoc-open-version-explorer";
		this.EVENTOUT_MANAGE_OWNER = "enoxdoc-open-owner-management";
		this.EVENTOUT_MANAGE_MATURITY = "enoxdoc-open-maturity-management";
		this.EVENTOUT_MANAGE_PROPERTY = "enoxdoc-open-property-management";
	};

	// register to the event of the user clicked on the Revision (link) of the
	// document
	DocumentDetailsPresenter.prototype.registerToOpenVersionManager = function (
		callback) {
		this._applicationChannel.subscribe({
			event: this.EVENTOUT_MANAGE_VERSION
		}, callback);
	};

	// register to the event of the user clicked on the Owner (link) of the
	// document
	DocumentDetailsPresenter.prototype.registerToOpenOwnerManager = function (
		callback) {
		this._applicationChannel.subscribe({
			event: this.EVENTOUT_MANAGE_OWNER
		}, callback);
	};

	// register to the event of the user clicked on the maturity (link) of the
	// document
	DocumentDetailsPresenter.prototype.registerToOpenMaturityManager = function (
		callback) {
		this._applicationChannel.subscribe({
			event: this.EVENTOUT_MANAGE_MATURITY
		}, callback);
	};

	// register to the event of the user clicked on the maturity (link) of the
	// document
	DocumentDetailsPresenter.prototype.registerToOpenPropertyManager = function (
		callback) {
		this._applicationChannel.subscribe({
			event: this.EVENTOUT_MANAGE_PROPERTY
		}, callback);
	};

	//console.log("compiling");
	DocumentDetailsPresenter.prototype.init = function (applicationChannel,
		options) {
		this._isDestroyed = false;
		this._applicationChannel = applicationChannel;
		this._options = options;
		this._id = options.id;
		/*
		 * this.PCName = options.name; this.PCImage = options.image;
		 */
		if (debug_DocumentDetailsPresenter) {
			console.log(options);
		}
		this._modelForIdCard = {};
		this.options = options;
		this._idCardData = {};
		this._enoxIDCardContainer = new ENOXIDCardContainer();
		this._privateModelEvents = new ModelEvents();
		this._privateModelEventsForSplitView = new ModelEvents();
		this._bridgeModelEvent = new ModelEvents();
		this._kpiModelEvents = new ModelEvents();
		this._privateChannelForSplitView = new ModelEvents();

		var splitView_options = {
			modelEvents: this._privateChannelForSplitView,
			withtransition: true,
			withoverflowhidden: false,
			params: {
				leftWidth: 40,
				leftVisible: true,
				rightVisible: false,
				rightMaximizer: true,
				leftMaximizer: false
			}
		};
		this._splitView = new ENOXSplitView();
		this._splitView.init(splitView_options);

		this._idCardAttrbEditorUtil = new DocCockpitIdCardAttributeEditor();
		this._idCardAttrbEditorUtil.init(this._privateModelEvents);

		this._initDivs();
		this._subscribeToEvents();
		this._initContentTabs();
	};
	DocumentDetailsPresenter.prototype._initDivs = function () {
		var that = this;
		this._container = UWA.createElement('div');
		this._container.classList.add('model-details');

		this._contentBottom = UWA.createElement('div');
		this._contentBottom.classList.add('bot-content');

		this._splitView.inject(this._contentBottom);
		this._leftPanelBottom = this._splitView.getLeft();
		this._rightPanelBottom = this._splitView.getRight();

		this._filesContainer = UWA.createElement('div');
		this._filesContainer.classList.add('model-baselines-container');
		// this._filesPresenter.inject(this._filesContainer);
		// this._filesContainer = {};
		// this._filesPresenter.render().inject(this._filesContainer);

	};

	DocumentDetailsPresenter.prototype.openDocument = function (docId) {
		// TODO
		// Refresh to view for another document, used from the version graph to navigate revision
	}

	DocumentDetailsPresenter.prototype._initContentTabs = function () {
		var that = this;

		var filesTab = {
			text: Document_NLS.DOC_Tab_File,
			fonticon: 'fonticon fonticon-attributes',
            allowUnsafeHTMLOnTabButton : false,
			content: function (parentContainer) {
				UWA.extendElement(parentContainer).setContent(that._filesContainer);
			}
		};
		var emptyTab = {
			text: '',
			fonticon: 'fonticon fonticon-attributes',
            allowUnsafeHTMLOnTabButton : false,
			content: function (parentContainer) {}
		};
		this._tabsOptions = {
			withCloseButton: false,
            allowUnsafeHTMLOnTabButton : false,
			// tabs: [variabilityTab, rulesTab, baselinesTab, PCsTab, reqsTab,
			// docsTab],
			tabs: [filesTab, emptyTab],
			modelEvents: that._bridgeModelEvent,
			lazyRendering: false,
			initialSelectedIndex: 0
		};
		this._tabbedObj = new ENOXTabs(this._tabsOptions);
		this._tabbedObj.render().inject(this._leftPanelBottom);
	};

	DocumentDetailsPresenter.prototype.inject = function (parent) {
		parent.appendChild(this._container);
	};

	DocumentDetailsPresenter.prototype._subscribeToEvents = function () {
		var that = this;

		this._bridgeModelEvent.subscribe({
			event: 'right-side-bar-tab-changed'
		}, function (eventData) {
			that._privateChannelForSplitView.publish({
				event: 'splitview-hide-panel',
				data: 'right'
			});
		});

		this._privateModelEvents.subscribe({
			event: 'idcard-open-version-explorer'
		}, function (data) {
			// open version explorer
			// if (that.versionExplorer) {
			// 	that.versionExplorer.showVersionExplorer();
			// }

			var idCard = that._enoxIDCardContainer.getIDCard();
			if (idCard) {
				var versionLabel = idCard.getElement('.version');
				if (versionLabel) {
					var data = {
						id: this._id,
						versionLabel: versionLabel,
						container: this._container
					};
					that._applicationChannel.publish({
						event: that.EVENTOUT_MANAGE_VERSION,
						data: data
					});
				}
			}
		});

		this._privateModelEvents
		.subscribe({
			event: 'idcard-attributes-clicked'
		},
			function (dataDetails) {
			// open version explorer
			if (debug_DocumentDetailsPresenter) {
				console.log('attribute clicked..');
			}
			var modelContext = {
				_selectedItems: [],
				_isMultiSelectMode: false,
				name: 'pad_component',
				initialize: function (xEngApp) {},
				init: function (options) {
					this._parent(options);
				},
				getContext: function () {
					return this;
				},
				author: function (bool) {
					return true;
				},
				getSelectedNodes: function () {
					return this._selectedItems;
				},
				resetSelection: function () {
					this._selectedItems = [];
				},
				addSelection: function (items, reset) {
					(true) ? this._selectedItems = [] : null;
					var that = this;

					if (UWA.is(items, 'array')) {
						items.forEach(function (item) {
							that._selectedItems.push(item);
						})
					} else {
						this._selectedItems.push(items);
					}
				},
				getReference: function (node) {
					return node.getID();
				},
				getParent: function (node) {
					return node.getParent();
				},
				getType: function (node) {
					return node.getType();
				},
				getName: function (node) {
					return node.getLabel();
				}
			};
			var ModelNode = UWA.extend(that._modelForIdCard, {
					getID: function () {
						return this.get('id');
					},
					getLabel: function () {
						return this.get('name');
					},
					getOwner: function () {
						return this.get('owner');
					},
					getType: function () {
						return this.get('type');
					},
					getDisplayName: function () {
						return this.get('name');
					},
					object: {
						revision: that._modelForIdCard.get('version')
					}
				});
			modelContext.addSelection(ModelNode);

			if (UWA.is(dataDetails.index, 'number')) {
				if (that._modelForIdCard.get('attributes')[dataDetails.index].name == 'Maturity') {
					if (debug_DocumentDetailsPresenter) {
						console.log('attribute clicked..maturity');
					}

					that._applicationChannel.publish({
						event: that.EVENTOUT_MANAGE_MATURITY,
						data: {
							id: modelContext
						}
					});

				} else if (that._modelForIdCard.get('attributes')[dataDetails.index].name == 'Owner') {
					if (debug_DocumentDetailsPresenter) {
						console.log('attribute clicked..owner');
					}
					that._applicationChannel.publish({
						event: that.EVENTOUT_MANAGE_OWNER,
						data: {
							id: modelContext
						}
					});
				}

			}
		});

		this._privateModelEvents.subscribe({ 'event': 'idcard-model-refresh' }, function (data) {
				console.log("ID Card Model refresh Event handler!!! dce6_1");
				that._refreshIdCardModel();
		});
	};

	DocumentDetailsPresenter.prototype._loadData = function (data) {
		    var that = this;

		if (data === undefined || data === null) {
				return;
		}

		this._modelForIdCard = DocCockpitIdCardAttributeCreator.prepareIdCardData(data, this._privateModelEvents);
		this._idCardAttrbEditorUtil.setDocIdAndInitCollabObj(this._modelForIdCard);
		this._enoxIDCardContainer.init({ modelEvents: this._privateModelEvents }, this._modelForIdCard); // all default options should do it

		that._enoxIDCardContainer.inject(that._container);

		var bottom = that._enoxIDCardContainer.getMainContent();
		// set the content of the bottom
		// bottom.innerHTML = that._contentBottom.innerHTML;
		bottom.appendChild(that._contentBottom);
		var idCard = that._enoxIDCardContainer.getIDCard();
		if (idCard) {
			var versionLabel = idCard.getElement('.version');
			if (versionLabel) {

				var data = {
					id: this._id,
					versionLabel: versionLabel,
					container: this._container
				};
				if (that._options.installVersionExplorer) {
					that._options.installVersionExplorer(data);
				}

			}
		}
	};

	DocumentDetailsPresenter.prototype._loadFilesData = function (dataDetails) {
		var l_data = UWA.clone(dataDetails);
		this._FilesPresenter = new FileDetailsPresenter({
				docId: this._id,
				dataJSON: l_data,
                //allowUnsafeHTMLContent: true,
				applicationChannel: this._applicationChannel,
				localChannel: this._privateModelEvents,
				"Columns-Data" : {
				"Columns" : [
				  {
				        "text": Document_NLS.DOC_Column_Files,
				        "dataIndex": "tree",
				        "width": "50%",
				        "valueAttribute" : "title",
				        "isSortable": true
				    },
				    {
				          "text": Document_NLS.DOC_Column_Status,
				          "dataIndex": "status",
				          "width": "20%",
				          "valueAttribute" : "status",
				          "isSortable": false
                          //"allowUnsafeHTMLContent" : true
				      },
				    {
				        "text": Document_NLS.DOC_Column_Version,
				        "dataIndex": "version",
				        "valueAttribute" : "version",
				        "width": "30%",
				        "isSortable": false
				    }
				]
				}
			});
		this._FilesPresenter.render().inject(this._filesContainer);
		//	this._FilesPresenter.attachResizeSensor();
	};

	DocumentDetailsPresenter.prototype.fetchData = function () {

		var that = this;
		Mask.mask(this._container);
		// UWA.extendElement(this._filesContainer);
		// Mask.mask(this._filesContainer);
		var options = {
			getVersions: true,
			'onComplete': function (output) {
				if (that._isDestroyed) {
					if (debug) {
						if (debug_DocumentDetailsPresenter) {
							console.log('model details destroyed before being loaded');
						}
					}
					return;
				}
				var data = output.data;
				if (data) {
					if (UWA.is(data, 'array')) {
						data = data[0];
					}
				}
				if (debug_DocumentDetailsPresenter) {
					console.log('data.relateddata.files[index]'
						 + data.relateddata.files.length)
				};
				that._loadData(data);
				that._loadFilesData(data);
				Mask.unmask(that._container);
				// Mask.unmask(this._filesContainer);
			},

			'onFailure': function (data) {
				if (debug_DocumentDetailsPresenter) {
					console.log('getDocuments: Service Call fail !!!');
				}
			},
		};

		DocumentManagement.getDocuments([this._id], options)

	};

	DocumentDetailsPresenter.prototype.destroy = function () {
		this._container = null;
		this._isDestroyed = true;
	};

	DocumentDetailsPresenter.prototype._refreshIdCardModel = function(){
			var that = this;
			var options = {
				getVersions: true,
				'onComplete': function (output) {
					if (that._isDestroyed) {
						return;
					}
					var data = output.data;
					if (data) {
						if (UWA.is(data, 'array')) {
							data = data[0];
						}
					}


					var updatedModel = DocCockpitIdCardAttributeCreator.prepareIdCardData(data, that._privateModelEvents,that._kpiModelEvents);
				// 				//this will trigger model's on change event and will be handled at IDCard side.
			//	that._enoxIDCardContainer._idCardModel.set('_attributes', updatedModel.get('attributes'));
				console.log('getDocuments: Service Call pass !!!');
						that._modelForIdCard.set('attributes', updatedModel.get('attributes'));

				},

				'onFailure': function (data) {
					if (debug_DocumentDetailsPresenter) {
						console.log('getDocuments: Service Call fail !!!');
					}
				},
			};

			DocumentManagement.getDocuments([this._id], options)
	};

	return DocumentDetailsPresenter;
});
