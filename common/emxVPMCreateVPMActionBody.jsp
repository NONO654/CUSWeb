<%-- @quickreview SBM1 17:09:25 : IR-550969-3DEXPERIENCER2018x Fix to prevent XSS attacks --%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%
	final String ecaBaseType="PLMActionBase";
	final String defaultECAType="PLMDesignActionCusto";
%>
<html>
	<head>
		<title></title>
		
		
		<%@include file="../common/emxUIConstantsInclude.inc"%>
		<%@include file="../components/emxCalendarInclude.inc"%>
		<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
		
		
		
		<script language="javascript" type="text/javascript"
			src="../common/scripts/emxUICalendar.js"></script>
		<script language="javascript" type="text/javascript"
			src="../common/scripts/emxUIConstants.js"></script>
		<script language="javascript" type="text/javascript"
			src="../common/scripts/emxUIModal.js"></script>
		<script language="javascript" type="text/javascript"
			src="../common/scripts/emxUIPopups.js"></script>
	
		
		<script language="javascript">
			function validateForm(){
				//Check Type
				var selectedType = document.getElementById("type");
				if(selectedType!=null){
					if(selectedType.value == ""){
			            alert(
			            "<%=i18nNow.getI18nString("emxVPMCentral.Change.CreateECA.Warning.MandatoryAttr","emxVPMCentralStringResource",context.getSession().getLanguage())%>"
			            +
			            "<%=i18nNow.getI18nString("emxVPMCentral.Change.WebForm.Type.Label","emxVPMCentralStringResource",context.getSession().getLanguage())%>"
			            );
			            return false;
			        }
				}

				//Check Name
				var selectName = document.getElementById("PLMEntity.PLM_ExternalID");
				var selectAutoName = document.getElementById("autoname");
		        if(selectName!=null){
		        	if( !selectAutoName.checked ){
				        if(selectName.value == ""){
				        	alert(
				            "<%=i18nNow.getI18nString("emxVPMCentral.Change.CreateECA.Warning.MandatoryAttr","emxVPMCentralStringResource",context.getSession().getLanguage())%>"
				            +
				            "<%=i18nNow.getI18nString("emxVPMCentral.Change.WebForm.PLM_ExternalID.Label","emxVPMCentralStringResource",context.getSession().getLanguage())%>"
				            );
				            return false;
				        }
		        	}
		        }

		        //Check Description
		        var selectDescription = document.getElementById("PLMEntity.V_description");
		        if(selectDescription!=null){
			        if(selectDescription.value == ""){
			        	alert(
			            "<%=i18nNow.getI18nString("emxVPMCentral.Change.CreateECA.Warning.MandatoryAttr","emxVPMCentralStringResource",context.getSession().getLanguage())%>"
			            +
			            "<%=i18nNow.getI18nString("emxVPMCentral.Change.WebForm.V_description.Label","emxVPMCentralStringResource",context.getSession().getLanguage())%>"
			            );
			            return false;
			        }
		        }

		        //Check Planned Start Date < Planned End Date
		        var selectedStartDate = document.getElementById("PLMChgBase.V_start_date_msvalue");
		        var selectedEndDate = document.getElementById("PLMChgBase.V_end_date_msvalue");
		        if(selectedStartDate!=null && selectedEndDate!=null){
			        if(selectedStartDate.value != "" && selectedEndDate.value != ""){
			        	if(selectedStartDate.value > selectedEndDate.value){
			        		alert("<%=i18nNow.getI18nString("emxVPMCentral.Change.CreateECA.Warning.PlannedStartAndEndDates","emxVPMCentralStringResource",context.getSession().getLanguage())%>");
				            return false;
			        	}
			        }
		        }

		        //Check Duration is a Real
		        var selectedDuration = document.getElementById("PLMChgBase.V_duration");
				if(selectedDuration!=null){
			        if(selectedDuration.value != ""){
			        	if(isNaN(selectedDuration.value)){
			        		alert(
			        		"<%=i18nNow.getI18nString("emxVPMCentral.Change.CreateECA.Warning.NonNumericValue","emxVPMCentralStringResource",context.getSession().getLanguage())%>"
			        		+
			        		"<%=i18nNow.getI18nString("emxVPMCentral.Change.WebForm.V_duration.Label","emxVPMCentralStringResource",context.getSession().getLanguage())%>"
			        		);
			        		return false;
			        	}
			        }
				}

		        //Check Interval Time is a Real
		        var selectedInterval = document.getElementById("PLMChgBase.V_delIntervalTime");
				if(selectedInterval!=null){
			        if(selectedInterval.value != ""){
			        	if(isNaN(selectedInterval.value)){
			        		alert(
			        		"<%=i18nNow.getI18nString("emxVPMCentral.Change.CreateECA.Warning.NonNumericValue","emxVPMCentralStringResource",context.getSession().getLanguage())%>"
			        		+
			        		"<%=i18nNow.getI18nString("emxVPMCentral.Change.WebForm.V_delIntervalTime.Label","emxVPMCentralStringResource",context.getSession().getLanguage())%>"
			        		);
			        		return false;
			        	}
			        }
				}
				return true;
			}

		    var txtTypeChange = false;
		    var bAbstractSelect = false;

		    function showTypeSelector(){
		        txtTypeChange = true;
		        var strURL="emxTypeChooser.jsp?fieldNameActual=type&fieldNameDisplay=typeDisp&formName=createAction&ShowIcons=true&InclusionList=<%=java.net.URLEncoder.encode( ecaBaseType )%>&ObserveHidden=true&ReloadOpener=true&SelectAbstractTypes="+bAbstractSelect;
		        showModalDialog(strURL, 450, 350);
		    }

		    function clearDate(dateName){
		        var date = "document.editForm.elements[\"" + dateName + "\"].value = \"\";"
		        eval(date);

		        var dateMS = "document.editForm.elements[\"" + dateName + "_msvalue\"].value = \"\";"
		        eval(dateMS);

		        return;
		    }
		    
		    function autoNameValue() {
		    	var checkBox = document.getElementById("autoname");
		    	var selectName = document.getElementById("PLMEntity.PLM_ExternalID");
		        if( checkBox.checked ) {
		        	selectName.value = "";
		        	selectName.disabled = true;
		        	checkBox.focus();
		        }
		        else
		        {
		        	selectName.disabled = false;
		        }
		        return;
		      } 

	    </script>

