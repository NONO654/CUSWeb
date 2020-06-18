<%--  emxCommonRequestAccessAutoPromotoProcess.jsp  -  The process page for  Approve,Reject and Expire a Request Access Object.
  Copyright (c) 1992-2018  Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
  
  static const char RCSID[] = $Id: emxCommonAccessRequestProcess.jsp.rca 1.5.7.5 Wed Oct 22 16:18:43 2008 przemek Experimental przemek $
--%>

<%@ include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@ include file = "emxComponentsUtil.inc" %>
<%@ include file = "../common/emxTreeUtilInclude.inc" %>
<%@page import = "com.matrixone.apps.domain.util.*" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="navigatorUtilBean" class="com.matrixone.apps.framework.ui.UINavigatorUtil" scope="session"/>

<script language = "JavaScript" src = "../common/scripts/emxUIConstants.js" type = "text/javascript"></script>
<%!
/** A string constant with the value state_Submitted. */
static final String SYMB_SUBMITTED = "state_Submitted";
/** A string constant with the value state_Review. */
static final String SYMB_REVIEW = "state_Review";
/** A string constant with the value state_Expired. */
static final String SYMB_EXPIRED = "state_Expired";
/** A string constant with the value state_Approved. */
static final String SYMB_APPROVED = "state_Approved";
/** A string constant with the value state_Approved. */
static final String SYMB_REJECTED = "state_Rejected";

%>

<%


final String RELATIONSHIP_REQUESTED_ASSIGNEE = PropertyUtil.getSchemaProperty(context,"relationship_RequestedAssignee");

String[] requestId = emxGetParameterValues( request, "emxTableRowId" );
requestId=navigatorUtilBean.getTableRowIDsArray(requestId);
String strMode = emxGetParameter( request, "mode" );
String fromPropertiesPage = emxGetParameter( request, "fromPropertiesPage" );
if("Extend".equalsIgnoreCase(strMode))
{
	String objectId=(String)emxGetParameter( request, "objectId" );
	%>
	<%
	return;
}

String strMsg = "";
boolean result =false;

if("true".equals(fromPropertiesPage))
{
	String strObjectId = emxGetParameter( request, "objectId" );
	result = executeCommandAction(context, strObjectId,strMode);
}
else
{
   for ( int count = 0; count<requestId.length; count++)
   {
		String strObjectId = (String)requestId[count];

	   if( "Remove".equals( strMode ) )
	   {
			String objectId = emxGetParameter( request, "objectId" );
			StringList objectSelects= new StringList(1);
			objectSelects.add( DomainConstants.SELECT_ID );
			StringList relSelects= new StringList(1);
			relSelects.add( DomainConstants.SELECT_RELATIONSHIP_ID );

			DomainObject docObj =  new DomainObject( objectId );
			MapList assignMapList = docObj.getRelatedObjects( context,
																					RELATIONSHIP_REQUESTED_ASSIGNEE,
																					"*", 
																					objectSelects,
																					relSelects,
																					true,
																					false,
																					(short)1,
																					"id == \"" +strObjectId+ "\"",
																					null);
			Map assigneeMap = (Map)assignMapList.get(0);
			DomainRelationship.disconnect( context, (String)assigneeMap.get(DomainConstants.SELECT_RELATIONSHIP_ID));
			result = true;
	   }
	   else
	   {
		   if(executeCommandAction(context, strObjectId,strMode))
		   {
				result = true;
		   }
	   }
    }
}

if("Remove".equals(strMode) || "true".equals(fromPropertiesPage))
{
	if(result)
	{
			%>
			<script language="JavaScript">
			
			getTopWindow().refreshContentPage();
			</script>
		<%
	   }
	else
	{
%>
		<script>
		  alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.AccessRequest.promote<%=XSSUtil.encodeForJavaScript(context, strMode)%>Alert</emxUtil:i18nScript>");
		</script>
<%
	}
}
else
{
	if (result)
	{
	%>
	<script language="JavaScript">
	getTopWindow().refreshContentPage();
	</script>
	<%
}
else
{
%>
	<script>
      alert ("<emxUtil:i18nScript localize="i18nId">emxComponents.AccessRequest.promote<%=XSSUtil.encodeForJavaScript(context, strMode)%>Alert</emxUtil:i18nScript>");
	</script>
<%
}
}
%>

