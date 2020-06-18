  function addChildNode(jsTreeId,nodeName,typeStr,nodeTargetPage,resourceBundle,OID,ImageString){
    var suiteKey = parent.parent.suiteKey;

    if ((ImageString == null) || (ImageString == 'null') || (ImageString == 'undefined')){
      ImageString = "null";
    }
    loadNodeURL = "../emxUILoadTreeChildNodes.jsp?nodeId=" + OID + "&nodeKey=" + typeStr + "&resourceBundle=" + resourceBundle + "&suiteKey=" + suiteKey;
    parent.parent.frames[0].location = "../common/emxTree.jsp?objectId=" + OID + "&mode=insert&jsTreeID=" + jsTreeId;
    return;
  }

  function addChildNodeParams(jsTreeId,OID,Params) {
    if ((Params != null) || (Params != 'null') || (Params != 'undefined')){
      parent.parent.frames[0].location = "../common/emxTree.jsp?objectId=" + OID + "&mode=insert&jsTreeID=" + jsTreeId + "&" + Params;
    } else {
      parent.parent.frames[0].location = "../common/emxTree.jsp?objectId=" + OID + "&mode=insert&jsTreeID=" + jsTreeId;
    }
  }
