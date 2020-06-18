(function ($,undefined) {

    var delimiter = new Array();
    var tags_callbacks = new Array();
    var ImageBank = {};
    $.fn.doAutosize = function (o) {
    };

    function removeA(arr) {
        var what, a = arguments, L = a.length, ax;
        while (L > 1 && arr.length) {
            what = a[--L];
            while ((ax = arr.indexOf(what)) !== -1) {
                arr.splice(ax, 1);
            }
        }
        return arr;
    }
    $.fn.resetAutosize = function (options) {
    };

    $.fn.addTag = function (value, options) {
        options = jQuery.extend({ focus: false, callback: true }, options);
        this.each(function () {
            var id = $(this).attr('id');
            var optiondiv = id.replace("tag_", "optiondiv_");//YUS

            var tagslist = $(this).val().split(delimiter[id]);
            if (tagslist[0] == '') {
                tagslist = new Array();
            }

            value = jQuery.trim(value);

            var optionImageNode = $('[elementid ^= ' + optiondiv + ']').find('[elementid ^= "' + options.iModelName + '_checkimg_' + options.ruleId + '"]');

            if (options.unique) {
                var skipTag = $(this).tagExist(value);
                if (skipTag == true) {
                    if (options.val == 2) {
                        $("#" + id + '_tagsinput').find('span[ruleId*="' + options.ruleId + '"]').addClass('tag_not');

                        if (optionImageNode.attr("type") == "Single")
                            optionImageNode.attr("src", ImageBank.radioselectedImgUrl);
                        else
                            optionImageNode.attr("src", ImageBank.rejectImgUrl);
                    }
                    else if (options.val == 0) {
                        //YUS for remove
                        var id = $(this).attr('id');
                        var tagslist = $(this).val().split(delimiter[id]);
                        //$('#' + id).removeTag(escape(value));
                        removeA(tagslist, value);
                        $(this).val(tagslist.join());
                        $("#" + id + '_tagsinput').find('span[ruleId*="' + options.ruleId + '"]').remove();
                        //$('[elementid ^= ' + optiondiv + ']').find('[elementid ^= "' + options.iModelName + '_checkimg_' + options.ruleId + '"]').attr("src", "RejectIcon.png");

                    }

                    var parentid = optionImageNode.attr("parentruleid");
                    var objectid = options.ruleId;
                    var displayname = optionImageNode.attr("name");
                    var parentname = optionImageNode.attr("parentname");
                    var effObj = {
                        'parentid': parentid,
                        'objectid': objectid,
                        'parentname': parentname,//need to pass parentname
                        'objectname': displayname,
                        'value': value,
                        Features: []
                    };
                    var msg = {};
                    msg.effObj = effObj;
                    //msg need optimisation in recent future
                    msg.parentid = parentid;
                    msg.objectid = objectid;
                    msg.objectname = displayname;
                    msg.parentname = parentname;
                    msg.value = options.val;
                    //msg.criteria = CriteriaIntercom.CRITERIA_FO;
                    //CriteriaIntercom.getInstance().Communicate(CriteriaIntercom.LOCAL_EFF_PREFIX + options.iModelName, msg);
                    return;
                }
            } else {
                var skipTag = false;
            }

            if (value != '' && skipTag != true) {

                var tag = $('<span class="tag" ruleid="' + options.ruleId + '">' +
                            '<img style="width:14px;height:14px;vertical-align:text-top;" src="' + ImageBank.chosenbyuserImgUrl + '">' +
                            '<span>' + value + '  </span></span>');
                var anchor = $('<span>X</span>');
                tag.append(anchor);
                tag.insertBefore('#' + id + '_addTag');


                var optionelement = $('[elementid ^= "' + optiondiv + '"]').find('[elementid ^= "' + options.iModelName + '_checkimg_' + options.ruleId + '"]');

                anchor.bind('click',options, function (event) {

                    var tagslist = $("#" + id).val().split(delimiter[id]);
                    //$('#' + id).removeTag(escape(value));
                    removeA(tagslist, value);
                    $("#" + id).val(tagslist.join());
                    $("#" + id + '_tagsinput').find('span[ruleId*="' + options.ruleId + '"]').remove();
                    if (optionelement.attr("type") == "Single")
                        $('[elementid ^= ' + optiondiv + ']').find('[elementid ^= "' + options.iModelName + '_checkimg_' + options.ruleId + '"]').attr("src", ImageBank.radioavailableImgUrl);
                        else
                    $('[elementid ^= ' + optiondiv + ']').find('[elementid ^= "' + options.iModelName + '_checkimg_' + options.ruleId + '"]').attr("src", ImageBank.availableImgUrl);
                    event.stopPropagation();

                    var parentid = optionImageNode.attr("parentruleid");
                    var objectid = options.ruleId;
                    var displayname = optionImageNode.attr("name");
                    var parentname = optionImageNode.attr("parentname");
                    var effObj = {
                        'parentid': parentid,
                        'objectid': objectid,
                        'parentname': parentname,//need to pass parentname
                        'objectname': displayname,
                        'value': 0,
                        Features: []
                    };
                    var msg = {};
                    msg.effObj = effObj;
                    //msg need optimisation in recent future
                    msg.parentid = parentid;
                    msg.objectid = objectid;
                    msg.objectname = displayname;
                    msg.parentname = parentname;
                    msg.value = 0;
                    //msg.criteria = CriteriaIntercom.CRITERIA_FO;
                    //CriteriaIntercom.getInstance().Communicate(CriteriaIntercom.LOCAL_EFF_PREFIX + options.iModelName, msg);
                    console.log(msg);
                });



                if (options.val == 2) {
                    $("#" + id + '_tagsinput').find('span[ruleId*="' + options.ruleId + '"]').addClass('tag_not');
                    if (optionelement.attr("type") == "Single")
                        optionelement.attr("src", ImageBank.radiodismissedImgUrl);
                    else
                        optionelement.attr("src", ImageBank.rejectImgUrl);
                }
                else if (options.val == 1)
                {
                    if (optionelement.attr("type") == "Single")
                        optionelement.attr("src", ImageBank.radioselectedImgUrl);
                else
                        optionelement.attr("src", ImageBank.checkImgUrl);
            }
                tagslist.push(value);



                var parentid = optionImageNode.attr("parentruleid");
                var objectid = options.ruleId;
                var displayname = optionImageNode.attr("name");
                var parentname = optionImageNode.attr("parentname");
                var effObj = {
                    'parentid': parentid,
                    'objectid': objectid,
                    'parentname': parentname,//need to pass parentname
                    'objectname': displayname,
                    'value': 1,
                    Features: []
                };
                var msg = {};
                msg.effObj = effObj;
                //msg need optimisation in recent future
                msg.parentid = parentid;
                msg.objectid = objectid;
                msg.objectname = displayname;
                msg.parentname = parentname;
                msg.value = 1;
                //msg.criteria = CriteriaIntercom.CRITERIA_FO;
                //CriteriaIntercom.getInstance().Communicate(CriteriaIntercom.LOCAL_EFF_PREFIX + options.iModelName, msg);


                $('#' + id + '_tag').val('');
                if (options.focus) {
                    $('#' + id + '_tag').focus();
                } else {
                    $('#' + id + '_tag').blur();
                }

                $.fn.tagsInput.updateTagsField(this, tagslist);

                if (options.callback && tags_callbacks[id] && tags_callbacks[id]['onAddTag']) {
                    var f = tags_callbacks[id]['onAddTag'];
                    f.call(this, value);
                }
                if (tags_callbacks[id] && tags_callbacks[id]['onChange']) {
                    var i = tagslist.length;
                    var f = tags_callbacks[id]['onChange'];
                    f.call(this, $(this), tagslist[i - 1]);
                }
            }

        });

        return false;
    };

    $.fn.removeTag = function (value) {
        value = unescape(value);
        this.each(function () {
            var id = $(this).attr('id');

            var old = $(this).val().split(delimiter[id]);

            $('#' + id + '_tagsinput .tag').remove();
            str = '';
            for (i = 0; i < old.length; i++) {
                if (old[i] != value) {
                    str = str + delimiter[id] + old[i];
                }
            }

            $.fn.tagsInput.importTags(this, str);

            if (tags_callbacks[id] && tags_callbacks[id]['onRemoveTag']) {
                var f = tags_callbacks[id]['onRemoveTag'];
                f.call(this, value);
            }
        });

        return false;
    };

    $.fn.tagExist = function (val) {
        var id = $(this).attr('id');
        var tagslist = $(this).val().split(delimiter[id]);
        return (jQuery.inArray(val, tagslist) >= 0); 
    };

    $.fn.importTags = function (str) {
        id = $(this).attr('id');
        $('#' + id + '_tagsinput .tag').remove();
        $.fn.tagsInput.importTags(this, str);
    }

    $.fn.tagsInput = function (options) {
        var settings = jQuery.extend({
            interactive: true,
            defaultText: '',
            minChars: 0,
            width: '600px',
            height: 'auto',
            autocomplete: { selectFirst: false },
            'hide': true,
            'delimiter': ',',
            'unique': true,
            removeWithBackspace: true,
            placeholderColor: '#666666',
            autosize: true,
            comfortZone: 20,
            inputPadding: 6 * 2
        }, options);
        ImageBank = options.iImageBank;
        this.each(function () {
            if (settings.hide) {
                $(this).hide();
            }
            var id = $(this).attr('id');
            if (!id || delimiter[$(this).attr('id')]) {
                id = $(this).attr('id', 'tags' + new Date().getTime()).attr('id');
            }

            var data = jQuery.extend({
                pid: id,
                real_input: '#' + id,
                holder: '#' + id + '_tagsinput',
                input_wrapper: '#' + id + '_addTag',
                fake_input: '#' + id + '_tag'
            }, settings);

            delimiter[id] = data.delimiter;

            if (settings.onAddTag || settings.onRemoveTag || settings.onChange) {
                tags_callbacks[id] = new Array();
                tags_callbacks[id]['onAddTag'] = settings.onAddTag;
                tags_callbacks[id]['onRemoveTag'] = settings.onRemoveTag;
                tags_callbacks[id]['onChange'] = settings.onChange;
            }

            var markup = '<div id="' + id + '_tagsinput" class="tagsinput"><div id="' + id + '_addTag">';

            if (settings.interactive) {
                markup = markup + '<input id="' + id + '_tag" value="" data-default="' + settings.defaultText + '" />';
            }

            markup = markup + '</div><div class="tags_clear"></div></div>';

            $(markup).insertAfter(this);

            $(data.holder).css('width', settings.width);
            $(data.holder).css('min-height', settings.height);
            $(data.holder).css('height', settings.height);

            if ($(data.real_input).val() != '') {
                $.fn.tagsInput.importTags($(data.real_input), $(data.real_input).val());
            }
            if (settings.interactive) {
                $(data.fake_input).val($(data.fake_input).attr('data-default'));
                $(data.fake_input).css('color', settings.placeholderColor);
				$(data.fake_input).css('display', 'none');
                $(data.fake_input).resetAutosize(settings);


                var inputid = id.replace("tag_", "input_");//YUS

                $(data.holder).bind('click', data, function (event) {
                    $("#" + inputid).focus();//YUS
                });

                $(data.fake_input).bind('focus', data, function (event) {
                    if ($(event.data.fake_input).val() == $(event.data.fake_input).attr('data-default')) {
                        $(event.data.fake_input).val('');
                    }
                    $(event.data.fake_input).css('color', '#000000');
                });

                if (settings.autocomplete_url != undefined) {
                    autocomplete_options = { source: settings.autocomplete_url };
                    for (attrname in settings.autocomplete) {
                        autocomplete_options[attrname] = settings.autocomplete[attrname];
                    }

                    if (jQuery.Autocompleter !== undefined) {
                        $(data.fake_input).autocomplete(settings.autocomplete_url, settings.autocomplete);
                        $(data.fake_input).bind('result', data, function (event, data, formatted) {
                            if (data) {
                                $('#' + id).addTag(data[0] + "", { focus: true, unique: (settings.unique) });
                            }
                        });
                    }

                } else {
                    $(data.fake_input).bind('blur', data, function (event) {
                        var d = $(this).attr('data-default');
                        if ($(event.data.fake_input).val() != '' && $(event.data.fake_input).val() != d) {
                            if ((event.data.minChars <= $(event.data.fake_input).val().length) && (!event.data.maxChars || (event.data.maxChars >= $(event.data.fake_input).val().length)))
                                $(event.data.real_input).addTag($(event.data.fake_input).val(), { focus: true, unique: (settings.unique) });
                        } else {
                            $(event.data.fake_input).val($(event.data.fake_input).attr('data-default'));
                            $(event.data.fake_input).css('color', settings.placeholderColor);
                        }
                        return false;
                    });

                }
                $(data.fake_input).bind('keypress', data, function (event) {
                    if (event.which == event.data.delimiter.charCodeAt(0) || event.which == 13) {
                        event.preventDefault();
                        if ((event.data.minChars <= $(event.data.fake_input).val().length) && (!event.data.maxChars || (event.data.maxChars >= $(event.data.fake_input).val().length)))
                            $(event.data.real_input).addTag($(event.data.fake_input).val(), { focus: true, unique: (settings.unique) });
                        $(event.data.fake_input).resetAutosize(settings);
                        return false;
                    } else if (event.data.autosize) {
                        $(event.data.fake_input).doAutosize(settings);

                    }
                });
                data.removeWithBackspace && $(data.fake_input).bind('keydown', function (event) {
                    if (event.keyCode == 8 && $(this).val() == '') {
                        event.preventDefault();
                        var last_tag = $(this).closest('.tagsinput').find('.tag:last').text();
                        var id = $(this).attr('id').replace(/_tag$/, '');
                        last_tag = last_tag.replace(/[\s]+x$/, '');
                        $('#' + id).removeTag(escape(last_tag));
                        $(this).trigger('focus');
                    }
                });
                $(data.fake_input).blur();

                if (data.unique) {
                    $(data.fake_input).keydown(function (event) {
                        if (event.keyCode == 8 || String.fromCharCode(event.which).match(/\w+|[áéíóúÁÉÍÓÚñÑ,/]+/)) {
                            $(this).removeClass('not_valid');
                        }
                    });
                }


                var configmodel = options.iJson;
                var ImageBank = options.iImageBank;
                var featureid = id.replace(options.iModelName + "_tag_", "");
                var optionlist = [];
                var optionrelidlist = [];
                for (var count = 0; count < configmodel.features.length; count++) {
                    if (featureid == configmodel.features[count].id) {
                        for (var cnt = 0; cnt < configmodel.features[count].options.length; cnt++) {
                            var key = configmodel.features[count].options[cnt].name;
                            var value = configmodel.features[count].options[cnt];
                            optionlist.push({ value: key, data: key, ruleId: configmodel.features[count].options[cnt].id })
                        }
                    }
                }
                var optiondiv = id.replace("tag_", "optiondiv_");//YUS

                //YUS need change
                $("#" + inputid).bind('keypress', data, function (event) {
                    if (event.which == event.data.delimiter.charCodeAt(0) || event.which == 13) {
                        event.preventDefault();
                        var found = 0;
                        var value = $(this).val();
                        var ruleId = "";
                        for (var i = 0; i < optionlist.length; i++) {
                            if (value == optionlist[i].value) {
                                ruleId = optionlist[i].ruleId;
                                found = 1; break;
                            }
                        }
                        if (found == 0) return;
                        $(data.fake_input).removeClass('not_valid');
                        if ((data.minChars <= $(data.fake_input).val().length) && (!data.maxChars || (data.maxChars >= $(data.fake_input).val().length))) {
                            if ($(this).attr("selectiontype") == "Single")
                            {
                                $('[elementid ^= ' + optiondiv + ']').find('[elementid ^= "' + options.iModelName + '_checkimg_"]').attr("src", ImageBank.radioavailableImgUrl);
                                $(data.real_input).removeAllInputTags();
                            }
                            $(data.real_input).addTag($(this).val(), { focus: false, unique: (settings.unique), val: 1, ruleId: ruleId, iModelName: options.iModelName });
                        }
                        $(data.fake_input).resetAutosize(settings);
                        $(this).val("");
                        return false;
                    } else if (data.autosize) {
                        $(data.fake_input).doAutosize(settings);
                    }
                });




                //$('[elementid ^= '+optiondiv+']').find("[elementid ^= 'checkimg_']").unbind("click");
                $('[elementid ^= ' + optiondiv + ']').find('[elementid ^= "' + options.iModelName + '_checkimg_"]').bind('click', data, function (event) {
                    var value = 0;
                    var srcpath = $(this).attr("src");
                    if ($(this).attr("type") == "Single") {
                        $('[elementid ^= ' + optiondiv + ']').find('[elementid ^= "' + options.iModelName + '_checkimg_"]').attr("src", ImageBank.radioavailableImgUrl);
                        if (srcpath == ImageBank.radioavailableImgUrl)
                        { $(this).attr("src", ImageBank.radioselectedImgUrl); value = 1; }
                        else if (srcpath == ImageBank.radiodismissedImgUrl)
                        { $(this).attr("src", ImageBank.radioavailableImgUrl); value = 0; }
                        else if (srcpath == ImageBank.radioselectedImgUrl)
                        { $(this).attr("src", ImageBank.radiodismissedImgUrl); value = 2; }
                    }
                    else {
                        if (srcpath == ImageBank.availableImgUrl)
                        { $(this).attr("src", ImageBank.checkImgUrl); value = 1; }
                        else if (srcpath == ImageBank.rejectImgUrl)
                        { $(this).attr("src", ImageBank.availableImgUrl); value = 0; }
                        else if (srcpath == ImageBank.checkImgUrl)
                        { $(this).attr("src", ImageBank.rejectImgUrl); value = 2; }
                    }

                    var id = $(this).attr("elementid").replace("checkimg_", "name_");
                    var text = $('[elementid ~= "' + id + '"]').text();
                    var ruleId = $(this).attr("elementid").replace(options.iModelName+"_checkimg_", "");
                    //if (event.which == event.data.delimiter.charCodeAt(0) || event.which == 13) {
                    event.preventDefault();
                    $(data.fake_input).removeClass('not_valid');
                    if ((data.minChars <= $(data.fake_input).val().length) && (!data.maxChars || (data.maxChars >= $(data.fake_input).val().length))) {
                        if ($(this).attr("type") == "Single") {
                            $(data.real_input).removeAllInputTags();
                        }
                        $(data.real_input).addTag(text, { focus: false, unique: (settings.unique), val: value, ruleId: ruleId, iModelName: options.iModelName });
                    }
                    $(data.fake_input).resetAutosize(settings);
                    $("#" + inputid).val("");

                    var parentid = $(this).attr("parentruleid");
                    var objectid = ruleId;
                    var displayname = $(this).attr("name");
                    var parentname = $(this).attr("parentname");
                    var effObj = {
                        'parentid': parentid,
                        'objectid': objectid,
                        'parentname': parentname,//need to pass parentname
                        'objectname': displayname,
                        'value': value,
                        Features: []
                    };
                    var msg = {};
                    msg.effObj = effObj;
                    //msg need optimisation in recent future
                    msg.parentid = parentid;
                    msg.objectid = objectid;
                    msg.objectname = displayname;
                    msg.parentname = parentname;
                    msg.value = value;
                    //msg.criteria = CriteriaIntercom.CRITERIA_FO;
                    //CriteriaIntercom.getInstance().Communicate(CriteriaIntercom.LOCAL_EFF_PREFIX + options.iModelName, msg);

                    console.log(msg);

                    return false;
                });
                $("#" + inputid).bind('click', data, function (event) {
                    event.stopPropagation();
                });

                //function broadcastMessage()
                //{

                //    var effObj = {
                //        'parentid': parentid,
                //        'objectid': objectid,
                //        'parentname': parentname,//need to pass parentname
                //        'objectname': displayname,
                //        'value': value,
                //        Features: []
                //    };
                //    var msg = {};
                //    msg.effObj = effObj;
                //    //msg need optimisation in recent future
                //    msg.parentid = parentid;
                //    msg.objectid = objectid;
                //    msg.objectname = displayname;
                //    msg.parentname = parentname;
                //    msg.value = value;
                //    msg.criteria = CriteriaIntercom.CRITERIA_FO;
                //    CriteriaIntercom.getInstance().Communicate(CriteriaIntercom.LOCAL_EFF_PREFIX + tab, msg);


                //}

                //var optionlist =  $.map(countries, function (value, key) { return { value: value, data: key }; });

                // Initialize autocomplete with local lookup:
                var inputdiv = id.replace("tag_", "input_");//YUS

                console.log(optionlist);
                $('#' + inputdiv).CFAutocomplete({
                    lookup: optionlist,
                    minChars: 1,
                    onSelect: function (suggestion) {
                    },
                    showNoSuggestionNotice: true,
                    noSuggestionNotice: 'Sorry, no matching results',
                    groupBy: 'category'
                });
            } // if settings.interactive
        });

        return this;

    };

    $.fn.tagsInput.updateTagsField = function (obj, tagslist) {
        var id = $(obj).attr('id');
        $(obj).val(tagslist.join(delimiter[id]));
    };

    $.fn.tagsInput.importTags = function (obj, val) {
        $(obj).val('');
        var id = $(obj).attr('id');
        var tags = val.split(delimiter[id]);
        for (i = 0; i < tags.length; i++) {
            $(obj).addTag(tags[i], { focus: false, callback: false });
        }
        if (tags_callbacks[id] && tags_callbacks[id]['onChange']) {
            var f = tags_callbacks[id]['onChange'];
            f.call(obj, obj, tags[i]);
        }
    };

    $.fn.removeAllInputTags = function (iModelName)
    {
        this.each(function () {
            id = $(this).attr('id');
            $("#" + id).val("");
            $("#" + id + '_tagsinput').find('span').remove();
            var optiondiv = id.replace("tag_", "optiondiv_");//YUS

            var optionImageNode = $('[elementid ^= ' + optiondiv + ']').find('[elementid ^= "' + iModelName + '_checkimg_"]');
            optionImageNode.attr("src", ImageBank.availableImgUrl);

        });
    }

    $.fn.setTagValues = function (effectivityobject, iModelName)
    {

        this.each(function () {
            var id = $(this).attr('id');
            var featureid = id.replace(iModelName+"_tag_", "");
            for (var count = 0; count < effectivityobject.Features.length; count++) {

                if (featureid == effectivityobject.Features[count].Feature.id) {
                    var options = effectivityobject.Features[count].Options;

                    for (var cnt = 0; cnt < options.length; cnt++) {
                        var optionid = options[cnt].id;
                        var value = options[cnt].value;
                        var name = options[cnt].name;
                        name = jQuery.trim(name);
                        var optiondiv = id.replace("tag_", "optiondiv_");//YUS
                        if (value == 0) continue;
                        var optionImageNode = $('[elementid ^= ' + optiondiv + ']').find('[elementid ^= "' + iModelName + '_checkimg_' + optionid + '"]');
                        if (name != '') {

                            var tag = $('<span class="tag" ruleid="' + optionid + '">' +
                                        '<img style="width:14px;height:14px;vertical-align:text-top;" src="' + ImageBank.chosenbyuserImgUrl + '">' +
                                        '<span>' + name + '  </span></span>');
                            var anchor = $('<span>X</span>');
                            tag.append(anchor);
                            tag.insertBefore('#' + id + '_addTag');

                            anchor.bind('click',options, function (event) {

                                var tagslist = $("#" + id).val().split(delimiter[id]);
                                //$('#' + id).removeTag(escape(value));
                                removeA(tagslist, value);
                                $("#" + id).val(tagslist.join());
                                $("#" + id + '_tagsinput').find('span[ruleId*="' + optionid + '"]').remove();
                                optionImageNode.attr("src", ImageBank.availableImgUrl);
                                event.stopPropagation();

                                var parentid = optionImageNode.attr("parentruleid");
                                var objectid = optionid;
                                var displayname = optionImageNode.attr("name");
                                var parentname = optionImageNode.attr("parentname");
                                var effObj = {
                                    'parentid': parentid,
                                    'objectid': objectid,
                                    'parentname': parentname,//need to pass parentname
                                    'objectname': displayname,
                                    'value': 0,
                                    Features: []
                                };
                                var msg = {};
                                msg.effObj = effObj;
                                //msg need optimisation in recent future
                                msg.parentid = parentid;
                                msg.objectid = objectid;
                                msg.objectname = displayname;
                                msg.parentname = parentname;
                                msg.value = 0;
                                //msg.criteria = CriteriaIntercom.CRITERIA_FO;
                                //CriteriaIntercom.getInstance().Communicate(CriteriaIntercom.LOCAL_EFF_PREFIX + iModelName, msg);
                                console.log(msg);
                            });

                            if (value == 1)
                                if (optionImageNode.attr("type") == "Single")
                                    optionImageNode.attr("src", ImageBank.radioselectedImgUrl);
                                else
                                    optionImageNode.attr("src", ImageBank.checkImgUrl);
                            else if (value == 2) {
                                tag.addClass('tag_not');
                                if (optionImageNode.attr("type") == "Single")
                                    optionImageNode.attr("src", ImageBank.radiodismissedImgUrl);
                                else
                                    optionImageNode.attr("src", ImageBank.rejectImgUrl);
                            }

                            $('#' + id + '_tag').val('');
                            if (options.focus) {
                                $('#' + id + '_tag').focus();
                            } else {
                                $('#' + id + '_tag').blur();
                            }
                            var tagslist = $("#" + id).val().split(delimiter[id]);
                            tagslist.push(name);
                            $(this).val(tagslist.join(delimiter[id]));
                        }
                    }
                }
            }
        })
    }


    var
        utils = (function () {
            return {
                escapeRegExChars: function (value) {
                    return value.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
                },
                createNode: function (containerClass) {
                    var div = document.createElement('div');
                    div.className = containerClass;
                    div.style.position = 'absolute';
                    div.style.display = 'none';
                    return div;
                }
            };
        }()),

        keys = {
            ESC: 27,
            TAB: 9,
            RETURN: 13,
            LEFT: 37,
            UP: 38,
            RIGHT: 39,
            DOWN: 40
        };

    function Autocomplete(el, options) {
        var noop = function () { },
            that = this,
            defaults = {
                ajaxSettings: {},
                autoSelectFirst: false,
                appendTo: document.body,
                serviceUrl: null,
                lookup: null,
                onSelect: null,
                width: 'auto',
                minChars: 1,
                maxHeight: 300,
                deferRequestBy: 0,
                params: {},
                formatResult: Autocomplete.formatResult,
                delimiter: null,
                zIndex: 9999,
                type: 'GET',
                noCache: false,
                onSearchStart: noop,
                onSearchComplete: noop,
                onSearchError: noop,
                preserveInput: false,
                containerClass: 'autocomplete-suggestions',
                tabDisabled: false,
                dataType: 'text',
                currentRequest: null,
                triggerSelectOnValidInput: true,
                preventBadQueries: true,
                lookupFilter: function (suggestion, originalQuery, queryLowerCase) {
                    return suggestion.value.toLowerCase().indexOf(queryLowerCase) !== -1;
                },
                paramName: 'query',
                transformResult: function (response) {
                    return typeof response === 'string' ? $.parseJSON(response) : response;
                },
                showNoSuggestionNotice: false,
                noSuggestionNotice: 'No results',
                orientation: 'bottom',
                forceFixPosition: false
            };

        that.element = el;
        that.el = $(el);
        that.suggestions = [];
        that.badQueries = [];
        that.selectedIndex = -1;
        that.currentValue = that.element.value;
        that.intervalId = 0;
        that.cachedResponse = {};
        that.onChangeInterval = null;
        that.onChange = null;
        that.isLocal = false;
        that.suggestionsContainer = null;
        that.noSuggestionsContainer = null;
        that.options = $.extend({}, defaults, options);
        that.classes = {
            selected: 'autocomplete-selected',
            suggestion: 'autocomplete-suggestion'
        };
        that.hint = null;
        that.hintValue = '';
        that.selection = null;

        that.initialize();
        that.setOptions(options);
    }

    Autocomplete.utils = utils;

    $.Autocomplete = Autocomplete;

    Autocomplete.formatResult = function (suggestion, currentValue) {
        var pattern = '(' + utils.escapeRegExChars(currentValue) + ')';

        return suggestion.value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>');
    };

    Autocomplete.prototype = {

        killerFn: null,

        initialize: function () {
            var that = this,
                suggestionSelector = '.' + that.classes.suggestion,
                selected = that.classes.selected,
                options = that.options,
                container;

            that.element.setAttribute('autocomplete', 'off');

            that.killerFn = function (e) {
                if ($(e.target).closest('.' + that.options.containerClass).length === 0) {
                    that.killSuggestions();
                    that.disableKillerFn();
                }
            };

            that.noSuggestionsContainer = $('<div class="autocomplete-no-suggestion"></div>')
                                          .html(this.options.noSuggestionNotice).get(0);

            that.suggestionsContainer = Autocomplete.utils.createNode(options.containerClass);

            container = $(that.suggestionsContainer);

            container.appendTo(options.appendTo);

            if (options.width !== 'auto') {
                container.width(options.width);
            }

            container.on('mouseover.autocomplete', suggestionSelector, function () {
                that.activate($(this).data('index'));
            });

            container.on('mouseout.autocomplete', function () {
                that.selectedIndex = -1;
                container.children('.' + selected).removeClass(selected);
            });

            container.on('click.autocomplete', suggestionSelector, function () {
                that.select($(this).data('index'));
            });

            that.fixPositionCapture = function () {
                if (that.visible) {
                    that.fixPosition();
                }
            };

            $(window).on('resize.autocomplete', that.fixPositionCapture);

            that.el.on('keydown.autocomplete', function (e) { that.onKeyPress(e); });
            that.el.on('keyup.autocomplete', function (e) { that.onKeyUp(e); });
            that.el.on('blur.autocomplete', function () { that.onBlur(); });
            that.el.on('focus.autocomplete', function () { that.onFocus(); });
            that.el.on('change.autocomplete', function (e) { that.onKeyUp(e); });
            that.el.on('input.autocomplete', function (e) { that.onKeyUp(e); });
        },

        onFocus: function () {
            var that = this;
            that.fixPosition();
            if (that.options.minChars <= that.el.val().length) {
                that.onValueChange();
            }
        },

        onBlur: function () {
            this.enableKillerFn();
        },

        setOptions: function (suppliedOptions) {
            var that = this,
                options = that.options;

            $.extend(options, suppliedOptions);

            that.isLocal = $.isArray(options.lookup);

            if (that.isLocal) {
                options.lookup = that.verifySuggestionsFormat(options.lookup);
            }

            options.orientation = that.validateOrientation(options.orientation, 'bottom');

        },


        clearCache: function () {
            this.cachedResponse = {};
            this.badQueries = [];
        },

        clear: function () {
            this.clearCache();
            this.currentValue = '';
            this.suggestions = [];
        },

        disable: function () {
            var that = this;
            that.disabled = true;
            clearInterval(that.onChangeInterval);
            if (that.currentRequest) {
                that.currentRequest.abort();
            }
        },

        enable: function () {
            this.disabled = false;
        },

        fixPosition: function () {

            var that = this,
                $container = $(that.suggestionsContainer),
                containerParent = $container.parent().get(0);
            if (containerParent !== document.body && !that.options.forceFixPosition) {
                return;
            }

            var orientation = that.options.orientation,
                containerHeight = $container.outerHeight(),
                height = that.el.outerHeight(),
                offset = that.el.offset(),
                styles = { 'top': offset.top, 'left': offset.left };

            if (orientation === 'auto') {
                var viewPortHeight = $(window).height(),
                    scrollTop = $(window).scrollTop(),
                    topOverflow = -scrollTop + offset.top - containerHeight,
                    bottomOverflow = scrollTop + viewPortHeight - (offset.top + height + containerHeight);

                orientation = (Math.max(topOverflow, bottomOverflow) === topOverflow) ? 'top' : 'bottom';
            }

            if (orientation === 'top') {
                styles.top += -containerHeight;
            } else {
                styles.top += height;
            }

            if (containerParent !== document.body) {
                var opacity = $container.css('opacity'),
                    parentOffsetDiff;

                if (!that.visible) {
                    $container.css('opacity', 0).show();
                }

                parentOffsetDiff = $container.offsetParent().offset();
                styles.top -= parentOffsetDiff.top;
                styles.left -= parentOffsetDiff.left;

                if (!that.visible) {
                    $container.css('opacity', opacity).hide();
                }
            }

            if (that.options.width === 'auto') {
                styles.width = (that.el.outerWidth() - 2) + 'px';
            }

            $container.css("top", styles.top);
            $container.css("left", styles.left);
            $container.css("width", styles.width);
        },

        enableKillerFn: function () {
            var that = this;
            $(document).on('click.autocomplete', that.killerFn);
        },

        disableKillerFn: function () {
            var that = this;
            $(document).off('click.autocomplete', that.killerFn);
        },

        killSuggestions: function () {
            var that = this;
            that.stopKillSuggestions();
            that.intervalId = window.setInterval(function () {
                that.hide();
                that.stopKillSuggestions();
            }, 50);
        },

        stopKillSuggestions: function () {
            window.clearInterval(this.intervalId);
        },

        isCursorAtEnd: function () {
            var that = this,
                valLength = that.el.val().length,
                selectionStart = that.element.selectionStart,
                range;

            if (typeof selectionStart === 'number') {
                return selectionStart === valLength;
            }
            if (document.selection) {
                range = document.selection.createRange();
                range.moveStart('character', -valLength);
                return valLength === range.text.length;
            }
            return true;
        },

        onKeyPress: function (e) {
            var that = this;

            if (!that.disabled && !that.visible && e.which === keys.DOWN && that.currentValue) {
                that.suggest();
                return;
            }

            if (that.disabled || !that.visible) {
                return;
            }

            switch (e.which) {
                case keys.ESC:
                    that.el.val(that.currentValue);
                    that.hide();
                    break;
                case keys.RIGHT:
                    if (that.hint && that.options.onHint && that.isCursorAtEnd()) {
                        that.selectHint();
                        break;
                    }
                    return;
                case keys.TAB:
                    if (that.hint && that.options.onHint) {
                        that.selectHint();
                        return;
                    }
                    if (that.selectedIndex === -1) {
                        that.hide();
                        return;
                    }
                    that.select(that.selectedIndex);
                    if (that.options.tabDisabled === false) {
                        return;
                    }
                    break;
                case keys.RETURN:
                    if (that.selectedIndex === -1) {
                        that.hide();
                        return;
                    }
                    that.select(that.selectedIndex);
                    break;
                case keys.UP:
                    that.moveUp();
                    break;
                case keys.DOWN:
                    that.moveDown();
                    break;
                default:
                    return;
            }

            e.stopImmediatePropagation();
            e.preventDefault();
        },

        onKeyUp: function (e) {
            var that = this;

            if (that.disabled) {
                return;
            }

            switch (e.which) {
                case keys.UP:
                case keys.DOWN:
                    return;
            }

            clearInterval(that.onChangeInterval);

            if (that.currentValue !== that.el.val()) {
                that.findBestHint();
                if (that.options.deferRequestBy > 0) {
                    that.onChangeInterval = setInterval(function () {
                        that.onValueChange();
                    }, that.options.deferRequestBy);
                } else {
                    that.onValueChange();
                }
            }
        },

        onValueChange: function () {
            var that = this,
                options = that.options,
                value = that.el.val(),
                query = that.getQuery(value),
                index;

            if (that.selection && that.currentValue !== query) {
                that.selection = null;
                (options.onInvalidateSelection || $.noop).call(that.element);
            }

            clearInterval(that.onChangeInterval);
            that.currentValue = value;
            that.selectedIndex = -1;

            if (options.triggerSelectOnValidInput) {
                index = that.findSuggestionIndex(query);
                if (index !== -1) {
                    that.select(index);
                    return;
                }
            }

            if (query.length < options.minChars) {
                that.hide();
            } else {
                that.getSuggestions(query);
            }
        },

        findSuggestionIndex: function (query) {
            var that = this,
                index = -1,
                queryLowerCase = query.toLowerCase();

            $.each(that.suggestions, function (i, suggestion) {
                if (suggestion.value.toLowerCase() === queryLowerCase) {
                    index = i;
                    return false;
                }
            });

            return index;
        },

        getQuery: function (value) {
            var delimiter = this.options.delimiter,
                parts;

            if (!delimiter) {
                return value;
            }
            parts = value.split(delimiter);
            return $.trim(parts[parts.length - 1]);
        },

        getSuggestionsLocal: function (query) {
            var that = this,
                options = that.options,
                queryLowerCase = query.toLowerCase(),
                filter = options.lookupFilter,
                limit = parseInt(options.lookupLimit, 10),
                data;

            data = {
                suggestions: $.grep(options.lookup, function (suggestion) {
                    return filter(suggestion, query, queryLowerCase);
                })
            };

            if (limit && data.suggestions.length > limit) {
                data.suggestions = data.suggestions.slice(0, limit);
            }

            return data;
        },

        getSuggestions: function (q) {
            var response,
                that = this,
                options = that.options,
                serviceUrl = options.serviceUrl,
                params,
                cacheKey,
                ajaxSettings;

            options.params[options.paramName] = q;
            params = options.ignoreParams ? null : options.params;

            if (options.onSearchStart.call(that.element, options.params) === false) {
                return;
            }

            if ($.isFunction(options.lookup)) {
                options.lookup(q, function (data) {
                    that.suggestions = data.suggestions;
                    that.suggest();
                    options.onSearchComplete.call(that.element, q, data.suggestions);
                });
                return;
            }

            if (that.isLocal) {
                response = that.getSuggestionsLocal(q);
            } else {
                if ($.isFunction(serviceUrl)) {
                    serviceUrl = serviceUrl.call(that.element, q);
                }
                cacheKey = serviceUrl + '?' + $.param(params || {});
                response = that.cachedResponse[cacheKey];
            }

            if (response && $.isArray(response.suggestions)) {
                that.suggestions = response.suggestions;
                that.suggest();
                options.onSearchComplete.call(that.element, q, response.suggestions);
            } else if (!that.isBadQuery(q)) {
                if (that.currentRequest) {
                    that.currentRequest.abort();
                }

                ajaxSettings = {
                    url: serviceUrl,
                    data: params,
                    type: options.type,
                    dataType: options.dataType
                };

                $.extend(ajaxSettings, options.ajaxSettings);

                that.currentRequest = $.ajax(ajaxSettings).done(function (data) {
                    var result;
                    that.currentRequest = null;
                    result = options.transformResult(data);
                    that.processResponse(result, q, cacheKey);
                    options.onSearchComplete.call(that.element, q, result.suggestions);
                }).fail(function (jqXHR, textStatus, errorThrown) {
                    options.onSearchError.call(that.element, q, jqXHR, textStatus, errorThrown);
                });
            } else {
                options.onSearchComplete.call(that.element, q, []);
            }
        },

        isBadQuery: function (q) {
            if (!this.options.preventBadQueries) {
                return false;
            }

            var badQueries = this.badQueries,
                i = badQueries.length;

            while (i--) {
                if (q.indexOf(badQueries[i]) === 0) {
                    return true;
                }
            }

            return false;
        },

        hide: function () {
            var that = this;
            that.visible = false;
            that.selectedIndex = -1;
            clearInterval(that.onChangeInterval);
            $(that.suggestionsContainer).hide();
            that.signalHint(null);
        },

        suggest: function () {
            if (this.suggestions.length === 0) {
                if (this.options.showNoSuggestionNotice) {
                    this.noSuggestions();
                } else {
                    this.hide();
                }
                return;
            }

            var that = this,
                options = that.options,
                groupBy = options.groupBy,
                formatResult = options.formatResult,
                value = that.getQuery(that.currentValue),
                className = that.classes.suggestion,
                classSelected = that.classes.selected,
                container = $(that.suggestionsContainer),
                noSuggestionsContainer = $(that.noSuggestionsContainer),
                beforeRender = options.beforeRender,
                html = '',
                category,
                formatGroup = function (suggestion, index) {
                    var currentCategory = suggestion.data[groupBy];

                    if (category === currentCategory) {
                        return '';
                    }

                    category = currentCategory;

                    return '<div class="autocomplete-group"><strong>' + category + '</strong></div>';
                },
                index;

            if (options.triggerSelectOnValidInput) {
                index = that.findSuggestionIndex(value);
                if (index !== -1) {
                    that.select(index);
                    return;
                }
            }

            $.each(that.suggestions, function (i, suggestion) {
                if (groupBy) {
                    html += formatGroup(suggestion, value, i);
                }

                html += '<div class="' + className + '" data-index="' + i + '">' + formatResult(suggestion, value) + '</div>';
            });

            this.adjustContainerWidth();

            noSuggestionsContainer.detach();
            container.html(html);

            if ($.isFunction(beforeRender)) {
                beforeRender.call(that.element, container);
            }

            that.fixPosition();
            container.show();

            if (options.autoSelectFirst) {
                that.selectedIndex = 0;
                container.scrollTop(0);
                container.children().first().addClass(classSelected);
            }

            that.visible = true;
            that.findBestHint();
        },

        noSuggestions: function () {
            var that = this,
                container = $(that.suggestionsContainer),
                noSuggestionsContainer = $(that.noSuggestionsContainer);

            this.adjustContainerWidth();

            noSuggestionsContainer.detach();
            container.empty(); 
            container.append(noSuggestionsContainer);

            that.fixPosition();

            container.show();
            that.visible = true;
        },

        adjustContainerWidth: function () {
            var that = this,
                options = that.options,
                width,
                container = $(that.suggestionsContainer);

            if (options.width === 'auto') {
                width = that.el.outerWidth() - 2;
                container.width(width > 0 ? width : 300);
            }
        },

        findBestHint: function () {
            var that = this,
                value = that.el.val().toLowerCase(),
                bestMatch = null;

            if (!value) {
                return;
            }

            $.each(that.suggestions, function (i, suggestion) {
                var foundMatch = suggestion.value.toLowerCase().indexOf(value) === 0;
                if (foundMatch) {
                    bestMatch = suggestion;
                }
                return !foundMatch;
            });

            that.signalHint(bestMatch);
        },

        signalHint: function (suggestion) {
            var hintValue = '',
                that = this;
            if (suggestion) {
                hintValue = that.currentValue + suggestion.value.substr(that.currentValue.length);
            }
            if (that.hintValue !== hintValue) {
                that.hintValue = hintValue;
                that.hint = suggestion;
                (this.options.onHint || $.noop)(hintValue);
            }
        },

        verifySuggestionsFormat: function (suggestions) {
            if (suggestions.length && typeof suggestions[0] === 'string') {
                return $.map(suggestions, function (value) {
                    return { value: value, data: null };
                });
            }

            return suggestions;
        },

        validateOrientation: function (orientation, fallback) {
            orientation = $.trim(orientation || '').toLowerCase();

            if ($.inArray(orientation, ['auto', 'bottom', 'top']) === -1) {
                orientation = fallback;
            }

            return orientation;
        },

        processResponse: function (result, originalQuery, cacheKey) {
            var that = this,
                options = that.options;

            result.suggestions = that.verifySuggestionsFormat(result.suggestions);

            if (!options.noCache) {
                that.cachedResponse[cacheKey] = result;
                if (options.preventBadQueries && result.suggestions.length === 0) {
                    that.badQueries.push(originalQuery);
                }
            }

            if (originalQuery !== that.getQuery(that.currentValue)) {
                return;
            }

            that.suggestions = result.suggestions;
            that.suggest();
        },

        activate: function (index) {
            var that = this,
                activeItem,
                selected = that.classes.selected,
                container = $(that.suggestionsContainer),
                children = container.find('.' + that.classes.suggestion);

            container.find('.' + selected).removeClass(selected);

            that.selectedIndex = index;

            if (that.selectedIndex !== -1 && children.length > that.selectedIndex) {
                activeItem = children.get(that.selectedIndex);
                $(activeItem).addClass(selected);
                return activeItem;
            }

            return null;
        },

        selectHint: function () {
            var that = this,
                i = $.inArray(that.hint, that.suggestions);

            that.select(i);
        },

        select: function (i) {
            var that = this;
            that.hide();
            that.onSelect(i);
        },

        moveUp: function () {
            var that = this;

            if (that.selectedIndex === -1) {
                return;
            }

            if (that.selectedIndex === 0) {
                $(that.suggestionsContainer).children().first().removeClass(that.classes.selected);
                that.selectedIndex = -1;
                that.el.val(that.currentValue);
                that.findBestHint();
                return;
            }

            that.adjustScroll(that.selectedIndex - 1);
        },

        moveDown: function () {
            var that = this;

            if (that.selectedIndex === (that.suggestions.length - 1)) {
                return;
            }

            that.adjustScroll(that.selectedIndex + 1);
        },

        adjustScroll: function (index) {
            var that = this,
                activeItem = that.activate(index);

            if (!activeItem) {
                return;
            }

            var offsetTop,
                upperBound,
                lowerBound,
                heightDelta = $(activeItem).outerHeight();

            offsetTop = activeItem.offsetTop;
            upperBound = $(that.suggestionsContainer).scrollTop();
            lowerBound = upperBound + that.options.maxHeight - heightDelta;

            if (offsetTop < upperBound) {
                $(that.suggestionsContainer).scrollTop(offsetTop);
            } else if (offsetTop > lowerBound) {
                $(that.suggestionsContainer).scrollTop(offsetTop - that.options.maxHeight + heightDelta);
            }

            if (!that.options.preserveInput) {
                that.el.val(that.getValue(that.suggestions[index].value));
            }
            that.signalHint(null);
        },

        onSelect: function (index) {
            var that = this,
                onSelectCallback = that.options.onSelect,
                suggestion = that.suggestions[index];

            that.currentValue = that.getValue(suggestion.value);

            if (that.currentValue !== that.el.val() && !that.options.preserveInput) {
                that.el.val(that.currentValue);
            }

            that.signalHint(null);
            that.suggestions = [];
            that.selection = suggestion;

            if ($.isFunction(onSelectCallback)) {
                onSelectCallback.call(that.element, suggestion);
            }
        },

        getValue: function (value) {
            var that = this,
                delimiter = that.options.delimiter,
                currentValue,
                parts;

            if (!delimiter) {
                return value;
            }

            currentValue = that.currentValue;
            parts = currentValue.split(delimiter);

            if (parts.length === 1) {
                return value;
            }

            return currentValue.substr(0, currentValue.length - parts[parts.length - 1].length) + value;
        },

        dispose: function () {
            var that = this;
            that.el.off('.autocomplete').removeData('autocomplete');
            that.disableKillerFn();
            $(window).off('resize.autocomplete', that.fixPositionCapture);
            $(that.suggestionsContainer).remove();
        }
    };

    $.fn.CFAutocomplete = function (options, args) {
        var dataKey = 'autocomplete';
        if (arguments.length === 0) {
            return this.first().data(dataKey);
        }

        return this.each(function () {
            var inputElement = $(this),
                instance = inputElement.data(dataKey);

            if (typeof options === 'string') {
                if (instance && typeof instance[options] === 'function') {
                    instance[options](args);
                }
            } else {
                if (instance && instance.dispose) {
                    instance.dispose();
                }
                instance = new Autocomplete(this, options);
                inputElement.data(dataKey, instance);
            }
        });
    };



})(jQuery);
