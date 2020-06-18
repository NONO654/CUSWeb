/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ps = swv6.ps || {};

(function () {
    /**
     * @class swv6.ui.Action.Camera
     * @extends swv6.ui.Action
     * TODO: description
     */
//    'use strict';
    var CLASS,
        BASE = swv6.ui.Action;

    CLASS =
        swv6.ui.Action.Camera =
        function (config) {
            CLASS.base.ctor.apply(this, arguments);

            this.position = config.position || this.state.camera.getPosition();
            this.duration = (config.duration !== undefined) ? config.duration : 500;

            this.store('camera');
        };

    swv6.util.inherit(CLASS, BASE, {

        redo: function () {
            CLASS.base.redo.apply(this, arguments);

            return this.state.camera.createPath()
                        .addPosition({
                            time: this.duration,
                            position: this.position
                        })
                        .run();
        },

        run: function () {

            return CLASS.base.run.apply(this, arguments);
        },

        setPosition: function (position) {
            this.position = position;
        },

        setDuration: function (duration) {
            this.duration = duration;
        }

    });

}());

