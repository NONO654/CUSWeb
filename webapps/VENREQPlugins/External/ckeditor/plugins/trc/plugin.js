CKEDITOR.plugins.add('trc', {
    beforeInit: function(editor) {},
    init: function(editor) {
        // Adding some functionnalities to the String object

        (function() {
            /**
             * This method is added to the String object in order to find the first occurence of a Regexp in a string.
             *
             * @param {Regexp} pattern The Regexp that we are looking for
             * @param {Number} startIndex The start index for the search
             * @returns {Number} The index of the found element, -1 if not found
             */
            String.prototype.regexIndexOf = function(pattern, startIndex) {
                startIndex = startIndex || 0;
                var searchResult = this.substr(startIndex).search(pattern);
                return (-1 === searchResult) ? -1 : searchResult + startIndex;
            };
            /**
             * This method is added to the String object in order to find the last occurence of a Regexp in a string.
             *
             * @param {Regexp} pattern The Regexp that we are looking for
             * @param {Number} startIndex The start index for the search
             * @returns {Number} The index of the found element, -1 if not found
             */
            String.prototype.regexLastIndexOf = function(pattern, startIndex) {
                startIndex = startIndex === undefined ? this.length : startIndex;
                var searchResult = this.substr(0, startIndex).reverse().regexIndexOf(pattern, 0);
                return (-1 === searchResult) ? -1 : this.length - ++searchResult;
            };
            String.prototype.reverse = function() {
                return this.split('').reverse().join('');
            };
        })();

        // Calling the init of the engine object
        //debugger;
        this.engine.init();

        editor.config.enableTabKeyTools = false; // Disabling the tab key inside the editor, in order to enable the plugin's autocomplete feature

        editor.addCommand('showSettingsDialog', new CKEDITOR.dialogCommand('TRC_settings')); // The settings' dialog command
        editor.addCommand('toggleSemanticCheck', { // The plugin initiation command
            exec: function() {
                var engine = CKEDITOR.plugins.get('trc').engine;

                // The command must close the plugin if it is already launched

                if (engine.globals.engine_active) {
                    engine.unloadUI();
                } else {
                    engine.loadUI();
                }
            }
        });
        editor.ui.addButton('TRC_check', {
            label: 'Semantic Check',
            command: 'showSettingsDialog',
            icon: this.engine.globals.path + 'images/settings.png'
        });
        editor.ui.addButton('TRC_toggle', {
            label: 'Semantic Feature Toggle',
            command: 'toggleSemanticCheck',
            icon: this.engine.globals.path + 'images/switch_off.png'
        });
        var jList = jQuery("<ul><li>Coffee</li><li>Tea</li><li>Milk</li></ul>");

        var jEditor = jQuery(editor);

        jEditor.add(jList);

        CKEDITOR.dialog.add('TRC_settings', function() // The settings' dialog
            {
                return {
                    title: 'Semantic tool properties',
                    minWidth: 400,
                    minHeight: 200,
                    contents: [{
                        id: 'general',
                        label: 'Settings',
                        elements: [{
                            type: 'text',
                            id: 'url',
                            label: 'Semantic Server URL',
                            validate: CKEDITOR.dialog.validate.notEmpty('The semantic server must have an URL.'),
                            required: true,
                            'default': CKEDITOR.plugins.get('trc').api.settings.webServiceUrl,
                            commit: function(data) {
                                data.url = this.getValue();
                            }
                        }, {
                            type: 'text',
                            id: 'connection_timeout',
                            label: 'Connection timeout (seconds)',
                            validate: CKEDITOR.dialog.validate.notEmpty('The connection timeout must be set.'),
                            required: true,
                            'default': CKEDITOR.plugins.get('trc').engine.settings.connection_timeout,
                            commit: function(data) {
                                data.connection_timeout = this.getValue();
                            }
                        }]
                    }],
                    onOk: function() {
                        var data = {};
                        this.commitContent(data);
                        CKEDITOR.plugins.get('trc').api.settings.webServiceUrl = data.url;
                        CKEDITOR.plugins.get('trc').engine.settings.connection_timeout = parseInt(data.connection_timeout);
                    }
                };
            });
    },
    engine: { // The plugin's engine object
        /**
         * The engine globals
         * @property {CKEDITOR.editor} editor The CKEDITOR editor object
         * @property {CKEDITOR.document} document The CKEDITOR document object
         * @property {Array<Word_object>} words_detected The array of words detected from the input, as Word_objects
         * @property {String} path The script folder path
         * @property {String} engine_active The engine state indicator, true if semantic checking is active
         */
        globals: {
            editor: null,
            document: null,
            words_detected: null,
            path: null,
            engine_active: false,
            current_word: null,
            last_sentence_assessed: null,
            modifiedStyles: [],
            metricDisplayed: null,
            ckEditorObject: null,
            engineInitialized: false
        },
        /**
         * The engine settings
         * @property {String} engine_name The engine name
         * @property {String} loader_image_name The image used for the loading state
         */
        settings: {
            engine_name: 'trc',
            loader_image_name: 'loading.gif',
            connection_timeout: 30
        },
        /**
         * Inits the CKEDITOR engine object
         * @function
         * @static
         */
        init: function() {
            this.globals.path = CKEDITOR.plugins.getFilePath('trc').substring(0, CKEDITOR.plugins.getFilePath('trc').lastIndexOf('/') + 1); // Getting the path to the plugin folder

            // Retrieving the editor instance and storing it in a global variable

            for (var e in CKEDITOR.instances) {
                var currentInstance = e;
                break;
            }
            this.globals.editor = CKEDITOR.instances[currentInstance];

            jQuery('head').append('<link rel="stylesheet" href="' + this.globals.path + 'style.css" type="text/css" />'); // Adding the stylesheet

            // When the editor is ready, we initiate the plugin's UI

            this.globals.editor.on('instanceReady', function() {
                CKEDITOR.plugins.get('trc').engine.initUI();
            });
        },

        /**
         * Inits the UI, adding the divs
         * @function
         * @static
         */
        initUI: function() {
            debugger;
            this.globals.document = this.globals.editor.document;
            debugger;
            this.globals.ckEditorObject =  jQuery(this.globals.editor.element.$);
            if (this.globals.document === undefined) {
                throw new Error('The engine objects have not been instanciated.');
            }
            // Creating the UI containers using Jquery
            var engine = CKEDITOR.plugins.get('trc').engine;
            //var cke_contents  = jQuery('div.ui-dialog').find('div.cke_contents');
            //var cke_contents  = jQuery(jQuery('.richViewContent')[1]);
            var cke_contents = jQuery(this.globals.editor.element.$);
            //this.globals.ckEditorObject =  jQuery(jQuery('.contentDataEditable')[0]).contents();
            engine.cke_contents = cke_contents;
            var trc_main;
            if (jQuery('#trc_main').length == 0) {
                trc_main = jQuery('<div id="trc_main" class="trc" display="none"></div>');
                trc_main.insertAfter(jQuery('.helpers'))
                    //jQuery('#TRMMainContainer').insertBefore(trc_main);
                    //debugger;
                    //jQuery('<div id="trc_details" class="metricDetails"></div>').insertBefore(trc_main);
                    //jQuery('<div id="trc_suggest" class="trc"></div>').insertBefore(engine.cke_contents);
                jQuery('<div id="trc_suggest" class="trc"></div>').insertBefore(trc_main);
                jQuery('#trc_main').html('<div id="trc_quality"><p>Semantic quality not assessed</p></div><div id="trc_metrics"></div>');

            } else {
                trc_main = jQuery('#trc_main');
            }
            this.uiElements = {
                mainDiv: jQuery('#trc_main'),
                qualityDiv: jQuery('#trc_quality'),
                metricsDiv: jQuery('#trc_metrics'),
                suggestionPanel: jQuery('#trc_suggest')
            };
            this.uiElements.suggestionPanel.html('<ul class="cke_top"></ul>');
            //this.uiElements.mainDiv.height(jQuery('div.cke_contents').height());
            //this.uiElements.metricsDiv.height(jQuery('div.cke_contents').height() - this.uiElements.qualityDiv.height() - 44);
            //this.uiElements.mainDiv.height(engine.cke_contents.height());
            //this.uiElements.metricsDiv.height(engine.cke_contents.height() - this.uiElements.qualityDiv.height() - 44);
            this.uiElements.suggestionPanel.hide();
            this.uiElements.mainDiv.hide();

            // When we resize the editor, we want the plugin's panel to follow

            this.globals.editor.on('resize', function() {
                //engine.uiElements.mainDiv.height(jQuery('div.cke_contents').height());
                //engine.uiElements.metricsDiv.height(jQuery('div.cke_contents').height() - engine.uiElements.qualityDiv.height() - 44);
                engine.uiElements.mainDiv.height(engine.cke_contents.height());
                engine.uiElements.metricsDiv.height(engine.cke_contents.height() - engine.uiElements.qualityDiv.height() - 44);
            });

            // We init the key binding in order to catch the user input

            this.initKeyBinding();
        },
        /**
         * Inits the key binding
         * @function
         * @static
         */
        initKeyBinding: function() {
            /**
             * The key binding is the core of the plugin.
             * We must limit the number of semantic quality checks, because it produces a call and answer to the web service.
             * However, we also want an on-the-fly checking, so here are the rules defining the checking policy.
             * We need to listen to the keyboards events in order to determine when we call the web service to check the semantic quality.
             * Whenever a punctuation mark is pressed, we check the quality (because it is very likely that we are at the end of a sentence).
             * When we change the input from the last check, if we spend one second without pressing any key, we might have finished the input, so we check the quality. 
             */

            var engine = CKEDITOR.plugins.get('trc').engine;
            var api = CKEDITOR.plugins.get('trc').api;

            var dropdown = CKEDITOR.plugins.get('trc').dropdown; // The suggestions dropdown

            this.globals.document.on("keydown", function(event) {
                if (engine.globals.engine_active) {
                    if (event.data.getKey() === 9) // The tab key is pressed
                    {
                        event.data.preventDefault(true);
                        if (engine.uiElements.suggestionPanel.is(":visible")) {
                            dropdown.autocomplete(); // Autocompleting the input
                            engine.globals.document.getBody().focus(); // The autocompletion looses the focus, so we need to fix it
                        }
                    } else if (event.data.getKey() === 40) // The down arrow is pressed, we scroll through the suggestions downward
                    {
                        dropdown.focusNext();
                        event.data.preventDefault(true);
                    } else if (event.data.getKey() === 38) // The up arrow is pressed, we scroll through the suggestions upward
                    {
                        dropdown.focusPrevious();
                        event.data.preventDefault(true);
                    }
                }
            });
            this.globals.document.on("keyup", function(event) {
                if (engine.globals.engine_active) {
                    var listKeys = new Array(32, 110, 13, 113, 188, 2228414, 2228412); // These values represent the dot, the spacebar, the comma, and all other punctuation mark,
                    //var current_text = engine.globals.ckEditorObject.context.getText(); 
                    var current_text = engine.globals.ckEditorObject.contents().text();
                    //engine.globals.document.getBody().getText();

                    if (listKeys.indexOf(event.data.getKeystroke()) !== -1) {
                        if (current_text.trim() !== engine.globals.last_sentence_assessed) {
                            (function() {
                                debugger;
                                var par = new Array();
                                var pattern = new Array();
                                var t = CKEDITOR.plugins.get('trc').t;
                                pattern.push(t.patternName);
                                pattern.push(t.patternCode);
                                par.push(new Array('sessionId', api.globals.sessionId));
                                par.push(new Array('headerText', 'header'));
                                //                                par.push(new Array('Name', api.Name));
                                par.push(new Array('description', current_text));
                                par.push(new Array('descriptionText', current_text));
                                par.push(new Array('selectedAuthoringPatternGroup', pattern));
                                api.call('AuthorText', par, api.callbacks.onAuthorTextSuccess);
                            })();
                            engine.globals.last_sentence_assessed = current_text.trim();
                        }
                        engine.uiElements.suggestionPanel.hide();
                    } else if (event.data.getKey() !== 40 && event.data.getKey() !== 38) {

                        // The timer to check the quality

                        clearTimeout(engine.suggestTimeout);
                        engine.suggestTimeout = setTimeout(function() {
                            if (current_text.trim() !== engine.globals.last_sentence_assessed) {
                                (function() {
                                    var t = CKEDITOR.plugins.get('trc').t;
                                    var par = new Array();
                                    par.push(new Array('sessionId', api.globals.sessionId));
                                    par.push(new Array('headerText', 'header'));
                                    //par.push(new Array('Name', api.Name));
                                    par.push(new Array('text', current_text));
                                    par.push(new Array('description', [t.patternName, t.patternCode]));
                                    par.push(new Array('descriptionText', current_text));
                                    api.call('AuthorText', par, api.callbacks.onAuthorTextSuccess);
                                })();
                                engine.globals.last_sentence_assessed = current_text.trim();
                            }
                        }, 1000);
                        dropdown.followCaretPosition();

                        // Retrieving the currently typed word, in order to produce the autocomplete suggestions by calling a function of the web service

                        (function() {
                            var temp_new_input = '';
                            var range = engine.globals.editor.getSelection().getRanges()[0];
                            var position = range.startOffset - 1;
                            var current_input = range.startContainer.getText();
                            var text_before = current_input.substring(0, position + 1);
                            var text_after = current_input.substring(position + 1);
                            var index_start = text_before.regexLastIndexOf(/[\W]/, current_input.length) + 1;
                            var index_end = text_after.regexIndexOf(/[\W]/, 0);
                            if (index_end === -1) {
                                temp_new_input = text_before.substring(index_start, position + 1) + text_after;
                            } else {
                                temp_new_input = text_before.substring(index_start, position + 1) + text_after.substring(0, index_end);
                            }
                            engine.globals.current_word = temp_new_input;
                            dropdown.setContent(engine.globals.current_word);
                        })();
                        if (engine.globals.current_word.length === 1) {
                            // A new word has began
                            (function() {
                                var par = new Array();
                                par.push(new Array('sessionId', api.globals.sessionId));
                                par.push(new Array('currentWordText', engine.globals.current_word));
                                api.call('GetPossibilitiesForNextSlot', par, api.callbacks.onGetPossibilitiesForNextSlotSuccess);
                            })();
                            engine.uiElements.suggestionPanel.find('ul').html('<li>Waiting for server\'s suggestions...</li>');
                            engine.uiElements.suggestionPanel.show();
                        }

                    }
                }
            });
        },
        /**
         * Displays the loading state, and attemps to connect to the api
         * @function
         * @static
         */
        loadUI: function() {
            var api = CKEDITOR.plugins.get('trc').api;

            this.globals.engine_active = true;
            //this.globals.editor.setReadOnly(true);
            jQuery('.cke_button__trc_toggle_icon').css('background-image', 'url(' + this.globals.path + 'images/loading.gif)');
            api.call('Connect', new Array('user', api.settings.user), api.callbacks.onConnectSuccess);
        },
        /**
         * Displays the unloading state, and attemps to disconnect from the api
         * @function
         * @static
         */
        unloadUI: function() {
            var api = CKEDITOR.plugins.get('trc').api;
            var engine = CKEDITOR.plugins.get('trc').engine;
            this.globals.engine_active = false;
            this.uiElements.mainDiv.hide();
            this.uiElements.metricsDiv.find('ul').empty();
            engine.cke_contents.width("100%");
            jQuery('.cke_button__trc_toggle').removeClass('cke_button_on');
            jQuery('.cke_button__trc_toggle').addClass('cke_button_off');
            jQuery('.cke_button__trc_toggle_icon').css('backgroundImage', 'url(' + this.globals.path + 'images/switch_off.png)');

            api.call('Disconnect', new Array('sessionId', api.globals.sessionId), api.callbacks.onDisconnectSuccess);
        },
        /**
         * Triggered when the semantic server responds, it changes the UI to the active state
         * @function
         * @static
         */
        onSemanticServerReady: function() {
            /**************/
            debugger;
            var engine = CKEDITOR.plugins.get('trc').engine;
            jQuery('.cke_button__trc_toggle').removeClass('cke_button_off');
            jQuery('.cke_button__trc_toggle').addClass('cke_button_on');
            // jQuery('.cke_button__trc_toggle_icon').css('backgroundImage', 'url(' + this.globals.path + 'images/switch_on.png)');
            //var current_text = engine.globals.ckEditorObject.context.getText();
            var current_text = engine.globals.ckEditorObject.contents().text();
            //engine.globals.document.getBody().getText();
            if (current_text != null && current_text.length != 0) {
                //debugger;
                var api = CKEDITOR.plugins.get('trc').api;
                var par = new Array();
                var pattern = new Array();
                var t = CKEDITOR.plugins.get('trc').t;
                pattern.push(t.patternName);
                pattern.push(t.patternCode);
                par.push(new Array('sessionId', api.globals.sessionId));
                par.push(new Array('headerText', 'header'));
                par.push(new Array('description', current_text));
                par.push(new Array('descriptionText', current_text));
                par.push(new Array('selectedAuthoringPatternGroup', pattern));
                api.call('AuthorText', par, api.callbacks.onAuthorTextSuccess);
                //api.call('AuthorText', par, api.callbacks.onAuthorTextSuccess);
            }
        },
        /**
         * Scans the input and gives an id to each word. Fills the globals.words_detected array
         * @function
         * @static
         */
        findWords: function() {
            var engine = CKEDITOR.plugins.get('trc').engine;
            engine.globals.words_detected = new Array();
            var boldObjects;
            var italicObjects;
            var innerText;
            var id = 1;
            debugger;
            engine.globals.ckEditorObject.find('.word').contents().unwrap();
            engine.globals.ckEditorObject.each(function(index, item) {
                innerText = jQuery(item).text().match(/[a-zA-Z']+/g);
                var paragraph = jQuery(item).html();
                paragraph = paragraph.replace(/[a-zA-Z']+/g, function(match) {
                    var word;
                    if (innerText != null && innerText.indexOf(match) >= 0) {
                        //the match object is a text object
                        word = '<span id="word' + id++ + '" class="word">' + match + '</span>';
                    } else {
                        word = match;
                    }
                    return (word);
                });
                jQuery(item).html(paragraph);
            });
            for (var i = 1; i < id; i++) {
                engine.globals.words_detected.push(new engine.Word_object(i));
            }
        },
        tooltipFields: [
            'MetricName',
            'Quality',
            'FeaturesAsString',
            'AffectsOverallQuality',
            'Summary',
            'Description'
            //'ranges'
        ],
        createToolTip: function(item) {
            var engine = CKEDITOR.plugins.get('trc').engine;
            var metricDiv = jQuery('<div>');
            var header = jQuery('<div>');
            header.addClass('metricHeader');
            var button = jQuery('<button >')
                //button.attr('src','TraceableRequirements/External/ckeditor/plugins/trc/buttonDialogCancel.gif');
            button.attr('value', 'Close');
            button.text('Back');
            button.attr('align', 'right');
            button.attr('id', 'trcClosebutton');
            button.addClass('cancelEvent btn btn-default');
            button.bind('click', function() {
                //debugger;
                jQuery(".metricDetails").empty();
                jQuery(".metricDetails").slideUp();
                engine.globals.metricDisplayed = null;
                var rtf = item.MetricRtf;
                if (rtf !== '' || item.FeaturesAsString !== '') {
                    var word = item.FeaturesAsString.split(':')[0];
                    engine.findWords();
                    engine.globals.words_detected.forEach(function(value, index, array, word) {
                        //debugger;
                        var word = item.FeaturesAsString.split(':')[0]
                        var rtfWord = value.getHtml().toLowerCase();
                        //var isBold = value.getAttribute('isBold');

                        if (rtfWord == word.toLowerCase()) {
                            engine.globals.modifiedStyles.push(value.getAttribute('style'))
                                //debugger;
                            var style = 'color: black;';
                            //value.setAttribute('style', 'color: red; font-weight: bold;');
                            value.setAttribute('style', style);
                        }
                    });
                }
            });
            header.append(button);

            var tooltip = jQuery('<div>');
            //tooltip.height(jQuery('#trc_main').height()-30);
            tooltip.addClass('advanced_tooltip');
            var tooltipFields = CKEDITOR.plugins.get('trc').engine.tooltipFields;
            tooltipFields.forEach(function(entry) {
                    var field = item[entry];
                    var title = '';
                    var paragraph = jQuery('<p>');
                    switch (entry) {
                        case 'MetricName':
                            title = '<b>Metric</b><br>';
                            break;
                        case 'FeaturesAsString':
                            title = '<b>Concepts found</b><br>';
                            break;
                        case 'AffectsOverallQuality':
                            title = '<b>Mandatory</b><br>';
                            break;
                        case 'Description':
                            title = '<b>Recomendation</b><br>';
                            break;
                        default:
                            title = '<b>' + entry + ': </b><br>';
                            break;
                    }
                    paragraph.append(jQuery(title));
                    if (entry == 'FeaturesAsString') {
                        var contentText = item[entry];
                        if (contentText.length > 0) {
                            var words = contentText.split(";");
                            words.forEach(function(value, index, array) {
                                if (value.length != 0) {
                                    //debugger;
                                    paragraph.append(value);
                                    if (index != (array.length - 1)) {
                                        paragraph.append('<br>');
                                    }
                                }
                            });
                        } else {
                            paragraph.append('None<br>');
                        }

                    } else {
                        var contentText = item[entry];
                        paragraph.append(contentText);
                    }
                    tooltip.append(paragraph);
                })
                //tooltip.hide();
            tooltip.height(jQuery('#trc_metrics').height() - 24);
            tooltip.width(jQuery('#trc_metrics').width());
            metricDiv.append(header);
            metricDiv.append(tooltip);

            return metricDiv;
        },
        setTooltipOffset: function(toolTip, mousex, mousey) {
            var tooltipHeight = toolTip.height();
            if ((mousey + tooltipHeight) > jQuery('.cke_wysiwyg_frame').height()) {

                toolTip.css({
                    top: mousey - tooltipHeight
                })

            } else {
                toolTip.css({
                    top: mousey
                })

            }
        },
        /**
         * Fills the metrics div
         * @param {api.qualityResult.value} metricsQuality The object containing all the metrics information
         * @function
         * @static
         */
        fillMetricsOnError: function(metricsQuality) {
            var engine = CKEDITOR.plugins.get('trc').engine;
            var api = CKEDITOR.plugins.get('trc').api;
            var table;
            //debugger;
            if (jQuery('.metric_table').length > 0) {
                table = jQuery('.metric_table');
                jQuery(table.find('tbody')).empty();
            } else {
                table = jQuery('<table>')
                table.addClass('metric_table');
                table.attr('id', 'semantic_table');
                table.append('<tr>');
            }

            //var header = '<th>  </th><th>  </th><th>Metric</th><th>Value</th>';
            var header = '<th>  </th><th>Metric</th><th>Quality</th>';
            var table_content = table.find('tbody');
            table.find('tr').append(jQuery.parseHTML(header));
            this.uiElements.metricsDiv.empty();


            jQuery(metricsQuality).each(function(index, item) {
                /*  find the correct metric to refresh*/
                /*******************************************************************************/
                if (jQuery('.metricDetails').is(':visible') == true) {
                    var metricDisplayed = engine.globals.metricDisplayed;
                    //need to refresh the current object
                    if (metricDisplayed.MetricName == item.MetricName &&
                        JSON.stringify(metricDisplayed) !== JSON.stringify(item)) {
                        //debugger;
                        engine.globals.metricDisplayed = item;
                        jQuery(".metricDetails").slideUp();
                        jQuery('.metricDetails').empty();
                        jQuery(".metricDetails").append(engine.createToolTip(item));
                        jQuery(".metricDetails").slideDown();
                        /*********************************************
                    	
                         *     refresh metric_table !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                         *     
                         *     
                         *     
                         *     
                         *     
                         *     
                         *     
                         *     
                         *     
                         *     
                         *     
                         *     
                         *     
                         *     
                         *     
                         *     
                         *
                         *
                         *************************************/
                    }
                }
                if (item.Description !== '') {
                    itemFormated = jQuery('<div>');
                    itemFormated.addClass('trc_metric');
                    itemTitle = jQuery('<div>');
                    itemTitle.addClass('trc_metric_title');
                    itemDescription = jQuery('<tr>');
                    //itemDescription = jQuery('<div>');
                    itemDescription.addClass('trc_metric_description');
                    itemDescription.attr('id', 'description' + index);
                    var titleContent = '';
                    var Quality = '';
                    switch (item.QualityLevel) {
                        case '1':
                            titleContent += '<img title="high quality" src="' + engine.globals.path + '/images/high_quality_warning.png">';
                            Quality = 'High';
                            break;
                        case '2':
                            titleContent += '<img title="medium quality" src="' + engine.globals.path + '/images/medium_quality_warning.png">';
                            Quality = 'Medium';
                            break;
                        case '3':
                            titleContent += '<img title="low quality" src="' + engine.globals.path + '/images/low_quality_warning.png">';
                            Quality = 'Low';
                            break;
                    }
                    var row = '<tr>';
                    //row+='<td id=\"expandCell\" index=\"'+index+'\"><img src=\"../common/images/utilTreeLineNodeClosedSB.gif\"></td>';
                    row += '<td>' + titleContent + '</td>';
                    row += '<td id=\"MetricName\">' + item.MetricName + '</td>';
                    row += '<td>' + Quality + '</td>'
                        //var htmlRow = jQuery.parseHTML(row);
                    var htmlRow = jQuery(row);;
                    table_content.append(htmlRow);


                    //var tooltip = engine.createToolTip(item); 
                    //table_content.append(jQuery(tooltip));



                    /* htmlRow.find('td#expandCell').click(function() {
                    	var tableIndex = jQuery(this).attr("index");
                    	if (table.find('#description'+index).is(':visible'))
                    	{
                    		table.find('#description'+index).hide();
                        }
                        else
                        {
                        	table.find('#description'+index).show();
                        }
                    });
*/
                    htmlRow.find('#MetricName').hover(function() {
                        jQuery(this).css('cursor', 'pointer');
                    }, function() {
                        jQuery(this).css('cursor', 'defaut');
                    });
                    htmlRow.find('#MetricName').click(function() {
                        debugger;
                        var position = jQuery('#trc_main').offset();
                        jQuery(".metricDetails").css({
                            top: jQuery('#trc_metrics').position().top,
                            left: jQuery('#trc_metrics').position().left
                        });
                        //jQuery(".metricDetails").height(jQuery('#trc_metrics').height());
                        //jQuery(".metricDetails").width(jQuery('#trc_metrics').width());
                        jQuery(".metricDetails").append(engine.createToolTip(item));
                        jQuery(".metricDetails").zIndex(1000000);
                        jQuery(".metricDetails").slideDown();

                        /************************
                         * hightlight the words to change
                         ************************/

                        var rtf = item.MetricRtf;
                        engine.globals.metricDisplayed = item;
                        //debugger;
                        if (rtf !== '' || item.FeaturesAsString !== '') {

                            engine.findWords();
                            engine.globals.words_detected.forEach(function(value, index, array, word) {
                                value.index = index;
                                var wordslist = item.FeaturesAsString.split(/:|;|,/);
                                wordslist.forEach(function(element) {
                                    //debugger;
                                    var word = element.replace(/\(x[0-9]\)/, '') /*.replace('(','').replace(')','')*/ ;
                                    var wordLength = word.split(/\s+/).length;
                                    var rtfWord = value.getHtml().toLowerCase();
                                    if (wordLength == 1) {
                                        if (rtfWord.contains(word.toLowerCase()) && word.length > 0) {
                                            value.setAttribute('style', 'color: red;');
                                        }
                                    } else {
                                        var avoidedWords = word.split(/\s+/);
                                        /*                            			engine.globals.words_detected.forEach(function(value,index,array,word){
                                                                    				value.get
                                                                    			}*/

                                        if (rtfWord.contains(avoidedWords[0].toLowerCase()) && word.length > 0) {
                                            var wordsFound = 1;
                                            debugger;
                                            var unwrapWordTag = jQuery(engine.globals.words_detected.slice(0));
                                        }
                                        //find these words in string
                                    }
                                });
                            });
                        }
                    });
                    titleContent += '<span>' + item.Summary + '</span>';
                    itemTitle.html(titleContent);
                    itemDescription.html('<td></td><td></td><td><div>' + item.Description + '</div></td>');
                    jQuery(itemDescription).hide();
                    jQuery(itemFormated).bind('mouseleave', function() {
                        engine.findWords();
                    });
                    jQuery(itemFormated).click(function() {
                        if (jQuery(this).find('.trc_metric_description').is(':visible')) {
                            jQuery(this).find('.trc_metric_description').hide();
                        } else {
                            var p = jQuery(this).offset();
                            p.top += 20;
                            jQuery(this).find('.trc_metric_description').toggle().offset(p);
                            jQuery(this).find('.trc_metric_description').show();
                        }
                    });

                    /*************/
                    table_content.append(itemDescription);
                    /************/
                    engine.uiElements.metricsDiv.append(table);

                }
            });

            //var height = jQuery('.metric_table').height();
            //jQuery('#trc_metrics').height(500);
            jQuery('#TRMMainContainer');
            jQuery('#trc_main').css('z-index', '100000000');
            //jQuery('#trc_main').width(300);
            //jQuery('#trc_main').height(500);
            jQuery('#trc_main').attr('title', 'Semantic Assessment');
            
            jQuery('#trc_main').show();
            jQuery('#trc_suggest').hide();

            //jQuery('#trc_main').show();
            /*jQuery('#trc_main').dialog({
                position: ['right', 'top'],
                width: '300px',
                height: '500px',
                draggable: true,
                resizable: false,
                modal: false,
                autoOpen: true,
                close: function() {
                    //debugger;
                    //gsdpgbhgkp^hgp^bhffg!:,tj::,;:,;
                }

            });*/
            var trc_details = jQuery('#trc_details');
            if (trc_details.length == 0) {
                jQuery('<div id="trc_details" class="metricDetails"></div>').insertBefore(jQuery('#trc_metrics'));
            }
        },
        /**
         * Displays a graphicall indicator for the quality status
         * @param {String} status The quality status that will be displayed
         * @function
         * @static
         */
        setQualityStatus: function(status) {
            var engine = CKEDITOR.plugins.get('trc').engine;

            engine.uiElements.qualityDiv.removeClass();
            switch (status) {
                case '1':
                    engine.uiElements.qualityDiv.addClass('trc_quality_high');
                    engine.uiElements.qualityDiv.find('p').html('High Quality');
                    break;
                case '2':
                    engine.uiElements.qualityDiv.addClass('trc_quality_medium');
                    engine.uiElements.qualityDiv.find('p').html('Medium Quality');
                    break;
                case '3':
                    engine.uiElements.qualityDiv.addClass('trc_quality_low');
                    engine.uiElements.qualityDiv.find('p').html('Low Quality');
                    break;
            }
            engine.uiElements.qualityDiv.find('p').css('color', 'white');
        },
        showSuggestionMenu: function(content) {
            var engine = CKEDITOR.plugins.get('trc').engine;
            var dropdown = CKEDITOR.plugins.get('trc').dropdown;

            if (content.length === 0) {
                engine.uiElements.suggestionPanel.hide();
            } else {
                dropdown.dictionary = content;
                dropdown.setContent(engine.globals.current_word);
            }
        },
        /**
         * The object wrapping every typed word
         * @class Word_object
         * @memberOf engine
         * @param {Number} id The id of the word
         */
        Word_object: function(id) {
            var engine = CKEDITOR.plugins.get('trc').engine;

            /**
             * The word's id
             * @memberOf Word_object
             * @type Number
             * @name id
             */
            this.id = id;
            /**
             * The Jquery word element
             * @memberOf Word_object
             * @type Jquery.element
             * @name element
             */
            this.element = engine.cke_contents.find('#word' + id)
                //engine.globals.document.getById('word' + id);
                /**
                 * Gets the word's id
                 * @function
                 * @name getId
                 * @memberOf Word_object
                 * @returns {Number} The word's id
                 */
                //this.isBold = engine.globals.document.getById('word' + id).getAttribute('isBold');



            this.getId = function() {
                return this.id;
            };
            /**
             * Gets the word's html content
             * @function
             * @name getHtml
             * @memberOf Word_object
             * @returns {String} The word's html content
             */
            this.getHtml = function() {
                return (this.element.text());
            };
            /**
             * Sets the word's html content
             * @function
             * @name setHtml
             * @memberOf Word_object
             * @param {String} html The html content
             */
            this.setHtml = function(html) {
                debugger;
                //this.element.setHtml(html);
                this.element.html(html);
            };
            /**
             * Sets a word's attribute
             * @function
             * @name setAttribute
             * @memberOf Word_object
             * @param {String} attribute The attribute's name
             * @param {String} value The attribute's value
             */
            this.setAttribute = function(attribute, value) {
                //this.element.setAttribute(attribute, value);
                this.element.attr(attribute, value);
            };
            /**
             * Gets a word's attribute's value
             * @function
             * @name getAttribute
             * @memberOf Word_object
             * @param {String} attribute The attribute's name
             * @returns {String} The word's attribute's value
             */
            this.getAttribute = function(attribute) {
                return (this.element.attr(attribute));
            };
        }
    },
    dropdown: {
        dictionary: [],
        autocomplete: function() {
            var engine = CKEDITOR.plugins.get('trc').engine;

            var suggestion = engine.uiElements.suggestionPanel.find("li.active").html();
            var regExp = new RegExp("^" + engine.globals.current_word, "g");
            suggestion = suggestion.replace(regExp, '');
            engine.globals.editor.insertText(suggestion + " ");
            engine.uiElements.suggestionPanel.hide();
        },
        followCaretPosition: function() {
            var engine = CKEDITOR.plugins.get('trc').engine;

            var temp_element = CKEDITOR.dom.element.createFromHtml('<span></span>');
            var range = engine.globals.editor.getSelection().getRanges()[0];
            range.insertNode(temp_element);
            var pos = jQuery(temp_element.$).position();
            temp_element.remove();
            //pos.left = pos.left + jQuery('div.cke_contents').position().left;
            //pos.top = pos.top + jQuery('div.cke_contents').position().top + 20;
            pos.left = pos.left + engine.cke_contents.position().left;
            pos.top = pos.top + engine.cke_contents.position().top + 20;
            engine.uiElements.suggestionPanel.css({
                top: pos.top,
                left: pos.left
            });
            engine.uiElements.suggestionPanel.css('max-height', jQuery('div.cke').offset().top + jQuery('div.cke').height() - pos.top);
        },
        focusNext: function() {
            var engine = CKEDITOR.plugins.get('trc').engine;

            var old_active = engine.uiElements.suggestionPanel.find("li.active");
            if (old_active.next().length !== 0) {
                old_active.removeClass("active");
                old_active.next().addClass("active");
            }
        },
        focusPrevious: function() {
            var engine = CKEDITOR.plugins.get('trc').engine;

            var old_active = engine.uiElements.suggestionPanel.find("li.active");
            if (old_active.prev().length !== 0) {
                old_active.removeClass("active");
                old_active.prev().addClass("active");
            }
        },
        setContent: function(content) {
            var engine = CKEDITOR.plugins.get('trc').engine;
            var dropdown = CKEDITOR.plugins.get('trc').dropdown;

            if (dropdown.dictionary.length !== 0) {
                engine.uiElements.suggestionPanel.find("ul").empty();
                reg = new RegExp("^" + content, 'g');
                var result = dropdown.dictionary.filter(function(item) {
                    return (item.match(reg));
                });
                result.forEach(function(item) {
                    engine.uiElements.suggestionPanel.find("ul").append('<li class="cke_button">' + item + '</li>');
                    engine.uiElements.suggestionPanel.find("li").last().click(function(e) {
                        engine.uiElements.suggestionPanel.find("li.active").removeClass("active");
                        jQuery(e.currentTarget).addClass("active");
                        dropdown.autocomplete();
                    });
                });
                engine.uiElements.suggestionPanel.find("li").first().addClass("active");
                if (engine.uiElements.suggestionPanel.find("li").length === 0) {
                    engine.uiElements.suggestionPanel.hide();
                }
            }
        }
    },
    api: {
        settings: {
            webServiceUrl: 'http://d1014eno:8085/ratapi.asmx',
            user: 'DSONE\\T94'
        },
        globals: {
            sessionId: ''
        },
        call: function(method, params, successCallbackFunction, failureCallbackFunction, httpFailureCallbackFunction) {
            var xmlhttp = new XMLHttpRequest();
            xmlhttp.open('POST', this.settings.webServiceUrl, true);
            // build SOAP request
            var sr =
                '<?xml version="1.0" encoding="utf-8"?>' +
                '<soap:Envelope ' +
                'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
                'xmlns:api="http://127.0.0.1/Integrics/Enswitch/API" ' +
                'xmlns:xsd="http://www.w3.org/2001/XMLSchema" ' +
                'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<soap:Body><' + method + ' xmlns="http://www.reusecompany.com/requirements-authoring-tool/">' +
                this.buildRequestParams(params) +
                '</' + method + '>' +
                '</soap:Body>' +
                '</soap:Envelope>';
            xmlhttp.onreadystatechange = function() {
                if (xmlhttp.readyState === 4) {
                    if (xmlhttp.status === 200) {
                        var response = jQuery(jQuery.parseXML(xmlhttp.response));
                        var trueOrNot = 'true';
                        if (response.find('Success').text() === trueOrNot) {
                            try {
                                successCallbackFunction(response);
                            } catch (error) {
                                if (error.message === 'successCallbackFunction is not a function') {
                                    console.info('Ckeditor semantic engine : The success callback function has been called for the "' + method + '" method, but had not been defined.');
                                }
                            }
                        } else {
                            try {
                            	 api.call('Disconnect', new Array('sessionId', api.globals.sessionId), api.callbacks.onDisconnectSuccess);
                                //failureCallbackFunction(response);
                            } catch (error) {
                                if (error.message === 'failureCallbackFunction is not a function') {
                                    console.info('Ckeditor semantic engine : The failure callback function has been called for the "' + method + '" method, but had not been defined.');
                                }
                            }
                        }
                    } else {
                        try {
                        	 api.call('Disconnect', new Array('sessionId', api.globals.sessionId), api.callbacks.onDisconnectSuccess);
                            //httpFailureCallbackFunction(xmlhttp.status);
                        } catch (error) {
                            if (error.message === 'httpFailureCallbackFunction is not a function') {
                                console.info('Ckeditor semantic engine : The http failure callback function has been called for the "' + method + '" method, but had not been defined.');
                            }
                        }
                    }
                }
            };
            // Send the POST request

            xmlhttp.setRequestHeader('Content-Type', 'text/xml');
            xmlhttp.send(sr);
        },
        buildRequestParams: function(params) {
            if (params instanceof Array) {
                if (!(params[0] instanceof Array)) {

                    if ((params[1] instanceof Array)) {
                        var ret = '';
                        ret += this.buildRequestParams(params[1]);
                        return ('<' + params[0] + '>' + ret + '</' + params[0] + '>');
                    } else {
                        return ('<' + params[0] + '>' + this.buildRequestParams(params[1]) + '</' + params[0] + '>');
                    }

                } else {
                    var ret = '';
                    for (var i = 0; i < params.length; i++) {
                        ret += this.buildRequestParams(params[i]);
                    }
                    return ret;
                }
            } else {
                return params;
            }
        },
        getWordOnErrorFromRtf: function(rtf) {
            var wordArray = new Array();
            var match = rtf.match(/\\cf1\\b\s[\w']*\\cf0\\b0/g);
            if (match !== null) {
                match.forEach(function(item) {
                    item = item.replace(/\\cf1\\b\s/g, '');
                    item = item.replace(/\\cf0\\b0/g, '');
                    wordArray.push(item);
                });
            }
            return wordArray;
        },
        callbacks: {
            onConnectSuccess: function(response) {
                var engine = CKEDITOR.plugins.get('trc').engine;
                var api = CKEDITOR.plugins.get('trc').api;
                var t = CKEDITOR.plugins.get('trc').t;
                if (engine.globals.engine_active) {
                    api.globals.sessionId = response.find('SessionId').first().text();
                    (function() {


                        var par = new Array();
                        par.push(new Array('sessionId', api.globals.sessionId));
                        par.push(new Array('rms', t.rms));
                        par.push(new Array('rmsLogin', t.rmsLogin));
                        par.push(new Array('databaseServer', t.repositoryServer));
                        par.push(new Array('databaseName', t.dataBaseName));
                        par.push(new Array('projectLocation', t.projectInternalCode));
                        par.push(new Array('projectName', 'TEST'));
                        par.push(new Array('projectCode', t.projectInternalCode));
                        api.call('InitProject', par, api.callbacks.onInitProjectSuccess);

                    })();
                    //engine.onSemanticServerReady();
                }
            },
            onInitProjectSuccess: function(response) {
                var engine = CKEDITOR.plugins.get('trc').engine;
                var api = CKEDITOR.plugins.get('trc').api;
                var t = CKEDITOR.plugins.get('trc').t;
                //api.globals.sessionId = response.find('SessionId').first().text();
                var par = new Array();
                par.push(new Array('sessionId', api.globals.sessionId));
                par.push(new Array('blockCode', 'none'));
                par.push(new Array('blockName', 'none'));
                par.push(new Array('blockLocation', 'none'));
                par.push(new Array('blockDescription', 'none'));
                par.push(new Array('blockUrl', 'none'));
                api.call('InitBlock', par, api.callbacks.onInitBlockSuccess);
            },
            onInitBlockSuccess: function(response) {
                var engine = CKEDITOR.plugins.get('trc').engine;
                var api = CKEDITOR.plugins.get('trc').api;
                var t = CKEDITOR.plugins.get('trc').t;
                var par = new Array();
                par.push(new Array('sessionId', api.globals.sessionId));
                par.push(new Array('absoluteNumber', t.absoluteNumber));
                par.push(new Array('header', t.header));
                par.push(new Array('description', t.description));
                par.push(new Array('url', t.url));
                par.push(new Array('authorName', t.authorName));
                par.push(new Array('userName', t.userName));
                par.push(new Array('creationDate', t.creationDate));
                par.push(new Array('lastModificationDate', t.lastModificationDate));
                par.push(new Array('lastModificationUser', t.lastModificationUser));
                par.push(new Array('level', t.level));
                par.push(new Array('code', t.code));
                par.push(new Array('traces', t.traces));
                par.push(new Array('versionCount', t.versionCount));
                par.push(new Array('numOleObjects', t.numOleObjects));
                par.push(new Array('moduleVolatilityCount', t.moduleVolatilityCount));
                par.push(new Array('authorEmailAddress', t.authorEmailAddress));
                par.push(new Array('attrs', t.attrs));
                api.call('InitRequirement', par, api.callbacks.onInitRequiremetSuccess);
            },
            onInitRequiremetSuccess: function(response) {
                var engine = CKEDITOR.plugins.get('trc').engine;
                var api = CKEDITOR.plugins.get('trc').api;
                var t = CKEDITOR.plugins.get('trc').t;
                var par = new Array();
                par.push(new Array('sessionId', api.globals.sessionId));
                api.call('HasBlockMetrics', par, api.callbacks.onCheckBlockMetricsSuccess);
            },
            onCheckBlockMetricsSuccess: function(response) {
                var api = CKEDITOR.plugins.get('trc').api;
                var par = new Array();
                var result = response.find('Result').text();
                par.push(new Array('sessionId', api.globals.sessionId));
                if (result == 'true') {
                    api.call('GetPatternGroups', par, api.callbacks.onInitSuccess);
                } else {
                    api.call('GetDefaultBlockId', par, api.callbacks.onBlockIdSuccess);
                }
            },
            onBlockIdSuccess: function(response) {
                var engine = CKEDITOR.plugins.get('trc').engine;
                var api = CKEDITOR.plugins.get('trc').api;
                var t = CKEDITOR.plugins.get('trc').t;
                var par = new Array();
                var blockId = response.find("DefaultBlockId").text();
                t.blockId = blockId;
                par.push(new Array('sessionId', api.globals.sessionId));
                par.push(new Array('metricsSetId', blockId));
                api.call('SetDefaultMetricsForBlock', par, api.callbacks.onSetMDefaultMetricsSuccess);
            },
            onSetMDefaultMetricsSuccess: function(response) {
                var engine = CKEDITOR.plugins.get('trc').engine;
                var api = CKEDITOR.plugins.get('trc').api;
                var t = CKEDITOR.plugins.get('trc').t;
                var par = new Array();
                par.push(new Array('sessionId', api.globals.sessionId));
                api.call('GetPatternGroups', par, api.callbacks.onInitSuccess);
            },
            onInitSuccess: function(response) {
                //debugger;
                var t = CKEDITOR.plugins.get('trc').t;
                var arrayName = new Array();
                var arrayCode = new Array();
                var patternName = response.find("AuthoringPatternGroup").children('name').get(0).textContent;
                arrayName.push('Name');
                arrayName.push(patternName);
                var patternCode = response.find("AuthoringPatternGroup").children('code').get(0).textContent;
                arrayCode.push('Code');
                arrayCode.push(patternCode);
                t.patternName = arrayName;
                t.patternCode = arrayCode;
                var engine = CKEDITOR.plugins.get('trc').engine;
                engine.onSemanticServerReady(response);
            },
            onDisconnectSuccess: function(response) {
                var api = CKEDITOR.plugins.get('trc').api;

                api.globals.sessionId = '';
            },
            onAuthorTextSuccess: function(response) {
                debugger;
                var engine = CKEDITOR.plugins.get('trc').engine;
                var api = CKEDITOR.plugins.get('trc').api;
                var dropdown = CKEDITOR.plugins.get('trc').dropdown;
                //debugger;

                if (!jQuery('.cke_button__trc_toggle_icon').css('backgroundImage').contains('switch_on.png')) {
                    jQuery('.cke_button__trc_toggle_icon').css('backgroundImage', 'url(' + engine.globals.path + 'images/switch_on.png)');
                }

                // Analysing the response

                var result = null;

                (function() {
                    result = {

                        MatchingState: response.find('MatchingState').first().text(),
                        MatchedPath: response.find('MatchedPath').first().text(),
                        MatchedPatterns: new Array(),
                        MatchingPatterns: new Array(),
                        NextPossibleElements: new Array(),
                        GlobalQualityId: response.find('GlobalQualityId').first().text(),
                        FeaturesByMetric: new Array(),
                        Misspelling: new Array()

                    };

                    response.find('MatchedPattern').each(function() {
                        result.MatchedPatterns.push({
                            PatternRestrictions: jQuery(this).find('PatternRestrictions').first().text()
                        });
                    });

                    response.find('MatchingPattern ').each(function() {
                        result.MatchingPatterns.push({
                            MatchingPattern: jQuery(this).find('MatchingPattern').first().text()
                        });
                    });

                    response.find('PossibleElement').each(function() {
                        result.NextPossibleElements.push({
                            Pattern: jQuery(this).find('Pattern').first().text(),
                            MatchedPath: jQuery(this).find('MatchedPath').first().text(),
                            NextValidRestriction: jQuery(this).find('NextValidRestriction').first().text(),
                            RestOfShortestPathForSelectedPattern: jQuery(this).find('RestOfShortestPathForSelectedPattern').first().text(),
                            ShortestPathForSelectedPattern: jQuery(this).find('ShortestPathForSelectedPattern').first().text()
                        });
                    });

                    response.find('AuthoringMetric').each(function() {
                        result.FeaturesByMetric.push({
                            Quality: jQuery(this).find('Quality').first().text(),
                            QualityLevel: jQuery(this).find('QualityLevel').first().text(),
                            MetricId: jQuery(this).find('MetricId').first().text(),
                            MetricName: jQuery(this).find('MetricName').first().text(),
                            AbsoluteValue: jQuery(this).find('AbsoluteValue').first().text(),
                            MetricRtf: jQuery(this).find('MetricRtf').first().text(),
                            Summary: jQuery(this).find('Summary').first().text(),
                            Description: jQuery(this).find('Description').first().text(),
                            UseMetric: jQuery(this).find('UseMetric').first().text(),
                            AffectsOverallQuality: jQuery(this).find('AffectsOverallQuality').first().text(),
                            Weight: jQuery(this).find('Weight').first().text(),
                            FeaturesAsString: jQuery(this).find('FeaturesAsString').first().text()
                        });
                    });

                    response.find('Misspelling').each(function() {
                        result.Misspelling.push({
                            LocatedString: jQuery(this).find('LocatedString ').first().text(),
                            Term: jQuery(this).find('Term ').first().text()
                        });
                    });
                })();

                var nextElements = new Array();
                jQuery(result.NextPossibleElements).each(function() {
                    if (this !== null) {
                        nextElements.push(this.RestOfShortestPathForSelectedPattern.match(/^[^\|]*\|/)[0].replace(/\|/, '').trim());
                    }
                });
                engine.setQualityStatus(result.GlobalQualityId);
                engine.fillMetricsOnError(result.FeaturesByMetric);
            },
            onGetPossibilitiesForNextSlotSuccess: function(response) {
                var engine = CKEDITOR.plugins.get('trc').engine;
                var api = CKEDITOR.plugins.get('trc').api;
                var dropdown = CKEDITOR.plugins.get('trc').dropdown;

                var result = new Array();
                response.find('string').each(function() {
                    result.push(jQuery(this).text());
                });
                engine.showSuggestionMenu(result);
            },
            onGetTokenExamplesByPatternSuccess: function(response) {
                console.log(response);
            }
        }
    },
    t: {
        patternName: '',
        patternCode: '',
        rmsLogin: 'DSONE\T94',
        rms: 'NATIVE',
        dataBaseName: 'ENOVIA',
        requirementsRepositoryDbType: 'Access',
        repositoryServer: 'Test repository server',
        repositoryName: 'Test repository name',
        projectInternalCode: 'Test project internal code',
        blockInternalCode: 'Test block internal code',
        blockName: 'Test blockName',
        absoluteNumber: 'Test absolute number',
        header: 'Test header',
        description: 'Test description',
        url: 'Test url',
        authorName: 'Test author name',
        userName: 'test username',
        lastModificationUser: 'Test last modification user',
        level: 0,
        code: 'Test code',
        traces: null,
        versionCount: 1,
        numOleObjects: 1,
        moduleVolatilityCount: 1,
        authorEmailAddress: 'Test author email address',
        attrs: null,
        creationDate: '2013-09-11T11:13:00',
        lastModificationDate: '2013-09-11T11:13:00',
        blockId: ''
    }

});

// When the editor is destroyed, we must disconnect from the web service

CKEDITOR.on('instanceDestroyed', function() {
    var engine = CKEDITOR.plugins.get('trc').engine;
    var api = CKEDITOR.plugins.get('trc').api;
    if (engine.globals.engine_active) {
        api.call('Disconnect', new Array('sessionId', api.globals.sessionId), api.callbacks.onDisconnectSuccess);
    }

});
