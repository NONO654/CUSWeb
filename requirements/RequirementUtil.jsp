<%--
  RequirementUtil.jsp

  Performs the action that creates an incident.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /web/requirements/RequirementUtil.jsp 1.10.2.1.1.1.1.1 Wed Dec 03 15:12:00 2008 GMT ds-bcasto Experimental$";

<%-- @quickreview T25 OEP  12:12:10  :  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet
     @quickreview T25 OEP  12:12:18  :  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview LX6 QYG  13:03:19  :  UI enhancement : refresh of the lifeCycle in proerties forms 
     @quickreview T25 DJH  13:10:25  :  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
	 @quickreview ZUD DJH  13:12:10  :  IR-233743V6R2015 An loading icon does not disappear 
	 @quickreview JX5 QYG  14:01:31  :  HL RMT Create Derivation links between Requirements
	 @quickreview JX5      14:07:17  :  HL RMT Create Derivation links between Requirements
	 @quickreview JX5      14:08:07  :  HL RMT Create Derivation links between Requirements - Special Characters
	 @quickreview HAT1 ZUD 14:08:13  :  Test Case count under validation column of REQ SPEC and Chapter.
	 @quickreview JX5      14:08:29  :  IR-320911-3DEXPERIENCE2015x Deleting derivation link is KO
	 @quickreview HAT1 ZUD 14:10:08  :  IR-331758-3DEXPERIENCER2015x STP: IE11 - Expand All on Req. Spec. Str. view gives XML Error.
	 @quickreview JX5	   14:10:10	 :  IR-333470 There is no tooltip on the objects displayed in the source and targets trees. 
	 @quickreview HAT1 ZUD 14:12:22	 :  HL Requirement Specification Dependency.
	 @quickreview ZUD	   15:01:27	 :  Fix For IR-349181-3DEXPERIENCER2016x
	 @quickreview ZUD	   15:02:05	 :  Fix For IR-352177-3DEXPERIENCER2016x IR-352455-3DEXPERIENCER2016x  IR-352416-3DEXPERIENCER2016x
     @quickreview HAT1 ZUD 15:02:11	 :  HL - Requirement Specification dependency. Tabs and buttons support in checkConsistency dialog.
	 @quickreview KIE1 ZUD 15:02:24  : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
	 @quickreview ZUD      15:02:24  : IR-356259-3DEXPERIENCER2016x V6R 2016x- 041578 :Application doesn't take preferences setting after first time login
	 @quickreview KIE1 ZUD 15:02:13  : IR-333259-3DEXPERIENCER2016 Parameter value displayed in "Content" cell contains unexpected "null" values
	 @quickreview JX5	   15:04:07  : IR-363767 Special Characters in the title field of Requirement Specification make Traceability authoring command KO. 
	 @quickreview ZUD 	   15:04:10  : IR-362248-3DEXPERIENCER2016x :[On-Premise] Export to work KO on 3DExperience On -Premise server.
	 @quickreview JX5	   15:04:17  : IR-366466-3DEXPERIENCER2016x : R418:STP:Expand all on tree display of traceability authoring command window is KO.
     @quickreview HAT1 ZUD 15:04:22  : IR-364298-3DEXPERIENCER2016x- FUN048478:Preference under Tree display option are not getting applied. 
     @quickreview HAT1 ZUD 15:04:23  : IR-364538-3DEXPERIENCER2016x- FUN048478:By default no option selected in Traceability Management section in Preferences tab. 
     @quickreview ZUD HAT1 15:04:27  : IR-364087-3DEXPERIENCER2016x : All target Req spec for existing dependency is not available in the traceability authoring command. Removal of hardcoded Req-Spec SubTypes value. Function getDerivedRequirementSpecificationRelationship() used to get rel name.
     @quickreview HAT1 ZUD 15:05:04  : Relationship direction modification for covered and refined requirements.
     @quickreview HAT1 ZUD 15:05:07  : IR-369433-3DEXPERIENCER2016x FIX Requirement: When creating requirement, garbage characters are displayed when user input Chinese characters.
     @quickreview JX5	   15:05:29  : IR-370825-3DEXPERIENCER2016x : Create links to cover requirements take too much time to launch
	 @quickreview KIE1 ZUD 18 JUN 2015  IR-364213-3DEXPERIENCER2016x : Issue on exporting the filtered objects of a specification to MS Word: RMC.
     @quickreview JX5	   15:06:11  : Autoname checked by default
     @quickreview KIE1 ZUD 15 JUL 2015  IR-382753-3DEXPERIENCER2016x: R418-STP: In Export To Word, Parameter, Test Case and Sub Requirements are getting supported and displayed in Import form.
     @quickreview HAT1 ZUD 15:07:15  : IR-381800-3DEXPERIENCER2016x - Solving inconsistency with create link command is KO.  
     @quickreview JX5	   15:07:27  : IR-388595-3DEXPERIENCER2016x - Creation of Usecase form display wrong label on usecase and code in form label of sub use case. 
     @quickreview HAT1 ZUD 15:07:16  : IR-381584-3DEXPERIENCER2016x - Wrong Tree structure is displayed in Create Link to Covered Requirement and check consistency pop-up windows.
     @quickreview ZUD      15:07:29   : IR-362248-3DEXPERIENCER2016x :[On-Premise] Export to work KO on 3DExperience On -Premise server.  
     @quickreview HAT1 ZUD 04:08:15  : LA Settings for ReqSpec Dependency HL
     @quickreview HAT1 ZUD 07:08:15  : IR-381835-3DEXPERIENCER2016x R418-FUN048478-Creation of Requirement specification traceability dependency is KO with some preference.
     @quickreview HAT1 ZUD 15:08:19  : IR-363246-3DEXPERIENCER2016x FUN048478:No option available to remove the target Requirement Specification from Create likn to cover\refine requirement pop upso that persistent dependencies can be deleted.
     @quickreview      ZUD 15:08:26  : IR-393038-3DEXPERIENCER2016x R418-FUN041578: After update of exported Document from RMC format, "Title" & "Content" of an object changes 

     @quickreview KIE1 ZUD 15:08:24  IR-386290-3DEXPERIENCER2016x: PLM Parameter migration
     @quickreview      ZUD 15:10:19  IR-396471-3DEXPERIENCER2017x : R418-FUN041578: In Export To Word document wrong sequence and hierarchy of object is displayed after preforming copy-paste operation in webtop.
     @quickreview HAT1 ZUD 16:02:03  HL -  To enable Content column for Test Cases. 
     @quickreview HAT1 ZUD 16:02:16  HL - ( xHTML editor for Use case) To enable Content column for Test Cases.
     @quickreview HAT1 ZUD 16:05:03  Populating title as per autoName of Name in Web form.
     @quickreview HAT1 ZUD 16:05:17  IR-433769-3DEXPERIENCER2017x:R419-FUN058646:NLS: On TRM object default value in Title attribute is not getting translated.
     @quickreview KIE1 ZUD 06:27:16  : IR-433967-3DEXPERIENCER2017x/ 14x: User must expand structure at least once for the Export to Word to include whole structure. Otherwise, it will just export what is on the screen.
     @quickreview KIE1 ZUD  16:07:19 : IR-448762-3DEXPERIENCER2017x: Tree preferences not applicable on Structure browser
     @quickreview HAT1 ZUD 16:08:03  IR-446064-3DEXPERIENCER2017x: Java error is displayed when try state up in different collaboration space.
     @quickreview QYG      16:08:15  changes to include RCO content in exported Word document.
     @quickreview ZUD      16:08:17 : Reserve/UnReserve Command for RMT Types in attribute Tab
     @quickreview KIE1 ZUD 16:11:04 : IR-475850-3DEXPERIENCER2018x: R419-FUN055837: Unnecessary Requirement object is getting created, after error message object type name revision not unique on creation form.
     @quickreview KIE1 ZUD 16:12:14 : R419-UX: Improper header for Create Requirement Specification, Requirement, Chapter, comment slideIn
     @quickreview HAT1 ZUD 17:02:22 : IR-502186-3DEXPERIENCER2018x: R420:FUN066070: Sub-Requirements are not getting Exported to Word.  
     @quickreview HAT1 ZUD 17:05:23 : HL - TSK3278161:	ENOVIA GOV TRM Deprecation of functionalities to clean up  
     @quickreview HAT1 ZUD 17:06:06 : IR-526839-3DEXPERIENCER2018x: ENOVIA GOV TRM Deprecation of functionalities to clean up
     @quickreview KIE11 ZUD 17:09:13 : IR-549171-3DEXPERIENCER2018x:   R20-STP: Export to Word become KO after invoking contextual menu.  
     @quickreview KIE1 ZUD 18:02:09 TSK3863562 : oslc_ENOVIA GOV Requirements OSLC support  
     @quickreview      ZUD 18:11:20 : IR-641061-3DEXPERIENCER2017x : Requirements not loading into the Cover dialog box
     @quickreview KIE1 ZUD 18:11:21 : IR-643386-3DEXPERIENCER2019x : finished removed the feature in requirements satisfied page the page will jump to overview page rather then stay on the current page
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.jdom.Parent"%>
<%@page import="java.awt.Window"%>
<%@page import="java.awt.Color"%>
<%@page import="com.matrixone.jdom.Element"%>
<%@page import="com.dassault_systemes.requirements.ReqConstants"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.matrixone.jdom.output.*"%>
<%@page import="com.matrixone.jdom.input.*"%>
<%@page import="com.matrixone.util.MxXMLUtils"%>


<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Vector"%>
<%@page import = "com.matrixone.apps.common.util.FormBean"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.Model"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.requirements.Requirement"%>
<%@page import = "com.matrixone.apps.requirements.RequirementsCommon"%>
<%@page import = "com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainRelationship"%>
<%@page import = "com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import = "com.dassault_systemes.enovia.webapps.richeditor.util.RichEditFactory"%>
<%@page import = "com.dassault_systemes.enovia.webapps.richeditor.util.IRichEditUtil"%>
<%@include file = "emxProductVariables.inc" %>
<%@page import="java.io.InputStream"%>
<%@page import="java.util.zip.GZIPInputStream"%>
<%@page import="java.util.Iterator"%>


<%@page import="org.apache.poi.util.IOUtils"%>

<%@ page import="com.aspose.words.Document"%>
<%@ page import="com.aspose.words.DocumentBuilder"%>
<%@ page import="com.aspose.words.*"%>

<%@page import="org.apache.commons.fileupload.*,java.util.*,java.io.*"%>
<%@page import = "java.util.Collections" %>
<%@page import="org.apache.commons.fileupload.*,java.util.*,java.io.*"%>
<%@page import ="com.matrixone.apps.requirements.SpecificationStructure" %>
<%@page import="com.matrixone.apps.requirements.ui.UITableRichText"%>

<%@page import="java.util.Enumeration"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="java.util.Date"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>
<%@page buffer="100kb" autoFlush="true" %>

<html>
    <script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
    <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
    <jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>  
    <jsp:useBean id="richtextTableBean"
	class="com.matrixone.apps.requirements.ui.UITableRichText"
	scope="session" />
    <form name="frm">

        <%!
            void AddParam(javax.servlet.http.HttpServletRequest request, Map params, String key) {
                String value = emxGetParameter(request, key);
                if (value != null) {
                    params.put(key, value);
                }
            }

            String getCopyWithLinkParameter(String[] tokens) {
                String CopyWithLink = "false";
                for (int i = 0; i < tokens.length; i++) {
                    if (tokens[i].contains(ReqConstants.COPY_WITH_LINK)) {
                        String Values[] = tokens[i].split(":");
                        CopyWithLink = Values[1];
                    }
                }
                return CopyWithLink;
            }
          
			
		  //++ HAT1 ZUD: IR-640730-3DEXPERIENCER2019x ++
          String getFromWebAppParameter(String[] tokens)
      	  {
      	    String isFromWebApp  = "false";
      	    for(int i = 0; i < tokens.length; i++)
      	    {
      	      if(tokens[i].contains(ReqConstants.FROM_WEB_APP))
      	      {
      	        String Values[] = tokens[i].split(":");
      	        isFromWebApp = Values[1];
      	      }
      	    }
      	    return isFromWebApp;
      	  }
		  // -- HAT1 ZUD: IR-640730-3DEXPERIENCER2019x --
            
