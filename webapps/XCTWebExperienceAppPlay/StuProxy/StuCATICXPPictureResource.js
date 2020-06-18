define('DS/XCTWebExperienceAppPlay/StuProxy/StuCATICXPPictureResource',
[
	'UWA/Core',
    'DS/XCTWebExperienceAppPlay/StuProxy/StuProxy'
],

function (
    UWA,
    StuProxy
    ) {
    'use strict';


    var StuCATICXPPictureResource = StuProxy.extend(
    {
        init: function (iModelObject, iStuObject) {
            this._parent(iModelObject, iStuObject);

            this._sizeInPixel = null;
            var self = this;
            //StuProxy async load?
            iModelObject.QueryInterface('CATICXPPictureResource').GetPictureSizeInPixel().done(function (iSize) {
                self._sizeInPixel = iSize;
            });
        },

        GetSizeInPixel: function () {
            return this._sizeInPixel;
        },

        GetPixelImage:function(){
            console.log('not implemented');
            //TODO
        }

    });

    return StuCATICXPPictureResource;
});

