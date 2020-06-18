define('DS/EngineeringItemCmd/SetPartNumberCmd/setPartNumberListView', [
        'UWA/Core',
        'UWA/Class/View',
        'DS/Handlebars/Handlebars',
        'DS/UIKIT/Spinner',
        'DS/UIKIT/Input/Text',
        'DS/UIKIT/Scroller',
        'DS/UIKIT/Tooltip',
        'i18n!DS/EngineeringItemCmd/assets/nls/ExposedCmdsNls.json',
        'text!DS/EngineeringItemCmd/SetPartNumberCmd/setPartNumberListView.html',
        'css!DS/EngineeringItemCmd/SetPartNumberCmd/setPartNumberListView.css'
    ],
    function(UWA, View, Handlebars, Spinner, Text, Scroller, Tooltip, nlsKeys , HTMLsetPartNumberListView) {
        'use strict';
        var MAX_LENGTH = 256 ;
        var setPartNumberListView = View.extend({
            name: 'setPartNumberListView',
            tagName: 'div',
            collection: null, //new links([]),
            toupdate: null,
            spinner: null,
            setCollection: function(collection) {
                var that = this;
                this.collection = collection;
                // IDENTIFY WHICH ARE THE ITEM TO BE UPDATED
                this.toupdate = collection.filter(function(item) {
                    return item.oldpartnumber !== item.newpartnumber;
                });
                this.toupdate.check = function(id, newvalue) {
                    // IE :(
                    var exist = this.filter(function (item) {
                        return item.id === id;
                    })[0];
                    if (UWA.is(exist, 'object')) {
                        exist.newpartnumber = newvalue;
                    } else {
                        // IE :(
                        var item = that.collection.filter(
                          function(item) {
                              return item.id === id;
                          }
                        )[0];
                        item.newpartnumber = newvalue;
                        this.push(item);
                    }
                };
                return this;
            },
            getPendingChanges: function() {
                return this.toupdate;
            },
            destroy: function () {
              this._parent();
              this.collection = null;
            },
            render: function() {
                this.container.addClassName('setPartNumberListView-container');
                if (!this.collection) {
                    if (!this.spinner) {
                        this.spinner = new Spinner().inject(this.container);
                    }
                    this.spinner.show();
                } else {
                    this.spinner.hide();
                    var scrollable = new Scroller({
                        element: new UWA.Element('div', {
                            id: 'scrollable-list'
                        })
                    }).inject(this.container);
                    var template = Handlebars.compile(HTMLsetPartNumberListView);
                    scrollable.elements.container.setHTML(template({
                        engItem: this.collection,
                        engItennls: nlsKeys.get('engineering_item_title'),
                        oldpartnumbernls: nlsKeys.get('eng.partNumber.old'),
                        newpartnumbernls: nlsKeys.get('eng.partNumber.new')
                    }));
                    var that = this;
                    var rows = this.container.querySelectorAll('.set-partnumber-row');
                    // IE :(
                    Array.prototype.forEach.call(rows, function(row) {

                    	//Adding Tooltip for Old Part Number -Start
                        var oldPartNumberContainer = row.querySelector('.container-old-partnumber');
                        var actualOLDPartNumber=oldPartNumberContainer.innerText;

                        if(actualOLDPartNumber) {
                            new Tooltip({
                                target: row.querySelector('.container-old-partnumber'),
                                body: actualOLDPartNumber
                            });
                        }
                    	//Adding Tooltip for Old Part Number -End

                        var id = row.getAttribute('data-id');
                        var textinputcontainer = row.querySelector('.container-input-field');
                        var newPartNumberFormula = (textinputcontainer.innerText) ? textinputcontainer.innerText : "|@|FREE|@|"; // To add input textbox if formula is not defined

                        var value = '';
                        textinputcontainer.innerHTML = '';

                        if (newPartNumberFormula == "|@|FREE|@|")
                        	value = actualOLDPartNumber; // To populate the old part number value inside input textbox if formula/BL is not defined

                        var formulaArray;
                    	formulaArray = newPartNumberFormula.split('|@|');

                    	if(formulaArray[0] =="")
                    		formulaArray.shift();

                    	if(formulaArray[formulaArray.length-1] =="")
                    		formulaArray.pop();

                        var newPartNumberDiv = new UWA.Element('div', {
                        	id: 'newPartNumber',
                        	value: newPartNumberFormula,
                        	objid:id,
                        	oldpartnumber: actualOLDPartNumber
                        });
                        newPartNumberDiv.inject(textinputcontainer);

                        for (var i=0;i<formulaArray.length;i++) {
                        	if(formulaArray[i] == "FREE") {
                        		var TextInput = new Text({
                                    placeholder: nlsKeys.get('edit_part_number.placeholder'),
                                    className: 'new-partnumber-input-text',
                                    maxlength: MAX_LENGTH,
                                    value: value
                                    /*events: {
                                        onChange: function(evt) {
                                            that.toupdate.check(id, evt.target.value);
                                        }
                                    }*/
                                });
                                TextInput.inject(newPartNumberDiv);

                                /*if (row.querySelector('.container-input-field').className.indexOf('editable-input-field') < 0) {
                                	TextInput.disable();
                                }*/

                        	}else {
                        		var displayValue = formulaArray[i];
                        		if(formulaArray[i].contains('@@<counter>@@')) {
                        			displayValue=displayValue.replace('counter', nlsKeys.get('eng.partNumber.counter'));
                        			displayValue=displayValue.replace('@@<', '<');
                        			displayValue=displayValue.replace('>@@', '>');
                        		}

                        		var spanNewPartNumberFixedText = new UWA.Element('span', {
                                	id: 'newPartNumberFixedText',
                                	value: formulaArray[i]
                                });
                        		spanNewPartNumberFixedText.innerText=displayValue;
                        		spanNewPartNumberFixedText.inject(newPartNumberDiv);
                        	}
                        }
                    });
                }
                return this;
            },

            getDataToBeUpdated: function() {
            	//Read data from UI - Start
            	var toUpdateArray =[];
            	var tableData = document.querySelectorAll('#newPartNumber');

            	var returnValue;

            	for(var i=0;i<tableData.length;i++) {
            		var toUpdateObj={};
            		var formula = tableData[i].value;
            		var formulaBackup = formula;
            		var objId = tableData[i].getAttribute('objid');
            		var oldPartNumber = tableData[i].getAttribute('oldpartnumber');
            		var childElements = tableData[i].getChildren();

            		for (var j=0;j<childElements.length;j++) {
            			if(childElements[j].tagName === "INPUT") {
            				var inputTag = childElements[j];
            				var inputtedValue = inputTag.value;
            				formula=formula.replace("|@|FREE|@|", inputtedValue);
            			}
            		}

            		if(!formulaBackup.contains("|@|FREE|@|") && formulaBackup != oldPartNumber) { // To update Part Number for BL or formula without text box use cases
            			toUpdateObj.id=objId;
            			toUpdateObj.newpartnumber=formulaBackup;
            			toUpdateArray.push(toUpdateObj);
            		}
            		else if(formula !== formulaBackup.replace(/\|\@\|FREE\|\@\|/g,"") && formula != oldPartNumber) { // Update only if at least one of the text boxes in a row is inputted and if old and new Part Number is different
            			toUpdateObj.id=objId;
            			toUpdateObj.newpartnumber=formula;
            			toUpdateArray.push(toUpdateObj);
            		}
            		else if(formula=="" && oldPartNumber) { // To support clear existing Part Number use case (only in case if formula/BL is not defined)
            			toUpdateObj.id=objId;
            			toUpdateObj.newpartnumber="";
            			toUpdateArray.push(toUpdateObj);
            		}
            	}
            	//Read data from UI - End

                return toUpdateArray;
            }
        });
        return setPartNumberListView;

    });

