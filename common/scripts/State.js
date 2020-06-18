/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ps = swv6.ui || {};


(function () {
    /**
     * @class swv6.ui.State
     * @extends Object
     * TODO: description
     */
    'use strict';
    var CLASS,
        BASE = Object;

    CLASS =
        swv6.ui.State =
        function (config) {
            this.camera = config.camera;
            this.tree = config.tree;
            this.visualTree = config.visualTree;
            this.history = config.history;
            this.controller = config.controller;
            this.miniMap = config.miniMap;
            this.search = config.search || new swv6.ui.Search({
                tree: this.visualTree,
                camera: this.camera,
                searchFn: config.searchFn
/*
                label: swv6.$('searchLabel'),
                backButton: swv6.$('searchBack'),
                forwardButton: swv6.$('searchForward'),
                searchField: swv6.$('searchField'),
                clearButton: swv6.$('searchDelete')
*/
            });
        };

    swv6.util.inherit(CLASS, BASE, {

        camera: null,
        tree: null,
        visualTree: null,
        history: null,
        controller: null,
        miniMap: null,
        searchFn: null,

        save: function (store, value) {

            switch (value) {
                case 'camera':
                    store.camera = this.camera.getPosition();
                    break;
                case 'tree':
                    store.tree = this.visualTree.saveState();
                    break;
                case 'search tree':
                    store.searchTree = this.search.saveState();
                    break;
                case 'search active':
                    store.searchActive = this.search.getActive();
                    break;
            }

        },

        load: function (store) {

            if (store.camera) {
                this.camera.createPath()
                    .addPosition({
                        time: 500,
                        position: store.camera
                    })
                    .run();
            }

            if (store.tree) {
                this.visualTree.loadState(store.tree);
            }

            if (store.searchTree !== undefined) { // null is valid.
                this.search.restoreState(store.searchTree);
            }

            if (store.searchActive !== undefined) { // null is valid.
                this.search.setActive(store.searchActive);
            }

        },

        setTree: function (tree) {
            this.tree = tree;
            if (this.miniMap) {
                this.miniMap.setRoot(this.visualTree.getRoot());
            }
        },

        search: function () {
            
        }

    });


}());


(function () {
    /**
     * @class swv6.ui.Search
     * @extends Object
     * TODO: description
     */
    'use strict';
    var CLASS,
        BASE = Object;

    CLASS =
        swv6.ui.Search =
        function (config) {
            this.tree = config.tree;
            this.camera = config.camera;
            this.searchFn = config.searchFn || function () { return false; };
            this.label = config.label;
            this.forwardButton = config.forwardButton;
            this.backButton = config.backButton;
            this.searchField = config.searchField;
            this.clearButton = config.clearButton;
            this.results = [];

        };

    swv6.util.inherit(CLASS, BASE, {

        camera: undefined,

        results: undefined,
        active: null,
        term: '',
        navigationEnabled: undefined,

        label: undefined,
        forwardButton: undefined,
        backButton: undefined,

        ctor: function (config) {
        },

        setActive: function (value) {
            if (this.active !== null) {
                if (this.results[this.active]) {
                    this.results[this.active].g.removeClass('active-search-item');
                }
            }

            this.active = value;
            this.updateLabelAndButtons();

            if (this.active !== null) {
                this.results[this.active].g.addClass('active-search-item');
            }
        },

        getActive: function () {
            return this.active;
        },

        getTerm: function () {
            return this.term;
        },

        updateLabelAndButtons: function () {
            var text = '';

            this.navigationEnabled = (this.results.length > 0);

            text += (this.active !== null) ? (this.active + 1) + ' of ' : '';
            text += this.results.length + ' result' + ((this.results.length === 1) ? '' : 's');
            if (this.label) {
                this.label.innerHTML = text;
                this.label.style.display = (this.term ? '' : 'none');
            }    
            if (this.clearButton) {
                this.clearButton.style.visibility =  (this.term ? '' : 'hidden');
            }
            if (this.backButton) {
                this.backButton.style.opacity = (this.navigationEnabled ? 1 : 0.3);
                this.backButton.style.display = (this.term ? '' : 'none');
            }
            if (this.forwardButton) {
                this.forwardButton.style.opacity = (this.navigationEnabled ? 1 : 0.3);
                this.forwardButton.style.display = (this.term ? '' : 'none');
            }

        },

        backward: function () {
            var active = this.active;
            if (this.navigationEnabled) {
                if (active === null) {
                    active = this.results.length-1;
                } else if (active === 0) {
                    active = null;
                } else {
                    active--;
                }
                this.setActive(active);
                this.ensureActiveVisible();
            }
        },

        forward: function () {
            var active = this.active;
            if (this.navigationEnabled) {
                if (active === null) {
                    active = 0;
                } else if (active === this.results.length-1) {
                    active = null;
                } else {
                    active++;
                }
                this.setActive(active);
                this.ensureActiveVisible();
            }
        },

        ensureActiveVisible: function () {
            var parent;
            if (this.active !== null) {
                parent = this.results[this.active].getParent();
                while(parent) {
                    if (!parent.getExpanded()) {
                        parent.setExpanded(true);
                    }
                    parent = parent.getParent();
                }
            }
        },

        search: function (term) {
            this.setActive(null); // clears existing active item.
            this.term = term;
            if (this.searchField) {
                if (this.searchField.value !== term) {
                    this.searchField.value = term;
                }
            }

            this.results = this.tree.search(term, this.searchFn);
            this.setActive(null);
        },

        clear: function () {
            this.setActive(null); // clears existing active item.
            this.term = '';
            if (this.searchField) {
                this.searchField.value = '';
            }
            this.results = [];
            this.tree.clearSearchResults();
            this.setActive(null);
        },

        saveState: function () {
            var state;

            if (this.term) {
                state = {
                    nodes: [],
                    active: this.active,
                    term: this.term
                };

                if (this.results) {
                    this.results.forEach(function(node) {
                        state.nodes.push(node.getIndexPath());
                    });
                }
            } else {
                state = null; // no search active.
            }

            return state;
        },

        restoreState: function (state) {
            var that = this;

            this.term = (state ? state.term : '');

            if (this.searchField) {
                this.searchField.value = this.term;
            }

            this.results = [];

            if (state) {
                state.nodes.forEach(function(path) {
                    that.results.push(that.tree.nodeFromIndexPath(path));
                });
            }

            if (this.term) {
                this.tree.markSearchResults(this.results);
            } else {
                this.tree.clearSearchResults();
            }

            this.setActive(state ? state.active : null);

        }

    });

}());
