<%--
  CommitedRequirementList.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENORequirementsManagementBase/CNext/webroot/requirements/CommitedRequirementList.jsp 1.3.2.1.1.1 Wed Oct 29 22:20:01 2008 GMT przemek Experimental$";

 --%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags 
       are added under respective scriplet
      @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
 --%>

<%-- Include Files --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../emxTagLibInclude.inc"%>

<%--Page directives for imports --%>
<%@page import = "com.matrixone.apps.productline.Model"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "matrix.util.StringList"%>
<%@page import = "com.matrixone.apps.domain.util.eMatrixDateFormat"%>
<%@page import = "java.text.SimpleDateFormat"%>
<%@page import = "matrix.db.Context"%>
<%@page import = "com.matrixone.apps.common.Person"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>


<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>

<%!  //Declarations Section

    //Static String declarations
    private final String NAME = "emxRequirements.Table.Name";
    private final String TYPE = "emxRequirements.Table.Type";
	private final String REVISION = "emxRequirements.Table.Revision";
    private final String DESCRIPTION = "emxRequirements.Table.Description";
    private final String STATE = "emxRequirements.Table.State";
    private final String OWNER = "emxRequirements.Table.Owner";
    private final String DEFAULT_IMAGE = "../common/images/iconSmallDefault.gif";
    private final String IMAGE_PATH = "../common/images/";
    private final String COMMITEDREQUIREMENTLIST = "emxRequirements.Table.CommitedRequirementsList";
    private final String OBJECT_ID = "objectId";
    private final String EMPTY_STRING ="";
    private final String PRODUCT = "emxRequirements.Table.Product";

    //Private to get the icon using emxSystem.properties
    private String getIcon(Context context, String strType)
    {
        String strObjectIcon = null;
    strObjectIcon = UINavigatorUtil.getTypeIconProperty(context, strType);
    if (strObjectIcon == null || strObjectIcon.length() == 0 )
            strObjectIcon = DEFAULT_IMAGE;
        else
            strObjectIcon = new StringBuffer().append(IMAGE_PATH).append(strObjectIcon).toString();
        return strObjectIcon;
    }

    /**** Begin of Add by Yukthesh, Enovia MatrixOne for Bug #294638  ****/
    public String getFullNameForOwner(Context context, String strUserName)
      throws Exception {
    	String strDisplayName = com.matrixone.apps.common.Person.getDisplayName(context,EMPTY_STRING+strUserName+EMPTY_STRING);
    	return (strDisplayName);
	}
     /**** End of Add by Yukthesh, Enovia MatrixOne for Bug #294638   ****/
    //End of Declarations Section
%>

<%
	//Formatting the current Date
	SimpleDateFormat _mxDateFormat =  new SimpleDateFormat(
                        eMatrixDateFormat.getEMatrixDateFormat(),
                        Locale.US);
    //Initialising a Calendar Object
	Calendar cal = Calendar.getInstance();
    cal.add(Calendar.SECOND, -1);
    Date date = cal.getTime();
    String strDate = _mxDateFormat.format(date);

	double dblTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
    int iDateFrmt = eMatrixDateFormat.getEMatrixDisplayDateFormat();
	String strFormatDate="";
	strFormatDate=eMatrixDateFormat.getFormattedDisplayDateTime(context, strDate, false, iDateFrmt, dblTZOffset, request.getLocale());
	String strUserDate = new StringBuffer().append(getFullNameForOwner(context,context.getUser())).append(" | ").append(strFormatDate).toString();


%>

<!--html-->
<head>
<title>
  <framework:i18n localize="i18nId">
    <xss:encodeForHTML><%=COMMITEDREQUIREMENTLIST%></xss:encodeForHTML>
  </framework:i18n>
</title>

<link rel="stylesheet" href="../common/styles/emxUIDefaultPF.css" type="text/css" />
<link rel="stylesheet" href="../common/styles/emxUIListPF.css" type="text/css" />
<link rel="stylesheet" href="../requirements/emxUIProductCentral.css" type="text/css" />
  <!--body-->
  <hr noshade>
    <table border="0" width="100%" cellspacing="2" cellpadding="4">
      <tr>
       <td width="60%"class="pageHeader">&nbsp;
         <framework:i18n localize="i18nId">
           <xss:encodeForHTML><%=COMMITEDREQUIREMENTLIST%></xss:encodeForHTML>
         </framework:i18n>
       </td>
       <td width="1%"><img src="../common/images/utilSpacer.gif" width="1" height="28" alt="" />
       </td>
       <td width="39%" align="right">
         <xss:encodeForHTML><%=strUserDate%></xss:encodeForHTML>
       </td>
     </tr>
   </table>
 <hr noshade>
   <table border="0" width="100%">
     <tr>
       <td><img src="../common/images/utilSpacer.gif" border="0" width="5" height="30"
