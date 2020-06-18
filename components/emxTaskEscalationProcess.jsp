<%--
  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%
    String taskAssigneePlusorMinus   = (String) emxGetParameter(request, "TaskAssigneePlusorMinus");
    String taskAssigneeDays          = (String) emxGetParameter(request, "TaskAssigneeDays");
    String taskAssigneeHours         = (String) emxGetParameter(request, "TaskAssigneeHours");

    String routeOwnerPlusorMinus     = (String) emxGetParameter(request, "RouteOwnerPlusorMinus");
    String routeOwnerDays            = (String) emxGetParameter(request, "RouteOwnerDays");
    String routeOwnerHours           = (String) emxGetParameter(request, "RouteOwnerHours");

    String workspaceLeadsPlusorMinus   = (String) emxGetParameter(request, "WorkspaceLeadsPlusorMinus");
    String workspaceLeadsDays          = (String) emxGetParameter(request, "WorkspaceLeadsDays");
    String workspaceLeadsHours         = (String) emxGetParameter(request, "WorkspaceLeadsHours");

    String projectLeadsPlusorMinus   = (String) emxGetParameter(request, "ProjectLeadsPlusorMinus");
    String projectLeadsDays          = (String) emxGetParameter(request, "ProjectLeadsDays");
    String projectLeadsHours         = (String) emxGetParameter(request, "ProjectLeadsHours");

    String objectId      = (String) emxGetParameter(request, "objectId");
  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
