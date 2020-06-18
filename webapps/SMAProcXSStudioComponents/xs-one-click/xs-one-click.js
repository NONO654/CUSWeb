/* global */
(function (window) {
	'use strict';
	var toQueryString = window.DS.SMAProcSP.SPBase.JS.toQueryString;
	window.Polymer({
		is: 'xs-one-click',

		ready: function(){
			window.top.addEventListener('message', this.receiveMessage.bind(this), false);
		},

		getJSPURL : function(templateId, templateTitle, timestamp, simId, simTitle, contentType){
			//./common/emxFrameworkContextManager.jsp?forwardUrl='+forwardURL+'&SecurityContext=' +
			return this.$.dashboard.getMcsUri() + '/common/emxFrameworkContextManager.jsp?' +
				 'SecurityContext=' + encodeURIComponent(this.$.dashboard.getSecurityContext()) +
				 '&forwardUrl=/simulationcentral/smaTemplateOptionsEdit.jsp?SecurityContext=' +      encodeURIComponent(this.$.dashboard.getSecurityContext()) +
				  '&templateTitle='+encodeURIComponent(templateTitle)+
				  '&objectId=' + templateId + '&simId=' + simId + '&simTitle=' + simTitle  +'&contentType=' + contentType +
				  '&table=SMATemplate_Options' +
				  '&program=jpo.simulation.Template%3AgetOptions' +
				  '&postProcessJPO=jpo.simulation.Template%3AeditOptions' +
				  '&xmlAttribute=attribute_Definition&xmlTableTag=TemplateOptions' +
				  '&objectBased=false' +
          '&massUpdate=false' +
          '&pagination=0' +
				  '&TEMPLATE_EDIT_TIMESTAMP=' + timestamp;
		},

		openOneClick : function (templateId, templateTitle, simId, simTitle, contentType) {
			this.simId = simId;
			this.simTitle=simTitle;
			this.templateId = templateId;
			this.templateTitle = templateTitle;
			this.contentType = contentType;
			this.TEMPLATE_EDIT_TIMESTAMP = Date.now();
			this.$.templateEditFrame.src = this.getJSPURL(templateId, templateTitle, this.TEMPLATE_EDIT_TIMESTAMP, simId, simTitle, contentType);
		},

		receiveMessage : function (event) {
			var templateData;
			//Add check based on origin 'event.origin'
			try {
				templateData = JSON.parse(event.data);

			} catch (e) {
				templateData = {};
			}
			//if refresh is set to be true, widget is refreshed to load new data.
			if (templateData && templateData.refresh){
				this.refreshData();
			}
			if (templateData.TEMPLATE_EDIT_TIMESTAMP === this.TEMPLATE_EDIT_TIMESTAMP.toString()){
				event.stopPropagation();
				if (templateData.OPERATION === 'close'){
					this.fire('closeTemplate');
				} else if (templateData.OPERATION === 'refresh') {
					this.$.notification.logMessage({
						type: 'success',
						text: 'Save Successful',
						autoRemove: true
					});
					this.refreshData();
				}
				else if (templateData.OPERATION ==='showProperties'){
					//console.log('here' + templateData);
					var propertiesContext = {
						getSecurityContext: function() {
							return  templateData.CONTEXT;
						},
						getSelectedNodes: function() {
							return [{ getID: function() { return templateData.OBJECTID; } }];
						}
					};

					require(['DS/LifecycleControls/EditPropDialog'], function (EditPropDialog) {
						var propDlg = new EditPropDialog();
						propDlg.launchProperties(propertiesContext);
					}, function (error) {
						logger.warn('Failed to load LifecycleControls widget: ' + error, error);
					});
				}
				else if (templateData.OPERATION ==='showWidget'){
					var transientOptions = {
						mode: 'panel',
						height: 800,
						width: 700
					  };
					  var items = [];
					  var appId;

					//Object to display in lifecycle widget.
					var obj = {
						displayName : templateData.TITLE,
						envId : window.widget.getValue('x3dPlatformId'),
						objectId : templateData.OBJECTID,
						objectType : this.contentType,
						serviceId: '3DSpace'
					};
					if (templateData['WIDGET']==='lifeCycle'){
						appId = 'ENOLCMI_AP';
					}
					else {
						appId = 'SIMPRCW_AP';
					}
					items.push(obj);
					var pref = {
						data : {
							items : items
						},
						protocol: '3DXContent',
						widgetId : window && window.widget && window.widget.id,
						source : 'SIMEXPS_AP'
					};
					var widgetPref = {
						X3DContentId : JSON.stringify(pref)
					};
					var instance=this;
					require(['DS/TransientWidget/TransientWidget'], function (Transient) {
						if (appId === 'ENOLCMI_AP'){
							Transient.showWidget(appId, templateData.title, widgetPref, transientOptions);
						}
						else {
							if (appId === 'SIMPRCW_AP' && obj.objectType === 'Simulation'){
								Transient.showWidget(appId, templateData.title, widgetPref, transientOptions);
							}
							else {
								instance.$.notification.logMessage({
									type: 'warning',
									text: 'Selected object is not compatible.',
									autoRemove: true
								});
							}
						}


					}, function (error) {
						logger.warn('Failed to load LifecycleControls widget: ' + error, error);
					});

				}
				else if (templateData.OPERATION ==='showAttributeGroups'){

					var url = this.querySelector('#dashboard').getAuthenticatedJspUri('/simulationcentral/SMAAttributeGroups.jsp?' + toQueryString({
						objectId: templateData.OBJECTID
					}));
					var attributesWindow = window.open(url, '', 'width=1000,height=800');
				}

		  }

		},
		refreshData : function(){
			this.TEMPLATE_EDIT_TIMESTAMP = Date.now();
			this.$.templateEditFrame.src = this.getJSPURL(this.templateId, this.templateTitle, this.TEMPLATE_EDIT_TIMESTAMP, this.simId, this.simTitle, this.contentType);
		},

		behaviors: [window.DS.SMAProcSP.SPBase]
	});
}(this));
