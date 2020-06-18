/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ps = swv6.ps || {};

(function () {
    /**
     * @class swv6.ui.Action.Search
     * @extends swv6.ui.Action.Camera
     * TODO: description
     */
    'use strict';
    var CLASS,
        BASE = swv6.ui.Action.Camera;

    CLASS =
        swv6.ui.Action.Search =
        function (config) {

            CLASS.base.ctor.apply(this, arguments);

            this.type = config.type; // 'new'|'forward'|'backward'|'clear'
            this.searchTerm = config.searchTerm; // for 'new' searches

            this.setPosition({ 
                type: 'fit', 
                el: this.state.camera.scene,
                padding: this.state.camera.padding
            });
            this.setDuration(700);

            this.firstRun = true;
        };

    swv6.util.inherit(CLASS, BASE, {

        redo: function () {
            var search = this.state.search,
                active,
                node,
                w, h,
                position;

            switch (this.type) {
            case 'new':
                search.search(this.searchTerm);
                break;
            case 'forward':
                search.forward();
                break;
            case 'backward':
                search.backward();
                break;
            case 'clear':
                search.clear();
                break;
            }

            if (this.firstRun) {
                this.firstRun = false;

                if ((this.type === 'forward') || (this.type === 'backward')) {
                    if (search.getActive() !== null) {
                        node = search.results[search.getActive()];

                        w = node.getWidth();
                        h = node.getHeight();

                        position = this.state.camera.createPosition({
                            type: 'box',
                            x: node.getX() - w/2,
                            y: node.getY() - h/2,
                            width: w*2,
                            height: h*2
                        });

                        if (position.getZoom() > 1) {
                            position = position.zoom(1);
                        }

                        this.setPosition(position);
                    }
                }
            }

            return CLASS.base.redo.apply(this, arguments);
        },

        run: function () {

            switch (this.type) {

            case 'new':
            case 'clear':
                this.store('tree');
                this.store('search tree');
                break;

            case 'forward':
            case 'backward':
                this.store('search active');
                break;
            }

            return CLASS.base.run.apply(this, arguments);
        }

    });

}());
