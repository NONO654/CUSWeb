const maxSupportedLength_withflag = 173;
const maxSupportedLength_withoutflag = 206;

define("DS/ENOXCADCATIAV5UI/ENOXCADFileNameValidation",
[
	'DS/i3DXCompassServices/i3DXCompassServices',
	'DS/WAFData/WAFData',
    'i18n!DS/ENOXCADCATIAV5UI/assets/nls/ENOXCADFileNameValidationNls'
],

function (i3DXCompassServices, WAFData, i18nENOXCADCATIAV5UI) {
    'use strict';

    var Services = {
        cache_data: {

        },

        //This method will be call by widget to validate file name
        checkfilenameValidity: function (filenameinput, callback) {
            var that = this;
            var errortext;
            var url = "";
            var IsAutoRenameActivated;
            //For multiple tenants we need platform id
            var envId = widget.getValue('x3dPlatformId');
            if (!envId || envId === undefined || envId === '') {
                envId = 'OnPremise'; //if no id, then default is "OnPremise"
            }

            //retrieve 3ddrive service
            i3DXCompassServices.getServiceUrl({
                serviceName: '3DSpace',
                platformId: envId,
                onComplete: function (URLService) {
                    url = URLService;
                    var AutoRenameActivated = that.cache_data["AutoRenameActivated"];
                    var attributename = "UT5-UniqueFileName";
                    if (AutoRenameActivated == null) {
                        url = url + "/resources/CATIAV5PowerBy/GlobalConfiguration/GetAttribute?tenant=" + envId + "&attributename=" + attributename;
                        var headers = {
                            'Accept': 'application/json',
                            'Content-Type': 'application/json',
                            'Accept-Language': widget.lang,
                        };
                        WAFData.authenticatedRequest(url, {
                            method: 'GET',
                            headers: headers,
                            timeout: 1000 * 60, // 1m
                            type: 'json', // {"attribute":"UT5-UniqueFileName","value":"XXXX"}
                            onComplete: function (payload) {
                                var result = payload.value;
                                if (result === "TRUE" || result === "true")
                                    that.cache_data["AutoRenameActivated"] = true;
                                else
                                    that.cache_data["AutoRenameActivated"] = false;
                                IsAutoRenameActivated = that.cache_data["AutoRenameActivated"];
                                errortext = that._checkfilenameValidity(filenameinput, IsAutoRenameActivated);
                                callback.call(null, errortext);
                            },
                            onFailure: function () {
                                //if web service failed,we will set the flag to false and take default value
                                IsAutoRenameActivated = false;
                                errortext = that._checkfilenameValidity(filenameinput, IsAutoRenameActivated);
                                callback.call(null, errortext);
                            },
                            onTimeout: function () {
                                //if web service failed,we will set the flag to false and take default value
                                 IsAutoRenameActivated = false;
                                 errortext = that._checkfilenameValidity(filenameinput, IsAutoRenameActivated);
                                 callback.call(null, errortext);
                             },
                        });
                    }
                    else {
                        //if we already did the web service call, then we will use the cache information next time
                        IsAutoRenameActivated = that.cache_data["AutoRenameActivated"];
                        errortext = that._checkfilenameValidity(filenameinput, IsAutoRenameActivated);
                        callback.call(null, errortext);
                    }
                },
                onFailure: function (err) {
                    //if we cant able to retrive url, we will set the flag to false and take default value
                    IsAutoRenameActivated = false;
                    errortext = that._checkfilenameValidity(filenameinput, IsAutoRenameActivated);
                    callback.call(null, errortext);

                }
            });
        },


        _checkfilenameValidity: function (filenameinput, IsAutoRenameActivated) {
            var errortext;

            //File size validation
            const Lengthlimit = IsAutoRenameActivated ? maxSupportedLength_withflag : maxSupportedLength_withoutflag;

            if (filenameinput.length > Lengthlimit) {
                errortext = i18nENOXCADCATIAV5UI.get("Size_error", { maxSupportedLength: Lengthlimit });
            }
            else {
                //Unsupported char validation
                var Unsupported_char;
                var regex = /[^a-zA-Z0-9\ \-\[\]\{}()+,-.=#@`~^_;!%&\'$]/g;
                var result = filenameinput.match(regex);

                if (result != null) {
                    var i;
                    for (i = 0; i < result.length; i++) {
                        if (Unsupported_char === undefined)
                            Unsupported_char = result[i];
                        else if (!Unsupported_char.includes(result[i]))
                            Unsupported_char += result[i];
                    }

                    var Unsupported = Unsupported_char.split("");

                    if (Unsupported !== undefined) {
                        errortext = i18nENOXCADCATIAV5UI.get("Unsupported_char", { char: Unsupported });
                    }
                } //extra spacing validation
                else if (filenameinput.startsWith(" ") && filenameinput.endsWith(" "))
                    errortext = i18nENOXCADCATIAV5UI.get("Space_Leading_Trailing");
                else if (filenameinput.startsWith(" "))
                    errortext = i18nENOXCADCATIAV5UI.get("Space_Leading");
                else if (filenameinput.endsWith(" "))
                    errortext = i18nENOXCADCATIAV5UI.get("Space_Trailing");;
            }

            return errortext;
        }
    };

    return Services;
});
