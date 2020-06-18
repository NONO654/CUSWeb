<%--  smaCreate.jsp
   (c) Dassault Systemes, 2007-2010

   This is an exact copy of emxCreate.jsp
   (modified as follows for use in SCE)

   Changes:
   1) Override xsl file on job create to allow enable/disable of host
      fields.
   2) Add time stamp to createBean.formData to enable structure
      browser row addition.
   3) "Massages" error messages to make them more user-friendly.
   static const char RCSID[] = $Id: emxCreate.jsp.rca 1.13.1.2.1.4 Wed Oct 22 15:48:40 2008 przemek Experimental przemek $ 
--%>
<%@ page import="java.util.*,java.io.*,
                com.matrixone.jdom.*,
                com.matrixone.jdom.output.*,
                com.matrixone.jdom.transform.*,
                 com.matrixone.apps.framework.ui.CharArrayWriterResponse,
                com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@include file = "emxNavigatorInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%@page  import  =  "com.dassault_systemes.smaslm.common.util.MessageServices"%>
<%@ page import="com.matrixone.util.*,
com.matrixone.apps.domain.util.FrameworkUtil,
                java.util.*,
                com.matrixone.jdom.*,
                com.matrixone.jdom.output.*"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<%@ page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle" %>
<!-- Added for IR-339803-3DEXPERIENCER2015x -->
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<jsp:useBean id="createBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<%
// timeStamp to handle the business objectList
String timeStamp = createBean.getTimeStamp();
String form = emxGetParameter(request, "form");
if(UIUtil.isNotNullAndNotEmpty(form)){
    String accessUsers = MqlUtil.mqlCommand(context, "print form $1 select $2 dump", form, "property[AccessUsers].value");
    if(UIUtil.isNotNullAndNotEmpty(accessUsers)) {
        if(!PersonUtil.hasAnyAssignment(context, accessUsers)) {
            return;
        }
    }
}

Vector userRoleList = PersonUtil.getAssignments(context);
String suiteKey = emxGetParameter(request, "suiteKey");

String header    = emxGetParameter(request,"header");
String subHeader = emxGetParameter(request,"subHeader");
String objectId = emxGetParameter(request, "objectId");

// get flag that indicates if launching smaCreate dialog in a slidein
// if we are using a slidein and there is an error...need to close the
// slidein not the top window
String usingSlideIn = emxGetParameter(request, "usingSlideIn");
if (null == usingSlideIn) usingSlideIn = "";

// The objectId , relId from the emxTable.jsp is passd as "emxTableRowId"
String tableRowIdList[] = Request.getParameterValues(request, "emxTableRowId");
String mode = emxGetParameter(request, "mode");
String tableRowId = "";
if (tableRowIdList != null)
{
    tableRowId = tableRowIdList[0];
}

if (tableRowId != null && tableRowId.length() > 0)
{
    objectId = tableRowId.trim(); 
    if(objectId.indexOf("|") != -1)
    {
        StringList objectIdList = FrameworkUtil.split(objectId, "|");
        //objectIdList.size() will be 3 for root node
        if (objectIdList.size() == 3)
        {
           objectId = (String)objectIdList.get(0);
        }
        else
        {
           objectId = (String)objectIdList.get(1);
        }
    }
}

String xsltFile = "emxCreatePage.xsl";
if  ("SMAJob_CreateViewEdit".equals(form))
    xsltFile  =  "smaCreateActivityPage.xsl";

String ua = request.getHeader("user-agent");
String timeZone=(String)session.getAttribute("timeZone");
//Start : IR-044112V6R2011
String sRdoTNR = (String)session.getAttribute("rdoTNR");
//End : IR-044112V6R2011
String isUnix = (ua.toLowerCase().indexOf("x11") > -1)?"true":"false";
boolean flag=false;

HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
requestMap = UINavigatorUtil.appendURLParams(context, requestMap, "Create");
MapList fields=new MapList();
//Code to remove support to toolbar, editLink and portalMode passed as URL parameters.
//This piece of code can be removed if in future the CreateComponent needs to support the same.
String toolbar = (String)requestMap.get("toolbar");
String editLink = (String)requestMap.get("editLink");
String portalMode = (String)requestMap.get("portalMode");
String languageStr = (String)requestMap.get("languageStr");
Locale locale           = new Locale(languageStr);
String settingErrMsg="";
if (toolbar!=null&&!"null".equals(toolbar)&&!"".equals(toolbar)){
        requestMap.remove("toolbar");
}
if (editLink!=null&&!"null".equals(editLink)&&!"".equals(editLink)){
        requestMap.remove("editLink");
}
if (portalMode!=null&&!"null".equals(portalMode)&&!"".equals(portalMode)){
        requestMap.remove("portalMode");
}
//End

