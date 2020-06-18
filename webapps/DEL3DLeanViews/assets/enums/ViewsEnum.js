/**
* @quickreview  FRL1 17:02:28 Extend Model Enum
* @quickreview  FRL1 17:04:26 Use InfraView + added leangetConstructor
* @quickreview  FRL1 17:04:27 Added tip of the day leanget
* @quickreview  FRL1 17:05:17 Moved all enums to dedicated module
* @quickreview  FRL1 17:06:13 Added WebViewerView
* @quickreview  FRL1 18:07:20 Added tasknote, issuenote and note models
* @quickreview  FRL1 18:07:25 Moved to NoteElements folder
* @quickreview  B5S  18:07:25 Integration of IssueLog from XZK
* @quickreview  FRL1 18:09:18 Merge 421 + Shanghai + People + Action Log integration + Name
*/

define('DS/DEL3DLeanViews/assets/enums/ViewsEnum',
[
    'pluginDS!DS/VENUnderscore/underscore.1.8.3/underscore',
    'DS/DEL3DLeanEnums/Model.enum',
    //	Statics
    'DS/DEL3DLeanViews/StaticViews/MapView',
    'DS/DEL3DLeanViews/StaticViews/PageView',
    //	Leangets Views
    'DS/DEL3DLeanViews/StaticViews/InfraView',
    'DS/DEL3DLeanViews/StaticViews/LeangetViews/ActionLogView',
    'DS/DEL3DLeanViews/StaticViews/LeangetViews/EHSCrossView',
    'DS/DEL3DLeanViews/StaticViews/LeangetViews/FollowUpView',
    'DS/DEL3DLeanViews/StaticViews/LeangetViews/IssueLogView',
    'DS/DEL3DLeanViews/StaticViews/LeangetViews/KPIView',
    'DS/DEL3DLeanViews/StaticViews/LeangetViews/SafetyView',
    'DS/DEL3DLeanViews/StaticViews/LeangetViews/SketchView',
    'DS/DEL3DLeanViews/StaticViews/LeangetViews/TeamView',
    'DS/DEL3DLeanViews/StaticViews/LeangetViews/CustomView',
    'DS/DEL3DLeanViews/StaticViews/LeangetViews/PlayerView',
    'DS/DEL3DLeanViews/StaticViews/LeangetViews/WebViewerView',
    //	Stickies
    'DS/DEL3DLeanViews/FloatableElements/StickerView',
    'DS/DEL3DLeanViews/FloatableElements/StickyMemberView',
    'DS/DEL3DLeanViews/FloatableElements/StickyNoteView',
    'DS/DEL3DLeanViews/FloatableElements/NoteElements/TaskNoteView',
    'DS/DEL3DLeanViews/FloatableElements/NoteElements/IssueNoteView',
    'DS/DEL3DLeanViews/FloatableElements/NoteElements/NoteView'
], function (
    _,
    ModelEnum,
    //	Statics
    MapView,
    PageView,
    //	Leangets
    InfraView,
    ActionLogView,
    EHSCrossView,
    FollowUpView,
    IssueLogView,
    KPIView,
    SafetyView,
    SketchView,
    TeamView,
    CustomView,
    PlayerView,
    WebViewerView,
    //	Stickies
    StickerView,
    StickyMemberView,
    StickyNoteView,
    TaskNoteView,
    IssueNoteView,
    NoteView
) {

    'use strict';

    /**
    * Enum of the different view types
    */
    var VIEW = ModelEnum;

    VIEW.STICKER = _.extend(ModelEnum.STICKER, {
        viewConstructor: StickerView
    });

    VIEW.STICKYMEMBER = _.extend(ModelEnum.STICKYMEMBER, {
        viewConstructor: StickyMemberView
    });

    VIEW.STICKYNOTE = _.extend(ModelEnum.STICKYNOTE, {
        viewConstructor: StickyNoteView
    });

    VIEW.NOTE = _.extend(ModelEnum.NOTE, {
        viewConstructor: NoteView
    });

    VIEW.TASKNOTE = _.extend(ModelEnum.TASKNOTE, {
        viewConstructor: TaskNoteView
    });

    VIEW.ISSUENOTE = _.extend(ModelEnum.ISSUENOTE, {
        viewConstructor: IssueNoteView
    });

    VIEW.PROJECT = _.extend(ModelEnum.PROJECT, {
        viewConstructor: MapView
    });

    VIEW.PAGE = _.extend(ModelEnum.PAGE, {
        viewConstructor:	PageView
    });

    VIEW.ACTIONLOG = _.extend(ModelEnum.ACTIONLOG, {
        viewConstructor:	InfraView,
        leangetConstructor:	ActionLogView
    });

	VIEW.ISSUELOG = _.extend(ModelEnum.ISSUELOG, {
		viewConstructor:	InfraView,
		leangetConstructor:	IssueLogView
	});

    VIEW.EHSCROSS = _.extend(ModelEnum.EHSCROSS, {
        viewConstructor:	InfraView,
        leangetConstructor:	EHSCrossView
    });

    VIEW.FOLLOWUP = _.extend(ModelEnum.FOLLOWUP, {
        viewConstructor:	InfraView,
        leangetConstructor:	FollowUpView
    });

    VIEW.KPI = _.extend(ModelEnum.KPI, {
        viewConstructor:	InfraView,
        leangetConstructor:	KPIView
    });

    VIEW.SAFETY = _.extend(ModelEnum.SAFETY, {
        viewConstructor:	InfraView,
        leangetConstructor:	SafetyView
    });

    VIEW.WEBVIEWER = _.extend(ModelEnum.WEBVIEWER, {
        viewConstructor:	InfraView,
        leangetConstructor:	WebViewerView
    });

    VIEW.TEAM = _.extend(ModelEnum.TEAM, {
        viewConstructor:	InfraView,
        leangetConstructor:	TeamView
    });

    VIEW.SKETCH = _.extend(ModelEnum.SKETCH, {
        viewConstructor:	InfraView,
        leangetConstructor:	SketchView
    });

    VIEW.CUSTOM = _.extend(ModelEnum.CUSTOM, {
        viewConstructor:	InfraView,
        leangetConstructor:	CustomView
    });

    VIEW.PLAYER = _.extend(ModelEnum.PLAYER, {
        viewConstructor:	InfraView,
        leangetConstructor:	PlayerView
    });

    return VIEW;
});
