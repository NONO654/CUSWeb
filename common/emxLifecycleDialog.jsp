<%-- emxLifecycleDialog.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLifecycleDialog.jsp.rca 1.18 Wed Oct 22 15:48:38 2008 przemek Experimental przemek $
--%>

<html>

<%@include file = "emxNavigatorInclude.inc"%>
<%@ page import="com.matrixone.apps.framework.lifecycle.*" %>

<%@include file="emxNavigatorTopErrorInclude.inc"%>

<head>

<%@include file = "emxUIConstantsInclude.inc"%>
<%

String PFmode = emxGetParameter(request, "PFmode");

boolean isPrinterFriendly = false;
if (PFmode != null && !"null".equals(PFmode) && !"".equals(PFmode))
{
	isPrinterFriendly = "true".equals(PFmode);
} else {
	PFmode="false";
}
%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<script type="text/javascript" src="scripts/emxUIModal.js"></script>

<script type="text/javascript"> 
<%
if(isPrinterFriendly) {
%>
	addStyleSheet("emxUIDefaultPF");
	addStyleSheet("emxUILifecyclePF");
<%
} else {
%>
	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIMenu");
<%
}
%>
</script>

</head>

<body class="content" onload="turnOffProgress();">
<%
if(isPrinterFriendly)
{
	String sHeaderId            = emxGetParameter(request, "header");
	String sBusId               = emxGetParameter(request, "objectId");

    String registeredSuite = "";
	String strResourceFileId = "";
    String suiteKey = emxGetParameter(request, "suiteKey");
    if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
    {
        registeredSuite = suiteKey.substring(13);
    } else if( suiteKey != null) {
        registeredSuite = suiteKey;
    }

    //IR-088123V6R2012: re-construct resourceFileId using suiteKey.
    if ( (registeredSuite != null) && (registeredSuite.trim().length() > 0 ) )
    {
    	strResourceFileId = UINavigatorUtil.getStringResourceFileId(context, registeredSuite);
    }

    if(strResourceFileId == null || "null".equals(strResourceFileId) || !(strResourceFileId.length() > 0))
    {
      strResourceFileId = "emxFrameworkStringResource";
    }

    String sHeader = UINavigatorUtil.getI18nString(sHeaderId, strResourceFileId, request.getHeader("Accept-Language"));

    if(sHeader.indexOf("$")>=0)
    {
      	sHeader=UIExpression.substituteValues(context, sHeader, sBusId);
    }
    
    String userName = PersonUtil.getFullName(context);
    // Get the calendar on server
    Calendar currServerCal = Calendar.getInstance();
    Date currentDateObj = currServerCal.getTime();

    // Date Format initialization
    int iDateFormat = PersonUtil.getPreferenceDateFormatValue(context);
    String prefTimeDisp = PersonUtil.getPreferenceDisplayTime(context);

    java.text.DateFormat outDateFrmt = null;
    if (prefTimeDisp != null && prefTimeDisp.equalsIgnoreCase("true"))
    {
        outDateFrmt = DateFormat.getDateTimeInstance(iDateFormat, iDateFormat, request.getLocale());
    } else {
        outDateFrmt = DateFormat.getDateInstance(iDateFormat, request.getLocale());
    }

    currentDateObj = outDateFrmt.parse(outDateFrmt.format(currentDateObj));
    String currentTime = outDateFrmt.format(currentDateObj);
%>
<title><xss:encodeForHTML><%=sHeader%></xss:encodeForHTML></title>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
    <tr>
        <td>&nbsp;</td>
    </tr>
    <tr>
        <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
    </tr>
</table>
<hr noshade>
<table border="0" width="100%" cellspacing="2" cellpadding="4">
    <tr>
    <td class="pageHeader" width="60%"><xss:encodeForHTML><%=sHeader%></xss:encodeForHTML></td>
    <td width="1%">&nbsp;</td>
    <td width="39%" align="right"></td>
    <td nowrap>
    <table>
        <!-- //XSSOK -->
        <tr><td nowrap=""><%=userName%></td></tr>
        <!-- //XSSOK -->
        <tr><td nowrap=""><%=currentTime%></td></tr>
    </table>
    </td>
    </tr>
</table>
<hr noshade>
<table border="0" cellspacing="0" cellpadding="0" width="100%">
    <tr>
    <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
    </tr>
    <tr>
    <td>&nbsp;</td>
    </tr>
</table>
<%
}
%>

