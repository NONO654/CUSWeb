<%-- emxFreezePaneExport.jsp
Copyright (c) 1992-2018 Dassault Systemes.
All Rights Reserved.
This program contains proprietary and trade secret information of MatrixOne,Inc.
Copyright notice is precautionary only
and does not evidence any actual or intended publication of such program

static const char RCSID[] = $Id: emxFreezePaneExport.jsp.rca 1.15 Wed Oct 22 15:49:01 2008 przemek Experimental przemek $
--%>

<%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers"%>

<%@ page import = "matrix.db.*, matrix.util.*,com.matrixone.servlet.*,com.matrixone.apps.framework.ui.*,com.matrixone.apps.domain.util.*, com.matrixone.apps.domain.*, java.io.*, java.util.*" errorPage="emxNavigatorErrorPage.jsp"%>
<%@include file = "../emxTagLibInclude.inc"%>
<emxUtil:localize id="i18nId" bundle="emxFrameworkStringResource" locale='<xss:encodeForHTMLAttribute><%= request.getHeader("Accept-Language") %></xss:encodeForHTMLAttribute>' />
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="structureCompareBean" class="com.matrixone.apps.framework.ui.UIStructureCompare" scope="session"/>
<%
String isStructureCompare = Request.getParameter(request, "IsStructureCompare");
if ( "TRUE".equalsIgnoreCase(isStructureCompare)){
	indentedTableBean = (com.matrixone.apps.framework.ui.UIStructureCompare)structureCompareBean;
}
if (!Framework.isLoggedIn(request))
{
 String loginPage = Framework.getPropertyValue("ematrix.login.page");
 %> <jsp:forward page ="<%=loginPage%>"/> <%
}

//Context initialization
matrix.db.Context context = Framework.getFrameContext(session);
//Byte Order Mark for UTF-8. Used to recognize file encoding while opening the file
final String BOM_UTF8 = "\ufeff";
boolean isIE = EnoviaBrowserUtility.is(request,Browsers.IE);
boolean isMoz = EnoviaBrowserUtility.is(request,Browsers.MOZILLAFAMILY);
boolean isEdge = EnoviaBrowserUtility.is(request,Browsers.EDGE);

String timeStamp = Request.getParameter(request, "timeStamp");
String rowIds = Request.getParameter(request, "rowIds");
String strGroupingRows = Request.getParameter(request, "bGroupingRows");
boolean bGroupingRows = false;
if(strGroupingRows.equalsIgnoreCase("true")){
	bGroupingRows = true;
}
String[] groupData = null;
int[] groupRowIndex = null;
String exportFormat = Request.getParameter(request, "exportFormat");
String sbMode= Request.getParameter(request, "sbMode");
String csvData = "";
if(!exportFormat.equals("HTML")) {
	if(bGroupingRows){
		String tempGroupData = Request.getParameter(request, "groupData");
		StringTokenizer strTkns1 = new StringTokenizer(tempGroupData,",");
		groupData = new String[strTkns1.countTokens()];
		int i=0;
		while(strTkns1.hasMoreTokens()){
			groupData[i++] = strTkns1.nextToken();
		}
		
		String tempGroupRowIndex = Request.getParameter(request, "groupRowIndex");
		StringTokenizer strTkns2 = new StringTokenizer(tempGroupRowIndex,",");
		groupRowIndex = new int[strTkns2.countTokens()];
		i=0;
		while(strTkns2.hasMoreTokens()){
			groupRowIndex[i++] = Integer.parseInt(strTkns2.nextToken());
		}
	}
	csvData = indentedTableBean.getCSVData(context,timeStamp,rowIds, sbMode, groupRowIndex, groupData,bGroupingRows);
}else{
	csvData = Request.getParameter(request, "csvData");
}
csvData = FrameworkUtil.findAndReplace(csvData,"&amp;","&");
csvData = FrameworkUtil.findAndReplace(csvData,"&lt;","<");
csvData = FrameworkUtil.findAndReplace(csvData,"&gt;",">");
csvData = FrameworkUtil.findAndReplace(csvData,"0x08"," ");

String fileEncodeType = request.getCharacterEncoding();
if ("".equals(fileEncodeType) || fileEncodeType == null || fileEncodeType == "null"){
	fileEncodeType=UINavigatorUtil.getFileEncoding(context, request);
}

