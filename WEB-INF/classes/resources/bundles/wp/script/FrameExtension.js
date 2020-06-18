/* global require */

require(['UWA/Environments/Frame', 'UWA/Widget'], function (Frame, Widget) {

    'use strict';

    /**
     * Prefix widget log message by their ID when inside a frame.
     */
    (function () {
        var parent = Widget.prototype.log;
        Widget.prototype.log = function (msg) {
            return parent.call(this, 'Widget' + (this.id ? ' instance #' + this.id : '') + ': ' + msg);
        };
    }());

    /**
     * Dispatch an onUpdateMenu when removeMenu is called.
     * Not done by netvibes. sight.
     */
    (function () {
        var parent = Widget.prototype.removeMenu;
        Widget.prototype.removeMenu = function (name) {
            parent.call(this, name);
            this.launched && this.dispatchEvent('onUpdateMenu', [this.menus]);
        };
    }());

    /**
     * We need this to pass the metas to the parent environment since the getWidget call
     * is not performed anymore.
     */
    (function () {
        var parent = Widget.prototype.setMetas;
        Widget.prototype.setMetas = function (metas) {
            // Avoid duplication of autorefresh calls
            this.clearPeriodical('autoRefresh');
            parent.call(this, metas);
            this.environment.sendRemote('onUpdateMetas', metas);
        };
    }());

    /**
     * This will call original onEdit then dispatch it to parent environment.
     */
    (function () {
        var parent = Frame.prototype.onEdit;
        Frame.prototype.onEdit = function (e) {
            parent.call(this);
            this.sendRemote('onEdit', e);
        };
    }());

    /**
     * This will call frame endEdit then dispatch it to parent environment.
     */
    (function () {
        var parent = Frame.prototype.endEdit;
        Frame.prototype.endEdit = function (e) {
            parent.call(this);
            this.sendRemote('endEdit', e);
        };
    }());

    /**
     * This will call frame onUpdateMenu then dispatch it to parent environment.
     */
    (function () {
        var parent = Frame.prototype.onUpdateMenu;
        Frame.prototype.onUpdateMenu = function (menus) {
            parent.call(this);
            this.widget.launched && this.sendRemote('onUpdateMenu', menus);
        };
        /**
         * Remove default frame menus.
         */
        Frame.prototype.registerMenus = function () {
            this.widget.setMenu({ name: 'options' });
        };
    }());

    /**
     * Remove any dispatch to parent environment from inside the frame.
     */
    (function () { Frame.prototype.onResize = function () {}; }());

    /**
     * Prevent 500 ms timeout on Intercom
     */
    (function () {
        var parent = Frame.prototype.initRemote;
        Frame.prototype.initRemote = function () {
            var that = this,
                savedRemoteQueue = this._remoteQueue;

            // Empty remote queue to bypass check inside _runRemoteQueue
            this._remoteQueue = [];
            parent.call(this);
            // Put back remote queue once parent is called
            this._remoteQueue = savedRemoteQueue;

            // Run the queue when we successfully subscribed to parent server
            this.socket.addListener('subscribe', function runQueue () {
                that._runRemoteQueue();
                that.socket.removeListener('subscribe', runQueue);
            });
        };
    }());
});
