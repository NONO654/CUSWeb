<%@page import="com.matrixone.apps.framework.ui.*"%>
<%@page import="com.matrixone.apps.framework.taglib.*"%>
<%@page import="matrix.db.*"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.dassault_systemes.vplmintegration.VPLMIntegSynchronizerObject"%>
<%@page import="com.matrixone.vplmintegrationitf.util.VPLMIntegrationConstants"%>
<%@page import="com.matrixone.vplmintegration.util.VPLMIntegSessionUtils"%>
<%@page import="com.dassault_systemes.vplmintegration.sdk.VPLMIntegException"%>
<%@page import="com.matrixone.vplmintegration.util.VPLMIntegTraceUtil" %>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.vplmintegrationitf.itf.IVPLMChgOperations"%>
<%@page import="com.matrixone.jsystem.util.StringUtils"%>
<%@page import="matrix.db.MQLCommand"%>
<%@page import="com.matrixone.apps.framework.ui.*"%>
<%@page import="java.util.List"%>
<%-- --%>
<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="emxVPLMSynchroStringResource" locale='<%= request.getHeader("Accept-Language") %>' />
<%
	String stringResource="emxVPLMSynchroStringResource";
	 String languageStr			= request.getHeader("Accept-Language");
// get request parameters
	String objectId = emxGetParameter(request, "objectId");
	String titleKey = emxGetParameter(request, "titleKey");
	String sEnableTransfer = emxGetParameter(request, "enableTransfer");
	// client specific use case
  boolean bIsBellEnv = Boolean.valueOf(com.matrixone.jsystem.util.Sys.getEnvEx("PUEECOSync"));
 	//
  BusinessObject bo  = new BusinessObject(objectId);
	// ConfigurationConstants.TYPE_PUEECO ????
	String typePUEECO=PropertyUtil.getSchemaProperty("type_PUEECO");
	DomainObject dom=new DomainObject(bo);
	String curType=dom.getType(context);
  boolean isPUEECO = dom.isKindOf(context,typePUEECO );
	//
  String StrMQLresult="";
	MQLCommand mqlCmd = new MQLCommand();
	List<String> listOfChangeObjectsId=new ArrayList<String>();
	MapList listOfChangeObjects= new MapList();
	List<String> listOfChangeObjectsName=new ArrayList<String>();

	//Check if the transfer is enabled by the command.
	boolean bEnableTransfer = Boolean.parseBoolean(sEnableTransfer);
	if (sEnableTransfer == null || sEnableTransfer.length() == 0
			|| bEnableTransfer) 
	{
		//VKY: If transfer is enabled by the command, check if the user has the authority to transfer control.
		try {
			bEnableTransfer = VPLMIntegSessionUtils.isAuthorizedToTransferVPLMControl(context,bEnableTransfer);
		}
	  catch (VPLMIntegException me) {
	  		VPLMIntegTraceUtil.trace(context, "Error in transferring control:" + me);
			bEnableTransfer=false;
		}
	}
	
	StringBuffer contentURL=new StringBuffer("emxSynchronizeReportDialogFS.jsp");
	if(bIsBellEnv) {
		contentURL.append("?objectId=");
		contentURL.append(objectId);
		contentURL.append("&titleKey=");
		contentURL.append(titleKey);
	} else {
		// Specify URL to come in middle of frameset
		String url = "";
		// add these parameters to each content URL, and any others the App needs
		//Pass all the arguments in the URL        
		Map params = request.getParameterMap();
		java.util.Set keys = params.keySet();
		Iterator it = keys.iterator();
		int count = 0;
		while (it.hasNext())
		{
			String key = (String) it.next();
			String value[] = (String[]) params.get(key);
			if (value != null && value[0].toString().length() > 0
							&& ++count == 1) {
						url += key + "=" + value[0].toString();
			} else {
						url += "&" + key + "=" + value[0].toString();
			}
		}	
		String myQ = request.getQueryString();
		contentURL.append("?");
		contentURL.append(url);
		contentURL = new StringBuffer(Framework.encodeURL(response,
						contentURL.toString()));
	}
	contentURL.append("&SYNC_DEPTH=0");
%>

<SCRIPT LANGUAGE="JavaScript" SRC="scripts/emxUIConstants.js"
	TYPE="text/javascript"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="scripts/emxUIModal.js"
	TYPE="text/javascript"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript" SRC="scripts/emxUIPopups.js"
	TYPE="text/javascript"></SCRIPT>
