<%-- emxLibraryCentralClassifiedItemsSearchBasicAttributes.inc
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLibraryCentralClassifiedItemsSearchBasicAttributes.inc.rca 1.2.3.4 Wed Oct 22 16:02:11 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import="java.util.List,java.util.Map,java.util.Collections,com.matrixone.apps.library.LibraryCentralCommon" %>

<emxUtil:localize id="i18nId" bundle="emxLibraryCentralStringResource" locale='<%= request.getHeader("Accept-Language") %>' />

<%

//--Getting The Request Parameters

//Define request Parameters for toolbar
// String toolbar = "searchToolbar";
String toolbar = emxGetParameter(request, "toolbar");
String objectId = null;
String relId = null;
String sName = "*";
String sRev = "*";
String sRevLatest = "false";
String sDesc = "*";
String sOwner = "*";
String sOwnerDisplay  = "*";
String sLevels = "searchSubLevel";
boolean showAdvancedLink = true;
//get title
String title = emxGetParameter(request, "title");
String useTypeChooser = emxGetParameter(request, "useTypeChooser");
String typeSelection = emxGetParameter(request, "SelectType");
String editable = emxGetParameter(request, "editable");
String InclusionList = emxGetParameter(request, "InclusionList");
String ExclusionList = emxGetParameter(request, "ExclusionList");
String SelectAbstractTypes = emxGetParameter(request,"SelectAbstractTypes");
String selfSubmit     =  emxGetParameter(request,"selfSubmit");
String strContextLevel = emxGetParameter(request,"searchWithinLevel");

StringBuffer typeChooserUrl = new StringBuffer(UINavigatorUtil.getCommonDirectory(application)+"/emxTypeChooser.jsp?");
String languageStr = request.getHeader("Accept-Language");
boolean isTypeFieldEditable = true;
String lastSearchedTypes = "";
String translatedTypeNames = "";
String childTypeName = "";

objectId = emxGetParameter(request, "objectId");
DomainObject domObj = new DomainObject(objectId);
String typeName = domObj.getInfo(context,domObj.SELECT_TYPE);
String objName = domObj.getInfo(context,domObj.SELECT_NAME);

String sPartFamily      = LibraryCentralConstants.TYPE_PART_FAMILY;
String sGeneralClass    = LibraryCentralConstants.TYPE_GENERAL_CLASS;
String sPartLibrary     = LibraryCentralConstants.TYPE_PART_LIBRARY;
String sGeneralLibrary  = LibraryCentralConstants.TYPE_GENERAL_LIBRARY;

String sPart            = LibraryCentralConstants.TYPE_PART;
//String sDoc = "Document";

if((selfSubmit != null) && (selfSubmit.equalsIgnoreCase("True"))){
    childTypeName  = emxGetParameter(request,"txtTypeActual");
    sName = emxGetParameter(request,"txtName");
    sRev= emxGetParameter(request,"txtRev");
    sRevLatest= emxGetParameter(request,"latestRevision");
    sDesc = emxGetParameter(request,"txtDescription");
    sOwner= emxGetParameter(request,"txtOwner");
    sOwnerDisplay = emxGetParameter(request,"txtDisplayOwner");
    
    sLevels = emxGetParameter(request,"levelSelction");
   }
   


//Prepares Person chooser URL for Owner


                      
String ownerChooserUrl = Framework.encodeURL(response, "../common/emxFullSearch.jsp?field=TYPES=type_Person:CURRENT=policy_Person.state_Active&suiteKey=LibraryCentral&showInitialResults=true&type=PERSON_CHOOSER&fieldNameDisplay=txtDisplayOwner&fieldNameActual=txtOwner&selection=single&form=AEFSearchPersonForm&submitURL=AEFSearchUtil.jsp&table=AEFPersonChooserDetails");

BusinessType busType = new BusinessType(typeName,context.getVault());
String strParentType = busType.getParent(context);

InclusionList = LibraryCentralCommon.getSearchWithInInclusionList(context,typeName);

