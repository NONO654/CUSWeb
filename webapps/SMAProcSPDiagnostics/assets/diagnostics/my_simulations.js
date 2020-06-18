import DiagnosticsBase from "./base.js";

class Diagnostics extends DiagnosticsBase {
  constructor () {
    super();

    this._listenersAdded = false;
  }
  
  _$contextRequest () {
    const app = document.querySelector('#psListView');    

    // if listeners are not already added
    if (!this._listenersAdded) {
      // when selected process changes pass through context
      app.addEventListener('activeitem-changed', diagnostics._$contextRequest.bind(diagnostics));
      this._listenersAdded = true;
    }

    const activeitem = app.activeitem;
    const $action = '_$contextRequest';
    const objectId = activeitem && activeitem.id;
    const securityContext = widget.data.collabspaces;
    const title = activeitem && activeitem.attributes.title;
    const jobId = 'TODO';
    const jobOid = activeitem && activeitem.latestExecution && activeitem.latestExecution.id;
    const platform = widget.data.x3dPlatformId;
    const eedJobId = activeitem && activeitem.latestExecution && activeitem.latestExecution.eedJobId;
    

    // example:
    // --------
    // objectId = 4B709B568954000079572C5BFDED0C00
    // contextId = ctx::VPLMProjectLeader.MyCompany.3DS Collab Space
    // widgetData = {...}
    this.send({
      $action,
      objectId,
      securityContext,
      title,
      jobId,
      jobOid,
      platform,
      eedJobId
    });
  }

}


// create a new diagnostics instance
const diagnostics = new Diagnostics();
diagnostics.init();



