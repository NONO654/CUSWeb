<%--
  RequirementStructureLinkToDecision.jsp - Link To Decision Dialog page.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program.

  static const char RCSID[] = "$Id: /web/requirements/RequirementStructureLinkToDecision.jsp 1.3.2.1.1.1.1.1 Wed Dec 03 15:12:00 2008 GMT ds-bcasto Experimental$";
--%>
<%-- @quickreview T25 	OEP 	12:12:10	: HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet
     @quickreview T25 	OEP 	12:12:18 	: HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview JX5			15:06:11	: Autoname checked by default
--%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%@include file="emxProductCommonInclude.inc"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>  

<%//Retrieves the suite key & other fields values.

    String suiteKey = emxGetParameter(request, "suiteKey");
    String formName = emxGetParameter(request, "formName");
    String fieldSelected = emxGetParameter(request, "fieldSelected");
    String fieldNameActual = emxGetParameter(request, "fieldNameActual");
    String fieldNameDisplay = emxGetParameter(request,
            "fieldNameDisplay");
    String fieldRadioSelected = emxGetParameter(request,
            "fieldRadioSelected");

    String strMsg1 = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.LinkToDecisionNotSelectedAnyCheckBoxOrRadioButton");

    String strMsg2 = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.LinkToDecisionNotSelectedAnyRadioButton");

    String strMsg3 = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.LinkToDecisionNotSelectedAnyCheckBox");

    String ENO_CSRF_TOKEN = (String)session.getAttribute("ENO_CSRF_TOKEN");
    if(ENO_CSRF_TOKEN != null){
    	session.setAttribute("ENO_CSRF_TOKEN_SAVED", ENO_CSRF_TOKEN);
    }
    
    String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxRequirements.form.create.autonamechecked");
  	if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
  		autonameChecked = "true";
  	}
	
%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<form name="decisionForm" method="post"
    onSubmit="javascript:submitForm(); return false">

<table border="0" cellpadding="10" cellspacing="2" width="100%">
    <tr>
        <br/>
        <br/>
        <!--For Choose Action Field-->
        <td class="label" width="200"><emxUtil:i18n localize="i18nId">emxRequirements.Label.ChooseAction
                             </emxUtil:i18n></td>

        <td nowrap="nowrap" class="field"><input name="chooseAction"
            type="radio" value="createNew" size="20" /> <emxUtil:i18n
            localize="i18nId">emxRequirements.Label.CreateNewDecision
                             </emxUtil:i18n> <br/>
        <input name="chooseAction" type="radio" value="AddExisting" /> <emxUtil:i18n
            localize="i18nId">emxRequirements.Label.AddExistingDecision
                             </emxUtil:i18n></td>
    </tr>

    <tr>
        <!--For Associate Decision Field-->
        <td class="label" width="200"><emxUtil:i18n localize="i18nId">emxRequirements.Label.AssociateDecisionTo
                             </emxUtil:i18n></td>

        <td nowrap="nowrap" class="field"><input name="associateToRel"
            type="checkbox" value="" size="20" /> <emxUtil:i18n
            localize="i18nId">emxRequirements.Label.RequirementRequirementRelationship
                             </emxUtil:i18n> <br/>
        <input name="associateToReq" type="checkbox" value="" /> <emxUtil:i18n
            localize="i18nId">emxRequirements.Label.NewRequirement
                             </emxUtil:i18n></td>
    </tr>
</table>
</form>