define('DS/EngineeringItemCmd/SetPartNumberCmd/SetPartCmd', [
    'UWA/Core',
    'DS/ApplicationFrame/Command',
    'DS/ENOXEngineerCommonUtils/XENModal',
    'DS/UIKIT/Input/Text',
    'DS/Utilities/Utils',
    'DS/ENOXEngineerCommonUtils/XENMask',
    'UWA/Class/View',
    'DS/ENOXEngineerCommonUtils/xEngAlertManager',
    'DS/EngineeringItemCmd/SetPartNumberCmd/setPartNumberListView',
    'DS/ENOXEngineerCommonUtils/XENPlatform3DXSettings',
    'DS/ENOXEngineerCommonUtils/PromiseUtils',
    'DS/ENOXEngineerCommonUtils/XENGenericHttpClient',
    'DS/ENOXEngineerCommonUtils/XENCommandsAppContextProxy',
    'DS/PlatformAPI/PlatformAPI',
    'DS/ENOXEngineerCommonUtils/XENWebInWinHelper',
    'i18n!DS/EngineeringItemCmd/assets/nls/ExposedCmdsNls.json'
], function(
    UWA,
    AFRCommand,
    XEngineerModal,
    Text,
    Utils,
    Mask,
    UWAView,
    xEngAlertManager,
    PartNumberListView,
    XENPlatform3DXSettings,
    PromiseUtils,
    xAppWSCalls,
    XENCommandsAppContextProxy,
    PlatformAPI,
    XENWebInWinHelper,
    nlsKeys
) {
    'use strict';

    var SetPartNumber = AFRCommand.extend({
        _setPartNumberListView: null,
        items: [],
        modal: null,
        init: function(options) {
            options = UWA.extend(options, {
                isAsynchronous: false
            });
            this._parent(options);
            //preload setting
            XENCommandsAppContextProxy.loadCommandsSetting();
            this._initCommandPrereqs();

        },
        isUserGranted: function(){
            if(this.grantingPromise)
                return this.grantingPromise;
        this.grantingPromise =  PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject){               
                XENCommandsAppContextProxy.loadCommandsSetting()
                                            .then(function(settings){
                                                if(settings && settings.isGrantedEnterpriseExtension){
                                                    resolve(true);
                                                }else{
                                                    reject('user is not granted');
                                                }
                                            }).catch(function(reason){
                                                console.error(reason);
                                                reject('some failure') ;
                                            });
            });
         return  this.grantingPromise;
        },
        _initCommandPrereqs: function () {
            var that = this;
            if (this._initPromise) return this._initPromise;
            this._initPromise = PromiseUtils.wrappedWithCancellablePromise(function (resolve, reject) {
                XENPlatform3DXSettings.discoverRelated3DXPlatform()
                    .then(function () {
                        that.isUserGranted().then(function(){
                            XENCommandsAppContextProxy.getAppContextPromise(that).then(function () {
                                that._SelectorManager = that.getSelectorManager();
                                if (null !== that._SelectorManager) {
                                    if (undefined !== that._SelectorManager.onChange) {
                                        var debounceSelection = Utils.debounce(function (data) {
                                            that._checkSelection(data);
                                        }, 100);
                                        that._SelectorManager.onChange(debounceSelection);
                                    } else {
                                        console.warn('###Define set part number Cmd / The onChange() function is not implemented !');
                                    }
                                }

                                
                                that.bindEditModeListener();
                                // that.buidModal();

                                if(that.options.context && 
                                    typeof that.options.context.getEditMode ==="function"
                                    ){
                                        if(!that.options.context.getEditMode())
                                              return   that.disable();
                                    }

                                that._checkSelection(); // check the selectection first
                            }).catch(function(reason){
                                xEngAlertManager.errorAlert(nlsKeys.get('eng.ui.error.command.init.failed'));
                            });
                            resolve(true);
                        }).catch(function(reason){
                            console.error(reason);
                            that.disable();
                            resolve(false);
                        });
                     
                       
                    }).catch(function (reason) {
                        xEngAlertManager.errorAlert(nlsKeys.get('eng.ui.error.command.init.failed'));
                        that.disable();
                        reject();
                    });
            });
        },
        bindEditModeListener: function(){
            var that =this;
            if(that.options.context && 
                typeof that.options.context.addEvent ==="function"
                ){
                    that.options.context.addEvent('editModeModified', function(state) {
                        if (state === true) {
                            that._checkSelection();
                        } else {
                            that.disable();
                        }
                    });
                }
        },
        _checkSelection: function () {
            var that  =this;
            if(that.options.context && 
                typeof that.options.context.getEditMode ==="function"
                ){
                    if(!that.options.context.getEditMode())
                          return   that.disable();
                }

            if (!Array.isArray(that.options.context.getSelectedNodes()) ||
                    that.options.context.getSelectedNodes().length === 0) {
                        return that.disable();
            }else{
                var SelectedNodes = that.options.context.getSelectedNodes();
                for (var  i = 0; i < SelectedNodes.length; i++) {
                    var node = SelectedNodes[i];
                    if(!node || !node.getID()){ // for not saved items
                        return that.disable();
                    }
                    if(node.options.type === 'VPMReference') continue;

                    if( node.options.type === 'Drawing'|| 
                        !node.options.padgrid ||  
                        node.options.padgrid['ds6w:globalType'] !=='ds6w:Part'){
                        return that.disable();
                    }
                }
                that.enable();
            }

        },
        _buildSetPartNumDialog: function() {
            if( this._setPartNumberListView ) {
              this._setPartNumberListView.destroy();
              this._setPartNumberListView = null;
            }
            var that = this;
            that.buidModal();
            that._setPartNumberListView = new PartNumberListView();
            that._setPartNumberListView.render().inject(that.modal.getBody());
            that.modal.show();
            that.retrievePartNumber();
        },
        destroyView: function(){
            var that = this;
            if(that._setPartNumberListView){
                that._setPartNumberListView.destroy();
                that._setPartNumberListView =null;
            }
            if(that.modal && that.modal.isNotDestroyed()){
                that.modal.dispose();
                that.modal = null;
            }
                

            if(XENWebInWinHelper)
                XENWebInWinHelper.closePanel();
        },
        buidModal: function() {
            var that = this;
            this.modal = new XEngineerModal({
                title: nlsKeys.get("edit_part_number"),
                className: 'set-partNumber-modal',
                withFooter: true,
                customFooter:function(){
                    return '<button type="button" name="okButton" class="btn btn-primary">' + nlsKeys.get('eng.ui.button.ok') + '</button>' +
                    '<button type="button" name="cancelButton" class="btn btn-default">' + nlsKeys.get('eng.ui.button.cancel') + '</button>';
                },
                persitId:'xen-edit-part-number',
                minSize:{
                  width:700,
                  height:300
                },
                relatedCommand: that,
                onClose:function(){
                  that.destroyView();
                  that.end();
                  that.modal = undefined;
                },
                onValidate: function(){
                 

                  //var collection = that._setPartNumberListView.getPendingChanges();
                  var collection = that._setPartNumberListView.getDataToBeUpdated();
                  if (!collection.length) {
                      that.destroyView();
                      that.end();
                      that.modal = undefined;
                      return;
                  }
                  Mask.mask(that.modal.getBody());
                  that.updatePartNumberAttr(collection.map(function(item) {
                      return {
                          physicalid: item.id,
                          partNumber: item.newpartnumber
                      };
                  })).then(function(data) {
                      //Notify all applications
                      that.options.context.author && that.options.context.author(true);
                      that.options.context.refreshView && that.options.context.refreshView({
                          modified: that.formatForRefreshView(data)
                      });
                      PlatformAPI.publish("XEN/PUBLIC_EVENT/ENGINEERING_ITEM/PART_NUMBER_UPDATED", data);
                      //notification for webinWin Solidworks
                      PlatformAPI.publish('webinwin:web:notification', JSON.stringify({
                          'operation': 'engineering/setPartNumber',
                          'operationVersion': '1.0',
                          'content': data
                      }));

                      //notification catiaV5
                      XENWebInWinHelper.notifyUpdatedEnterpriseItem(data);
                      
                      if(that.modal && that.modal.isNotDestroyed())
                      Mask.unmask(that.modal.getBody());

                      that.destroyView();
                      that.end();
                  }).catch(function(errors) {
                      console.error(errors);
                      xEngAlertManager.errorAlert(nlsKeys.get('edit_part_number.errorset'));

                      if(that.modal && that.modal.isNotDestroyed())
                      Mask.unmask(that.modal.getBody());
                      that.destroyView();
                      that.end();
                  });
                }
              });

        },
        formatForRefreshView: function(data){
            if(!data || !Array.isArray(data.references)) return [];

            return data.references.map(function(item){
                return {
                    physicalid: item.physicalid,
                    attributes:[{
                        name: "ds6wg:EnterpriseExtension.V_PartNumber",
                        value: item.partNumber
                    }]
                }
            })
        },
        getProvidedSC: function(){
            if(!this.context || !this.options.context || !this.options.context.getSecurityContext) return null;

            var _sc  = this.options.context.getSecurityContext() || {};
             var value = _sc.SecurityContext;
             if(!value) return null;
            if(value.startsWith('ctx::'))
                value = value.substring(5);
            XENPlatform3DXSettings.setDefaultSecurityContext(value);
            return value;
        },
        getSelectorManager: function () {
            if (this.options.context&& this.options.context.getPADTreeDocument)
                return this.options.context.getPADTreeDocument().getXSO();
            else
                return null;
        },
        execute: function() {
            var that = this;
            XENCommandsAppContextProxy.getAppContextPromise(this).then(function(context){

                if (!Array.isArray(that.options.context.getSelectedNodes()) ||
                    that.options.context.getSelectedNodes().length === 0) {
                    throw new Error('No Selected Items!');
                }

                that.items = that.options.context.getSelectedNodes().map(function(item) {
                    return {
                        physicalId: item.getID(),
                        name: item.getLabel(),
                        partNumber: item.options.grid['ds6wg:EnterpriseExtension.V_PartNumber']
                    };
                });
                that.items = that.items.reduce(function(result, item){
                  var idx = result.filter((function(cp){
                    return item.physicalId === cp.physicalId;
                  }))[0];
                  if (!UWA.is(idx)) {
                    result.push(item);
                  }
                  return result;
                }, []);

                var needSC = (!that.getProvidedSC());

                XENPlatform3DXSettings.bindCommandsToABackend(needSC /* need to retrieve SC */).then(function(){
                    that.isUserGranted().then(function(){
                        that._buildSetPartNumDialog();
                    }).catch(function(reason){
                        console.error(reason);
                        xEngAlertManager.errorAlert(nlsKeys.get("error.not.granted"));
                    });
                }).catch(function(error){
                    console.error(error);
                    //notify the user
                    xEngAlertManager.errorAlert(nlsKeys.get("error.contact.admin"));
                })

            }).catch(function(error){
                console.error(error);
                xEngAlertManager.errorAlert(nlsKeys.get("error.contact.admin"));

            });


        },
        retrievePartNumber: function() {
            var that = this;
            var physicalIds = this.items.map(function(item) {
                return item.physicalId;
            });
            this.retrievePartNumberAttr(physicalIds).then(function(data) {
                that._setPartNumberListView.destroy();
                that._setPartNumberListView.setCollection(data.references.map(function(current) {
                    // IE :(
                    var item = that.items.filter(function(item) {
                        if (item.physicalId === current.physicalid) {
                            return true;
                        }
                        return false;
                    })[0];
                    if(current.status === 'error') {
                      xEngAlertManager.errorAlert(nlsKeys.get('edit_part_number.errorretrieve.item').replace("{name}", item.name));
                      throw new Error('BR execution for item ' + item.name + ' has failed!');
                    }
                    return {
                        id: item.physicalId,
                        name: item.name,
                        oldpartnumber: current.partNumber,
                        editable: (current.status !== 'computed') ? true : false,
                        newpartnumber: current.computedPartNumber
                    };
                })).render().inject(that.modal.getBody());
                XENWebInWinHelper.commandViewReady();
            }).catch(function(errors) {
                console.warn(errors);
                xEngAlertManager.errorAlert(errors.message);

                if(that.modal && that.modal.isNotDestroyed())
                    Mask.unmask(that.modal.getBody());

                xEngAlertManager.errorAlert(nlsKeys.get('edit_part_number.errorretrieve'));
                that.destroyView();
                that.end();
            });
        },

        getTargetedNode: function() {
            var nodes = this.options.context.getSelectedNodes();
            return nodes.length > 0 ? nodes[0] : null;
        },
        retrievePartNumberAttr: function(physicalIds) {
            var myRetrievePartNumCommand = XENPlatform3DXSettings.getCommand('mcs_retrievePartNumber');
            var payload = {
                references: physicalIds.map(function(physicalid) {
                    return {
                        physicalid: physicalid
                    };
                })
            };
            return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject) {
                xAppWSCalls.perform(myRetrievePartNumCommand, JSON.stringify(payload)).then(function(res) {
                    //app.core.settingManager.setApplicationMode('authoring');

                	// Sorting the result in the order of payload - start
                	var payloadArray=payload.references;

                	if(payloadArray.length>1) {
                    	var resultJson = {};
                    	var resArray=res.references;
                    	var phyId;
                		for (var i=0;i<resArray.length;i++)
                			resultJson[resArray[i].physicalid] = resArray[i];

                    	var sortedResArray=[];
                    	for (var i=0; i<payloadArray.length; i++)
                    		sortedResArray.push(resultJson[payloadArray[i].physicalid]);

                    	res.references=sortedResArray;
                	}
                	// Sorting the result in the order of payload - end

                    return resolve(res);
                }).catch(function(errors) {
                    reject(errors);
                });
            });
        },
        updatePartNumberAttr: function(references) {
            var myUpdatePartNumCommand = XENPlatform3DXSettings.getCommand('mcs_setPartNumber');

            var payload = {
                references: references
            };
            return PromiseUtils.wrappedWithCancellablePromise(function(resolve, reject) {
                xAppWSCalls.perform(myUpdatePartNumCommand, JSON.stringify(payload)).then(function(res) {
                    //app.core.settingManager.setApplicationMode('authoring');
                    return resolve(res);
                }).catch(function(errors) {
                    reject(errors);
                });
            });
        }
    });
    return SetPartNumber;
});

