/* global DS*/
(function () {
	'use strict';
	window.Polymer({
		is: 'xs-wg-3dplay',
		properties: {
			//Physical id of object
			physicalid: {
				notify: true
			},
			//object type
			dtype: {
				notify: true
			},
			//What type of loading behavior - preload ,onclick or autoplay
			loading: {
				notify: true,
				value: 'autoplay'
			},
			//label for this widget
			label: {
				notify: true
			},
           	rawvalue: {
				notify: true
			},
           	value: {
           		notify: true
			}
		},

		observers: [
			'load3DPlayWidget(physicalid, dtype, loading, _isDesignMode)'
		],

		attached: function() {
			this._adp = this.XS();
			this._isDesignMode = this._adp.whichMode() === 'design';
		},
		/**
		 * Loads 3dplay object
		 * @param {String} physicalid Physical object id of Design sight object
		 * @param {String} dtype object type of given object
		 * @param {String} loading What type of loading you want
		 * @param {Boolean} _isDesignMode is component in design mode
		 */
		load3DPlayWidget: function(physicalid, dtype, loading, _isDesignMode) {
			if (!_isDesignMode) {
				this._load3DPlayWidget(this.$.container,
					{
						provider: 'EV6',
						physicalid: physicalid,
						dtype: dtype,
						type: dtype,
						serverurl: this.$.dashboard.getMcsUri(),
						server: this.$.dashboard.getMcsUri(),
						proxyurl:this.$.dashboard.getMcsUri(),
						requireAuth: null,
						tenant: 'OnPremise'
					},
					{
						loading: loading,
						fullscreen: {
							activateOnStart: false,
							mode: 'PLATFORM'
						}
					});
			} else {
				// Removes no data message to no preview in design mode message
				this.$.container.classList.remove('no-data');
				this.$.container.classList.add('no-design');
			}
		},

		maximize: function() {
			this.$.container.classList.add('maximized');
		},

		minimize: function() {
			this.$.container.classList.remove('maximized');
		},

		/**
		 * Loads 3dplay widget in given node
		 * @param {HTMLElement} containerDiv HTMLNode in which 3dplay has to be rendered
		 * @param {any} input input data
		 * @param {any} options options for 3dplay
		 */
		_load3DPlayWidget: function(containerDiv, input, options) {
			//For avoiding adding 3dplay in dependency - using it as text
			//temproray fix - add dependency when this component is exposed
			var PlayerHelperModule = 'DS/3DPlayHelper/3DPlayHelper';
			require([
				'UWA/Core',
				PlayerHelperModule
			], function (UWA, Player3DPlayWeb) {
				this.$.container.classList.remove('no-data');
				if (this._player) {
					this._player.loadAsset(input, options);
				} else {
					this._player = new Player3DPlayWeb({
						container: containerDiv,
						input: input,
						options: options
				   });
				}
			}.bind(this));
		},

		/**
		 * Reloads the 3dplay object with new geometry
		 *
		 */
		refresh: function() {
			this.load3DPlayWidget(this.physicalid, this.dtype, this.autoplay, this._isDesignMode);
		},

		behaviors: [DS.SMAProcXSWidgets.XSWgBase]
	});
}(this));
