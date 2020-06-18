// TODO (HWU): 
// - Rename this in "BeScript" or "Script".

define('DS/StuModel/StuBeScript', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask'], function (STU, Behavior, Task) {
    'use strict';
    

    //////////////////////////////////////////////////////////////////////////////
    //                            Class definitions                             //
    //////////////////////////////////////////////////////////////////////////////
    /*****************************************************************************
    Task dedicated to Script execution. This task will invoke the "execute"
    method on script components.
    
    @constructor
    @param {StuBeScript} iStuBeScript - The script component to "execute".
    *****************************************************************************/
    var StuBeScriptTask = function (iStuBeScript) {

        Task.call(this);

        this.comp = iStuBeScript;

    };
    

    StuBeScriptTask.prototype = new Task();
    StuBeScriptTask.prototype.constructor = StuBeScriptTask;

    StuBeScriptTask.prototype.onExecute = function (iExContext) {
        if (this.comp !== undefined && this.comp !== null && this.comp.getActor() !== undefined && this.comp.getActor() !== null) {

            // first of all we check if script was built correctly
            if (this.comp.scriptinstance !== undefined && this.comp.scriptinstance.BuildStatus !== undefined && this.comp.scriptinstance.BuildStatus === "Failed") {

                if (((this.comp.execute === undefined) || (this.comp.execute !== undefined && this.comp.execute.errorsent === undefined)) && (this.comp.onStart !== undefined && this.comp.onStart.errorsent === undefined)) {
                    // We want to send the error only once, so we check if it has already been sent either by the execute or by the OnStart
                    var actor = this.comp.getActor();
                    throw new Error('Actor : ' + "Script was not built successfully and hence cannot be run - Task is deactivated");
                }
                this.comp.execute = function () { };
                this.comp.execute.errorsent = "true";
            }
            // Call execute only if the method exists on the component and that build succeeded
            else if ("execute" in this.comp) {
                try {
                    var result = eval(this.comp.execute(iExContext));
                }
                catch (runtimeError) {
                    var actor = this.comp.getActor();

                    console.log(runtimeError);

                    //console.error('Actor : ' + actor.getName() + " - " + runtimeError.stack);
                    console.error(this.decodeErrorStack(runtimeError.stack) + "\n" + runtimeError.stack);
                    this.comp.execute = function () { };
                }
            }

        }
    };

    StuBeScriptTask.prototype.onStart = function () {
        if (this.comp !== undefined && this.comp !== null && this.comp.getActor() !== undefined && this.comp.getActor() !== null) {
            // We make sure auto listeners are properly registered 
            if(typeof this.comp.registerAutoListeners == "function"){
                this.comp.registerAutoListeners();
            }

            // first of all we check if script was built correctly
            if (this.comp.scriptinstance !== undefined && this.comp.scriptinstance.BuildStatus !== undefined && this.comp.scriptinstance.BuildStatus === "Failed") {

                if ((this.comp.onStart === undefined) || (this.comp.onStart !== undefined && this.comp.onStart.errorsent === undefined)) {
                    var actor = this.comp.getActor();
                    throw new Error(' Actor : ' + actor.getName() + " - Script was not built successfully and hence cannot be run - Task is deactivated");
                }
                this.comp.onStart = function () { };
                this.comp.onStart.errorsent = "true";
            }
            // Call "onStart" only if the method exists on the component and that build succeeded
            else if ("onStart" in this.comp) {
                try {
                    this.comp.onStart();
                }
                catch (runtimeError) {
                    var actor = this.comp.getActor();

                                        
                    
                    console.error(this.decodeErrorStack(runtimeError.stack) + "\n" + runtimeError.stack);
                    //console.error('Actor : ' + actor.getName() + " - " + runtimeError.stack);
                    this.comp.onStart = function () { };
                }
            }
        }
        return this;
    };

    StuBeScriptTask.prototype.onStop = function () {
        if (this.comp !== undefined && this.comp !== null && this.comp.getActor() !== undefined && this.comp.getActor() !== null) {

            // first of all we check if script was built correctly
            if (this.comp.scriptinstance !== undefined && this.comp.scriptinstance.BuildStatus !== undefined && this.comp.scriptinstance.BuildStatus === "Failed") {

                if (((this.comp.onStop === undefined) || (this.comp.onStop !== undefined && this.comp.onStop.errorsent === undefined)) && (this.comp.execute !== undefined && this.comp.execute.errorsent === undefined) && (this.comp.onStart !== undefined && this.comp.onStart.errorsent === undefined)) {
                    // We want to send the error only once, so we check if it has already been sent either by the execute or by the OnStart
                    var actor = this.comp.getActor();
                    throw new Error('Actor : ' + "Script was not built successfully and hence cannot be run - Task is deactivated");
                }
                this.comp.onStop = function () { };
                this.comp.onStop.errorsent = "true";
            }
            // Call "onStop" only if the method exists on the component and that build succeeded
            else if ("onStop" in this.comp) {
                try {
                    this.comp.onStop();
                }
                catch (runtimeError) {
                    var actor = this.comp.getActor();

                    //console.error('Actor : ' + actor.getName() + " - " + runtimeError.stack);
                    console.error(this.decodeErrorStack(runtimeError.stack) + "\n" + runtimeError.stack);
                    this.comp.onStop = function () { };
                }
            }
        }
        return this;
    };


    StuBeScriptTask.prototype.decodeErrorStack = function (stack) {        
        var actor = this.comp.parent;        
        var compName = this.comp.name;
                       
        //var regexp = /at beScript\..+(\d+):\d+\)/;
        //var regexp = /at beScript\..+:([\d]+):/;
        var regexp = /at .+:([\d]+):/;
        var match = regexp.exec(stack);
        
        // Note: be carefull when editing this line generation, as this line is 
        // parsed by the CXP GUI for crosshiglight with the Script Editor.
        // Search for [ScriptErrorParsing] tag to find that code.
        return "Actor: <" + actor.name + "> Script: <" + compName + "> Line: <" + match[1] + ">";
    };

    /*****************************************************************************
    Component dedicated to Script authoring and execution.
    The "execute" method should be overridden on each Script instance.

    @constructor
    *****************************************************************************/
    var StuBeScript = function Script() {
        Behavior.call(this);

        this.name = "BeScript";
        // Useless until JS -> C++ mechanism is bypassed for this entity.
        //this.script     = "beScript.execute = function () \n{\n //Insert your code here.\n}\n";
        this.script = "";
        //this.scriptinstance = null;

        this.associatedTask;        
    };

    //////////////////////////////////////////////////////////////////////////////
    //                           Prototype definitions                          //
    //////////////////////////////////////////////////////////////////////////////
    StuBeScript.prototype = new Behavior();
    StuBeScript.prototype.constructor = StuBeScript;
    
    /*****************************************************************************
    This method describes the "logic" of the script component 
    (its user implementation).
    Studio build phase is responsible for this method creation on each 
    instance (by defining its content based on the "script" property).

    @return {StuBeScript} this (calling instance)
    *****************************************************************************/
    StuBeScript.prototype.execute = function () {        
        return this;        
    };

    /*****************************************************************************
    This method applies the code contained in the script property to the 
    current instance of StuBeScript.
    Studio build phase is responsible for this method call on each 
    instance.

    @return {StuBeScript} this (calling instance)
    *****************************************************************************/
    StuBeScript.prototype.updateCode = function () {
        var that = this;
        STU.trace(function () { return " StuBeScript.updateCode: Applying source \"" + that.script + "\" on instance " + that.stuId; }, STU.eTraceMode.eVerbose, "BeScript");
        if (this.scriptinstance !== null) {

            try {
                var result = eval("(function (beScript) { " + this.scriptinstance.script + "})(this)");
            }
            catch (e) {
                var error_msg = "StuBeScriptB Syntax error in '" + that.name + "' : ";
                error_msg += (e.message !== undefined && e.message !== null ? e.message : "<undefined error>")
                error_msg += (e.line !== undefined && e.line !== null ? e.line : "")
                console.error(error_msg);
            }
        }
    };


    StuBeScript.prototype.finalize = function () {
        Behavior.prototype.finalize.call(this);
        
        var that = this;

        STU.trace(function () { return " StuBeScript.finalize: On instance " + that.stuId; }, STU.eTraceMode.eVerbose, "BeScript");

        this.updateCode();
        
        return this;
    };

    StuBeScript.prototype.onActivate = function () {
        Behavior.prototype.onActivate.call(this);

        this.associatedTask = new StuBeScriptTask(this);
        EP.TaskPlayer.addTask(this.associatedTask);
        if (EP.TaskPlayer.isPlaying()) {
            this.associatedTask.start();
        }
    };

    StuBeScript.prototype.onDeactivate = function () {
        EP.TaskPlayer.removeTask(this.associatedTask);
        delete this.associatedTask;

        Behavior.prototype.onDeactivate.call(this);
    };

    //////////////////////////////////////////////////////////////////////////////
    //                            STU expositions.                              //
    //////////////////////////////////////////////////////////////////////////////

    // Expose only those entities in STU namespace.
    STU.StuBeScriptTask = StuBeScriptTask;
    // EEA IR-310911 careful here we have renamed the exposition in STU because of that IR
    STU.Script = StuBeScript;



	// Add a container for all scripts prototypes created by the user, that will be put here
	// automatically during the projection (see StuEScriptComponentPrototypeBuild)
    STU.Scripts = {};

    return StuBeScript;
});

define('StuModel/StuBeScript', ['DS/StuModel/StuBeScript'], function (StuBeScript) {
    'use strict';

    return StuBeScript;
});
