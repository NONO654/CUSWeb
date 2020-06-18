
//@fullReview  ZUR 16/02/13 2017x
/*global define, console*/
/*jslint plusplus: true*/
define('DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/ParamStepGeometry',
    [
        'egraph/core',
        'egraph/views',
        'egraph/utils'
    ],
    function(core, views, utils) {
        'use strict';

        var exports = {};

        function sign(x) {
            return typeof x === 'number' ? x ? x < 0 ? -1 : 1 : x === x ? 0 : NaN : NaN;
        }

        exports.ParamStepGeometry = function(stubScenario) {
            if (!isNaN(stubScenario)) {
                this.stubScenario = stubScenario;
            }
        };

        //StepGeometry.prototype.stubScenario = 1;   //gphSymbol
        //utils.inherit(exports.gphSymbol, views.HTMLView);
        //ParameterizationLifecycleWidget/Views

        exports.ParamStepGeometry.prototype.onupdate = function onupdate(e) {
            var x1, x2, y1, y2, stubminlength, randomHeight, iStub, signp,
                iIntervals, isum, j,
                maxLimit = 1.5;
            console.log("Build scenario " + this.stubScenario);
            console.log(e);

            x1 = e.cl1.c.aleft;
            y1 = e.cl1.c.atop;
            x2 = e.cl2.c.aleft;
            y2 = e.cl2.c.atop;

            // xm = 0.5*(x1 + x2);  //    xm = 0.9*x1 + 0.1*x2;
            stubminlength = 45;//50;
            if (this.stubScenario === 1) {
                e.set('path', [
                    core.PathCmd.M, x1, y1,
                    core.PathCmd.L, x2, y2
                ]);
            } else {
                randomHeight = 30 * Math.random();
                iStub = this.stubScenario;

                if (e.randomHeight == null) {
                    e.randomHeight = randomHeight;
                } else {
                    randomHeight = e.randomHeight;
                }

                signp = sign(iStub);
                //maxLimit = 1.5;//2
                if (Math.abs(iStub) > maxLimit) {
                    iIntervals = (Math.abs(iStub) - maxLimit);
                    isum = maxLimit;

                    for (j = 1; j <= iIntervals; j++) {
                        isum = isum + 0.5 / j;
                    }

                    iStub = signp * isum;
                }

                e.set('path', [
                    core.PathCmd.M, x1 + 3, y1,
                    core.PathCmd.L, x1 + 3, y1 + randomHeight - iStub * stubminlength,
                    core.PathCmd.L, x2, y2 + randomHeight - iStub * stubminlength,
                    core.PathCmd.L, x2, y2
                ]);
            }
        };

        return exports;
    });

/*global define*/
define('DS/ParameterizationSkeleton/Model/MappingModel',
    [
        'UWA/Core',
        'UWA/Class/Model'
    ], function (UWA, Model) {
        "use strict";
        return Model.extend({
            defaults: function() {
                return {
                    id: '',
                    title : '',
                    AttributeInfo : '',
                    TypeRelInfo : '',
                    InterfaceInfo : '',
                    TypeRelMapping : '',
                    InterfaceMapping : '',
                    AttributeMapping : '',
                };
            }
        });
    });

define('DS/ParameterizationSkeleton/Views/ParameterizationXEngineering/ParameterizationXEngineerConstants', [], function() {

    'use strict';


    const contants = {
    		NEW_NOT_DEPLOYED : 'NewNotDeployed',
    		USER_DEFINED : 'UserDefined',
    		DEPOLOYED : 'Deployed',
    		ADD : 'Add',
    		REMOVE : 'Remove',
    		MODIFY : 'Modify',
    		OPERATION : 'UserOperation',
    		ORDER : 'Order',
    		TYPE : 'Type',
    		NAME : 'Name',
    		VALUE : 'Value',
    		ATTRIBUTE : 'AttributeName',
    		ATTRIBUTE_NLS_NAME : 'Attribute_NLS',
    		COUNTER : 'CounterSize',
    		FORMULA_ROW : "FormulaRow",
    		FORMULA_CELL : "Formula",
    		STRATEGY_ROW : "StrategyRow",
    		BUSINESS_LOGIC : "BLDefined",
    		STRATEGY_CELL : "Strategy",
            FORMAT_FREE : 'Free',
            FORMAT_STRING :'String',
            FORMAT_ATTRIBUTE : 'Attribute',
            FORMAT_COUNTER : 'Counter',
            MAX_ROWS : 15,
            WIDTH_ARRAY: [15, 15, 15, 25, 15, 15]
    		
    };

    return  Object.freeze(contants);

});

/*@fullReview  ZUR 15/11/23 2017x Param Skeleton*/
/*global define*/
define('DS/ParameterizationSkeleton/Model/ParameterizationDomainModel',
     [
        'UWA/Core',
        'UWA/Class/Model'
    ], function (UWA, Model) {
        "use strict";
        return Model.extend({
            defaults: function() {
                return {
                    id : '',
                    family : ''
                };
            }
        });
    });


/*global define*/
define('DS/ParameterizationSkeleton/Model/ParameterizationLifecycle/LifecycleListModel',
    [
        'UWA/Class/Model'
    ], function (Model) {
        "use strict";
        return Model.extend({
            defaults: function() {
                return {
                    title : '',
                    id: '',
                    subtitle : '',
                    date : '',
                    content : '',
                    image : '',
                    icon: '',
                    modifyTopology : true,
                    renameStates: true,
                    supportRules: true
                };
            }
        });
    });


define('DS/ParameterizationSkeleton/Model/ParameterizationLifecycle/LifecycleModel',
[
    'UWA/Core',
    'UWA/Class/Model'
], function (UWA, Model) {
    return Model.extend({
        defaults: function() {
            return {
                id : '',
                states : '',
                transitions : '',
                checks: '',
                types: '',
                appCategory : '',
            	title : '',
                subtitle : '',               
            };
        }
    });
});


/*@fullReview  NZV  17/03/02 FUN066122 Added compareArray */
/*@fullReview  ZUR 15/07/29 2016xFD01 Param Widgetization NG*/
/*global define, widget, document, setTimeout, console*/
/*jslint plusplus: true*/
/*jslint nomen: true*/
define('DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
    [
        'UWA/Core',
        'UWA/Controls/Accordion',
        'DS/UIKIT/Accordion',
        'DS/UIKIT/Input/Button',
        'DS/UIKIT/Modal',
        'DS/UIKIT/Alert',
        'DS/UIKIT/Popover',
        'DS/UIKIT/Spinner',
        'DS/UIKIT/Autocomplete',
        'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS'
    ],
    function (UWA,
              UWAccordion, Accordion,
              Button,
              Modal,
              Alert, Popover, Spinner, Autocomplete,
              ParamSkeletonNLS) {

        'use strict';

        var UIview = {

            createFamilyAccordion : function () {
                var iAccord = new UWAccordion({
                    className: 'visu-debug-panel-section',
                    backgroundColor : 'white',
                    multiSelect : true
                });
                return iAccord;
            },

            createFamilyUIKITAccordion : function (parentDiv) {
                var iAccord = new Accordion({
                    className: 'styled divided filled',
                    exclusive: false,
                    items : []
                }).inject(parentDiv);
                return iAccord;
            },

            createInfoDiv : function (iTooltip) {
                var isubDiv =  UWA.createElement('div', {
                    'height'     : '5%'
                });
                UWA.createElement('p', {
                    text: iTooltip,// font-3dsbold 
                    'class': ''//font-3dslight
                }).inject(isubDiv);
                return isubDiv;
            },

            createParamsContainerDiv : function () {
                var iParamsDIV =  UWA.createElement('div', {
                        'id' : 'parametersDiv'
                    });
                return iParamsDIV;
            },

            createWdgAlert : function () {
                var iAlert = new Alert({
                    closable: true,
                    visible: true,
                    autoHide : true,
                    hideDelay : 2500
                });
                return iAlert;
            },

            beingDeployed: function (imageCell, imgTitle) {
                var paramDeploySpinner = new Spinner({visible : true});
                imageCell.empty();
                paramDeploySpinner.inject(imageCell);
                imageCell.set("Title", imgTitle);
            },

            beingModified : function (imageCell, imgTitle, iconSize) {
                //var imgClass = 'fonticon fonticon-2x fonticon-pencil';
                //var imgClass = 'fonticon fonticon-' + iconSize + 'x fonticon-pencil';
                var imgClass = 'fonticon fonticon-' + iconSize + 'x fonticon-cog';

                imageCell.empty();
                UWA.createElement('span', {
                    'class' : imgClass
                }).inject(imageCell);

                imageCell.set("Title", imgTitle);
            },

            updateIcon : function(result, imageCell) {

                var imgSpan,
                    imgTitle = ParamSkeletonNLS.deployedParamtxt,
                    imgClass = 'fonticon fonticon-2x fonticon-check',
                    iconColor = 'green';

                imageCell.empty();

                if (result != true) {
                    imgClass = 'fonticon fonticon-2x fonticon-alert';
                    imgTitle = ParamSkeletonNLS.notdeployedParamtxt;
                    iconColor = 'red';
                }
                imgSpan = UWA.createElement('span', {
                    'class' : imgClass
                }).inject(imageCell);
                imgSpan.setStyle("color", iconColor);
                imageCell.set("Title", imgTitle);
            },

            computePopoverPos : function (i, familyPosition, nbofRows) {
                var popoverPosition = "left";

                if (familyPosition === "first") {
                    popoverPosition = "bottom";
                } else if ((familyPosition === "last") && (i == nbofRows - 1)) {
                    popoverPosition = "top";
                }

                return popoverPosition;
            },

            isInteger : function (str) {
                str = str.trim();
                return (/^[-+]?[0-9]+$/).test(str);
            },

            isReal : function(value) {
                return ("." != value && "-" != value && "-." != value && /^-{0,1}\d*\.{0,1}\d*$/.test(value));
            },

            testDataType : function (iValue, iType) {
                if (iType === "integer") {
                    return this.isInteger(iValue);
                }
                return true;
            },

            getTypeErrorMsgNLS : function (iType) {
                if (iType === "integer") {
                    return ParamSkeletonNLS.Not_Integer;
                }
                return "error";
            },

            inputErrorCell : function (imageCell, imgTitle, imgColor, msgPopOver) {
                var imgSpan,
                    imgClass = 'fonticon fonticon-2x fonticon-attention';
                if (msgPopOver !== null) {
                    if (msgPopOver.isVisible) { msgPopOver.hide(); }
                    msgPopOver.destroy();
                } 
                imageCell.empty();
                imgSpan = UWA.createElement('span', {
                    'class' : imgClass
                }).inject(imageCell);

                imgSpan.setStyle("color", imgColor);
                imageCell.set("Title", "");
                msgPopOver = new Popover({
                    target   : imgSpan,
                    trigger  : "hover",
                    animate  : "true",
                    position : 'top',
                    body     : imgTitle,
                    title    : ''
                });
                msgPopOver.toggle();
                if (msgPopOver.isVisible) {
                    setTimeout(function () {msgPopOver.hide(); }, 3000);
                }
                return msgPopOver;
            },

            buildPopoverSpan : function (iContainerCell, tooltipNlsTxt) {
                var popoverTooltip,
                    imgInfoSpan = UWA.createElement('span', {
                        'class' : 'fonticon fonticon-info'
                    }).inject(iContainerCell);

                imgInfoSpan.setStyle("color", "black");

                popoverTooltip = new Popover({
                    target   : imgInfoSpan,
                    trigger  : "hover",
                    animate  : "true",
                    position : "top",
                    body     : tooltipNlsTxt,
                    title    : ''
                });
            },


            buildDeployStsCell : function (isParamDeployed, cellWidth, iconSize, cellAlign) {
                var imgCell, imgSpan,
                    imgTitle = ParamSkeletonNLS.deployedParamtxt,
                    imgClass = 'fonticon fonticon-' + iconSize + 'x fonticon-check',
                    iconColor = 'green';

                if (isParamDeployed === "false") {
                    imgClass = 'fonticon fonticon-' + iconSize + 'x fonticon-cog';
                    imgTitle =  ParamSkeletonNLS.notdeployedParamtxt;
                    iconColor = 'orange';
                } else if (isParamDeployed === "NewNotDeployed") {
                    imgClass = 'fonticon fonticon-' + iconSize + 'x fonticon-cog';
                    imgTitle =  ParamSkeletonNLS.newNotdeployedParam;
                    iconColor = 'black';
                }

                imgCell = UWA.createElement('td', {
                    'width' : cellWidth, //'15%',
                    'align' : cellAlign,//'class': 'paramtd','vertical-align': 'text-bottom',
                    'title' : imgTitle
                });

                imgSpan = UWA.createElement('span', {
                    'class' : imgClass
                }).inject(imgCell);

                imgSpan.setStyle("color", iconColor);
                imgCell.setStyle("vertical-align", "text-bottom");
                imgCell.setStyle("min-width", "46px");//NZV-fixed spinner issue
                return imgCell;
            },

            buildControlCell : function (iParamID, iArgument, cellWidth) {
                var controlObjectCell = UWA.createElement('td', {
                    'width' : cellWidth,
                    'align' : 'right'//nzv-IR-574318-3DEXPERIENCER2019x
                });
                controlObjectCell.setData('argumentNode', {
                    paramid     : iParamID,
                    argumentid  : iArgument.id,
                    defaultval  : iArgument.defaultValue,
                    argtype     : iArgument.type,
                    inputtype   : iArgument.input
                });
                controlObjectCell.setStyle("vertical-align", "text-bottom");
                return controlObjectCell;
            },

            createApplyResetToolbar : function (insertdivID, activateApplyBtn, applyParams, confirmationModalShow) {
                var applyDiv, tableButtons, lineButtons, buttonApplyCell, applyBttn,
                    buttonResetCell, resetBbttn;
                    //that = this;
                    //resetwidth = '100%';

                applyDiv =  UWA.createElement('div', {
                    'id': 'ApplyResetDiv'
                }).inject(insertdivID);
                //                            
                tableButtons = UWA.createElement('table', {
                    'class' : '',
                    'id' : '',
                    'width' : '100%'
                }).inject(applyDiv);

                lineButtons = UWA.createElement('tr').inject(tableButtons);//tbody

                if (activateApplyBtn === true) {
                    buttonApplyCell = UWA.createElement('td', {
                        'width' : '50%',
                        'Align' : 'left'
                    }).inject(lineButtons);

                    applyBttn =  new Button({
                        className: 'primary',
                        id : 'buttonExport',
                        icon : 'export',//'download'//value: 'Button',          
                        attributes: {
                            disabled: false,
                            title: ParamSkeletonNLS.Applytooltip,//IR-651121-3DEXPERIENCER2019x/20x
                            text : ParamSkeletonNLS.Apply
                        },
                        events: {
                            onClick: function () {
                                applyParams();
                            }
                        }
                    }).inject(buttonApplyCell);
                    applyBttn.getContent().setStyle("width", 130);
                }

                buttonResetCell = UWA.createElement('td', {
                    'width' : '50%',
                    'Align' : 'right'//center
                }).inject(lineButtons);

                resetBbttn = new Button({
                    className: 'warning',
                    icon: 'loop',
                    attributes: {
                        disabled: false,
                        title: ParamSkeletonNLS.ResetOnServertooltip,
                        text : ParamSkeletonNLS.Reset
                    },
                    events: {
                        onClick: function () {
                            //that.resetParamsinSession();//testPreviewBlock();                               
                            confirmationModalShow();
                        }
                    }
                }).inject(buttonResetCell);

                resetBbttn.getContent().setStyle("width", 130);
                return applyDiv;
            },

            buildFormulaLine : function () {
                var cellLabel,
                    FormulaDetail = '{' + ParamSkeletonNLS.Prefix + '}-{' + ParamSkeletonNLS.Interfix + '}-<' + ParamSkeletonNLS.Counter + '>-{' + ParamSkeletonNLS.Suffix + '}',
                    lineParam = UWA.createElement('tr', {title: ''});

                UWA.createElement('td', {
                    'width': '30%',
                    'title': ParamSkeletonNLS.FormulaTxt,
                    'html' : ParamSkeletonNLS.FormulaTxt
                }).inject(lineParam);

                cellLabel = UWA.createElement('td',
                    {'width': '70%', 'colspan': '2', 'align': 'left', 'title': ''}).inject(lineParam);

                UWA.createElement('p', {
                    text: FormulaDetail,
                    'class': 'lead'//'uwa-input'//'width':'100%'    
                }).inject(cellLabel);

                return lineParam;
            },

            UpdateFinalFormatOverView : function(iPrefix, iAffix, iSuffix, iSeparator, iAppType, iInput) {
                var previewValue;

                if (iAffix != "") {
                    iAffix  = iAffix + iSeparator;
                    if (iPrefix != "") { iPrefix = iPrefix + iSeparator; }
                } else if ((iAppType == "CBP") && (iPrefix != "")) {
                    //To fix IR-529946-3DEXPERIENCER2017x\18x removed test for iAppType == "CBP"
                    //IR-685759-3DEXPERIENCER2019x\20x : Revert change which we made with IR-529946-3DEXPERIENCER2017x\18x 
                    iPrefix = iPrefix + iSeparator;
                }

                if (iSuffix != "") {iSuffix = iSeparator + iSuffix; }

                previewValue = iPrefix + iAffix + '<' + ParamSkeletonNLS.Counter + '>' + iSuffix;
                iInput.setValue(previewValue);
                iInput.elements.input.title = previewValue;
            },

            getNamingControlInput : function (inputControls, inputID) {
                var foundInput;
                inputControls.forEach(function (iInput) {
                    if (iInput.elements.input.id == inputID) {
                        foundInput =  iInput;
                    }
                });
                return foundInput;
            },

            getCustoNamingElement : function (custoNamingsArray, iType) {
                var i;
                for (i = 0; i < custoNamingsArray.length; i++) {
                    if (custoNamingsArray[i].objTypeID == iType) {
                        return custoNamingsArray[i];
                    }
                }
                return custoNamingsArray[0];//default
            },

            getIndexInNamingArray : function(custoNamingsArray, iType) {
                var i;
                for (i = 0; i < custoNamingsArray.length; i++) {
                    if (custoNamingsArray[i].objTypeID == iType) {
                        return i;
                    }
                }
                return 0;
            },

            getCommonNamingElementItr : function(commonNamingArray, iID) {
                var i;
                for (i = 0; i < commonNamingArray.length; i++) {
                    if (commonNamingArray[i].namingID == iID) {
                        return i;
                    }
                }
                return 0;//default
            },

            testSpecialCharacters : function (iString, iAdditionalCharsToTest) {
                var i,
                    iChars = "!#$%^&*()+=[]\\\';,/{}|\":<>?";//-

                if (typeof iAdditionalCharsToTest === 'undefined') {
                    iAdditionalCharsToTest = '';
                } else {
                    iChars += iAdditionalCharsToTest;
                }

                for (i = 0; i < iString.length; i++) {
                    if (iChars.indexOf(iString.charAt(i)) != -1) {
                        return true;
                    }
                }

                return false;
            },

            containsAccents : function (iString) {
                var i,
                    accentChars = "ÀÃÂÄÅÇÑñÇçÈÉÊËÒÓÔÕÖØáàâãäåèéêëðòóôõöøùúûüýÿÑñçÙÚÛÜìîïÎÌ";
                for (i = 0; i < iString.length; i++) {
                    if (accentChars.indexOf(iString.charAt(i)) !== -1) {
                        return true;
                    }
                }
                return false;
            },

            containsBlanks : function (iStr) {
                if (/\s/.test(iStr)) {
                    return true;
                }
                return false;
            },

            removeBlancks : function (iInputStr) {
                return iInputStr.replace(/ /g, '');
            },

            CheckforRaisedWarnings : function(warnArrays) {
                var i;
                for (i = 0; i < warnArrays.length; i++) {
                    if (warnArrays[i].warnRaised == true) {
                        return "WARN";
                    }
                }
                return "OK";
            },

            getNamingDeployCellSts : function (tbodyreflist) {
                var iLines = tbodyreflist[0].children;
                return (iLines[0].cells[2]);
            },

            compareArray : function(arr1, arr2) {
                var isBothSame = false,
                    elementsFound = 0;

                if (arr1.length != arr2.length) {
                    return isBothSame;
                }

                arr1.forEach(function (arr1Element) {
                    arr2.forEach(function (arr2Element) {
                        if (arr2Element === arr1Element) {
                            elementsFound++;
                            // break;
                        }
                    });
                });

                if (elementsFound == arr1.length) {
                    isBothSame =  true;
                }
                return isBothSame;
            },

            computeColumnsWidths : function (columnsList, widthArray) {
                var i, meanWidth,
                    initArrayLength = widthArray.length,
                    newArrayWidth = [];

                newArrayWidth.push(widthArray[0]);
                newArrayWidth.push(widthArray[1]);

                if (columnsList.length > 0) {
                    meanWidth = Math.round(widthArray[2] / columnsList.length);
                }

                for (i = 0; i < columnsList.length; i++) {
                    if (columnsList[i].widgetSize !== undefined) {
                        newArrayWidth.push(parseInt(columnsList[i].widgetSize, 10));
                    } else {
                        newArrayWidth.push(meanWidth);
                    }
                }
                newArrayWidth.push(widthArray[initArrayLength - 1]);
                return newArrayWidth;
            },

            buildImgSpan : function (iconChoice, iconSize, iconColor) {
                var imgClass = 'fonticon fonticon-' + iconSize + 'x fonticon-' + iconChoice,
                    imgSpan = UWA.createElement('span', {
                        'class' : imgClass
                    });

                imgSpan.setStyle("color", iconColor);
                return imgSpan;
            },

            buildImgCell : function (iconChoice, iconSize, iconColor, imgTitle, cellWidth, cellAlign) {
                var imgCell, imgSpan;

                imgCell = UWA.createElement('td', {
                    'width' : cellWidth, //'15%',
                    'align' : cellAlign,//'class': 'paramtd','vertical-align': 'text-bottom',
                    'title' : imgTitle
                });
                imgSpan = UIview.buildImgSpan(iconChoice, iconSize, iconColor);
                imgSpan.inject(imgCell);
                imgCell.setStyle("vertical-align", "text-bottom");

                return imgCell;
            },
            //NZV : Added with FUN085423 and removed createDeleteActionElements
            createActionElements : function (iTitle, removebtn) {
                var actionelts = [], actionSpan = UWA.createElement('span'), actionBtn, actionPop;
                if (removebtn == true) {
                    actionBtn = new Button({
                        className: 'close',
                        icon: 'fonticon fonticon-trash fonticon-1.5x',//value: 'Button', //fonticon-cancel  fonticon-minus-circled    
                        attributes: {
                            disabled: false,
                            'aria-hidden' : 'true'
                        }
                    }).inject(actionSpan);
                } else {
                    actionBtn = new Button({
                        className: 'close',
                        icon: 'fonticon fonticon-pencil fonticon-1.5x',//value: 'Button', //fonticon-cancel  fonticon-minus-circled    
                       
                        attributes: {
                            disabled: false,
                            'aria-hidden' : 'true'
                        }
                    }).inject(actionSpan);                  
                }

                actionPop = new Popover({
                      //class: 'parampopover',
                    target: actionSpan,//iCell,                        
                    trigger : "hover",
                    animate: "true",
                    position: "top",
                    body: iTitle,
                    title: ''//iParamObj.nlsKey
                });

                actionelts.push(actionSpan);
                actionelts.push(actionBtn);
                actionelts.push(actionPop);
                
                return actionelts;
            },

            buildColumnsTitleLine : function (columnsList, widthArray) {
                var i, columnCell,
                    titlesLine = UWA.createElement('tr', {title: ''});

                columnCell = UWA.createElement('td', {
                    'width' : widthArray[0].toString() + '%'
                }).inject(titlesLine);

                columnCell = UWA.createElement('td', {
                    'width' : widthArray[1].toString() + '%'
                }).inject(titlesLine);

                for (i = 0; i < columnsList.length; i++) {

                    columnCell = UWA.createElement('td', {
                        'width' : widthArray[i + 2].toString() + '%',
                        'title' : columnsList[i].tooltipNlsKey,
                        'id'    : columnsList[i].id
                    }).inject(titlesLine);

                    UWA.createElement('h4', {
                        text   : columnsList[i].nlsKey,
                        'class': 'font-3dslight' // font-3dsbold
                    }).inject(columnCell);
                }

                columnCell = UWA.createElement('td', {
                    'width' : widthArray[widthArray.length - 1].toString() + '%'
                }).inject(titlesLine);

                UWA.createElement('h4', {
                    text   : 'isDeployed',
                    'class': 'font-3dslight' // font-3dsbold
                }).inject(columnCell);

                return titlesLine;
            },

            buildSeparationLine : function (iText) {
                var cellTitle,
                    sepLine = UWA.createElement('tr');

                cellTitle = UWA.createElement('td', {
                    'colspan': '3',
                    'align': 'left'
                }).inject(sepLine);

                UWA.createElement('h4', {
                    text: iText,
                    'class': 'font-3dslight'
                }).inject(cellTitle);

                return sepLine;
            },

            createParamMask : function (iElement, iText) {
                var imgClass = 'fonticon fonticon-1x fonticon-attention',
                    imask = new UWA.createElement('div', { 'class': 'pmask' });

                new UWA.createElement('div', {
                    'class': 'pmask-wrapper',
                    html: {
                        tag: 'div',
                        'class': 'pmask-content',
                        html: [
                            new UWA.createElement('span', {
                                'class' : imgClass
                            }),
                            new UWA.createElement('span', {
                                'class': 'text',
                                text: iText
                            })
                        ]
                    }
                }).inject(imask);

                imask.inject(iElement);
            },

            isOnTheCloud : function (platformID) {

                if ((platformID !== null) &&
                        (platformID !== "") &&
                           (platformID != "OnPremise")) {
                    return true;
                }

                return false;
            },

            buildNoLicenseUI : function () {

                var licenseAlert = new Alert({
                    className : 'param-alert',
                    closable: true,
                    visible: true,
                    renderTo : document.body,
                    autoHide : false,
                    hideDelay : 5000,
                    messageClassName : 'warning'
                });

                return licenseAlert;
            },

            // getDisplayNameForTenant : function (iTenantID, iPlaformCollection) {

            //     var iTenantName = iTenantID;

            //     iPlaformCollection.forEach(function (model) {
            //         if (model.get('id') === iTenantID) {
            //             iTenantName = model.get('displayName');
            //         }
            //     });

            //     return iTenantName;
            // },

            getObjValFromACollection : function (valueToCompare, collectionOfObject, propNameToCompare, propNameToFetch) {

                var resultValue = "";

                collectionOfObject.forEach(function (model) {
                    if (model[propNameToCompare] === valueToCompare) {
                        resultValue = model[propNameToFetch];
                    }
                });

                return resultValue;
            },

            isDashboardChoosenTenantInPreferences : function (iDashboardTenantID, iPreferences) {

                var isTenantInPreferences = false;

                iPreferences.forEach(function (iPref) {
                    if (iPref.id === iDashboardTenantID) {
                        isTenantInPreferences = true;
                    }
                });

                return isTenantInPreferences;
            },
            compareContentNamingObject : function(Obj1, Obj2) {
                if (Obj1.nlsKey !== undefined && Obj2.nlsKey !== undefined) {
                    return Obj1.nlsKey.localeCompare(Obj2.nlsKey);
                }
            },
            //ZUR - IR-518037-3DEXPERIENCER2017x\18, IR-689657-3DEXPERIENCER2019x
            showContextualDeleteModal : function (iTargetElement, modalCssClass, nlsMessage, nlsMsgOnOkBtn, nlsMsgOnCancelBtn, nlsTitle, removeOperation, data) {
                var deleteConfirmModal, deleteDiv,
                    lineModal, iCell, modalDeleteBtn, modalCancelBtn, mainText;

                deleteDiv = UWA.createElement('div', {
                    'id': 'deleteAttributeConfDiv'
                });

                lineModal = UWA.createElement('tr').inject(deleteDiv);
                iCell = UWA.createElement('td').inject(lineModal);

                mainText = UWA.createElement('p', {
                    text   : nlsMessage,
                    'class': 'font-3dslight'
                }).inject(iCell);

                UWA.createElement('br').inject(mainText);
                UWA.createElement('br').inject(mainText);

                UWA.createElement('p', {
                    text   : ParamSkeletonNLS.AreYouWantToProceed,
                    'class': 'font-3dslight'
                }).inject(mainText);

                modalDeleteBtn = new Button({
                    value : nlsMsgOnOkBtn, //ParamSkeletonNLS.RemoveElement,
                    className: 'attrConfRemoveBtn warning',
                    id    : "modalOKButton"
                });

                modalCancelBtn = new Button({
                    value : nlsMsgOnCancelBtn, //ParamSkeletonNLS.CancelButton,
                    className: 'attrConfCancelBtn default',
                    id    : 'modalCancelButton'
                });

                deleteConfirmModal = new Modal({
                    className : modalCssClass,
                    overlay : true,
                    closable : true,
                    header : '<h4>' + nlsTitle/*ParamSkeletonNLS.ConfirmDelete*/ + '</h4>',
                    body :   deleteDiv,
                    footer  : [ modalDeleteBtn, modalCancelBtn ]
                }).inject(iTargetElement);
                //deleteConfirmModal.setStyle("width")
                deleteConfirmModal.getContent().getElements('.attrConfRemoveBtn').forEach(function (element) {
                    element.addEvent('click', function () {
                        deleteConfirmModal.destroy();
                        removeOperation(data);
                    });
                });

                deleteConfirmModal.getContent().getElements('.attrConfCancelBtn').forEach(function (element) {
                    element.addEvent('click', function () {
                        deleteConfirmModal.destroy();
                    });
                });
                deleteConfirmModal.show();
            },

            showSearchInput: function(that) {
                var root, placeHolderMsg, fragmentSearch, searchDiv, noResultsMessage,
                    prefix = that.model._attributes.domainid, selectedItem,
                    autoCompAxiom = [], searchNode = null,
                    fragmentDataSet = {
                        'name' : 'Fragments',
                        'items': [{}],
                        searchEngine: function (dataset, text) {
                            var items = dataset.items;
                            if (text.length) {
                                return items.filter(function (item) {
                                    return (item.value && (item.subLabel.toLowerCase().contains(text.toLowerCase()) || item.value.toLowerCase().contains(text.toLowerCase())));
                                });
                            }
                            return [];
                        }
                    };

                that.collection._models.forEach(function (val) {
                    autoCompAxiom.push({
                        value : val._attributes.title,
                        subLabel : val._attributes.id
                    });
                });
                if (that.model.id === "AttributeDef") {
                    placeHolderMsg =  ParamSkeletonNLS.SelectAType; 
                    noResultsMessage = ParamSkeletonNLS.NoTypeFound;
                } else if (that.model.id === "XCADParameterization") {
                    placeHolderMsg =  ParamSkeletonNLS.SelectACADConfiguration; 
                    noResultsMessage = ParamSkeletonNLS.NoCADConfigurationFound;
                } else {
                    placeHolderMsg = ParamSkeletonNLS.SelectAPolicy; 
                    noResultsMessage = ParamSkeletonNLS.NoPolicyFound;
                }
                searchNode = this.container.getElement("#searchAutoCompleteInput");
                if (searchNode !== null) {
                    searchNode.destroy();
                }
                fragmentDataSet.items = fragmentDataSet.items.concat(autoCompAxiom);
                searchDiv = UWA.createElement('div', {
                    'id': 'searchAutoCompleteInput',
                    'class':'autoCompleteSearch'
                }).inject(this.container.children[0]);

                fragmentSearch = new Autocomplete({
                    multiSelect: false,
                    showSuggestsOnFocus: true,
                    noResultsMessage: noResultsMessage,
                    allowFreeInput: false,
                    placeholder: placeHolderMsg,
                    filterEngine: function (suggestions) { 
                        return suggestions;
                    },
                    events: {
                        onSelect: function() {
                            selectedItem = fragmentSearch.getSelection();
                            root = '/domains/' + prefix + '/parentRenderer/' + selectedItem.subLabel + '/?f=0';
                            that.pSkeleton.setRoute(root);
                            fragmentSearch.reset();
                        },
                        onKeyDown: function(e) {//IR-673291-3DEXPERIENCER2019x\20x
                            if (e.keyCode === 13) {
                                e.preventDefault();
                            }
                        },
                        onKeyUp: function(e) {
                            if (e.keyCode === 13) {
                                fragmentSearch.showAll();
                            }
                        }
                    }
                }).inject(searchDiv);

                fragmentSearch.addDataset(fragmentDataSet);//fragmentSearch.focus();
            }
        };

        return UIview;
    });

/*global define,clearTimeout,setTimeout */
define('DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/ParamNodeView',
    [
        'UWA/Core',
        'egraph/views',
        'egraph/utils',
        'DS/UIKIT/Popover',
        'DS/UIKIT/Input/Text',
        'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS'
    ], function(UWA,
                views, utils, Popover,
                Text,
                ParamSkeletonNLS) {
        // 'DS/Param/Views/LifecycleViewUtilities'
        "use strict";
        var callfctrename, localthat,
            exports = {},
            areStatesRenamable = true,
            modifyTopology = true;

        exports.ParamNodeView = function(that, renameStates, iModifyTopology) {
            UWA.log("ParamNodeView::Inside");
           // callfctrename = renamefct;
            callfctrename = that.handleRenamingIssues;
            localthat = that;
            areStatesRenamable = renameStates;
            modifyTopology = iModifyTopology;
            views.HTMLNodeView.call(this);
        };

        utils.inherit(exports.ParamNodeView, views.HTMLNodeView);

        //Redefining the view of a node
        exports.ParamNodeView.prototype.buildNodeElement = function (iNode) {
            UWA.log("buildNodeElement");
            UWA.log(iNode);
            return customizeNode(iNode);
        };

        //Redefining actions of node select
        exports.ParamNodeView.prototype.onselect = function(e, selected) {
            UWA.log("ParamNodeView - onselect");
          /*if (selected) return (this.selectNode(e));  */
        };

        function customizeNode(iNode) {

            var mainDiv, iTable, newRow, newCell, imgSpan, stateNameInput, timerconn, stateLockPop,
                nodeLocked = false,
                lockTitle = ParamSkeletonNLS.StateCriticalText.format(iNode.name),
                ititle = iNode.name;

            if (!areStatesRenamable) {
                ititle = ititle + " - " + ParamSkeletonNLS.StatesCannotBeRenamedText;
            }

            mainDiv = UWA.createElement("div");
            iTable = UWA.createElement("table", {'height': '100%'}).inject(mainDiv);
            newRow = UWA.createElement('tr').inject(iTable);
            newCell = UWA.createElement('td',
                        {'width': '100%', 'colspan': '2'}).inject(newRow);

            stateNameInput = new Text({
                placeholder: "...",
                attributes: {
                    value: iNode.name,
                    multiline: false,
                    title : ititle,
                    disabled: !areStatesRenamable,
                    readonly: !areStatesRenamable
                },
                events: {
                    onChange: function () {
                        UWA.log("onchange");
                        this.elements.input.title = this.getValue();
                        callfctrename(iNode, localthat, this.getValue());
                      //  UIUtilities.beingModified(imgCell, ParamWdgNLS.Being_Modified);
                      //  updateParameterOnChange(this,controlObjectCell,imgCell);
                    },
                    onKeyDown: function () {
                        UWA.log("onKeyDown");

                        if (timerconn) { clearTimeout(timerconn); }

                        timerconn = setTimeout(function() {
                            callfctrename(iNode, localthat, stateNameInput.getValue());
                        }, 20);

                      //  UIUtilities.beingModified(imgCell, ParamWdgNLS.Being_Modified);
                    }
                }
            }).inject(newCell);

            newRow = UWA.createElement('tr').inject(iTable);
            newCell = UWA.createElement('td',
                        {'width': '50%', 'align' : 'left'}).inject(newRow);

            if (!modifyTopology) {
                nodeLocked = true;
                lockTitle = ParamSkeletonNLS.TopologyNotModifiable;
            } else if (iNode.isCritical === "true") {
                nodeLocked = true;
            }

            if (nodeLocked) {
                imgSpan = UWA.createElement('span', {
                    'class' : 'fonticon fonticon-2x fonticon-lock'
                }).inject(newCell);

                imgSpan.setStyle("color", "#77797c");
                newCell.setStyle("vertical-align", "bottom");//"text-bottom"

                stateLockPop = new Popover({
                    target: imgSpan,
                    trigger : "hover",
                    animate: "true",
                    position: "top",
                    body: lockTitle,
                    title: ''//iParamObj.nlsKey
                });
            }

            UWA.createElement('td',
                        {'width': '50%'}).inject(newRow);

            mainDiv.addClassName("my-node");
            return mainDiv;
        }

        return exports;
    });

/*! Copyright 2017, Dassault Systemes. All rights reserved. */
/*global define, widget, document, setTimeout, console*/
/*jslint nomen: true*/
/*@fullReview  ZUR 16/02/13 2017x HL*/
define('DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/LifecycleDescriptionView',
    [
        'UWA/Core',
        'UWA/Class/View',
        'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS'
    ],
    function (UWA, View,
              ParamSkeletonNLS) {

        'use strict';

        var extendedView =  View.extend({
            tagName: 'div',
            className: 'generic-detail',

            init: function (options) {
                options = UWA.clone(options || {}, false);
                this._parent(options);
            },

            render: function () {
                var that = this;

                if (this.collection._models.length === 0) {
                    UWA.log("LifecycleDescriptionView::fist time");
                    this.listenTo(this.collection, {
                        onSync: that.onCompleteRequestDescription
                    });
                } else {
                    UWA.log("LifecycleDescriptionView::model already there");
                    that.onCompleteRequestDescription();
                }

                return this;
            },

            onCompleteRequestDescription : function () {
                UWA.log("LifecycleDescriptionView::onCompleteRequestDescription::");

                var mainDiv, newRow, newCell, SummaryTable, opTable, opTbody, optionText,
                    summaryDiv, operationsDiv, tooltiptoShow;

                mainDiv =  UWA.createElement('div', {
                    'id': 'DescriptionMainDiv'
                });

                tooltiptoShow = this.collection._models[0]._attributes.tooltip;

                if (!tooltiptoShow.startsWith("OOTBParameterization.LifecycleTopology")) {
                    summaryDiv =  UWA.createElement('div', {'id': 'summaryDiv'}).inject(mainDiv);
                    SummaryTable =  UWA.createElement('table', {
                        'padding-left': '100'
                    }).inject(summaryDiv);

                    newRow = UWA.createElement('tr', {title: ParamSkeletonNLS.SummaryText}).inject(SummaryTable);
                    //newRow.style.backgroundColor = "#659ac2";
                    newCell = UWA.createElement('td',
                            {'width': '100%', 'title': ParamSkeletonNLS.SummaryText}).inject(newRow);

                    UWA.createElement('h3', {
                        text: ParamSkeletonNLS.SummaryText,//this.collection._models[0]._attributes.title,
                        'class': ''//font-3dslight font-3dsbold  
                    }).inject(newCell);

                    newRow = UWA.createElement('tr').inject(SummaryTable);
                    newCell = UWA.createElement('td', {'width': '100%'}).inject(newRow);

                    UWA.createElement('h4', {
                        text   : tooltiptoShow,
                        'class': 'font-3dslight'
                    }).inject(newCell);
                }

                operationsDiv =  UWA.createElement('div', {
                    'id': 'operationsDiv'
                }).inject(mainDiv);

                SummaryTable =  UWA.createElement('table', {
                    'padding-left': '100'
                }).inject(operationsDiv);

                newRow = UWA.createElement('tr').inject(SummaryTable);
                //newRow.style.backgroundColor = "#659ac2";
                newCell = UWA.createElement('td', {
                    'width': '100%',
                    'title': ParamSkeletonNLS.PossibleOperationsTxt
                }).inject(newRow);

                UWA.createElement('h3', {text: ParamSkeletonNLS.PossibleOperationsTxt}).inject(newCell);

                newRow = UWA.createElement('tr').inject(SummaryTable);
                newCell = UWA.createElement('td', {'width': '100%'}).inject(newRow);
                UWA.createElement('h4', {
                    text   : ParamSkeletonNLS.possibleOperationsText + this.collection._models[0]._attributes.title,// font-3dsbold
                    'class': 'font-3dslight'
                }).inject(newCell);

                opTable = UWA.createElement('table', {
                    'id': 'optionstable',
                    'width': '30%',
                    'class': 'table table-condensed table-hover table-bordered'
                }).inject(operationsDiv);

                opTbody =  UWA.createElement('tbody', {
                    'width': '50%',
                    'class': ''
                }).inject(opTable);

                newRow = UWA.createElement('tr').inject(opTbody);
                newCell = UWA.createElement('td', {'width': '80%', 'class': 'active'}).inject(newRow);

                UWA.createElement('h4', {
                    text   : ParamSkeletonNLS.ModifyTopologyTxt,// font-3dsbold
                    'class': 'font-3dslight'
                }).inject(newCell);
                newCell = UWA.createElement('td', {'width': '20%'}).inject(newRow);

                optionText = ParamSkeletonNLS.NoText;
                if (this.model.get("modifyTopology")) {
                    optionText = ParamSkeletonNLS.YesText;

                }

                UWA.createElement('h4', {
                    text   : optionText,// font-3dsbold
                    'class': 'font-3dslight'
                }).inject(newCell);

                newRow = UWA.createElement('tr').inject(opTbody);
                newCell = UWA.createElement('td', {'width': '80%', 'class': 'active'}).inject(newRow);

                UWA.createElement('h4', {
                    text   : ParamSkeletonNLS.RenameStatesTxt,// font-3dsbold
                    'class': 'font-3dslight'
                }).inject(newCell);

                optionText = ParamSkeletonNLS.NoText;
                if (this.model.get("renameStates")) {
                    optionText = ParamSkeletonNLS.YesText;
                }

                newCell = UWA.createElement('td', {'width': '20%'}).inject(newRow);
                UWA.createElement('h4', {
                    text   : optionText,// font-3dsbold
                    'class': 'font-3dslight'
                }).inject(newCell);

                newRow = UWA.createElement('tr').inject(opTbody);
                newCell = UWA.createElement('td', {'width': '80%', 'class': 'active'}).inject(newRow);
                UWA.createElement('h4', {
                    text   : ParamSkeletonNLS.AddPromotionRulesTxt,// font-3dsbold
                    'class': 'font-3dslight'
                }).inject(newCell);

                optionText = ParamSkeletonNLS.NoText;
                if (this.model.get("supportRules")) {
                    optionText = ParamSkeletonNLS.YesText;
                }

                newCell = UWA.createElement('td', {'width': '20%'}).inject(newRow);
                UWA.createElement('h4', {
                    text   : optionText,// font-3dsbold
                    'class': 'font-3dslight'
                }).inject(newCell);

                this.container.setContent(mainDiv);
            },

            removeElement : function() {
                UWA.log(":");
            },

            restoreStates : function() {
                UWA.log(":");
            },

            showAddElementsModal : function() {
                UWA.log(":");
            },

            destroy : function() {
                this.stopListening();
                this._parent.apply(this, arguments);
            }

        });

        return extendedView;
    });

/*global define*/
define('DS/ParameterizationSkeleton/Views/ParameterizationDataModeling/AttributesTypesDefine',
    [
    ], function() {
        "use strict";
        var iList = {

            getListOfHandledTypes : function () {

                var typesArray = [];
                typesArray.push({ type: 'String', length: '' });
                typesArray.push({ type: 'String', length: '16' });
                typesArray.push({ type: 'String', length: '40' });
                typesArray.push({ type: 'String', length: '80' });
                typesArray.push({ type: 'Boolean', length: '' });
                typesArray.push({ type: 'Integer', length: '' });
                typesArray.push({ type: 'Real', length: '' });
                typesArray.push({ type: 'Date', length: '' });
                return typesArray;
            }
        };

        return iList;
    });

/*global define*/
define('DS/ParameterizationSkeleton/Model/ParameterizationDataModeling/TypeModel',
    [
        'UWA/Core',
        'UWA/Class/Model'
    ], function (UWA, Model) {
        "use strict";
        return Model.extend({
            defaults: function() {
                return {
                    id: '',
                    title : '',
                    listofAttributes : '',
                    listofSynchros : '',
                    listofSystemAttribues : '', //NZV :IR-540216-3DEXPERIENCER2018x
                    typeCategory : '' //VPM/CBP
                };
            }
        });
    });

/*global define*/
define('DS/ParameterizationSkeleton/Model/ParameterizationXCAD/XCADListModel',
    [
        'UWA/Class/Model'
    ], function (Model) {
        "use strict";
        return Model.extend({
            defaults: function() {
                return {
                    id: '',
                    title : '',
                    subtitle : '',
                    domainid : '',
                    image : ''
                };
            }
        });
    });

/*global define*/
define('DS/ParameterizationSkeleton/Model/ParameterizationXCAD/XCADModel',
    [
        'UWA/Class/Model'
    ], function (Model) {
        "use strict";
        return Model.extend({
            defaults: function() {
                return {
                    id: ''
                };
            }
        });
    });

/*@fullReview  ZUR 15/11/23 2017x Param Skeleton*/
/*global define*/
define('DS/ParameterizationSkeleton/Model/ParameterizationDomainsListModel',
    [
        'UWA/Core',
        'UWA/Class/Model'
    ], function (UWA, Model) {
        "use strict";
        return Model.extend({
            defaults: function() {
                return {
                    id  : '',
                    title : '',
                    subtitle : '',
                    tooltip : '',
                    domainid: '',
                    familyid: '',
                    image : ''
                };
            }
        });
    });

/*@fullReview  ZUR 15/11/23 2017x Param Skeleton*/
/*global define, widget*/
define('DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler',
    [
    ], function () {
        "use strict";

        var iHandler = {
            //
            init: function (url, tenant) {
                this.url = url;
                this.tenant = tenant;
            },

            setURL : function(url) {
                this.url = url;
            },

            getURL : function() {
                return this.url;
            },

            getTenant : function() {
                return this.tenant;
            },

            setTenant : function (itenant) {
                this.tenant = itenant;
            }

        };

        return iHandler;
    });

/*@fullReview  ZUR 15/11/23 2017x Param Skeleton*/
/*global define*/
/*jslint nomen: true */
/*jslint plusplus: true*/
define('DS/ParameterizationSkeleton/Utils/ParameterizationDataUtils',
    [
    ], function () {

        "use strict";
        var pUtils = {

            /*
            JSONreplace : function (data) {

                JSON.stringify(data, function (key, value) {
                    var k, replacement;
                    if (value && typeof value === 'object') {
                        replacement = {};
                        for (k in value) {
                            if (Object.hasOwnProperty.call(value, k)) {
                                replacement[k && k.charAt(0).toLowerCase() + k.substring(1)] = value[k];
                            }
                        }
                        return replacement;
                    }
                    return value;
                });
                return data;
            },//JSONreplace */

            paramStructBuilder: function (fields) {
                var i,
                    fields = fields.split(','),
                    count = fields.length;

                function constructor() {
                    for (i = 0; i < count; i++) {
                        this[fields[i]] = arguments[i];
                    }
                }
                return constructor;
            },

        };//pUtils

        return pUtils;

    });

/*global define*/
define('DS/ParameterizationSkeleton/Model/ParameterizationLifecycle/LifecycleDescriptionModel',
    [
        'UWA/Class/Model'
    ], function (Model) {

        'use strict';
        //
        return Model.extend({
            defaults: function() {
                return {
                    id : '',
                    text : '',
                    tooltip : ''
                };
            }
        });
    });


/*@fullReview  ZUR 15/11/23 2017x Param Skeleton*/
/*global define,console*/
/*jslint nomen: true*/
define('DS/ParameterizationSkeleton/Views/ParamItemsListView',
    [
        'DS/W3DXComponents/Views/Layout/GridScrollView',
        'DS/W3DXComponents/Views/Item/TileView',
        'DS/W3DXComponents/Views/Item/SetView',
        'css!DS/W3DXComponents/W3DXComponents'
    ], function(GridScrollView, ItemViewTile, ItemViewSet) {
        'use strict';
        var ItemsListView,
            _name = 'list';
        ItemsListView = ItemViewSet.extend({
            name : _name,
            defaultOptions : {
                contents : {
                    //defaultView: 'tile',
                    useInfiniteScroll : false,
                    usePullToRefresh : false,
                    selectionMode : 'oneToOne',
                    views : [ {
                        'id' : 'tile',
                        //'title' : 'Tile View',
                        'view' : GridScrollView,
                        'itemView' : ItemViewTile,
                        'scrollPosition' : 'center',
                        'layout' : {
                            column : 3
                        }
                    } ]
                }
            },



            /*destroy : function() {
                this.childView.destroy();
                this.stopListening();
                this._parent.apply(this, arguments);
            }
            destroy : function() {
                this.stopListening();
                this._parent.apply(this, arguments);
            }*/

            destroy: function(options) {

                if (this.isDestroyed) {
                    return;
                }

                if (this.collection) {
                    this.stopListening(this.collection, this._externalEvents);
                }

                return this._parent.apply(this, arguments);
            },

            reload: function() {
                this.container.addClassName('loading');
                //  /!\ pour compenser l'absence de resetState dans la pageableCollection
                this.collection.state.totalRecords = null;
                //this.collection.reset();
                this.collection.getFirstPage();
            }
        });

        return ItemsListView;
    });

/*global define*/
define('DS/ParameterizationSkeleton/Model/ParameterizationDataModeling/TypesListModel',
    [
        'UWA/Class/Model'
    ], function (Model) {
        "use strict";
        return Model.extend({
            defaults: function() {
                return {
                    id: '',
                    title : '',
                    subtitle : '',
                    domainid : '',
                    image : ''
                };
            }
        });
    });

/*global define, widget*/
/*jslint nomen: true*/
define('DS/ParameterizationSkeleton/Collection/LifecycleDescriptionCollection', [
    // UWA
    'UWA/Core',
    'UWA/Class/Collection',
    'DS/ParameterizationSkeleton/Model/ParameterizationLifecycle/LifecycleDescriptionModel',
    'DS/WAFData/WAFData',
    'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler'
], function (UWA, Collection, LifecycleDescriptionModel, WAFData, URLHandler) {
    "use strict";
    return Collection.extend({
        model : LifecycleDescriptionModel,
        setup: function (models, options) {
            var ipolicyID = options._modelKey._attributes.id;
            this.url = URLHandler.getURL() + "/resources/ParamWS/lifecycle/extendeddescription?tenant=" + URLHandler.getTenant() + "&policy=" + ipolicyID;
        },

        sync : function(method, model, options) {
            UWA.log('LifecycleDescriptionCollection::sync');
            //options.contentType = 'application/json';//application/ds-json
            //options.proxy = 'passport';
            //options.lang = widget.lang;

            options.headers = {
                'Accept-Language' : widget.lang
            };//ZUR IR-454515-3DEXPERIENCER2017x

            UWA.log(options);

            options = Object.assign({
                ajax: WAFData.authenticatedRequest
            }, options);
            //console.log(model);
            //this.childCollection.sync(method, model, options);
            this._parent.apply(this, [method, model, options]);
        },

        parse: function (data) {
            UWA.log("LifecycleDescriptionCollection::parse");
            return data;
        }

        /*create: function(attributes, options) {
            options.proxy = 'passport';
            // options.headers = 'headers%5BAccept%5D=application%2Fjson&headers%5BX-Request%5D=JSON';
            this._parent.apply(this, [attributes, options]);
        }*/

    });
});

/*@fullReview  SSV1 19/06/13  FUN090928 : SSV1 Engineering Definition configuration UI*/
/*global define, widget, document, setTimeout, console*/
/*jslint nomen: true */
define('DS/ParameterizationSkeleton/Collection/ParameterizationXEngineeringCollection', [
    // UWA
    'UWA/Core',
    'UWA/Class/Model',
    'UWA/Class/Collection',
    'DS/ParameterizationSkeleton/Model/MappingModel',
    'DS/ParameterizationSkeleton/Utils/ParameterizationDataUtils',
    'DS/WAFData/WAFData',
    'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler'
], function (UWA, Model, Collection,  MappingModel, 
    ParameterizationDataUtils, WAFData, URLHandler) {
    'use strict';
    //

    var handledDomain = null;

    return Collection.extend({
        model : function (modelid) {
            return MappingModel;
        },

        setup: function (models, options) {
            UWA.log('ParameterizationXEngineering::setup');

            UWA.log(models);
            UWA.log(options);

            console.log("ParameterizationXEngineering::setup, Sucessful");
            var iURL, iObjID,
                _modelKey = options._modelKey,
                domainID = _modelKey._attributes.domainid,
                familyID = _modelKey._attributes.familyid;

            if (UWA.is(this.model, "function")) {
                this.model = this.model(domainID);
                handledDomain = domainID;
            }

                iObjID = _modelKey._attributes.id;
                this.url = URLHandler.getURL() +
                    "/resources/v1/xENGParameterization/getAdminPartNumberProperties?tenant=" + URLHandler.getTenant();
        },

        sync : function(method, model, options) {
            UWA.log('ParameterizationXEngineering::sync');
            options.contentType = 'application/json';
            options.lang = widget.lang;

            options.headers = {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Accept-Language' : widget.lang
            };

            UWA.log(options);

            options = Object.assign({
                ajax: WAFData.authenticatedRequest
            }, options);  
            this._parent.apply(this, [method, model, options]);
        },

        parse: function (data) {
            UWA.log("ParameterizationXEngineering::parse");
            UWA.log(data);

            return this.parseMappingData(data);
           
        },

        create: function(attributes, options) {
            options.proxy = 'passport';
            this._parent.apply(this, [attributes, options]);
        },

    

        parseMappingData: function (data) {
        	if(data.ExpressionList){
	    		data.ExpressionList.sort(function(a, b){
	    			if(a.Order && b.Order){
	    				return a.Order - b.Order;
	    			}
	    		});
        	}
        	
            return data;
        }

    });
});

/*@fullReview  ZUR 15/11/23 2017x Param Widgetization NG*/
/*global define, widget, document, setTimeout, console*/
/*jslint nomen: true */
define('DS/ParameterizationSkeleton/Collection/ParameterizationXCADDomainsListCollection', [
    'UWA/Core',
    'UWA/Class/Collection',
    'DS/ParameterizationSkeleton/Model/ParameterizationDomainsListModel',
    'WebappsUtils/WebappsUtils',// WebApps
    'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler',
    'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS'
], function (UWA, Collection, ParameterizationDomainsModel, WebappsUtils, URLHandler, ParamSkeletonNLS) {
    'use strict';

    return Collection.extend({
        model : ParameterizationDomainsModel,

        setup: function () {
            UWA.log("ParameterizationDomainsListCollection::setup");
            this.url = WebappsUtils.getWebappsAssetUrl('ParameterizationSkeleton', 'Integrations.json');
        },

        sync : function(method, model, options) {
            UWA.log("ParameterizationDomainsListCollection::sync");
            //options.contentType = 'application/json';
            options.proxy = 'passport';

            options.headers = {
                'Accept-Language' : widget.lang
            };
            //'Accept-Language' : widget.lang
            //options.acceptLanguage = widget.lang;
            this._parent.apply(this, [method, model, options]);
        },

        parse: function (data) {
            UWA.log("ParameterizationDomainsListCollection::parse");
            var titleText, titleTooltip, paramEntries = [];

            /*var imgClass = 'fonticon fonticon-2x fonticon-flow-cascade';
            var imgSpan = UWA.createElement('span', {
                    'class' :  imgClass
            });*/

            if (Array.isArray(data)) {
                data.forEach(function (iElement) {
                    titleText = ParamSkeletonNLS[iElement.domainid + "Text"];
                    titleTooltip = ParamSkeletonNLS[iElement.domainid + "Tooltip"];

                    if ((iElement.familyid !== null) && (iElement.familyid !== "")) {
                        titleText = ParamSkeletonNLS[iElement.familyid + "Text"];
                        titleTooltip = ParamSkeletonNLS[iElement.familyid + "Tooltip"];
                    }

                    paramEntries.push({
                        title          : titleText,
                        subtitle       : titleTooltip,
                        introduction   : titleTooltip,
                        //image          : URLHandler.getURL() + "/widget/images/MyApps/" + iElement.image,
                        image          : URLHandler.getURL() + "/webapps/ParameterizationSkeleton/assets/img/" + iElement.image,
                        domainid       : iElement.domainid,
                        familyid       : iElement.familyid,
                        id             : iElement.domainid + iElement.familyid
                    });
                });
            }
            return paramEntries;

 /* "Iteration" "ENOWMOD_AP_AppIcon.png"
    "DataAccessRight" "ENOTASK_AP_AppIcon.png"
    "ObjectIdentification" "ENOCOEX_AP_AppIcon.png"
    "ObjectIdentification//ENOWCHG_AP_AppIcon.png"
    "EngineeringCentral//ENOREPR_AP_AppIcon.png"
    "AttributeDefENOBPCO_AP_AppIcon.png"*/

        }

    });
});

/*@fullReview  ZUR 15/11/23 2017x Param Widgetization NG*/
/*global define, widget, document, setTimeout, console*/
/*jslint nomen: true */
define('DS/ParameterizationSkeleton/Collection/ParameterizationCommonCollection', [
    // UWA
    'UWA/Core',
    'UWA/Class/Model',
    'UWA/Class/Collection',
    'DS/ParameterizationSkeleton/Model/ParameterizationDomainModel',
    'DS/ParameterizationSkeleton/Model/ParameterizationDataModeling/TypeModel',
    'DS/ParameterizationSkeleton/Model/ParameterizationLifecycle/LifecycleModel',
    'DS/ParameterizationSkeleton/Model/ParameterizationXCAD/XCADModel',
    'DS/ParameterizationSkeleton/Utils/ParameterizationDataUtils',
    'DS/WAFData/WAFData',
    'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler'
], function (UWA, Model, Collection, ParameterizationDomainModel, TypeModel, LifecycleModel, XCADModel,
    ParameterizationDataUtils, WAFData, URLHandler) {
    'use strict';
    //

    var handledDomain = null;

    //var  ParameterizationParentCol = 
    return Collection.extend({
        model : function (modelid) {
            UWA.log('ParameterizationCommonCollection::model = ' + modelid);
            if (modelid === "AttributeDef") {
                return TypeModel;
            }
            if (modelid === "XCADParameterization") {
                return XCADModel;
            }
            return LifecycleModel;
        },

        //model:ParameterizationDomainModel,
        setup: function (models, options) {
            UWA.log('ParameterizationCommonCollection::setup');
            //this.childCollection = null;

            UWA.log(models);
            UWA.log(options);
            /*var options2 = this.options;
            UWA.log(options2);*/

            console.log("ParameterizationCommonCollection::setup, la suite");
            var iURL, iObjID,
                _modelKey = options._modelKey,
                domainID = _modelKey._attributes.domainid,
                familyID = _modelKey._attributes.familyid;

            if (UWA.is(this.model, "function")) {
                this.model = this.model(domainID);
                handledDomain = domainID;
            }

            if (domainID === 'AttributeDef') {
                UWA.log("ParameterizationCommonCollection::Attributes!");
                iObjID = _modelKey._attributes.id;
                this.url = URLHandler.getURL() +
                    "/resources/ParamWS/datamodel/listofattributesfortype?tenant=" + URLHandler.getTenant() + "&type=" + iObjID;
            } else if (domainID === 'LifecycleTopology') {
                iObjID = _modelKey._attributes.id;
                UWA.log("ParameterizationCommonCollection::Setting lifecycle URLs");
                this.url = URLHandler.getURL() +
                    "/resources/ParamWS/lifecycle/topology?tenant=" + URLHandler.getTenant() + "&policy=" + iObjID;

            } else if (domainID === 'XCADParameterization') {
                iObjID = _modelKey._attributes.id;
                UWA.log("ParameterizationCommonCollection::Setting xcad URLs");
                this.url = URLHandler.getURL() +
                    "/resources/xcadparam/gco/get?tenant=" + URLHandler.getTenant() + "&integration=" + iObjID;

            } else {
                iURL = URLHandler.getURL() + "/resources/ParamWS/access/DomainElements?tenant=" + URLHandler.getTenant() + "&domainid=" + domainID;

                if ((familyID !== null) && (familyID !== "")) {
                    iURL = iURL + "&familyid=" + familyID;
                }
                this.url = iURL;
                //this.childCollection = new ParameterizationDomainCollection();
                //return this.childCollection.setup(models, options);
            }
        },

        sync : function(method, model, options) {
            UWA.log('ParameterizationCommonCollection::sync');
            options.contentType = 'application/json';//application/ds-json
            //options.proxy = 'passport';
            options.lang = widget.lang;

            options.headers = {
                Accept: 'application/json',
                //'Content-Type': 'application/json',
                'Accept-Language' : widget.lang
            };

            UWA.log(options);

            options = Object.assign({
                ajax: WAFData.authenticatedRequest
            }, options);  
            //console.log(model);
            //this.childCollection.sync(method, model, options);
            this._parent.apply(this, [method, model, options]);
        },

        parse: function (data) {
            UWA.log("ParameterizationParentCollection::parse");
            //return this.childCollection.parse(data);
            UWA.log(data);

            if (handledDomain === "AttributeDef") {
                return this.parseTypeAttributesData(data);
            }

            if (handledDomain === "LifecycleTopology") {
                return this.parseMaturityData(data);
            }

            if (handledDomain === "XCADParameterization") {
                return this.parseXCADData(data);
            }
        },

        create: function(attributes, options) {
            options.proxy = 'passport';
            this._parent.apply(this, [attributes, options]);
        },

        parseTypeAttributesData : function (data) {
            UWA.log("ParameterizationCommonCollection::parseAttributesData");
            UWA.log(data);
            var oData = [], Attributes = [], Synchros = [], SystemAttributes = [];

            if (Array.isArray(data.attributeDescription)) {
                data.attributeDescription.forEach(function (rElement) {
                    Attributes.push(rElement);
                });
            }

            if (Array.isArray(data.attributesSynchronization)) {
                data.attributesSynchronization.forEach(function (rElement) {
                    Synchros.push(rElement);
                });
            }
            //NZV :IR-540216-3DEXPERIENCER2018x
            if (Array.isArray(data.attributesInSystem)) {
                data.attributesInSystem.forEach(function (rElement) {
                    SystemAttributes.push(rElement.sysAttribute);
                });
            }

            oData.push({
                id               : data.id,
                listofAttributes : Attributes,
                listofSynchros   : Synchros,
                listofSystemAttribues : SystemAttributes
            });
            return oData;
        },

        parseMaturityData: function (data) {
            var rPolicy, StateNodeModel,
                States  = [],
                Transitions = [],
                Checks = [],
                Types = [];

            UWA.log("LifecycleCollection::parse");
            UWA.log(data);

            StateNodeModel = ParameterizationDataUtils.paramStructBuilder("id,states");
            rPolicy = new StateNodeModel("", "");
            //:[{"id":"PRIVATE","stateUserName":"Private","isEnabled":"true","isCritical":"true","isDefault":"false","visuOrder":"0"},

            if (Array.isArray(data.state)) {
                data.state.forEach(function (rState) {
                    States.push({
                        id: rState.id,
                        stateUserName: rState.stateUserName,
                        isDefault  : rState.isDefault,
                        isEnabled  : rState.isEnabled,
                        isCritical : rState.isCritical,
                        visuOrder  : rState.visuOrder,
                        isDeployed : rState.isDeployed
                    });
                });
            }

            //":[{"name":"","sourceState":"Create","targetState":"Peer Review","isDefault":"false","isForbidden":"false","isCritical":"false"}
            if (Array.isArray(data.transition)) {
                data.transition.forEach(function (rTransition) {
                    Transitions.push({
                        name        : rTransition.name,
                        nlsname     : rTransition.nlsname,
                        sourceState : rTransition.sourceState,
                        targetState : rTransition.targetState,
                        isForbidden : rTransition.isForbidden,
                        isDefault   : rTransition.isDefault,
                        isCritical  : rTransition.isCritical,
                        isDeployed  : rTransition.isDeployed
                    });
                });
            }

            //<Check objType="Schema_Snapshot_Log" fromState="FROZEN" toState="RELEASED" ruleID="RejectOnCreator" additionalProps="NOINFO" isDeployed="true"/>
            if (Array.isArray(data.check)) {
                data.check.forEach(function (rCheck) {
                    Checks.push({
                        objType         : rCheck.objType,
                        sourceState     : rCheck.fromState,
                        targetState     : rCheck.toState,
                        ruleID          : rCheck.ruleID,
                        additionalProps : rCheck.additionalProps,
                        isDeployed      : (rCheck.isDeployed === "true")
                    });
                });
            }

            if (Array.isArray(data.governedType)) {
                data.governedType.forEach(function (rType) {
                    Types.push(rType);
                });
            }
            //listofRules, typeCategory, typeID, typeNLS

            rPolicy.id = data.id;
            rPolicy.appCategory = data.appCategory;
            rPolicy.states = States;
            rPolicy.transitions = Transitions;
            rPolicy.checks = Checks;
            rPolicy.types = Types;
            return rPolicy;
        },

        parseXCADData : function (data) {
            UWA.log("ParameterizationCommonCollection::parseXCADData");
            UWA.log(data);
            var oData = [], Attributes = [];

            if (Array.isArray(data.Mapping)) {
                data.Mapping.forEach(function (rElement) {
                    Attributes.push(rElement);
                });
            }

            oData.push({
              id               : data.Connector,
              Mapping : Attributes
            });
            return oData;
        },



    });

    //return ParameterizationParentCol;
});

/*@fullReview  ZUR 15/11/23 2017x Param Widgetization NG*/
/*global define, widget, document, setTimeout, console*/
/*jslint nomen: true */
define('DS/ParameterizationSkeleton/Collection/ParameterizationDomainsListCollection', [
    'UWA/Core',
    'UWA/Class/Collection',
    'DS/ParameterizationSkeleton/Model/ParameterizationDomainsListModel',
    'WebappsUtils/WebappsUtils',// WebApps
    'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler',
    'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS'
], function (UWA, Collection, ParameterizationDomainsModel, WebappsUtils, URLHandler, ParamSkeletonNLS) {
    'use strict';

    return Collection.extend({
        model : ParameterizationDomainsModel,

        setup: function () {
            UWA.log("ParameterizationDomainsListCollection::setup");
            this.url = WebappsUtils.getWebappsAssetUrl('ParameterizationSkeleton', 'Param_Entries.json');
        },

        sync : function(method, model, options) {
            UWA.log("ParameterizationDomainsListCollection::sync");
            //options.contentType = 'application/json';
            options.proxy = 'passport';

            options.headers = {
                'Accept-Language' : widget.lang
            };
            //'Accept-Language' : widget.lang
            //options.acceptLanguage = widget.lang;
            this._parent.apply(this, [method, model, options]);
        },

        parse: function (data) {
            UWA.log("ParameterizationDomainsListCollection::parse");
            var titleText, titleTooltip, paramEntries = [];

            /*var imgClass = 'fonticon fonticon-2x fonticon-flow-cascade';
            var imgSpan = UWA.createElement('span', {
                    'class' :  imgClass
            });*/

            if (Array.isArray(data)) {
                data.forEach(function (iElement) {
                    titleText = ParamSkeletonNLS[iElement.domainid + "Text"];
                    titleTooltip = ParamSkeletonNLS[iElement.domainid + "Tooltip"];

                    if ((iElement.familyid !== null) && (iElement.familyid !== "")) {
                        titleText = ParamSkeletonNLS[iElement.familyid + "Text"];
                        titleTooltip = ParamSkeletonNLS[iElement.familyid + "Tooltip"];
                    }

                    paramEntries.push({
                        title          : titleText,
                        subtitle       : titleTooltip,
                        introduction   : titleTooltip,
                        //image          : URLHandler.getURL() + "/widget/images/MyApps/" + iElement.image,
                        image          : URLHandler.getURL() + "/webapps/ParameterizationSkeleton/assets/img/" + iElement.image,
                        domainid       : iElement.domainid,
                        familyid       : iElement.familyid,
                        id             : iElement.domainid + iElement.familyid
                    });
                });
            }
            return paramEntries;

 /* "Iteration" "ENOWMOD_AP_AppIcon.png"
    "DataAccessRight" "ENOTASK_AP_AppIcon.png"
    "ObjectIdentification" "ENOCOEX_AP_AppIcon.png"
    "ObjectIdentification//ENOWCHG_AP_AppIcon.png"
    "EngineeringCentral//ENOREPR_AP_AppIcon.png"
    "AttributeDefENOBPCO_AP_AppIcon.png"*/

        }

    });
});



/*! Copyright 2017, Dassault Systemes. All rights reserved. */
/*global define, widget, document, setTimeout, console*/
/*jslint nomen: true */
/*@fullReview  ZUR 15/11/23 2017x Param Widgetization NG*/
/*@fullReview  NZV 17/06/12 HL FUN060421, Interface name/Attribute group name set as InterfaceID (parseAttributesData)*/
/*@quickReview ZUR 18/04/24 FUN079262 2019x : EBOM-PS Collaboration Mapping Object Widget*/

define('DS/ParameterizationSkeleton/Collection/ParameterizationParentCollection', [
    // UWA
    'UWA/Core',
    'UWA/Class/Model',
    'UWA/Class/Collection',
    'DS/ParameterizationSkeleton/Model/ParameterizationDomainModel',
    'DS/ParameterizationSkeleton/Utils/ParameterizationDataUtils',
    'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler',
    'DS/ParameterizationSkeleton/Model/ParameterizationDataModeling/TypesListModel',
    'DS/ParameterizationSkeleton/Model/ParameterizationLifecycle/LifecycleListModel',
    'DS/ParameterizationSkeleton/Model/ParameterizationXCAD/XCADListModel',
    'DS/WAFData/WAFData',
    'WebappsUtils/WebappsUtils'
], function (UWA, Model, Collection, ParameterizationDomainModel,
             ParamDataUtils, URLHandler, TypesListModel, LifecycleListModel, XCADListModel, WAFData, WebappsUtils) {
    'use strict';
    //

    var handledDomain = null;

    //var  ParameterizationParentCol = 
    return Collection.extend({
        model : function (modelid) {
            UWA.log('ParameterizationParentCollection::model');
            if (modelid === "AttributeDef") {
                UWA.log('ParameterizationParentCollection::TypesListModel');
                return TypesListModel;
            }
            if (modelid === "LifecycleTopology") {
                UWA.log('ParameterizationParentCollection::LifecycleListModel');
                return LifecycleListModel;
            }
            if (modelid === "XCADParametrization") {
                UWA.log('ParameterizationParentCollection::XCADListModel');
                return XCADListModel;
            }

            return ParameterizationDomainModel;//previously worked only with ParameterizationDomainModel 
        },

        //model:ParameterizationDomainModel,
        setup: function (models, options) {
            UWA.log('ParameterizationParentCollection::setup');
            this.childCollection = null;

            UWA.log(models);
            UWA.log(options);
            /*var options2 = this.options;
            UWA.log(options2);*/

            console.log("ParameterizationParentCollection::setup, la suite");
            var iURL,
                _modelKey = options._modelKey,
                domainID = _modelKey._attributes.domainid,
                familyID = _modelKey._attributes.familyid;

            if (UWA.is(this.model, "function")) {
                this.model = this.model(domainID);
                handledDomain = domainID;
            }

            if (domainID === 'AttributeDef') {
                this.url = URLHandler.getURL() + "/resources/ParamWS/datamodel/listofsupportedtypes?tenant=" + URLHandler.getTenant();
                UWA.log("ParameterizationParentCollection::AttributeDef");
            } else if (domainID === 'LifecycleTopology') {
                this.url = URLHandler.getURL() + "/resources/ParamWS/lifecycle/listoflifecycles?tenant=" + URLHandler.getTenant();
                UWA.log("ParameterizationParentCollection::Setting lifecycle URLs");
             } else if (domainID === 'XCADParameterization') {
                this.url = URLHandler.getURL() + "/resources/xcadparam/gco/list?tenant=" + URLHandler.getTenant();
                UWA.log("ParameterizationParentCollection::Setting lifecycle URLs");
           } else {
                iURL = URLHandler.getURL() + "/resources/ParamWS/access/DomainElements?tenant=" + URLHandler.getTenant() + "&domainid=" + domainID;

                if ((familyID !== null) && (familyID !== "")) {
                    iURL = iURL + "&familyid=" + familyID;
                }
                this.url = iURL;
                //this.childCollection = new ParameterizationDomainCollection();
                //return this.childCollection.setup(models, options);
            }


            /*
            iURL = URLHandler.getURL() + "/resources/ParamWS/access/DomainElements?tenant=" + URLHandler.getTenant() + "&domainid=" + domainID;
            if ((familyID !== null) && (familyID !== "")) {
                iURL = iURL + "&familyid=" + familyID;
            }
            UWA.log(iURL);
            this.url = iURL;*/
            /*{"domainid": "AttributeDef","familyid": "","image": "paramAttributeDef.gif"}, 
              { "domainid": "ObjectIdentification", "familyid": "VersionNaming", "image": "paramVersionNaming.gif"}*/
        },

            /*init : function (models, options) {
            UWA.log('ParameterizationParentCollection::init');
            this.childCollection = null;
            this.mychosenModel = null;
            this.setup(models, options);
        },*/
        /*model : function (options) {
            //return this.mytest(options);
            
            //return ParameterizationParentCol.mytest(options);
            return ParameterizationDomainModel;
        },*/
        //model : ParameterizationParentCol.mytest(options),
        //model : this.mychosenModel,
        //model : ParameterizationDomainModel,
        //Application.version >= 2 ? TriangleV2 : Triangle;

        /*sync : function(method, model, options) {
            UWA.log('ParameterizationParentCollection::sync');
            options.contentType = 'application/json';//application/ds-json
            options.proxy = 'passport';
            options.lang = widget.lang;

            options.headers = {
                Accept: 'application/json',
                'Content-Type': 'application/json'
            };

            UWA.log(options);
            //console.log(model);
            //this.childCollection.sync(method, model, options);
            this._parent.apply(this, [method, model, options]);
        },*/

        sync : function(method, model, options) {
            UWA.log("ParameterizationParentCollection::sync::WD");
            //options.contentType = 'application/json';
            //options.proxy = 'passport';
            //options.lang = widget.lang;
            //options.lang = I18n.getCurrentLanguage(); doesn't work correctly
            //options.lang = widget.lang;
            //options.type = 'json';

            options.headers = {
                Accept: 'application/json',
               // 'Content-Type': 'application/json',
                'Accept-Language' : widget.lang
            };
            //ZUR in options.headers 'Accept-Language' : widget.lang --> IR-454515-3DEXPERIENCER2017x

            options = Object.assign({
                ajax: WAFData.authenticatedRequest
            }, options);

            this._parent.apply(this, [method, model, options]);
        },


        parse: function (data) {
            UWA.log("ParameterizationParentCollection::parse");
            //return this.childCollection.parse(data);
            UWA.log(data);

            if (handledDomain === "AttributeDef") {
                return this.parseAttributesData(data);
            }

            if (handledDomain === "LifecycleTopology") {
                return this.parseLifecylesData(data);
            }

            if (handledDomain === "XCADParameterization") {
                return this.parseXCADData(data);
            }

            var familyModel = ParamDataUtils.paramStructBuilder("id,family"),
                oData = new familyModel("", ""),
                Families = [];

            if (Array.isArray(data.family)) {
                data.family.forEach(function (rElement) {
                    Families.push(rElement);
                });
            }

            oData.id = data.id;
            oData.family = Families;
            return oData;
        },

        create: function(attributes, options) {
            options.proxy = 'passport';
            this._parent.apply(this, [attributes, options]);
        },

        parseAttributesData : function (data) {
            var paramEntries = [], paramTitle, paramSubTitle;

            if (Array.isArray(data.typeDescription)) {
                data.typeDescription.forEach(function (iElement) {
                    if (typeof iElement.interfaceID != "undefined" && iElement.interfaceID !== "") {
                        paramTitle = iElement.nlsName + ' - ' + iElement.interfaceID;
                        paramSubTitle = iElement.interfaceID;
                    } else {
                        paramTitle = iElement.nlsName;
                        paramSubTitle = iElement.id;
                    }
                    paramEntries.push({
                        title              : paramTitle,
                        subtitle           : paramSubTitle,
                        image              : URLHandler.getURL() + "/webapps/ParameterizationSkeleton/assets/img/" + "paramAttributeDef.png",
                        id                 : iElement.id,
                        domainid           : data.domainid
                        
                    });
                });
            }
            //ZUR - FUN079262 - 2019x : Deactivating Synchro Tile in Attributes Management, functionality moved to the new domain MappingManagement
            /*paramEntries.push({
                title          : ParamSkeletonNLS.PhysicalBOMCollabTitle,
                subtitle       : ParamSkeletonNLS.PhysicalBOMCollabTitle,
                image          : URLHandler.getURL() + "/webapps/ParameterizationSkeleton/assets/img/" + "paramAttributeSynchro.gif",
                id             : 'AttributeSynchronization',
                domainid       : data.domainid,
                sixwTagDescription : ''
            });*/
            // Promoted with IR IR-651121-3DEXPERIENCER2019x
           paramEntries.sort(function (paramEnt1, paramEnt2) {
                if (paramEnt1.title !== undefined && paramEnt2.title !== undefined) {
                    return paramEnt1.title.localeCompare(paramEnt2.title);
                } else {
                    // not possible case
                    console.log("sorting failed : " + paramEnt1);
                    console.log(paramEnt2);
                    return 0;
                }                
            });
            return paramEntries;
        },

        parseLifecylesData: function (data) {
            UWA.log("LifecycleListCollection::parse");
            UWA.log(data);
            var policies;

            UWA.log(URLHandler.getURL());
            if (Array.isArray(data.lifecycleDescription)) {

                policies = [];

                data.lifecycleDescription.forEach(function (ipolicy) {

                    policies.push({
                        title          : ipolicy.title,
                        subtitle       : ipolicy.id,
                        //content        : ipolicy.content,
                        image          : URLHandler.getURL() + "/webapps/ParameterizationSkeleton/assets/img/" + "paramLifecycleTopology.png",
                        id             : ipolicy.id,
                        domainid       : data.domainid,
                        modifyTopology : (ipolicy.areTransitionsEditable === "true"),
                        renameStates   : (ipolicy.areStatesRenamable === "true"),
                        supportRules   : (ipolicy.supportsPromoteRules === "true")
                        // parent: role.parent,//    child: role.child,
                    });
                });
            }
           // Promoted with IR IR-651121-3DEXPERIENCER2019x
           policies.sort(function (paramEnt1, paramEnt2) {
                if (paramEnt1.title !== undefined && paramEnt2.title !== undefined) {
                    return paramEnt1.title.localeCompare(paramEnt2.title);
                } else {
                    // not possible case
                    console.log("sorting failed : " + paramEnt1);
                    console.log(paramEnt2);
                    return 0;
                }                
            });
            return policies;
        },

      parseXCADData : function (data) {
          var paramEntries = [];
          
          if (Array.isArray(data.xcadDescription)) {
            data.xcadDescription.forEach(function (iElement) {
              paramEntries.push({
                title              : iElement.nlsName,
                subtitle           : '',
                image              : URLHandler.getURL() + "/webapps/ParameterizationSkeleton/assets/img/paramXCAD" + iElement.icon + ".png",
                id                 : iElement.id,
                domainid           : "XCADParameterization"
                
              });
            });
          }
          return paramEntries;
        }


    });

    //return ParameterizationParentCol;
});

/*@fullReview  ZUR 15/11/23 2017x Param Widgetization NG*/
/*global define, widget, document, setTimeout, console*/
/*jslint nomen: true */
define('DS/ParameterizationSkeleton/Collection/ParameterizationDomainCollection', [
    // UWA
    'UWA/Core',
    'UWA/Class/Model',
    'UWA/Class/Collection',
    'DS/ParameterizationSkeleton/Model/ParameterizationDomainModel',
    'DS/ParameterizationSkeleton/Utils/ParameterizationDataUtils',
    'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler',
    'DS/WAFData/WAFData',
    'WebappsUtils/WebappsUtils'
], function (UWA, Model, Collection, ParameterizationDomainModel, ParamDataUtils, URLHandler, WAFData, WebappsUtils) {
    'use strict';
    //
    return Collection.extend({
        model : ParameterizationDomainModel,
        setup: function (models, options) {
            console.log("ParameterizationDomainModel::setup::");
            var iURL,
                _modelKey = options._modelKey,
                domainID = _modelKey._attributes.domainid,
                familyID = _modelKey._attributes.familyid;

            iURL = URLHandler.getURL() + "/resources/ParamWS/access/DomainElements?tenant=" + URLHandler.getTenant() + "&domainid=" + domainID;

            if ((familyID !== null) && (familyID !== "")) {
                iURL = iURL + "&familyid=" + familyID;
            }
            UWA.log(iURL);
            this.url = iURL;
            /*if (domainID === "Deployment")
                this.url= "_Blank";//a tester si besoin
            */
        },

        /*sync : function(method, model, options) {
            UWA.log("ParameterizationDomainModel::sync");
            options.contentType = 'application/json';//application/ds-json
            options.proxy = 'passport';
            options.lang = widget.lang;
            options.type = 'json';

            options.headers = {
                 Accept: 'application/json',
                 'Content-Type': 'application/json'
            };          
            UWA.log(options);
            this._parent.apply(this, [method, model, options]);
        },*/

        sync : function(method, model, options) {
            UWA.log("ParameterizationDomainCollection::sync");
           // options.contentType = 'application/json';
            //options.proxy = 'passport';
            options.lang = widget.lang;
            options.type = 'json';

            options.headers = {
                 Accept: 'application/json',
                // 'Content-Type': 'application/json'
            };       

            options = Object.assign({
                ajax: WAFData.authenticatedRequest
            }, options);   

            this._parent.apply(this, [method, model, options]);
        },


          //options.Accept = 'application/json';
            //Content-Type:application/json

        parse: function (data) {
            UWA.log("ParameterizationDomainModel::parse");
            UWA.log(data);
            var familyModel = ParamDataUtils.paramStructBuilder("id,family"),
                oData = new familyModel("", ""),
                Families = [];

            if (Array.isArray(data.family)) {
                data.family.forEach(function (rElement) {
                    Families.push(rElement);
                });
            }

            //oData.id = "TESTID";
            oData.id = data.id;
            oData.family = Families;

            return oData;

            /*id: "EngineeringCentral"
                    nlsKey: "Engineering"
                    packaging: null
                    regSuite: null
                    solution: ""
                    tooltipNlsKey: "Engineering"*/
        },

        create: function(attributes, options) {
            options.proxy = 'passport';
            this._parent.apply(this, [attributes, options]);
        }

    });
});

/*@fullReview  ZUR 15/11/23 2017x Param Widgetization NG*/
/*global define, widget, document, setTimeout, console*/
/*jslint nomen: true */
define('DS/ParameterizationSkeleton/Collection/ParameterizationMappingCollection', [
    // UWA
    'UWA/Core',
    'UWA/Class/Model',
    'UWA/Class/Collection',
    'DS/ParameterizationSkeleton/Model/MappingModel',
    'DS/ParameterizationSkeleton/Utils/ParameterizationDataUtils',
    'DS/WAFData/WAFData',
    'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler'
], function (UWA, Model, Collection,  MappingModel, 
    ParameterizationDataUtils, WAFData, URLHandler) {
    'use strict';
    //

    var handledDomain = null;

    //var  ParameterizationParentCol = 
    return Collection.extend({
        model : function (modelid) {
            return MappingModel;
        },

        //model:ParameterizationDomainModel,
        setup: function (models, options) {
            UWA.log('ParameterizationCommonCollection::setup');
            //this.childCollection = null;

            UWA.log(models);
            UWA.log(options);
            /*var options2 = this.options;
            UWA.log(options2);*/

            console.log("ParameterizationCommonCollection::setup, la suite");
            var iURL, iObjID,
                _modelKey = options._modelKey,
                domainID = _modelKey._attributes.domainid,
                familyID = _modelKey._attributes.familyid;

            if (UWA.is(this.model, "function")) {
                this.model = this.model(domainID);
                handledDomain = domainID;
            }

                iObjID = _modelKey._attributes.id;
                this.url = URLHandler.getURL() +
                    "/resources/MappingWS/mapping/mappinginformation?tenant=" + URLHandler.getTenant();
        
        },

        sync : function(method, model, options) {
            UWA.log('ParameterizationCommonCollection::sync');
            options.contentType = 'application/json';//application/ds-json
            //options.proxy = 'passport';
            options.lang = widget.lang;

            options.headers = {
                Accept: 'application/json',
                'Content-Type': 'application/json',
                'Accept-Language' : widget.lang
            };

            UWA.log(options);

            options = Object.assign({
                ajax: WAFData.authenticatedRequest
            }, options);  
            //console.log(model);
            //this.childCollection.sync(method, model, options);
            this._parent.apply(this, [method, model, options]);
        },

        parse: function (data) {
            UWA.log("ParameterizationParentCollection::parse");
            //return this.childCollection.parse(data);
            UWA.log(data);

                return this.parseMappingData(data);
           
        },

        create: function(attributes, options) {
            options.proxy = 'passport';
            this._parent.apply(this, [attributes, options]);
        },

    

        parseMappingData: function (data) {
            var rMapping, MappingNodeModel,
                AttributeInfo  = [],
                TypeRelInfo = [],
                InterfaceInfo = [],
                InterfaceMapping = [],
                TypeRelMapping = [],
                AttributeMapping =[];

            UWA.log("LifecycleCollection::parse");
            UWA.log(data);

            MappingNodeModel = ParameterizationDataUtils.paramStructBuilder("id,TypeRelInfo,InterfaceInfo,InterfaceMapping,TypeRelMapping");
            rMapping = new MappingNodeModel("", "", "", "", "", "");

            if (Array.isArray(data.typeRelInfo)) {
            	
                data.typeRelInfo.forEach(function (rTypeRel) {
                	
                	AttributeInfo=[];
                	
                  	if (Array.isArray(rTypeRel.mappableAttributes)) {
                  		rTypeRel.mappableAttributes.forEach(function (rAttrInfo) {
                			
                  			AttributeInfo.push({
                            	id         : rAttrInfo.id,
                            	name : rAttrInfo.name,
                            	type :  rAttrInfo.type,
                            	range: rAttrInfo.range,
                            	itf: rAttrInfo.interface,
                            	basic: rAttrInfo.isbasic,
                            	deployed: rAttrInfo.isDeployed,
                            	isenum: rAttrInfo.isEnum
                            });
                        });
                    }
                	
                
                	TypeRelInfo.push({
                        id        : rTypeRel.id,
                        attributeInfo : AttributeInfo,
                        isType   : rTypeRel.isType,
                        isCusto  : rTypeRel.isCusto,
                        derivedFrom  : rTypeRel.derivedFrom,
                        derivationPath : rTypeRel.derivationPath,
                        name : rTypeRel.name
                    });
                });
            }
     

            if (Array.isArray(data.typeRelMapping)) {
                data.typeRelMapping.forEach(function (rTypeRelMapping) {
                	
                	AttributeMapping=[];
                	
                	
                	if (Array.isArray(rTypeRelMapping.attributeMapping)) {
                		rTypeRelMapping.attributeMapping.forEach(function (rAttrMapping) {
                			
                			
                			/*var VPMAttribute,MatrixAttribute,VPMTypeAttribute,MatrixTypeAttribute,VPMItfAttribute,MatrixItfAttribute;
                			
                				VPMAttribute = rAttrMapping.vpmAttribute.id;
                				VPMTypeAttribute = rAttrMapping.vpmAttribute.type;
                				MatrixAttribute = rAttrMapping.mxAttribute.id;
                				MatrixTypeAttribute = rAttrMapping.mxAttribute.type;*/
                			
                				/*var status = "Deployed";
                				if(!rAttrMapping.isDeployed)
                					status = "Stored";*/
                		
                        	AttributeMapping.push({
                            	VPMAttribute         : {id:rAttrMapping.vpmAttribute.id,name:rAttrMapping.vpmAttribute.name,type:rAttrMapping.vpmAttribute.type,itf:rAttrMapping.vpmAttribute.interface,basic:rAttrMapping.vpmAttribute.isbasic,deployed:rAttrMapping.vpmAttribute.isDeployed,isenum:rAttrMapping.vpmAttribute.isenum},
                            	MatrixAttribute     :  {id:rAttrMapping.mxAttribute.id,name:rAttrMapping.mxAttribute.name,type:rAttrMapping.mxAttribute.type,itf:rAttrMapping.mxAttribute.interface,basic:rAttrMapping.mxAttribute.isbasic,deployed:rAttrMapping.mxAttribute.isDeployed,isenum:rAttrMapping.mxAttribute.isenum},
                            	SynchDirection          : rAttrMapping.synchDirection,
                            	status          : rAttrMapping.deployedStatus,
                            	OriginalSynchDirection:  rAttrMapping.synchDirection,
                            	isBaseMapping: rAttrMapping.isBaseMapping,
                            });
                        });
                    }
                	
                	TypeRelMapping.push({	
                		
                	    AttributeMapping:      AttributeMapping,
                		KindOfMapping         : rTypeRelMapping.kindOfMapping,
                    	VPMObjectName         : rTypeRelMapping.vpmObject.name,
                    	VPMObject         : rTypeRelMapping.vpmObject.id,
                    	MatrixObject     : rTypeRelMapping.mxObject.id,
                    	MatrixObjectName     : rTypeRelMapping.mxObject.name,
                    	SynchDirection     : rTypeRelMapping.synchDirection,
                    	isBaseMapping          : rTypeRelMapping.isBaseMapping,
                    	DerivationPath   : rTypeRelMapping.derivationPath,
                    	status          : "deployed",
                    });
                });
            }
           

            //listofRules, typeCategory, typeID, typeNLS

            rMapping.id = data.id;
            rMapping.TypeRelInfo = TypeRelInfo;
            rMapping.TypeRelMapping = TypeRelMapping;
            return rMapping;
        }

    });

    //return ParameterizationParentCol;
});

/*! Copyright 2017, Dassault Systemes. All rights reserved. */
/*@fullReview  NZV 17/05/09 remove getDimensions function*/
/*@fullReview  NZV 17/04/28 Add function getDimensions*/
/*@fullReview  ZUR 15/07/24 2016xFD01*/
/*@quickReview ZUR 15/11/23 2017x Param Skeleton*/
/*global define*/
define(
    'DS/ParameterizationSkeleton/Utils/ParameterizationWebServices',
    [
        'UWA/Core',
        'DS/WAFData/WAFData',
        'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler'
    ],
    function(UWA, WAFData, URLHandler) {

        'use strict';

        var wsUtils = {

            postParamsArrOnServer : function (connectProps, jsonArr, theImageCell, onFailurefct, onSuccessfct) {

                var url = URLHandler.getURL() + "/resources/ParamWS/access/postparams?tenant=" + URLHandler.getTenant(),
                    datatoSend = {
                        domain    : connectProps.domainName,
                        parameter : jsonArr
                    };
                    //onFailurefct = onFailurefct.bind(this);
                    //onSuccessfct = onSuccessfct.bind(this);
                    //WAFData.authenticatedRequest
                    //UWA.Data.request

                WAFData.authenticatedRequest(url, {
                    timeout: 100000,
                    method: 'POST',
                    data: JSON.stringify(datatoSend),
                    type: 'json',
                    //proxy: 'passport',

                    headers: {
                        'Content-Type' : 'application/json',
                        'Accept' : 'application/json'
                    },

                    onFailure : function (json) {
                        onFailurefct(json, theImageCell); //this.onApplyFailure(json, this, theImageCell);
                    },

                    onComplete: function(json) {
                        onSuccessfct(json, theImageCell);
                    }
                });
            },//postParamsArrOnServer

            ImportParamToServer : function (iStream, iAction, importFailurefct, importSucessfct) {
                var url = URLHandler.getURL() + "/resources/ParamWS/access/importparams?tenant=" + URLHandler.getTenant();
                url = url + "&importAction=" + iAction;

                WAFData.authenticatedRequest(url, {
                    timeout: 100000,
                    method: 'POST',
                    data: iStream, //JSON.stringify(datatoSend),
                    type: 'text',
                    //proxy: 'passport',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    onFailure : function (json) {
                        importFailurefct(json);
                    },
                    onComplete: function(json) {
                        importSucessfct(json, iAction);
                    }
                });
            },

            deployParamsOnServer : function (onDeployFailure, onDeploySuccess) {
                var url = URLHandler.getURL() + "/resources/ParamWS/access/deployallparams?tenant=" + URLHandler.getTenant();

                WAFData.authenticatedRequest(url, {
                    timeout: 100000,
                    method: 'POST',
                    type: 'json',
                    //proxy: 'passport',

                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },

                    onFailure : function (json) {
                        onDeployFailure(json);
                    },

                    onComplete: function(json) {
                        onDeploySuccess(json);
                    }
                });
            },

            postLifecycleParams : function (datatoSend, onDeployFailurefct, onDeploySuccessfct) {
                var url = URLHandler.getURL() + "/resources/ParamWS/lifecycle/postlcparams?tenant=" + URLHandler.getTenant();
                WAFData.authenticatedRequest(url, {
                    timeout: 100000,
                    method: 'POST',
                    data: JSON.stringify(datatoSend),
                    type: 'json',

                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },

                    onFailure : function (json) {
                        onDeployFailurefct(json);
                    },

                    onComplete: function(json) {
                        onDeploySuccessfct(json);
                    }
                });
            },

            GetTicketForDownload: function(iFileID, onSuccessfct, onFailurefct) {
                var url = URLHandler.getURL() + "/resources/ParamWS/access/getCheckoutParamGenericFileTicket";//getCheckoutParamFileTicket

                WAFData.authenticatedRequest(url, {
                    data: {
                        fileID : iFileID,
                        tenant : URLHandler.getTenant()
                    },
                    headers: {
                        'Accept': 'application/json'//,
                       // 'Content-Type': 'application/json'
                    },
                    method: 'get',
                    type: 'json',
                    //proxy: 'passport',
                    onComplete: function(json) {
                        onSuccessfct(json, iFileID); //IR-684310-3DEXPERIENCER2019x
                    },
                    onFailure: function(json) {
                        onFailurefct(json, iFileID);
                    }
                });
            },

            postAttributesOnServer : function (jsonArr, servicePath, onFailurefct, onSuccessfct) {

                var url = URLHandler.getURL() + "/resources/ParamWS/datamodel/" + servicePath + "?tenant=" + URLHandler.getTenant();
                //postattrparams

                WAFData.authenticatedRequest(url, {
                    timeout: 250000,
                    method: 'POST',
                    data: JSON.stringify(jsonArr),
                    type: 'json',
                    //proxy: 'passport',
                    headers: {
                        'Content-Type' : 'application/ds-json',
                        'Accept' : 'application/ds-json'
                    },
                    onFailure : function (json) {
                        onFailurefct(json);
                    },
                    onComplete: function(json) {
                        onSuccessfct(json);
                    }
                });
            },//postParamsArrOnServer

            launchServiceOnServer : function (wsPath, onSuccessfct, onFailurefct) {
                var url = URLHandler.getURL() + "/resources/ParamWS/" + wsPath;

                WAFData.authenticatedRequest(url, {
                    headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json'
                    },
                    method: 'POST',
                    type: 'json',
                    //proxy: 'passport',
                    onComplete: function(json) {
                        onSuccessfct(json);
                    },
                    onFailure: function(json) {
                        onFailurefct(json);
                    }
                });
            }
        };

        return wsUtils;

    }
);

//@fullReview  ZUR 15/03/11 2016x HL 
//@fullReview  ZUR 16/02/13 2017x
//@fullReview  ZUR 17/07/06 2018x IR-529086-3DEXPERIENCER2018x
/*global define, document*/
/*jslint plusplus: true*/

define('DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/LifecycleViewUtilities',
    [
        'UWA/Core',
        'DS/UIKIT/Input/Button',
        'DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
        'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS'
    ],
    function(UWA,
            Button,
            ParametersLayoutViewUtilities,
            ParamSkeletonNLS) {

        'use strict';
        //'UWA/Controls/Abstract',
        var lcview = {

            buildLifecycleChecksView : function(wdthArray) {
                //UWA.log("buildLifecycleChecksView");
                var k, iTitleRowSum, AlreadySetRlsDiv, rulesTbl, tbody, newRow, newCell,
                    expandButton, reduceButton;

                AlreadySetRlsDiv =  UWA.createElement('div', {
                    'id': 'AlreadySetRules'
                });
                /*AlreadySetRlsDiv.style.overflowY = 'auto';
                AlreadySetRlsDiv.style.overflowX = 'auto';      
                AlreadySetRlsDiv.style.minHeight = '20%';*/
                //document.getElementsByTagName('body')[0].appendChild(AlreadySetRlsDiv);
                //
                rulesTbl =  UWA.createElement('table', {
                    'id': 'rulestable',
                    'class': 'table table-condensed table-hover'
                });
                /*      
                rulesTbl.style.width="100%";
                rulesTbl.style.height="20%";        
                rulesTbl.cellPadding="0"; rulesTbl.cellSpacing="2";
                rulesTbl.style.backgroundColor="white";*/
                tbody =  UWA.createElement('tbody', {
                    'class': 'paramtbody'
                }).inject(rulesTbl);

                newRow = UWA.createElement('tr').inject(tbody);//row1

                for (k = 0; k < 6; k++) {
                    iTitleRowSum = iTitleRowSum + wdthArray[k];
                }
                //{title: ParamSkeletonNLS.CurrentControlsTitle}
                //newRow.style.backgroundColor = "#659ac2";

                newCell = UWA.createElement('td',
                        {'width': iTitleRowSum.toString() + '%', 'colspan': '6', 'title': ParamSkeletonNLS.CurrentControlsTitle}).inject(newRow);//60%
                //
                UWA.createElement('h5', {
                    text: ParamSkeletonNLS.CurrentControlsTitle// font-3dsbold
                    //'class': 'font-3dslight'
                }).inject(newCell);

                newCell = UWA.createElement('td',
                    {'width': wdthArray[6].toString() + '%', 'align' : 'right'}).inject(newRow);//20%

                newCell.setStyle("padding-right", "15px");

                expandButton = new Button({
                    className: 'close',
                    icon: 'fonticon fonticon-resize-full',//value: 'Button', //fonticon-cancel  fonticon-minus-circled  
                    attributes: {
                        disabled: false,
                        title : ParamSkeletonNLS.Expand,//"expand",
                        'aria-hidden' : 'true'
                    }
                }).inject(newCell);

                reduceButton = new Button({
                    className: 'close',
                    icon: 'fonticon fonticon-resize-small',
                    attributes: {
                        disabled: false,
                        title : ParamSkeletonNLS.Reduce, //"reduce",
                        'aria-hidden' : 'true'
                    },
                    events: {
                        onClick: function () {
                            UWA.log(AlreadySetRlsDiv);//.log(AlreadySetRlsDiv.getStyle("height"));
                            AlreadySetRlsDiv.setStyle("height", "30%");
                            this.hide();
                            expandButton.show();
                        }
                    }
                }).inject(newCell);
                reduceButton.hide();

                expandButton.addEvent("onClick", function () {
                    AlreadySetRlsDiv.setStyle("height", "50%");
                    this.hide();
                    reduceButton.show();
                });

                newRow = UWA.createElement('tr', {title: ''}).inject(tbody);//row2                    
                //newRow.style.backgroundColor = "#CDD8EB";
                k = 0;
                newCell = UWA.createElement('td',
                    {'width': wdthArray[k++].toString() + '%', 'title': ParamSkeletonNLS.DataTypeLabel}).inject(newRow);

                UWA.createElement('h5', {
                    //'class': 'font-3dslight',//'',font-3dsregular
                    text: ParamSkeletonNLS.DataTypeLabel
                }).inject(newCell);

                newCell = UWA.createElement('td', {
                    'width': wdthArray[k++].toString() + '%',//10
                    'title': ParamSkeletonNLS.FromStatusLabel
                }).inject(newRow);

                UWA.createElement('h5', {
                    //'class': 'font-3dslight',
                    text: ParamSkeletonNLS.FromStatusLabel
                }).inject(newCell);

                newCell = UWA.createElement('td',
                        {'width': wdthArray[k++].toString() + '%', 'title': ParamSkeletonNLS.ToStatusLabel}).inject(newRow);//10

                UWA.createElement('h5', {
                    //'class': 'font-3dslight',
                    text: ParamSkeletonNLS.ToStatusLabel
                }).inject(newCell);

                newCell = UWA.createElement('td',
                        {'width': wdthArray[k++].toString() + '%', 'title': ParamSkeletonNLS.Rulelabel}).inject(newRow);//15

                UWA.createElement('h5', {
                    //'class': 'font-3dslight',
                    text: ParamSkeletonNLS.Rulelabel
                }).inject(newCell);

                newCell = UWA.createElement('td', {
                    'width': '15%',
                    'title': ParamSkeletonNLS.AdditionalInfoTitle
                }).inject(newRow);

                UWA.createElement('h5', {
                    //'class': 'font-3dslight',
                    text: ParamSkeletonNLS.AdditionalInfoTitle
                }).inject(newCell);

                newCell = UWA.createElement('td', {
                    'width': wdthArray[k++].toString() + '%',//15
                    'title': ParamSkeletonNLS.RemoveElement //NZV:IR-629593-3DEXPERIENCER2019x
                }).inject(newRow);

                UWA.createElement('h5', {
                    //'class': 'font-3dslight',
                    text: ParamSkeletonNLS.RemoveElement
                }).inject(newCell);

                newCell = UWA.createElement('td', {
                    'width' : wdthArray[k++].toString() + '%',//7
                    'title' : ParamSkeletonNLS.DeployStatus
                }).inject(newRow);//dernière colonne : pas de titre        

                AlreadySetRlsDiv.appendChild(rulesTbl);

                return AlreadySetRlsDiv;
            },

            addDeployIndicator : function (deployStatus) {
                UWA.log("addApplyIndicator");
                var deployIndicDiv, deployTable, dtbody, newRow, imageCell, imgSpan,
                    imgTitle = ParamSkeletonNLS.deployedParamtxt,
                    imgClass = 'fonticon fonticon-2x fonticon-check',
                    iconColor = 'green';

                deployIndicDiv =  UWA.createElement('div', {
                    'id': 'IndicatorDiv'
                });

                deployTable =  UWA.createElement('table', {
                    'id': 'rulestable',
                    'class': 'table table-condensed table-hover'
                }).inject(deployIndicDiv);

                dtbody =  UWA.createElement('tbody', {
                    'class': 'indicatortbody'
                }).inject(deployTable);

                newRow = UWA.createElement('tr').inject(dtbody);//row1
                //newRow.style.backgroundColor = "#659ac2";
                imageCell = UWA.createElement('td',
                        {'width': '100%', 'title': ParamSkeletonNLS.deployedParamtxt}).inject(newRow);

                if (deployStatus === false) {
                    iconColor = "orange";
                    imgClass = 'fonticon fonticon-2x fonticon-cog';
                    imgTitle =  ParamSkeletonNLS.notdeployedParamtxt;//"Some Parameters are not Deployed"
                }

                imgSpan = UWA.createElement('span', {
                    'class' : imgClass
                }).inject(imageCell);

                imgSpan.setStyle("color", iconColor);
                imageCell.set("Title", imgTitle);

                return deployIndicDiv;
            },

            updateIcon : function(result, imageCell) {
                var imgSpan,
                    imgTitle = ParamSkeletonNLS.deployedParamtxt,
                    imgClass = 'fonticon fonticon-2x fonticon-check',
                    iconColor = 'green';

                imageCell.empty();

                if (result !== true) {
                    imgClass = 'fonticon fonticon-2x fonticon-alert';
                    imgTitle = ParamSkeletonNLS.notdeployedParamtxt;
                    iconColor = 'red';
                }
                imgSpan = UWA.createElement('span', {
                    'class' : imgClass
                }).inject(imageCell);
                imgSpan.setStyle("color", iconColor);
                imageCell.set("Title", imgTitle);
            },

            beingModified : function (imageCell, imgTitle) {
                var imgClass = 'fonticon fonticon-2x fonticon-pencil';

                imageCell.empty();
                UWA.createElement('span', {
                    'class' : imgClass
                }).inject(imageCell);

                imageCell.set("Title", imgTitle);
            },

            getNamingDeployCellSts : function (tbodyreflist) {
                var iLines = tbodyreflist[0].children;
                return (iLines[0].cells[0]);
            },

            getCurrentChecks : function(iContentDiv) {
                var tbodyref = iContentDiv.getElements('.paramtbody')[0],
                    listofLines = tbodyref.children,
                    nbofLines = listofLines.length,
                    clistofChecks = [],
                    iadditionalinfo = "",
                    i,
                    iRule,
                    iID;

                this.clearPreviousChecksHighlighting(listofLines);

                for (i = 2; i < nbofLines; i++) {
                    iRule = listofLines[i].cells[3].value;

                    /* if ( (document.getElementById('rulestable').rows[i].cells[4].childNodes[0])==null)
                        iadditionalinfo="";
                    else
                        iadditionalinfo = document.getElementById('rulestable').rows[i].cells[4].childNodes[0].value;
    
                    if (iRule=="RejectIfAttributeNotValuated") {
                        var iID=iadditionalinfo.indexOf(":");
                        iadditionalinfo=iadditionalinfo.substring(iID+1,iadditionalinfo.length);
                    }
                
                    if ((iRule=="RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState")
                            &&(iadditionalinfo!="ALL")) {
                            iadditionalinfo = document.getElementById('rulestable').rows[i].cells[4].value; 
                    }*/

                    if (listofLines[i].cells[4].value === null) {
                        iadditionalinfo = "";
                    } else {
                        iadditionalinfo = listofLines[i].cells[4].value;
                    }
                    //
                    if (iRule === "RejectIfAttributeNotValuated") {
                        iID = iadditionalinfo.indexOf(":");
                        iadditionalinfo = iadditionalinfo.substring(iID + 1, iadditionalinfo.length);
                    }
                    //
                    if ((iRule === "RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState")
                                && (iadditionalinfo !== "ALL")) {
                        iadditionalinfo = listofLines[i].cells[4].value;
                    }

                    clistofChecks.push({
                        objType         : listofLines[i].cells[0].value,
                        fromState       : listofLines[i].cells[1].value,
                        toState         : listofLines[i].cells[2].value,
                        ruleID          : iRule,
                        additionalProps : iadditionalinfo
                    });
                }
                return clistofChecks;
            },

            printTransitionList : function (iList) {
                var e, nbofTransitions = 0;

                for (e = iList.first; e; e = e.next) {
                    UWA.log(e);
                    UWA.log("from : " + e.cl1.c.node.stateid + " to : " + e.cl2.c.node.stateid);
                    nbofTransitions++;
                }
                UWA.log("nbofTransitions = " + nbofTransitions);
            },

            printNodesList : function (iList) {
                var e, nbofstates = 0;

                for (e = iList.first; e; e = e.next) {
                    UWA.log(e);
                    UWA.log(e.stateid + "<-->" + e.name);
                    nbofstates++;
                }
                UWA.log("nbofstates =" + nbofstates);
            },

            sortArrayByKey: function(array, key) {
                return array.sort(function(a, b) {
                    var x = a[key],
                        y = b[key];
                    return ((x < y) ? -1 : ((x > y) ? 1 : 0));
                });
            },

            clearPreviousChecksHighlighting: function (iListofRows) {
                var i, nbofRows = iListofRows.length;

                for (i = 2; i < nbofRows; i++) {
                    iListofRows[i].removeClassName("info");
                }
            },

            resetLifecycleChecks : function(listofLines) {
                var i = listofLines.length - 1;
                while (i >= 2) {
                    listofLines[i].remove();
                    i--;
                }
            },

            populateAddInfoSelect: function (iSelect, selectedType, iListofSortedTypes) {
                var i,
                    nbofTypes = iListofSortedTypes.length,
                    currTypeCategory;

                for (i = 0; i < nbofTypes; i++) {
                    if (selectedType[0] === iListofSortedTypes[i].typeID) {
                        currTypeCategory = iListofSortedTypes[i].typeCategory;
                        break;
                    }
                }

                iSelect.remove();
                iSelect.add([{
                    label: ParamSkeletonNLS.AllChildrenTypes,
                    value: "ALL"
                }]);

                for (i = 0; i < nbofTypes; i++) {
                    if (currTypeCategory === iListofSortedTypes[i].typeCategory) {
                        iSelect.add([{
                            label: iListofSortedTypes[i].typeNLS,
                            value: iListofSortedTypes[i].typeID
                        }]);
                    }
                }

                return;
            },

            getListofAttributesForType : function(selectedType, sortedTypes) {

                var i,
                    nbofTypes = sortedTypes.length,
                    listofAttrs = "";

                for (i = 0; i < nbofTypes; i++) {
                    if (selectedType[0] === sortedTypes[i].typeID) {
                        if (sortedTypes[i].listofAddedAttributes !== undefined) {
                            listofAttrs = sortedTypes[i].listofAddedAttributes;
                        }
                        break;
                    }
                }
                return listofAttrs;
            },

            populateAttributesSelector : function (attributesSelector, iAttributes) {

                var i,
                    nbofAttr,
                    iListofAttributes;

                attributesSelector.remove();

                if (iAttributes !== "") {
                    iListofAttributes = iAttributes.split(';');
                    nbofAttr = iListofAttributes.length;

                    for (i = 0; i < nbofAttr; i++) {
                        attributesSelector.add([{
                            label: iListofAttributes[i],
                            value: iListofAttributes[i]
                        }]);
                    }
                }
            },

            updateRulesListforType : function(RulesListSelect, selectedType, iListofSortedTypes) {
                var i, rulesforType, listofRulesForType, nbofRules,
                    nbofTypes = iListofSortedTypes.length;

                for (i = 0; i < nbofTypes; i++) {
                    if (selectedType[0] == iListofSortedTypes[i].typeID) {
                        rulesforType = iListofSortedTypes[i].listofRules;
                        break;
                    }
                }

                listofRulesForType = rulesforType.split(',');
                nbofRules = listofRulesForType.length;

                RulesListSelect.remove();

                for (i = 0; i < nbofRules; i++) {
                    RulesListSelect.add([{
                        //label: eval("ParamSkeletonNLS." + listofRulesForType[i] + "Text"),
                        label: ParamSkeletonNLS[listofRulesForType[i] + "Text"],
                        value: listofRulesForType[i]
                    }]);
                }
            },

            getMatchingNode : function(iNodeList, iNodeID) {
                var e;
                for (e = iNodeList.first; e; e = e.next) {
                    if (e.stateid == iNodeID) {
                        return e;
                    }
                }
                return null;
            },

            checkforSingletonStates : function(iNodes, iEdges) {
                var eNode, itr,
                    edgeList = iEdges,//this.grph.edges,
                    isNodeConnected = false;
                    //this.grph.nodes.first
                for (eNode = iNodes.first; eNode; eNode = eNode.next) {
                    isNodeConnected = false;
                    for (itr = edgeList.first; itr; itr = itr.next) {
                        if ((itr.cl1.c.node.stateid == eNode.stateid) ||
                                (itr.cl2.c.node.stateid == eNode.stateid)) {
                            isNodeConnected = true;
                            break;
                        }
                    }
                    if (isNodeConnected === false) {//IR-529086-3DEXPERIENCER2018x
                        if (eNode.next !== null || eNode.prev !== null) {
                            UWA.log(eNode.stateid + " is not connected ");
                            return false;
                        }
                    }
                }

                return true;
            },

            removeRelatedChecksForTransition : function (iSource, iDestination, tbodyref) {
                var listofLines = tbodyref.children,
                    i = listofLines.length - 1;

                while (i >= 2) {
                    if ((listofLines[i].cells[1].value == iSource) &&
                            (listofLines[i].cells[2].value == iDestination)) {
                        listofLines[i].remove();
                    }
                    i--;
                }
            },

            removeRelatedChecksForState : function (iStateID, tbodyref) {
                var i,
                    listofLines = tbodyref.children;
                //
                i = listofLines.length - 1;
                while (i >= 2) {
                    if ((listofLines[i].cells[1].value == iStateID) ||
                            (listofLines[i].cells[2].value == iStateID)) {
                        listofLines[i].remove();
                    }
                    i--;
                }
            },

            isCheckAlreadyAdded : function (iType, iSource, iDestination, iRule, iAddinfo, tbodyref) {
                //var tbodyref = this.contentDiv.getElements('.paramtbody')[0];
                var i,
                    listofLines = tbodyref.children,
                    nbofLines = listofLines.length;

                for (i = 2; i < nbofLines; i++) {
                    if ((listofLines[i].cells[1].value == iSource) &&
                            (listofLines[i].cells[2].value == iDestination) &&
                                (listofLines[i].cells[0].value == iType) &&
                                    (listofLines[i].cells[3].value == iRule)) {
                        //Additional Infos Tests
                        if (iAddinfo == listofLines[i].cells[4].value) {
                            return true;//Check Already there
                        }
                        if ((iAddinfo === "ALL") ||
                                (listofLines[i].cells[4].value === "ALL")) {
                            UWA.log("Check Already there::ALL");
                            return true;
                        }
                    }
                }
                return false;
            },

            UpdateLifecycleChecksStsInTable : function(iContentDiv) {
                var imgSpan,
                    tbodyreflist = iContentDiv.getElements('.paramtbody'),
                    iLines = tbodyreflist[0].childNodes,
                    nbofLines = iLines.length,
                    i = nbofLines - 1;

                while (i > 1) {
                    /*if (iLines[i].cells[10].value === "DeletedNotDeployed") {
                        iLines[i].remove();
                    } else */
                    if (iLines[i].cells[6].value === "newcheck") {
                        iLines[i].cells[6].empty();
                        iLines[i].cells[6].value = true;
                        imgSpan = ParametersLayoutViewUtilities.buildImgSpan('check', '1.5', 'green');
                        imgSpan.inject(iLines[i].cells[6]);
                    }
                    i--;
                }
            },

            disableApplyButton : function (iContentDiv) {
                var applyBttnPtr = iContentDiv.getElements('.btn-primary')[0];
                applyBttnPtr.disabled = true;
            },

            enableApplyButton : function (iContentDiv) {
                var applyBttnPtr = iContentDiv.getElements('.btn-primary')[0];
                applyBttnPtr.disabled = false;
            },

            sign: function (x) {
                return typeof x === 'number' ? x ? x < 0 ? -1 : 1 : x === x ? 0 : NaN : NaN;
            },

            transformCoordinates : function(iCoord, transVec) {
                //this.grph.views.main.vpt
                var xL, yL,
                    s = transVec[2],
                    tx = transVec[0],
                    ty = transVec[1],
                    lCoord = [];

                xL = (iCoord[0] + tx) * s;
                yL = (iCoord[1] + ty) * s;

                lCoord.push(xL);
                lCoord.push(yL);

                return lCoord;
            }

        };

        return lcview;

    });

define('DS/ParameterizationSkeleton/Views/ParameterizationXEngineering/XENGModal',
	[
		'DS/UIKIT/Modal',
		'UWA/Core',
		'DS/UIKIT/Input/Select',
		'DS/UIKIT/Input/Text',
		'DS/UIKIT/Input/Number',
		'DS/UIKIT/Alert',
		'DS/UIKIT/Tooltip',
		'DS/WAFData/WAFData',
		'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler',
		'DS/ParameterizationSkeleton/Views/ParameterizationXEngineering/ParameterizationXEngineerConstants',
		'i18n!DS/ParameterizationSkeleton/assets/nls/XEngineeringNLS'
	],
	function (Modal,
		UWACore,
		Select,
		Text,
		Number,
		Alert,
		Tooltip,
		WAFData,
		URLHandler,
		ParameterizationXEngineerConstants,
		XEngineeringNLS) {

	'use strict';

	function _createModal(options) {
		var modal = new Modal({
				className: options.className || '',
				closable: true,
				header: '<h4>' + options.title + '</h4>',
				body: '',
				footer: ''
			});
		return modal;
	}

	function XEngineerModal(options) {
		this.options = {
			title: 'Dialog',
			className: '',
			withFooter: true
		};
		this.options = UWACore.extend(this.options, options);

		this.modal = _createModal(this.options);
		this.modal.inject(document.querySelector('#typeMainDiv'));
		if (this.options.withFooter) {
			this._bindFooterEvent();
		}

	}

	XEngineerModal.prototype.getPartNumberFormat = function () {

		var _formatContent = this.modal.getContent().getElement('.enox-part-number-content');
		var that = this;

		if (this.partNumberTypeCombobox.getValue()[0] == ParameterizationXEngineerConstants.FORMAT_FREE) {
			var _dynamicFormatContent = this.modal.getContent().getElement('.enox-part-number-dynamic-content');
			_dynamicFormatContent.empty();
			that.destroyValueFieldComponents();
		} else if (this.partNumberTypeCombobox.getValue()[0] == ParameterizationXEngineerConstants.FORMAT_STRING) {
			that.destroyValueFieldComponents();
			that.getValueField(_formatContent);
		} else if (this.partNumberTypeCombobox.getValue()[0] == ParameterizationXEngineerConstants.FORMAT_ATTRIBUTE) {
			that.destroyValueFieldComponents();
			that.getDynamicFields(_formatContent, this.partNumberTypeCombobox.getValue()[0]);
		} else if (this.partNumberTypeCombobox.getValue()[0] == ParameterizationXEngineerConstants.FORMAT_COUNTER) {
			that.destroyValueFieldComponents();
			that.getDynamicFields(_formatContent, this.partNumberTypeCombobox.getValue()[0]);
		}
	};

	XEngineerModal.prototype.getDefaultFields = function (_formatContent) {

		var that = this;

		var divTag = document.createElement('div');
		divTag.className = "formats";

		var labelDiv = document.createElement('div');
		labelDiv.className = "formats-label";
		labelDiv.innerText = XEngineeringNLS.name; //formats[i];

		var textBoxDiv = document.createElement('div');
		textBoxDiv.className = "formats-tbox";
		var textOptions = {
			events: {
				//  onChange: that.validateEnteredNameValue.bind(that)
			}
		};

		this.nameTextBox = this.getTextBox(textOptions);
		this.nameTextBox.domId = XEngineeringNLS.name + "_textBox";
		this.nameTextBox.inject(textBoxDiv);

		divTag.appendChild(labelDiv);
		divTag.appendChild(textBoxDiv);

		_formatContent.appendChild(divTag);

		var divTagForNbrBox = document.createElement('div');
		divTagForNbrBox.className = "formats";

		var labelDivForNbrBox = document.createElement('div');
		labelDivForNbrBox.className = "formats-label";
		labelDivForNbrBox.innerText = XEngineeringNLS.order; //formats[i];

		var textBoxDivForNbrBox = document.createElement('div');
		textBoxDivForNbrBox.className = "formats-tbox";

		var numberOptions = {
			min: 1,
			max: ParameterizationXEngineerConstants.MAX_ROWS,

			value: this.getHighestOrder() + 1,
			events: {}
		};

		this.numberOrderBox = this.getNumberBox(numberOptions);
		this.numberOrderBox.domId = XEngineeringNLS.order + "_textBox";
		this.numberOrderBox.inject(textBoxDivForNbrBox);




		divTagForNbrBox.appendChild(labelDivForNbrBox);
		divTagForNbrBox.appendChild(textBoxDivForNbrBox);

		_formatContent.appendChild(divTagForNbrBox);

		var divTagForType = document.createElement('div');
		divTagForType.className = "formats";

		var typelabelDiv = document.createElement('div');
		typelabelDiv.className = "formats-label";
		typelabelDiv.innerText = XEngineeringNLS.type;

		var typeComboBoxDiv = document.createElement('div');
		typeComboBoxDiv.className = "formats-tbox";

		var selectOptions = {
				custom: false,
				placeholder: XEngineeringNLS.selectType,
				options: [{
						label: XEngineeringNLS.String,
						value: ParameterizationXEngineerConstants.FORMAT_STRING
					}, {
						label: XEngineeringNLS.Free,
						value: ParameterizationXEngineerConstants.FORMAT_FREE
					}, {
						label: XEngineeringNLS.Attribute,
						value: ParameterizationXEngineerConstants.FORMAT_ATTRIBUTE
					}, {
						label: XEngineeringNLS.Counter,
						value: ParameterizationXEngineerConstants.FORMAT_COUNTER
					}

				],
				events: {
					onChange: that.getPartNumberFormat.bind(that)
				}
			};

		this.partNumberTypeCombobox = this.getSelectComponent(selectOptions);
		this.partNumberTypeCombobox.setId(XEngineeringNLS.type + "_comboBox");
		this.partNumberTypeCombobox.inject(typeComboBoxDiv);

		divTagForType.appendChild(typelabelDiv);
		divTagForType.appendChild(typeComboBoxDiv);
		_formatContent.appendChild(divTagForType);

	};

	XEngineerModal.prototype.getDynamicFields = function (_formatContent, format) {
		var that = this;

		var _dynamicFormatContent = this.modal.getContent().getElement('.enox-part-number-dynamic-content');
		_dynamicFormatContent.empty();

		if (format == ParameterizationXEngineerConstants.FORMAT_ATTRIBUTE) {
			that.getAttributeFormat(_formatContent, _dynamicFormatContent);

		} else if (format == ParameterizationXEngineerConstants.FORMAT_COUNTER) {
			this.getCounterFormat(_formatContent, _dynamicFormatContent);
		}

	};
	XEngineerModal.prototype.getAttributeFormat = function (_formatContent, _dynamicFormatContent) {

		var formatField = XEngineeringNLS.attribute;

		var divTag = document.createElement('div');
		divTag.className = "formats";

		var labelDiv = document.createElement('div');
		labelDiv.className = "formats-label";
		labelDiv.innerText = formatField;

		var comboBoxDiv = document.createElement('div');
		comboBoxDiv.className = "formats-tbox";
		var allAttributes = [];

		if (typeof this.attributes.message === "undefined") {
			for (var key in this.attributes) {
				var attributes1 = {};

				attributes1["label"] = this.attributes[key]
				attributes1["value"] = key

				allAttributes.push(attributes1);
			}
		}

		var selectOptions = {
			custom: false,
			placeholder: XEngineeringNLS.selectAttribute,
			options: allAttributes
		};

		this.partNumberAttributeCombobox = this.getSelectComponent(selectOptions);

		this.partNumberAttributeCombobox.setId(formatField + "_comboBox");
		this.partNumberAttributeCombobox.inject(comboBoxDiv);

		divTag.appendChild(labelDiv);
		divTag.appendChild(comboBoxDiv);

		var formatFieldValue = XEngineeringNLS.defaultValue;
			var divTagForValue = document.createElement('div');
		divTagForValue.className = "formats";

		var labelDivForValue = document.createElement('div');
		labelDivForValue.className = "formats-label";
		labelDivForValue.innerText = formatFieldValue;

		var textBoxDivForValue = document.createElement('div');
		textBoxDivForValue.className = "formats-tbox";
		this.valueDynTextBox = this.getTextBox();
		this.valueDynTextBox.domId = formatFieldValue + "_textBox";
		this.valueDynTextBox.inject(textBoxDivForValue);

		divTagForValue.appendChild(labelDivForValue);
		divTagForValue.appendChild(textBoxDivForValue);

		_dynamicFormatContent.appendChild(divTag);
		_dynamicFormatContent.appendChild(divTagForValue);
		_formatContent.appendChild(_dynamicFormatContent);

	};

	XEngineerModal.prototype.getCounterFormat = function (_formatContent, _dynamicFormatContent) {
		var that = this;
		var divTagForNbrBox = document.createElement('div');
		divTagForNbrBox.className = "formats";

		var labelDivForNbrBox = document.createElement('div');
		labelDivForNbrBox.className = "formats-label";

		var divForLabel = document.createElement('div');
		divForLabel.className = 'label-counter';

		var labelText = document.createElement('div');
		labelText.className = 'label-text';
		labelText.innerText = XEngineeringNLS.digits;

		var informationDiv = document.createElement('div');
		informationDiv.className = "fonticon fonticon-attention";
		informationDiv.id = "information";
		informationDiv.style.color = "black";

		divForLabel.appendChild(labelText);
		divForLabel.appendChild(informationDiv);

		labelDivForNbrBox.appendChild(divForLabel);

		var textBoxDivForNbrBox = document.createElement('div');
		textBoxDivForNbrBox.className = "formats-tbox";

		var numberOptions = {
			min: 1,
			max: ParameterizationXEngineerConstants.MAX_ROWS /*Number.MAX_SAFE_INTEGER*/,
			step: 1,
			value: 6,
			events: {
				onChange: that.updateSampleText.bind(that)
			}
		};

		this.counterNumberBox = this.getNumberBox(numberOptions);
		this.counterNumberBox.domId = XEngineeringNLS.digits + "_textBox";
		this.counterNumberBox.inject(textBoxDivForNbrBox);

		divTagForNbrBox.appendChild(labelDivForNbrBox);
		divTagForNbrBox.appendChild(textBoxDivForNbrBox);

		_dynamicFormatContent.appendChild(divTagForNbrBox);

		var formatField = XEngineeringNLS.sample;

		var divTag = document.createElement('div');
		divTag.className = "formats-sample";

		var labelDiv = document.createElement('div');
		labelDiv.className = "formats-sample-label";
		//labelDiv.innerText = formatField;


		var sampleTextLabelSpan = document.createElement('span');
		sampleTextLabelSpan.id = "sampleTextLabel";
		sampleTextLabelSpan.innerText = formatField  +" : "  ;

		var sampleTextValueSpan = document.createElement('span');
		sampleTextValueSpan.id = "sampleValue";

		var textBoxDiv = document.createElement('div');
		textBoxDiv.className = "formats-sample-value";

		textBoxDiv.appendChild(sampleTextLabelSpan);
		textBoxDiv.appendChild(sampleTextValueSpan);
		//textBoxDiv.id = "sampleValue";

		divTag.appendChild(labelDiv);
		divTag.appendChild(textBoxDiv);

		_dynamicFormatContent.appendChild(divTag);
		_formatContent.appendChild(_dynamicFormatContent);

		this.updateSampleText(); // sets the number of digits value

		this.modal.getContent().getElement('#information').addEvent('mouseover', function () {
			that.getInformation(that.modal.getContent().getElement("#information"), XEngineeringNLS.counterTooltip);
		});

		// this.modal.getContent().getElement('#sampleValue').addEvent('mouseover', function () {
		//   that.getInformation(that.modal.getContent().getElement("#sampleValue"), event.currentTarget.getText());
		//
		// })


		// this.modal.getContent().getElement('#sampleValue').addEventListener('mouseout', function () {
		// 	//that.getInformation(that.modal.getContent().getElement("#sampleValue"), event.currentTarget.getText());
		// 	console.log(that);
		// 	that.tooltip.elements.body.empty()
		//
		// })


	};

	XEngineerModal.prototype.getInformation = function (targetElement, toDisplayOver) {

		var tooltipOtions = {
			target: targetElement,
			body: toDisplayOver
		};
		this.getTooltip(tooltipOtions);

	};

	XEngineerModal.prototype.getValueField = function (_formatContent) {

		var _dynamicFormatContent = this.modal.getContent().getElement('.enox-part-number-dynamic-content');

		_dynamicFormatContent.empty();

		var formatField = XEngineeringNLS.value;

		var divTag = document.createElement('div');
		divTag.className = "formats";

		var labelDiv = document.createElement('div');
		labelDiv.className = "formats-label";
		labelDiv.innerText = formatField;

		var textBoxDiv = document.createElement('div');
		textBoxDiv.className = "formats-tbox";
		this.valueTextBox = this.getTextBox();
		this.valueTextBox.domId = formatField + "_textBox";
		this.valueTextBox.inject(textBoxDiv);

		divTag.appendChild(labelDiv);
		divTag.appendChild(textBoxDiv);

		_dynamicFormatContent.appendChild(divTag);
		_formatContent.appendChild(_dynamicFormatContent);

	};

	XEngineerModal.prototype.getModalBody = function () {

		var partNumberContent = this.modal.elements.body;

		var _errorsMessageDiv = UWACore.createElement('div');
		_errorsMessageDiv.className = "enox-part-number-error-content";

		var _formatContent = UWACore.createElement('div');
		_formatContent.className = "enox-part-number-content";

		var _dynamicFormatContent = UWACore.createElement('div');
		_dynamicFormatContent.className = "enox-part-number-dynamic-content";

		this.getDefaultFields(_formatContent);

		partNumberContent.appendChild(_errorsMessageDiv);
		partNumberContent.appendChild(_formatContent);
		partNumberContent.appendChild(_dynamicFormatContent);
		return partNumberContent;
	};

	XEngineerModal.prototype.validateEnteredNameValue = function (operation, editingField) {

		var duplicateData = {};
		duplicateData.isValid = true;
		var userEnteredFormat = this.nameTextBox.getValue();
		var isSuccess = this.validateEnteredValues(userEnteredFormat, XEngineeringNLS.name, operation, editingField);

		if (!isSuccess) {
			duplicateData.isValid = false;
		}
		duplicateData.data = userEnteredFormat;
		return duplicateData;
	};

	XEngineerModal.prototype.validateEnteredOrderValue = function (operation, editingField) {

		var duplicateData = {};
		duplicateData.isValid = true;

		var userEnteredFormat = this.numberOrderBox.getValue();
		var isSuccess = this.validateEnteredValues(userEnteredFormat, XEngineeringNLS.order, operation, editingField);

		if (!isSuccess) {

			duplicateData.isValid = false;
		}

		duplicateData.data = userEnteredFormat;
		return duplicateData;
	};

	XEngineerModal.prototype.validateEnteredValues = function (userEnteredFormat, field, operation, editingField) {
		var rowsOfMappedFields = document.querySelectorAll(".partNumberFieldMapping");
		var successFields = document.querySelector('.success');


		var isSuccess = true;

		if (operation == "edit") {
			for (var k = 0; k < rowsOfMappedFields.length; k++) {
				if (rowsOfMappedFields[k] != editingField) {
					for (var j = 0; j < 2; j++) {
						if (successFields.getChildren()[j].getText() == field && userEnteredFormat == rowsOfMappedFields[k].getChildren()[j].getText()) {
							isSuccess = false;
							break;
						}
					}
				}
			}
		} else {
			for (var k1 = 0; k1 < rowsOfMappedFields.length; k1++) {

				for (var j1 = 0; j1 < 2; j1++) {
					if (successFields.getChildren()[j1].getText() == field && userEnteredFormat == rowsOfMappedFields[k1].getChildren()[j1].getText()) {
						isSuccess = false;
						break;
					}
				}
			}
		}
	return isSuccess;
	};

	XEngineerModal.prototype.validateEnteredNameValueNotNull = function () {
		var userEnteredFormat = this.nameTextBox.getValue();
		var isNull = this.validateEnteredValuesNotNull(userEnteredFormat);
		return isNull;
	};

	XEngineerModal.prototype.validateEnteredOrderValueNotNull = function () {
		var userEnteredFormat = this.numberOrderBox.getValue();
		var isNull = this.validateEnteredValuesNotNull(userEnteredFormat);
		return isNull;
	};

	XEngineerModal.prototype.validateEnteredValueFieldValueNotNull = function () {
		var isNull = false;
		if (this.getUserEnteredValues().Type != ParameterizationXEngineerConstants.FORMAT_ATTRIBUTE) {
			isNull = this.valueTextBox ? this.validateEnteredValuesNotNull(this.valueTextBox.getValue()) : this.valueDynTextBox ? this.validateEnteredValuesNotNull(this.valueDynTextBox.getValue()) : false;
		}
		return isNull;
	};

	XEngineerModal.prototype.validatSelectedTypeFieldValueNotNull = function () {
		var userEnteredFormat = this.partNumberTypeCombobox.getValue()[0];
		var isNull = this.validateEnteredValuesNotNull(userEnteredFormat);
		return isNull;
	};

	XEngineerModal.prototype.validateSelectedAttributeFieldValueNotNull = function () {
		var userEnteredFormat = this.partNumberAttributeCombobox ? this.partNumberAttributeCombobox.getValue()[0] : '';
		var isNull = false;
		if (this.partNumberTypeCombobox.getValue()[0] == ParameterizationXEngineerConstants.FORMAT_ATTRIBUTE) {
			isNull = this.validateEnteredValuesNotNull(userEnteredFormat);
		}

		return isNull;
	};

	XEngineerModal.prototype.validateEnteredCounterFieldValueNotNull = function () {
		var userEnteredFormat = this.counterNumberBox ? this.counterNumberBox.getValue() : '';
		var isNull = false;
		if (this.partNumberTypeCombobox.getValue()[0] == ParameterizationXEngineerConstants.FORMAT_COUNTER) {
			isNull = this.validateEnteredValuesNotNull(userEnteredFormat);
		}

		return isNull;
	};


	XEngineerModal.prototype.validateEnteredValuesNotNull = function (userEnteredFormat) {

		var isNull = false;
		if (userEnteredFormat == '' || userEnteredFormat == "") {
			isNull = true;
		}
		return isNull;
	};

	XEngineerModal.prototype.displayAlertMessage = function (messageToDisplay, toDisplayOver) {
		var alertOptions = {
			visible: true,
			className: 'param-alert',
			messageClassName: 'error',
			closable: true,
			renderTo: toDisplayOver,
			autoHide: true,
			hideDelay: 2000
		};
		var alert = this.getAlertComponent(alertOptions);

		alert.add({
			message: messageToDisplay
		});

	};

	XEngineerModal.prototype.getUserEnteredValues = function () {

		var userEnteredFormatValues = {};

		var valueField = this.valueTextBox ? this.valueTextBox.getValue() : this.valueDynTextBox ? this.valueDynTextBox.getValue() : this.modal.getContent().getElement('#sampleValue') ? this.modal.getContent().getElement('#sampleValue').innerText : '';
		var attributeFieldLabel = this.partNumberAttributeCombobox ? this.partNumberAttributeCombobox.getOption(this.partNumberAttributeCombobox.getValue()[0]).getText() : '';
		var attributeFieldValue = this.partNumberAttributeCombobox ? this.partNumberAttributeCombobox.getValue()[0] : '';
		var numberOfDigits = this.counterNumberBox ? this.counterNumberBox.getValue() : '';
		
		userEnteredFormatValues[ParameterizationXEngineerConstants.NAME] = this.nameTextBox.getValue();
		userEnteredFormatValues[ParameterizationXEngineerConstants.ORDER] = this.numberOrderBox.getValue();
		userEnteredFormatValues[ParameterizationXEngineerConstants.TYPE] = this.partNumberTypeCombobox.getValue()[0];
		userEnteredFormatValues[ParameterizationXEngineerConstants.ATTRIBUTE] = attributeFieldValue;
		userEnteredFormatValues[ParameterizationXEngineerConstants.ATTRIBUTE_NLS_NAME] = attributeFieldLabel;
		userEnteredFormatValues[ParameterizationXEngineerConstants.COUNTER] = numberOfDigits;
		userEnteredFormatValues[ParameterizationXEngineerConstants.VALUE] = valueField;

		return userEnteredFormatValues;
	};

	XEngineerModal.prototype.updateSampleText = function () {

		var sampleTextDiv = this.modal.getContent().getElement('#sampleValue');
		var updatedCount = this.counterNumberBox ? this.counterNumberBox.getValue() : '';
		//var noOFDigits = "1";
			var noOFDigits = "";



		for (var i = 0; i < parseInt(updatedCount); i++) {
			noOFDigits = '0' + noOFDigits;
		}

		if (sampleTextDiv != null) {
			sampleTextDiv.innerText = noOFDigits;
		}

	};

	XEngineerModal.prototype.getTotalFormatRows = function () {
		return document.querySelectorAll(".partNumberFieldMapping").length;
	};

	XEngineerModal.prototype.getHighestOrder = function () {
		var rowsOfMappedFields = document.querySelectorAll(".partNumberFieldMapping");
		var toCheckTheExistingRows = rowsOfMappedFields.length;
		var highestOrder = 0;
		if (toCheckTheExistingRows > 0) {
			for (var k = 0; k < rowsOfMappedFields.length; k++) {
				if (parseInt(rowsOfMappedFields[k].getChildren()[1].getText()) > highestOrder) {
					highestOrder = parseInt(rowsOfMappedFields[k].getChildren()[1].getText());
				}
			}
		}

		return highestOrder;

	};
	XEngineerModal.prototype.isCounterExists = function (field) {
		var rowsOfMappedFields = document.querySelectorAll(".partNumberFieldMapping");
		var toCheckTheExistingRows = rowsOfMappedFields.length;
		var isSuccess = false;
		if (toCheckTheExistingRows > 0) {
			for (var k = 0; k < rowsOfMappedFields.length; k++) {
				//IR-704024-3DEXPERIENCER2019x 
				if (rowsOfMappedFields[k].getChildren()[2].value == ParameterizationXEngineerConstants.FORMAT_COUNTER) {
					isSuccess = true;
					break;
				}
			}
		}

		return isSuccess;
	};

	XEngineerModal.prototype.destroyValueFieldComponents = function () {

		this.valueTextBox = undefined;
		this.valueDynTextBox = undefined;
		this.counterNumberBox = undefined;

	};

	XEngineerModal.prototype.getAttributes = function (data) {
		var that = this;
		that.storeAttributes(data);
	};

	XEngineerModal.prototype.storeAttributes = function (data) {

		this.attributes = data;

	};


	XEngineerModal.prototype.getTextBox = function (textBoxOptions) {

		this.textBox = new Text(textBoxOptions);
		return this.textBox;
	};
	XEngineerModal.prototype.getNumberBox = function (numberOptions) {

		this.numberBox = new Number(numberOptions);
		return this.numberBox;
	};

	XEngineerModal.prototype.getSelectComponent = function (selectOptions) {

		this.select = new Select(selectOptions);
		return this.select;
	};

	XEngineerModal.prototype.getAlertComponent = function (alertOptions) {

		this.alert = new Alert(alertOptions);
		return this.alert;
	};

	XEngineerModal.prototype.getTooltip = function (tooltipOtions) {
		this.tooltip = new Tooltip(tooltipOtions);
		return this.tooltip;
	};

	XEngineerModal.prototype.show = function () {
		this.modal.show();
	};


	XEngineerModal.prototype._bindFooterEvent = function () {
		var that = this;

		this.modal.getFooter().getElements('.btn').forEach(function (element) {
			if (element.name === 'cancelButton') {
				element.addEvent('click', function () {
					that.modal.hide();
				});
			}
		});

	};

	XEngineerModal.prototype.getContent = function () {
		return this.modal.getContent();
	};

	XEngineerModal.prototype.destroy = function () {
		this.modal.destroy();
		var keys = Object.keys(this);
		for (var i = 0; i < keys.length; i++) {
			this[keys[i]] = undefined;
		}
	};

	return XEngineerModal;
});

//@fullReview  ZUR 16/04/05 2017x, enhancing code organization for Jasmine/KarmaReplay Tests
/*global define, document, clearTimeout, setTimeout*/
/*jslint plusplus: true*/

define('DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/LifecycleEgraphUtilities',
    [
        'UWA/Core',
        'egraph/core',
        'egraph/views',
        'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/ParamStepGeometry',
        'DS/UIKIT/Input/Button',
        'DS/UIKIT/Input/Text',
        'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/LifecycleViewUtilities',
		'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS'
    ],
    function(UWA, core, views,
            StepGx,
            Button, Text,
            LifecycleViewUtilities, ParamSkeletonNLS) {

        'use strict';
        //'UWA/Controls/Abstract',
        var lcview = {

            addeGraphDivs: function() {
                var content, canvas, placeholder,
                    divArrays = new Array(2);
                //
                content = UWA.createElement("div", {
                    'id': 'main_Content_Div'
                });
                canvas = UWA.createElement("div", {
                    'id': 'graph_canvas'
                });
                canvas.addClassName("canvas");
                canvas.setStyle("height", "100%");
                canvas.setStyle("width", "100%");
                //
                placeholder = UWA.createElement("div");
                placeholder.addClassName("graphPlaceholder");
                //
                content.addContent(placeholder);
                content.addContent(canvas);
                divArrays[0] = content;
                divArrays[1] = canvas;

                return divArrays;
            },
             /**
             * Procedure addEdgeArrowDesign
             * This method creates the design of the arrow and injects it (hidden) into the body
             * @author TEE1
             */
            addEdgeArrowDesign : function (widget) {
                //The elements are all created with an NLS so they can't
                //be created with a UWA function but they need to inherit
                var svg = UWA.extendElement(document.createElementNS('http://www.w3.org/2000/svg', 'svg')),
                    defs = UWA.extendElement(document.createElementNS('http://www.w3.org/2000/svg', 'defs')),
                    marker = UWA.extendElement(document.createElementNS('http://www.w3.org/2000/svg', 'marker')),
                    path = UWA.extendElement(document.createElementNS('http://www.w3.org/2000/svg', 'path'));
                svg.set({
                    "width" : 0,
                    "height" : 0
                });
                svg.set("style", "position", "absolute");
                marker.set({
                    "id": "arrow-edge-end-marker",
                    "markerWidth": "10",
                    "markerHeight": "8",
                    "refX": "8",
                    "refY" : "4",
                    "orient": "auto"
                });
                path.set({
                    "d": "M 0 0 L 10 4 L 0 8",
                    "fill": "#777",
                    "stroke": "none"
                });
                path.inject(marker);
                marker.inject(defs);
                defs.inject(svg);
                svg.inject(widget.body);
            },
            /**
             * Connector factory
             * @param {number} side the attachement side
             * @param {number} row the row index of the connector
             * @return {module:egraph/core.Connector} new connector instance
             */
            createConnector: function (side, row) {
                var connector, offset;

                offset = row;//20 + 30 * row;
                connector = new core.Connector();
                // instantiate default connector view
                connector.views.main = new views.SVGConnView();
                // use multiset to force the dispatch of properties change
                // notifications to group all modifications of connectors
                // properties (again, not really useful in that specific case)
                connector.multiset(['cstr', 'attach'], side,
                                   ['cstr', 'offset'], offset);

                //console.log(connector);
                return connector;
            },

            /**
            * Add an edge between two connectors.
            * @param {module:egraph/core.Connector} c1
            * @param {module:egraph/core.Connector} c2
            * @returns {module:egraph/core.Edge} the new edge
            */
            builTransitiondEdge : function (stub) {
                var edge = new core.Edge(),
                    currstepGeometry = new StepGx.ParamStepGeometry(stub);
                //increment minTangentLength in order to avoir overlapping
                //autoBezierGeometry.minTangentLength = autoBezierGeometry.minTangentLength+20;             
                //stepGeometry.stubScenario = stub;    
                UWA.log("Setting stepGeometry.stubScenario = " + currstepGeometry.stubScenario);
                edge.set('geometry', currstepGeometry); //edge.set('geometry', autoBezierGeometry);            
                edge.views.main = new views.SVGEdgeView('arrow-edge'); //edge.views.main = new views.SVGEdgeView();
                return edge;
            },

            buildpropsNode: function (elt, fctChange) {

                var selectedObjpropsDiv, insertDiv, timerconn, closeButton,
                    iXCoordinate, iYCoordinate, pathArray, nbofPoints,
                    newRow, newCell, newCell2, titleTable, currentCheck,
                    elementName, iV,
                    worldCoord = [];
                    //headerTable, tbody, testX, removeStateButton

                lcview.removePropsNode();

                if (elt) {
                    if (elt.type === core.Type.EDGE) {
                        //elementType = "Transition";
                        elementName = elt.signatureNLS;
                    }
                }

                pathArray = elt.path;
                nbofPoints = pathArray.length / 3;
                iYCoordinate = pathArray[5] - LifecycleViewUtilities.sign(pathArray[5]) * 40;//50
                iXCoordinate = (pathArray[1] + pathArray[(nbofPoints - 1) * 3 + 1]) / 2;

                if (nbofPoints === 2) {
                    iYCoordinate = pathArray[5] - LifecycleViewUtilities.sign(pathArray[5]) * 15;//20
                }

                worldCoord.push(iXCoordinate);
                worldCoord.push(iYCoordinate);
                iV = LifecycleViewUtilities.transformCoordinates(worldCoord, elt.gr.views.main.vpt);

                //testX = (elt.cl1.c.aleft + elt.cl2.c.aleft) / 2;

                selectedObjpropsDiv =  UWA.createElement('div', {'id': 'propsTransitionDiv'});
                selectedObjpropsDiv.setStyle("visibility", "visible");//hidden
                selectedObjpropsDiv.setStyle("left", iV[0]);// iXCoordinate "40em" elt.cl1.c.aleft
                selectedObjpropsDiv.setStyle("top", iV[1]);//iYCoordinate 2em     elt.cl1.c.atop

                titleTable =  UWA.createElement('table', {
                    'width': '100%'
                }).inject(selectedObjpropsDiv);

                newRow = UWA.createElement('tr', {title: ''}).inject(titleTable);
                newCell2 = UWA.createElement('td',
                        {'width': '90%', 'title': ''}).inject(newRow);

                /*UWA.createElement('h4', {
                    text: 'properties',// font-3dsbold ParamWdgNLS
                    'class': 'font-3dslight'
                }).inject(newCell);*/

                newCell = UWA.createElement('td',
                        {'width': '10%', 'title': ''}).inject(newRow);

                //fonticon-2x

                closeButton = new Button({
                    className: 'close',
                    id : 'togglepropsBox',//  html: '&times;',
                    icon : ' cancel',//value: 'Button',

                    attributes: {
                        disabled: false,
                        'aria-hidden' : 'true',
                        title : ParamSkeletonNLS.Close //NZV:IR-629593-3DEXPERIENCER2019x
                    //  text : ParamWdgNLS.Apply
                    }
                }).inject(newCell);

                /*headerTable =  UWA.createElement('table', {
                    'id': 'propBoxheader',
                    'class': 'table table-condensed table-hover',
                    'width': '100%'
                }).inject(selectedObjpropsDiv);

                tbody = UWA.createElement('tbody').inject(headerTable);
                newRow = UWA.createElement('tr', {title: ''}).inject(tbody);
                newCell = UWA.createElement('td', {'width': '40%', 'title': ''}).inject(newRow);
                UWA.createElement('strong', {text: 'Name'}).inject(newCell);

                newCell = UWA.createElement('td',
                        {'width': '60%', 'title': ''}).inject(newRow);*/

                currentCheck = new Text({
                    placeholder: "...",
                    attributes: {
                        value: elementName,
                        multiline: true,
                        disabled: false
                    },
                    events: {
                        onChange: function () {//IR-695253-3DEXPERIENCER2019x FD06: remove currentCheck.getValue()
                            fctChange(elt, currentCheck, true);
                            UWA.log("onchange");
                        },
                        onKeyDown: function () {

                            if (timerconn) { clearTimeout(timerconn); }
                            timerconn = setTimeout(function() {
                                fctChange(elt, currentCheck, false);
                            }, 20);
                        }
                    }
                }).inject(newCell2);

                closeButton.addEvent("onClick", function () {
                    lcview.removePropsNode();
                    fctChange(elt, currentCheck, true);
                });

                /*onKeyDown: function () {
                    console.log("onKeyDown");
                //UIUtilities.beingModified(imgCell, ParamWdgNLS.Being_Modified);
                 }*/

                insertDiv = document.getElementsByClassName("egraph_views_domroot")[0];
                insertDiv.appendChild(selectedObjpropsDiv);
            },

            removePropsNode : function () {
                var child = document.getElementById("propsTransitionDiv");
                if (child) {
                    if (child.parentNode) {
                        child.parentNode.removeChild(child);
                    }
                }
            }


        };

        return lcview;

    });

define('DS/ParameterizationSkeleton/Views/ParameterizationXEngineering/PartNumberingViewUtilities',
    [
        'UWA/Core',
        'DS/UIKIT/Input/Select',
        'DS/UIKIT/Modal',
        'DS/UIKIT/Input/Text',
        'DS/UIKIT/Input/Number',
        'DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
        'DS/WAFData/WAFData',
        'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler',
        'DS/ParameterizationSkeleton/Views/ParameterizationXEngineering/ParameterizationXEngineerConstants',
        'DS/ParameterizationSkeleton/Views/ParameterizationXEngineering/XENGModal',
        'i18n!DS/ParameterizationSkeleton/assets/nls/XEngineeringNLS',
    ],
    function(UWA,
        Select,
        Modal,
        Text,
        Number,
        ParametersLayoutViewUtilities,
        WAFData,
        URLHandler,
        ParameterizationXEngineerConstants,
        XENGModal,
        XEngineeringNLS) {

        'use strict';

        var LEFT_ALIGNMENT = 'left';
        var RIGHT_ALIGNMENT = 'right';
        var HTML_BOLD_FORMAT = 'h5';
        var HTML_PARAG_FORMAT = null;
        var partNumberTable = UWA.createElement('table', {
            'class': 'partNumberTableMapping table table-condensed'
        });
        var widthTable = ParameterizationXEngineerConstants.WIDTH_ARRAY;

        var physicalProductAttributesValues = {};

        var strategySelectorCombobox = [{
                label: XEngineeringNLS.UserDefined,
                value: "UserDefined"
            }/*,{
                        label: XEngineeringNLS.External,
                        value: "External"
             }*/];

        var strategyCombobox;

        var partNumberView = {

            initVariable: function() {
                this.cellsIndex = {
                    "name": 0,
                    "order": 1,
                    "type": 2,
                    "value": 3,
                    "action": 4,
                    "deployFlag": 5,
                };
            },

            physicalProductAttributes: function(attributeMapping) {
                physicalProductAttributesValues = attributeMapping;
            },

            buildImgSpan: function(iconChoice, iconSize, iconColor, title) {
                var imgClass = 'fonticon fonticon-' + iconSize + 'x fonticon-' + iconChoice,
                    imgSpan = UWA.createElement('span', {
                        'class': imgClass,
                        'title': title
                    });

                imgSpan.setStyle("color", iconColor);
                return imgSpan;
            },

            buildTextTableCell: function(alignment, cellWidth, row, cellFormat, cellTest, colspan) {
                var colspanValue = (colspan) ? colspan : '1';
                var iCell = UWA.createElement('td', {
                    'Align': alignment,
                    'width': cellWidth,
                    'colspan': colspanValue,
                    'class': 'partNumberingField'// font-3dsbold
                }).inject(row);

                if (cellFormat) {
                    UWA.createElement(cellFormat, {
                        text: cellTest
                    }).inject(iCell);
                } else {
                    iCell.appendText(cellTest);
                }
                return iCell;
            },

            buildAttributeTable: function(data) {

                var pNFieldbody = UWA.createElement('tbody', {
                    'class': 'partNumberFieldbody'
                }).inject(partNumberTable);


                var fieldInfo;
                /*fieldInfo = partNumberView.buildPNStrategyRow(data);
                fieldInfo.inject(pNFieldbody);*/

                fieldInfo = partNumberView.buildPNFormulaRow(data);
                fieldInfo.inject(pNFieldbody);

                fieldInfo = partNumberView.buildPNTableHeading();
                fieldInfo.inject(pNFieldbody);

                return partNumberTable;
            },

            /*buildStrategyCombombox: function(iCell, value) {
                var that = this;
                strategyCombobox = new Select({
                    nativeSelect: true,
                    placeholder: false,
                    multiple: false,
                    options: strategySelectorCombobox,
                });

                strategyCombobox.inject(iCell);

                strategyCombobox.setValue(value);
                strategyCombobox.addEvent("onChange", function(e) {
                    partNumberView.updateStrategy(strategyCombobox.getValue()[0], ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED);
                });
            },*/

            /*buildPNStrategyRow: function(data) {
                var fieldInfo = UWA.createElement('tr', {
                    'class': 'partNumberStrategyMapping'
                });

                fieldInfo.value = (data[ParameterizationXEngineerConstants.STRATEGY_CELL] !== "") ? data[ParameterizationXEngineerConstants.STRATEGY_CELL] : "UserDefined";

                var iCell;

                partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.name], fieldInfo, HTML_PARAG_FORMAT, XEngineeringNLS.Strategy);


                iCell = UWA.createElement('td', {
                    'width': widthTable[this.cellsIndex.order],
                    'align': LEFT_ALIGNMENT,
                    'class': 'partNumberingField font-3dslight'// font-3dsbold
                });

                var imgSpan = partNumberView.buildImgSpan('info', "2.5", "black", XEngineeringNLS.StrategyRelatedInfo);
                imgSpan.inject(iCell);

                iCell.inject(fieldInfo);


                partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.type], fieldInfo, HTML_PARAG_FORMAT, "");

                iCell = UWA.createElement('td', {
                    'width': widthTable[this.cellsIndex.type].toString(),
                    'align': LEFT_ALIGNMENT,
                    'colpan': '2',
                    'class': 'partNumberingField font-3dslight'// font-3dsbold
                });

                partNumberView.buildStrategyCombombox(iCell, data.Strategy, widthTable[this.cellsIndex.value])
                iCell.inject(fieldInfo);


                partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.action], fieldInfo, HTML_PARAG_FORMAT, "");

                iCell = UWA.createElement('td', {
                    'width': widthTable[this.cellsIndex.deployFlag],
                    'align': RIGHT_ALIGNMENT,
                    'title': XEngineeringNLS.deployStatus,
                    'class': 'partNumberingField font-3dslight'// font-3dsbold
                });

                var imgSpan = partNumberView.buildImgSpan('check', '2.5', 'green', XEngineeringNLS.Deployed);
                imgSpan.inject(iCell);
                iCell.value = "success";
                iCell.inject(fieldInfo);

                return fieldInfo;
            },*/

            buildPNFormulaRow: function(data) {
                var fieldInfo, iCell;

                fieldInfo = UWA.createElement('tr', {
                    'class': 'partNumberFormulaMapping',
                    'id': 'partNumberFormulaMapping'
                });

                fieldInfo.value = [];


                partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.name], fieldInfo, HTML_PARAG_FORMAT, XEngineeringNLS.Formula);

                var imgClass = 'fonticon fonticon-' + '2.5' + 'x  fonticon-info';

                if (data[ParameterizationXEngineerConstants.BUSINESS_LOGIC]) {

                    iCell = UWA.createElement('td', {
                        'Align': LEFT_ALIGNMENT,
                        'width': widthTable[this.cellsIndex.order],
                        'class': 'partNumberingField font-3dslight'// font-3dsbold
                    }).inject(fieldInfo);

                    UWA.createElement(HTML_PARAG_FORMAT, {
                        'class': imgClass,
                        'title': XEngineeringNLS.FormulaTooltip
                    }).inject(iCell);

                } else {
                    partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.name], fieldInfo, HTML_PARAG_FORMAT, "");
                }

                iCell = partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.type], fieldInfo, HTML_BOLD_FORMAT, "[" + XEngineeringNLS.freeValue + "]", "3");
                iCell.value = ParameterizationXEngineerConstants.FORMULA_CELL;

                iCell = UWA.createElement('td', {
                    'width': widthTable[this.cellsIndex.deployFlag],
                    'align': RIGHT_ALIGNMENT,
                    'title': XEngineeringNLS.deployStatus,
                    'class': 'partNumberingField font-3dslight'// font-3dsbold
                });

                var imgSpan = partNumberView.buildImgSpan('check', '2.5', 'green', XEngineeringNLS.Deployed);
                imgSpan.inject(iCell);
                iCell.value = "success";
                iCell.inject(fieldInfo);

                return fieldInfo;
            },

            buildPNTableHeading: function() {
                var fieldInfo;

                fieldInfo = UWA.createElement('tr', {
                    'class': 'success'
                });

                partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.name], fieldInfo, HTML_BOLD_FORMAT, XEngineeringNLS.name);
                partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.order], fieldInfo, HTML_BOLD_FORMAT, XEngineeringNLS.order);
                partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.type], fieldInfo, HTML_BOLD_FORMAT, XEngineeringNLS.type);
                partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.value], fieldInfo, HTML_BOLD_FORMAT, XEngineeringNLS.value);
                partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.action], fieldInfo, HTML_BOLD_FORMAT, XEngineeringNLS.actions);
                partNumberView.buildTextTableCell(RIGHT_ALIGNMENT, widthTable[this.cellsIndex.deployFlag], fieldInfo, HTML_BOLD_FORMAT, XEngineeringNLS.deployStatus);

                return fieldInfo;
            },


            addEditButtonToCellRow: function(iCell, fieldInfo) {
                var editElts = ParametersLayoutViewUtilities.createActionElements(XEngineeringNLS.editField, false);
                var editSpan = editElts[0];
                editSpan.setStyle("float", LEFT_ALIGNMENT);
                editSpan.setStyle("padding", "0px 8px");
                editSpan.inject(iCell);
                var editAttributeButton = editElts[1];
                var editPop = editElts[2];

                editAttributeButton.addEvent("onClick", function(event) {
                    var fieldToEdit = event.currentTarget.getParent().getParent().getParent();
                    partNumberView.editFieldDialog(fieldToEdit, physicalProductAttributesValues);

                });

                return editAttributeButton;
            },

            addRemoveButtonToCellRow: function(iCell, fieldInfo) {
                var removelts = ParametersLayoutViewUtilities.createActionElements(XEngineeringNLS.removeField, true);
                var deleteSpan = removelts[0];
                deleteSpan.setStyle("float", LEFT_ALIGNMENT);
                deleteSpan.setStyle("padding", "0px 8px");
                deleteSpan.inject(iCell);
                var removeAttributeButton = removelts[1];
                var removePop = removelts[2];

                removeAttributeButton.addEvent("onClick", function(e) {
                    partNumberView.removefieldLineCallBack(fieldInfo);
                });

                return removeAttributeButton;
            },


            buildValueCellInPNTable: function(valueCell, name, order, type, value, attributeName, isDeployed) {

                var cellText = value;
                if (ParameterizationXEngineerConstants.FORMAT_ATTRIBUTE == type) {
                    if (physicalProductAttributesValues && physicalProductAttributesValues[attributeName]) {
                        cellText = physicalProductAttributesValues[attributeName];
                    } else {
                        cellText = attributeName;
                    }

                }

                valueCell.setText((cellText)?cellText:"");
                valueCell.value = value;

                partNumberView.updateFormulaTextFields(order, type, cellText, isDeployed);
            },

            buildPartNumberField: function(fieldInfo, name, order, type, value, attributeName, isDeployed) {
                var that = this;
                var iCell;

                fieldInfo.value = isDeployed;



                partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.name], fieldInfo, HTML_PARAG_FORMAT, name);
                partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.order], fieldInfo, HTML_PARAG_FORMAT, order);
                partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.type], fieldInfo, HTML_PARAG_FORMAT, XEngineeringNLS[type]).value = type;
                partNumberView.buildValueCellInPNTable(partNumberView.buildTextTableCell(LEFT_ALIGNMENT, widthTable[this.cellsIndex.value], fieldInfo, HTML_PARAG_FORMAT, value), name, order, type, value, attributeName, isDeployed);

                iCell = UWA.createElement('td', {
                    'Align': LEFT_ALIGNMENT,
                    'width': widthTable[4],
                    'class': 'partNumberingField font-3dslight'// font-3dsbold
                }).inject(fieldInfo);

                var editAttributeButton = partNumberView.addEditButtonToCellRow(iCell, fieldInfo);
                var removeAttributeButton = partNumberView.addRemoveButtonToCellRow(iCell, fieldInfo);


                iCell = UWA.createElement('td', {
                    'Align': RIGHT_ALIGNMENT,
                    'width': widthTable[5],
                    'class': 'partNumberingField font-3dslight'// font-3dsbold
                }).inject(fieldInfo);

                if (isDeployed == ParameterizationXEngineerConstants.DEPOLOYED) {
                    var imgSpan = partNumberView.buildImgSpan('check', '2.5', 'green', XEngineeringNLS.Deployed);
                    imgSpan.inject(iCell);
                } else if (isDeployed === ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED) {
                    var imgSpan = partNumberView.buildImgSpan('cog', '2.5', 'orange', XEngineeringNLS.Modified);
                    imgSpan.inject(iCell);
                }


                iCell.inject(fieldInfo);

                return fieldInfo;
            },


            buildsFieldJsonObject: function(fieldInfo) {
                var type = fieldInfo.cells[this.cellsIndex.type].getText();
                var value = fieldInfo.cells[this.cellsIndex.value].getText();
                if (ParameterizationXEngineerConstants.FORMAT_ATTRIBUTE == type) {
                    value = fieldInfo.cells[this.cellsIndex.value].value;
                }
                var obj = {};

                obj[ParameterizationXEngineerConstants.OPERATION] = fieldInfo.cells[this.cellsIndex.deployFlag].value;
                obj[ParameterizationXEngineerConstants.NAME] = fieldInfo.cells[this.cellsIndex.name].getText();
                obj[ParameterizationXEngineerConstants.TYPE] = fieldInfo.cells[this.cellsIndex.type].value;
                obj[ParameterizationXEngineerConstants.VALUE] = value;
                obj[ParameterizationXEngineerConstants.ORDER] = fieldInfo.cells[this.cellsIndex.order].getText();
                obj[ParameterizationXEngineerConstants.ATTRIBUTE] = fieldInfo.cells[this.cellsIndex.value][ParameterizationXEngineerConstants.ATTRIBUTE];
                obj[ParameterizationXEngineerConstants.COUNTER] = fieldInfo.cells[this.cellsIndex.value][ParameterizationXEngineerConstants.COUNTER];

                return obj;

            },

            buildJsonObjForPNField: function(operation, name, order, type, value, attributeName, counterSize) {
                var obj = {};

                obj[ParameterizationXEngineerConstants.OPERATION] = operation;
                obj[ParameterizationXEngineerConstants.NAME] = name;
                obj[ParameterizationXEngineerConstants.TYPE] = type;
                obj[ParameterizationXEngineerConstants.VALUE] = value;
                obj[ParameterizationXEngineerConstants.ORDER] = order;
                obj[ParameterizationXEngineerConstants.ATTRIBUTE] = attributeName;
                obj[ParameterizationXEngineerConstants.COUNTER] = counterSize;

                return obj;


            },

            buildNewPartNumberField: function(objParam, isDeployedStatus) {
                var fieldInfo;

                fieldInfo = UWA.createElement('tr', {
                    'class': 'partNumberFieldMapping'
                });

                partNumberView.buildPartNumberField(fieldInfo, objParam.Name, objParam.Order, objParam.Type, objParam.Value, objParam[ParameterizationXEngineerConstants.ATTRIBUTE], isDeployedStatus);
                fieldInfo.cells[this.cellsIndex.value][ParameterizationXEngineerConstants.ATTRIBUTE] = objParam[ParameterizationXEngineerConstants.ATTRIBUTE];
                fieldInfo.cells[this.cellsIndex.value][ParameterizationXEngineerConstants.COUNTER] = objParam[ParameterizationXEngineerConstants.COUNTER];
                fieldInfo.cells[this.cellsIndex.deployFlag].value = ParameterizationXEngineerConstants.ADD;

                return fieldInfo;
            },

            modifyPartNumberField: function(fieldInfo, objParam, isDeployedStatus) {
                fieldInfo.value = isDeployedStatus;

                var existOrder = fieldInfo.cells[this.cellsIndex.order].getText();
                if (objParam.Order != existOrder) {
                    partNumberView.updateFormulaTextFields(existOrder, objParam.Type, null, ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED);
                }

                fieldInfo.cells[this.cellsIndex.name].setText(objParam.Name);
                fieldInfo.cells[this.cellsIndex.order].setText(objParam.Order);
                fieldInfo.cells[this.cellsIndex.type].setText(XEngineeringNLS[objParam.Type]);
                fieldInfo.cells[this.cellsIndex.type].value = objParam.Type;

                partNumberView.buildValueCellInPNTable(fieldInfo.cells[this.cellsIndex.value], objParam.Name, objParam.Order, objParam.Type, (objParam.Value) ? objParam.Value : "", objParam[ParameterizationXEngineerConstants.ATTRIBUTE], isDeployedStatus);

                fieldInfo.cells[this.cellsIndex.value][ParameterizationXEngineerConstants.ATTRIBUTE] = objParam[ParameterizationXEngineerConstants.ATTRIBUTE];
                fieldInfo.cells[this.cellsIndex.value][ParameterizationXEngineerConstants.COUNTER] = objParam[ParameterizationXEngineerConstants.COUNTER];

                var deploycell = fieldInfo.cells[this.cellsIndex.deployFlag];
                deploycell.empty();

                var imgSpan = partNumberView.buildImgSpan('cog', '2.5', 'orange', XEngineeringNLS.Modified);
                imgSpan.inject(deploycell);

                deploycell.value = ParameterizationXEngineerConstants.MODIFY;

                return fieldInfo;
            },

            updateFormulaTextFields: function(index, type, value, isDeployed) {
                var field = document.querySelector(".partNumberFormulaMapping");
                if(field){
	                var newVal = "";
	                if (type) {
	                    if (type == ParameterizationXEngineerConstants.FORMAT_ATTRIBUTE && value) {
	                        newVal = "{" + value + "}";
	                    } else if (type == ParameterizationXEngineerConstants.FORMAT_COUNTER && value) {
	                        newVal = "&lt;" + XEngineeringNLS.counterValue + "&gt;";
	                    } else if (type == ParameterizationXEngineerConstants.FORMAT_FREE && (value != null)) {
	                        newVal = "[" + XEngineeringNLS.freeValue + "]";
	                    } else if (value) {
	                        newVal = value;
	                    }
	                }
	
	
	
	                field.value[index] = newVal;
	                field.cells[this.cellsIndex.type].empty();
	                field.cells[this.cellsIndex.type].setStyle("font-size", "21px");
	
	                var newFormula = field.value.join("");
	                var counterInfoCell = field.cells[this.cellsIndex.type];
	                if(newFormula != ""){
		                if (newFormula.indexOf(XEngineeringNLS.counterValue) == -1) {
		                    counterInfoCell.empty();
		                    var imgClass = 'fonticon fonticon-' + '1' + 'x  fonticon-attention';
		                    UWA.createElement(HTML_PARAG_FORMAT, {
		                        'class': imgClass,
		                        'title': XEngineeringNLS.counterTooltipAttention
		                    }).inject(counterInfoCell);
		                } else {
		                    counterInfoCell.empty();
		                }
	                }
	                if(!newFormula){
	                	field.cells[this.cellsIndex.type].addContent("[" + XEngineeringNLS.freeValue + "]");
	                }
	                field.cells[this.cellsIndex.type].addContent(field.value.join(""));
	
	
	
	                var iCell = field.cells[this.cellsIndex.value];
	                if (isDeployed == ParameterizationXEngineerConstants.DEPOLOYED) {
	                    iCell.empty();
	                    var imgSpan = partNumberView.buildImgSpan('check', '2.5', 'green', XEngineeringNLS.Deployed);
	                    imgSpan.inject(iCell);
	                } else if (isDeployed === ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED) {
	                    iCell.empty();
	                    var imgSpan = partNumberView.buildImgSpan('cog', '2.5', 'orange', XEngineeringNLS.Modified);;
	                    imgSpan.inject(iCell);
	                }
                }
            },

            removefieldLineCallBack: function(fieldInfo) {

                if (fieldInfo != "undefined") {
                    partNumberView.updateFormulaTextFields(fieldInfo.cells[this.cellsIndex.order].getText(), fieldInfo.cells[this.cellsIndex.type].value, null, ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED);
                    if (fieldInfo.value === ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED) {
                        fieldInfo.remove();
                    } else {
                        partNumberView.setForRemoveFieldLine(fieldInfo);
                    }
                }
            },

            resetForAdd: function(fieldInfo) {
                partNumberView.updateFormulaTextFields(fieldInfo.cells[this.cellsIndex.order].getText(), fieldInfo.cells[this.cellsIndex.type].value, null, ParameterizationXEngineerConstants.DEPOLOYED);
            },

            resetForRemove: function(fieldInfo) {

                var cellValue = fieldInfo.cells[partNumberView.cellsIndex.deployFlag].value;
                var imgSpan = partNumberView.buildImgSpan('check', '2.5', 'green', XEngineeringNLS.Deployed);
                var actionCell = fieldInfo.cells[partNumberView.cellsIndex.action];
                var deploycell = fieldInfo.cells[partNumberView.cellsIndex.deployFlag];


                partNumberView.addEditButtonToCellRow(actionCell, fieldInfo);
                partNumberView.addRemoveButtonToCellRow(actionCell, fieldInfo);
                deploycell.empty();
                imgSpan.inject(deploycell);

                partNumberView.updateFormulaTextFields(fieldInfo.cells[this.cellsIndex.order].getText(), fieldInfo.cells[this.cellsIndex.type].value, fieldInfo.cells[this.cellsIndex.value].getText(), ParameterizationXEngineerConstants.DEPOLOYED);
            },

            resetForModify: function(fieldInfo, savedInfo) {

                var imgSpan = partNumberView.buildImgSpan('check', '2.5', 'green', XEngineeringNLS.Deployed);
                var actionCell = fieldInfo.cells[partNumberView.cellsIndex.action];
                var deploycell = fieldInfo.cells[partNumberView.cellsIndex.deployFlag];

                if (savedInfo) {
                    var existOrder = fieldInfo.cells[this.cellsIndex.order].getText();
                    if (savedInfo[ParameterizationXEngineerConstants.ORDER] != existOrder) {
                        partNumberView.updateFormulaTextFields(existOrder, savedInfo[ParameterizationXEngineerConstants.TYPE], null, ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED);
                    }

                    fieldInfo.cells[this.cellsIndex.name].setText(savedInfo[ParameterizationXEngineerConstants.NAME]);
                    fieldInfo.cells[this.cellsIndex.type].setText(XEngineeringNLS[savedInfo[ParameterizationXEngineerConstants.TYPE]]);
                    fieldInfo.cells[this.cellsIndex.type].value = savedInfo[ParameterizationXEngineerConstants.TYPE];
                    fieldInfo.cells[this.cellsIndex.order].setText(savedInfo[ParameterizationXEngineerConstants.ORDER]);


                    partNumberView.buildValueCellInPNTable(fieldInfo.cells[this.cellsIndex.value], savedInfo[ParameterizationXEngineerConstants.NAME], savedInfo[ParameterizationXEngineerConstants.ORDER], savedInfo[ParameterizationXEngineerConstants.TYPE], savedInfo[ParameterizationXEngineerConstants.VALUE], savedInfo[ParameterizationXEngineerConstants.ATTRIBUTE], ParameterizationXEngineerConstants.DEPOLOYED);
                }
                deploycell.empty();
                imgSpan.inject(deploycell);
            },

            resetForFieldLineChanges: function(fieldInfo, savedInfo) {

                if (fieldInfo.value == ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED) {
                    var cellValue = fieldInfo.cells[partNumberView.cellsIndex.deployFlag].value;
                    if (cellValue == ParameterizationXEngineerConstants.ADD) {
                        partNumberView.resetForAdd(fieldInfo);
                        return fieldInfo;
                    } else if (cellValue == ParameterizationXEngineerConstants.REMOVE) {
                        partNumberView.resetForRemove(fieldInfo);

                    } else if (cellValue == ParameterizationXEngineerConstants.MODIFY) {
                        partNumberView.resetForModify(fieldInfo, savedInfo);
                    }

                    fieldInfo.value = ParameterizationXEngineerConstants.DEPOLOYED;
                    fieldInfo.cells[partNumberView.cellsIndex.deployFlag].value = null;
                }

            },

            setForRemoveFieldLine: function(fieldInfo) {
                fieldInfo.value = ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED;
                var arrayAction = fieldInfo.cells[partNumberView.cellsIndex.action].getElements('span');
                arrayAction.forEach(function(action) {
                    action.hide();
                });

                var deploycell = fieldInfo.cells[partNumberView.cellsIndex.deployFlag];
                var imgSpan = partNumberView.buildImgSpan('trash', '1.5', 'red', XEngineeringNLS.removedField);

                deploycell.empty();

                deploycell.value = ParameterizationXEngineerConstants.REMOVE;

                imgSpan.inject(deploycell);
            },

            /*updateStrategy: function(selectedValue, isDeployed) {
                var strategyField = document.querySelector(".partNumberStrategyMapping");
                strategyField.value = selectedValue;

                strategyCombobox.setValue(selectedValue)

                var deployCell = strategyField.cells[this.cellsIndex.deployFlag];
                deployCell.empty();

                if (isDeployed == ParameterizationXEngineerConstants.DEPOLOYED) {
                    var imgSpan = partNumberView.buildImgSpan('check', '2.5', 'green', XEngineeringNLS.Deployed);
                    imgSpan.inject(deployCell);
                } else if (isDeployed === ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED) {
                    var imgSpan = partNumberView.buildImgSpan('cog', '2.5', 'orange', XEngineeringNLS.Modified);
                    imgSpan.inject(deployCell);
                }

            },*/


            editFieldDialog: function(editField, result) {

                var options = {
                    className: "part-number-edit-modal",
                    title: XEngineeringNLS.editField
                };

                var that = this;
                this.modal = new XENGModal(options);
                this.modal.attributes = result;

                function _getFooter() {
                    return "<button type='button'  name='addButton' id='add-button' class='btn btn-primary'>" + XEngineeringNLS.add + "</button> " + "</button>" + "<button type='button' name='cancelButton' id='cancel-button' class='btn btn-default'>" + XEngineeringNLS.cancel + "</button>"
                }
                this.modal.modal.setFooter(_getFooter());
                this.modal.getModalBody();
                this.modal._bindFooterEvent();

                var editingField = editField;


                var rowsOfMappedFields = document.querySelectorAll(".partNumberFieldMapping");
                var successFields = document.querySelector('.success');
                var toCheckTheExistingRows = rowsOfMappedFields.length;

                var fetchedData = this.buildsFieldJsonObject(editField);


                this.modal.nameTextBox.setValue(fetchedData.Name);
                this.modal.numberOrderBox.setValue(fetchedData.Order);
                this.modal.partNumberTypeCombobox.select(fetchedData.Type, true);
                this.modal.nameTextBox.disable();  


                if (fetchedData.Type == ParameterizationXEngineerConstants.FORMAT_STRING) {
                    this.modal.valueTextBox.setValue(fetchedData.Value);
                } else if (fetchedData.Type == ParameterizationXEngineerConstants.FORMAT_ATTRIBUTE) {
                    this.modal.partNumberAttributeCombobox.select(editingField.cells[this.cellsIndex.value][ParameterizationXEngineerConstants.ATTRIBUTE], true);
                    this.modal.valueDynTextBox.setValue(fetchedData.Value);
                } else if (fetchedData.Type == ParameterizationXEngineerConstants.FORMAT_COUNTER) {
                    var numberOfDigits = fetchedData.Value.length;
                    this.modal.counterNumberBox.setValue(numberOfDigits);
                }

                this.tableWdthArray = ParameterizationXEngineerConstants.WIDTH_ARRAY

                this.modal.partNumberTypeCombobox.disable();

                this.modal.getContent().getElements('.btn').forEach(function(element) {

                    if (element.name === 'addButton') {

                        element.addEvent('click', function() {
                            var userEditedFormat = that.modal.getUserEnteredValues();
                            var duplicateData = {};
                            var checkStatus = {};
                            checkStatus.isSuccess = true;

                            var toDisplayOver = that.modal.getContent().getElement('.enox-part-number-content'); 

                            if (that.modal.validateEnteredNameValueNotNull()) {
                                that.modal.displayAlertMessage(XEngineeringNLS.nameNullMessage, toDisplayOver);
                            } else if (that.modal.validateEnteredOrderValueNotNull()) {
                                that.modal.displayAlertMessage(XEngineeringNLS.orderNullMessage, toDisplayOver);
                            } else if (that.modal.validatSelectedTypeFieldValueNotNull()) {
                                that.modal.displayAlertMessage(XEngineeringNLS.selectTypeMessage, toDisplayOver);
                            } else if (that.modal.validateSelectedAttributeFieldValueNotNull()) {
                                that.modal.displayAlertMessage(XEngineeringNLS.selectAttributeMessage, toDisplayOver);
                            }else if (that.modal.validateEnteredCounterFieldValueNotNull()) {
                              that.modal.displayAlertMessage(XEngineeringNLS.counterIsEmptyMessage, toDisplayOver);
                            } else if (that.modal.validateEnteredValueFieldValueNotNull()) {
                                that.modal.displayAlertMessage(XEngineeringNLS.valueEmptyMessage, toDisplayOver);
                            } else {
                            	if (!that.modal.validateEnteredNameValue("edit", editingField).isValid) {
    								that.modal.displayAlertMessage(XEngineeringNLS.nameMessage + ' ' + XEngineeringNLS.alreadyExists, toDisplayOver);
    							} else if (!that.modal.validateEnteredOrderValue("edit", editingField).isValid) {
    								that.modal.displayAlertMessage(XEngineeringNLS.orderMessage + ' ' + XEngineeringNLS.alreadyExists, toDisplayOver);
    							}  else {
                                    var userSelectedFormat = that.modal.getUserEnteredValues();
                                    userEditedFormat[ParameterizationXEngineerConstants.OPERATION] = ParameterizationXEngineerConstants.MODIFY;
                                    var fieldInfo = partNumberView.modifyPartNumberField(editingField, userEditedFormat, ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED);
                                    that.modal.destroy();
                                }
                            }
                        });
                    }
                });


                this.modal.show();

            }


        };
        partNumberView.initVariable();
        return partNumberView;
    });

define('DS/ParameterizationSkeleton/Views/ParameterizationXEngineering/PartNumberingLayoutView', [
        'UWA/Core',
        'UWA/Class/View',
        'DS/UIKIT/Mask',
        'DS/UIKIT/Scroller',
        'DS/WAFData/WAFData',
        'DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
        'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler',
        'DS/ParameterizationSkeleton/Views/ParameterizationXEngineering/PartNumberingViewUtilities',
        'DS/ParameterizationSkeleton/Views/ParameterizationXEngineering/ParameterizationXEngineerConstants',
        'DS/ParameterizationSkeleton/Views/ParameterizationXEngineering/XENGModal',
        'DS/UIKIT/Input/Button',
        'DS/UIKIT/Alert',
        'i18n!DS/ParameterizationSkeleton/assets/nls/XEngineeringNLS'
    ],
    function(UWA,
        View,
        Mask,
        Scroller,
        WAFData,
        ParametersLayoutViewUtilities,
        URLHandler,
        PartNumberingViewUtilities,
        ParameterizationXEngineerConstants,
        XENGModal,
        Button,
        Alert,
        XEngineeringNLS) {

        'use strict';

        var extendedView;

        extendedView = View.extend({
            tagName: 'div',
            className: 'generic-detail',

            init: function(options) {
                var initDate = new Date();

                options = UWA.clone(options || {}, false);
                this._parent(options);

                this.contentDiv = null;
                this.paramScroller = null;
                this.userMessaging = null;
                this.lastAlertDate = initDate.getTime();
                this.controlDiv = null;
			},

            setup: function(options) {
                UWA.log('XEngineering Layout::setup!');
                UWA.log(options);
            },

            render: function() {
                UWA.log("XEngineering LayoutView::render");
                var introDiv,
                    mappingDiv,
                    that = this;

                this.contentDiv = UWA.createElement('div', {
                    'id': 'typeMainDiv'
                });
                Mask.mask(this.contentDiv);

                introDiv = UWA.createElement('div', {
                    'class': 'information'
                }).inject(this.contentDiv);

                UWA.createElement('p', {
                    text: XEngineeringNLS.intro,
                    'class': 'font-3dslight'
                }).inject(introDiv);

                this.controlDiv = ParametersLayoutViewUtilities.createApplyResetToolbar.call(this, this.contentDiv, true,
                    this.applyParams.bind(this), this.resetParams.bind(this));

                this.container.setContent(this.contentDiv);
                this.listenTo(this.collection, {
                    onSync: that.onCompleteRequestMapping
                });

                return this;
            },

            onCompleteRequestMapping: function() {
                var that = this;
                UWA.log('XEngineering Layout::Complete rendering!');


                var collection = this.collection._models[0]._attributes;

                PartNumberingViewUtilities.physicalProductAttributes(collection.PhysicalProductAttributes);

                var fields = collection.ExpressionList;
                var nosOfFields = (fields) ? fields.length : 0;

                this.divPartNumbering = UWA.createElement('div', {
                    'class': 'partNumberingDivScroll',
                }).inject(this.contentDiv);


                this.baseAccordion = ParametersLayoutViewUtilities.createFamilyUIKITAccordion(this.divPartNumbering);

                var partNumberingDiv = UWA.createElement('div', {
                    'class': 'partNumbering'
                });

                var partNumberTable = PartNumberingViewUtilities.buildAttributeTable(collection);
                partNumberTable.inject(partNumberingDiv);

                var AddMappingButton = new Button({
                    className: 'AddPartNumberFieldButton',
                    icon: 'plus-circled',
                    attributes: {
                        disabled: false,
                        'aria-hidden': 'true',
                        title: XEngineeringNLS.AddFieldMappingTooltip,
                    },
                    events: {
                        onClick: function(e) {
                            that.ShowAddNewFieldPanel(that, partNumberTable.getElement(".partNumberFieldbody"));
                        }
                    }
                }).inject(partNumberingDiv);


                this.baseAccordion.addItem({
                    title: XEngineeringNLS.BaseTitle,
                    content: partNumberingDiv,
                    selected: true,
                    name: XEngineeringNLS.BaseName,
                });

                for (var i = 0; i < nosOfFields; i++) {
                    var field = fields[i];
                    var deployedStatus = (field.Deployed && field.Deployed=="True")? ParameterizationXEngineerConstants.DEPOLOYED : ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED;
                    var fieldInfo = PartNumberingViewUtilities.buildNewPartNumberField(
                        PartNumberingViewUtilities.buildJsonObjForPNField(ParameterizationXEngineerConstants.ADD, field.Name, field.Order, field.Type, field.Value, field[ParameterizationXEngineerConstants.ATTRIBUTE], field[ParameterizationXEngineerConstants.COUNTER]),
                        deployedStatus);
                    fieldInfo.inject(partNumberTable.getElement(".partNumberFieldbody"));
                }

                this.paramScroller = new Scroller({
                    element: this.divPartNumbering,
                }).inject(this.contentDiv);

                Mask.unmask(this.contentDiv);
            },


            resetParams: function() {
                var that = this;
		Mask.mask(this.contentDiv);
                var url = URLHandler.getURL() + "/resources/v1/xENGParameterization/resetAdminPartNumberProperties?tenant=" + URLHandler.getTenant();
                WAFData.authenticatedRequest(url, {
                    timeout: 250000,
                    method: 'GET',
                    type: 'json',

                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                    },

                    onFailure: function(json) {
			Mask.unmask(that.contentDiv);
                        that.onResetFailure(XEngineeringNLS.ResetError);
                    },

                    onComplete: function(json) {
                        if(json && json.ExpressionList){
                            json.ExpressionList.sort(function(a, b) {
                                if (a.Order && b.Order) {
                                    return a.Order - b.Order;
                                }
                            });
                        }
                        that.onResetSuccess(json);
			Mask.unmask(that.contentDiv);
			that.getAlertMessage(XEngineeringNLS.ResetSuccess, 'success', that.contentDiv);
                    }

                });

            },

            onResetSuccess: function(json) {
            	var savedInfo = json.ExpressionList;
                var that = this;
                var fieldsToBeRemoved = new Array();
                var rowsOfMappedFields = this.contentDiv.getElementsByClassName("partNumberFieldMapping");
                for (var i = 0; i < rowsOfMappedFields.length; i++) {
                    if (rowsOfMappedFields[i].value == ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED) {
                        if ((savedInfo && savedInfo[i])) {
                            var fieldInfo = (that.collection._models[0]._attributes.ExpressionList && that.collection._models[0]._attributes.ExpressionList[i]) ? that.collection._models[0]._attributes.ExpressionList[i] : savedInfo[i];
                            fieldsToBeRemoved.push(PartNumberingViewUtilities.resetForFieldLineChanges(rowsOfMappedFields[i], fieldInfo));
                        } else {
                            fieldsToBeRemoved.push(PartNumberingViewUtilities.resetForFieldLineChanges(rowsOfMappedFields[i]));
                        }
                    }
                }
                fieldsToBeRemoved.forEach(function(attrMapping) {
                    if (attrMapping) {
                        attrMapping.remove();
                    }
                });
                //PartNumberingViewUtilities.updateStrategy(json.Strategy, ParameterizationXEngineerConstants.DEPOLOYED);
                PartNumberingViewUtilities.updateFormulaTextFields(ParameterizationXEngineerConstants.MAX_ROWS + 1, null, null, ParameterizationXEngineerConstants.DEPOLOYED);
            },

            onResetFailure: function(message) {
		this.getAlertMessage(message, 'error', this.contentDiv);

            },


            applyParams: function() {
                var that = this;
                var rowsOfMappedFields = this.contentDiv.getElementsByClassName("partNumberFieldMapping");
                var payloadToSend = {};
//                payloadToSend.Strategy = document.querySelector(".partNumberStrategyMapping").value;
		Mask.mask(this.contentDiv);
                payloadToSend.ExpressionList = [];
                for (var i = 0; i < rowsOfMappedFields.length; i++) {
                    if (rowsOfMappedFields[i].value == ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED) {
                        var value = PartNumberingViewUtilities.buildsFieldJsonObject(rowsOfMappedFields[i]);
                        payloadToSend.ExpressionList.push(value);
                    }
                }

                var url = URLHandler.getURL() + "/resources/v1/xENGParameterization/setAdminPartNumberProperties?tenant=" + URLHandler.getTenant(),payloadToSend;
                WAFData.authenticatedRequest(url, {
                    timeout: 250000,
                    method: 'POST',
                    data: JSON.stringify(payloadToSend),
                    type: 'json',

                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },

                    onFailure: function(json) {
                    	Mask.unmask(that.contentDiv);
                        that.onApplyFailure(XEngineeringNLS.ApplyError);
                    },

                    onComplete: function(json) {
                        if (json.Action == "Success") {
                            that.onApplySuccess(payloadToSend.Strategy);
						    Mask.unmask(that.contentDiv);
						    that.getAlertMessage(XEngineeringNLS.ApplySuccess, 'success', that.contentDiv);

                        } else {
                        	Mask.unmask(that.contentDiv);
                            that.onApplyFailure(json.message);
                        }
                    }

                });
            },

            onApplyFailure: function(message) {
            	this.getAlertMessage(message, 'error', this.contentDiv);
            },

            onApplySuccess: function(strategyValue) {
            	
                //PartNumberingViewUtilities.updateStrategy(strategyValue, ParameterizationXEngineerConstants.DEPOLOYED);
                var fieldsToBeRemoved = new Array();

                var rowsOfMappedFields = this.contentDiv.getElementsByClassName("partNumberFieldMapping");
                for (var i = 0; i < rowsOfMappedFields.length; i++) {
                    if (rowsOfMappedFields[i].value == ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED) {
                        var statusCell = rowsOfMappedFields[i].cells[5];
                        if (statusCell.value == ParameterizationXEngineerConstants.ADD || statusCell.value == ParameterizationXEngineerConstants.MODIFY) {
                            rowsOfMappedFields[i].cells[5].empty();
                            rowsOfMappedFields[i].value = ParameterizationXEngineerConstants.DEPOLOYED;
                            var imgSpan = PartNumberingViewUtilities.buildImgSpan('check', '1.5', 'green', XEngineeringNLS.Deployed);
                            imgSpan.inject(rowsOfMappedFields[i].cells[5]);
                        }
                        if (rowsOfMappedFields[i].cells[5].value == ParameterizationXEngineerConstants.REMOVE) {
                            fieldsToBeRemoved.push(rowsOfMappedFields[i]);
                        }
                    }
                }

                fieldsToBeRemoved.forEach(function(attrMapping) {
                    attrMapping.remove();
                });

                var formulaField = document.querySelector(".partNumberFormulaMapping");
                formulaField.cells[3].empty();
                var imgSpan = ParametersLayoutViewUtilities.buildImgSpan('check', '1.5', 'green', XEngineeringNLS.Deployed);
                imgSpan.inject(formulaField.cells[3]);

            },

            ShowAddNewFieldPanel: function(attrtbody) {
                this.createPartNumberingDialogBox(attrtbody);
                var isDeployed = ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED;
            },

            createPartNumberingDialogBox: function(attrtbody) {
                var that = this;
                var attributes = (this.collection._models[0]._attributes && this.collection._models[0]._attributes.PhysicalProductAttributes);
                var options = {
                    className: "part-number-modal",
                    title: XEngineeringNLS.AddFieldMappingTooltip 
                }

                this.modal = new XENGModal(options);

                this.modal.getAttributes(attributes);

                if (this.modal.getTotalFormatRows() == ParameterizationXEngineerConstants.MAX_ROWS) {
                    var alert = that.modal.displayAlertMessage(XEngineeringNLS.maxLimitOfRows, document.querySelector('#typeMainDiv').getChildren()[0]);
                } else {
                    function _getFooter() {
                        return "<button type='button'  name='addButton' id='add-button' class='btn btn-primary'>" + XEngineeringNLS.add + "</button> " + "</button>" + "<button type='button' name='cancelButton' id='cancel-button' class='btn btn-default'>" + XEngineeringNLS.cancel + "</button>"
                    }

                    this.modal.modal.setFooter(_getFooter());
                    this.modal.getModalBody();
                    this.modal._bindFooterEvent();
                    this.modal.getContent().getElements('.btn').forEach(function(element) {
                        if (that.modal.isCounterExists(ParameterizationXEngineerConstants.TYPE)) {
                            that.modal.partNumberTypeCombobox.disable(ParameterizationXEngineerConstants.FORMAT_COUNTER);
                        }

                        if (element.name === 'cancelButton') {
                            element.addEvent('click', function() {
                                that.modal.destroy();

                            });
                        } else if (element.name === 'addButton') {

                            element.addEvent('click', function() {

                                var toDisplayOver = that.modal.getContent().getElement('.enox-part-number-content');

                                if (that.modal.validateEnteredNameValueNotNull()) {
                                    that.modal.displayAlertMessage(XEngineeringNLS.nameNullMessage, toDisplayOver);
                                } else if (that.modal.validateEnteredOrderValueNotNull()) {
                                    that.modal.displayAlertMessage(XEngineeringNLS.orderNullMessage, toDisplayOver);
                                } else if (that.modal.validatSelectedTypeFieldValueNotNull()) {
                                    that.modal.displayAlertMessage(XEngineeringNLS.selectTypeMessage, toDisplayOver);
                                } else if (that.modal.validateSelectedAttributeFieldValueNotNull()) {
                                	that.modal.displayAlertMessage(XEngineeringNLS.selectAttributeMessage, toDisplayOver);
                                }else if (that.modal.validateEnteredCounterFieldValueNotNull()) {
                                   that.modal.displayAlertMessage(XEngineeringNLS.counterIsEmptyMessage, toDisplayOver);
                                }else if (that.modal.validateEnteredValueFieldValueNotNull()) {
                                    that.modal.displayAlertMessage(XEngineeringNLS.valueEmptyMessage, toDisplayOver);
                                } else {
                                	if (!that.modal.validateEnteredNameValue().isValid) {
										that.modal.displayAlertMessage(XEngineeringNLS.nameMessage +  ' ' + XEngineeringNLS.alreadyExists, toDisplayOver);
									} else if (!that.modal.validateEnteredOrderValue().isValid) {
										that.modal.displayAlertMessage(XEngineeringNLS.orderMessage +  ' ' + XEngineeringNLS.alreadyExists, toDisplayOver);
									} else {
                                        var userSelectedFormat = that.modal.getUserEnteredValues();

                                        userSelectedFormat[ParameterizationXEngineerConstants.OPERATION] = ParameterizationXEngineerConstants.ADD;
                                        var fieldInfo = PartNumberingViewUtilities.buildNewPartNumberField(userSelectedFormat, ParameterizationXEngineerConstants.NEW_NOT_DEPLOYED);
                                        fieldInfo.inject(attrtbody.getElement(".partNumberFieldbody"));
                                        that.modal.destroy();
                                    }
                                }
                            });
                        };
                    });

                    that.modal.show();
                }
            },

			getAlertMessage: function (message, className, toDisplayOn) {
	
				this.alertOptions = {
					visible: true,
					className: 'param-alert',
					messageClassName: className,
					closable: true,
					renderTo: toDisplayOn,
					autoHide: true,
					hideDelay: 2000
				};
	
				var alert = new Alert(this.alertOptions);
				alert.add({
					message: message,
				});
	
			},

            destroy: function() {
                this.stopListening();
                this._parent.apply(this, arguments);
            }
        });

        return extendedView;
    });

/*@fullReview  ZUR 15/07/24 2016xFD01*/
/*@quickReview ZUR 15/11/23 2017x Param Skeleton*/
/*global define*/
define(
    'DS/ParameterizationSkeleton/Utils/PropagationWebServices',
    [
        'UWA/Core',
        'DS/WAFData/WAFData',
        'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler'
    ],
    function(UWA, WAFData, URLHandler) {

        'use strict';

        var wsUtils = {

            findTypes : function (onSearchFailure, onSearchSuccess, onSearchTimeOut) {
                var sIndexAPIUrl = "";
                if(this.indexAPIUrl)
                    sIndexAPIUrl="?indexURL="+this.indexAPIUrl;
                var url = URLHandler.getURL() + "/resources/dictionary/typesExtensions" + sIndexAPIUrl;
                var that = this;
                UWA.log("PropagationWebServices::findTypes call");
                WAFData.authenticatedRequest(url, {
                    timeout: 180000,
                    method: 'GET',
                    type: 'json',
                    //proxy: 'passport',

                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                    },

                    onFailure : function (resError,Response,resHeaders) {
                        /*var message = Response.message;
                        if (data && typeof data === 'object') { // null = 'object'
                            if (data.error && data.error.message) {
                                message = data.error.message;
                            }
                            else if (data.message) {
                                message = data.message;
                            }
                        }
                        else if (typeof object === 'string') {
                            if (object.startsWith('NetworkError:')) {
                                if (object.endsWith('return ResponseCode with value "0".')) {
                                    message = "There is no Internet connection.";
                                }
                                else if (object.endsWith('return ResponseCode with value "401".') ||
                                        object.endsWith('return ResponseCode with value "403".')) {
                                    message = "You are unauthorized to access the resource, please refresh the webpage to login and try again.";
                                }
                                else {
                                    message = "An error is returned from web service.";
                                }
                            }
                            else if (object === 'null') {
                                message = "An error is returned from web service.";
                            }
                        }*/
                        onSearchFailure(that,resError);
                    },

                    onComplete: function(Response) {
                        onSearchSuccess(that, Response);
                    },
                    onTimeout: function() {
                        onSearchTimeOut(that);
                    }
                });
            },

            PropagAtt : function (payload, admin, onPropagFailure, onPropagSuccess, onPropagTimeOut) {
                var url = URLHandler.getURL() + "/resources/dictionary/propagateProperties?admin=" + admin;
                var that=this;
                UWA.log("PropagationWebServices::bindTypes call");
                WAFData.authenticatedRequest(url, {
                    timeout: 180000,
                    method: 'POST',
                    data: JSON.stringify(payload),
                    type: 'json',
                    //proxy: 'passport',

                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json',
                    },

                    onFailure : function (resError,Response,resHeaders) {
                        /*var message = object;
                        if (data && typeof data === 'object') { // null = 'object'
                            if (data.error && data.error.message) {
                                message = data.error.message;
                            }
                            else if (data.message) {
                                message = data.message;
                            }
                        }
                        else if (typeof object === 'string') {
                            if (object.startsWith('NetworkError:')) {
                                if (object.endsWith('return ResponseCode with value "0".')) {
                                    message = "There is no Internet connection.";
                                }
                                else if (object.endsWith('return ResponseCode with value "401".') ||
                                        object.endsWith('return ResponseCode with value "403".')) {
                                    message = "You are unauthorized to access the resource, please refresh the webpage to login and try again.";
                                }
                                else {
                                    message = "An error is returned from web service.";
                                }
                            }
                            else if (object === 'null') {
                                message = "An error is returned from web service.";
                            }
                        }*/
                        onPropagFailure(that, resError);
                    },

                    onComplete: function(Response) {
                        onPropagSuccess(that, Response);
                    },
                    onTimeout: function() {
                        onPropagTimeOut(that);
                    }
                });
            }
        };

        return wsUtils;

    }
);

define('DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/LabelEdgeView', 
[
     'UWA/Core',   
     'egraph/core', 
     'egraph/views', 
     'egraph/utils',    
     'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/ParamStepGeometry',
],function(UWA, 
           core, views, utils,
           StepGeo)
{  /**
         * Add an edge between two connectors.
         * @param {module:egraph/core.Connector} c1
         * @param {module:egraph/core.Connector} c2
         * @returns {module:egraph/core.Edge} the new edge
         */ 

        var svgNS ='http://www.w3.org/2000/svg',xlinkNS = 'http://www.w3.org/1999/xlink';
        var nextUID_x = 0;

        var exports = {};  
        var currSign = "";//removeit ne sert à rien

        exports.LabelEdgeView = function (signature) {
            
            currSign = signature; //removeit ne sert à rien
            views.SVGEdgeView.call(this);
        },

        utils.inherit(exports.LabelEdgeView, views.SVGEdgeView);

        exports.LabelEdgeView.prototype.className = 'arrow-edge';

        exports.LabelEdgeView.prototype.oncreateDisplay = function (e) {
        var textPath;

        views.SVGEdgeView.prototype.oncreateDisplay.apply(this, arguments);

        // assign a unique ID to the path that can be later referenced
        // by the <textPath>
        this.display.elt.id = makeUniqueID2();

        // create a <textPath> following the edge's path
        textPath = document.createElementNS(svgNS, 'textPath');
        // set the reference to edge's path
        textPath.setAttributeNS(xlinkNS, 'href', '#' + this.display.elt.id);
        // set the offset so that the text anchor is centered --> 20%
        textPath.setAttribute('startOffset', '20%');
        // insert the text content
        textPath.appendChild(document.createTextNode(e.signature));

        // create a <text> for the <textPath>
        this.display.text = document.createElementNS(svgNS, 'text');
        // offset the text of 5 above the path (can't be assigned in CSS)
        this.display.text.setAttribute('dy', '-5');
        // assign the CSS class to the text
        utils.classListAdd(this.display.text, 'edge-text');
        // append the <textPath>
        this.display.text.appendChild(textPath);
        // append the <text> to the structure of the edge's view
        this.structure.root.appendChild(this.display.text);
        };


        function makeUniqueID ()
        {
        
            function next() {
                return '--path' + nextUID++;
            }

            var nextUID = 0;
            UWA.log("next = "+next);
            return next;
        }

        function makeUniqueID2 ()
        {
        
            var yx =  '--path' + nextUID_x++;        
            UWA.log("yx = "+yx);
            return yx;
        }
  


        return exports;

});    

/*global define*/
define('DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/ParamEdgeView',
     [
        'UWA/Core',
        'egraph/core',
        'egraph/views',
        'egraph/utils',
        'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/LabelEdgeView',
        'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/ParamStepGeometry'
    ], function(UWA,
           core, views, utils,
           LabelEdgeView, StepGeo) {
        'use strict';

        var edgebuild = {

            buildEdge : function (stub, signature) {
                var edge = new core.Edge(),
                    currstepGeometry = new StepGeo.ParamStepGeometry(stub);

                edge.set('geometry', currstepGeometry);
                edge.views.main = new views.SVGEdgeView('arrow-edge');
                //    edge.views.main = new LabelEdgeView.LabelEdgeView(signature);
                return edge;
            },
        };

        return edgebuild;
    });

/*@fullReview  S63 17/03/03 2018xFD01 Param Widgetization NG*/
/*global define, widget, document, setTimeout, console*/
/*jslint plusplus: true*/
/*jslint nomen: true*/
define('DS/ParameterizationSkeleton/Views/PropagationLayoutViewUtilities',
    [
        'UWA/Core',
        'DS/UIKIT/Input/Button',
        'DS/UIKIT/Alert',
        'DS/UIKIT/Input/Toggle',
        'DS/UIKIT/Popover',
        'DS/UIKIT/Spinner',
        'DS/UIKIT/Mask',
        'DS/UIKIT/Modal',
        'DS/UIKIT/SuperModal',
        'DS/ParameterizationSkeleton/Utils/PropagationWebServices',
        'DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
        'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS'
    ],
    function (UWA,
              Button,
              Alert, Toggle, Popover, Spinner, Mask,
              Modal,SuperModal,
              PropagationWebServices, ParamLayoutUtilities,
              ParamSkeletonNLS) {

        'use strict';

        var UIview = {

            buildPropagAttLine : function (wdthArray,content) {
                var buttonBindCell, cellBindText, cellInfo, bindBttn,
                    bindLine = UWA.createElement('tr'),
                    that = this,
                    admBtn, currUsrBtn, headertitle, bodyDiv,
                    admin=false;

                UWA.log("PropagationLayoutViewUtilities::buildBindAutoExtLine start");

                cellBindText = UWA.createElement('td', {
                    //'colspan': '2',
                    'width': wdthArray[0].toString() + '%',
                    'align': 'left'
                }).inject(bindLine);

                UWA.createElement('p', {
                    text: ParamSkeletonNLS.PropagationFirstLine,
                    'class': ''
                }).inject(cellBindText);

                cellInfo = UWA.createElement('td', {
                    'width': wdthArray[1].toString() + '%',
                    'align': 'left'
                }).inject(bindLine);

                ParamLayoutUtilities.buildPopoverSpan(cellInfo, ParamSkeletonNLS.PropagationInfo);

                UWA.createElement('td', {
                    'width': wdthArray[2].toString() + '%',
                    'align': 'left'
                }).inject(bindLine);

                buttonBindCell = UWA.createElement('td', {
                    'width'  : wdthArray[3].toString() + '%'
                }).inject(bindLine);

                bindBttn =  new Button({
                    className: 'primary',
                    id : 'bindButton',
                    icon: 'archive',
                    attributes: {
                        disabled: false,
                        //title: ParamSkeletonNLS.IndexationTooltip,
                        text : ParamSkeletonNLS.Search,
                        title: ParamSkeletonNLS.SearchInfo                    },
                    events: {
                        onClick: function () {
                            Mask.mask(content.contentDiv);
                            //that.contentDiv.destroy();
                            //var tbodyreflist = this.contentDiv.getElements('.fparamtbody'),
                            //tbodyref = tbodyreflist[2],
                            //iLines = tbodyref.children;

                           //iLines[2].hide();
                            //tbodyref.empty();
                            PropagationWebServices.findTypes.call(content, that.onSearchFailure.bind(that), that.onSearchSuccess.bind(that), that.onSearchTimeOut.bind(that));
                        }
                    }
                }).inject(buttonBindCell);
                bindBttn.getContent().setStyle("width", 150);

                if(content.adminModal == null) {
                    var tbodyreflist = content.contentDiv.getElements('.fparamtbody'),
                        tbodyref = tbodyreflist[2];
                    content.adminModal = new SuperModal({ renderTo: content.contentDiv });
                }

                UWA.log("PropagationLayoutViewUtilities::buildBindAutoExtLine end");

                return bindLine;
            },
            
            updateUIPropagAtt : function(json, content) {
                UWA.log("PropagationLayoutViewUtilities::updateUIPropagAtt start");
                var tbodyreflist = content.contentDiv.getElements('.fparamtbody'),
                iController, imgCell,
                tbodyref = tbodyreflist[2],
                listTypes=json.Result,
                resultJSON = content.payload,
               //noAccessObj=json.NoAccessObj,
                that=this,
                needAdminPropag=false;
                content.inputControls = [];
                content.propagTypesArray = [];
                tbodyref.empty();
                content.indexAPIUrl = json.url;

                //UWA.log("PropagationLayoutViewUtilities::updateUIPropagAtt start");


                //FirstLine ==============================================>
                var firstLine = UWA.createElement('tr').inject(tbodyref);

                var infoCell = UWA.createElement('td', {
                    'colspan': '15',
                    'width': '75%',
                    'align': 'left'
                }).inject(firstLine);
                UWA.createElement('p', {
                    text : ParamSkeletonNLS.PropagationReloadText,
                    'class': ''
                }).inject(infoCell);
                var buttonCell = UWA.createElement('td', {
                    'colspan': '5',
                    'width': '25%',
                    }).inject(firstLine);
                var reloadBttn =  new Button({
                    className: 'primary',
                    id : 'reloadButtonX',
                    icon: 'archive',
                    attributes: {
                        disabled: false,
                        //title: ParamSkeletonNLS.IndexationTooltip,
                        text : ParamSkeletonNLS.PropagationReloadButton,
                        'title' : ParamSkeletonNLS.PropagationReloadTitle
                    },
                    events: {
                        onClick: function () {
                            Mask.mask(content.contentDiv);
                            that.callFindTypes(content);
                            //PropagationWebServices.findTypes.call(content, that.onSearchFailure.bind(that), that.onSearchSuccess.bind(that));
                        }
                    }
                }).inject(buttonCell);
                reloadBttn.getContent().setStyle("width", 150);

                //Header ============================================>
                var header = UWA.createElement('tr', {
                    'class': 'active'
                }).inject(tbodyref);
                var cellAllCheck = UWA.createElement('td', {
                    'width'  : '5%',
                    'align': 'left'
                }).inject(header);
                iController = new Toggle({
                    type: "checkbox",
                    className: "primary",
                    value: "",
                    'name' : "AllExtensions",
                    id : "Extensions",
                    disabled: false,
                    events: {
                        onChange: function() {
                            //content.userMessaging.add({ className: "message", message: "CheckBox Checked" });
                            that.onToggleClick.call(that,content,this);
                        }
                    }
                }).inject(cellAllCheck);
                //UWA.createElement('td', {
                //    'width' : '5%',
                //    'align':'left'
                //}).inject(header);
                var cellHeaderObj = UWA.createElement('td', {
                    'colspan': '7',
                    'width'  : '35%',
                    'align': 'left'
                }).inject(header);
                UWA.createElement('p', {
                    text: ParamSkeletonNLS.TypesNames,
                    'class': ''
                }).inject(cellHeaderObj);

                var cellHeaderOwner = UWA.createElement('td', {
                    'colspan': '7',
                    'width': '35%',
                    'align': 'left'
                }).inject(header);
                UWA.createElement('p', {
                    text: ParamSkeletonNLS.AttributesInfo,
                    'class': ''
                }).inject(cellHeaderOwner);

                var cellHeaderNumber = UWA.createElement('td', {
                    'colspan': '4',
                    'width': '20%',
                    'align': 'left'
                }).inject(header);
                UWA.createElement('p', {
                    text: ParamSkeletonNLS.PropagationNumber,
                    'class': ''
                }).inject(cellHeaderNumber);
                UWA.createElement('td', {
                    'width' : '5%',
                    'align':'left'
                }).inject(header);

                //Extensions Lines ==============================================================>
                listTypes.sort(function(a, b) {
                    var x = a.NLS,
                        y = b.NLS;
                    return ((x < y) ? -1 : ((x > y) ? 1 : 0));
                });
                for (var i=0; i<listTypes.length; i++) {           
                    var result = listTypes[i];
                    content.propagTypesArray.push(result)
                    var extensions,check,
                    name = result.Name,
                    //owner = result.extOwners,
                    nls = result.NLS,
                    total = result.Total,
                    lAtts = result.Attributes,
                    toTreat = result.Objects,
                    lExtensions = result.Extensions,
                    objets = total - toTreat,
                    myLine = UWA.createElement('tr').inject(tbodyref),
                    treated, atts;

                    if(toTreat == 0) {
                        treated = true;
                    }
                    else {
                        treated = false;
                        //S63:IR-656210-3DEXPERIENCER2019x If there is remaining objects after the attributes propagation we need to executen it as super admin
                        if(resultJSON) {
                            resultJSON.Results.forEach(function(myObj) {
                                if(myObj.typeName===name) {
                                    needAdminPropag=true;
                                }
                            });
                        }
                    }

                    imgCell = ParamLayoutUtilities.buildDeployStsCell(check, '5%', '2', 'right');//5%
                    if(!treated) {
                        imgCell.firstChild.setStyle("color", 'orange');
                    }

                    for(var j=0; j<lAtts.length; j++) {
                        if(j==0) {
                            atts = lAtts[j];
                            //ownersNls = owner[j].nls;
                        }
                        else {
                            atts = atts + ', ' + lAtts[j];
                            //ownersNls = ownersNls + ', ' + owner[j].nls;
                        }
                    }

                    for(var j=0; j<lExtensions.length; j++) {
                        if(j==0) {
                            extensions = lExtensions[j];
                            //ownersNls = owner[j].nls;
                        }
                        else {
                            extensions = extensions + ', ' + lExtensions[j];
                            //ownersNls = ownersNls + ', ' + owner[j].nls;
                        }
                    }

                    var cellObj = UWA.createElement('td', {
                        'width'  : '5%',
                        'align': 'left'
                    }).inject(myLine);
                    iController = new Toggle({
                        type: "checkbox",
                        className: "primary",
                        value: "",
                        'name': name,
                        //text: "test2",
                        //label: "...",
                        id : "Type" + i,
                        disabled: treated
                    }).inject(cellObj);
                    content.inputControls.push(iController);


                    var cellType = UWA.createElement('td', {
                    'colspan': '7',
                    'width': '35%',
                    'style':"vertical-align:middle",
                    'align': 'left'
                    }).inject(myLine);
                    UWA.createElement('label', {
                        text: nls,
                        'for':"Type" + i,
                        //'title': atts
                    }).inject(cellType);
                    this.linkPopoverSpan(cellType, name);

                    var cellAtt = UWA.createElement('td', {
                        'colspan': '7',
                        'width': '35%',
                        'align': 'left'
                    }).inject(myLine);
                    ParamLayoutUtilities.buildPopoverSpan(cellAtt, atts);
                    //UWA.createElement('p', {
                    //    text: ownersNls,
                    //    'class': '',
                    //    //'title': owners
                    //}).inject(cellOwner);
                    //this.linkPopoverSpan(cellOwner, owners);

                    var cellNbObj = UWA.createElement('td', {
                        'colspan': '4',
                        'width': '20%',
                        'align': 'left'
                    }).inject(myLine);
                    UWA.createElement('p', {
                        text: objets + ' / ' + total,
                        'class': '',
                        //'title': toTreat + ' ' +ParamSkeletonNLS.Missing
                    }).inject(cellNbObj);
                    this.linkPopoverSpan(cellNbObj, toTreat + ' ' +ParamSkeletonNLS.Missing);

                    imgCell.inject(myLine);
                }

                //Last Line ============================================================>
                var lastLine = UWA.createElement('tr').inject(tbodyref);

                var infoCell2 = UWA.createElement('td', {
                    'colspan': '15',
                    'width': '75%',
                    'align': 'left'
                    }).inject(lastLine);
                UWA.createElement('p', {
                    text : ParamSkeletonNLS.PropagationlastLine,
                    'class': ''
                    }).inject(infoCell2);

                var buttonCell2 = UWA.createElement('td', {
                    'colspan': '5',
                    'width': '25%',
                    }).inject(lastLine);
                var bindBttn =  new Button({
                    className: 'primary',
                    id : 'propagButtonX',
                    icon: 'archive',
                    attributes: {
                        disabled: false,
                        //title: ParamSkeletonNLS.IndexationTooltip,
                        text : ParamSkeletonNLS.PropagationAttachButton
                    },
                    events: {
                        onClick: function () {
                            that.propagateAtt(content, false);
                            //content.adminModal.show();
                        }
                    }
                }).inject(buttonCell2);
                bindBttn.getContent().setStyle("width", 150);

                //Last Line 2 ============================================================>
                //S63:IR-656210-3DEXPERIENCER2019x If we need super admin context to propagate attributes we add this button
                if(needAdminPropag) {
                    var lastLine2 = UWA.createElement('tr').inject(tbodyref);

                    var infoCell3 = UWA.createElement('td', {
                        'colspan': '8',
                        'width': '40%',
                        'align': 'left'
                        }).inject(lastLine2);
                    UWA.createElement('p', {
                        text : ParamSkeletonNLS.PropagationlastLine2,
                        'class': ''
                        }).inject(infoCell3);
                    var cellWarningInfo = UWA.createElement('td', {
                        'colspan': '7',
                        'width': '35%',
                        'align': 'left'
                    }).inject(lastLine2);
                    ParamLayoutUtilities.buildPopoverSpan(cellWarningInfo, ParamSkeletonNLS.PropagationWarningInfo);

                    var buttonCell3 = UWA.createElement('td', {
                        'colspan': '5',
                        'width': '25%',
                        }).inject(lastLine2);
                    var bindBttn2 =  new Button({
                        className: 'primary',
                        id : 'propagButtonX',
                        icon: 'archive',
                        attributes: {
                            disabled: false,
                            //title: ParamSkeletonNLS.IndexationTooltip,
                            text : ParamSkeletonNLS.PropagationAttachAllButton
                        },
                        events: {
                            onClick: function () {
                                that.propagateAtt(content, true);
                                //content.adminModal.show();
                            }
                        }
                    }).inject(buttonCell3);
                    bindBttn2.getContent().setStyle("width", 150);
                }

                UWA.log("PropagationLayoutViewUtilities::updateUIPropagAtt end");

            },

            propagateAtt : function(content, admin) {
                UWA.log("PropagationLayoutViewUtilities::propagateAtt start");
                var name,
                payload = [],
                that = this;
                content.inputControls.forEach(function (iInput) {
                    if (iInput.isChecked()==true){
                        name=iInput.elements.input.name;
                        content.propagTypesArray.forEach(function(myObj) {
                            if(myObj.Name===name) {
                                payload.push(myObj);
                            }

                        });
                    }
                });
                UWA.log(payload);
                Mask.mask(content.contentDiv);
                //ParameterizationWebServices.bindExt.call(this,payload,  //Appel du web service retournant les informations.
                //                this.onBindFailure.bind(this), this.onBindSuccess.bind(this));

                that.callPropagAtt(payload,content,admin);
                UWA.log("PropagationLayoutViewUtilities::propagateAtt end");

            },

            callPropagAtt : function (iData, content, admin) {
                PropagationWebServices.PropagAtt.call(content, iData, admin, this.onPropagFailure.bind(this), this.onPropagSuccess.bind(this), this.onPropagTimeOut.bind(this));
            },

            callFindTypes : function (content,json) {

                if(content.payload == null) {
                    content.payload = json;
                }

                PropagationWebServices.findTypes.call(content, this.onSearchFailure.bind(this), this.onSearchSuccess.bind(this), this.onSearchTimeOut.bind(this));
            },

            onSearchFailure : function (content,json) {
                UWA.log(">>Search Extension Fail");
                UWA.log(json);
                content.userMessaging.add({ className: "error", message: ParamSkeletonNLS.ExtensionsSearchFailure });
                Mask.unmask(content.contentDiv);
            },

            onSearchTimeOut: function (content) {
                UWA.log(">>Search Extension Fail");
                //UWA.log(json);
                content.userMessaging.add({ className: "error", message: ParamSkeletonNLS.ExtensionsSearchTimeOut });
                Mask.unmask(content.contentDiv);
            },

            onSearchSuccess : function (content, json) {
                UWA.log(">>Search Extension Success");
                UWA.log(json);
                this.updateUIPropagAtt(json, content);
                Mask.unmask(content.contentDiv);
                //this.userMessaging.add({ className: "success", message: "Succes"});
            },

            onPropagFailure : function (content, json) {
                UWA.log(">>Bind att Fail");
                UWA.log(json);

                this.callFindTypes(content);
                content.userMessaging.add({ className: "error", message: ParamSkeletonNLS.AttributesPropagationFailure });
                content.adminModal.alert(ParamSkeletonNLS.PropagationWarningMessage, function () {
                    UWA.log('A sample alert message callback');
                });
                //Mask.unmask(this.contentDiv);
            },

            onPropagSuccess : function (content, json) {
                UWA.log(">>Bind att Success");
                UWA.log(json);

                this.callFindTypes(content,json);
                content.userMessaging.add({ className: "warning", message: ParamSkeletonNLS.AttributesPropagationSuccess });
                /*content.adminModal.alert(ParamSkeletonNLS.AttributesPropagationSuccess, function () {
                    UWA.log('A sample alert message callback');
                });*/
            },

            onPropagTimeOut : function (content) {
                UWA.log(">>Bind att Success");
                //UWA.log(message);

                this.callFindTypes(content);
                content.userMessaging.add({ className: "error", message: ParamSkeletonNLS.AttributesPropagationTimeOut });
                /*content.adminModal.alert(ParamSkeletonNLS.AttributesPropagationSuccess, function () {
                    UWA.log('A sample alert message callback');
                });*/
            },

            linkPopoverSpan : function (iContainerSpan, tooltipNlsTxt) {
                var popoverTooltip = new Popover({
                    target   : iContainerSpan,
                    trigger  : "hover",
                    animate  : "true",
                    position : "top",
                    body     : tooltipNlsTxt,
                    title    : ''
                });
            },

            onToggleClick : function (content,toggle) {
                if(toggle.isChecked()){
                    this.checkAll(content);
                }
                else{
                    this.unCheckAll(content);
                }
            },

            checkAll : function (content) {
                content.inputControls.forEach(
                    function (iInput) {
                        if(iInput.isDisabled()==false){
                            if (iInput.isChecked()==false){
                                iInput.check();
                            }
                            //iInput.dispatchEvent('onChange', content);//onClick
                        }
                    }
                );
            },

            unCheckAll : function (content) {
                content.inputControls.forEach(
                    function (iInput) {
                        if(iInput.isDisabled()==false){
                            if (iInput.isChecked()==true){
                                iInput.uncheck();
                            }
                            //iInput.dispatchEvent('onChange', content);//onClick
                        }
                    }
                );
            }
        };

        return UIview;
    });


/*global define, UWA*/
/*jslint plusplus: true*/
define('DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/ParamTransitionsDrag',
    [
        'egraph/core',
        'egraph/views',
        'egraph/utils',
        'egraph/iact',
        'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/LifecycleEgraphUtilities',
        'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/ParamEdgeView',
        'DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
        'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS'
    ],
    function(core, views, utils, iact, LifecycleEgraphUtilities, ParamEdgeView, ParametersLayoutViewUtilities, ParamSkeletonNLS) {

        'use strict';

        var exports = {},
            grphcopy,
            userSMS,
            errorMsgTime = 0,
            listFbdTransitions = [],
            defaultTransitions = [];

        exports.ParamTransitionsDrag = function (grph, c, userMessaging, listofdefaulttransitions, forbiddenTransitions) {
            UWA.log("ParamTransitionsDrag");
            grphcopy = grph;
            userSMS = userMessaging;
            listFbdTransitions = forbiddenTransitions;
            defaultTransitions = listofdefaulttransitions;
            iact.ConnConnectDrag.call(this, grph, c);
        };

        utils.inherit(exports.ParamTransitionsDrag, iact.ConnConnectDrag);

        exports.ParamTransitionsDrag.prototype.onconnect = function () {
            UWA.log("ParamTransitionsDrag::onconnect");
        };

        exports.ParamTransitionsDrag.prototype.newEdge = function () {
            UWA.log("ParamTransitionsDrag::newEdge");
            //.log(this)//this.edge;//this.edge.cl2;//this.otherConnector.aleft
            return LifecycleEgraphUtilities.builTransitiondEdge(2); //null;//LifecycleView.buildEdge(2);
        };

        exports.ParamTransitionsDrag.prototype.onend = function () {
            UWA.log("ParamTransitionsDrag::onend");
            var edgecopy,
                iSign = [];

            iact.ConnConnectDrag.prototype.onend.apply(this, arguments);
            //.log(this)//this.c.node//this.c.otherConnector;
            //this.updateInputs();

            if (this.edge != null) {
                //iSign = "to" + this.edge.cl2.c.node.name;
                //iSign = ParametersLayoutViewUtilities.removeBlancks(this.edge.cl1.c.node.name + "to" + this.edge.cl2.c.node.name);
                iSign = computeSignatureName(this.edge.cl1.c.node, this.edge.cl2.c.node);

                this.edge.signature = iSign[0];
                this.edge.signatureNLS = iSign[1];
                this.edge.isCritical = false;
                edgecopy =  this.edge;

                if ("CBP" === grphcopy.appCategory) {
                    if (testifaSignatureisNeeded(edgecopy.cl1.c.node, edgecopy.cl2.c.node)) {
                        UWA.log("A signature is needed");
                    }
                }

                redrawTransition(edgecopy.cl1.c.node, edgecopy.cl2.c.node, iSign);
                this.edge.remove();

            }
        };

        exports.ParamTransitionsDrag.prototype.onaccept = function (c1, c2) {
            UWA.log("ParamTransitionsDrag::onaccept");
            var currDate = new Date(),
                currTime = currDate.getTime(),
                diffDate = currTime - errorMsgTime;

            if (checkifNodesAreAlreadyConnected(c1.node.gr.edges, c1, c2)) {

                if (diffDate >= 1400) {
                    errorMsgTime = currTime;
                    userSMS.add({className: "warning", message: ParamSkeletonNLS.DoubleTransitionText});
                }
                return false;
            }
            if (c2.node.stateid === c1.node.stateid) {

                if (diffDate >= 1400) {
                    errorMsgTime = currTime;
                    userSMS.add({className: "warning", message: ParamSkeletonNLS.CyclicTransitionText});
                }
                return false;
            }
            if (checkifForbiddenTransition(c1, c2)) {

                if (diffDate >= 1400) {
                    errorMsgTime = currTime;
                    userSMS.add({className: "warning", message: ParamSkeletonNLS.ForbiddenTransitionText});
                }
                return false;
            }

            return true;
        };

        exports.ParamTransitionsDrag.prototype.onconnect = function (edge, otherConnector, temporaryEdge) {
            UWA.log("onconnect::three");
            //.log(edge);
            this.updateTests();//update the input connectors of the node
        };

        exports.ParamTransitionsDrag.prototype.updateTests = function () {
            UWA.log("updateTests");
        };

        function checkifNodesAreAlreadyConnected(listofEdges, c1, c2) {
            var e;
            for (e = listofEdges.first; e; e = e.next) {
                if ((e.cl1.c.node.stateid == c1.node.stateid) &&
                        (e.cl2.c.node.stateid == c2.node.stateid)) {
                    UWA.log("Check::Nodes Already Connected");
                    return true;
                }
            }

            UWA.log("Check::Nodes can be Connected");
            return false;
        }

        function checkifForbiddenTransition(c1, c2) {
            var i, nbofForbiddenTR =  listFbdTransitions.length;

            for (i = 0; i < nbofForbiddenTR; i++) {
                if ((c1.node.stateid == listFbdTransitions[i].sourceState) &&
                        (c2.node.stateid == listFbdTransitions[i].targetState)) {
                    return true;
                }
            }
            return false;
        }

        function buildNewEdge(stub, iSignature, c1, c2) {
            var edge = ParamEdgeView.buildEdge(stub, iSignature);
            edge.signature = iSignature[0];
            edge.signatureNLS = iSignature[1];
            edge.isCritical = false;
            grphcopy.addEdge(c1, c2, edge);//add the edge to the graph
            return edge;
        }

        function redrawTransition(fromNode, toNode, iTransition) {
            var xdiff = toNode.left - fromNode.left,
                iPositions = Math.round(xdiff / grphcopy.nodeSpacing);

            if (iPositions === 1) {
                buildNewEdge(iPositions, iTransition, fromNode.data.right, toNode.data.left);
            } else if (iPositions < 0) {
                buildNewEdge(iPositions, iTransition, fromNode.data.bottom, toNode.data.bottom);
            } else {
                buildNewEdge(iPositions, iTransition, fromNode.data.top, toNode.data.top);
            }
        }

        function testifaSignatureisNeeded(fromNode, toNode) {
            var e, listofEdges, genSign,
                xdiff = toNode.left - fromNode.left,
                iPositions = Math.round(xdiff / grphcopy.nodeSpacing);

            if (iPositions > 1) {
                //return true;
                //UWA.log(grphcopy);
                listofEdges = grphcopy.edges;

                for (e = listofEdges.first; e; e = e.next) {

                    if (e.cl1.c.node.stateid === fromNode.stateid) {
                        xdiff = e.cl2.c.node.left - e.cl1.c.node.left;
                        iPositions = Math.round(xdiff / grphcopy.nodeSpacing);
                        UWA.log("from : " + e.cl1.c.node.stateid + " to : " + e.cl2.c.node.stateid + " :: " + iPositions);

                        if (iPositions === 1) {
                            if (e.signature === "") {
                                //genSign = ParametersLayoutViewUtilities.removeBlancks(e.cl1.c.node.name + "to" + e.cl2.c.node.name);
                                genSign = ParametersLayoutViewUtilities.removeBlancks(e.cl1.c.node.stateid + "to" + e.cl2.c.node.stateid);
                                e.signature = genSign;
                                e.signatureNLS = genSign;
                            }
                        }
                    }
                }
            }

            return false;
        }

        function computeSignatureName(fromNode, toNode) {

            var i,
                oIDandName = [];

            oIDandName[0] = ParametersLayoutViewUtilities.removeBlancks(fromNode.stateid + "to" + toNode.stateid);
            oIDandName[1] = ParametersLayoutViewUtilities.removeBlancks(fromNode.name + "to" + toNode.name);

            for (i = 0; i < defaultTransitions.length; i++) {
                if ((defaultTransitions[i].sourceState === fromNode.stateid) &&
                        (defaultTransitions[i].targetState === toNode.stateid)) {
                    oIDandName[0] = defaultTransitions[i].name;
                    oIDandName[1] = defaultTransitions[i].name;
                    break;
                }
            }
            return oIDandName;
        }

        return exports;

    });

/*@QuickReview NZV 18/06/20  Fixed alignment issues IR-574318-3DEXPERIENCER2019x IR-574334-3DEXPERIENCER2019x */
/*@fullReview  NZV 18/05/28  IR-600551-3DEXPERIENCER2019x */
/*@fullReview  NZV 17/03/02  FUN066122 Added comboboxmultiselect */
/*@fullReview  ZUR 15/07/29 2016xFD01 Param Widgetization NG*/
/*global define, widget, document, setTimeout, console, clearTimeout, FileReader*/
/*jslint plusplus: true*/
/*jslint nomen: true*/
define('DS/ParameterizationSkeleton/Views/ParametersLayoutView',
    [
        'UWA/Core',
        'UWA/Class/View',
        'DS/UIKIT/Input/Button',
        'DS/UIKIT/Input/Select',
        'DS/UIKIT/Input/Text',
        'DS/UIKIT/Input/Toggle',
        'DS/UIKIT/Modal',
        'DS/UIKIT/Alert',
        'DS/UIKIT/Popover',
        'DS/UIKIT/Mask',
        'DS/UIKIT/Scroller',
        'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler',
        'DS/ParameterizationSkeleton/Utils/ParameterizationDataUtils',
        'DS/ParameterizationSkeleton/Utils/ParameterizationWebServices',
        'DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
        'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS',
        'DS/ParameterizationSkeleton/Views/PropagationLayoutViewUtilities'
    ],
    function (UWA, View,
              Button, Select, Text, Toggle,
              Modal,
              Alert, Popover, Mask, Scroller,
              URLHandler, ParameterizationDataUtils, ParameterizationWebServices,
              ParamLayoutUtilities,
              ParamSkeletonNLS, PropagLayoutUtilities) {

        'use strict';

        var extendedView;

        extendedView = View.extend({
            tagName: 'div',
            className: 'generic-detail',

            init: function (options) {
                UWA.log('ParametersLayoutView::init');
                UWA.log(options);
                var initDate =  new Date(),
                    ConnectStruct = ParameterizationDataUtils.paramStructBuilder("domainName,tenantID,env_url");

                options = UWA.clone(options || {}, false);

                this._parent(options);
                this.wdgAccordion = null;
                this.contentDiv = null;
                this.inputControls = [];
                this.paramScroller = null;
                this.userMessaging = null;
                this.userDeployMessaging = null;
                this.lastAlertDate = initDate.getTime();
                this.resetModal = null;
                this.controlDiv = null;
                //NZV - IR-574318-3DEXPERIENCER2019x
                this.columnWidthArray = [60, 5, 25, 10];//[65, 20, 5, 10];
                this.columnLine = null;
                this.ArrayView = false;

                this.connectProps = new ConnectStruct();

                this.custoNamingsArray = [];//Naming
                this.forbiddenNamings = [];//Naming
                this.warnArrays = [];//Naming
                this.commonNamingElts = [];//Naming
                this.nbofShownParameters = 0;
                this.RevMsgTime = 0;
                this.handledFamily = "";
                this.custoAutoExtArray = [];
                this.propagTypesArray = [];
                this.adminModal = null;
                this.ErrorMsgPopup = null;

                //URLHandler.setURL("https://vdevpril807dsy.ux.dsone.3ds.com:443/3DSpace/");
                //URLHandler.setURL("https://dsdev034-euw1-18dna10916-space.3dexperience.3ds.com/enovia/");
            },

            setup: function(options) {
                UWA.log('ParametersLayoutView::setup!');
                UWA.log(options);
            },

            render: function () {
                UWA.log("ParametersLayoutView::render");
                var introDiv,
                    that = this,
                    activateApply = false;

                this.contentDiv =  UWA.createElement('div', {
                    'id': 'mainParamDiv'
                });

                Mask.mask(this.contentDiv);

                this.userMessaging = new Alert({
                    className : 'param-alert',
                    closable: true,
                    visible: true,
                    renderTo : document.body,
                    autoHide : true,
                    hideDelay : 2500,
                    messageClassName : 'warning'
                });

                this.userDeployMessaging = new Alert({
                    className : 'param-alert',
                    closable: true,
                    visible: true,
                    renderTo : document.body,
                    autoHide : true,
                    hideDelay : 5000,
                    messageClassName : 'warning'
                });

                introDiv = ParamLayoutUtilities.createInfoDiv(that.model.get("introduction"));
                introDiv.inject(this.contentDiv);

                if ("ObjectIdentifier" === this.model.get("familyid")) {
                    activateApply = true;
                }

                this.connectProps.domainName = this.model.get("domainid");
                this.connectProps.tenantID   = URLHandler.getTenant();
                this.connectProps.env_url    = URLHandler.getURL();

                //this.createApplyResetToolbar(this.contentDiv, activateApply);
                if ((this.model.get("domainid") !== "Deployment")) {
                    this.controlDiv = ParamLayoutUtilities.createApplyResetToolbar.call(this, this.contentDiv, activateApply,
                                                                  this.applyParams.bind(this), this.confirmationModalShow.bind(this));
                }

                this.container.setContent(this.contentDiv);

                this.listenTo(this.collection, {
                    onSync: that.onCompleteRequestParameters
                });

                /*if ((this.model.get("domainid") !== "Deployment")) {
                    UWA.log("Where do you think we are ?!");
                    this.listenTo(this.collection, {
                        onSync: that.onCompleteRequestParameters
                    });
                } else {
                    that.launchtest();
                }*/

                return this;
            },

            onCompleteRequestParameters : function() {
                UWA.log("onCompleteRequestParameters::");
                var i, iFamilies, nbofFamilies, iContent, paramsDIV, iParamAccordion,
                    familyposition = "mid";

                paramsDIV = ParamLayoutUtilities.createParamsContainerDiv();
                paramsDIV.inject(this.contentDiv);
                //
                UWA.log(this.collection._models[0]._attributes);

                if (this.model.get("domainid")  !== "Deployment") {

                    iFamilies = this.collection._models[0]._attributes.family;
                    nbofFamilies = iFamilies.length;

                    if (nbofFamilies === 1) {
                        iContent = this.buildFamilyItemContent(iFamilies[0], familyposition);
                        iContent.inject(paramsDIV);
                    } else {
                        iParamAccordion = ParamLayoutUtilities.createFamilyUIKITAccordion(paramsDIV);

                        for (i = 0; i < nbofFamilies; i++) {
                            familyposition = "mid";
                            if (i === 0) {
                                familyposition = "first";
                            } else if (i === nbofFamilies - 1) {
                                familyposition = "last";
                            }
                            iContent = this.buildFamilyItemContent(iFamilies[i], familyposition);
                            iParamAccordion.addItem({
                                title: iFamilies[i].nlsKey,
                                content: iContent,
                                selected : true,
                                name : iFamilies[i].id
                            });
							//IR-670134-3DEXPERIENCER2019x
							iParamAccordion.getItem(i).elements.content.setStyle('overflow-y','visible');
                        }
                    }

                    if (this.nbofShownParameters === 0) {
                        ParamLayoutUtilities.createParamMask(this.contentDiv, ParamSkeletonNLS.NoParamAvailabletxt);
                    }
                } else {
                    this.buildDeploymentTab();
                }

                this.paramScroller = new Scroller({
                    element: paramsDIV
                }).inject(this.contentDiv);

                UWA.log('unmask');
                Mask.unmask(this.contentDiv);
            },

            buildFamilyItemContent : function(iFamily, familyPosition) {
                var familyTable, ftbody;

                familyTable = UWA.createElement('table', {
                    'class': 'table table-hover',
                    'table-layout': 'fixed', //NZV-IR-574318-3DEXPERIENCER2019x
                    'id': iFamily.id + 'familytable'
                });

                ftbody =  UWA.createElement('tbody', {
                    'class': 'fparamtbody',
                    'id': iFamily.id + 'familytbody'
                }).inject(familyTable);

                if (iFamily.id == "ObjectIdentifier") {// NZV IR-548508-3DEXPERIENCER2018x\17x
                    iFamily.parameter.sort(ParamLayoutUtilities.compareContentNamingObject);
                    this.processIDFamily(iFamily, ftbody);
                } else {
                    this.buildParametersLayout(iFamily, ftbody, familyPosition);
                }

                return familyTable;
            },

            buildParametersLayout : function (iElements, familytbody, familyPosition) {

                var i, popoverPosition,
                    familyID = iElements.id,
                    listfofParams = iElements.parameter,
                    nbofRows = listfofParams.length;

                this.handledFamily = familyID;

                if ((iElements.column !== undefined)
                        && (iElements.column !== null)
                           && (iElements.column.length > 0)) {
                    //listofColumns = iElements.column;
                    this.columnWidthArray = ParamLayoutUtilities.computeColumnsWidths(iElements.column, this.columnWidthArray);
                    this.columnLine = ParamLayoutUtilities.buildColumnsTitleLine(iElements.column, this.columnWidthArray);//BuiltTitle                    
                    this.columnLine.inject(familytbody);
                    this.ArrayView = true;

                    for (i = 0; i < nbofRows; i++) {
                        popoverPosition = ParamLayoutUtilities.computePopoverPos(i, familyPosition, nbofRows);
                        this.buildParameterLineV2(listfofParams[i], familytbody, popoverPosition);
                        this.nbofShownParameters++;
                    } // of for
                }



                if (this.ArrayView === false) {
                    for (i = 0; i < nbofRows; i++) {
                        popoverPosition = ParamLayoutUtilities.computePopoverPos(i, familyPosition, nbofRows);
                        this.buildParameterLine(listfofParams[i], familyID, familytbody, popoverPosition);
                        this.nbofShownParameters++;
                    } // of for
                }

            },//of function

            onKeyDownTextField : function (event) {
               // ParamLayoutUtilities.beingModified(imgCell, ParamSkeletonNLS.ParamBeingModified, '2');
                UWA.log(event);
            },

            buildParameterLineV2 : function (iParamObj, familytbody, popoverPosition) {

                var i, j, k, iArgument, newParamline, iArgumentList,
                    imgCell, ParamTextCell, imgInfoSpan, ParamInfoCell,
                    popoverTooltip, unit2Display, unitCell,
                    nbofValuesForArg, listofValues, isSelected, controlObjectCell,
                    isArgumentFound = false,
                    that = this,
                    //onChangeToggle, onChangetextfield,onKeyDownTextField, onChangeSelect,
                    iController;

                function onChangeToggle(iController, controlObjectCell, imgCell) {
                    var valuetoSend = iController.isChecked() ? "Enabled" : "Disabled";
                    ParamLayoutUtilities.beingDeployed(imgCell, ParamSkeletonNLS.ParamBeingModified);
                    that.updateParameterOnChange(valuetoSend, controlObjectCell, imgCell);
                }

                function onChangetextfield(iController, controlObjectCell, imgCell) {
                    ParamLayoutUtilities.beingModified(imgCell, ParamSkeletonNLS.ParamBeingModified, '2');
                    that.checkParameterValueOnChange(iController, controlObjectCell, imgCell);
                }

                function onChangeSelect(iController, controlObjectCell, imgCell) {
                    ParamLayoutUtilities.beingModified(imgCell, ParamSkeletonNLS.ParamBeingModified, '2');
                    that.updateRevisioningParameterOnChange(iController, controlObjectCell, imgCell);
                }

                newParamline = UWA.createElement('tr', {title: ''});//iParamObj.tooltipNlsKey                

                imgCell = ParamLayoutUtilities.buildDeployStsCell(iParamObj.isDeployed, that.columnWidthArray[3].toString() + '%', '2', 'right');//5%

                ParamTextCell = UWA.createElement('td', {
                    'width' : that.columnWidthArray[0].toString() + '%',
                    'title' : ''
                });
                ParamTextCell.setStyle("vertical-align", "text-bottom");
                UWA.createElement('p', {text: iParamObj.nlsKey, 'class': ''}).inject(ParamTextCell);

                ParamInfoCell = UWA.createElement('td', {
                    'width' : that.columnWidthArray[1].toString() + '%',
                    'align' : 'left'
                });
                ParamInfoCell.setStyle("vertical-align", "text-bottom");

                imgInfoSpan = UWA.createElement('span', {
                    'class' : 'fonticon fonticon-info'
                }).inject(ParamInfoCell);

                imgInfoSpan.setStyle("color", "black");

                popoverTooltip = new Popover({
                    target   : imgInfoSpan,
                    trigger  : "hover",
                    animate  : "true",
                    position : popoverPosition,
                    body     : iParamObj.tooltipNlsKey,
                    title    : ''
                });

                iArgumentList = iParamObj.argument;
                isArgumentFound = false;

                ParamTextCell.inject(newParamline);
                ParamInfoCell.inject(newParamline);

                for (i = 2; i < this.columnLine.childNodes.length - 1; i++) {
                    isArgumentFound = false;
                    for (k = 0; k < iArgumentList.length; k++) {
                        iArgument = iParamObj.argument[k];
                        if (iArgument.id === this.columnLine.childNodes[i].id) {
                        //Add the td
                            UWA.log('id found!!');
                            isArgumentFound = true;
                            //iArgument = iParamObj.argument[0];                     

                            controlObjectCell = ParamLayoutUtilities.buildControlCell(iParamObj.id, iArgument, that.columnWidthArray[2].toString() + '%');
                            //controlObjectCell.push(tempCell);
                            //var currListLength = controlObjectCell.length;

                            if (iArgument.input === "checkbox") {
                                //NZV-IR-574334-3DEXPERIENCER2019x
                                controlObjectCell.setStyle("vertical-align", "middle");
                                controlObjectCell.setStyle("padding-top", "3px");
                                iController = new Toggle({
                                    type: "checkbox",
                                    className: "primary",
                                    value: "",
                                    //label: "...",
                                    id : iParamObj.id + iArgument.id,
                                    disabled: false,
                                    checked: iArgument.argValue == "Enabled" ? true : false
                                        //onChange: function() {} onClick
                                }).inject(controlObjectCell);
                                //iController.addEvent("onChange", onChangeToggle(iController, controlObjectCell, imgCell));
                                //iController[iController.length - 1].inject(controlObjectCell[currListLength - 1]);
                                /*var myEventListener = {
                                        myProperty : 'event listener',
                                        handleEvent : function (event) {
                                            //UWA.log('"this" is scoped to this ' + this.myProperty);
                                            onChangeToggle(iController, controlObjectCell, imgCell);
                                        }
                                };

                                iController.addEvent("onChange", myEventListener); */

/*
                                iController.addEvent("onChange", function() {       
                                    onChangeToggle(iController, controlObjectCell, imgCell);
                                });*/

                             //   iController.addEvent("onChange", onChangeToggle(iController, controlObjectCell, imgCell));

                            } else if (iArgument.input === "textfield") {
                                //controlObjectCell[currListLength - 1].setStyle("width", "20%");
                                //controlObjectCell.setStyle("width", "20%");
                                iController = new Text({
                                    className: "form-control",
                                    placeholder: "...",
                                    id : iParamObj.id + iArgument.id,
                                    attributes: {
                                        value: iArgument.argValue,
                                        multiline: false,
                                        disabled: false
                                    }
                                    /*events: {
                                        onChange: function () {
                                            ParamLayoutUtilities.beingModified(imgCell, ParamSkeletonNLS.ParamBeingModified, '2');
                                            that.checkParameterValueOnChange(this, controlObjectCell[currListLength - 1], imgCell);
                                        },
                                        onKeyDown: function () {
                                            ParamLayoutUtilities.beingModified(imgCell, ParamSkeletonNLS.ParamBeingModified, '2');
                                        }
                                    }*/
                                }).inject(controlObjectCell);

                               //iController.addEvent("onChange",  onChangetextfield(iController, controlObjectCell, imgCell));
                               // iController.addEvent("onKeyDown", that.onKeyDownTextField());

                                /* iController.addEvent("onKeyDown", function() {
                                    that.onKeyDownTextField(event, imgCell);
                                    });*/
                                //iController[iController.length - 1].inject(controlObjectCell[currListLength - 1]);

                                unit2Display = iParamObj.nlsKey;
                                unitCell = UWA.createElement('td', {
                                    'width': '25%',
                                    'align': 'left',
                                    'html' : unit2Display,
                                    'title': unit2Display
                                });
                                unitCell.setStyle("vertical-align", "text-bottom");
                            } else if (iArgument.input === "combobox") {
                                iController = new Select({
                                    placeholder: false,
                                    nativeSelect: true,
                                    attributes: {
                                        id : iParamObj.id + iArgument.id,
                                        name : iParamObj.id + iArgument.id,
                                        disabled: false
                                    }
                                }).inject(controlObjectCell);//of selectControler                              

                                iController.getContent().setStyle("width", "100%");
                                //controlObjectCell.set({'title' : iArgument.tooltipNlsKey});//  change it  
                                listofValues = iArgument.value;
                                nbofValuesForArg = listofValues.length;
                                for (j = 0; j < nbofValuesForArg; j++) {
                                    isSelected = false;

                                    if (iArgument.argValue == listofValues[j].id) {
                                        isSelected = true;
                                    }

                                    iController.add([{
                                        label: listofValues[j].nlsKey,
                                        value: listofValues[j].id,
                                        selected: isSelected
                                    }], false);
                                }

                                /*iController.addEvent("onChange", function () {
                                    ParamLayoutUtilities.beingModified(imgCell, ParamSkeletonNLS.ParamBeingModified, '2');
                                    that.updateRevisioningParameterOnChange(this, controlObjectCell,imgCell);
                                });*/
                               // iController.addEvent("onChange", onChangeSelect(iController, controlObjectCell, imgCell));
                            } // of  else if (iArgument.input == "combobox") 

                            this.inputControls.push(iController);
                            controlObjectCell.inject(newParamline);
                        }//of if arg.id == column.id
                    }

                    if (isArgumentFound === false) {
                        UWA.createElement('td', {
                            'width' : that.columnWidthArray[2].toString() + '%',
                            'align' : 'left'
                        }).inject(newParamline);
                    }
                }

                /*if (iArgument.input === "textfield") {
                    unitCell.inject(newParamline);
                }*/

                imgCell.inject(newParamline);
                newParamline.inject(familytbody);//familyparamtable 
            },


            buildParameterLine : function (iParamObj, familyID, familytbody, popoverPosition) {

                var j, iArgument, newParamline,
                    imgCell, ParamTextCell, imgInfoSpan, ParamInfoCell, paramTxtToShow,
                    popoverTooltip, controlObjectCell, unit2Display = "", unitCell,
                    iController, nbofValuesForArg, listofValues, isSelected, valuetoSend,
                    bMultiple, bCustom, listOfArg, textfieldTbl, firstTDWidth, firstCol,
                    that = this;

                newParamline = UWA.createElement('tr', {title: ''});//iParamObj.tooltipNlsKey

                iArgument = iParamObj.argument[0];

                imgCell = ParamLayoutUtilities.buildDeployStsCell(iParamObj.isDeployed, that.columnWidthArray[3].toString() + '%', '2', 'right');//5%

                ParamTextCell = UWA.createElement('td', {
                    'width' : that.columnWidthArray[0].toString() + '%',
                    'title' : ''
                });
                ParamTextCell.setStyle("vertical-align", "text-bottom");//iParamObj iArgument

                paramTxtToShow = iArgument.nlsKey;

                if (iArgument.input === "combobox" || iArgument.input === "comboboxmultiselect") {
                    paramTxtToShow = iParamObj.nlsKey;
                }
                UWA.createElement('p', {text: paramTxtToShow,  'class': ''}).inject(ParamTextCell);

                ParamInfoCell = UWA.createElement('td', {
                    'width' : that.columnWidthArray[1].toString() + '%',
                    'align' : 'left'
                });
                ParamInfoCell.setStyle("vertical-align", "text-bottom");

                imgInfoSpan = UWA.createElement('span', {
                    'class' : 'fonticon fonticon-info'
                }).inject(ParamInfoCell);

                imgInfoSpan.setStyle("color", "black");

                popoverTooltip = new Popover({
                    target   : imgInfoSpan,
                    trigger  : "hover",
                    animate  : "true",
                    position : popoverPosition,
                    body     : iArgument.tooltipNlsKey,
                    title    : ''
                });

                controlObjectCell = ParamLayoutUtilities.buildControlCell(iParamObj.id, iArgument, that.columnWidthArray[2].toString() + '%');

                if (iArgument.input === "checkbox") {
                     //NZV-IR-574334-3DEXPERIENCER2019x
                    controlObjectCell.setStyle("vertical-align", "middle");
                    controlObjectCell.setStyle("padding-top", "3px");
                    iController = new Toggle({
                        type: "checkbox",
                        className: "primary",
                        value: "",
                        //label: "...",
                        id : iParamObj.id,
                        disabled: false,
                        checked: iArgument.argValue == "Enabled" ? true : false,

                        events: {
                            onChange: function () {
                                ParamLayoutUtilities.beingDeployed(imgCell, ParamSkeletonNLS.ParamBeingModified);
                                valuetoSend = this.isChecked() ? "Enabled" : "Disabled";
                                that.updateParameterOnChange(valuetoSend, controlObjectCell, imgCell);
                            }
                            //onChange: function() {} onClick
                        }
                    }).inject(controlObjectCell);
                } else if (iArgument.input === "textfield") {
                    //NZV-IR-574318-3DEXPERIENCER2019
                    unit2Display = iParamObj.nlsKey;
                    textfieldTbl = UWA.createElement('table', {'title': ""
                            }).inject(controlObjectCell);
                    firstTDWidth = '100%';
                    if (unit2Display !== "") {
                        firstTDWidth = '90%';
                    }
                    firstCol = UWA.createElement('td', {
                        'width': firstTDWidth,
                        'align': 'right'
                    }).inject(textfieldTbl);
                    iController = new Text({
                        className: "form-control",
                        placeholder: "...",
                        id : iParamObj.id,
                        attributes: {
                            value: iArgument.argValue,
                            multiline: false,
                            disabled: false
                        },
                        events: {
                            onChange: function () {
                                ParamLayoutUtilities.beingModified(imgCell, ParamSkeletonNLS.ParamBeingModified, '2');
                                that.checkParameterValueOnChange(this, controlObjectCell, imgCell);
                            },
                            onKeyDown: function () {
                                ParamLayoutUtilities.beingModified(imgCell, ParamSkeletonNLS.ParamBeingModified, '2');
                            }
                        }
                    }).inject(firstCol);

                    unit2Display = iParamObj.nlsKey;
                    if (unit2Display !== "") {
                        unitCell = UWA.createElement('td', {
                            'width': '10%',
                            'align': 'left',
                            'html' : unit2Display,
                            'title': unit2Display
                        });
                        unitCell.setStyle("vertical-align", "text-bottom");
                        unitCell.setStyle("padding-left", "5px");
                    }
                } else if (iArgument.input === "combobox") {
                    iController = new Select({
                        placeholder: false,
                        nativeSelect: true,
                        attributes: {
                            id : iParamObj.id,
                            name : iParamObj.id,
                            disabled: false
                        }
                    });//of selectControler                              
                    iController.getContent().setStyle("width", "100%");//NZV-IR-574318-3DEXPERIENCER2019x
                    //controlObjectCell.set({'title' : iArgument.tooltipNlsKey});//  change it  
                    listofValues = iArgument.value;
                    nbofValuesForArg = listofValues.length;
                    for (j = 0; j < nbofValuesForArg; j++) {
                        isSelected = false;

                        if (iArgument.argValue == listofValues[j].id) {
                            isSelected = true;
                        }

                        iController.add([{
                            label: listofValues[j].nlsKey,
                            value: listofValues[j].id,
                            selected: isSelected
                        }], false);
                    }

                    iController.addEvent("onChange", function () {
                        ParamLayoutUtilities.beingModified(imgCell, ParamSkeletonNLS.ParamBeingModified, '2');

                        if (familyID === "VersionNaming") {
                            that.updateRevisioningParameterOnChange(this, controlObjectCell, imgCell);
                        } else {
                            that.updateComboParamOnChange(this, controlObjectCell, imgCell);
                        }
                    });

                    iController.inject(controlObjectCell);
                    // of  else if (iArgument.input == "combobox") 
                } else if (iArgument.input === "comboboxmultiselect") {
                    bMultiple = true;
                    bCustom = true;
                    iController = new Select({
                        placeholder: false,
                        nativeSelect: true,
                        multiple: bMultiple,
                        custom: bCustom,
                        attributes: {
                            id : iParamObj.id,
                            name : iParamObj.id,
                            disabled: false
                        }
                    });//of selectControler                              
                    //NZV-IR-574318-3DEXPERIENCER2019x  
                    iController.getContent().setStyle("width", "100%");
                    listofValues = iArgument.value;
                    listOfArg = null;
                    if (iArgument.argValue.indexOf(",") > 0) {
                        listOfArg = iArgument.argValue.split(",");
                    } else {
                        listOfArg = [iArgument.argValue];
                    }
                    nbofValuesForArg = listofValues.length;
                    for (j = 0; j < nbofValuesForArg; j++) {
                        isSelected = false;
                        if (listOfArg != null) {
                            listOfArg.forEach(function (item) {
                                if (item == listofValues[j].id) {
                                    isSelected = true;
                                }
                            });
                        }

                        iController.add([{
                            label: listofValues[j].nlsKey,
                            value: listofValues[j].id,
                            selected: isSelected
                        }], false);
                    }

                    iController.addEvent("onChange", function () {
                        ParamLayoutUtilities.beingModified(imgCell, ParamSkeletonNLS.ParamBeingModified, '2');
                        that.updateComboParamOnChange(this, controlObjectCell, imgCell);
                    });

                    iController.inject(controlObjectCell);
                }
             // of  else if (iArgument.input == "comboboxmultiselect")
                this.inputControls.push(iController);

                ParamTextCell.inject(newParamline);
                ParamInfoCell.inject(newParamline);
                controlObjectCell.inject(newParamline);

                if (iArgument.input === "textfield" && unit2Display !== "") {
                    unitCell.inject(textfieldTbl);
                }

                imgCell.inject(newParamline);
                newParamline.inject(familytbody);//familyparamtable
            },

            processIDFamily : function (iFamilyObject, ftbody) {
                var i, j, k, l,
                    iParam, iArg, iType, nbofctes, nbofArgs, nbofValuesForArg, currAppType, labelAffixcell,
                    affixvaluetoshow, iPrefixVal, iSuffixVal, iPrefixDefVal, iSuffixDefVal, internalType,
                    iFamilyToolTip = iFamilyObject.tooltipNlsKey,
                    nbofParamofNamings = iFamilyObject.parameter.length,
                    wdgDeployIndicator = true,
                    cellLabel, controlObjectCellPreview, controlObjectCell, labelSepcell, iVal, trsfVal,
                    lineParam, imgSpan, imgCell, initialPreview,
                    prefixField, suffixField, affixField, sepControler, finalformatinput, initPreftoShow, initSufftoShow,
                    selectControler, isSelected, iTypeNLS,
                    imgTitle = ParamSkeletonNLS.deployedParamtxt,
                    imgClass = 'fonticon fonticon-2x fonticon-check',
                    iconColor = 'green',
                    optionsSepArray = [],//new Array(); iFamilyNLS = iFamilyObject.nlsKey,
                    constantArray = [],
                    separatorValue = "-",
                    isCommonParamsDeployed = "true",
                    isNamingParamDeployed = "true",
                    sepElt = ParameterizationDataUtils.paramStructBuilder("id,nlsKey,value"),
                    CteElt = ParameterizationDataUtils.paramStructBuilder("id,value"),
                    NamingElement       = ParameterizationDataUtils.paramStructBuilder("namingID,initialValue,defaultValue,currentValue"),
                    CustoNamingElement  = ParameterizationDataUtils.paramStructBuilder("objTypeID,prefix,suffix,defprefix,defsuffix,appType,deploySts"),
                    WarningLabel = ParameterizationDataUtils.paramStructBuilder("warnID", "warnRaised"),
                    separatorContainer, affixContainer, timerconn,
                    jmin = -1, isTypeSelected = false,
                    popOver = null, imgInfoSpan = null, tooltipCell = null, preFixTooltipCell = null,
                    prefixPopOver = null, prefixImgInfoSpan = null,
                    that = this;

                //1st line : preview line          
                lineParam = UWA.createElement('tr', {title: ''}).inject(ftbody);

                cellLabel = UWA.createElement('td', {'width': '30%', 'title': ''}).inject(lineParam);
                UWA.createElement('p', {text: ParamSkeletonNLS.PreviewTxt, 'class': ''}).inject(cellLabel);

                controlObjectCellPreview = UWA.createElement('td', {
                    'width' : '30%',
                    'title' : '',
                    'align' : 'left'
                }).inject(lineParam);

                imgCell = UWA.createElement('td', {
                    'width' : '40%',
                    'title' : '',
                    'id' : 'nameDeployIndicator',
                    align : 'left'
                }).inject(lineParam);

                //1st line bis : Formula Line
                lineParam = ParamLayoutUtilities.buildFormulaLine();
                lineParam.inject(ftbody);

                this.nbofShownParameters = nbofParamofNamings;

                for (j = 0; j < nbofParamofNamings; j++) {
                    iParam = iFamilyObject.parameter[j];

                    if (iParam.id === "IdentifierAffix") {
                        isCommonParamsDeployed = iParam.isDeployed;
                        //getconstants
                        nbofctes = iParam.constant.length;
                        for (l = 0; l < nbofctes; l++) {
                            constantArray[l] = new CteElt(iParam.constant[l].id, iParam.constant[l].value);
                        }

                        nbofArgs = iParam.argument.length;
                        for (k = 0; k < nbofArgs; k++) {
                            if ("AffixArg" === iParam.argument[k].id) {
                                iArg = iParam.argument[k];

                                affixContainer = new NamingElement("IdentifierAffix",
                                        iArg.argValue, iArg.defaultValue,
                                        iArg.argValue);
                                this.commonNamingElts.push(affixContainer);
                            } else if ("SeparatorArg" === iParam.argument[k].id) {
                                iArg = iParam.argument[k];
                                separatorValue = iArg.argValue;
                                nbofValuesForArg = iArg.value.length;

                                for (i = 0; i < nbofValuesForArg; i++) {
                                    iVal = iParam.argument[k].value[i];
                                    trsfVal = iVal.id;

                                    for (l = 0; l < nbofctes; l++) {
                                        if (constantArray[l].id == iVal.id) {
                                            trsfVal =   constantArray[l].value;
                                            break;
                                        }
                                    }

                                    optionsSepArray[i] = new sepElt(trsfVal, iVal.nlsKey, iVal.tooltipNlsKey);
                                    separatorContainer = new NamingElement("SeparatorArg",
                                            separatorValue,
                                            iArg.defaultValue,
                                            separatorValue);
                                    this.commonNamingElts.push(separatorContainer);
                                }//of for loop on the args
                            }//on the if else : iParam.argument[k].id
                        }//of the for loop on the number of args
                        break;
                    }//if (iParam.id == "IdentifierAffix")              
                }//of the first loop on the naming params

                if (isCommonParamsDeployed == "false") { wdgDeployIndicator = false; }

                affixvaluetoshow = affixContainer.initialValue;
                if (affixvaluetoshow === "TBD") { affixvaluetoshow = ""; }

                //2nd line Select Object Type Line
                lineParam = UWA.createElement('tr', {title: ''}).inject(ftbody);
                cellLabel = UWA.createElement('td', {'width' : '30%', 'title' : ''}).inject(lineParam);
                UWA.createElement('p', {text: ParamSkeletonNLS.ObjectTypeTxt, 'class' : ''}).inject(cellLabel);
                controlObjectCell = UWA.createElement('td', {'width': '70%', 'colspan': '2', 'title': ''}).inject(lineParam);

                selectControler = new Select({
                    placeholder: false,
                    nativeSelect: true,
                    attributes: {
                        id       : 'iTypeSelect',
                        disabled : false
                    }
                });

                selectControler.getContent().setStyle("width", 300);
                this.inputControls.push(selectControler);

                for (j = 0; j < nbofParamofNamings; j++) {
                    iParam = iFamilyObject.parameter[j];
                    iType = iParam.id;
                    isTypeSelected = false;

                    if (iParam.id != "IdentifierAffix") {
                        isNamingParamDeployed = iParam.isDeployed;
                        iTypeNLS = iParam.nlsKey;

                        if (jmin === -1) {//ZUR
                            jmin = j;
                            isTypeSelected = true;//IR-559116-3DEXPERIENCER2018x
                        }

                        selectControler.add([{
                            label: iTypeNLS,
                            value: iType,
                            selected : isTypeSelected
                        }], false);

                        nbofArgs = iParam.argument.length;
                        if (nbofArgs === 2) {
                            for (l = 0; l < nbofArgs; l++) {
                                iArg = iParam.argument[l];
                                if ("PrefixArg" === iArg.id) {
                                    iPrefixVal = iArg.argValue;
                                    iPrefixDefVal = iArg.defaultValue;
                                } else if ("SuffixArg" === iArg.id) {
                                    iSuffixVal = iArg.argValue;
                                    iSuffixDefVal = iArg.defaultValue;
                                }
                            }//of for loop
                        //of if nbarg == 2                
                        } else { UWA.log("Houston, we have a problem!"); }

                        nbofctes = iParam.constant.length;
                        currAppType = "VPM";

                        for (l = 0; l < nbofctes; l++) {
                            if (iParam.constant[l].id === "appType") {
                                currAppType = iParam.constant[l].value;
                            } else if (iParam.constant[l].id === "type") {
                                internalType = iParam.constant[l].value;
                            }
                        }
                        //iArgument.nlsKey,iParamObj.id,iArgument.tooltipNlsKey 
                        this.custoNamingsArray.push(new CustoNamingElement(iType,
                                                                        iPrefixVal, iSuffixVal,
                                                                        iPrefixDefVal, iSuffixDefVal,
                                                                        currAppType,
                                                                        isNamingParamDeployed));

                        if (currAppType === "VPM") { this.forbiddenNamings.push(internalType); }

                        if (isTypeSelected === true) {//ZUR - IR-559116-3DEXPERIENCER2018x
                            initPreftoShow = iPrefixVal;
                            initSufftoShow = iSuffixVal;
                        }

                        if (isNamingParamDeployed == "false") { wdgDeployIndicator = false; }

                    }//of if (iParam.id != "IdentifierAffix")                   
                } //of the 2nd loop on the naming params      
                selectControler.inject(controlObjectCell);

                selectControler.addEvent("onChange", function () {
                    that.selectedTypeChanged(this);
                });

                //3rd line : Prefix Line
                lineParam = UWA.createElement('tr', {title: ''}).inject(ftbody);
                cellLabel = UWA.createElement('td', {'width': '30%', 'title': ''}).inject(lineParam);
                UWA.createElement('p', {text: ParamSkeletonNLS.Prefix, 'class': ''}).inject(cellLabel);
                controlObjectCell = UWA.createElement('td', {'width': '30%', 'title': ''}).inject(lineParam);

                prefixField = new Text({
                    placeholder: ParamSkeletonNLS.EmptyValueNotAllowed,
                    attributes: {
                        id : 'prefixInput',
                        value: initPreftoShow,
                        multiline: false,
                        disabled: false
                    },
                    events: {
                        onKeyDown: function () {
                            if (timerconn) { clearTimeout(timerconn); }
                            timerconn = setTimeout(function() {
                                var typeSelector, currSelectedOpt, selectedTypeLabel, cNamingElt;
                                if ((prefixField.getValue()).trim() === "") {
                                    typeSelector = ParamLayoutUtilities.getNamingControlInput(that.inputControls, "iTypeSelect");
                                    currSelectedOpt = typeSelector.getSelection();
                                    selectedTypeLabel = currSelectedOpt[0].label;
                                    cNamingElt = ParamLayoutUtilities.getCustoNamingElement(that.custoNamingsArray, currSelectedOpt[0].value);
                                    prefixPopOver.setBody(ParamSkeletonNLS.EmptyPrefixForbidden + " (" + ParamSkeletonNLS.DefaultPrefixValueOfType + " " + cNamingElt.defprefix + ")");
                                    // if (prefixPopOver.isVisible) {
                                    //     setTimeout(function () {prefixPopOver.hide(); }, 3000);
                                    // }
                                } else {
                                    prefixPopOver.setBody(ParamSkeletonNLS.EmptyPrefixForbidden);
                                    prefixPopOver.hide();
                                }
                                that.testOnlineIdInput('prefixInput');
                            }, 20);
                        }
                    }
                }).inject(controlObjectCell);
                preFixTooltipCell = UWA.createElement('td', {
                    'width' : '40%',
                    'title' : '',
                    'id' : 'nameDeployxxxIndicator',
                    align : 'left'
                }).inject(lineParam);
                prefixImgInfoSpan = UWA.createElement('span', {
                    'class' : 'fonticon fonticon-info'
                }).inject(preFixTooltipCell);

                prefixImgInfoSpan.setStyle("color", "black");
                prefixPopOver = new Popover({
                    target   : prefixImgInfoSpan,
                    trigger  : "hover",
                    animate  : "true",
                    position : 'top',
                    body     : ParamSkeletonNLS.EmptyPrefixForbidden,//ZUR IR-620497-3DEXPERIENCER2019x
                    title    : ''
                });
                prefixField.getContent().setStyle("width", 300);
                prefixField.getContent().set("maxLength", 170);
                this.inputControls.push(prefixField);

                //4th line             
                lineParam = UWA.createElement('tr', {title: ''}).inject(ftbody);
                cellLabel = UWA.createElement('td', {'width': '30%', 'title': ''}).inject(lineParam);
                UWA.createElement('p', {text: ParamSkeletonNLS.Suffix, 'class': ''}).inject(cellLabel);

                controlObjectCell = UWA.createElement('td', {'width': '70%', 'colspan': '2', 'title': ''}).inject(lineParam);

                suffixField = new Text({
                    placeholder: "...",
                    attributes: {
                        id : 'suffixInput',
                        value: initSufftoShow,
                        multiline: false,
                        disabled: false
                    },
                    events: {
                        onKeyDown: function () {
                            if (timerconn) { clearTimeout(timerconn); }

                            timerconn = setTimeout(function() {
                                that.testOnlineIdInput('suffixInput');
                            }, 20);
                        }
                    }
                }).inject(controlObjectCell);
                suffixField.getContent().setStyle("width", 300);
                suffixField.getContent().set("maxLength", 170);
                this.inputControls.push(suffixField);

                //5th line : Affix Line
                //NZV - IR-529946-3DEXPERIENCER2017x/18x added tooltip to Affix Line
                lineParam = UWA.createElement('tr', {title: iFamilyToolTip}).inject(ftbody); //tableParameters       
                labelAffixcell = UWA.createElement('td', {'width': '30%', 'title': ''}).inject(lineParam);//'class':'',           
                UWA.createElement('p', {text: ParamSkeletonNLS.Interfix + ' (' + ParamSkeletonNLS.CommonParam + ') ', 'class': ''}).inject(labelAffixcell);

                controlObjectCell = UWA.createElement('td', {'width': '30%', 'title': ''}).inject(lineParam);

                affixField = new Text({
                    placeholder: "...",
                    attributes: {
                        id : 'sitenameinput',
                        value: affixvaluetoshow,
                        multiline: false,
                        disabled: false
                    },
                    events: {
                        onKeyDown: function () {
                            if (timerconn) { clearTimeout(timerconn); }
                            timerconn = setTimeout(function() {
                                that.testOnlineIdInput('sitenameinput');
                            }, 20);
                        }
                    }
                }).inject(controlObjectCell);
                tooltipCell = UWA.createElement('td', {
                    'width' : '40%',
                    'title' : '',
                    'id' : 'nameDeployxxxIndicator',
                    align : 'left'
                }).inject(lineParam);
                imgInfoSpan = UWA.createElement('span', {
                    'class' : 'fonticon fonticon-info'
                }).inject(tooltipCell);

                imgInfoSpan.setStyle("color", "black");
                popOver = new Popover({
                    target   : imgInfoSpan,
                    trigger  : "hover",
                    animate  : "true",
                    position : 'top',
                    body     : ParamSkeletonNLS.InterfixTooltip,
                    title    : ''
                });
                affixField.getContent().setStyle("width", 300);
                affixField.getContent().set("maxLength", 200);
                this.inputControls.push(affixField);

                //5th line bis : character selector  
                lineParam = UWA.createElement('tr', {title: ''}).inject(ftbody);//tableParameters

                labelSepcell = UWA.createElement('td', {'width': '30%', 'title': ''}).inject(lineParam);//'class':'',
                UWA.createElement('p', {text: ParamSkeletonNLS.Separator + ' (' + ParamSkeletonNLS.CommonParam + ') ', 'class': ''}).inject(labelSepcell);
                controlObjectCell = UWA.createElement('td', {'width': '70%', 'colspan': '2', 'title': ''}).inject(lineParam);

                sepControler = new Select({
                    placeholder: false,
                    nativeSelect: true,
                    attributes: {
                        id : 'selectSeparator',
                        disabled: false
                    }
                });
                sepControler.getContent().setStyle("width", 300);

                for (i = 0; i < nbofValuesForArg; i++) {
                    isSelected = false;

                    if (optionsSepArray[i].id == separatorValue) {
                        isSelected = true;
                    }
                    sepControler.add([{
                        label: optionsSepArray[i].nlsKey,//iArgument.value[i].nlsKey,   
                        value: optionsSepArray[i].id,//iArgument.value[i].id,     
                        selected: isSelected
                    }], false);
                }
                sepControler.inject(controlObjectCell);

                sepControler.addEvent("onChange", function () {
                    that.testOnlineIdInput("sitenameinput");
                });

                this.inputControls.push(sepControler);

                /*//Intermediary Line           
                UWA.createElement('tr',{html:  [{ tag: 'th', colspan: 3, html:"<br/><br/>" }] }).inject(ftbody);*/

                //Injecting the preview Input
                if (initSufftoShow === "") {
                    initialPreview = initPreftoShow + separatorValue + affixvaluetoshow + separatorValue + '<' + ParamSkeletonNLS.Counter + '>';
                } else {
                    initialPreview = initPreftoShow + separatorValue + affixvaluetoshow + separatorValue + '<' + ParamSkeletonNLS.Counter + '>' + separatorValue + initSufftoShow;
                }//NZV - IR-559116-3DEXPERIENCER2018x

                finalformatinput = new Text({
                    placeholder: "...",
                    attributes: {
                        id : 'finalformat',
                        value: initialPreview,
                        multiline: false,
                        disabled: false,
                        readonly: true,
                        title : initialPreview
                    }
                }).inject(controlObjectCellPreview);
                finalformatinput.getContent().setStyle("width", 360);
                this.inputControls.push(finalformatinput);

                if (wdgDeployIndicator == false) {
                    iconColor = "orange";
                    imgTitle = ParamSkeletonNLS.notdeployedParamtxt;
                    imgClass = 'fonticon fonticon-2x fonticon-cog';
                    //CommonUtilities.dispatchNeedDeployEvt(paramWidget);
                }
                imgSpan = UWA.createElement('span', {
                    'class' :  imgClass
                }).inject(imgCell);
                imgSpan.setStyle("color", iconColor);
                imgCell.set("Title", imgTitle);

                this.warnArrays[0] = new WarningLabel("sitenameinput", false);
                this.warnArrays[1] = new WarningLabel("prefixInput", false);
                this.warnArrays[2] = new WarningLabel("suffixInput", false);
            },

            selectedTypeChanged : function (iInput) {
                var cNamingElt, nInput, affixInput, separatorSelector,
                    typeSelector = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "iTypeSelect"),
                    currSelectedOpt = typeSelector.getSelection(),
                    selectedTypeLabel = currSelectedOpt[0].label;

                cNamingElt = ParamLayoutUtilities.getCustoNamingElement(this.custoNamingsArray, currSelectedOpt[0].value);
                nInput = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "prefixInput");
                nInput.setValue(cNamingElt.prefix);
                nInput = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "suffixInput");
                nInput.setValue(cNamingElt.suffix);

                affixInput = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "sitenameinput");
                separatorSelector = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "selectSeparator");
                currSelectedOpt = separatorSelector.getSelection();

                ParamLayoutUtilities.UpdateFinalFormatOverView(cNamingElt.prefix, affixInput.getValue(), cNamingElt.suffix, currSelectedOpt[0].value,
                                                               cNamingElt.appType,
                                                                ParamLayoutUtilities.getNamingControlInput(this.inputControls, "finalformat"));
                typeSelector.elements.input.title = selectedTypeLabel;
            },

            testOnlineIdInput : function(inputID) {
                var i, iID, iAffixID, iWrn, imgCell, currSelectedOpt, currSelectedSepOpt, controlupdate, cSeparator, cNamingElt, selectedTypeLabel,
                    typeSelector = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "iTypeSelect"),
                    separatorSelector = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "selectSeparator"),
                    inputToTest =  ParamLayoutUtilities.getNamingControlInput(this.inputControls, inputID),//"sitenameinput"
                    inputValue = inputToTest.getValue(),
                    containsInternalTypeName = false,
                    containSpecialchars = false,
                    errInputMsg = ParamSkeletonNLS.SpecialCharMsg,
                    applyBttnPtr = this.controlDiv.getElements('.btn-primary')[0],
                    tbodyreflist = this.contentDiv.getElements('.fparamtbody'), 
                    prefixElm = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "prefixInput"),
                    suffixElm = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "suffixInput"),
                    affixElm = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "sitenameinput");

                imgCell = ParamLayoutUtilities.getNamingDeployCellSts(tbodyreflist);//"nameDeployIndicator"
                ParamLayoutUtilities.beingModified(imgCell, ParamSkeletonNLS.ParamBeingModified, '2');

                for (i = 0; i < this.warnArrays.length; i++) {
                    if (this.warnArrays[i].warnID === inputID) {
                        iWrn = i;
                        break;
                    }
                }
                containSpecialchars = ParamLayoutUtilities.testSpecialCharacters(inputValue);
                if ((inputID === "prefixInput") || (inputID === "suffixInput")) {
                    containsInternalTypeName = this.testInputForTypeIds(inputValue);
                }
                //NZV-IR-600551-3DEXPERIENCER2019x
                if ((containSpecialchars === true) || (containsInternalTypeName === true) ||
                        (inputValue === "" && (inputID === "prefixInput" || inputID === "sitenameinput"))) {
                    if ((ParamLayoutUtilities.testSpecialCharacters(inputValue) === true) || (containsInternalTypeName === true) ||
                            (inputValue === "" && inputID === "prefixInput")) {
                        applyBttnPtr.disabled = true;
                        typeSelector.elements.input.disabled = true;
                        separatorSelector.elements.input.disabled = true;
                        //block all except it
                        if (inputID === "prefixInput") {
                            suffixElm.elements.input.disabled = true;
                            affixElm.elements.input.disabled = true;
                        }
                        if (inputID === "suffixInput" && containSpecialchars === true) {
                            prefixElm.elements.input.disabled = true;
                            affixElm.elements.input.disabled = true;
                        }
                        if (inputID === "sitenameinput") {
                            prefixElm.elements.input.disabled = true;
                            suffixElm.elements.input.disabled = true;
                        }
                        if (inputValue === "" && inputID === "prefixInput") {
                            currSelectedOpt = typeSelector.getSelection();
                            cNamingElt = ParamLayoutUtilities.getCustoNamingElement(this.custoNamingsArray, currSelectedOpt[0].value);
                            errInputMsg = ParamSkeletonNLS.EmptyPrefixForbidden + " (" + ParamSkeletonNLS.DefaultPrefixValueOfType + " " + cNamingElt.defprefix + ")";
                        }
                        if (containsInternalTypeName === true) {
                            inputToTest.elements.input.style.color = 'red';
                            errInputMsg = ParamSkeletonNLS.typesForbiddenMessage;
                        }
                        if (containSpecialchars === true) {
                            inputToTest.elements.input.style.color = 'red';
                            errInputMsg = ParamSkeletonNLS.SpecialCharMsg;
                        }
                        this.ErrorMsgPopup = ParamLayoutUtilities.inputErrorCell(imgCell, errInputMsg, 'red', this.ErrorMsgPopup);
                        this.warnArrays[iWrn].warnRaised = true;
                    }
                    if (inputValue === "" && inputID === "sitenameinput") {
                        errInputMsg = ParamSkeletonNLS.InterfixTooltip;
                        this.ErrorMsgPopup = ParamLayoutUtilities.inputErrorCell(imgCell, errInputMsg, 'orange', this.ErrorMsgPopup);
                        typeSelector.elements.input.disabled = false;
                        separatorSelector.elements.input.disabled = false;
                        applyBttnPtr.disabled = false;
                        prefixElm.elements.input.disabled = false;
                        suffixElm.elements.input.disabled = false;
                    }
                    //IR-685759-3DEXPERIENCER2019x\20x : updating Preview even in case error or warning 
                    currSelectedOpt = typeSelector.getSelection();
                    cNamingElt = ParamLayoutUtilities.getCustoNamingElement(this.custoNamingsArray, currSelectedOpt[0].value);
                    ParamLayoutUtilities.UpdateFinalFormatOverView(cNamingElt.prefix, affixElm.getValue(), cNamingElt.suffix,
                                                                  (separatorSelector.getSelection())[0].value, cNamingElt.appType,
                                                                   ParamLayoutUtilities.getNamingControlInput(this.inputControls, "finalformat"));
                    inputToTest.focus();
                } else {
                    this.warnArrays[iWrn].warnRaised = false;
                    controlupdate = ParamLayoutUtilities.getNamingControlInput(this.inputControls, this.warnArrays[iWrn].warnID);
                    controlupdate.elements.input.style.color = "#555555";//070E14 color: #555;

                    iAffixID = ParamLayoutUtilities.getCommonNamingElementItr(this.commonNamingElts, "IdentifierAffix");

                    if ("sitenameinput" ===  inputID) {
                        this.commonNamingElts[iAffixID].currentValue = inputValue;
                    } else {
                        currSelectedOpt = typeSelector.getSelection();
                        iID = ParamLayoutUtilities.getIndexInNamingArray(this.custoNamingsArray, currSelectedOpt[0].value);

                        if (inputID === "prefixInput") {
                            this.custoNamingsArray[iID].prefix = inputValue;
                        } else if (inputID === "suffixInput") {
                            this.custoNamingsArray[iID].suffix = inputValue;
                        }
                    }

                    currSelectedSepOpt = separatorSelector.getSelection();
                    cSeparator = currSelectedSepOpt[0].value;

                    currSelectedOpt = typeSelector.getSelection();
                    selectedTypeLabel = currSelectedOpt[0].label;
                    cNamingElt = ParamLayoutUtilities.getCustoNamingElement(this.custoNamingsArray, currSelectedOpt[0].value);

                    ParamLayoutUtilities.UpdateFinalFormatOverView(cNamingElt.prefix, affixElm.getValue(), suffixElm.getValue(),
                                                                   cSeparator, cNamingElt.appType,
                                                                   ParamLayoutUtilities.getNamingControlInput(this.inputControls, "finalformat"));

                    if (ParamLayoutUtilities.CheckforRaisedWarnings(this.warnArrays) === "OK") {
                        if (this.ErrorMsgPopup  != null) {
                            if (this.ErrorMsgPopup.isVisible) {this.ErrorMsgPopup.hide(); }
                        }
                        ParamLayoutUtilities.beingModified(imgCell, ParamSkeletonNLS.ParamBeingModified, '2');

                        for (i = 0; i < this.warnArrays.length; i++) {
                            controlupdate = ParamLayoutUtilities.getNamingControlInput(this.inputControls, this.warnArrays[i].warnID);
                            controlupdate.elements.input.style.color = "#555555";//070E14 color: #555;
                        }

                        typeSelector.elements.input.disabled = false;
                        separatorSelector.elements.input.disabled = false;
                        applyBttnPtr.disabled = false;
                        prefixElm.elements.input.disabled = false;
                        suffixElm.elements.input.disabled = false;
                        affixElm.elements.input.disabled = false;

                        /*if (tSiteName == "")//IR-207199V6R2014 {
                            //document.getElementById("labelwarning").innerHTML="<affixDefineTooltip>";} else */
                    }
                }

            },//of function testonlineinputname

            testInputForTypeIds : function (iInputString) {
                var i,
                    typeSelector = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "iTypeSelect"),
                    currSelectedOpt = typeSelector.getSelection(),
                    currNamingElt = ParamLayoutUtilities.getCustoNamingElement(this.custoNamingsArray, currSelectedOpt[0].value),
                    currAppType = currNamingElt.appType;

                if (currAppType === "VPM") {
                    for (i = 0; i < this.forbiddenNamings.length; i++) {
                        if (iInputString.indexOf(this.forbiddenNamings[i]) !== -1) {
                            return true;
                        }
                    }
                }
                return false;
            },

            UpdateCommonParamsOnServer : function () {
                var iParam, imgCell,
                    jsonArr = [],
                    ArgArr = [],
                    affixInput = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "sitenameinput"),
                    separatorSelector = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "selectSeparator"),
                    currSelectedOpt = separatorSelector.getSelection(),
                    separatorVal = currSelectedOpt[0].value,
                    AffixValue = affixInput.getValue(),
                    tbodyreflist = this.contentDiv.getElements('.fparamtbody');

                if (AffixValue === "") { AffixValue = "TBD"; }

                Mask.mask(this.contentDiv);

                ArgArr.push({id: "AffixArg", value: AffixValue});
                ArgArr.push({id: "SeparatorArg", value: separatorVal});

                iParam = {
                    domain: this.model.get("domainid"),
                    id: "IdentifierAffix",
                    argument : ArgArr
                };

                imgCell = ParamLayoutUtilities.getNamingDeployCellSts(tbodyreflist);

                jsonArr.push(iParam);
                /*var func2 = func1.bind(this); func2(params);*/
                ParameterizationWebServices.postParamsArrOnServer.call(this, this.connectProps, jsonArr, imgCell,
                    this.onApplyFailure.bind(this), this.postNamingParams.bind(this));
            },//of function UpdateCommonParamsOnServer

            postNamingParams : function(json, theImageCell) {
                UWA.log("postNamingParams");

                var i, ArgArr, iParam,
                    jsonArr = [];

                for (i = 0; i < this.custoNamingsArray.length; i++) {
                    ArgArr = [];
                    ArgArr.push({id: "PrefixArg", value: this.custoNamingsArray[i].prefix});
                    ArgArr.push({id: "SuffixArg", value: this.custoNamingsArray[i].suffix});

                    iParam = {
                        domain : this.model.get("domainid"),
                        id : this.custoNamingsArray[i].objTypeID,
                        argument : ArgArr
                    };
                    jsonArr.push(iParam);
                }

                ParameterizationWebServices.postParamsArrOnServer.call(this, this.connectProps, jsonArr, theImageCell,
                    this.onApplyFailure.bind(this), this.onApplySuccess.bind(this));
            },

            ResetNamingParams : function() {
                var i, iID, imgCell, tbodyreflist, affixInput, sepControler, optionValue, prefixElm,
                    suffixElm, affixElm, typeSelector, separatorSelector, applyBttnPtr;

                iID = ParamLayoutUtilities.getCommonNamingElementItr(this.commonNamingElts, "IdentifierAffix");
                this.commonNamingElts[iID].currentValue = URLHandler.getTenant();//this.commonNamingElts[iID].defaultValue;
                iID = ParamLayoutUtilities.getCommonNamingElementItr(this.commonNamingElts, "SeparatorArg");
                this.commonNamingElts[iID].currentValue = this.commonNamingElts[iID].defaultValue;

                affixInput = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "sitenameinput");
                affixInput.setValue(URLHandler.getTenant());//this.connectProps.tenantID affixContainer.defaultValue;

                sepControler = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "selectSeparator");

                for (i = 0; i < sepControler.elements.input.length; i++) {
                    optionValue = sepControler.elements.input[i].value;

                    if (optionValue == this.commonNamingElts[iID].defaultValue) {
                        sepControler.select(i, true, false);
                        break;
                    }
                }//of for elements
                //clear warning array 
                //NZV-IR-600551-3DEXPERIENCER2019x
                for (i = 0; i < this.warnArrays.length; i++) {
                    this.warnArrays[i].warnRaised = false;
                }
                 //enable all inputs 
                prefixElm = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "prefixInput");
                suffixElm = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "suffixInput");
                affixElm = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "sitenameinput");
                typeSelector = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "iTypeSelect");
                separatorSelector = ParamLayoutUtilities.getNamingControlInput(this.inputControls, "selectSeparator");
                applyBttnPtr = this.controlDiv.getElements('.btn-primary')[0];
                typeSelector.elements.input.disabled = false;
                separatorSelector.elements.input.disabled = false;
                applyBttnPtr.disabled = false;
                prefixElm.elements.input.disabled = false;
                suffixElm.elements.input.disabled = false;
                affixElm.elements.input.disabled = false;
                //Prefixes and Suffixes
                for (i = 0; i < this.custoNamingsArray.length; i++) {
                    this.custoNamingsArray[i].prefix = this.custoNamingsArray[i].defprefix;
                    this.custoNamingsArray[i].suffix = this.custoNamingsArray[i].defsuffix;
                }

                this.selectedTypeChanged();//Updating View

                tbodyreflist = this.contentDiv.getElements('.fparamtbody');
                imgCell = ParamLayoutUtilities.getNamingDeployCellSts(tbodyreflist);//Deploy Indicator  
                ParamLayoutUtilities.beingModified(imgCell, ParamSkeletonNLS.ParamBeingModified, '2');

                this.applyParams();
            },

            buildDeploymentTab : function () {
                var tableImport, deploytbody, iDeployAccordion, tableUtilities, globalDeplDiv,
                    lineExport, cellExportText, buttonExportCell, exportBttn, cellInfo,
                    lineImport, cellImportContainer, cellImportText, fileController,
                    importBttnCell, importBttnGrp,
                    lineDeployButton, ApplyBttnCell, ApplyBttn, cellDeployText, FamilyDeploySts, ParameterDeploySts,
                    indexLine, reloadCacheLine, exportCATNLSLine,
                    tablePropagAtt, propagAttLine,
                    dplWdthArr = [40, 10, 25, 25, 190], //NZV :here last value(190) of array is width of all buttons
                    that = this; //NZV:IR-628784-3DEXPERIENCER2019x			

                globalDeplDiv = ParamLayoutUtilities.createParamsContainerDiv();
                globalDeplDiv.inject(this.contentDiv);

                iDeployAccordion = ParamLayoutUtilities.createFamilyUIKITAccordion(globalDeplDiv);

                tableImport = UWA.createElement('table', {
                    'class': 'table table-hover',//'tableImportExport',    
                    'id': ''
                });

                deploytbody =  UWA.createElement('tbody', {
                    'class': 'fparamtbody',
                    'id': ''
                }).inject(tableImport);

                //intermediaryLine = ParamLayoutUtilities.buildSeparationLine('Import and Export Utilities');

                lineExport = UWA.createElement('tr').inject(deploytbody);

                cellExportText = UWA.createElement('td', {
                    //'colspan': '2',
                    'width': dplWdthArr[0].toString() + '%',
                    'align': 'left'
                }).inject(lineExport);

                UWA.createElement('p', {
                    text: ParamSkeletonNLS.ExportConfiguration,
                    'class': ''
                }).inject(cellExportText);

                cellInfo = UWA.createElement('td', {
                    'width': dplWdthArr[1].toString() + '%',
                    'align': 'left'
                }).inject(lineExport);

                ParamLayoutUtilities.buildPopoverSpan(cellInfo, ParamSkeletonNLS.ExportTooltip);

                UWA.createElement('td', {
                    'width': dplWdthArr[2].toString() + '%',
                    'align': 'left'
                }).inject(lineExport);

                buttonExportCell = UWA.createElement('td', {
                    'width'  :  dplWdthArr[3].toString() + '%'
                }).inject(lineExport);

                exportBttn =  new Button({
                    className: 'primary',
                    id : 'buttonExport',
                    icon: 'export',//'download'//value: 'Button',               
                    attributes: {
                        disabled: false,
                        //title: ParamSkeletonNLS.ExportTxt,
                        text : ParamSkeletonNLS.ExportTxt
                    },
                    events: {
                        onClick: function () {
                            that.launchFilesExport("Parameterization_Export");
                        }
                    }
                }).inject(buttonExportCell);
                exportBttn.getContent().setStyle("width", dplWdthArr[4]);

                lineImport = UWA.createElement('tr').inject(deploytbody);//tbody      

                cellImportText = UWA.createElement('td', {
                    'width': dplWdthArr[0].toString() + '%',
                    'align': 'left'
                }).inject(lineImport);

                UWA.createElement('p', {
                    text: ParamSkeletonNLS.SelectImportFile,
                    'class': ''
                }).inject(cellImportText);

                cellInfo = UWA.createElement('td', {
                    'width': dplWdthArr[1].toString() + '%',
                    'align': 'left'
                }).inject(lineImport);

                ParamLayoutUtilities.buildPopoverSpan(cellInfo, ParamSkeletonNLS.ImportFileTooltip);

                cellImportContainer = UWA.createElement('td', {
                    'width': dplWdthArr[2].toString() + '%',
                    'align': 'left',
                    'title': ''
                });

                fileController = new UWA.Controls.Input.File({
                    attributes: {
                        'id': 'ImportFileInput'
                    },
                    className: 'xml-file-input'
                }).inject(cellImportContainer);

                fileController.getContent().setStyle("width", 250);

                importBttnCell = UWA.createElement('td', {
                    'width': dplWdthArr[3].toString() + '%',
                    'align': 'left'
                });

                importBttnGrp = new Button({
                    value: ParamSkeletonNLS.ImportBttnTxt,
                    className: 'primary',
                    icon: 'fonticon-upload',
                    attributes: {
                        title: ParamSkeletonNLS.ImportFile
                    },
                    dropdown: {
                        items: [
                            { text: ParamSkeletonNLS.ImportBttnTxt, name : 'Import', title : ParamSkeletonNLS.ImportNoApplytooltip },
                            { text: ParamSkeletonNLS.ImportAndApply, name : 'importNdeploy', title : ParamSkeletonNLS.ImportApplytooltip }
                        ]
                    }
                }).inject(importBttnCell);

                importBttnGrp.addEvent('onDropdownClick', function (e, item) {
                    that.onXMLFileSelected(item.name);
                });

                importBttnGrp.getContent().setStyle("width", dplWdthArr[4]);

                /*cellSpinnerContainer = UWA.createElement('td', {
                    'width': dplWdthArr[3].toString() + '%',
                    'align': 'center',
                    'title': ''
                });*/

                //cellImportText.inject(lineImport);
                cellImportContainer.inject(lineImport);
                importBttnCell.inject(lineImport);
                lineImport.inject(deploytbody);

                FamilyDeploySts = this.collection._models[0]._attributes.family;
                ParameterDeploySts = FamilyDeploySts[0].parameter;

                lineDeployButton = UWA.createElement('tr');

                if (ParameterDeploySts[0].isDeployed == "true") {
                    lineDeployButton.hide();
                }

                cellDeployText = UWA.createElement('td', {
                    'width': dplWdthArr[0].toString() + '%',
                    'align': 'left'
                    //'title': ParamSkeletonNLS.ApplyNonDeployed
                }).inject(lineDeployButton);

                UWA.createElement('p', {
                    text: ParamSkeletonNLS.ApplyNonDeployed,
                    'class': ''
                }).inject(cellDeployText);

                cellInfo = UWA.createElement('td', {
                    'width': dplWdthArr[1].toString() + '%',
                    'align': 'left'
                }).inject(lineDeployButton);

                ParamLayoutUtilities.buildPopoverSpan(cellInfo, ParamSkeletonNLS.ApplyNonDeployed);

                UWA.createElement('td', {
                    'width': dplWdthArr[2].toString() + '%',
                    'align': 'left'
                }).inject(lineDeployButton);

                ApplyBttnCell = UWA.createElement('td', {
                    //'colspan': '2',
                    'width': dplWdthArr[3].toString() + '%',
                    'align': 'left',
                    'title': ''
                }).inject(lineDeployButton);

                ApplyBttn = new Button({
                    id : 'buttonImport',
                    className: 'primary',
                    icon: 'fonticon-forward',
                    value: ParamSkeletonNLS.Apply,
                    attributes: {
                        //title: ParamSkeletonNLS.Apply,
                        text : ParamSkeletonNLS.Apply
                    },
                    events: {
                        onClick: function () {
                            Mask.mask(that.contentDiv);
                            ParameterizationWebServices.deployParamsOnServer.call(that,
                                that.onDeployFailure.bind(that), that.onDeploySuccess.bind(that));
                        }
                    }
                }).inject(ApplyBttnCell);

                ApplyBttn.getContent().setStyle("width", dplWdthArr[4]);
                lineDeployButton.inject(deploytbody);

                iDeployAccordion.addItem({
                    title: ParamSkeletonNLS.ImportExportConfigTxt,
                    content: tableImport,
                    selected : true,
                    name : 'ImpExpid'
                });

                tableUtilities = UWA.createElement('table', {
                    'class': 'table table-hover',//'tableImportExport',    
                    'id': ''
                });

                deploytbody =  UWA.createElement('tbody', {
                    'class': 'fparamtbody',
                    'id': ''
                }).inject(tableUtilities);

                /*intermediaryLine = ParamLayoutUtilities.buildSeparationLine(ParamSkeletonNLS.DeploymentUtilitiesTxt);*/

                indexLine = this.buildIndexationLine(dplWdthArr);
                indexLine.inject(deploytbody);

                reloadCacheLine = this.buildReloadCacheLine(dplWdthArr);
                reloadCacheLine.inject(deploytbody);

                exportCATNLSLine = this.buildExportLine(dplWdthArr, 'ParameterizationCATNls',
                    ParamSkeletonNLS.DownloadTxt, ParamSkeletonNLS.DownloadTooltip,
                    ParamSkeletonNLS.DownloadCATNLSTxt);

                exportCATNLSLine.inject(deploytbody);

                iDeployAccordion.addItem({
                    title: ParamSkeletonNLS.DeploymentUtilitiesTxt,
                    content: tableUtilities,
                    selected : true,
                    name : 'Utilitiesid'
                });

                tablePropagAtt = UWA.createElement('table', {
                    'class': 'table table-hover',//table deployment auto ext
                    'id': 'PropagAtt'
                });

                deploytbody =  UWA.createElement('tbody', {
                    'class': 'fparamtbody',
                    'id': ''
                }).inject(tablePropagAtt);

                propagAttLine = PropagLayoutUtilities.buildPropagAttLine(dplWdthArr, this);
                propagAttLine.inject(deploytbody);

                iDeployAccordion.addItem({
                    title: ParamSkeletonNLS.PropagationTitle,
                    content: tablePropagAtt,
                    selected : false,
                    name : 'PropagAttid'
                });

                this.paramScroller = new Scroller({
                    element: globalDeplDiv
                }).inject(this.contentDiv);

            },

            onXMLFileSelected : function (currAction) {
                //console.log(' File {0} has been selected', this._ FilePath); //fileobject as entry 
                var fileInput = document.getElementById('ImportFileInput');
                if (fileInput.files.length === 1) {
                    this.launchImportProcess(fileInput.files[0], currAction);
                } else {
                    this.userMessaging.add({ className: "warning", message: ParamSkeletonNLS.NotSelectedMsg });
                }
            },

            buildIndexationLine : function (wdthArray) {
                var buttonIndexCell, cellExportText, cellInfo, indexBttn,
                    indexLine = UWA.createElement('tr'),
                    that = this;

                cellExportText = UWA.createElement('td', {
                    //'colspan': '2',
                    'width': wdthArray[0].toString() + '%',
                    'align': 'left'
                }).inject(indexLine);

                UWA.createElement('p', {
                    text: ParamSkeletonNLS.IndexationTxt,
                    'class': ''
                }).inject(cellExportText);

                cellInfo = UWA.createElement('td', {
                    'width': wdthArray[1].toString() + '%',
                    'align': 'left'
                }).inject(indexLine);

                ParamLayoutUtilities.buildPopoverSpan(cellInfo, ParamSkeletonNLS.IndexationTooltip);

                UWA.createElement('td', {
                    'width': wdthArray[2].toString() + '%',
                    'align': 'left'
                }).inject(indexLine);

                buttonIndexCell = UWA.createElement('td', {
                    'width'  : wdthArray[3].toString() + '%'
                }).inject(indexLine);

                indexBttn =  new Button({
                    className: 'primary',
                    id : 'buttonIndex',
                    icon: 'archive',
                    attributes: {
                        disabled: false,
                       // title: ParamSkeletonNLS.IndexationBtnTxt,
                        text : ParamSkeletonNLS.IndexationBtnTxt
                    },
                    events: {
                        onClick: function () {
                            ParameterizationWebServices.launchServiceOnServer.call(that, 'datamodel/launchIndex',
                                that.onIndexLaunchFailure.bind(that), that.onIndexLaunchSuccess.bind(that));
                            that.userDeployMessaging.add({ className: "info", message: ParamSkeletonNLS.IndexationInfo});
                        }
                    }
                }).inject(buttonIndexCell);
                indexBttn.getContent().setStyle("width", wdthArray[4]);

                return indexLine;
            },

            buildReloadCacheLine : function (wdthArray) {
                var buttonCacheCell, cellInfo, cellCacheText, relCacheBttn,
                    reloadCacheLine = UWA.createElement('tr'),
                    that = this;

                cellCacheText = UWA.createElement('td', {
                    'width': wdthArray[0].toString() + '%',
                    'align': 'left',
                    'title': ''
                }).inject(reloadCacheLine);

                UWA.createElement('p', {
                    text: ParamSkeletonNLS.ReloadCacheTxt,
                    'class': ''
                }).inject(cellCacheText);

                cellInfo = UWA.createElement('td', {
                    'width': wdthArray[1].toString() + '%',
                    'align': 'left'
                }).inject(reloadCacheLine);

                ParamLayoutUtilities.buildPopoverSpan(cellInfo, ParamSkeletonNLS.ReloadCacheTooltip);

                UWA.createElement('td', {
                    'width': wdthArray[2].toString() + '%',
                    'align': 'left'
                }).inject(reloadCacheLine);

                buttonCacheCell = UWA.createElement('td', {
                    'width'  : wdthArray[3].toString() + '%'
                }).inject(reloadCacheLine);

                relCacheBttn =  new Button({
                    className: 'primary',
                    id : 'buttonReloadCache',
                    icon: 'picture',
                    attributes: {
                        disabled: false,
                        //title: ParamSkeletonNLS.ReloadCacheBttn,
                        text : ParamSkeletonNLS.ReloadCacheBttn
                    },
                    events: {
                        onClick: function () {
                            ParameterizationWebServices.launchServiceOnServer.call(that, 'access/reloadcache',
                                that.onReloadCacheSuccess.bind(that), that.onReloadCacheFailure.bind(that));
                            Mask.mask(that.contentDiv);
                            //that.userDeployMessaging.add({ className: "info", message: ''});
                        }
                    }
                }).inject(buttonCacheCell);
                relCacheBttn.getContent().setStyle("width", wdthArray[4]);

                return reloadCacheLine;
            },

            buildExportLine : function (dplWdthArr, iFileID, exportBtntext, exportBtnTooltip, exportCellText) {

                var cellExportText, exportBttn, buttonExportCell, cellInfo,
                    lineExport = UWA.createElement('tr'),
                    that = this;

                cellExportText = UWA.createElement('td', {
                    //'colspan': '2',
                    'width': dplWdthArr[0].toString() + '%',
                    'align': 'left',
                    'title': exportCellText
                }).inject(lineExport);

                UWA.createElement('p', {
                    text: exportCellText,
                    'class': ''
                }).inject(cellExportText);

                cellInfo = UWA.createElement('td', {
                    'width': dplWdthArr[1].toString() + '%',
                    'align': 'left'
                }).inject(lineExport);

                ParamLayoutUtilities.buildPopoverSpan(cellInfo, exportBtnTooltip);

                UWA.createElement('td', {
                    'width': dplWdthArr[2].toString() + '%',
                    'align': 'left'
                }).inject(lineExport);

                buttonExportCell = UWA.createElement('td', {
                    'width'  : dplWdthArr[3].toString() + '%'
                }).inject(lineExport);

                exportBttn =  new Button({
                    className: 'primary',
                    id : 'buttonExport' + iFileID,
                    icon: 'export',//'download'//value: 'Button',               
                    attributes: {
                        disabled: false,
                       // title: exportBtntext,
                        text : exportBtntext
                    },
                    events: {
                        onClick: function () {
                            that.launchFilesExport(iFileID);
                        }
                    }
                }).inject(buttonExportCell);
                exportBttn.getContent().setStyle("width", dplWdthArr[4]);

                return lineExport;
            },

            onIndexLaunchFailure : function (iRes) {
                UWA.log("Failure");
                UWA.log(iRes);
            },

            onIndexLaunchSuccess : function (iRes) {
                UWA.log("Success");
                UWA.log(iRes);
            },

            onReloadCacheFailure : function (iRes) {
                UWA.log("timeout");
                Mask.unmask(this.contentDiv);
                this.userDeployMessaging.add({ className: "info", message: ParamSkeletonNLS.ReloadCacheTimeout});
                UWA.log(iRes);
            },

            onReloadCacheSuccess : function (iRes) {
                UWA.log("onReloadCacheSuccess::");
                Mask.unmask(this.contentDiv);
                this.userMessaging.add({ className: "success", message: ParamSkeletonNLS.ReloadCacheSuccessMsg});
                UWA.log(iRes);
            },


            launchImportProcess : function (File, iAction) {
                var reader, importerrmsg, unabletoreadfile,
                    textType = /text.*/,
                    that = this;
                UWA.log("File.type = " + File.type);

                if (File.type.match(textType)) {
                    Mask.mask(this.contentDiv);
                    reader = new FileReader();
                    reader.onload = function(e) {
                        ParameterizationWebServices.ImportParamToServer.call(that, reader.result, iAction,
                            that.importFailure.bind(that), that.importSuccess.bind(that));
                    };
                    reader.readAsText(File);//DEACTIVATE ??

                    reader.onerror = function() {
                        unabletoreadfile = ParamSkeletonNLS.UnabletoReadMsg + ' ' + File.fileName;
                        that.userMessaging.add({ className: "error", message: unabletoreadfile });
                        Mask.unmask(this.contentDiv);
                    };
                    reader.onloadend = function() {
                        UWA.log("onloadend !!");//need to do something ?
                    };
                } else {
                    importerrmsg = ParamSkeletonNLS.NotAnXMLMsg;
                    that.userMessaging.add({ className: "error", message: importerrmsg }); //File not supported!
                    Mask.unmask(this.contentDiv);
                }
            },

            importFailure : function (json) {
                UWA.log("import Failure !!!");
                UWA.log(json);
                Mask.unmask(this.contentDiv);
                this.userMessaging.add({ className: "error", message: ParamSkeletonNLS.ImportFailureMsg });
            },

            importSuccess : function (json, iAction) {
                UWA.log(json);
                Mask.unmask(this.contentDiv);
                var jsParsed = JSON.parse(json);
                /* globalParamWidget.socket.dispatchEvent('onPlatformChange', {selectedTenant:globalParamWidget.tenantID,
                url3DSpace: globalParamWidget.env_url});*/

                if (jsParsed.deployStatus === "S_OK") {
                    this.userMessaging.add({ className: "success", message: ParamSkeletonNLS.ImportSuccessMsg});
                    if ("importNdeploy" === iAction) {
                        this.hideApplylines();
                    } else {
                        this.showApplylines();
                    }
                } else {
                    this.importFailure();
                }
            },

            onDeployFailure : function (json) {
                UWA.log(json);
                this.userMessaging.add({ className: "error", message: ParamSkeletonNLS.ParametersDeplFail });
                Mask.unmask(this.contentDiv);
            },

            onDeploySuccess : function (jsonObj) {
                UWA.log(jsonObj);
                Mask.unmask(this.contentDiv);
                /* globalParamWidget.socket.dispatchEvent('onPlatformChange', {selectedTenant:globalParamWidget.tenantID,
                        url3DSpace:globalParamWidget.env_url});*/
                if (jsonObj.deployStatus === "S_OK") {
                    this.hideApplylines();
                    this.userMessaging.add({ className: "success", message: ParamSkeletonNLS.ParametersDeplSucc});
                } else {
                    this.onDeployFailure(jsonObj);
                }
            },

            hideApplylines : function () {
                var tbodyreflist = this.contentDiv.getElements('.fparamtbody'),
                    tbodyref = tbodyreflist[0],
                    iLines = tbodyref.children;

                iLines[2].hide();
            },

            showApplylines : function () {
                var tbodyreflist = this.contentDiv.getElements('.fparamtbody'),
                    tbodyref = tbodyreflist[0],
                    iLines = tbodyref.children;

                iLines[2].show();
            },

            launchFilesExport : function (iFile) {
                Mask.mask(this.contentDiv);//"ParameterizationCATNls" "Parameterization_Export" 
                ParameterizationWebServices.GetTicketForDownload.call(this, iFile,
                    this.onCompleteRequestFCSTicket.bind(this), this.onFailureRequestFCSTicket.bind(this));
            },

            onCompleteRequestFCSTicket : function (responseObjectJson, iFileID) {
                UWA.log("We have our ticket ... Let's fly... Up, up here we go, go");
                this.postCallFCS(responseObjectJson);
				//NZV : IR-632818-3DEXPERIENCER2019x
                if (iFileID === "Parameterization_Export") {//IR-684310-3DEXPERIENCER2019x
                    this.userMessaging.add({ className: "info", message: ParamSkeletonNLS.ExportXMLWarning});
                }
			},

            onFailureRequestFCSTicket : function (resp, iFileID) {
                UWA.log("Failure to Get a F***** Ticket"+ resp);// Why?
                Mask.unmask(this.contentDiv);
                //IR-684310-3DEXPERIENCER2019x
                if (iFileID === "Parameterization_Export") {
                    this.userMessaging.add({ className: "error", message: ParamSkeletonNLS.ExportParamFail});
                } else {
                    this.userMessaging.add({ className: "error", message: ParamSkeletonNLS.DownloadParamFail});
                }
            },

            postCallFCS : function (responseObjectJson) {
                //Content-Disposition: attachment
                var form = UWA.createElement('form', {
                        'class': 'form-wrapper hidden',
                        action: responseObjectJson.fcsxmlurl,
                        method: 'POST',
                        enctype: 'application/x-www-form-urlencoded',
                        //target: Utils.detectOs() === 'ios' ||  Utils.detectOs() === 'macos' ? '_blank' : 'uploadFrame' + that.id, 
                        //target blank for ios download*
                        target: document.body,//'_blank'
                        //WARNING CHANGE target regarding to file
                        //target: '_blank',//new
                        html: [{
                            tag: 'input',
                            type: 'hidden',
                            name: '__fcs__jobTicket',
                            id: '__fcs__jobTicket',
                            value: responseObjectJson.fcsxmljobTicket
                        }]
                    });
                form.inject(this.contentDiv);//that.getBody()
                form.submit();
                Mask.unmask(this.contentDiv);

                setTimeout(function () {
                    form.remove();//Clean up    
                }, 5000);
            },

            confirmationModalShow : function () {
                var headertitle, OKBtn, CancelBtn,
                    bodyDiv,
                    that = this;

                if (this.resetModal !== null) {
                    this.resetModal.show();//Modal already exists
                } else {
                    headertitle = UWA.createElement('h4', {
                        text   : ParamSkeletonNLS.confirmResetTitle,
                        'class': 'font-3dslight' // font-3dsbold
                    });

                    OKBtn = new Button({
                        value : ParamSkeletonNLS.OKButton,
                        className : 'btn primary',
                        events : {
                            'onClick' : function() {
                                UWA.log("DoSomething");
                                that.resetAndDeloyParams();
                            }
                        }
                    });
                    CancelBtn = new Button({
                        value : ParamSkeletonNLS.CancelButton,
                        className : 'btn default',
                        events : {
                            'onClick' : function(e) {
                                UWA.log("Cancel");
                            }
                        }
                    });
                    bodyDiv = UWA.createElement('div', {
                        'id': 'resetContentDiv',
                        'width' : '100%',
                        'height': '100%'
                    });
                    UWA.createElement('p', {
                        text   :  ParamSkeletonNLS.confirmResetMsg,
                        'class': 'font-3dslight'// font-3dsbold
                    }).inject(bodyDiv);

                    this.resetModal = new Modal({
                        className: "reset-confirm-modal",
                        closable: true,
                        header: headertitle,
                        body:   bodyDiv,
                        footer: [ OKBtn, CancelBtn ]
                    }).inject(this.contentDiv);
                    this.resetModal.getContent().setStyle("padding-top", 1);
                    this.resetModal.show();

                    this.resetModal.getContent().getElements(".btn").forEach(function (element) {
                        element.addEvent("click", function () {
                            that.resetModal.hide();
                        });
                    });
                }
            },

            //Rb0afx
            resetAndDeloyParams : function () {
                Mask.mask(this.contentDiv);
                var i, j, datacell, dataStruct, tbodyref, iLines,
                    tbodyreflist = this.contentDiv.getElements('.fparamtbody'),
                    nboffamilies = tbodyreflist.length,
                    wasAParamModified = false,
                    wasmodified = true;

                if ("ObjectIdentifier" === this.model.get("familyid")) {
                    this.ResetNamingParams();
                } else {
                    for (i = 0; i < nboffamilies; i++) {
                        tbodyref = tbodyreflist[i];
                        iLines = tbodyref.children;
                        for (j = 0; j < iLines.length; j++) {
                            datacell = iLines[j].cells[2];
                            dataStruct = datacell.getData('argumentNode');
                            wasmodified = this.resetInput(dataStruct);

                            if (wasmodified) { wasAParamModified = true; }
                        }
                    }

                    if (!wasAParamModified) {//noparamReset, the current vals are basically the OOTB ones
                        Mask.unmask(this.contentDiv);
                        this.userMessaging.add({ className: "success", message: ParamSkeletonNLS.deploySuccessMsg});
                    }
                }//of else
            },

            //Rb0afx
            resetInput : function (idataStruct) {
                var j, optionValue, currSelectedOpt, currSelectedValue,
                    defaultvallist,
                    defaultval = idataStruct.defaultval,
                    paramID = idataStruct.paramid,
                    inputType = idataStruct.inputtype,
                    currSelectedList = [],
                    paramModified = true;

                this.inputControls.forEach(function (iInput) {
                    if (iInput.elements.input.id === paramID) {
                        if (inputType === "checkbox") {
                            if (defaultval == "Enabled") {
                                iInput.check();
                            } else {
                                iInput.uncheck();
                            }
                            iInput.dispatchEvent('onChange', this);//onClick
                        } else if (inputType === "combobox") {
                            if (paramID !== "VNaming_DevelopmentPart") {
                                currSelectedOpt = iInput.getSelection();
                                currSelectedValue = currSelectedOpt[0].value;
                                if (defaultval == currSelectedValue) {
                                    paramModified = false;
                                }
                                for (j = 0; j < iInput.elements.input.length; j++) {
                                    optionValue = iInput.elements.input[j].value;

                                    if (optionValue === defaultval) {
                                        iInput.select(j, true, false);
                                    }
                                }//of for elements
                            } else { //VNaming_DevelopmentPart
                                paramModified = false;
                            }
                        } else if (inputType === "comboboxmultiselect") {

                            currSelectedOpt = iInput.getSelection();
                            defaultvallist = null;
                            if (defaultval.indexOf(",")) {
                                defaultvallist = defaultval.split(",");
                            } else {
                                defaultvallist = [defaultval];
                            }

                            currSelectedOpt.forEach(function(item) {
                                currSelectedList.push(item.value);
                            });
                            //check if detaul value & selected value are same
                            if (ParamLayoutUtilities.compareArray(defaultvallist, currSelectedList)) {
                                paramModified = false;
                            }
                            if (paramModified) {
                                //clear user selection
                                iInput.clear(true);
                                for (j = 0; j < iInput.elements.input.length; j++) {
                                    optionValue = iInput.elements.input[j].value;

                                    defaultvallist.forEach(function (item) {
                                        if (optionValue === item) {
                                            iInput.select(j, true, true);
                                        }
                                    });
                                }//for loop
                                iInput.dispatchEvent('onChange');
                            }
                         // comboboxmultiselect
                        } else {
                            //textfield
                            iInput.setValue(defaultval);
                            paramModified = true;
                            iInput.dispatchEvent('onChange');
                        }
                    }
                });
                return paramModified;
            },

            checkParameterValueOnChange : function (inputElement, ctrlObjectCell, imageCell) {
                var errorMsg, dataStruct, datatype,
                    inputVal = inputElement.getValue();

                dataStruct = ctrlObjectCell.getData('argumentNode');
                datatype = dataStruct.argtype;

                if (ParamLayoutUtilities.testDataType(inputVal, datatype)) {
                    //All is good Send the POST Request  
                    this.updateParameterOnChange(inputVal, ctrlObjectCell, imageCell);
                } else {
                    errorMsg = ParamLayoutUtilities.getTypeErrorMsgNLS(datatype);
                    this.ErrorMsgPopup = ParamLayoutUtilities.inputErrorCell(imageCell, errorMsg, 'red', this.ErrorMsgPopup);
                    this.userMessaging.add({ className: "error", message: errorMsg });
                }
            },

            /*updateRevisioningParameterOnChange_old : function(inputElement, ctrlObjectCell, imageCell) {
                var i, j, currSelOpt, currSelectedValue, optionValue,
                    ParamID = ctrlObjectCell.getData('argumentNode').paramid,
                    SetValueArray = inputElement.getValue(),
                    currSetValue =  SetValueArray[0],
                    toChangeValue = "NumericalRev",
                    ParamToTest = "VNaming_DevelopmentPart";

                if (currSetValue === "NumericalRev") { toChangeValue = "AlphabeticalRev"; }
                if (ParamID === "VNaming_DevelopmentPart") { ParamToTest = "VNaming_ProductionPart"; }

                if (("VNaming_DevelopmentPart" === ParamID) ||
                        ("VNaming_ProductionPart" === ParamID)) {
                    for (i = 0; i < this.inputControls.length; i++) {
                        if (this.inputControls[i].elements.input.id == ParamToTest) {
                            //Find the Selected option/value for other policy to Change (currSelectedValue)
                            currSelOpt = this.inputControls[i].getSelection();
                            currSelectedValue = currSelOpt[0].value;
                            //if this option matches the new value set () for
                            if (currSelectedValue == currSetValue) {
                                for (j = 0; j < this.inputControls[i].elements.input.length; j++) {
                                    optionValue = this.inputControls[i].elements.input[j].value;
                                    if (optionValue == toChangeValue) {
                                        this.inputControls[i].select(j, true, false);
                                        this.userMessaging.add({ className: "info", message: ParamSkeletonNLS.partSameSequence});
                                        break;
                                    }
                                }
                                break;
                            }//of  (currSelectedValue == currSetValue)                  
                        }
                    }//of for  this.inputControls                  
                }//of VNaming_DevelopmentPart == VNaming_ProductionPart

                this.updateParameterOnChange(currSetValue, ctrlObjectCell, imageCell);
            },*/

            updateRevisioningParameterOnChange : function(inputElement, ctrlObjectCell, imageCell) {
                var i, j, currSelOpt, currSelectedValue, optionValue,//currDate, currTime, diffDate,
                    currentPlatform = this.connectProps.tenantID,
                    ParamID = ctrlObjectCell.getData('argumentNode').paramid,
                    SetValueArray = inputElement.getValue(),
                    currSetValue =  SetValueArray[0];
                    //hasAnInputChanged = false;

                if (ParamLayoutUtilities.isOnTheCloud(currentPlatform)) {
                    //Force values for Cloud envs only
                    for (i = 0; i < this.inputControls.length; i++) {
                        if (this.inputControls[i].elements.input.id !== ParamID) {
                            //Find the Selected option/value for other policy to Change (currSelectedValue)
                            currSelOpt = this.inputControls[i].getSelection();
                            currSelectedValue = currSelOpt[0].value;
                            //if this option matches don't the new value set () for
                            if (currSelectedValue !== currSetValue) {
                                for (j = 0; j < this.inputControls[i].elements.input.length; j++) {
                                    optionValue = this.inputControls[i].elements.input[j].value;
                                    if (optionValue === currSetValue) {
                                        this.inputControls[i].select(j, true, false);
                                        //hasAnInputChanged = true;
                                        break;
                                    }
                                }
                                //break;
                            }//of  (currSelectedValue !== currSetValue)                  
                        }
                    }//of for  this.inputControls   

                    /*if (hasAnInputChanged === true) {
                        currDate = new Date();
                        currTime = currDate.getTime();
                        diffDate = currTime - this.RevMsgTime;

                        if (diffDate >= 5000) {
                            this.RevMsgTime = currTime;
                            this.userMessaging.add({className: "info", message: ParamSkeletonNLS.cloudSequenceChange});
                        }
                    }*/
                }

                this.updateParameterOnChange(currSetValue, ctrlObjectCell, imageCell);
            },

            updateComboMultiSelectParamOnChange : function(inputElement, ctrlObjectCell, imageCell) {
                //NZV : No need to separate funciton can be combined with function updateComboParamOnChange
                var SetValueArray = inputElement.getValue(),
                    currSetValue = null;

                if ((Array.isArray(SetValueArray) == true)) {
                    currSetValue = SetValueArray.join(",");
                }
                this.updateParameterOnChange(currSetValue, ctrlObjectCell, imageCell);
            },

            updateComboParamOnChange : function(inputElement, ctrlObjectCell, imageCell) {
                var SetValueArray = inputElement.getValue(),
                    currSetValue = SetValueArray.join(",");
                this.updateParameterOnChange(currSetValue, ctrlObjectCell, imageCell);
            },

            updateParameterOnChange : function(iValue, ctrlObjectCell, imageCell) {
                var iParam,
                    imageTXT = ParamSkeletonNLS.Under_Deploy,
                    ParamID = ctrlObjectCell.getData('argumentNode').paramid,
                    argID = ctrlObjectCell.getData('argumentNode').argumentid,
                    jsonArr = [],
                    ArgArr = [];

                ParamLayoutUtilities.beingDeployed(imageCell, imageTXT);

                ArgArr.push({id: argID, value: iValue});
                iParam = {
                    domain   : this.connectProps.domainName,
                    id       : ParamID,
                    argument : ArgArr
                };
                jsonArr.push(iParam);
                ParameterizationWebServices.postParamsArrOnServer.call(this, this.connectProps, jsonArr, imageCell,
                    this.onApplyFailure.bind(this), this.onApplySuccess.bind(this));
            },

            onApplyFailure : function (json, theImageCell) {
                UWA.log(json);
                Mask.unmask(this.contentDiv);//Rb0afx
                this.userMessaging.add({ className: "error", message: ParamSkeletonNLS.deployFailureMsg });
                ParamLayoutUtilities.updateIcon(false, theImageCell);
            },

            onApplySuccess : function (json, theImageCell) { //Rb0afx                      
                var currDate, currTime, diffDate,
                    successmsg = ParamSkeletonNLS.deploySuccessMsg;// + ' - ' + new Date();
                Mask.unmask(this.contentDiv);
                UWA.log(json);

                currDate = new Date();
                currTime = currDate.getTime();
                diffDate = currTime - this.lastAlertDate;
                this.lastAlertDate = currTime;

                if ((this.handledFamily === "VersionNaming") &&
                        (ParamLayoutUtilities.isOnTheCloud(this.connectProps.tenantID))) {
                    successmsg = ParamSkeletonNLS.cloudSequenceChange;
                }

                //IR-496432-3DEXPERIENCER2017x  
                if (json.deployStatus === "S_OK") {
                    if (diffDate >= 2000) {
                        this.userMessaging.add({ className: "success", message: successmsg });
                    }
                    ParamLayoutUtilities.updateIcon(true, theImageCell);
                } else {
                    this.onApplyFailure(json, theImageCell);
                }

            },

            applyParams : function () {
                UWA.log("applyParams");
                this.UpdateCommonParamsOnServer();
            },

            //show: function () {},
            destroy : function() {
                this.stopListening();
                this._parent.apply(this, arguments);
            }

        });

        return extendedView;
    });

/*@fullReview  ZUR 15/11/23 2017x Param Skeleton*/
/*global define, widget*/
define('DS/ParameterizationSkeleton/Views/ParametersParentView',
    [
        'UWA/Core',
        'UWA/Class/View',
        'DS/ParameterizationSkeleton/Views/ParametersLayoutView',
        'DS/W3DXComponents/Views/Layout/ListView',
        'DS/ParameterizationSkeleton/Views/ParamItemsListView'
    ], function (UWA, View, ParametersLayoutView, ListView, ParamItemsListView) {

        'use strict';

        return View.extend({

            defaultOptions: {
                type: 'default'
            },

            /* setup : function () {
            //muter via un extend ?
            //appeler le setup  / options / propertymodel
            //tester le type d'instance de ce model with instanceof
            },*/

            init : function (options) {
                UWA.log("ParametersParentView::init");
                UWA.log(options);
                this.options = options;
                this.childView = null;
            },

        // The ‘options’ object is passed via the ‘viewOptions’ specified in the Renderer at the Skeleton instantiation
            render: function () {
                //options = options || {options = {}};
                //options = UWA.clone(options || {}, false);
                var options = this.options,
                    myView = this.getViewFromDomainID(options);

                if (myView !== null) {
                     //myView.init();
                    this.childView = myView;
                    return myView.render();
                }

                return null;//defaultView.render();

            },

            getViewFromDomainID : function (options) {
                var i,
                    AppIntItemsDomainViewList = ["AttributeDef", "LifecycleTopology", "XCADParameterization"];

                for (i = 0; i < AppIntItemsDomainViewList.length; i++) {
                    if (options.domainid === AppIntItemsDomainViewList[i]) {
                        return new ParamItemsListView(options);
                    }
                }
                return new ParametersLayoutView(options);
            },

            /*getViewFromDomainID : function (options) {
                var i,
                    AppIntExchangeDomainList = ["Iteration", "DataAccessRight", "ObjectIdentification", "EngineeringCentral", "Deployment", "ParamDev", "EngineeringWorkspace"];

                for (i = 0; i < AppIntExchangeDomainList.length; i++) {
                    if (options.domainid === AppIntExchangeDomainList[i]) {
                        return new ParametersLayoutView(options);
                    }
                }
                return new ParamItemsListView(options);
            },*/

            destroy : function() {
                this.childView.destroy();
                this.stopListening();
                this._parent.apply(this, arguments);
            }

        });
    });

/*global define, widget, document, setTimeout, console*/
/*jslint plusplus: true*/
/*jslint nomen: true*/
define('DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/LifecycleView',
    [
        'UWA/Core',
        'UWA/Class/View',
        'egraph/core',
        'egraph/views',
        'egraph/iact',
        'egraph/utils',
        'DS/UIKIT/Input/Button',
        'DS/UIKIT/Input/Select',
        'DS/UIKIT/Modal',
        'DS/UIKIT/Alert',
        'DS/UIKIT/Popover',
        'DS/UIKIT/Mask',
        'DS/UIKIT/Scroller',
        'DS/ParameterizationSkeleton/Utils/ParameterizationDataUtils',
        'DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
        'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/LifecycleViewUtilities',
        'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/LifecycleEgraphUtilities',
        'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/ParamStepGeometry',
        'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/ParamNodeView',
        'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/ParamTransitionsDrag',
        'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/ParamEdgeView',
        'DS/ParameterizationSkeleton/Utils/ParameterizationWebServices',
        'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS'
    ],
    function (UWA, View,
              core, views, iact, utils,
              Button, Select,
              Modal,
              Alert, Popover, Mask, Scroller,
              ParameterizationDataUtils,
              ParametersLayoutViewUtilities,
              LifecycleViewUtilities, LifecycleEgraphUtilities, StepGx, ParamNodeView, ParamTransitionsDrag,
              ParamEdgeView,
              ParameterizationWebServices,
              ParamSkeletonNLS) {

        'use strict';

        var extendedView;

        extendedView =  View.extend({
            tagName: 'div',
            className: 'generic-detail',

            init: function (options) {
                options = UWA.clone(options || {}, false);
                var GraphSettings   = ParameterizationDataUtils.paramStructBuilder("nodewidth,nodeheight,nodeSpacing");
                this.transitionElt  = ParameterizationDataUtils.paramStructBuilder("sourceState,targetState,name,nlsname,isCritical,isDeployed");
                this.stateElt       = ParameterizationDataUtils.paramStructBuilder("stateid,name,isCritical,isEnabled,isDeployed");

                this._parent(options);
                this.stepGeometry = new StepGx.ParamStepGeometry(10);//StepGeometry(10);
                this.grProps = new GraphSettings(180, 110, 320); //(150,100,200);   (180,110,250) 
                this.grph = null;
                this.nodes = [];
                this.contentDiv = null;
                this.userMessaging = null;
                this.userMessagingDrag = null;
                this.policyID = null;
                this.RulesModal = null;
                this.defaulttransitions = [];
                this.forbiddentransitions = [];
                this.defaultstates = [];
                this.rulesTableWdthArr = [15, 10, 10, 35, 20, 5, 5];
                this.errorMsgTime = 0;
                this.renameStates = true;
                this.modifyTopology = true;
                //IR-695253-3DEXPERIENCER2019x FD06
                this.lastDeployedStates = [];
                this.lastDeployedTransitions = [];
                this.lastDeployedChecks = [];

                LifecycleEgraphUtilities.addEdgeArrowDesign(widget);

            },

            setup: function(options) {
                UWA.log('LifecycleView::setup!');
                //this.listenTo(this.collection, "onSync", this.render);
                //var statesArray = this.collection._models[0]._attributes.states;

                /* //the good one
                this.listenTo(this.collection, {          
                    onSync: this.render,
                });*/
                UWA.log(options);
            },
            // in:render console.log(this.collection._models.keys());
            /*  var content = [];
            models.keys().forEach(function (key) {
                var value = this.collection._models.get(key);
                console.log("logggggggggggggggg::key = "+key+" and value = "+value);
            }, this);

            this.model.keys().forEach(function (key) {
                var value = this.model.get(key);
                console.log("key = "+key+" and value = "+value);          
            }, this);*/

            render: function () {
                UWA.log("LifecycleView::render");
                var LCChecksDiv, paramScroller, iDivs, contentDiv,
                    that = this;

                iDivs = that.rendereGraphElements();
                contentDiv = iDivs[0];

                Mask.mask(contentDiv);

                this.userMessaging = new Alert({
                    className : 'param-alert',
                    closable: true,
                    visible: true,
                    renderTo : document.body,
                    autoHide : true,
                    hideDelay : 1200,
                    messageClassName : 'warning'
                });

                this.userMessagingDrag = new Alert({
                    className : 'param-alert',
                    closable: true,
                    visible: true,
                    renderTo : document.body,
                    autoHide : true,
                    hideDelay : 1200,
                    messageClassName : 'warning'
                });

                this.renameStates = this.model.get("renameStates");
                this.modifyTopology = this.model.get("modifyTopology");


                //.inject(contentDiv);

                // create the graph

                //LifecycleViewUtilities.addApplyResetToolbar(contentDiv, this.applyParams, this.resetParamsinSession) ;  
                //à tester innerHeight: 516 innerWidth: 1875  outerHeight: 1032 outerWidth: 1920 */
                //UWA.log("policyID=" + that.model.get('id'));
                //UWA.log("width = " + wdth);

                this.addApplyResetToolbar2(contentDiv);
                this.container.setContent(contentDiv);
                this.contentDiv = contentDiv;

                LCChecksDiv = LifecycleViewUtilities.buildLifecycleChecksView(this.rulesTableWdthArr);

                //var insertDiv = document.getElementsByClassName("egraph_views_domroot")[0];//OK
                //var insertDiv = document.getElementById("egraph_views_domroot");
                //insertDiv.appendChild(LCChecksDiv);

                LCChecksDiv.inject(this.contentDiv);

                paramScroller = new Scroller({
                    element: LCChecksDiv
                }).inject(this.contentDiv);

                //this.listenTo(this.model.get('resultsColl'), "onSync", this.onModelLoaded);
                //that.listenTo(that.collection, "onSync", that.onCompleteRequestTopology());

                //the good one 
                this.listenTo(this.collection, {
                    onSync: that.onCompleteRequestTopology
                });

               // this.onCompleteRequestTopology();
                return this;
            },

            rendereGraphElements : function () {

                var sm, that, wdth, hgth, newWdth, newhgth, vpt, transitionDragHandler,
                    canvas,
                    currDate, currTime, diffDate,
                    iDivs =  LifecycleEgraphUtilities.addeGraphDivs();

                canvas = iDivs[1];

                this.grph = new core.EGraph();
                this.grph.nodeSpacing = this.grProps.nodeSpacing;//200

                // add the main view of the graph in 'graph_canvas' div using a
                // HTMLGraphView view to have default display                               
                this.grph.addView('main', new views.HTMLGraphView(canvas));//('main', new views.HTMLGraphView(document.querySelector('#graph_canvas')));

                that = this;
                // instantiate a default state machine to handle mouse & touch interactions
                sm = new iact.StateMachine(this.grph, null, null, this.grph.views.main);

                // override onmousedown to prevent any stopPropagation & preventDefault 
                // to happen and to make sure we don't manipulate the graph when dragging
                // the selection of an input element
                sm.rootState.onmousedown = (function (old_onmousedown) {
                    return function onmousedown(sm, data) {
                        var old_ret, ret;

                        if (data.button === iact.Buttons.LEFT &&
                                data.modifiers === 0 &&
                                data.dom && data.dom.tagName === 'INPUT') {
                            if (data.grElt !== undefined) {
                                if (!sm.graph.isSelected(data.grElt)) {
                                    sm.graph.updateLock();
                                    try {
                                        sm.graph.replaceSelectionWith(data.grElt);
                                        if (data.grElt.bringToFront) {
                                            data.grElt.bringToFront();
                                        }
                                    } finally {
                                        sm.graph.updateUnlock();
                                    }
                                    // after reparenting the focus is not given back to the input
                                    setTimeout(data.dom.focus.bind(data.dom), 0);
                                }
                            }
                            return { state: {
                                onmouseup: function (sm, data) {
                                    if (data.button === iact.Buttons.LEFT) {
                                        return {
                                            state: null
                                        };
                                    }
                              // FIXME: if undefined it should be considered empty
                                    return {};
                                }
                            }};
                        }

                        // by default disable the consumption
                        old_ret = old_onmousedown.apply(this, arguments);
                        if (old_ret) {
                            ret = {};
                            Object.keys(old_ret).forEach(function (k) {
                                if (k !== 'consume') {
                                    ret[k] = old_ret[k];
                                }
                            });
                            return ret;
                        } else {
                            return old_ret;
                        }
                    }
                }(sm.rootState.onmousedown));

                sm.rootState.newDragForElement = function(grph, elt, subElt) {
                    //var drag;
                    /*
                    EGRAPH      number  0   Object is a module:egraph/core.EGraph
                    NODE        number  1   Object is a module:egraph/core.Node
                    GROUP       number  2   Object is a module:egraph/core.Group
                    CONNECTOR   number  3   Object is a module:egraph/core.Connector
                    EDGE        number  4   Object is an module:egraph/core.Edge
                    */
                    if (elt.type === core.Type.CONNECTOR) {
                        UWA.log("CONNECTOR");
                        if (that.modifyTopology) {
                            transitionDragHandler = new ParamTransitionsDrag.ParamTransitionsDrag(grph, elt, that.userMessagingDrag, that.defaulttransitions, that.forbiddentransitions);
                            that.handledeployIndicator();
                            return transitionDragHandler;
                        }
                        currDate = new Date();
                        currTime = currDate.getTime();
                        diffDate = currTime - that.errorMsgTime;
                        if (diffDate >= 1400) {
                            that.errorMsgTime = currTime;
                            that.userMessagingDrag.add({className: "warning", message: ParamSkeletonNLS.TopologyNotModifiable});
                        }
                        return null;//non modifiyable topology
                    }
                    if (elt.type === core.Type.NODE) {
                       /* if (elt.stateid == "controlBox")
                            return iact.DefaultRootState.prototype.newDragForElement.apply(this, arguments);
                        else*/
                        LifecycleEgraphUtilities.removePropsNode();
                        return null;
                    }

                    if (elt.type === core.Type.EDGE) {
                        UWA.log("edge");
                        that.highlightMatchingChecksInTable(elt.cl1.c.node.stateid, elt.cl2.c.node.stateid);
                        LifecycleEgraphUtilities.buildpropsNode.call(that, elt, that.RenameTransition.bind(that));
                        return iact.DefaultRootState.prototype.newDragForElement.apply(this, arguments);
                    } else {
                        // by default we reuse the DefaultRootState's implementation
                        UWA.log("drag::else");
                        //UWA.log(this);
                        return iact.DefaultRootState.prototype.newDragForElement.apply(this, arguments);
                    }
                };

                //utils.inherit(PropsView, views.HTMLNodeView); //ZUR Desactivate
                /*utils.inherit(ChecksListView, views.HTMLNodeView);*/
                /* edge.prototype.onselect = function(e, selected){
                    if (selected) 
                        return (selectNode(e));  
                    };*/
                wdth = this.grph.views.main.domRoot.clientWidth;
                hgth = this.grph.views.main.domRoot.clientHeight;
                newWdth = 600 + (wdth / 2);
                newhgth = 300 + (hgth / 2);
                vpt = utils.changeViewpointScale(this.grph.views.main.vpt, 0.81, [ newWdth, newhgth ], false);//0.75
                //Handling view point 
                this.grph.views.main.setViewpoint(vpt, true);

                return iDivs;

            },

            onCompleteRequestTopology : function () {
                var deployStsDiv,
                    that = this,
                    statesArray = LifecycleViewUtilities.sortArrayByKey(this.collection._models[0]._attributes.states, "visuOrder"),
                    transitionsArray = this.collection._models[0]._attributes.transitions,
                    areAllChecksDeployed = true,
                    deployIndicatorSts = true;

                UWA.log("onCompleteRequestTopology");
                //var statesArray = this.collection._models[0]._attributes.states;

                if ((this.nodes !== null) && (this.nodes.length === 0)) {

                    that.policyID = that.collection._models[0]._attributes.id;

                    deployIndicatorSts = that.buildLifecycleGraph(statesArray, transitionsArray);

                    areAllChecksDeployed = that.showCurrentLifecycleChecksList(that.collection._models[0]._attributes.checks,
                                                        that.collection._models[0]._attributes.types);

                    if (!areAllChecksDeployed) { deployIndicatorSts = false; }

                    that.grph.appCategory = this.collection._models[0]._attributes.appCategory;

                    deployStsDiv = LifecycleViewUtilities.addDeployIndicator(deployIndicatorSts);
                    deployStsDiv.inject(that.contentDiv);

                    Mask.unmask(that.contentDiv);
                }
            },

            buildLifecycleGraph : function (statesArray, transitionsArray) {

                var i, defTRcounter, forbiddenTRcount, deployIndicatorSts,
                    defstateCount = 0,
                    stateCount = 0,
                    xStart = 5,
                    xIncr = this.grph.nodeSpacing,
                    that = this;

                for (i = 0; i < statesArray.length; i++) {
                    if (statesArray[i].isDefault.toString() === "false") {
                        that.nodes[stateCount++] = that.lifecycleStateNode(statesArray[i].id, statesArray[i].stateUserName,
                                                                    statesArray[i].isCritical, statesArray[i].isEnabled,
                                                                    xStart, 40, this.grProps);
                        if (statesArray[i].isDeployed !== true) {
                            deployIndicatorSts = false;
                        } else { //IR-695253-3DEXPERIENCER2019x FD06
                            that.lastDeployedStates.push(statesArray[i]);
                        }
                        //this.nodes[stateCount++] = LifecycleViewUtilities.newMixNode(statesArray[i].id, statesArray[i].stateUserName, xStart, 40, this.grProps);                                       
                        xStart = xStart + xIncr;
                    } else {
                        /*this.defaultnodes[defstateCount] =  this.tempMixNode(statesArray[i].id, statesArray[i].stateUserName, 
                                                                    statesArray[i].isCritical, statesArray[i].isEnabled,
                                                                    xdefStart, 40, this.grProps); 
                        xdefStart = xdefStart + xIncr;*/
                        this.defaultstates[defstateCount++] = new this.stateElt(statesArray[i].id, statesArray[i].stateUserName,
                                                                             statesArray[i].isCritical, statesArray[i].isEnabled,
                                                                             false);
                    }
                }
                //this.nodes[stateCount++] = propertiesNode("controlBox",-70, 220);              
                //this.nodes[stateCount++] = ChecksNode("controlBox",550, 220);   
                // add the nodes and an edge; we lock the graph update to only do
                // one update when all nodes will have been added          
                this.grph.updateLock();
                try {
                        // adding the nodes
                    this.nodes.forEach(function (n) {
                        if (n.isEnabled == "true") {
                            that.grph.addNode(n);
                        } else {
                            UWA.log(n);
                        }
                    });
                    // We could have used 'children' property on nodes but this would have been 
                    // less readable than using names in that configuration. This is the added
                    // value of having custom data on nodes depending on the type of graph. 

                    defTRcounter = 0;
                    forbiddenTRcount = 0;
                    //<Transition name="ToRelease" sourceState="IN_WORK" targetState="RELEASED" isDefault="false" isForbidden="false" isCritical="false"/>
                    for (i = 0; i < transitionsArray.length; i++) {
                        if ((transitionsArray[i].isDefault.toString() === "false") && (transitionsArray[i].isForbidden.toString() === "false")) {
                            //this line replaced a lot
                            that.drawtransition(transitionsArray[i], that.grph.nodes);

                            if (transitionsArray[i].isDeployed !== true) {
                                deployIndicatorSts = false;
                            } else {//IR-695253-3DEXPERIENCER2019x FD06
                                that.lastDeployedTransitions.push(transitionsArray[i]);

                            }

                        } else if (transitionsArray[i].isDefault.toString() === "true") {
                            this.defaulttransitions[defTRcounter++] = new that.transitionElt(transitionsArray[i].sourceState, transitionsArray[i].targetState,
                                                                                                transitionsArray[i].name, transitionsArray[i].nlsname,
                                                                                                transitionsArray[i].isCritical, false);
                        } else if (transitionsArray[i].isForbidden == "true") {
                            this.forbiddentransitions[forbiddenTRcount++] = new that.transitionElt(transitionsArray[i].sourceState, transitionsArray[i].targetState,
                                                                                                transitionsArray[i].name, transitionsArray[i].name,
                                                                                                false, false);
                        }
                    }
                } finally {
                    this.grph.updateUnlock();
                }

                return deployIndicatorSts;
            },

            //show: function () {},
            addNewEdge : function (stub, iSignature, iSignatureNLS, isCritical, c1, c2) {
                 //var edge = this.buildEdge(stub);    
                var edge = ParamEdgeView.buildEdge(stub, iSignature);
                edge.signature = iSignature;
                edge.signatureNLS = iSignatureNLS;
                edge.DeployedSig = iSignatureNLS;
                edge.isCritical = isCritical;
                this.grph.addEdge(c1, c2, edge);// add the edge to the graph
                return edge;
            },

            handleRenamingIssues : function(iNode, that, iEnteredName) {
                //UWA.log(iNode);
                var errorMsg, currDate, currTime, diffDate,
                    checkNameResult;
                    //IR-695253-3DEXPERIENCER2019x FD06
                if ((iEnteredName != null) /* &&  (iEnteredName != "")*/) {// && (enteredname!=previousName)
                    checkNameResult = that.testStateNamingRules(iNode, iEnteredName, that);
                    if (checkNameResult === "ok") {
                        that.renameSelectedState(that, iNode.stateid, iEnteredName);
                        iNode.views.main.display.elt.removeClassName("my-error-node");
                        that.handledeployIndicator();
                        LifecycleViewUtilities.enableApplyButton(that.contentDiv);
                    } else { ////IR-695253-3DEXPERIENCER2019x FD06
                        errorMsg = ParamSkeletonNLS.SpecialCharactersMessage;
                        if (checkNameResult === "alreadyUsedName") { errorMsg = ParamSkeletonNLS.StateNameAlreadyUsed.format(iEnteredName); }
                        if (checkNameResult === "emptyString") { errorMsg = ParamSkeletonNLS.EmptyValueNotAllowed; }
                        currDate = new Date();
                        currTime = currDate.getTime();
                        diffDate = currTime - that.errorMsgTime;
                        if (diffDate >= 1400) {
                            that.errorMsgTime = currTime;
                            that.userMessaging.add({className: "error", message: errorMsg});
                        }
                        iNode.views.main.display.elt.addClassName("my-error-node");
                        LifecycleViewUtilities.disableApplyButton(that.contentDiv);
                    }
                }
            },

            testStateNamingRules : function (iNode, enteredname, that) {
                var e;
                //IR-695253-3DEXPERIENCER2019x FD06 : added test for empty state name
                enteredname = enteredname.trim();
                if(enteredname.length === 0) {
                    return "emptyString";
                }
                for (e = that.grph.nodes.first; e; e = e.next) {
                    if ((e.name === enteredname) && (e.stateid != iNode.stateid)) {
                        return "alreadyUsedName";
                    }
                }
                if (ParametersLayoutViewUtilities.testSpecialCharacters(enteredname)) { return "specialCharacterName"; }
                return "ok";
            },

            renameSelectedState : function(that, stateid, newStateName) {
                var e, i,
                    tbodyref = that.contentDiv.getElements('.paramtbody')[0],
                    listofLines = tbodyref.children,
                    nbofLines = listofLines.length;

                for (e = that.grph.nodes.first; e; e = e.next) {
                    if (e.stateid == stateid) {
                        e.name = newStateName;
                        break;
                    }
                }

                for (i = 2; i < nbofLines; i++) {
                    if (listofLines[i].cells[1].value === stateid) {
                        listofLines[i].cells[1].children[0].innerText = newStateName;
                    }

                    if (listofLines[i].cells[2].value === stateid) {
                        listofLines[i].cells[2].children[0].innerText = newStateName;
                    }
                }
            },

            testTransitionRenamingRules : function (newName) {
                if (this.grph.appCategory === "VPM") { //IR-695253-3DEXPERIENCER2019x FD06
                    newName = newName.trim();
                    if(newName.length === 0) {
                        return "emptyString";
                    }
                }
                if (ParametersLayoutViewUtilities.testSpecialCharacters(newName)) { return "specialCharacterName"; }
                return "S_OK";
            },

            RenameTransition : function (elt, iElm, isOnFinalChange) {
                var currDate, currTime, diffDate, errorMsg, testResult, iValue = iElm.getValue();
                testResult = this.testTransitionRenamingRules(iValue);
                if (testResult === "S_OK") {
                    elt.signatureNLS = iValue; //elt.signature = iValue;
                    this.handledeployIndicator();
                    LifecycleViewUtilities.enableApplyButton(this.contentDiv);
                } else {
                    if (testResult === "specialCharacterName") {
                        errorMsg = ParamSkeletonNLS.SpecialCharactersMessage;
                    } else {
                        errorMsg = ParamSkeletonNLS.EmptyValueNotAllowed;
                         elt.signatureNLS = elt.DeployedSig;//IR-695253-3DEXPERIENCER2019x FD06
                    }
                    
                    LifecycleViewUtilities.disableApplyButton(this.contentDiv);

                    currDate = new Date();
                    currTime = currDate.getTime();
                    diffDate = currTime - this.errorMsgTime;
                    if (diffDate >= 1400) {
                        this.errorMsgTime = currTime;
                        this.userMessaging.add({className: "error", message: errorMsg});
                    }

                    if (isOnFinalChange) { 

                        LifecycleViewUtilities.enableApplyButton(this.contentDiv);
                        LifecycleEgraphUtilities.removePropsNode();
                    }
                }
            },


            /*handleSignatureOnRename : function (elt, iValue) {
                var currLabel, 
                    that = this;

            if (that.model.get("modifyTopology")) {
                currLabel = elt.signature;         
                 
                if (iValue !== null) {                                       
                    if (testNameForSpecialChar(enteredname)==true)
                    {   
                        alert("<SpecialCharactersMessage>");
                        return;
                    }
                    
                    var policyType = currPolicyDescriptor.appType;                  
                    
                    if ( (policyType == "VPM") && (testNameForBlankChar(enteredname)==true)) {
                        UWA.log("<blankCharactersMessage>");           
                        return;
                    }
                    
                    if (enteredname !== "") {                                   
                       elt.signature = iValue;
                    }
                }                       
            },*/

            /*
            function testNameForBlankChar(iString) {   
                var iChars =" ";
                for (var i = 0; i < iString.length; i++)                        
                    if (iChars.indexOf(iString.charAt(i)) != -1)    
                        return true;
                
                return false;       
            }
            
            function trimGeneratedName(iString) {
                return(iString.replace(/ /g,''));
            }               
            }*/


             /**
             * Factory of node with two inputs and one output (a 'mix' node)
             * @param {number} x
             * @param {number} y
             * @returns {module:egraph/core.Node} the new node
             */
            lifecycleStateNode : function (nodeid, nlsName, isCritical, isEnabled, x, y, graphProps) {
                var stateNodeView,
                    node = new core.Node(),  // create the node
                    offset;
                //  node.views.main = new fctNodeView();//new views.HTMLNodeView();//default      
                // ParamNodeView.ParamNodeView.bind(this);
                // var myView = new ParamNodeView.ParamNodeView(that.handleRenamingIssues).bind(this);
                // utils.inherit(myView, views.HTMLNodeView);

                stateNodeView  = new ParamNodeView.ParamNodeView(this, this.renameStates, this.modifyTopology);
                //stateNodeView  = ParamNodeView.ParamNodeView.call(this, this, this.model.get("renameStates"), this.model.get("modifyTopology"));

                node.views.main = stateNodeView;//new views.HTMLNodeView();//default           
                node.data = {};//object will be used to store references to connectors
                node.stateid = nodeid;
                node.name = nlsName;
                node.isCritical = isCritical;
                node.isEnabled  = isEnabled;
                // use multiset to force the dispatch of properties change notifications
                // to group all modifications of nodes properties (useless here since
                // nobody listen to the node yet; but good to keep in mind)
                node.multiset('left', x,
                              'top', y,
                              'width', graphProps.nodewidth,
                              'height', graphProps.nodeheight);

                // create connectors and store their eferences in the data object of the node
                offset = Math.round(graphProps.nodeheight / 2);
                node.data.left = LifecycleEgraphUtilities.createConnector(core.BorderCstr.LEFT, offset);
                node.appendConnector(node.data.left);
                node.data.right = LifecycleEgraphUtilities.createConnector(core.BorderCstr.RIGHT, offset);
                node.appendConnector(node.data.right);

                offset = Math.round(graphProps.nodewidth / 2);
                node.data.top = LifecycleEgraphUtilities.createConnector(core.BorderCstr.TOP, offset);
                node.appendConnector(node.data.top);
                node.data.bottom = LifecycleEgraphUtilities.createConnector(core.BorderCstr.BOTTOM, offset);
                node.appendConnector(node.data.bottom);
                return node;
            },

            buildEdge : function (stub) {
                var edge = new core.Edge(),
                    currstepGeometry = new StepGx.ParamStepGeometry(stub);//   StepGeometry(stub);  
                // autoBezierGeometry.minTangentLength = autoBezierGeometry.minTangentLength+20;             
                // edge.set('geometry', autoBezierGeometry);

                UWA.log("Setting stepGeometry.stubScenario = " + currstepGeometry.stubScenario);
                edge.set('geometry', currstepGeometry);
                 //edge.views.main = new views.SVGEdgeView();
                edge.views.main = new views.SVGEdgeView('arrow-edge');

                //edge.views.main = new LabelEdgeView.LabelEdgeView();
                return edge;
            },

            showCurrentLifecycleChecksList : function(iListofChecks, iListofTypes) {
                var i, iTypeNLS, additionalinfoNLS,
                    tbodyref = this.contentDiv.getElements('.paramtbody'),//tbodytest = this.contentDiv.getElements('tbody');
                    nbofChecks = iListofChecks.length,
                    allChecksDeployed = true;

                for (i = 0; i < nbofChecks; i++) {
                    iTypeNLS = this.getTypeNLS(iListofChecks[i].objType, iListofTypes);
                    //additionalInfoNLS = ParamSkeletonNLS.ConsiderChildType + ":" + complementarySelect.getSelection()[0].label;
                    additionalinfoNLS = iListofChecks[i].additionalProps;

                    if ((iListofChecks[i].ruleID === "RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState") ||
                            (iListofChecks[i].ruleID === "RejectIfAttributeNotValuated")) {
                        if (iListofChecks[i].additionalProps === "ALL") {//NZV:IR-541898 
                            additionalinfoNLS = ParamSkeletonNLS.ConsiderKey.format(ParamSkeletonNLS.AllChildrenTypes);
                        } else {
                            additionalinfoNLS = ParamSkeletonNLS.ConsiderKey.format(this.getTypeNLS(iListofChecks[i].additionalProps, iListofTypes));
                        }
                    }

                    this.addChecktoTable(tbodyref[0],
                        iListofChecks[i].objType, iTypeNLS,
                        iListofChecks[i].sourceState, this.getUserStateNameforNode(this.grph.nodes, iListofChecks[i].sourceState),
                        iListofChecks[i].targetState, this.getUserStateNameforNode(this.grph.nodes, iListofChecks[i].targetState),
                        iListofChecks[i].ruleID,
                        iListofChecks[i].additionalProps, additionalinfoNLS,
                        iListofChecks[i].isDeployed);

                    if (!iListofChecks[i].isDeployed) { allChecksDeployed = false; }
                    else {//
                        this.lastDeployedChecks.push(iListofChecks[i]);
                    }
                }
                //BuildInitialTable
                return allChecksDeployed;
            },

            getTypeNLS : function (iType, iTypesList) {
                var i;
                for (i = 0; i < iTypesList.length; i++) {
                    if (iTypesList[i].typeID === iType) {
                        return iTypesList[i].typeNLS;
                    }
                }
                return iType;//nothin found, returning original
            },

            addChecktoTable : function(tableID, iTypeID, iTypeNLS, ifromStateID, ifromStateNLS, itoStateID, itoStateNLS, iRuleID, iAdditionalInfo, iAdditionalInfoNLS, isDeployed) {
                var ruleTextID, ruleTooltipID, rulePop,
                    iRuleNLS, iRuleTooltip,
                    iCell, lineCheck,
                    iAdditionalInfoUI,
                    deleteSpan, removeLCCheckButton, deletePop,
                    iconChoice = 'cog',
                    k = 0,
                    that = this,
                    iconColor = "orange",//to isDeployed
                    ititle = ParamSkeletonNLS.NotYetDeployed, //NZV:IR-613083-3DEXPERIENCER2019x
                    removelts = [];

                lineCheck = UWA.createElement('tr').inject(tableID); //Adding the line (type)                
                iCell = UWA.createElement('td', {
                    'width' : that.rulesTableWdthArr[k++].toString() + '%',
                    'Align' : 'left'
                }).inject(lineCheck);//object type

                iCell.value = iTypeID;
                UWA.createElement('p', {text: iTypeNLS, 'class': ''}).inject(iCell);

                iCell = UWA.createElement('td', {
                    'width' : that.rulesTableWdthArr[k++].toString() + '%',
                    'Align' : 'left'
                }).inject(lineCheck);//sourceState   

                iCell.value = ifromStateID;
                UWA.createElement('p', {text: ifromStateNLS, 'class': ''}).inject(iCell);

                iCell = UWA.createElement('td', {
                    'width' : that.rulesTableWdthArr[k++].toString() + '%',
                    'Align' : 'left'
                }).inject(lineCheck);//target state   

                iCell.value = itoStateID;
                UWA.createElement('p', {text: itoStateNLS, 'class': ''}).inject(iCell);

                ruleTextID = iRuleID + "Text";
                ruleTooltipID = iRuleID + "Tooltip";
                iRuleNLS = ParamSkeletonNLS[ruleTextID];
                iRuleTooltip = ParamSkeletonNLS[ruleTooltipID];

                iCell = UWA.createElement('td', {
                    'width' : that.rulesTableWdthArr[k++].toString() + '%',
                    'Align' : 'left'
                }).inject(lineCheck);//Rule

                iCell.value = iRuleID;
                UWA.createElement('p', {text: iRuleNLS, 'class': ''}).inject(iCell);
                /*
                var ruleSpan = UWA.createElement('span', {
                                'class' : 'fonticon fonticon-info'        
                            }).inject(iCell);       
                ruleSpan.setStyle("color", "black") ;  */
                rulePop = new Popover({
                    target: iCell,
                    trigger : "hover",
                    animate: "true",
                    position: "top",
                    body: iRuleTooltip,
                    title: ''//iParamObj.nlsKey
                });
                //iAdditionalInfo
                iCell = UWA.createElement('td', {
                    'width' : that.rulesTableWdthArr[k++].toString() + '%',
                    'Align' : 'left'
                }).inject(lineCheck);

                iCell.value = iAdditionalInfo;
                iAdditionalInfoUI = iAdditionalInfoNLS;

                if (iAdditionalInfo === "NOINFO") { iAdditionalInfoUI = ""; }

                UWA.createElement('p', {text: iAdditionalInfoUI, 'class': ''}).inject(iCell);

                iCell = UWA.createElement('td', {
                    'width' : that.rulesTableWdthArr[k++].toString() + '%',
                    'Align' : 'left'
                }).inject(lineCheck);
                //NZV - IR-666515-3DEXPERIENCER2019x
                removelts = ParametersLayoutViewUtilities.createActionElements(ParamSkeletonNLS.removePromotionRuleTxt, true);
                deleteSpan = removelts[0];
                deleteSpan.inject(iCell);
                removeLCCheckButton = removelts[1];
                deletePop = removelts[2];

                if (isDeployed === true) {
                    iconColor = "green";
                    ititle = ParamSkeletonNLS.Deployed; //NZV-IR-628927-3DEXPERIENCER2019x
                    iconChoice = 'check';
                } else if (isDeployed === false) {
                    iconColor = "orange";
                } else {//"newcheck"
                    lineCheck.addClassName("info");
                /* lineCheck.scrollIntoView(true);////lineCheck.focus();
                    iCell0.scrollIntoView(); iCell0.scrollIntoView(true);*/ //IE pas terrible du tout
                    //lineCheck.scrollTop = tableID.scrollHeight;
                    //lineCheck.parentNode.scrollTop = lineCheck.offsetTop; // marche pas
                }

                iCell = ParametersLayoutViewUtilities.buildImgCell(iconChoice, '1.5', iconColor, ititle, that.rulesTableWdthArr[k++].toString() + '%', 'center');
                iCell.inject(lineCheck);
                iCell.value = isDeployed;

                /* iCell = UWA.createElement('td', {
                    'Align' : 'center'
                    // 'title' : ititle,
                }).inject(lineCheck);
                
                removePop = new Popover({
                    class: 'parampopover',
                    target: iCell,
                    trigger : "hover",
                    animate: "true",
                    position: "top",
                    body: ititle,
                    title: ''//iParamObj.nlsKey
                });

                removeCheckButton = new Button({
                    className: 'close',
                    id  : 'togglepropsBox',
                    icon: 'fonticon fonticon-cancel fonticon-1.5x',//value: 'Button', //fonticon-cancel  fonticon-minus-circled    
                    attributes: {
                        disabled: false,
                        'aria-hidden' : 'true'
                    //  text : ParamWdgNLS.Apply 
                    },
                    events: {
                        onClick: function () {
                               //selectedObjpropsDiv.setStyle("visibility", "hidden");
                            removePop.destroy();
                            lineCheck.remove();
                            that.handledeployIndicator();
                        }
                    }
                }).inject(iCell);*/

                removeLCCheckButton.addEvent("onClick", function () {
                    deletePop.destroy();
                    lineCheck.remove();
                    //Check removed
                    that.handledeployIndicator();
                });

                //removeCheckButton.getContent().setStyle("color", iconColor);//"#1D7294"
            },

            highlightMatchingChecksInTable : function (iSourceState, iTargetState) {
                var i,
                    tbodyref = this.contentDiv.getElements('.paramtbody')[0],
                    listofLines = tbodyref.children,
                    nbofLines = listofLines.length;

                LifecycleViewUtilities.clearPreviousChecksHighlighting(listofLines);

                for (i = 2; i < nbofLines; i++) {
                    if ((listofLines[i].cells[1].value === iSourceState)
                            && (listofLines[i].cells[2].value === iTargetState)) {
                        listofLines[i].addClassName("info");//info
                    }
                }
            },

            /*getNodeIndex : function (iNodes, iNodeID) {
                var i,
                    nodesLength = iNodes.length;
                for (i = 0; i < nodesLength; i++) {
                    if (iNodes[i].stateid == iNodeID) {
                        return i;
                    }
                }
                return -1;
            },*/

            getUserStateNameforNode: function(iNodeList, iNodeID) {
                var userStateName = iNodeID,
                    matchingNode = LifecycleViewUtilities.getMatchingNode(iNodeList, iNodeID);

                if (matchingNode !== null) { userStateName = matchingNode.name; }
                return userStateName;
            },

            applyParams : function () {
                var e, i, itr,
                    stateslist, transitionList,
                    iRemStates, nbofRemovedStates,
                    datatoSend,
                    that = this,
                    state = [],
                    transition = [], isSomethingChanged = false, isAnyChangedInTransition = false,
                    isAnyChangeInStates = false, isAnyChangeInChecks = false, countSameTranistion = 0,
                    j = 0, sameCheckCount = 0, tbodyreflist, imgCell;
                if (this.checksBeforeDeploy()) {
                    stateslist = that.grph.nodes;
                    //
                    for (e = stateslist.first; e; e = e.next) {
                        state.push({
                            id: e.stateid,
                            stateUserName :  e.name,
                            isCritical : e.isCritical == "false" ? false : true,
                            isEnabled : true
                        });
                    }
                    //Check For Deleted States
                    iRemStates = this.getRemovedStatesList();
                    nbofRemovedStates = iRemStates.length;

                    for (i = 0; i < nbofRemovedStates; i++) {
                        state.push({
                            id : iRemStates[i].stateid,
                            stateUserName:  iRemStates[i].name,
                            isCritical : iRemStates[i].isCritical === "false" ? false : true,
                            isEnabled : false
                        });
                    }

                    transitionList = that.grph.edges;
                    for (itr = transitionList.first; itr; itr = itr.next) {
                        transition.push({
                            name : itr.signature,
                            nlsname : itr.signatureNLS,
                            sourceState : itr.cl1.c.node.stateid,
                            targetState : itr.cl2.c.node.stateid,
                            isCritical  : itr.isCritical.toString() == "false" ? false : true
                        });
                    }
					//ZUR IR-712839-3DEXPERIENCER2019x : .toString()
                    //NZV IR-695253-3DEXPERIENCER2019x FD06: Checkng for any modification
                    if(true) {
                         //Check addition & removal of state
                        if(this.lastDeployedStates.length !== state.length) {
                            //Modification in number of transitions 
                            isAnyChangeInStates = true;
                        }
                        //Check NLS name change for states
                        if(isAnyChangeInStates !== true) {
                            //further test
                            for(i = 0; i <  state.length; i++) {
                                
                                for(j = 0; j < this.lastDeployedStates.length; j++) {
                                    if (state[i].id === this.lastDeployedStates[j].id) {
                                        if(state[i].stateUserName === this.lastDeployedStates[j].stateUserName ) {
                                            isAnyChangeInStates = false;
                                            break;
                                        } else {
                                            isAnyChangeInStates = true;
                                             break;
                                        }
                                       
                                    }
                                }
                                if(isAnyChangeInStates === true) {
                                    break;
                                }
                            }
                        }
                    }

                    if (isAnyChangeInStates === false) {
                       //Check adition or removal of transition
                        if (this.lastDeployedTransitions.length !== transition.length) {
                            //Modification in number of transitions 
                            isAnyChangedInTransition = true;
                        }
                        if (isAnyChangedInTransition !== true) {
                            //Check for any signature change/name change of a transition.                           
                            for(i = 0; i <  transition.length; i++) {
                                for (j = 0; j < this.lastDeployedTransitions.length; j++) {
                                    if (transition[i].sourceState === this.lastDeployedTransitions[j].sourceState &&
                                        transition[i].targetState === this.lastDeployedTransitions[j].targetState &&
                                        transition[i].name === this.lastDeployedTransitions[j].name /*not required but save side*/) {
                                        if (transition[i].nlsname === this.lastDeployedTransitions[j].nlsname ) {
                                            isAnyChangedInTransition = false;
                                            countSameTranistion++;
                                            break;
                                        } else {
                                            isAnyChangedInTransition = true;
                                             break;
                                        }
                                    }
                                }
                                if (isAnyChangedInTransition === true) {
                                    break;
                                }
                            }

                            if (isAnyChangedInTransition === false) { 
                                if(countSameTranistion !== this.lastDeployedTransitions.length)  
                                        isAnyChangedInTransition = true;
                            }

                        }
                    }

                    datatoSend = {
                        id          : that.policyID,
                        state       : state,
                        transition  : transition,
                        check       : LifecycleViewUtilities.getCurrentChecks(this.contentDiv)
                    };
                     if (isAnyChangeInStates === false && isAnyChangedInTransition === false) {
                        //Check addtion or removal of rule
                        if (this.lastDeployedChecks.length !== datatoSend.check.length) {
                            //Modification in number of transitions 
                            isAnyChangeInChecks = true;
                        }
                        if (isAnyChangeInChecks === false) {
                             //Check for any signature change/name change of a transition.                           
                            for (i = 0; i <  datatoSend.check.length; i++) {
                                for (j = 0; j < this.lastDeployedChecks.length; j++) {
                                    if (datatoSend.check[i].objType === this.lastDeployedChecks[j].objType &&
                                        datatoSend.check[i].fromState === this.lastDeployedChecks[j].fromState &&
                                        datatoSend.check[i].toState === this.lastDeployedChecks[j].toState &&
                                        datatoSend.check[i].ruleID === this.lastDeployedChecks[j].ruleID  &&
                                        datatoSend.check[i].additionalProps === this.lastDeployedChecks[j].additionalProps) {
                                        sameCheckCount++;
                                        break;
                                    }
                                }
                                if (isAnyChangeInChecks === true) {
                                    break;
                                }
                            }
                            if (isAnyChangeInChecks === false) {
                                if (sameCheckCount !== datatoSend.check.length)
                                    isAnyChangeInChecks = true;
                            }
                        }
                     }
                    isSomethingChanged = isAnyChangedInTransition || isAnyChangeInStates || isAnyChangeInChecks;
                    if(isSomethingChanged === false) {
                        this.userMessaging.add({className: "error", message: ParamSkeletonNLS.NoChangeFound});
                        tbodyreflist = this.contentDiv.getElements('.indicatortbody');
                        imgCell = LifecycleViewUtilities.getNamingDeployCellSts(tbodyreflist);
                        LifecycleViewUtilities.updateIcon(true, imgCell);
                    }
                        //alert("No changed found");
                    UWA.log(datatoSend);
                    //Comment to tempratory 

                    if(isSomethingChanged === true) {
                        // alert("Something changed ");
                        Mask.mask(that.contentDiv);
                        ParameterizationWebServices.postLifecycleParams.call(this, datatoSend,
                            this.onDeployLCFailure.bind(this), this.onDeployLCSuccess.bind(this,datatoSend));
                    }
                }
            },

            checksBeforeDeploy : function () {
                if (!LifecycleViewUtilities.checkforSingletonStates(this.grph.nodes, this.grph.edges)) {
                    this.userMessaging.add({className: "error", message: ParamSkeletonNLS.SingletonStateText});
                    return false;
                }
                return true;
            },

            launchDeployProcess : function () {
                UWA.log(this.grph);
            },

            resetParamsinSession : function () {
                Mask.mask(this.contentDiv);
                LifecycleViewUtilities.resetLifecycleChecks(this.contentDiv.getElements('.paramtbody')[0].children);//Checks 
                this.resetStates();//States
                this.resetTransitions();//Transitions
                this.handledeployIndicator();//deploy indicator
                LifecycleViewUtilities.enableApplyButton(this.contentDiv);//Apply Button, if it was disabled before
                Mask.unmask(this.contentDiv);
            },

            onDeployLCSuccess : function (data) {
                UWA.log("onDeployLCSuccess");
                UWA.log(data);
                var imgCell, tbodyreflist, transitionList, itr, i;
                this.handleChecksAfterDeploy();
                Mask.unmask(this.contentDiv);
                this.userMessaging.add({className: "success", message: ParamSkeletonNLS.LCParamsDeploySuccess});
                //IR-695253-3DEXPERIENCER2019x FD06: update deployed parameter for UI
                this.lastDeployedTransitions = data.transition;
                this.lastDeployedStates = data.state;
                this.lastDeployedChecks = data.check;
                //UI update 
                transitionList = this.grph.edges;
                for ( itr = transitionList.first; itr; itr = itr.next) {
                    for ( i = 0 ; i < this.lastDeployedTransitions.length; i++) {

                        if (itr.signature === this.lastDeployedTransitions[i].name) {
                            itr.signatureNLS = this.lastDeployedTransitions[i].nlsname;
                            itr.DeployedSig = this.lastDeployedTransitions[i].nlsname;
                            break;
                        }
                    } 
                }
                tbodyreflist = this.contentDiv.getElements('.indicatortbody');
                imgCell = LifecycleViewUtilities.getNamingDeployCellSts(tbodyreflist);
                LifecycleViewUtilities.updateIcon(true, imgCell);

                LifecycleViewUtilities.UpdateLifecycleChecksStsInTable(this.contentDiv);//update icons
            },

            onDeployLCFailure : function (data) {
                UWA.log("onDeployLCFailure");
                UWA.log(data);
                Mask.unmask(this.contentDiv);
                this.userMessaging.add({className: "error", message: ParamSkeletonNLS.LCParamsDeployFailure});

                var tbodyreflist = this.contentDiv.getElements('.indicatortbody'),
                    imgCell = LifecycleViewUtilities.getNamingDeployCellSts(tbodyreflist);
                LifecycleViewUtilities.updateIcon(false, imgCell);
            },

            handleChecksAfterDeploy : function () {
                var i,//listofPopoversButtons,
                    tbodyref = this.contentDiv.getElements('.paramtbody')[0],
                    //listofLines = tbodyref.children,
                    //listofCloseButtons = tbodyref.getElements('.close');
                    listofCloseButtons = tbodyref.getElements('.cog');
                //
                for (i = 0; i < listofCloseButtons.length; i++) {
                    listofCloseButtons[i].setStyle("color", "green");
                }

                //listofPopoversButtons = tbodyref.getElements('.parampopover');
                /*removeCheckButton.getContent().setStyle("color",iconColor);//"#1D7294"  */
                /*for (var i=0; i<listofCloseButtons.length; i++)
                    listofCloseButtons[i].setStyle("color","green");*/
                //setBody
                //UWA.log(listofCloseButtons);
            },

            /*selectNode : function (e) {
                UWA.log("Node Selected");
               // LifecycleView.buildpropsNode(e, RenameState, RemoveState);
            },*/

            resetStates : function() {
                var i, defstateIndex,
                    nodesLength = this.nodes.length;

                for (i = 0; i < nodesLength; i++) {
                    this.nodes[i].remove();
                }
                for (i = 0; i < nodesLength; i++) {
                    defstateIndex = this.getDefaultStateIndex(this.nodes[i].stateid);
                    if (defstateIndex >= 0) {
                        this.nodes[i].name = this.defaultstates[i].name;
                        this.nodes[i].isEnabled = this.defaultstates[i].isEnabled;
                    }
                    this.grph.addNode(this.nodes[i]);
                }
            },

            getDefaultStateIndex: function (stateid) {
                var i,
                    defstatesLength = this.defaultstates.length;
                //
                for (i = 0; i < defstatesLength; i++) {
                    if (stateid == this.defaultstates[i].stateid) {
                        return i;
                    }
                }
                return -1;
            },

            /*
            resetTransitions : function ()
            {            
                var defTransitions = this.defaulttransitions;
                var nbofDefaultTransitions = defTransitions.length;

                for (var i=0; i<nbofDefaultTransitions; i++)
                {
                    var ifromNode = this.getNodeIndex(this.defaultnodes, defTransitions[i].sourceState);
                    var itoNode = this.getNodeIndex(this.defaultnodes, defTransitions[i].targetState);  

                    var xdiff = this.defaultnodes[itoNode].left - this.defaultnodes[ifromNode].left;                            
                    var iPositions = Math.round(xdiff/this.grph.nodeSpacing);

                    if  ((ifromNode>=0) && (itoNode>=0))
                    {
                        if (iPositions == 1)
                                this.addNewEdge(iPositions, defTransitions[i].name, defTransitions[i].isCritical, this.defaultnodes[ifromNode].data.right, this.defaultnodes[itoNode].data.left);
                            else if (iPositions <0)
                                this.addNewEdge(iPositions, defTransitions[i].name, defTransitions[i].isCritical, this.defaultnodes[ifromNode].data.bottom, this.defaultnodes[itoNode].data.bottom);
                            else
                                this.addNewEdge(iPositions, defTransitions[i].name, defTransitions[i].isCritical, this.defaultnodes[ifromNode].data.top, this.defaultnodes[itoNode].data.top);
                    }
                }              
            },*/

            resetTransitions : function () {
                var i,
                    nbofTransitions = this.defaulttransitions.length;

                for (i = 0; i < nbofTransitions; i++) {
                    this.drawtransition(this.defaulttransitions[i], this.grph.nodes);
                }
            },

            drawtransition : function(iTransition, iNodesList) {
                var xdiff, iPositions,
                    fromNode = LifecycleViewUtilities.getMatchingNode(iNodesList, iTransition.sourceState),
                    toNode   = LifecycleViewUtilities.getMatchingNode(iNodesList, iTransition.targetState);

                if ((fromNode !== null) && (toNode !== null)) {
                    xdiff = toNode.left - fromNode.left;
                    iPositions = Math.round(xdiff / this.grph.nodeSpacing);

                    if (iPositions === 1) {
                        this.addNewEdge(iPositions, iTransition.name, iTransition.nlsname, iTransition.isCritical, fromNode.data.right, toNode.data.left);
                    } else if (iPositions < 0) {
                        this.addNewEdge(iPositions, iTransition.name, iTransition.nlsname, iTransition.isCritical, fromNode.data.bottom, toNode.data.bottom);
                    } else {
                        this.addNewEdge(iPositions, iTransition.name, iTransition.nlsname, iTransition.isCritical, fromNode.data.top, toNode.data.top);
                    }
                } else {
                    UWA.log("prb with " + iTransition.sourceState + " or " + iTransition.targetState);
                }
            },

            addApplyResetToolbar2 : function (insertdivID) {
                var applyDiv, tableButtons, lineButtons, buttonApplyCell, applyBttn,
                    buttonResetCell, resetBbttn,
                    that = this;

                applyDiv =  UWA.createElement('div', {
                    'id': 'ApplyResetDivLC'
                }).inject(insertdivID);

                tableButtons = UWA.createElement('table', {
                    'class' : '',
                    'id' : '',
                    'width' : '100%'
                }).inject(applyDiv);

                lineButtons = UWA.createElement('tr').inject(tableButtons);  // tbody

                buttonApplyCell = UWA.createElement('td', {
                    'width' : '50%',
                    'Align' : 'center'
                }).inject(lineButtons);

                applyBttn =  new Button({
                    className: 'primary',
                    id : 'buttonExport',
                    icon : 'export',//'download'//value: 'Button',             
                    attributes: {
                        disabled: false,
                        title: ParamSkeletonNLS.ApplyLifecyleTooltip,
                        text : ParamSkeletonNLS.Apply
                    },
                    events: {
                        onClick: function () {
                            that.applyParams();
                        }
                    }
                }).inject(buttonApplyCell);
                //
                applyBttn.getContent().setStyle("width", 110);
                //
                buttonResetCell = UWA.createElement('td', {
                    'width' : '50%',
                    'Align' : 'center'
                }).inject(lineButtons);
                //
                resetBbttn = new Button({
                    className: 'warning',
                    icon: 'loop',
                    attributes: {
                        disabled: false,
                        title: ParamSkeletonNLS.ResetLifecycle,
                        text : ParamSkeletonNLS.Reset
                    },
                    events: {
                        onClick: function () {
                            that.resetParamsinSession();//testPreviewBlock();                               
                        }
                    }
                }).inject(buttonResetCell);
                //
                resetBbttn.getContent().setStyle("width", 110);
            },

			//NZV - IR-499665-3DEXPERIENCER2017x/IR-538770-3DEXPERIENCER2018x 
            removeElement : function () {
                var e, stateNodeFound = false, eltRemoved = false, isCritical = false;
                for (e = this.grph.selection.first; e; e = e.nextSel) {
                    if ((e.type === core.Type.NODE) &&
                            !e.hidden) {
                        eltRemoved = true;
                        if (e.isCritical == "true") {
                            this.userMessaging.add({
                                className: "warning",
                                message : ParamSkeletonNLS.StateCriticalText.format(e.name)
                            });
                            isCritical = true;
                            break;
                        } else {
                            stateNodeFound = true;
                        }
                    } else if ((e.type === core.Type.EDGE) && !e.hidden) {
                        eltRemoved = true;
                    }
                }
                if (!isCritical && eltRemoved && stateNodeFound) { //IR-689657-3DEXPERIENCER2019x
                    ParametersLayoutViewUtilities.showContextualDeleteModal(widget.body, "delAttrModal", ParamSkeletonNLS.removeStatesWarning, 
                        ParamSkeletonNLS.RemoveElement, ParamSkeletonNLS.CancelButton, ParamSkeletonNLS.ConfirmDelete, this.removeStatesAndTransitions, this);
                } else if (!isCritical && eltRemoved) {
                    this.removeStatesAndTransitions(this);
                } else if (!eltRemoved) {
                    this.userMessaging.add({className: "warning", message: ParamSkeletonNLS.NoObjectedSelectedrmText});
                }
            },

            removeStatesAndTransitions: function (that) {
                var e, cantrmTransition,
                    //eltRemoved = false,
                    eltstoDelete = [],
                    tbodyref = that.contentDiv.getElements('.paramtbody')[0];

                if (that.model.get("modifyTopology")) {

                    LifecycleEgraphUtilities.removePropsNode();

                    for (e = that.grph.selection.first; e; e = e.nextSel) {
                        if ((e.type === core.Type.NODE  ||
                                e.type === core.Type.EDGE) &&
                                !e.hidden) {

                            eltstoDelete.push(e);
                        }
                    }

                    that.grph.updateLock();
                    try {
                        UWA.log("delete");
                        eltstoDelete.forEach(function (e) {

                            if (e.type === core.Type.NODE) {
                                //eltRemoved = true;
                                // 
                                /*if (e.isCritical == "true") {
                                    that.userMessaging.add({
                                        className: "warning",
                                        message : ParamSkeletonNLS.StateCriticalText.format(e.name)
                                    });
                                } else*/ 
                                //{
                                console.log(e);
                                LifecycleViewUtilities.removeRelatedChecksForState(e.stateid, tbodyref);
                                e.remove();
                                that.handledeployIndicator();
                                //}
                            } else if (e.type === core.Type.EDGE) {
                                //eltRemoved = true;

                                if (e.isCritical == "true") {
                                    cantrmTransition = ParamSkeletonNLS.TransitionCriticalText.format(e.cl1.c.node.name, e.cl2.c.node.name);
                                    that.userMessaging.add({className: "warning", message: cantrmTransition});
                                } else {
                                    LifecycleViewUtilities.removeRelatedChecksForTransition(e.cl1.c.node.stateid, e.cl2.c.node.stateid, tbodyref);

                                    if (that.grph.appCategory === "CBP") {
                                        that.handleTransitionRemovalForCBP(e.cl1.c.node, e.cl2.c.node);
                                    }
                                    e.remove();
                                    that.handledeployIndicator();
                                }
                            }
                        });//forEach

                    } finally {
                        that.grph.updateUnlock();
                    }
                    //
                    /*if (!eltRemoved) {
                        that.userMessaging.add({className: "warning", message: ParamSkeletonNLS.NoObjectedSelectedrmText});
                    }*/
                } else {
                    that.userMessaging.add({className: "warning", message: ParamSkeletonNLS.TopologyNotModifiable});
                }
            },


            handledeployIndicator : function () {
                var tbodyreflist = this.contentDiv.getElements('.indicatortbody'),
                    imgCell = LifecycleViewUtilities.getNamingDeployCellSts(tbodyreflist);//"nameDeployIndicator"

                LifecycleViewUtilities.beingModified(imgCell, ParamSkeletonNLS.Being_Modified);
            },

            handleTransitionRemovalForCBP : function (fromNode, toNode) {

                var e, listofEdges,
                    nbofOutTrans = 0,
                    xdiff = toNode.left - fromNode.left,
                    iPositions = Math.round(xdiff /  this.grph.nodeSpacing);

                if (iPositions > 1) {
                    listofEdges = this.grph.edges;
                    for (e = listofEdges.first; e; e = e.next) {
                        if (e.cl1.c.node.stateid === fromNode.stateid) {
                            nbofOutTrans++;
                        }
                    }

                    if (nbofOutTrans == 2) {
                        for (e = listofEdges.first; e; e = e.next) {
                            xdiff = e.cl2.c.node.left - e.cl1.c.node.left;
                            iPositions = Math.round(xdiff / this.grph.nodeSpacing);
                            UWA.log("from : " + e.cl1.c.node.stateid + " to : " + e.cl2.c.node.stateid + " :: " + iPositions);

                            if (iPositions === 1) {
                                if (e.signature !== "") {
                                    e.signature = "";
                                    e.signatureNLS = "";
                                    break;
                                }
                            }
                        }
                    }
                }// of if (iPositions > 1)

            },

            /*
            removeElement_old : function () {
                UWA.log("inside removeElement");
                var i, itr,
                    cantrmTransition,
                    that = this,
                    nodesLength = that.nodes.length,
                    eltRemoved = false,
                    tbodyref = this.contentDiv.getElements('.paramtbody')[0];
                //
                if (that.model.get("modifyTopology")) {
                    for (i = 0;  i < nodesLength; i++) {
                        if (that.nodes[i].isSelected()) {
                            eltRemoved = true;
                            //
                            if (that.nodes[i].isCritical == "true") {
                                that.userMessaging.add({
                                    className: "warning",
                                    message : ParamSkeletonNLS.StateCriticalText.format(that.nodes[i].name)
                                });
                            } else {
                                that.nodes[i].remove();
                                that.removeRelatedChecksForState(that.nodes[i].stateid, tbodyref);
                            }
                        }
                    }

                    var transitionList = that.grph.edges;
                    for (itr = transitionList.first; itr; itr = itr.next) {
                        if (itr.isSelected() == true) {
                            eltRemoved = true;
                            //
                            if (itr.isCritical == "true") {
                                cantrmTransition = ParamSkeletonNLS.TransitionCriticalText.format(itr.cl1.c.node.name, itr.cl2.c.node.name);
                                that.userMessaging.add({className: "warning", message: cantrmTransition});
                            } else {
                                LifecycleViewUtilities.removeRelatedChecksForTransition(itr.cl1.c.node.stateid, itr.cl2.c.node.stateid, tbodyref);
                                itr.remove();
                            }
                        }
                    }
                    //
                    if (!eltRemoved) {
                        this.userMessaging.add({className: "warning", message: ParamSkeletonNLS.NoObjectedSelectedrmText});// + ' - ' + new Date();
                    }
                } else {
                    this.userMessaging.add({className: "warning", message: ParamSkeletonNLS.TopologyNotModifiable});
                }
            },*/

            restoreStates : function () {
                var warningNoRemovedStates, headertitle,
                    OKBtn, CancelBtn,
                    StatesListSelect,
                    restoreStsModal,
                    i,
                    that = this,
                    removedStates = this.getRemovedStatesList(),
                    nbofRemovedStates = removedStates.length;

                if (nbofRemovedStates === 0) {
                    warningNoRemovedStates = ParamSkeletonNLS.NoStatesRemoved;
                    that.userMessaging.add({className: "warning", message: warningNoRemovedStates});
                } else {
                    StatesListSelect =  new Select({
                        nativeSelect: true,
                        placeholder: false,
                        multiple: true
                    });
                    //
                    headertitle = UWA.createElement('h4', {
                        text   : ParamSkeletonNLS.SelectStateToRestore,//NZV-IR-613104-3DEXPERIENCER2019x
                        'class': 'font-3dslight' // font-3dsbold
                    });
                    //
                    OKBtn = new Button({
                        value : ParamSkeletonNLS.OKButton,
                        className : 'btn primary',
                        events : {
                            'onClick' : function() {
                                var selectedStates = StatesListSelect.getValue();//.getValue()[0]
                                that.restoreStatesinSession(selectedStates);
                                that.handledeployIndicator();
                            }
                        }
                    });
                    //    
                    CancelBtn = new Button({
                        value : ParamSkeletonNLS.CancelButton,
                        className : 'btn default',                        
                        events : {
                            'onClick' : function(e) {
                                that.onCancelCalled(e);
                            }
                        }
                    });
                    /*"<button type='button' class='btn btn-primary'>OK</button> " +
                    "<button type='button' class='btn btn-default'>Annuler</button>"*/

                    for (i = 0; i < nbofRemovedStates; i++) {
                        StatesListSelect.add([{
                            label: removedStates[i].name,
                            value: removedStates[i].stateid
                        }]);
                    }
                    //
                    restoreStsModal = new Modal({
                        className: "restore-sts-modal",
                        closable: true,
                        header: headertitle,
                        body:   StatesListSelect,
                        footer: [ OKBtn, CancelBtn ]
                    }).inject(that.contentDiv);
                    //
                    restoreStsModal.getContent().setStyle("padding-top", 90);
                    restoreStsModal.show();
                    //
                    restoreStsModal.getContent().getElements(".btn").forEach(function (element) {
                        element.addEvent("click", function () {
                            restoreStsModal.hide();
                        });
                    });
                }//of else if nbofRemovedStates

            },

            showAddElementsModal : function() {
                var itr, i, e,
                    headertitle,
                    sortedTypes, listofRulesForType, ruleTextID,
                    selectedRule, additionalInfo, additionalInfoNLS,
                    nbofTypes, selectHiddenCell,
                    tbodyref, isCheckAdded,
                    modalbodyTable, modaltbody,
                    lineModal,
                    typeTextCell, selectCell,
                    RulesListSelect,
                    lineComplModal, complementarySelect,
                    OKBtn, CancelBtn,
                    TypesListSelect, listofAttrs,
                    that = this,
                    transitionList = that.grph.edges,
                    addCheckAttrOK = true,
                    isTransitionSelected = false;

                for (e = this.grph.selection.first; e; e = e.nextSel) {
                    if (e.type === core.Type.EDGE) {
                        isTransitionSelected = true;
                        break;
                    }
                }
                // loop on the added elements and log them in the console
                /*for (itr = transitionList.first; itr; itr = itr.next) {
                    if (itr.isSelected()) {
                        isTransitionSelected = true;
                        break;
                    }
                }*/

                if (!isTransitionSelected) {
                    that.userMessaging.add({className: "warning", message: ParamSkeletonNLS.NoTransitionSelected});
                } else {
                    LifecycleEgraphUtilities.removePropsNode();
                    if (that.RulesModal !== null) {
                        that.RulesModal.show();//Modal already exists
                    } else {
                        headertitle = UWA.createElement('h4', {
                            text   : ParamSkeletonNLS.AddNewRule,
                            'class': 'font-3dslight' // font-3dsbold
                        });

                        sortedTypes = LifecycleViewUtilities.sortArrayByKey(that.collection._models[0]._attributes.types, "typeNLS");
                        nbofTypes = sortedTypes.length;

                        //if (( !== '') && (!== undefined))

                        modalbodyTable =  UWA.createElement('table', {
                            'id': '',
                            'class': 'table table-condensed table-hover'
                        });
                        modaltbody = UWA.createElement('tbody', {
                            'class': ''
                        }).inject(modalbodyTable);
                        lineModal = UWA.createElement('tr').inject(modaltbody);
                        //
                        typeTextCell = UWA.createElement('td', {
                            'Align' : 'left',
                            'width' : '15%'
                        }).inject(lineModal);

                        UWA.createElement('p', {
                            text   : ParamSkeletonNLS.DataTypeLabel,// font-3dsbold
                            'class': 'font-3dslight'
                        }).inject(typeTextCell);

                        selectCell = UWA.createElement('td', {
                            'Align' : 'left'
                        }).inject(lineModal);

                        lineComplModal = UWA.createElement('tr');

                        TypesListSelect =  new Select({
                            nativeSelect: true,
                            placeholder: false,
                            multiple: false
                        }).inject(selectCell);

                        for (i = 0; i < nbofTypes; i++) {
                            TypesListSelect.add([{
                                label: sortedTypes[i].typeNLS,
                                value: sortedTypes[i].typeID
                            }]);
                        }
                        //Complementary Select
                        complementarySelect =  new Select({
                            nativeSelect: true,
                            placeholder: false,
                            multiple: false
                        });

                        lineModal = UWA.createElement('tr').inject(modaltbody);

                        typeTextCell = UWA.createElement('td', {
                            'Align' : 'left',
                            'width' : '15%'
                        }).inject(lineModal);

                        UWA.createElement('p', {
                            text   : ParamSkeletonNLS.Rulelabel,// font-3dsbold
                            'class': 'font-3dslight'
                        }).inject(typeTextCell);

                        selectCell = UWA.createElement('td', {
                            'Align' : 'left'
                        }).inject(lineModal);

                        RulesListSelect =  new Select({
                            nativeSelect: true,
                            placeholder: false,
                            multiple: false
                            /*events: {
                                'onChange' : function () {
                                    if (this.getValue()[0] === "RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState") {
                                        lineComplModal.show();
                                        LifecycleViewUtilities.populateAddInfoSelect(complementarySelect, TypesListSelect.getValue(), sortedTypes);
                                    } else {
                                        lineComplModal.hide();
                                    }
                                }
                            }*/
                        }).inject(selectCell);


                        //pour l'initalisation
                        listofRulesForType = sortedTypes[0].listofRules.split(',');

                        for (i = 0; i < listofRulesForType.length; i++) {
                            //if (listofRulesForType[i] !== "RejectIfAttributeNotValuated") {
                            ruleTextID = listofRulesForType[i] + "Text";

                            RulesListSelect.add([{
                                label: ParamSkeletonNLS[ruleTextID],
                                value: listofRulesForType[i]
                            }]);
                            //}
                        }

                        RulesListSelect.addEvent("onChange", function () {
                            if (this.getValue()[0] === "RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState") {
                                lineComplModal.show();
                                LifecycleViewUtilities.populateAddInfoSelect(complementarySelect, TypesListSelect.getValue(), sortedTypes);
                            } else if (this.getValue()[0] === "RejectIfAttributeNotValuated") {
                                lineComplModal.show();
                                listofAttrs = LifecycleViewUtilities.getListofAttributesForType(TypesListSelect.getValue(), sortedTypes);
                                LifecycleViewUtilities.populateAttributesSelector(complementarySelect, listofAttrs);
                            } else {
                                lineComplModal.hide();
                            }
                        });

                        TypesListSelect.addEvent("onChange", function () {
                            lineComplModal.hide();
                            LifecycleViewUtilities.updateRulesListforType(RulesListSelect, this.getValue(), sortedTypes);
                        });

                        typeTextCell = UWA.createElement('td', {
                            'Align' : 'left',
                            'width' : '15%'
                        }).inject(lineComplModal);

                        UWA.createElement('p', {
                            text   : ParamSkeletonNLS.ConsiderChildType,// font-3dsbold
                            'class': 'font-3dslight'
                        }).inject(typeTextCell);

                        selectHiddenCell = UWA.createElement('td', {
                            'Align' : 'left'
                        }).inject(lineComplModal);

                        complementarySelect.inject(selectHiddenCell);
                        lineComplModal.inject(modaltbody);
                        lineComplModal.hide();

                        OKBtn = new Button({
                            value : ParamSkeletonNLS.OKButton,
                            className : 'btn primary',
                            events : {
                                'onClick' : function() {
                                    //var selectedStates = StatesListSelect.getValue();//.getValue()[0]
                                    //that.restoreStatesinSession(selectedStates);//StatesListSelect.getValue()
                                    tbodyref = that.contentDiv.getElements('.paramtbody');
                                    addCheckAttrOK = true;

                                    for (itr = transitionList.first; itr; itr = itr.next) {
                                        if (itr.isSelected() === true) {
                                            //var readTypeVal = TypesListSelect.getValue();
                                            //var readTypeNAme = TypesListSelect.getName();
                                            /*UWA.log("complementary");
                                            UWA.log(complementarySelect.getValue());
                                            UWA.log(lineComplModal.hidden);*/

                                            selectedRule = RulesListSelect.getSelection()[0].value;
                                            additionalInfo = "NOINFO";
                                            additionalInfoNLS = "";
                                            //
                                            if (selectedRule === "RejectIfAnyOfTheCommonlyGovernedChildNotOnTargetState") {
                                                additionalInfo = complementarySelect.getSelection()[0].value;
                                                additionalInfoNLS = ParamSkeletonNLS.ConsiderKey.format(complementarySelect.getSelection()[0].label);
                                            }

                                            //ZUR IR-496665-3DEXPERIENCER2017x
                                            if (selectedRule === "RejectIfAttributeNotValuated") {
                                                if (complementarySelect.getOptions().length > 0) {
                                                    additionalInfo = complementarySelect.getSelection()[0].value;
                                                    additionalInfoNLS = ParamSkeletonNLS.ConsiderKey.format(complementarySelect.getSelection()[0].label);
                                                } else {
                                                    that.userMessagingDrag.add({className: "warning", message: ParamSkeletonNLS.NoCustoAttributesAdded});
                                                    addCheckAttrOK = false;
                                                }
                                            }
                                            //var tbodyref = this.contentDiv.getElements('.paramtbody')[0];
                                            isCheckAdded = LifecycleViewUtilities.isCheckAlreadyAdded(TypesListSelect.getSelection()[0].value,
                                                itr.cl1.c.node.stateid, itr.cl2.c.node.stateid,
                                                selectedRule, additionalInfo,
                                                tbodyref[0]);

                                            if (addCheckAttrOK) {
                                                if (!isCheckAdded) {

                                                    that.addChecktoTable(tbodyref[0],
                                                        TypesListSelect.getSelection()[0].value, TypesListSelect.getSelection()[0].label,
                                                        itr.cl1.c.node.stateid, itr.cl1.c.node.name,
                                                        itr.cl2.c.node.stateid, itr.cl2.c.node.name,
                                                        selectedRule,
                                                        additionalInfo, additionalInfoNLS,
                                                        "newcheck");
                                                    that.handledeployIndicator();
                                                } else {
                                                    that.userMessaging.add({className: "error", message: ParamSkeletonNLS.CheckAlreadyAdded});
                                                }
                                            }
                                        }
                                    }//of for loop
                                }//of onclick
                            }//events
                        });

                        CancelBtn = new Button({
                            value : ParamSkeletonNLS.CancelButton,
                            className : 'btn default',
                            events : {
                                'onClick' : function(e) {
                                    UWA.log(e);//that.onCancelCalled();
                                }
                            }
                        });

                        that.RulesModal = new Modal({
                            className: "restore-sts-modal",
                            closable: true,
                            header  : headertitle,
                            body    : modalbodyTable,
                            footer  : [ OKBtn, CancelBtn ]
                        }).inject(that.contentDiv);

                        that.RulesModal.getContent().setStyle("padding-top", 90);
                        that.RulesModal.show();

                        that.RulesModal.getContent().getElements(".btn").forEach(function (element) {
                            element.addEvent("click", function () {
                                that.RulesModal.hide();
                            });
                        });
                    }
                }
            },

            restoreStatesinSession : function(ilistofStates) {
                var iRestore, i,
                    that = this,
                    nbofStatestoRestore = ilistofStates.length,
                    nodesLength = that.nodes.length;

                for (iRestore = 0; iRestore < nbofStatestoRestore; iRestore++) {
                    for (i = 0; i < nodesLength; i++) {
                        if (that.nodes[i].stateid == ilistofStates[iRestore]) {
                            that.grph.addNode(that.nodes[i]);
                            UWA.log("State Restored " + ilistofStates[iRestore]);
                            break;
                        }
                    }
                }
            },

            onCancelCalled : function(x) {
                UWA.log("onCancelCalled" + x);
            },

            getRemovedStatesList : function () {
                var i,
                    ArrayNodeList = [],
                    nodesLength = this.nodes.length,
                    k = 0;

                for (i = 0; i < nodesLength; i++) {
                    if (this.nodes[i].parent === null) {
                        ArrayNodeList[k++] = this.nodes[i];
                    }
                }
                return ArrayNodeList;
            },

            destroy : function() {
                UWA.log("LifecycleView::destroy");
                this.stopListening();
                this._parent.apply(this, arguments);
            }

        });

        return extendedView;
    });

/*@fullReview  CN1 18/05/15 2019xBeta2 Mapping Widget*/
/*global define, widget, document, setTimeout, console*/
/*jslint plusplus: true*/
/*jslint nomen: true*/
define('DS/ParameterizationSkeleton/Views/ParameterizationMapping/MappingViewUtilities',
		[
		 'UWA/Core',
		 'UWA/Controls/Accordion',
		 'DS/UIKIT/Accordion',
		 'DS/UIKIT/Input/Button',
		 'DS/UIKIT/Input/Select',
		 'DS/UIKIT/Input/Toggle',
		 'DS/UIKIT/Modal',
		 'DS/UIKIT/Alert',
		 'DS/UIKIT/Popover',
		 'DS/UIKIT/Tooltip',
		 'DS/UIKIT/Spinner',
		 'DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
		 'i18n!DS/ParameterizationSkeleton/assets/nls/MappingManagementNLS',
		 ],
		 function (UWA,
				 UWAccordion, Accordion,
				 Button, Select, Toggle,
				 Modal,
				 Alert, Popover,Tooltip, Spinner, ParametersLayoutViewUtilities,
				 MappingManagementNLS) {

	'use strict';

	var UIview = {

			init : function () {
				this.cellsAttrIndex = [];
				this.cellsIndex = [];
				
				
			},

			initVariable : function () {
				this.cellsIndex = {
						"kindOfMapping" : 0,
						"VPMObject" : 1,
						"side" : 2,
						"MatrixObject" : 3,
						"action" : 4,
						"deployFlag" : 5,
						"Indexed" : 6,
				};
				this.cellsAttrIndex = {
						//"VPMItf" : 0,
						"VPMAttr" : 0,
						"side" : 1,
						//"MatrixItf" : 3,
						"MatrixAttr" : 2,
						"action" : 3,
						"deployFlag" : 4,
				};
				
				this.direction =  {
						"BOTH" : "<=>",
						"VPM_To_MX" : "=>",
						"MX_To_VPM" : "<=",
				};
				
				this.enumType = "enum";
				//this.MxAttrOnlysAsSource = [ "Modified","Originated", "Policy" , "Revision" ,  "Current" ];
				this.PartAttrAsTarget = [ "Part Classification","Material Category", "Production Make Buy Code" , "Service Make Buy Code" ,  "Unit of Measure", "Description", "Estimated Cost","Target Cost", "Lead Time","Spare Part","End Item","End Item Override Enabled","Lead Time Duration" ];
				this.VPMAttrAsTarget = [ "PLMReference.V_versionComment","PLMEntity.V_description"];
			},


			/*createAddMappingToolBar : function (insertdivID,  ShowAddMappingPanel) {
				var selectMappingDiv, tableAddMapping, lineAddMapping, selectMappingCell, selectMapping,
				CellAddMappingButton, AddMappingButton, that=this;
				//that = this;
				//resetwidth = '100%';

				selectMappingDiv =  UWA.createElement('div', {
					'id': 'selectMappingDiv'
				}).inject(insertdivID);
				//                            
				tableAddMapping = UWA.createElement('table', {
					'class' : '',
					'id' : '',
					'width' : '100%'
				}).inject(selectMappingDiv);

				lineAddMapping = UWA.createElement('tr').inject(tableAddMapping);//tbody


				selectMappingCell = UWA.createElement('td', {
					'width' : '80%',
					'Align' : 'left'
				}).inject(lineAddMapping);

				selectMapping = new Select({
					nativeSelect: true,
					className: 'SelectTypeMapping',
					placeholder: "Select your mappping",
					options: [
					          { value: "1", label: "Type" },
					          { value: "2", label: "Relationship" },
					          ]
				}).inject(selectMappingCell);



				CellAddMappingButton = UWA.createElement('td', {
					'width' : '20%',
					'Align' : 'left'//center
				}).inject(lineAddMapping);

				AddMappingButton = new Button({
					className: 'AddMappingButton',
					icon: 'plus-circled',
					attributes: {
						disabled: false,
						'aria-hidden' : 'true',
						title : 'AddMapping'
					},
					events: {
						onClick: function () {
							//that.resetParamsinSession();//testPreviewBlock();                               
							ShowAddMappingPanel(selectMapping.value);
						}
					}
				}).inject(CellAddMappingButton);

				return selectMapping;
			},*/



			buildAttributeLine : function (VPMTypeRelInfo ,MatrixTypeRelInfo ,kindOfMapping,attributeMapping,listofAttributesMapping,widthTable) {
				var iCell, removeAttributeButton, deleteSpan, removePop,position,
				actionButton = [],//editElts = [], 
				lineAttr = UWA.createElement('tr', {'class': 'AttrLineMapping'}),
				itfVPM= "",
				attrVPM=attributeMapping.VPMAttribute.id,
				attrVPMInfo,
				attrVPMName = attributeMapping.VPMAttribute.name,
				side=attributeMapping.SynchDirection,
				itfMatrix="",
				attrMatrix=attributeMapping.MatrixAttribute.id,
				attrMatrixInfo,
				attrMatrixName=attributeMapping.MatrixAttribute.name,
				status=attributeMapping.status,
				isBaseMapping = attributeMapping.isBaseMapping.toString(),
				that = this;

				if(attributeMapping.VPMAttribute.itf !== undefined && attributeMapping.VPMAttribute.itf !=="") itfVPM = attributeMapping.VPMAttribute.itf;
				
				if(attributeMapping.MatrixAttribute.itf !== undefined && attributeMapping.MatrixAttribute.itf!="") itfMatrix = attributeMapping.MatrixAttribute.itf;
				

				UIview.initVariable();

				/*iCell = UWA.createElement('td', {
					'Align' : 'left',
					'width' : widthTable[0],
					'value'  : itfVPM,
					'class': 'attributeMappingField font-3dslight'// font-3dsbold
				}).inject(lineAttr);

				UWA.createElement('p', {
					text   : itfVPM,
				}).inject(iCell);*/

				iCell = UWA.createElement('td', {
					'Align'  : 'left',
					'width'  : widthTable[0],
					'value'  : attrVPM,
					'class': 'attributeMappingField font-3dslight'// font-3dsbold
				}).inject(lineAttr);

				UWA.createElement('p', {
					text   : attrVPMName,
					value  : attrVPM,
				}).inject(iCell);

				var txtSide =MappingManagementNLS.both;
				if(side=="BOTH")
					txtSide = MappingManagementNLS.both;
				else if (side=="VPM_To_MX")
					txtSide =MappingManagementNLS.unilateralDirection.format(VPMTypeRelInfo.name,MatrixTypeRelInfo.name);
				else if (side=="MX_To_VPM")
					txtSide =MappingManagementNLS.unilateralDirection.format(MatrixTypeRelInfo.name,VPMTypeRelInfo.name);

				/*iCell = UWA.createElement('td', {
					'Align' : 'left',
					'width' :widthTable[1],
					'value' : txtSide,
					'class': 'attributeMappingField font-3dslight'// font-3dsbold
				}).inject(lineAttr);*/
				
				iCell = UWA.createElement('td', {
					'width' : widthTable[1], 
					'align' : 'left',
					'title' : txtSide,
					'value' : side,
					'class': 'attributeMappingField font-3dslight'// font-3dsbold
				}).inject(lineAttr);

				/*imgSpan = UWA.createElement('span', {
					'class' : imgClass
				}).inject(iCell);
				iCell.setStyle("vertical-align", "text-bottom");*/
				var imgSpanRight = UWA.createElement('span', {
					'class' : 'fonticon  fonticon-expand-right'
				})
				
				var imgSpanLeft = UWA.createElement('span', {
					'class' : 'fonticon  fonticon-expand-left'
				})
				
				if(side=="BOTH")
				{
					imgSpanLeft.inject(iCell);
					imgSpanRight.inject(iCell);		
				}
				else if (side=="VPM_To_MX")
					imgSpanRight.inject(iCell);
				else if (side=="MX_To_VPM")
					imgSpanLeft.inject(iCell);
				
				iCell.setStyle("vertical-align", "text-bottom");

				/*UWA.createElement('p', {
					text   : txtSide,
				}).inject(iCell);*/


			/*	iCell = UWA.createElement('td', {
					'Align' : 'left',
					'width' : widthTable[3],
					'value'  : itfMatrix,
					'class': 'attributeMappingField font-3dslight'// font-3dsbold
				}).inject(lineAttr);

				UWA.createElement('p', {
					text   : itfMatrix,
				}).inject(iCell);*/

				iCell = UWA.createElement('td', {
					'Align'  : 'left',
					'width'  : widthTable[2],
					'value'  : attrMatrix,
					'class': 'attributeMappingField font-3dslight'// font-3dsbold
				}).inject(lineAttr);

				UWA.createElement('p', {
					text   : attrMatrixName,
					value  : attrMatrix,
				}).inject(iCell);


				iCell = UWA.createElement('td', {
					'Align' : 'left',
					'width' : widthTable[3],
					'class': 'attributeMappingField font-3dslight'// font-3dsbold
				}).inject(lineAttr);
				
				if(isBaseMapping==="false")
				{
					actionButton = UIview.createDeleteModifyActionsIcon(iCell);
					
					
					actionButton.addEvent("onClick", function (e) {
						UIview.removeAttrLineCallBack(lineAttr,attributeMapping,listofAttributesMapping);

					});
					
					/*actionButton[1].addEvent("onClick", function (e) {
					UIview.ShowModifyDirectionPanel.call(that,lineAttr,VPMType,MatrixType,attributeMapping,kindOfMapping);
					});*/
				}

				var isDeployed ;
				if(status==="New") isDeployed ="NewNotDeployed";
				else
				isDeployed = (status==="Deployed")? 'true':'false';
				
				//iCell = ParametersLayoutViewUtilities.buildDeployStsCell(isDeployed.toString(), widthTable[4], '1.5', 'center');
				
				
				
				
				var invalidStoredMapping = false;
				var messageInvalidStoredMapping = "";

				if (isDeployed === "false")
				{
					
					
					if(!attributeMapping.VPMAttribute.deployed  || !attributeMapping.MatrixAttribute.deployed) 
					{
						invalidStoredMapping = true;
						messageInvalidStoredMapping = MappingManagementNLS.NonDeployedAttribute;
					}

					attrVPMInfo = UIview.retrieveAttributeInfo(VPMTypeRelInfo,attrVPM );
					attrMatrixInfo = UIview.retrieveAttributeInfo(MatrixTypeRelInfo,attrMatrix );
					if(attrVPMInfo!=undefined && attrMatrixInfo!=undefined)
					{
						var result = UIview.CheckIsSameAttrRange(attrVPMInfo.range, attrMatrixInfo.range);
						if(side=="BOTH")
						{
							if(!result.BOTH)
							{
								invalidStoredMapping=true;
								messageInvalidStoredMapping += result.message.BOTH; 
							}
						}
						else if (side=="VPM_To_MX")
						{
							if(!result.VPM_To_MX)
							{
								invalidStoredMapping=true;
								messageInvalidStoredMapping += result.message.VPM_To_MX; 
							}
						}
						else if (side=="MX_To_VPM")
						{
							if(!result.MX_To_VPM)
							{
								invalidStoredMapping=true;
								messageInvalidStoredMapping += result.message.MX_To_VPM; 
							}
						}
					}
				}

				var imgSpan,
				imgTitle = MappingManagementNLS.deployedParamtxt,
				imgClass = 'fonticon fonticon-' + '1.5' + 'x fonticon-check',
				iconColor = 'green',
				iconSize = '1.5';

				if (isDeployed === "false") {
					imgClass = 'fonticon fonticon-' + iconSize + 'x fonticon-cog';
					if(!invalidStoredMapping)
					{
						imgTitle =  MappingManagementNLS.notdeployedParamtxt;
						iconColor = 'orange';
					}
					else
					{
						imgTitle = messageInvalidStoredMapping;
						iconColor = 'red';
						attributeMapping.status = "InvalidStored";
					}
				} else if (isDeployed === "NewNotDeployed") {
					imgClass = 'fonticon fonticon-' + iconSize + 'x fonticon-cog';
					imgTitle =  MappingManagementNLS.newNotdeployedParam;
					iconColor = 'black';
				}

				iCell = UWA.createElement('td', {
					'width' : widthTable[4], 
					'align' : 'center',
					'title' : imgTitle
				});

				imgSpan = UWA.createElement('span', {
					'class' : imgClass
				}).inject(iCell);

				imgSpan.setStyle("color", iconColor);
				iCell.setStyle("vertical-align", "text-bottom");

				/*if (status==="deployed") {
					iCell.value  = "Deployed";
				} 
				else if (status === "StoredButNotDeployed")
					iCell.value  = "StoredButNotDeployed";
				else iCell.value  = "NewNotDeployed";*/
				
				
			 
				iCell.value = status;
				iCell.inject(lineAttr);

				//if(status==="RemovedbyImport")
				if(status.indexOf("Removed")!==-1)
					UIview.setToRemoveAttrLine(lineAttr);

				return lineAttr;
			},


			buildAttributeTableHeading : function (widthTable) {
				var lineTitle,iCell;

				lineTitle = UWA.createElement('tr', {
					'class' : 'success'
				});

				/*iCell = UWA.createElement('td', {'class':'colMappingAttr',
					'Align' : 'left',
					'width' : widthTable[0],
				}).inject(lineTitle);

				UWA.createElement('h5', {
					text   : MappingManagementNLS.ProductItf
				}).inject(iCell)*/

				iCell = UWA.createElement('td', {
					'Align' : 'left',
					'width' : widthTable[0],
				}).inject(lineTitle);

				UWA.createElement('h5', {
					text   : MappingManagementNLS.ProductAttr
						//'class': 'font-3dslight'// font-3dsbold
				}).inject(iCell);


				iCell = UWA.createElement('td', {
					'Align' : 'left',
					'width' : widthTable[1],
				}).inject(lineTitle);

				UWA.createElement('h5', {
					text   : MappingManagementNLS.side
						//'class': 'font-3dslight'// font-3dsbold
				}).inject(iCell);

				/*iCell = UWA.createElement('td', {
					'Align' : 'left',
					'width' : widthTable[3],
				}).inject(lineTitle);

				UWA.createElement('h5', {
					text   : MappingManagementNLS.PartItf
						//'class': 'font-3dslight'// font-3dsbold
				}).inject(iCell);*/

				iCell = UWA.createElement('td', {
					'Align' : 'left',
					'width' : widthTable[2],
				}).inject(lineTitle);

				UWA.createElement('h5', {
					text   : MappingManagementNLS.PartAttr
						//'class': 'font-3dslight'// font-3dsbold
				}).inject(iCell);

				iCell = UWA.createElement('td', {
					'Align' : 'left',
					'width' : widthTable[3],
				}).inject(lineTitle);

				UWA.createElement('h5', {
					text   : MappingManagementNLS.actions
						//'class': 'font-3dslight'// font-3dsbold
				}).inject(iCell);

				iCell = UWA.createElement('td', {
					'Align' : 'left',
					'width' : widthTable[4],
				}).inject(lineTitle);

				UWA.createElement('h5', {
					text   : MappingManagementNLS.deployStatus
						//'class': 'font-3dslight'// font-3dsbold
				}).inject(iCell);

				return lineTitle;
			},


			buildMappingLine : function (/*kindOfMapping, VPMType, side, MatrixType, isBaseMapping, status*/eltmapping)
			{

				var MatrixType,VPMType, side, kindOfMapping ,isBaseMapping,status  ,mappingTable,lineMapping,txtSide,iCell,deleteIcon,deleteAction,deleteSpan,
				removeLineMappingButton,removePropMappingButton,attributeMappingDiv,attributesTable,mappingTable,actionCol,modifySpan,modifyAttributeButton,modifyPop,modifySpan, MatrixTypeName, VPMTypeName, that=this;
				UIview.initVariable();

				MatrixType = eltmapping.MatrixObject;
				VPMType = eltmapping.VPMObject;
				MatrixTypeName = eltmapping.MatrixObjectName;
				VPMTypeName = eltmapping.VPMObjectName;
				side  = eltmapping.SynchDirection;
				kindOfMapping = eltmapping.KindOfMapping.toLowerCase();
				isBaseMapping = eltmapping.isBaseMapping.toString();
				status = eltmapping.status;
				mappingTable = UWA.createElement('table', {
					'class': 'tableMapping'
				});//table-bordered

				lineMapping = UWA.createElement('tr', {
					'class' : 'lineMapping'
				}).inject(mappingTable);

				UWA.createElement('td', {'class': 'colMappingType', 'text': "", 'value':""}).inject(lineMapping);

				UWA.createElement('td', {'class': 'colMappingVPMObject', 'text':VPMTypeName, 'value':VPMType}).inject(lineMapping);

				if(side=="BOTH")
					txtSide="<=>";
				else if (side=="VPM_To_MX")
					txtSide="=>";
				else if (side=="MX_To_VPM")
					txtSide="<=";


				side = UWA.createElement('td', {'class': 'colMappingSide', 'text':txtSide, 'value':side}).inject(lineMapping);

				UWA.createElement('td', {'class': 'colMappingMatrixObject', 'text':MatrixTypeName, 'value':MatrixType}).inject(lineMapping);


			

			/*	if(isBaseMapping==="false")
				{

					actionCol = UWA.createElement('td', {'class': 'colMappingDeleteAction'}).inject(lineMapping);

					deleteAction = ParametersLayoutViewUtilities.createDeleteActionElements("delete line mapping");
					deleteSpan = deleteAction[0];
					removeLineMappingButton = deleteAction[1];
					removePropMappingButton = deleteAction[2];
					deleteSpan.inject(actionCol);

					
					modifySpan = UWA.createElement('span');

					modifyAttributeButton = new Button({
						className: 'close',
						icon: 'fonticon fonticon-pencil fonticon-1.5x',//value: 'Button', //fonticon-cancel  fonticon-minus-circled    
						attributes: {
							disabled: false,
							'aria-hidden' : 'true'
						}
					}).inject(modifySpan);

					modifyPop = new Popover({
						//class: 'parampopover',
						target: modifySpan,//iCell,                        
						trigger : "hover",
						animate: "true",
						position: "top",
						body: "modify direction",
						title: ''//iParamObj.nlsKey
					});

					modifySpan.inject(actionCol);
					
					removeLineMappingButton.addEvent("onClick", function (e) {	
						UIview.removeTypeRelLineCallBack.call(this,lineMapping,eltmapping);
					}.bind(that));
					
				}*/
				var isDeployed = (status==="deployed")? 'true':'false';
				iCell = UWA.createElement('td', {'class': 'colMappingType', 'text': "", 'value':"deployed"}).inject(lineMapping);
				return mappingTable;
			},



			buildAttributeTable : function (VPMTypeRelInfo,MatrixTypeRelInfo,kindOfMapping,listofAttributesMapping,widthTable) {
				var attributesTable, attrtbody, iCell,lineTitle, lineAttribute,j;


				attributesTable = UWA.createElement('table', {
					'class': 'attrTableMapping table table-condensed'
				});//table-bordered

				attrtbody =  UWA.createElement('tbody', {
					'class': 'attrstbodyMapping'
				}).inject(attributesTable);


				lineTitle = UIview.buildAttributeTableHeading(widthTable);
				lineTitle.inject(attrtbody);

				for (j = 0; j < listofAttributesMapping.length; j++) {
					lineAttribute = UIview.buildAttributeLine.call(this,VPMTypeRelInfo,MatrixTypeRelInfo,kindOfMapping,listofAttributesMapping[j],listofAttributesMapping,widthTable);
					lineAttribute.inject(attrtbody);
				}

				return attributesTable;
			},

			retrieveMappingEntry : function (VPMTypeRel, MxTypeRel,/*KindOfMapping,*/ collectionMapping) {
				var EltMapping, foundElt=false, cpt=0;

				while (!foundElt && cpt <collectionMapping.length)
				{
					EltMapping = collectionMapping[cpt];
					if(EltMapping!=undefined)
					{
						if(/*KindOfMapping===EltMapping.KindOfMapping &&*/ VPMTypeRel ===EltMapping.VPMObject &&  MxTypeRel === EltMapping.MatrixObject)
							foundElt=true;
						else cpt++
					}

				}
				if (!foundElt) return undefined;
				else return EltMapping;
			},

			retrieveMappingAttrEntry : function (VPMAttr,MxAttr,attributeMappingList) {
				var EltAttrMapping, foundElt=false, cpt=0, VPMAttrName=VPMAttr, MxAttrName=MxAttr;

				/*if(VPMItf!=undefined && VPMItf!="") 
					VPMAttrName = VPMItf+"."+VPMAttrName;
				
				if(MxItf!=undefined && MxItf!="") 
					MxAttrName = MxItf+"."+MxAttrName;*/
				
				while (!foundElt && cpt <attributeMappingList.length)
				{
					EltAttrMapping = attributeMappingList[cpt];
					if(EltAttrMapping!=undefined)
					{
						if( VPMAttrName ===EltAttrMapping.VPMAttribute.id &&    MxAttrName === EltAttrMapping.MatrixAttribute.id)
							foundElt=true;
						else cpt++
					}

				}
				if (!foundElt) return undefined;
				else return EltAttrMapping;
			},
			
			retrieveAttributeInfo : function (typeRelInfo,attr) {
				var EltAttrInfo, foundElt=false,attributeInfo, cpt=0;
				
				if(attr ==="WCGEquivalentDeclaredWeightExt.V_WCG_Declared_Mass" )
					return {basic:false,id:"WCGEquivalentDeclaredWeightExt.V_WCG_Declared_Mass",itf:"WCGEquivalentDeclaredWeightExt",range:[], type:"Double"};
				
				attributeInfo = typeRelInfo.attributeInfo;

				while (!foundElt && cpt <attributeInfo.length)
				{
					EltAttrInfo = attributeInfo[cpt];
					if(EltAttrInfo!=undefined)
					{
						if( attr.toUpperCase() ===EltAttrInfo.id.toUpperCase())
							foundElt=true;
						else cpt++
					}

				}
				if (!foundElt) return undefined;
				else return EltAttrInfo;
			},


			//Change mapping in Deployed  state to remove State
			setToRemoveAttrLine : function (attrLine) {
				var deployAttrcell,imgAttrSpan,i,arrayAction;

				deployAttrcell=attrLine.cells[UIview.cellsAttrIndex.deployFlag];
				/*for (i = 0; i <= UIview.cellsAttrIndex.MatrixAttr; i++) 
					UIview.setDeletedCellStyle(attrLine.cells[i]);*/
				UIview.setDeletedCellStyle(attrLine.cells[UIview.cellsAttrIndex.VPMAttr]);
				UIview.setDeletedCellStyle(attrLine.cells[UIview.cellsAttrIndex.MatrixAttr]);
				var iconsSide = attrLine.cells[UIview.cellsAttrIndex.side].getElements('span');
				iconsSide.forEach(function(icon){
					icon.setStyle("color", "grey");
				});

				arrayAction = attrLine.cells[UIview.cellsAttrIndex.action].getElements('span');
				arrayAction.forEach(function(action){
					action.hide();
				});

				if(deployAttrcell.value === "Stored" || deployAttrcell.value === "InvalidStored")
				{
					imgAttrSpan = ParametersLayoutViewUtilities.buildImgSpan('trash', '1.5', 'orange');
					deployAttrcell.title = MappingManagementNLS.DeletedStoredNotApplied;
				}
				else
				{
					imgAttrSpan = ParametersLayoutViewUtilities.buildImgSpan('trash', '1.5', 'red');
					deployAttrcell.title = MappingManagementNLS.DeletedNotApplied;
				}

				deployAttrcell.empty();
				deployAttrcell.value = "Removed";

				imgAttrSpan.inject(deployAttrcell);

				//}
			},


			//Change mapping in remove state to deployed state
			unsetRemoveAttrLine : function (attrLine,attributeMapping,listofAttributesMapping) {
				var deployAttrcell,imgAttrSpan,i,actionCell,deleteIcon,actionButton,arrayAction,status, that=this;

				deployAttrcell=attrLine.cells[UIview.cellsAttrIndex.deployFlag];
				actionCell = attrLine.cells[UIview.cellsAttrIndex.action];
				
				var iconsSide = attrLine.cells[UIview.cellsAttrIndex.side].getElements('span');
				iconsSide.forEach(function(icon){
					icon.setStyle("color", "black");
				});

				//
				/*for (i = 0; i <= UIview.cellsAttrIndex.MatrixAttr; i++) 
					UIview.setNormalCellStyle (attrLine.cells[i]);*/
				
				UIview.setNormalCellStyle(attrLine.cells[UIview.cellsAttrIndex.VPMAttr]);
				UIview.setNormalCellStyle(attrLine.cells[UIview.cellsAttrIndex.MatrixAttr]);

				//Add delete action icon and callback
				/*actionButton = UIview.createDeleteModifyActionsIcon(actionCell);
				actionButton[0].addEvent("onClick", function (e) {
					UIview.removeAttrLineCallBack(attrLine,attributeMapping,listofAttributesMapping);
				});
				
				actionButton[1].addEvent("onClick", function (e) {
					UIview.ShowModifyDirectionPanel(that.contentDiv);
					});*/
				
				//actionCell.show();
				
				arrayAction = attrLine.cells[UIview.cellsAttrIndex.action].getElements('span');
				arrayAction.forEach(function(action){
					action.show();
				});
				
				deployAttrcell.empty();

				if(attributeMapping.status === "RemovedStored")
				{
					deployAttrcell.title = MappingManagementNLS.Stored;
					imgAttrSpan = ParametersLayoutViewUtilities.buildImgSpan('cog', '1.5', 'orange');
					deployAttrcell.value = "Stored";
					//Update the mapping model
					attributeMapping.status="Stored";
				}
				else
				{
					deployAttrcell.title = MappingManagementNLS.Deployed;
					imgAttrSpan = ParametersLayoutViewUtilities.buildImgSpan('check', '1.5', 'green');
					deployAttrcell.value = "Deployed";
					//Update the mapping model
					attributeMapping.status="Deployed";
				}

				//Update the UI
	
				imgAttrSpan.inject(deployAttrcell);

				
				//}
			},
			
			
		/*	unsetModifiedAttrLine : function (attrLine,attributeMapping) {
				var deployAttrcell,imgAttrSpan,i,actionCell,arrayAction,directionAttributeCell,direction,that=this;

				deployAttrcell=attrLine.cells[UIview.cellsAttrIndex.deployFlag];
				actionCell = attrLine.cells[UIview.cellsAttrIndex.action];
				directionAttributeCell = attrLine.cells[UIview.cellsAttrIndex.side];
				
				
				if(attributeMapping.OriginalSynchDirection === "BOTH")
					direction = UIview.direction.BOTH;
				else if (attributeMapping.OriginalSynchDirection === "VPM_To_MX")
					direction = UIview.direction.VPM_To_MX;
				else if (attributeMapping.OriginalSynchDirection === "MX_To_VPM")
					direction = UIview.direction.MX_To_VPM;
				else
					direction = UIview.direction.BOTH;


				directionAttributeCell.value=direction;
				directionAttributeCell.empty();
				UWA.createElement('p', {
					text   : direction,
				}).inject(directionAttributeCell);

				
				

				arrayAction = actionCell.getElements('span');
				arrayAction.forEach(function(action){
					action.show();
				});

				//Update the UI
				deployAttrcell.empty();
				
				
				
				if(attributeMapping.status === "ModifiedStored")
				{
					deployAttrcell.title = MappingManagementNLS.Stored;
					imgAttrSpan = ParametersLayoutViewUtilities.buildImgSpan('cog', '1.5', 'orange');
					deployAttrcell.value = "Stored";
					//Update the mapping model
					attributeMapping.status="Stored";
				}
				else
				{
					deployAttrcell.title = MappingManagementNLS.Deployed;
					imgAttrSpan = ParametersLayoutViewUtilities.buildImgSpan('check', '1.5', 'green');
					deployAttrcell.value = "Deployed";
					//Update the mapping model
					attributeMapping.status="Deployed";
				}
				
				attributeMapping.SynchDirection=attributeMapping.OriginalSynchDirection;
				imgAttrSpan.inject(deployAttrcell);
				//}
			},*/




			removeAttrLineCallBack : function (attrLine,attributeMapping,listofAttributesMapping) {
				var /*lineAttrMapping = UWA.Event.findElement(e, '.AttrLineMapping'),*/deployAttrcell;
				if(attrLine!="undefined")
				{
					deployAttrcell=attrLine.cells[UIview.cellsAttrIndex.deployFlag];
					//If mapping in New state, delete the line
					if(deployAttrcell.value==="New")
						attrLine.remove();
					else
						//If mapping in deployed state, change the state and the UI to removed
						UIview.setToRemoveAttrLine(attrLine);
				}
				//Update mapping model
				UIview.removeMappingAttr(attributeMapping,listofAttributesMapping);
				//removePop.destroy();
			},


		/*	removeTypeRelLineCallBack : function (typeLine,typeRelMapping) {
				var title, line, deployCell,custoAccordionItem,i,imgSpan,attrDiv,attrTable,nbofLines,attrLine,deployAttrcell,cptAttr,imgAttrSpan, attrToRemove= new Array(),deployAttrcell;

				deployCell = typeLine.cells[UIview.cellsIndex.deployFlag];
				custoAccordionItem = this.custoAccordion.getItem(typeRelMapping.VPMObject+"_"+typeRelMapping.MatrixObject);
				if(custoAccordionItem!=undefined)
				{

					if(deployCell.value==="NewNotDeployed")
					{
						this.custoAccordion.removeItem(custoAccordionItem);

						var index = this.custoAccordion.items.indexOf(custoAccordionItem);
						if (index>-1) {
							this.custoAccordion.items.splice(index, 1);
						}
					}
					else
					{
						for (i = 0; i <= UIview.cellsIndex.MatrixObject; i++) {
							UIview.setDeletedCellStyle(typeLine.cells[i]);
						}

						typeLine.cells[UIview.cellsIndex.action].empty();
						deployCell.empty();
						deployCell.value = "DeletedNotDeployed";
						imgSpan = ParametersLayoutViewUtilities.buildImgSpan('trash', '1.5', 'red');
						deployCell.title = MappingManagementNLS.DeletedNotApplied;
						imgSpan.inject(deployCell);

						attrDiv = custoAccordionItem.elements.content.children[0];
						attrTable = attrDiv.getElement(".attrstbodyMapping");
						nbofLines = attrTable.children.length;
						for(cptAttr=1;cptAttr<nbofLines;cptAttr++)
						{
							attrLine = attrTable.children[cptAttr];
							deployAttrcell=attrLine.cells[UIview.cellsAttrIndex.deployFlag];
							if(deployAttrcell.value==="NewNotDeployed")
								attrToRemove.push(attrLine)
								else
									UIview.setToRemoveAttrLine(attrLine);
						}

						attrToRemove.forEach(function(attrMapping){
							attrMapping.remove();
						});
					}
				}

				UIview.removeMappingTypeOrRel(typeRelMapping,this.listofTypeRelMapping);
			},*/



		/*	unsetRemoveTypeRelLine : function (typeLine, custoAccordionItem,typeRelMapping) {
				var deployAttrcell,imgAttrSpan,i,actionCell,deleteIcon,actionButton,that=this,typeLine;

				deployAttrcell=typeLine.cells[UIview.cellsIndex.deployFlag];
				actionCell = typeLine.cells[UIview.cellsIndex.action];

				for (i = 0; i <= UIview.cellsIndex.MatrixObject; i++) 
					UIview.setNormalCellStyle (typeLine.cells[i]);

				//Add delete action icon and callback
				actionButton = UIview.createDeleteModifyActionsIcon(actionCell);
				actionButton.addEvent("onClick", function (e) {	
					UIview.removeTypeRelLineCallBack.call(this,typeLine,typeRelMapping);
				}.bind(that));

				deployAttrcell.empty();
				deployAttrcell.value = "Deployed";
				deployAttrcell.title = MappingManagementNLS.Deployed;
				imgAttrSpan = ParametersLayoutViewUtilities.buildImgSpan('check', '1.5', 'green');
				imgAttrSpan.inject(deployAttrcell);

				//Update mapping model
				typeRelMapping.status="deployed";
				//}
			},*/





			createDeleteModifyActionsIcon: function(actionCell)
			{
				var deleteSpan, deleteButton, deletePop, modifySpan, modifyButton, modifyPop  ;

				/*removelts = ParametersLayoutViewUtilities.createDeleteActionElements("delete attribute mapping");
				deleteSpan = removelts[0];
				deleteSpan.inject(deleteActionCell);
				removeButton = removelts[1];
				removePop = removelts[2];*/
				
				deleteSpan = UWA.createElement('span');
				deleteButton = new Button({
					className: 'close',
					icon: 'fonticon fonticon-trash fonticon-1.5x',//value: 'Button', //fonticon-cancel  fonticon-minus-circled    
					attributes: {
						disabled: false,
						'aria-hidden' : 'true'
					}
				}).inject(deleteSpan);
				deletePop = new Popover({
					//class: 'parampopover',
					target: deleteSpan,//iCell,                        
					trigger : "hover",
					animate: "true",
					position: "top",
					body: MappingManagementNLS.deleteAttrMapping,
					title: ''//iParamObj.nlsKey
				});
				deleteSpan.inject(actionCell);
				
				/*modifySpan = UWA.createElement('span');
				modifyButton = new Button({
					className: 'close',
					icon: 'fonticon fonticon-pencil fonticon-1.5x',//value: 'Button', //fonticon-cancel  fonticon-minus-circled    
					attributes: {
						disabled: false,
						'aria-hidden' : 'true'
					}
				}).inject(modifySpan);
				modifyPop = new Popover({
					//class: 'parampopover',
					target: modifySpan,//iCell,                        
					trigger : "hover",
					animate: "true",
					position: "top",
					body: MappingManagementNLS.modifyDirection,
					title: ''//iParamObj.nlsKey
				});
				modifySpan.inject(actionCell);*/
				
				
				//return [deleteButton,modifyButton];
				return deleteButton;
			},

			/*removeMappingTypeOrRel : function (eltMapping, typeRelMapping) {

				var listOfAttrMapping,index;
				if(eltMapping.status==="new" || eltMapping.status==="removed")
				{
					index = typeRelMapping.indexOf(eltMapping);
					if(index!=-1)
						typeRelMapping.splice(index,1);		
				}
				else
					eltMapping.status="removed";

				listOfAttrMapping = eltMapping.AttributeMapping;
				listOfAttrMapping.forEach(function(attrMapping){
					UIview.removeMappingAttr(attrMapping,listOfAttrMapping);
				})

			},*/

			removeMappingAttr : function (eltAttrMapping, listOfAttributeMapping) {
				var index;
				if(eltAttrMapping.status.indexOf("Removed")===-1)
				{
					if(eltAttrMapping.status==="New" )
					{
						//listOfAttributeMapping.remove(eltAttrMapping);
						index = listOfAttributeMapping.indexOf(eltAttrMapping);
						if(index!=-1)
							listOfAttributeMapping.splice(index,1);	
					}
					else if(eltAttrMapping.status==="Stored" || eltAttrMapping.status==="InvalidStored")
						eltAttrMapping.status="RemovedStored";
					else 
						eltAttrMapping.status="RemovedDeployed";
				}
			},

			/*buildTypeRelMappedWith: function(typeRelMapping,kindOfMapping)
			{
				var typeRelVPMMappedWith =  new Map(),typeRelMxMappedWith =  new Map(),i,eltMapping,eltKindOfMapping,mapValue,mappedTypes,dirArray;
				for(i=0;i<typeRelMapping.length;i++)
				{
					eltMapping = typeRelMapping[i];
					eltKindOfMapping = eltMapping.KindOfMapping;
					if(eltMapping.status !== "removed" && kindOfMapping.toLowerCase() === eltKindOfMapping.toLowerCase())
					{
						mapValue = typeRelVPMMappedWith.get(eltMapping.VPMObject)
						if(mapValue === undefined )
						{
							mapValue = new Map();
							mapValue.set("BOTH",new Array());
							mapValue.set("VPM_To_MX",new Array());
							mapValue.set("MX_To_VPM",new Array());
							typeRelVPMMappedWith.set(eltMapping.VPMObject, mapValue)
						}

						dirArray = mapValue.get(eltMapping.SynchDirection);
						if (dirArray != undefined)
							//dirArray.push(eltMapping.MatrixObject);
							dirArray.push({type:eltMapping.MatrixObject,mapping:{element : eltMapping}});

						mapValue = typeRelMxMappedWith.get(eltMapping.MatrixObject)
						if(mapValue === undefined )
						{
							mapValue = new Map();
							mapValue.set("BOTH",new Array());
							mapValue.set("VPM_To_MX",new Array());
							mapValue.set("MX_To_VPM",new Array());
							typeRelMxMappedWith.set(eltMapping.MatrixObject, mapValue)
						}

						dirArray = mapValue.get(eltMapping.SynchDirection);
						if (dirArray != undefined)
							//dirArray.push(eltMapping.VPMObject);
							dirArray.push({type:eltMapping.VPMObject,mapping:{element : eltMapping}});
					}

				}

				return {VPM:typeRelVPMMappedWith,MX:typeRelMxMappedWith};

			},*/


			buildAttributesMappedWith: function(listOfEltMapping, mappingToExlude)
			{
				var AttrVPMMappedWith =  new Map(),AttrMxMappedWith =  new Map(),i,j,eltMapping,attributeMapping,mapValue,VPMAttr, MxAttr,dirArray;
				for(i=0;i<listOfEltMapping.length;i++)
				{
					eltMapping=(listOfEltMapping[i]).element;
					attributeMapping=eltMapping.AttributeMapping;
					for(j=0;j<attributeMapping.length;j++)
					{
						if(attributeMapping[j] !== mappingToExlude && attributeMapping[j].status.indexOf("Removed")===-1 )
						{
							VPMAttr = attributeMapping[j].VPMAttribute.id;
							MxAttr = attributeMapping[j].MatrixAttribute.id;


							mapValue=AttrVPMMappedWith.get(VPMAttr);
							if(mapValue === undefined )
							{
								mapValue = new Map();
								mapValue.set("BOTH",new Array());
								mapValue.set("VPM_To_MX",new Array());
								mapValue.set("MX_To_VPM",new Array());
								AttrVPMMappedWith.set(VPMAttr, mapValue)
							}

							dirArray = mapValue.get(attributeMapping[j].SynchDirection);
							if (dirArray != undefined)
								dirArray.push({attr:MxAttr,mapping:listOfEltMapping[i]});

							mapValue=AttrMxMappedWith.get(MxAttr);
							if(mapValue === undefined )
							{
								mapValue = new Map();
								mapValue.set("BOTH",new Array());
								mapValue.set("VPM_To_MX",new Array());
								mapValue.set("MX_To_VPM",new Array());
								AttrMxMappedWith.set(MxAttr, mapValue)
							}

							dirArray = mapValue.get(attributeMapping[j].SynchDirection);
							if (dirArray != undefined)
								dirArray.push({attr:VPMAttr,mapping:listOfEltMapping[i]});
						}

					}
				}
				return {VPM:AttrVPMMappedWith,MX:AttrMxMappedWith};

			},


			/*getTypeMappedWith : function (type, typeRelMapping) {
				var i, listOfMappedTypes = new Array(),eltmapping;

				for(i=0;i<typeRelMapping.length;i++)
				{
					eltmapping = typeRelMapping[i];
					if(eltmapping.VPMObject === type )
						listOfMappedTypes.push(eltmapping.MatrixObject)
						else if (eltmapping.MatrixObject === type )
							listOfMappedTypes.push(eltmapping.VPMObject)

				}
				return listOfMappedTypes;
			},*/


			/*getListOfLinkedMapping : function (VPMTypeRelInfo, MatrixTypeRelInfo,kindOfMapping, VPMTypeRelMap, MxTypeRelMap,typeRelMapping) {
				var listOfDerivativeMapping=[],listOfDerivedMapping=[],mapping, VPMObj, MxObj, VPMInheritancePath, MxInheritancePath,i,eltMapping,VPMEltMapping,MxEltMapping, eltKindOfMapping;

				VPMObj = VPMTypeRelInfo.id;
				MxObj = MatrixTypeRelInfo.id;
				if(VPMTypeRelInfo!=undefined)
					VPMInheritancePath=VPMTypeRelInfo.derivationPath;
				if(VPMTypeRelInfo!=undefined)
					MxInheritancePath=MatrixTypeRelInfo.derivationPath;

				for(i=0;i<typeRelMapping.length;i++)
				{
					eltMapping = typeRelMapping[i];	
					VPMEltMapping = eltMapping.VPMObject;
					MxEltMapping = eltMapping.MatrixObject;
					eltKindOfMapping = eltMapping.KindOfMapping;
					if(kindOfMapping.toLowerCase() === eltKindOfMapping.toLowerCase() && eltMapping.status !== "removed")
						if(mapping ===undefined && (eltMapping.VPMObject === VPMObj && eltMapping.MatrixObject === MxObj))
							mapping = eltMapping;
						else if((VPMInheritancePath !==undefined && MxInheritancePath!==undefined)  && (VPMInheritancePath.indexOf(eltMapping.VPMObject)!==-1 && MxInheritancePath.indexOf(eltMapping.MatrixObject)!==-1) )
							listOfDerivativeMapping.push(eltMapping);
						else
						{
							var VPMInheritancePath2=VPMTypeRelMap.get(VPMEltMapping).derivationPath;
							var MxInheritancePath2=MxTypeRelMap.get(MxEltMapping).derivationPath;
							if(VPMInheritancePath2 !==undefined && MxInheritancePath2!==undefined  && VPMInheritancePath2.indexOf(VPMObj)!==-1 && MxInheritancePath2.indexOf(MxObj)!==-1)
								listOfDerivedMapping.push(eltMapping);
						}
				}

				return {EltMapping:mapping, derivativeMapping: listOfDerivativeMapping, derivedMapping:listOfDerivedMapping};
			},*/


			getListOfLinkedMapping : function (VPMTypeRelInfo, MatrixTypeRelInfo,kindOfMapping, VPMTypeRelMap, MxTypeRelMap,typeRelMapping) {
				var listOfLinkedMapping=[], VPMObj, MxObj, VPMInheritancePath, MxInheritancePath,i,eltMapping,VPMEltMapping,MxEltMapping, eltKindOfMapping;

				VPMObj = VPMTypeRelInfo.id;
				MxObj = MatrixTypeRelInfo.id;
				if(VPMTypeRelInfo!=undefined)
					VPMInheritancePath=VPMTypeRelInfo.derivationPath;
				if(VPMTypeRelInfo!=undefined)
					MxInheritancePath=MatrixTypeRelInfo.derivationPath;

				for(i=0;i<typeRelMapping.length;i++)
				{
					eltMapping = typeRelMapping[i];	
					VPMEltMapping = eltMapping.VPMObject;
					MxEltMapping = eltMapping.MatrixObject;
					eltKindOfMapping = eltMapping.KindOfMapping;
					if(kindOfMapping.toLowerCase() === eltKindOfMapping.toLowerCase() && eltMapping.status !== "Removed")
						if((eltMapping.VPMObject === VPMObj && eltMapping.MatrixObject === MxObj))
							listOfLinkedMapping.push({element:eltMapping,position:"current"});
						else if((VPMInheritancePath !==undefined && MxInheritancePath!==undefined)  && (VPMInheritancePath.indexOf(eltMapping.VPMObject)!==-1 && MxInheritancePath.indexOf(eltMapping.MatrixObject)!==-1) )
							listOfLinkedMapping.push({element:eltMapping,position:"parent"});
						else
						{
							var VPMInheritancePath2=VPMTypeRelMap.get(VPMEltMapping).derivationPath;
							var MxInheritancePath2=MxTypeRelMap.get(MxEltMapping).derivationPath;
							if(VPMInheritancePath2 !==undefined && MxInheritancePath2!==undefined  && VPMInheritancePath2.indexOf(VPMObj)!==-1 && MxInheritancePath2.indexOf(MxObj)!==-1)
								listOfLinkedMapping.push({element:eltMapping,position:"child"});
						}
				}

				return listOfLinkedMapping;
			},


		/*	CheckRulesToAddMapping: function(VPMObj, MXObj, VPMObjMappedType, MXObjMappedType)
			{

				var VPMArrayVPMToMx=new Array(),VPMArrayMxToVPM=new Array(),VPMArrayBoth=new Array(),MXArrayVPMToMx=new Array(),MXArrayMxToVPM=new Array(),MXArrayBoth=new Array(),result,resultRule1,resultRule2,resultRule3;
				result={VPM_To_MX:true,MX_To_VPM:true,BOTH:true,message:{VPM_To_MX:new Array(), MX_To_VPM:new Array(),BOTH:new Array()}};

				if(VPMObjMappedType!=undefined)
				{
					VPMArrayVPMToMx=VPMObjMappedType.get("VPM_To_MX");
					VPMArrayMxToVPM = VPMObjMappedType.get("MX_To_VPM");
					VPMArrayBoth = VPMObjMappedType.get("BOTH");
				}
				if(MXObjMappedType!=undefined)
				{
					MXArrayVPMToMx=MXObjMappedType.get("VPM_To_MX");
					MXArrayMxToVPM = MXObjMappedType.get("MX_To_VPM");
					MXArrayBoth = MXObjMappedType.get("BOTH");
				}

				resultRule1 = UIview.CheckIsNotAlreadyMappedWithMxObj(MXObj,VPMArrayVPMToMx,VPMArrayMxToVPM,VPMArrayBoth);
				resultRule2 = UIview.CheckNotUsedTwiceAsSource(VPMArrayVPMToMx,VPMArrayMxToVPM,VPMArrayBoth,MXArrayVPMToMx,MXArrayMxToVPM,MXArrayBoth);
				resultRule3 = UIview.CheckCoherence( VPMArrayVPMToMx,VPMArrayMxToVPM,VPMArrayBoth,MXArrayVPMToMx,MXArrayMxToVPM,MXArrayBoth);

				result.VPM_To_MX = resultRule1.VPM_To_MX && resultRule2.VPM_To_MX && resultRule3.VPM_To_MX;
				result.MX_To_VPM = resultRule1.MX_To_VPM && resultRule2.MX_To_VPM && resultRule3.MX_To_VPM;
				result.BOTH = resultRule1.BOTH && resultRule2.BOTH && resultRule3.BOTH;

				Array.prototype.push.apply(result.message.BOTH, resultRule1.message.BOTH);Array.prototype.push.apply(result.message.BOTH, resultRule2.message.BOTH);Array.prototype.push.apply(result.message.BOTH, resultRule3.message.BOTH)
				Array.prototype.push.apply(result.message.VPM_To_MX, resultRule1.message.VPM_To_MX); Array.prototype.push.apply(result.message.VPM_To_MX, resultRule2.message.VPM_To_MX);Array.prototype.push.apply(result.message.VPM_To_MX, resultRule3.message.VPM_To_MX)
				Array.prototype.push.apply(result.message.MX_To_VPM, resultRule1.message.MX_To_VPM);Array.prototype.push.apply(result.message.MX_To_VPM, resultRule2.message.MX_To_VPM);Array.prototype.push.apply(result.message.MX_To_VPM, resultRule3.message.MX_To_VPM);
				return result;
			},*/


			CheckRulesToAddAttrMapping: function(VPMTypeRelInfo,VPMAttrInfo,MxTypeRelInfo,MxAttrInfo, parentSide,VPMObjMappedAttr, MXObjMappedAttr,messageSuffix)
			{

				var VPMArrayVPMToMx=new Array(),VPMArrayMxToVPM=new Array(),VPMArrayBoth=new Array(),MXArrayVPMToMx=new Array(),MXArrayMxToVPM=new Array(),MXArrayBoth=new Array(),result,resultRule1,resultRule2,resultRule3,resultRule4,resultRule5,resultRule6,VPMAttrInfo, MxAttrInfo,VPMAttrRange="",MxAttrRange="";
				result={VPM_To_MX:true,MX_To_VPM:true,BOTH:true,message:{VPM_To_MX:new Array(), MX_To_VPM:new Array(),BOTH:new Array()}};

				if(VPMObjMappedAttr!=undefined)
				{
					VPMArrayVPMToMx=VPMObjMappedAttr.get("VPM_To_MX");
					VPMArrayMxToVPM = VPMObjMappedAttr.get("MX_To_VPM");
					VPMArrayBoth = VPMObjMappedAttr.get("BOTH");
				}
				if(MXObjMappedAttr!=undefined)
				{
					MXArrayVPMToMx=MXObjMappedAttr.get("VPM_To_MX");
					MXArrayMxToVPM = MXObjMappedAttr.get("MX_To_VPM");
					MXArrayBoth = MXObjMappedAttr.get("BOTH");
				}

				resultRule1 = UIview.CheckIsNotAlreadyMapped(MXArrayVPMToMx,MXArrayMxToVPM,MXArrayBoth);
				//resultRule1 = UIview.CheckIsSameAttrType(VPMAttr,MxAttr);
				//resultRule1 = UIview.CheckIsNotAlreadyMappedWithMxObj(MxAttr,VPMArrayVPMToMx,VPMArrayMxToVPM,VPMArrayBoth);
				//resultRule2 = UIview.CheckNotUsedTwiceAsTarget(VPMArrayVPMToMx,VPMArrayMxToVPM,VPMArrayBoth,MXArrayVPMToMx,MXArrayMxToVPM,MXArrayBoth);
				//resultRule3 = UIview.CheckCoherence( VPMArrayVPMToMx,VPMArrayMxToVPM,VPMArrayBoth,MXArrayVPMToMx,MXArrayMxToVPM,MXArrayBoth);
				//resultRule4 = UIview.CheckCoherenceWithParentSide(parentSide);
				
				
				//VPMAttrInfo = UIview.retrieveAttributeInfo(VPMTypeRelInfo,VPMAttr);
				if(VPMAttrInfo!=undefined) VPMAttrRange = VPMAttrInfo.range;
				//MxAttrInfo = UIview.retrieveAttributeInfo(MxTypeRelInfo,MxAttr);
				if(MxAttrInfo!=undefined) MxAttrRange = MxAttrInfo.range;
				
				resultRule5 =  UIview.CheckIsSameAttrRange(VPMAttrRange,MxAttrRange);
				
				resultRule6 = UIview.CheckIsAuthorizedAsTarget(MxAttrInfo.itf,MxAttrInfo.id,VPMAttrInfo.itf,VPMAttrInfo.id);

				result.VPM_To_MX = resultRule1.VPM_To_MX/* && resultRule2.VPM_To_MX && resultRule3.VPM_To_MX && resultRule4.VPM_To_MX */&& resultRule5.VPM_To_MX && resultRule6.VPM_To_MX;
				result.MX_To_VPM = resultRule1.MX_To_VPM /*&& resultRule2.MX_To_VPM && resultRule3.MX_To_VPM && resultRule4.MX_To_VPM */&& resultRule5.MX_To_VPM && resultRule6.MX_To_VPM;
				result.BOTH = resultRule1.BOTH /*&& resultRule2.BOTH && resultRule3.BOTH && resultRule4.BOTH*/ && resultRule5.BOTH && resultRule6.BOTH;

				Array.prototype.push.apply(result.message.BOTH, resultRule1.message.BOTH);/*Array.prototype.push.apply(result.message.BOTH, resultRule2.message.BOTH);Array.prototype.push.apply(result.message.BOTH, resultRule3.message.BOTH);Array.prototype.push.apply(result.message.BOTH, resultRule4.message.BOTH);*/Array.prototype.push.apply(result.message.BOTH, resultRule5.message.BOTH);Array.prototype.push.apply(result.message.BOTH, resultRule6.message.BOTH);
				Array.prototype.push.apply(result.message.VPM_To_MX, resultRule1.message.VPM_To_MX); /*Array.prototype.push.apply(result.message.VPM_To_MX, resultRule2.message.VPM_To_MX);Array.prototype.push.apply(result.message.VPM_To_MX, resultRule3.message.VPM_To_MX);Array.prototype.push.apply(result.message.VPM_To_MX, resultRule4.message.VPM_To_MX);*/Array.prototype.push.apply(result.message.VPM_To_MX, resultRule5.message.VPM_To_MX);Array.prototype.push.apply(result.message.VPM_To_MX, resultRule6.message.VPM_To_MX);
				Array.prototype.push.apply(result.message.MX_To_VPM, resultRule1.message.MX_To_VPM);/*Array.prototype.push.apply(result.message.MX_To_VPM, resultRule2.message.MX_To_VPM);Array.prototype.push.apply(result.message.MX_To_VPM, resultRule3.message.MX_To_VPM);Array.prototype.push.apply(result.message.MX_To_VPM, resultRule4.message.MX_To_VPM);*/Array.prototype.push.apply(result.message.MX_To_VPM, resultRule5.message.MX_To_VPM);Array.prototype.push.apply(result.message.MX_To_VPM, resultRule6.message.MX_To_VPM);

				return result;
			},


			CheckIsSameAttrType : function (VPMAttr,MxAttr) {
				var result={VPM_To_MX:true,MX_To_VPM:true,BOTH:true,message:{VPM_To_MX:new Array(), MX_To_VPM:new Array(),BOTH:new Array()}},message="";

				if(VPMAttr.isenum === true )
				{
					if(MxAttr.type !== "String")
					{
						message=MappingManagementNLS.ErrorNotSameType;
						result.BOTH=false;result.VPM_To_MX=false;result.MX_To_VPM=false;
						result.message.BOTH.push(message);result.message.VPM_To_MX.push(message);result.message.MX_To_VPM.push(message);
					}
				}
				else if(VPMAttr.type !==MxAttr.type)
				{
					message=MappingManagementNLS.ErrorNotSameType;
					result.BOTH=false;result.VPM_To_MX=false;result.MX_To_VPM=false;
					result.message.BOTH.push(message);result.message.VPM_To_MX.push(message);result.message.MX_To_VPM.push(message);
				}
				return result;
			},

			CheckIsSameAttrRange : function (VPMAttrRange,MxAttrRange) {
				var result={VPM_To_MX:true,MX_To_VPM:true,BOTH:true,message:{VPM_To_MX:new Array(), MX_To_VPM:new Array(),BOTH:new Array()}},message="",isVPMRangesIncludesMxRange,isMxRangesIncludesVPMRange,cpt,range;

				message=MappingManagementNLS.ErrorRange;
				//if( VPMAttrRange.length===0 &&  MxAttrRange.length===0)
				//return result;
				if( VPMAttrRange.length===0 &&  MxAttrRange.length!==0)
				{
					result.VPM_To_MX=false;result.message.VPM_To_MX.push(message);
					result.BOTH=false;result.message.BOTH.push(message);
				}
				else if( VPMAttrRange.length!==0 &&  MxAttrRange.length===0)
				{
					result.MX_To_VPM=false;result.message.MX_To_VPM.push(message);
					result.BOTH=false;result.message.BOTH.push(message);
				}
				else if(VPMAttrRange.length!==0 &&  MxAttrRange.length!==0)
				{
					//ArrayVPMRange = VPMAttrRange.split(",");
					//ArrayMxRange = MxAttrRange.split(",");
					isVPMRangesIncludesMxRange = true;
					isMxRangesIncludesVPMRange =true;
					cpt=0;
					while(cpt<VPMAttrRange.length && isMxRangesIncludesVPMRange)
					{
						range = VPMAttrRange[cpt];
						if(MxAttrRange.indexOf(range)<0) isMxRangesIncludesVPMRange=false;
						cpt++;
					}
					cpt=0;
					while(cpt<MxAttrRange.length && isVPMRangesIncludesMxRange)
					{
						range = MxAttrRange[cpt];
						if(VPMAttrRange.indexOf(range)<0) isVPMRangesIncludesMxRange=false;
						cpt++;
					}
					if(!isVPMRangesIncludesMxRange || !isMxRangesIncludesVPMRange)
					{
						result.BOTH=false;
						result.message.BOTH.push(message);
					}
					if(!isVPMRangesIncludesMxRange )
					{
						result.MX_To_VPM=false;
						result.message.MX_To_VPM.push(message);
					}
					if(!isMxRangesIncludesVPMRange )
					{
						result.VPM_To_MX=false;
						result.message.VPM_To_MX.push(message);
					}

				}

				return result;
			},

		/*	CheckIsNotAlreadyMappedWithMxObj : function (MXObj,VPMArrayVPMToMx,VPMArrayMxToVPM,VPMArrayBoth) {

				var result={VPM_To_MX:true,MX_To_VPM:true,BOTH:true,message:{VPM_To_MX:new Array(), MX_To_VPM:new Array(),BOTH:new Array()}},message="";

				if(VPMArrayVPMToMx.indexOf(MXObj)!==-1 || VPMArrayMxToVPM.indexOf(MXObj)!==-1 || VPMArrayBoth.indexOf(MXObj)!==-1)
				{
					message=MappingManagementNLS.ErrorAlreadyMappedTogether;
					result.BOTH=false;result.VPM_To_MX=false;result.MX_To_VPM=false;
					result.message.BOTH.push(message);result.message.VPM_To_MX.push(message);result.message.MX_To_VPM.push(message);
				}
				return result;
			},*/
			
			CheckIsNotAlreadyMapped : function (MXArrayVPMToMx,MXArrayMxToVPM,MXArrayBoth) {

				var result={VPM_To_MX:true,MX_To_VPM:true,BOTH:true,message:{VPM_To_MX:new Array(), MX_To_VPM:new Array(),BOTH:new Array()}},message="";

				if(MXArrayVPMToMx.length!==0 || MXArrayMxToVPM.length!==0 || MXArrayBoth.length!==0)
				{
					message=MappingManagementNLS.ErrorMatrixAlreadyMapped;
					result.BOTH=false;result.VPM_To_MX=false;result.MX_To_VPM=false;
					result.message.BOTH.push(message);result.message.VPM_To_MX.push(message);result.message.MX_To_VPM.push(message);
				}
				return result;
			},
			
			CheckIsAuthorizedAsTarget : function (MxItf, MXObj, VPMItf, VPMObj) {

				var result={VPM_To_MX:true,MX_To_VPM:true,BOTH:true,message:{VPM_To_MX:new Array(), MX_To_VPM:new Array(),BOTH:new Array()}},message="", isVPMAuthorized, isPartAuthorized;

				isVPMAuthorized= UIview.VPMAttrAsTarget.indexOf(VPMObj)!==-1;
				isPartAuthorized = UIview.PartAttrAsTarget.indexOf(MXObj)!==-1;
				
				if( !isVPMAuthorized && (VPMItf==="" ||VPMItf===undefined)  )
				{
					message=MappingManagementNLS.ErrorVPMOnlyUsedAsSource;
					result.BOTH=false;result.MX_To_VPM=false;;
					result.message.BOTH.push(message);result.message.MX_To_VPM.push(message);
				}
				if( !isPartAuthorized && (MxItf==="" ||MxItf===undefined) )
				{
					message=MappingManagementNLS.ErrorMxOnlyUsedAsSource;
					result.BOTH=false;result.VPM_To_MX=false;;
					result.message.BOTH.push(message);result.message.VPM_To_MX.push(message);
				}
				return result;
			},



		/*	CheckCoherenceWithParentSide : function (parentSide) {

				var result={VPM_To_MX:true,MX_To_VPM:true,BOTH:true,message:{VPM_To_MX:new Array(), MX_To_VPM:new Array(),BOTH:new Array()}},message="";

				if(parentSide=="VPM_To_MX")
				{
					message=MappingManagementNLS.ErrorParentSideVPMENG;
					result.BOTH=false;result.MX_To_VPM=false;
					result.message.BOTH.push(message);result.message.MX_To_VPM.push(message);
				}
				else if(parentSide=="MX_To_VPM")
				{
					message=MappingManagementNLS.ErrorParentSideENGVPM;
					result.BOTH=false;result.VPM_To_MX=false;
					result.message.BOTH.push(message);result.message.VPM_To_MX.push(message);
				}
				return result;
			},*/

		/*	CheckNotUsedTwiceAsSource : function (VPMArrayVPMToMx,VPMArrayMxToVPM,VPMArrayBoth,MXArrayVPMToMx,MXArrayMxToVPM,MXArrayBoth) {

				var result={VPM_To_MX:true,MX_To_VPM:true,BOTH:true,message:{VPM_To_MX:new Array(), MX_To_VPM:new Array(),BOTH:new Array()}},message="";

				if(MXArrayBoth.length===1 || VPMArrayBoth.length===1 || VPMArrayVPMToMx.length===1 || MXArrayMxToVPM.length===1) 
				{
					result.BOTH=false;
					if(VPMArrayBoth.length===1 || VPMArrayVPMToMx.length===1) {
						message="";
						result.VPM_To_MX=false;
						message = message +  MappingManagementNLS.ErrorVPMAlreadyUsedAsSource;
						if(VPMArrayBoth.length===1)
							message = message +  VPMArrayBoth[0].mapping.element.VPMObject + " <=> "+ VPMArrayBoth[0].mapping.element.MatrixObject+"\n"; 
						else if(VPMArrayVPMToMx===1)
							message = message +  VPMArrayVPMToMx[0].mapping.element.VPMObject + " => " + VPMArrayVPMToMx[0].mapping.element.MatrixObject+"\n"; 

						result.message.BOTH.push(message);
						result.message.VPM_To_MX.push(message);
						//result.message.push("VPM Object already used as source"+suffix+". BOTH or VPM to ENG direction are not possible."); 
					}
					if(MXArrayBoth.length===1 || MXArrayMxToVPM.length===1) {
						result.MX_To_VPM=false;
						message="";
						message = message +  MappingManagementNLS.ErrorMatrixAlreadyUsedAsSource;
						if(MXArrayBoth.length===1)
							message = message +  MXArrayBoth[0].mapping.element.VPMObject + " <=> "+ MXArrayBoth[0].mapping.element.MatrixObject+"\n"; 
						else if(MXArrayMxToVPM===1)
							message = message +  MXArrayMxToVPM[0].mapping.element.VPMObject + " => " + MXArrayMxToVPM[0].mapping.element.MatrixObject+"\n"; 
						result.message.BOTH.push(message);
						result.message.MX_To_VPM.push(message);
						//result.message.push("Matrix Object already used as source"+suffix+". BOTH or ENG to VPM direction are not possible.");
					}
				}
				return result;
			},*/

		/*	CheckNotUsedTwiceAsTarget : function (VPMArrayVPMToMx,VPMArrayMxToVPM,VPMArrayBoth,MXArrayVPMToMx,MXArrayMxToVPM,MXArrayBoth) {

				var result={VPM_To_MX:true,MX_To_VPM:true,BOTH:true, message:{VPM_To_MX:new Array(), MX_To_VPM:new Array(),BOTH:new Array()}},message="";

				if(MXArrayBoth.length===1 || VPMArrayBoth.length===1 || VPMArrayMxToVPM.length===1 || MXArrayVPMToMx.length===1) 
				{
					result.BOTH=false;
					if(MXArrayBoth.length===1 || MXArrayVPMToMx.length===1) 
					{
						message="";
						result.VPM_To_MX=false;
						message = message +  MappingManagementNLS.ErrorMatrixAlreadyUsedAsTarget;

						if(MXArrayBoth.length===1)
						{
							message = message  + MXArrayBoth[0].mapping.element.VPMObject + " <=> "+ MXArrayBoth[0].mapping.element.MatrixObject+"\n"; 
						}
						else if(MXArrayVPMToMx===1)
							message = message +  MXArrayVPMToMx[0].mapping.element.VPMObject + " => " + MXArrayVPMToMx[0].mapping.element.MatrixObject+"\n"; 

						//message = message +  ". BOTH and VPM to ENG direction are not possible."; 
						result.message.BOTH.push(message);
						result.message.VPM_To_MX.push(message);
					}

					if(VPMArrayBoth.length===1 ||VPMArrayMxToVPM.length===1) 
					{
						message="";
						result.MX_To_VPM=false;
						message = message +  MappingManagementNLS.ErrorVPMAlreadyUsedAsTarget;

						if(VPMArrayBoth.length===1)
							message = message +  VPMArrayBoth[0].mapping.element.VPMObject + " <=> "+VPMArrayBoth[0].mapping.element.MatrixObject; 
						else if (VPMArrayMxToVPM.length===1)
							message = message +  VPMArrayMxToVPM[0].mapping.element.VPMObject + " <= " + VPMArrayMxToVPM[0].mapping.element.MatrixObject; 

						//message += ". BOTH and ENG to VPM direction are not possible.";
						//result.message.push(message);
						result.message.BOTH.push(message);
						result.message.MX_To_VPM.push(message);
					}
				}
				return result;
			},*/


			/*CheckCoherence : function ( VPMArrayVPMToMx,VPMArrayMxToVPM,VPMArrayBoth,MXArrayVPMToMx,MXArrayMxToVPM,MXArrayBoth) {

				var result={VPM_To_MX:true,MX_To_VPM:true,BOTH:true,message:{VPM_To_MX:new Array(), MX_To_VPM:new Array(),BOTH:new Array()}}, message="";

				if(VPMArrayMxToVPM.length!==0 || MXArrayMxToVPM.length!==0) {
					result.VPM_To_MX=false;
					message="";
					if(VPMArrayMxToVPM.length!==0)
					{
						message = message +  MappingManagementNLS.ErrorVPMAlreadyUsedAsTargetWithAnotherObject;
						message += UIview.buildAddMappingWarningMessage(VPMArrayMxToVPM,"<=");
					}

					if (MXArrayMxToVPM.length!==0)
					{
						message = message +  MappingManagementNLS.ErrorMatrixAlreadyUsedAsSourceWithAnotherObject;
						message += UIview.buildAddMappingWarningMessage(MXArrayMxToVPM,"<=");
					}

					//message += ". VPM to ENG direction is not possible.";
					//result.message.push(message);
					result.message.VPM_To_MX.push(message);
				}
				if(VPMArrayVPMToMx.length!==0 || MXArrayVPMToMx.length!==0) 
				{
					result.MX_To_VPM=false;
					message="";
					if(VPMArrayVPMToMx.length!==0)
					{
						message = message + MappingManagementNLS.ErrorVPMAlreadyUsedAsSourceWithAnotherObject;
						message += UIview.buildAddMappingWarningMessage(VPMArrayVPMToMx,"=>");
					}
					if (MXArrayVPMToMx.length!==0)
					{
						message = message +  MappingManagementNLS.ErrorMatrixAlreadyUsedAsTargetWithAnotherObject;
						message += UIview.buildAddMappingWarningMessage(MXArrayVPMToMx,"=>");
					}
					//message += ". ENG to VPM direction is not possible.";
					//result.message.push(message);
					result.message.MX_To_VPM.push(message);
				}

				return result;
			},*/


			/*modifyToggleAccordingAvailableDirection : function ( toggleBoth,toggleVPM,toggleENG,authorizedDirection) {

				toggleBoth.setDisabled(false);toggleVPM.setDisabled(false);toggleENG.setDisabled(false);
				if(authorizedDirection!==undefined)
				{
					if(!authorizedDirection.BOTH) toggleBoth.setDisabled(true);
					if(!authorizedDirection.VPM_To_MX) toggleVPM.setDisabled(true);
					if(!authorizedDirection.MX_To_VPM) toggleENG.setDisabled(true);
				}

				if( !toggleBoth.isDisabled()) toggleBoth.check();
				else if(!toggleVPM.isDisabled()) toggleVPM.check();
				else if(!toggleENG.isDisabled()) toggleENG.check();

			},*/

			modifyToggleAccordingAvailableDirection : function ( typesSelectVPM, typesSelectMatrix,OkButton,toggleBoth,toggleVPM,toggleENG,directionAvailableMap,messageDivBOTH,popoverInfoMappingBOTH,messageDivVPMENG,popoverInfoMappingVPMENG,messageDivENGVPM,popoverInfoMappingENGVPM) {

				var selectedMxTypeOpt, selectedMxType,authorizedDirection,messagesBOTH,messagesVPMENG,messagesENGVPM,cpt,messageList,childrenList,iconInfo;
				toggleBoth.setDisabled(false);toggleVPM.setDisabled(false);toggleENG.setDisabled(false);


				selectedMxTypeOpt = typesSelectMatrix.getSelection(false);
				if(selectedMxTypeOpt.length>0)
				{
					if((typesSelectVPM.getSelection(false)).length>0)
						OkButton.enable();
					else
						OkButton.disable();

					selectedMxType = selectedMxTypeOpt[0].value;
					authorizedDirection = directionAvailableMap.get(selectedMxType);	
					if(authorizedDirection!==undefined)
					{
						if(!authorizedDirection.BOTH) toggleBoth.setDisabled(true);
						if(!authorizedDirection.VPM_To_MX) toggleVPM.setDisabled(true);
						if(!authorizedDirection.MX_To_VPM) toggleENG.setDisabled(true);

						messagesBOTH = authorizedDirection.message.BOTH;
						messagesVPMENG = authorizedDirection.message.VPM_To_MX;
						messagesENGVPM = authorizedDirection.message.MX_To_VPM;
					}

					if( !toggleBoth.isDisabled()) toggleBoth.check();
					else if(!toggleVPM.isDisabled()) toggleVPM.check();
					else if(!toggleENG.isDisabled()) toggleENG.check();

					UIview.displayAddMappingWarningMessage (messageDivBOTH,popoverInfoMappingBOTH ,messagesBOTH );
					UIview.displayAddMappingWarningMessage (messageDivVPMENG,popoverInfoMappingVPMENG ,messagesVPMENG );
					UIview.displayAddMappingWarningMessage (messageDivENGVPM,popoverInfoMappingENGVPM ,messagesENGVPM );

				}
				else
				{
					OkButton.disable();
					toggleBoth.setDisabled(true);
					toggleVPM.setDisabled(true);
					toggleENG.setDisabled(true);
					UIview.hideAddMappingWarningMessage(messageDivBOTH);
					UIview.hideAddMappingWarningMessage(messageDivVPMENG);
					UIview.hideAddMappingWarningMessage(messageDivENGVPM);
				}
			},

			
			
			
			
		/*	enableMatrixTypeRelAccordingRules : function ( typesSelectVPM,typesSelectMatrix,typeRelMappingMapVPM,typeRelMappingMapMX,directionAvailableMap) {

				var selectedVPMType, selectedMxType,selectedVPMTypeOpt,listOfMappedMXType,listMatrixOptions,cptOptions,listOfMappedVPMType,directionAvailable,matrixOption,listOfEnableOption = new Array(), listOfDisableOption=new Array();

				typesSelectMatrix.select(0,true);

				selectedVPMTypeOpt = typesSelectVPM.getSelection(false);
				if(selectedVPMTypeOpt.length!=0)
				{


					selectedVPMType = selectedVPMTypeOpt[0].value;

					listOfMappedMXType = typeRelMappingMapVPM.get(selectedVPMType);


					listMatrixOptions = typesSelectMatrix.getOptions(false);
					for(cptOptions=0; cptOptions<listMatrixOptions.length;cptOptions++){
						matrixOption = listMatrixOptions[cptOptions].value;;
						listOfMappedVPMType = typeRelMappingMapMX.get(matrixOption);
						directionAvailable = UIview.CheckRulesToAddMapping(selectedVPMType, matrixOption, listOfMappedMXType, listOfMappedVPMType);
						directionAvailableMap.set(matrixOption,directionAvailable);

						if(directionAvailable.VPM_To_MX || directionAvailable.MX_To_VPM  || directionAvailable.BOTH )
							listOfEnableOption.push(listMatrixOptions[cptOptions]);
						else
							listOfDisableOption.push(listMatrixOptions[cptOptions]);		
					}


					typesSelectMatrix.remove (listMatrixOptions);

					listOfEnableOption.forEach(function(matrixOption){
						typesSelectMatrix.add( {label:matrixOption.label, value:matrixOption.value});
						typesSelectMatrix.enable(matrixOption.value);
					});

					listOfDisableOption.forEach(function(matrixOption){
						typesSelectMatrix.add({label:matrixOption.label, value:matrixOption.value});
						typesSelectMatrix.disable(matrixOption.value);

					});

				}

			},*/

			/*enableMatrixAttrAccordingRules : function ( attrsSelectVPM,attrsSelectMatrix,attrMappingMap,attrMappingDerivativeMap,attrMappingDerivedMap,directionAvailableMap) {

				var selectedVPMAttr, selectedVPMAttrType,selectedMxAttr, selectedMxAttrType,selectedVPMAttrOpt,listOfMappedMXattr,listOfMappedDerivativeMXattr,listOfMappedDerivedMXattr,listMatrixOptions,cptOptions,listOfMappedVPMattr,listOfMappedDerivativeVPMattr,listOfMappedDerivedVPMattr,directionAvailable,directionAvailableDerivative, directionAvailableDerived ,matrixOption,position;

				selectedVPMAttrOpt = attrsSelectVPM.getSelection();
				position = selectedVPMAttrOpt[0].value.indexOf(",");
				if(position != -1)
				{
					selectedVPMAttr = selectedVPMAttrOpt[0].value.slice(0,position);
					selectedVPMAttrType =  selectedVPMAttrOpt[0].value.slice(position+1);
				}

				listOfMappedMXattr = (attrMappingMap.VPM).get(selectedVPMAttr);
				listOfMappedDerivativeMXattr = (attrMappingDerivativeMap.VPM).get(selectedVPMAttr);
				listOfMappedDerivedMXattr = (attrMappingDerivedMap.VPM).get(selectedVPMAttr);


				listMatrixOptions = attrsSelectMatrix.getOptions();
				for(cptOptions=0; cptOptions<listMatrixOptions.length;cptOptions++){
					matrixOption = listMatrixOptions[cptOptions].value;
					position = matrixOption.indexOf(",");
					if(position != -1)
					{
						selectedMxAttr = matrixOption.slice(0,position);
						selectedMxAttrType =  matrixOption.slice(position+1);
					}

					directionAvailable = UIview.CheckIsSameAttrType(selectedVPMAttrType,selectedMxAttrType);

					if(directionAvailable.BOTH)
					{

						listOfMappedVPMattr = (attrMappingMap.MX).get(selectedMxAttr);
						listOfMappedDerivativeVPMattr = (attrMappingDerivativeMap.MX).get(selectedMxAttr);
						listOfMappedDerivedVPMattr = (attrMappingDerivedMap.MX).get(selectedMxAttr);


						directionAvailable = UIview.CheckRulesToAddAttrMapping(selectedVPMAttr,selectedMxAttr, listOfMappedMXattr, listOfMappedVPMattr);
						directionAvailableDerivative = UIview.CheckRulesToAddAttrMapping(selectedVPMAttr,selectedMxAttr, listOfMappedDerivativeMXattr, listOfMappedDerivativeVPMattr, "in one of derivative mapping");
						directionAvailableDerived = UIview.CheckRulesToAddAttrMapping(selectedVPMAttr,selectedMxAttr, listOfMappedDerivedMXattr, listOfMappedDerivedVPMattr,"in one of derived mapping");

						directionAvailable.VPM_To_MX = directionAvailable.VPM_To_MX && directionAvailableDerivative.VPM_To_MX && directionAvailableDerived.VPM_To_MX;
						directionAvailable.MX_To_VPM = directionAvailable.MX_To_VPM && directionAvailableDerivative.MX_To_VPM && directionAvailableDerived.MX_To_VPM;
						directionAvailable.BOTH = directionAvailable.BOTH && directionAvailableDerivative.BOTH && directionAvailableDerived.BOTH;

						var derivativeMessages= directionAvailableDerivative.message;
						var derivedMessages= directionAvailableDerived.message;



						Array.prototype.push.apply(directionAvailable.message, directionAvailableDerivative.message);
						Array.prototype.push.apply(directionAvailable.message, directionAvailableDerived.message);


					}

					directionAvailableMap.set(matrixOption,directionAvailable);

					if(directionAvailable.VPM_To_MX || directionAvailable.MX_To_VPM  || directionAvailable.BOTH )
					{
						if( attrsSelectMatrix.getSelection().length===0)
						{
							attrsSelectMatrix.select (matrixOption,true);
						}
						attrsSelectMatrix.enable(matrixOption);
					}
					else
					{
						attrsSelectMatrix.disable(matrixOption);
						attrsSelectMatrix.select (matrixOption,false);
					}			
				}

			},*/


			/*enableMatrixAttrAccordingRules : function (VPMTypeRelInfo, attrsSelectVPM, MxTypeRelInfo, attrsSelectMatrix,parentSide,attrMappingMap,directionAvailableMap) {

				var selectedVPMAttr, selectedVPMAttrType,selectedMxAttr, selectedMxAttrType,selectedVPMAttrOpt,listOfMappedMXattr,listMatrixOptions,cptOptions,listOfMappedVPMattr,directionAvailable ,matrixOption,position,listOfEnableOption = new Array(), listOfDisableOption=new Array(),group,VPMAttrInfo,MxAttrInfo;
				attrsSelectMatrix.select(0,true);


				selectedVPMAttrOpt = attrsSelectVPM.getSelection(false);

				if(selectedVPMAttrOpt.length!=0)
				{
					
						selectedVPMAttr = selectedVPMAttrOpt[0].value;
						VPMAttrInfo = UIview.retrieveAttributeInfo(VPMTypeRelInfo,selectedVPMAttr);
					
					
					
					

					listOfMappedMXattr = (attrMappingMap.VPM).get(selectedVPMAttr);

					listMatrixOptions = attrsSelectMatrix.getOptions(false);
					for(cptOptions=0; cptOptions<listMatrixOptions.length;cptOptions++){
						selectedMxAttr = listMatrixOptions[cptOptions].value;
						if(selectedMxAttr!==undefined && selectedMxAttr!=="")
						{
							
							
							MxAttrInfo = UIview.retrieveAttributeInfo(MxTypeRelInfo,selectedMxAttr);
							
							
							
							directionAvailable = UIview.CheckIsSameAttrType(VPMAttrInfo.type,MxAttrInfo.type);
			
							if(directionAvailable.BOTH)
							{
								listOfMappedVPMattr = (attrMappingMap.MX).get(selectedMxAttr);

								directionAvailable = UIview.CheckRulesToAddAttrMapping(VPMTypeRelInfo, VPMAttrInfo,MxTypeRelInfo,MxAttrInfo,parentSide, listOfMappedMXattr, listOfMappedVPMattr);
							}

							directionAvailableMap.set(selectedMxAttr,directionAvailable);

							if(directionAvailable.VPM_To_MX || directionAvailable.MX_To_VPM  || directionAvailable.BOTH )
							{
							
								listOfEnableOption.push({option:listMatrixOptions[cptOptions]});
							}
							else
							{
								
								listOfDisableOption.push({option:listMatrixOptions[cptOptions]});

							}
						}
					}

					attrsSelectMatrix.remove (listMatrixOptions);

					listOfEnableOption.forEach(function(matrixOption){
						attrsSelectMatrix.add( {label:matrixOption.option.label, value:matrixOption.option.value, group:matrixOption.group});
						attrsSelectMatrix.enable(matrixOption.option.value);
					});

					listOfDisableOption.forEach(function(matrixOption){
						attrsSelectMatrix.add( {label:matrixOption.option.label, value:matrixOption.option.value, group:matrixOption.group});
						attrsSelectMatrix.disable(matrixOption.option.value);

					});



				}
			},*/
			
			

			enableMatrixAttrAccordingRules : function (VPMTypeRelInfo, attrsSelectVPM, MxTypeRelInfo, attrsSelectMatrix,MatrixAttributes, parentSide,attrMappingMap,directionAvailableMap) {

				var selectedVPMAttr, selectedVPMAttrType, selectedMxAttrType,selectedVPMAttrOpt,listOfMappedMXattr,listMatrixOptions,cptOptions,listOfMappedVPMattr,directionAvailable ,matrixOption,position,listOfEnableOption = new Array(), listOfDisableOption=new Array(),group,VPMAttrInfo,MxAttrInfo;
				attrsSelectMatrix.select(0,true);


				selectedVPMAttrOpt = attrsSelectVPM.getSelection(false);

				if(selectedVPMAttrOpt.length!=0)
				{
					selectedVPMAttr = selectedVPMAttrOpt[0].value;
					VPMAttrInfo = UIview.retrieveAttributeInfo(VPMTypeRelInfo,selectedVPMAttr);

					attrsSelectMatrix.remove();

					listOfMappedMXattr = (attrMappingMap.VPM).get(selectedVPMAttr);

					listMatrixOptions = attrsSelectMatrix.getOptions(false);
					for(cptOptions=0; cptOptions<MatrixAttributes.length;cptOptions++){
						{
							MxAttrInfo = MatrixAttributes[cptOptions];

								directionAvailable = UIview.CheckIsSameAttrType(VPMAttrInfo,MxAttrInfo);

								if(directionAvailable.BOTH)
								{
									listOfMappedVPMattr = (attrMappingMap.MX).get(MxAttrInfo.id);
									directionAvailable = UIview.CheckRulesToAddAttrMapping(VPMTypeRelInfo, VPMAttrInfo,MxTypeRelInfo,MxAttrInfo,parentSide, listOfMappedMXattr, listOfMappedVPMattr);
								}

								directionAvailableMap.set(MxAttrInfo.id,directionAvailable);

								if(directionAvailable.VPM_To_MX || directionAvailable.MX_To_VPM  || directionAvailable.BOTH )
									listOfEnableOption.push( {label:MxAttrInfo.name + " ("+MxAttrInfo.type+")", value:MxAttrInfo.id });
								else
									listOfDisableOption.push({label:MxAttrInfo.name + " ("+MxAttrInfo.type+")", value:MxAttrInfo.id });
						}
					}

					listOfEnableOption.forEach(function(matrixOption){
						attrsSelectMatrix.add(matrixOption );
						attrsSelectMatrix.enable(matrixOption);
					});

					listOfDisableOption.forEach(function(matrixOption){
						attrsSelectMatrix.add( matrixOption);
						attrsSelectMatrix.disable(matrixOption);

					});

				}
			},


			/*buildLinkedMappingView : function (derivativeMapping, derivedMapping ) {

				var listMapping, listDerivativeMapping,listDerivedMapping,cpt=0, txtSide,text;

				listMapping = UWA.createElement('dl', {
				});

				if(derivativeMapping.length !==0)
					listDerivativeMapping = UWA.createElement('dt', {
						'text': "Derivative Mapping"
					}).inject(listMapping);

				UIview.buildListMappingView(derivativeMapping,listMapping);

				if(derivedMapping.length !==0)
					listDerivedMapping = UWA.createElement('dt', {
						'text': "Derived Mapping"
					}).inject(listMapping);
				UIview.buildListMappingView(derivedMapping,listMapping);

				return listMapping;
			},*/

			/*buildLinkedMappingView : function (attrsSelectVPM,attrsSelectMatrix,attrMappingMap,listMapping) {

				var selectedVPMAttrOpt, position,selectedVPMAttr,listOfMappedMxattr,selectedMxAttrOpt,selectedMxAttr,listOfMappedVPMattr,message,childrenList
				childrenList = listMapping.getChildren();
				if(childrenList!=undefined)
					UWA.Array.invoke(childrenList, 'remove');

				selectedVPMAttrOpt = attrsSelectVPM.getSelection(false);
				selectedMxAttrOpt = attrsSelectMatrix.getSelection(false);

				if(selectedVPMAttrOpt.length!=0 )
				{

					position = selectedVPMAttrOpt[0].value.indexOf(",");
					if(position != -1)
						selectedVPMAttr = selectedVPMAttrOpt[0].value.slice(0,position);
					listOfMappedMxattr = (attrMappingMap.VPM).get(selectedVPMAttr);

					if(listOfMappedMxattr !=undefined)
					{
						message = "use VPM attribute with BOTH direction.";
						UIview.buildListMappingView(listOfMappedMxattr.get("BOTH"),listMapping, message);

						message = "use VPM attribute with VPM_To_MX direction.";
						UIview.buildListMappingView(listOfMappedMxattr.get("VPM_To_MX"),listMapping, message);

						message = "use VPM attribute with VPM_To_MX direction.";
						UIview.buildListMappingView(listOfMappedMxattr.get("MX_To_VPM"),listMapping, message);
					}
					else
						UWA.createElement('li', {
							'text':"VPM attribute not already used in this mapping or in a linked mapping"
						}).inject(listMapping);
				}

				if(selectedMxAttrOpt.length!=0)
				{
					position = selectedMxAttrOpt[0].value.indexOf(",");
					if(position != -1)
						selectedMxAttr = selectedMxAttrOpt[0].value.slice(0,position);
					listOfMappedVPMattr=(attrMappingMap.MX).get(selectedMxAttr);


					if(listOfMappedVPMattr!=undefined)
					{

						message = "use Mx attribute with BOTH direction.";
						UIview.buildListMappingView(listOfMappedVPMattr.get("BOTH"),listMapping, message);

						message =  "use Mx attribute with VPM_To_MX direction.";
						UIview.buildListMappingView(listOfMappedVPMattr.get("VPM_To_MX"),listMapping, message);

						message =  "use Mx attribute with VPM_To_MX direction.";
						UIview.buildListMappingView(listOfMappedVPMattr.get("MX_To_VPM"),listMapping, message)	;
					}
					else
						UWA.createElement('li', {
							'text':"Matrix attribute not already used in this mapping or in a linked mapping"
						}).inject(listMapping);
				}

			},*/



			/*buildListMappingView : function (listOfEltMapping,listMapping ) {
				var cpt=0,txtSide,text;
				for(cpt=0;cpt<listOfEltMapping.length;cpt++)
				{
					if(listOfEltMapping[cpt].SynchDirection=="BOTH")
						txtSide="<=>";
					else if (listOfEltMapping[cpt].SynchDirection=="VPM_To_MX")
						txtSide="=>";
					else if (listOfEltMapping[cpt].SynchDirection=="MX_To_VPM")
						txtSide="<=";

					text = listOfEltMapping[cpt].VPMObject + txtSide +  listOfEltMapping[cpt].MatrixObject;
					UWA.createElement('dd', {
						'text': text
					}).inject(listMapping);
				}


			},*/

			/*buildListMappingView : function (listOfMappedAttr,listMapping, message ) {
				var cpt=0,txtSide,text,listOfMappingForAttr,mapping,position,messageInfo,eltMapping;


				if(listOfMappedAttr.length!=0)
				{
					

					for(cpt=0;cpt<listOfMappedAttr.length;cpt++)
					{
						mapping = listOfMappedAttr[cpt].mapping;
						eltMapping = mapping.element;
						if(eltMapping.SynchDirection=="BOTH")
							txtSide="<=>";
						else if (eltMapping.SynchDirection=="VPM_To_MX")
							txtSide="=>";
						else if (eltMapping.SynchDirection=="MX_To_VPM")
							txtSide="<=";

						text = eltMapping.VPMObject + txtSide +  eltMapping.MatrixObject;

						messageInfo = mapping.position + " mapping "+ text +" "+ message;
						UWA.createElement('li', {
							'text': messageInfo
						}).inject(listMapping);
					}
				}


			},*/

			buildAddMappingWarningMessage : function (mappingArray, direction ) {
				var messageArray = new Array(), mappingMessage = "",  mapping;

				mappingArray.forEach(function(param) 
						{
					mapping = param.mapping.element;
					mappingMessage =  mapping.VPMObject + direction + mapping.MatrixObject; 
					if(messageArray.indexOf(mappingMessage) === -1)
					{
						messageArray.push(mappingMessage);
					}

						});

				return messageArray.join();
			},

			displayAddMappingWarningMessage : function (messageDiv,popoverInfoMapping ,messages ) {
				var messageList,iconInfo,cpt=0;
				if(messageDiv!=undefined)
				{
					iconInfo = messageDiv.getElement(".InfoAddMapping");
					if(messages.length !==0)
					{
						iconInfo.show();
						messageList =UWA.createElement('ul', {'class' : 'ListAddMappingMessage'});

						for(cpt=0;cpt<messages.length;cpt++)
						{
							UWA.createElement('li', {
								'text':messages[cpt],
							}).inject(messageList);
						}


						popoverInfoMapping.setBody(messageList);
					}
					else
					{
						popoverInfoMapping.setBody("");
						iconInfo.hide();
					}
				}
			},

			hideAddMappingWarningMessage : function (messageDiv) {
				var iconInfo;
				iconInfo = messageDiv.getElement(".InfoAddMapping");
				if(iconInfo != undefined)
					iconInfo.hide();
			},


			/*groupAttributeItf : function (listOfAttributeInfo) {
				var mapAttributeInfo = new Map(),i, attributeInfo, mapvalue,mapKey="Default";

				for (i=0; i<listOfAttributeInfo.length;i++)
				{
					attributeInfo = listOfAttributeInfo[i];
					if(attributeInfo.itf!==undefined && attributeInfo.itf!=="") mapKey = "Custo";
					else mapKey="Default";

					mapvalue = mapAttributeInfo.get(mapKey);
					if(mapvalue === undefined)
					{
						mapvalue = new Array();
						mapAttributeInfo.set(mapKey,mapvalue );
					}
					mapvalue.push(attributeInfo);	
				}
				return mapAttributeInfo;
			},*/
			
			
			
			
		/*	ShowModifyDirectionPanel: function (lineAttr,VPMType,MatrixType,attributeMapping,kindOfMapping) {
				
				var  iconInfoMessageBOTH,iconInfoMessageVPMENG,iconInfoMessageENGVPM,divMessageBOTH, 
				divMessageVPMENG, divMessageENGVPM,popoverInfoMappingBOTH,popoverInfoMappingVPMENG,popoverInfoMappingENGVPM,
				OKBtn, CancelBtn,modalbodydiv, modalbodyTable,modaltbody,lineModal,iCell,iCell1, toggleBoth, toggleVPM, toggleENG, changeDirectionModal, modifyDirectionTitle ;


				modifyDirectionTitle = UWA.createElement('h4', {
					text   : MappingManagementNLS.ModifyDirectionTitle.format(attributeMapping.VPMAttribute,attributeMapping.MatrixAttribute) ,
				});

				modalbodydiv = UWA.createElement('div', {
					'class': 'PartProductAddMappingDiv',
				})


				modalbodyTable =  UWA.createElement('table', {
					'id': 'PartProductAddMappingTable',
					'class': 'table table-condensed table-hover'
				}).inject(modalbodydiv);


				modaltbody = UWA.createElement('tbody', {
					'class': 'addMappingBody'
				}).inject(modalbodyTable);

				lineModal = UWA.createElement('tr').inject(modaltbody);

				iCell = UWA.createElement('td', {
					'Align' : 'left',
				});

				iCell1 = UWA.createElement('td', {
					'Align' : 'left',
					'width' : '92%'
				}).inject(iCell);

				UWA.createElement('p', {
					text   : MappingManagementNLS.side,
					'class': 'font-3dslight'// font-3dsbold
				}).inject(iCell1);

				iCell.inject(lineModal);

				iCell = UWA.createElement('td', {
					'Align' : 'left',
				}).inject(lineModal);

				
				toggleBoth =  new Toggle({ name: "optionsRadiosSide", value: "both", className: "primary"}).inject(iCell);
				toggleVPM =  new Toggle({ name: "optionsRadiosSide", value: "VPM to ENG", className: "primary"}).inject(iCell);
				toggleENG =  new Toggle({ name: "optionsRadiosSide", value: "ENG to VPM", className: "primary"}).inject(iCell);


				var iCell2 = UWA.createElement('td', {
					'Align' : 'left',
				}).inject(lineModal);
				divMessageBOTH = UWA.createElement('div', {'class':'divAddMappingMessage'}).inject(iCell2);
				divMessageVPMENG = UWA.createElement('div', {'class':'divAddMappingMessage'}).inject(iCell2);
				divMessageENGVPM = UWA.createElement('div', {'class':'divAddMappingMessage'}).inject(iCell2);
				
				
				if(attributeMapping.SynchDirection === "BOTH" ) {toggleBoth.hide();divMessageBOTH.hide();}
				if(attributeMapping.SynchDirection === "VPM_To_MX" ) {toggleVPM.hide();divMessageVPMENG.hide();}
				if(attributeMapping.SynchDirection === "MX_To_VPM" ) {toggleENG.hide();divMessageENGVPM.hide();}
				


				iconInfoMessageBOTH = UWA.createElement('span', {
					'class' : 'InfoAddMapping fonticon fonticon-info'
				}).inject(divMessageBOTH);
				iconInfoMessageBOTH.hide();
				popoverInfoMappingBOTH = new Popover({
					target   : iconInfoMessageBOTH,
					trigger  : "hover",
					animate  : "true",
					position : 'left',
					body     : "",
					title    : 'BOTH'
				});

				iconInfoMessageVPMENG = UWA.createElement('span', {
					'class' : 'InfoAddMapping fonticon fonticon-info'
				}).inject(divMessageVPMENG);
				iconInfoMessageVPMENG.hide();
				popoverInfoMappingVPMENG = new Popover({
					target   : iconInfoMessageVPMENG,
					trigger  : "hover",
					animate  : "true",
					position : 'left',
					body     : "",
					title    : 'VPM to ENG'
				});

				iconInfoMessageENGVPM = UWA.createElement('span', {
					'class' : 'InfoAddMapping fonticon fonticon-info'
				}).inject(divMessageENGVPM);
				iconInfoMessageENGVPM.hide();
				popoverInfoMappingENGVPM = new Popover({
					target   : iconInfoMessageENGVPM,
					trigger  : "hover",
					animate  : "true",
					position : 'left',
					body     : "",
					title    : 'ENG to VPM'
				});

				UWA.createElement('ul', {'class' : 'ListAddMappingMessage'}).inject(divMessageBOTH);
				UWA.createElement('ul', {'class' : 'ListAddMappingMessage'}).inject(divMessageVPMENG);
				UWA.createElement('ul', {'class' : 'ListAddMappingMessage'}).inject(divMessageENGVPM);
				
				
				var listOfVPMTypeRel,listOfMxTypeRel,listOfLinkedMapping,attrMappingMap,listOfMappedMXattr,listOfMappedVPMattr, VPMTypeRelInfo, MatrixTypeRelInfo, directionAvailable,authorizedDirection,
				messagesBOTH,messagesVPMENG,messagesENGVPM;
				
				if(kindOfMapping.toUpperCase()==="TYPE")
				{
					listOfVPMTypeRel = this.listOfCustoVPMType;
					listOfMxTypeRel = this.listOfCustoPartType;
				}
				else
				{
					listOfVPMTypeRel = this.listOfCustoVPMRel;
					listOfMxTypeRel= this.listOfCustoEBOMRel;
				}
				
				
				VPMTypeRelInfo = listOfVPMTypeRel.get(VPMType);
				MatrixTypeRelInfo = listOfMxTypeRel.get (MatrixType);	

				OKBtn = new Button({
					value : "Apply",
					id    : "modalOKButton",
					className : 'btn primary'
				});
				//OKBtn.disable();

				CancelBtn = new Button({
					value : "Cancel",
					id    : 'modalCancelButton',
					className : 'btn default'
				});
				
				
				if(VPMTypeRelInfo !== undefined  && MatrixTypeRelInfo !== undefined)	
				{
					listOfLinkedMapping = UIview.getListOfLinkedMapping(VPMTypeRelInfo,MatrixTypeRelInfo,kindOfMapping,listOfVPMTypeRel,listOfMxTypeRel,this.listofTypeRelMapping);
					attrMappingMap = UIview.buildAttributesMappedWith(listOfLinkedMapping,attributeMapping);
					listOfMappedMXattr = (attrMappingMap.VPM).get(attributeMapping.VPMAttribute);
					listOfMappedVPMattr = (attrMappingMap.MX).get(attributeMapping.MatrixAttribute);
					
					directionAvailable = UIview.CheckRulesToAddAttrMapping(VPMTypeRelInfo, attributeMapping.VPMAttribute ,MatrixTypeRelInfo,attributeMapping.MatrixAttribute,kindOfMapping, listOfMappedMXattr, listOfMappedVPMattr);
					//UIview.modifyToggleAccordingAvailableDirection( attrVPM, attrMatrix,OKBtn, toggleBoth,toggleVPM,toggleENG,directionAvailable,divMessageBOTH,popoverInfoMappingBOTH,divMessageVPMENG,popoverInfoMappingVPMENG,divMessageENGVPM,popoverInfoMappingENGVPM);
					
					if(directionAvailable!==undefined)
					{
						if(!directionAvailable.BOTH) toggleBoth.setDisabled(true);
						if(!directionAvailable.VPM_To_MX) toggleVPM.setDisabled(true);
						if(!directionAvailable.MX_To_VPM) toggleENG.setDisabled(true);

						messagesBOTH = directionAvailable.message.BOTH;
						messagesVPMENG = directionAvailable.message.VPM_To_MX;
						messagesENGVPM = directionAvailable.message.MX_To_VPM;
					}

					
					if( !toggleBoth.isDisabled() && attributeMapping.SynchDirection !== "BOTH") toggleBoth.check();
					else if(!toggleVPM.isDisabled()&& attributeMapping.SynchDirection !== "VPM_To_MX") toggleVPM.check();
					else if(!toggleENG.isDisabled()&& attributeMapping.SynchDirection !== "MX_To_VPM") toggleENG.check();
					
					if(!toggleENG.isChecked() && !toggleVPM.isChecked() && !toggleBoth.isChecked())
						OKBtn.setDisabled(true);
		

					UIview.displayAddMappingWarningMessage (divMessageBOTH,popoverInfoMappingBOTH ,messagesBOTH );
					UIview.displayAddMappingWarningMessage (divMessageVPMENG,popoverInfoMappingVPMENG ,messagesVPMENG );
					UIview.displayAddMappingWarningMessage (divMessageENGVPM,popoverInfoMappingENGVPM ,messagesENGVPM );
				}


				changeDirectionModal = new Modal({
					className: 'add-mapping-modal',
					closable: true,
					header  :modifyDirectionTitle,
					body    : modalbodydiv,
					footer  : [ OKBtn, CancelBtn ]
				});

				CancelBtn.addEvent("onClick", function (e) {
					UWA.log(e);//that.onCancelCalled();
					changeDirectionModal.hide();
				});
				
				OKBtn.addEvent("onClick", function (e) {
					var txtSide,deployAttrcell,imgAttrSpan,directionAttributeCell, direction;
					
					txtSide;
					if(toggleBoth.isChecked())
					{
						txtSide="BOTH";
						direction = UIview.direction.BOTH;
					}
					else if (toggleVPM.isChecked())
					{
						txtSide="VPM_To_MX";
						direction = UIview.direction.VPM_To_MX;
					}
					else if (toggleENG.isChecked())
					{
						txtSide="MX_To_VPM";
						direction = UIview.direction.MX_To_VPM;
					}
					else
					{
						txtSide="BOTH";
						direction = UIview.direction.BOTH;
					}

					attributeMapping.SynchDirection = txtSide;

					directionAttributeCell = lineAttr.cells[UIview.cellsAttrIndex.side];
					directionAttributeCell.value=direction;
					directionAttributeCell.empty();
					UWA.createElement('p', {
						text   : direction,
					}).inject(directionAttributeCell);


					if(attributeMapping.status === "Deployed" || attributeMapping.status === "Stored")
					{
						
						if(attributeMapping.status === "Stored")
						attributeMapping.status = "ModifiedStored";
						else
							attributeMapping.status = "ModifiedDeployed";

						//lineAttr.cells[UIview.cellsAttrIndex.action].hide();
						var arrayAction = lineAttr.cells[UIview.cellsAttrIndex.action].getElements('span');
						arrayAction.forEach(function(action){
							action.hide();
						});

						deployAttrcell=lineAttr.cells[UIview.cellsAttrIndex.deployFlag];
						deployAttrcell.empty();
						deployAttrcell.value = "Modified";
						deployAttrcell.title = MappingManagementNLS.ModifiedNotApplied;
						imgAttrSpan = ParametersLayoutViewUtilities.buildImgSpan('pencil', '1.5', 'red');
						imgAttrSpan.inject(deployAttrcell);
					}
					changeDirectionModal.hide();

					
				});

				
				changeDirectionModal.inject(this.contentDiv);
				changeDirectionModal.show();



		
	},*/

			BuildMappingToSend : function(attrMappingPartProduct)
			{
				var isInvalidMapping = false;
				var mappingToSend = new Array();
				var i=0;
				for (i=0;i<attrMappingPartProduct.length;i++)
				{
					//if(attrMappingPartProduct[i].status !== "RemovedStored" && attrMappingPartProduct[i].status !== "RemovedDeployed")
					if(attrMappingPartProduct[i].status.indexOf("Removed")===-1)
					{
						if(attrMappingPartProduct[i].status === "InvalidStored" ) isInvalidMapping=true;
						else
						{
							//var vpmAttr = attrMappingPartProduct[i].VPMAttribute

							//var vpmAttrInfo = MappingViewUtilities.retrieveAttributeInfo( typeVPMInfo,vpmAttr);

							//var mxAttr = attrMappingPartProduct[i].MatrixAttribute
							//var mxAttrInfo = MappingViewUtilities.retrieveAttributeInfo( typePartInfo,mxAttr);

							//if(!attrMappingPartProduct[i].VPMAttributeDeployed  || !attrMappingPartProduct[i].MatrixAttributeDeployed) usedNonDeployedAttribute = true
							//var mappingLine ={MatrixAttribute:mxAttrInfo,SynchDirection:attrMappingPartProduct[i].SynchDirection,VPMAttribute:vpmAttrInfo, isBaseMapping:attrMappingPartProduct[i].isBaseMapping};
							//mappingToSend.push(mappingLine);
							mappingToSend.push(attrMappingPartProduct[i]);
						}
					}

				}
				return {isInvalidMapping:isInvalidMapping,mappingToSend:mappingToSend }
			},
			
			
			onApplySuccessForAttributes : function (mappingElt,item) {
				var item,attrTable,nbofLines,cptAttr,attrLines,cellAttr,mappingEltAttr,imgSpan,listOfAttributes,attrLineToRemove=new Array();

				listOfAttributes = mappingElt.AttributeMapping;
				//item = item.elements.content.children[0];
				if(item !== undefined)
				{
					attrTable = item.getElement(".attrstbodyMapping");
					nbofLines = attrTable.children.length;
					for(cptAttr=1;cptAttr<nbofLines;cptAttr++)
					{
						attrLines = attrTable.children[cptAttr];
						cellAttr=attrLines.cells[UIview.cellsAttrIndex.deployFlag];
						mappingEltAttr=UIview.retrieveMappingAttrEntry(attrLines.cells[UIview.cellsAttrIndex.VPMAttr].value,attrLines.cells[UIview.cellsAttrIndex.MatrixAttr].value,listOfAttributes);
						if(cellAttr.value==="New" ||cellAttr.value === "Stored")
						{
							if(mappingEltAttr!=undefined)
							{
								mappingEltAttr.status="Deployed";
								cellAttr.empty();
								cellAttr.value="Deployed";
								imgSpan = ParametersLayoutViewUtilities.buildImgSpan('check', '1.5', 'green');
								imgSpan.inject(cellAttr);
							}
						}
						else if(cellAttr.value==="Removed")
						{
							//attrLines.remove();
							attrLineToRemove.push(attrLines);
							UIview.removeMappingAttr(mappingEltAttr,listOfAttributes);
						}
					}
					
					attrLineToRemove.forEach(function(attrMapping){
						attrMapping.remove();
					});
				}	
			},


			resetForForAttributes : function (mappingElt,item) {
				var item,attrTable,nbofLines,cptAttr,attrLines,cellAttr,mappingEltAttr,listOfAttributes,attrLinesToRemove=new Array();

				if(mappingElt!=undefined)
				{
					listOfAttributes = mappingElt.AttributeMapping;
					if(item!=undefined)
					{
						
						if(item !== undefined)
						{
							attrTable = item.getElement(".attrstbodyMapping");
							nbofLines = attrTable.children.length;
							for(cptAttr=1;cptAttr<nbofLines;cptAttr++)
							{
								attrLines = attrTable.children[cptAttr];
								cellAttr=attrLines.cells[UIview.cellsAttrIndex.deployFlag];
								mappingEltAttr=mappingElt=UIview.retrieveMappingAttrEntry(attrLines.cells[UIview.cellsAttrIndex.VPMAttr].value,attrLines.cells[UIview.cellsAttrIndex.MatrixAttr].value,listOfAttributes);


								if(mappingEltAttr.status==="New" || mappingEltAttr.status.indexOf("Stored")!==-1)
								{
									///attrLines.remove();
									attrLinesToRemove.push(attrLines);
									UIview.removeMappingAttr(mappingEltAttr,listOfAttributes);

								}
								else if(mappingEltAttr.status.indexOf("Removed")!==-1)
								{
									if(mappingEltAttr!=undefined)
										UIview.unsetRemoveAttrLine.call(this,attrLines,mappingEltAttr,listOfAttributes);
								}
								/*else if(mappingEltAttr.status==="Modified")
									MappingViewUtilities.unsetModifiedAttrLine(attrLines,mappingEltAttr);*/
							}

							attrLinesToRemove.forEach (function (attrline) {attrline.remove();});
						}
					}
				}

			},


			BuildAddMappingPanel : function ( title, VPMSelectPlaceHolder, MatrixSelectPlaceHolder, labelVPMtxt, labelMatrixtxt, labelProductToPart, labelPartToProduct) {


				var addMappingTitle, labelVPM, labelMatrix,  iconInfoMessageBOTH,iconInfoMessageVPMENG,iconInfoMessageENGVPM,divMessageBOTH, 
				divMessageVPMENG, divMessageENGVPM,popoverInfoMappingBOTH,popoverInfoMappingVPMENG,popoverInfoMappingENGVPM,
				OKBtn, CancelBtn,modalbodydiv, modalbodyTable,modaltbody,lineModal,iCell,iCell1, toggleBoth, toggleVPM, toggleENG,selectVPM, selectMatrix, addMappingModal ;


				addMappingTitle = UWA.createElement('h4', {
					text   : title,
				});

				modalbodydiv = UWA.createElement('div', {
					'class': 'PartProductAddMappingDiv',
				})

				/*UWA.createElement('input', {
					'id': 'inputTypeMapping',
					'class': 'inputTypeMapping',
					'type': 'hidden',
					'name': 'type mapping',
					'value': typeMapping.toLowerCase(),
				}).inject(modalbodydiv);*/

				modalbodyTable =  UWA.createElement('table', {
					'id': 'PartProductAddMappingTable',
					'class': 'table table-condensed table-hover'
				}).inject(modalbodydiv);


				modaltbody = UWA.createElement('tbody', {
					'class': 'addMappingBody'
				}).inject(modalbodyTable);

				lineModal = UWA.createElement('tr').inject(modaltbody);

				iCell = UWA.createElement('td', {
					'Align' : 'left',
				});

				iCell1 = UWA.createElement('td', {
					'Align' : 'left',
					'width' : '92%'
				}).inject(iCell);

				labelVPM = UWA.createElement('p', {
					text   : labelVPMtxt ,
					'class': 'font-3dslight'// font-3dsbold
				}).inject(iCell1);

				iCell.inject(lineModal);


				iCell = UWA.createElement('td', {
					'Align' : 'left',
				}).inject(lineModal);

				selectVPM =  new Select({
					nativeSelect: true,
					placeholder: VPMSelectPlaceHolder,
					multiple: false,
				});
				selectVPM.inject(iCell);

				lineModal = UWA.createElement('tr').inject(modaltbody);

				iCell = UWA.createElement('td', {
					'Align' : 'left',
				});

				iCell1 = UWA.createElement('td', {
					'Align' : 'left',
					'width' : '92%'
				}).inject(iCell);

				labelMatrix = UWA.createElement('p', {
					text   : labelMatrixtxt ,
					'class': 'font-3dslight'// font-3dsbold
				}).inject(iCell1);

				iCell.inject(lineModal);


				iCell = UWA.createElement('td', {
					'Align' : 'left',
				}).inject(lineModal);

				selectMatrix =  new Select({
					nativeSelect: true,
					placeholder: MatrixSelectPlaceHolder,
					multiple: false,
				});
				selectMatrix.inject(iCell);

				lineModal = UWA.createElement('tr').inject(modaltbody);

				iCell = UWA.createElement('td', {
					'Align' : 'left',
				});

				iCell1 = UWA.createElement('td', {
					'Align' : 'left',
					'width' : '92%'
				}).inject(iCell);

				UWA.createElement('p', {
					text   : MappingManagementNLS.side,
					'class': 'font-3dslight'// font-3dsbold
				}).inject(iCell1);

				iCell.inject(lineModal);

				iCell = UWA.createElement('td', {
					'Align' : 'left',
				}).inject(lineModal);

				toggleBoth =  new Toggle({ name: "optionsRadiosSide", value: MappingManagementNLS.both, className: "primary"}).inject(iCell);
				toggleBoth.setDisabled(true);
				toggleVPM =  new Toggle({ name: "optionsRadiosSide", value: labelProductToPart, className: "primary"}).inject(iCell);
				toggleVPM.setDisabled(true);
				toggleENG =  new Toggle({ name: "optionsRadiosSide", value: labelPartToProduct, className: "primary"}).inject(iCell);
				toggleENG.setDisabled(true);

				var iCell2 = UWA.createElement('td', {
					'Align' : 'left',
				}).inject(lineModal);
				divMessageBOTH = UWA.createElement('div', {'class':'divAddMappingMessage'}).inject(iCell2);
				divMessageVPMENG = UWA.createElement('div', {'class':'divAddMappingMessage'}).inject(iCell2);
				divMessageENGVPM = UWA.createElement('div', {'class':'divAddMappingMessage'}).inject(iCell2);


				iconInfoMessageBOTH = UWA.createElement('span', {
					'class' : 'InfoAddMapping fonticon fonticon-info'
				}).inject(divMessageBOTH);
				iconInfoMessageBOTH.hide();
				popoverInfoMappingBOTH = new Popover({
					target   : iconInfoMessageBOTH,
					trigger  : "hover",
					animate  : "true",
					position : 'left',
					body     : "",
					title    : 'BOTH'
				});

				iconInfoMessageVPMENG = UWA.createElement('span', {
					'class' : 'InfoAddMapping fonticon fonticon-info'
				}).inject(divMessageVPMENG);
				iconInfoMessageVPMENG.hide();
				popoverInfoMappingVPMENG = new Popover({
					target   : iconInfoMessageVPMENG,
					trigger  : "hover",
					animate  : "true",
					position : 'left',
					body     : "",
					title    : 'Product to Part'
				});

				iconInfoMessageENGVPM = UWA.createElement('span', {
					'class' : 'InfoAddMapping fonticon fonticon-info'
				}).inject(divMessageENGVPM);
				iconInfoMessageENGVPM.hide();
				popoverInfoMappingENGVPM = new Popover({
					target   : iconInfoMessageENGVPM,
					trigger  : "hover",
					animate  : "true",
					position : 'left',
					body     : "",
					title    : 'Part to Product'
				});

				UWA.createElement('ul', {'class' : 'ListAddMappingMessage'}).inject(divMessageBOTH);
				UWA.createElement('ul', {'class' : 'ListAddMappingMessage'}).inject(divMessageVPMENG);
				UWA.createElement('ul', {'class' : 'ListAddMappingMessage'}).inject(divMessageENGVPM);


				OKBtn = new Button({
					value : MappingManagementNLS.Apply,
					id    : "modalOKButton",
					className : 'btn primary'
				});
				OKBtn.disable();

				CancelBtn = new Button({
					value : MappingManagementNLS.Cancel,
					id    : 'modalCancelButton',
					className : 'btn default'
				});


				addMappingModal = new Modal({
					className: 'add-mapping-modal',
					closable: true,
					header  :addMappingTitle,
					body    : modalbodydiv,
					footer  : [ OKBtn, CancelBtn ]
				});


				return [addMappingModal, {selectVPM:selectVPM,selectMatrix:selectMatrix}, {toggle:toggleVPM, div:divMessageVPMENG, popover:popoverInfoMappingVPMENG},{toggle:toggleENG, div:divMessageENGVPM, popover:popoverInfoMappingENGVPM},{toggle:toggleBoth, div:divMessageBOTH, popover:popoverInfoMappingBOTH},{OKButton:OKBtn, CancelButton:CancelBtn }];
			},
			
			
            setDeletedCellStyle : function (iCell) {
                var previousVal = iCell.value,
                previousTxt = iCell.getText();
                if(previousTxt === undefined) previousTxt = previousVal;
                iCell.empty();
                UWA.createElement('del', {
                    text   : previousTxt,
                    value  : previousVal,
                }).inject(iCell);
            },

            setNormalCellStyle : function (iCell) {
                var previousVal = iCell.value,
                previousTxt = iCell.getText();
                if(previousTxt === undefined) previousTxt = previousVal;
                iCell.empty();
                UWA.createElement('p', {
                    text   : previousTxt,
                    value  : previousVal,
                }).inject(iCell);
            },
            
            
            PopulateAddMappingAttributePanel: function (typeMapping,parentSide,kindOfMapping,attrtbody,listOfVPMTypeRel,listOfMxTypeRel,listofTypeRelMapping,wdthArrayAttr)
			{

				var result, VPMTypeRelInfo, MatrixTypeRelInfo, selectVPM, selectMatrix, VPMAttributes,MatrixAttributes,
				directionAvailableMap = new Map(), attrMappingMap, listOfLinkedMapping, labelVPM, labelENG, toggleVPM, divVPMMessage, VPMPopover, toggleENG,
				divENGMessage, ENGPopover, toggleBoth, divBothMessage, BothPopover, OkButton, CancelButton,addMappingModal, i, that=this;


				/*if(kindOfMapping.toUpperCase()==="TYPE")
		{*/
				//listOfVPMTypeRel = this.listOfCustoVPMType;
				//listOfMxTypeRel = this.listOfCustoPartType;
				/*}
		else
		{
			listOfVPMTypeRel = this.listOfCustoVPMRel;
			listOfMxTypeRel= this.listOfCustoEBOMRel;
		}*/


				labelVPM = typeMapping.VPMObjectName+" "+MappingManagementNLS.attribute;
				labelENG = typeMapping.MatrixObjectName+" "+MappingManagementNLS.attribute;

				function compare(attrInfo1, attrInfo2) {
					if (attrInfo1.name.toUpperCase() <  attrInfo2.name.toUpperCase())
						return -1;
					if (attrInfo1.name.toUpperCase() >  attrInfo2.name.toUpperCase())
						return 1;
					return 0;
				}

				VPMTypeRelInfo = listOfVPMTypeRel.get(typeMapping.VPMObject);
				if(VPMTypeRelInfo!==undefined)  
				{
					VPMAttributes = VPMTypeRelInfo.attributeInfo;
					VPMAttributes.sort(compare);
				}


				MatrixTypeRelInfo = listOfMxTypeRel.get(typeMapping.MatrixObject);
				if(MatrixTypeRelInfo!==undefined)  {
					MatrixAttributes = MatrixTypeRelInfo.attributeInfo;
					MatrixAttributes.sort(compare);
				}

				result = UIview.BuildAddMappingPanel( MappingManagementNLS.addMappingAttributeTitle.format(typeMapping.VPMObjectName,typeMapping.MatrixObjectName), MappingManagementNLS.selectAttr.format(typeMapping.VPMObjectName), MappingManagementNLS.selectAttr.format(typeMapping.MatrixObjectName), labelVPM, labelENG, MappingManagementNLS.unilateralDirection.format(typeMapping.VPMObjectName,typeMapping.MatrixObjectName), MappingManagementNLS.unilateralDirection.format(typeMapping.MatrixObjectName,typeMapping.VPMObjectName));

				addMappingModal = result[0];
				selectVPM = result[1].selectVPM;
				selectMatrix = result[1].selectMatrix;
				toggleVPM = result[2].toggle;
				divVPMMessage = result[2].div;
				VPMPopover=  result[2].popover;
				toggleENG= result[3].toggle;
				divENGMessage = result[3].div;
				ENGPopover= result[3].popover;
				toggleBoth= result[4].toggle;
				divBothMessage = result[4].div;
				BothPopover = result[4].popover;
				OkButton = result[5].OKButton;
				CancelButton = result[5].CancelButton;

				//Build VPM attributes list


				/*for (i=0; i<VPMAttributes.length;i++)
			selectVPM.addOption({label:VPMAttributes[i].id + " ("+VPMAttributes[i].type+")", value:VPMAttributes[i].id+", "+VPMAttributes[i].type });*/


				/*function addEltToSelect(value, key,select,filterForVPM) {
			var i, attributeInfo,attributeName,position,VPMoption;
			for (i=0; i<value.length;i++)
			{
				attributeInfo = value[i];
				attributeName = attributeInfo.id;
				VPMoption = {label:attributeInfo.name + " ("+attributeInfo.type+")", value:attributeInfo.id,group:key };
				select.addOption(VPMoption);

				if(filterForVPM)
				{
					var listOfMappedMXattr = (attrMappingMap.VPM).get(attributeInfo.id); 
					if(listOfMappedMXattr!=undefined)
						if(listOfMappedMXattr.get("VPM_To_MX").length!=0 || listOfMappedMXattr.get("MX_To_VPM").length!=0 || listOfMappedMXattr.get("BOTH").length!=0)
							select.disable(VPMoption);
				}
			}
		}*/


				function addEltToSelect(value, select,filterForVPM) {
					var i, attributeInfo,attributeName,attributeItf,position,option,listOfEnableOption = new Array(), listOfDisableOption=new Array(), attrType;
					for (i=0; i<value.length;i++)
					{
						attributeInfo = value[i];

						attributeItf = attributeInfo.itf;
						
						//select only OOTB attribute and custo attribute (attributes coming from another interface cloud added once bug will be corrected)
						if(attributeItf === null || attributeItf ==="" || attributeItf === "XP_VPMReference_Ext" || attributeItf === "XP_Part_Ext")
						{
							attributeName = attributeInfo.id;
							if(attributeInfo.isenum === true )
								attrType = UIview.enumType;
							else
								attrType = attributeInfo.type;
							option = {label:attributeInfo.name + " ("+attrType+")", value:attributeInfo.id };

							if(filterForVPM)
							{
								var listOfMappedMXattr = (attrMappingMap.VPM).get(attributeInfo.id); 
								if( listOfMappedMXattr!=undefined && (listOfMappedMXattr.get("VPM_To_MX").length!=0 || listOfMappedMXattr.get("MX_To_VPM").length!=0 || listOfMappedMXattr.get("BOTH").length!=0))
									listOfDisableOption.push(option);
								else listOfEnableOption.push(option);
							}
							else
								listOfEnableOption.push(option);
						}
					}

					listOfEnableOption.forEach(function(optionSelect){
						select.add(optionSelect );
						select.enable(optionSelect);
					});

					listOfDisableOption.forEach(function(optionSelect){
						select.add( optionSelect);
						select.disable(optionSelect);

					});

				}
				
				listOfLinkedMapping = UIview.getListOfLinkedMapping(VPMTypeRelInfo,MatrixTypeRelInfo,kindOfMapping,listOfVPMTypeRel,listOfMxTypeRel,listofTypeRelMapping);
				attrMappingMap = UIview.buildAttributesMappedWith(listOfLinkedMapping);



				addEltToSelect(VPMAttributes, selectVPM,true);



				addEltToSelect(MatrixAttributes, selectMatrix,false);


				/*var MapVPMAttributes = MappingViewUtilities.groupAttributeItf(VPMAttributes);
		MapVPMAttributes.forEach(function(value, key,map){ addEltToSelect(value, key,selectVPM,true);});*/

				//Build Matrix attributes
				/*for (i=0; i<MatrixAttributes.length;i++)
		{ 
			var option = {label:MatrixAttributes[i].id + " ("+MatrixAttributes[i].type+")", value:MatrixAttributes[i].id+", "+MatrixAttributes[i].type};
			selectMatrix.addOption(option);
		}*/


				/*var MapMatrixAttributes = MappingViewUtilities.groupAttributeItf(MatrixAttributes);
		MapMatrixAttributes.forEach(function(value, key,map){ addEltToSelect(value, key,selectMatrix,false);});*/

				selectMatrix.disable();



				selectVPM.addEvent("onChange",  function (e) {
					if( (selectVPM.getSelection(false)).length!=0) 
					{
						selectMatrix.enable();
						UIview.enableMatrixAttrAccordingRules( VPMTypeRelInfo, selectVPM,MatrixTypeRelInfo,selectMatrix,MatrixAttributes,parentSide, attrMappingMap,directionAvailableMap) ;
					}
					else
					{
						selectMatrix.disable();
						selectMatrix.select(0,true);
					}
					UIview.modifyToggleAccordingAvailableDirection( selectVPM, selectMatrix,OkButton, toggleBoth,toggleVPM,toggleENG,directionAvailableMap,divBothMessage,BothPopover,divVPMMessage,VPMPopover,divENGMessage,ENGPopover);
				});


				selectMatrix.addEvent("onChange", function (e) {
					UIview.modifyToggleAccordingAvailableDirection(selectVPM, selectMatrix,OkButton,toggleBoth,toggleVPM,toggleENG,directionAvailableMap,divBothMessage,BothPopover,divVPMMessage,VPMPopover,divENGMessage,ENGPopover);
				});

				CancelButton.addEvent("onClick", function (e) {
					UWA.log(e);//that.onCancelCalled();
					addMappingModal.hide();
				});

				OkButton.addEvent("onClick", function (e) {

					var selectedVPMAttr, selectedMatrixAttr, txtSide , lineAttribute, position, typeAttrVPM, typeAttrMatrix, nameAttrVPM, nameAttrMatrix, mappingElt, AttrList, mappingEltAttr,displayNameAttrMatrix,displayNameAttrVPM;

					selectedVPMAttr = selectVPM.getSelection();
					selectedMatrixAttr = selectMatrix.getSelection();

					if(toggleBoth.isChecked())
						txtSide="BOTH";
					else if (toggleVPM.isChecked())
						txtSide="VPM_To_MX";
					else if (toggleENG.isChecked())
						txtSide="MX_To_VPM";
					else txtSide="BOTH";

					nameAttrVPM = selectedVPMAttr[0].value/*.slice(0,position)*/;

					/*position = selectedVPMAttr[0].label.indexOf("(");
					if(position != -1)
					{
						displayNameAttrVPM = selectedVPMAttr[0].label.slice(0,position-1);;
						typeAttrVPM = selectedVPMAttr[0].label.slice(position+1,selectedVPMAttr[0].label.length-1);
					}*/
					
					var attrVPMInfo = UIview.retrieveAttributeInfo(VPMTypeRelInfo,nameAttrVPM);
					


					nameAttrMatrix = selectedMatrixAttr[0].value/*.slice(0,position)*/;

					/*position = selectedMatrixAttr[0].label.indexOf("(");
					if(position != -1)
					{
						displayNameAttrMatrix = selectedMatrixAttr[0].label.slice(0,position-1);
						typeAttrMatrix = selectedMatrixAttr[0].label.slice(position+1,selectedMatrixAttr[0].label.length-1);

					}*/

					
					var attrMXInfo = UIview.retrieveAttributeInfo(MatrixTypeRelInfo,nameAttrMatrix);
					
					

					mappingElt=UIview.retrieveMappingEntry(typeMapping.VPMObject,typeMapping.MatrixObject,listofTypeRelMapping);
					if(mappingElt!=undefined)
					{
						mappingEltAttr = { MatrixAttribute: attrMXInfo, SynchDirection: txtSide, VPMAttribute:attrVPMInfo,status:"New",isBaseMapping:false,OriginalSynchDirection:txtSide,VPMAttributeDeployed:true, MatrixAttributeDeployed:true };
						mappingElt.AttributeMapping.push(mappingEltAttr);
					}

					lineAttribute = UIview.buildAttributeLine.call(that,VPMTypeRelInfo ,MatrixTypeRelInfo ,kindOfMapping,mappingEltAttr, mappingElt.AttributeMapping,wdthArrayAttr);
					//attrbody= result[0].getBody().getElementsByTagName("tbody");;
					lineAttribute.inject(attrtbody);

					addMappingModal.hide();
				});

				return result;
				//addMappingModal.inject(this.contentDiv);
				//addMappingModal.show();
			},


	}



	return UIview;
});

/*global define, widget, document, setTimeout, console, clearTimeout, FileReader*/
/*jslint plusplus: true*/
/*jslint nomen: true*/
/*! Copyright 2017, Dassault Systemes. All rights reserved. */
/*@fullReview  CN1     18/05/15 2019xBeta2 Mapping Widget*/
define('DS/ParameterizationSkeleton/Views/ParameterizationMapping/MappingLayoutView',
		[
		 'UWA/Core',
		 'UWA/Class/View',
		 'DS/UIKIT/Modal',
		 'DS/UIKIT/Popover',
		 'DS/UIKIT/Mask',
		 'DS/UIKIT/Scroller',
		 'DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
		 'DS/ParameterizationSkeleton/Views/ParameterizationMapping/MappingViewUtilities',
		 'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler',
		 'DS/UIKIT/Input/Button',
		 'DS/UIKIT/Input/Select',
		 'DS/UIKIT/Input/Toggle',
		 'DS/UIKIT/Alert',
		 'i18n!DS/ParameterizationSkeleton/assets/nls/MappingManagementNLS',
		 'DS/WAFData/WAFData',
		 ],
		 function (UWA, View,
				 Modal,
				 Popover, Mask, Scroller,
				 ParametersLayoutViewUtilities, MappingViewUtilities,
				 URLHandler,  Button, Select, Toggle, Alert,
				 MappingManagementNLS,WAFData) {

	'use strict';

	var extendedView;

	extendedView = View.extend({
		tagName: 'div',
		className: 'generic-detail',

		init: function (options) {
			var initDate =  new Date();

			options = UWA.clone(options || {}, false);
			this._parent(options);
			this.contentDiv = null;
			this.paramScroller = null;
			this.userMessaging = null;
			this.lastAlertDate = initDate.getTime();
			this.controlDiv = null;
			this.wdthArrayAttr = /*[15,20,10,15,20,10,10]*/[35,10,35,10,10];
			this.divMapping = null;
			this.divCustoMapping =null;
			//this.custoAccordion=null;
			this.baseAccordion=null;
			this.selectMapping=null;
			this.listOfBasicVPMType =[];
			this.listOfBasicType =[];
			this.listOfCustoVPMType=new Map();
			this.listOfCustoPartType=new Map();
			//this.listOfCustoVPMRel=new Map();
			//this.listOfCustoEBOMRel=new Map();
			this.divBaseMapping;
			this.listofTypeRel;
			this.listofTypeRelMapping;
			this.mappingScroller=null;
			this.lastAlertDate = initDate.getTime();
			this.userMessaging=null;
		},

		setup: function(options) {
			UWA.log('AttributesLayoutView::setup!');
			UWA.log(options);
			//var listoftagsSetup = this.model.get('sixwTagDescription');
		},

		render: function () {
			UWA.log("AttributesLayoutView::render");
			var introDiv,
			mappingDiv,
			that = this;
			/*introText = ParamDataModelingNLS.IntroDivText.format(this.model.get('title'));*/

			this.contentDiv =  UWA.createElement('div', {'id': 'typeMainDiv'});
			Mask.mask(this.contentDiv);
			
			this.userMessaging = new Alert({
                className : 'param-alert',
                closable: true,
                visible: true,
                renderTo : document.body,
                autoHide : true,
                hideDelay : 2000,
                messageClassName : 'warning'
            });

			introDiv = UWA.createElement('div', {'class': 'information'}).inject(this.contentDiv);

			UWA.createElement('p', {
				text   : MappingManagementNLS.intro,
				'class': 'font-3dslight'//'font-3dsbold'
			}).inject(introDiv);

			this.controlDiv = ParametersLayoutViewUtilities.createApplyResetToolbar.call(this, this.contentDiv, true,
					this.applyParams.bind(this), this.resetParams.bind(this));
	
			this.container.setContent(this.contentDiv);
			this.listenTo(this.collection, {
				onSync: that.onCompleteRequestMapping
			});

			return this;
		},




		onCompleteRequestMapping : function() {

			UWA.log("MappingLayoutView::onCompleteRequestMapping");
			var resultDiv;
			var that=this;
			var MatrixType, VPMType, side, line,i,j, kindOfMapping, listofAttributesMapping, TypeName, DerivedFrom , listOfAttributeInfos, isBaseMapping, isDeployed;
			var AddMappingAttributeButton,divMapping,MatrixTypeRelInfo,VPMTypeRelInfo;


			this.divMapping = UWA.createElement('div', {
				'class': 'DivMappingScroll',
			}).inject(this.contentDiv);
			
				
					
			/*this.divBaseMapping = UWA.createElement('div', {
				'class': 'DivMapping',
			}).inject(this.divMapping);


			var labelBaseMapping = UWA.createElement('div', {
				'class': 'labelMapping',
				'text': 'Base Mapping',
			}).inject(this.divBaseMapping);*/

			/*this.divCustoMapping = UWA.createElement('div', {
				'class': 'DivMapping',
			}).inject(this.divMapping);*/

			/*var labelCustoMapping = UWA.createElement('div', {
				'class': 'labelMapping',
				'text': 'Custo Mapping',
			}).inject(this.divCustoMapping);*/


			//Recupération des types et leur attributs
			this.listofTypeRel = this.collection._models[0]._attributes.TypeRelInfo;
			this.listofTypeRelMapping = this.collection._models[0]._attributes.TypeRelMapping;

			for (i = 0; i < this.listofTypeRel.length; i++)
			{
				TypeName = this.listofTypeRel[i].id;
				DerivedFrom=this.listofTypeRel[i].derivedFrom;
				listOfAttributeInfos = this.listofTypeRel[i].AttributeInfo;

				if(DerivedFrom === "VPMReference" || TypeName==="VPMReference")
					this.listOfCustoVPMType.set(TypeName,this.listofTypeRel[i]);
				else if (DerivedFrom === "Part" || TypeName==="Part")
					this.listOfCustoPartType.set(TypeName,this.listofTypeRel[i]);
				/*else if (DerivedFrom === "VPMInstance"|| TypeName==="VPMInstance")
					this.listOfCustoVPMRel.set(TypeName,this.listofTypeRel[i]);
				else if (DerivedFrom === "EBOM"|| TypeName==="EBOM")
					this.listOfCustoEBOMRel.set(TypeName,this.listofTypeRel[i]);*/
			}

			resultDiv = UWA.createElement('div', {'class': 'result'}).inject(this.contentDiv);

			this.baseAccordion = ParametersLayoutViewUtilities.createFamilyUIKITAccordion(/*this.divBaseMapping*/this.divMapping);
			//this.custoAccordion = ParametersLayoutViewUtilities.createFamilyUIKITAccordion(this.divCustoMapping);


			for (i = 0; i < this.listofTypeRelMapping.length; i++) {

				MatrixType = this.listofTypeRelMapping[i].MatrixObject;
				VPMType = this.listofTypeRelMapping[i].VPMObject;
				side  = this.listofTypeRelMapping[i].SynchDirection;
				kindOfMapping = this.listofTypeRelMapping[i].KindOfMapping;
				listofAttributesMapping = this.listofTypeRelMapping[i].AttributeMapping;
				isBaseMapping = this.listofTypeRelMapping[i].isBaseMapping;
				status = this.listofTypeRelMapping[i].status;

				VPMTypeRelInfo = this.listOfCustoVPMType.get(VPMType);
				MatrixTypeRelInfo = this.listOfCustoPartType.get(MatrixType);


				var mappingTable = MappingViewUtilities.buildMappingLine.call(that,this.listofTypeRelMapping[i]);


				//attribute table

				var attributeMappingDiv = UWA.createElement('div', {
					'class': 'attributeMapping'
				});//table-bordered

				var attributesTable = MappingViewUtilities.buildAttributeTable.call(that,VPMTypeRelInfo,MatrixTypeRelInfo,kindOfMapping,listofAttributesMapping,that.wdthArrayAttr);
				attributesTable.inject(attributeMappingDiv);

				/*var addAttributeMappingIcon = UWA.createElement('span', {
					'class': 'fonticon fonticon-1,5x fonticon-plus',
					'title': 'add attribute mapping',
					//'onclick': 'ShowAddMappingAttributePanel()'
				}).inject(attributeMappingDiv);//table-bordered*/
				
				
				
				var AddMappingButton = new Button({
					className: 'AddMappingButton',
					icon: 'plus-circled',
					attributes: {
						disabled: false,
						'aria-hidden' : 'true',
						title : MappingManagementNLS.AddAttributeMappingTooltip,
					},
					events: {
						onClick: that.ShowAddMappingAttributePanel.bind(that,this.listofTypeRelMapping[i],side,kindOfMapping,attributesTable.getElement(".attrstbodyMapping"))
					}
				}).inject(attributeMappingDiv);

				//addAttributeMappingIcon.addEvent('click', that.ShowAddMappingAttributePanel.bind(that,VPMType,MatrixType,side,kindOfMapping,attributesTable.getElement(".attrstbodyMapping")));

			//	if(isBaseMapping)
					this.baseAccordion.addItem({
						title:  mappingTable,
						content: attributeMappingDiv,
						selected : true,
						name:VPMType+"_"+MatrixType,
					});
				/*else
					this.custoAccordion.addItem({
						title:  mappingTable,
						content: attributeMappingDiv,
						selected : false,
						name:VPMType+"_"+MatrixType,
					});*/
			}


			this.paramScroller = new Scroller({
                element: this.divMapping,
            }).inject(this.contentDiv);

			
			
			var divAddMapping = UWA.createElement('div', {
				'class': 'AddMapping'//'font-3dsbold'
			}).inject(this.contentDiv);
			
			

			//this.selectMapping = MappingViewUtilities.createAddMappingToolBar.call(this, divAddMapping,  this.ShowAddMappingPanel.bind(this));


			Mask.unmask(this.contentDiv);
		},


		
		
		resetParams : function () {
			UWA.log("applyReset");
			var that=this;
			
			 Mask.mask(this.contentDiv);
			var url = URLHandler.getURL() + "/resources/MappingWS/mapping/resetmapping?tenant=" + URLHandler.getTenant();

			WAFData.authenticatedRequest(url, {
				timeout: 100000,
				method: 'POST',
				//data: JSON.stringify(datatoSend),
				type: 'json',
				//proxy: 'passport',

				headers: {
					'Content-Type' : 'application/json',
					'Accept' : 'application/json'
				},

				onFailure : function (json) {
					that.onResetFailure.call(that,json); 
				},

				onComplete: function(json) {
					that.onResetSuccess.call(that,json);
				}

			});


			//this.UpdateCommonParamsOnServer();
		},
		
		onResetFailure : function (json) {
			UWA.log(json);
			Mask.unmask(this.contentDiv);
			// Mask.unmask(this.contentDiv);//Rb0afx
			// this.userMessaging.add({ className: "error", message: ParamDataModelingNLS.deployFailureMsg });
			this.userMessaging.add({ className: "warning", message: MappingManagementNLS.ErrorReset });
			//ParamLayoutUtilities.updateIcon(false, theImageCell);
		},


		applyParams : function () {
			UWA.log("applyParams");
			var datatoSend, that=this;
			var mappingToSend = new Array();
			var attrMappingPartProduct = this.collection._models[0]._attributes.TypeRelMapping[0].AttributeMapping;
			var i=0;
			Mask.mask(this.contentDiv);
			var typeVPMInfo = this.listOfCustoVPMType.get("VPMReference");
			var typePartInfo = this.listOfCustoPartType.get("Part");
			
			var resultMappingToSend = MappingViewUtilities.BuildMappingToSend(attrMappingPartProduct);
			
			if( resultMappingToSend.isInvalidMapping)
			{
				Mask.unmask(this.contentDiv);
				this.userMessaging.add({ className: "error", message: MappingManagementNLS.InvalidMapping });
			}
			else
			{
				datatoSend = {
						AttributeMapping : resultMappingToSend.mappingToSend//this.collection._models[0]._attributes.TypeRelMapping
				};


				var url = URLHandler.getURL() + "/resources/MappingWS/mapping/postmapping?tenant=" + URLHandler.getTenant(),datatoSend;

				WAFData.authenticatedRequest(url, {
					timeout: 250000,
					method: 'POST',
					data: JSON.stringify(datatoSend),
					type: 'json',
					//proxy: 'passport',

					headers: {
						'Content-Type' : 'application/json',
						'Accept' : 'application/json'
					},

					onFailure : function (json) {
						that.onApplyFailure.call(that,json); 
					},

					onComplete: function(json) {
						that.onApplySuccess.call(that,json);
					}

				});
			}

			//this.UpdateCommonParamsOnServer();
		},

		onApplyFailure : function (json) {
			UWA.log(json);
			// Mask.unmask(this.contentDiv);//Rb0afx
			// this.userMessaging.add({ className: "error", message: ParamDataModelingNLS.deployFailureMsg });
			 Mask.unmask(this.contentDiv);
			this.userMessaging.add({ className: "error", message: MappingManagementNLS.applyErrorMessage });
			//ParamLayoutUtilities.updateIcon(false, theImageCell);
		},

		onApplySuccess : function (json) { //Rb0afx                      
		
			var cpt=0,cptAttr=0,item,title,line,cell,nbofLines,mappingElt,imgSpan, itemToRemove = new Array(), that=this, currDate, currTime, diffDate;
			 Mask.unmask(this.contentDiv);
			currDate = new Date();
			currTime = currDate.getTime();
			diffDate = currTime - this.lastAlertDate;
			this.lastAlertDate = currTime;
			
			this.lastAlertDate = currTime;
			if (diffDate >= 2000) {
                this.userMessaging.add({ className: "success", message: MappingManagementNLS.applySuccessMessage });
            }


			/*for(cpt=0;cpt<this.custoAccordion.items.length;cpt++)
			{
		
				item = this.custoAccordion.getItem(cpt);
				title = item.title.children[1];
				line = title.getElementsByTagName("tr");
				cell = line[0].cells[5];
				mappingElt=MappingViewUtilities.retrieveMappingEntry(line[0].cells[1].value,line[0].cells[3].value,that.listofTypeRelMapping);
				if(cell.value==="NewNotDeployed" ||cell.value === "StoredButNotDeployed")
				{
					cell.empty();
					cell.value="Deployed";
					imgSpan = ParametersLayoutViewUtilities.buildImgSpan('check', '1.5', 'green');
					imgSpan.inject(cell);
					if(mappingElt!=undefined)
						mappingElt.status="deployed";
				}
				else if(cell.value==="DeletedNotDeployed")
				{
					itemToRemove.push(item);
					MappingViewUtilities.removeMappingTypeOrRel(mappingElt,that.collection._models[0]._attributes.TypeRelMapping);
				}

				that.onApplySuccessForAttributes(mappingElt,item);

			};
			
			itemToRemove.forEach(function(itemAccordion){
				that.custoAccordion.removeItem(itemAccordion);
				var index = that.custoAccordion.items.indexOf(itemAccordion);
				if (index>-1) {
					that.custoAccordion.items.splice(index, 1);
				}
			});*/

			for(cpt=0;cpt<this.baseAccordion.items.length;cpt++)
			{
				item = this.baseAccordion.getItem(cpt);
				title = item.title.children[1];
				line = title.getElementsByTagName("tr");
				cell = line[0].cells[5];
				mappingElt=MappingViewUtilities.retrieveMappingEntry(line[0].cells[1].value,line[0].cells[3].value,this.listofTypeRelMapping);
				MappingViewUtilities.onApplySuccessForAttributes(mappingElt,item.elements.content.children[0]);

			}
		},

		
		




		onResetSuccess : function () {
			
			var cpt=0,cptAttr=0,item,title,imgSpan,line,cell,mappingElt,mappingEltAttr,itemToRemove=new Array(),that=this;
			Mask.unmask(this.contentDiv);
			//Check type and attribute mapping for Custo accordion
			/*for(cpt=0;cpt<this.custoAccordion.items.length;cpt++)
			{
				item = this.custoAccordion.getItem(cpt);
				title = item.title.children[1];
				line = title.getElementsByTagName("tr");
				cell = line[0].cells[5];
				mappingElt=MappingViewUtilities.retrieveMappingEntry(line[0].cells[1].value,line[0].cells[3].value,this.listofTypeRelMapping);
				
				if(cell.value==="NewNotDeployed" ||cell.value === "StoredButNotDeployed")
				{
					MappingViewUtilities.removeMappingTypeOrRel(mappingElt,this.collection._models[0]._attributes.TypeRelMapping);
					itemToRemove.push(item);
				}
				else if(cell.value==="DeletedNotDeployed")
					MappingViewUtilities.unsetRemoveTypeRelLine.call(this,line[0],item,mappingElt);
				
				
				this.confirmationModalShowForAttributes.call(that,mappingElt,item);
			}
			
			itemToRemove.forEach(function(itemAccordion){
				that.custoAccordion.removeItem(itemAccordion);
				var index = that.custoAccordion.items.indexOf(itemAccordion);
				if (index>-1) {
					that.custoAccordion.items.splice(index, 1);
				}
			});*/
			
			//Check only attribute mapping for base Accordion
			for(cpt=0;cpt<this.baseAccordion.items.length;cpt++)
			{
				item = this.baseAccordion.getItem(cpt);
				title = item.title.children[1];
				line = title.getElementsByTagName("tr");
				cell = line[0].cells[5];
				mappingElt=MappingViewUtilities.retrieveMappingEntry(line[0].cells[1].value,line[0].cells[3].value,this.listofTypeRelMapping);
				MappingViewUtilities.resetForForAttributes.call(that,mappingElt,item.elements.content.children[0]);
				
			}
		},
		
		
	

	
		ShowAddMappingAttributePanel: function (typeMapping,parentSide,kindOfMapping,attrtbody)
		{
			
			var result = MappingViewUtilities.PopulateAddMappingAttributePanel(typeMapping,parentSide,kindOfMapping,attrtbody,this.listOfCustoVPMType,this.listOfCustoPartType,this.listofTypeRelMapping,this.wdthArrayAttr);
			result[0].inject(this.contentDiv);
			result[0].show();
		},
		
	


		/*ShowAddMappingPanel: function () {

			var i, addMappingSelection, addMappingChoice,addMappingTitle, labelVPM, labelENG, result,addMappingModal,selectVPM,selectMatrix,emptyListMessage,
			toggleVPM,divVPMMessage,VPMPopover,toggleENG,divENGMessage,ENGPopover,toggleBoth,divBothMessage,BothPopover,OkButton,CancelButton,typeMapping,
			typeRelMappingMap,typeRelMappingMapVPM,typeRelMappingMapMX, directionAvailableMap = new Map(),listOfVPMObject=[],listOfENGObject=[],
			sizeVPMObj,sizeMxObj, that=this ;

			addMappingSelection =  this.selectMapping.getSelection();
			addMappingChoice = addMappingSelection[0].value;

			if(addMappingChoice === "1")
			{
				addMappingTitle = "Add Mapping Custo Type";
				labelVPM = "select Custo VPM Type";
				labelENG = "select Custo Part Type";
				this.listOfCustoVPMType.forEach (function (value,key,map) { if(key !== "VPMReference") listOfVPMObject.push(key)});
				this.listOfCustoPartType.forEach (function (value,key,map) {if(key !== "Part") listOfENGObject.push(key)});
				typeMapping ="TYPE";
			}
			else if(addMappingChoice === "2")
			{
				addMappingTitle= "Add Mapping Custo Relation";
				labelVPM = "select Custo VPM Relation";
				labelENG = "select Custo ENG Relation";	
				this.listOfCustoVPMRel.forEach (function (value,key,map) {if(key !== "VPMInstance") listOfVPMObject.push(key)});
				this.listOfCustoEBOMRel.forEach (function (value,key,map) {if(key !== "EBOM") listOfENGObject.push(key)});
				typeMapping ="RELATION";
			}

			if(addMappingChoice != "")
			{
				sizeVPMObj = listOfVPMObject.length;
				sizeMxObj = listOfENGObject.length;
				if(sizeVPMObj===0 || sizeMxObj===0)
				{
					emptyListMessage="";
					if(sizeVPMObj===0)				
						emptyListMessage += "There is no derivative VPM "+ typeMapping.toLowerCase()+ " to map";
					else
						emptyListMessage += "There is no derivative Matrix "+ typeMapping.toLowerCase()+ " to map";
					new Alert({
						visible: true,
						messages: [
						           { message: emptyListMessage, className: "primary" },
						           ]
					}).inject(this.contentDiv);
				}

				else 
				{
					result = MappingViewUtilities.BuildAddMappingPanel( addMappingTitle, "select VPM "+typeMapping.toLowerCase(), "select Matrix "+typeMapping.toLowerCase(), labelVPM, labelENG);
					addMappingModal = result[0];
					selectVPM = result[1].selectVPM;
					selectMatrix = result[1].selectMatrix;
					toggleVPM = result[2].toggle;
					divVPMMessage = result[2].div;
					VPMPopover=  result[2].popover;
					toggleENG= result[3].toggle;
					divENGMessage = result[3].div;
					ENGPopover= result[3].popover;
					toggleBoth= result[4].toggle;
					divBothMessage = result[4].div;
					BothPopover = result[4].popover;
					OkButton = result[5].OKButton;
					CancelButton = result[5].CancelButton;

					for (i=0; i<listOfVPMObject.length;i++)
						selectVPM.addOption(listOfVPMObject[i]);

					for (i=0; i<listOfENGObject.length;i++)
						selectMatrix.addOption(listOfENGObject[i]);	

					typeRelMappingMap = MappingViewUtilities.buildTypeRelMappedWith(that.listofTypeRelMapping,typeMapping)
					typeRelMappingMapVPM = typeRelMappingMap.VPM;
					typeRelMappingMapMX = typeRelMappingMap.MX;


					selectVPM.addEvent("onChange", function (e) {
						if( (selectVPM.getSelection(false)).length!=0) 
						{
							selectMatrix.enable();
							MappingViewUtilities.enableMatrixTypeRelAccordingRules(selectVPM,selectMatrix,typeRelMappingMapVPM,typeRelMappingMapMX,directionAvailableMap);
						}
						else
						{
							selectMatrix.disable();
							selectMatrix.select(0,true);
						}
						MappingViewUtilities.modifyToggleAccordingAvailableDirection( selectVPM,selectMatrix,OkButton,toggleBoth,toggleVPM,toggleENG,directionAvailableMap,divBothMessage,BothPopover,divVPMMessage,VPMPopover,divENGMessage,ENGPopover);
					});


					selectMatrix.addEvent("onChange", function (e) {
						MappingViewUtilities.modifyToggleAccordingAvailableDirection( selectVPM,selectMatrix,OkButton,toggleBoth,toggleVPM,toggleENG,directionAvailableMap,divBothMessage,BothPopover,divVPMMessage,VPMPopover,divENGMessage,ENGPopover);
					});



					OkButton.addEvent("onClick", function (e) {

						var SelectedVPMTypeOpt, VPMType, SelectedPartTypeOpt, PartType,  lineMapping, type, VPMObject, MatrixObject, txtSide, side, attributesTable, deleteIcon,deleteAction, deleteSpan, removeLineMappingButton, removePropMappingButton, accordionName, newMappingElt,mappingTable;

						UWA.log(e);//that.onCancelCalled();
						SelectedVPMTypeOpt = selectVPM.getSelection();
						VPMType = SelectedVPMTypeOpt[0].value;

						SelectedPartTypeOpt = selectMatrix.getSelection();
						PartType = SelectedPartTypeOpt[0].value;

						txtSide;
						if(toggleBoth.isChecked())
							txtSide="BOTH";
						else if (toggleVPM.isChecked())
							txtSide="VPM_To_MX";
						else if (toggleENG.isChecked())
							txtSide="MX_To_VPM";
						else txtSide="BOTH";

						//Add new Mapping Line in the map
						newMappingElt = {AttributeMapping: Array(0), KindOfMapping: typeMapping, VPMObject: VPMType, MatrixObject: PartType, SynchDirection: txtSide, status:"NewNotDeployed",isBaseMapping:"false"};
						that.collection._models[0]._attributes.TypeRelMapping.push(newMappingElt);


						mappingTable = MappingViewUtilities.buildMappingLine.call(that,newMappingElt);


						var attributeMappingDiv = UWA.createElement('div', {
							'class': 'attributeMapping'
						});//table-bordered

						//attribute table
						var attributesTable = MappingViewUtilities.buildAttributeTable.call(that,VPMType,MatrixType,typeMapping,[],that.wdthArrayAttr);
						attributesTable.inject(attributeMappingDiv);

						var addAttributeMappingIcon = UWA.createElement('span', {
							'class': 'fonticon fonticon-1,5x fonticon-plus',
							'title': 'add attribute mapping',
							//'onclick': 'ShowAddMappingAttributePanel()'
						}).inject(attributeMappingDiv);//table-bordered

						addAttributeMappingIcon.addEvent('click', that.ShowAddMappingAttributePanel.bind(that,VPMType,PartType,txtSide,typeMapping,attributesTable.getElement(".attrstbodyMapping")));

						accordionName = VPMType+"_"+PartType;

						that.custoAccordion.addItem({
							title:  mappingTable,
							content: attributeMappingDiv,
							selected : false,
							name:accordionName,
						});

						addMappingModal.hide();
					});

					CancelButton.addEvent("onClick", function (e) {
						UWA.log(e);//that.onCancelCalled();
						addMappingModal.hide();
					});

					addMappingModal.inject(this.contentDiv);
					addMappingModal.show();



				}
			}
		},*/
		
		
		



		//show: function () {},
		destroy : function() {
			this.stopListening();
			this._parent.apply(this, arguments);
		}
	});

	return extendedView;
});

/*! Copyright 2017, Dassault Systemes. All rights reserved. */

/*@quickReview NZV 17/05/09 Add getDimensions function & fixed IR-519160-3DEXPERIENCER2018x*/
/*@quickReview NZV 18/04/27 Function FUN076055 19x Beta2 : Added getPredicatesObject, getPredicatesReturn */
/*global define*/
define(
    'DS/ParameterizationSkeleton/Utils/ParameterizationGenericServices',
    [
        'UWA/Core',
        'UWA/Promise',
        'DS/WAFData/WAFData',
        'DS/FedDictionaryAccess/FedDictionaryAccessAPI',
        'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler'
    ],
    function(UWA, Promise, WAFData, Dico, URLHandler) {

        'use strict';

        var genericWSUtils = {

            compareDimensionObject : function(dimObj1, dimObj2) {
                if (dimObj1.NLS !== undefined && dimObj2.NLS !== undefined) {
                    return dimObj1.NLS.localeCompare(dimObj2.NLS);
                } else {
                    var nameDim1 = dimObj1.Name.toUpperCase(),
                        nameDim2 = dimObj2.Name.toUpperCase(); // ignore upper and lowercase
                    if (nameDim1 < nameDim2) {
                        return -1;
                    }
                    if (nameDim1 > nameDim2) {
                        return 1;
                    }

                    // names must be equal
                    return 0;
                }

            },

            dimensionOnSuccess : [],

            dimensionOnFail : [],

            getDimensions : function (onSuccess, OnDimServiceFail) {

                var url = URLHandler.getURL() + '/resources/dictionary/dimensions';

                if (genericWSUtils.dimensionOnSuccess.length > 0) {
                    genericWSUtils.dimensionOnSuccess.push(onSuccess);
                    genericWSUtils.dimensionOnFail.push(OnDimServiceFail);
                } else {

                    genericWSUtils.dimensionOnSuccess.push(onSuccess);
                    genericWSUtils.dimensionOnFail.push(OnDimServiceFail);
                    WAFData.authenticatedRequest(url, {
                        headers: {
                            'Accept' : 'application/json',
                            //'Content-Type' : 'application/json',
                            'Accept-Language' : widget.lang
                        },
                        method: 'get',
                        type: 'json',

                        onComplete: function (json) {
                            if (json !== 'undefined') {
                                if (json.results !== 'undefined') {
                                    json.results.sort(genericWSUtils.compareDimensionObject);
                                    genericWSUtils.dimensionOnSuccess.forEach(function (item) {
                                        item(json.results);
                                    });
                                }
                            }
                            while (genericWSUtils.dimensionOnSuccess.length > 0) {
                                genericWSUtils.dimensionOnSuccess.shift();
                            }
                            while (genericWSUtils.dimensionOnFail.length > 0) {
                                genericWSUtils.dimensionOnFail.shift();
                            }
                            genericWSUtils.dimensionOnFail = [];
                            genericWSUtils.dimensionOnSuccess = [];
                        },
                        onFailure: function(json) {
                            UWA.log("onFailure : getDimensions funciton failed.Not able to call " + url);
                            UWA.log(json);
                            genericWSUtils.dimensionOnFail.forEach(function (item) {
                                item.call();
                            });
                            while (genericWSUtils.dimensionOnFail.length > 0) {
                                genericWSUtils.dimensionOnFail.shift();
                            }
                            while (genericWSUtils.dimensionOnSuccess.length > 0) {
                                genericWSUtils.dimensionOnSuccess.shift();
                            }
                            genericWSUtils.dimensionOnFail = [];
                            genericWSUtils.dimensionOnSuccess = [];
                        }
                    });
                }
            },

            getSessionInfo : function () {
                var sessionObj = new Promise(function (resolve, reject) {
                    var url = URLHandler.getURL() + '/resources/enocsmrest/session?tenant=' + URLHandler.getTenant();
                    WAFData.authenticatedRequest(url, {
                        headers: {
                            'Accept' : 'application/json',
                            //'Content-Type' : 'application/json',
                            'Accept-Language' : widget.lang
                        },
                        method: 'get',
                        type: 'json',

                        onComplete: function (json) {
                            if (json !== 'undefined') {
                                resolve(json);
                            }
                        },
                        onFailure: function(json) {
                            UWA.log("Paramaterization::Services falied! :" + url);
                            UWA.log(json);
                            reject(json);

                        }
                    });
                });
                return sessionObj;
            }, //end of getSessionInfo
           //Remomve before delivry
            // loginStep : function () {
            //     var loginObj1 = new Promise(function (resolve, reject) {
            //         var url = "https://vdevpril464dsy.ux.dsone.3ds.com:453/iam/login?action=get_auth_params";
            //         WAFData.authenticatedRequest(url, {
            //             headers: {
            //                // 'Accept' : 'text/html',
            //                // 'Content-Type' : 'text/html',
            //                 'Accept-Language' : widget.lang
            //             },
            //             method: 'get',
            //            // type: 'html',

            //             onComplete: function (result) {
            //                 resolve(result);
            //             },
            //             onFailure: function(error, responseAsString) {
            //                 UWA.log("Paramaterization::loginStep1 falied! :" + url);
            //                 UWA.log(error);
            //                 reject(responseAsString);

            //             }
            //         });
            //     });
            //     return loginObj1;
            // },//Remomve before delivry
            // loginToRDFServer : function(userTicket) {
            //     var respJson = JSON.parse(userTicket);
            //     var LT = respJson.lt;
            //     var loginObj = new Promise(function (resolve, reject) {
            //         //var url ='https://vdevpril464dsy.ux.dsone.3ds.com:453/iam/login?service=https%3A%2F%2Fvdevpril510dsy.ux.dsone.3ds.com%2F3DRDFPersist%2Fv0%2Finvoke%2Fdsbase%3AgetFedProperties';
            //         var url = 'https://vdevpril464dsy.ux.dsone.3ds.com:453/iam/login?service=https%3A%2F%2Fvdevpril510dsy.ux.dsone.3ds.com%2F3DRDFPersist%2Fservice%2FrdfQL%3Fquery%3Dshow%2520context';
            //          WAFData.authenticatedRequest(url, {
            //             headers: {
            //                 //'Accept' : 'text/html',
            //                 'Content-Type' : 'application/x-www-form-urlencoded;charset=UTF-8',
            //                 'Accept-Language' : widget.lang
            //             },
            //             //application/x-www-form-urlencoded;charset=UTF-8
            //             method: 'post',
            //            // data : 'lt=LT-10617-RMtdUSexQQ0j7CSyR4fYqgVdXc5PIA&fp=f15adf37375019a0d3b8f5f42d57bfe228fe2da050ef97a7e3f5be92dbc4aaacea07d4b1cd90ef29d22ab22a79a83f2b7413b8834f773b33ab270b4285cc0896&username=VPLMAdminUser&password=Passport1',
            //            data : "lt="+ LT+ "&username=VPLMAdminUser&password=Passport1",
            //             onComplete: function (json) {
            //                 if (json !== 'undefined') {
            //                    resolve(json);
            //                 } 
            //             },
            //             onFailure: function(error, responseAsString) {
            //                 UWA.log("Paramaterization::loginToRDFServer falied! :" + url);
            //                 UWA.log(error);
            //                 reject(error);

            //             } 
            //          });
            //     });
            //     return loginObj;
            // },
            isThisNotARootPredicates : function  (item) {
                // var rootPredicates = ["ds6w:what", "ds6w:why", "ds6w:when", "ds6w:where", "ds6w:how", "ds6w:who"], i;
                // for (i = 0; i < rootPredicates.length; i++) {
                //     if (rootPredicates[i] === item.curi.toLowerCase()) { return false; }
                // }
                // return true;
                return ((item.subPropertyOf === "") ? false : true);
            },

            filter6WRootPredicates : function (listofsixWTags) {
                var predicatesList, propt = "ds6w";
                //for (propt in listofsixWTags) {
                if (listofsixWTags[propt].properties.length > 0) {
                    predicatesList = listofsixWTags[propt].properties;
                    if (predicatesList !== undefined && predicatesList.length > 0) {
                        listofsixWTags[propt].properties = predicatesList.filter(genericWSUtils.isThisNotARootPredicates);
                    }
                }
                //}
                return listofsixWTags;
            },

            getPredicatesObject : function () {
                var rdfPredicateServiceObj = new Promise(function (resolve, reject) {
                        var ontologyServiceObj =  {
                            onComplete: function(result) {
                                UWA.log("Got a predicates result!" + result);
                                resolve(result);
                            },
                            onFailure: function(errorMessage) {
                                UWA.log("predicates service request Fail!" + errorMessage);
                                reject(errorMessage);
                            },
                            tenantId: URLHandler.getTenant(),
                            lang: widget.lang,
                            apiVersion: "R2019x",
							onlyMappable: true //IR-619053-3DEXPERIENCER2019x 							
                        };
                        Dico.getFedProperties(ontologyServiceObj);             
                    });
                return rdfPredicateServiceObj;
            }, //end of getPredicatesObject

            onSuccessPredicateActionList : [],

            OnFailedPredicateActionList : [],

            getPredicatesReturn : function (onSuccess, onFailed) {
                if (genericWSUtils.onSuccessPredicateActionList.length > 0) {
                    genericWSUtils.onSuccessPredicateActionList.push(onSuccess);
                    genericWSUtils.OnFailedPredicateActionList.push(onFailed);
                } else {
                    genericWSUtils.onSuccessPredicateActionList.push(onSuccess);
                    genericWSUtils.OnFailedPredicateActionList.push(onFailed);
                    genericWSUtils.getPredicatesObject()
                        .then(function (result) {
                            result = genericWSUtils.filter6WRootPredicates(result);
                            genericWSUtils.onSuccessPredicateActionList.forEach(function (item) {
                                item(result);
                            });
                            genericWSUtils.OnFailedPredicateActionList = [];
                            genericWSUtils.onSuccessPredicateActionList = [];
                        })['catch'](function (errorMessage) {
                            genericWSUtils.OnFailedPredicateActionList.forEach(function (item) {
                                item(errorMessage);
                            });
                            genericWSUtils.OnFailedPredicateActionList = [];
                            genericWSUtils.onSuccessPredicateActionList = [];
                        });
                }

            }//end of getPredicatesReturn
        };
        return genericWSUtils;
    }
);


define('DS/ParameterizationSkeleton/Views/ParameterizationXCAD/XCADViewUtilities',
[
 'UWA/Core',
 'UWA/Controls/Accordion',
 'DS/UIKIT/Accordion',
 'DS/UIKIT/Input/Button',
 'DS/UIKIT/Input/Select',
 'DS/UIKIT/Input/Toggle',
 'DS/UIKIT/Input/Text',
 'DS/UIKIT/Modal',
 'DS/UIKIT/Alert',
 'DS/UIKIT/Popover',
 'DS/UIKIT/Tooltip',
 'DS/UIKIT/Spinner',
 'DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
 'i18n!DS/ParameterizationSkeleton/assets/nls/XCADMappingNLS',
 'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS',
 ],
 function (UWA,
           UWAccordion, Accordion,
           Button, Select, Toggle, Text,
           Modal,
           Alert, Popover,Tooltip, Spinner, ParametersLayoutViewUtilities,
           XCADMappingNLS,
           ParamSkeletonNLS) {

'use strict';

var UIview = {

  init : function () {
    this.cellsAttrIndex = [];
    this.cellsIndex = [];


  },

  initVariable : function () {
    this.cellsIndex = {
        "Connector" : 0,
        "VPMObject" : 1,
        "CADType" : 2,
        "action" : 3,
        "deployFlag" : 4,
        "Indexed" : 5,
    };
    this.cellsAttrIndex = {
        "VPMAttr" : 0,
        "side" : 1,
        "CADAttr" : 2,
        "action" : 3,
        "deployFlag" : 4,
    };

    this.direction =  {
        "BOTH" : "<=>",
        "VPM_To_CAD" : "=>",
        "CAD_To_VPM" : "<=",
    };

  },

  createApplyResetToolbar : function (insertdivID, activateApplyBtn, applyParams, confirmationModalShow) {
    var applyDiv, tableButtons, lineButtons, buttonApplyCell, applyBttn,
    buttonResetCell, resetBbttn;
    //that = this;
    //resetwidth = '100%';
    
    applyDiv =  UWA.createElement('div', {
      'id': 'ApplyResetDiv'
    }).inject(insertdivID);
    //                            
    tableButtons = UWA.createElement('table', {
      'class' : '',
      'id' : '',
      'width' : '100%'
    }).inject(applyDiv);
    
    lineButtons = UWA.createElement('tr').inject(tableButtons);//tbody
    
    if (activateApplyBtn === true) {
      buttonApplyCell = UWA.createElement('td', {
        'width' : '50%',
        'Align' : 'left'
      }).inject(lineButtons);
      
                    applyBttn =  new Button({
                      className: 'primary',
                      id : 'buttonExport',
                      icon : 'export',//'download'//value: 'Button',          
                      attributes: {
                        disabled: false,
                        title: XCADMappingNLS.ApplyMappingtooltip,
                        text : ParamSkeletonNLS.Apply
                      },
                      events: {
                        onClick: function () {
                          applyParams();
                        }
                      }
                    }).inject(buttonApplyCell);
      applyBttn.getContent().setStyle("width", 130);
    }
    
    buttonResetCell = UWA.createElement('td', {
      'width' : '50%',
      'Align' : 'right'//center
    }).inject(lineButtons);
    
    resetBbttn = new Button({
      className: 'warning',
      icon: 'loop',
      attributes: {
        disabled: false,
        title: ParamSkeletonNLS.ResetOnServertooltip,
        text : ParamSkeletonNLS.Reset
      },
      events: {
        onClick: function () {
          //that.resetParamsinSession();//testPreviewBlock();                               
          confirmationModalShow();
        }
      }
    }).inject(buttonResetCell);
    
    resetBbttn.getContent().setStyle("width", 130);
    return applyDiv;
  },
  

  buildAttributeLine : function (attributeList, attributeMapping,widthTable) {
    var iCell, removeAttributeButton, deleteSpan, removePop,position;
    var that = this;

    var actionButton = [];
    var lineAttr = UWA.createElement('tr', {'class': 'AttrLineXCADMapping'});

    // VPM info
    var itfVPM= attributeMapping.Extension;
    var attrVPM=attributeMapping.Name;
    var attrVPMName = attributeMapping.Name;

    if (!attributeMapping.nlsName) {
      if (attrVPM == "V_Name") attrVPMName = "Title"
      else if (attrVPM == "V_description") attrVPMName = "Description";
    } else {
      attrVPMName = attributeMapping.nlsName;
    }


    var side=attributeMapping.Sync;

    // CAD Info
    var attrCAD=attributeMapping.cadName;
    var attrCADName=attributeMapping.cadName;
    var status=attributeMapping.status;
    var isDefault = attributeMapping["default"];

    UIview.initVariable();

    iCell = UWA.createElement('td', {
      'Align'  : 'left',
      'width'  : widthTable[0],
      'value'  : attrVPM,
      'class': 'attributeXCADMappingField font-3dslight'// font-3dsbold
    }).inject(lineAttr);

    UWA.createElement('p', {
      text   : attrVPMName,
      value  : attrVPM,
    }).inject(iCell);

    var txtSide = XCADMappingNLS.both;
    var valueSide = "<=>";
    if(side==0) {
      valueSide = "<=>";
      txtSide = XCADMappingNLS.both;
    } else if (side<0) {
      valueSide = "=>";
      txtSide =XCADMappingNLS.unilateralDirection.format("Physical Product","CAD");
    } else if (side>0) {
      valueSide = "<=";
      txtSide =XCADMappingNLS.unilateralDirection.format("CAD","Physical Product");
    }
 
    iCell = UWA.createElement('td', {
      'Align' : 'left',
      'width' :widthTable[1],
      'title' : txtSide,
      'value' : valueSide,
      'class': 'attributeXCADMappingField font-3dslight'// font-3dsbold
    }).inject(lineAttr);

   var imgSpanRight = UWA.createElement('span', {
      'class' : 'fonticon fonticon-expand-right'
    })
    
    var imgSpanLeft = UWA.createElement('span', {
      'class' : 'fonticon fonticon-expand-left'
    })
    
    if(side==0) {
      imgSpanLeft.inject(iCell);
      imgSpanRight.inject(iCell);		
    } else if (side<0) {
      imgSpanRight.inject(iCell);
    } else if (side>0) {
      imgSpanLeft.inject(iCell);
    }

    iCell.setStyle("vertical-align", "text-bottom");
 
 
    iCell = UWA.createElement('td', {
      'Align'  : 'left',
      'width'  : widthTable[2],
      'value'  : attrCAD,
      'class': 'attributeXCADMappingField font-3dslight'// font-3dsbold
    }).inject(lineAttr);

    UWA.createElement('p', {
      text   : attrCADName,
      value  : attrCAD,
    }).inject(iCell);


    iCell = UWA.createElement('td', {
      'Align' : 'left',
      'width' : widthTable[3],
      'class': 'attributeXCADMappingField font-3dslight'// font-3dsbold
    }).inject(lineAttr);

    if(!isDefault)
    {
      actionButton = UIview.createDeleteModifyActionsIcon(iCell);


      actionButton.addEvent("onClick", function (e) {
        UIview.removeAttrLineCallBack(lineAttr,attributeMapping, attributeList);

      });
    }

    var isDeployed ;
    if(status==="New") isDeployed ="NewNotDeployed";
    else
    isDeployed = (status==="Deployed")? 'true':'false';


    var invalidStoredMapping = false;
    var messageInvalidStoredMapping = "";

    if (isDeployed === "false")
    {
      if(attributeMapping.VPMAttributeNotDeployed)
      {
        invalidStoredMapping = true;
        messageInvalidStoredMapping = XCADMappingNLS.NonDeployedAttribute;
      }

    }

    var imgSpan,
    imgTitle = XCADMappingNLS.deployedParamtxt,
    imgClass = 'fonticon fonticon-' + '1.5' + 'x fonticon-check',
    iconColor = 'green',
    iconSize = '1.5';

    if (isDeployed === "false") {
      imgClass = 'fonticon fonticon-' + iconSize + 'x fonticon-cog';
      if(!invalidStoredMapping)
      {
        imgTitle =  XCADMappingNLS.notdeployedParamtxt;
        iconColor = 'orange';
      }
      else
      {
        imgTitle = messageInvalidStoredMapping;
        iconColor = 'red';
        attributeMapping.status = "InvalidStored";
      }
    } else if (isDeployed === "NewNotDeployed") {
      imgClass = 'fonticon fonticon-' + iconSize + 'x fonticon-cog';
      imgTitle =  XCADMappingNLS.newNotdeployedParam;
      iconColor = 'black';
    }

    iCell = UWA.createElement('td', {
      'width' : widthTable[4],
      'align' : 'center',
      'title' : imgTitle
    });

    imgSpan = UWA.createElement('span', {
      'class' : imgClass
    }).inject(iCell);

    imgSpan.setStyle("color", iconColor);
    iCell.setStyle("vertical-align", "text-bottom");

    iCell.value = status;
    iCell.inject(lineAttr);

    if(status==="RemovedbyImport")
      UIview.setToRemoveAttrLine(lineAttr);

    return lineAttr;
  },


  buildAttributeTableHeading : function (widthTable) {
    var lineTitle,iCell;

    lineTitle = UWA.createElement('tr', {
      'class' : 'success'
    });

    iCell = UWA.createElement('td', {
      'Align' : 'left',
      'width' : widthTable[0],
    }).inject(lineTitle);

    UWA.createElement('h5', {
      text   : XCADMappingNLS.ProductAttr
        //'class': 'font-3dslight'// font-3dsbold
    }).inject(iCell);


    iCell = UWA.createElement('td', {
      'Align' : 'left',
      'width' : widthTable[1],
    }).inject(lineTitle);

    UWA.createElement('h5', {
      text   : XCADMappingNLS.side
    }).inject(iCell);

    iCell = UWA.createElement('td', {
      'Align' : 'left',
      'width' : widthTable[2],
    }).inject(lineTitle);

    UWA.createElement('h5', {
      text   : XCADMappingNLS.CADAttr
    }).inject(iCell);

    iCell = UWA.createElement('td', {
      'Align' : 'left',
      'width' : widthTable[3],
    }).inject(lineTitle);

    UWA.createElement('h5', {
      text   : XCADMappingNLS.actions
        //'class': 'font-3dslight'// font-3dsbold
    }).inject(iCell);

    iCell = UWA.createElement('td', {
      'Align' : 'left',
      'width' : widthTable[4],
    }).inject(lineTitle);

    UWA.createElement('h5', {
      text   : XCADMappingNLS.deployStatus
        //'class': 'font-3dslight'// font-3dsbold
    }).inject(iCell);

    return lineTitle;
  },


  buildMappingLine : function (eltmapping)
  {
    var that=this;

    var CADType,VPMType, CADTypeName, VPMTypeName;
    var side,status ,mappingTable,lineMapping,txtSide,iCell,deleteIcon,deleteAction,deleteSpan;
    var removeLineMappingButton,removePropMappingButton,attributeMappingDiv;
    var attributesTable,mappingTable,actionCol,modifySpan,modifyAttributeButton,modifyPop,modifySpan;
    UIview.initVariable();

    CADType = eltmapping.cadType;
    VPMType = eltmapping.Type;
    CADTypeName = XCADMappingNLS[eltmapping.cadType] ?  XCADMappingNLS[eltmapping.cadType]: eltmapping.cadType;
    VPMTypeName = eltmapping.VPMObjectName;

    // Filtre sur les VPMReference .. 
    if (VPMType != 'VPMReference') return undefined;

    // Filtre solid works .. pas de virtual
    if (CADType == 'virtualComponentInstance')  return undefined;
    if (CADType == 'virtualAssemblyInstance')  return undefined;

    side  = "BOTH";
    txtSide="<=>";
    
    status = eltmapping.status;
    mappingTable = UWA.createElement('table', {
      'class': 'tableXCADMapping'
    });//table-bordered

    lineMapping = UWA.createElement('tr', {
      'class' : 'lineXCADMapping'
    }).inject(mappingTable);

    UWA.createElement('td', {'class': 'colXCADMappingType', 'text': "", 'value':""}).inject(lineMapping);

    UWA.createElement('td', {'class': 'colXCADMappingVPMObject', 'text':VPMTypeName, 'value':VPMType}).inject(lineMapping);

    side = UWA.createElement('td', {'class': 'colXCADMappingSide', 'text':txtSide, 'value':side}).inject(lineMapping);

    UWA.createElement('td', {'class': 'colXCADMappingCADType', 'text':CADTypeName, 'value':CADType}).inject(lineMapping);


    // Edition du mapping de type .. plus tard !
    // livr� desactiv�
    if (false)
    {
      actionCol = UWA.createElement('td', {'class': 'colXCADMappingDeleteAction'}).inject(lineMapping);

      deleteAction = ParametersLayoutViewUtilities.createDeleteActionElements("delete line mapping");
      deleteSpan = deleteAction[0];
      removeLineMappingButton = deleteAction[1];
      removePropMappingButton = deleteAction[2];
      deleteSpan.inject(actionCol);


      modifySpan = UWA.createElement('span');

      modifyAttributeButton = new Button({
        className: 'close',
        icon: 'fonticon fonticon-pencil fonticon-1.5x',//value: 'Button', //fonticon-cancel  fonticon-minus-circled
        attributes: {
          disabled: false,
          'aria-hidden' : 'true'
        }
      }).inject(modifySpan);

      modifyPop = new Popover({
        //class: 'parampopover',
        target: modifySpan,//iCell,
        trigger : "hover",
        animate: "true",
        position: "top",
        body: "modify direction",
        title: ''//iParamObj.nlsKey
      });

      modifySpan.inject(actionCol);

      removeLineMappingButton.addEvent("onClick", function (e) {
        UIview.removeTypeMappingLineCallBack.call(this,lineMapping,eltmapping);
      }.bind(that));

    }

    var isDeployed = 'true'; // (status==="deployed")? 'true':'false';

    iCell = UWA.createElement('td', {'class': 'colXCADMappingType', 'text': "", 'value':"deployed"}).inject(lineMapping);

    return mappingTable;

  },



  buildAttributeTable : function (listofAttributesMapping,widthTable) {
    var attributesTable, attrtbody, iCell,lineTitle, lineAttribute,j;


    attributesTable = UWA.createElement('table', {
      'class': 'attrTableXCADMapping table table-condensed'
    });//table-bordered

    attrtbody =  UWA.createElement('tbody', {
      'class': 'attrstbodyXCADMapping'
    }).inject(attributesTable);


    lineTitle = UIview.buildAttributeTableHeading(widthTable);
    lineTitle.inject(attrtbody);

    for (j = 0; j < listofAttributesMapping.length; j++) {
      lineAttribute = UIview.buildAttributeLine.call(this, listofAttributesMapping, listofAttributesMapping[j],widthTable);
      lineAttribute.inject(attrtbody);
    }

    return attributesTable;
  },

  retrieveMappingEntry : function (vpmtype, cadtype,collectionMapping) {
    var EltMapping, foundElt=false, cpt=0;

    while (!foundElt && cpt <collectionMapping.length)
    {
      EltMapping = collectionMapping[cpt];
      if(EltMapping!=undefined)
      {
        if(vpmtype ===EltMapping.Type &&  cadtype === EltMapping.cadType)
          foundElt=true;
        else cpt++
      }

    }
    if (!foundElt) return undefined;
    else return EltMapping;
  },

  retrieveMappingAttrEntry : function (itfVPM, VPMAttr,cadAttr,attributeMappingList) {
    var EltAttrMapping, foundElt=false, cpt=0, VPMAttrName=VPMAttr, cadAttrName=cadAttr;

    while (!foundElt && cpt <attributeMappingList.length)
    {
      EltAttrMapping = attributeMappingList[cpt];
      if(EltAttrMapping!=undefined)
      {
        if( itfVPM === EltAttrMapping.Extension && VPMAttrName ===EltAttrMapping.Name &&  cadAttrName === EltAttrMapping.cadName)
          foundElt=true; 
        else if( itfVPM === undefined && VPMAttrName ===EltAttrMapping.Name &&  cadAttrName === EltAttrMapping.cadName)
          foundElt=true; 
        else cpt++
      }

    }
    if (!foundElt) return undefined;
    else return EltAttrMapping;
  },

  //Change mapping in Deployed  state to remove State
  setToRemoveAttrLine : function (attrLine) {
    var deployAttrcell,imgAttrSpan,i,arrayAction;

    deployAttrcell=attrLine.cells[UIview.cellsAttrIndex.deployFlag];
    
    UIview.setDeletedCellStyle(attrLine.cells[UIview.cellsAttrIndex.VPMAttr]);
    UIview.setDeletedCellStyle(attrLine.cells[UIview.cellsAttrIndex.CADAttr]);
    
    var iconsSide = attrLine.cells[UIview.cellsAttrIndex.side].getElements('span');
    iconsSide.forEach(function(icon){
      icon.setStyle("color", "grey");
    });

    arrayAction = attrLine.cells[UIview.cellsAttrIndex.action].getElements('span');
    arrayAction.forEach(function(action){
      action.hide();
    });

    if(deployAttrcell.value === "Stored" || deployAttrcell.value === "InvalidStored")
    {
      imgAttrSpan = ParametersLayoutViewUtilities.buildImgSpan('trash', '1.5', 'orange');
      deployAttrcell.title = XCADMappingNLS.DeletedStoredNotApplied;
    }
    else
    {
      imgAttrSpan = ParametersLayoutViewUtilities.buildImgSpan('trash', '1.5', 'red');
      deployAttrcell.title = XCADMappingNLS.DeletedNotApplied;
    }

    deployAttrcell.empty();
    deployAttrcell.value = "Removed";

    imgAttrSpan.inject(deployAttrcell);

    //}
  },


  removeAttrLineCallBack : function (attrLine,attributeMapping,listofAttributesMapping) {
    var /*lineAttrMapping = UWA.Event.findElement(e, '.AttrLineMapping'),*/deployAttrcell;
    if(attrLine!="undefined")
    {
      deployAttrcell=attrLine.cells[UIview.cellsAttrIndex.deployFlag];
      //If mapping in New state, delete the line
      if(deployAttrcell.value==="New")
        attrLine.remove();
      else
        //If mapping in deployed state, change the state and the UI to removed
        UIview.setToRemoveAttrLine(attrLine);
    }
    //Update mapping model
    UIview.removeMappingAttr(attributeMapping,listofAttributesMapping);
    //removePop.destroy();
  },


  createDeleteModifyActionsIcon: function(actionCell)
  {
    var deleteSpan, deleteButton, deletePop, modifySpan, modifyButton, modifyPop  ;

    deleteSpan = UWA.createElement('span');
    deleteButton = new Button({
      className: 'close',
      icon: 'fonticon fonticon-trash fonticon-1.5x',//value: 'Button', //fonticon-cancel  fonticon-minus-circled
      attributes: {
        disabled: false,
        'aria-hidden' : 'true'
      }
    }).inject(deleteSpan);
    deletePop = new Popover({
      //class: 'parampopover',
      target: deleteSpan,//iCell,
      trigger : "hover",
      animate: "true",
      position: "top",
      body: XCADMappingNLS.deleteAttrMapping,
      title: ''//iParamObj.nlsKey
    });
    deleteSpan.inject(actionCell);

    return deleteButton;
  },

  removeMappingAttr : function (eltAttrMapping, listOfAttributeMapping) {
    var index;
    if(eltAttrMapping.status==="New" )
    {
      //listOfAttributeMapping.remove(eltAttrMapping);
      index = listOfAttributeMapping.indexOf(eltAttrMapping);
      if(index!=-1)
        listOfAttributeMapping.splice(index,1);
    }
    else if(eltAttrMapping.status==="Stored" || eltAttrMapping.status==="InvalidStored")
      eltAttrMapping.status="RemovedStored";
    else
      eltAttrMapping.status="RemovedDeployed";
  },

  CheckRulesToAddAttrMapping: function(VPMTypeRelInfo,VPMAttrInfo,MxTypeRelInfo,MxAttrInfo, parentSide,VPMObjMappedAttr, MXObjMappedAttr,messageSuffix)
  {

    var VPMArrayVPMToMx=new Array(),VPMArrayMxToVPM=new Array(),VPMArrayBoth=new Array(),MXArrayVPMToMx=new Array(),MXArrayMxToVPM=new Array(),MXArrayBoth=new Array(),result,resultRule1,resultRule2,resultRule3,resultRule4,resultRule5,resultRule6,VPMAttrInfo, MxAttrInfo,VPMAttrRange="",MxAttrRange="";
    result={VPM_To_CAD:true,CAD_To_VPM:true,BOTH:true,message:{VPM_To_CAD:new Array(), CAD_To_VPM:new Array(),BOTH:new Array()}};

    if(VPMObjMappedAttr!=undefined)
    {
      VPMArrayVPMToMx=VPMObjMappedAttr.get("VPM_To_CAD");
      VPMArrayMxToVPM = VPMObjMappedAttr.get("CAD_To_VPM");
      VPMArrayBoth = VPMObjMappedAttr.get("BOTH");
    }
    if(MXObjMappedAttr!=undefined)
    {
      MXArrayVPMToMx=MXObjMappedAttr.get("VPM_To_CAD");
      MXArrayMxToVPM = MXObjMappedAttr.get("CAD_To_VPM");
      MXArrayBoth = MXObjMappedAttr.get("BOTH");
    }

    resultRule1 = UIview.CheckIsNotAlreadyMapped(MXArrayVPMToMx,MXArrayMxToVPM,MXArrayBoth);

    //VPMAttrInfo = UIview.retrieveAttributeInfo(VPMTypeRelInfo,VPMAttr);
    if(VPMAttrInfo!=undefined) VPMAttrRange = VPMAttrInfo.range;
    //MxAttrInfo = UIview.retrieveAttributeInfo(MxTypeRelInfo,MxAttr);
    if(MxAttrInfo!=undefined) MxAttrRange = MxAttrInfo.range;

    resultRule5 =  UIview.CheckIsSameAttrRange(VPMAttrRange,MxAttrRange);

    resultRule6 = UIview.CheckIsAuthorizedAsTarget(MxAttrInfo.itf,MxAttrInfo.id,VPMAttrInfo.itf,VPMAttrInfo.id);

    result.VPM_To_CAD = resultRule1.VPM_To_CAD/* && resultRule2.VPM_To_CAD && resultRule3.VPM_To_CAD && resultRule4.VPM_To_CAD */&& resultRule5.VPM_To_CAD && resultRule6.VPM_To_CAD;
    result.CAD_To_VPM = resultRule1.CAD_To_VPM /*&& resultRule2.CAD_To_VPM && resultRule3.CAD_To_VPM && resultRule4.CAD_To_VPM */&& resultRule5.CAD_To_VPM && resultRule6.CAD_To_VPM;
    result.BOTH = resultRule1.BOTH /*&& resultRule2.BOTH && resultRule3.BOTH && resultRule4.BOTH*/ && resultRule5.BOTH && resultRule6.BOTH;

    Array.prototype.push.apply(result.message.BOTH, resultRule1.message.BOTH);/*Array.prototype.push.apply(result.message.BOTH, resultRule2.message.BOTH);Array.prototype.push.apply(result.message.BOTH, resultRule3.message.BOTH);Array.prototype.push.apply(result.message.BOTH, resultRule4.message.BOTH);*/Array.prototype.push.apply(result.message.BOTH, resultRule5.message.BOTH);Array.prototype.push.apply(result.message.BOTH, resultRule6.message.BOTH);
    Array.prototype.push.apply(result.message.VPM_To_CAD, resultRule1.message.VPM_To_CAD); /*Array.prototype.push.apply(result.message.VPM_To_CAD, resultRule2.message.VPM_To_CAD);Array.prototype.push.apply(result.message.VPM_To_CAD, resultRule3.message.VPM_To_CAD);Array.prototype.push.apply(result.message.VPM_To_CAD, resultRule4.message.VPM_To_CAD);*/Array.prototype.push.apply(result.message.VPM_To_CAD, resultRule5.message.VPM_To_CAD);Array.prototype.push.apply(result.message.VPM_To_CAD, resultRule6.message.VPM_To_CAD);
    Array.prototype.push.apply(result.message.CAD_To_VPM, resultRule1.message.CAD_To_VPM);/*Array.prototype.push.apply(result.message.CAD_To_VPM, resultRule2.message.CAD_To_VPM);Array.prototype.push.apply(result.message.CAD_To_VPM, resultRule3.message.CAD_To_VPM);Array.prototype.push.apply(result.message.CAD_To_VPM, resultRule4.message.CAD_To_VPM);*/Array.prototype.push.apply(result.message.CAD_To_VPM, resultRule5.message.CAD_To_VPM);Array.prototype.push.apply(result.message.CAD_To_VPM, resultRule6.message.CAD_To_VPM);

    return result;
  },

  CheckIsNotAlreadyMapped : function (MXArrayVPMToMx,MXArrayMxToVPM,MXArrayBoth) {

    var result={VPM_To_CAD:true,CAD_To_VPM:true,BOTH:true,message:{VPM_To_CAD:new Array(), CAD_To_VPM:new Array(),BOTH:new Array()}},message="";

    if(MXArrayVPMToMx.length!==0 || MXArrayMxToVPM.length!==0 || MXArrayBoth.length!==0)
    {
      message=XCADMappingNLS.ErrorMatrixAlreadyMapped;
      result.BOTH=false;result.VPM_To_CAD=false;result.CAD_To_VPM=false;
      result.message.BOTH.push(message);result.message.VPM_To_CAD.push(message);result.message.CAD_To_VPM.push(message);
    }
    return result;
  },

  CheckCoherenceWithParentSide : function (parentSide) {

    var result={VPM_To_CAD:true,CAD_To_VPM:true,BOTH:true,message:{VPM_To_CAD:new Array(), CAD_To_VPM:new Array(),BOTH:new Array()}},message="";

    if(parentSide=="VPM_To_CAD")
    {
      message=XCADMappingNLS.ErrorParentSideVPMCAD;
      result.BOTH=false;result.CAD_To_VPM=false;
      result.message.BOTH.push(message);result.message.CAD_To_VPM.push(message);
    }
    else if(parentSide=="CAD_To_VPM")
    {
      message=XCADMappingNLS.ErrorParentSideCADVPM;
      result.BOTH=false;result.VPM_To_CAD=false;
      result.message.BOTH.push(message);result.message.VPM_To_CAD.push(message);
    }
    return result;
  },

  CheckCoherence : function ( VPMArrayVPMToMx,VPMArrayMxToVPM,VPMArrayBoth,MXArrayVPMToMx,MXArrayMxToVPM,MXArrayBoth) {

    var result={VPM_To_CAD:true,CAD_To_VPM:true,BOTH:true,message:{VPM_To_CAD:new Array(), CAD_To_VPM:new Array(),BOTH:new Array()}}, message="";

    if(VPMArrayMxToVPM.length!==0 || MXArrayMxToVPM.length!==0) {
      result.VPM_To_CAD=false;
      message="";
      if(VPMArrayMxToVPM.length!==0)
      {
        message = message +  XCADMappingNLS.ErrorVPMAlreadyUsedAsTargetWithAnotherObject;
        message += UIview.buildAddMappingWarningMessage(VPMArrayMxToVPM,"<=");
      }

      if (MXArrayMxToVPM.length!==0)
      {
        message = message +  XCADMappingNLS.ErrorMatrixAlreadyUsedAsSourceWithAnotherObject;
        message += UIview.buildAddMappingWarningMessage(MXArrayMxToVPM,"<=");
      }

      //message += ". VPM to CAD direction is not possible.";
      //result.message.push(message);
      result.message.VPM_To_CAD.push(message);
    }
    if(VPMArrayVPMToMx.length!==0 || MXArrayVPMToMx.length!==0)
    {
      result.CAD_To_VPM=false;
      message="";
      if(VPMArrayVPMToMx.length!==0)
      {
        message = message + XCADMappingNLS.ErrorVPMAlreadyUsedAsSourceWithAnotherObject;
        message += UIview.buildAddMappingWarningMessage(VPMArrayVPMToMx,"=>");
      }
      if (MXArrayVPMToMx.length!==0)
      {
        message = message +  XCADMappingNLS.ErrorMatrixAlreadyUsedAsTargetWithAnotherObject;
        message += UIview.buildAddMappingWarningMessage(MXArrayVPMToMx,"=>");
      }
      //message += ". CAD to VPM direction is not possible.";
      //result.message.push(message);
      result.message.CAD_To_VPM.push(message);
    }

    return result;
  },


  buildAddMappingWarningMessage : function (mappingArray, direction ) {
    var messageArray = new Array(), mappingMessage = "",  mapping;

    mappingArray.forEach(function(param)
        {
      mapping = param.mapping.element;
      mappingMessage =  mapping.VPMObject + direction + mapping.MatrixObject;
      if(messageArray.indexOf(mappingMessage) === -1)
      {
        messageArray.push(mappingMessage);
      }

        });

    return messageArray.join();
  },

  displayAddMappingWarningMessage : function (messageDiv,popoverInfoMapping ,messages ) {
    var messageList,iconInfo,cpt=0;
    if(messageDiv!=undefined)
    {
      iconInfo = messageDiv.getElement(".InfoAddXCADMapping");
      if(messages.length !==0)
      {
        iconInfo.show();
        messageList =UWA.createElement('ul', {'class' : 'ListAddXCADMappingMessage'});

        for(cpt=0;cpt<messages.length;cpt++)
        {
          UWA.createElement('li', {
            'text':messages[cpt],
          }).inject(messageList);
        }


        popoverInfoMapping.setBody(messageList);
      }
      else
        iconInfo.hide();
    }
  },

  hideAddMappingWarningMessage : function (messageDiv) {
    var iconInfo;
    iconInfo = messageDiv.getElement(".InfoAddXCADMapping");
    if(iconInfo != undefined)
      iconInfo.hide();
  },


  groupAttributeItf : function (listOfAttributeInfo) {
    var mapAttributeInfo = new Map(),i, attributeInfo, mapvalue,mapKey="Default";

    for (i=0; i<listOfAttributeInfo.length;i++)
    {
      attributeInfo = listOfAttributeInfo[i];
      if(attributeInfo.itf!==undefined && attributeInfo.itf!=="") mapKey = "Custo";
      else mapKey="Default";

      mapvalue = mapAttributeInfo.get(mapKey);
      if(mapvalue === undefined)
      {
        mapvalue = new Array();
        mapAttributeInfo.set(mapKey,mapvalue );
      }
      mapvalue.push(attributeInfo);
    }
    return mapAttributeInfo;
  },


  ShowModifyDirectionPanel: function (lineAttr,VPMType,MatrixType,attributeMapping,kindOfMapping) {

    var  iconInfoMessageBOTH,iconInfoMessageVPMCAD,iconInfoMessageCADVPM,divMessageBOTH,
    divMessageVPMCAD, divMessageCADVPM,popoverInfoMappingBOTH,popoverInfoMappingVPMCAD,popoverInfoMappingCADVPM,
    OKBtn, CancelBtn,modalbodydiv, modalbodyTable,modaltbody,lineModal,iCell,iCell1, toggleBoth, toggleVPM, toggleCAD, changeDirectionModal, modifyDirectionTitle ;


    modifyDirectionTitle = UWA.createElement('h4', {
      text   : XCADMappingNLS.ModifyDirectionTitle.format(attributeMapping.VPMAttribute,attributeMapping.MatrixAttribute) ,
    });

    modalbodydiv = UWA.createElement('div', {
      'class': 'CADProductAddXCADMappingDiv',
    })


    modalbodyTable =  UWA.createElement('table', {
      'id': 'CADProductAddXCADMappingTable',
      'class': 'table table-condensed table-hover'
    }).inject(modalbodydiv);


    modaltbody = UWA.createElement('tbody', {
      'class': 'addXCADMappingBody'
    }).inject(modalbodyTable);

    lineModal = UWA.createElement('tr').inject(modaltbody);

    iCell = UWA.createElement('td', {
      'Align' : 'left',
    });

    iCell1 = UWA.createElement('td', {
      'Align' : 'left',
      'width' : '92%'
    }).inject(iCell);

    UWA.createElement('p', {
      text   : XCADMappingNLS.side,
      'class': 'font-3dslight'// font-3dsbold
    }).inject(iCell1);

    iCell.inject(lineModal);

    iCell = UWA.createElement('td', {
      'Align' : 'left',
    }).inject(lineModal);


    toggleBoth =  new Toggle({ name: "optionsRadiosSide", value: "both", className: "primary"}).inject(iCell);
    toggleVPM =  new Toggle({ name: "optionsRadiosSide", value: "VPM to CAD", className: "primary"}).inject(iCell);
    toggleCAD =  new Toggle({ name: "optionsRadiosSide", value: "CAD to VPM", className: "primary"}).inject(iCell);


    var iCell2 = UWA.createElement('td', {
      'Align' : 'left',
    }).inject(lineModal);
    divMessageBOTH = UWA.createElement('div', {'class':'divAddXCADMappingMessage'}).inject(iCell2);
    divMessageVPMCAD = UWA.createElement('div', {'class':'divAddXCADMappingMessage'}).inject(iCell2);
    divMessageCADVPM = UWA.createElement('div', {'class':'divAddXCADMappingMessage'}).inject(iCell2);


    if(attributeMapping.SynchDirection === "BOTH" ) {toggleBoth.hide();divMessageBOTH.hide();}
    if(attributeMapping.SynchDirection === "VPM_To_CAD" ) {toggleVPM.hide();divMessageVPMCAD.hide();}
    if(attributeMapping.SynchDirection === "CAD_To_VPM" ) {toggleCAD.hide();divMessageCADVPM.hide();}



    iconInfoMessageBOTH = UWA.createElement('span', {
      'class' : 'InfoAddMapping fonticon fonticon-info'
    }).inject(divMessageBOTH);
    iconInfoMessageBOTH.hide();
    popoverInfoMappingBOTH = new Popover({
      target   : iconInfoMessageBOTH,
      trigger  : "hover",
      animate  : "true",
      position : 'left',
      body     : "",
      title    : 'BOTH'
    });

    iconInfoMessageVPMCAD = UWA.createElement('span', {
      'class' : 'InfoAddMapping fonticon fonticon-info'
    }).inject(divMessageVPMCAD);
    iconInfoMessageVPMCAD.hide();
    popoverInfoMappingVPMCAD = new Popover({
      target   : iconInfoMessageVPMCAD,
      trigger  : "hover",
      animate  : "true",
      position : 'left',
      body     : "",
      title    : 'VPM to CAD'
    });

    iconInfoMessageCADVPM = UWA.createElement('span', {
      'class' : 'InfoAddMapping fonticon fonticon-info'
    }).inject(divMessageCADVPM);
    iconInfoMessageCADVPM.hide();
    popoverInfoMappingCADVPM = new Popover({
      target   : iconInfoMessageCADVPM,
      trigger  : "hover",
      animate  : "true",
      position : 'left',
      body     : "",
      title    : 'CAD to VPM'
    });

    UWA.createElement('ul', {'class' : 'ListAddXCADMappingMessage'}).inject(divMessageBOTH);
    UWA.createElement('ul', {'class' : 'ListAddXCADMappingMessage'}).inject(divMessageVPMCAD);
    UWA.createElement('ul', {'class' : 'ListAddXCADMappingMessage'}).inject(divMessageCADVPM);


    var listOfVPMTypeRel,listOfMxTypeRel,listOfLinkedMapping,attrMappingMap,listOfMappedMXattr,listOfMappedVPMattr, VPMTypeRelInfo, MatrixTypeRelInfo, directionAvailable,authorizedDirection,
    messagesBOTH,messagesVPMCAD,messagesCADVPM;

    if(kindOfMapping.toUpperCase()==="TYPE")
    {
      listOfVPMTypeRel = this.listOfCustoVPMType;
      listOfMxTypeRel = this.listOfCustoPartType;
    }
    else
    {
      listOfVPMTypeRel = this.listOfCustoVPMRel;
      listOfMxTypeRel= this.listOfCustoEBOMRel;
    }


    VPMTypeRelInfo = listOfVPMTypeRel.get(VPMType);
    MatrixTypeRelInfo = listOfMxTypeRel.get (MatrixType);

    OKBtn = new Button({
      value : "Apply",
      id    : "modalOKButton",
      className : 'btn primary'
    });
    //OKBtn.disable();

    CancelBtn = new Button({
      value : "Cancel",
      id    : 'modalCancelButton',
      className : 'btn default'
    });


    if(VPMTypeRelInfo !== undefined  && MatrixTypeRelInfo !== undefined)
    {
      listOfLinkedMapping = UIview.getListOfLinkedMapping(VPMTypeRelInfo,MatrixTypeRelInfo,kindOfMapping,listOfVPMTypeRel,listOfMxTypeRel,this.listofTypeRelMapping);
      attrMappingMap = UIview.buildAttributesMappedWith(listOfLinkedMapping,attributeMapping);
      listOfMappedMXattr = (attrMappingMap.VPM).get(attributeMapping.VPMAttribute);
      listOfMappedVPMattr = (attrMappingMap.MX).get(attributeMapping.MatrixAttribute);

      directionAvailable = UIview.CheckRulesToAddAttrMapping(VPMTypeRelInfo, attributeMapping.VPMAttribute ,MatrixTypeRelInfo,attributeMapping.MatrixAttribute,kindOfMapping, listOfMappedMXattr, listOfMappedVPMattr);

      if(directionAvailable!==undefined)
      {
        if(!directionAvailable.BOTH) toggleBoth.setDisabled(true);
        if(!directionAvailable.VPM_To_CAD) toggleVPM.setDisabled(true);
        if(!directionAvailable.CAD_To_VPM) toggleCAD.setDisabled(true);

        messagesBOTH = directionAvailable.message.BOTH;
        messagesVPMCAD = directionAvailable.message.VPM_To_CAD;
        messagesCADVPM = directionAvailable.message.CAD_To_VPM;
      }


      if( !toggleBoth.isDisabled() && attributeMapping.SynchDirection !== "BOTH") toggleBoth.check();
      else if(!toggleVPM.isDisabled()&& attributeMapping.SynchDirection !== "VPM_To_CAD") toggleVPM.check();
      else if(!toggleCAD.isDisabled()&& attributeMapping.SynchDirection !== "CAD_To_VPM") toggleCAD.check();

      if(!toggleCAD.isChecked() && !toggleVPM.isChecked() && !toggleBoth.isChecked())
        OKBtn.setDisabled(true);


      UIview.displayAddMappingWarningMessage (divMessageBOTH,popoverInfoMappingBOTH ,messagesBOTH );
      UIview.displayAddMappingWarningMessage (divMessageVPMCAD,popoverInfoMappingVPMCAD ,messagesVPMCAD );
      UIview.displayAddMappingWarningMessage (divMessageCADVPM,popoverInfoMappingCADVPM ,messagesCADVPM );
    }


    changeDirectionModal = new Modal({
      className: 'add-mapping-modal',
      closable: true,
      header  :modifyDirectionTitle,
      body    : modalbodydiv,
      footer  : [ OKBtn, CancelBtn ]
    });

    CancelBtn.addEvent("onClick", function (e) {
      UWA.log(e);//that.onCancelCalled();
      changeDirectionModal.hide();
    });

    OKBtn.addEvent("onClick", function (e) {
      var txtSide,deployAttrcell,imgAttrSpan,directionAttributeCell, direction;

      txtSide;
      if(toggleBoth.isChecked())
      {
        txtSide="BOTH";
        direction = UIview.direction.BOTH;
      }
      else if (toggleVPM.isChecked())
      {
        txtSide="VPM_To_CAD";
        direction = UIview.direction.VPM_To_CAD;
      }
      else if (toggleCAD.isChecked())
      {
        txtSide="CAD_To_VPM";
        direction = UIview.direction.CAD_To_VPM;
      }
      else
      {
        txtSide="BOTH";
        direction = UIview.direction.BOTH;
      }

      attributeMapping.SynchDirection = txtSide;

      directionAttributeCell = lineAttr.cells[UIview.cellsAttrIndex.side];
      directionAttributeCell.value=direction;
      directionAttributeCell.empty();
      UWA.createElement('p', {
        text   : direction,
      }).inject(directionAttributeCell);


      if(attributeMapping.status === "Deployed" || attributeMapping.status === "Stored")
      {

        if(attributeMapping.status === "Stored")
        attributeMapping.status = "ModifiedStored";
        else
          attributeMapping.status = "ModifiedDeployed";

        //lineAttr.cells[UIview.cellsAttrIndex.action].hide();
        var arrayAction = lineAttr.cells[UIview.cellsAttrIndex.action].getElements('span');
        arrayAction.forEach(function(action){
          action.hide();
        });

        deployAttrcell=lineAttr.cells[UIview.cellsAttrIndex.deployFlag];
        deployAttrcell.empty();
        deployAttrcell.value = "Modified";
        deployAttrcell.title = XCADMappingNLS.ModifiedNotApplied;
        imgAttrSpan = ParametersLayoutViewUtilities.buildImgSpan('pencil', '1.5', 'red');
        imgAttrSpan.inject(deployAttrcell);
      }
      changeDirectionModal.hide();


    });


    changeDirectionModal.inject(this.contentDiv);
    changeDirectionModal.show();




},



  BuildAddMappingPanel : function ( title, VPMSelectPlaceHolder, MatrixSelectPlaceHolder, labelVPMtxt, labelMatrixtxt, labelProductToPart, labelPartToProduct, prefixToAdd) {


    var addMappingTitle, labelVPM, labelMatrix,  iconInfoMessageBOTH,iconInfoMessageVPMCAD,iconInfoMessageCADVPM,divMessageBOTH,
    divMessageVPMCAD, divMessageCADVPM,popoverInfoMappingBOTH,popoverInfoMappingVPMCAD,popoverInfoMappingCADVPM,
    OKBtn, CancelBtn,modalbodydiv, modalbodyTable,modaltbody,lineModal,iCell,iCell1, toggleBoth, toggleVPM, toggleCAD,selectVPM, cadAttr, addMappingModal ;


    addMappingTitle = UWA.createElement('h4', {
      text   : title,
    });

    modalbodydiv = UWA.createElement('div', {
      'class': 'CADProductAddXCADMappingDiv',
    })

    modalbodyTable =  UWA.createElement('table', {
      'id': 'CADProductAddXCADMappingTable',
      'class': 'table table-condensed table-hover'
    }).inject(modalbodydiv);


    modaltbody = UWA.createElement('tbody', {
      'class': 'addXCADMappingBody'
    }).inject(modalbodyTable);

    lineModal = UWA.createElement('tr').inject(modaltbody);

    iCell = UWA.createElement('td', {
      'Align' : 'left',
    });

    iCell1 = UWA.createElement('td', {
      'Align' : 'left',
      'width' : '92%'
    }).inject(iCell);

    labelVPM = UWA.createElement('p', {
      text   : labelVPMtxt ,
      'class': 'font-3dslight'// font-3dsbold
    }).inject(iCell1);

    iCell.inject(lineModal);


    iCell = UWA.createElement('td', {
      'Align' : 'left',
    }).inject(lineModal);

    selectVPM =  new Select({
      nativeSelect: true,
      placeholder: VPMSelectPlaceHolder,
      multiple: false,
    });
    selectVPM.inject(iCell);

    lineModal = UWA.createElement('tr').inject(modaltbody);

    iCell = UWA.createElement('td', {
      'Align' : 'left',
    });

    iCell1 = UWA.createElement('td', {
      'Align' : 'left',
      'width' : '92%'
    }).inject(iCell);

    labelMatrix = UWA.createElement('p', {
      text   : labelMatrixtxt ,
      'class': 'font-3dslight'// font-3dsbold
    }).inject(iCell1);

    iCell.inject(lineModal);


    iCell = UWA.createElement('td', {
      'Align' : 'left',
    }).inject(lineModal);

    cadAttr = new Text({
      placeholder: "...",
      id : 'cadAttrName',
      attributes: {
        value: '',
        multiline: false,
        disabled: false
      }
    });
    cadAttr.inject(iCell);

    lineModal = UWA.createElement('tr').inject(modaltbody);

    iCell = UWA.createElement('td', {
      'Align' : 'left',
    });

    iCell1 = UWA.createElement('td', {
      'Align' : 'left',
      'width' : '92%'
    }).inject(iCell);

    UWA.createElement('p', {
      text   : XCADMappingNLS.side,
      'class': 'font-3dslight'// font-3dsbold
    }).inject(iCell1);

    iCell.inject(lineModal);

    iCell = UWA.createElement('td', {
      'Align' : 'left',
    }).inject(lineModal);

    toggleBoth =  new Toggle({ name: "optionsRadiosSide", value: XCADMappingNLS.both, className: "primary"}).inject(iCell);
    toggleBoth.setCheck(true);
    toggleVPM =  new Toggle({ name: "optionsRadiosSide", value: labelProductToPart, className: "primary"}).inject(iCell);
    toggleCAD =  new Toggle({ name: "optionsRadiosSide", value: labelPartToProduct, className: "primary"}).inject(iCell);

    var iCell2 = UWA.createElement('td', {
      'Align' : 'left',
    }).inject(lineModal);
    divMessageBOTH = UWA.createElement('div', {'class':'divAddXCADMappingMessage'}).inject(iCell2);
    divMessageVPMCAD = UWA.createElement('div', {'class':'divAddXCADMappingMessage'}).inject(iCell2);
    divMessageCADVPM = UWA.createElement('div', {'class':'divAddXCADMappingMessage'}).inject(iCell2);


    iconInfoMessageBOTH = UWA.createElement('span', {
      'class' : 'InfoAddXCADMapping fonticon fonticon-info'
    }).inject(divMessageBOTH);
    iconInfoMessageBOTH.hide();
    popoverInfoMappingBOTH = new Popover({
      target   : iconInfoMessageBOTH,
      trigger  : "hover",
      animate  : "true",
      position : 'left',
      body     : "",
      title    : 'BOTH'
    });

    iconInfoMessageVPMCAD = UWA.createElement('span', {
      'class' : 'InfoAddXCADMapping fonticon fonticon-info'
    }).inject(divMessageVPMCAD);
    iconInfoMessageVPMCAD.hide();
    popoverInfoMappingVPMCAD = new Popover({
      target   : iconInfoMessageVPMCAD,
      trigger  : "hover",
      animate  : "true",
      position : 'left',
      body     : "",
      title    : 'Product to CAD'
    });

    iconInfoMessageCADVPM = UWA.createElement('span', {
      'class' : 'InfoAddXCADMapping fonticon fonticon-info'
    }).inject(divMessageCADVPM);
    iconInfoMessageCADVPM.hide();
    popoverInfoMappingCADVPM = new Popover({
      target   : iconInfoMessageCADVPM,
      trigger  : "hover",
      animate  : "true",
      position : 'left',
      body     : "",
      title    : 'CAD to Product'
    });

    UWA.createElement('ul', {'class' : 'ListAddXCADMappingMessage'}).inject(divMessageBOTH);
    UWA.createElement('ul', {'class' : 'ListAddXCADMappingMessage'}).inject(divMessageVPMCAD);
    UWA.createElement('ul', {'class' : 'ListAddXCADMappingMessage'}).inject(divMessageCADVPM);


    OKBtn = new Button({
      value : XCADMappingNLS.Apply,
      id    : "modalOKButton",
      className : 'btn primary'
    });
    OKBtn.disable();

    CancelBtn = new Button({
      value : XCADMappingNLS.Cancel,
      id    : 'modalCancelButton',
      className : 'btn default'
    });


    addMappingModal = new Modal({
      className: 'add-mapping-modal',
      closable: true,
      header  :addMappingTitle,
      body    : modalbodydiv,
      footer  : [ OKBtn, CancelBtn ]
    });



    selectVPM.addEvent("onChange",  function (e) {
      if( (selectVPM.getSelection(false)).length!=0) {
	cadAttr.enable();
        var myValue = selectVPM.getSelection(false)[0].value;
        if (myValue.contains('.')) {
          myValue = myValue.split('.')[1];

          toggleBoth.enable();
          toggleBoth.setCheck(true);
          toggleVPM.enable();
          toggleCAD.enable();
      
        } else {
          // we are on a core attribute by default allow only MxToCAD
          toggleBoth.disable();
          toggleVPM.setCheck(true);
          toggleVPM.disable();
          toggleCAD.disable();
        }

        // adding default prefix
        myValue = prefixToAdd+myValue;
 
        cadAttr.setValue(myValue);
        OKBtn.enable();
      } else {
	cadAttr.disable();
	cadAttr.setValue('');
        OKBtn.disable();
      }
    });


    cadAttr.addEvent("onChange", function (e) {
      
      if( (cadAttr.getValue().length==0)) {
        OKBtn.disable();
      } else {
        if( (selectVPM.getSelection(false)).length!=0) {
          OKBtn.enable();
        } else {
          OKBtn.disable();
        }
      }
    });

    return [addMappingModal, {selectVPM:selectVPM,cadAttr:cadAttr}, {toggle:toggleVPM, div:divMessageVPMCAD, popover:popoverInfoMappingVPMCAD},{toggle:toggleCAD, div:divMessageCADVPM, popover:popoverInfoMappingCADVPM},{toggle:toggleBoth, div:divMessageBOTH, popover:popoverInfoMappingBOTH},{OKButton:OKBtn, CancelButton:CancelBtn }];
  },


        setDeletedCellStyle : function (iCell) {
            var previousVal = iCell.value,
            previousTxt = iCell.getText();
            if(previousTxt === undefined) previousTxt = previousVal;
            iCell.empty();
            UWA.createElement('del', {
                text   : previousTxt,
                value  : previousVal,
            }).inject(iCell);
        },

        setNormalCellStyle : function (iCell) {
            var previousVal = iCell.value,
            previousTxt = iCell.getText();
            if(previousTxt === undefined) previousTxt = previousVal;
            iCell.empty();
            UWA.createElement('p', {
                text   : previousTxt,
                value  : previousVal,
            }).inject(iCell);
        },


}



return UIview;
});

/*! Copyright 2017, Dassault Systemes. All rights reserved. */
/*global define, widget, document, setTimeout, console, alert, clearTimeout*/
/*jslint plusplus: true*/
/*jslint nomen: true*/
/*@quickReview NZV 19/01/31 FUN085423 delivery*/
/*@quickReview NZV 18/04/27 FUN076055 delivery*/
/*@quickReview NZV 18/02/07 FUN076053 delivery*/
/*@quickReview ZUR 17/10/11 IR-558248-3DEXPERIENCER2018x*/
/*@quickReview NZV 17/08/27 IR-540216-3DEXPERIENCER2018x*/
/*@quickReview NZV 17/07/06 Minor change related to Units NLS value*/
/*@quickReview NZV 17/06/15 Minor change clear dimension dropdown list before populate*/
/*@quickReview NZV 17/06/15 IR-529296-3DEXPERIENCER2018x*/
/*@quickReview NZV 17/05/22 IR-518037-3DEXPERIENCER2018x*/
/*@quickReview ZUR 17/05/10 IR-518037-3DEXPERIENCER2018x*/
/*@quickReview NZV 17/05/09 IR-519160-3DEXPERIENCER2018x minor changes*/
/*@quickReview NZV 17/05/04 IR-519148-3DEXPERIENCER2018x,IR-512104-3DEXPERIENCER2018x,IR-509281-3DEXPERIENCER2018x */
/*@quickReview NZV 17/05/02 Minor change */
/*@quickReview ZUR 17/04/19 IR-514503-3DEXPERIENCER2017x/18x */
/*@quickReview NZV 17/03/06 IR-506136-3DEXPERIENCER2018x fixed -minor change */
/*@quickReview NZV 17/03/02 IR-504465-3DEXPERIENCER2018x fixed -minor change */
/*@fullReview  NZV 17/04/21 Delivery of HL FUN070867  -major change */
/*@fullReview  NZV 17/03/06 IR-506136-3DEXPERIENCER2018x fixed -minor change */
/*@fullReview  NZV 17/03/02 IR-504465-3DEXPERIENCER2018x fixed -minor change */
/*@fullReview  ZUR 15/07/29 2016xFD01 Param Widgetization NG*/
define('DS/ParameterizationSkeleton/Views/ParameterizationDataModeling/AttributesLayoutUtilities',
    [
        'UWA/Core',
        'DS/UIKIT/Input/Button',
        'DS/UIKIT/Modal',
        'DS/UIKIT/Input/Select',
        'DS/UIKIT/Input/Text',
        'DS/UIKIT/Input/Toggle',
        'DS/UIKIT/Input/Date',
        'DS/UIKIT/Alert',
        'DS/UIKIT/Popover',
        'DS/UIKIT/Autocomplete',
        'UWA/Controls/Tag',
        'DS/ParameterizationSkeleton/Views/ParameterizationDataModeling/AttributesTypesDefine',
        'DS/ParameterizationSkeleton/Utils/ParameterizationGenericServices',
        'DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
        'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS'
    ],
    function (UWA,
              Button, Modal, Select, Text, Toggle, InputDate,
              Alert, Popover, Autocomplete, Tag,
              AttributesTypesDefine, GenericServices,
              ParametersLayoutViewUtilities,
              ParamSkeletonNLS) {

        'use strict';

        var AttrUtilsView = {

                init : function () {
                    this.attrDefValueInput = null;
                    this.cellsIndex = [];
                    this.dimensionsList = null;
                    this.dimensionServiceFailed = false;
                    this.dimensionToolTipCell = null;
                    this.userMessaging = null;
                    /*"DeletedNotDeployed"
                    "NewNotDeployed"
                    "StoredButNotDeployed"
                    "Deployed"
                    "Modified"*/
                },

                initCells : function () {
                    this.cellsIndex = {
                        "TypeName" : 0,
                        "AttributeName" : 1,
                        "DefaultValue" : 2,
                        "Mandatory" : 3,
                        "Export3DXML" : 4,
                        "resetWhenDuplicate" : 5,
                        "resetWhenRevision" : 6,
                        "ReadOnly" : 7,
                        "Indexed" : 8,
                        "AuthValue" : 9,
                        "SixWTag" : 10,
                        "Dimension" : 11,
                        "Action" : 12,
                        "DeployStatus" : 13
                    };

                    this.dimensionServiceFailed = false;
                    this.dimensionToolTipCell = null;
                    this.dimensionsSelector = null;
                    this.dimensionTitleCell = null;

                },

                dimensionsList : null,
                listOf6Wpredicates : null,
 
                getDefaultValueInput : function () {
                    return this.attrDefValueInput;
                },

                buildNLSText : function(title1, width1, tooltiptext) {
                    var iCell, iCell1, iCell2, imgInfoSpan, popoverAuth;


                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : width1
                    });

                    iCell1 = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : '92%'
                    }).inject(iCell);

                    UWA.createElement('p', {
                        text   : title1,
                        'class': 'font-3dslight'// font-3dsbold
                    }).inject(iCell1);

                    if (tooltiptext !== '') {
                        iCell2 = UWA.createElement('td', {
                            'Align' : 'left',
                            'width' : '5%'
                        }).inject(iCell);

                        imgInfoSpan = UWA.createElement('span', {
                            'class' : 'fonticon fonticon-info'
                        }).inject(iCell2);

                        imgInfoSpan.setStyle("color", "black");

                        popoverAuth = new Popover({
                            target   : imgInfoSpan,
                            trigger  : "hover",
                            animate  : "true",
                            position : 'top',
                            body     : tooltiptext,
                            title    : ''
                        });
                    }
                    return iCell;
                },

                fetchAndPopulate6WPredicates : function (sixWTagControl, attributeType) {
                    if (AttrUtilsView.listOf6Wpredicates === null) {
                        GenericServices.getPredicatesReturn(function (result) {
                            AttrUtilsView.listOf6Wpredicates = result;
                            AttrUtilsView.FilterPredicatesListbyType(attributeType, AttrUtilsView.listOf6Wpredicates, sixWTagControl);
                        }, function () {
                            UWA.log("getFedProperties failed! call while updating dropdown list of sixWPredicate");
                        });
                    } else {
                        if (sixWTagControl !== undefined && sixWTagControl !== null) {
                            AttrUtilsView.FilterPredicatesListbyType(attributeType, AttrUtilsView.listOf6Wpredicates, sixWTagControl);
                        }
                    }

                },

                addUserMessaging : function (renderToTarget, ihideDelay) {
                    var userMessaging = new Alert({
                        className : 'param-alert',
                        closable: true,
                        visible: true,
                        renderTo : renderToTarget,
                        autoHide : true,
                        hideDelay : ihideDelay,
                        messageClassName : 'warning'
                    });
                    return userMessaging;
                },

                buildTypeSelect : function () {
                    var i, typeID, isOptionSelected,
                        listofTypes = AttributesTypesDefine.getListOfHandledTypes(),
                        typesSelect =  new Select({
                            nativeSelect: true,
                            placeholder: false,
                            multiple: false
                        });

                    for (i = 0; i < listofTypes.length; i++) {
                        typeID = listofTypes[i].type + listofTypes[i].length;
                        isOptionSelected = false;
                        if (typeID  === 'String') {
                            isOptionSelected = true;
                        }

                        typesSelect.add([{
                            label: ParamSkeletonNLS[typeID],
                            value: typeID,
                            selected: isOptionSelected
                        }], false);
                    }
                    return typesSelect;
                },

                buildToolTipForDimension : function(iCell, message, toolTipcolor) {
                    var imgInfoSpan, popoverAuth;

                    if (iCell !== null && AttrUtilsView.dimensionServiceFailed === true) {

                        if (iCell.childNodes[1].childNodes[0].destroy !== undefined) {
                            iCell.childNodes[1].childNodes[0].destroy();
                        }

                        imgInfoSpan = UWA.createElement('span', {
                            'class' : 'fonticon fonticon-info'
                        }).inject(iCell.childNodes[1]);

                        imgInfoSpan.setStyle("color", toolTipcolor);

                        popoverAuth = new Popover({
                            target   : imgInfoSpan,
                            trigger  : "hover",
                            animate  : "true",
                            position : 'top',
                            body     : message,
                            title    : ''
                        });
                    }
                },

                buildDimensionError : function () {
                    var timerconn, userMessaging;
                    AttrUtilsView.dimensionServiceFailed = true;

                    userMessaging = AttrUtilsView.addUserMessaging(document.body, 1500);

                    AttrUtilsView.buildToolTipForDimension(AttrUtilsView.dimensionToolTipCell, ParamSkeletonNLS.DimensionServiceFailed, "orange");

                    if (timerconn) { clearTimeout(timerconn); }
                    timerconn = setTimeout(function() {
                        userMessaging.add({ className: "warning", message: ParamSkeletonNLS.DimensionServiceFailed});
                    }, 40);
                },

                fetchAndSetNLSDimensions : function (dimension, perferredUnit, dimPara) {
                    var i, j, dimName, dimNLSName = "", unitNLSName = "", units = [], nlsStr = "";

                    if (AttrUtilsView.dimensionsList !== null && dimension !== undefined && dimension !== "") {

                        for (i = 0; i < AttrUtilsView.dimensionsList.length; i++) {
                            dimName = AttrUtilsView.dimensionsList[i].Name;
                            if (dimName === dimension) {
                                dimNLSName = AttrUtilsView.dimensionsList[i].NLS;
                                units = AttrUtilsView.dimensionsList[i].Units;

                                if (perferredUnit !== undefined && perferredUnit !== "") {
                                    for (j = 0; j < units.length; j++) {
                                        if (perferredUnit === units[j].Name) {
                                            unitNLSName = units[j].NLSName;
                                            break;
                                        }
                                    }
                                }
                                break;
                            }
                        }
                        if (dimNLSName !== undefined && dimNLSName !== "") {
                            if (unitNLSName !== undefined && unitNLSName !== "") {
                                nlsStr = dimNLSName + "\n(" + unitNLSName + ")";
                            } else if (perferredUnit !== undefined && perferredUnit !== "") {
                                nlsStr = dimNLSName + "\n(" + perferredUnit + ")";
                            } else {
                                nlsStr = dimNLSName;
                            }
                        } else if (dimension !== undefined && dimension !== "") {
                            if (perferredUnit !== undefined && perferredUnit !== "") {
                                nlsStr = dimension + "\n(" + perferredUnit + ")";
                            } else {
                                nlsStr = dimension;
                            }
                        }
                    } else {
                        nlsStr = "";
                    }
                    if (dimPara.setText !== undefined) {
                        dimPara.setText(nlsStr);
                    }
                },

                getNLSDimensionStr : function (dimension, perferredUnit, dimPara) {
                    if (AttrUtilsView.dimensionsList === null) {
                        AttrUtilsView.dimensionServiceFailed = false;
                        GenericServices.getDimensions(function (jsonResult) {
                            if (jsonResult !== 'undefined') {
                                AttrUtilsView.dimensionsList = jsonResult;
                                AttrUtilsView.getNLSDimensionStr(dimension, perferredUnit, dimPara);
                            }
                        },
                            function () {
                                if (AttrUtilsView.dimensionTitleCell !== null) {
                                    if (AttrUtilsView.dimensionTitleCell.childNodes.length === 1) {
                                        UWA.createElement('h5', {
                                            text: ParamSkeletonNLS.DimensionInternalName
                                        }).inject(AttrUtilsView.dimensionTitleCell);
                                    }
                                }
                                AttrUtilsView.dimensionServiceFailed = true;
                                AttrUtilsView.fetchAndSetNLSDimensions(dimension, perferredUnit, dimPara);

                            });
                    } else {
                        AttrUtilsView.fetchAndSetNLSDimensions(dimension, perferredUnit, dimPara);
                    }
                },

                onSuccessOfGetDimensions : function (jsonResult) {
                    if (jsonResult !== 'undefined') {
                        AttrUtilsView.dimensionsList = jsonResult;
                        AttrUtilsView.populateDimenstionSelect();
                    }
                },

                populateDimenstionSelect : function (dimensionsSelect) {
                    var i, dimNLSName, dimName,
                        listofDimension = AttrUtilsView.dimensionsList;

                    dimensionsSelect = AttrUtilsView.dimensionsSelector;
                    dimensionsSelect.remove();

                    if ((dimensionsSelect !== undefined) && (dimensionsSelect !== null)) {
                        if (listofDimension.length > 0) {
                            dimensionsSelect.enable();
                        }
                        for (i = 0; i < listofDimension.length; i++) {
                            dimNLSName = listofDimension[i].NLS;
                            dimName = listofDimension[i].Name;
                            dimensionsSelect.add([{
                                label: dimNLSName,
                                value: dimName
                            }], false);
                        }
                    }
                },

                buildDimensionsSelect : function (dimensionsSelect) {
                    if (AttrUtilsView.dimensionsList === null) {
                        AttrUtilsView.dimensionServiceFailed = false;
                        GenericServices.getDimensions(AttrUtilsView.onSuccessOfGetDimensions, AttrUtilsView.buildDimensionError);
                    } else {
                        AttrUtilsView.populateDimenstionSelect(dimensionsSelect);
                    }
                },

                buildPreUnitsSelect : function (inputElement, unitsSelect) {
                    var i, j, dimNLSName, dimName, unitsName, defaultUnitName,
                        unitsNLS, isOptionSelected, dimensionName, listofDimension,
                        units = null,
                        dimensions = inputElement.getValue();

                    dimensionName = dimensions[0];
                    unitsSelect.clear();
                    unitsSelect.remove();//IR-529296-3DEXPERIENCER2018x

                    if (dimensionName === '') {
                        unitsSelect.disable();
                        return unitsSelect;
                    }

                    listofDimension = AttrUtilsView.dimensionsList;

                    for (i = 0; i < listofDimension.length; i++) {
                        dimNLSName = listofDimension[i].NLS;
                        dimName =  listofDimension[i].Name;

                        if (dimName  === dimensionName) {
                            defaultUnitName = listofDimension[i].MKSUnit;
                            units = listofDimension[i].Units;
                            break;
                        }
                    }
                    if (units !== null) {
                        if (units.length > 0) {
                            unitsSelect.enable();
                        } else {
                            unitsSelect.disable();
                        }

                        for (j = 0; j < units.length; j++) {
                            unitsName = units[j].Name;
                            if (units[j].NLSName !== "") {
                                unitsNLS = units[j].NLSName;
                            } else {
                                unitsNLS = unitsName;
                            }
                            isOptionSelected = false;
                            if (unitsName === defaultUnitName) {
                                isOptionSelected = true;
                            }

                            unitsSelect.add([{
                                label: unitsNLS,
                                value: unitsName,
                                selected: isOptionSelected
                            }], false);
                        }
                    } else {
                        unitsSelect.disable();
                    }

                    return unitsSelect;
                },

                buildBooleanDefault : function () {
                    var boolSelect =  new Select({
                            nativeSelect: true,
                            placeholder: false,
                            multiple: false,
                            options: [ { value: 'TRUE', label: ParamSkeletonNLS.TrueLabel, selected: true},
                                       { value: 'FALSE', label: ParamSkeletonNLS.FalseLabel}]
                        });
                    return boolSelect;
                },

                buildTextDefault : function (userMessaging) {
                    var timerconn, diffDate,
                        currTime = new Date().getTime(),
                        lastMessageDate = currTime,
                        iDefaulInputText = new Text({
                            id : 'attrDefValueInput',
                            attributes: {
                                value: '',
                                multiline: false,
                                disabled: false
                            },
                            events: {
                                onKeyDown: function () {
                                    if (timerconn) { clearTimeout(timerconn); }
                                    timerconn = setTimeout(function() {
                                        currTime = new Date().getTime();

                                        if (AttrUtilsView.testStrictSpecialCharacters(iDefaulInputText.getValue())) {
                                            diffDate = currTime - lastMessageDate;
                                            if (diffDate > 1500) {
                                                userMessaging.add({ className: "error", message: ParamSkeletonNLS.SpecialCharactersMsg});
                                                lastMessageDate = new Date().getTime();
                                            }
                                            iDefaulInputText.elements.input.setStyle('color', 'red');
                                            iDefaulInputText.focus();
                                        } else if (ParametersLayoutViewUtilities.containsAccents(iDefaulInputText.getValue())) {
                                            diffDate = currTime - lastMessageDate;
                                            if (diffDate > 1500) {
                                                userMessaging.add({ className: "error", message: ParamSkeletonNLS.AccentsnotAllowedMsg});
                                                lastMessageDate = new Date().getTime();
                                            }
                                            iDefaulInputText.elements.input.setStyle('color', 'red');
                                            iDefaulInputText.focus();
                                        } else {
                                            iDefaulInputText.elements.input.setStyle('color', '#555555');
                                        }
                                    }, 20);
                                }//onKeyDown
                            }//events
                        });
                    return iDefaulInputText;
                },

                buildDateDefault : function () {
                    var dateSpan, dateInput, dateCheckbox;
                    dateSpan = UWA.createElement('span');

                    dateInput = new InputDate({
                        value: new Date()
                    }).inject(dateSpan);

                    dateSpan.dateInput = dateInput;

                    dateCheckbox = new Toggle({
                        type: 'checkbox',
                        label: ParamSkeletonNLS.NoDefaultValue
                    }).uncheck().inject(dateSpan);
                    dateSpan.dateCheckbox = dateCheckbox;
                    dateCheckbox.addEvent('onChange', function() {
                        if (this.isChecked()) {
                            dateInput.setDate(null);
                            dateInput.setValue(null);
                            dateInput.disable();
                        } else {
                            dateInput.setDate(new Date());
                            dateInput.enable();
                        }
                    });
                    return dateSpan;
                },

                buildTitlesLine : function (wdthArray) {
                    var iCell, cellsIndex,
                        lineTitle = UWA.createElement('tr', {
                            'class' : 'success'
                        });
                    //initilize variable & constent
                    this.initCells();
                    cellsIndex = this.cellsIndex;
                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.TypeName].toString() + '%'
                    }).inject(lineTitle);

                    UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.AttributeTypeNLenth
                        //'class': 'font-3dslight'// font-3dsbold
                    }).inject(iCell);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.AttributeName].toString() + '%'
                    }).inject(lineTitle);

                    UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.AttributeName
                        //'class': 'font-3dslight'
                    }).inject(iCell);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.DefaultValue].toString() + '%'
                    }).inject(lineTitle);

                    UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.AttributeDefaultValue
                        //'class': 'font-3dslight'
                    }).inject(iCell);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.Mandatory].toString() + '%'
                    }).inject(lineTitle);

                    UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.MandatoryAttributeTitle
                        //'class': 'font-3dslight'
                    }).inject(iCell);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.Export3DXML].toString() + '%'
                    }).inject(lineTitle);

                    UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.ExportIn3DXML
                        //'class': 'font-3dslight'
                    }).inject(iCell);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.resetWhenDuplicate].toString() + '%'
                    }).inject(lineTitle);

                    UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.ResetOnDuplicate
                        //'class': 'font-3dslight'
                    }).inject(iCell);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.resetWhenRevision].toString() + '%'
                    }).inject(lineTitle);

                    UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.ResetOnRevision
                        //'class': 'font-3dslight'
                    }).inject(iCell);


                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.ReadOnly].toString() + '%'
                    }).inject(lineTitle);

                    UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.ReadOnlyAttributeTitle
                        //'class': 'font-3dslight'
                    }).inject(iCell);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.Indexed].toString() + '%'
                    }).inject(lineTitle);

                    UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.IndexedAttributeTitle
                        //'class': 'font-3dslight'
                    }).inject(iCell);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.AuthValue].toString() + '%'
                    }).inject(lineTitle);

                    UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.AuthorizedValsTitle
                        //'class': 'font-3dslight'
                    }).inject(iCell);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.SixWTag].toString() + '%'
                    }).inject(lineTitle);

                    UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.SixWTagAttributeTitle
                        //'class': 'font-3dslight'
                    }).inject(iCell);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.Dimension].toString() + '%'
                    }).inject(lineTitle);

                    AttrUtilsView.dimensionTitleCell =  UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.Dimensions
                        //'class': 'font-3dslight'
                    }).inject(iCell);

                    //actionWidth = wdthArray[10] + wdthArray[11];

                    iCell = UWA.createElement('td', {
                        'Align'  : 'left',
                        'colspan': '2',
                        'width'  : wdthArray[cellsIndex.Action].toString() + '%'
                    }).inject(lineTitle);

                    UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.ActionsText
                    }).inject(iCell);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.DeployStatus].toString() + '%'
                    }).inject(lineTitle);

                    UWA.createElement('h5', {
                        text   : ParamSkeletonNLS.DeployStatus
                        //'class': 'font-3dslight'
                    }).inject(iCell);

                    return lineTitle;
                },
                update6WTagCellWithNLS : function (cell, sixWTagValue, isixwTagNLS) {
                    if (isixwTagNLS !== "") {
                        AttrUtilsView.update6WTagCell(cell, isixwTagNLS);
                    } else {

                        if (AttrUtilsView.listOf6Wpredicates !== null) {
                            isixwTagNLS = AttrUtilsView.getMatching6wtagNLS(sixWTagValue, AttrUtilsView.listOf6Wpredicates);
                            AttrUtilsView.update6WTagCell(cell, isixwTagNLS);
                        } else {
                            GenericServices.getPredicatesReturn(function (result) {
                                AttrUtilsView.listOf6Wpredicates = result;
                                isixwTagNLS = AttrUtilsView.getMatching6wtagNLS(sixWTagValue, AttrUtilsView.listOf6Wpredicates);
                                AttrUtilsView.update6WTagCell(cell, isixwTagNLS);
                            }, function (eMessage) {
                                AttrUtilsView.update6WTagCell(cell, sixWTagValue);
                                UWA.log("getFedProperties failed! call while get label value of " + sixWTagValue + eMessage);
                            });
                        }
                    }
                },

                update6WTagCell : function (cell, isixwTag) {
                    if ((isixwTag !== undefined) &&
                            (isixwTag !== '')) {
                        new Tag({
                            value: isixwTag,
                            className: 'border-only',
                            closable: true
                        }).inject(cell);
                    }
                },

                buildAttributeLine : function (itypeNLen, iName, iDefaultValue, isMand, isReadOnly,
                    isExposedTo3DXML, iDimension, iPerferredUnit, isIndexed, iAuthValues, isixwTag,
                    isixwTagValue, isUsedInOtherSettings, isDeployed, wdthArray, userMessaging,
                    revisionToggle, duplicateToggle,that) {
                    var iCell, removeAttributeButton, deleteSpan, removePop, defaultValuetoShow, iATpos,//editPop, editSpan, editAttributeButton,
                        iconChoice, iconColor,
                        dimPara,
                        defaultDateObj,//sixWTagContainer,
                        defCellTitle = "",
                        removelts = [], dimensionText = "",
                        lineAttr = UWA.createElement('tr'),
                        cellsIndex = this.cellsIndex, sixWTagCell;

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.TypeName].toString() + '%',
                        'value'  : itypeNLen
                    }).inject(lineAttr);

                    UWA.createElement('p', {
                        text   : ParamSkeletonNLS[itypeNLen],
                        'class': 'font-3dslight'// font-3dsbold
                    }).inject(iCell);

                    iCell = UWA.createElement('td', {
                        'Align'  : 'left',
                        'width'  : wdthArray[cellsIndex.AttributeName].toString() + '%',
                        'value'  : iName
                    }).inject(lineAttr);

                    UWA.createElement('p', {
                        text   : iName,
                        value  : iName,
                        'class': 'font-3dslight'
                    }).inject(iCell);

                    defaultValuetoShow = iDefaultValue;
                    //ZUR IR-494192-3DEXPERIENCER2017x
                    //default 2017/01/24@11:00:00:GMT (generated 2017-01-24T18:32:22.382Z)
                    //3/23/2017           

                    if (itypeNLen === "Date") {
                        defaultDateObj = new Date(iDefaultValue);
                        defCellTitle = defaultDateObj.toDateString();
                        iATpos = iDefaultValue.indexOf("@");
                        if (iATpos > 0) {
                            defaultValuetoShow  = iDefaultValue.substring(0, iATpos);
                        }
                    }

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.DefaultValue].toString() + '%',
                        'value' : iDefaultValue,
                        'title' : defCellTitle
                    }).inject(lineAttr);

                    UWA.createElement('p', {
                        text   : defaultValuetoShow,
                        'class': 'font-3dslight'
                    }).inject(iCell);

                    /*if (!isMand) {
                        iconChoice = 'cancel-squared';
                        iconColor = 'orange';
                    }*/

                    if (isMand === true) {
                        iconChoice = 'check';
                        iconColor = 'green';
                        iCell = ParametersLayoutViewUtilities.buildImgCell(iconChoice, '1', iconColor, isMand, wdthArray[cellsIndex.Mandatory].toString() + '%', 'center');
                    } else {
                        iCell = UWA.createElement('td', {'width'  : wdthArray[cellsIndex.Mandatory].toString() + '%'}).inject(lineAttr);
                    }
                    iCell.value = isMand;
                    iCell.inject(lineAttr);

                    //expose to 3dXML
                    if (isExposedTo3DXML === true) {
                        iconChoice = 'check';
                        iconColor = 'green';
                        iCell = ParametersLayoutViewUtilities.buildImgCell(iconChoice, '1', iconColor, isExposedTo3DXML, wdthArray[cellsIndex.Export3DXML].toString() + '%', 'center');
                    } else {
                        iCell = UWA.createElement('td', {'width'  : wdthArray[cellsIndex.Export3DXML].toString() + '%'}).inject(lineAttr);
                    }
                    iCell.value = isExposedTo3DXML;
                    iCell.inject(lineAttr);
                   // end expose to 3dxml
                    if (duplicateToggle === undefined || duplicateToggle === "") {
                        duplicateToggle = false; //set defual value
                    }
                    //expose to duplicateToggle
                    if (duplicateToggle === true) {
                        iconChoice = 'check';
                        iconColor = 'green';
                        iCell = ParametersLayoutViewUtilities.buildImgCell(iconChoice, '1', iconColor, duplicateToggle, wdthArray[cellsIndex.resetWhenDuplicate].toString() + '%', 'center');
                    } else {
                        iCell = UWA.createElement('td', {'width'  : wdthArray[cellsIndex.resetWhenDuplicate].toString() + '%'}).inject(lineAttr);
                    }
                    iCell.value = duplicateToggle;
                    iCell.inject(lineAttr);
                    //end expose to duplicateToggle
                    //expose to revisionToggle, 
                    if (revisionToggle === undefined || revisionToggle === "") {
                        revisionToggle = false; //set defual value
                    }
                    if (revisionToggle === true) {
                        iconChoice = 'check';
                        iconColor = 'green';
                        iCell = ParametersLayoutViewUtilities.buildImgCell(iconChoice, '1', iconColor, revisionToggle, wdthArray[cellsIndex.resetWhenRevision].toString() + '%', 'center');
                    } else {
                        iCell = UWA.createElement('td', {'width'  : wdthArray[cellsIndex.resetWhenRevision].toString() + '%'}).inject(lineAttr);
                    }
                    iCell.value = revisionToggle;
                    iCell.inject(lineAttr);
                    //end expose to revisionToggle
                    if (isReadOnly === true) {
                        iconChoice = 'check';
                        iconColor = 'green';
                        iCell = ParametersLayoutViewUtilities.buildImgCell(iconChoice, '1', iconColor, isReadOnly, wdthArray[cellsIndex.ReadOnly].toString() + '%', 'center');
                    } else {
                        iCell = UWA.createElement('td', {'width'  : wdthArray[cellsIndex.ReadOnly].toString() + '%'}).inject(lineAttr);
                    }
                    iCell.value = isReadOnly;
                    iCell.inject(lineAttr);
                    //NZV : Remove Index toggle button with Function FUN085423 
                    if (isIndexed === true) {
                        iconChoice = 'check';
                        iconColor = 'green';
                        iCell = ParametersLayoutViewUtilities.buildImgCell(iconChoice, '1', iconColor, isIndexed, wdthArray[cellsIndex.Indexed].toString() + '%', 'center');
                    } else {
                        iCell = UWA.createElement('td', {'width'  : wdthArray[cellsIndex.Indexed].toString() + '%'}).inject(lineAttr);
                    }
                    iCell.value = isIndexed;
                    iCell.inject(lineAttr);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.AuthValue].toString() + '%',
                        'value' : iAuthValues
                    }).inject(lineAttr);

                    UWA.createElement('p', {
                        text   : iAuthValues,
                        'class': 'font-3dslight'
                    }).inject(iCell);

                    sixWTagCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.SixWTag].toString() + '%',
                        'value' : isixwTagValue
                    }).inject(lineAttr);

                    if ((isixwTagValue !== undefined) && (isixwTagValue !== '')) {
                        AttrUtilsView.update6WTagCellWithNLS(sixWTagCell, isixwTagValue, isixwTag);
                    }

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : wdthArray[cellsIndex.Dimension].toString() + '%',
                        'value' : iDimension + "," + iPerferredUnit
                    }).inject(lineAttr);

                    dimPara = UWA.createElement('p', {
                        text   : dimensionText,
                        'class': 'font-3dslight'
                    }).inject(iCell);

                    if ((iDimension !== undefined) && (iDimension !== "")) {
                        dimensionText = AttrUtilsView.getNLSDimensionStr(iDimension, iPerferredUnit, dimPara);

                    }

                    //fonticon fonticon-pencil 
                    //fonticon fonticon-fonticon fonticon-cancel fonticon-1.5x

                    /*editElts = AttrUtilsView.createEditActionElements();
                    editSpan = editElts[0];
                    editSpan.inject(iCell);
                    editAttributeButton = editElts[1];
                    editPop = editElts[2];

                    editAttributeButton.addEvent("onClick", function () {
                        UWA.log("editAttributeButton::onClick");
                    });*/
                    //Cell - 10, Action element
                   // var  actionWidth = wdthArray[cellsIndex.Action] + wdthArray[cellsIndex.DeployStatus];
                    /*iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : actionWidth.toString() + '%'
                    }).inject(lineAttr);*/

                    iCell = UWA.createElement('td', {
                        'Align' : 'center',
                        'colspan': '2',
                        'width' : wdthArray[cellsIndex.Action].toString() + '%'
                    }).inject(lineAttr);
                    //NZV - FUN085423
                    var editElts = ParametersLayoutViewUtilities.createActionElements(ParamSkeletonNLS.EditAttribute, false);
                    var editSpan = editElts[0];
                     //actionSpan.setStyle("padding-right", "20px");
                    editSpan.setStyle("float", "left");
                    editSpan.inject(iCell);
                    var editAttributeButton = editElts[1];
                    var editPop = editElts[2];
                    
                    removelts = ParametersLayoutViewUtilities.createActionElements(ParamSkeletonNLS.DeleteAttributetxt, true);
                    deleteSpan = removelts[0];
                    deleteSpan.setStyle("float", "right");
                    deleteSpan.inject(iCell);
                    removeAttributeButton = removelts[1];
                    removePop = removelts[2];

                    iCell = ParametersLayoutViewUtilities.buildDeployStsCell(isDeployed.toString(), wdthArray[cellsIndex.DeployStatus].toString() + '%', '1.5', 'center');

                    if (isDeployed === true) {
                        iCell.value  = "Deployed";
                    } else if (isDeployed === "NewNotDeployed") {
                        iCell.value  = "NewNotDeployed";
                    } else {
                        iCell.value  = "StoredButNotDeployed";//"false"
                    }

                    //iCell.value = isDeployed;
                    iCell.inject(lineAttr);

                    editAttributeButton.addEvent("onClick", function () {
                        AttrUtilsView.showEditAttributeModel(userMessaging,that,lineAttr)
                    });

                    removeAttributeButton.addEvent("onClick", function () {
                        var lineDeployStatusValue = iCell.value, objToBeRemoved;//IR-518037-3DEXPERIENCER2018x
                        if (isUsedInOtherSettings === true) {//IR-516226-3DEXPERIENCER2017x/18x
                            userMessaging.add({ className: "warning", message: ParamSkeletonNLS.AttributeUsedInOtherMsg });
                        } else {
                            if (lineDeployStatusValue === "NewNotDeployed") {
                                removePop.destroy();//editPop.remove();
                                AttrUtilsView.attributeLinetobeDeleted(lineAttr);//attrIndexToggle*/
                            } else {
                                //AttrUtilsView.showContextualDeleteModal(widget.body, lineAttr, removePop);
                                objToBeRemoved = {popOver : removePop, attrLine : lineAttr}; //IR-689657-3DEXPERIENCER2019x
                                ParametersLayoutViewUtilities.showContextualDeleteModal(widget.body, "delAttrModal", ParamSkeletonNLS.removeAttributesWarning, 
                                    ParamSkeletonNLS.RemoveElement, ParamSkeletonNLS.CancelButton, ParamSkeletonNLS.ConfirmDelete, AttrUtilsView.removeAttribueLine, objToBeRemoved);
                            }
                        }
                    });

                    return lineAttr;
                },
                //NZV - FUN085423
                showEditAttributeModel : function (userMessaging, that,lineAttr) {
                    var headertitle, modalbodyTable, tbodyreflist, attrLine, listofAddedAttrs,
                        AuthValsInput, typeNLen,
                        OKBtn, CancelBtn, checkResult, hasAuthVals,
                        sixwTagSelector, typesSelect, attrNameInput, attrDefValueInput,
                        currSelectedOpt, iDefaultValue, 
                        mandToggle, readonlyToggle, indexedToggle,
                        dateInput, dateSpan, iShortDate,
                        selected6wTag = '',
                        selected6wTagValue = '',
                        inputsArray = [],
                        dimensionsSelector, unitSelect,
                        export3DXMLToggle = false, revisionToggle = null, duplicateToggle = null,
                        trdimValues, trLine, trDim = "", trPreUnits = "", trhasAuthValues=false, trTypeNLen,
                        cellsIndex = this.cellsIndex, isLineModified = -1, i, j, authValuesStr = "";

                    UWA.log("showAddAttributesModal::");

                    if (that.editAttributesModal !== null) {
                        that.editAttributesModal.destroy();//Modal already exists
                    } 
                
                    headertitle = UWA.createElement('h4', {
                        text   : ParamSkeletonNLS.EditAttribute,
                        'class': 'font-3dslight' // font-3dsbold
                    });
                    
                    inputsArray        = AttrUtilsView.buildModalSkeleton(userMessaging);
                    modalbodyTable     = AttrUtilsView.getInputFromSkeleton(inputsArray, "modalbodyTable");
                    typesSelect        = AttrUtilsView.getInputFromSkeleton(inputsArray, "typesSelect");
                    attrNameInput      = AttrUtilsView.getInputFromSkeleton(inputsArray, "attrNameInput");
                    mandToggle         = AttrUtilsView.getInputFromSkeleton(inputsArray, "mandToggle");
                    readonlyToggle     = AttrUtilsView.getInputFromSkeleton(inputsArray, "readonlyToggle");
                    indexedToggle      = AttrUtilsView.getInputFromSkeleton(inputsArray, "indexedToggle");
                    sixwTagSelector    = AttrUtilsView.getInputFromSkeleton(inputsArray, "sixwTagAutoSelect");
                    AuthValsInput      = AttrUtilsView.getInputFromSkeleton(inputsArray, "AuthValsInput");
                    OKBtn              = AttrUtilsView.getInputFromSkeleton(inputsArray, "OKBtn");
                    CancelBtn          = AttrUtilsView.getInputFromSkeleton(inputsArray, "CancelBtn");
                    dimensionsSelector = AttrUtilsView.getInputFromSkeleton(inputsArray, "dimensionsSelect");
                    unitSelect         = AttrUtilsView.getInputFromSkeleton(inputsArray, "unitSelect");
                    export3DXMLToggle  = AttrUtilsView.getInputFromSkeleton(inputsArray, "export3DXMLToggle");
                    revisionToggle     = AttrUtilsView.getInputFromSkeleton(inputsArray, "revisionToggle");
                    duplicateToggle    = AttrUtilsView.getInputFromSkeleton(inputsArray, "duplicateToggle");
                    attrDefValueInput  = AttrUtilsView.getInputFromSkeleton(inputsArray, "attrDefValueInput");
                    //build line object from reading value from tr 
                    trdimValues = lineAttr.cells[cellsIndex.Dimension].value.split(",");
                       
                    if (trdimValues.length > 1) {
                        trDim = trdimValues[0];
                        trPreUnits = trdimValues[1];
                    } else {
                        trDim = trdimValues[0];
                    }
                    if(lineAttr.cells[cellsIndex.AuthValue].value != undefined && lineAttr.cells[cellsIndex.AuthValue].value !== "") {
                        trhasAuthValues = true;
                    }
                    trTypeNLen = AttrUtilsView.getSelectedTypeAndLength(lineAttr.cells[cellsIndex.TypeName].value);
                    trLine = {
                            nlsName          : lineAttr.cells[cellsIndex.AttributeName].value,
                            type             : trTypeNLen[0],
                            maxLength        : trTypeNLen[1],
                            defaultValue     : lineAttr.cells[cellsIndex.DefaultValue].value,
                            isMandatory      : lineAttr.cells[cellsIndex.Mandatory].value,
                            isExposedTo3DXML : lineAttr.cells[cellsIndex.Export3DXML].value,
                            resetWhenDuplicate : lineAttr.cells[cellsIndex.resetWhenDuplicate].value,
                            resetWhenRevision : lineAttr.cells[cellsIndex.resetWhenRevision].value,
                            isReadOnly       : lineAttr.cells[cellsIndex.ReadOnly].value,
                            isIndexed        : lineAttr.cells[cellsIndex.Indexed].value,//lineAttr.cells[cellsIndex.Indexed].childNodes[0].childNodes[0].checked,
                            hasAuthValues    : trhasAuthValues,
                            listofAuthValues : lineAttr.cells[cellsIndex.AuthValue].value,
                            SixWTag          : lineAttr.cells[cellsIndex.SixWTag].value,
                            dimension        : trDim,
                            preferredunit    : trPreUnits
                        }

                    //initilization from existing values 
                    typesSelect.select(String, true, false, false);
                    typesSelect.select(trLine.type, true, false, false);
                    

                    attrNameInput.setValue(trLine.nlsName);
                    attrNameInput.disable();

                    if(trLine.isMandatory === true) {
                        mandToggle.check();
                    } else {
                        mandToggle.uncheck();
                    }

                    if(trLine.isReadOnly === true) {
                        readonlyToggle.check();
                    } else {
                        readonlyToggle.uncheck();
                    } 

                    if(trLine.isIndexed === true) {
                        indexedToggle.check();
                    } else {
                        indexedToggle.uncheck();
                        sixwTagSelector.disable();
                    }

                    if(trLine.listofAuthValues !== "") {
                        AuthValsInput.setValue(trLine.listofAuthValues);
                    } else {
                        if (lineAttr.cells[cellsIndex.DeployStatus].value !== "NewNotDeployed") {
                            AuthValsInput.disable();
                        }
                    }
                    
                    if (trLine.type === 'Real') {
                        AttrUtilsView.buildDimensionsSelect(dimensionsSelector);
                        dimensionsSelector.select(trLine.dimension,true, false, false);
                        unitSelect.select(trLine.preferredunit,true, false, false);

                    } else {
                        unitSelect.disable();
                    }
                    dimensionsSelector.disable();

                    if(trLine.isExposedTo3DXML === true) {
                        export3DXMLToggle.check();
                    } else {
                        export3DXMLToggle.uncheck();
                    }

                    if(trLine.resetWhenRevision === true) {
                        revisionToggle.check();
                    } else {
                        revisionToggle.uncheck();
                    }

                    if(trLine.resetWhenDuplicate === true) {
                        duplicateToggle.check();
                    } else {
                        duplicateToggle.uncheck();
                    }
                    
                    if(trLine.type !== 'Date') {
                        this.attrDefValueInput.setValue(trLine.defaultValue);
                    } else {
                       if(trLine.defaultValue !== "") {
                            this.attrDefValueInput.dateInput.setDate(trLine.defaultValue);
                        } else {
                           
                            this.attrDefValueInput.dateCheckbox.setCheck(true);
                            this.attrDefValueInput.dateInput.setDate(null);
                            this.attrDefValueInput.dateInput.setValue(null);
                        }
                    }
                    if(trLine.SixWTag !== "") {
                        var ds6wLabel = ""
                        if (AttrUtilsView.listOf6Wpredicates !== null) {
                            ds6wLabel = AttrUtilsView.getMatching6wtagNLS(trLine.SixWTag, AttrUtilsView.listOf6Wpredicates);
                        }
                        sixwTagSelector.onSelect({value:trLine.SixWTag, label:ds6wLabel});
                    }
                   
                    typesSelect.disable();
                    
                    OKBtn.addEvent("onClick", function () {

                        var userSelectDimention = "", perferredUnit = "", attriLineAuthValues = trLine.listofAuthValues;

                        typeNLen = AttrUtilsView.getSelectedTypeAndLength(typesSelect.getSelection()[0].value);
                       // userSelectDimention = {};
                        if (typeNLen[0] === 'Boolean') {
                            attrDefValueInput = AttrUtilsView.getDefaultValueInput();
                            currSelectedOpt = attrDefValueInput.getSelection();
                            iDefaultValue = currSelectedOpt[0].value;
                        } else if (typeNLen[0] === 'Date') {
                            //ZUR IR-494192-3DEXPERIENCER2017x
                            dateSpan = AttrUtilsView.getDefaultValueInput();
                            dateInput = dateSpan.dateInput;
                            iShortDate = dateInput.getDate();
                            if (iShortDate !== null) {
                                iShortDate.setHours(11);//ZUR IR-502127-3DEXPERIENCER2018x
                                //toLocaleDateString
                                iDefaultValue = AttrUtilsView.getCATIACompatibleDateFromISOString(iShortDate.toISOString());
                            } else {
                                iDefaultValue = "";
                            }

                        } else if (typeNLen[0] === 'Real') {

                            if (dimensionsSelector.getSelection()[0].value !== '') {

                                userSelectDimention = dimensionsSelector.getSelection()[0].value;

                                if (unitSelect.getSelection()[0].value !== '') {
                                    perferredUnit = unitSelect.getSelection()[0].value;
                                }
                            }
                            iDefaultValue = AttrUtilsView.getDefaultValueInput().getValue();
                        } else {
                            iDefaultValue = AttrUtilsView.getDefaultValueInput().getValue();
                        }
                        listofAddedAttrs = AttrUtilsView.getNamesListofAlreadyAddedAttributes(that.contentDiv);

                        hasAuthVals = false;

                        if ((AuthValsInput.getValue() !== '') &&
                                (AuthValsInput.getValue() !== undefined)) {
                            hasAuthVals = true;
                            authValuesStr = AuthValsInput.getValue();

                        } else {
                            authValuesStr = "";
                        }


                        checkResult = AttrUtilsView.checkOptionsBeforeAddAttrs(typeNLen[0], typeNLen[1],
                            attrNameInput.getValue(), iDefaultValue,
                            readonlyToggle.isChecked(), mandToggle.isChecked(), hasAuthVals,
                            AuthValsInput.getValue(),
                            listofAddedAttrs, that.systemAttributes);
                            ////Extra validation for Authorzied Values not allow to remove any old value.                            
                            if (lineAttr.cells[cellsIndex.DeployStatus].value !== "NewNotDeployed") {
                                if(attriLineAuthValues !== "") {

                                    if(authValuesStr !== "") {
                                        var valueListTab = authValuesStr.split(',');
                                        var attriLineValuesLst = attriLineAuthValues.split(',');
                                        for(i = 0; i < valueListTab.length; i++ ) {
                                            for(j = 0; j < attriLineValuesLst.length; j++ ) {
                                                if(valueListTab[i] === attriLineValuesLst[j]) {
                                                    attriLineValuesLst.splice(j, 1);
                                                }
                                            }
                                        }
                                        if(attriLineValuesLst.length > 0 ) {
                                           //that.userMessaging.add({ className: "error", message: "Removal of existing Authorized value not allow, Only addition of new value allow!"});
                                           checkResult = "RemovalOfExistingValNotAllow";
                                        }
                                    }
                                }
                            }

                        if (!(checkResult === "S_OK" || checkResult === "AttibutesSameName")) {
                            UWA.log("checkResult = " + ParamSkeletonNLS[checkResult]);
                            that.userMessaging.add({ className: "error", message: ParamSkeletonNLS[checkResult]});

                            if ((checkResult === 'DefaultValueSizeInadequate') ||
                                    (checkResult === 'AccentsnotAllowedMsg') ||
                                      (checkResult === 'DefaultValueSizeInadequate')) {
                                AttrUtilsView.getDefaultValueInput().focus();
                            }

                        } else {

                            selected6wTag = '';
                            selected6wTagValue = '';

                            if (sixwTagSelector.selectedItems[0] != undefined) {
                                selected6wTag = sixwTagSelector.selectedItems[0].label;
                                selected6wTagValue = sixwTagSelector.selectedItems[0].value;
                            }

                            isLineModified =  AttrUtilsView.checkAndUpdateAttributeLine(lineAttr,typesSelect.getSelection()[0].value,
                                attrNameInput.getValue(), iDefaultValue,
                                mandToggle.isChecked(), readonlyToggle.isChecked(), export3DXMLToggle.isChecked(),
                                userSelectDimention, perferredUnit,
                                indexedToggle.isChecked(),
                                AuthValsInput.getValue(),
                                selected6wTagValue,
                                revisionToggle.isChecked(), duplicateToggle.isChecked(),that.wdthArray); 
                            if(isLineModified !== -1) {
                               if (lineAttr.cells[cellsIndex.DeployStatus].value !== "NewNotDeployed") {
                                    lineAttr.cells[cellsIndex.DeployStatus].empty();
                                    lineAttr.cells[cellsIndex.DeployStatus].value = "ModifiedNotDeployed";
                                    var imgSpan = ParametersLayoutViewUtilities.buildImgSpan('fonticon fonticon-pencil fonticon-1.5x', '1.5', 'orange');
                                    lineAttr.cells[cellsIndex.DeployStatus].title = ParamSkeletonNLS.ModifiedNotYetDeployed;
                                    imgSpan.inject(lineAttr.cells[cellsIndex.DeployStatus]);
                                }
                            }
                            that.editAttributesModal.hide();
                            that.editAttributesModal.destroy();
                            lineAttr.focus();
                        }

                    });

                    CancelBtn.addEvent("onClick", function (e) {
                        UWA.log(e);//that.onCancelCalled();
                        that.editAttributesModal.hide();
                        that.editAttributesModal.destroy();
                    });

                    that.editAttributesModal = new Modal({
                        className: 'add-attr-modal',
                        closable: true,
                        header  : headertitle,
                        body    : modalbodyTable,
                        footer  : [ OKBtn, CancelBtn ]
                    }).inject(that.contentDiv);

                    that.editAttributesModal.getContent().setStyle("padding-top", 10);
                    that.editAttributesModal.elements.wrapper.setStyle("width", 800);
                    that.editAttributesModal.show();
                
                },
                //NZV - FUN085423
                checkAndUpdateAttributeLine : function (lineAttr, type, attributeName, defaultValue, isMand, isReadOnly, is3DXMLExproted,
                                        dimension, preferredUnit, isIndexed, authValues, selected6wTagValue, 
                                        isRevision, isDup, wdthArray) {
                    var changeFound = -1,  cellsIndex = this.cellsIndex, defaultValuetoShow, defaultDateObj, defCellTitle="", iATpos;
                    if(lineAttr.cells[cellsIndex.AttributeName].value !== attributeName) {
                        changeFound = 1;
                        lineAttr.cells[cellsIndex.AttributeName].value = attributeName;
                    }

                    if(lineAttr.cells[cellsIndex.DefaultValue].value !== defaultValue) {
                        defaultValuetoShow = defaultValue;
                        if (type === "Date") {
                            defaultDateObj = new Date(defaultValue);
                            defCellTitle = defaultDateObj.toDateString();
                            iATpos = defaultValue.indexOf("@");
                            if (iATpos > 0) {
                                defaultValuetoShow  = defaultValue.substring(0, iATpos);
                            }
                        }                        

                        changeFound = 2;
                        lineAttr.cells[cellsIndex.DefaultValue].value = defaultValue;
                        lineAttr.cells[cellsIndex.DefaultValue].empty();
                        UWA.createElement('p', {
                            text   : defaultValuetoShow,
                            'class': 'font-3dslight'
                        }).inject(lineAttr.cells[cellsIndex.DefaultValue]);
                         //lineAttr.cells[cellsIndex.DefaultValue].title = defaultValue;
                    }

                    if(lineAttr.cells[cellsIndex.Mandatory].value !== isMand) {
                        changeFound = 3;
                        AttrUtilsView.checkAndModifiedToggle(lineAttr.cells[cellsIndex.Mandatory], isMand,  wdthArray[cellsIndex.Mandatory]);
                    }
                    if(lineAttr.cells[cellsIndex.Export3DXML].value !== is3DXMLExproted) {
                        changeFound = 4;
                        AttrUtilsView.checkAndModifiedToggle(lineAttr.cells[cellsIndex.Export3DXML], is3DXMLExproted,  wdthArray[cellsIndex.Export3DXML]);
                        
                    }
                    if(lineAttr.cells[cellsIndex.resetWhenDuplicate].value !== isDup) {
                        changeFound = 5;
                        AttrUtilsView.checkAndModifiedToggle(lineAttr.cells[cellsIndex.resetWhenDuplicate], isDup,  wdthArray[cellsIndex.resetWhenDuplicate]);
                        
                    }

                    if(lineAttr.cells[cellsIndex.resetWhenRevision].value !== isRevision) {
                        changeFound = 6;
                        AttrUtilsView.checkAndModifiedToggle(lineAttr.cells[cellsIndex.resetWhenRevision], isRevision,  wdthArray[cellsIndex.resetWhenRevision]);
                    }

                    if(lineAttr.cells[cellsIndex.ReadOnly].value !== isReadOnly) {
                        changeFound = 7;
                        AttrUtilsView.checkAndModifiedToggle(lineAttr.cells[cellsIndex.ReadOnly], isReadOnly,  wdthArray[cellsIndex.ReadOnly]);
                    }
                    if(lineAttr.cells[cellsIndex.Indexed].value !== isIndexed) {
                        changeFound = 8;
                        AttrUtilsView.checkAndModifiedToggle(lineAttr.cells[cellsIndex.Indexed], isIndexed,  wdthArray[cellsIndex.Indexed]);
                    }
                    
                    if(dimension !== "") {
                        if(lineAttr.cells[cellsIndex.Dimension].value !== undefined  &&  lineAttr.cells[cellsIndex.Dimension].value !== "")
                        {
                            var dimValues = lineAttr.cells[cellsIndex.Dimension].value.split(",");
                            var dimId, unitId, dimensionText ="";
                            if (dimValues.length > 1) {
                                dimId = dimValues[0];
                                unitId = dimValues[1];
                            } else {
                                dimId = dimValues[0];
                            }
                            if(unitId !== preferredUnit && dimId === dimension) {
                                changeFound = 9;
                                lineAttr.cells[cellsIndex.Dimension].empty();
                                lineAttr.cells[cellsIndex.Dimension].value = dimension+","+preferredUnit;

                                var dimPara = UWA.createElement('p', {
                                    text   : dimensionText,
                                    'class': 'font-3dslight'
                                }).inject(lineAttr.cells[cellsIndex.Dimension]);

                                /* dimensionText = */AttrUtilsView.getNLSDimensionStr(dimId, preferredUnit, dimPara);

                               
                                
                            }

                        }
                    }
                    // ilistofAuthValues = iLines[i].cells[cellsIndex.AuthValue].value;
                    if(lineAttr.cells[cellsIndex.AuthValue].value !== authValues && authValues !== undefined) {
                        changeFound = 10;
                        lineAttr.cells[cellsIndex.AuthValue].value = authValues;
                        lineAttr.cells[cellsIndex.AuthValue].empty();
                        UWA.createElement('p', {
                            text   : authValues,
                            'class': 'font-3dslight'
                        }).inject(lineAttr.cells[cellsIndex.AuthValue]);
                    }
                    if(lineAttr.cells[cellsIndex.SixWTag].value !== selected6wTagValue) {
                        changeFound = 11;
                        lineAttr.cells[cellsIndex.SixWTag].empty();
                        lineAttr.cells[cellsIndex.SixWTag].value = selected6wTagValue;
                        AttrUtilsView.update6WTagCellWithNLS(lineAttr.cells[cellsIndex.SixWTag], selected6wTagValue, "");
                    }

                    // if(changeFound !== -1) {
                    //     lineAttr.cells[cellsIndex.DeployStatus].empty();
                    //     lineAttr.cells[cellsIndex.DeployStatus].value = "ModifiedNotDeployed";
                    //     var imgSpan = ParametersLayoutViewUtilities.buildImgSpan('fonticon fonticon-pencil fonticon-1.5x', '1.5', 'orange');
                    //     lineAttr.cells[cellsIndex.DeployStatus].title = ParamSkeletonNLS.ModifiedNotYetDeployed;
                    //     imgSpan.inject(lineAttr.cells[cellsIndex.DeployStatus]);
                    // }

                    return changeFound;
                },

                checkAndModifiedToggle : function (cellElement, changedValue, width) {
                        cellElement.value = changedValue;
                        cellElement.empty();
                        if(changedValue === true) {
                            ParametersLayoutViewUtilities.buildImgCell('check', '1', 'green', changedValue, width + '%', 'center').inject(cellElement);                            
                        }
                }, 

                attributeLinetobeDeleted : function (iLine) {
                    var i, imgSpan,
                        cellsIndex = this.cellsIndex;

                    if (iLine.cells[cellsIndex.DeployStatus].value === "NewNotDeployed") {
                        iLine.remove();
                    } else {
                        for (i = 0; i < 3; i++) {
                            AttrUtilsView.setDeletedCellStyle(iLine.cells[i]);
                        }

                        AttrUtilsView.setDeletedCellStyle(iLine.cells[cellsIndex.AuthValue]);
                                               
                        iLine.cells[cellsIndex.SixWTag].empty();
                        iLine.cells[cellsIndex.Dimension].empty();
                        iLine.cells[cellsIndex.Action].empty();
                        //iLine.cells[9].setStyle("visibility", "hidden");//pas terrible

                        //iLine.cells[cellsIndex.DeployStatus].empty();
                       // iLine.cells[10].value = "DeletedNotDeployed";
                        iLine.cells[cellsIndex.DeployStatus].empty();
                        iLine.cells[cellsIndex.DeployStatus].value = "DeletedNotDeployed";
                        imgSpan = ParametersLayoutViewUtilities.buildImgSpan('trash', '1.5', 'red');
                        iLine.cells[cellsIndex.DeployStatus].title = ParamSkeletonNLS.DeletedButNotYetApplied; //NZV:IR-629593-3DEXPERIENCER2019x
                        imgSpan.inject(iLine.cells[cellsIndex.DeployStatus]);
                    }
                },

                removeAttribueLine : function (objToBeRemoved) {
                    objToBeRemoved.popOver.destroy();
                    AttrUtilsView.attributeLinetobeDeleted(objToBeRemoved.attrLine);
                },

                undeleteAttribute : function (iLine,that) {
                    var i, imgSpan,//editSpan, editPop, editAttributeButton,
                        deleteSpan, removeAttributeButton, removePop,
                        removelts = [],
                        cellsIndex = this.cellsIndex,attriList, deployedAttri, isLineModified = -1 ;

                    for (i = 0; i < 3; i++) {
                        AttrUtilsView.setNormalCellStyle(iLine.cells[i]);
                    }
                     AttrUtilsView.setNormalCellStyle(iLine.cells[cellsIndex.AuthValue]);
                    //that
                    attriList = that.collection._models[0]._attributes.listofAttributes;
                    deployedAttri = "";
                    for(i = 0; i < attriList.length; i++) {
                        if (attriList[i].nlsName === iLine.cells[cellsIndex.AttributeName].value) {
                            deployedAttri = attriList[i];
                            break;
                        }
                    }
                    isLineModified =  AttrUtilsView.checkAndUpdateAttributeLine(iLine, deployedAttri.type,
                                deployedAttri.nlsName, deployedAttri.defaultValue, deployedAttri.isMandatory, 
                                deployedAttri.isReadOnly, deployedAttri.isExposedTo3DXML, deployedAttri.dimension, 
                                deployedAttri.preferredunit, deployedAttri.isIndexed, deployedAttri.listofAuthValues,
                                deployedAttri.sixWTag, deployedAttri.resetWhenRevision, deployedAttri.resetWhenDuplicate,
                                that.wdthArray); 

                    //iLine.cells[9].setStyle("visibility", "block");

                    /*editElts = AttrUtilsView.createEditActionElements();
                    editSpan = editElts[0];
                    editSpan.inject(iLine.cells[8]);
                    editAttributeButton  = editElts[1];
                    editPop = editElts[2];*/

                    //NZV - FUN085423
                    if (iLine.cells[cellsIndex.DeployStatus].value !== "ModifiedNotDeployed") {
                        var editElts = ParametersLayoutViewUtilities.createActionElements(ParamSkeletonNLS.EditAttribute, false);
                        var editSpan = editElts[0];
                        editSpan.setStyle("float", "left");
                        editSpan.inject(iLine.cells[cellsIndex.Action]);
                        var editAttributeButton = editElts[1];
                        var editPop = editElts[2];

                        removelts = ParametersLayoutViewUtilities.createActionElements(ParamSkeletonNLS.DeleteAttributetxt, true);
                        deleteSpan = removelts[0];
                        deleteSpan.setStyle("float", "right");
                        deleteSpan.inject(iLine.cells[cellsIndex.Action]);
                        removeAttributeButton = removelts[1];
                        removePop = removelts[2];
                        // if(deployedAttri.isDeployed == true) {
                        //     iLine[i].cells[cellsIndex.DeployStatus].empty();
                        //     iLine[i].cells[cellsIndex.DeployStatus].value = "Deployed";
                        //     imgSpan = ParametersLayoutViewUtilities.buildImgSpan('check', '1.5', 'green');
                        //     iLine[i].cells[cellsIndex.DeployStatus].title = ParamSkeletonNLS.deployedParamtxt;
                        //  } else {
                        //     iLine.cells[cellsIndex.DeployStatus].empty();
                        //     iLine.cells[cellsIndex.DeployStatus].value = "StoredButNotDeployed";
                        //     imgSpan = ParametersLayoutViewUtilities.buildImgSpan('cog', '1.5', 'black');                        
                        // }

                       // imgSpan.inject(iLine.cells[cellsIndex.DeployStatus]);

                        removeAttributeButton.addEvent("onClick", function () {
                            /*removePop.destroy(); //removePop.remove();  //editPop.destroy();
                            AttrUtilsView.attributeLinetobeDeleted(iLine);*/
                            //AttrUtilsView.showContextualDeleteModal(widget.body, iLine, removePop);
                            var objToBeRemoved = {popOver : removePop, attrLine : iLine}; //IR-689657-3DEXPERIENCER2019x
                            ParametersLayoutViewUtilities.showContextualDeleteModal(widget.body, "delAttrModal", ParamSkeletonNLS.removeAttributesWarning, 
                                ParamSkeletonNLS.RemoveElement, ParamSkeletonNLS.CancelButton, ParamSkeletonNLS.ConfirmDelete, AttrUtilsView.removeAttribueLine, objToBeRemoved);
                        });

                        editAttributeButton.addEvent("onClick", function () {
                          
                           AttrUtilsView.showEditAttributeModel(that.userMessaging,that,iLine);
                            
                        });
                    }
                    iLine.cells[cellsIndex.DeployStatus].empty();
                    iLine.cells[cellsIndex.DeployStatus].value = "Deployed";
                    imgSpan = ParametersLayoutViewUtilities.buildImgSpan('check', '1.5', 'green');
                    iLine.cells[cellsIndex.DeployStatus].title = ParamSkeletonNLS.deployedParamtxt;
                    imgSpan.inject(iLine.cells[cellsIndex.DeployStatus]); 
                },

                setDeletedCellStyle : function (iCell) {
                    var previousVal = iCell.value, showValue = previousVal,iATpos;
                    iCell.empty();
                    iATpos = previousVal.indexOf("@");
                    if (iATpos > 0) {
                        showValue  = previousVal.substring(0, iATpos);
                    }
                    UWA.createElement('del', {
                        text   : showValue,
                        value  : previousVal,//ZUR - IR-497281-3DEXPERIENCER2017x
                        'class': 'font-3dslight'
                    }).inject(iCell);
                },

                setNormalCellStyle : function (iCell) {
                    var previousVal = iCell.value, showValue = previousVal,iATpos;
                    iCell.empty();
                    iATpos = previousVal.indexOf("@");
                    if (iATpos > 0) {
                        showValue  = previousVal.substring(0, iATpos);
                    }
                    UWA.createElement('p', {
                        text   : showValue,
                        value  : previousVal,//ZUR - IR-497281-3DEXPERIENCER2017x
                        'class': 'font-3dslight'
                    }).inject(iCell);
                },

                /*createEditActionElements : function () {
                    var editPop,
                        editElts = [],
                        editSpan = UWA.createElement('span'),
                        editAttributeButton = new Button({
                            className: 'close',
                            icon: 'fonticon fonticon-pencil fonticon-1.5x',//value: 'Button', //fonticon-cancel  fonticon-minus-circled    
                            attributes: {
                                disabled: false,
                                'aria-hidden' : 'true'
                                //title : 'delete attribute'
                            }
                        }).inject(editSpan);

                    editPop = new Popover({
                        //class: 'parampopover',
                        target: editSpan,//iCell,
                        trigger : "hover",
                        animate: "true",
                        position: "top",
                        body: 'Edit attribute',
                        title: ''//iParamObj.nlsKey
                    });

                    editElts.push(editSpan);
                    editElts.push(editAttributeButton);
                    editElts.push(editPop);

                    return editElts;
                },*/

                checkIfAttrNameAlreadyUsed : function (attrUserName, listofAddedAttrs) {
                    var i;
                    for (i = 0; i < listofAddedAttrs.length; i++) {
                        if (attrUserName.replace(/ /g, "_") ===  listofAddedAttrs[i].replace(/ /g, "_")) {
                            return true;
                        }
                    }
                    return false;
                },

                checkOptionsBeforeAddAttrs : function (attrType, attrLength, attrUserName, attrValue,
                    isReadOnly, isMandatory, hasAuthValues, authValuesStr, listofAddedAttrs, allMatrixAttributesnames) {

                    var i,
                        valueListTab = [],
                        AdditionalSpecialChars = "-.",
                        defaultInAuthorized = false;

                    if (attrUserName === "") {
                        UWA.log(ParamSkeletonNLS.NoAttributeName);
                        return "NoAttributeName";
                    }
                    if (!isNaN(attrUserName.charAt(0))) {
                        UWA.log(ParamSkeletonNLS.AttributeNameFirstCharNumber);
                        return "AttributeNameFirstCharNumber";
                    }
                    /*if (ParametersLayoutViewUtilities.containsBlanks(attrUserName)) {
                        return "AttributeNameContainsSpace";
                    }*/

                    if (ParametersLayoutViewUtilities.containsAccents(attrUserName)) {
                        return "AccentsnotAllowedInNameMsg";
                    }

                    if (isMandatory && attrValue === "") {
                        UWA.log(ParamSkeletonNLS.AttrMandMustHaveDefVal);
                        return "AttrMandMustHaveDefVal";
                    }

                    /* NZV : REACTIVATE for IR-540216-3DEXPERIENCER2018x */
                    if (allMatrixAttributesnames !== undefined) {
                        for (i = 0; i < allMatrixAttributesnames.length; i++) {
                            if (attrUserName === allMatrixAttributesnames[i]) {
                                UWA.log(ParamSkeletonNLS.DefaultPartNameMsg);
                                return "DefaultPartNameMsg";
                            }
                        }
                    }

                    if (AttrUtilsView.testStrictSpecialCharacters(attrUserName)) {
                        UWA.log(ParamSkeletonNLS.SpecialCharactersMsg);
                        return "SpecialCharactersMsg";
                    }

                    if (attrType !== 'Date') {
                        if (AttrUtilsView.testStrictSpecialCharacters(attrValue)) {
                            UWA.log(ParamSkeletonNLS.SpecialCharactersMsg);
                            return "SpecialCharactersMsg";
                        }
                    }

                    if (AttrUtilsView.testStrictSpecialCharacters(attrUserName, AdditionalSpecialChars)) {
                        UWA.log(ParamSkeletonNLS.SpecialCharactersMsg);
                        return "SpecialCharactersMsg";
                    }

                    if (attrType !== 'Real' && attrType !== 'Integer' && attrType !== 'Date') {
                        if (AttrUtilsView.testStrictSpecialCharacters(attrValue, AdditionalSpecialChars)) {
                            UWA.log(ParamSkeletonNLS.SpecialCharactersMsg);
                            return "SpecialCharactersMsg";
                        }
                    }

                    if ((authValuesStr !== "") && (attrType !== 'Boolean')) {
                        valueListTab = authValuesStr.split(',');
                        for (i = 0; i < valueListTab.length; i++) {
                            if (AttrUtilsView.testStrictSpecialCharacters(valueListTab[i])) {
                                UWA.log(ParamSkeletonNLS.SpecialCharactersMsgAuthVals);
                                return "SpecialCharactersMsgAuthVals";
                            }
                        }
                    }

                    if (ParametersLayoutViewUtilities.containsAccents(attrValue)) {
                        UWA.log(ParamSkeletonNLS.AccentsnotAllowedMsg);
                        return "AccentsnotAllowedMsg";
                    }

                    if ((authValuesStr !== "") && (attrType !== 'Boolean')) {
                        for (i = 0; i < valueListTab.length; i++) {
                            if (ParametersLayoutViewUtilities.containsAccents(valueListTab[i])) {
                                UWA.log(ParamSkeletonNLS.AccentsnotAllowedMsgAuthVals);
                                return "AccentsnotAllowedMsgAuthVals";
                            }
                        }
                    }

                    if ((attrType === 'String') && (attrLength !== 0)) {
                        if (attrValue.length > attrLength) {
                            UWA.log(ParamSkeletonNLS.DefaultValueSizeInadequate);
                            return "DefaultValueSizeInadequate";
                        }

                        if (authValuesStr !== "") {
                            for (i = 0; i < valueListTab.length; i++) {
                                if (valueListTab[i].length > attrLength) {
                                    UWA.log(ParamSkeletonNLS.ProposedValueSizeInadequate);
                                    return "ProposedValueSizeInadequate";
                                }
                            }
                        }
                    }

                    if (attrType === 'Real') {
                        if (!ParametersLayoutViewUtilities.isReal(attrValue)) {
                            UWA.log(ParamSkeletonNLS.DefaultValueNumeric);
                            return "DefaultValueNumeric";
                        }

                        if (authValuesStr !== "") {
                            for (i = 0; i < valueListTab.length; i++) {
                                if (!ParametersLayoutViewUtilities.isReal(valueListTab[i])) {
                                    UWA.log(ParamSkeletonNLS.AuthValsNonNumericMessage);
                                    return "AuthValsNonNumericMessage";
                                }
                            }
                        }
                    } else if (attrType === 'Integer' && attrValue.trim() !== "") {
                        if (!ParametersLayoutViewUtilities.isInteger(attrValue)) {
                            UWA.log(ParamSkeletonNLS.DefaultValueNumericForInt);
                            return "DefaultValueNumericForInt";
                        }
                        if (authValuesStr !== "") {
                            for (i = 0; i < valueListTab.length; i++) {
                                if (!ParametersLayoutViewUtilities.isInteger(valueListTab[i])) {
                                    UWA.log(ParamSkeletonNLS.AuthValsNonNumericForIntMsg);
                                    return "AuthValsNonNumericForIntMsg";
                                }
                            }
                        }
                    }

                    if (hasAuthValues && (attrType !== 'Boolean')) {
                        if (authValuesStr !== "") {
                            for (i = 0; i < valueListTab.length; i++) {
                                if (valueListTab[i] === attrValue) {
                                    defaultInAuthorized = true;
                                    break;
                                }
                            }
                        }
                        if (!defaultInAuthorized) {
                            UWA.log(ParamSkeletonNLS.DefaultNotInAuthValsMsg);
                            return "DefaultNotInAuthValsMsg";
                        }
                    }
                    //NZV - FUN085423
                    if (AttrUtilsView.checkIfAttrNameAlreadyUsed(attrUserName, listofAddedAttrs)) {
                        UWA.log(ParamSkeletonNLS.AttibutesSameName);
                        return "AttibutesSameName";
                    }
                    return "S_OK";

                    /*addAttributeRow(type, ..., sixWTagNLS, 0, false, false);
                    manageHelpAuthValues();
                    setCurrentReadOnlyStatus(defaultReadOnly);
                    setCurrentMandatoryStatus(defaultMandatory);
                    setCurrentIndexedStatus(defaultIndexed);
                    clearSixWTag();*/
                },

                buildAutoComplete : function () {
                    var sixwTagAutoSelect = new Autocomplete({
                            multiSelect: false,
                            showSuggestsOnFocus: true,
                            filterEngine: function (suggestions) { 
                                return suggestions;
                            },
                            events: {//IR-673291-3DEXPERIENCER2019x\20x
                                onKeyDown: function(e) {
                                    if (e.keyCode === 13) {
                                        e.preventDefault();
                                    }
                                },
                                onKeyUp: function(e) {
                                    if (e.keyCode === 13) {
                                        sixwTagAutoSelect.showAll();
                                    }
                                },
                                onUnselect : function (item) {
                                    sixwTagAutoSelect.showAll();
                                    return item;
                                }
                            }
                        });
                    return sixwTagAutoSelect;
                },

                buildModalSkeleton : function (userMessaging) {
                    var modalbodyTable, modaltbody, lineModal, errorMsg,
                        iCell, AuthValsInput, timerconn, diffDate,
                        typesSelect, attrNameInput, iDefaultControlCell,
                        mandToggle, readonlyToggle, indexedToggle, export3DXMLToggle,// AuthValsToggle,
                        //imgInfoSpan, popoverAuth,
                        OKBtn, CancelBtn, unitsSelector, /*dimensionsSelector*/
                        currTime = new Date().getTime(),
                        lastMessageDate = currTime,
                        activateError = false,
                        col1Wdth = '50%', col2Wdth = '50%',
                        typeNLen = [], modalSkeleton = [], typeNLenDim = [],
                        that = this, duplicateToggle, revisionToggle, sixwTagAutoSelect;

                    that.initCells();
                    modalbodyTable =  UWA.createElement('table', {
                        'id': '',
                        'class': 'table table-condensed table-hover'
                    });
                    modaltbody = UWA.createElement('tbody', {
                        'class': ''
                    }).inject(modalbodyTable);

                    lineModal = UWA.createElement('tr').inject(modaltbody);
                    iCell = AttrUtilsView.buildNLSText(ParamSkeletonNLS.AttributeTypeNLenth, col1Wdth, '');
                    iCell.inject(lineModal);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : col2Wdth
                    }).inject(lineModal);

                    typesSelect = AttrUtilsView.buildTypeSelect();
                    typesSelect.inject(iCell);

                    lineModal = UWA.createElement('tr').inject(modaltbody);
                    iCell = AttrUtilsView.buildNLSText(ParamSkeletonNLS.AttributeName, col1Wdth, '');
                    iCell.inject(lineModal);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : col2Wdth
                    }).inject(lineModal);

                    attrNameInput = new Text({
                        //className: "form-control",
                        placeholder: "...",
                        id : 'attrNameInput',
                        attributes: {
                            value: '',
                            multiline: false,
                            disabled: false
                        }
                    }).inject(iCell);

                    lineModal = UWA.createElement('tr').inject(modaltbody);
                    iCell = AttrUtilsView.buildNLSText(ParamSkeletonNLS.AttributeDefaultValue, col1Wdth, '');
                    iCell.inject(lineModal);


                    iDefaultControlCell = UWA.createElement('td', {
                        'id'    : 'iDefaultControlCell',
                        'Align' : 'left',
                        'width' : col2Wdth
                    }).inject(lineModal);

                    this.attrDefValueInput = AttrUtilsView.buildTextDefault(userMessaging);
                    this.attrDefValueInput.inject(iDefaultControlCell);

                     // Dimensions 
                    lineModal = UWA.createElement('tr').inject(modaltbody);
                    this.dimensionToolTipCell = AttrUtilsView.buildNLSText(ParamSkeletonNLS.Dimensions, col1Wdth, ParamSkeletonNLS.DimensionsToolTip);

                    this.dimensionToolTipCell.inject(lineModal);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : col2Wdth
                    }).inject(lineModal);
                    this.dimensionsSelector = new Select({
                        nativeSelect: true,
                        placeholder: ParamSkeletonNLS.DimensionsSelect,
                        multiple: false
                    });
                    this.dimensionsSelector.disable();
                    this.dimensionsSelector.inject(iCell);
                     //End Dimensions
                    //Add unit combo..
                    lineModal = UWA.createElement('tr').inject(modaltbody);
                    iCell = AttrUtilsView.buildNLSText(ParamSkeletonNLS.PreUnits, col1Wdth, ParamSkeletonNLS.PreferredUnitToolTip);
                    iCell.inject(lineModal);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : col2Wdth
                    }).inject(lineModal);
                    unitsSelector = new Select({
                        nativeSelect: true,
                        placeholder: ParamSkeletonNLS.PreUnitsSelect,
                        multiple: false
                    });

                    unitsSelector.disable();
                    unitsSelector.inject(iCell);
                     //End Unit combo

                     // 3DXML Export
                    lineModal = UWA.createElement('tr').inject(modaltbody);
                    iCell = AttrUtilsView.buildNLSText(ParamSkeletonNLS.ExportIn3DXML, col1Wdth, ParamSkeletonNLS.ExportIn3DXMLToolTip);
                    iCell.inject(lineModal);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : col2Wdth
                    }).inject(lineModal);

                    export3DXMLToggle = new Toggle({
                        type: 'switch',//value: 'option1',                        
                        label: ''
                    }).uncheck().inject(iCell);
                     //3DXML Export
                    //Duplicate/Clone
                    lineModal = UWA.createElement('tr').inject(modaltbody);
                    iCell = AttrUtilsView.buildNLSText(ParamSkeletonNLS.ResetOnDuplicate, col1Wdth, ParamSkeletonNLS.ResetOnDuplicateToolTip);
                    iCell.inject(lineModal);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : col2Wdth
                    }).inject(lineModal);

                    duplicateToggle = new Toggle({
                        type: 'switch',//value: 'option1',                        
                        label: ''
                    }).uncheck().inject(iCell);
                    //End duplicate
                     //Revision 
                    lineModal = UWA.createElement('tr').inject(modaltbody);
                    iCell = AttrUtilsView.buildNLSText(ParamSkeletonNLS.ResetOnRevision, col1Wdth, ParamSkeletonNLS.ResetOnRevisionToolTip);
                    iCell.inject(lineModal);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : col2Wdth
                    }).inject(lineModal);

                    revisionToggle = new Toggle({
                        type: 'switch',//value: 'option1',                        
                        label: ''
                    }).uncheck().inject(iCell);
                    //End - Revision
                    lineModal = UWA.createElement('tr').inject(modaltbody);
                    iCell = AttrUtilsView.buildNLSText(ParamSkeletonNLS.MandatoryAttributeTitle, col1Wdth, '');
                    iCell.inject(lineModal);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : col2Wdth
                    }).inject(lineModal);

                    mandToggle = new Toggle({
                        type: 'switch',//value: 'option1',                        
                        label: ''
                    }).uncheck().inject(iCell);

                    lineModal = UWA.createElement('tr').inject(modaltbody);
                    iCell = AttrUtilsView.buildNLSText(ParamSkeletonNLS.ReadOnlyAttributeTitle, col1Wdth, ParamSkeletonNLS.ReadOnlyAttrTooltip);
                    iCell.inject(lineModal);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : col2Wdth
                    }).inject(lineModal);

                    readonlyToggle = new Toggle({
                        type: 'switch',
                        label: ''
                    }).uncheck().inject(iCell);

                    lineModal = UWA.createElement('tr').inject(modaltbody);
                    iCell = AttrUtilsView.buildNLSText(ParamSkeletonNLS.IndexedAttributeTitle, col1Wdth, ParamSkeletonNLS.AttributeIndexedTooltip);
                    iCell.inject(lineModal);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : col2Wdth
                    }).inject(lineModal);

                    indexedToggle = new Toggle({
                        type: 'switch',
                        label: ''
                    }).check().inject(iCell);

                    lineModal = UWA.createElement('tr').inject(modaltbody);
                    lineModal.inject(modaltbody);
                    iCell = AttrUtilsView.buildNLSText(ParamSkeletonNLS.AuthorizedValsTitle, col1Wdth, ParamSkeletonNLS.AuthorizedValuesTooltip);
                    iCell.inject(lineModal);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : col2Wdth
                    }).inject(lineModal);

                    AuthValsInput = new Text({
                        //className: "form-control",
                        placeholder: "...",
                        id : 'AuthValsInput',
                        disabled: false,
                        attributes: {
                            value: '',
                            multiline: false
                        }
                    }).inject(iCell);

                    lineModal = UWA.createElement('tr').inject(modaltbody);
                    iCell = AttrUtilsView.buildNLSText(ParamSkeletonNLS.Select6WPredicateTxt, col1Wdth, '');
                    iCell.inject(lineModal);

                    iCell = UWA.createElement('td', {
                        'Align' : 'left',
                        'width' : col2Wdth
                    }).inject(lineModal);

                    sixwTagAutoSelect = this.buildAutoComplete().inject(iCell);

                    this.fetchAndPopulate6WPredicates(sixwTagAutoSelect, 'String');

                    OKBtn = new Button({
                        value : ParamSkeletonNLS.OKButton,
                        id    : "modalOKButton",
                        className : 'btn primary'
                    });

                    CancelBtn = new Button({
                        value : ParamSkeletonNLS.CancelButton,
                        id    : 'modalCancelButton',
                        className : 'btn default'
                    });

                    attrNameInput.addEvent("onKeyDown", function () {
                        if (timerconn) { clearTimeout(timerconn); }
                        timerconn = setTimeout(function() {
                            activateError = false;
                            if (AttrUtilsView.testStrictSpecialCharacters(attrNameInput.getValue())) {
                                activateError = true;
                                errorMsg = ParamSkeletonNLS.SpecialCharactersMsg;
                            } else if (ParametersLayoutViewUtilities.containsAccents(attrNameInput.getValue())) {
                                activateError = true;
                                errorMsg = ParamSkeletonNLS.AccentsnotAllowedInNameMsg;
                            }

                            /*else if (ParametersLayoutViewUtilities.containsBlanks(attrNameInput.getValue())) {
                                activateError = true;
                                errorMsg = ParamSkeletonNLS.AttributeNameContainsSpace;
                            } */

                            if (activateError === true) {
                                currTime = new Date().getTime();
                                diffDate = currTime - lastMessageDate;
                                if (diffDate > 1500) {
                                    userMessaging.add({ className: "error", message: errorMsg});
                                    lastMessageDate = new Date().getTime();
                                }
                                attrNameInput.elements.input.setStyle('color', 'red');
                                attrNameInput.focus();
                            } else {
                                attrNameInput.elements.input.setStyle('color', '#555555');
                            }
                        }, 20);
                    });

                    this.dimensionsSelector.addEvent("onChange", function () {
                        typeNLenDim = AttrUtilsView.getSelectedTypeAndLength(typesSelect.getSelection()[0].value);
                        if (typeNLenDim[0] === 'Real' && this.getValue()[0] !== "") {
                            AuthValsInput.disable();//ZUR - IR-558248-3DEXPERIENCER2018x 
                            AuthValsInput.setValue('');
                        } else if (typeNLenDim[0] === 'Real' && this.getValue()[0] === "") {
                            AuthValsInput.enable();//ZUR - IR-558248-3DEXPERIENCER2018x 
                            AuthValsInput.setValue('');
                        }
                        AttrUtilsView.buildPreUnitsSelect(this, unitsSelector);
                    });

                    typesSelect.addEvent("onChange", function () {
                        typeNLen = AttrUtilsView.getSelectedTypeAndLength(this.getSelection()[0].value);
                        //AttrUtilsView.FilterPredicatesListbyType(typeNLen[0], AttrUtilsView.processed6WList, sixwTagSelector);//IR-514503-3DEXPERIENCER2017x/18x
                        AttrUtilsView.fetchAndPopulate6WPredicates(sixwTagAutoSelect, typeNLen[0]);
                        iDefaultControlCell.childNodes[0].destroy();

                        if (typeNLen[0] === 'Boolean') {
                            that.attrDefValueInput = AttrUtilsView.buildBooleanDefault();
                            AuthValsInput.disable();
                            AuthValsInput.setValue(ParamSkeletonNLS.TrueLabel + ',' + ParamSkeletonNLS.FalseLabel);
                            that.dimensionsSelector.clear();
                            that.dimensionsSelector.disable();
                            AttrUtilsView.buildToolTipForDimension(AttrUtilsView.dimensionToolTipCell, ParamSkeletonNLS.DimensionsToolTip, "black");
                            unitsSelector.clear();
                            unitsSelector.disable();
                        } else if ((typeNLen[0] === 'String') || (typeNLen[0] === 'Integer')) {
                            that.attrDefValueInput = AttrUtilsView.buildTextDefault(userMessaging);
                            AuthValsInput.enable();
                            AuthValsInput.setValue('');
                            that.dimensionsSelector.clear();
                            that.dimensionsSelector.disable();
                            AttrUtilsView.buildToolTipForDimension(AttrUtilsView.dimensionToolTipCell, ParamSkeletonNLS.DimensionsToolTip, "black");
                            unitsSelector.clear();
                            unitsSelector.disable();
                        } else if (typeNLen[0] === 'Date') {
                            that.attrDefValueInput = AttrUtilsView.buildDateDefault();
                            AuthValsInput.disable();
                            AuthValsInput.setValue('');
                            that.dimensionsSelector.clear();
                            that.dimensionsSelector.disable();
                            AttrUtilsView.buildToolTipForDimension(AttrUtilsView.dimensionToolTipCell, ParamSkeletonNLS.DimensionsToolTip, "black");
                            unitsSelector.clear();
                            unitsSelector.disable();
                        } else if (typeNLen[0] === 'Real') {
                            that.attrDefValueInput = AttrUtilsView.buildTextDefault(userMessaging);
                            AuthValsInput.enable();
                            AuthValsInput.setValue('');
                            AttrUtilsView.buildDimensionsSelect(that.dimensionsSelector);
                        }
                        that.attrDefValueInput.inject(iDefaultControlCell);
                    });

                    indexedToggle.addEvent("onChange", function () {
                        if (this.isChecked()) {
                            sixwTagAutoSelect.enable();
                        } else {
                            if (sixwTagAutoSelect.selectedItems[0] !== undefined) {
                                sixwTagAutoSelect.onUnselect(sixwTagAutoSelect.selectedItems[0]);
                            }
                            //sixwTagAutoSelect.clear();
                            sixwTagAutoSelect.disable();
                        }
                    });
                    //AttrUtilsView.FilterPredicatesListbyType('String', this.processed6WList, sixwTagSelector);//IR-514503-3DEXPERIENCER2017x/18x


                    modalSkeleton.push({id: 'typesSelect', obj: typesSelect });
                    modalSkeleton.push({id: 'attrNameInput', obj: attrNameInput });
                    modalSkeleton.push({id: 'dimensionsSelect', obj: AttrUtilsView.dimensionsSelector });
                    modalSkeleton.push({id: 'unitSelect', obj: unitsSelector });
                    modalSkeleton.push({id: 'export3DXMLToggle', obj: export3DXMLToggle });
                    modalSkeleton.push({id: 'mandToggle', obj: mandToggle });
                    modalSkeleton.push({id: 'revisionToggle', obj: revisionToggle });
                    modalSkeleton.push({id: 'duplicateToggle', obj: duplicateToggle });
                    modalSkeleton.push({id: 'readonlyToggle', obj: readonlyToggle });
                    modalSkeleton.push({id: 'indexedToggle', obj: indexedToggle });
                    modalSkeleton.push({id: 'AuthValsInput', obj: AuthValsInput });
                    modalSkeleton.push({id: 'sixwTagAutoSelect', obj: sixwTagAutoSelect });
                    modalSkeleton.push({id: 'modalbodyTable', obj: modalbodyTable });
                    modalSkeleton.push({id: 'OKBtn', obj: OKBtn });
                    modalSkeleton.push({id: 'CancelBtn', obj: CancelBtn });
                    modalSkeleton.push({id: 'attrDefValueInput', obj: this.attrDefValueInput });
                    
                    return modalSkeleton;
                },

                getInputFromSkeleton : function (modalSkeleton, inputID) {
                    var i;
                    for (i = 0; i < modalSkeleton.length; i++) {
                        if (modalSkeleton[i].id === inputID) {
                            return modalSkeleton[i].obj;
                        }
                    }
                },

                getSelectedTypeAndLength : function (selectedVal) {
                    var outArray = [],
                        iStringIndex = selectedVal.indexOf('String');
                        //selectedVal = currentSelectedOption[0].value,                        

                    if (iStringIndex >= 0) {
                        outArray.push('String');

                        if (selectedVal === 'String') {
                            outArray.push(0);
                        } else {
                            outArray.push(parseInt(selectedVal.substring(6), 10));//10 : radix parameter
                        }
                    } else {
                        outArray.push(selectedVal);
                        outArray.push(0);
                    }
                    return outArray;
                },

                getCurrentAttributesList : function(iContentDiv) {
                    var typeNLenArr, i, ilistofAuthValues,
                        tbodyreflist = iContentDiv.getElements('.attrstbody'),
                        iLines = tbodyreflist[0].childNodes,
                        nbofLines = iLines.length,
                        ilistofAttributes = [], dimValues = [], dimId = "", unitId = "",
                        ihasAuthValues = false,
                        cellsIndex = this.cellsIndex;

                    for (i = 1; i < nbofLines; i++) {

                        if (iLines[i].cells[cellsIndex.DeployStatus].value !== "DeletedNotDeployed") {

                            typeNLenArr = AttrUtilsView.getSelectedTypeAndLength(iLines[i].cells[cellsIndex.TypeName].value);

                            ihasAuthValues = false;
                            ilistofAuthValues = '';
                            if ((iLines[i].cells[cellsIndex.AuthValue].value !== '') &&
                                    (iLines[i].cells[cellsIndex.AuthValue].value !== undefined)) {
                                ihasAuthValues = true;
                                ilistofAuthValues = iLines[i].cells[cellsIndex.AuthValue].value;
                            }
                            if ((iLines[i].cells[cellsIndex.Dimension].value !== '') &&
                                    (iLines[i].cells[cellsIndex.Dimension].value !== undefined)) {
                                dimValues = iLines[i].cells[cellsIndex.Dimension].value.split(",");
                                if (dimValues.length > 1) {
                                    dimId = dimValues[0];
                                    unitId = dimValues[1];
                                } else {
                                    dimId = dimValues[0];
                                }
                            }
                            ilistofAttributes.push({
                                //id Not Needed
                                nlsName          : iLines[i].cells[cellsIndex.AttributeName].value,
                                type             : typeNLenArr[0],
                                maxLength        : typeNLenArr[1],
                                defaultValue     : iLines[i].cells[cellsIndex.DefaultValue].value,
                                isMandatory      : iLines[i].cells[cellsIndex.Mandatory].value,
                                isExposedTo3DXML : iLines[i].cells[cellsIndex.Export3DXML].value,
                                resetWhenDuplicate : iLines[i].cells[cellsIndex.resetWhenDuplicate].value,
                                resetWhenRevision : iLines[i].cells[cellsIndex.resetWhenRevision].value,
                                isReadOnly       : iLines[i].cells[cellsIndex.ReadOnly].value,
                                isIndexed        : iLines[i].cells[cellsIndex.Indexed].value,
                                hasAuthValues    : ihasAuthValues,
                                listofAuthValues : ilistofAuthValues,
                                SixWTag          : iLines[i].cells[cellsIndex.SixWTag].value,
                                dimension        : dimId,
                                preferredunit    : unitId
                            });
                        }
                    }
                    return ilistofAttributes;
                },

                getNamesListofAlreadyAddedAttributes : function (contentDiv) {
                    var i,
                        tbodyreflist = contentDiv.getElements('.attrstbody'),
                        iLines = tbodyreflist[0].childNodes,
                        listofUserNames = [];

                    for (i = 1; i < iLines.length; i++) {
                        listofUserNames.push(iLines[i].cells[this.cellsIndex.AttributeName].childNodes[0].value);
                    }

                    return listofUserNames;
                },

                getMatching6wtagNLS : function (isixWID, itagslist) {
                    var i, predicatesList, propt;
                    for (propt in itagslist) {
                        if (itagslist[propt].properties.length > 0) {
                            predicatesList = itagslist[propt].properties;                           
                            if (predicatesList !== undefined && predicatesList.length > 0) {
                                for (i = 0; i < predicatesList.length; i++) {
                                    if (predicatesList[i].curi ===  isixWID) {
                                        return predicatesList[i].label;
                                    }
                                }
                            }
                        }
                    }
                    UWA.log("getMatching6wtagNLS::Warning, no matching has been found, returning the ID");
                    return isixWID;
                },

                getCATIACompatibleDateFromISOString : function(iISOString) {
                    //2017-01-16T18:32:22.382Z to 2017/01/24@11:00:00:GMT
                    var CATIADate, tPlace = 0;

                    iISOString = iISOString.replace('-', '/');
                    iISOString = iISOString.replace('-', '/');

                    tPlace = iISOString.indexOf('T');
                    CATIADate = iISOString.substring(0, tPlace) + "@11:00:00:GMT";
                    return CATIADate;
                },
                //IR-514503-3DEXPERIENCER2017x/18x
                FilterPredicatesListbyType : function (attrType, listofsixWTags, sixwTagSelector) {
                    var dataItems, newObject, predicatesList, propt;
                    dataItems = {name : "Avaliable_ds6w_tag", items: []};
                    sixwTagSelector.removeDataset(dataItems.name);
                    for (propt in listofsixWTags) {

                        if (listofsixWTags[propt].properties.length > 0) {
                            newObject = {'label' : listofsixWTags[propt].label, 'items': []};
                            predicatesList = listofsixWTags[propt].properties;

                            if (predicatesList !== undefined && predicatesList.length > 0) {
                                predicatesList.forEach(function (item) {
                                    if (AttrUtilsView.PredicateDataTypeAttributeMatch(item.dataType, attrType) === true) {
                                        newObject.items.push({
                                            value : item.curi,
                                            label : item.label
                                        });
                                    }
                                });
                                
                                if (newObject.items.length > 0) {
                                    //sorting 
                                    newObject.items.sort(function (tagOne, tagTwo) {
                                        if (tagOne.label !== undefined && tagTwo.label !== undefined) {
                                            return tagOne.label.localeCompare(tagTwo.label);
                                        }
                                        return false; 
                                    });
                                    dataItems.items.push(newObject);
                                }
                            }
                        }
                    }
                    sixwTagSelector.addDataset(dataItems);
                },
                //IR-514503-3DEXPERIENCER2017x/18x
                PredicateDataTypeAttributeMatch : function (iDataType, iAttributeType) {
                    if (iDataType.toUpperCase().indexOf(iAttributeType.toUpperCase()) >= 0) {
                        return true;//string/String(s), integer/Interger, boolean/Boolean, dateTime/Date
                    }
                   // if ((iDataType === "double") && (iAttributeType === "Real")) 
                    if ((iDataType.toUpperCase().indexOf("DOUBLE") >= 0) && (iAttributeType === "Real")) {
                        return true;
                    }
                    return false;
                },

                /*testStrictSpecialCharacters : function (attrName) {
                    var regS = /^[0-9a-zA-Z\s_]+$/; //A to Z , 0 to 9, underscores and spaces 
                    //var regM = "[A-Za-z0-9_][A-Za-z0-9_\\ -:/]+"; 
                    if (!regS.test(attrName)) {
                        return true;
                    }
                    return false;
                },

                testStrictSpecialCharacters : function(strtoTest) {
                    return (/^[\w\-\.\s]+$/).test(strtoTest);
                },*/

                testStrictSpecialCharacters : function(strtoTest, iAdditionalSpecialChars) {
                    var i, firsttest;

                    if (strtoTest === "") {
                        return false;
                    }

                    firsttest = (/^[\w\-\.\s]+$/).test(strtoTest);

                    if (typeof iAdditionalSpecialChars === 'undefined') {
                        return !firsttest;
                    }

                    if (firsttest === true) {
                        for (i = 0; i < strtoTest.length; i++) {
                            if (iAdditionalSpecialChars.indexOf(strtoTest.charAt(i)) !== -1) {
                                return true;
                            }
                        }
                    }
                    return !firsttest;
                },

                UpdateAttributesStsInTable : function(iContentDiv) {
                    var imgSpan,
                        tbodyreflist = iContentDiv.getElements('.attrstbody'),
                        iLines = tbodyreflist[0].childNodes,
                        nbofLines = iLines.length,
                        i = nbofLines - 1,
                        cellsIndex = this.cellsIndex;
                    while (i >= 1) {
                        if (iLines[i].cells[cellsIndex.DeployStatus].value === "DeletedNotDeployed") {
                            iLines[i].remove();
                        } else if (iLines[i].cells[cellsIndex.DeployStatus].value === "NewNotDeployed" || iLines[i].cells[cellsIndex.DeployStatus].value === "ModifiedNotDeployed" 
                            || iLines[i].cells[cellsIndex.DeployStatus].value === "StoredButNotDeployed") { //IR-666051-3DEXPERIENCER2018x/19x/20x
                            iLines[i].cells[cellsIndex.DeployStatus].empty();
                            iLines[i].cells[cellsIndex.DeployStatus].value = "Deployed";
                            imgSpan = ParametersLayoutViewUtilities.buildImgSpan('check', '1.5', 'green');
                            iLines[i].cells[cellsIndex.DeployStatus].title = ParamSkeletonNLS.deployedParamtxt;
                            imgSpan.inject(iLines[i].cells[cellsIndex.DeployStatus]);
                        }
                        i--;
                    }
                }

            };

        return AttrUtilsView;
    });

/*global define, widget, document, setTimeout, console, clearTimeout, FileReader*/
/*jslint plusplus: true*/
/*jslint nomen: true*/
/*! Copyright 2017, Dassault Systemes. All rights reserved. */
/*@fullReview  CN1     18/05/15 2019xBeta2 Mapping Widget*/
define('DS/ParameterizationSkeleton/Views/ParameterizationXCAD/ParamXCADLayoutView',
[
 'UWA/Core',
 'UWA/Class/View',
 'DS/UIKIT/Modal',
 'DS/UIKIT/Popover',
 'DS/UIKIT/Mask',
 'DS/UIKIT/Scroller',
 'DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
 'DS/ParameterizationSkeleton/Views/ParameterizationXCAD/XCADViewUtilities',
 'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler',
 'DS/UIKIT/Input/Button',
 'DS/UIKIT/Input/Select',
 'DS/UIKIT/Input/Toggle',
 'DS/UIKIT/Alert',
 'i18n!DS/ParameterizationSkeleton/assets/nls/XCADMappingNLS',
 'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS',
 'DS/WAFData/WAFData',
 ],
 function (UWA, View,
     Modal,
     Popover, Mask, Scroller,
     ParametersLayoutViewUtilities, XCADViewUtilities,
     URLHandler,  Button, Select, Toggle, Alert,
     XCADMappingNLS,ParamSkeletonNLS, WAFData) {

'use strict';

var extendedView;

extendedView = View.extend({
tagName: 'div',
className: 'generic-detail',

init: function (options) {
  var initDate =  new Date();

  options = UWA.clone(options || {}, false);
  this._parent(options);
  this.contentDiv = null;
  this.paramScroller = null;
  this.userMessaging = null;
  this.lastAlertDate = initDate.getTime();
  this.controlDiv = null;
  this.wdthArrayAttr = [35,10,35,10,10];
  this.divMapping = null;
  this.divCustoMapping =null;
  this.baseAccordion=null;
  this.selectMapping=null;
  this.listOfBasicVPMType =[];
  this.listOfBasicType =[];
  this.listOfCustoVPMType=new Map();
  this.listOfCustoPartType=new Map();
  this.divBaseMapping;
  this.listofTypeRel;
  this.listofTypeRelMapping;
  this.mappingScroller=null;
  this.lastAlertDate = initDate.getTime();
  this.userMessaging=null;
},

setup: function(options) {
  UWA.log('AttributesLayoutView::setup!');
  UWA.log(options);
},

render: function () {
  UWA.log("AttributesLayoutView::render");
  var introDiv,
  mappingDiv,
  that = this;

  this.contentDiv =  UWA.createElement('div', {'id': 'typeMainDiv'});
  Mask.mask(this.contentDiv);

  this.userMessaging = new Alert({
            className : 'param-alert',
            closable: true,
            visible: true,
            renderTo : document.body,
            autoHide : true,
            hideDelay : 2000,
            messageClassName : 'warning'
        });

  introDiv = UWA.createElement('div', {'class': 'information'}).inject(this.contentDiv);



  UWA.createElement('p', {
    text   : XCADMappingNLS.intro,
    'class': 'font-3dslight'      //'font-3dsbold'
  }).inject(introDiv);

  this.controlDiv = XCADViewUtilities.createApplyResetToolbar.call(this, this.contentDiv, true,
      this.applyParams.bind(this), this.confirmationResetModalShow.bind(this));

  this.container.setContent(this.contentDiv);
  this.listenTo(this.collection, {
    onSync: that.onCompleteRequestMapping
  });

  return this;
},




onCompleteRequestMapping : function() {

  UWA.log("MappingLayoutView::onCompleteRequestMapping");
  var resultDiv;
  var that=this;
  var CADType, VPMType, side, line,i,j, listofAttributesMapping, TypeName, CADTypeName, isDeployed;
  var AddMappingAttributeButton,divMapping;


  this.divMapping = UWA.createElement('div', {
    'class': 'DivXCADScroll',
  }).inject(this.contentDiv);

  //Recuperation des Mapping
  this.Mapping = this.collection._models[0]._attributes.Mapping;

  resultDiv = UWA.createElement('div', {'class': 'result'}).inject(this.contentDiv);

  this.baseAccordion=  ParametersLayoutViewUtilities.createFamilyUIKITAccordion(this.divMapping);

  for (i = 0; i < this.Mapping.length; i++) {
    
    CADType = this.Mapping[i].cadType;
    VPMType = this.Mapping[i].Type;
    if (!this.Mapping[i].VPMObjectName) {
      
      if (this.Mapping[i].Type == "VPMReference") this.Mapping[i].VPMObjectName = "Physical Product";
      else 
        this.Mapping[i].VPMObjectName = this.Mapping[i].Type;
    }

    if (!this.Mapping[i].cadTypeName) {
      this.Mapping[i].cadTypeName = XCADMappingNLS[this.Mapping[i].cadType] ? XCADMappingNLS[this.Mapping[i].cadType] : CADType;
    }
    CADTypeName = this.Mapping[i].cadTypeName;


    listofAttributesMapping = this.Mapping[i].AttributeMapping;

    var mappingTable = XCADViewUtilities.buildMappingLine.call(that,this.Mapping[i]);

    if (!mappingTable) continue;

    var attributeMappingDiv = UWA.createElement('div', {
      'class': 'attributeMapping'
    });//table-bordered

    var attributesTable = XCADViewUtilities.buildAttributeTable.call(that,listofAttributesMapping ,that.wdthArrayAttr);
    attributesTable.inject(attributeMappingDiv);

    var AddMappingButton = new Button({
      className: 'AddMappingButton',
      icon: 'plus-circled',
      attributes: {
        disabled: false,
        'aria-hidden' : 'true',
        title : XCADMappingNLS.AddAttributeMappingTooltip,
      },
      events: {
        onClick: that.ShowAddMappingAttributePanel.bind(that,this.Mapping[i], attributesTable.getElement(".attrstbodyXCADMapping"))
      }
    }).inject(attributeMappingDiv);

      this.baseAccordion.addItem({
        title:  mappingTable,
        content: attributeMappingDiv,
        selected : true,
        name:CADType + "_" + VPMType,
      });
  }



  var divAddMapping = UWA.createElement('div', {
    'class': 'AddXCADMapping'//'font-3dsbold'
  }).inject(this.contentDiv);
  
  Mask.unmask(this.contentDiv);
},




resetParams : function () {
  UWA.log("applyReset");
  var that=this;

  Mask.mask(this.contentDiv);
  var integration = encodeURI(this.model.id);
  var url = URLHandler.getURL() + "/resources/xcadparam/gco/reset?integration="+integration+"&tenant=" + URLHandler.getTenant();
  
  WAFData.authenticatedRequest(url, {
    timeout: 100000,
    method: 'POST',
    type: 'json',

    headers: {
      'Content-Type' : 'application/json',
      'Accept' : 'application/json'
    },

    onFailure : function (json) {
      that.onResetFailure.call(that,json);
    },

    onComplete: function(json) {
      that.onResetSuccess.call(that,json);
    }

  });


  //this.UpdateCommonParamsOnServer();
},

onResetFailure : function (json) {
  UWA.log(json);
  Mask.unmask(this.contentDiv);
  // Mask.unmask(this.contentDiv);//Rb0afx
  // this.userMessaging.add({ className: "error", message: ParamDataModelingNLS.deployFailureMsg });
  this.userMessaging.add({ className: "warning", message: XCADMappingNLS.ErrorReset });
  //ParamLayoutUtilities.updateIcon(false, theImageCell);
},


applyParams : function () {
  UWA.log("applyParams");
  var that = this;
  var mappingToSend = that.Mapping;

  Mask.mask(this.contentDiv);

  var isInvalidMapping = false;

  if( isInvalidMapping)
  {
    Mask.unmask(this.contentDiv);
    this.userMessaging.add({ className: "error", message: XCADMappingNLS.InvalidMapping });
  }
  else
  {
    datatoSend = { "Connector": that.model.id,
                   Mapping : mappingToSend
                 };

    var integration = encodeURI(this.model.id);
    var url = URLHandler.getURL() + "/resources/xcadparam/gco/set?integration="+integration+"&tenant=" + URLHandler.getTenant(),datatoSend;
    
    WAFData.authenticatedRequest(url, {
      timeout: 250000,
      method: 'POST',
      data: JSON.stringify(datatoSend),
      type: 'json',
      //proxy: 'passport',

      headers: {
        'Content-Type' : 'application/json',
        'Accept' : 'application/json'
      },

      onFailure : function (json) {
        that.onApplyFailure.call(that,json);
      },

      onComplete: function(json) {
        that.onApplySuccess.call(that,json);
      }

    });
  }

  //this.UpdateCommonParamsOnServer();
},

onApplyFailure : function (json) {
  UWA.log(json);
  Mask.unmask(this.contentDiv);
  this.userMessaging.add({ className: "error", message: XCADMappingNLS.applyErrorMessage });
},

onApplySuccess : function (json) { //Rb0afx

  var cpt=0,cptAttr=0,item,title,line,cell,nbofLines,mappingElt,imgSpan, itemToRemove = new Array(), that=this, currDate, currTime, diffDate;
   Mask.unmask(this.contentDiv);
  currDate = new Date();
  currTime = currDate.getTime();
  diffDate = currTime - this.lastAlertDate;
  this.lastAlertDate = currTime;

  this.lastAlertDate = currTime;
  if (true) { //  (diffDate >= 2000) {
            this.userMessaging.add({ className: "success", message: XCADMappingNLS.applySuccessMessage });
        }

  for(cpt=0;cpt<this.baseAccordion.items.length;cpt++)
  {
    item = this.baseAccordion.getItem(cpt);
    title = item.title.children[1];
    line = title.getElementsByTagName("tr");
    cell = line[0].cells[5];
    mappingElt=XCADViewUtilities.retrieveMappingEntry(line[0].cells[1].value, line[0].cells[3].value,this.Mapping);
    this.onApplySuccessForAttributes(mappingElt,item);

  }
},



onApplySuccessForAttributes : function (mappingElt,item) {
  var attrDiv,attrTable,nbofLines,cptAttr,attrLines,cellAttr,mappingEltAttr,imgSpan,listOfAttributes,attrLineToRemove=new Array();

  listOfAttributes = mappingElt.AttributeMapping;
  attrDiv = item.elements.content.children[0];
  if(attrDiv !== undefined)
  {
    attrTable = attrDiv.getElement(".attrstbodyXCADMapping");
    nbofLines = attrTable.children.length;
    for(cptAttr=1;cptAttr<nbofLines;cptAttr++)
    {
      attrLines = attrTable.children[cptAttr];
      cellAttr=attrLines.cells[XCADViewUtilities.cellsAttrIndex.deployFlag];
      mappingEltAttr=XCADViewUtilities.retrieveMappingAttrEntry(undefined,attrLines.cells[XCADViewUtilities.cellsAttrIndex.VPMAttr].value,attrLines.cells[XCADViewUtilities.cellsAttrIndex.CADAttr].value,listOfAttributes);
      if(cellAttr.value==="New" ||cellAttr.value === "Stored")
      {
        if(mappingEltAttr!=undefined)
        {
          mappingEltAttr.status="Deployed";
          cellAttr.empty();
          cellAttr.value="Deployed";
          cellAttr.title=XCADMappingNLS.deployedParamtxt;
          imgSpan = ParametersLayoutViewUtilities.buildImgSpan('check', '1.5', 'green');
          imgSpan.inject(cellAttr);
        }
      }
      else if(cellAttr.value==="Removed")
      {
        //attrLines.remove();
        attrLineToRemove.push(attrLines);
        XCADViewUtilities.removeMappingAttr(mappingEltAttr,listOfAttributes);
      }
    }

    attrLineToRemove.forEach(function(attrMapping){
      attrMapping.remove();
    });
  }
},



onResetSuccess : function (json) {
  var that = this;

  Mask.unmask(this.contentDiv);

  that.resetUI(json);


},


ShowAddMappingAttributePanel: function (typeMapping, attrtbody)
{
  var that = this;
  var vpmtype = encodeURI(typeMapping.Type);

  Mask.mask(that.contentDiv);

  var url = URLHandler.getURL() + "/resources/ParamWS/datamodel/listofattributesfortype?type="+vpmtype+"&tenant=" + URLHandler.getTenant(),datatoSend;

  WAFData.authenticatedRequest(url, {
    timeout: 250000,
    method: 'GET',
    data: JSON.stringify(datatoSend),
    type: 'json',
    
    headers: {
      'Content-Type' : 'application/json',
      'Accept' : 'application/json'
    },
    
    onFailure : function (json) {
      Mask.unmask(that.contentDiv);
      // TODO raise error
      //that.onApplyFailure.call(that,json);
    },
    
    onComplete: function(json) {
      Mask.unmask(that.contentDiv);


      var url2 = URLHandler.getURL() + "/resources/xcadparam/gco/listextraatt?type="+vpmtype+"&tenant=" + URLHandler.getTenant(),datatoSend;
      
      WAFData.authenticatedRequest(url2, {
        timeout: 250000,
        method: 'GET',
        data: JSON.stringify(datatoSend),
        type: 'json',
        
        headers: {
          'Content-Type' : 'application/json',
          'Accept' : 'application/json'
        },
        
        onFailure : function (json2) {
          Mask.unmask(that.contentDiv);
          that.ShowAddMappingAttributePanelWithAtt.call(that, typeMapping, attrtbody, json);
        },
        
        onComplete: function(json2) {

          if (json2.attributeDescription) {
            json.attributeDescription = json.attributeDescription.concat(json2.attributeDescription);
          }

          Mask.unmask(that.contentDiv);
          that.ShowAddMappingAttributePanelWithAtt.call(that, typeMapping, attrtbody, json);
        }
      }
                                  );                   
    }
  });
},
                              

ShowAddMappingAttributePanelWithAtt : function (typeMapping, attrtbody, json) {

  var that = this;
  var labelVPM = typeMapping.VPMObjectName+" "+XCADMappingNLS.attribute;
  var labelCAD = "CAD "+XCADMappingNLS.attribute;

  function compare(attrInfo1, attrInfo2) {
      if (attrInfo1.nlsName.toUpperCase() <  attrInfo2.nlsName.toUpperCase())
         return -1;
      if (attrInfo1.nlsName.toUpperCase() >  attrInfo2.nlsName.toUpperCase())
         return 1;
      return 0;
    }

  var VPMAttributes;
  if(json!==undefined)
    {
      VPMAttributes = json.attributeDescription;
      VPMAttributes.sort(compare);
    }

  var defaultPrefix = "";
  if (that.model.id==="CATIAV5UPS") defaultPrefix="cus:";

  var result = XCADViewUtilities.BuildAddMappingPanel( XCADMappingNLS.addMappingAttributeTitle.format(typeMapping.VPMObjectName,typeMapping.cadTypeName), XCADMappingNLS.selectAttr.format(typeMapping.VPMObjectName), XCADMappingNLS.selectAttr.format(typeMapping.cadTypeName), labelVPM, labelCAD, XCADMappingNLS.unilateralDirection.format(typeMapping.VPMObjectName,typeMapping.cadTypeName), XCADMappingNLS.unilateralDirection.format(typeMapping.cadTypeName,typeMapping.VPMObjectName), defaultPrefix);

  var addMappingModal = result[0];
  var selectVPM = result[1].selectVPM;
  var selectCAD = result[1].cadAttr;
  var toggleVPM = result[2].toggle;
  var divVPMMessage = result[2].div;
  var VPMPopover=  result[2].popover;
  var toggleCAD= result[3].toggle;
  var divCADMessage = result[3].div;
  var CADPopover= result[3].popover;
  var toggleBoth= result[4].toggle;
  var divBothMessage = result[4].div;
  var BothPopover = result[4].popover;
  var OkButton = result[5].OKButton;
  var CancelButton = result[5].CancelButton;

  //Build VPM attributes list

  function addEltToSelect(value, select,filterForVPM) {
    var i, attributeInfo,attributeName,attributeItf,position,option,listOfEnableOption = new Array(), listOfDisableOption=new Array();
    for (i=0; i<value.length;i++)
    {
      attributeInfo = value[i];

      attributeName = attributeInfo.id;
      option = {label:attributeInfo.nlsName + " ("+attributeInfo.type+")", value:attributeInfo.internalName };
      listOfEnableOption.push(option);
    }

    listOfEnableOption.forEach(function(optionSelect){
      select.add(optionSelect );
      select.enable(optionSelect);
    });

    listOfDisableOption.forEach(function(optionSelect){
      select.add( optionSelect);
      select.disable(optionSelect);

    });

  }

  addEltToSelect(VPMAttributes, selectVPM,true);
  
  CancelButton.addEvent("onClick", function (e) {
    UWA.log(e);//that.onCancelCalled();
    addMappingModal.hide();
  });

  OkButton.addEvent("onClick", function (e) {

    var selectedVPMAttr = selectVPM.getSelection();
    var nameAttrCAD = selectCAD.getValue();
    var side=0;
    if(toggleBoth.isChecked())
      side=0;
    else if (toggleVPM.isChecked())
      side=-1;
    else if (toggleCAD.isChecked())
      side=1;

    var nameAttrVPM = selectedVPMAttr[0].value;

    var position = selectedVPMAttr[0].label.indexOf("(");
    var displayNameAttrVPM = nameAttrVPM;
    var typeAttrVPM = "String";

    if(position != -1)
    {
      displayNameAttrVPM = selectedVPMAttr[0].label.slice(0,position);;
      typeAttrVPM = selectedVPMAttr[0].label.slice(position+1,selectedVPMAttr[0].label.length-1);
    }

    var itfVPMOpt="";
    if (nameAttrVPM.contains('.')) {
      itfVPMOpt = nameAttrVPM.split('.')[0];
      nameAttrVPM = nameAttrVPM.split('.')[1];
    }

    var mappingElt=XCADViewUtilities.retrieveMappingEntry(typeMapping.Type,typeMapping.cadType,that.Mapping);

    var mappingEltAttr = null;
    if(mappingElt!=undefined)
    {
      mappingEltAttr = { cadName: nameAttrCAD, Extension: itfVPMOpt, Name:  nameAttrVPM, Sync: side, nlsName:displayNameAttrVPM, status:"New","default":false };
      mappingElt.AttributeMapping.push(mappingEltAttr);

      var lineAttribute = XCADViewUtilities.buildAttributeLine.call(that, mappingElt.AttributeMapping, mappingEltAttr,that.wdthArrayAttr);
      var attrbody= result[0].getBody().getElementsByTagName("tbody");;
      lineAttribute.inject(attrtbody);
      
    }


    addMappingModal.hide();
  });

  addMappingModal.inject(this.contentDiv);
  addMappingModal.show();
},

  resetUI : function(json) {
    var that = this;
    
    this.divMapping.empty();
    this.divMapping.parentNode.removeChild(this.divMapping);
    this.collection._models[0]._attributes = json;
    this.onCompleteRequestMapping();

  },
  confirmationResetModalShow : function () {
    var headertitle, OKBtn, CancelBtn,
    bodyDiv,
    that = this;
    
    if (this.resetModal) {
      this.resetModal.show();//Modal already exists
    } else {
      headertitle = UWA.createElement('h4', {
        text   : ParamSkeletonNLS.confirmResetTitle,
        'class': 'font-3dslight' // font-3dsbold
      });
      
      OKBtn = new Button({
        value : ParamSkeletonNLS.OKButton,
        className : 'btn primary',
        events : {
          'onClick' : function() {
            UWA.log("DoSomething");
            that.resetParams();
          }
        }
      });
      CancelBtn = new Button({
        value : ParamSkeletonNLS.CancelButton,
        className : 'btn default',
        events : {
          'onClick' : function(e) {
            UWA.log("Cancel");
          }
        }
      });
      bodyDiv = UWA.createElement('div', {
        'id': 'resetContentDiv',
        'width' : '100%',
        'height': '100%'
      });
      UWA.createElement('p', {
        text   :  XCADMappingNLS.resetMsg,
        'class': 'font-3dslight'// font-3dsbold
      }).inject(bodyDiv);
      UWA.createElement('p', {
        text   :  ParamSkeletonNLS.confirmResetMsg,
        'class': 'font-3dslight'// font-3dsbold
      }).inject(bodyDiv);
      
      this.resetModal = new Modal({
        className: "reset-confirm-modal",
        closable: true,
        header: headertitle,
        body:   bodyDiv,
        footer: [ OKBtn, CancelBtn ]
      }).inject(this.contentDiv);
      this.resetModal.getContent().setStyle("padding-top", 1);
      this.resetModal.show();
      
      this.resetModal.getContent().getElements(".btn").forEach(function (element) {
        element.addEvent("click", function () {
          that.resetModal.hide();
        });
      });
    }
  },
  
  destroy : function() {
    this.stopListening();
    this._parent.apply(this, arguments);
  }
});

return extendedView;
});

/*! Copyright 2017, Dassault Systemes. All rights reserved. */
/*global define, widget, document, setTimeout, console, clearTimeout, FileReader*/
/*jslint plusplus: true*/
/*jslint nomen: true*/
/*! Copyright 2017, Dassault Systemes. All rights reserved. */
/*@quickReview NZV 19/01/31 FUN085423 delivery*/
/*@quickReview ZUR 18/04/24 FUN079262 2019x : EBOM-PS Collaboration Mapping Object Widget*/
/*@quickReview NZV 18/02/07 FUN076053 delivery*/
/*@quickReview NZV 17/08/27 IR-540216-3DEXPERIENCER2018x*/
/*@quickReview ZUR 17/08/04 IR-540566-3DEXPERIENCER2018x */
/*@quickReview NZV 17/05/09 Minor change */
/*@quickReview NZV 17/05/04 IR-512104-3DEXPERIENCER2018x */
/*@fullReview  NZV 17/04/21 Delivery of HL FUN070867  -major change */
/*@quickReview ZUR 17/04/19 IR-514503-3DEXPERIENCER2017x/18x, IR-516226-3DEXPERIENCER2017x/18x */
/*@fullReview  ZUR 15/07/29 2016xFD01 Param Widgetization NG*/

define('DS/ParameterizationSkeleton/Views/ParameterizationDataModeling/AttributesLayoutView',
    [
        'UWA/Core',
        'UWA/Class/View',
        'DS/UIKIT/Modal',
        'DS/UIKIT/Popover',
        'DS/UIKIT/Mask',
        'DS/UIKIT/Scroller',
        'DS/ParameterizationSkeleton/Views/ParametersLayoutViewUtilities',
        'DS/ParameterizationSkeleton/Views/ParameterizationDataModeling/AttributesLayoutUtilities',
        'DS/ParameterizationSkeleton/Utils/ParameterizationURLHandler',
        'DS/ParameterizationSkeleton/Utils/ParameterizationWebServices',
        'i18n!DS/ParameterizationSkeleton/assets/nls/ParamSkeletonNLS'
    ],
    function (UWA, View,
              Modal,
              Popover, Mask, Scroller,
              ParametersLayoutViewUtilities, AttributesLayoutUtilities,
              URLHandler, ParameterizationWebServices,
              ParamDataModelingNLS) {

        'use strict';

        var extendedView;

        extendedView = View.extend({
            tagName: 'div',
            className: 'generic-detail',

            init: function (options) {
                var initDate =  new Date();

                options = UWA.clone(options || {}, false);
                this._parent(options);

                this.contentDiv = null;
                this.inputControls = [];
                this.paramScroller = null;
                this.userMessaging = null;
                this.userMessagingLong = null;
                this.lastAlertDate = initDate.getTime();
                this.resetModal = null;
                this.controlDiv = null;
                this.addAttributesModal = null;
                this.editAttributesModal = null;
                this.handledTypeID = null;
                this.wdthArray = [10, 15, 12, 5, 5, 5, 5, 5, 5, 15, 16, 16, 3, 7];
                //this.attSynchroCombos = [];
                this.systemAttributes = [];
            },

            setup: function(options) {
                UWA.log('AttributesLayoutView::setup!');
                UWA.log(options);
                //var listoftagsSetup = this.model.get('sixwTagDescription');
            },

            render: function () {
                UWA.log("AttributesLayoutView::render");
                var introDiv,
                    that = this,
                    introText = ParamDataModelingNLS.IntroDivText.format(this.model.get('title'));

                this.contentDiv =  UWA.createElement('div', {'id': 'typeMainDiv'});
                Mask.mask(this.contentDiv);
                this.userMessaging = AttributesLayoutUtilities.addUserMessaging(document.body, 1500);
                this.userMessagingLong = AttributesLayoutUtilities.addUserMessaging(document.body, 5000);//IR-516226-3DEXPERIENCER2017x/18x

                introDiv = UWA.createElement('div', {'class': 'information'}).inject(this.contentDiv);

                /*if ((this.model.get("id") === "AttributeSynchronization")) {
                    introText = ParamDataModelingNLS.IntroSynchroText;
                }*/

                UWA.createElement('p', {
                    text   : introText,
                    'class': 'font-3dslight'//'font-3dsbold'
                }).inject(introDiv);

                this.controlDiv = ParametersLayoutViewUtilities.createApplyResetToolbar.call(this, this.contentDiv, true,
                                                                  this.applyParams.bind(this), this.resetDMParamsInSession.bind(this));

                this.container.setContent(this.contentDiv);
                this.listenTo(this.collection, {
                    onSync: that.onCompleteRequestParameters
                });

                return this;
            },

            onCompleteRequestParameters : function() {
                UWA.log("AttributesLayoutView::onCompleteRequestParameters");
                var i, attributesTable, attrtbody, titlesLine, paramLine, typeNLen,
                    isixWNLS = '', listofAuthValues, //listofSynchros,
                    paramsDIV = ParametersLayoutViewUtilities.createParamsContainerDiv(),
                    listofAttr = this.collection._models[0]._attributes.listofAttributes;
                this.handledTypeID = this.collection._models[0]._attributes.id;
                this.systemAttributes = this.collection._models[0]._attributes.listofSystemAttribues;

                attributesTable = UWA.createElement('table', {
                    'class': 'table table-hover'
                }).inject(paramsDIV);//table-bordered

                attrtbody =  UWA.createElement('tbody', {
                    'class': 'attrstbody'
                }).inject(attributesTable);

                if (this.handledTypeID !== "AttributeSynchronization") {

                    titlesLine =  AttributesLayoutUtilities.buildTitlesLine(this.wdthArray);
                    //titlesLine.addClassName("active");
                    titlesLine.inject(attrtbody);

                    for (i = 0; i < listofAttr.length; i++) {

                        typeNLen = listofAttr[i].type;
                        if ((listofAttr[i].type === 'String') && (listofAttr[i].maxLength != 0)) {
                            typeNLen = listofAttr[i].type + listofAttr[i].maxLength;
                        }

                        listofAuthValues = '';
                        if (listofAttr[i].hasAuthValues === true) {
                            listofAuthValues = listofAttr[i].listofAuthValues;
                        }

                        paramLine = AttributesLayoutUtilities.buildAttributeLine(typeNLen,
                            listofAttr[i].nlsName,
                            listofAttr[i].defaultValue,
                            listofAttr[i].isMandatory, listofAttr[i].isReadOnly, listofAttr[i].isExposedTo3DXML,
                            listofAttr[i].dimension, listofAttr[i].preferredunit, listofAttr[i].isIndexed,
                            listofAuthValues,
                            isixWNLS,
                            listofAttr[i].sixWTag,
                            listofAttr[i].isUsedInOther,
                            listofAttr[i].isDeployed,
                            this.wdthArray,
                            this.userMessagingLong, listofAttr[i].resetWhenRevision, listofAttr[i].resetWhenDuplicate,this);
                        paramLine.inject(attrtbody);
                    }
                }

                /*else {
                    attributesTable.setStyle("width", "70%");
                    //attributesTable.setStyle("margin", "0 auto");//this works correctly
                    //VpmCbpMapping
                    AttributesSynchroView.init(attrtbody);
                    titlesLine = AttributesSynchroView.buildSynchroTitlesLine();
                    titlesLine.inject(attrtbody);
                    UWA.log(this.collection._models[0]);
                    listofSynchros = this.collection._models[0]._attributes.listofSynchros;
                    AttributesSynchroView.buildSynchroView(listofAttr, listofSynchros);
                }*/

                paramsDIV.inject(this.contentDiv);

                this.paramScroller = new Scroller({
                    element: paramsDIV
                }).inject(this.contentDiv);

                Mask.unmask(this.contentDiv);
            },

            showAddElementsModal : function() {
                var headertitle, modalbodyTable, tbodyreflist, attrLine, listofAddedAttrs,
                    AuthValsInput, typeNLen,
                    OKBtn, CancelBtn, checkResult, hasAuthVals,
                    sixwTagSelector, typesSelect, attrNameInput, attrDefValueInput,
                    currSelectedOpt, iDefaultValue, 
                    mandToggle, readonlyToggle, indexedToggle,
                    dateInput, dateSpan, iShortDate,
                    selected6wTag = '',
                    selected6wTagValue = '',
                    inputsArray = [],
                    dimensionsSelector, unitSelect,
                    export3DXMLToggle = false, revisionToggle = null, duplicateToggle = null,
                    that = this;

                UWA.log("showAddAttributesModal::");

                if (that.addAttributesModal !== null) {
                    //that.addAttributesModal.show();//Modal already exists
                    //NZV : Need to comfirm this change.
                    that.addAttributesModal.destroy();
                }  {
                    headertitle = UWA.createElement('h4', {
                        text   : ParamDataModelingNLS.AddAttributeTxt,
                        'class': 'font-3dslight' // font-3dsbold
                    });

                    //sortedTypes = LifecycleViewUtilities.sortArrayByKey(that.collection._models[0]._attributes.types, "typeNLS");

                    inputsArray        = AttributesLayoutUtilities.buildModalSkeleton(that.userMessaging);
                    modalbodyTable     = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "modalbodyTable");
                    typesSelect        = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "typesSelect");
                    attrNameInput      = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "attrNameInput");
                    mandToggle         = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "mandToggle");
                    readonlyToggle     = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "readonlyToggle");
                    indexedToggle      = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "indexedToggle");
                    sixwTagSelector    = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "sixwTagAutoSelect");
                    AuthValsInput      = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "AuthValsInput");
                    OKBtn              = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "OKBtn");
                    CancelBtn          = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "CancelBtn");
                    dimensionsSelector = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "dimensionsSelect");
                    unitSelect         = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "unitSelect");
                    export3DXMLToggle  = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "export3DXMLToggle");
                    revisionToggle     = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "revisionToggle");
                    duplicateToggle    = AttributesLayoutUtilities.getInputFromSkeleton(inputsArray, "duplicateToggle");

                    OKBtn.addEvent("onClick", function () {

                        var userSelectDimention = "", perferredUnit = "";

                        typeNLen = AttributesLayoutUtilities.getSelectedTypeAndLength(typesSelect.getSelection()[0].value);
                       // userSelectDimention = {};
                        if (typeNLen[0] === 'Boolean') {
                            attrDefValueInput = AttributesLayoutUtilities.getDefaultValueInput();
                            currSelectedOpt = attrDefValueInput.getSelection();
                            iDefaultValue = currSelectedOpt[0].value;
                        } else if (typeNLen[0] === 'Date') {
                            //ZUR IR-494192-3DEXPERIENCER2017x
                            dateSpan = AttributesLayoutUtilities.getDefaultValueInput();
                            dateInput = dateSpan.dateInput;
                            iShortDate = dateInput.getDate();
                            if (iShortDate !== null) {
                                iShortDate.setHours(11);//ZUR IR-502127-3DEXPERIENCER2018x
                                //toLocaleDateString
                                iDefaultValue = AttributesLayoutUtilities.getCATIACompatibleDateFromISOString(iShortDate.toISOString());
                            } else {
                                iDefaultValue = "";
                            }

                        } else if (typeNLen[0] === 'Real') {

                            if (dimensionsSelector.getSelection()[0].value !== '') {

                                userSelectDimention = dimensionsSelector.getSelection()[0].value;

                                if (unitSelect.getSelection()[0].value !== '') {
                                    perferredUnit = unitSelect.getSelection()[0].value;
                                }
                            }
                            iDefaultValue = AttributesLayoutUtilities.getDefaultValueInput().getValue();
                        } else {
                            iDefaultValue = AttributesLayoutUtilities.getDefaultValueInput().getValue();
                        }
                        listofAddedAttrs = AttributesLayoutUtilities.getNamesListofAlreadyAddedAttributes(that.contentDiv);

                        hasAuthVals = false;

                        if ((AuthValsInput.getValue() !== '') &&
                                (AuthValsInput.getValue() !== undefined)) {
                            hasAuthVals = true;
                        }

                        checkResult = AttributesLayoutUtilities.checkOptionsBeforeAddAttrs(typeNLen[0], typeNLen[1],
                            attrNameInput.getValue(), iDefaultValue,
                            readonlyToggle.isChecked(), mandToggle.isChecked(), hasAuthVals,
                            AuthValsInput.getValue(),
                            listofAddedAttrs, that.systemAttributes);

                        if (checkResult !== "S_OK") {
                            UWA.log("checkResult = " + ParamDataModelingNLS[checkResult]);
                            that.userMessaging.add({ className: "error", message: ParamDataModelingNLS[checkResult]});

                            if ((checkResult === 'DefaultValueSizeInadequate') ||
                                    (checkResult === 'AccentsnotAllowedMsg') ||
                                      (checkResult === 'DefaultValueSizeInadequate')) {
                                AttributesLayoutUtilities.getDefaultValueInput().focus();
                            }

                        } else {

                            selected6wTag = '';
                            selected6wTagValue = '';

                            if (sixwTagSelector.selectedItems[0] != undefined) {
                                selected6wTag = sixwTagSelector.selectedItems[0].label;
                                selected6wTagValue = sixwTagSelector.selectedItems[0].value;
                            }

                            attrLine = AttributesLayoutUtilities.buildAttributeLine(typesSelect.getSelection()[0].value,
                                attrNameInput.getValue(), iDefaultValue,
                                mandToggle.isChecked(), readonlyToggle.isChecked(), export3DXMLToggle.isChecked(),
                                userSelectDimention, perferredUnit,
                                indexedToggle.isChecked(),
                                AuthValsInput.getValue(),
                                selected6wTag,
                                selected6wTagValue,
                                false,
                                "NewNotDeployed",//'false',//isDeployed
                                that.wdthArray,
                                this.userMessagingLong, revisionToggle.isChecked(), duplicateToggle.isChecked(),that);

                            tbodyreflist = that.contentDiv.getElements('.attrstbody');
                            attrLine.inject(tbodyreflist[0]);
                            attrLine.focus();
                            that.addAttributesModal.hide();
                            that.addAttributesModal.destroy();
                        }

                    });

                    CancelBtn.addEvent("onClick", function (e) {
                        UWA.log(e);//that.onCancelCalled();
                        that.addAttributesModal.hide();
                        that.addAttributesModal.destroy();
                    });

                    that.addAttributesModal = new Modal({
                        className: 'add-attr-modal',
                        closable: true,
                        header  : headertitle,
                        body    : modalbodyTable,
                        footer  : [ OKBtn, CancelBtn ]
                    }).inject(that.contentDiv);

                    that.addAttributesModal.getContent().setStyle("padding-top", 10);
                    that.addAttributesModal.elements.wrapper.setStyle("width", 800);
                    that.addAttributesModal.show();
                }
            },

            resetDMParamsInSession : function () {
                /*if (this.model.get("id") === "AttributeSynchronization") {
                    this.resetSynchroParams();
                } else {*/
                this.confirmationModalShow();
                //}
            },

            confirmationModalShow : function () {
                UWA.log("confirmationModalShow");
                var tbodyreflist = this.contentDiv.getElements('.attrstbody'),
                    iLines = tbodyreflist[0].childNodes,
                    nbofLines = iLines.length,
                    i = nbofLines - 1, deployStatusValue, attriList, deployedAttri, j;

                while (i >= 1) {
                    deployStatusValue = iLines[i].cells[AttributesLayoutUtilities.cellsIndex.DeployStatus].value;
                    if (deployStatusValue === "Deployed") {
                        i--;
                        continue;
                    }
                    attriList = this.collection._models[0]._attributes.listofAttributes;
                    deployedAttri = "";
                    for(j = 0; j < attriList.length; j++) {
                        if (attriList[j].nlsName === iLines[i].cells[AttributesLayoutUtilities.cellsIndex.AttributeName].value) {
                            deployedAttri = attriList[j];
                            break;
                        }
                    }
                    if ( deployStatusValue === "NewNotDeployed" || deployedAttri === "") {
                        iLines[i].remove();
                    } else if (deployStatusValue === "DeletedNotDeployed" || deployStatusValue === "ModifiedNotDeployed") {
                        AttributesLayoutUtilities.undeleteAttribute(iLines[i],this);
                    }
                    i--;
                }
                /*
                   "DeletedNotDeployed"
                    "NewNotDeployed"
                    "StoredButNotDeployed"
                    "Deployed"
                */
            },

            /*resetSynchroParams : function () {
                AttributesSynchroView.resetSynchroParams();
            },*/

            applyParams : function () {
                UWA.log("applyParams");

                /*if (this.model.get("id") === "AttributeSynchronization") {
                    this.UpdateSynchroParams();

                } else {*/
                //IR-689657-3DEXPERIENCER2019x : Popup a warning msg when new attribute being added.
                var tbodyreflist = this.contentDiv.getElements('.attrstbody'),
                iLines = tbodyreflist[0].childNodes;
                var newAttributeAdded = false, i;
                for(i = 1 ; i < iLines.length; i++) {
                   if("NewNotDeployed" === iLines[i].cells[AttributesLayoutUtilities.cellsIndex.DeployStatus].value) {
                     newAttributeAdded = true;
                   }
                }
                if(newAttributeAdded === true) {
                    ParametersLayoutViewUtilities.showContextualDeleteModal(widget.body, "longAttrModal", ParamDataModelingNLS.NewAttrAddWarningMsg/*+"&lt%br&gt%" +ParamDataModelingNLS.AreYouWantToProceed*/, 
                        ParamDataModelingNLS.YesText,  ParamDataModelingNLS.NoText, ParamDataModelingNLS.Warning, this.UpdateDataModelingParams, this);
                } else {   
                    this.UpdateDataModelingParams(this);
                }
            },

            UpdateDataModelingParams : function (that) { //IR-689657-3DEXPERIENCER2019x
                var datatoSend,
                    attributeList = [];

                //if this.handledTypeID === AttributeSynchronization

                Mask.mask(that.contentDiv);
                attributeList = AttributesLayoutUtilities.getCurrentAttributesList(that.contentDiv);

                UWA.log(attributeList);


                datatoSend = {
                    id                      : that.handledTypeID,
                    attributeDescription    : attributeList
                };
                UWA.log(datatoSend);

                ParameterizationWebServices.postAttributesOnServer.call(that, datatoSend, "postattrparams",
                    that.onApplyFailure.bind(that), that.onApplySuccess.bind(that));
            },//of function UpdateCommonParamsOnServer

            /*UpdateSynchroParams : function () {
                var synchroList, datatoSend;
                Mask.mask(this.contentDiv);

                synchroList = AttributesSynchroView.getCurrentSynchroList(this.contentDiv);

                datatoSend = {
                    AttributesSynchronization : synchroList
                };

                UWA.log(datatoSend);

                ParameterizationWebServices.postAttributesOnServer.call(this, datatoSend, "postsynchros",
                    this.onApplyFailure.bind(this), this.onApplySuccess.bind(this));
            },*/

            onApplyFailure : function (json) {
                UWA.log(json);
                Mask.unmask(this.contentDiv);//Rb0afx
                this.userMessaging.add({ className: "error", message: ParamDataModelingNLS.deployFailureMsg });
                //ParamLayoutUtilities.updateIcon(false, theImageCell);
            },

            onApplySuccess : function (json) { //Rb0afx                      
                var currDate, currTime, diffDate,
                    successmsg = ParamDataModelingNLS.deploySuccessMsg, attributeList = [], attriList,
                    i = 0, existingAttribute = false, j = 0, modelAttriList, uiAttriList;// + ' - ' + new Date();
                Mask.unmask(this.contentDiv);
                UWA.log(json);

                currDate = new Date();
                currTime = currDate.getTime();
                diffDate = currTime - this.lastAlertDate;
                this.lastAlertDate = currTime;

                if (diffDate >= 2000) {
                    this.userMessaging.add({ className: "success", message: successmsg });
                }
                //UPDATE MODEL WITH LATEST CHANGES
                uiAttriList = AttributesLayoutUtilities.getCurrentAttributesList(this.contentDiv);
                modelAttriList = this.collection._models[0]._attributes.listofAttributes;
                for(i =0 ; i < modelAttriList.length; i++) {
                    modelAttriList[i].tempStatus = "ToBeDeleted";
                }

                for(i =0; i < uiAttriList.length; i++) {
                    existingAttribute = false;
                    for(j = 0; j < modelAttriList.length; j++) {
                        if (modelAttriList[j].nlsName === uiAttriList[i].nlsName) {
                                modelAttriList[j].type             = uiAttriList[i].type;
                                modelAttriList[j].maxLength        = uiAttriList[i].maxLength;
                                modelAttriList[j].defaultValue     = uiAttriList[i].defaultValue;
                                modelAttriList[j].isMandatory      = uiAttriList[i].isMandatory;
                                modelAttriList[j].isExposedTo3DXML = uiAttriList[i].isExposedTo3DXML;
                                modelAttriList[j].resetWhenDuplicate = uiAttriList[i].resetWhenDuplicate;
                                modelAttriList[j].resetWhenRevision = uiAttriList[i].resetWhenRevision;
                                modelAttriList[j].isReadOnly       = uiAttriList[i].isReadOnly;
                                modelAttriList[j].isIndexed        = uiAttriList[i].isIndexed;
                                modelAttriList[j].hasAuthValues    = uiAttriList[i].hasAuthValues;
                                modelAttriList[j].listofAuthValues = uiAttriList[i].listofAuthValues;
                                modelAttriList[j].SixWTag          = uiAttriList[i].SixWTag;
                                modelAttriList[j].dimension        = uiAttriList[i].dimension;
                                modelAttriList[j].preferredunit    = uiAttriList[i].preferredunit;
                                delete modelAttriList[i].tempStatus;
                                existingAttribute = true;
                            break;
                       }
                    }
                    if (existingAttribute === false) {
                        //add new entry
                        modelAttriList.push({
                                    "id"                : "NotYetCalulated",
                                    "internalName"      : "NotYetCalulated",
                                    "isDeployed"        : true,
                                    "isUsedInOther"     : false,
                                    "parentType"        : "NotYetCalulated",
                                    "nlsName"           : uiAttriList[i].nlsName,
                                    "type"              : uiAttriList[i].type,
                                    "maxLength"         : uiAttriList[i].maxLength,
                                    "defaultValue"      : uiAttriList[i].defaultValue,
                                    "isMandatory"       : uiAttriList[i].isMandatory,
                                    "isExposedTo3DXML"  : uiAttriList[i].isExposedTo3DXML,
                                    "resetWhenDuplicate": uiAttriList[i].resetWhenDuplicate,
                                    "resetWhenRevision" : uiAttriList[i].resetWhenRevision,
                                    "isReadOnly"        : uiAttriList[i].isReadOnly,
                                    "isIndexed"         : uiAttriList[i].isIndexed,
                                    "hasAuthValues"     : uiAttriList[i].hasAuthValues,
                                    "listofAuthValues"  : uiAttriList[i].listofAuthValues,
                                    "SixWTag"           : uiAttriList[i].SixWTag,
                                    "dimension"         : uiAttriList[i].dimension,
                                    "preferredunit"     : uiAttriList[i].preferredunit                           
                        });
                    }
                }                
                //Remove old attributes if have 
               modelAttriList = modelAttriList.filter(function (value, index, arr) {
                        return  (value.tempStatus !== undefined) ? false : true;});
                //var tbodyreflist = this.contentDiv.getElements('.attrstbody');
                /*if (this.model.get("id") === "AttributeSynchronization") {
                    AttributesSynchroView.UpdateSynchrosStsInTable(this.contentDiv);
                } else {*/
                AttributesLayoutUtilities.UpdateAttributesStsInTable(this.contentDiv);

                //}

                //ParamLayoutUtilities.updateIcon(true, theImageCell);
            },

            //show: function () {},
            destroy : function() {
                this.stopListening();
                this._parent.apply(this, arguments);
            }

        });

        return extendedView;
    });

/*@fullReview  ZUR 16/02/19 2017x Param Skeleton*/
/*global define, widget*/
/*jslint nomen: true*/
define('DS/ParameterizationSkeleton/Views/ParametersCommonView',
    [
        'UWA/Core',
        'UWA/Class/View',
        'DS/ParameterizationSkeleton/Views/ParameterizationDataModeling/AttributesLayoutView',
      'DS/ParameterizationSkeleton/Views/ParameterizationLifecycle/LifecycleView',
        'DS/ParameterizationSkeleton/Views/ParameterizationXCAD/ParamXCADLayoutView'
    ], function (UWA, View, AttributesLayoutView, LifecycleView, ParamXCADLayoutView) {

        'use strict';

        return View.extend({

            defaultOptions: {
                type: 'default'
            },

            init : function (options) {
                UWA.log("ParametersCommonView::init");
                UWA.log(options);
                this.options = options;
                this.childView = null;
            },

        // The ‘options’ object is passed via the ‘viewOptions’ specified in the Renderer at the Skeleton instantiation
            render: function () {
                //options = options || {options = {}};
                //options = UWA.clone(options || {}, false);
                var options = this.options,
                    commonViewSwitcher = this.getCommonView(options);

                if (commonViewSwitcher !== null) {
                    this.childView = commonViewSwitcher;
                    return commonViewSwitcher.render();
                }

                return null;//defaultView.render();
            },

            getCommonView : function (options) {

                if (options.domainid === "AttributeDef") {
                    return new AttributesLayoutView(options);
                }
                if (options.domainid === "XCADParameterization") {
                    return new ParamXCADLayoutView(options);
                }

                return new LifecycleView(options);
            },

            destroy : function() {
                this.childView.destroy();
                this.stopListening();
                this._parent.apply(this, arguments);
            }

        });
    });