if ("".equalsIgnoreCase(childTypeName))
{
     if(InclusionList != null && !(InclusionList.indexOf(",") == -1))
    {
    	 StringBuffer buffer = new StringBuffer();
    	 String[] types = InclusionList.split(",");
    	 for (String type:types)
    	 {
    		 buffer.append(PropertyUtil.getSchemaProperty(context,type));
    		 buffer.append(",");
		 }
    	 childTypeName = buffer.toString().trim().substring(0,buffer.toString().trim().lastIndexOf(","));
	}
}
	String typeChooserUrlEncoded = "";
	try {
		ContextUtil.startTransaction(context, false);
		if (!"false".equalsIgnoreCase(useTypeChooser)
				&& !"true".equalsIgnoreCase(editable)) {
			isTypeFieldEditable = false;
		}

		if (typeSelection == null || "".equals(typeSelection)) {
			typeSelection = "multiselect";
		}

		typeChooserUrl
				.append("fieldNameDisplay=DisplayType&fieldNameActual=txtTypeActual");
		typeChooserUrl.append("&formName=SearchForm&ShowIcons=true");

		//typeChooserUrl.append("&direction=" + direction);
		typeChooserUrl.append("&ObserveHidden=false");
		typeChooserUrl.append("&SelectType=" + typeSelection);
		typeChooserUrl.append("&ReloadOpener=true");

		//Allow type chooser to use abstract types?
		if (SelectAbstractTypes != null
				&& "false".equals(SelectAbstractTypes.toLowerCase())) {
			SelectAbstractTypes = "false";
		} else {
			SelectAbstractTypes = "true";
		}
		typeChooserUrl.append("&SelectAbstractTypes="
				+ SelectAbstractTypes);
		if (InclusionList != null && InclusionList.trim().length() > 0) {
			typeChooserUrl.append("&InclusionList=" + InclusionList);

		}

		//Encode Type chooser URL
		typeChooserUrlEncoded = Framework.encodeURL(response,
				typeChooserUrl.toString());

		//get last searched types for this user

	} catch (Exception ex) {
		ContextUtil.abortTransaction(context);

		if (ex.toString() != null
				&& (ex.toString().trim()).length() > 0) {
			emxNavErrorObject.addMessage("emxSearch:"
					+ ex.toString().trim());
		}
	} finally {
		ContextUtil.commitTransaction(context);
	}
%>

<script>
    //----define the variables for type chooser

var txtType = "";
var arrTypes = "";

var bAbstractSelect = true;

function ClearSearch() {
    document.SearchForm.txtName.value = "*";
    document.SearchForm.txtRev.value = "*";
}

function clearOwner(){
    document.SearchForm.txtOwner.value='*';
    document.SearchForm.txtDisplayOwner.value='*';
}

  function showTypeSelector(varUrl)
  {
    txtType=eval(strType);
    txtDisplayType=eval(strDisType);
    showModalDialog(varUrl, 500, 400, true);
  }

  function  callDoFind(){
     //footer frame
     var footerFrame = findFrame(getTopWindow(),"searchFoot");
     alert(footerFrame);
     footerFrame.doFind();

}

      //Function to reload the page on changing the type using type chooser
    //Function to submit itself after choosing type(Reload the Page)

    //For IR-351519 : Disabling Backspace in the pop-up, for IE.  
	$(document).keydown(function(e) {
	    if (e.keyCode === 8) {
	        var element = e.target.nodeName.toLowerCase();
	        if ((element != 'input' && element != 'textarea') || $(e.target).attr("readonly")) {
	            return false;
	        }
	    }
	});

</script>

<%
  String suiteKey    = emxGetParameter(request,"suiteKey");
  if (suiteKey == null || suiteKey.equals("null") || suiteKey.equals("")){
    suiteKey = "eServiceSuiteLibraryCentral";
  }
