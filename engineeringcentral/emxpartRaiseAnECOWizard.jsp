<%--  emxpartRaiseAnECOWizard.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%
  String jsTreeID           = emxGetParameter(request,"jsTreeID");
  String objectId           = emxGetParameter(request,"objectId");
  String suiteKey           = emxGetParameter(request,"suiteKey");

  String selectedParts      = (String)session.getAttribute("selectedParts");

  String checkedButtonValue = emxGetParameter(request,"checkedButtonValue");
  String Relationship       =emxGetParameter(request,"Relationship");
  boolean bConfig = false; //IR:072877
  String sParentPolicyClass  ="";
  StringTokenizer sObjectIdTok = new StringTokenizer(selectedParts, ",",false);
  boolean isPart = true;
  while (sObjectIdTok.hasMoreTokens()) {
    String passedId = sObjectIdTok.nextToken();
	String strObjectId = passedId.substring(0,passedId.indexOf("|")).trim();
	DomainObject domObj = new DomainObject(strObjectId);
	String strType = PropertyUtil.getSchemaProperty(context,"type_Part");
				if(!domObj.isKindOf(context,strType)){
				isPart = false;
				break;
			}
  }
  StringList memberIds = new StringList();

    String strIds = "";

  if (selectedParts != null)
  {
	  StringList strlParts = FrameworkUtil.split(selectedParts , ",");

	  Iterator itrParts = strlParts.iterator();

	  StringList strlTemp = null;
	  String strPartId = null;

	  int k = 0;

	  while (itrParts.hasNext())
	  {
		  strlTemp = FrameworkUtil.split((String) itrParts.next(), "|");
		  strPartId = (String) strlTemp.get(0);
		  memberIds.add(strPartId);

		//IR:072877
	      DomainObject doPart = new DomainObject(strPartId);
          String policyClassification   = "policy.property[PolicyClassification].value";
          sParentPolicyClass      = doPart.getInfo(context,policyClassification);
          bConfig="Unresolved".equalsIgnoreCase(sParentPolicyClass);         
          if( bConfig ){   
              %>
                         <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
                         <script language="javascript">
                           alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.RaiseECR.PerformMassChange.Configured</emxUtil:i18nScript>");                           
                           //window.parent.location = "../common/emxCloseWindow.jsp";
                           getTopWindow().closeWindow();
                        </script>
                  
                  <%}
          
          
		  if (k == 0)
		  {
			  strIds =  strPartId;
		  }
		  else
		  {
		  	strIds =  strIds + "~" + strPartId;
		  }

		  k++;
	  }
  }

  i18nNow i18nnow = new i18nNow();
  
  //Multitenant
  //String strContentLabel=i18nnow.GetString("emxEngineeringCentralStringResource", context.getSession().getLanguage(), "emxEngineeringCentral.RaiseECO.CreateAnECO");// IR:042045
  String strContentLabel=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.RaiseECO.CreateAnECO");
  //Multitenant
  //String someString =i18nnow.GetString("emxEngineeringCentralStringResource", context.getSession().getLanguage(), "emxEngineeringCentral.RaiseECO.SearchAnECO");// IR:042045
  String someString =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.RaiseECO.SearchAnECO");

  String modetype = "";
  String strDefaultPolicy = "policy_ECO";

  String smbPolicyFilterForECO = ":Policy!=policy_DECO,policy_TeamECO";

  String sCreateURL = "../common/emxCreate.jsp?form=type_CreateECO&type=type_ECO&policy=ECO&typeChooser=true&nameField=autoname&ExclusionList=type_DECO&header=" + strContentLabel + "&submitAction=insertContent&CreateMode="+modetype+"&suiteKey=EngineeringCentral&postProcessURL=../engineeringcentral/emxpartWhereUsedECOPostProcess.jsp" + "&prevmode=false&Relationship="+Relationship+"&HelpMarker=emxhelpecocreate&checkboxValue=unchecked&preProcessJavaScript=preProcessInCreateECO&checkedButtonValue=";
  String sCreateMassChangeURL = "../common/emxCreate.jsp?form=type_CreateECO&type=type_ECO&policy=ECO&typeChooser=true&nameField=autoname&ExclusionList=type_DECO&header=" + strContentLabel + "&submitAction=insertContent&HelpMarker=emxhelpecocreate&CreateMode="+modetype+"&suiteKey=EngineeringCentral&postProcessURL=../engineeringcentral/emxpartWhereUsedECOPostProcess.jsp" + "&prevmode=false&Relationship="+Relationship+"&checkboxValue=checked&preProcessJavaScript=preProcessInCreateECO&checkedButtonValue=";
  
  String sExistURL =  "../common/emxFullSearch.jsp?field=TYPES=type_ECO" + smbPolicyFilterForECO + ":CURRENT=policy_ECO.state_Create,policy_ECO.state_DefineComponents,policy_ECO.state_DesignWork&HelpMarker=emxhelpecrexistingsearch&table=ENCGeneralSearchResult&selection=single&submitURL=../engineeringcentral/emxEngrRaiseECRECOHiddenProcess.jsp&calledMethod=RaiseECO&jsTreeID=" + jsTreeID + "&objectId=" + objectId + "&suiteKey=" + suiteKey + "&Relationship="+Relationship+ "&header="+ someString +"&hideHeader =false";
  String sExistURLMassChangeURL = "emxpartSearchAnECOWizardFS.jsp?jsTreeID=" + jsTreeID + "&objectId=" + objectId + "&suiteKey=" + suiteKey + "&Relationship="+Relationship+"&checkboxValue=checked&checkedButtonValue=";