%>

 <html>
  <body>
  <script language="javascript">
  <%
        try{
                MapList finalMapList  = new MapList();
                DomainObject route = DomainObject.newInstance(context);
                String sRouteIds=emxGetParameter(request,"routeIds");

                Vector routes = new Vector();
                if( (sRouteIds != null) && (!sRouteIds.equals("")) ){
                        StringTokenizer stToken   = new StringTokenizer(sRouteIds,"~");
                        while (stToken.hasMoreTokens()) {
                                routes.add((String)stToken.nextToken());
                        }
                }else if((objectId != null) && (!objectId.equals("")) ){
                        routes.add(objectId);
                }else{
                    //do nothing
                }
                int size = routes.size();

                String routeId="";
                String routeName="";
                for(int i=0;i<size;i++)
                {
                        routeId = (String)routes.get(i);
                        route.setId(routeId);
                        routeName = (String)route.getInfo(context,route.SELECT_NAME);
                        if ("on".equals(emxGetParameter(request, "TaskAssignee"))) {
                                if ("minus".equals(taskAssigneePlusorMinus))  {
                                        taskAssigneeDays = "-"+taskAssigneeDays;
                                        taskAssigneeHours = "-"+taskAssigneeHours;
                                }
                                HashMap attrMap = new HashMap();
                                attrMap.put("days",taskAssigneeDays);
                                attrMap.put("hours",taskAssigneeHours);
                                attrMap.put("type",routeName+"TaskAssigneeEscalation");
                                attrMap.put("recepient","emxTaskAssignee");
                                attrMap.put("setting","on");
                                finalMapList.add(attrMap);

                        } else {
                                if ("minus".equals(taskAssigneePlusorMinus))  {
                                        taskAssigneeDays = "-"+taskAssigneeDays;
                                        taskAssigneeHours = "-"+taskAssigneeHours;
                                }
                                HashMap attrMap = new HashMap();
                                attrMap.put("days",taskAssigneeDays);
                                attrMap.put("hours",taskAssigneeHours);
                                attrMap.put("type",routeName+"TaskAssigneeEscalation");
                                attrMap.put("recepient","emxTaskAssignee");
                                attrMap.put("setting","off");
                                finalMapList.add(attrMap);
                        }
                        if ("on".equals(emxGetParameter(request, "RouteOwner")))  {
                                if ("minus".equals(routeOwnerPlusorMinus))  {
                                        routeOwnerDays = "-"+routeOwnerDays;
                                        routeOwnerHours = "-"+routeOwnerHours;
                                }

                                HashMap attrMap = new HashMap();
                                attrMap.put("days",routeOwnerDays);
                                attrMap.put("hours",routeOwnerHours);
                                attrMap.put("type",routeName+"RouteOwnerEscalation");
                                attrMap.put("recepient","emxRouteOwner");
                                attrMap.put("setting","on");
                                finalMapList.add(attrMap);

                        } else {
                              if ("minus".equals(routeOwnerPlusorMinus))  {
                                routeOwnerDays = "-"+routeOwnerDays;
                                routeOwnerHours = "-"+routeOwnerHours;
                              }
                                HashMap attrMap = new HashMap();
                                attrMap.put("days",routeOwnerDays);
                                attrMap.put("hours",routeOwnerHours);
                                attrMap.put("type",routeName+"RouteOwnerEscalation");
                                attrMap.put("recepient","emxRouteOwner");
                                attrMap.put("setting","off");
                                finalMapList.add(attrMap);
                        }
                        if ("on".equals(emxGetParameter(request, "WorkspaceLeads")))  {
                                if ("minus".equals(workspaceLeadsPlusorMinus))  {
                                        workspaceLeadsDays = "-"+workspaceLeadsDays;
                                        workspaceLeadsHours = "-"+workspaceLeadsHours;
                                }

                                HashMap attrMap = new HashMap();
                                attrMap.put("days",workspaceLeadsDays);
                                attrMap.put("hours",workspaceLeadsHours);
                                attrMap.put("type",routeName+"WorkspaceLeadsEscalation");
                                attrMap.put("recepient","emxWorkspaceLeads");
                                attrMap.put("setting","on");
                                finalMapList.add(attrMap);
                        } else {
                                if ("minus".equals(workspaceLeadsPlusorMinus))  {
                                        workspaceLeadsDays = "-"+workspaceLeadsDays;
                                        workspaceLeadsHours = "-"+workspaceLeadsHours;
                                }

                                HashMap attrMap = new HashMap();
                                attrMap.put("days",workspaceLeadsDays);
                                attrMap.put("hours",workspaceLeadsHours);
                                attrMap.put("type",routeName+"WorkspaceLeadsEscalation");
                                attrMap.put("recepient","emxWorkspaceLeads");
                                attrMap.put("setting","off");
                                finalMapList.add(attrMap);
                        }
                        if ("on".equals(emxGetParameter(request, "ProjectLeads")))  {
                                if ("minus".equals(projectLeadsPlusorMinus))  {
                                        projectLeadsDays = "-"+projectLeadsDays;
                                        projectLeadsHours = "-"+projectLeadsHours;
                                }

                                HashMap attrMap = new HashMap();
                                attrMap.put("days",projectLeadsDays);
                                attrMap.put("hours",projectLeadsHours);
                                attrMap.put("type",routeName+"ProjectLeadsEscalation");
                                attrMap.put("recepient","emxProjectLeads");
                                attrMap.put("setting","on");
                                finalMapList.add(attrMap);
                        } else {
                                if ("minus".equals(projectLeadsPlusorMinus))  {
                                        projectLeadsDays = "-"+projectLeadsDays;
                                        projectLeadsHours = "-"+projectLeadsHours;
                                }

                                HashMap attrMap = new HashMap();
                                attrMap.put("days",projectLeadsDays);
                                attrMap.put("hours",projectLeadsHours);
                                attrMap.put("type",routeName+"ProjectLeadsEscalation");
                                attrMap.put("recepient","emxProjectLeads");
                                attrMap.put("setting","off");
                                finalMapList.add(attrMap);
                        }
						Route.setTaskEscalation(context , route , finalMapList);
                }
        } catch(Exception e) {
        	System.out.println(" error "+e);session.putValue("error.message", e.getMessage());
        }
        %>
  getTopWindow().closeWindow();
  </script>
  </body>
  </html>
