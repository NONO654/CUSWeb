<%@ page import="matrix.db.*,matrix.util.*,com.matrixone.MCADIntegration.server.beans.*, matrix.util.*,com.matrixone.apps.domain.*,com.matrixone.MCADIntegration.server.cache.*" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../components/emxComponentsNoCache.inc"%>
<%@include file = "../components/emxComponentsUtil.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<html>
    <head>
	<script>
	function getIntegrationFrame(win)
	{
		var hldrIntegrationFrame = null;
		var obj = win.getTopWindow();
		if(obj.integrationsFrame != null && obj.integrationsFrame.eiepIntegration != null)
		{
			//Current window has Integration frame.
			hldrIntegrationFrame = obj.integrationsFrame.eiepIntegration;
		}
		else if(obj.opener != null && !obj.opener.closed)
		{
			//Looking in opener...
			hldrIntegrationFrame = getIntegrationFrame(obj.opener);
		}

		return hldrIntegrationFrame;		
	}	
	
	function checkout(objectsInfo)
	{    
		var integrationFrame = null;
		if (opener == null || opener != "undefined")
		{
		   integrationFrame = getIntegrationFrame(this);
		}
		else
		{
		   integrationFrame = getIntegrationFrame(opener);
		}
		
		//cannot go ahead if unable to locate integration frame.
		if(integrationFrame == null)
		{
			alert("Integration Applet is not available. Please close the browser and login again.");
			return;
		}	
		
		//Yoe Needs some code cleanup
		var result = integrationFrame.getAppletObject().callCommandHandler("", "checkoutFromApps", "MSOffice|"+ objectsInfo + "|true");

	}
	</script>
	</head>
	 <body>
