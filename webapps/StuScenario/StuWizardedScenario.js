define('DS/StuScenario/StuWizardedScenario', ['DS/StuCore/StuContext', 'DS/StuScenario/StuScenario'], function (STU, Scenario) {
    'use strict';

    /*****************************************************************************
    Component dedicated to WizardedScenario definition.

    @constructor
    *****************************************************************************/

    /**
    * Describe a wizarded scenario object ordered by a sequence of Acts {@link STU.ScenarioAct}.
    *
    * @exports WizardedScenario
    * @class 
    * @constructor
    * @public
    * @extends STU.Scenario
    * @memberof STU
    * @alias STU.WizardedScenario
    */

    var WizardedScenario = function () {
        Scenario.call(this);
        this.name = "WizardedScenario";

        /*
        * This is the collection of acts contained within the WizardedScenario.
        *
        * @property acts
        * @private
        * @type {Array.<STU.ScenarioAct>}
        */
        this.acts = [];

        /*
        * This is the first act to be played.
        *
        * @property startupAct
        * @private
        * @type {STU.ScenarioAct}
        */
        this.startupAct = null;

    };

    //////////////////////////////////////////////////////////////////////////////
    //                           Prototype definitions                          //
    //////////////////////////////////////////////////////////////////////////////
    WizardedScenario.prototype = new Scenario();
    WizardedScenario.prototype.constructor = WizardedScenario;

    //////////////////////////////////////////////////////////////////////////////
    //                            Methods definitions.                          //
    //////////////////////////////////////////////////////////////////////////////

    /**
     * Process executed when STU.WizardedScenario is activating.
     *
     * @method
     * @private
     */
    WizardedScenario.prototype.onActivate = function () {
        Scenario.prototype.onActivate.call(this);

        // activate the startup act
        if (this.startupAct !== null && this.startupAct !== undefined && this.startupAct instanceof STU.ScenarioAct) {

            this.startupAct.activate();
        }
    };

    /**
     * Process executed when STU.WizardedScenario is deactivating.
     *
     * @method
     * @private
     */
    WizardedScenario.prototype.onDeactivate = function () {
        for (var i = 0; i < this.acts.length; i++) {
            this.acts[i].deactivate();
        }

        Scenario.prototype.onDeactivate.call(this);
    };

    /**
     * Process to execute when this STU.WizardedScenario is initializing.
     *
     * @method
     * @private
     */
    WizardedScenario.prototype.onInitialize = function () {
        Scenario.prototype.onInitialize.call(this);


        // initialize only the startup act
        if (this.startupAct !== null && this.startupAct !== undefined && this.startupAct instanceof STU.ScenarioAct) {

            this.startupAct.initialize();
        }
    };

    /**
     * Process to execute when this STU.WizardedScenario is disposing.
     *
     * @method
     * @private
     */
    WizardedScenario.prototype.onDispose = function () {
        for (var i = 0; i < this.acts.length; i++) {
            this.acts[i].dispose();
        }

        Scenario.prototype.onDispose.call(this);
    };

    /**
     * Process to activate next act.<br/>
     * Sometimes the Act aggregates STU.Output(s) which is(are) connected to STU.Transition(s) leading to the next act with this linkage :<br/>
     *      Act(Output) <---> (Output)Transition(NextAct)<br/>
     * Transitions are aggregated on the scenario.<br/>
     * An helper methods 'GetNextActFromOutput()' is provided to give the NextAct according to an Output.<br/>
	 * 3 possible cases :<br/>
	 *      - no output on the current act => activate the following act of the scenario.Acts array<br/>
	 *      - optional output is specified => activate next act of the connected transition<br/>
	 *      - no optional output but there's a link exist between the current act and a transition => activate the 1st connected output<br/>
     *
     * @param {STU.ScenarioAct} [iCurrentAct] current act to deactivate
     * @method
     * @public
     */
    WizardedScenario.prototype.activateNextAct = function (iCurrentAct) {

        // try to get next act
        var currentAct = iCurrentAct !== null ? iCurrentAct : this.GetCurrentAct();
        if (currentAct === null || currentAct === undefined) {
            return;
        }

        var nextAct = this.GetNextAct(currentAct);
        if (nextAct === null || nextAct === undefined) {
            return;
        }

        // initialize and activate if any
        if (nextAct !== null && nextAct !== undefined && nextAct instanceof STU.ScenarioAct) {
            nextAct.initialize();
            nextAct.activate();
        }

        // deactivate the current one
        currentAct.deactivate();
    }

    /**
     * Helper to get next act, index+1 from the scenario.acts array.
     *
     * @method
     * @private
     * @param {STU.ScenarioAct} iAct - act to search from
     */
    WizardedScenario.prototype.GetNextAct = function (iAct) {
        var currentActIndex = this.acts.indexOf(iAct);
        var nextAct=null;
        if (currentActIndex != -1 && currentActIndex + 1 < this.acts.length) {
            nextAct = this.acts[currentActIndex + 1];
        }
        return nextAct;
    }

    /**
     * Helper to get previous act, index-1 from the scenario.acts array.
     *
     * @method
     * @private
     * @param {STU.ScenarioAct} iAct - act to search from
     */
    WizardedScenario.prototype.GetPreviousAct = function (iAct) {
        var currentActIndex = this.acts.indexOf(iAct);
        var nextAct=null;
        if (currentActIndex != -1 && currentActIndex - 1 >= 0) {
            nextAct = this.acts[currentActIndex - 1];
        }
        return nextAct;
    }

    /**
     * Public methods should be in lower camel case 
     * @deprecated R2019x
     * @private
     */
    WizardedScenario.prototype.GetCurrentAct = function () {
        for (var i = 0; i < this.acts.length; i++) {
            if (this.acts[i].isActive()) {
                return this.acts[i];
            }
        }
        return null;
    };
    
    /**
     * Helper to get the current act.
     * @method
     * @public
     * @return {STU.ScenarioAct}
     */
    WizardedScenario.prototype.getCurrentAct = WizardedScenario.prototype.GetCurrentAct;

    // Expose only those entities in STU namespace.
    STU.WizardedScenario = WizardedScenario
    return WizardedScenario;
});

define('StuScenario/StuWizardedScenario', ['DS/StuScenario/StuWizardedScenario'], function (WizardedScenario) {
    'use strict';

    return WizardedScenario;
});