<script language="javascript" type="text/javaScript">

     //When Next Key Pressed on the form
        function submitForm()
        {
            var strURL           = "";
            var varSelected      = "";
            var selectedAction   = "";
            var formName         = '<xss:encodeForJavaScript><%=formName%></xss:encodeForJavaScript>';
            var fieldSelected    = '<xss:encodeForJavaScript><%=fieldSelected%></xss:encodeForJavaScript>';
            var fieldNameActual  = '<xss:encodeForJavaScript><%=fieldNameActual%></xss:encodeForJavaScript>';
            var fieldNameDisplay = '<xss:encodeForJavaScript><%=fieldNameDisplay%></xss:encodeForJavaScript>';
            var fieldRadioSelected = '<xss:encodeForJavaScript><%=fieldRadioSelected%></xss:encodeForJavaScript>';


            //Condition to test when both the check boxes are selected
            if((document.decisionForm.associateToRel.checked ==1) && (document.decisionForm.associateToReq.checked ==1)){
                        //set a variable with value 'both' when both the check boxes are selected
                        varSelected = "both";
            }
            else {
                        if(document.decisionForm.associateToRel.checked ==1){
                        //set a variable with value 'rel' when first check box for relationship is selected
                        varSelected = "rel";
                        }
                        else if(document.decisionForm.associateToReq.checked ==1) {
                        //set a variable with value 'req' when second check box for requirement is selected
                        varSelected = "req";
                        }
                        else{
                            //do nothing, dont initialize varSelected with any value.
                        }
            }

                //a variable that will hold the index number of the selected radio button
                for (i=0;i<document.decisionForm.chooseAction.length;i++){
                    if (document.decisionForm.chooseAction[i].checked==true)
                       var selectedOne=i;
                }

             //Display an alert when none of the check boxes and radio button are selected

            if((document.decisionForm.associateToReq.checked ==0 && document.decisionForm.associateToRel.checked ==0) && (!document.decisionForm.chooseAction[0].checked && !document.decisionForm.chooseAction[1].checked)) {
                        alert("<xss:encodeForJavaScript><%=strMsg1%></xss:encodeForJavaScript>");
             }    //Display an alert when none of the check boxes are selected
             else if(document.decisionForm.associateToReq.checked ==0 && document.decisionForm.associateToRel.checked ==0){
                 alert("<xss:encodeForJavaScript><%=strMsg3%></xss:encodeForJavaScript>");
             }    //Display an alert when none of the radio button are selected
              else if(!document.decisionForm.chooseAction[0].checked && !document.decisionForm.chooseAction[1].checked){
                 alert("<xss:encodeForJavaScript><%=strMsg2%></xss:encodeForJavaScript>");
             }
             else {


                           selectedAction = document.decisionForm.chooseAction[selectedOne].value;
                                //If the selected radio button value is 'createNew',construct the url with create component and append the required parameters to it.
                                if(selectedAction=="createNew"){
                                	
                                        strURL="../common/emxCreate.jsp?type=type_Decision&autoNameChecked="+"<%=autonameChecked%>"+"&typeChooser=true&nameField=both&vaultChooser=true&header=emxRequirements.Label.CreateNewDecisionStep2&postProcessURL=../requirements/MultiObjectSelectDecision.jsp&parentFormName="+formName+"&fieldNameActual="+fieldNameActual+"&fieldNameDisplay="+fieldNameDisplay+"&fieldSelected="+fieldSelected+"&fieldRadioSelected="+fieldRadioSelected+"&selected="+varSelected+"&selectedAction="+selectedAction+"&relationship=relationship_RequirementDecision&form=APPDecisionCreate&suiteKey=Requirements&HelpMarker=emxhelpdecisioncreate";

                                        getTopWindow().location.href = strURL;

                                }
                                else {

                                        //If the selected radio button value is 'AddExisting',construct the url with search page and append the required parameters to it.
                                         strURL="../common/emxFullSearch.jsp?parentFormName="+formName+"&field=TYPES=type_Decision&selection=multiple&cancelLabel=emxRequirements.Button.Cancel&searchmode=chooser&suiteKey=Requirements&table=RMTSearchDecisionsTable&showSavedQuery=True&excludeOIDprogram=emxRequirement:excludeDecisionObjects&searchCollectionEnabled=True&submitURL=../requirements/MultiObjectSelectDecision.jsp&frameName=searchPane&fieldNameActual="+fieldNameActual+"&fieldNameDisplay="+fieldNameDisplay+"&fieldSelected="+fieldSelected+"&fieldRadioSelected="+fieldRadioSelected+"&selected="+varSelected+"&selectedAction="+selectedAction;
                                         getTopWindow().location.href = strURL;

                                }
                            }
            return;
         }
    </script>