<%
	String strPartId = null;
	Map emxCommonDocumentCheckoutData = (Map) session.getAttribute("emxCommonDocumentCheckoutData");
	String objectAction = (String)emxCommonDocumentCheckoutData.get("objectAction");
    String action  = (String)emxCommonDocumentCheckoutData.get("action");
	String errorMessage = (String) emxCommonDocumentCheckoutData.get("error.message");
	String filename = (String) emxCommonDocumentCheckoutData.get("fileName");
   
	String[] objectIds = (String[]) emxCommonDocumentCheckoutData.get("objectIds");
	String correctObjectId = null;
	correctObjectId = objectIds[0];
	if(((Boolean)emxCommonDocumentCheckoutData.get("multipleObjectIds")).booleanValue() == true)
	{
		String message = null;
		String closemessage = null;
		ResourceBundle mcadIntegrationBundle = ResourceBundle.getBundle("iefStringResource");
		try
		{
			message  = mcadIntegrationBundle.getString("msdi.MultipleSelectionNotAllowed");
			closemessage = mcadIntegrationBundle.getString("msdi.CloseCheckoutPage");
		}
		catch(MissingResourceException _ex)
		{
			message = "Please select a single file or object to checkout";
			closemessage = "Close";
		}
%>
	<div>
	<br/><br/><br/><br/><br/><br/>
	<center>
	<!--XSSOK-->
	<p><%= message %></p>
    <button onClick="javascript:top.close()"><!--XSSOK-->
			<%= closemessage%>&nbsp;&nbsp;
	</button>
	</center>
    </div>
<%
		return;
	}

	// Code to check for multifile obj
	Map mapDocumentFileNames = (Map)emxCommonDocumentCheckoutData.get("documentFileNames");
	boolean bMultifileCheck = false;
		
	DomainObject majorObject1 = new DomainObject(correctObjectId);
	FileList fileList1 = majorObject1.getFiles(context);
    if(fileList1.size() >1 && filename == null )
	{
		String message = null;
		String closemessage = null;
		ResourceBundle mcadIntegrationBundle = ResourceBundle.getBundle("iefStringResource");
		try
		{
			message  = mcadIntegrationBundle.getString("msdi.MultifileObjectErrorMessage");
			closemessage = mcadIntegrationBundle.getString("msdi.CloseCheckoutPage");
		}
		catch(MissingResourceException _ex)
		{
			message = "Please go to the Files page and select a single file to checkout";
			closemessage = "Close";
		}
%>
	<div>
	<br/><br/><br/><br/><br/><br/>
	<center>
	<!--XSSOK-->
	<p><%= message %></p>
    <button onClick="javascript:top.close()"><!--XSSOK-->
			<%= closemessage%>&nbsp;&nbsp;
	</button>
	</center>
    </div>
<%
		return;
	}
    emxCommonDocumentCheckoutData.put("refresh", "true");

	
	String objectIDforCheckout = null;
	boolean skipCheckout = false;
   
	if(action.equals("checkout") && !skipCheckout)
	{
		String successmessage = null;
		String checkoutdonemessage = null;
		boolean bObjectIdSet = false;
		BusinessObject majorObject = new BusinessObject(objectIds[0]);   
		MCADMxUtil _util = new MCADMxUtil(context,null,new IEFGlobalCache());
		BusinessObject versionObject = null;
		try
		{
		   if(filename != null)
			{
			   versionObject = _util.getCDMMinorObjectWithFileNameAsTitle(context,majorObject,filename);
			   String versionObjectId = versionObject.getObjectId(context);
			   ResourceBundle mcadIntegrationBundle = ResourceBundle.getBundle("iefStringResource");
			   try
			   {
				  successmessage  = mcadIntegrationBundle.getString("msdi.Checkoutdone");
				  checkoutdonemessage = mcadIntegrationBundle.getString("msdi.CheckoutSuccess");
				  objectIDforCheckout = new String (versionObjectId);
				  correctObjectId = objectIDforCheckout;
				  //correctObjectId = objectIds[0];
				  bObjectIdSet = true;
			   }
			   catch(MissingResourceException _ex)
			   {
				   successmessage = "Please click on Done after checkout is complete";
				   checkoutdonemessage = "Done";
			   }
			}

			else
			{
				ResourceBundle mcadIntegrationBundle = ResourceBundle.getBundle("iefStringResource");
			   try
			   {
				  successmessage  = mcadIntegrationBundle.getString("msdi.Checkoutdone");
				  checkoutdonemessage = mcadIntegrationBundle.getString("msdi.CheckoutSuccess");
				  correctObjectId = objectIds[0];
				  bObjectIdSet = true;
			   }
			   catch(MissingResourceException _ex)
			   {
				   successmessage = "Please click on Done after checkout is complete";
				   checkoutdonemessage = "Done";
			   }

			}
		}
	    catch(Exception e)
		{
			ResourceBundle mcadIntegrationBundle = ResourceBundle.getBundle("iefStringResource");
			try
			{
				successmessage	= mcadIntegrationBundle.getString("msdi.Checkoutdone");
				checkoutdonemessage = mcadIntegrationBundle.getString("msdi.CheckoutSuccess");
				objectIDforCheckout = correctObjectId;
				bObjectIdSet = true;
			}
			catch(MissingResourceException _ex)
			{
				successmessage = "Please click on Done after checkout is complete";
				checkoutdonemessage = "Done";			
			}
		}
%>
	<div>
	<br/><br/><br/><br/><br/><br/>
	        <center>
			<!--XSSOK-->
			<p><%= successmessage %></p>
          <button onClick="javascript:top.close()"><!--XSSOK-->
			<%= checkoutdonemessage %>&nbsp;&nbsp;
		  </button>
			</center>
    </div>
	<script>
		<% 
			DomainObject correctedBusObject = DomainObject.newInstance(context, correctObjectId);
			StringList selectsName = new StringList(3);
			selectsName.add(DomainConstants.SELECT_NAME);
			Map objectSelectMap2 = correctedBusObject.getInfo(context,selectsName);                                
			String busName = (String)objectSelectMap2.get(DomainConstants.SELECT_NAME);
		%>
		//XSSOK
		checkout('<%= correctObjectId%>' + '|' + '<%=busName%>');
	</script>

<%
		}

		else if(skipCheckout)
		{
%>
	<div>
	<br/><br/><br/><br/><br/><br/>
	        <center>
			<p>Please go inside the multifile doc and checkout</p>
          <button onClick="javascript:top.close()">
			Close&nbsp;&nbsp;
		  </button>
			</center>
    </div>
 <%
		}
%>
   </body>
  </html>
