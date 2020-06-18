

<%-- Common Includes --%>
<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.program.ResourcePlan"%>
<%@page import="com.matrixone.apps.program.ResourceRequest"%>
<%@page import="com.matrixone.apps.framework.ui.UITableCommon"%>
<%@page import="matrix.util.*"%>
<%@page import="com.matrixone.apps.domain.util.PolicyUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.Iterator"%>
<%@page import="com.matrixone.apps.program.FTE"%>
<%@page import="com.matrixone.apps.program.ProjectSpace"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Calendar"%>
<%@page import="com.matrixone.apps.domain.util.eMatrixDateFormat"%>


<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@page import="matrix.db.MQLCommand"%>
<%@page import="com.matrixone.apps.program.DurationKeywordsUtil"%>
<%@page import="com.matrixone.apps.program.DurationKeyword"%>
<%@page import="com.matrixone.apps.program.DurationKeywords"%>
<%@page import="java.util.regex.Pattern"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="com.matrixone.apps.common.Task"%>
<%@page import="org.w3c.dom.Element"%>
<%@page import= "javax.xml.parsers.DocumentBuilder"%>
<%@page import ="javax.xml.parsers.DocumentBuilderFactory"%>
<%@page import="java.io.ByteArrayInputStream"%>
<%@page import="java.io.ByteArrayOutputStream"%>

<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>

<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>
<script language="javascript" src="../common/emxJSValidation.jsp"></script>
<script language="javascript" src="../common/scripts/emxJSValidationUtil.js"></script>
<script language="javascript" type="text/javascript" src="emxProgramUtil.js"></script>

