<%--  emxComponentsLocationsDelete.jsp   - This code is to delete the Locations
      Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
      This program contains proprietary and trade secret information of MatrixOne,Inc.
      Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxComponentsLocationsDelete.jsp.rca 1.5 Wed Oct 22 16:17:54 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
String accessUsers = "role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

    int fromDisconnectAccessNumber    = (new Integer((String)AccessUtil._accessBits.get("fromdisconnect"))).intValue();
    boolean hasFromDisconnectAccess   = true;
    int toDisconnectAccessNumber      = (new Integer((String)AccessUtil._accessBits.get("todisconnect"))).intValue();
    boolean hasToDisconnectAccess     = true;
  
    String languageStr  = request.getHeader("Accept-Language");

    DomainObject location = DomainObject.newInstance(context);

    String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");  
  
    StringBuffer strBufLocationIdsDeleted = new StringBuffer();
    StringBuffer strBufLocationNames = new StringBuffer();
  
    RelationshipType relType = null;
    RelationshipTypeList relTypeList = null;
    String strRelName = "";
  
    StringList strListFromBusIds  = null;
    StringList strListToBusIds    = null;
  
    int relListSize = 0;
    int listSize = 0;
  
    String strLocationName = "";
    DomainObject domObj = null;
  
    if(checkBoxId != null )
    {
        StringTokenizer st = null;
        String sRelId = "";
        String sObjId = "";
        
        for(int k=0;k<checkBoxId.length;k++)
        {
            if(checkBoxId[k].indexOf("|") != -1)
            {
                st = new StringTokenizer(checkBoxId[k], "|");
                sRelId = st.nextToken();
                sObjId = st.nextToken();
            }
            else
            {
                sObjId = checkBoxId[k];
            }

            location.setId(sObjId);

            strLocationName = location.getInfo(context,DomainObject.SELECT_NAME);

            hasFromDisconnectAccess = true;
            hasToDisconnectAccess = true;

            // getting all the relationships where Location is on the From and To side
            relTypeList = location.getBusinessType(context).getRelationshipTypes(context,true,true,false);
            if(relTypeList != null && (relListSize = relTypeList.size()) > 0 )
            {
                for( int count = 0 ; count < relListSize ; count++)
                {
                    relType = (RelationshipType)relTypeList.get(count);
                    strRelName = relType.getName();

                    strListFromBusIds = location.getInfoList(context,"relationship["+strRelName+"].from.id");
                    if(strListFromBusIds != null && (listSize = strListFromBusIds.size()) > 0)
                    {
                        for(int i = 0 ; i < listSize ; i++)
                        {
                            domObj = new DomainObject(strListFromBusIds.get(i).toString());
                            if(!domObj.checkAccess(context,(short)fromDisconnectAccessNumber))
                            {
                                hasFromDisconnectAccess = false;
                                break;
                            }
                        }

                        if(!hasFromDisconnectAccess)
                        {
                            break;
                        }
                    }

                    strListToBusIds = location.getInfoList(context,"relationship["+strRelName+"].to.id");
                    if(strListToBusIds != null && (listSize = strListToBusIds.size()) > 0)
                    {
                        for(int i = 0 ; i < listSize ; i++)
                        {
                            domObj = new DomainObject(strListToBusIds.get(i).toString());
                            if(!domObj.checkAccess(context,(short)toDisconnectAccessNumber))
                            {
                                hasToDisconnectAccess = false;
                                break;
                            }
                        }
                        if(!hasToDisconnectAccess)
                        {
                            break;
                        }
                    }
                }
            }

            if(!hasFromDisconnectAccess || !hasToDisconnectAccess)
            {
                if(strBufLocationNames.length() > 0)
                {
                    strBufLocationNames.append(", ");
                }
                strBufLocationNames.append(strLocationName);
                continue;
            }

            strBufLocationIdsDeleted.append(sObjId);
            strBufLocationIdsDeleted.append(";");
            location.deleteObject(context);
        }
    }

    if(strBufLocationNames.length() > 0)
    {
        StringBuffer strBufMessage = new StringBuffer();
        strBufMessage.append(EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.LocationsDelete.DeleteMessage1"));
        strBufMessage.append(" '");
        strBufMessage.append(strBufLocationNames.toString());
        strBufMessage.append("' ");
        strBufMessage.append(EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.LocationsDelete.DeleteMessage2"));
        
        MqlUtil.mqlCommand(context,"error $1 ",strBufMessage.toString());
    }
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<script language="Javascript">
  var tree = parent.getTopWindow().objDetailsTree;
  if(tree != null && tree.root != null)
  {
<%
  StringTokenizer sLocationIdsToken = new StringTokenizer(strBufLocationIdsDeleted.toString(),";",false);
  String strLocationId = "";
  while (sLocationIdsToken.hasMoreTokens()) 
  {
    strLocationId = sLocationIdsToken.nextToken();
%>
    tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, strLocationId)%>");
<%
  }
%>
  }
  parent.location.href = parent.location.href;
</script>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
