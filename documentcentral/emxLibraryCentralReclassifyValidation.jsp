<%--  emxLibraryCentralReclassifyValidation.jsp
  Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: This page constructs the frameset to gather search criteria
                                to search for business objects
--%>

<%@include file="../emxUIFramesetUtil.inc" %>
<%@include file = "emxLibraryCentralUtils.inc" %>
<%@ page import="java.util.List,java.util.Map,com.matrixone.apps.library.LibraryCentralCommon" %>
<jsp:useBean id="libraries" class="com.matrixone.apps.library.Libraries" scope="session"/>
<%
    HashMap allowedParentsMap           = (HashMap)LibraryCentralCommon.getAllowedParentsMap(context);
    StringList slAllowedClassifiedTypes =(StringList)LibraryCentralCommon.getAllAllowedClasificationTypes(context);

    String languageStr              = request.getHeader("Accept-Language");
    String sErrorMsg                = "";
    String sClassificationID        = "";
    boolean isAssigned              = false;
    boolean bPurgedType             = false;
    String strClassificationId      = "";
    String[] arrClassificationIds   = new String[]{};
    String emxTableRowIds[]         = (String[]) emxGetParameterValues(request, "emxTableRowId");
    arrClassificationIds            = getTableRowIDsArray(emxTableRowIds);
    sClassificationID               = getTableRowIDsString(emxTableRowIds);
    String baseType                 = "type_GeneralClass";
    libraries.setObjectRowID(arrClassificationIds);
    boolean hasPartType = false;
    boolean hasNonPartType = false;
    if (arrClassificationIds != null && arrClassificationIds.length > 0) {
        for(int iCnt=0 ; iCnt < arrClassificationIds.length ; iCnt++) {
                DomainObject doObj              = new DomainObject(arrClassificationIds[iCnt]);
                String strClassifiedItemType    = doObj.getInfo(context,DomainConstants.SELECT_TYPE);
                String classifiedItemSchemaName = FrameworkUtil.getAliasForAdmin(context, "type", strClassifiedItemType, true);
                baseType                        = (String) allowedParentsMap.get(classifiedItemSchemaName);
                if("type_PurgedRecord".equalsIgnoreCase(classifiedItemSchemaName)) {
                    bPurgedType = true;
                    break;
                }        
                boolean isPartType = doObj.isKindOf(context,PropertyUtil.getSchemaProperty(context,"type_Part"));
                
			    // Changes added by PSA11 start(IR-532424-3DEXPERIENCER2018x).
                /* 'Supplier Equivalent Part(SEP) is not a type of Part'
                   However, since this is a special type which, even not being a Part or type of Part 
				   can be added to a Part Family or a Manufacturturing Part Family, the boolean isPartType 
				   has been forced to be 'true' only in case when more than one BOs are selected for 
				   Reclassify(and in which one of them in an SEP) */
				
                if("type_SupplierEquivalentPart".equalsIgnoreCase(classifiedItemSchemaName) && arrClassificationIds.length > 1){
                	isPartType = true;
                }
                // Changes added by PSA11 end.
				
				hasPartType = hasPartType ||isPartType;
                hasNonPartType = hasNonPartType || !isPartType;
        }
    }
    
    
    
    
    
    if(bPurgedType) {
        sErrorMsg = EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource", new Locale(languageStr),"emxLibraryCentralStringResource.PurgedType.Reclasify.Error.Message");
%>
<script language="javascript">
          alert ("<xss:encodeForJavaScript><%=sErrorMsg%></xss:encodeForJavaScript>");
</script>
<%
    } else  {
        
        String objectId     = emxGetParameter(request, "objectId");
        String fromPage     = emxGetParameter(request, "fromPage");
        if(hasPartType && hasNonPartType) {
            baseType = "type_GeneralClass";
        }
        StringBuffer contentURL          = new StringBuffer("../common/emxFullSearch.jsp?field=TYPES=");  
        contentURL.append(baseType);
        contentURL.append("&formInclusionList=COUNT&selection=single&table=LBCFindObjectsList&showInitialResults=true&");
        contentURL.append("excludeOIDprogram=emxLibraryCentralFindObjects:getReClassifyExcludeOIDs&hideHeader=true&header=emxLibraryCentral.Search.Results&");
        contentURL.append("&objectId=");
        contentURL.append(objectId);
        contentURL.append("&HelpMarker=emxhelpfullsearch&fromPage=");
        contentURL.append(fromPage);
        contentURL.append("&submitURL=../documentcentral/emxMultipleClassificationReclassifyPreProcess.jsp?");
        
        
        
%>      
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript">
      showModalDialog("<xss:encodeForJavaScript><%=contentURL.toString()%></xss:encodeForJavaScript>");
</script>
<%
    }
%>
