<%-- emxComponentSearchRolesDialog.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsAddSkillSearchForward.jsp.rca 1.7 Wed Oct 22 16:17:49 2008 przemek Experimental przemek $ 
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>


<%

String accessUsers = "role_ResourceManager,role_VPLMProjectAdministrator,role_OrganizationManager,role_CompanyRepresentative,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
	return;
}

    com.matrixone.apps.common.Person person = (com.matrixone.apps.common.Person)DomainObject.newInstance(context,
                       DomainConstants.TYPE_PERSON);
  
  
    String objectId = emxGetParameter(request,"objectId");
    String mode	 = emxGetParameter(request,"mode");
    String personId = "";
    StringList nonSelectList = new StringList();
    if (mode!= null && !"".equals(mode) && !"null".equals(mode))  
    {
        if("ResourcePool".equals(mode))
        {
        	int cnt=0;
	        String name = "";
  		    java.util.Enumeration enume = request.getParameterNames();
  	    	System.out.println(request.getParameterNames());
	        for (; enume.hasMoreElements(); )
    	    {
	      		// Get the name of the request parameter
	           	name = (String)enume.nextElement();
              	// If the request parameter can appear more than once in the query string, get all values
              	String[] values = emxGetParameterValues(request, name);
      
          	}
        	String[] strPersonIds = emxGetParameterValues(request, "emxTableRowId");  
        	String strTableRowId = "";
        	StringList slTokens = null;
        	String strPersonId =  null;
	        matrix.util.StringList slSelectedPersonID = new matrix.util.StringList();
	        
        	for (int i = 0; i < strPersonIds.length; i++)
  			{
        		cnt=0;
	  		    strTableRowId = strPersonIds[i];
	  		    if (strTableRowId == null || strTableRowId.length() == 0)
	  		    {
	  		        continue;
	  		    }
	  		   
	  		  slTokens = com.matrixone.apps.domain.util.FrameworkUtil.split(strTableRowId, "|");
              strPersonId = (String) slTokens.get(1);

	    		slSelectedPersonID.add(strPersonId);
  			}
        	personId = com.matrixone.apps.domain.util.FrameworkUtil.join(slSelectedPersonID,",");
        	//Modified:18-Feb-2010:s2e:R209 PRG:IR-032879V6R2011 
        	if(null != personId)
        	{
        	    person.setId(personId);
        	}
            StringList busSelects = new StringList();
            
            busSelects.add(person.SELECT_ID);
            MapList relatedSkills = person.getRelatedObjects(context, "hasBusinessSkill", "*", busSelects, DomainConstants.EMPTY_STRINGLIST, false, true, (short)1, DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
            if(null == relatedSkills){
            	relatedSkills = new MapList();
            }
            for(int i = 0 ; (null != relatedSkills && i<relatedSkills.size()); i++){
                nonSelectList.add( (String) ((Map)relatedSkills.get(i)).get(person.SELECT_ID));
                // Bug 296187 fix, add all parents of current assiged skills to nonSelectList
                getParentSkills(context , nonSelectList,(String)((Map)relatedSkills.get(i)).get(person.SELECT_ID));     
            }
            //End:18-Feb-2010:s2e:R209 PRG:IR-032879V6R2011  
        	
        }
    }    
    else
    {
    person.setId(objectId);
    StringList busSelects = new StringList();
    
    busSelects.add(person.SELECT_ID);
    MapList relatedSkills = person.getRelatedObjects(context, "hasBusinessSkill", "*", busSelects, DomainConstants.EMPTY_STRINGLIST, false, true, (short)1, DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
    for(int i = 0 ; i <relatedSkills.size(); i++){
        nonSelectList.add( (String)((Map)relatedSkills.get(i)).get(person.SELECT_ID));
        // Bug 296187 fix, add all parents of current assiged skills to nonSelectList
        getParentSkills(context , nonSelectList,(String)((Map)relatedSkills.get(i)).get(person.SELECT_ID));     
    }
        personId = objectId;
    }
    if(nonSelectList == null)
    {
        nonSelectList = new StringList();
    }
    session.setAttribute("nonSelectList", nonSelectList);
    String url = "emxComponentsBusinessSkillSearchFS.jsp?multiSelect=true&objectId=" + objectId + "&mainSearchPage=emxComponentsBusinessSkillSearchFS.jsp&targetSearchPage=emxComponentsBusinessSkillSearchResultsFS.jsp&personId="+ personId +"&mode="+mode;
    response.sendRedirect(url);

%>

<%!
    public void getParentSkills(Context context,StringList nonSelectList, String objectId)
    {
        try
        {
          boolean flag=true;
          DomainObject domChildObject = new DomainObject(objectId);
          String parentObjectId= domChildObject .getInfo(context,"to["+PropertyUtil.getSchemaProperty(context,"relationship_SubSkill")+"].from."+DomainConstants.SELECT_ID);
    
          DomainObject domParentObject = new DomainObject(parentObjectId);
         
          StringList busSelects = new StringList();
          busSelects.add(DomainConstants.SELECT_ID);
  
          MapList childFromParentList = domParentObject.getRelatedObjects(context, PropertyUtil.getSchemaProperty(context,"relationship_SubSkill"), PropertyUtil.getSchemaProperty(context,"type_BusinessSkill"), busSelects, DomainConstants.EMPTY_STRINGLIST, false, true, (short)1, DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING );
                 
          Iterator childFromParentItr = childFromParentList.iterator();
          while(childFromParentItr.hasNext())
          {
            Map childFromParent =(Map)childFromParentItr.next();
            String childObjectId = (String) childFromParent.get(DomainConstants.SELECT_ID);
            if(!nonSelectList.contains(childObjectId))
            {
              flag=false;
              break;
            }
            
          }
          
          if(flag)
          {
            nonSelectList.add(parentObjectId);
            getParentSkills(context,nonSelectList,parentObjectId);
          }
          
        }
        catch(Exception e)
        {
          e.toString();
        }
    }  
%>