%>

<script language="javascript">

  function submitForm() {
    var checkedButton = "None checked";
      var i = 0;
        if(document.createDialog.choiceFlag.length != null)
         {
           for (i=0;i<document.createDialog.choiceFlag.length;i++)
           {
             if (document.createDialog.choiceFlag[i].checked)
             {
              checkedButton = document.createDialog.choiceFlag[i].value;
             }
           }
         }
         else
         {
           if (document.createDialog.choiceFlag.checked)
           {
            checkedButton = document.createDialog.choiceFlag.value;
            }
         }

         if (checkedButton == "None checked" )
         {

         }
         else if(checkedButton == "0" )
         {
        	 //XSSOK
            document.createDialog.action = "<%=XSSUtil.encodeForJavaScript(context,sExistURL)%>";
            document.createDialog.submit();
         }
         else if(checkedButton == "1")
         {
        	 //XSSOK
            document.createDialog.action = "<%=XSSUtil.encodeForJavaScript(context,sExistURLMassChangeURL)%>"+checkedButton;
            document.createDialog.submit();
         }
         else if(checkedButton == "2")
         {
        	 //XSSOK
            document.createDialog.action = "<%=XSSUtil.encodeForJavaScript(context,sCreateURL)%>";
            document.createDialog.submit();
         }
         else if(checkedButton == "3")
         {
        	 //XSSOK
            document.createDialog.action = "<%=XSSUtil.encodeForJavaScript(context,sCreateMassChangeURL)%>"+checkedButton;
            document.createDialog.submit();
         }
    }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="createDialog" method="post" onSubmit="submitForm()" action="" target="_parent">
<input type="hidden" name="memberid" value="<xss:encodeForHTMLAttribute><%=memberIds%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="OBJId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="CreateMode" value="<xss:encodeForHTMLAttribute><%=modetype%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="strMode" value="AddToECO" />
<input type="hidden" name="affectedItems" value="<xss:encodeForHTMLAttribute><%=strIds%></xss:encodeForHTMLAttribute>" />


<%
  String checkExist = "";
  String checkNew = "";
  String checkNewMassChange="";
  String checkExistMassChange="";

  if (checkedButtonValue!= null && checkedButtonValue.equals("0")){
    checkExist = "checked";

  }
  else if(checkedButtonValue!= null && checkedButtonValue.equals("1")){
    checkExistMassChange = "checked";
  }
  else if(checkedButtonValue!= null && checkedButtonValue.equals("2")){
      checkNew = "checked";
  }
  else if(checkedButtonValue!= null && checkedButtonValue.equals("3")){
        checkNewMassChange = "checked";
  }
  else
  {
    checkExist = "checked";
  }
%>
  <table border="0" cellpadding="3" cellspacing="2" width="100%">
     <tr>
          <td width="150" class="labelRequired"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Action</emxUtil:i18n></td>
          <td class="inputField">
            <table border="0">
              <tr>
              <!-- XSSOK -->
                <td><input type="radio" name="choiceFlag" id="0" value="0" <%=checkExist%> onClick="" /></td>
                <td><emxUtil:i18n localize="i18nId">emxEngineeringCentral.RaiseECO.ExistingECOradio</emxUtil:i18n></td>
              </tr>
			  <% if(!isPart){ %>
              <tr>
               <!-- XSSOK -->
			    <td><input type="radio" name="choiceFlag" id="0" value="1" <%=checkExistMassChange%> onClick="" disabled /></td>
			    <td><emxUtil:i18n localize="i18nId">emxEngineeringCentral.RaiseECO.ExistingECOradioMassChange</emxUtil:i18n></td>
			  </tr>
			  <% } else {%>
              <tr>
               <!-- XSSOK -->
			    <td><input type="radio" name="choiceFlag" id="0" value="1" <%=checkExistMassChange%> onClick="" /></td>
			    <td><emxUtil:i18n localize="i18nId">emxEngineeringCentral.RaiseECO.ExistingECOradioMassChange</emxUtil:i18n></td>
			  </tr>
			  <% }%>
              <tr>
               <!-- XSSOK -->
                <td><input type="radio" name="choiceFlag" id="1" value="2" <%=checkNew%> onClick="" /></td>
                <td><emxUtil:i18n localize="i18nId">emxEngineeringCentral.RaiseECO.NewECOradio</emxUtil:i18n></td>
              </tr>
			  <% if(!isPart){ %>
			  <tr>
			   <!-- XSSOK -->
			    <td><input type="radio" name="choiceFlag" id="1" value="3" <%=checkNewMassChange%> onClick="" disabled /></td>
			    <td><emxUtil:i18n localize="i18nId">emxEngineeringCentral.RaiseECO.NewECOradioMassChange</emxUtil:i18n></td>
			  </tr>
			   <% } else {%>
			  <tr>
			   <!-- XSSOK -->
			    <td><input type="radio" name="choiceFlag" id="1" value="3" <%=checkNewMassChange%> onClick="" /></td>
			    <td><emxUtil:i18n localize="i18nId">emxEngineeringCentral.RaiseECO.NewECOradioMassChange</emxUtil:i18n></td>
			  </tr>
			  <% }%>
            </table>
          </td>

    </tr>
    <tr>
    	<td width="150" class="label"></td>
		          <td class="inputField">
		          <emxUtil:i18n localize="i18nId">emxEngineeringCentral.RaiseECO.NoteMessage</emxUtil:i18n>
          </td>
    </tr>
  </table>
</form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