%>


    <!--form method="post" name="SearchForm" id="SearchForm" onsubmit="doSubmit(); return false"-->
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Name</emxUtil:i18n></td>
          <td class="inputField"><input type="text" size="20" name="txtName" id="txtName" value="<xss:encodeForHTMLAttribute><%=sName%></xss:encodeForHTMLAttribute>" />
          </td>
        </tr>
<%
        // The lastest reviosn checkbox is unchecked by default but in case of refine search
        // its checked /unchked depending upon previous search Criteria
        String sChecked="";
        String checked = "";
        String sDisabled = "";
        if ( sRevLatest != null && (sRevLatest.equals ( "last" )||sRevLatest.equals ( "true" )) )
        {
             sChecked="checked";
             sDisabled = "DISABLED";
        }

%>

        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Revision</emxUtil:i18n></td>
          <td class="inputField"><input type="text" name="txtRev" id="txtRev" value="<xss:encodeForHTMLAttribute><%=sRev==null?"*":sRev%></xss:encodeForHTMLAttribute>" <%=sDisabled%> />
            <!-- XSSOK - sChecked value is not read from db or request -->
            <input type="checkbox" name="latestRevision" id="latestRevision" value="last" onclick="javascript:disableRevision()" <%= sChecked %>/><emxUtil:i18n localize="i18nId">emxLibraryCentral.Common.LatestRevisionOnly</emxUtil:i18n></td>
        </tr>

        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Type</emxUtil:i18n></td>
<%
                String[] childTypes = childTypeName.split(",");
                StringBuffer childTypeDisplayName = new StringBuffer();
                for(int i=0;i<childTypes.length;i++){
                        childTypeDisplayName.append(i18nNow.getTypeI18NString(childTypes[i],languageStr));
                        childTypeDisplayName.append(",");
                }
                String strChildTypeDisplayName = "";
                if(!(selfSubmit == null || selfSubmit.equalsIgnoreCase("null") || selfSubmit.equalsIgnoreCase(""))){
                strChildTypeDisplayName = childTypeDisplayName.toString();
                if(strChildTypeDisplayName.endsWith(",")){
                        strChildTypeDisplayName = strChildTypeDisplayName.substring(0,strChildTypeDisplayName.length()-1);
                }}
                else{
                	strChildTypeDisplayName = "*";
                }
%>
          <td class="inputField">
          <input READONLY readonly="readonly" type="text" size="16" name="DisplayType" value="<xss:encodeForHTMLAttribute><%= strChildTypeDisplayName%></xss:encodeForHTMLAttribute>" />
             <!-- XSSOK - typeChooserUrlEncoded is encoded using Framework.encodeURL -->
             <input type="button" value="..." name="btntype" id="btntype" onclick="showTypeSelector('<%=typeChooserUrlEncoded%>')" />

            &nbsp;

          <input type="hidden" name="txtTypeActual" id="txtTypeActual" value="<xss:encodeForHTMLAttribute><%=childTypeName%></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="txtTypeActualobjectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
        </tr>

        <!-- Owner-->
        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Owner</emxUtil:i18n></td>
          <td class="inputField">
            <input type="hidden" name="txtOwner" id="txtOwner" value="<xss:encodeForHTMLAttribute><%=sOwner%></xss:encodeForHTMLAttribute>" />
            <input READONLY readonly="readonly" type="text" size="20" name="txtDisplayOwner" id="txtDisplayOwner" value="<xss:encodeForHTMLAttribute><%=sOwnerDisplay%></xss:encodeForHTMLAttribute>" />
             <!-- XSSOK - ownerChooserUrl is encoded using Framework.encodeURL -->
            <input type="button" value="..." name="btnPerson" id="btnPerson" onclick="showPersonChooser('<%=ownerChooserUrl%>')" />
            <a class = "dialogClear" href = "javascript:;" onclick = "document.forms[0].txtDisplayOwner.value = '*';document.forms[0].txtOwner.value = '*'"> <emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.Clear</emxUtil:i18n></a>


          </td>
        </tr>
        <!-- Search Within -->
        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxLibraryCentral.Common.SearchWithIn</emxUtil:i18n>&nbsp;</td>
          <td class="inputField"><xss:encodeForHTML><%=objName%></xss:encodeForHTML></td>
        </tr>

        <tr>
          <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxLibraryCentral.Common.Levels</emxUtil:i18n>&nbsp;</td>
          <td class="inputField">
          <% if("Library".equalsIgnoreCase( strContextLevel ) ) { %>
            <input name="levelSelction" id="levelSelction" type="hidden" value="searchSubLevel" />
            <emxUtil:i18n localize="i18nId">emxLibraryCentral.Common.SearchSubLevel</emxUtil:i18n>
          <%} else { %>
            <select name="levelSelction" id="levelSelction">
            <%if (null!=sLevels && "searchSubLevel".equalsIgnoreCase(sLevels)){ %>
               <option value="searchSubLevel"> <emxUtil:i18n localize="i18nId">emxLibraryCentral.Common.SearchSubLevel</emxUtil:i18n> </option>
               <option value="searchThisLevel"> <emxUtil:i18n localize="i18nId">emxLibraryCentral.Common.SearchThisLevel</emxUtil:i18n> </option>
            </select>
            <%} else { %>
            
               <option value="searchThisLevel"> <emxUtil:i18n localize="i18nId">emxLibraryCentral.Common.SearchThisLevel</emxUtil:i18n> </option>
               <option value="searchSubLevel"> <emxUtil:i18n localize="i18nId">emxLibraryCentral.Common.SearchSubLevel</emxUtil:i18n> </option>
            
          <%}} %>
        </td>
    </tr>
    <tr>
      <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxDocumentCentral.Common.State</emxUtil:i18n></td>
      <td class="inputField">
        <select name="state" >
        <option value="*">*</option>