<SCRIPT TYPE="text/javascript">
            addStyleSheet("emxUIDefault");
            addStyleSheet("emxUIForm");
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">
	function getSyncAndTransfertValue()
  {
  	if(document.emxSyncDialog.SYNC_AND_TRANSFER.checked==true)
    {
			return document.emxSyncDialog.SYNC_AND_TRANSFER.value;
	  }
	  else
    {
			return "no";
    }
  }
</SCRIPT>
<SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript">

	function checkInput()
	{
		var syncDepth=0;	
		var allowTransfer = <%=bEnableTransfer%>;
		var jscontentURL="<%=contentURL.toString()%>&vplmContext=" + document.emxSyncDialog.vplmContext.value+"&SYNC_AND_TRANSFER=";
		if(allowTransfer)
		{				 
			jscontentURL = jscontentURL + getSyncAndTransfertValue() ;		
		}
		else
		{
			jscontentURL = jscontentURL+ "no";
		}	
		top.location.href=jscontentURL;
	}
</SCRIPT>
<%@include file="../emxUICommonHeaderEndInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="<%=stringResource%>" locale='<%=languageStr%>' />
<FORM NAME="emxSyncDialog" ID="syncDialog" METHOD="post" ACTION="">
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="2" WIDTH="100%">
<% if(isPUEECO)
	{
%>
	<TR>
		<TD WIDTH="200" CLASS="labelRequired"><emxUtil:i18n
			localize="i18nId">emxVPLMSynchro.Preferences.VPLMContext</emxUtil:i18n>
		</TD>
		<%
		//CRK 2/25/10 IR-041724V6R2011: For current SMB product, user must select a context/role upon login through the web.
		//We should disable the role selection in the UI if the context already has a VPM role set.
		String roleFromContext = context.getRole();
		final String token_pre = "ctx::";
		if(roleFromContext.startsWith(token_pre))
		{
		//disable the selection
			%>
				<TD CLASS="inputField"><SELECT NAME="vplmContext" ID="vplmContext" DISABLED="true">
			<%
		} else {
		//enable the selection
			%>
			<TD CLASS="inputField"><SELECT NAME="vplmContext" ID="vplmContext">
			<%
		}
	  try 
	  {
			// Get User Roles
			List userRoles = PersonUtil.getUserRoles(context);
			//Check if context already has a role set
			String userRole = null;
			//If not, then get the preferred context
			if(!roleFromContext.startsWith(token_pre)) 
			{
				userRole = PropertyUtil.getAdminProperty(
					context,
					"person",
					context.getUser(),
					VPLMIntegrationConstants.PREFERENCE_VPLMINTEG_VPLMCONTEXT);
			} else {
			    userRole = roleFromContext.substring(token_pre.length());
			}
			// for each userRole choice
			for (int i = 0; i < userRoles.size(); i++) 
			{
				// get choice
				String choice = (String) userRoles.get(i);
				//keep only those values which have a "ctx::VPLM"
				if (!choice.contains(token_pre)) {
					continue;
				}
				choice = choice.substring(token_pre.length());
				// if choice is equal to default then mark it selected
				if (choice.equals(userRole)) 
				{
					%>
					<OPTION VALUE="<%=choice%>" SELECTED><%=choice%></OPTION>
					<%
				} else {
					%>
					<OPTION VALUE="<%=choice%>"><%=choice%></OPTION>
					<%
				}
			}
		} catch (Exception ex) {
			if (ex.toString() != null
					&& (ex.toString().trim()).length() > 0) {
				emxNavErrorObject.addMessage("emxPrefConversions:"
						+ ex.toString().trim());
			}
		} finally {
		}
		%>
		</SELECT></TD>
	</TR>
	
	<% 
	if (bEnableTransfer) 
	{
	%>
	<TR>
		<TD CLASS="label"><emxUtil:i18n localize="i18nId">emxVPLMSynchro.SynchronizationChange.TransferAuthoringControl</emxUtil:i18n>
		</TD>
		<!-- SM7 - Apr 04, 2012 - ECC-VPM synch Support HL- Introduced the disabled tag to disable the TC in case of configured root part and release state  -->
		<TD CLASS="inputField"><INPUT TYPE="CHECKBOX"
			NAME="SYNC_AND_TRANSFER" VALUE="give"/></TD>
	</TR>
<%}
	}
	else
	{
		// not a PUEECO => error
		String errBadType=UINavigatorUtil.getI18nString("emxVPLMSynchro.Error.BadTypeObject", stringResource, languageStr);
		errBadType=errBadType.replace("{0}",curType);
		errBadType=errBadType.replace("{1}",typePUEECO);
%>
		<tr>
		<td class="label"><%=errBadType%></td>
		</tr>
<%
	}
%>

</TABLE>
</FORM>

<%@include file="emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>



