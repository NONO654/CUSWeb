/**
 * @license Copyright 2017 Dassault Systemes. All rights reserved.
 *
 * @overview : Mediator Component - handling communication between components
 *
 */

define('DS/ENOXMediator/js/Mediator', [
        'DS/CoreEvents/ModelEvents'
    ],

    function(
        ModelEvents) {
        'use strict';

        var mediator = function() {
            // Private variables
            this._uniqueId = 0;
            this._componentsMap = new Map();
            this._channelsMap = new Map();
        };

        // Public API
        /**
         * publish a topic on given channels in param, additional data may go along with the topic published
         * @param {string} eventTopic the topic to publish
         * @param {string} the id of the component publishing (may not be needed.. we can retrieve the caller)
         * @param {Array} an array of channels Ids, where to publish the topic. If null or undefined or [], all channels where the components is registered will be notified
         * @param {JSON} data a set of additional data (no data will be passed if null passed in param)
         * @return
         */
        mediator.prototype.publish = function(eventTopic, componentId, channels, data) {
            var channelsIds = (channels) ? channels : [];
            var i = 0;
            if (channelsIds.length === 0) { // if no channels passed in param, publish on all channels of the component
                channelsIds = this._componentsMap.get(componentId);
            }
            for (i = 0; i < channelsIds.length; i += 1) {
                this._channelsMap.get(channelsIds[i]).publish({
                    event: eventTopic,
                    data: data
                }); // publish from ModelEvent
            }
        };

        /**
         *
         * Subscribe to a topic
         * @param {string} eventTopic the topic to subcribe to
         * @param {string} componentId, the componentId that is subscribing
         * @param {array} channels channelIDs as array where to subscribe to the eventTopic
         * @param {function} callback the function to be called when the event fires
         * @param {args} potentially additional arguments, passed to the callback if need be
         */
        mediator.prototype.subscribe = function(eventTopic, componentId, channels, callback, ...args) {

            var channelsIds = (channels) ? channels : [];
            var i = 0;
            // if no channels passed in param, publish on all channels of the component
            if (channelsIds.length === 0) {
                channelsIds = this._componentsMap.get(componentId);
            }
            for (i = 0; i < channelsIds.length; i += 1) {
                if (args && args.length > 0) {
                    this._channelsMap.get(channelsIds[i]).subscribe({
                        event: eventTopic
                    }, function(data) {
                        callback(data, ...args)
                    });
                } else {
                    this._channelsMap.get(channelsIds[i]).subscribe({
                        event: eventTopic
                    }, callback);
                }
            }
        };

        /**
         * NOT IMPLEMENTED FOR NOW **
         * Unsubscribe to a topic
         * @param {string} eventTopic the topic to subcribe to
         * @param {string} componentId, the componentId that is unsubscribing
         * @param {array} channels the list of channels where to unsubsribe
         */
        mediator.prototype.unsubscribe = function(eventTopic, componentId, channels) {
            //var channelsIds = (channels) ? channels : [];
            //var i = 0;
            //// if no channels passed in param, publish on all channels of the component
            //if (channelsIds.length === 0) {
            //    channelsIds = this._componentsMap.get(componentId);
            //}
            //for (i = 0; i < channelsIds.length; i += 1) {
            //    this._channelsMap.get(channelsIds[i]).unsubscribe({ event: eventTopic });
            //}
        };

        /**
         * Create a new channel in the mediator. Ensures that the created channel is unique
         * @return {integer/string} channelId the id that identifies the channel created
         */
        mediator.prototype.createNewChannel = function() {
            this._channelsMap.set(this._uniqueId, new ModelEvents());
            var currentId = this._uniqueId;
            this._uniqueId++;
            return {
                channel: this._channelsMap.get(currentId),
                id: currentId
            };
        };

        /**
         * Registers a component to a channel
         * @param {integer/string}  idChannel the channel to register to
         * @param {integer/string} idComponent the component identifier that wants to register
         */
        mediator.prototype.registerToChannel = function(idChannel, idComponent) {
            var currentArray = this._componentsMap.get(idComponent);
            if (currentArray) { // check whether the compoennt is already kwnown
                if (currentArray.indexOf(idChannel) >= 0) {
                    return 0; // no need to re-register the component on the channel
                } else {
                    currentArray.push(idChannel);
                    //this._componentsMap.set(idComponent, currentArray); -- currentArray already pointing on the good element
                    return 0;
                }
            }
            this._componentsMap.set(idComponent, [idChannel]);
            return 0;
        };

        /**
         * Unregisters a component from a channel
         * @param {integer/string}  idChannel the channel to register to
         * @param {integer/string} idComponent the component identifier that wants to register
         */
        mediator.prototype.unregisterToChannel = function(idChannel, idComponent) {
            var currentArray = this._componentsMap.get(idComponent);
            var currentIndex = -1;
            if (currentArray) {
                currentIndex = currentArray.indexOf(idChannel);
                if (currentIndex >= 0) {
                    currentArray = currentArray.splice(currentIndex, 1);
                }
            }
            return 0;
        };
        return mediator;
    });