<%
            boolean bFlag = false;
            try 
            {
            	String sCharSet = Framework.getCharacterEncoding(request);
                String languageStr = context.getSession().getLanguage();
                String strMode = emxGetParameter(request, "FunctionMode");
                String projectId = emxGetParameter(request, "objectId");
                String strReturnResult = "";
                StringBuffer sBuff = new StringBuffer();
                DurationKeywordsUtil durationKeywordsUtil = new DurationKeywordsUtil();
                String [] strObjectIds = emxGetParameterValues(request,"objectId");
                //String strObjectId = emxGetParameter(request,"objectId");
                String strObjectId = strObjectIds[0];
                strObjectId = XSSUtil.encodeURLForServer(context, strObjectId);
                DomainObject domainObject = DomainObject.newInstance(context, strObjectId);
                if(domainObject.isKindOf(context, DomainConstants.TYPE_TASK_MANAGEMENT))
                {   
                    StringList busSelects = new StringList(1);
                    busSelects.add(DomainConstants.SELECT_ID);
                    Task task = new Task();
                    task.setId(strObjectId);
                    Map projectInfo = task.getProject(context, busSelects);
                    String strProjectId = (String) projectInfo.get(DomainConstants.SELECT_ID);
                    strObjectId = strProjectId;
                }
                if (("create").equals(strMode)) 
                {
                	boolean isOfTemplateType = ProgramCentralUtil.isOfGivenTypeObject(context,DomainConstants.TYPE_PROJECT_TEMPLATE,strObjectId);	
                    String strKeywordName = emxGetParameter(request,"Name");
                    String strKeywordType = emxGetParameter(request,"DurationMap");
                    String strKeywordDuration = emxGetParameter(request,"Duration");
                    String strKeywordDurationUnit = emxGetParameter(request,"DurationUnit");
                    String strKeywordDescription = emxGetParameter(request,"Description");
                    strKeywordDescription = FrameworkUtil.findAndReplace(strKeywordDescription,"<","&lt;");
                    strKeywordDescription = FrameworkUtil.findAndReplace(strKeywordDescription,">","&gt;");
                    DurationKeywords durationKeywords = new DurationKeywords(context, strObjectId);
                    DurationKeyword [] sDurationKeywords = durationKeywords.getDurationKeywords(context,DurationKeyword.ATTRIBUTE_NAME, strKeywordName);
                    if(null!=sDurationKeywords && sDurationKeywords.length>0)
                    {
%>
                        <script language="javascript" type="text/javaScript">
                        	alert("<framework:i18nScript localize="i18nId">emxProgramCentral.DurationKeywords.NameAlreadyExist</framework:i18nScript>");
                        </script>
<%
						return;
                    }
                    DurationKeyword durationKeyword = new DurationKeyword(strKeywordName, strKeywordType, Task.parseToDouble(strKeywordDuration),strKeywordDurationUnit,strKeywordDescription);
                    durationKeywordsUtil.createDurationKeywords(context, strObjectId, durationKeyword);
%>
                    <script language="javascript" type="text/javaScript">
                    getTopWindow().closeSlideInDialog();
                    var contentFrame;
                    if(<%=isOfTemplateType%> == true){
	                 contentFrame = findFrame(getTopWindow(),"content");
                    }else {
                    	contentFrame = findFrame(getTopWindow(),"PMCKeywordDuration");
                    }
                    contentFrame.location.href = contentFrame.location.href;
                   </script>
<%                    
                    
                }
                else if (("apply").equals(strMode)) 
                {
                    String strSuiteKey = emxGetParameter(request, "suiteKey");
                    String strKeywordName = emxGetParameter(request,"Name");
                    String strKeywordType = emxGetParameter(request,"DurationMap");
                    String strKeywordDuration = emxGetParameter(request,"Duration");
                    String strKeywordDurationUnit = emxGetParameter(request,"DurationUnit");
                    String strKeywordDescription = emxGetParameter(request,"Description");
                    String NEGATIVE_FLOATING_POINT_FIELD = "([ ]*)((-?+)|(\\+{0,1}+))([ ]*)([0-9]+)([ 0-9 ]*)([ ]*)((\\.)([ ]*[0-9]+))?+([ ]*)([ 0-9 ]*)([ ]*)";
                    String NON_NEGATIVE_FLOATING_POINT_FIELD = "([ ]*)((\\+{0,1}+))([ ]*)([0-9]+)([ 0-9 ]*)([ ]*)((\\.)([ ]*[0-9]+))?+([ ]*)([ 0-9 ]*)([ ]*)";
                    boolean isNumber = Pattern.matches(NEGATIVE_FLOATING_POINT_FIELD, strKeywordDuration);
                    boolean isPositiveNumber = Pattern.matches(NON_NEGATIVE_FLOATING_POINT_FIELD, strKeywordDuration);
                    DurationKeywords durationKeywords = new DurationKeywords(context, strObjectId);
                    //Added for special character.(Passed context)
                    DurationKeyword [] sDurationKeywords = durationKeywords.getDurationKeywords(context,DurationKeyword.ATTRIBUTE_NAME, strKeywordName);
                    
                    
                    if(null==strKeywordName || "".equals(strKeywordName) || "null".equals(strKeywordName))
                    {
%>
                        <script language="javascript" type="text/javaScript">
                        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.DurationKeywords.NameIsMandatory</framework:i18nScript>");
                       </script>
<%
                    }
                    else 
                    {
	                 	String emxNameBadChars = EnoviaResourceBundle.getProperty(context, "emxFramework.Javascript.NameBadChars");
	                 	String strBadChars = "";
	                 	String strResult = "";
	                 	boolean isBadNameCharRequired = false;
	                 	if(null!=emxNameBadChars && !"".equals(emxNameBadChars) && !"null".equals(emxNameBadChars))
	                 	{
	                 	   isBadNameCharRequired = true;
	                 	   String[] arrBadChars = emxNameBadChars.split(" ");
	                 	   for (int i=0; i < arrBadChars.length; i++)
	                 	   {
	                 		   if (strKeywordName.indexOf(arrBadChars[i]) > -1)
	                 		   {
	                 			   strBadChars += arrBadChars[i] + " ";
	                 		   }
	                 	   }
	                 	   if (strBadChars.length() > 0) 
	                       {
	                 		   strResult = emxNameBadChars;
	                       }
	                 	}
	                    if (isBadNameCharRequired && strResult.length() != 0)
	                    {
%>
	                        <script language="javascript" type="text/javaScript">
	                        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.InvalidCharacters</framework:i18nScript>\n"
	                        	    + "<%=XSSUtil.encodeForJavaScript(context,strResult)%>" + "\n<framework:i18nScript localize="i18nId">emxProgramCentral.Common.RemoveInvalidCharacter</framework:i18nScript>");
	                        </script>
<%
							return;
	                    }
	                    else if(null!=sDurationKeywords && sDurationKeywords.length>0)
	                    {
	%>
	                        <script language="javascript" type="text/javaScript">
	                        	alert("<framework:i18nScript localize="i18nId">emxProgramCentral.DurationKeywords.NameAlreadyExist</framework:i18nScript>");
	                        </script>
	<%
							return;
	                    }
	                    if((strKeywordType.equals("SlackTime")&& !isNumber) || ((!strKeywordType.equals("SlackTime")) && !isPositiveNumber))
	                    {
	%>
	                        <script language="javascript" type="text/javaScript">
	                        	alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Task.PleaseEnterOnlyNumbers</framework:i18nScript>");
	                        </script>
	<%	
							return;
	                    }
	                    else if (Task.parseToDouble(strKeywordDuration) >= 10000)
	                    {
	%>
	                        <script language="javascript" type="text/javaScript">
	                       	 	alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Common.PleaseEnterADurationValueLessThan</framework:i18nScript>");
	                        </script>
	<%
							return;
	                    }
	                    else
	                    {
	                    	DurationKeyword durationKeyword = new DurationKeyword(strKeywordName, strKeywordType, Task.parseToDouble(strKeywordDuration),strKeywordDurationUnit,strKeywordDescription);
	                    	durationKeywordsUtil.createDurationKeywords(context, strObjectId, durationKeyword);
%>
	                        <script language="javascript" type="text/javaScript">
	                        alert("<framework:i18nScript localize="i18nId">emxProgramCentral.DurationKeywords.KeywordCreatedSuccessFully</framework:i18nScript>");
	                        
	                        getTopWindow().getWindowOpener().refreshSBTable(getTopWindow().getWindowOpener().configuredTableName);
	                        
	                        var contentFrame = findFrame(getTopWindow(),"content");
	                        contentFrame.location.href = contentFrame.location.href;
	                        </script>
<%	                     }
                     }
                }
                else if (("preedit").equals(strMode))
                {
                	String [] strKeywordNames = emxGetParameterValues(request,"emxTableRowId");
                	strKeywordNames = ProgramCentralUtil.parseTableRowId(context,strKeywordNames);
                    String strSuiteKey = emxGetParameter(request, "suiteKey");
                    
                  //Modified:1-Sept-2010:s4e:R210 PRG:IR-060959V6R2011x
                   
                  String strDurationKeywordName = FrameworkUtil.encodeNonAlphaNumeric(strKeywordNames[0],sCharSet); 
%>
                  <script language="javascript" type="text/javaScript">
                        getTopWindow().location.href = "../common/emxForm.jsp?form=PMCDurationKeywordCreateForm&formHeader=emxProgramCentral.DurationKeywords.Edit&mode=edit&postProcessURL=../programcentral/emxProgramCentralDurationKeywordsUtil.jsp&suiteKey=<%=XSSUtil.encodeForURL(context,strSuiteKey)%>&HelpMarker=emxhelpkeywordedit&FunctionMode=edit&DurationKeywordName=<%=XSSUtil.encodeForURL(context,strDurationKeywordName)%>&objectId=<%=XSSUtil.encodeURLForServer(context,strObjectIds[0])%>";
                  </script>
<%
                   //End:Modified:1-Sept-2010:s4e:R210 PRG:IR-060959V6R2011x
                }
                else if (("edit").equals(strMode))
                {
                    DurationKeyword [] sDurationKeyword = new DurationKeyword[1];
                    String strKeywordName = emxGetParameter(request,"Name");
                    String strKeywordType = emxGetParameter(request,"DurationMap");
                    String strKeywordDuration = emxGetParameter(request,"Duration");
                    String strKeywordDurationUnit = emxGetParameter(request,"DurationUnit");
                    String strKeywordDescription = emxGetParameter(request,"Description");
                    strKeywordDescription = FrameworkUtil.findAndReplace(strKeywordDescription,"<","&lt;");
                    strKeywordDescription = FrameworkUtil.findAndReplace(strKeywordDescription,">","&gt;");
                    DurationKeyword durationKeyword = new DurationKeyword(strKeywordName, strKeywordType, Task.parseToDouble(strKeywordDuration),strKeywordDurationUnit,strKeywordDescription);
                    sDurationKeyword[0] = durationKeyword;
                    durationKeywordsUtil.updateMassDurationKeywords(context, strObjectId, sDurationKeyword);
%>
                    <script language="javascript" type="text/javaScript">
                    getTopWindow().getWindowOpener().refreshSBTable(getTopWindow().getWindowOpener().configuredTableName);
                    getTopWindow().closeWindow();
                    </script>
<%
                }
                else if (("editall").equals(strMode)) 
                {
                    int nObjCount = Integer.parseInt((String) emxGetParameter(request,"objCount"));
                    DurationKeyword [] sDurationKeyword = new DurationKeyword[nObjCount];
                    
                    DurationKeyword [] oldDurationKeyword = new DurationKeyword[nObjCount];
                    DomainObject domainProjectObject = DomainObject.newInstance(context,strObjectId);
        			String strXML = domainProjectObject.getAttributeValue(context, DomainConstants.ATTRIBUTE_ESTIMATED_DURATION_KEYWORD_VALUES);
        			ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(strXML.toString().getBytes());
        	       	DocumentBuilder parser = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        	       	org.w3c.dom.Document docXML = parser.parse(byteArrayInputStream);
        	       	org.w3c.dom.Element root = docXML.getDocumentElement();
        	        org.w3c.dom.NodeList nodel = root.getChildNodes();
        			for (int a = 0; a < nodel.getLength(); a++){
        				org.w3c.dom.Node node = nodel.item(a);
        				if(node instanceof Element) {
        				  String sDKName = ((Element)node).getAttribute("name");
        				 /* String sDKType = ((Element)node).getAttribute("type");
        				  String sDKUnit = ((Element)node).getAttribute("unit");
        				  String sDKDuration = ((Element)node).getAttribute("duration");*/
        				  String strKeywordType = emxGetParameter(request,"Type"+a);
                          String strKeywordDuration = emxGetParameter(request,"Duration"+a);
                          String strKeywordDurationUnit = emxGetParameter(request,"DurationUnit"+a);
        				  String strKeywordDescriptions = emxGetParameter(request,"Description"+a);
        				  
        				 // DurationKeyword durationKeywords = new DurationKeyword(sDKName, sDKType, Task.parseToDouble(sDKDuration),sDKUnit,strKeywordDescriptions);
        				 DurationKeyword durationKeyword = new DurationKeyword(sDKName, strKeywordType, Task.parseToDouble(strKeywordDuration),strKeywordDurationUnit,strKeywordDescriptions);
        				 oldDurationKeyword[a] = durationKeyword;
        				}
        			}
                   /* for(int i=0; i<nObjCount; i++)
                    {
                    	//Modified:20-Sept-2011:MS9:R212 PRG:IR-076404V6R2012x
                        String strKeywordName = emxGetParameter(request,"Name"+i);
                        //End:20-Sept-2011:MS9:R212 PRG:IR-076404V6R2012x
                        String strKeywordType = emxGetParameter(request,"Type"+i);
                        String strKeywordDuration = emxGetParameter(request,"Duration"+i);
                        String strKeywordDurationUnit = emxGetParameter(request,"DurationUnit"+i);
                        String strKeywordDescription = emxGetParameter(request,"Description"+i);
                        strKeywordDescription = FrameworkUtil.findAndReplace(strKeywordDescription,"<","&lt;");
                        strKeywordDescription = FrameworkUtil.findAndReplace(strKeywordDescription,">","&gt;");
                        DurationKeyword durationKeyword = new DurationKeyword(strKeywordName, strKeywordType, Task.parseToDouble(strKeywordDuration),strKeywordDurationUnit,strKeywordDescription);
                        sDurationKeyword[i] = durationKeyword;
                    }*/
                   
                    durationKeywordsUtil.updateMassDurationKeywords(context, strObjectId, oldDurationKeyword);
                   // durationKeywordsUtil.updateMassDurationKeywords(context, strObjectId,oldDurationKeyword,sDurationKeyword); //Added:di7
%>
                    <script language="javascript" type="text/javaScript">
                    getTopWindow().getWindowOpener().refreshSBTable(getTopWindow().getWindowOpener().configuredTableName);
                    getTopWindow().closeWindow();
                    </script>
<%
                }
                else if (("delete").equals(strMode))
                {
                	String [] strKeywordNames = emxGetParameterValues(request,"emxTableRowId");
                	strKeywordNames = ProgramCentralUtil.parseTableRowId(context,strKeywordNames);
                	int nObjCount = strKeywordNames.length;
                    DurationKeyword [] sDurationKeyword = new DurationKeyword[nObjCount];
                    for(int i=0; i<nObjCount; i++)
                    {
                        String strKeywordName = strKeywordNames[i];
                        DurationKeywords durationKeywords = new DurationKeywords(context, strObjectId);
                        //Added for special character.(Passed context)
                        DurationKeyword [] sDurationKeywords = durationKeywords.getDurationKeywords(context,DurationKeyword.ATTRIBUTE_NAME, strKeywordName);
                        DurationKeyword durationKeyword = sDurationKeywords[0];
                        sDurationKeyword[i] = durationKeyword;
                    }
                    durationKeywordsUtil.removeDurationKeywordsValue(context, strObjectId, sDurationKeyword);
%>
                    <script language="javascript" type="text/javaScript">
                     getTopWindow().getWindowOpener().refreshSBTable(getTopWindow().getWindowOpener().configuredTableName);
                    getTopWindow().closeWindow();
                    </script>
<%
                }
                else
                {
                    throw new IllegalArgumentException(strMode);
                }
            }
            catch (Exception e)
            {
                bFlag = true;
                e.printStackTrace();
                session.putValue("error.message", e.getMessage());
            }

%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "../components/emxComponentsDesignBottomInclude.inc"%>
