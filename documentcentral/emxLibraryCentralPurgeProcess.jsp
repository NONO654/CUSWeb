<%--emxLibraryCentralPurgeProcess.jsp
    Copyright (c) 1992-2016 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of
    MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any
    actual or intended publication of such program

    Description: Purge the Selected Documents those satisfies the Purge Conditions
    Parameters : ObjectId-parent objectId


    Author     : Deepika
    Date       : 02/25/2007
    History    :

    static const char RCSID[] = $Id: emxLibraryCentralPurgeProcess.jsp.rca 1.5.1.4 Wed Oct 22 16:02:46 2008 przemek Experimental przemek $;
    --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>


<jsp:useBean id="validateRetentionBean" scope="session" class="com.matrixone.apps.library.RetentionRecord"/>
<emxUtil:localize id="i18nId" bundle="emxLibraryCentralStringResource" 
    locale='<%= request.getHeader("Accept-Language") %>'/>

<%
    
    Vector vecObjectIds = new Vector();
    String childIds []   = emxGetParameterValues(request,"emxTableRowId");

    StringList DocName=new StringList();
    StringList purgedRecords = new StringList();
    String sId="";
    String typePurgedRecord = Framework.getPropertyValue(session, "type_PurgedRecord");
    
    if(childIds!= null)
    {
            String DocId[]=new String[childIds.length];

            for(int i=0;i<childIds.length;i++)
            {

                sId=childIds[i].substring(childIds[i].indexOf("|")+1,childIds[i].length());
                sId=sId.substring(0,sId.indexOf("|"));
                String[] arguments= new String[2];

                arguments[0]=sId;
                DomainObject dobDoc=new DomainObject(sId);
                StringList objectSelects = new StringList();
                objectSelects.add(DomainObject.SELECT_NAME);
                objectSelects.add(DomainObject.SELECT_TYPE);
                
                Map docInfo = (Map)dobDoc.getInfo(context,objectSelects);
                String strNameDoc = (String)docInfo.get(DomainObject.SELECT_NAME);
                String strTypeDoc = (String)docInfo.get(DomainObject.SELECT_TYPE);
                
                if(strTypeDoc.equals(typePurgedRecord)){
                    // selected purged records can not be purged once again
                    purgedRecords.addElement(strNameDoc);
                }else{
                    /* Calling the "validatePurgerecord" method of Bean.
                    "strValidatePurge" variable will be "true" if the document is eligible for Purge
                    otherwise it will be false. */

                    boolean strValidatePurge =  validateRetentionBean.validatePurgeRecord(context,arguments);
                
                    // If strValidatePurge is false then store all the Document names that
                    //are not eligible for Purge in DocName List.
    
                    if(strValidatePurge==false)
                    {
                        DocName.addElement(strNameDoc);
    
                    }
                }

            }//End of For

            if(purgedRecords.size()>0 || DocName.size()>0){
            %>
                <script language="javascript" type="text/javaScript">
                    var errorMessage="";
                    
                    <%if(purgedRecords.size()>0){%>
                        errorMessage += "<emxUtil:i18nScript localize = "i18nId">emxLibraryCentral.Purge.PurgedRecordsNotPurged</emxUtil:i18nScript>";                   
                        errorMessage += "\n <xss:encodeForJavaScript><%=purgedRecords%></xss:encodeForJavaScript>\n\n";
                    <%}
                    if(DocName.size()>0){%>
                        errorMessage += "<emxUtil:i18nScript localize = "i18nId">emxLibraryCentral.Purge.RetentionDocuments</emxUtil:i18nScript>";                   
                        errorMessage += "\n <xss:encodeForJavaScript><%=DocName%></xss:encodeForJavaScript>";
                        errorMessage += "\n - <emxUtil:i18nScript localize = "i18nId">emxLibraryCentral.Purge.RetentionDateNotReached</emxUtil:i18nScript>";
                        errorMessage += "\n - <emxUtil:i18nScript localize = "i18nId">emxLibraryCentral.Purge.RetentionHoldNotInReleased</emxUtil:i18nScript>";
                            errorMessage += "\n - <emxUtil:i18nScript localize = "i18nId">emxLibraryCentral.Purge.NoAccessToPurge</emxUtil:i18nScript>";
                    <%}%>
                    alert(errorMessage);
                </script>

            <%  }
    
}//End of IF

%>
<script language="javascript" type="text/javaScript">
    try{
<%
        int iSize = vecObjectIds.size();
        for (int i = 0; i < iSize; ++i) {
%>
            var childId     = '<xss:encodeForJavaScript><%=(String)vecObjectIds.elementAt(i)%></xss:encodeForJavaScript>';
            getTopWindow().deleteObjectFromTrees(childId,true);
<%
        }
%>
         getTopWindow().refreshTrees();
         //getTopWindow().refreshTablePage();
    }catch(exec){
    }
</script>
