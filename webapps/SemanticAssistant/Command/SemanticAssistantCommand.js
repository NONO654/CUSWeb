define('DS/SemanticAssistant/Command/SemanticAssistantCommand',
		['DS/ApplicationFrame/Command',
		 'DS/PADUtils/PADContext',
		 'DS/PADUtils/PADCommandProxy',
		 'DS/TraceableRequirementsUtils/REQCommandProxy',
		 'DS/TraceableRequirementsUtils/Services/RequirementWebServices',
		 'DS/TraceableRequirementsUtils/Utils',
		 'DS/SemanticAssistant/SemanticAssistant_Slide',
		 'DS/SemanticAssistant/Timer'
	], function (AFRCommand,
			PADContext,
			PADCommandProxy,
			REQCommandProxy,
			RequirementWebServices,
			Utils,
			SemanticAssistant,
			Timer) {

		'use strict';

		var that = undefined;
		/**
         * @summary Semantic Assistant Command
         * @description
         * <p>
         * The SemanticAssistantCommand is responsible for creating, opening and closing the SemanticAssistant.
         * It listens to events like changes in the RichView and the RichContentEditors and calls the respective functions
         * of the SemanticAssistant
         * </p>
         *
         * @author TRM Team
         * @licence Copyright 2006-2018 Dassault Systemes company. All rights reserved.
         *
         * @module DS/SemanticAssistant/SemanticAssistantCommand
         */
		var Command = AFRCommand.extend({

			isActivated: undefined,

			_semanticAssistant: undefined,

			timer: undefined,

			intervall: 1000,

			init: function(options) {

				this.disable();

				that = this;

				this._parent(options, {
					isAsynchronous: true,
					repeatMode: true
				});

				this.checkIfEnabled();
//				try {
//					Utils.get3DSpaceUrl();
//					this.checkIfEnabled();
//				} catch {
//					Utils.app_initialization(this.checkIfEnabled);
//				}
			},

			checkIfEnabled: function() {
				console.log('SA: Checking if SA is enabled ...');
				// check if tool was enabled via Admin's Platform Management
				RequirementWebServices.getTRMExpressionValue({
					expression: 'TRM_TRC_Enabled',
					securityContext: Utils.getSecurityContext(),
					method:'GET',
					onComplete: function(response) {
						console.log('TRC enabled?: ' + response);
						var isActivated = jQuery.parseJSON(response).results.value;
						if (UWA.is(isActivated) && isActivated === 'true') {
							that.isActivated = true;
							that._init();
						} else {
							that.disable();
							that.isActivated = false;
							console.log('Semantic Assistant not enabled.');
						}
					},
					onFailure: function(response) {
						that.disable();
						that.isActivated = false;
						console.error('Could not retreive Semantic Assistant activation information. -> Semantic Assistant will be disabled.');
					},
					onTimeout: function(response) {
						that.disable();
						that.isActivated = false;
						console.error('Could not retreive Semantic Assistant activation information. -> Semantic Assistant will be disabled.');
					},
					onCancel: function(response) {
						that.disable();
						that.isActivated = false;
						console.error('Could not retreive Semantic Assistant activation information. -> Semantic Assistant will be disabled.');
					}
				});
			},

			_init: function() {
				this._semanticAssistant = new SemanticAssistant({
                	container: '.properties-panel',
                	commandButton: this
                });

				// Timer to fire quality check x ms after typing stop
				this.timer = new Timer(this.intervall, this.checkQuality, 'timer');

				this.addRichViewListeners();

				this._check_select();
			},
			/**
             * @description
             * <p>This method opens the SemanticAssistant when icon in ActionBar is clicked</p>
             */
			beginExecute: function() {

				if(this._semanticAssistant !== undefined) {
					this._semanticAssistant.toggleOpenClose();
				}
			},
			/**
             * @description
             * <p>Method closes the SemanticAssistant panel</p>
             */
			cancelExecute: function() {

				if(this._semanticAssistant !== undefined) {
					this._semanticAssistant.toggleOpenClose();
				}
			},
			/**
             * @description
             * <p>
             * Method registers listeners to RichView/widget refresh events, Requirement selections and deselections as well as changes
             * discharged by RichContentEditors
             *  </p>
             */
			addRichViewListeners: function() {

				// listen for change events on padcontext to enable and disable command button
				if (PADContext.get()) {
					this._check_select();
	        		PADContext.get().getPADTreeDocument().getXSO().onChange(this._check_select.bind(this));
	        	}

				// listen for requirement selections
				REQCommandProxy.create({
					events: {
						onReqSelect: function(event, data){
							that.checkQuality('');
						},
						// open SemanticAssistant panel if it had been opened before a widget refresh
						onRefreshRV: function(event){
							that._semanticAssistant.clearRichViewContent();
							that._semanticAssistant.container = jQuery(that._semanticAssistant.panelSelector);
							if(PADContext.get().options.isSemanticQualityPanelOpen === true) {
								that._semanticAssistant.open();
							}
						},
						// call the resize method of the SemanticAssistant on RichView/widget resize events
						onResizeRV: function(event){
							if(PADContext.get().options.isSemanticQualityPanelOpen === true && that._semanticAssistant.isOpen === true) {
								that._semanticAssistant.resize();
							}
						},
						// update timer on change events discharged by any RichContentEditor object
						onContentChanged: function(event) {
							if(PADContext.get().options.isSemanticQualityPanelOpen === true && that._semanticAssistant.isOpen === true && that._semanticAssistant.checkSelection()) {
								// only check semantic quality if time elapsed since last change is bigger than minimum time
								that.timer.check();
							}
						}
					}
				});
			},

			setIntervall: function(newIntervall) {
				if(UWA.is(newIntervall, 'number') && newIntervall > 0 && UWA.is(this.timer)) {
					this.intervall = newIntervall;
					this.timer.setIntervall(newIntervall);
				}
			},
			/**
             * @description
             * <p>Method enables and disables the SemanticAssitant button in the ActionBar</p>
             */
			_check_select: function() {

				const has_selected = PADContext.get().getPADTreeDocument().getXSO().get().length ? true : false;

				if(UWA.is(this._semanticAssistant) && !this._semanticAssistant.isOpen) {

					if (has_selected === true && PADContext.get().getSelectedNodes()[0].options.kindof === 'Requirement') {
						// Requirement is selected -> enable button
						this.enable();
		            } else {
		            	// No Requirement is selected -> disable button
	            		this.disable();
		            }

				}  else if (UWA.is(this._semanticAssistant) && this._semanticAssistant.isOpen && has_selected === false) {
					// process deselection of Requirement
					this._semanticAssistant.showFalseSelection(this._semanticAssistant.getSelectedType());
				}
			},

			/**
             * @description
             * <p>
             * Method calls SemanticAssistant quality check while saving the current cursor position if called by the timer,
             * otherwise without saving a cursor position
             * </p>
             */
			checkQuality: function(calledBy) {
				if (calledBy === 'timer') {
					that._semanticAssistant.selReqHasBeenChanged = true;
					that._semanticAssistant.process(true);
				} else {
					that._semanticAssistant.process(false);
				}

			},

		});

		return Command;
	});
