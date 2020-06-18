define('DS/CATCXPModel/extensions/CATE3DActorMovable',
[
	'UWA/Core',
	'MathematicsES/MathsDef',
	'DS/CAT3DExpModel/CAT3DXInterfaceImpl',
    'UWA/Class/Events',
    'UWA/Class/Listener',
],

function (
    UWA,
	DSMath,
	CAT3DXInterfaceImpl,
    Events,
    Listener
    ) {
	'use strict';

	var CATE3DActorMovable = UWA.Class.extend(CAT3DXInterfaceImpl, Events, Listener,
    {

    	destroy: function () {
    	    this._parent();
    	    this.stopListening();
    	},

    	Build: function () {
    		var self = this;
    		this.listenTo(this.QueryInterface('CATI3DExperienceObject'), '_varposition.CHANGED', function (itransform) {
    			self.dispatchEvent('TRANSFORM_CHANGED', [itransform]);
    		});
    	},

    	/**  
        * @public
        */
    	GetLocalPosition: function (oTransform) {
    	    if (!(oTransform instanceof DSMath.Transformation)) {
    	        throw new TypeError('iTransform argument is not a DSMath.Transformation');
    	    }
    	    //Chek transform validity cf StuActor3D
    	    var _varposition = this.QueryInterface('CATI3DExperienceObject').GetValueByName('_varposition');
    	    oTransform.setFromArray(_varposition);
    	},

    	/**  
        * @public
        */
    	SetLocalPosition: function (iMovable, iTransform) {
    	    // TODO : use iMovable
    	    if (!(iTransform instanceof DSMath.Transformation)) {
    	        throw new TypeError('iTransform argument is not a DSMath.Transformation');
    	    }
    	    //Chek transform validity cf StuActor3D
    	    this.QueryInterface('CATI3DExperienceObject').SetValueByName('_varposition', iTransform.getArray());
    	},

    	/**  
        * @public
        */
    	GetAbsPosition: function (oTransform) {
    	    var _varposition = this.QueryInterface('CATI3DExperienceObject').GetValueByName('_varposition');
    	    oTransform.setFromArray(_varposition);

    	    var parentExpObj, parentMovable;
    	    var parentExpObj = this.QueryInterface('CATICXPObject').GetFatherObject();
    	    if (parentExpObj) {
    	        parentMovable = parentExpObj.QueryInterface('CATIMovable');
    	    }

    	    if (parentMovable) {
    	        var parentTransform = new DSMath.Transformation();
    	        parentMovable.GetAbsPosition(parentTransform);
    	        oTransform.setFromArray(DSMath.Transformation.multiply(parentTransform, oTransform).getArray());
    	    }
    	},

    	/**  
		* @public
		*/
    	SetAbsPosition: function (iTransform) {
    	    var parentExpObj, parentMovable;
    	    parentExpObj = this.QueryInterface('CATICXPObject').GetFatherObject();
    	    if (parentExpObj) {
    	        parentMovable = parentExpObj.QueryInterface('CATIMovable');
    	    }

    	    if (parentMovable) {
    	        var parentTransform = new DSMath.Transformation();
    	        parentMovable.GetAbsPosition(parentTransform);
    	        var localPosition = DSMath.Transformation.multiply(parentTransform.getInverse(), iTransform);
    	        this.QueryInterface('CATI3DExperienceObject').SetValueByName('_varposition', localPosition.getArray());
    	    }
    	    else {
    	        this.QueryInterface('CATI3DExperienceObject').SetValueByName('_varposition', iTransform.getArray());
    	    }

    	},
    });

	return CATE3DActorMovable;
});

