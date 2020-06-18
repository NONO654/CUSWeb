/**
 * CATE3DXUIActorUIRep
*  @category Extension
 * @name DS/CATCXPModel/extensions/CATE3DXUIActorUIRep
 * @description Implements {@link DS/CAT3DExpModel/interfaces/CATI3DXUIRep CATI3DXUIRep}
 * @constructor
 */

define('DS/CATCXPModel/extensions/CATE3DXUIActorUIRep',
[
	'UWA/Core',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
	'UWA/Class/Listener',
	'DS/Core/Events',
	'DS/CATCXPCIDModel/CXPUIRepFactory',
	'DS/CAT3DExpModel/interfaces/CATI3DXUIRep',
	'DS/Visualization/ThreeJS_DS',
	'DS/CAT3DExpModel/CAT3DXModel'
],
function (
	UWA,
	CAT3DXInterfaceImpl,
	Listener,
	WUXEvent,
	RepFactory,
	CATI3DXUIRep,
	THREE,
	CAT3DXModel
	) {
	'use strict';

	var CATE3DXUIActorUIRep = CAT3DXInterfaceImpl.extend(Listener,
	/** @lends DS/CATCXPModel/extensions/CATE3DXUIActorUIRep.prototype **/
	{
		init: function () {
			this._parent();
			this._UIActorRep = null;
			this.frameUIChanges = [];
		},

		destroy: function () {
			this._parent();
			this.stopListening();			
			this._UIActorRep.destroy();
			this._UIActorRep = null;
			this.frameUIChanges = [];
		},

		// --- Interface CATE3DXUIActorUIRep
		_Create: function () {
			var self = this;
			var expObject = this.QueryInterface('CATI3DExperienceObject');

			var data = expObject.GetValueByName('data');
			if (data) {
			    var dataExpObject = data.QueryInterface('CATI3DExperienceObject');

				var uiRep = this.GetObject()._experienceBase.getManager('CAT3DXUIManager').getFactory().createRep(dataExpObject.GetValueByName('__configurationName__'), expObject);

				this.listenTo(expObject, 'offset.CHANGED', function () {
					self.frameUIChanges.push(self._refreshOffset);
					self.RequestUIRefresh();
				});
				this.listenTo(expObject, 'attachment.CHANGED', function () {
					self.frameUIChanges.push(self._refreshAttachment);
					self.RequestUIRefresh();
				});

				this.frameUIChanges.push(self._refreshAttachment);
				this.frameUIChanges.push(self._refreshOffset);
				this.RequestUIRefresh();

				return uiRep;
			} else {
			    return this.GetObject()._experienceBase.getManager('CAT3DXUIManager').getFactory().createRep('undefined', expObject);
			}
		},

		Refresh: function () {
			for (var i = 0; i < this.frameUIChanges.length; ++i) {
				this.frameUIChanges[i].call(this);
			}
			this.frameUIChanges.length = 0;
		},

		RequestUIRefresh: function () {
			// notify VisuManager
			var iUIRep = this.QueryInterface('CATI3DXUIRep');
			if (UWA.is(iUIRep)) {
				WUXEvent.publish({
					event: 'STU_UI_CHANGED',
					data: {
						CATI3DXUIRep: iUIRep
					}
				});
			}
		},

		_refreshAttachment: function () {
		    var expObject = this.QueryInterface('CATI3DExperienceObject');

			var attachment = expObject.GetValueByName('attachment');
			var attachmentEO = attachment.QueryInterface('CATI3DExperienceObject');
			var side = attachmentEO.GetValueByName('side');

			if (side === CATI3DXUIRep.Attachment.ESide.e3DActor) {
				this._UIActorRep.attachTo3D(attachmentEO.GetValueByName('target'));
			}
			else {
				if (this._UIActorRep.isAttachTo3D()) {
					this._UIActorRep.detachFrom3D();
				}
			}
		},

		_refreshOffset: function () {
		    var expObject = this.QueryInterface('CATI3DExperienceObject');

			var attachment = expObject.GetValueByName('attachment');
			var attachmentEO = attachment.QueryInterface('CATI3DExperienceObject');
			var side = attachmentEO.GetValueByName('side');

			var dimension = this.QueryInterface('CATICXPUIActor').GetDimension();
			var width = dimension.width;
			var height = dimension.height;

			//Fix wait div rendered to get Dimension
			var minDimension = this.QueryInterface('CATICXPUIActor').GetMinimumDimension();

			if (side !== CATI3DXUIRep.Attachment.ESide.eTopLeft && width === 0 && height === 0 && expObject.GetValueByName('visible') && (minDimension.width !== 0 || minDimension.height !== 0)) {
				var self = this;
				setTimeout(function () {
					self.frameUIChanges.push(self._refreshOffset);
					self.RequestUIRefresh();
				}, 200);
				return;
			}

			var offset = expObject.GetValueByName('offset');
			var offsetEO = offset.QueryInterface('CATI3DExperienceObject');
			var offsetX = offsetEO.GetValueByName('x');
			var offsetY = offsetEO.GetValueByName('y');

			var left, top;

			switch (side) {
			    case CATI3DXUIRep.Attachment.ESide.eTopLeft:
					left = offsetX + 'px';
					top = offsetY + 'px';
					break;
			    case CATI3DXUIRep.Attachment.ESide.eTop:
					left = 'calc(50% + ' + (offsetX - width / 2) + 'px)';
					top = offsetY + 'px';
					break;
			    case CATI3DXUIRep.Attachment.ESide.eTopRight:
					left = 'calc(100% + ' + (offsetX - width) + 'px)';
					top = offsetY + 'px';
					break;
			    case CATI3DXUIRep.Attachment.ESide.eLeft:
					left = offsetX + 'px';
					top = 'calc(50% + ' + (offsetY - height / 2) + 'px)';
					break;
			    case CATI3DXUIRep.Attachment.ESide.eCenter:
					left = 'calc(50% + ' + (offsetX - width / 2) + 'px)';
					top = 'calc(50% + ' + (offsetY - height / 2) + 'px)';
					break;
			    case CATI3DXUIRep.Attachment.ESide.eRight:
					left = 'calc(100% + ' + (offsetX - width) + 'px)';
					top = 'calc(50% + ' + (offsetY - height / 2) + 'px)';
					break;
			    case CATI3DXUIRep.Attachment.ESide.eBottomLeft:
					left = offsetX + 'px';
					top = 'calc(100% + ' + (offsetY - height) + 'px)';
					break;
			    case CATI3DXUIRep.Attachment.ESide.eBottom:
					left = 'calc(50% + ' + (offsetX - width / 2) + 'px)';
					top = 'calc(100% + ' + (offsetY - height) + 'px)';
					break;
			    case CATI3DXUIRep.Attachment.ESide.eBottomRight:
					left = 'calc(100% + ' + (offsetX - width) + 'px)';
					top = 'calc(100% + ' + (offsetY - height) + 'px)';
					break;
			    case CATI3DXUIRep.Attachment.ESide.e3DActor:
					var node2D = this.QueryInterface('CATI3DXUIRep').Get().get2DNode();
					node2D.setOffset(new THREE.Vector2(offsetX, offsetY));
					this.GetObject()._experienceBase.webApplication.viewer.render();
					return;
			}
			this._UIActorRep.left = left;
			this._UIActorRep.top = top;
		},

		Show: function () {
			this.Get().show();
		},

		Hide: function () {
			this.Get().hide();
		},


		/**  
		* @public
		*/
		Get: function () {
			if (this._UIActorRep === null) {
				this._UIActorRep = this._Create();
			}
			return this._UIActorRep;
		}

	});
	return CATE3DXUIActorUIRep;
});
