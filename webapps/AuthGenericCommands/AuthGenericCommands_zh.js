define("DS/AuthGenericCommands/AuthGenericCommands_zh",{});define("DS/AuthGenericCommands/assets/nls/AuthDlgReorder",{modalHeader:"树重新排序",modalFooterReset:"重置树顺序",modalFooterOK:"确定",modalFooterCancel:"取消",upArrow:"上移选择",downArrow:"下移选择",freeArrow:"自由移动选择",TreeListViewHeaderName:"标题",TreeListViewHeaderResponsible:"责任对象",TreeListViewHeaderModifiedDate:"修改日期",TreeListViewHeaderCreationDate:"创建日期"});define("DS/AuthGenericCommands/assets/nls/AuthDlgRevisionUpdate",{modalFooterOK:"确定",modalFooterCancel:"取消",TreeListViewHeaderName:"标题",TreeListViewHeaderRevisionCurrent:"修订版",TreeListViewHeaderAction:"替换操作",TreeListViewHeaderRevisionPreview:"预期修订版",TreeListViewHeaderMaturityCurrent:"成熟度",TreeListViewHeaderMaturityPreview:"预期成熟度",TreeListViewHeaderType:"类型",TreeListViewHeaderResponsible:"责任对象",TreeListViewHeaderCandidate:"候选",TreeListViewContextualMenuSelectAllChildren:"选择所有子级",TreeListViewContextualMenuSelectChildren:"选择子级",TreeListViewContextualMenuCompareRevisions:"比较修订版",TreeListViewContextualMenuReplaceby:"将选定项替换为",TreeListViewContextualMenuResetAction:"重置操作",TreeListViewReplacePlaceholder:"替换为",ReplaceActionLatest:"最新",ReplaceActionLatestReleased:"最新发布",ReplaceActionLatestStable:"最新稳定",ReplaceActionNone:"无",ReplaceActionByRevision:"按修订版",ReplaceMultiInfoPartial:"{selectedNodes} 中有 {candidatesCount} 是 {action} 修订版的候选项",ReplaceMultiInfoFailure:"选定的对象都不是 {action} 修订版的候选项",ReplaceMultiInfoSuccess:"选定的所有对象都是 {action} 修订版的候选项",TreeListViewTooltipHeaderIsModified:"已修改",TreeListViewTooltipCellCandidateAvailable:"{objectName} 可以更新到：\n{candidateList}",TreeListViewTooltipCellCandidateNone:"{objectName} 无法更新。",TreeListViewTooltipCellIsModifiedAvailable:"{objectName} 将在验证后修改。",TreeListViewTooltipCellIsModifiedForbidden:"{objectName} 因其当前成熟度状态而无法修改。"});define("DS/AuthGenericCommands/assets/nls/AuthGenericCommandsCatalog",{SEL_001:"不能同时替换多选的多个对象。请仅选择一个对象。",SEL_002:"不能替换根对象。请选择子级对象。",SEL_003:"要将对象重新排序，它必须包含至少两个有效子级并且必须已经展开。",SEL_004:"只能将 {type} 重新排序。请选择 {type}。",SEL_005:"不能同时将多选的多个对象重新排序。请仅选择一个对象。",SEL_006:"由于至少有一个选定根对象没有父级，因此不能将其拆离。请仅选择子级对象。",ERR_003:"插入现有项失败： ",ERR_005:"重新排序失败： ",ERR_006:"重新排序操作期间结构已被修改（至少已添加或删除一个元素）。请在树重新排序前刷新选择。",ERR_007:"对象 {name} 不存在。请先刷新 widget，然后再执行此操作。",ERR_008:"至少有一个选定对象不存在。请先刷新 widget，然后再执行此操作。",SUC_003:"成功插入现有项。",SUC_005:"成功重新排序。",BAD_SELECTION:"错误选择已移除。",selection_root:"您不能选择根对象 {name}。",selection_child:"您不能针对父级 {parent} 和子级 {child} 选择所选子级对象。",selection_root_no_children:"您不能选择 {name}，因为它没有有效子级或未扩展。",selection_unsupported_type:"您不能选择 {type} 类型的对象 {name}。",selection_cycle:"您不能同时选择 {name} 及其父级之一。",unwanted_word_delete:"删除",unwanted_word_replacer_delete:"拆离",error_license:"您没有该命令所需的许可证。",operationAborted_Cycle:"操作已中止，因为它会导致循环。",error_timeout:"操作超时。",error_cancelled:"操作已取消。",displayAgain:"不再显示此消息",executing:"正在执行...",insert_unsupported_type_parent:"您不能插入到 {type} 类型的对象下。",insert_unsupported_unkowntype_parent:"您只能插入到 {type} 类型的对象下。",insert_unsupported_child:"您不能插入对象 {name}。",insert_unsupported_child_type:"您不能插入 {type} 类型的对象 {name}。",insert_unsupported_root:"您不能添加根对象 {name}。",insert_unsupported_cycle:"插入操作已中止，因为它在 {child} 和 {parent} 之间创建了周期。",insert_unsupported_itself:"您不能在对象 {name} 上插入对象本身。",insert_failure:"插入现有项失败。<br>无法在 {parent} 下插入 {child}。<br>{error}",replace_report_success:"成功将 {oldName} 替换为 {newName}。",replace_report_failure1:"替换 {oldName} 失败。",replace_report_failure2:"将 {oldName} 替换为 {newName} 失败。",replace_report_abort:"将 {oldName} 替换为 {newName} 中止。",replace_success:"成功替换。",replace_error:"替换失败。 ",replace_unsupported_type:"您不能替换 {type} 类型的对象 {name}。",replace_unaccessible_objet:"您没有对象 {name} 的访问权限。",replace_bad_replacer_type:"您不能替换为对象 {name}，因为其类型 {type} 无效。",replace_latest_failed_already_latest:"替换操作已被忽略，因为对象 {name} 已是最新修订版。",replace_latest_failed_child_selected:"请不要将节点及其直接或间接子级一起选择进行替换。",unparent_success:"成功拆离。",unparent_error:"拆离失败。 ",unparent_unsupported_object:"您不能取消对象 {name} 的父级关系。",unparent_confirm_title:"拆离",unparent_confirm_message_single:"是否确定要拆离 {name}？",unparent_confirm_message_multiple:"是否确定要拆离选定的所有对象？",reparent_failed_unsupported_type_child_known:"您不能为 {type} 类型的对象重新设置父级。",reparent_failed_unsupported_type_child_unknown:"您不能为此类型的对象重新设置父级。",reorder_view_partially_expanded:"结构已被部分展开。将不会重新排序未显示的元素。要重新排序结构中的所有元素，您必须首先显示整个结构。",SUC_InsertProductCconfiguration:"插入产品配置成功。",ERR_InsertProductCconfiguration:"插入产品配置失败： ",insertPC_failure:"插入产品配置失败。<br>无法在 {parent} 下插入 {child}。<br>{error}",insertPC_noPCFound:"插入已中止。未找到产品配置。选择对象以通过带有产品配置的附加配置模型进行插入。",SUC_ReplaceProductCconfiguration:"替换产品配置成功。",ERR_ReplaceProductCconfiguration:"替换产品配置失败： ",replacePC_failure:"替换产品配置失败。<br>无法替换 {parent} 下的 {child}。<br>{error}",replacePC_noPCFound:"替换已中止。未找到产品配置。选择对象以替换为带有产品配置的附加配置模型。",abort_confirm_message:"是否确定要中止此操作",confirm:"确认",modalFooterAbort:"中止"});define("DS/AuthGenericCommands/assets/nls/AuthGenericReportPanel",{success:"成功",failure:"失败",neutral:"警告",aborted:"已中止"});