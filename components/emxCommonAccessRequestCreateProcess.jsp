<%--  emxCommonAccessRequestCreateProcess.jsp  -  The process page for Access Request creation.
  Copyright (c) 1992-2018  Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
  
  static const char RCSID[] = $Id: emxCommonAccessRequestCreateProcess.jsp.rca 1.3.6.5 Wed Oct 22 16:18:58 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc" %>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>
 <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>

<%
  // Access Request Type 	
  String strAccessRequestType = PropertyUtil.getSchemaProperty(context,"type_AccessRequest"); 
 
  // Access Request Policy 	
  String strRequestPolicy =  PropertyUtil.getSchemaProperty(context,"policy_AccessRequest");
 
  /**
  * Access Request Attributes
  **/ 
  String ATTRIBUTE_REASON_FOR_REQUEST =  PropertyUtil.getSchemaProperty(context,"attribute_ReasonforRequest");
  String ATTRIBUTE_INCLUDE_SELF =  PropertyUtil.getSchemaProperty(context,"attribute_IncludeSelf");
  String ATTRIBUTE_ORIGINATOR =  PropertyUtil.getSchemaProperty(context,"attribute_Originator");
 
  // Access Request Relationship
  String RELATIONSHIP_REQUESTED_DOCUMENT =  PropertyUtil.getSchemaProperty(context,"relationship_RequestedDocument");
 
  // Access Request Relationship
  String RELATIONSHIP_REQUESTED_ASSIGNEE =  PropertyUtil.getSchemaProperty(context,"relationship_RequestedAssignee");

  String jsTreeID = emxGetParameter( request, "jsTreeID" );
  String initSource = emxGetParameter( request, "initSource" );
  String suiteKey = emxGetParameter( request, "suiteKey" );
  
  /**
  * Access Request form parameters
  **/ 
  String strRequestedDocuments = emxGetParameter( request, "strRequestedDocuments" );
  String strRequestName = emxGetParameter( request, "strRequestName");
  String strReasonforRequest = emxGetParameter( request, "strReasonforRequest" );
  String strIncludeSelf = emxGetParameter( request, "strIncludeSelf");
  String autoRequestName = emxGetParameter( request, "autoRequestName" );
  String strAssigneeId = emxGetParameter( request, "hiddenAssignees" );
  
  Policy requestPolicy = new Policy( strRequestPolicy );
  requestPolicy.open( context );
  String strRequestRevision = "";
  String strRequestId = "";
  DomainObject doRequest = new DomainObject();

  if ( requestPolicy.hasSequence() ) 
  {
    strRequestRevision = requestPolicy.getFirstInSequence();
  }
  requestPolicy.close( context );

  // auto name check
  if ( autoRequestName == null || autoRequestName.equals( "null" ) )
  {
	  // BusinessObject creation
	  BusinessObject busRequest = new BusinessObject( strAccessRequestType,    
																				   strRequestName,
																				   strRequestRevision,
																				   context.getVault().getName() );
	  boolean requestexists = false;
	  if( strRequestId == null || "".equalsIgnoreCase( strRequestId ) ) 
	  {
		requestexists = busRequest.exists(context);
	  }
	  if (requestexists) 
	  {
		  com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();
		  String msgtext = loc.GetString("emxComponentsStringResource", request.getHeader("Accept-Language"), "emxComponents.Common.AlreadyExists");
		  msgtext = "'"+strRequestName+"' " + msgtext;
		  session.putValue("error.message"," " + msgtext);
                  context.shutdown();

	%>
	<jsp:forward page ="emxCommonAccessRequestCreateDialog.jsp" />
	<%
		return;
	  } 
	  else
	  {
		/**
		* Name :: Object Creation 
		**/
		  doRequest.createObject( context,
												strAccessRequestType,
												strRequestName,
												strRequestRevision,
												strRequestPolicy,
												context.getVault().getName());
		   strRequestId = doRequest.getId();
	  }
  }
  else{
	  	/**
		*  Auto name :: Object Creation
		**/
		strRequestId = FrameworkUtil.autoName( context,"type_AccessRequest","policy_AccessRequest");
		doRequest.setId(strRequestId);
  }
  
  /**
	Strore object id into description for access key purpose in giveing the  grant/revoke access on Document Object
  **/
  // QBQ : IR-468655-3DEXPERIENCER2015x : internal id has been replaced with name of the access request for security purpose. 
	  DomainObject requestObj = new DomainObject( strRequestId );
	  StringList sl = new StringList(1);
	  sl.add( DomainConstants.SELECT_NAME);
	
	   Map map = requestObj.getInfo( context, sl );
	   String strNewRequestName = ( String) map.get( DomainConstants.SELECT_NAME );
	  doRequest.setDescription(context, strNewRequestName );
   //doRequest.setDescription(context, strRequestId );
   /**
   * Attribute Values upadation
   **/
   doRequest.setAttributeValue( context, ATTRIBUTE_REASON_FOR_REQUEST,strReasonforRequest);
   doRequest.setAttributeValue( context, ATTRIBUTE_ORIGINATOR,context.getUser());
   /**
   * By deafault Include Self is true so if it is empty then updated as false
   **/
   if (strIncludeSelf == null || strIncludeSelf.equals("No") ){
		 doRequest.setAttributeValue( context, ATTRIBUTE_INCLUDE_SELF ,"No");
   }
  /**
  * Documents are connected to Access Request Object
  **/
  		 if ( ! ( strRequestedDocuments == null || strRequestedDocuments.equals("null") || strRequestedDocuments.equals("") )	)
	     {
			StringList slDocId = FrameworkUtil.split( strRequestedDocuments , "|" );
			//above split method gives one extra element, which is would be always blank.
			//it requires to be removed from the list.
			int iListSize = slDocId.size()-1;
			String relatedIds[] = new String[ iListSize ];
			for ( int i = 0; i < iListSize; i++ )
			{
				relatedIds[ i ]  = (String)slDocId.get( i );
			}
			ContextUtil.pushContext(context);
			DomainRelationship.connect( context,doRequest,RELATIONSHIP_REQUESTED_DOCUMENT,true,relatedIds);
			ContextUtil.popContext(context);
		 }
		 if ( ! ( strAssigneeId == null || strAssigneeId.equals("null") || strAssigneeId.equals("") )	)
	     {
			strAssigneeId = FrameworkUtil.findAndReplace(strAssigneeId,"|",",");
			StringList slAssigneeIds = FrameworkUtil.split( strAssigneeId, "," );
			int iListSize = slAssigneeIds.size();
			String relatedIds[] = new String[ iListSize ];
			for ( int i = 0; i < iListSize; i++ )
			{
				relatedIds[ i ]  = PersonUtil.getPersonObjectID(context, (String)slAssigneeIds.get( i ));
			}
			DomainRelationship.connect( context,doRequest,RELATIONSHIP_REQUESTED_ASSIGNEE,false,relatedIds);
	   }
%>
<script>
	alert("<emxUtil:i18n localize = "i18nId">emxComponents.AccessRequest.RequestCreatedAlertMsg</emxUtil:i18n>");
	parent.window.closeWindow(); //IR-571153-3DEXPERIENCER2019x AND IR-373510-3DEXPERIENCER2019x
</script>
