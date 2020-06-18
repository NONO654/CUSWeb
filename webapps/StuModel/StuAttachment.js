define('DS/StuModel/StuAttachment', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
	'use strict';


    /**
     * Describe an Object representing an UI attachment.
     * It is defined by a side: 0 to 8 for 2D screen positioning and 9 for 3D actor positioning.
     * In the specific case of a 3D attachment a target should also be specified.
     *
     * @exports Attachment
     * @class
     * @constructor
     * @public
     * @extends STU.Instance
     * @memberOf STU
	 * @alias STU.Attachment
     * 
     * @param {STU.Attachment.ESide} [iSide=4] side value
     * @param {STU.Actor3D} [iTarget=null] 3D Actor target (in case of a 3D attachment)
     * @param {Boolean} [iShowAttachment=false] do show the attachment link
     */
	var Attachment = function (iSide, iTarget, iShowAttachment) {
	    Instance.call(this);
	    this.name = 'Attachment';


	    /**
	     * Side of the current attachment.
	     *
	     * @member
	     * @public
	     * @type {STU.Attachment.ESide}
	     */
	    this.side = iSide || 4;

	    /**
	     * Target of the 3D attachment.
         * It supposed that side is e3DActor.
	     *
	     * @member
	     * @public
	     * @type {STU.Actor3D}
	     */
	    this.target = iTarget || null;

	    /**
	     * Show the 3D attachment.
	     *
	     * @member
	     * @public
	     * @type {Boolean}
	     */
	    this.showAttachment = iShowAttachment || false;

	};


	/**
	* An enumeration of sides.<br/>
    * It allows to refer in the code to a specific side of the screen or as 3D attachment.
    *
    * @enum {number}
	* @public
    */
	Attachment.ESide = {
	    eTopLeft: 0,
	    eTop: 1,
	    eTopRight: 2,
	    eLeft: 3,
	    eCenter: 4,
	    eRight: 5,
	    eBottomLeft: 6,
	    eBottom: 7,
	    eBottomRight: 8,
        e3DActor: 9
    };

	Attachment.prototype = new Instance();
	Attachment.prototype.constructor = Attachment;
	Attachment.prototype.featureCatalog = 'CXPBasicTypesCatalog.feat';
	Attachment.prototype.featureStartup = 'Attachment_Spec';


	// Expose in STU namespace.
	STU.Attachment = Attachment;

	return Attachment;
});

define('StuModel/StuAttachment', ['DS/StuModel/StuAttachment'], function (Attachment) {
    'use strict';

    return Attachment;
});
