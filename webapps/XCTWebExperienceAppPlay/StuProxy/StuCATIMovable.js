define('DS/XCTWebExperienceAppPlay/StuProxy/StuCATIMovable',
[
	'UWA/Core',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuProxy',
    'MathematicsES/MathsDef',
],

function (
    UWA,
    StuProxy,
    DSMath
    ) {
    'use strict';

    var _ArrayBuffer = null;

    var StuCATIMovable = StuProxy.extend(
    {

        init: function (iModelObject, iStuObject) {
            this._parent(iModelObject, iStuObject);
            this._modelCATIMovable = iModelObject.QueryInterface('CATIMovable');
            Object.defineProperty(this, '_ArrayBuffer', {
                enumerable: true,
                configurable: true,
                get: function () {
                    return _ArrayBuffer;
                },
                set: function (iValue) {
                    _ArrayBuffer = iValue;
                }
            });
        },

        /**  
        * @public
        */
        GetLocalPosition: function () {
            var transform = new DSMath.Transformation();
            this._modelCATIMovable.GetLocalPosition(transform);
            this._transformToArrayBuffer(transform);
        },

        /**  
        * @public
        */
        SetLocalPosition: function () {
            //TODO implement movable
            var transform = this._arrayBufferToTransform();
            this._modelCATIMovable.SetLocalPosition(null/*iMovable*/, transform);
        },

        /**  
        * @public
        */
        GetAbsPosition: function () {
            var transform = new DSMath.Transformation();
            this._modelCATIMovable.GetAbsPosition(transform);
            this._transformToArrayBuffer(transform);
        },

        /**  
		* @public
		*/
        SetAbsPosition: function () {
            var transform = this._arrayBufferToTransform();
            this._modelCATIMovable.SetAbsPosition(transform);
        },

        /**  
        * @public
        */
        ExternalizeArray: function (iArrayBuffer) {
            this._ArrayBuffer = iArrayBuffer;
        },

        /**  
        * @public
        */
        CleanArray: function () {
            this._ArrayBuffer = null;
        },

        _transformToArrayBuffer: function (iTransform) {
            var array = iTransform.getArray();
            this._ArrayBuffer[0] = array[0]; this._ArrayBuffer[1] = array[1]; this._ArrayBuffer[2] = array[2];
            this._ArrayBuffer[3] = array[3]; this._ArrayBuffer[4] = array[4]; this._ArrayBuffer[5] = array[5];
            this._ArrayBuffer[6] = array[6]; this._ArrayBuffer[7] = array[7]; this._ArrayBuffer[8] = array[8];
            this._ArrayBuffer[9] = array[9]; this._ArrayBuffer[10] = array[10]; this._ArrayBuffer[11] = array[11];
        },

        _arrayBufferToTransform: function () {
            var transform = new DSMath.Transformation();
            transform.setFromArray(Array.prototype.slice.call(this._ArrayBuffer));
            return transform;
        }

    });

    return StuCATIMovable;
});

