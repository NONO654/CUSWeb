// @ts-check
define('DS/SMAProcWebEditorsCommon/SMAProcWebInWin', [
    'DS/ApplicationFrame/FrameWindowsManager',
    'DS/ApplicationFrame/FrameWindow',
    'DS/JSCMM/SMAJSCMMProcess',
    'DS/JSCMM/SMAJSCMMActivity',
    'DS/JSCMM/SMAJSCMMStep',
    'DS/SMAProcWebCMMUtils/SMAJSCMMWebInWinUtils',
    'DS/SMAProcWebCMMUtils/SMAProcWebInWinEventHandler',
    'DS/SMAProcWebCMMUtils/PubSub',
    'DS/SMAProcWebCMMUtils/SMAJSCMMAuthoringUtils',
    'DS/SMAProcWebCMMUtils/SMAWINAuthoringUtils',
    'DS/SMAProcWebCommonControls/Polymer',
    'css!DS/SMAProcWebEditorsCommon/SMAProcWebInWin.css'
], function (
        frameWindowsManager,
        AFRFrameWindow,
        SMAJSCMMProcess,
        SMAJSCMMActivity,
        SMAJSCMMStep,
        SMAJSCMMWebInWinUtils,
        SMAProcWebInWinEventHandler,
        PubSub,
        SMAJSCMMAuthoringUtils,
        SMAWINAuthoringUtils) {
        'use strict';
        var SMAProcWebInWin = function() {
            this._stepConfig = null;
            this._stepConfigJson = null;
            this._EditorImpl = null;
            this._cachedFunctions = [];
            this._loaded = false;
            this._activity = null;
            this._process = null;
            this._step = null;
            this._xmlDoc =  null;
        };

        /**
         * Following function will create web component for adapter.
         * Call updateUI of web-adapter-editor.
         */
        SMAProcWebInWin.prototype.SMAWflUpdateUI = function (webEditor, webComp)
        {
            var me = this;
            var wc;
            var updateUiAfterLoad = function () {
                console.log('web component <' + webComp + '> available, will now try to call UpdateUI');
                if (wc && wc.ExtensionEditorImpl) {
                    var EditorImpl = wc.ExtensionEditorImpl;
                    me._EditorImpl = wc.ExtensionEditorImpl;
                    if (EditorImpl)
                    { EditorImpl.UpdateUI(me._activity, me._step, me._stepConfig); }
                    //me.UpdateUI(actId, stepId, xmlConfig, EditorImpl);
                }
            };

            if (webEditor && webComp) {
            // if component is not already in the DOM
                wc = document.querySelector(webComp);
                if (wc === null) {
                // Always import it and instanciate it
                    var wcUrl = '../' + webEditor;
                    window.Polymer.Base.importHref([wcUrl], function () {
                        wc = document.querySelector(webComp) || document.createElement(webComp);
                        // WebUX dialog requires immersiveFrame.
                        this.frmWindow = new AFRFrameWindow({
                            workbench: '',
                            workbenchModule: 'SMAProcWebApp',
                            height: '100%',
                            width: '100%',
                            viewer: 'none',
                            viewerOptions: {
                                antiAliasing: true,
                                useShadowMap: false,
                                infinitePlane: false,
                                displayGrid: false,
                                displayLines: false,
                                control: 'SIMPLE',
                                ssao: false,
                                debugShadowLight: false,
                                debugBSphere: false,
                                debugBBox: false
                            },
                            uiOptions: {
                                displayActionBar: false,
                                displayTree: false
                            }
                        }).inject(document.getElementById('extensionEditor'));

                        var frameWindow = frameWindowsManager.getFrameWindow(), uiFrame = null;
                        if (frameWindow) {
                            uiFrame = frameWindow.getUIFrame();
                        }
                        if (uiFrame ) {
                            uiFrame.appendChild(wc);
                        }
                        var attached = wc.attached;
                        wc.attached = function(){
                            attached && attached.call(this);
                            setTimeout(updateUiAfterLoad, 100);
                        };

                    });
                } else {
                    updateUiAfterLoad();
                }
            } else {
                console.log('both web editor and web component must be specified');
                webEditor = '';
                webComp = 'cmp-generic';
            }
        };
        SMAProcWebInWin.prototype.changeSelectedContent = function(data)
        {
            var event = new CustomEvent('PCWSelectedContentChanged', {detail:{content:data.content}});
            var contentElem = document.getElementById(data.contentElemName);
            contentElem.dispatchEvent(event);
        };

        /**
         * This is the first funtion call in JS called from loadExtension
         * This function will register PubSub callbacks for messages and requests.
         * Also, this function will send first message to Wintop. This message will contain
         * request for
         * 1) Content
         * 2) Parameters
         * 3) StepConfig
         * 4) Extension Descriptor Query
         */
        SMAProcWebInWin.prototype.onExtensionLoaded = function () {
            console.info('in onExtensionLoaded');

            this._loaded = true;
            this._process = new SMAJSCMMProcess();
            SMAJSCMMAuthoringUtils.currentProcess = this._process;

            this._activity = new SMAJSCMMActivity();
            this._process.addChild(this._activity);
            this._process.addActivity(this._activity);

            this._step = new SMAJSCMMStep();

            var eventHandlerList = [];
            var eventHandlerNamesArray = [];
            var me = this;
            if (SMAProcWebInWinEventHandler && SMAProcWebInWinEventHandler.getEventHandlersList)
            { eventHandlerList = SMAProcWebInWinEventHandler.getEventHandlersList(); }
            eventHandlerNamesArray = Object.getOwnPropertyNames(eventHandlerList);
            for (var i = 0; i < eventHandlerNamesArray.length; i++) {
                PubSub.add(eventHandlerNamesArray[i], eventHandlerList[eventHandlerNamesArray[i]]);
            }
            /*
             * Add PubSub event to handle UpdateUI.
             * This will be called after wintop message is parsed
             * and converted xml to appropriate JSCMM objects.
             */
            PubSub.add('UpdateUI_Completed', function(data) {
                me._activity = data.activity;
                me._step = data.step;
                me._stepConfig = data.stepConfig;
                window.SMAProcWebInWinUtils.SMAWflUpdateUI( data.webEditor, data.webComp);
                console.log('Update completed');
            });

            /*
             * Following callbak will be dispatched after Apply message is received
             */
            PubSub.add('Apply_started', function() {
                console.info('in SMAProcWebInWin.Apply');
                if (!me._EditorImpl) {
                    alert('No editor implementation found');
                } else {
                    me._EditorImpl.Apply();
                }
            });
            /*
             * After response XML is created for Apply,
             * following callback will be invoked.
             * This callback sends the message back to the wintop
             * to save changes.
             */
            PubSub.add('Apply_Completed', function(data) {
            //remove jscallback from the message. Once we send this message we do not expect to do any other processing
                var msgDoc = data.message;
                msgDoc.setAttribute('jsCallback', 'ApplyComplete');
                var messageString = (new XMLSerializer()).serializeToString(msgDoc);
                console.log(messageString);
                SMAWINAuthoringUtils.sendMessage(messageString);
                console.log('Apply completed');
            });

            PubSub.add('contentAdded', function(data){
                window.SMAProcWebInWinUtils.changeSelectedContent(data);
            });


            /*
             * Create first message XML. And send message to wintop to get follwoing
             * 1. Parameters
             * 2. StepConfig
             * 3. Content
             */
            var requestList = [];
            var request = SMAJSCMMWebInWinUtils.createRequestXML('ExtensionConfig');
            requestList.push(request);
            request = SMAJSCMMWebInWinUtils.createRequestXML('SimulationData');
            requestList.push(request);
            request = SMAJSCMMWebInWinUtils.createRequestXML('Parameters');
            requestList.push(request);
            request = SMAJSCMMWebInWinUtils.createRequestXML('Content');
            requestList.push(request);
            request = SMAJSCMMWebInWinUtils.createRequestXML('ExtensionDescriptor');
            var updatedRequest = SMAJSCMMWebInWinUtils.updateExtensionDescriptorReqXML(request);
            requestList.push(updatedRequest);
            var messageDom = SMAJSCMMWebInWinUtils.createMessageXML('GET', 'UpdateUI', requestList);
            var messageString = (new XMLSerializer()).serializeToString(messageDom);
            SMAWINAuthoringUtils.sendMessage(messageString);

        };

        /**
         * This function parses incoming message from Wintop
         * and dispatches callback to messageHandler
         * @param {Object} data message from wintop
         */
        SMAProcWebInWin.prototype.parseMessage = function(data) {
            var xmlDoc = (new DOMParser()).parseFromString(data.message, 'text/xml');
            var messageNodes = xmlDoc.getElementsByTagName('Message');
            if (data.activityId) {
                this._activity.setId(data.activityId);
            }

            var stepConfig = this._stepConfig;
            for (var i=0;i<messageNodes.length;i++){
                var messageElem = messageNodes[i];
                var jsCallback = messageElem.getAttribute('jsCallback');
                var requestList = messageElem.getElementsByTagName('Request');
                var messageType = messageElem.getAttribute('messageType');
                var requestType;
                if (/GET/i.test(messageType)) {
                    requestType = 'set';
                } else if (/POST/i.test(messageType)) {
                    requestType = 'get';
                } else {
                    console.warn('Missing message type: ', messageType);
                }
                var obj = {
                    requestType:requestType,
                    requestList:requestList,
                    activity:this._activity,
                    step:this._step,
                    stepConfig:stepConfig,
                    webComp:data.webCompName,
                    webEditor:data.webEditor,
                    message:messageElem
                };
                PubSub.dispatch(jsCallback, obj);

            }


        };
        return SMAProcWebInWin;

    });

/** Called upon webview startup */
function loadExtension() { // eslint-disable-line no-unused-vars

    'use strict';
    console.info('Called loadExtension');
    require(['DS/SMAProcWebEditorsCommon/SMAProcWebInWin'], function(SMAProcWebInWin) {
        // @ts-ignore
        if (!window.SMAProcWebInWinUtils){
            // @ts-ignore
            window.SMAProcWebInWinUtils = new SMAProcWebInWin();
        }
        // @ts-ignore
        window.SMAProcWebInWinUtils.onExtensionLoaded();
    });
}

/**
 * Called from wintop to send messages to JS
 * @param {String} message message from wintop
 */
function receiveMessage(message) { // eslint-disable-line no-unused-vars
    'use strict';
    var data = {message:message, webCompName:'', webEditor:''};
    window.SMAProcWebInWinUtils.parseMessage(data);
}
