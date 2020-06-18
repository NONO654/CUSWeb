
define('DS/StuScenario/StuScenarioParagraph', ['DS/StuCore/StuContext', 'DS/StuModel/StuInstance'], function (STU, Instance) {
    'use strict';


    /**
     * @exports ScenarioParagraph
     * @class
     * @constructor
     * @noinstancector
     * @private
     * @extends STU.Instance
     * @memberof STU
	 * @alias STU.ScenarioParagraph
     */
    var ScenarioParagraph = function () {
        Instance.call(this);

        this.CATI3DExperienceObject;

        this.name = "ScenarioParagraph";

        this.sentences = [];
    };

    ScenarioParagraph.prototype = new Instance();
    ScenarioParagraph.prototype.constructor = ScenarioParagraph;

    /**
    * Return the experience
    * @method
    * @private
    * @return {STU.Experience} instance object corresponding to the experience
    */
    ScenarioParagraph.prototype.getExperience = function () {
        return STU.Experience.getCurrent();
    };

    /**
     * Process executed when STU.ScenarioParagraph is initializing.
     *
     * @method
     * @private
     */
    ScenarioParagraph.prototype.onInitialize = function () {
        STU.Instance.prototype.onInitialize.call(this);

        for (var i = 0; i < this.sentences.length; i++) {
            this.sentences[i].initialize();
        }
    };
    /**
     * Process executed when STU.ScenarioParagraph is activating.
     *
     * @method
     * @private
     */
    ScenarioParagraph.prototype.onActivate = function () {

        if (this.activation == false) 
            return;

        STU.Instance.prototype.onActivate.call(this);

        for (var i = 0; i < this.sentences.length; i++) {
            this.sentences[i].activate();
        }
    };
    /**
     * Deactivate the STU.ScenarioParagraph.
     *
     * @method
     * @private
     */
    ScenarioParagraph.prototype.onDeactivate = function () {
        
        if (this.activation == false) 
            return;

        for (var i = 0; i < this.sentences.length; i++) {
            this.sentences[i].deactivate();
        }

        STU.Instance.prototype.onDeactivate.call(this);
    };


    // Expose in STU namespace.
    STU.ScenarioParagraph = ScenarioParagraph;

    return ScenarioParagraph;
});

define('StuScenario/StuScenarioParagraph', ['DS/StuScenario/StuScenarioParagraph'], function (ScenarioParagraph) {
    'use strict';

    return ScenarioParagraph;
});
