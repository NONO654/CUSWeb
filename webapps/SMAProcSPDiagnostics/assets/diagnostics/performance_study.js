import DiagnosticsBase from "./base.js";

class Diagnostics extends DiagnosticsBase {
  _$contextRequest () {
    const $action = '_$contextRequest';

    const app = document.querySelector('#psSimDesc');

    const objectId = app.simOid;
    const securityContext = widget.data.collabspaces;
    const title = app.simDetails && app.simDetails.attributes.title;
    const jobId = app.selectedJob.objectId;
    const jobOid = app.selectedJob.jobObjectId;
    const platform = widget.data.x3dPlatformId;
    const eedJobId = app.eedjobId;
    

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