alt="" /></td>
     </tr>
   </table>
   <table border="0" cellpadding="5" cellspacing="0" width="100%">
     <tr>
       <th>
         <framework:i18n localize="i18nId">
           <xss:encodeForHTML><%=NAME%></xss:encodeForHTML>
         </framework:i18n>
       </th>
	   <th>
         <framework:i18n localize="i18nId">
           <xss:encodeForHTML><%=REVISION%></xss:encodeForHTML>
         </framework:i18n>
       </th>
    <th>
      <framework:i18n localize="i18nId">
        <xss:encodeForHTML><%=DESCRIPTION%></xss:encodeForHTML>
      </framework:i18n>
    </th>
    <th>
      <framework:i18n localize="i18nId">
        <xss:encodeForHTML><%=OWNER%></xss:encodeForHTML>
      </framework:i18n>
    </th>
	<th>
	  <framework:i18n localize="i18nId">
		<xss:encodeForHTML><%=PRODUCT%></xss:encodeForHTML>
	  </framework:i18n>
	</th>
<%

        //Initialising the Incident bean
        Model modelBean = (Model)DomainObject.newInstance(context,ReqSchemaUtil.getModelType(context),"PRODUCTLINE");
        StringList allAttribsList = null;
        try
        {
          //Calling the getCommitedRequirements() method of Model.java to get the commited features list
          allAttribsList = modelBean.getCommittedRequirementsWithProduct(context,emxGetParameter(request,OBJECT_ID));
        }
        catch(Exception IndexOutOfBoundsException)
        {
%>
          <tr width="100%">
            <td colspan = "3" align="center">
	  			<framework:i18n localize="i18nId">emxRequirements.Message.NoObjectsFound</framework:i18n>
            </td>
          </tr>

<%
        }

        //Variable which contains the size of the returned StringList
        int iSize = allAttribsList.size();
        String strAllAttribs = null;
        String strRequirementAttribs = null;
        String strIAAttribs = null;
        String strName = null;
        String strType = null;
		String strRevision = null;
        String strState = null;
        String strDescription = null;
        String strOwner = null;
        String strIcon = null;
        String strProduct = null;

    //Looping through the StringList
    for(int i = 0;i < iSize;i++)
    {
        //Getting the ith value of the StringList
        strRequirementAttribs = (String)allAttribsList.get(i);

        //Tokenising the String having the Requirement Attributes
        StringTokenizer stRequirementAttribs = new StringTokenizer(strRequirementAttribs,"|");

        //Seperating the Requirement attributes from the Requirement StringList
        strName = stRequirementAttribs.nextToken();
        //Moving String Tokenizer(getting) as it is not immediate to Name field
        strType = stRequirementAttribs.nextToken();
		strRevision = stRequirementAttribs.nextToken();
		strDescription = stRequirementAttribs.nextToken();
        if(strDescription.equals(" "))
            strDescription = "&nbsp;";
        //Moving String Tokenizer(getting) as it is not immediate to Description field
        stRequirementAttribs.nextToken();
		strOwner = stRequirementAttribs.nextToken();

	/**** Begin of Add by Yukthesh, Enovia MatrixOne for Bug #294638  ****/
	    strOwner = getFullNameForOwner(context,strOwner);
	 /**** Begin of Add by Yukthesh, Enovia MatrixOne for Bug #294638 ****/

        if(strOwner.equals(" "))
            strOwner = "&nbsp;";
 //Start of Add by Enovia MatrixOne for Bug # 315389 on 03-Mar-06
 		strProduct = stRequirementAttribs.nextToken();

	   if(strProduct.equals(" ")||strProduct==null||"null".equals(strProduct))
	    	strProduct = "&nbsp;";
 //End of Add by Enovia MatrixOne for Bug # 315389 on 03-Mar-06

		strIcon = getIcon(context, strType);//Private method defined in the declarations section above
%>
    <!--Displaying the values in the table-->
      <tr>
        <td class="listCell" style="text-align: ">
        <table border="0">
          <tr>
            <td valign="top">
              <img src="<xss:encodeForHTMLAttribute><%=strIcon%></xss:encodeForHTMLAttribute>" border="0" />
            </td>
                <td>
                  <span class="object">
                    <xss:encodeForHTML><%=strName%></xss:encodeForHTML>
                  </span>
                </td>
          </tr>
        </table>
      </td>

	  <td class="listCell" style="text-align: ">
          <xss:encodeForHTML><%=strRevision%></xss:encodeForHTML>
        </td>

        <td class="listCell" style="text-align: ">
          <xss:encodeForHTML><%=strDescription%></xss:encodeForHTML>
        </td>

        <td class="listCell" style="text-align: ">
          <xss:encodeForHTML><%=strOwner%></xss:encodeForHTML>
        </td>
	    <td class="listCell" style="text-align: ">
	      <xss:encodeForHTML><%=strProduct%></xss:encodeForHTML>
	    </td>
      </tr>

<%
    }

%>

    </table>
  <!--/body-->
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
