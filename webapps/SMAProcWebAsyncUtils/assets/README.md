# Layout Edit
This document attempts to list all corner cases that author of this framework need to take into consideration, while editing the layout.

## Background
Lets recap the existing web services

* SMA_Gateway : Update Action = CREATE
    * Check if ParentID (Id of object to which Gateway is to be added) is empty. If so throw Exception.
    * Check for CEStamp. If Outdated throw Exception.
    * Check if the Parent is Activity. If so then
        * Add the information of the Gateway in the &lt;Gateways&gt; tag in the definition of Activity.
        * Update the sequence flows of the Activity based on the Sequence flows coming in payload.
    * If Parent is Simulation Process
        * Add the information of the Gateway in the &lt;Gateways&gt; tag in the definition of Process.
        * Update the sequence flows of the Activity based on the Sequence flows coming in payload.
    
* SMA_Gateway : Update Action = DELETE
    * Check if ParentID (Id of object to which Gateway is to be added) is empty. If so throw Exception.
    * Check for CEStamp. If Outdated throw Exception.
    * Check if the Parent is Activity. If so then
        * Delete the gateway element from gateway tag in definition of Activity.
        * Update the sequence flows of the Activity based on the Sequence flows coming in payload.
    * If Parent is Simulation Process
        * Delete the gateway element from gateway tag in definition of Process.
        * Update the sequence flows of the Activity based on the Sequence flows coming in payload.

* SMA_Process : UpdateAction = CREATE
    * Create new Simulation Process

* SMA_Process : UpdateAction = DELETE
    * Delete Simulation Process


* SMA_Process : UpdateAction = MODIFY
    * Check for CEStamp. If Outdated throw Exception.
    * Set Description if it is not null in payload.
    * Set title if it is not null in payload.
    * Update Sequence flows as sent in payload.
    * If (connectAction==Disconnect) then
        * if the parent object upon which this WebService is called is Simulation Activity then
            * Find the object child object through getRelatedObjects method.
                * Get the connection id between the child object and Parent Object.
                * Disconnect this relationship.
                * Connect the child to Ancestor Simulation Process.
        * If the parent object upon which this WebService is called is Simulation Process then
            * Remove Parameter mapping between Parent and Child objects.
    * If (connectAction==Connect) then
        * If the parent object upon which this WebService is called is Simulation Activity then
            * Find the Relationship to which child Activity is connected to. (Code Assumes that it is connected to Ancestor Simulation Process.)
            * Get the connection id and disconnect this relationship.
            * Connect the child activity to the parent object.
    * Return updated CEStamp.

* SMA_Activity : UpdateAction = DELETE
    * Check for CEStamp. If Outdated throw Exception..
    * Delete the Activity Object from the activity Id Provided.
    * Update the sequence flows of parent Simulation as per sequence flows provided in payload. 


* SMA_Activity : UpdateAction = CREATE
    * Check if ParentID is empty. If so throw Exception.
    * Check for CEStamp. If Outdated throw Exception.
        * Create the Activity object.
        * Connect it to the parent Simulation Process
    * Update the sequence flows as sent in payload.


* SMA_Activity : UpdateAction = MODIFY
    * Update the Sequence flows as per payload.
    * Update description and title as per payload.
    * Return Updated CEStamp.


## Parent child relationship

Activities are stored at PLM level, so each activity has physical id associated with them. Also, the parent child relationship between activities are at PLM level. 

However gateways are not persisted as PLM object, so they don't have physical id. They exist purely on XML data.

One drawback of our existing architecture is that this parent-child relationship between activities are not exposed in the JSON data we get from web services. They are inferred from sequence flows (see SMAJSCMMCommonServices#parseSeqFlows for more details). This is fine for connected simple processes. But for disconnected ones, things starts to gets complicated.


For example: consider the case below:

![isolated-before]

After removing G1, it becomes

![isolated-after]

For this process, the sequence flow of A1 will not contain C1, since it does not have any outgoing or incoming flow items. In this case, PCW will have C1 parent set to `null`, but on the server side, it still has A1 as its parent.

However for case below, A1 will have seq flow for (C1, C2) even after deleting G1. Hence, when we parse this sequence, both C1 and C2 will have their parent set as A1 (correct behavior).

![isolated-safe]


## Limitation of web service

One of the limitation of existing web service is that we cannot change the parent of an activity. When creating a flow sequence (`from`, `to`), we must have `to`'s parent to be either process or the same parent as `from`.  

In preceding example, it means the isolated activity C1, can only be connected to gateways that are child of A1. Trying to connect it from other parent result in error.

![parent-issue]


## Invariant Checking

When editing the seq flows, we need to maintain certain invariants. 

* Subflow must be closed. This can be violated when activity being modified is either first child or last child. If user deletes a last child, and subsequently forgets to elect new last child, it will result in open subflow. Similar for first child.

If subflow has not well defined last child, PCW will still draw the diagram as shown below. But not having first child will have undefined behavior and layout diagram.

![invariant-open-subflow]

* A path must exist between first and last child. This also extends to start and end node. These kind of process won't be rendered properly in PCW.

![invariant-path-subflow]


<!-- Figures -->
[isolated-before]: f1.png
[isolated-after]: f2.png
[isolated-safe]: f3.png
[parent-issue]: f4.png
[invariant-open-subflow]: f5.png
[invariant-path-subflow]: f6.png
