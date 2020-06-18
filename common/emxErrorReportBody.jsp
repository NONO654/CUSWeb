<!-- emxErrorReportBody.jsp
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program

  static const char RCSID[] = $Id: emxErrorReportBody.jsp.rca 1.6.3.2 Wed Oct 22 15:47:58 2008 przemek Experimental przemek $
-->
<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="lifecycleBeanNew" class="com.matrixone.apps.framework.lifecycle.CalculateSequenceNumber" scope="session"/>
<%
String strLanguage = request.getHeader("Accept-Language");
Locale loc = new Locale(strLanguage);
String strErrorReportDialogTitle = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.Common.Title.ErrorReportDialog", loc );
String ERROR_NO_ACCESS = "privilege";
String ERROR_NO_SIGN = "Signature";
String ERROR_TRIGGER = "trigger";
String ERROR_EXCLUDED = "Excluded";
String ERROR_FINAL_STATE = "final state";
String ERROR_INITIAL_STATE="Initial State";
String ERROR_MISC = "";
int ERROR_NO =  6;
String errorMessage = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.Common.PageHeading", loc);
String event =(String) emxGetParameter(request,"strEvent");
String pf = (String)emxGetParameter(request,"pf");
String timeStamp =(String) emxGetParameter(request,"timeStamp");
MapList  errorMapList  = lifecycleBeanNew.getErrorReportData(timeStamp);
HashMap messageMap=new HashMap();
String Count = (String) emxGetParameter(request,"totalCount");
MapList ERROR_1 = new MapList();
MapList ERROR_2 = new MapList();
MapList ERROR_3 = new MapList();
MapList ERROR_4 = new MapList();
MapList ERROR_5 = new MapList();
MapList ERROR_6 = new MapList();
MapList ERROR_7 = new MapList();
MapList ERROR_8 = new MapList();
HashMap errorMap = null;
String strError = "";
DomainObject dObj = null;
int noObjFailed = 0;
if (errorMapList != null)
{
	noObjFailed = errorMapList.size();
}
for (int i = 0; i < noObjFailed ; i++)
{
	errorMap = (HashMap)errorMapList.get(i);
	strError = (String) errorMap.get("error");
	dObj = new DomainObject((String) errorMap.get("id"));
	errorMap.put("name",(String)dObj.getName(context));
	errorMap.put("type", UINavigatorUtil.getAdminI18NString("Type", (String)dObj.getType(context), strLanguage));
	errorMap.put("revision",(String)dObj.getRevision(context));

	if(strError != null )
	{
		if (strError.contains(ERROR_NO_ACCESS) && event.equals("Promote"))
		{
		    ERROR_1.add(errorMap);
		}	
		else if (strError.contains(ERROR_NO_ACCESS) && event.equals("Demote"))
		{
		    ERROR_7.add(errorMap);
		}	
		else if (strError.contains(ERROR_NO_SIGN))
		{
		    ERROR_2.add(errorMap);
		}
		else if (strError.contains(ERROR_TRIGGER))
		{
		    ERROR_3.add(errorMap);
		}
		else if (strError.contains(ERROR_FINAL_STATE))
		{
		    ERROR_4.add(errorMap);
		}
		else if (strError.contains(ERROR_INITIAL_STATE))
        {
            ERROR_8.add(errorMap);
        }
		else if (strError.contains(ERROR_EXCLUDED))
		{
		    ERROR_5.add(errorMap);
		}
		else
		{
		    ERROR_6.add(errorMap);
		}
	}
}
HashMap hmpFinal  = new HashMap();
hmpFinal.put("0",ERROR_1);
hmpFinal.put("1",ERROR_2);
hmpFinal.put("2",ERROR_3);
hmpFinal.put("3",ERROR_4);
hmpFinal.put("4",ERROR_5);
hmpFinal.put("5",ERROR_6);
hmpFinal.put("6",ERROR_7);
hmpFinal.put("7",ERROR_8);

String tblcls = "class='list'";
if("true".equalsIgnoreCase(pf)){
	tblcls = "";
}
%>

<html>
<head>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript">
   addStyleSheet("emxUIDefault");
   addStyleSheet("emxUIList");
</script>
</head>
<body>
<%if ("true".equalsIgnoreCase(pf)){ %>
 <span class="pageHeader">&nbsp;<%=errorMessage%></span>
 <br/><span class="headerSubTitle">&nbsp;<%=strErrorReportDialogTitle%></span>
	<hr/>
<%} %>
<b><%=Integer.parseInt(Count)-noObjFailed %> <%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.MassPromote.Of", new Locale(strLanguage)) %> <%=Integer.parseInt(Count)%> <%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.MassPromote.SuccessObjects", new Locale(strLanguage)) %> <%=noObjFailed %> <%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.MassPromote.FailedObjects", loc) %>
<%
String strOdd = "odd";
String propEntryKeyheader ="";
String propEntryKeySubheader ="";
String propEntryheader ="";
String propEntrySubheader ="";
int m = 0 ;
for(int k = 0 ; k < hmpFinal.size() ; k++)
{
    m = k+1;
    propEntryKeyheader  ="emxFramework.MassPromoteDemote.ErrorMessage"+m+".heading";
    propEntryKeySubheader = "emxFramework.MassPromoteDemote.ErrorMessage"+m+".subheading";
    propEntryheader = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, propEntryKeyheader, loc );
    propEntrySubheader = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, propEntryKeySubheader, loc );
	MapList errorList = (MapList) hmpFinal.get(String.valueOf(k)) ;
	HashMap objMap  = new HashMap();

	if (errorList != null && errorList.size() > 0)
{
%>
	<hr/>
	<!-- //XSSOK -->
	<div id="errorMessageDiv"+i><span class="pageSubTitle"><%=propEntryheader%></span><br/>
	<!-- //XSSOK -->
	<%=propEntrySubheader%>
	<!-- //XSSOK -->
	<table <%=tblcls%>>
		<!-- //XSSOK -->
		<tr><th width="30%"><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.JavaScript.Type",new Locale(strLanguage))%></th><th><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.JavaScript.Name", new Locale(strLanguage))%></th><th ><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.JavaScript.Rev", new Locale(strLanguage))%></th><th ><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.JavaScript.Description", loc )%></th>
<%
	for( int j = 0 ; j < errorList.size() ; j++)
	{
    	objMap = (HashMap) errorList.get(j);
    	if (j%2 == 0)
    	{
    	    strOdd ="even";
    	}
%>
		<!-- //XSSOK -->
		<tr class = <%=strOdd%>><td width="10%" ><%=XSSUtil.encodeForHTML(context,(String) objMap.get("type"))%></td><td width="10%"><%=XSSUtil.encodeForHTML(context,(String) objMap.get("name"))%></td><td width="10%"><%=XSSUtil.encodeForHTML(context,(String) objMap.get("revision"))%></td><td width="30%"><%=XSSUtil.encodeForHTML(context,(String) objMap.get("error"))%></td>

<%
		strOdd  = "odd";
	}
%>
	</table>
<%
}
}
%>

</body>
</html>