<center>
<%
    //Array of arrayLists eah arrayList represents row for HTM table
    ArrayList[] htmlTableCells = null;

    try
    {
        ContextUtil.startTransaction(context, false);

        //This variable stores policy detais of an object
        HashMap policyDetails =  null;

        //This variable stores Image resultant data required for life cycle rendering
        LifeCycleImageData imageData =  LifeCycleImageData.getInstance();
        LifeCyclePolicyDetails objDetails = new LifeCyclePolicyDetails();

        LifeCycleTablePresentation tableData = new LifeCycleTablePresentation();

        //This varibale is refers to interface which stores image urls required
        //for branch lifecycle renedering
        ImageUrlConstants imageRef;

        String sObjectId = emxGetParameter(request, "objectId" );
        String sAdHocRouteName= (String) EnoviaResourceBundle.getProperty(context, "emxFramework.Lifecycle.AdHocRouteName");

        policyDetails = objDetails.getPolicyDetails(context, sObjectId, sAdHocRouteName, request.getHeader("Accept-Language"));


        if ( policyDetails != null && PFmode != null )
    	{
      		// Putting the Printer Friendly Mode in the HashMap before calling the LifeCycleTablePresentation
          	policyDetails.put("PFmode", PFmode);
            htmlTableCells = tableData.generateTableForPresentation(policyDetails, sObjectId);
    	}

        ContextUtil.commitTransaction(context);
    }
    catch (Exception ex)
    {
        ContextUtil.abortTransaction(context);

        if( ( ex.toString() !=null )
            && ( ( ex.toString().trim()).length()>0 ) )
            emxNavErrorObject.addMessage(ex.toString().trim());
    }
    finally
    {
    }
%>

<table class="lifecycle" cellpadding = 0 cellspacing = 0 border = 0 >
<%
    if( htmlTableCells != null )
    {
        ArrayList eachRow = null;

        //get the table for presentation - name of array is htmlTableCells
        for (int i=0; i < htmlTableCells.length; i++)
        {
            //each element of htmlTableCells contains an arraylist which
            //holds list of cells to be displayed in the table

            //get the arraylist from table array
            eachRow = (ArrayList) htmlTableCells[i];


%>
            <tr>
<%          for( int j=0; j < eachRow.size(); j+=3 )
            {
                //renders three images in one iteration
%>
                <!-- //XSSOK -->
                <%=( (HtmlRenderable) eachRow.get(j ) ).renderImage(38 , 26 )%>
                <!-- //XSSOK -->
                <%=( (HtmlRenderable) eachRow.get(j + 1) ).renderImage(90 , 26 )%>
                <!-- //XSSOK -->
                <%=( (HtmlRenderable) eachRow.get(j + 2 ) ).renderImage(22 , 26 )%>
<%
            }
%>
        </tr>
<%
        }
    }
%>
</table>

</center>
<form name="lifecycledialog" method="post" style="display:none">
<%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
<%
  //take all params passed in and draw hidden fields
  Enumeration eNumParameters = emxGetParameterNames(request);
  while( eNumParameters.hasMoreElements() )
  {

    String strParamName = (String)eNumParameters.nextElement();

    // If the parameter contains multiple values, create multiple hidden
    // fields so that all the values are retained
    String strParamValues[] = emxGetParameterValues(request, strParamName);

    if (strParamValues != null)
    {
      for (int iCount=0; iCount<strParamValues.length; iCount++)
      {
%>
        <input type=hidden name="<xss:encodeForHTMLAttribute><%=strParamName%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=strParamValues[iCount]%></xss:encodeForHTMLAttribute>"/>
<%
      }
    }
  }
%>
</form>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>
