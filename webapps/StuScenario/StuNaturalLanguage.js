define('DS/StuScenario/StuNaturalLanguage', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior'], function (STU, Behavior) {
    'use strict';

    /*****************************************************************************
    Instance dedicated to act definition.

    @constructor
    *****************************************************************************/

    /**
    * Describe a natural language behavior.
    *
    * @exports NaturalLanguage
    * @class 
    * @constructor
    * @private
    * @extends STU.Behavior
    * @memberof STU
    */
    var NaturalLanguage = function (iRenderable) {
        Behavior.call(this);
        this.name = "NaturalLanguage";

        /*
        * This is the collection of paragraphs contained within the act.
        *
        * @property paragraphs
        * @private
        * @type {Object}
        * @default empty array
        */
        this.paragraphs = [];
    };

    //////////////////////////////////////////////////////////////////////////////
    //                           Prototype definitions                          //
    //////////////////////////////////////////////////////////////////////////////
    NaturalLanguage.prototype = new Behavior();
    NaturalLanguage.prototype.constructor = NaturalLanguage;

    //////////////////////////////////////////////////////////////////////////////
    //                            Methods definitions.                          //
    //////////////////////////////////////////////////////////////////////////////

    /**
     * Process executed when STU.NaturalLanguage is initializing.
     *
     * @method
     * @private
     */
    NaturalLanguage.prototype.onInitialize = function () {
        STU.Behavior.prototype.onInitialize.call(this);

        for (var i = 0; i < this.paragraphs.length; i++) {
            this.paragraphs[i].onInitialize();
        }
    };

    /**
     * Process executed when STU.NaturalLanguage is disposing.
     *
     * @method
     * @private
     */
    NaturalLanguage.prototype.onDispose = function () {
        // for (var i = 0; i < this.paragraphs.length; i++) {
        //     this.paragraphs[i].dispose();
        // }

        STU.Behavior.prototype.onDispose.call(this);
    };

    /**
     * Process executed when STU.NaturalLanguage is activating.
     *
     * @method
     * @private
     */
    NaturalLanguage.prototype.onActivate = function () {
        Behavior.prototype.onActivate.call(this);

        for (var i = 0; i < this.paragraphs.length; i++) {
            //if (this.paragraphs[i].activation == true)
                this.paragraphs[i].activate();
        }
    };

    /**
     * Process executed when STU.NaturalLanguage is deactivating.
     *
     * @method
     * @private
     */
    NaturalLanguage.prototype.onDeactivate = function () {
        for (var i = 0; i < this.paragraphs.length; i++) {
            this.paragraphs[i].deactivate();
        }

        Behavior.prototype.onDeactivate.call(this);
    };

    // Expose only those entities in STU namespace.
    STU.NaturalLanguage = NaturalLanguage;

    return NaturalLanguage;

});

define('StuScenario/StuNaturalLanguage', ['DS/StuScenario/StuNaturalLanguage'], function (NaturalLanguage) {
    'use strict';

    return NaturalLanguage;
});
