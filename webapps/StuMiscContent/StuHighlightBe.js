define('DS/StuMiscContent/StuHighlightBe', ['DS/StuCore/StuContext', 'DS/StuModel/StuBehavior', 'DS/EPTaskPlayer/EPTask'], function (STU, Behavior, Task) {
    'use strict';

    //Highlight Behaviour
    var Highlight = function () {

        Behavior.call(this);

        this.componentInterface = this.protoId;
        this.highlightOnMouseover = true;


        this.name = "Highlight";
        this.mainViewer;
    };

    Highlight.prototype = new Behavior();
    Highlight.prototype.constructor = Highlight;
    Highlight.prototype.protoId = "11A0A8D8-65D0-43B8-92E8-CB048E800386";

    Highlight.prototype.onActivate = function () {
        Behavior.prototype.onActivate.call(this);
        this.main3DViewer = new StuViewer();
        if (this.highlightOnMouseover) {
        	this.getActor().addObjectListener(STU.ClickableMoveEvent, this, 'onEnterMouseOver');
        	this.getActor().addObjectListener(STU.ClickableExitEvent, this, 'onExitMouseOver');
        }

    };

    Highlight.prototype.onDeactivate = function () {

        Behavior.prototype.onDeactivate.call(this);
        this.getActor().removeObjectListener(STU.ClickableMoveEvent, this, 'onEnterMouseOver');
        this.getActor().removeObjectListener(STU.ClickableExitEvent, this, 'onExitMouseOver');

    };


    Highlight.prototype.onEnterMouseOver = function () {
        //var currentActor = this.getActor().CATI3DExperienceObject;
        //var val = this.main3DViewer.HighlightDisplay(currentActor, 1);
        var currentActor = this.getActor();
        var renderManager = STU.RenderManager.getInstance();
        renderManager.highlight(currentActor, 1);
    };

    Highlight.prototype.onExitMouseOver = function () {
       // var currentActor = this.getActor().CATI3DExperienceObject;
       // var val = this.main3DViewer.HighlightDisplay(currentActor, 0);
        var currentActor = this.getActor();
        var renderManager = STU.RenderManager.getInstance();
        renderManager.highlight(currentActor, 0);
       
    };

    Highlight.prototype.highlight = function () {
        var currentActor = this.getActor();
        var renderManager = STU.RenderManager.getInstance();
        renderManager.highlight(currentActor, 1);
    };

    Highlight.prototype.deHighlight = function () {
        var currentActor = this.getActor();
        var renderManager = STU.RenderManager.getInstance();
        renderManager.highlight(currentActor, 0);
    };
    

    STU.Highlight = Highlight;

    return Highlight;

});

define('StuMiscContent/StuHighlightBe', ['DS/StuMiscContent/StuHighlightBe'], function (Highlight) {
    'use strict';

    return Highlight;
});
