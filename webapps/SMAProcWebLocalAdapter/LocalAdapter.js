require(['DS/SMAProcWebCommonControls/Polymer', 'DS/SMAProcWebCommonControls/utils',
    'DS/SMAProcWebCMMUtils/SMAJSCMMUtils', 'DS/SMAProcWebCMMUtils/SMAJSCMMParameterUtils', 'DS/JSCMM/SMAJSCMMParameter',
    'DS/SMAProcWebCMMUtils/SMAJSCMMAuthoringUtils', 'DS/SMAProcWebCommonControls/NativeEditor', 'DS/UIKIT/Spinner',
    //,'text!DS/SMAPrcWebLocalAdapter/LocalAdapter.html'
    'DS/SMAProcWebContents/PolyUtils',
    'DS/SMAProcWebContents/ContentService',
    'DS/SMAProcWebContents/FileChooser',
    'DS/SMAProcWebCommonControls/FileChooser'
],
    function (Polymer, controlsUtils, SMAJSCMMUtils, SMAJSCMMParameterUtils, SMAJSCMMParameter,
        SMAJSCMMAuthoringUtils, NativeEditor, Spinner, PolyUtils, ContentService/*, template*/) {

        'use strict';

        //controlsUtils.registerDomModule(template);

        window.Polymer({
            is: 'pcw-local-adapter',
            properties: {

                ExtensionEditorImpl: {
                    type: Object
                },

                outputParameters: {
                    type: Array,
                    value: function () {
                        return [];
                    }
                },

                snippet: {
                    type: String,
                    notify: true
                },

                info: {
                    type: Object,
                    value: function () {
                        return {
                            'class': '',
                            'message': ''
                        };
                    }

                },

                downloadString: {
                    type: String,
                    value: null
                },

                uploadString: {
                    type: String,
                    value: null
                }

            },

            downloadChanged: function (val) {
                this.downloadString = val.detail.datahandlerconfig;
            },

            uploadChanged: function (val) {
                this.uploadString = val.detail.datahandlerconfig;
            },

            ready: function () {
                var me = this;

                this.ExtensionEditorImpl = this;

                this.nativeEditor = document.createElement('pcw-native-editor');

                this.loader = new Spinner({
                    renderTo: this.$.container,
                    visible: false
                });

                /*ksa7:: Usage of new pcw-sdk-* components. Follow these steps: */
                //1. create this in ready callback so that sp-* components are ready to use
                this.contentService = new ContentService();
            },

            runNoUpload: function () {
                this.run({
                    runDownload: true,
                    runUpload: false
                });
            },

            runNoDownload: function () {
                this.run({
                    runDownload: false,
                    runUpload: true
                });
            },

            runProgram: function () {
                this.run({
                    runDownload: false,
                    runUpload: false
                });
            },

            runAll: function () {
                this.run({
                    runDownload: true,
                    runUpload: true
                });
            },

            run: function (options) {
                var me = this;

                this.loader.show();

                this.nativeEditor.setCommand(this.snippet);
                this.nativeEditor.setActivity(this.activity);
                this.nativeEditor.setExtensionConfig(this.extensionConfig);
                var rule = this.$.download.getRule();
                this.nativeEditor.setDownloadRule(rule);
                rule = this.$.upload.getRule();
                this.nativeEditor.setUploadRule(rule);

                this.nativeEditor.setDebug(true);

                this.nativeEditor.run(options.runDownload, options.runUpload, function (jobDetails) {
                    console.log(jobDetails);
                    me.loader.hide();
                });
            },

            UpdateUI: function (iActivity, iStep, iExtensionConfig) {
                this.activity = iActivity;
                this.step = iStep;
                this.extensionConfig = iExtensionConfig;

                //2, wait for the file chooser SDK are ready
                PolyUtils.whenComponentListReady([this.$.download, this.$.upload]).then(function () {

                    //3. setup activity for content service
                    this.contentService.setActivity(this.activity);

                    //4. set up content service for sdk's
                    this.$.upload.setContentService(this.contentService);
                    this.$.download.setContentService(this.contentService);

                    var upload = this.extensionConfig.getPropertyByName('upload');
                    if (upload) {
                        var val = upload.getValue();
                        if (val && val !== 'undefined') {
                            //5. if you have rule, use setRule to init sdk UI
                            this.$.upload.setRule(this.activity, val);
                        }
                        else {
                            //6. otherwise user 'setModel' to set up default UI
                            this.$.upload.setModel('content', this.activity);
                        }
                    }

                    var download = this.extensionConfig.getPropertyByName('download');
                    if (download) {
                        var val = download.getValue();
                        if (val && val !== 'undefined') {
                            this.$.download.setRule(this.activity, val);
                        }
                        else {
                            this.$.download.setModel('content', this.activity);
                        }
                    }

                }.bind(this));

                var property = this.extensionConfig.getPropertyByName('program');
                if (property) {
                    var val = property.getValue();
                    if (val && val !== 'undefined') {
                        this.snippet = val;
                    }
                }


                console.log('updateUI');
            },

            Apply: function () {
                var program = this.extensionConfig.getPropertyByName('program');
                if (program) {
                    this.extensionConfig.setPropertyValue(program, this.snippet);
                }

                var download = this.extensionConfig.getPropertyByName('download');

                //7. use 'getRule' explicitly to get updatedRule, no data-binding here
                var rule = this.$.download.getRule();
                if (rule && download) {
                    this.extensionConfig.setPropertyValue(download, rule);
                }

                var upload = this.extensionConfig.getPropertyByName('upload');
                rule = this.$.upload.getRule();
                if (upload && rule) {
                    this.extensionConfig.setPropertyValue(upload, rule);
                }

                console.log('Apply');
            },

            logInfo: function (msg) {
                this.set('info.class', 'info');
                this.set('info.message', msg);
            },

            logError: function (msg) {
                this.set('info.class', 'error');
                this.set('info.message', msg);
            }
        });
    });
