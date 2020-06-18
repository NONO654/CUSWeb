<%--  emxIssueCreateDialog.jsp

  Copyright (c) 1999-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxIssueCreateDialog.jsp.rca 1.34 Wed Oct 22 16:18:00 2008 przemek Experimental przemek $";

--%><%@page import="com.matrixone.apps.common.Person,
				com.matrixone.apps.common.Issue,
				com.matrixone.apps.domain.DomainConstants,
				com.matrixone.apps.domain.DomainObject,
				matrix.db.AttributeTypeList,
				matrix.db.BusinessType,
				matrix.db.Attribute,
				matrix.db.AttributeType,
				java.util.Vector,
				java.util.ArrayList,
				java.util.List,
				matrix.db.Vault,
				matrix.util.StringList,
				com.matrixone.apps.domain.util.mxType,
				com.matrixone.apps.domain.util.i18nNow,
				com.matrixone.apps.domain.util.PropertyUtil,
				com.matrixone.apps.domain.util.FrameworkUtil,
				com.matrixone.apps.common.util.JSPUtil" %>
<%-- Include JSP for error handling --%>


<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%-- Common Includes --%>
<%@include file = "emxComponentsCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxValidationInclude.inc" %>
<%@include file = "emxIssueGlobalSettingInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%

  //This is required for the Type Chooser to work
  String sFunctionality = emxGetParameter(request, "functionality");
  String fromGlobalActionToolbar = emxGetParameter(request, "fromGlobalActionToolbar");
  String targetLocation = emxGetParameter(request, "targetLocation");
  
  String strBaseType = "";
  String strIssueFSParam2 = "";
  String strAffectedItem = "";
  String strActualAffectedItem = "";
  String strSelectedItem = "";
  String relName = PropertyUtil.getSchemaProperty(context, "relationship_Issue");
  String searchTypes = MqlUtil.mqlCommand(context, "print relationship $1 select $2 dump", true, relName, "totype");
  try {
    strAffectedItem = emxGetParameter(request, "txtIssueAffectedItem");
    strActualAffectedItem = emxGetParameter(request, "txtActualAffectedItem");

    //Getting the parameter for Create Issue under Resolved To Category
    String strResolvedTo = emxGetParameter(request, "resolvedTo");
    
    if (strResolvedTo == null || "".equals(strResolvedTo) || "null".equals(strResolvedTo)) {
  		strResolvedTo = "";
 	}

 	//Retrieves Objectid and jsTreeID for processing
    String strObjectId = emxGetParameter(request, "objectId");

    //If the Create Issue is not done from any Context object
    if (strObjectId == null || "".equals(strObjectId)||"null".equals(strObjectId)) {
    	strObjectId = "";
  	} else {
  		//If Issue Create is being done under context
  		//If Not from Resolved To Category then the Context Object is the Reported Against item
  		if (strResolvedTo == null || "".equals(strResolvedTo) || "null".equals(strResolvedTo)) {
   			DomainObject dom = new DomainObject(strObjectId);
   			strAffectedItem = dom.getInfo(context,DomainConstants.SELECT_NAME);
   			strActualAffectedItem = strObjectId;
  		}
 	}
    strSelectedItem = emxGetParameter(request, "emxTableRowId");
    strSelectedItem = strSelectedItem != null ? 
    com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(new String[]{strSelectedItem})[0] : strSelectedItem;

    if (strSelectedItem == null || "".equals(strSelectedItem) || "null".equals(strSelectedItem)) {
        strSelectedItem ="";
    } else {
        StringList strRowIdList = FrameworkUtil.split(strSelectedItem,"|");
        String strRowId = (String) strRowIdList.elementAt(strRowIdList.size()-1);
        DomainObject dom = new DomainObject(strRowId);
		/*  Get the Object Type
    	if the type is Part check if it is Classified 
    	if it is Document get its parent and check if it is Classified
		*/
        boolean bCreateIssue = false;

        String strRowType = Issue.getParentType(context,strRowId);
        if(strRowType.equals(DomainConstants.TYPE_PART)) {
            String strRelClassPart = dom.getInfo(context,"to[" + DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM + "].id");
            bCreateIssue = (!(strRelClassPart == null || "".equals(strRelClassPart) || "null".equals(strRelClassPart)));
        } else if (strRowType.equals(Issue.TYPE_DOCUMENTS)) {
                StringBuffer sbRelRefDoc = new StringBuffer("to[");
                sbRelRefDoc.append(DomainConstants.RELATIONSHIP_REFERENCE_DOCUMENT);
                sbRelRefDoc.append("].from.to[");
                sbRelRefDoc.append(DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM);
                sbRelRefDoc.append("].id");

                StringBuffer sbRelPartSpec = new StringBuffer("to[");
                sbRelPartSpec.append(DomainConstants.RELATIONSHIP_PART_SPECIFICATION);
                sbRelPartSpec.append("].from.to[");
                sbRelPartSpec.append(DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM);
                sbRelPartSpec.append("].id");
                
                StringBuffer sbRelClassDoc = new StringBuffer("to[");
                sbRelClassDoc.append(DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM);
                sbRelClassDoc.append("].id");

                StringList slDocRel = new StringList(3);
                slDocRel.add(sbRelRefDoc.toString());
                slDocRel.add(sbRelPartSpec.toString());
                slDocRel.add(sbRelClassDoc.toString());

                Map mapRelRefDoc = dom.getInfo(context, slDocRel);
                String strRelRefDoc = (String) mapRelRefDoc.get(sbRelRefDoc.toString());
                String strRelSpeDoc = (String) mapRelRefDoc.get(sbRelPartSpec.toString());
                String strRelClassDoc = (String) mapRelRefDoc.get(sbRelClassDoc.toString());

                bCreateIssue = ((!UIUtil.isNullOrEmpty(strRelRefDoc)) || (!UIUtil.isNullOrEmpty(strRelSpeDoc))
                		       || (!UIUtil.isNullOrEmpty(strRelClassDoc)));
                                
        } else {
            bCreateIssue = true;
        }
        if (bCreateIssue) {
            strAffectedItem = dom.getInfo(context,DomainConstants.SELECT_NAME);
            strActualAffectedItem = strRowId;
        } else {
          	StringList strList = new StringList(3);
            strList.add(DomainConstants.SELECT_TYPE);
            strList.add(DomainConstants.SELECT_NAME);
            strList.add(DomainConstants.SELECT_REVISION);

            DomainObject domObject = new DomainObject(strRowId);
            Map mapInfo = domObject.getInfo(context, strList);

            String strObjType = (String) mapInfo.get(DomainConstants.SELECT_TYPE);
            String strObjName = (String) mapInfo.get(DomainConstants.SELECT_NAME);
            String strObjRev = (String) mapInfo.get(DomainConstants.SELECT_REVISION);

            String strErrorMsg = i18nNow.getI18nString("emxComponents.Issue.ErrorMessage", bundle,acceptLanguage);

            strErrorMsg = FrameworkUtil.findAndReplace(strErrorMsg, "${TYPE}", strObjType);
            strErrorMsg = FrameworkUtil.findAndReplace(strErrorMsg, "${NAME}", strObjName);
            strErrorMsg = FrameworkUtil.findAndReplace(strErrorMsg, "${REVISION}", strObjRev);
            %>
            <script language="javascript" type="text/javaScript">
            //XSSOK
			alert(" <%=strErrorMsg%>");
            window.closeWindow();
            </script>            
            <%
            return;
        }
    }

 //to get the field information if the page gets relaoaded after the type change happens
 String strTypeDisplay = emxGetParameter(request, "txtIssueType");
 String strTypeActual = emxGetParameter(request, "txtIssueActualType");
 String strDescription = emxGetParameter(request, "txtIssueDescription");
 String strEstimatedStartDate = emxGetParameter(request, "txtIssueEstimatedStartDate");
 String strEstimatedEndDate = emxGetParameter(request, "txtIssueEstimatedEndDate");
 String strResolutionRecommendation = emxGetParameter(request, "txtIssueResolutionRecommendation");
 String strStepsToReproduce = emxGetParameter(request, "txtIssueStepsToReproduce");
 String strCategoryClassification = emxGetParameter(request, "txtIssueCategoryClassificationDisplay");
 String strVault = emxGetParameter(request, "txtIssueVault");
 String strPriority = emxGetParameter(request, "txtIssuePriority");
 String strEscalationRequired = emxGetParameter(request, "radEscalationRequired");

 /*Start Of Add by Sandeep, Infosys for Bug # 310341*/
 String strCategoryClassificationActual = emxGetParameter(request, "txtIssueCategoryClassification");
 String strCategoryClassificationId = emxGetParameter(request, "txtIssueCategoryClassificationId");
 /*End Of Add by Sandeep, Infosys for Bug # 310341*/

 String strCoOwner = emxGetParameter(request, "txtCoOwner");
 String strProblemType = emxGetParameter(request, "txtProblemType");

 //Checking the Co Owners field for null and making it to blank(for Websphere).
 if ((strCoOwner == null) || "null".equalsIgnoreCase(strCoOwner)) {
  	strCoOwner = "";
 }

/* End Adding for New Attributes in Raise Issue feature */

 //Checking the Description field for null and making it to blank(for Websphere).
 if ((strActualAffectedItem == null) || "null".equalsIgnoreCase(strActualAffectedItem)) {
  	strActualAffectedItem = "";
 }

 //Checking the Description field for null and making it to blank(for Websphere).
 if ((strDescription == null) || "null".equalsIgnoreCase(strDescription)) {
  	strDescription = "";
 }

 //Checking the Estimated Start Date field for null and making it to blank(for Websphere).
 if ((strEstimatedStartDate == null) || "null".equalsIgnoreCase(strEstimatedStartDate)) {
  	strEstimatedStartDate = "";
 }

 //Checking the Estimated End Date field for null and making it to blank(for Websphere).
 if ((strEstimatedEndDate == null) || "null".equalsIgnoreCase(strEstimatedEndDate)) {
  	strEstimatedEndDate = "";
 }

 //Checking the Resolution Recommendation field for null and making it to blank(for Websphere).
 if ((strResolutionRecommendation == null) || "null".equalsIgnoreCase(strResolutionRecommendation)) {
  	strResolutionRecommendation = "";
 }

 //Checking the Steps To Reproduce field for null and making it to blank(for Websphere).
 if ((strStepsToReproduce == null) || "null".equalsIgnoreCase(strStepsToReproduce)) {
  	strStepsToReproduce = "";
 }

 //Checking the Issue Category Classification field for null and making it to blank(for Websphere).
 if ((strCategoryClassification == null) || "null".equalsIgnoreCase(strCategoryClassification)) {
  	strCategoryClassification = "";
 }

 //Checking the Affected Item field for null and making it to blank(for Websphere).
 if ((strAffectedItem == null) || "null".equalsIgnoreCase(strAffectedItem)) {
  	strAffectedItem = "";
 }

 //Checking the Vault field for null and making it to blank(for Websphere).
 if ((strVault == null) || "null".equalsIgnoreCase(strVault)) {
  	strVault = "";
 }


 //Checking the Type field
 String strTypeToDisplay=null;
 String strType=null;
 String strLocale = context.getSession().getLanguage();
 // The base type is set for the Type chooser variable.
 strBaseType = PropertyUtil.getSchemaProperty(context, Issue.SYMBOLIC_type_Issue);

 if ( strTypeDisplay!=null && !strTypeDisplay.equals("") && !"null".equalsIgnoreCase(strTypeDisplay)) {
 	strType = strTypeActual;
    strTypeToDisplay = EnoviaResourceBundle.getTypeI18NString(context,strType, strLocale);
 } else {
  	strType = strBaseType;
  	strTypeToDisplay = EnoviaResourceBundle.getTypeI18NString(context,strType, strLocale);
 }

 //Retrieves the tree node id to insert the created object
 String jsTreeID = "";
 jsTreeID = emxGetParameter(request, "jsTreeID");

 //Issue bean instantiated for processing
 Issue issueBean = (Issue) DomainObject.newInstance(context,strBaseType);

 StringList companyList =  issueBean.getUserCompanyIdName(context);
 String strCompanyId = "";
 strCompanyId = (String)companyList.elementAt(0);
 String strCompanyName = "";
 strCompanyName = (String)companyList.elementAt(1);
 /*
 *The array of attribute names is formed to get back the ranges of the
 *attribute from the backend using one function call
 */

 String strAttribPriority = PropertyUtil.getSchemaProperty(context, Issue.SYMBOLIC_attribute_Priority);
 String strAttribEscRequired = PropertyUtil.getSchemaProperty(context, Issue.SYMBOLIC_attribute_EscalationRequired);

 /* Start Adding for New Attributes in Raise Issue feature */
 String strAttribProblemType = PropertyUtil.getSchemaProperty(context, Issue.SYMBOLIC_attribute_ProblemType);
 /* End Adding for New Attributes in Raise Issue feature */

/* Following line commented for Raise Issue feature  */
    String strAttribNames[] = {strAttribPriority, strAttribEscRequired,strAttribProblemType};
    Map attrRangeMap = Issue.getAttributeChoices(context,strAttribNames);
    MapList priorityList = (MapList) attrRangeMap.get(strAttribNames[0]);
    MapList DefaultPriorityMapList = (MapList) attrRangeMap.get("Select Default Attributes");
    Map defaultPriorityMap = (HashMap)DefaultPriorityMapList.get(0);
    //Getting the default range value
    String priorityDefault = (String)defaultPriorityMap.get(strAttribNames[0]);
    String priorityClearAllDefault = priorityDefault;
    String escalationDefault = (String)defaultPriorityMap.get(strAttribNames[1]);
    //Getting the Internationalized value.
 	priorityDefault = i18nNow.getRangeI18NString(strAttribNames[0], priorityDefault, acceptLanguage);

    //Reassigning the Maplist with internationalized values
    priorityList = Issue.getI18nValues(priorityList, strAttribPriority, acceptLanguage);

/* Start Adding for New Attributes in Raise Issue feature *
 * Getting the Default values for new Attributes waitingOn and problemType and Internatioanalizing */

    MapList problemTypeList = (MapList) attrRangeMap.get(strAttribNames[2]);
    String problemTypeDefault = (String)defaultPriorityMap.get(strAttribNames[2]);
    String problemTypeClearAllDefault = problemTypeDefault;
    //Getting the Internationalized value.
    problemTypeDefault = i18nNow.getRangeI18NString(strAttribNames[2], problemTypeDefault, acceptLanguage);
    //Reassigning the Maplist with internationalized values
    problemTypeList = Issue.getI18nValues(problemTypeList, strAttribProblemType, acceptLanguage);

/* End Adding for New Attributes in Raise Issue feature */

//For formating the dates
  String strTimeZone = "";
 strTimeZone =(String)session.getValue ("timeZone");
 Locale Local = request.getLocale();
     String strCountry = "";
    strCountry = Local.getCountry();

//For getting the Time Setting
 String strTimeSetting = EnoviaResourceBundle.getProperty(context,"emxFramework.DateTime.DisplayFormat");
 Boolean dsServer =(Boolean)JPO.invoke(context, "emxVCDocumentUI", null, "hasDesignSyncServer", null, Boolean.class);
%>

	<script language="javascript" type="text/javascript" src="../components/emxComponentsJSFunctions.js"></script>
	
	<script language="javascript">
		function btnCoOwners_onclick() {
			showModalDialog("../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active:USERROLE=role_IssueManager,role_VPLMCreator&selection=multiple&showInitialResults=true&form=AEFSearchPersonForm&submitURL=../common/AEFSearchUtil.jsp?formName=IssueCreate%26fieldNameActual=txtCoOwner%26fieldNameDisplay=txtIssueCoOwner&table=AEFPersonChooserDetails", this.windowWidth, this.windowHeight, true);
		}
		
		function submitCoOwnersSearch (arrSelectedObjects) {
		    for (var i = 0; i < arrSelectedObjects.length; i++) {
		        var objSelection = arrSelectedObjects[i];
		        var objForm = document.forms["IssueCreate"];
		        if (objForm) {
		        	if (objForm.txtCoOwnerId) {
		        		objForm.txtCoOwnerId.value = objSelection.name;
		        	}
		        	if (objForm.txtIssueCoOwner) {
		        		objForm.txtIssueCoOwner.value = objSelection.name;
		        	}
		        }
		        break;
		    }
		}
		
		function companySelector_onclick() {
			var objCommonAutonomySearch = new emxCommonAutonomySearch();
			objCommonAutonomySearch.txtType = "type_Company";
			objCommonAutonomySearch.selection = "single";
			objCommonAutonomySearch.onSubmit = "getTopWindow().getWindowOpener().submitCompanySearch"; 
			objCommonAutonomySearch.open();
		}
		
		function submitCompanySearch (arrSelectedObjects) {
		    for (var i = 0; i < arrSelectedObjects.length; i++) {
		        var objSelection = arrSelectedObjects[i];
		        var objForm = document.forms["IssueCreate"];
		        if (objForm) {
		        	if (objForm.txtCompanyId) {
		        		objForm.txtCompanyId.value = objSelection.objectId;
		        	}
		        	if (objForm.txtIssueCompany) {
		        		objForm.txtIssueCompany.value = objSelection.name;
		        	}
		        }
		        break;
		    }
		}
				
	</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js">
</script>


  <script language="javascript" src="../common/scripts/emxUIModal.js"></script>


    <form name="IssueCreate" method="post" onsubmit="submitForm(); return false">
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="TimeZone" value="<xss:encodeForHTMLAttribute><%=strTimeZone%></xss:encodeForHTMLAttribute>" />
   	  <input type="hidden" name="RequestLocale" value="<%=Local%>" />
      <input type="hidden" name="Country" value="<xss:encodeForHTMLAttribute><%=strCountry%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="functionality" value="<xss:encodeForHTMLAttribute><%=sFunctionality%></xss:encodeForHTMLAttribute>" />


      <table>

      <%-- Display the input fields. --%>
   <tr>
    <td width="150" nowrap="nowrap" class="labelRequired">
   <emxUtil:i18n localize="i18nId">
     emxFramework.Basic.Type
   </emxUtil:i18n>
      </td>
   <td  nowrap="nowrap" class="field">
   <input type="text" name="txtIssueType" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strTypeToDisplay%></xss:encodeForHTMLAttribute>"/>
   <input class="button" type="button" name="btnType" size="200" value="..." alt=""  onClick="javascript:showTypeSelector();"/>
   <input type="hidden" name="txtIssueActualType" value="<xss:encodeForHTMLAttribute><%=strType%></xss:encodeForHTMLAttribute>"/>
    </td>
      </tr>
      <tr>
    <td width="150" class="labelRequired" >
   <emxUtil:i18n localize="i18nId">
     emxFramework.Basic.Description
   </emxUtil:i18n>
    </td>
    <td  class="field">
   <textarea name="txtIssueDescription" rows="5" cols="25" wrap><xss:encodeForHTML><%=strDescription%></xss:encodeForHTML></textarea>
    </td>
      </tr>
      <tr>
<!--Modified the Class Value from label to labelRequired for LC V11  -->
    <td width="150" nowrap="nowrap" class="labelRequired">
   <emxUtil:i18n localize="i18nId">
     emxComponents.Form.Label.AffectedItem
   </emxUtil:i18n>
    </td>
    <td  nowrap="nowrap" class="field">
   <input type="text" name="txtIssueAffectedItem" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strAffectedItem%></xss:encodeForHTMLAttribute>"/>
   <%
      if ((strObjectId == null || "".equals(strObjectId) || "null".equalsIgnoreCase(strObjectId)) || (!(strResolvedTo == null || "".equals(strResolvedTo) || "null".equalsIgnoreCase(strResolvedTo))))
      {
   %>
    <input class="button" type="button" name="btnAffectedItem" size="200" value="..." alt=""  onClick="javascript:showAffectedItemSelector();"/>
   <%}%>
   <input type="hidden" name="txtActualAffectedItem" value="<xss:encodeForHTMLAttribute><%=strActualAffectedItem%></xss:encodeForHTMLAttribute>"/>
    </td>
      </tr>

      <tr>
           <td width="150" class="label">
             <emxUtil:i18n localize="i18nId">
               emxComponents.Form.Label.EscalationRequired
             </emxUtil:i18n>
           </td>
           <td  class="field">
   <%
       //Getting the range values of attributes Escalation Required in a MapList object
       MapList attrMapList = (MapList) attrRangeMap.get(strAttribNames[1]);
       //Reassigning the Maplist object with internationalized values
       attrMapList = Issue.getI18nValues(attrMapList, strAttribEscRequired, acceptLanguage);
       String strSelected = "";
       String strAttrRangeValue = "";
       String strAttrRangeI18nName = "";
       for (int i = 0 ; i < attrMapList.size();i++)
       {
      strAttrRangeValue = (String)((HashMap)attrMapList.get(i)).get(Issue.VALUE);

   strAttrRangeI18nName = (String)((HashMap)attrMapList.get(i)).get(DomainConstants.SELECT_NAME);
   if((strEscalationRequired == null) || "".equals(strEscalationRequired) || "null".equalsIgnoreCase(strEscalationRequired))
     {
    if (strAttrRangeValue.equalsIgnoreCase("No"))
     strSelected = "checked";
    else
     strSelected = "";
     }
   else{
    if (strAttrRangeValue!=null&&strAttrRangeValue.equalsIgnoreCase(strEscalationRequired))
     strSelected = "checked";
    else
     strSelected = "";
   }

   %>
           <INPUT TYPE="radio" NAME="radEscalationRequired" value="<%=strAttrRangeValue%>" <%=strSelected%>/><%=strAttrRangeI18nName%>
           <BR></BR>

   <%
       }
   %>
   </td>
      </tr>

      <tr>
    <td width="150" nowrap="nowrap" class="label">
   <emxUtil:i18n localize="i18nId">
     emxComponents.Form.EstimatedStartDate
   </emxUtil:i18n>
    </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtIssueEstimatedStartDate" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strEstimatedStartDate%></xss:encodeForHTMLAttribute>"/>
              <a href="javascript:showCalendar('IssueCreate','txtIssueEstimatedStartDate', '')">
                <img src="../common/images/iconSmallCalendar.gif" border="0" valign="bottom"/></a>
           <input type="hidden" name="txtIssueEstimatedStartDate_msvalue" value=""/>
         </td>
      </tr>
      <tr>
    <td width="150" nowrap="nowrap" class="label">
   <emxUtil:i18n localize="i18nId">
     emxComponents.Form.EstimatedFinishDate
   </emxUtil:i18n>
    </td>
        <td  nowrap="nowrap" class="field">
          <input type="text" name="txtIssueEstimatedEndDate" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strEstimatedEndDate%></xss:encodeForHTMLAttribute>" />
          <a href="javascript:showCalendar('IssueCreate','txtIssueEstimatedEndDate', '')">
            <img src="../common/images/iconSmallCalendar.gif" border="0" valign="bottom"/></a>
           <input type="hidden" name="txtIssueEstimatedEndDate_msvalue" value=""/>
        </td>
      </tr>
       <tr>
    <td width="150" class="labelRequired">
   <emxUtil:i18n localize="i18nId">
     emxComponents.Form.Priority
   </emxUtil:i18n>
    </td>
    <td class="field">
   <select name="txtIssuePriority">
     <framework:optionList
    optionMapList="<%= priorityList%>"
    optionKey="<%=DomainConstants.SELECT_NAME%>"
    valueKey="<%=Issue.VALUE%>"
    selected = "<%=priorityDefault%>"/>
   </select>
    </td>
      </tr>
      <tr>
    <td width="150" nowrap="nowrap" class="label">
   <emxUtil:i18n localize="i18nId">
     emxComponents.Form.Label.CoOwner
   </emxUtil:i18n>
    </td>
    <td  nowrap="nowrap" class="field">
   <input type="text" name="txtIssueCoOwner" id="txtIssueCoOwner" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strCoOwner%></xss:encodeForHTMLAttribute>" />
   <input type="hidden" name="txtCoOwnerOID"  id="txtCoOwnerOID" value=""/>
   <input type="hidden" name="txtCoOwner"  id="txtCoOwner" value=""/>
   <input class="button" type="button" name="btnCoOwners" size="200" value="..." alt="" onClick="btnCoOwners_onclick()"/>

    </td>
      </tr>
        <!--  * Start Adding for Problem Type Attribute in Raise Issue feature  
        * Problem Type Attribute as combo box with list of values -->
       <tr>
    <td width="150" class="label">
   <emxUtil:i18n localize="i18nId">
     emxComponents.Form.Label.ProblemType
   </emxUtil:i18n>
    </td>
    <td class="field">
   <select name="txtIssueProblemType">
     <framework:optionList
    optionMapList="<%= problemTypeList%>"
    optionKey="<%=DomainConstants.SELECT_NAME%>"
    valueKey="<%=XSSUtil.encodeForHTML(context, Issue.VALUE)%>"
    selected = "<%=XSSUtil.encodeForHTML(context, problemTypeDefault)%>"/>
   </select>
    </td>
      </tr>
<!--  * End Adding of new Attributes in Raise Issue feature   -->

      <tr>
    <td width="150" class="label" >
   <emxUtil:i18n localize="i18nId">
     emxComponents.Form.ResolutionRecommendation
   </emxUtil:i18n>
    </td>
    <td  class="field">
   <textarea name="txtIssueResolutionRecommendation" rows="5" cols="25"><xss:encodeForHTML><%=strResolutionRecommendation%></xss:encodeForHTML></textarea>
    </td>
      </tr>
   <tr>
    <td width="150" class="label" >
   <emxUtil:i18n localize="i18nId">
     emxComponents.Form.Label.StepsToReproduce
   </emxUtil:i18n>
    </td>
    <td  class="field">
   <textarea name="txtIssueStepsToReproduce" rows="5" cols="25"><xss:encodeForHTML><%=strStepsToReproduce%></xss:encodeForHTML></textarea>
    </td>
  </tr>
      <tr>
<!--Modified the IssueCategoryClassification from required field to non required field for Raise Issues feature -->

    <td width="150" nowrap="nowrap" class="label">
   <framework:i18n localize="i18nId">
     emxComponents.Form.Label.IssueCategoryClassification
   </framework:i18n>
    </td>
    <td  nowrap="nowrap" class="field">
    <input type="text" name="txtIssueCategoryClassificationDisplay" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strCategoryClassification%></xss:encodeForHTMLAttribute>" />
   <input class="button" type="button" name="btnCategoryClassification" size="200" value="..." alt=""  onClick="javascript:showIssueCategoryClassification();"/>
   <input type="hidden" name="txtIssueCategoryClassification" value="<xss:encodeForHTMLAttribute><%=strCategoryClassificationActual%></xss:encodeForHTMLAttribute>"/>
   <input type="hidden" name="txtIssueCategoryClassificationId" value="<xss:encodeForHTMLAttribute><%=strCategoryClassificationId%></xss:encodeForHTMLAttribute>"/>
     </td>
      </tr>
      <tr>
    <td width="150" nowrap="nowrap" class="labelRequired">
   <emxUtil:i18n localize="i18nId">
     emxComponents.Form.Label.Company
   </emxUtil:i18n>
    </td>
    <td  nowrap="nowrap" class="field">
   <input type="text" name="txtIssueCompany" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strCompanyName%></xss:encodeForHTMLAttribute>"/>
   <input class="button" type="button" name="btnCompany" size="200" value="..." alt=""  onClick="companySelector_onclick()"/>
   <input type="hidden" name="txtCompanyId" value="<xss:encodeForHTMLAttribute><%=strCompanyId%></xss:encodeForHTMLAttribute>"/>
    </td>
      </tr>


<%
     /*
    *This logic defines if the Policy field is to be made visible to the user or not
    *These setting are based on the global settings for each module made in the
    *application property file.
    */

     HashMap mapPolicyList = Issue.getI18NPolicyList(context,strBaseType,acceptLanguage);
     StringList policyValueList = (StringList)mapPolicyList.get(Issue.VALUE);
   if (bPolicyAwareness)
   {
       StringList il18NPolicyList = (StringList)mapPolicyList.get(DomainConstants.SELECT_NAME);
       String strPolicyName="";
       int intListSize=policyValueList.size();
     %>

  <tr>
    <td width="150" class="label" valign="top">
       <emxUtil:i18n localize="i18nId">
          emxFramework.Basic.Policy
       </emxUtil:i18n>
    </td>
<% if (intListSize>1)
     {
%>
      <td class="inputField">
      <select name="txtIssuePolicy"  >
<%
      for (int i=0;i<intListSize;i++)
         {
%>
        <option value="<%=XSSUtil.encodeForHTMLAttribute(context, policyValueList.get(i).toString())%>" ><%= XSSUtil.encodeForHTML(context, il18NPolicyList.get(i).toString())%>
        </option>

<%
         }
%>
       </select>
    </td>
  </tr>
<%
     }
    if(intListSize==1)
      {
%>
       <td class="field">
          <%=XSSUtil.encodeForHTML(context, il18NPolicyList.get(0).toString())%>
          <input type="hidden" name="txtIssuePolicy" value="<xss:encodeForHTMLAttribute><%=policyValueList.get(0)%></xss:encodeForHTMLAttribute>"/>
       </td>
       </tr>

<%
      }
    }else
         {
  %>
     <input type="hidden" name="txtIssuePolicy" value="<xss:encodeForHTMLAttribute><%=policyValueList.get(0)%></xss:encodeForHTMLAttribute>"/>
 <%
     }

 if (bShowVault)
    {
%>
      <tr>
        <td width="150" class="label">
          <emxUtil:i18n localize="i18nId">
            emxFramework.Basic.Vault
          </emxUtil:i18n>
        </td>
        <td  class="field">

          <input type="text" name="txtIssueVaultDisplay" readonly="readonly" size="20" value="<xss:encodeForHTMLAttribute><%=strUserVaultDisplay%></xss:encodeForHTMLAttribute>"/>
          <input type="hidden" name="txtIssueVault" size="15" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>"/>
          <input class="button" type="button" name="btnVault" size="200" value="..." alt=""  onClick="javascript:showVaultSelector();"/>&nbsp;
          <a name="ancClear" href="#ancClear" class="dialogClear" onclick="document.IssueCreate.txtIssueVault.value='';document.IssueCreate.txtIssueVaultDisplay.value='';"><framework:i18n localize="i18nId">emxComponents.Common.Clear</framework:i18n></a>
        </td>
      </tr>
<%
    }else{
%>
        <input type="hidden" name="txtIssueVault" value="<xss:encodeForHTMLAttribute><%=strUserVault%></xss:encodeForHTMLAttribute>"/>
<%
    }
%>
      <input type="hidden" name="txtResolvedTo" value="<xss:encodeForHTMLAttribute><%=strResolvedTo%></xss:encodeForHTMLAttribute>"/>
	<%
/* Code for Issue sub type starts here by T8R */
	
	// Global List of fields that needs to be validiated thorugh js. 
	List<Map<String,String>> mlSubIssueAttributesForValidiation = new ArrayList();
	
	List<String> extraAttributes = Issue.getExtraAttributesForSubType(context, strType);
	
	// Iterating over the attributes left after filtering.
	// according to each attributes type, feilds will be rendred with their default values.
	// name of the generated field will be the attribute's symbolic name
	for(String strAttribute : extraAttributes) {
		AttributeType typeAttribute = new AttributeType(strAttribute);
		String type = typeAttribute.getDataType(context);
		String symName = PropertyUtil.getAliasForAdmin(context, "attribute",strAttribute,true);
		String defaultValue = typeAttribute.getDefaultValue(context);
		StringList rangeList = typeAttribute.getChoices(context);

		if(rangeList != null && !rangeList.isEmpty()){
			
		    //Reassigning the Maplist with internationalized values
			StringList i18rangeList = i18nNow.getAttrRangeI18NStringList(strAttribute, rangeList, acceptLanguage);
			
			MapList rangeMapList = new MapList();
			int rangeSize = rangeList.size();
			for(int i = 0; i < rangeSize ; i++){
				Map choiceMap = new HashMap();
				choiceMap.put("value", rangeList.get(i));
				choiceMap.put("i18value", i18rangeList.get(i));
				rangeMapList.add(choiceMap);
			}
%>
			<tr>
				<td width="150" class="label">
					<%=i18nNow.getAttributeI18NString(strAttribute,acceptLanguage)%>
				</td>
				<td class="field">
					<select name="<%=symName%>" >
						<framework:optionList optionMapList="<%= rangeMapList%>"
							optionKey="i18value" valueKey="value" selected="<%=defaultValue%>" />
					</select>
				</td>
			</tr>
<%
		}
		else {
			// If attribute type is string 
			if("string".equalsIgnoreCase(type)) {
						
				// if attribute has no ranges, then a text area is rendered
%>
				<tr>
					<td width="150" class="label">
						<%=i18nNow.getAttributeI18NString(strAttribute,acceptLanguage)%>
					</td>
					<td class="field">
						<textarea name="<%=symName%>"  rows="5" cols="25"><%=defaultValue%></textarea>
					</td>
				</tr>
<%
			}
			else if("timestamp".equalsIgnoreCase(type))	{
%>
				<tr>
					<td width="150" nowrap="nowrap" class="label">
						<%=i18nNow.getAttributeI18NString(strAttribute,acceptLanguage)%>
					</td>
					<td nowrap="nowrap" class="field">
						<input type="text" name="<%=symName%>"  size="20" readonly="readonly" value="<%=defaultValue%>" /> 
						<a href="javascript:showCalendar('IssueCreate','<%=symName%>', '')">
							<img src="../common/images/iconSmallCalendar.gif" border="0" valign="bottom" />
						</a> 
						<input type="hidden" name="<%=symName%>_msvalue" value="" />
					</td>
				</tr>
<%
			}
			else if("integer".equalsIgnoreCase(type) || "real".equalsIgnoreCase(type)) {
				String intlValue = i18nNow.getI18nString("emxComponents.Form.SubIssueType."+symName, bundle,acceptLanguage);
				Map values = new HashMap();
				values.put(symName,intlValue);
				mlSubIssueAttributesForValidiation.add(values);
%>
				<tr>
					<td width="150" nowrap="nowrap" class="label">
						<%=i18nNow.getAttributeI18NString(strAttribute,acceptLanguage)%>
					</td>
					<td nowrap="nowrap" class="field">
						<input type="text" name="<%=symName%>"  size="20" value="<%=defaultValue%>" />
					</td>
				</tr>
<%
			}
			else if("boolean".equalsIgnoreCase(type)) {
%>
				<tr>
					<td width="150" nowrap="nowrap" class="label">
						<%=i18nNow.getAttributeI18NString(strAttribute,acceptLanguage)%>
					</td>
					<td class="field">
						<INPUT TYPE="radio" NAME="<%=symName%>" value="true" <%=("true".equalsIgnoreCase(defaultValue))?"checked":""%> /> 
						<emxUtil:i18n localize="i18nId">emxComponents.Form.True</emxUtil:i18n>
						<BR/>
						<INPUT TYPE="radio" NAME="<%=symName%>"  value="false" <%=("false".equalsIgnoreCase(defaultValue))?"checked":""%> />
						<emxUtil:i18n localize="i18nId">emxComponents.Form.False</emxUtil:i18n>
						<BR/>
					</td>
				</tr>
<%
				}
			}	
		}
	
	/* Code for Issue sub type end here by T8R*/
%>



      </table>
    </form>

  <script language="javascript" type="text/javaScript">
  //<![CDATA[
    var  formName = document.IssueCreate;

    //when 'Cancel' button is pressed in Dialog Page
    function closeWindow()
    {
        //Releasing Mouse Events

        window.closeWindow();
    }

    //Validating the form before submitting
 function validateForm()
    {

      var iValidForm = true;


      //Validation for Required field for Type
      if (iValidForm)
      {
        var fieldName = "<%=i18nNow.getI18nString("emxFramework.Basic.Type", bundle,acceptLanguage)%> ";
        var field = formName.txtIssueType;
        iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,false);

      }


      //Validation for Required field for Description
      if (iValidForm)
      {
        var fieldName = "<%=i18nNow.getI18nString("emxFramework.Basic.Description", bundle,acceptLanguage)%> ";
        var field = formName.txtIssueDescription;
        iValidForm = basicValidation(formName,field,fieldName,true,false,true,false,false,false,checkBadChars);
      }

      //validation for Reported Against
      if(iValidForm)
      {
        var fieldName = "<%=i18nNow.getI18nString("emxComponents.Form.Label.AffectedItem", bundle,acceptLanguage)%> ";
        var field = formName.txtIssueAffectedItem;
        iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,false);
      }

      //Validation for Company
        if (iValidForm)
      {
        var fieldName = "<%=i18nNow.getI18nString("emxComponents.Form.Label.Company", bundle,acceptLanguage)%> ";
         var field =  formName.txtIssueCompany;
        iValidForm = basicValidation(formName,field,fieldName,true,false,false,false,false,false,false);
      }

      //Validation for  Resolution Recommendation.
     if (iValidForm)
      {
        var fieldName = "<%=i18nNow.getI18nString("emxComponents.Form.ResolutionRecommendation", bundle,acceptLanguage)%> ";
         var field =  formName.txtIssueResolutionRecommendation;
        iValidForm = basicValidation(formName,field,fieldName,false,false,true,false,false,false,checkBadChars);
      }

      //Validation for   Steps To Reproduce.
     if (iValidForm)
      {
        var fieldName = "<%=i18nNow.getI18nString("emxComponents.Form.Label.StepsToReproduce", bundle,acceptLanguage)%> ";
         var field =  formName.txtIssueStepsToReproduce;
        iValidForm = basicValidation(formName,field,fieldName,false,false,true,false,false,false,checkBadChars);
      }


      //Validation required for estimated start and end dates
     if (iValidForm)
      {
     
       if(formName.txtIssueEstimatedStartDate!="" && formName.txtIssueEstimatedEndDate!="")
       {
       if(formName.txtIssueEstimatedStartDate.value!="" && formName.txtIssueEstimatedEndDate.value!="")
       {
         if(formName.txtIssueEstimatedStartDate_msvalue.value>formName.txtIssueEstimatedEndDate_msvalue.value)
         {
         alert("<%=i18nNow.getI18nString("emxComponents.Common.Issue.Alert.EstimatedStartAndEndDates",bundle,acceptLanguage)%>");
         iValidForm=false;
         }
       }
      }
	}
   // Validation for sub issue type starts by T8R--