String fieldSeparator = PersonUtil.getFieldSeparator(context);
String recordSeparator = PersonUtil.getRecordSeparator(context);
String scarriageReturn = PersonUtil.getRemoveCarriageReturns(context);

try
{
    if (exportFormat == null || exportFormat.trim().length() == 0)
    {
        exportFormat = EnoviaResourceBundle.getProperty(context, "emxFramework.Preferences.ExportFormat.Default");
        if (exportFormat == null || exportFormat.trim().length() == 0)
        {
          exportFormat = "CSV";
        }
    }

    HashMap tableData = indentedTableBean.getTableData(timeStamp);
    HashMap tableControlMap = indentedTableBean.getControlMap(tableData);
    String header =indentedTableBean.getPageHeader(tableControlMap);
    //START---for table subheader display 
    String languageStr = request.getHeader("Accept-Language");
    HashMap requestMap=indentedTableBean.getRequestMap(tableData);
    String subHeader = Request.getParameter(request,"subHeader");
    if(!(subHeader == null || "null".equalsIgnoreCase(subHeader))){
       requestMap.put("subHeader", subHeader);
       tableControlMap.put("subHeader", subHeader);
    }
    String subHeaderLabel=(String)requestMap.get("subHeader");
    String suiteKey = (String)requestMap.get("suiteKey");
    String objectId = (String)requestMap.get("objectId");
    //END---for table subheader display 
    
   
    String badChars=":><[]|*/\\; ";
    char[] charArray=badChars.toCharArray();
    char repchar='_';
    header=replaceCharacters(header, charArray, repchar);
    String fileCreateTimeStamp =  Long.toString(System.currentTimeMillis());
    StringBuffer filename = new StringBuffer(50);   

    if (exportFormat.equals("HTML"))
    {
    	csvData = FrameworkUtil.findAndReplace(csvData, "N:eW:Li:nE", "<br/>");
    	csvData = FrameworkUtil.findAndReplace(csvData, "Â", "");
    	
        filename.append(header);
        filename.append(fileCreateTimeStamp);
        filename.append(".html");
        response.setContentType("text/xlshtml; charset="+fileEncodeType);
        String tempname = filename.toString();
        filename = new StringBuffer(50);
        filename.append(FrameworkUtil.encodeURL(tempname,"UTF8"));
        response.setHeader ("Content-Disposition","attachment; filename=\"" + filename.toString() +"\"");
        response.setLocale(request.getLocale());
    } else if(exportFormat.equals("CSV")) {
    	StringBuffer formattedExpData=new StringBuffer();
        String record;
    	recordSeparator = "\r\n";
    	if (fieldSeparator != null)	{
    		fieldSeparator=getCharacterValue(fieldSeparator);
    	} else {
    		fieldSeparator=",";
		}
		StringTokenizer st1 = new StringTokenizer(csvData,"\n");
        String formattedRecord = "";
    	while (st1.hasMoreTokens()){
    		record = st1.nextToken().trim();
    				
			if(record.indexOf('\r') != -1){
    	    	StringList recordList = FrameworkUtil.split(record, ",");
    	        record = "";
    	        for (int itr = 0; itr < recordList.size(); itr++){
    	        	String tempRecord = (String)recordList.get(itr);
    	            if (tempRecord != null && tempRecord.indexOf("\"=") != -1 && tempRecord.indexOf('\r') != -1){
    	                        tempRecord = tempRecord.substring(3, tempRecord.length() - 2);
    	                    }

					if (record!=null && record.length() == 0){
    	            	record = tempRecord;
					} else{
    	            	 record = record + "," + tempRecord;
    	            }
				}
			}

			record = FrameworkUtil.findAndReplace(record,"\r"," ");
    	    record = FrameworkUtil.findAndReplace(record,",",fieldSeparator);
    			   
			if(record.endsWith("\",")) {
    			formattedRecord = record;
			}else {
    	    	formattedRecord = FrameworkUtil.findAndReplace(record, ",", fieldSeparator+"");
			}
    			   
			if(formattedRecord.endsWith(",")) {
    	    	formattedRecord = formattedRecord.substring(0, formattedRecord.length() - 1) + fieldSeparator;
			}
    		
			//START---for table subheader display 
			if ( (subHeaderLabel != null) && (subHeaderLabel.trim().length() > 0) ){
    	    	if(formattedRecord.equalsIgnoreCase(subHeaderLabel)){
    	        	String subHeaderValue=UINavigatorUtil.parseHeader(context, pageContext, subHeaderLabel, objectId, suiteKey, languageStr);
    	        	formattedRecord=subHeaderValue;
				} 
			}
    	    //END---for table subheader display 
    	    formattedExpData.append(formattedRecord);   
    	    formattedExpData.append(recordSeparator);

		}
    			
		if (isIE){
    		response.setContentType("text/plain; charset="+fileEncodeType);
    	} else {
    		response.setContentType("application/csv; charset="+fileEncodeType);
		}
    				
		filename = new StringBuffer(50);
    	filename.append(header);
    	filename.append(fileCreateTimeStamp);
    	filename.append(".csv");
    				
    	String tempname = filename.toString();
    	filename = new StringBuffer(50);
    	if (!isMoz || isEdge){
    		filename.append(FrameworkUtil.encodeURL(tempname,"UTF-8"));
    	} else {
    		filename.append("=?UTF-8?B?" + new String(FrameworkUtil.encodeBase64(tempname.getBytes("UTF-8"),false), "UTF-8") + "?=");                
    	}
    	response.setHeader ("Content-Disposition","attachment; filename=\"" + filename.toString() +"\"");
    	response.setLocale(request.getLocale());
    	csvData = formattedExpData.toString();
    	csvData = FrameworkUtil.findAndReplace(csvData, "<M:yN:ewLine>","\n");
    	csvData = FrameworkUtil.findAndReplace(csvData, "N:Com:Sep", ",");
    	csvData = FrameworkUtil.findAndReplace(csvData, "N:SemiCol:Sep", ";");
    } else {

        StringBuffer formattedExpData=new StringBuffer();
        if (exportFormat.equals("CSV"))
        {
            recordSeparator = "\r\n";            
        }
        String sRecordSepPropValue = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Preferences.FieldSeparator.New_Line", request.getLocale());
            if (recordSeparator == null
                    || recordSeparator.trim().length() == 0
                    || recordSeparator.equalsIgnoreCase(sRecordSepPropValue))
            {
                recordSeparator = "\r\n";
            }

             if (fieldSeparator != null)
             {
                fieldSeparator=getCharacterValue(fieldSeparator);
             } else {
                 fieldSeparator=",";
             }
        

        //csvData = FrameworkUtil.findAndReplace(csvData, "\n", "<M:yN:ewLine>");
        csvData = FrameworkUtil.findAndReplace(csvData, "N:eW:Li:nE", "\n");
        StringTokenizer st1 = new StringTokenizer(csvData,"\n");
        String record;
        String sQuotes = "";

        String formattedRecord = "";
        while (st1.hasMoreTokens())
        {
           record = st1.nextToken().trim();
	       if(record.indexOf("/") != -1)
     	    { 
	   		 StringList recList = FrameworkUtil.split(record, ",");
             for(int itr=0;itr<recList.size();itr++)
              {
			   	String recListItem = recList.get(itr).toString();
               	if(recListItem.contains("/") && !((recListItem.startsWith("\"")) || (recListItem.startsWith("=\"")))){
           	  		record = record.replaceAll(recListItem,"=\""+recListItem+"\"\r");                       
				}
              }
      		 }
           if(record.indexOf('\r') != -1 && "CSV".equals(exportFormat))
           {
               StringList recordList = FrameworkUtil.split(record, ",");
               StringBuffer sb = new StringBuffer();
               for (int itr = 0; itr < recordList.size(); itr++)
               {
                    String tempRecord = (String)recordList.get(itr);
                    if (tempRecord != null && tempRecord.indexOf("\"=") != -1 && tempRecord.indexOf('\r') != -1)
                    {
                        tempRecord = tempRecord.substring(3, tempRecord.length() - 2);
                    }

                    if (sb.length()==0)
                    {
                        sb.append(tempRecord);
                    }
                    else
                    {
                        sb.append(",");
                        sb.append(tempRecord);
                    }
               }
               record = sb.toString();
           }
           record = FrameworkUtil.findAndReplace(record, "N:Com:Sep", ",");

           if(record.indexOf("<M:yN:ewLine>") != -1) {
               record = FrameworkUtil.findAndReplace(record, "<M:yN:ewLine>", "\n");
           }
           if("CSV".equals(exportFormat)) {
                record = record.replace('\r', ' ');
                record = record.replace(",", fieldSeparator);
           }
             if("Text".equals(exportFormat)&& "Yes".equals(scarriageReturn)) {
               recordSeparator = recordSeparator.replace("\r", "");
           }
           if(record.endsWith("\",")) {
                if (exportFormat.equalsIgnoreCase("Text")) {
                    if (record.endsWith("\"\"\","))
                    {
                        record = record.substring(0, record.length()-3) + fieldSeparator;
                    }
                    formattedRecord = FrameworkUtil.findAndReplace(record, ",\"=\"\"", fieldSeparator);
                    formattedRecord = FrameworkUtil.findAndReplace(formattedRecord, ",\"", fieldSeparator);
                    formattedRecord = FrameworkUtil.findAndReplace(formattedRecord, "\"\"" + fieldSeparator, fieldSeparator);
                    formattedRecord = FrameworkUtil.findAndReplace(formattedRecord, "\"\"", "\"");
                    if("Yes".equals(scarriageReturn)) {
                        formattedRecord = formattedRecord.replace('\n', ' ');
                        formattedRecord = formattedRecord.replace('\r', ' ');
                    }
                }
                else {
                    formattedRecord = record;
                }
           }
           else {
                formattedRecord = FrameworkUtil.findAndReplace(record, ",", fieldSeparator+"");
           }

           if(formattedRecord.endsWith(",")) {
            formattedRecord = formattedRecord.substring(0, formattedRecord.length() - 1) + fieldSeparator;
           }
   
           //START---for table subheader display 
          if ( (subHeaderLabel != null) && (subHeaderLabel.trim().length() > 0) )
          {
              
               if(formattedRecord.equalsIgnoreCase(subHeaderLabel))
                {
                String subHeaderValue=UINavigatorUtil.parseHeader(context, pageContext, subHeaderLabel, objectId, suiteKey, languageStr);
                formattedRecord=subHeaderValue;
                } 
           }
           //END---for table subheader display 
           formattedExpData.append(formattedRecord);   
           formattedExpData.append(recordSeparator);
        }

        if ( exportFormat.equals("Text"))
        {
             response.setContentType("text/plain; charset=UTF-8");
             filename = new StringBuffer(50);
             filename.append(header);
             filename.append(fileCreateTimeStamp);
             filename.append(".txt");
        }
        else
        {
            if (isIE)
            {
                response.setContentType("text/plain; charset="+fileEncodeType);
            } else {
                response.setContentType("application/csv; charset="+fileEncodeType);
            }
            filename = new StringBuffer(50);
            filename.append(header);
            filename.append(fileCreateTimeStamp);
            filename.append(".csv");
        }
        String tempname = filename.toString();
        filename = new StringBuffer(50);
        if (isIE || isEdge)
        {
            filename.append(FrameworkUtil.encodeURL(tempname,"UTF-8"));
        } else {
            filename.append("=?UTF-8?B?" + new String(FrameworkUtil.encodeBase64(tempname.getBytes("UTF-8"),false), "UTF-8") + "?=");                
        }
        response.setHeader ("Content-Disposition","attachment; filename=\"" + filename.toString() +"\"");
        response.setLocale(request.getLocale());
        csvData = formattedExpData.toString();
    }
  out.clear();
  if(exportFormat.equals("HTML") || exportFormat.equals("CSV")){
		out.print(BOM_UTF8 + csvData);
	  }else{
  out.print(csvData);
	  }  


} catch (Exception ex) {
    ex.printStackTrace();
}
%>


<%!
static public String replaceCharacters(String source, char[] charList, char replacementChar)
{
  String retString = source;
  if(retString==null)
  {
    retString="";
  }
  if(charList !=null && charList.length>0 )
  {
       for (int index = 0; index < charList.length; index++)
         {
            char sElement = charList[index];
            retString=retString.replace(sElement,replacementChar);
         }

    }

return retString;

}
%>

<%!
static public String getCharacterValue(String strValue)
{
if(strValue==null || strValue.length() == 0){
    return "";
}else{
    if ( strValue.equalsIgnoreCase("Pipe") ){
        strValue = "|";
    }else if ( strValue.equalsIgnoreCase("Comma") ){
        strValue = ",";
    }else if ( strValue.equalsIgnoreCase("Tab") ){
        strValue = "\t";
    }else if ( strValue.equalsIgnoreCase("Semicolon") ){
        strValue = ";";
    }
}

return strValue;
}

%>

