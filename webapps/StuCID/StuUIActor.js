define('DS/StuCID/StuUIActor', ['DS/StuCore/StuContext',
                                'DS/StuModel/StuActor',
                                'DS/EPEventServices/EPEvent',
                                'DS/StuModel/StuDimension',
                                'DS/StuModel/StuAttachment', 
                                'DS/EP/EP',
                                'MathematicsES/MathsDef',
								'DS/StuPictureResource/StuPictureResource'],
function (STU, Actor, Event, Dimension, Attachment, EP, DSMath)
{
	'use strict';


    /**
    * Describe a STU.UIActor which represents a 2D UI object.
    * This class provides the possibility to interact and manipulate them through different kind of APIs.
    *
    * @exports UIActor
    * @class
    * @constructor
    * @noinstancector
    * @public
    * @extends STU.Actor
    * @memberof STU
    * @alias STU.UIActor
    */
	var UIActor = function () {

        Actor.call(this);

        this.name = 'UIActor';

        this.CATICXPUIActor;

	    /**
         * True if this UI Actor is visible, false otherwise.
         *
         * @member
         * @instance
         * @name visible
         * @public
         * @type {boolean}
         * @memberOf STU.UIActor
         */
        Object.defineProperty(this, "visible", {
        	enumerable: true,
        	configurable: true,
        	get: function () {
        			if (this.CATICXPUIActor !== null && this.CATICXPUIActor !== undefined)
        				{return this.CATICXPUIActor.getVisible();}
        			else
        				{return false;}
        	},
        	set: function (iVisible) {
        		if (iVisible !== true && iVisible !== false) {
        			throw new TypeError('iVisible argument is not a boolean');
        		}

        		if (this.CATICXPUIActor !== null && this.CATICXPUIActor !== undefined)
        			{this.CATICXPUIActor.setVisible(iVisible === true);}
        	}
        });

	    /**
         * True if this UI Actor is enabled, false otherwise.
         *
         * @member
         * @instance
         * @name enable
         * @public
         * @type {boolean}
         * @memberOf STU.UIActor
         */
        Object.defineProperty(this, "enable", {
            enumerable: true,
            configurable: true,
            get: function () {
                if (this.CATICXPUIActor !== null && this.CATICXPUIActor !== undefined)
                    {return this.CATICXPUIActor.getEnable();}
                else
                    {return false;}
            },
            set: function (iEnable) {
                if (iEnable !== true && iEnable !== false) {
                    throw new TypeError('iEnable argument is not a boolean');
                }

                if (this.CATICXPUIActor !== null && this.CATICXPUIActor !== undefined)
                    {this.CATICXPUIActor.setEnable(iEnable === true);}
            }
        });

	    /**
         * Offset of display position relative to the attachment of this UI Actor.
         *
         * @member
         * @instance
         * @name offset
         * @public
         * @type {DSMath.Vector2D}
         * @memberOf STU.UIActor
         */
        if (STU.isEKIntegrationActive()) {
        	this.__offset = new DSMath.Vector2D();
        }
        Object.defineProperty(this, "offset", {
            enumerable: true,
            configurable: true,
            get: function () {
            	if (!STU.isEKIntegrationActive()) {
            		if (this.CATICXPUIActor !== null && this.CATICXPUIActor !== undefined) {
            			var offset = new DSMath.Vector2D();
            			var xy = this.CATICXPUIActor.getOffset();
            			offset.set(xy[0], xy[1]);
            			return offset;
            		}
            		else
            			{return undefined;}
            	}
            	else {
            		return this.__offset;
            	}
            },
            set: function (iOffset) {
                if (iOffset !== null && iOffset !== undefined && !(iOffset instanceof DSMath.Vector2D)) {
                    throw new TypeError('iOffset argument is not a DSMath.Vector2D');
                }

                if (this.CATICXPUIActor !== null && this.CATICXPUIActor !== undefined)
                	{this.CATICXPUIActor.setOffset(iOffset.x, iOffset.y);}

                if (STU.isEKIntegrationActive()) {
                	this.__offset = iOffset;
                }
            }
        });

	    /**
         * Minimum dimension of displayed UI Actor.
         * It will not take into account the margin due to display mode.
         *
         * @member
         * @instance
         * @name minimumDimension
         * @public
         * @type {STU.Dimension}
         * @memberOf STU.UIActor
         */
        if (STU.isEKIntegrationActive()) {
        	this.__minimumDimension = new Dimension();
        }

        Object.defineProperty(this, "minimumDimension", {
        	enumerable: true,
        	configurable: true,
        	get: function () {
        		if (!STU.isEKIntegrationActive()) {
        			if (this.CATICXPUIActor !== null && this.CATICXPUIActor !== undefined) {
        				var whm = this.CATICXPUIActor.getMinimumDimension();
        				var minDim = new Dimension(whm[0], whm[1], whm[2]);
        				return minDim;
        			}
        			return undefined;
        		}
        		else {
        			return this.__minimumDimension;
        		}
        	},
        	set: function (iMinimumDimension) {
        		if (iMinimumDimension !== null && iMinimumDimension !== undefined && !(iMinimumDimension instanceof STU.Dimension)) {
        			throw new TypeError('iMinimumDimension argument is not a STU.Dimension');
        		}

        		if (this.CATICXPUIActor !== null && this.CATICXPUIActor !== undefined)
        			{this.CATICXPUIActor.setMinimumDimension(iMinimumDimension.width, iMinimumDimension.height, iMinimumDimension.mode);}

        		if (STU.isEKIntegrationActive()) {
        			this.__minimumDimension = iMinimumDimension;
        		}
        	}
        });

	    /**
         * Opacity of this UI Actor.
         *  Opacity is expressed in % so it's value is limited between 0 and 1.
         *
         * @member
         * @instance
         * @name opacity
         * @public
         * @type {Number}
         * @memberOf STU.UIActor
         */
        Object.defineProperty(this, "opacity", {
            enumerable: true,
            configurable: true,
            get: function () {
                if (this.CATICXPUIActor !== null && this.CATICXPUIActor !== undefined) {
                    return this.CATICXPUIActor.getOpacity();
                }
                else
                    {return undefined;}
            },
            set: function (iOpacity) {
                if (iOpacity !== null && iOpacity !== undefined && typeof iOpacity !== "number") {
                    throw new TypeError('iOpacity argument is not a number');
                }

                if (this.CATICXPUIActor !== null && this.CATICXPUIActor !== undefined){
                    if(iOpacity <= 255){
                        if(iOpacity > 1){
                            iOpacity = iOpacity / 255;
                        }
                        this.CATICXPUIActor.setOpacity(iOpacity);
                    }
                    else{
                        console.error("iOpacity must be between 0 and 1");
                    }
                }
            }
        });

	    /**
         * Attachment of displayed UI Actor.
         *
         * @member
         * @instance
         * @name attachment
         * @public
         * @type {STU.Attachment}
         * @memberOf STU.UIActor
         * @see STU.Attachment
         */
        this.__attachment = new Attachment();
        Object.defineProperty(this, "attachment", {
            enumerable: true,
            configurable: true,
            get: function () {
                return this.__attachment;
            },
            set: function (iAttachment) {
                if (iAttachment !== null && iAttachment !== undefined && !(iAttachment instanceof STU.Attachment)) {
                    throw new TypeError('iAttachment argument is not a STU.Attachment');
                }

                if (this.CATICXPUIActor !== null && this.CATICXPUIActor !== undefined)
                {
                    var target = null;
                    if (iAttachment.target !== null && iAttachment.target !== undefined)
                        {target = iAttachment.target.CATI3DExperienceObject;}

                    this.CATICXPUIActor.setAttachment(iAttachment.side, target);

                    this.__attachment = iAttachment;
                }
            }
        });

	};

	UIActor.prototype = new Actor();
	UIActor.prototype.constructor = UIActor;
	UIActor.prototype.featureCatalog = 'CXPUIActor_Spec.feat';
	UIActor.prototype.featureStartup = 'CXPUIActor_Spec';



    UIActor.prototype.doUIDispatchEvent = function (iEventName, iIndex) {
        var event = new STU[iEventName + "Event"]();
        event.sender = this;
        event.index = iIndex;
        this.dispatchEvent(event);
    };

    UIActor.prototype.doUIDispatchEventInt = function (iEventName, iIndex, iIntParam) {
        var event = new STU[iEventName + "Event"]();
        event.sender = this;
        event.index = iIndex;
        event.paramInt = iIntParam;
        this.dispatchEvent(event);
    };


	UIActor.prototype.onInitialize = function () {
		Actor.prototype.onInitialize.call(this);
		this._UI = this.getUIBinder();
		this.ctl = this.getCtl();

		if (!STU.isEKIntegrationActive()) {
			this.CATICXPUIActor.setESObject(this);
		}
		else {
			if (this.CATICXPUIActor !== null && this.CATICXPUIActor !== undefined) {
				this.CATICXPUIActor.setESObject(this);
			}
		}

		//  Register Events
        var i;
        if (this._events !== undefined && this._events !== null) {
    		for (i = 0; i < this._events.length; i++) {
    			if (EP.EventServices.getEventByType(this._events[i].name + "Event") === undefined) {
    				var myEvent = function (iObj) { Event.call(this); };
    				myEvent.prototype = new Event();
    				myEvent.prototype.constructor = myEvent;
    				myEvent.prototype.type = this._events[i].name + "Event";
    				STU[this._events[i].name + "Event"] = myEvent;
    				EP.EventServices.registerEvent(myEvent);
    			}
    		}
        }
        // Keep old-way declared events
        // -------------------------------------------------------------------------------
        // UIActor migrated on XML capacities declaration
        // but old data still get their event in "events" string variable
        for (i = 0; i < this.events.length; i++) {
            if (EP.EventServices.getEventByType(this.events[i] + "Event") === undefined) {
                var myEvent = function (iObj) { Event.call(this); };
                myEvent.prototype = new Event();
                myEvent.prototype.constructor = myEvent;
                myEvent.prototype.type = this.events[i] + "Event";
                STU[this.events[i] + "Event"] = myEvent;
                EP.EventServices.registerEvent(myEvent);
            }
        }
        // -------------------------------------------------------------------------------
		// Instantiate View (Ctl will be projected)
		if (!STU.isEKIntegrationActive()) {
			this.CATICXPUIActor.instantiateView();


			// Retrieve Data from View
			this._UI.fillProperties(this.ctl.Data);

			// Parse recusivly properties to "connect" correctly VID properties and Experience properties
			this.__parseProperties(this, this.data, this.ctl.Data);
		}
		else {
			if (this.CATICXPUIActor !== null && this.CATICXPUIActor !== undefined) {
				this.CATICXPUIActor.instantiateView();
				// Retrieve Data from View
				this._UI.fillProperties(this.ctl.Data);
				//Win -> Parse recusivly properties to "connect" correctly VID properties and Experience properties
				//Web -> Project data variables under UIActor
				this.__parseProperties(this, this.data, this.ctl.Data);
			}
		}
	};

	UIActor.prototype.onDeactivate = function () {
	    //this.ctl.RequestDelayedDestruction();
	    //this.ctl = null;
	    Actor.prototype.onDeactivate.call(this);
	};


    /**
     * Is Visible this STU.UIActor.
     *
     * @method
     * @private
     * @see STU.UIActor#visible
     */
	UIActor.prototype.isVisible = function () {
	    return this.visible;
	};

    /**
     * Hide this STU.UIActor.
     *
     * @method
     * @private
     * @see STU.UIActor#visible
     */
	UIActor.prototype.hide = function () {
	    this.visible = false;
	};
	
    /**
     * Show this STU.UIActor.
     *
     * @method
     * @private
     * @see STU.UIActor#visible
     */
	UIActor.prototype.show = function () {
	    this.visible = true;
	};

    /**
     * Disables this STU.UIActor.
     *
     * @method
     * @private
     * @see STU.UIActor#enable
     */
	UIActor.prototype.disables = function () {
	    this.enable = false;
	};

    /**
     * Enables this STU.UIActor.
     *
     * @method
     * @private
     * @see STU.UIActor#enable
     */
	UIActor.prototype.enables = function () {
	    this.enable = true;
	};

    /**
     * Is Enabled this STU.UIActor.
     *
     * @method
     * @private
     * @see STU.UIActor#enable
     */
	UIActor.prototype.isEnabled = function () {
	    return this.enable;
	};

	// Expose in STU namespace.
	STU.UIActor = UIActor;

	return UIActor;
});

define('StuCID/StuUIActor', ['DS/StuCID/StuUIActor'], function (UIActor) {
    'use strict';

    return UIActor;
});
