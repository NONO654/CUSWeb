<%--  emxLifecycleTasksSignaturesFilterProcess.jsp   -   It will filter the information on the Tasks/Signature tab under advance lifecycle page

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended
   publication of such program.

   static const char RCSID[] = $Id: emxLifecycleTasksSignaturesFilterProcess.jsp.rca 1.4.3.2 Wed Oct 22 15:47:59 2008 przemek Experimental przemek $
--%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%@page import="com.matrixone.apps.common.Lifecycle" %>

<%@include file="../emxUICommonHeaderEndInclude.inc"%>
	
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%!
// Constants
final String FILTER_ALL_APPROVALS = "All Approvals";
final String FILTER_MY_APPROVALS = "My Approvals";
final String FILTER_ALL = "All";
final String FILTER_PENDING = "Pending";
final String FILTER_COMPLETED = "Completed";
final String FILTER_CURRENT_OBJECT = "Current Object";
final String FILTER_CURRENT_AND_RELATED_TASKS = "Current and Related Tasks";        
final String INFO_TYPE_ACTIVATED_TASK = "activatedTask";
final String INFO_TYPE_DEFINED_TASK = "definedTask";
final String INFO_TYPE_SIGNATURE = "signature";
%>

<%
    try {
        // Constants
		final String POLICY_INBOX_TASK_STATE_COMPLETE = PropertyUtil.getSchemaProperty(context, "Policy", DomainObject.POLICY_INBOX_TASK, "state_Complete");
        
        // Get request paramaters
		String strTableId = emxGetParameter(request, "tableID");
        String strShowFilter = emxGetParameter(request, "showFilter");
        String strApprovalStatusFilter = emxGetParameter(request, "approvalStatusFilter");
        String strIncludeFilter = emxGetParameter(request, "includeFilter");
        String strMyName = context.getUser();
        
        String strInfoType = null;
		Map mapObjectInfo = null;
		
        // Get the table data
        // Get business object list from session level Table bean
		// HashMap tableData = tableBean.getTableData(tableID);
		MapList mlObjects = tableBean.getObjectList(strTableId);
		HashMap mapReqParam = tableBean.getRequestMap(strTableId);
		MapList mlFilteredObjects = null;
		MapList mlColumns = tableBean.getColumns(strTableId);
		Lifecycle lifecycle = new Lifecycle();
		
		// Check filter values
		if ( !(FILTER_ALL_APPROVALS.equals(strShowFilter) || FILTER_MY_APPROVALS.equals(strShowFilter))) {
		    strShowFilter = FILTER_ALL_APPROVALS;//Default
		}
		if ( !(FILTER_ALL.equals(strApprovalStatusFilter) || FILTER_PENDING.equals(strApprovalStatusFilter) || FILTER_COMPLETED.equals(strApprovalStatusFilter))) {
		    strApprovalStatusFilter = FILTER_ALL;//Default
		}
		if ( !(FILTER_CURRENT_OBJECT.equals(strIncludeFilter) || FILTER_CURRENT_AND_RELATED_TASKS.equals(strIncludeFilter))) {
		    strIncludeFilter = FILTER_CURRENT_AND_RELATED_TASKS;//Default
		}
		
		//
		// Filter for 'Show' filter
		//
		if (FILTER_ALL_APPROVALS.equals(strShowFilter)) {
		    // Do nothing
		}
		else {//My Approvals
		    
			String strRouteTaskUser = null;
			String strRoleName = null;
			String strGroupName = null;			
			String strApprovers = null;
			mlFilteredObjects = new MapList();
			
			
		    for (Iterator itrObjects = mlObjects.iterator(); itrObjects.hasNext(); ) {
		        mapObjectInfo = (Map)itrObjects.next();
		        strInfoType = (String)mapObjectInfo.get("infoType");
	            
	            if (INFO_TYPE_ACTIVATED_TASK.equals(strInfoType) || INFO_TYPE_DEFINED_TASK.equals(strInfoType)) {
					
	            	// Decide the name of the approver
					if (DomainObject.TYPE_ROUTE_TASK_USER.equals(mapObjectInfo.get("assigneeType"))) {
						// If the type of the assignee is RTU then get the name of the role/group as approver name
						strRouteTaskUser = (String)mapObjectInfo.get("routeTaskUser");
						if (strRouteTaskUser == null || "".equals(strRouteTaskUser.trim()) || "null".equals(strRouteTaskUser)) {
							continue; // Do not add this task
						}
						else {
							if (strRouteTaskUser.startsWith("role_")) {
								strRoleName = PropertyUtil.getSchemaProperty(context, strRouteTaskUser);//Symbolic->Real name
								if (strRoleName == null || "".equals(strRoleName)) {
								    continue;
								}
								
								// If I have this role then this is my approval								
								if (lifecycle.isRoleOrGroupAssigned(context, strMyName, strRoleName)) {
								    mlFilteredObjects.add(mapObjectInfo);
								}					
							}
							else if (strRouteTaskUser.startsWith("group_")) {
							    strGroupName = PropertyUtil.getSchemaProperty(context, strRouteTaskUser);//Symbolic->Real name
								if (strGroupName == null || "".equals(strGroupName)) {
								    continue;
								}
								// If I have this group then this is my approval
							    if (lifecycle.isRoleOrGroupAssigned(context, strMyName, strGroupName)) {
								    mlFilteredObjects.add(mapObjectInfo);
								}
							}
						}
					}
					else {
						// If the type of the assignee is not RTU then it is person and get the name of the person as approver name
						if (strMyName != null && strMyName.equals((String)mapObjectInfo.get("assigneeName"))) {
							mlFilteredObjects.add(mapObjectInfo);						    
						}
					}
	            }
	            else if (INFO_TYPE_SIGNATURE.equals(strInfoType)) {
	            	if ("true".equalsIgnoreCase((String)mapObjectInfo.get("signed"))) {
	            	    if (strMyName != null && strMyName.equals((String)mapObjectInfo.get("approver"))) {
							mlFilteredObjects.add(mapObjectInfo);						    
						}
	            	}
	            	else {
	            		strApprovers = (String)mapObjectInfo.get("approver");
	            		if (strApprovers == null || "".equals(strApprovers.trim())) {
	            		    continue;
	            		}
	            		if (lifecycle.isRoleOrGroupAssigned(context, strMyName, strApprovers)) {
	            		    mlFilteredObjects.add(mapObjectInfo);
	            		}
	            	}
	            }
	            else {
	            	throw new Exception("Invalid type of task object in task/signature table");
	            } 
		    }// for each object
		    mlObjects = mlFilteredObjects;
		}
		
		//
		// Filter for 'Approval Status' filter
		//
		if (FILTER_ALL.equals(strApprovalStatusFilter)) {
		    //Do nothing
		}
		else if (FILTER_PENDING.equals(strApprovalStatusFilter)) {
		    mlFilteredObjects = new MapList();
		    
			// Do for each object
            for (Iterator itrObjects = mlObjects.iterator(); itrObjects.hasNext();) {
                mapObjectInfo = (Map) itrObjects.next();
                strInfoType = (String)mapObjectInfo.get("infoType");
                
                // The Approval Status reflect Completed for completed tasks; 
                // For unsigned tasks or signatures, the status will reflect "Pending" till the task is completed.
                if (INFO_TYPE_SIGNATURE.equals(strInfoType)) {
                	// If signature is completed then show accordingly else show the links for operations
					if (!"true".equalsIgnoreCase((String)mapObjectInfo.get("signed"))) {
					    mlFilteredObjects.add(mapObjectInfo);
					}
                }
                else if (INFO_TYPE_ACTIVATED_TASK.equals(strInfoType)) {
                	// Show Completed for active task else show status depending on some things//TODO
                	if (!POLICY_INBOX_TASK_STATE_COMPLETE.equals((String)mapObjectInfo.get("currentState"))) {
                	    mlFilteredObjects.add(mapObjectInfo);
                	}
                }
                else if (INFO_TYPE_DEFINED_TASK.equals(strInfoType)) {
                    mlFilteredObjects.add(mapObjectInfo);
                }
            }
            mlObjects = mlFilteredObjects;
		}
		else {//Completed
			mlFilteredObjects = new MapList();
		    
			// Do for each object
            for (Iterator itrObjects = mlObjects.iterator(); itrObjects.hasNext();) {
                mapObjectInfo = (Map) itrObjects.next();
                strInfoType = (String)mapObjectInfo.get("infoType");
                
                // The Approval Status reflect Completed for completed tasks; 
                // For unsigned tasks or signatures, the status will reflect "Pending" till the task is completed.
                if (INFO_TYPE_SIGNATURE.equals(strInfoType)) {
                	// If signature is completed then show accordingly else show the links for operations
					if ("true".equalsIgnoreCase((String)mapObjectInfo.get("signed"))) {
					    mlFilteredObjects.add(mapObjectInfo);
					}
                }
                else if (INFO_TYPE_ACTIVATED_TASK.equals(strInfoType)) {
                	// Show Completed for active task else show status depending on some things//TODO
                	if (POLICY_INBOX_TASK_STATE_COMPLETE.equals((String)mapObjectInfo.get("currentState"))) {
                	    mlFilteredObjects.add(mapObjectInfo);
                	}
                }
                else if (INFO_TYPE_DEFINED_TASK.equals(strInfoType)) {
                    //Do nothing
                }
            }
            mlObjects = mlFilteredObjects;
		}
		
		//
		// Filter for 'Include' filter
		//
        if (FILTER_CURRENT_AND_RELATED_TASKS.equals(strIncludeFilter)) {
			// Do nothing
		}
		else if (FILTER_CURRENT_OBJECT.equals(strIncludeFilter)) {
			mlFilteredObjects = new MapList();
		    
			// Do for each object
            for (Iterator itrObjects = mlObjects.iterator(); itrObjects.hasNext();) {
                mapObjectInfo = (Map) itrObjects.next();
                
                // If this task of signature is not from related object then add it as filtered item
                if (!"true".equalsIgnoreCase((String)mapObjectInfo.get("isFromRelatedObject"))) {
                    mlFilteredObjects.add(mapObjectInfo);
                }
            }
			
            mlObjects = mlFilteredObjects;
		}
		
		//
		// If Related Objects Info Present, then show the related objects columns
		//
		boolean isRelatedObjectsInfoPresent = false;
        for (Iterator itrObjects = mlObjects.iterator(); itrObjects.hasNext();) {
            mapObjectInfo = (Map) itrObjects.next();
            
            // If this task of signature is from related object then add it as filtered item
            if ("true".equalsIgnoreCase((String)mapObjectInfo.get("isFromRelatedObject"))) {
                isRelatedObjectsInfoPresent = true;
                break;
            }
        }
        
        if (isRelatedObjectsInfoPresent) {
			// Add related objects column to columns maplist if the related objects information is present
		    // (and if they are not already added)
            addRelatedObjectsColumns(mlColumns, strTableId, session);
			TaskSignatureTable.setSortColumnName(tableBean, strTableId, "Related Object Name");
        }
        else {
			// Remove the related objects columns from columns maplist if they are present
            removeRelatedObjectsColumns(mlColumns, strTableId, session);            
            TaskSignatureTable.setSortColumnName(tableBean, strTableId, "Name");
        }
		
        //
		// Set the filtered objects list back into the table bean
		//
        tableBean.setFilteredObjectList(strTableId, mlObjects);
%>
		<script language="JavaScript">
			// Refresh the parent table page to show the updated infromation
			parent.refreshTableBody();
		</script>
<%		
        // Do something here
    } catch (Exception ex) {
         if (ex.toString() != null && ex.toString().length() > 0) {
            emxNavErrorObject.addMessage(ex.toString());
         }
         ex.printStackTrace();
    } finally {
        // Add cleanup statements if required like object close, cleanup session, etc.
    }
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file="../emxUICommonEndOfPageInclude.inc"%>
<%!
	/**
	 * Adds the related objects columns from the maplist if they are not added already
	 * @param mlColumns The maplist of columns to be modified
	 * @param strTableId The id for the table
	 * @param session The Http session object
	 */
	public static void addRelatedObjectsColumns(MapList mlColumns, String strTableId, HttpSession session) {
	     // Variables 
	     Map mapRelObjColumn = null;
	     Map mapColumn = null;
	     String strRelObjColumnName = null;
	     String strColumnName = null;
	     boolean isColumnPresent = false;
	     
	    // Get the columns to be added
	    Map mapRemovedColumnsInfo = (Map)session.getAttribute("_removedRelatedObjectsColumn_");
	    if (mapRemovedColumnsInfo == null) {
	        return;
	    }
	    session.removeAttribute("_removedRelatedObjectsColumn_");
	    
	    // If this column information is not for our table then return
	    if (!strTableId.equals((String)mapRemovedColumnsInfo.get("tableId"))) {
	        return;
	    }
	    MapList mlRelObjColumns = (MapList)mapRemovedColumnsInfo.get("removedColumns");
	    
	    // If any of the map is not present then return
	    if (mlColumns == null || mlRelObjColumns == null) {
	        return;
	    }
	    
	    // Check each column of related object's column, if it is present already in given map
	    for (Iterator itrRelObjColumns = mlRelObjColumns.iterator(); itrRelObjColumns.hasNext();) {
	        mapRelObjColumn = (Map)itrRelObjColumns.next();
	        strRelObjColumnName = (String)mapRelObjColumn.get("name");
	        isColumnPresent = false;
	        
	        for (Iterator itrColumns = mlColumns.iterator(); itrColumns.hasNext();) {
	            mapColumn = (Map)itrColumns.next();
	            strColumnName = (String)mapColumn.get("name");
	            
	            if (strRelObjColumnName.equals(strColumnName)) {
	                isColumnPresent = true;
	                break;
	            }
	        }// for
	        // If not present already then add this column
	        if (!isColumnPresent) {
	            mlColumns.add(mapRelObjColumn);
	        }
	    }// for
	    
	}
	
	/**
	 * Removed the related objects columns from the maplist if they are present
	 * @param mlColumns The maplist of columns to be modified
	 * @param strTableId The id for the table
	 * @param session The Http session object	 
	 */
	public static void removeRelatedObjectsColumns(MapList mlColumns, String strTableId, HttpSession session) {
		
	     //Variables 
	    Map mapRelObjColumn = null;
	    Map mapColumn = null;
	    String strRelObjColumnName = null;
	    String strColumnName = null;
	    boolean isColumnPresent = false;
	    int nColumnIndex = -1;
	    
	    MapList mlRemovedColumns = new MapList();
	    Map mapRemovedColumn = null;
	     
	    // Get the columns to be added
	    com.matrixone.apps.common.Lifecycle lifecycle = new Lifecycle();
	    MapList mlRelObjColumns = lifecycle.getRelatedObjectColumnsForTaskSignaturesTable();
	    
	    // If any of the map is not present then return
	    if (mlColumns == null || mlRelObjColumns == null) {
	        return;
	    }
	    
	    // Check each column of related object's column, if it is present already in given map
	    for (Iterator itrRelObjColumns = mlRelObjColumns.iterator(); itrRelObjColumns.hasNext();) {
	        mapRelObjColumn = (Map)itrRelObjColumns.next();
	        strRelObjColumnName = (String)mapRelObjColumn.get("name");
	        isColumnPresent = false;
	        nColumnIndex = 0;
	        
	        for (Iterator itrColumns = mlColumns.iterator(); itrColumns.hasNext();) {
	            mapColumn = (Map)itrColumns.next();
	            strColumnName = (String)mapColumn.get("name");
	            
	            if (strRelObjColumnName.equals(strColumnName)) {
	                isColumnPresent = true;
	                break;
	            }
	            
	            nColumnIndex++;
	        }// for
	        
	        // If present then remove this column
	        if (isColumnPresent) {
	            mapRemovedColumn = (Map)mlColumns.remove(nColumnIndex);
	            
	            mlRemovedColumns.add(mapRemovedColumn);
	            mapRemovedColumn = null;
	        }
	    }// for
	    
	    // Save the removed column in session against this table object timestamp
	    Map mapRemovedColumnsInfo = (Map)session.getAttribute("_removedRelatedObjectsColumn_");
	    if (mapRemovedColumnsInfo == null) {    
	        mapRemovedColumnsInfo = new HashMap();
		    mapRemovedColumnsInfo.put("tableId", strTableId);
		    mapRemovedColumnsInfo.put("removedColumns", mlRemovedColumns);
		    
		    session.setAttribute("_removedRelatedObjectsColumn_", mapRemovedColumnsInfo);
	    }
	}
	
	/**
	 * This class represents the table Task Signatures. The purpose of this class is to just 
	 * set the sorting column synamically depending upon the filtering process.
	 * It is required to extend this class from UITable to get access to the protected constants
	 * in it which will be used as key in the control map of the table.
	 */
	public static final class TaskSignatureTable extends com.matrixone.apps.framework.ui.UITable {
	    
	    /** 
	     * Sets the sorting column name.
	     * @param tableBean The table bean obtained from session scope
	     * @param strTableId The timestamp value that will be used to access the table data
	     * @param strColumnName The name of the column to be set for sorting
	     * @returns -
	     */
	    public static void setSortColumnName(com.matrixone.apps.framework.ui.UITable tableBean, String strTableId, String strColumnName) {
	        Map mapControl = tableBean.getControlMap(strTableId);
	        mapControl.put(CONTROL_SORT_COLUMN_NAME, strColumnName);
	    }
	}
%>