if (objectId != null && objectId.length() > 0)
{
	// ignore object id for create host and create host group
	// ignores any selected rows since not used
	if (!"SMAHost_Create".equalsIgnoreCase(form)
			&& !"SMAHostGroup_Create".equalsIgnoreCase(form))
	{
	    requestMap.put("objectId", objectId);
	}
}

//Start : IR-044112V6R2011 - This RDO value which is retrieved from the session will be used by EC
//in order to populate wherever the RDO field is used in create forms.
if(sRdoTNR !=null && sRdoTNR.length()>0){
    requestMap.put("sRdoTNR", sRdoTNR);
}
//End : IR-044112V6R2011
    String typeStr = (String)requestMap.get("type");
    String strtypeChooser=(String)requestMap.get("typeChooser");
 	// Added for IR-339803-3DEXPERIENCER2015x
 	// This allows the RA landing page to be loaded
 	// when a case is created.
    if(typeStr != null && typeStr.length() > 0){
    	if(typeStr.equals(SimulationConstants.SYMBOLIC_type_AnalyticsCase)){
    		if(requestMap.containsKey("submitAction")){
    			requestMap.put("submitAction", "treeContent");
    		}
    	}
    }


    if (
    (typeStr==null||"null".equals(typeStr) || "".equals(typeStr)) && (strtypeChooser==null||"null".equals(strtypeChooser)||"".equals(strtypeChooser)|| "false".equalsIgnoreCase(strtypeChooser)))
    {
        if (form != null && form.length() > 0)
        {
            MapList mapfields=createBean.getFields(context, form, userRoleList);
            Iterator itr=mapfields.iterator();
            while(itr.hasNext())
            {
                HashMap field=(HashMap)itr.next();
                if(createBean.isTypeField(field))
                {
                    flag=true;
                    break;
                }
            }
        }
    }else
    {
        flag=true;
    }
    if(flag)
    {
    try{
    ContextUtil.startTransaction(context,false);
    createBean.setCreateFormData(context, timeStamp, requestMap, userRoleList);
    
    //  Add  timeStamp  from  original  table  so  that  if  it  is  a  
    //  structure  browser,  we  can  use  the  timestamp  to  get  the  selected
    //  row  to  add  the  newly  created  entity  to  it
    Map  formData  =  createBean.getFormData(timeStamp);
    formData.put("timeStamp",  (String)  requestMap.get("timeStamp")  );
    
    fields = createBean.getFormFields(timeStamp);
    settingErrMsg= createBean.checkForUnspportedSetting(fields);
    String localDateFormat = ((java.text.SimpleDateFormat)java.text.DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(), request.getLocale())).toLocalizedPattern();
    String allowKeyableDates = "false";
    try {
        allowKeyableDates = EnoviaResourceBundle.getProperty(context, "emxFramework.AllowKeyableDates");
    } catch(Exception e) {
        allowKeyableDates = "false";
    }
    HashMap inputMap = new HashMap();

    if (form == null || form.length() == 0)
    {
        form = "mxDummyForm";
    }
    inputMap.put("localDateFormat", localDateFormat);
    inputMap.put("allowKeyableDates", allowKeyableDates);
    inputMap.put("timeZone", timeZone);
    inputMap.put("localeObj", request.getLocale());
    inputMap.put("languageStr", (String)requestMap.get("languageStr"));
    inputMap.put("formname",form);
    inputMap.put("pageContext",pageContext);

    Vector contentVector = new Vector();
    Element root = new Element("mxRoot", createBean.XML_NAMESPACE, "http://www.matrixone.com/" + createBean.XML_NAMESPACE);
    Namespace nameSpace = root.getNamespace();
    Map pairs = new HashMap();
    pairs.put("type", "text/xsl");
    pairs.put("href", xsltFile);
    ProcessingInstruction pi = new ProcessingInstruction("xml-stylesheet", pairs);
    contentVector.add(pi);

    //set the root element
    contentVector.add(root);
    Document doc = new Document(contentVector);
    root.addContent(createBean.createSetting("timeStamp",timeStamp, nameSpace));
    root.addContent(createBean.createSetting("isUnix",isUnix,nameSpace));

    String i18strClear = "Clear";
    String i18strApply = "Done";
    String i18strDone = "Done";
    String i18strCancel = "Cancel";
    String i18strNext = "Next";
    String i18strRedFields = "Fields in red italics are required";

    String i18strHeader="";
    String i18strSubHeader="";

    try {
        i18strClear = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", locale,"emxFramework.FormComponent.Clear");
        i18strDone = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",locale,"emxFramework.Common.Done");
        i18strCancel = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",locale,"emxFramework.Button.Cancel");
        i18strApply = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",locale,"emxFramework.Consolidate.Button.Apply");
        i18strNext = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",locale,"emxFramework.Button.Next");
        i18strRedFields = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",locale,"emxFramework.Common.FieldsInRed");

        if(header!=null && !"null".equalsIgnoreCase(header) && !"".equalsIgnoreCase(header))
        {
            i18strHeader = UIForm.getFormHeaderString(context,
                                                 pageContext,
                                                 header,
                                                 null,
                                                 suiteKey,
                                                 languageStr);
            
            //This  is  being  remove  for  IR-061551V6R2011x  -  SCE  objects  
            //create  and  edit  dialogs  header  now  has  the  folder  name  
            //followed  by  a  separator  followed  by  dialog  title  
            
            //Until  Enovia  provides  a  mechanism  to  get  the  parent  object
            //title  instead  of  name  we  will  not  show  the  new  window
            //title  on  the  create  dialogs. 

            //i18strHeader=UIUtil.getWindowTitleName(context,null,objectId,i18strHeader);
        }
        else
        {

            if(typeStr==null || "null".equals(typeStr) || "".equals(typeStr))
            {
                typeStr="";
            }
                else{
                        StringList typeList = FrameworkUtil.split(typeStr, ",");
                        if (typeList.size()>1)
                        {
                            typeStr = (String)typeList.get(0);
                        }
                        if (typeStr.startsWith("_selectedType:"))
                        {
                            String ary[]=typeStr.split("_selectedType:");
                            typeStr=ary[1];
                        }
                    String aliasname=typeStr;
                    try{
                        typeStr=PropertyUtil.getSchemaProperty(context,typeStr);
                    }catch(Exception e){
                        typeStr=aliasname;
                    }
                    if (typeStr==null||"null".equals(typeStr)||"".equals(typeStr))
                    {
                        typeStr=aliasname;
                    }
                }
            i18strHeader = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",locale,"emxFramework.Create.DefaultHeading") + " " + UINavigatorUtil.getAdminI18NString("Type",typeStr ,languageStr);
        }
        if(subHeader!=null && !"null".equalsIgnoreCase(subHeader) && !"".equalsIgnoreCase(subHeader))
        {
            i18strSubHeader = UIForm.getFormHeaderString(context,
                                                 pageContext,
                                                 subHeader,
                                                 null,
                                                 suiteKey,
                                                 languageStr);
        }


    } catch(Exception e) {
        i18strClear = "Clear";
        i18strApply = "Apply";
        i18strDone = "Done";
        i18strCancel = "Cancel";
        i18strNext = "Next";
        i18strRedFields = "Fields in red italics are required";
    }
    root.addContent(createBean.createSetting("clear",i18strClear,nameSpace));
    root.addContent(createBean.createSetting("header",i18strHeader,nameSpace));
    root.addContent(createBean.createSetting("subHeader",i18strSubHeader,nameSpace));
    root.addContent(createBean.createSetting("apply",i18strApply,nameSpace));
    root.addContent(createBean.createSetting("done",i18strDone,nameSpace));
    root.addContent(createBean.createSetting("cancel",i18strCancel,nameSpace));
    root.addContent(createBean.createSetting("next",i18strNext,nameSpace));
    root.addContent(createBean.createSetting("fieldsinred",i18strRedFields,nameSpace));
    //Remove the basic fields from request, to avoid creation of hidden variables on the form.
    requestMap.remove("owner");
    requestMap.remove("vault");
    requestMap.remove("policy");
    requestMap.put("localeObj",request.getLocale().toString());
    requestMap.put("submitMethod",request.getMethod());

    root.addContent(createBean.explodeMap("requestMap", requestMap, nameSpace));
    
  //get emxToolbarJavaScript.jsp response here to avoid server side unnecesary round trip
    CharArrayWriterResponse customResponse  = new CharArrayWriterResponse(response);
 
    StringBuffer toolbarURL = new StringBuffer("emxToolbarJavaScript.jsp?uiType=form&printerFriendly=false&export=false&timeStamp=");
    toolbarURL.append(timeStamp);
    Iterator itr = requestMap.keySet().iterator();
    while (itr.hasNext()) {
        String key = (String)itr.next();
        if (key.equals("timeStamp")) {
            continue;
        }
        String value = "";
        try{
            value = (String)requestMap.get(key);
        }catch(Exception ex){
            String[] values = (String[])requestMap.get(key);
            value = FrameworkUtil.join(values, ",");
        }
        toolbarURL.append("&");
        toolbarURL.append(key);
        toolbarURL.append("=");
        toolbarURL.append(value);
    }
 
    request.getRequestDispatcher(toolbarURL.toString()).include(request, customResponse);
    Element toolbarCode = new Element("toolbarCode");
    toolbarCode.setContent(new CDATA(customResponse.toString()));
    root.addContent(toolbarCode);
 
    // get emxFormConstantsJavascriptInclude.jsp
    customResponse  = new CharArrayWriterResponse(response);
    request.getRequestDispatcher("emxFormConstantsJavascriptInclude.jsp").include(request, customResponse);
    Element formConstantsCode = new Element("formConstants");
    formConstantsCode.setContent(new CDATA(customResponse.toString()));
    root.addContent(formConstantsCode);
    
    // get emxJSValidation.jsp
    customResponse  = new CharArrayWriterResponse(response);
    request.getRequestDispatcher("emxJSValidation.jsp").include(request, customResponse);
    Element JSValidationCode = new Element("JSValidations");
    JSValidationCode.setContent(new CDATA(customResponse.toString()));
    root.addContent(JSValidationCode);
    
    //get columns
    inputMap.put("timeStamp", timeStamp);
    inputMap.put("uiType", "createForm");
    createBean.addFields(context, root, nameSpace, fields, inputMap);
    if (settingErrMsg!=null&&!"null".equals(settingErrMsg)&&!"".equals(settingErrMsg))
    {
       String errorMessage = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",locale,"emxFramework.Create.FieldTypeErrorMessage");
            settingErrMsg=errorMessage+"\\n "+ settingErrMsg;
       Element unsupp = new Element("UnsupportedFieldTypeSetting", root.getNamespace());
       unsupp.addContent(createBean.createSetting("Message",settingErrMsg,nameSpace));
       root.addContent(unsupp);
    }

    StringList incFileList = UIComponent.getCreateJSValidationFileList(context, suiteKey);
    if(incFileList != null && incFileList.size() > 0){
        //add Custom clientside validation includes
        Element custVal = new Element("CustomValidation", root.getNamespace());
        String fileTok = "";
        for(StringItr keyItr = new StringItr(incFileList); keyItr.next();)
        {
            custVal.addContent(createBean.createSetting("file",keyItr.obj(),nameSpace));
        }
        root.addContent(custVal);
    }


    out.clear();
    XSLTransformer transformer = new XSLTransformer(new java.io.File(request.getRealPath("/common"), xsltFile));
    com.matrixone.jdom.output.Format format = com.matrixone.jdom.output.Format.getCompactFormat();
    format.setTextMode(com.matrixone.jdom.output.Format.TextMode.PRESERVE);
    format.setExpandEmptyElements(true);
    format.setOmitDeclaration(true);

    XMLOutputter  outputter = new XMLOutputter(format);
    outputter.output(new DocType("html"), out);
    String outString = outputter.outputString(transformer.transform(doc));
    outString = FrameworkUtil.findAndReplace(outString,"&amp;","&");     
    out.print(outString);   

    /*response.setContentType("text/xml; charset=UTF-8");
    XMLOutputter  outputter = MxXMLUtils.getOutputter();
    outputter.output(doc, out);*/
    //outputter.output(doc, System.out);
    ContextUtil.commitTransaction(context);
    // End: Get Data
} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    String  errMsg  =  ex.toString().trim();
    if  (errMsg  !=  null  &&  errMsg.length()  >  0){
            errMsg  =  MessageServices.massageMessage(errMsg);
            emxNavErrorObject.addMessage(errMsg);
            System.out.println(errMsg);
%>
        <%@include file = "emxNavigatorBottomErrorInclude.inc"%> 
        <script>
            slideIn = "<xss:encodeForJavaScript><%=usingSlideIn%></xss:encodeForJavaScript>";
            if (slideIn.length > 0)
            {
                getTopWindow().closeSlideInDialog();
            }
            else
            {
            	getTopWindow().closeWindow();
            }
            </script>
<%
    }
        }
    }
    else
    {
        String errorMessage = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource",locale,"emxFramework.Create.TypeErrorMessage");
%>
        <script language="JavaScript">
         alert("<%=errorMessage%>");
         slideIn = "<xss:encodeForJavaScript><%=usingSlideIn%></xss:encodeForJavaScript>";
         if (slideIn.length > 0)
         {
             getTopWindow().closeSlideInDialog();
         }
         else
         {
         	getTopWindow().closeWindow();
         }
        </script>
<%
} 
%>