<%!  

public void putSignature( Context context, String strMode, String requestId ) throws MatrixException
{
        com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context, "approve bus $1 signature $2 comment $3 ", requestId,"To"+strMode,strMode);
}
private boolean executeCommandAction(Context context, String objId,String strMode) throws Exception
{ 
	final String POLICY_DOWNLOAD_ACCESS_REQUEST = PropertyUtil.getSchemaProperty(context,"policy_AccessRequest");
	String strSubmitted = FrameworkUtil.lookupStateName(context, POLICY_DOWNLOAD_ACCESS_REQUEST, SYMB_SUBMITTED);
	String strApproved = FrameworkUtil.lookupStateName(context, POLICY_DOWNLOAD_ACCESS_REQUEST, SYMB_APPROVED);
	String strReview = FrameworkUtil.lookupStateName(context, POLICY_DOWNLOAD_ACCESS_REQUEST, SYMB_REVIEW);
	String strExpired = FrameworkUtil.lookupStateName(context, POLICY_DOWNLOAD_ACCESS_REQUEST, SYMB_EXPIRED);
	String strRejected = FrameworkUtil.lookupStateName(context, POLICY_DOWNLOAD_ACCESS_REQUEST, SYMB_REJECTED);
	
	DomainObject domAccessRequest = new DomainObject();
	domAccessRequest.setId(objId);

	String strCurrent = domAccessRequest.getInfo(context,DomainConstants.SELECT_CURRENT);

	if ( strMode.equals( strExpired ) )
	   {
			if ( strCurrent.equals( strApproved ))
		   {
				domAccessRequest.promote( context);
		   }
		   else
		   {
				return false;
		   }
	   }
	   else if ( strMode.equals( strApproved ) )
	   {
		   	if ( strCurrent.equals( strSubmitted ) )
			{
				domAccessRequest.promote( context);
				try
				{
					com.matrixone.apps.domain.util.MqlUtil.mqlCommand( context, "unsign bus $1 signature $2",objId, "ToRejected");
				}catch(Exception e)
				{//no need to do throw.
				}
				putSignature( context, strMode,  objId );
			}
		    else if ( strCurrent.equals( strReview ) )
			{
				try
				{
					com.matrixone.apps.domain.util.MqlUtil.mqlCommand( context, "unsign bus $1 signature $2", objId, "ToRejected" );
				}catch(Exception e)
				{//no need to do throw.
				}
				putSignature( context, strMode,  objId );
			}	
			else
		   {
				return false;
		   }
	   }
	   else if ( strMode.equals( strRejected ) )
	   {
			if ( strCurrent.equals( strSubmitted ) )
			{
				domAccessRequest.promote( context);
				putSignature( context, strMode,  objId );
			}
		    else if ( strCurrent.equals( strReview ) )
			{
				putSignature( context, strMode,  objId );
			}	
			else
		   {
				return false;
		   }
	   }
	   else if ( strMode.equals( strSubmitted ) )
	   {
		    if ( strCurrent.equals( strReview ) )
			{
				domAccessRequest.demote(context);
			}
			else if ( strCurrent.equals( strRejected ) )
			{
				domAccessRequest.promote(context);
			}
			else
			{
				return false;
		    }
	   }
	   else if ( strMode.equals( strReview ) )
	   {
		    if ( strCurrent.equals( strSubmitted ) )
			{
				domAccessRequest.promote( context);
			}
			else if ( strCurrent.equals( strApproved ) )
		    {
				domAccessRequest.demote( context);
		    }
			else if ( strCurrent.equals( strRejected ) )
		    {
				domAccessRequest.demote( context);
		    }
			else
		    {
				return false;
		    }
	   }
	   return true;
}

%>