<%
        Hashtable hashPolicies  = new Hashtable();
        String state            = "";
        Vector vecStates        = new Vector();
        Vector vecAddesStates   = new Vector();
        Enumeration ePolicies ;
        String policyName       = "";
        String sSelected        = "";
        MapList mlState         = new MapList();
        HashMap hmState         = null;

        if(childTypeName != null && childTypeName.indexOf(',') == -1)
        {
            hashPolicies    =(Hashtable) LibraryCentralCommon.getAllPolicyStatesForType(context,childTypeName);
            ePolicies       = hashPolicies.keys();
            while(ePolicies.hasMoreElements())
            {
                policyName  = (String)ePolicies.nextElement();
                vecStates   = (Vector)hashPolicies.get(policyName);
                int iSize   = vecStates.size();

                for(int m = 0; m < iSize; m++)
                {
                    state       = (String)vecStates.elementAt(m);
                    sSelected   = "";
                    if("".equals(state))
                    {
                        sSelected   = "selected";
                    }
                    if(!vecAddesStates.contains(state))
                    {
                        hmState     = new HashMap();
                        hmState.put("StateActual", state);
                        hmState.put("StateDisplay", i18nNow.getStateI18NString(policyName,state,languageStr));
                        hmState.put("Selected",sSelected);
                        mlState.add(hmState);
                        vecAddesStates.addElement(state);
                    }
                    
                }
            }
            mlState.sort("StateDisplay",null,null);
            Iterator stateItr  = mlState.iterator();
            while (stateItr.hasNext()) {
                hmState     = (HashMap)stateItr.next();
                state       = (String)hmState.get("StateActual");
                sSelected   = (String)hmState.get("Selected");
%>
                <option value="<xss:encodeForHTML><%=state%></xss:encodeForHTML>" <xss:encodeForHTML><%=sSelected%></xss:encodeForHTML>><xss:encodeForHTML><%=(String)hmState.get("StateDisplay")%></xss:encodeForHTML></option>
<%
            }
        }
%>
      </td>
    </tr>
      </table>
      <table border="0" cellpadding="5" cellspacing="2" width="100%">
        <tr>
          <td>&nbsp;</td>
        </tr>
      </table>
