define('DS/ENOXSplittedView/js/ENOXSplittedView',
	[
		'UWA/Class/View',
		'css!DS/ENOXSplittedView/css/ENOXSplittedView.css',
		'css!DS/UIKIT/UIKIT'
	],
	function (View) {
	"use strict";
	var ContainerView = View.extend({

			init : function (options) {
				options = options ? options : {};

				this.id = options.id;
				this.title = options.title;
				this.view = options.view;
				this.allowFullScreen = options.allowFullScreen;

				this._parent();
			},

			render : function () {
				var containerView = UWA.createElement('div', {
						'class' : 'containerView',
						styles : {
							height : '100%',
							width : '100%'
						}
					});

				if (this.allowFullScreen == true || this.title) {
					var fullscreenPanel = UWA.createElement('div', {
							text : this.title,
							'class' : 'fullscreenPanel'
						});
					var contentView = UWA.createElement('div', {
							'class' : 'contentView',
							html : this.view,
							styles : {
								height : '100%',
								width : '100%'
							}
						}).inject(containerView);
					fullscreenPanel.inject(containerView, 'top');
				} else {
					containerView.setContent(this.view);
				}

				if (this.allowFullScreen == true) {
					var smallscreenIcon = UWA.createElement('div', {
							'class' : 'fonticon fonticon-resize-small',
							styles : {
								float : 'right',
								opacity : '0.3',
								cursor : 'pointer'
							},
							events : {
								click : function (e) {
									containerView.removeClassName('fullscreen');
									smallscreenIcon.hide();
									fullscreenIcon.show();
								}
							}
						}).inject(fullscreenPanel).hide();

					var fullscreenIcon = UWA.createElement('div', {
							'class' : 'fonticon fonticon-resize-full',
							styles : {
								float : 'right',
								opacity : '0.3',
								cursor : 'pointer'
							},
							events : {
								click : function (e) {
									containerView.addClassName('fullscreen');
									fullscreenIcon.hide();
									smallscreenIcon.show();
								}
							}
						}).inject(fullscreenPanel);
				}
				this.container.setContent(containerView);
				this.container.setStyles({
					height : '100%',
					width : '100%'
				});
				return this;
			}
		});
	var ResizableSplittedView = View.extend({

			init : function (viewOptions) {
				var options = {};
				if (viewOptions) {
					options = UWA.clone(viewOptions, false);
				}

				var defaults = {
					view1 : {
						id : 'viewId1',
						title : '',
						view : '',
						defaultSize : '50', // Value apply to flex out of 100%
						allowFullScreen : false // or true (default: false) for allowing fullscreen funcationality to view
					},
					view2 : {
						id : 'viewId2',
						title : '',
						view : '',
						defaultSize : '50', // Value apply to flex out of 100%
						allowFullScreen : false // or true (default: false) for allowing fullscreen funcationality to view
					},
					resizable : 'true',
					orientation : 'vertical',
					domEvents : {
						'resize' : function () {
							console.log('Splitter view resize event');
						}
					}
				};

				UWA.merge(options, defaults);
				UWA.merge(options.view1, defaults.view1);
				UWA.merge(options.view2, defaults.view2);

				this.view1 = options.view1;
				this.view2 = options.view2;

				this.resizable = options.resizable;
				this.orientation = options.orientation;

				if (this.orientation == 'vertical') {
					this.cursorType = 'w-resize';
					this.orientation = 'row';
				}
				if (this.orientation == 'horizontal') {
					this.cursorType = 's-resize';
					this.orientation = 'column';
				}
				this.buildContainer(options);
				this._parent();
			},

			buildContainer : function (options) {
				var that = this;
				this.splittedViewContainer = UWA.createElement('div', {
						'class' : 'splittedViewContainer',
						styles : {
							display : 'flex',
							flexDirection : this.orientation,
							height : '100%',
							width : '100%'
						}
					});

				this.firstViewContainer = UWA.createElement('div', {
						'class' : 'firstViewContainer',
						styles : {
							flex : this.view1.defaultSize,
							overflow : 'hidden'
						}
					}).inject(this.splittedViewContainer, 'top').hide();

				this.separator = UWA.createElement('div', {
						'class' : 'saperator',
						styles : {
							minWidth : '5px',
							minHeight : '5px',
							cursor : this.cursorType,
							background : 'grey',
							opacity : '0.3'
						},
						events : {
							click : function (e) {
								that.onResize();
							}
						}
					}).inject(this.splittedViewContainer).hide();

				this.secondViewContainer = UWA.createElement('div', {
						'class' : 'secondViewContainer',
						styles : {
							flex : this.view2.defaultSize,
							overflow : 'hidden'
						}
					}).inject(this.splittedViewContainer, 'bottom').hide();

				if (this.view1.view != '') {
					var initOptions1 = {
						id : this.view1.id,
						title : this.view1.title,
						view : this.view1.view,
						allowFullScreen : this.view1.allowFullScreen
					};
					this.buildContent(initOptions1, 1);
				}

				if (this.view2.view != '') {
					var initOptions2 = {
						id : this.view2.id,
						title : this.view2.title,
						view : this.view2.view,
						allowFullScreen : this.view2.allowFullScreen
					};
					this.buildContent(initOptions2, 2);
				}

			},
			buildContent : function (options, index) {
				var contentView = new ContainerView(options);
				contentView.render();
				if (index == 1) {
					this.firstViewContainer.setContent(contentView);
				}
				if (index == 2) {
					this.secondViewContainer.setContent(contentView);
				}
				this.showView(index);
			},
			render : function () {
				this.container.setContent(this.splittedViewContainer);
				this.container.setStyles({
					height : '100%',
					width : '100%'
				});
				return this;
			},
			hideView : function (index) {
				if (index == 1) {
					this.firstViewContainer.hide();
					this.separator.hide();
				}
				if (index == 2) {
					this.secondViewContainer.hide();
					this.separator.hide();
				}
			},
			showView : function (index) {
				var showSeparator = false;
				if (index == 1) {
					this.firstViewContainer.show();
					showSeparator = this.isHidden(2) ? false: true;
				}
				if (index == 2) {
					this.secondViewContainer.show();
					showSeparator = this.isHidden(1) ? false: true;
				}
				if(showSeparator)
					this.separator.show();
			},
			setView : function (viewOption, index) {
				var defaults = {
					id : 'viewId' + index,
					title : '',
					view : '',
					allowFullScreen : false
				};

				UWA.merge(viewOption, defaults);
				this.buildContent(viewOption, index);
				this.render();
			},
			isHidden : function (index) {
				if (index == 1) {
					return this.firstViewContainer.isHidden();
				}
				if (index == 2) {
					return this.secondViewContainer.isHidden();
				}
			},
			onResize : function () {
				var isResizing = false,
				lastDownX = 0,
				lastDownY = 0;

				if (this.orientation == 'row') {
					var that = this;
					this.separator.addEvent('mousedown', function (e) {
						isResizing = that.resizable;
						lastDownX = e.clientX;
					});

					this.splittedViewContainer.addEvent("mousemove", function (e) {
						if (!isResizing)
							return;

						var mouseX = e.clientX;
						var containerX = that.splittedViewContainer.getOffsets().x;
						var containerWidth = that.splittedViewContainer.getSize().width;

						var sizeX = mouseX - containerX;

						var xPercentage = (sizeX / containerWidth) * 100;

						that.firstViewContainer.setStyle('flex', xPercentage);
						that.secondViewContainer.setStyle('flex', (100 - xPercentage));

						that.firstViewContainer.triggerEvent('resize');
						that.secondViewContainer.triggerEvent('resize');

					});

					this.splittedViewContainer.addEvent("mouseup", function (e) {
						isResizing = false;
					});
				}
				if (this.orientation == 'column') {
					var that = this;
					this.separator.addEvent('mousedown', function (e) {
						isResizing = that.resizable;
						lastDownY = e.clientY;
					});

					this.splittedViewContainer.addEvent("mousemove", function (e) {
						if (!isResizing)
							return;

						var mouseY = e.clientY;
						var containerY = that.splittedViewContainer.getOffsets().y;
						var containerHeight = that.plittedViewContainer.getSize().height;

						var sizeY = mouseY - containerY;

						var yPercentage = (sizeY / containerHeight) * 100;

						that.firstViewContainer.setStyle('flex', yPercentage);
						that.secondViewContainer.setStyle('flex', (100 - yPercentage));

						that.firstViewContainer.triggerEvent('resize');
						that.secondViewContainer.triggerEvent('resize');

					});

					this.splittedViewContainer.addEvent("mouseup", function (e) {
						isResizing = false;
					});
				}
			}
		})

		return ResizableSplittedView;
})
