define('DS/CATCXPModel/extensions/CATEVPMOccurrenceMovable',
[
	'UWA/Core',
	'MathematicsES/MathsDef',
	'DS/CATCXPModel/extensions/CATE3DActorMovable'
],

function (
    UWA,
	DSMath,
	CATE3DActorMovable
    ) {
	'use strict';

	var CATEVPMOccurrenceMovable = CATE3DActorMovable.extend(
    {
    	/**  
        * @public
        */
        GetAbsPosition: function (oTransform) {
            var _varposition = this.QueryInterface('CATI3DExperienceObject').GetValueByName('_varposition');

            oTransform.setFromArray(_varposition);

            var cache = this.QueryInterface('CATI3DXAssetHolder').getCache();
            var parentTransfoInAssetContext = new DSMath.Transformation().setFromArray(cache.ParentPositionInAssetContext);
            oTransform.copy(DSMath.Transformation.multiply(parentTransfoInAssetContext, oTransform));

            var parentVisu = this.QueryInterface('CATI3DXVisuHierarchy').GetVisuParent();
            var parentMovable = parentVisu.QueryInterface('CATIMovable');

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
            var parentVisu = this.QueryInterface('CATI3DXVisuHierarchy').GetVisuParent();
            var parentMovable = parentVisu.QueryInterface('CATIMovable');

            if (parentMovable) {
                var parentTransform = new DSMath.Transformation();
                parentMovable.GetAbsPosition(parentTransform);
                var localPosition = DSMath.Transformation.multiply(parentTransform.getInverse(), iTransform);

                var cache = this.QueryInterface('CATI3DXAssetHolder').getCache();
                var parentTransfoInAssetContext = new DSMath.Transformation().setFromArray(cache.ParentPositionInAssetContext);
                localPosition = DSMath.Transformation.multiply(parentTransfoInAssetContext.getInverse(), localPosition);

                this.QueryInterface('CATI3DExperienceObject').SetValueByName('_varposition', localPosition.getArray());
            }
            else {
                this.QueryInterface('CATI3DExperienceObject').SetValueByName('_varposition', iTransform.getArray());
            }
        }
    });


	return CATEVPMOccurrenceMovable;
});

