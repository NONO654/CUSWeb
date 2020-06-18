<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProductVariables.inc"%>

<script src="../webapps/ConfiguratorWebClient/ConfiguratorWebClient.js" type="text/javascript"></script> 

<%		

String appendParams = emxGetQueryString(request);
String contextId = emxGetParameter(request,"objectId");
String strAction = emxGetParameter(request,"strAction");

		String strHelpMarker = "emxhelpproductconfigurationcreate";

		String strFooterURL = "ProductConfigurationFooter.jsp?" + appendParams;
		String strBodyURL = "ProductConfigurationCreateDialog.jsp?"+ appendParams;
		   	 	
   	  	String Directory = (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteConfiguration.Directory");
      	framesetObject fs = new framesetObject();
      	fs.setDirectory(Directory);
      	fs.setObjectId(contextId);
      	fs.setStringResourceFile("emxConfigurationStringResource");
      	
        fs.initFrameset("emxProduct.Heading.ProductConfigurationFlatViewCreate",
        		strHelpMarker,
        		strBodyURL,
                false,
                true,
                false,
                false);
        
        /* emxProduct.Button.SelectCriteria */
        fs.createFooterLink("emxProduct.Button.DefineConfiguration",
                "moveNext()",
                "role_GlobalUser",
                false,
                true,
                "common/images/buttonDialogDone.gif",
                0);

        fs.createFooterLink("emxProduct.Button.Done",
                "doneAction()",
                "role_GlobalUser",
                false,
                true,
                "common/images/buttonDialogDone.gif",
                0);
		fs.createFooterLink("emxProduct.Button.Cancel",
                "closeSlideInDialog()",
                "role_GlobalUser",
                false,
                true,
                "common/images/buttonDialogCancel.gif",
                0);
        
        fs.writePage(out);
%>  

