<%--  emxComponentsAddExistingPersonProcess.jsp   -   connect people to Company

   Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxComponentsPersonAddSkillProcess.jsp.rca 1.7 Wed Oct 22 16:18:34 2008 przemek Experimental przemek $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
    //import com.matrixone.apps.common.*;
    DomainObject orgObj = DomainObject.newInstance(context);
    DomainObject personObj = DomainObject.newInstance(context);

    String personId = emxGetParameter(request,"personId");
    String mode = emxGetParameter(request,"mode");

    String selectedSkills[] = emxGetParameterValues(request, "businessSkills");
    String competency[] = emxGetParameterValues(request, "Competency");
    String experience[] = emxGetParameterValues(request, "Experience");

    matrix.util.StringList slPersonIds = new matrix.util.StringList();
    if("ResourcePool".equals(mode))
    {
      slPersonIds = com.matrixone.apps.domain.util.FrameworkUtil.split(personId, ",");
    }
    else
    {
      slPersonIds.add(personId);
    }

    String sRelHasBusinessSkill  = PropertyUtil.getSchemaProperty(context, "relationship_hasBusinessSkill" );
    String sAttrCompetency = PropertyUtil.getSchemaProperty(context,"attribute_Competency");
    String sAttrExperience = PropertyUtil.getSchemaProperty(context,"attribute_Experience");
    Map attribMap = null;
    DomainObject objSkill = null;
    String sCompetency = "";
    String sExperience = "";
    String sBusinessSkillId = "";
    DomainRelationship newRel = null;
    DomainObject dmoObject = null;
    boolean flag = false;
    final String SELECT_BUSINESS_SKILL_ID = "from["+sRelHasBusinessSkill+"].to.id";
    String strTypePattern = com.matrixone.apps.domain.DomainConstants.TYPE_BUSINESS_SKILL;
    boolean getTo = false;
    boolean getFrom = true;
    matrix.util.StringList slBusSelect = new matrix.util.StringList();
    slBusSelect.add(com.matrixone.apps.domain.DomainConstants.SELECT_ID);
    slBusSelect.add(SELECT_BUSINESS_SKILL_ID);
    matrix.util.StringList slRelSelect = new matrix.util.StringList();
    short recurseToLevel = 1;
    String strBusWhere = "";
    String strRelWhere = "";
    com.matrixone.apps.domain.util.MapList mlPersonSelectable = null;
    boolean isSkillAlreadyExists = false; 
    for(int index =0; index<slPersonIds.size(); index++)
    {
        personId = (String)slPersonIds.get(index);  
        for (int i = 0; i < selectedSkills.length; i++) 
        {
            try
            {
                sCompetency = competency[i];
                sExperience = experience[i];
                sBusinessSkillId = selectedSkills[i];
                objSkill = new DomainObject(sBusinessSkillId);
                flag = false;
                isSkillAlreadyExists = false; 
                try
                {
                    dmoObject = DomainObject.newInstance(context, personId);
                    mlPersonSelectable = dmoObject.getRelatedObjects(context,
                                                                      sRelHasBusinessSkill, //pattern to match relationships
                                                                      strTypePattern, //pattern to match types
                                                                      slBusSelect, //the eMatrix StringList object that holds the list of select statement pertaining to Business Obejcts.
                                                                      slRelSelect, //the eMatrix StringList object that holds the list of select statement pertaining to Relationships.
                                                                      getTo, //get To relationships
                                                                      getFrom, //get From relationships
                                                                      recurseToLevel, //the number of levels to expand, 0 equals expand all.
                                                                      strBusWhere, //where clause to apply to objects, can be empty ""
                                                                      strRelWhere); //where clause to apply to relationship, can be empty ""
                    java.util.Map mapPesonSelectable = null;    
                    Object objValue = null;
                    String strValue = "";
                    matrix.util.StringList slValue = null;
                    for (Iterator itrResourcePools = mlPersonSelectable.iterator(); itrResourcePools.hasNext();) 
                    {
                        mapPesonSelectable = (Map) itrResourcePools.next();
                        objValue = mapPesonSelectable.get(com.matrixone.apps.domain.DomainConstants.SELECT_ID);
                        if (objValue != null) 
                        {
                            if (objValue instanceof String) 
                            {
                                strValue = (String)objValue;
                                isSkillAlreadyExists = strValue.equals(sBusinessSkillId);
                            }
                            else if (objValue instanceof StringList) 
                            {
                                slValue = (matrix.util.StringList)objValue;
                                isSkillAlreadyExists = slValue.contains(sBusinessSkillId);
                            }
                        }
                    }
                    if(!isSkillAlreadyExists)
                    {
                        ContextUtil.pushContext(context);
                        flag = true;
                        newRel = objSkill.connect(context, sRelHasBusinessSkill, DomainObject.newInstance(context, personId), true);
                        attribMap = new HashMap();
                        attribMap.put(sAttrCompetency, sCompetency);
                        attribMap.put(sAttrExperience, sExperience);
                        newRel.setAttributeValues(context, attribMap);
                    }
                } 
                catch (Exception e)
                {
                    e.printStackTrace();
                    throw new FrameworkException(e);
                }
                finally
                {
                    if(flag)
                    {
                        ContextUtil.popContext(context);
                    }
                }
            }
            catch(Exception e)
            {
                session.putValue("error.message", e.getMessage());
            }
        }
    }

%>
<script language="javascript">
      parent.window.getWindowOpener().location.href=parent.window.getWindowOpener().location.href;
      window.closeWindow();
</script>
<%@include file = "emxComponentsDesignBottomInclude.inc"%>