<% 
		for (Object objValidate : mlSubIssueAttributesForValidiation) {
			String jField = "";
			String jFieldName = "";
			Map<String,String> mValidate = (Map<String,String>)objValidate;
		    for (Map.Entry<String,String> mSetValue : mValidate.entrySet()) {
				jField = "formName."+mSetValue.getKey();
				jFieldName = mSetValue.getValue();
			}
%>
			if (iValidForm)
		      {
		        var jsField =  <%=XSSUtil.encodeForJavaScript(context, jField)%>;
		        var jsFieldName = "<%=XSSUtil.encodeForJavaScript(context, jFieldName)%>";
		        iValidForm = basicValidation(formName,jsField,jsFieldName,false,false,false,true,false,false,false);
		      }
<%
		}
%>

	// Validation for sub issue type ends by T8R--

      //If validation fails
      if (!iValidForm)
      {
        return false;
      }

      return true;

    }

    //When Enter Key Pressed on the form
    function submitForm()
    {
	  submit();
    }

 // when submit button is pressed
    function submit()
    {

       if(validateForm()) {
		  formName.action="../components/emxIssueUtil.jsp?mode=createIssue&IssueFSParam2=Action&resolvedTo=<%=XSSUtil.encodeForURL(context, strResolvedTo)%>&fromGlobalActionToolbar=<%=XSSUtil.encodeForURL(context, fromGlobalActionToolbar)%>&targetLocation=<%=XSSUtil.encodeForURL(context, targetLocation)%>";
  
  		  //If validation passes
  		  formName.target = "jpcharfooter";
  		  
		  turnOnProgress();
		  if (jsDblClick()) {
		       formName.submit();
		  }
  		}
     	return;
  }

    // when apply button is pressed
     function apply()
     {
   		if(validateForm()) {
      		formName.action="../components/emxIssueUtil.jsp?mode=createMultipleIssue&IssueFSParam2=<%=XSSUtil.encodeForURL(context, strIssueFSParam2)%>&fromGlobalActionToolbar=<%=XSSUtil.encodeForURL(context, fromGlobalActionToolbar)%>&targetLocation=<%=XSSUtil.encodeForURL(context, targetLocation)%>";

	     //If validation passes
	       formName.target = "jpcharfooter";
	       
	       turnOnProgress();
	       if (jsDblClick()) {
	      		formName.submit();
	     	}
	   }
       return;
    }

    //function to show type chooser
 function showTypeSelector()
    {

      //This function is for popping the Type chooser.
      //The value chosen by the type chooser is returned to the corresponding field.

      var field = formName.txtIssueType.name;
      var fieldActual = formName.txtIssueActualType.name;
      showChooser('../common/emxTypeChooser.jsp?fieldNameDisplay='+field+'&fieldNameActual='+fieldActual+'&formName=IssueCreate&SelectType=single&SelectAbstractTypes=false&InclusionList=<%=strBaseType%>&ObserveHidden=true&SuiteKey=eServiceSuiteProductCentral&ShowIcons=true&ReloadOpener=true',500,400);

    }

 //function to reload the page after changing the type
 function reload()
    {
      document.IssueCreate.action="../components/emxIssueCreateDialog.jsp?suiteKey=components&showWarning=true&contentPageIsDialog=true&resolvedTo=<%=XSSUtil.encodeForURL(context, strResolvedTo)%>";
      document.IssueCreate.submit();
    }


    //function to show affected Item chooser
 function showAffectedItemSelector()
    {
	 var sURL= '../common/emxFullSearch.jsp?suiteKey=Components&field=TYPES=<%=XSSUtil.encodeForURL(context, searchTypes)%>&table=IssueAddExistingSearchGenericTable&submitURL=../components/emxCommonSelectObject.jsp&sercDestRelName=relationship_Issue&formName=IssueCreate&fieldNameActual=txtActualAffectedItem&fieldNameDisplay=txtIssueAffectedItem&HelpMarker=emxhelpsearch&selection=single';
     showChooser(sURL, 700, 500);
    }


 function showIssueCategoryClassification()
 {
       //This function is for popping the Issue Category Classification chooser.
    //The value chosen by the type chooser is returned to the corresponding field.

     showChooser('../common/emxIndentedTable.jsp?expandProgram=emxCommonIssue:issueCategoryExpand&table=APPIssueCategoryChooser&program=emxCommonIssue:issueCategoryChooser&header=emxComponents.Form.Label.IssueCategoryClassification&suiteKey=Components&submitLabel=emxFramework.Common.Done&cancelLabel=emxFramework.Common.Cancel&cancelButton=true&submitURL=../components/emxIssueCategoryClassificationProcess.jsp?fieldNameDisplay=txtIssueCategoryClassificationDisplay&fieldNameActual=txtIssueCategoryClassification&fieldNameId=txtIssueCategoryClassificationId&fromPage=issueSBChooser&formName=IssueCreate&frameName=pageContent', 700, 500);
    }

    // Replace vault dropdown box with vault chooser.
    var txtVault = null;
    var bVaultMultiSelect = false;
    var strTxtVault = "document.forms['IssueCreate'].txtIssueVault";
    function showVaultSelector()
    {
      //This function is for popping the Vault chooser.
      txtVault = eval(strTxtVault);

     showChooser('../common/emxVaultChooser.jsp?fieldNameActual=txtIssueVault&fieldNameDisplay=txtIssueVaultDisplay&incCollPartners=false&multiSelect=false');
    }

 function clearAll()
    {
     var formObject=document.IssueCreate;

        //Setting the type to default
        formObject.txtIssueType.value="<%=XSSUtil.encodeForJavaScript(context, strTypeToDisplay)%>";
        formObject.txtIssueActualType.value="<%=XSSUtil.encodeForJavaScript(context, strType)%>";

        //Clearing the description field
        formObject.txtIssueDescription.value="";

        //Clearing the Affected Item field
        var objectid = "<%=XSSUtil.encodeForJavaScript(context, strObjectId)%>";
        var resolvedto = "<%=XSSUtil.encodeForJavaScript(context, strResolvedTo)%>";
        if ((objectid == "") || (resolvedto != ""))
        {
            formObject.txtIssueAffectedItem.value="";
            formObject.txtActualAffectedItem.value="";
        }

        //Setting Escalation required radio buttons to default
         for(i=0;i<formName.radEscalationRequired.length;i++){
            if(formObject.radEscalationRequired[i].value=="<%=XSSUtil.encodeForJavaScript(context, escalationDefault)%>")
             {
                formObject.radEscalationRequired[i].checked=true;
             }
         }

        //Clearing the Estimated Start Date and End Date fields
        formObject.txtIssueEstimatedStartDate.value="";
        formObject.txtIssueEstimatedEndDate.value="";

        //Setting the priority combo box to default
        formObject.txtIssuePriority.value="<%=XSSUtil.encodeForJavaScript(context, priorityClearAllDefault)%>";

        //Setting the Problem Type combo box to default and CoOwner to blank
        formObject.txtIssueProblemType.value="<%=XSSUtil.encodeForJavaScript(context, problemTypeClearAllDefault)%>";
        formObject.txtIssueCoOwner.value="";

        //Cleraing Resolution and Steps to reproduce fields
        formObject.txtIssueResolutionRecommendation.value="";
        formObject.txtIssueStepsToReproduce.value="";

        //Clearing Category classification filed
        formObject.txtIssueCategoryClassificationDisplay.value="";
        formObject.txtIssueCategoryClassification.value="";
        formObject.txtIssueCategoryClassificationId.value="";

        //Setting Company Filed to default
        formObject.txtIssueCompany.value="<%=XSSUtil.encodeForJavaScript(context, strCompanyName)%>";
        formObject.txtCompanyId.value="<%=XSSUtil.encodeForJavaScript(context, strCompanyId)%>";

        //Setting Vault to default
        formObject.txtIssueVault.value="<%=XSSUtil.encodeForJavaScript(context, strUserVault)%>";
        formObject.txtIssueVaultDisplay.value="<%=XSSUtil.encodeForJavaScript(context, strUserVaultDisplay)%>";
     }
     
     // A variable is used to remember the window to be refreshed
     var _tableWindowToRefresh = null;
     var _contentFrameToRefresh = null;
     
    //]]>
    </script>
<%
  }catch(Exception e){
    session.putValue("error.message", e.getMessage());
  }

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