</head>

<%
	String languageStr = request.getHeader("Accept-Language");

	String type = PropertyUtil.getSchemaProperty( ecaBaseType );
	String defaultType = PropertyUtil.getSchemaProperty( "type_PLMDesignAction" );
	
	String errorMessage = emxGetParameter(request, "errorMessage");

	String targetLocation = emxGetParameter(request, "targetLocation");

	StringBuffer parametersBuffer = new StringBuffer();
	Map parameters = request.getParameterMap();
	java.util.Set keys= parameters.keySet();
	Iterator keysItr = keys.iterator();

	while(keysItr.hasNext()){
		String key = (String) keysItr.next();
		String value[] = (String[])parameters.get(key);

		if(parametersBuffer!=null && !parametersBuffer.toString().isEmpty()){
			parametersBuffer.append("&");
		}
		parametersBuffer.append(key + "=" + value[0]);
	}

    %>

<body>
	<form name="editForm" id="createAction" method="post"
		action="../common/emxVPMCreateVPMActionProcessing.jsp?targetLocation=<%=XSSUtil.encodeForURL(context,targetLocation)%>"
		target=_parent>
		<emxUtil:localize id="i18n" bundle="emxVPMCentralStringResource"
			locale="<%=languageStr%>" />

		<table>
			<tr>
				<td class="requiredNotice"><emxUtil:i18n localize="i18n">emxVPMCentral.Change.CreateECA.Label.FieldsInRed</emxUtil:i18n>
			<tr>
			</tr>
		</table>

		<table>

			<!-- TYPE -->
			<tr>
				<td class="labelRequired"><emxUtil:i18n localize="i18n">emxVPMCentral.Change.WebForm.Type.Label</emxUtil:i18n>
				</td>
			</tr>

			<tr>
				<td class="inputField">
					<%
					String selectedType = emxGetParameter(request, "type");
					
					if(!(selectedType!=null && !selectedType.isEmpty())){
						selectedType = defaultType;
					}
					if( selectedType == null || selectedType.equals(""))
					{
						
					}
					
					%>
					<script> alert( <%=selectedType%> ); </script>
					<script> alert( <%=defaultType%> ); </script>
					<script> alert(<%=i18nNow.getTypeI18NString(selectedType,languageStr)%> ); </script>
					 <input type="hidden" name="type" id="type"
					value="<%=selectedType%>"> <input type="text"
					name="typeDisp"
					value="<%=i18nNow.getTypeI18NString(selectedType,languageStr)%>"
					readonly="readonly"> <input type=button name="" value="..."
					onClick="javascript:showTypeSelector()">
				</td>
			</tr>

			<!-- NAME -->
			<tr>
				<td class="labelRequired"><emxUtil:i18n localize="i18n">emxVPMCentral.Change.WebForm.Name.Label</emxUtil:i18n>
				</td>
			</tr>

			<tr>
				<td class="inputField">
					<%
					String selectedName = emxGetParameter(request, "PLMEntity.PLM_ExternalID");
					String disabled = "",checked="";
					if(!(selectedName!=null && !selectedName.isEmpty())){
						selectedName = "";
						disabled = "disabled";
						checked="checked";
					}
					%> <input type="text" value="<%=selectedName%>"
					name="PLMEntity.PLM_ExternalID"
					id="PLMEntity.PLM_ExternalID" onfocus="autoNameValue()"
					onkeypress="autoNameValue()" onclick="autoNameValue()"
					onblur="autoNameValue()" onselect="autoNameValue()"
					onkeydown="autoNameValue()" onchange="autoNameValue()" <%=disabled %> />

					<input type="checkbox" id="autoname" name="autoname"
					onClick="autoNameValue()" <%=checked %> />
					<%= i18nNow.getI18nString("emxComponents.Common.AutoName","emxComponentsStringResource",context.getSession().getLanguage()) %>
				</td>
			</tr>
			
			<!-- DESCRIPTION -->
			<tr>
				<td class="labelRequired"><emxUtil:i18n localize="i18n">emxVPMCentral.Change.WebForm.V_description.Label</emxUtil:i18n>
				</td>
			</tr>

			<tr>
				<td class="inputField">
					<%
					String selectedDescription = emxGetParameter(request, "PLMEntity.V_description");
					if(!(selectedDescription!=null && !selectedDescription.isEmpty())){
						selectedDescription = "";
					}
					%> <textarea cols="35" rows="3"
						name="PLMEntity.V_description"
						id="PLMEntity.V_description"><%=selectedDescription%></textarea>
				</td>
			</tr>


			<!-- ABSTRACT -->
			<tr>
				<td class="label"><emxUtil:i18n localize="i18n">emxVPMCentral.Change.WebForm.V_abstract.Label</emxUtil:i18n>
				</td>
			</tr>

			<tr>
				<td class="inputField">
					<%
					String selectedAbstract = emxGetParameter(request, "PLMChgBase.V_abstract");
					if(!(selectedAbstract!=null && !selectedAbstract.isEmpty())){
						selectedAbstract = "";
					}
					%> <input type="text" value="<%=selectedAbstract%>"
					name="PLMChgBase.V_abstract"
					id="PLMChgBase.V_abstract">
				</td>
			</tr>

			<!-- PRIORITY -->
			<tr>
				<td class="label"><emxUtil:i18n localize="i18n">emxVPMCentral.Change.WebForm.V_priority.Label</emxUtil:i18n>
				</td>
			</tr>
			<tr>
				<td class="inputField">
					<%
					String selectedPriority = emxGetParameter(request, "PLMChgBase.V_priority");
					if(!(selectedPriority!=null && !selectedPriority.isEmpty())){
						selectedPriority = "";
					}
					%> <select name="PLMChgBase.V_priority"
					id="PLMChgBase.V_priority">
						<option value="1" <%if(selectedPriority.equals("1")){%> selected
							<%}%>>
							<emxUtil:i18n localize="i18n">emxVPMCentral.Change.WebForm.V_priority.Value.Low</emxUtil:i18n>
						</option>
						<option value="2" <%if(selectedPriority.equals("2")){%> selected
							<%}%>>
							<emxUtil:i18n localize="i18n">emxVPMCentral.Change.WebForm.V_priority.Value.Medium</emxUtil:i18n>
						</option>
						<option value="3" <%if(selectedPriority.equals("3")){%> selected
							<%}%>>
							<emxUtil:i18n localize="i18n">emxVPMCentral.Change.WebForm.V_priority.Value.High</emxUtil:i18n>
						</option>
				</select>
				</td>
			</tr>

			<!-- PLANNED START DATE -->
			<tr>
				<td class="label"><emxUtil:i18n localize="i18n">emxVPMCentral.Change.WebForm.V_start_date.Label</emxUtil:i18n>
				</td>
			</tr>

			<tr>
				<td class="inputField">
					<%
					String selectedStartDate = emxGetParameter(request, "PLMChgBase.V_start_date");
					if(!(selectedStartDate!=null && !selectedStartDate.isEmpty())){
						selectedStartDate = "";
					}
					String selectedStartDateMSValue = emxGetParameter(request, "PLMChgBase.V_start_date_msvalue");
					if(!(selectedStartDateMSValue!=null && !selectedStartDateMSValue.isEmpty())){
						selectedStartDateMSValue = "";
					}
					%> <input type="text" readonly="readonly"
					value="<%=selectedStartDate%>"
					name="PLMChgBase.V_start_date"
					id="PLMChgBase.V_start_date"> <input type="hidden"
					value="<%=selectedStartDateMSValue%>"
					name="PLMChgBase.V_start_date_msvalue"
					id="PLMChgBase.V_start_date_msvalue"> <a
					href="javascript:showCalendar2('editForm','PLMChgBase.V_start_date','')">
						<img border="0" name="img5" valign="absmiddle"
						src="../common/images/iconSmallCalendar.gif">
				</a> <a href="javascript:clearDate('PLMChgBase.V_start_date')">
						<emxUtil:i18n localize="i18n">emxVPMCentral.Change.CreateECA.Button.Clear</emxUtil:i18n>
				</a>
				</td>
			</tr>


			<!-- PLANNED END DATE -->
			<tr>
				<td class="label"><emxUtil:i18n localize="i18n">emxVPMCentral.Change.WebForm.V_end_date.Label</emxUtil:i18n>
				</td>
			</tr>

			<tr>
				<td class="inputField">
					<%
					String selectedEndDate = emxGetParameter(request, "PLMChgBase.V_end_date");
					if(!(selectedEndDate!=null && !selectedEndDate.isEmpty())){
						selectedEndDate = "";
					}
					String selectedEndDateMSValue = emxGetParameter(request, "PLMChgBase.V_end_date_msvalue");
					if(!(selectedEndDateMSValue!=null && !selectedEndDateMSValue.isEmpty())){
						selectedEndDateMSValue = "";
					}
					%> <input type="text" readonly="readonly"
					value="<%=selectedEndDate%>" name="PLMChgBase.V_end_date"
					id="PLMChgBase.V_end_date"> <input type="hidden"
					value="<%=selectedEndDateMSValue%>"
					name="PLMChgBase.V_end_date_msvalue"
					id="PLMChgBase.V_end_date_msvalue"> <a
					href="javascript:showCalendar2('editForm','PLMChgBase.V_end_date','')">
						<img border="0" name="img5" valign="absmiddle"
						src="../common/images/iconSmallCalendar.gif">
				</a> <a href="javascript:clearDate('PLMChgBase.V_end_date')">
						<emxUtil:i18n localize="i18n">emxVPMCentral.Change.CreateECA.Button.Clear</emxUtil:i18n>
				</a>
				</td>
			</tr>

		</table>

		<%if(errorMessage!=null && !errorMessage.isEmpty()){
			%>
		<script language="javascript">
				alert("<%=XSSUtil.encodeForJavaScript(context, errorMessage)%>");
			</script>
		<%
		}
		%>
	
</body>

</html>

