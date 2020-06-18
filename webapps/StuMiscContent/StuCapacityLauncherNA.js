
/* global define , StuVisuServices , StuViewer , StuGeomPrimitive_ISOManager , stu__GlobeServices*/
define('DS/StuMiscContent/StuCapacityLauncherNA', ['DS/StuMiscContent/StuCapacityLauncher'], function (CapacityLauncher) {
    'use strict';

    CapacityLauncher.prototype.createElement = function (name,args) {
        return UI.createElement(name, args);
    };
   //CapacityLauncher.prototype.createButtonsLayout = function (buttons) {
   //    var layout = UI.createElement("CATVidLayGrid");
   //    for (var i = 0; i < buttons.length; i++) {
   //        var constraints = "x=0 y=" + i + " " + "xSpan=1 ySpan=1 attach=RLTB";
   //        layout.SetConstraints(buttons[i], constraints);
   //    }
   //    return layout;
   //};

    CapacityLauncher.prototype.createCapacityPanel = function (buttons,offset) {
        //create a grid-based button layout
        var layout = UI.createElement("CATVidLayGrid");
        for (var i = 0; i < buttons.length; i++) {
            var constraints = "x=0 y=" + i + " " + "xSpan=1 ySpan=1 attach=RLTB";
            layout.SetConstraints(buttons[i], constraints);
        }
        //create a panel that contains the buttons
        var panel = UI.createElement("CATVidFraLabel", {
            ApplicativeWidget: layout,
            FloatableFlag: true,
            AutoCloseFlag: true,
            CompactFlag: true,
            TitleBarVisibleFlag: false,
            MinimumDimension: "200 150",
            Opacity: 255
        });
        
        return panel;
    }
    CapacityLauncher.prototype.setClickEventName = function(){
        return "Press";
    };

    CapacityLauncher.prototype.getCapacities = function () {
        return this.capacities;
    };

    CapacityLauncher.prototype.setVisibility = function (elem, visibility) {
            elem.VisibleFlag = visibility;

    }
    CapacityLauncher.prototype.toggleVisibility = function (elem) {
        elem.VisibleFlag = !elem.VisibleFlag; 
          
    };
    return CapacityLauncher;
});