// ++ ZUD Functions for HL ENOVIA GOV TRM Export to MS Word ++ 
/*            public static com.aspose.words.Document GetHtmlDoc( String Html)
        	 
           	{
            	com.aspose.words.Document HtmlDoc = null;            	
            	try
            	{
            		HtmlDoc = new com.aspose.words.Document();
            		com.aspose.words.DocumentBuilder builder = new DocumentBuilder(HtmlDoc);
            		builder.insertHtml(Html);
            		return HtmlDoc;
            		
           	    }
            	catch(Exception e)
            	{
            		
           	    }

           	    return HtmlDoc;
           	 
           	}
            

            public static com.aspose.words.Document GetrtfDoc( String rtfString)
        	 
           	{
            	com.aspose.words.Document rtfDoc = null;
            	
            	try
            	{           	   
            		// Check for the format identifier at the begining of the string. If this does not exist
            		// add it as it is needed for the content to be loaded into a new document.
            		String magicNumber = "{\\rtf1";
            		
            		if (!rtfString.startsWith(magicNumber))
            			rtfString = magicNumber + rtfString;
            		
            		// Convert the string into an array of bytes and pass it into a new memory stream.
            		byte[]dataBytes = rtfString.getBytes("UTF-8");
            		InputStream byteStream = new ByteArrayInputStream(dataBytes);
            		
            		// Load RTF stream into a new document.
            		rtfDoc = new com.aspose.words.Document(byteStream);
            	}
            	catch(Exception e)
            	{
            		
            	
           	    }
           	    return rtfDoc;           	 
           	}
*/            	

            	
           	public static void insertDocument(com.aspose.words.Paragraph ipara, com.aspose.words.Document srcDoc , Color tobefilled) throws Exception
           	{
           		
           		com.aspose.words.Node insertAfterNode = ipara;
           		// Make sure that the node is either a paragraph or table.
           	    if ((insertAfterNode.getNodeType() != com.aspose.words.NodeType.PARAGRAPH) &
           	      (insertAfterNode.getNodeType() != com.aspose.words.NodeType.TABLE))
           	        throw new IllegalArgumentException("The destination node should be either a paragraph or table.");
				
           	// Remove Bookmark from source document (created while inserting rtf or HTML content)
           	 BookmarkCollection bmcollec = srcDoc.getRange().getBookmarks();
   	         Iterator IT = bmcollec.iterator();
   	         while ( IT.hasNext())
   	         {
   	        	com.aspose.words.Bookmark bookmark = (com.aspose.words.Bookmark) IT.next();
   	        	bookmark.remove();
   	         }
   	         
           	    // We will be inserting into the parent of the destination paragraph.
           	    com.aspose.words.CompositeNode dstStory = insertAfterNode.getParentNode();
           	 	
           	    // This object will be translating styles and lists during the import.
           	    com.aspose.words.NodeImporter importer = new com.aspose.words.NodeImporter(srcDoc, insertAfterNode.getDocument(), ImportFormatMode.USE_DESTINATION_STYLES/*.KEEP_SOURCE_FORMATTING*/);

           	    // Loop through all sections in the source document.
           	    for (com.aspose.words.Section srcSection : srcDoc.getSections())
           	    {
           	        // Loop through all block level nodes (paragraphs and tables) in the body of the section.
           	        for (com.aspose.words.Node srcNode : (Iterable<com.aspose.words.Node>) srcSection.getBody())
           	        {
           	            // Let's skip the node if it is a last empty paragraph in a section.
           	            if (srcNode.getNodeType() == (com.aspose.words.NodeType.PARAGRAPH))
           	            {
           	            	com.aspose.words.Paragraph para = (com.aspose.words.Paragraph)srcNode;
           	                if (para.isEndOfSection() && !para.hasChildNodes())
           	                    continue;
           	            }

           	            // This creates a clone of the node, suitable for insertion into the destination document.
						  if (srcNode.getNodeType() == (com.aspose.words.NodeType.PARAGRAPH))
						  {
							  com.aspose.words.Paragraph para2 = (com.aspose.words.Paragraph)srcNode;
							  com.aspose.words.Shading shading=para2.getParagraphFormat().getShading();
							  shading.setBackgroundPatternColor(tobefilled);
						 }
						  else if(srcNode.getNodeType() == (com.aspose.words.NodeType.TABLE))
						  {
							  com.aspose.words.Table table_New = (com.aspose.words.Table)srcNode;
							  table_New.setShading(0, Color.cyan, tobefilled);							 
						  }
							  
           	            com.aspose.words.Node newNode = importer.importNode(srcNode, true);
           	        
           	            // Insert new node after the reference node.
           	            dstStory.insertAfter(newNode, insertAfterNode);  
           	            insertAfterNode = newNode;
           	        }
           	    }
           	}
           	String GetConvertedValuesParameter(Context context,String []Args )
           	{
           		String returnValues = "";
           	
           		try{
           		
           		if (Args[2] != null && !Args[2].isEmpty())
    			{
    				ArrayList<Double> ret = (ArrayList<Double>) JPO.invoke(context, "emxParameter", null,
    					"getConvertedValues", Args, ArrayList.class);
    				
    					returnValues += ret.get(0);
    			}
           		}
           		catch(Exception e){
           			System.out.println(e.getMessage());
           		}
           		return returnValues;
           	}
           	
    // -- ZUD Functions for HL ENOVIA GOV TRM Export to MS Word --        
                                     %>
        <%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
        <%

            boolean bFlag = false;
            String msg = "";
            boolean check = true;
            String timeStamp = emxGetParameter(request, "timeStamp");
            if (timeStamp != null) {
                Map requestMap = (Map) indentedTableBean.getRequestMap(timeStamp);
                if (requestMap != null) {
                    java.util.Set keys = requestMap.keySet();
                    Iterator itr = keys.iterator();
                    String paramName = null;
                    String paramValue = null;
                    while (itr.hasNext()) {
                        paramName = (String) itr.next();
                        try {
                            paramValue = (String) requestMap.get(paramName);
                        } catch (Exception ClassCastException) {
                            //Ignore the exception
                        }
        %>
        <input type="hidden" name="<%=paramName%>" value="<xss:encodeForHTMLAttribute><%=paramValue%></xss:encodeForHTMLAttribute>" />
        <%
                    }
                }
            }
            try {
                /**
                 * A string constant with the value Release.
                 */
                String strAlertMessage = "";
                String strMode = emxGetParameter(request, "mode");
                String strUiType = emxGetParameter(request, "uiType");
                String strSearch = emxGetParameter(request, "search");
                String strParentObjId = "";
                String options = emxGetParameter(request, "options");
                // ++ ZUD  for HL ENOVIA GOV TRM Export to MS Word ++ 
                String docString = "";
                com.matrixone.jdom.Document reponseDoc = null;
               //  ++ ZUD  for HL ENOVIA GOV TRM Export to MS Word ++ 
                if ((strMode.equalsIgnoreCase("create")) || (strMode.equalsIgnoreCase("apply"))) {
                    strParentObjId = emxGetParameter(request, "txtObjectId");
                    //Instantiating the FormBean
                    com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();

                    //Processing the form using FormBean.processForm
                    formBean.processForm(session, request);

                    //Instantiating the Requirement bean
                    Requirement requirementBean = (Requirement) DomainObject.newInstance(context, ReqSchemaUtil.getRequirementType(context), "Requirements");
                    String strNewObjId = null;
                    //Calling the create Method of Requirement.java
                    strNewObjId = requirementBean.create(context, formBean);
                    String strCommandSource = emxGetParameter(request, "txtCommandSource");
                    String strTreeID = emxGetParameter(request, "txtTreeId");

                    //to refresh the Requirement Create Dialog page
                    if (strMode.equalsIgnoreCase("apply")) {

                        String strCreateStatus = "apply";
        %>
        <script language="javascript" type="text/javaScript">
            <!-- hide JavaScript from non-JavaScript browsers -->
            //<![CDATA[
            findFrame(parent, 'pagecontent').clicked = false;
            parent.turnOffProgress();         
            //]]>
        </script>

        <%
        } else {
            /*Begin of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005*/
            strParentObjId = emxGetParameter(request, "txtObjectId");
            String strRelName = requirementBean.getRelName(context, strParentObjId);
            String strSelectRelId = "to[" + strRelName + "].id";
            DomainObject domObjReq = DomainObject.newInstance(context, strNewObjId);
            String strRelId = domObjReq.getInfo(context, strSelectRelId);
            /*End of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005*/
            if ("structureBrowser".equalsIgnoreCase(strUiType)) {
        %>
	 //KIE1 ZUD TSK447636 
        <script language="javascript" type="text/javaScript">
            if (parent.window.getWindowOpener().parent != null)
            {
            if(parent.window.getWindowOpener().parent.reloadTableEditPage != null && parent.window.getWindowOpener().parent.reloadTableEditPage != 'undefined')
            {
            parent.window.getWindowOpener().parent.reloadTableEditPage();
            }
            else
            {
            parent.window.getWindowOpener().parent.location = parent.window.getWindowOpener().parent.location;
            }
            getTopWindow().closeWindow();
            }
        </script>
        <%
        } else if (strCommandSource != null && strCommandSource.equalsIgnoreCase("action")) {

        %>
        <!--Javascript for opening the tree with the object Id of the object that has been created-->
        <script language="javascript" type="text/javaScript">
            <!-- hide JavaScript from non-JavaScript browsers -->
            //<![CDATA[
            var strURL    = "../common/emxTree.jsp?objectId=<xss:encodeForJavaScript><%=strNewObjId%></xss:encodeForJavaScript>";
            //Modified by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005
            strURL        = strURL  + "&mode=insert&jsTreeID=<xss:encodeForJavaScript><%=strTreeID%></xss:encodeForJavaScript>&relId=<xss:encodeForJavaScript><%=strRelId%></xss:encodeForJavaScript>";
            var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
            contentFrameObj.document.location.href= strURL;
            var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
            topFrameObj.window.focus();
            parent.closeWindow();
            //]]>
        </script>
        <%
        } else {
            if (strTreeID == null || "".equals(strTreeID) || "null".equalsIgnoreCase(strTreeID)) {
        %>
        <script language="javascript" type="text/javaScript">
            <!-- hide JavaScript from non-JavaScript browsers -->
            //<![CDATA[
            var strURL    ="../common/emxTree.jsp?objectId=<xss:encodeForJavaScript><%=strNewObjId%></xss:encodeForJavaScript>";
            //Modified by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005
            strURL        =strURL + "&mode=insert&jsTreeID=<xss:encodeForJavaScript><%=strTreeID%></xss:encodeForJavaScript>&relId=<xss:encodeForJavaScript><%=strRelId%></xss:encodeForJavaScript>";
            var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
            contentFrameObj.document.location.href= strURL;
            var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
            topFrameObj.window.focus();
            parent.closeWindow();
            //]]>
        </script>
 //KIE1 ZUD TSK447636 
        <%
        } else {
        %>
 //KIE1 ZUD TSK447636 
        <script language="javascript" type="text/javaScript">
            <!-- hide JavaScript from non-JavaScript browsers -->
            //<![CDATA[
            var strURL    = "../common/emxTree.jsp?objectId=<xss:encodeForJavaScript><%=strNewObjId%></xss:encodeForJavaScript>";
            //Modified by:Raman,Enovia MatrixOne for Bug # 298000 on 5/11/2005
            strURL        =strURL + "&mode=insert&jsTreeID=<xss:encodeForJavaScript><%=strTreeID%></xss:encodeForJavaScript>&relId=<xss:encodeForJavaScript><%=strRelId%></xss:encodeForJavaScript>";
            var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
            contentFrameObj.document.location.href= strURL;
            var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
            topFrameObj.window.focus();
            parent.closeWindow();
 //KIE1 ZUD TSK447636 
            //]]>
        </script>
        <%
                    }
                }
            }
        } else if (strMode.equalsIgnoreCase("disconnect")) {
            //Instantiating ProductLineCommon.java
            ProductLineCommon ProductLineCommonBean = new ProductLineCommon();

            ///extract Table Row ids of the checkboxes selected.
            String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");

            //extracts Object id of the Objects to be disconnected.
            Map relIdMap = ProductLineUtil.getObjectIdsRelIdsR213(arrTableRowIds);

            //Obtaining the relationship ids from the Map returned by the previous step
            String[] arrObjectIds = (String[]) relIdMap.get("ObjId");
            String[] arrRelIds = (String[]) relIdMap.get("RelId");

            //Begin of Add by RashmiL_Joshi, Enovia MatrixOne for Bug# 297936 Date: 3/3/2005
            String strObjectId = emxGetParameter(request, "objectId");
                    //End of Add for Bug# 297936

            //returns true in case of successful disconnect.
            boolean bRemove = false;

            //Start of Add by Enovia MatrixOne for Committed Requirement Bug # 315389.
            //Getting the ID of the model to which the Product is connected using the Products relationship.
            DomainObject domObjContextProd = new DomainObject(strObjectId);
            String[] arrRelIdsTemp = new String[1];
            String[] arrObjectIdsTemp = new String[1];

            for (int i = 0; i < arrRelIds.length; i++) {
                DomainRelationship domRelObj = new DomainRelationship(arrRelIds[i].toString());
                String strIsCommittedRequirement = domRelObj.getAttributeValue(context, ReqSchemaUtil.getCommittedRequirementAttribute(context));
                if (strIsCommittedRequirement.trim().equalsIgnoreCase(ProductLineConstants.RANGE_VALUE_YES)) {
                    //disconnect the Product and the Requirement, get the model for the Product, and add the requirement under the model as the Candidate Item.
                    String strRelIdnew = arrRelIds[i];
                    arrRelIdsTemp[0] = arrRelIds[i];
                    Model modelbean = new Model();
                    String strReqID = modelbean.getConnectedRequirement(context, strRelIdnew);
                    arrObjectIdsTemp[0] = strReqID;
                    bRemove = ProductLineCommonBean.removeObjects(context, arrRelIdsTemp);
                    modelbean.removeCommittedRequirementfromProduct(context, arrObjectIdsTemp, strObjectId);
                } else {
                    //disconnect the Product and the requirement
                    arrRelIdsTemp[0] = arrRelIds[i];
                    bRemove = ProductLineCommonBean.removeObjects(context, arrRelIdsTemp);
                }
            }//end of For Loop for arrRelIds.length
            //End of Add by Enovia MatrixOne for Committed Requirement Bug # 315389.

        %>
        <script language="javascript" type="text/javaScript">
            <!-- hide JavaScript from non-JavaScript browsers -->
            //<![CDATA[
            <%    //For loop for refreshing the tree
                for (int i = 0; i < arrObjectIds.length; i++) {
            %>
            //NExt Genui Changes for IR-089620V6R2012
            var tree = getTopWindow().trees['emxUIStructureTree'];
            tree.deleteObject("<xss:encodeForJavaScript><%=arrObjectIds[i]%></xss:encodeForJavaScript>");
            <%
                }
                /*           //Begin of Add by RashmiL_Joshi, Enovia MatrixOne for Bug# 297936 Date: 3/3/2005
                 if (bRemove)
                 {
                 Model modelbean = new Model();
                 modelbean.removeCommittedRequirements(context , arrObjectIds, strObjectId);

                 }
                 //End of Add for Bug# 297936   */
            %>
			
			if(parent.editableTable)
			{
			  parent.editableTable.loadData();
			  parent.emxEditableTable.refreshStructureWithOutSort();
			}
			else
			{
				window.refreshTablePage();
			}
			
			console.log("by");
            refreshStructureTree();
            //]]>
        </script>
        <%
        } /* Added for Copy Requirement Functionality on < 19th Oct 2004 > */ else if (strMode.equalsIgnoreCase("copy")) {

            Map params = new HashMap();
            if (options != null) {
                String[] tokens = options.split("[;]");
                for (int i = 0; i < tokens.length; i++) {
                    String token = tokens[i];
                    String[] items = token.split("[=]");
                    if (items.length == 2) {
                        params.put(items[0], items[1]);
                    }
                }
                PropertyUtil.setGlobalRPEValue(context, ReqConstants.COPY_WITH_LINK, getCopyWithLinkParameter(tokens));
                PropertyUtil.setGlobalRPEValue(context, ReqConstants.FROM_WEB_APP, getFromWebAppParameter(tokens));

            }

            AddParam(request, params, "relationship");

            //Instantiating the FormBean
            FormBean formBean = new FormBean();

            //Processing the form using FormBean.processForm
            formBean.processForm(session, request);
            String strObjectId = (String) formBean.getElementValue("relationship");

            //Instantiating the Requirement bean
            Requirement requirementBean = new Requirement();
            requirementBean.copyRequirement(context, formBean, params);

            strAlertMessage = EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.CopyRequirementSuccessful");

        %>
        <script language="javascript" type="text/javaScript">
            //<![CDATA[
            //copy Successful
            //IR-233743V6R2015 An loading icon does not disappear 
            getTopWindow().turnOffProgress();

            alert("<xss:encodeForJavaScript><%=strAlertMessage%></xss:encodeForJavaScript>");
            refreshTablePage();
            getTopWindow().closeSlideInDialog();
        </script>
        <%
        } /* Added for Replace Requirement Functionality on < 27th Oct 2004 > */ else if (strMode.equalsIgnoreCase("replace")) {

            //Instantiating the FormBean
            FormBean formBean = new FormBean();

            //Processing the form using FormBean.processForm
            formBean.processForm(session, request);
            String strObjectId = (String) formBean.getElementValue("txtSourceReqId");

            //Instantiating the Requirement bean
            Requirement requirementBean = new Requirement();
            requirementBean.replaceRequirement(context, formBean);

        %>
        <script language="javascript" type="text/javaScript">
            //<![CDATA[
            //copy Successful

            var tree = window.getTopWindow().trees['emxUIDetailsTree'];
            tree.deleteObject ("<xss:encodeForJavaScript><%=strObjectId%></xss:encodeForJavaScript>");
            getTopWindow().closeSlideInDialog();
            window.getTopWindow().refreshTablePage();
        </script>
        <%
            //START LX6
        } else if (strMode.equalsIgnoreCase("Promote")) {
            String sOID = request.getParameter("objectId");
            BusinessObject bObject = new BusinessObject(sOID);
            bObject.promote(context);
        %>
        <script language="javascript" type="text/javaScript">
            parent.location.href = parent.location.href;
        </script> 
        <%
        } else if (strMode.equalsIgnoreCase("Demote")) {
            String sOID = request.getParameter("objectId");
            BusinessObject bObject = new BusinessObject(sOID);
            bObject.demote(context);
        %>
        <script language="javascript" type="text/javaScript">
            parent.location.href = parent.location.href;
        </script> 
        <%
            //END LX6 
        }else if (strMode.equalsIgnoreCase("Reserve")) {
            String sOID = request.getParameter("objectId");
             HashMap requestMap = new HashMap();
             requestMap.put("objectId", sOID);
             requestMap.put("rowIds", "");
             
             HashMap programMap = new HashMap();
             programMap.put("requestMap",requestMap);
             
             HashMap Ret = (HashMap) JPO.invoke(context,
                     "emxSpecificationStructureBase", null, "commandReserveTree", JPO.packArgs(programMap),
                     HashMap.class);
        %>
        <script language="javascript" type="text/javaScript">
            parent.location.href = parent.location.href;
        </script> 
        <%
             
        }
        else if (strMode.equalsIgnoreCase("UnReserve")) {
            String sOID = request.getParameter("objectId");
             HashMap requestMap = new HashMap();
             requestMap.put("objectId", sOID);
             requestMap.put("rowIds", "");
             
             HashMap programMap = new HashMap();
             programMap.put("requestMap",requestMap);
             
             HashMap Ret = (HashMap) JPO.invoke(context,
                     "emxSpecificationStructureBase", null, "commandUnreserveExtendedTree", JPO.packArgs(programMap),
                     HashMap.class);
        %>
        <script language="javascript" type="text/javaScript">
            parent.location.href = parent.location.href;
        </script> 
        <%
             
        } 
        else if (strMode.equalsIgnoreCase("checkTypeBeforeAdding")) {
            out.clear();
            if (request.getProtocol().equals("HTTP/1.1")) {
                response.setHeader("Cache-Control", "public");
            } else { // HTTPS
                response.setHeader("Cache-Control", "private");
            }

            response.setContentType("text/xml; charset=UTF-8");

            String strParentID = emxGetParameter(request, "strParentID");
            Map<String, String> rmtTableType = (Map<String, String>) JPO.invoke(context,
                    "emxRequirementSearchBase", null, "updateValuesRMTTableType", JPO.packArgs(strParentID),
                    Map.class);

        %>
        <mxRoot>
            <%                short countDefault = 1;
                for (Map.Entry<String, String> entryType : rmtTableType.entrySet()) {
            %><t_data_value_<%=countDefault%>><![CDATA[<%=entryType.getValue()%>]]></t_data_value_<%=countDefault%>><%
                    countDefault += 1;
                }

                %>
        </mxRoot>
        <%                // We can end the JSP here
            return;
        } else if (strMode.equalsIgnoreCase("getAutoNameFor")) {
            out.clear();
            response.setHeader("Cache-Control", "no-cache");
            response.setContentType("text/xml; charset=UTF-8");

            String strType = emxGetParameter(request, "strType");
            String autoName = (String) JPO.invoke(context,
                    "emxRequirementSearchBase", null, "getAutoNameValueRMT", JPO.packArgs(strType),
                    String.class);

        %>
        <mxRoot>
            <action>CONTINUE</action>
                <%
                %><autoNameRMT><![CDATA[<%=autoName%>]]></autoNameRMT><%

                %>
        </mxRoot>
        <%                // We can end the JSP here
            return;
        } else if (strMode.equalsIgnoreCase("loadRTFContent")) {
            out.clear();

            if (request.getProtocol().equals("HTTP/1.1")) {
                response.setHeader("Cache-Control", "public");
            } else { // HTTPS
                response.setHeader("Cache-Control", "private");
            }
            String strObjID = emxGetParameter(request, "strObjID");
            
            HashMap<String, String> argsMap = new HashMap<String, String>();
            argsMap.put("objectId", strObjID);

            response.setDateHeader("Expires", System.currentTimeMillis() + 3600000 * 24 * 7);
            response.setContentType("text/xml");

            String htmlContent = (String) JPO.invoke(context,
                    "emxRMTCommonBase", null, "getHTMLSourceFromRTF", JPO.packArgs(argsMap),
                    String.class);

        %>
        <mxRoot>
            <%
            %><htmlContent><![CDATA[<%=htmlContent%>]]></htmlContent><%
                %>
        </mxRoot>
        <%
            // We can end the JSP here
            return;
        } 
	// ++ ZUD Parameter Support under Requirement
	//retrieve Content column value for Parameter Node
         else if (strMode.equalsIgnoreCase("getParameterValues")) {
            out.clear();

            if (request.getProtocol().equals("HTTP/1.1")) {
                response.setHeader("Cache-Control", "public");
            } else { // HTTPS
                response.setHeader("Cache-Control", "private");
            }
            String strObjID = emxGetParameter(request, "strObjID");
            
            response.setDateHeader("Expires", System.currentTimeMillis() + 3600000 * 24 * 7);
            response.setContentType("text/xml");
            
           
	        String parameterContent = (String) JPO.invoke(context,
	            "emxRMTCommonBase", null, "getParameterContentValue", JPO.packArgs(strObjID),
	             String.class);

	        %>
	        <mxRoot>
	        <%
	           %><htmlContent><![CDATA[<%=parameterContent%>]]></htmlContent><%
	        %>
	        </mxRoot>
	        <%
	        
	        // We can end the JSP here
	        return;
        }
        //Cehcks if PArameter Value is Correct
         else if (strMode.equalsIgnoreCase("CheckParameterValues")) {
            out.clear();

            if (request.getProtocol().equals("HTTP/1.1")) {
                response.setHeader("Cache-Control", "public");
            } else { // HTTPS
                response.setHeader("Cache-Control", "private");
            }
            String strObjID = emxGetParameter(request, "strObjID");
            String ParamVal = emxGetParameter(request, "ParamVal");
         // Fix for IR-333259-3DEXPERIENCER2016
            ParamVal += " ";
           
            response.setDateHeader("Expires", System.currentTimeMillis() + 3600000 * 24 * 7);
            response.setContentType("text/xml");
            
            String [] PAram_values ={strObjID,ParamVal};
	        String parameterContent = (String) JPO.invoke(context,
	            "emxRMTCommonBase", null, "CheckParameterContentValue", JPO.packArgs(PAram_values),
	             String.class);

	        %><%=parameterContent%><%
	        
	        // We can end the JSP here
	        return;
        }
	//-- ZUD PArameter Suport Under Requirement --
	else if(strMode.equalsIgnoreCase("errorInconsistency"))
		{
  			out.clear();
  			String strObjID      = emxGetParameter(request, "strObjID");        	
  			String nodeStatus    = emxGetParameter(request,"nodeStatus");
        	String rootReqSpecId = emxGetParameter(request,"rootReqSpecId");
        	//String str = "strObjID = " + strObjID + "nodeStatus = " + nodeStatus;
		    
        	DomainObject dObj = DomainObject.newInstance(context, rootReqSpecId);
        	
        	StringList selectsAttribs  = new StringList(4);
		    selectsAttribs.add(DomainConstants.SELECT_ID);
		    selectsAttribs.add(DomainConstants.SELECT_NAME);
		    selectsAttribs.add(DomainConstants.SELECT_TYPE);
		    selectsAttribs.add(DomainConstants.SELECT_REVISION);
        	
        	
	    	MapList reqSpecRelatedObjMapList = dObj.getRelatedObjects(context,
			"Specification Structure,Sub Requirement", //Relationship form parent ReqSpec to child Req.
			"*",//allToTypes,   
			selectsAttribs,    // Object selects
			    null,   //relationshipSelets, // relationship selects
	            false,      // from false -
	            true,       // to true - 
	            (short)0,   //expand level
	            null,       // object where
	            null,       // relationship where
	            0);         // limit
			
	            
	          Map ErrorRootObjMap = new HashMap();
	            
        	  BusinessObject ErrorNodeObj = new BusinessObject(rootReqSpecId);
        	  ErrorNodeObj.open(context);
        
        	  ErrorRootObjMap.put("id",rootReqSpecId);
        	  ErrorRootObjMap.put("revision",ErrorNodeObj.getRevision());
        	  ErrorRootObjMap.put("name", ErrorNodeObj.getName());
        	  ErrorRootObjMap.put("type", ErrorNodeObj.getTypeName());
        	  ErrorRootObjMap.put("level","0");
    		
        	  ErrorNodeObj.close(context); 
    		
        	  reqSpecRelatedObjMapList.add(ErrorRootObjMap);
        	  
	          MapList mList = reqSpecRelatedObjMapList;
	          Iterator relatedObjItr = reqSpecRelatedObjMapList.iterator();
	          MapList requiredRelatedObjMapList = new MapList();
	          String errorObjKindOf    = "";
			  int sizeOfMapList = 0;

        	%>
        	<mxRoot>
        	<rows>
        	<%
           while(relatedObjItr.hasNext())
           {
  				Map curRelatedObjectMap     = (Map) relatedObjItr.next();
				String nodeLevel      = (String) curRelatedObjectMap.get("level");
				
				
				if(nodeLevel.equalsIgnoreCase("1") || nodeLevel.equalsIgnoreCase("0"))
				{
					requiredRelatedObjMapList.clear();					
				}
  				requiredRelatedObjMapList.add(curRelatedObjectMap);
  				
				String curRelatedObjectId    = (String) curRelatedObjectMap.get("id");
				if(curRelatedObjectId.equalsIgnoreCase(strObjID) || nodeLevel.equalsIgnoreCase("0"))
				{
					  //int sizeOfMapList = 0;
				   	  Iterator requiredRelatedObjItr = requiredRelatedObjMapList.iterator();
			          while(requiredRelatedObjItr.hasNext())
			          {
			        	    Map requiredRelatedObjectMap     = (Map) requiredRelatedObjItr.next();
			  				
							String curRelatedObjType       = (String) requiredRelatedObjectMap.get("type");
							String curRelatedObjName       = (String) requiredRelatedObjectMap.get("name");
							String curRelatedObjId         = (String) requiredRelatedObjectMap.get("id");
							String curRelatedObjRevision   = (String) requiredRelatedObjectMap.get("revision");
							String curRelatedObjLevel      = (String) requiredRelatedObjectMap.get("level");

							
							curRelatedObjName = curRelatedObjName.replaceAll("<","%3C");
							curRelatedObjName = curRelatedObjName.replaceAll(">","%3E");
				        	curRelatedObjName = curRelatedObjName.replaceAll("&","%26");
							
							errorObjKindOf    =  MqlUtil.mqlCommand(context,"print bus $1 select $2 dump", curRelatedObjId, "type.kindof");
				        	
							BusinessObject reqSpecObj = new BusinessObject(curRelatedObjId);
				        	reqSpecObj.open(context);
				        	
				        	//Retrieve Title and Content Text Attribute for Tooltip purpose
				        	StringList selectAttributes = new StringList();
				    		selectAttributes.add(DomainConstants.ATTRIBUTE_TITLE);
				    		selectAttributes.add(ReqSchemaUtil.getContentTextAttribute(context));
				    		AttributeList attrValues = reqSpecObj.getAttributeValues(context, selectAttributes);
				    		Attribute aTitle = (Attribute)attrValues.get(0);
				    		Attribute aContentText = (Attribute)attrValues.get(1);
				    		String objectTitle = aTitle.getValue();
				    		String attrContentText = aContentText.getValue();
				    		
				    		if(attrContentText.length() > 60){
				    			attrContentText = attrContentText.substring(0, 60-1);
				    			attrContentText += "...";
				    		}
				    		
				    		//retrieve icon Name rootArgs rootObjLst
				    		HashMap nodeArgs = new HashMap();
				    		MapList nodeObjLst = new MapList();
				    		MapList nodemapIconList = new MapList();
				    		HashMap tmpMap = new HashMap();
				    		Map nodemapIcon =  new HashMap();
				    		
				    		tmpMap.put("id",curRelatedObjId);
				    		nodeObjLst.add(tmpMap);
				    		nodeArgs.put("objectList",nodeObjLst);
				    		
				    		nodemapIconList = JPO.invoke(context, "emxRMTCommon",null,"getRequirementIcons",JPO.packArgs(nodeArgs),MapList.class);
				    		nodemapIcon = (Map)nodemapIconList.get(0);
				    		String nodeIconName = (String)nodemapIcon.get(curRelatedObjId);

					        String treeDisplaySettings = JPO.invoke(context, "emxRMTCommon",null,"getTreeDisplaySettings",JPO.packArgs(curRelatedObjType),String.class);
				    		//String rootLevel = "1";
				    		
				    		String str1 = objectTitle;
				    		String str2 = attrContentText;
				    		String str3 = errorObjKindOf;
				    		
				    		reqSpecObj.close(context);	
				    		
				    		String rootXMLData = "";

				    		rootXMLData = "o=\""+curRelatedObjId+"\" r=\"\" p=\"\" type=\""+curRelatedObjType+"\" rel=\"\" level=\""+curRelatedObjLevel+
				       				"\" revision=\""+curRelatedObjRevision+"\" seqOrder=\"\" name=\""+curRelatedObjName+"\" icon=\"images/"+nodeIconName+
				       				"\""+" isDerived=\"false\" colorCode=\"N/A\" warningOrError=\"N/A\" kindOf=\""+errorObjKindOf+
				       				"\" treeDisplaySettings=\""+ treeDisplaySettings + "\" indexInTree=\""+ sizeOfMapList +
				       				"\" title=\""+objectTitle+"\" contentText=\""+attrContentText+"\"";   		
				    	    
				    		%> 
				        	<r <%=rootXMLData%> ></r>
				        	<%
				        	
			        	    sizeOfMapList++;
			          }
   	   	            requiredRelatedObjMapList.clear();		

				}

           }
	            
			%>
        	</rows>
        	</mxRoot>
        	<%
        	
  			return;     

		}
		  
         //Tree showing inconsistency as warning.

  		else if (strMode.equalsIgnoreCase("warningInconsistency"))
  		{
  			out.clear();
  			Map WarningObject = new HashMap();
  			String strObjID      = emxGetParameter(request, "strObjID");
        	String nodeStatus    = emxGetParameter(request,"nodeStatus");
        	String rootReqSpecId = emxGetParameter(request,"rootReqSpecId"); //adding rootReqSpecId to find allDependent reqSpecs.
        	
        	BusinessObject warningNodeObj = new BusinessObject(strObjID);
        	warningNodeObj.open(context);
        
    		WarningObject.put("id",strObjID);
    		WarningObject.put("revision",warningNodeObj.getRevision());
    		WarningObject.put("name", warningNodeObj.getName());
    		WarningObject.put("type", warningNodeObj.getTypeName());
    		
    		warningNodeObj.close(context);        	
        	
        	DomainObject domOjb = DomainObject.newInstance(context, strObjID);
        	
        	StringList selectsAttribs  = new StringList(4);
		    selectsAttribs.add(DomainConstants.SELECT_ID);
		    selectsAttribs.add(DomainConstants.SELECT_NAME);
		    selectsAttribs.add(DomainConstants.SELECT_TYPE);
		    selectsAttribs.add(DomainConstants.SELECT_REVISION);
		    
        	MapList allRelatedObjectMapList = domOjb.getRelatedObjects(context,
        			"Specification Structure,Sub Requirement", // Relationship form Req Spec to Req Spec
    				"*",
					selectsAttribs,    // Object selects
				    null,       //relationshipSelets, // relationship selects
		            true,       // from true -
		            false,      // to false - 
		            (short)0,   // expand level
		            null,       // object where
		            null,       // relationship where
		            0);         // limit
    		
        	MapList temp = allRelatedObjectMapList;
		    // Add the warning Node also        
        	allRelatedObjectMapList.add(WarningObject);
        	
        	Iterator relatedObjItr = allRelatedObjectMapList.iterator();
        	
        	int rootNodeIndex     = 0;
        	int childNodeIndex    = 0;
        	int curRootNodeIndex  = rootNodeIndex;
			int curChildNodeIndex = childNodeIndex;
			
    		String treeDisplaySettings = JPO.invoke(context, "emxRMTCommon",null,"getTreeDisplaySettings",JPO.packArgs(ReqSchemaUtil.getRequirementType(context)),String.class);
        	String warningObjKindOf    = MqlUtil.mqlCommand(context,"print bus $1 select $2 dump",strObjID,"type.kindof");

    		
        	String warningNodeXMLData = "";
    		String rootLevel = "0";

        	%>
        	<mxRoot>
        	<rows>
        	<%
        	MapList allRelatedReqSpecMapList = new MapList();
                Map allRelatedReqSpecMap = new HashMap();
        	
        	//Finding all dependent/related reqSpec to main tree req Spec. 
        	
        	Map programMap = new HashMap();
        	programMap.put("rootReqSpecId", rootReqSpecId);
        	programMap.put("isCovered", true);
        	programMap.put("isRefined", true);
        	
        	allRelatedReqSpecMap = (Map)JPO.invoke(context, "emxSpecificationStructure", null, "getAllDependentReqSpecMap_JPO", JPO.packArgs(programMap), Map.class);
        	ArrayList<String> rootXMLDataList = new ArrayList<String>();
        
			while(relatedObjItr.hasNext())
			{
   				Map curRelatedObjectMap     = (Map) relatedObjItr.next();
				String curRelatedObjType    = (String) curRelatedObjectMap.get("type");
				
				String curRelatedReqSpecObjName     = (String) curRelatedObjectMap.get("name");
				String curRelatedReqSpecObjId       = (String) curRelatedObjectMap.get("id");
				String curRelatedReqSpecObjRevision = (String) curRelatedObjectMap.get("revision");
				//String rootLevel    = (String) curRelatedObjectMap.get("level");
				
	    		String objectKindOf = MqlUtil.mqlCommand(context,"print bus $1 select $2 dump",curRelatedReqSpecObjId,"type.kindof");

	    		String rooObjType   = curRelatedObjType; //"Requirement Specification";
	    		rootLevel    = "1";

				//retrieve icon Name 
	    		HashMap nodeArgs        = new HashMap();
	    		MapList nodeObjLst      = new MapList();
	    		MapList nodemapIconList = new MapList();
	    		HashMap tmpMap          = new HashMap();
	    		Map nodemapIcon         = new HashMap();
	    		
	    		tmpMap.put("id",curRelatedReqSpecObjId);
	    		nodeObjLst.add(tmpMap);
	    		nodeArgs.put("objectList",nodeObjLst);
	    		
	    		nodemapIconList = JPO.invoke(context, "emxRMTCommon",null,"getRequirementIcons",JPO.packArgs(nodeArgs),MapList.class);
	    		nodemapIcon = (Map)nodemapIconList.get(0);
	    		String nodeIconName = (String)nodemapIcon.get(curRelatedReqSpecObjId);

	    		
	        	BusinessObject reqSpecObj = new BusinessObject(curRelatedReqSpecObjId);
	        	reqSpecObj.open(context);
	        	
	        	curRelatedReqSpecObjName = curRelatedReqSpecObjName.replaceAll("<","%3C");
	        	curRelatedReqSpecObjName = curRelatedReqSpecObjName.replaceAll(">","%3E");
	        	curRelatedReqSpecObjName = curRelatedReqSpecObjName.replaceAll("&","%26");
	        	
	        	//Retrieve Title and Content Text Attribute for Tooltip purpose
	        	StringList selectAttributes = new StringList();
	    		selectAttributes.add(DomainConstants.ATTRIBUTE_TITLE);
	    		selectAttributes.add(ReqSchemaUtil.getContentTextAttribute(context));
	    		AttributeList attrValues = reqSpecObj.getAttributeValues(context, selectAttributes);
	    		Attribute aTitle         = (Attribute)attrValues.get(0);
	    		Attribute aContentText   = (Attribute)attrValues.get(1);
	    		String objectTitle     = aTitle.getValue();
	    		String attrContentText = aContentText.getValue();
	    		
	    		if(attrContentText.length() > 60){
	    			attrContentText = attrContentText.substring(0, 60-1);
	    			attrContentText += "...";
	    		}
	    		
	    		String str1 = objectTitle;
	    		String str2 = attrContentText;
	    		String str3 = objectKindOf;
	    		
	    		reqSpecObj.close(context);	
	    		
	    		String rootXMLData = "";

				String treeDisplaySettings1 = JPO.invoke(context, "emxRMTCommon",null, "getTreeDisplaySettings", JPO.packArgs(curRelatedObjType), String.class);
				
	    		rootXMLData = "o=\""+curRelatedReqSpecObjId+"\" r=\"\" p=\"\" type=\""+rooObjType+"\" rel=\"\" level=\""+rootLevel+
   				"\" revision=\""+curRelatedReqSpecObjRevision+"\" seqOrder=\"\" name=\""+curRelatedReqSpecObjName+"\" icon=\"images/"+nodeIconName+
   				"\""+" isDerived=\"false\" colorCode=\"N/A\" warningOrError=\"N/A\" kindOf=\""+objectKindOf+
   				"\" treeDisplaySettings=\""+ treeDisplaySettings1 + "\" rootNodeIndex=\""+curRootNodeIndex+"\" childNodeIndex=\""+curChildNodeIndex+
   				"\" title=\""+objectTitle+"\" contentText=\""+attrContentText+"\"";   		
	    		
	    		boolean hasNextMap = relatedObjItr.hasNext();
	        	//Will add all children of reqSpec into list.
 				if(!curRelatedObjType.equalsIgnoreCase((String)ReqSchemaUtil.getRequirementSpecificationType(context)) && hasNextMap)
				{
 					rootXMLDataList.add(rootXMLData);
 		    		curChildNodeIndex++; 
				}
	        	//When adding leaf node (last requirement- warning node in mainTree)
 				else if(!curRelatedObjType.equalsIgnoreCase((String)ReqSchemaUtil.getRequirementSpecificationType(context)) && !hasNextMap)
 				{
 					%>
		        	<r <%=rootXMLData%> ></r>
		        	<%
 				}
				else
				{
					//If current ReqSpec has relationship with MainTree ReqSpec.
					if(allRelatedReqSpecMap.containsKey(curRelatedReqSpecObjId))
					{
						curChildNodeIndex = curChildNodeIndex - rootXMLDataList.size(); // decreasing value by no of children in list.
						rootXMLDataList.clear();                     //Clearing the children of curr ReqSpec from list
					}
					else
					{
						//adding each element of the list into XMLData.
						for(String getEachRootXMLData : rootXMLDataList)
						{
				    		%>
				        	<r <%=getEachRootXMLData%> ></r>
				        	<%
						}
						//adding the rootReqSpec XMLData at last position.
	    		%>
	        	<r <%=rootXMLData%> ></r>
	        	<%

	    		 curChildNodeIndex++; 
					}
				} 
			}        
		    
			%>
        	</rows>
        	</mxRoot>
        	<%
        	
  			return;
  		}
        // HAT1 ZUD end : HL - Requirement Specification dependency. Check consistency cmd - Tree showing inconsistency as Error and Warning.

			
 // JX5 Start : derivation Cmd
        else if (strMode.equalsIgnoreCase("expandStructure")){
        	out.clear();
        	String strObjectId = emxGetParameter(request, "strObjID");
        	String strExpandLevel = emxGetParameter(request,"strExpandLevel");
        	String strDerivMode = emxGetParameter(request,"strDerivMode");
        	String strTreeMode = emxGetParameter(request,"strTreeMode");
        	
        	// ++ HAT1 ZUD HL Requirement Specification Dependency	        
        	String strCheckConsistencyMode = "";
	        String rootReqSpecId = "";
	        if(strTreeMode.equalsIgnoreCase("refined") || strTreeMode.equalsIgnoreCase("covered"))
	        {
	        	rootReqSpecId = emxGetParameter(request,"rootReqSpecId");
	        	strCheckConsistencyMode = emxGetParameter(request,"strCheckConsistencyMode");
	        }
	        else
	        {
	        	rootReqSpecId = "empty";
	        	strCheckConsistencyMode = "empty";
	        }
        	// -- HAT1 ZUD HL Requirement Specification Dependency
        	
        	//Prepare Param Map
        	HashMap programMap = new HashMap();
        	HashMap paramMap = new HashMap();
        	programMap.put("objectId",strObjectId);
        	programMap.put("OBJECT_ID",strObjectId);
        	programMap.put("expandLevel",strExpandLevel);
        	programMap.put("paramMap",paramMap);
        	programMap.put("mode",strDerivMode);
        	programMap.put("tree",strTreeMode);
        	programMap.put("rootReqSpecId",rootReqSpecId);
        	programMap.put("strCheckConsistencyMode",strCheckConsistencyMode);
			
        	String xmlData = (String)JPO.invoke(context, "emxSpecificationStructure", null, "getXMLDataForTraceabilityAuthoring", JPO.packArgs(programMap),String.class);
        	
        	%>
        	<mxRoot>
        	<rows>
			<%=xmlData%>
        	</rows>
        	</mxRoot>
        	<%
        	// We can end the JSP here
        	return;
        }

		// ++ HAT1 ZUD: IR-381800-3DEXPERIENCER2016x ++
        else if (strMode.equalsIgnoreCase("expandStructureChkConsistency")){
        	out.clear();
        	String strObjectId = emxGetParameter(request, "strObjID");
        	String strExpandLevel = emxGetParameter(request,"strExpandLevel");
        	String strDerivMode = emxGetParameter(request,"strDerivMode");
        	String strTreeMode = emxGetParameter(request,"strTreeMode");
        	
        	String strCheckConsistencyMode = "";
	        String rootReqSpecId = "";
	        if(strTreeMode.equalsIgnoreCase("refined") || strTreeMode.equalsIgnoreCase("covered"))
	        {
	        	rootReqSpecId = emxGetParameter(request,"rootReqSpecId");
	        	strCheckConsistencyMode = emxGetParameter(request,"strCheckConsistencyMode");
	        }
	        else
	        {
	        	rootReqSpecId = "empty";
	        	strCheckConsistencyMode = "empty";
	        }
        	
        	//Prepare Param Map
        	HashMap programMap = new HashMap();
        	HashMap paramMap = new HashMap();
        	programMap.put("objectId",strObjectId);
        	programMap.put("OBJECT_ID",strObjectId);
        	programMap.put("expandLevel",strExpandLevel);
        	programMap.put("paramMap",paramMap);
        	programMap.put("mode",strDerivMode);
        	programMap.put("tree",strTreeMode);
        	programMap.put("rootReqSpecId",rootReqSpecId);
        	programMap.put("strCheckConsistencyMode",strCheckConsistencyMode);
			
        	String xmlData = (String)JPO.invoke(context, "emxSpecificationStructure", null, "getXMLDataForCheckConsistency", JPO.packArgs(programMap),String.class);
        	
        	String abc = xmlData;
        	%>
        	<mxRoot>
        	<rows>
			<%=xmlData%>
        	</rows>
        	</mxRoot>
        	<%
        	// We can end the JSP here
        	return;
        }
 		// -- HAT1 ZUD: IR-381800-3DEXPERIENCER2016x --
        
        else if (strMode.equalsIgnoreCase("getSubTypes")){
        	        	out.clear();
        	        	
			String mqlQuery = "print type $1 select derivative dump";
			String includesType = "";
			includesType += MqlUtil.mqlCommand(context,mqlQuery,"Requirement Specification").trim();
			includesType += MqlUtil.mqlCommand(context,mqlQuery,"Requirement").trim();
			includesType += MqlUtil.mqlCommand(context,mqlQuery,"Chapter").trim();
			includesType += MqlUtil.mqlCommand(context,mqlQuery,"Comment").trim();
			includesType += ",Requirement Specification,Requirement,Chapter,Comment";
			
		/* 	// TC and Parameter
			String excludesType = "";
			excludesType += MqlUtil.mqlCommand(context,
					mqlQuery, "Test Case").trim();
			excludesType += MqlUtil.mqlCommand(context, mqlQuery,
					"PARParameter").trim(); */
			
			String dataIncludeXML = "include=\"" + includesType + "\"";
			/* String dataExcludeXML = "exclude=\"" + excludesType + "\""; */
        	%>
        	<mxRoot>
        	<rows>
        	<r <%=dataIncludeXML%> ></r>
        	<%-- <r1 <%=dataExcludeXML%> ></r1> --%>
        	</rows>
        	</mxRoot>
        	<%
        	
        	return;
        }
        else if(strMode.equalsIgnoreCase("createDerivationLink"))
        {   
        	out.clear();
        	String objIdFrom = emxGetParameter(request, "fromId");
        	String objIdTo = emxGetParameter(request, "toId");
        	String dataXML = "";
        	if(objIdFrom != null && !objIdFrom.equalsIgnoreCase("") && objIdTo!=null && !objIdTo.equalsIgnoreCase(""))
        	{
        		DomainObject objFrom = DomainObject.newInstance(context, objIdFrom);
        		DomainObject objTo = DomainObject.newInstance(context, objIdTo);
        		
        		String[] IDsToFrom = new String[2];	
        		IDsToFrom[0] = objIdFrom;
        		IDsToFrom[1] = objIdTo;
        		
        		boolean CloseBO = objTo.openObject(context);
				String objToName = objTo.getName();
				objToName = RequirementsUtil.encodeSpecialCharAsHTML(objToName);
				String objToTitle = objTo.getAttributeValue(context, "Title");
				objToTitle = RequirementsUtil.encodeSpecialCharAsHTML(objToTitle);
				String objToContentTex = objTo.getInfo(context,ReqSchemaUtil.getContentTextAttribute(context));
				String objToRevision	= objTo.getRevision();
				objTo.closeObject(context,CloseBO);
				
				//HL - TSK3278161:	ENOVIA GOV TRM Deprecation of functionalities to clean up 
        		StringList objectRelId = null;
			      
			      //Create Derived Requirement rel
        		// ++ OSLC Traceability Authoring Cmd ++
        		try
        		{
        			objectRelId = SpecificationStructure.createDerivationLink(context, IDsToFrom);
    				dataXML = "id=\"" + objIdTo + "\" relId=\"" +objectRelId.get(0) +"\" name=\""+objToName+"\" image=\"images/iconReqTypeRequirement.png\" revision=\""+objToRevision+"\" title=\""+objToTitle+"\" contentText=\""+objToContentTex+"\" errorMsg=\""+""+"\"";

        		}
        		catch(Exception e)
        		{
        			e.printStackTrace();
              String errorMessage = e.getMessage();
              
              if(errorMessage.contains("Exception:"))
              {
                errorMessage = e.getMessage().split("Exception: ")[1];
              }else{
                errorMessage = "Error: "+e.getMessage().split(":")[2];
              }
    				dataXML = "errorMsg=\"" + errorMessage +"\"";
        		}
				// -- OSLC Traceability Authoring Cmd --
           	}
        	
        	%>
        	<mxRoot>
        	<rows>
    		<r <%=dataXML%> ></r>
        	</rows>
        	</mxRoot>
        	<%
        	return;
        }
        else if(strMode.equalsIgnoreCase("DeleteDerivationLinks")){
        	out.clear();
        	
        	String relId = emxGetParameter(request, "relId");
      	    // ++ HAT1 ZUD: IR-526839-3DEXPERIENCER2018x: ENOVIA GOV TRM Deprecation of functionalities to clean up ++
       		String[] relIds = new String[1];	
       		relIds[0] = relId;
        	String msg1 = SpecificationStructure.deleteDerivationLink(context, relIds);
      	    // -- HAT1 ZUD: IR-526839-3DEXPERIENCER2018x -- 

        	%>
        		<mxRoot>
        		<rows>
        		</rows>
        		</mxRoot>
        	<%
        	
        	return;

         } else if (strMode.equalsIgnoreCase("EnsureSourceReqForUseCase")){
        	 String strSourceObjectId = emxGetParameter(request, "objectId");
        	 DomainObject bo = DomainObject.newInstance(context, strSourceObjectId);
        	 State curState = bo.getCurrentState(context);
     		String strState = curState.getName();

     		if(strState.equals("Release") || strState.equals("Obsolete"))
     		{
     		  throw new Exception("modifyReleaseObsoleteState");
     		}	
     		else
     		{
     //START LX6			
     			String isSimplifiedForm = EnoviaResourceBundle.getProperty(context, "emxRequirements.Preferences.Creation.isSimplifiedCreationForm");
     			String valueToAdd = "";
            if(isSimplifiedForm == null || "".equals(isSimplifiedForm) || "false".equals(isSimplifiedForm))
            {
         	   valueToAdd = "&vaultChooser=true";
            }
            else
            {
         	   String UseCasePolicy = EnoviaResourceBundle.getProperty(context, "emxRequirements.Default.Creation.DefaultUseCasePolicy");
         	   valueToAdd = "&policy="+UseCasePolicy;
            }
            boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
            String csrfTokenName = "";
            String csrfTokenValue = "";
            if(csrfEnabled)
            {
            	Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
            	csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
            	csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
            }          
           
            String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxRequirements.form.create.autonamechecked");
	        if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
	           autonameChecked = "true";
	        }
 
                %>		
                <script language="javascript" type="text/javaScript">		//HAT1 ZUD: xHTML editor for Use case    // HAT1 ZUD: Populating title as per autoName of Name in Web form-->nameField=autoName
                var strDialogUrl = "../common/emxCreate.jsp?openerFrame="+parent.name+"&submitAction=xmlMessage&nameField=program"+"&postProcessURL=../productline/CreateProcess.jsp?Mode=refresh&direction=from&objectId="+"<%=strSourceObjectId%>"+"&relationship=relationship_RequirementUseCase&type=type_UseCase"+"<%=valueToAdd%>"+"&objectId="+"<%=strSourceObjectId%>"+"&typeChooser=true&form=RMTCreateUseCase&header=emxRequirements.Heading.UseCaseCreate&showApply=true&suiteKey=Requirements"+
											"&windowMode=slidein" + "<%=csrfEnabled ? ("&" + ENOCsrfGuard.CSRF_TOKEN_NAME + "= " + csrfTokenName + "&" + csrfTokenName + "=" + csrfTokenValue ) : ""%>";
				getTopWindow().showSlideInDialog(strDialogUrl, true, window.name,"",550);
			</SCRIPT>
<%
     		}
         }

        // ++ HAT1 ZUD HL Requirement Specification Dependency
         else if (strMode.equalsIgnoreCase("TraceabilityMgtSettings")) {
             out.clear();

             if (request.getProtocol().equals("HTTP/1.1")) {
                 response.setHeader("Cache-Control", "public");
             } else { // HTTPS
                 response.setHeader("Cache-Control", "private");
             }
             //Getttig selected Traceability Management Settings from Perferences.
			 String selectedTraceabilityMgtSettings = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTraceabilityMgtSettings");		
			 
             // ++ HAT1 ZUD :  LA Settings for ReqSpec Dependency HL
             String showCheckConsistency = "";
     		 showCheckConsistency = EnoviaResourceBundle.getProperty(context, "emxRequirements.ManageReqSpecDependencies");
         	 boolean toShow = showCheckConsistency!=null&&showCheckConsistency.equalsIgnoreCase("true")?true:false;
             if(toShow == false && !selectedTraceabilityMgtSettings.equalsIgnoreCase("NeverPrompt"))
             {
            	 selectedTraceabilityMgtSettings = "NeverPrompt";
     			 PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTraceabilityMgtSettings", "NeverPrompt");
             }
             // -- HAT1 ZUD : LA Settings for ReqSpec Dependency HL
             
             
             // ++ HAT1 ZUD IR-364538-3DEXPERIENCER2016x
             if(selectedTraceabilityMgtSettings.equalsIgnoreCase("") || selectedTraceabilityMgtSettings.equalsIgnoreCase("null") || selectedTraceabilityMgtSettings.equalsIgnoreCase(null))
			 {
					PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedTraceabilityMgtSettings", "AlwaysPrompt");
					PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedAlwaysPromptTargets", "AlwaysPromptTargets");	
					selectedTraceabilityMgtSettings = "AlwaysPrompt";
			 } 
             // -- HAT1 ZUD IR-364538-3DEXPERIENCER2016x
			 
             if(selectedTraceabilityMgtSettings.equalsIgnoreCase("AlwaysPrompt"))
             {
                 String strAlwaysPrompt = (String) emxGetParameter(request, "alwaysPrompt");
            	 if(strAlwaysPrompt.equalsIgnoreCase("AlwaysPromptTargets"))
            	 {
        			 selectedTraceabilityMgtSettings = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedAlwaysPromptTargets");		
            	 }
            	 else if(strAlwaysPrompt.equalsIgnoreCase("AlwaysPromptRelationship"))
            	 {
        			 selectedTraceabilityMgtSettings = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedAlwaysPromptRelationship");		
            	 }
             }
             
             // ++ Relationship direction modification for covered and refined requirements.
             String rootXMLData = "selectedTraceabilityMgtSettings=\""+selectedTraceabilityMgtSettings+"\"";

 	        %>
 	        <mxRoot>
         	<rows>   
         	<r <%=rootXMLData%>></r>  	        	
         	</rows>
 	        </mxRoot>
 	        <%
            // -- Relationship direction modification for covered and refined requirements.
 	        
 	        // We can end the JSP here
 	        return;
         }
         
         else if (strMode.equalsIgnoreCase("checkForReqSpecsDerivationLink")) {
             out.clear();

             if (request.getProtocol().equals("HTTP/1.1")) {
                 response.setHeader("Cache-Control", "public");
             } else { // HTTPS
                 response.setHeader("Cache-Control", "private");
             }
			
             String reqSpecSourceId = (String) emxGetParameter(request, "reqSpecSourceId");
             String reqSpecTargetId = (String) emxGetParameter(request, "reqSpecTargetId");
             
             //Relationship direction modification for covered and refined requirements.
             String derivationMode = (String) emxGetParameter(request, "derivationMode");
     		
             HashMap reqSpecIdsMap = new HashMap();
             reqSpecIdsMap.put("reqSpecSourceId",reqSpecSourceId);
             reqSpecIdsMap.put("reqSpecTargetId",reqSpecTargetId);
             reqSpecIdsMap.put("derivationMode",derivationMode);
             
             String isReqSpecsDerivationLinkExists = (String) JPO.invoke(context,
     	 	         "emxRMTCommonBase", null, "getReqSpecsDerivationLink", JPO.packArgs(reqSpecIdsMap),
     	             String.class);
             
             // ++ Relationship direction modification for covered and refined requirements.             
             String rootXMLData       = "isReqSpecsDerivLinkExists=\""+isReqSpecsDerivationLinkExists+"\"";
 	         
 	        %>
 	        <mxRoot>
         	<rows>
         	<r <%=rootXMLData%>></r>
         	</rows>
 	        </mxRoot>
 	        <%
            // -- Relationship direction modification for covered and refined requirements.
 	        
 	        // We can end the JSP here
 	        return;
         }
        
         else if (strMode.equalsIgnoreCase("createReqSpecsDerivationLink")) {
             out.clear();

             if (request.getProtocol().equals("HTTP/1.1")) {
                 response.setHeader("Cache-Control", "public");
             } else { // HTTPS
                 response.setHeader("Cache-Control", "private");
             }
			 
             String reqSpecSourceId  = (String) emxGetParameter(request, "reqSpecSourceId");             
             String reqSpecTargetIds = (String) emxGetParameter(request, "reqSpecTargetIds");
             
             //Relationship direction modification for covered and refined requirements.
             String derivationMode   = (String) emxGetParameter(request, "derivationMode");
             
     		 HashMap reqSpecIdsMap = new HashMap();
             reqSpecIdsMap.put("reqSpecSourceId",reqSpecSourceId);
             reqSpecIdsMap.put("reqSpecTargetIds",reqSpecTargetIds);
             reqSpecIdsMap.put("derivationMode",derivationMode);
             
             String isReqSpecsDerivationLinkExists = (String) JPO.invoke(context,
     	 	         "emxRMTCommonBase", null, "createReqSpecsDerivationLink", JPO.packArgs(reqSpecIdsMap),
     	             String.class); 
     	                         
             // ++ HAT1 ZUD: IR-381835-3DEXPERIENCER2016x fix 
             isReqSpecsDerivationLinkExists = "isReqSpecsDerivationLinkExists=\"" + isReqSpecsDerivationLinkExists+"\"";
             
 	        %>
 	        <mxRoot>
	         	<rows>   
	         		<r <%=isReqSpecsDerivationLinkExists%>></r>
	         	</rows>
 	        </mxRoot>
         	 <%	
             // -- HAT1 ZUD: IR-381835-3DEXPERIENCER2016x fix 
 	        
 	        // We can end the JSP here
 	        return;
         }
        
         // -- HAT1 ZUD HL Requirement Specification Dependency

        // ++ IR-364087-3DEXPERIENCER2016x existing dependency Target Reqspecs
         else if(strMode.equalsIgnoreCase("existingDependTargetReqSpecs"))
         {
        	 	out.clear();
         
             // ++ Relationship direction modification for covered and refined requirements.
             String rootObjectId   = (String) emxGetParameter(request, "objectId");
             String derivationMode = (String) emxGetParameter(request, "derivationMode");
			 
     		 HashMap reqSpecIdModeMap = new HashMap();
     		 reqSpecIdModeMap.put("rootObjectId",rootObjectId);
     		 reqSpecIdModeMap.put("derivationMode",derivationMode);
             
			 StringList listExistingDependTargetReqSpecs = (StringList) JPO.invoke(context,
     	 	         "emxRMTCommonBase", null, "getExistingDependTargetReqSpecs", JPO.packArgs(reqSpecIdModeMap),
     	             StringList.class); 
             // -- Relationship direction modification for covered and refined requirements.
			 
			 //Populating data xml in this format
			 
             %>
         	<mxRoot>
         	<rows>   
         	<%
         	for(int i=0;i<listExistingDependTargetReqSpecs.size();i++)
         	{
         		String rootXMLData = "o=\""+listExistingDependTargetReqSpecs.get(i)+"\"";
         	%>
         	<r <%=rootXMLData%>></r>  	
         	<%
         	}
         	%>         	
         	</rows>
         	</mxRoot>
         	<%	 
        	 return;
         } 
         // -- IR-364087-3DEXPERIENCER2016x existing dependency Target Reqspecs 

         // ++ HAT1 ZUD: IR-363246-3DEXPERIENCER2016x fix
         else if(strMode.equalsIgnoreCase("DeleteDependencyLinks"))
         {
        	 	out.clear();
         
             // list of all the selected target reqSpec
             String sourceRootId   = (String) emxGetParameter(request, "sourceRootId");
             String sIdString      = (String) emxGetParameter(request, "sIdString");

             
     		 HashMap reqSpecIdsMap = new HashMap();
     		 reqSpecIdsMap.put("sIdString", sIdString);
     		 reqSpecIdsMap.put("sourceRootId", sourceRootId);
     		 
			 StringList listDeletedDependTargetReqSpecs = (StringList) JPO.invoke(context,
     	 	         "emxRMTCommonBase", null, "getDeletedDependTargetReqSpecs", JPO.packArgs(reqSpecIdsMap),
     	             StringList.class); 
			 
			 //Populating data xml in this format
			 
             %>
         	<mxRoot>
         	<rows>   
         	<%
         	for(int i=0;i<listDeletedDependTargetReqSpecs.size();i++)
         	{
         		String rootXMLData = "name=\""+listDeletedDependTargetReqSpecs.get(i)+"\"";
         	%>
         	<r <%=rootXMLData%>></r>  	
         	<%
         	}
         	%>         	
         	</rows>
         	</mxRoot>
         	<%	 
        	 return;
         }
         // -- HAT1 ZUD: IR-363246-3DEXPERIENCER2016x fix

         
	 // ++ ZUD for HL ENOVIA GOV TRM Export to MS Word ++ 
         else if (strMode.equalsIgnoreCase("GetExportMode"))
         {
        	 
         	out.clear();

             if (request.getProtocol().equals("HTTP/1.1")) {
                 response.setHeader("Cache-Control", "public");
             } else { // HTTPS
                 response.setHeader("Cache-Control", "private");
             }
             
        	 String selectedExportWordFormatSettings = PropertyUtil.getAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedExportWordFormatSettings");
        	 // ++ IR-356259-3DEXPERIENCER2016x ++
        	 if(selectedExportWordFormatSettings.equalsIgnoreCase(""))
        	 {
        		 selectedExportWordFormatSettings = "RMC";
        		 PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "preference_selectedExportWordFormatSettings", selectedExportWordFormatSettings.trim());
        	 
        	 }
        	// -- IR-356259-3DEXPERIENCER2016x --
        	 %>
  	        <mxRoot>
  	        <%
  	           %><htmlContent><![CDATA[<%=selectedExportWordFormatSettings%>]]></htmlContent><%
  	        %>
  	        </mxRoot>
  	        <%
  	        return;
         }
         else if (strMode.equalsIgnoreCase("Aspose"))
         {
        	%> 
        	 <script language="javascript" type="text/javaScript">
        	 refreshPage();
        	 </script>
        	 <%
  			out.clear();
  			// Check Aspose License
  			com.aspose.words.License license = new com.aspose.words.License();
  			try 
  			{
  				license.setLicense("../../WebClient/Aspose.Words.lic");
  			} 
  			catch (Exception e) 
  			{
  				// NOP, an error message will appear on the translation too
  				e.printStackTrace();
  			}

  			strParentObjId = emxGetParameter(request, "objectIdRoot");
  			// docWordAspose Aspose Word document which will be exported
  			com.aspose.words.Document docWordAspose = new com.aspose.words.Document();
  			// Document builder for Aspose doc
  			com.aspose.words.DocumentBuilder builder = new com.aspose.words.DocumentBuilder(docWordAspose);

  			// Get business object list from session level Table bean
  			HashMap tableData = indentedTableBean.getTableData(timeStamp);
  					
  					
  		// ++ KIE1 ZUD Fix for IR-364213-3DEXPERIENCER2016x
    	// Retrieve list of objects to export 
    	String ObjectsToExport = (String) emxGetParameter(request, "objectsToExport");
    	int childListLength = 0;
    	if(ObjectsToExport != null)
    	{
    		childListLength = ObjectsToExport.length();
    	}
    	
    	// FileterdObject MapList 
		MapList oFilteredObject = new MapList();
		TreeMap indexedObjectList = (TreeMap)tableData.get("IndexedObjectList");
		// To srore Object Info from indesedbobject List with No Name attribute 
 		//( Exported just after creation)
 		TreeMap MapWithoutName= new TreeMap();
 		boolean IsNameAbsentInIndxObjList = false;
 		StringList objectIdsForName = new StringList();
 		String[] ObjectToExportIds = ObjectsToExport.split(":");
		
 		// condition will run when user want to import only displyed struture
    	if( childListLength > 0 && !ObjectsToExport.contains("Whole"))
    	{    		 
    		 for(int i=0;i<ObjectToExportIds.length;i++)
    		 {
    			 Map objInfo = (Map)indexedObjectList.get(ObjectToExportIds[i]);
    			 if(null!=objInfo)
    			 {
    				 String Level = (String)objInfo.get("level");
    				 if(Level.equalsIgnoreCase("0")) // Root object info not aprropriate in Indexed table list hence doing a server call
    				 {
    					 DomainObject rootObj = DomainObject.newInstance(context, (String)objInfo.get("id"));
    					 String rootType = rootObj.getInfo(context, DomainConstants.SELECT_TYPE);
    					 String rootName = rootObj.getInfo(context, DomainConstants.SELECT_NAME);
    					 String rootRev = rootObj.getInfo(context, DomainConstants.SELECT_REVISION);
    					 String rootModified = rootObj.getInfo(context, DomainConstants.SELECT_MODIFIED);
    					 
    					 Hashtable rootMap = new Hashtable();
    					 rootMap.put(DomainConstants.SELECT_ID, (String)objInfo.get("id"));
    					 rootMap.put(DomainConstants.SELECT_TYPE, rootType);
    					 rootMap.put(DomainConstants.SELECT_NAME, rootName);
    					 rootMap.put(DomainConstants.SELECT_MODIFIED, rootModified);
    					 rootMap.put(DomainConstants.SELECT_REVISION, rootRev);
    					 rootMap.put("Root Node", "true");
    					 rootMap.put(DomainConstants.SELECT_LEVEL, "0");
    					 oFilteredObject.add(rootMap);
    				}
    				 else
     				{	// Store information in Filtered object only if it contains name
     					if(!IsNameAbsentInIndxObjList && null!=(String)objInfo.get(DomainConstants.SELECT_NAME))
     						oFilteredObject.add(objInfo);
     					else// else save it for retrieving name from DB
     					{
     						MapWithoutName.put((String)objInfo.get(DomainConstants.SELECT_ID),objInfo);
     						IsNameAbsentInIndxObjList = true;
     						objectIdsForName.addElement((String)objInfo.get(DomainConstants.SELECT_ID));
     					}
     				}
    			 }
    		 }
    		
     		}
 			//execute for exporting whole/complete struture in word
    		else
     		{     			  				
     	    	HashMap programMap = new HashMap();
     	    	// filling programMap with required attribute
     	    	programMap.put("objectId",strParentObjId);
     	    	programMap.put("expandLevel","All");
     	       	programMap.put("CFFExpressionFilterInput_OID","undefined");
     	    	programMap.put("fullTextSearch","false");
     	    	
     	    	MapList allExpandedObject = new MapList();
     	    	// invoking jpo for fetching complete tree struture objects using modified programMap above.
     	    	allExpandedObject = (MapList)JPO.invoke(context, "emxSpecificationStructure", null, "expandTreeWithAllRequirements", JPO.packArgs(programMap), MapList.class);
     
     	    	// adding root object in oFilteredObject list
     	    	 DomainObject rootObj = DomainObject.newInstance(context, strParentObjId);
				 String rootType = rootObj.getInfo(context, DomainConstants.SELECT_TYPE);
				 String rootName = rootObj.getInfo(context, DomainConstants.SELECT_NAME);
				 String rootRev = rootObj.getInfo(context, DomainConstants.SELECT_REVISION);
				 String rootModified = rootObj.getInfo(context, DomainConstants.SELECT_MODIFIED);
				 
				 Hashtable rootMap = new Hashtable();
				 rootMap.put(DomainConstants.SELECT_ID, strParentObjId);
				 rootMap.put(DomainConstants.SELECT_TYPE, rootType);
				 rootMap.put(DomainConstants.SELECT_NAME, rootName);
				 rootMap.put(DomainConstants.SELECT_MODIFIED, rootModified);
				 rootMap.put(DomainConstants.SELECT_REVISION, rootRev);
				 rootMap.put("Root Node", "true");
				 rootMap.put(DomainConstants.SELECT_LEVEL, "0");
				 oFilteredObject.add(rootMap);
			// iterating through allExpandedObject and adding it to the oFilteredObject
				 for(int i = 0; i < allExpandedObject.size()-1; i++)
				 {
					 Map objInfo = (Map)allExpandedObject.get(i);
				 	 oFilteredObject.add(objInfo);
				 }
     		}
 		   
    		// If Some Object from indexed object List have no name attribute
	 		if(true == IsNameAbsentInIndxObjList)
	 		{
	 			IsNameAbsentInIndxObjList = false;
	 			StringList selects = new StringList(DomainConstants.SELECT_NAME);
	 			selects.addElement(DomainConstants.SELECT_ID);
	 			String[] IdsForSelect = new String[objectIdsForName.size()];
	 			for(int i=0;i<objectIdsForName.size();i++)
	 				 IdsForSelect[i] = (String)objectIdsForName.get(i);
	 			// fetch Name from DB
	 			MapList list = DomainObject.getInfo(context,IdsForSelect, selects);
	 			// Populate FilteredObjectList
	 			for(int i=0;i<list.size();i++)
	 			{
	 				Map ObjectToPut = (Map)list.get(i);
	 				Map FiletredObjectMap = (Map)MapWithoutName.get(ObjectToPut.get(DomainConstants.SELECT_ID));
	 				FiletredObjectMap.put(DomainConstants.SELECT_NAME,ObjectToPut.get(DomainConstants.SELECT_NAME));
	 				oFilteredObject.add(FiletredObjectMap);
	 			}
	 		}
	 		// Fill the Filtered Object List of table
	    	tableData.put("FilteredObjectList", oFilteredObject);
  	    	// -- KIE1 ZUD Fix for IR-364213-3DEXPERIENCER2016x
  	    	
  	    	
  			boolean isSimpleView = false;
  			// We can set the exportFormat if any
  			((Map) tableData.get("RequestMap")).put("exportFormat",	"Word");
  			richtextTableBean.setTableData(timeStamp, tableData);
  			reponseDoc = richtextTableBean.getXMLData(context, timeStamp, timeZone, strParentObjId, isSimpleView);

  			docString = reponseDoc.toString();
			// ZUD Commenting the useless code
  			/*XMLOutputter xmlOut = MxXMLUtils.getOutputter(false);

  			out.clearBuffer();
  			xmlOut.output(reponseDoc, System.out);
  			xmlOut.output(reponseDoc, out);*/
  			com.matrixone.jdom.Element rootNode = reponseDoc.getRootElement();
  			
  			// Set height and define the height rule for the header row.  	
  			int intPreviousLevel = Integer.parseInt("0");
  			String previousBookmark = "";
  			int intCurLevel = intPreviousLevel;
  			List list = rootNode.getChildren("object");
  			String docName = "";
  			String strType = "";
            // IR-383770-3DEXPERIENCER2016x :No Color exported during export to word
  			Color tobefilled= Color.WHITE;
  			// Stack for filling bookmarks of each Requirement Object
  			// ArrayList Contains two String 
  			// 0--> Level of Object
  			// 1--> Bookmark name
  			List<ArrayList<String>> Stack_List = new ArrayList<ArrayList<String>>();
  			
  			// Traverse throush all children of Parent Req-Spec(strParentObjId) and dump them in Aspose document
  			int bm_Fake_index =0;
  			for (int i = 0; i < list.size(); i++)
  			{
  				// Fetch the Shading of Paragraph for coloring (Comment Chapter Req etc)
  				com.aspose.words.Shading shading = builder.getParagraphFormat().getShading();
  				// Get the Requrement object node from List
  				com.matrixone.jdom.Element node = (com.matrixone.jdom.Element) list.get(i);
				// Fetch attributes of Requirement Object
  				String objectId = node.getAttributeValue("oid");
  				String relId = node.getAttributeValue("rel");
  				// Create DOM Object
  				DomainObject dmoObj = DomainObject.newInstance(context,	objectId);
  				String ObjectType = dmoObj.getInfo(context, DomainConstants.SELECT_TYPE);
  				String ObjectTitle = dmoObj.getAttributeValue(context, "Title");
  				String ObjectRevision = dmoObj.getInfo(context, DomainConstants.SELECT_REVISION);
  				// Export TO Word is not Supported for RMC
  				if(!ObjectType.equalsIgnoreCase("Requirement Proxy"))
  				{
  				String bookMarkStart = "";
  				String Name = node.getChildText("name");
  				String strCurLevel = node.getAttributeValue("level");
  				intCurLevel = Integer.parseInt(node.getAttributeValue("level"));
  				System.out.println("First Name : " + Name);
  				System.out.println("Current Level : " + strCurLevel);
  				ArrayList<String> BookMark_Level= new ArrayList<String>();
  				
  				// Exported Document name will be that of Req-Spec
  				if (0 == i)
  				{
  					docName = Name;
  				}
				 
  				if(Stack_List.size()>0)
  				{
  					List<String> Check_Level = Stack_List.get(Stack_List.size()-1);
  					
  					// Close the book-mark after popping from stack
  					while(Integer.parseInt(Check_Level.get(0))>= Integer.parseInt(strCurLevel))
  					{
  						builder.moveToBookmark(Check_Level.get(1), false,
  	  							false);
  						builder.endBookmark(Check_Level.get(1));
  						Stack_List.remove(Stack_List.size()-1);
  						if(Stack_List.size()>0)
  						{
  							Check_Level=Stack_List.get(Stack_List.size()-1);
  						}
  						else
  						{
  							break;
  						}
  						
  					}
  				}
  					
					// Check for Object Type and Sub Type IR-352416-3DEXPERIENCER2016x
						
  				  String IconName = ""; 
  				  if(dmoObj.isKindOf(context, "Chapter"))
  				  {
  					strType = ObjectType;
                    // IR-383770-3DEXPERIENCER2016x :No Color exported during export to word
  					//shading.setBackgroundPatternColor(Color.BLUE);
  					//tobefilled = Color.BLUE;
  					bookMarkStart = "RMTAH";
  					ObjectType = "Chapter";
  				    IconName = UINavigatorUtil.getTypeIconProperty(context, ObjectType);
  				  }
  				   
  				  else if(dmoObj.isKindOf(context, "Comment"))
  				  {
                    // IR-383770-3DEXPERIENCER2016x :No Color exported during export to word
  					//shading.setBackgroundPatternColor(Color.cyan);  // Light Salmon
  					strType = ObjectType;
  					//tobefilled = Color.cyan;
  					bookMarkStart = "RMTAC"; 
  					ObjectType = "Comment";
  					IconName = UINavigatorUtil.getTypeIconProperty(context, ObjectType);
  				  }
  				   
  				  else if(dmoObj.isKindOf(context, "Requirement"))
  				  {
  					// Fix for IR-382753-3DEXPERIENCER2016x
  					if(relId.compareTo("") != 0){
	  					DomainRelationship dRel = new DomainRelationship(relId);
	  					Hashtable relData = dRel.getRelationshipData(context,new StringList(DomainRelationship.SELECT_NAME));
	  					if(!relData.toString().contains("Sub Requirement"))
	  					{
                            // IR-383770-3DEXPERIENCER2016x :No Color exported during export to word
		  					//shading.setBackgroundPatternColor(Color.LIGHT_GRAY);  //
		  					strType = ObjectType;
		  					//tobefilled = Color.LIGHT_GRAY;
		  					bookMarkStart = "RMTAR";  
		  					ObjectType = "Requirement";
		  					IconName = UINavigatorUtil.getTypeIconProperty(context, ObjectType);
	  					}else
	  					{
	  						// ++ HAT1 ZUD: IR-502186-3DEXPERIENCER2018x fix
	  						strType = ObjectType;
		  					//tobefilled = Color.LIGHT_GRAY;
		  					bookMarkStart = "RMTCB";  
		  					ObjectType = "Sub Requirement";
		  					IconName = "iconReqTypeSubRequirement.png";
		  					// -- HAT1 ZUD: IR-502186-3DEXPERIENCER2018x fix
	  					}
	  				  }
  				  }
  				   
  				  else if(dmoObj.isKindOf(context, "Requirement Specification"))
  				  {
  					bookMarkStart = "RMTAS";
  					ObjectType = "Requirement Specification";
  					strType = ObjectType;
  					IconName = UINavigatorUtil.getTypeIconProperty(context, ObjectType);
  				  }
				  // Don't export any other Requirement Objects IR-352455-3DEXPERIENCER2016x
  				  else
  					  continue;
				 
				// Dont add bookmark of Req-Spec in Stack (It dosent contain sub mookmark)
				// Otherwise push Requirement Object Level and Bookmark in Stack
				BookmarkCollection bmcollec = docWordAspose.getRange().getBookmarks();
  				String BookMarkName = bookMarkStart+objectId;
  				Bookmark bmExist =  bmcollec.get(BookMarkName);
  				if(bmExist!=null)
  					BookMarkName = BookMarkName +"_DUP_"+ ++bm_Fake_index;
  				
  				 if(i>0)
  				 {
  					BookMark_Level.add(strCurLevel);
  					BookMark_Level.add(BookMarkName);
  					Stack_List.add(BookMark_Level);
  				 }
				
  				// Deprecated code to be removed in future
  				if (objectId.equals(null))
  				{
  					previousBookmark = Name;
  					intPreviousLevel = intCurLevel;
  					builder.getFont().setBold(false);
  					shading.clearFormatting();
  					continue;
  				}
  				
  				// Create Shape in ASpose Word Doc for Chapter/Req/Req-Spec etc Icons and hyperlink 
  				Shape shape = null;
  				com.aspose.words.Paragraph para = builder.insertParagraph();
  				// ++ Insert Code for Content Controls in Future ++
  				
  				// -- Insert Code for Content Controls in Future --
  				builder.startBookmark(BookMarkName);
  	  					
  				
  				String sFullClientSideURL = MailUtil.getBaseURL(context);
  				 				 
  				// Fix for IR-352177-3DEXPERIENCER2016x Export doesn't woek on IE
  				//String[] LinkToSplit=sFullClientSideURL.split("/common");
  				//String URLToSend = LinkToSplit[0];
                //IR-362248-3DEXPERIENCER2016x :[On-Premise] Export to work KO on 3DExperience On -Premise server.
  				String ReqPath = getServletConfig().getServletContext().getRealPath("/common/images");
  				shape = builder.insertImage(ReqPath+"/"+IconName);
  				//shape = builder.insertImage(URLToSend+"//"+suiteDir+"/images/"+ObjectType+".gif");
  				String Link = sFullClientSideURL+"?objectId="+objectId+"&Name="+Name;   					
  				shape.setHRef(Link);
  				String alternateText = Name+","+ObjectTitle+","+ObjectRevision;
  				shape.setAlternativeText(alternateText);
  				if(bmExist!=null)
  				{
  					
  					builder.getFont().setColor(Color.BLUE);
  					builder.insertHyperlink(Name, bookMarkStart+objectId, true).isLocked(true);
  					builder.getFont().setColor(Color.black);  	
  					 					
  					continue;
  				}
  				
  				// ZUD 	IR-394636-3DEXPERIENCER2016x Dump the Name as Title if title is missing
  				if(dmoObj.getAttributeValue(context,DomainConstants.ATTRIBUTE_TITLE).equals(""))
  					builder.writeln(Name);
  				else
  					builder.writeln(dmoObj.getAttributeValue(context,DomainConstants.ATTRIBUTE_TITLE));
  					
  						
  				
  				if(i==0)// Close bookmark for Requirement-Spec
  				{
  					builder.endBookmark(bookMarkStart+objectId);
  				}  				
  				// Fetch Content Data and Content Type
  				String strContentData = dmoObj.getAttributeValue(context, "Content Data");
  				String strContentType = dmoObj.getAttributeValue(context, "Content Type");

   				if ((strContentData.equals(null))
  						|| (strContentData.contentEquals("")))
  				{
  					previousBookmark = bookMarkStart+objectId;
  					intPreviousLevel = intCurLevel;
  					builder.getFont().setBold(false);
  					shading.clearFormatting();
  					continue;
  				}
  				// com.matrixone.jdom.Document rtfDoc = new com.matrixone.jdom.Document(root);
  				byte[]dataBytes = strContentData.getBytes("UTF-8");
  				com.aspose.words.Document DocToInsert = new com.aspose.words.Document(RichEditFactory.getRichEditUtil().getContentStream(context, objectId, IRichEditUtil.Format.DOCX));

  				previousBookmark = bookMarkStart+objectId;
  				intPreviousLevel = intCurLevel;
  				insertDocument(para, DocToInsert,tobefilled); 		
  				
  				builder.getFont().setBold(false);
  				shading.clearFormatting();
  			}
  			
  			}
  			
  			// Pop all the remaining Bookmark from stack and Close
  			while(Stack_List.size() > 0)
  			{
  				List<String> Check_Level = Stack_List.get(Stack_List.size()-1);
  				builder.moveToBookmark(Check_Level.get(1), false,false);
  				builder.endBookmark(Check_Level.get(1));
  				Stack_List.remove(Stack_List.size()-1);
  			} 			

  			//change the bookmark name from those of new to those of existing 
  			Iterator it = docWordAspose.getRange().getBookmarks().iterator();
  			String bookname = "";

  			while (it.hasNext())
  			{
  				com.aspose.words.Bookmark bookmark = (com.aspose.words.Bookmark) it.next();
  				bookname = bookmark.getName();
  				System.out.println("Bookmark Name : " + bookname);
  				if (bookname.startsWith("RMTC"))
  				{
  					bookname = bookname.replace("RMTC", "RMTA");
  				}

  				try
  				{
  				bookmark.setName(bookname);
  				}
  				catch (Exception e)
  				{
  					
  				}
  				System.out.println("New Name : " + bookname);
  				
  			}
  			
  		
  			//get the attribute values

                
             //   String[] getAttributes(Context context, String sContext, String username, String password, String lang, String type)
                //HashMap methodMap = new HashMap();
                HashMap<String, String> argsMap = new HashMap<String, String>();
                
               
               // Map customData = context.getCustomData();
                
                String strContext = context.getRole();
                
                String loginUsername = context.getUser();
                String strLoginPassword = context.getPassword();
                
                argsMap.put("sContext", strContext);
                argsMap.put("username", loginUsername);
                argsMap.put("password", strLoginPassword);                
                argsMap.put("lang", request.getHeader("Accept-Language"));
                argsMap.put("type", strType);
//                 String[] methodArgs = JPO.packArgs(argsMap);
//                 String[] attributes = (String[]) JPO.invoke( context, "emxRequirementCaptureWebservice", new String[] {},
//                 		                                     "getAttributes", methodArgs, String[].class);
//                 if(attributes == null)
//                 {
                	
//                 }
//                 else
//                 {
//                 	String[] attNames = new String[attributes.length];
//                 	String[] attValues = new String [attributes.length];
//                     for (int i = 0; i < attributes.length; i++)
//                     {
//                       String[] splitStr = (attributes[i]).split("\\|");
//                       attNames[i] = splitStr[0];
                      
                      
//                     }
//                 }
                
  			
  			//set them in content controls
    			
			// Put the exported Doc in Temp not in Working Dir (In future)
  			// Ask user to Save at desider Location
  			if (!docName.equals(null) && !docName.contentEquals(""))
  			{
  				
  				ServletOutputStream sout = response.getOutputStream();
  				response.addHeader("Content-Disposition","attachment; filename=\"" + docName +".docx" + "\"" );
  				response.setContentType("application/vnd.ms-word");
  				// IR-362248-3DEXPERIENCER2016x : for Content Disposition on HTTPS server (3DExperience server.)
  				response.addHeader("Cache-Control", "max-age=0");
  				docWordAspose.save(sout, com.aspose.words.SaveFormat.DOCX);
  				sout.close();
  	            sout.flush();
  			}  
  	        out.clear();
  	        out = pageContext.pushBody();
  		} 
        // ++KIE1 ZUD 15:08:24  IR-386290-3DEXPERIENCER2016x
        // Added new mode for converting values depends on unit which is in combobox and value will display in parameter table
         else if (strMode != null && strMode.equals("convert")){
        	 
             out.clear();

             if (request.getProtocol().equals("HTTP/1.1")) {
                 response.setHeader("Cache-Control", "public");
             } else { // HTTPS
                 response.setHeader("Cache-Control", "private");
             }
             
        	 String[] args = new String[3];
 			 args[0] = emxGetParameter(request, "prevUnit");
 			 args[1] = emxGetParameter(request, "currUnit");
 			
 			 String paramValues = emxGetParameter(request, "paramValues");
 			 String values[] = paramValues.split("<");
 			 String returnValues = "";
 			
 			 for(int i=0;i<values.length;i++)
 			 {
				if(!values[i].trim().equals(""))
				{
 				 args[2] = values[i];
 				 returnValues += GetConvertedValuesParameter(context,args);
 				 if(returnValues.trim().length() >= 1)
 					 returnValues +=" , ";
				}
 			 }
 			
 			String rootXMLData = "returnVaues=\""+returnValues+"\"";

 			%>
 			<mxRoot>
 			<rows>
 			<r <%=rootXMLData %> ></r>
 			</rows>
 			</mxRoot>
 			<%
 	        return;
         }
        //   ++ KIE1 ZUD for Tree Preferences in Struture Browser
         else if (strMode != null && strMode.equals("getTreeDisplaySettings"))
         {
        	 out.clear();
    		 String rootXMLData = (String)JPO.invoke(context, "emxRMTCommon", null, "getTreeDisplaySettingsForStrutureBrowser", null,String.class);
    	   	%>
 			<mxRoot>
 			<rows>
 			<%=rootXMLData%>
 			</rows>
 			</mxRoot>
        	<%
        	
     	   return;
         }
         // -- KIE1 ZUD for Tree Preferences in Struture Browser
   }
 catch (Exception e) 
 {
       bFlag = true;
       String strAlertString = "emxRequirements.Alert." + e.getMessage();
       
        // ++ HAT1 ZUD IR-446064-3DEXPERIENCER2017x FIX 
        String msgError = e.getMessage();
        if(msgError.contains("ErrorCode:"))
        {
        	int index = msgError.indexOf("ErrorCode:");
	   		String errorCode = msgError.substring(index+10);
	   		if(errorCode.equalsIgnoreCase("1500019"))
	   			strAlertString = "emxRequirements.Alert." + "NoPrivilege";
        }
	    // -- HAT1 ZUD IR-446064-3DEXPERIENCER2017x FIX
	   	
       String i18nErrorMessage = EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), strAlertString);
       if (i18nErrorMessage.equals(DomainConstants.EMPTY_STRING)) {
           session.putValue("error.message", e.getMessage());
       } else
       {
           session.putValue("error.message", i18nErrorMessage);
       }
   }
        
        %>
        <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
        <%
            if (bFlag) {
        %>
        <script language="javascript" type="text/javaScript">
            findFrame(parent, 'pagecontent').clicked = false;
            //IR-233743V6R2015 An loading icon does not disappear 
            getTopWindow().turnOffProgress();
            history.back();
        </script>
        <%
            }
        %>
    </form>
</html>
