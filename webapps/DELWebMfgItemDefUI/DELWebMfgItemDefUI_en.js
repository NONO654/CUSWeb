define("DS/DELWebMfgItemDefUI/DELWebMfgItemDefUI_en",{});define("DS/DELWebMfgItemDefUI/assets/nls/MGI_Errors_NLS",{"Error.Dummy.Title":"Manufacturing Item Definition","Error.AssignNotSupported.Title":"This type does not support assign","Error.ProvidedReferenceNode.Title":"Can't create a link for parent node","Error.CannotCreateImplementLink.Title":"Implement link creation failed","Error.NotScoped.Title":"Product is not scoped","Error.fillMandatoryField.Title":"Fill the mandatory fields","Error.ErrorLinkCreation.Title":"Error during link creation","Error.ScopeFailed.Title":"Scope creation failed","Error.ScopeFailed.scopeFromMFGItem":"This manufacturing item is already scoped","Error.ScopeFailed.scopeToProd":"This product item is already scoped with this manufacturing item","Error.CreateAndScopeFailed.Title":"Create Assembly and scope link creation failed","Error.SelectionNotScoped.Title":"To delete a scope please select a scoped assembly","Error.ScopeDeletionFailed.Title":"Scoped deletion failed","Error.RemoveFailed.Title":"Remove failed","Error.ConnectionNotFound.Title":"Connection could not be retrieved","Error.ProductNotUnassigned.Title":"Failure while unassigning product","Error.ExpandFailed.Title":"Failure while expanding object","Error.ExpandTooLong.Title":"Expand command took too long",Dummy:"COMMENT: Dummy entry without ending coma","Error.AlternateBL.Failure":"Failure while calling alternate command","Error.CapableResourceBL.Failure":"Failure while calling capable resource command","Error.CreateFailed.Title":"Creation of Mfg items failed","Error.CreateMfgSuccess.UIUpdateFailed.Title":"Mfg Item structure created successfully for selected Mfg Item, but view couldn't be updated","Error.UpdateFailed.Title":"Updation of Mfg items failed","Error.AssignFailed.Title":"Assignment of product failed","Error.NoProductScopeExists.Title":"Manufactured item structure update cannot be processed since no product scope exists","Error.NoProductScopeLink.Title":"Selected Manufactured Item doesn't have a scope","Error.NoHigherRevisionExists.Title":"Scoped Product have no higher revision","Error.ReconnectScopeFailure.Title":"Reconnect Scoped Link falied","Error.ReviseNReconnectScopeFailure.Title":"Revise and Reconnect Scoped Link falied","Error.MfgNotInReadWrite.Title":"Selected Manufactured Item is not in Read Write State","Error.MfgNotLatestRevision.Title":"Selected Manufactured Item is not the latest revision","Error.GetMajorRevisionFailure.Title":"Failed while getting higher revision of scoped product","Error.NoLatestForReplaceByLatest.Title":"Replace operation is ignored, the selected object is already the latest revision","Error.ReplaceByLatestScopeToDiffPrd.Title":"Replace operation is ignored, latest revision scoped to other product","Error.ReplaceByLatestError.Title":"Replace by Latest operation is failed","Error.ReplaceByExistingScopeExists.Title":"Replace operation is ignored, selected item is scoped to other product","Error.ReplaceByExistingParentNotInReadWrite.Title":"Replace operation is ignored, parent is not in read-write maturity state","Error.ReplaceByExistingError.Title":"Replace by Existing operation is failed","Error.ReplaceByNewRevisionError.Title":"Replace by New Revision operation is failed"});define("DS/DELWebMfgItemDefUI/assets/nls/MGI_Infos_NLS",{"Info.Dummy.Title":"Manufacturing Item Definition","Info.BodySelection.Title":"Select a product","Info.AsyOrPrvSelection.Title":"Select an assembly or a provide","Info.RefreshAll.Title":"Refreshing Widget","Info.ElementNotRemoved.Title":"Element not removed","Info.ElementNotAdded.Title":"Element not added","Info.SelectAssembly.Title":"Select an assembly","Info.SelectManufacturingItem.Title":"Select a manufacturing item","Info.SelectProductOrPart.Title":"Select a product or a part","Info.SelectProductsOrParts.Title":"Select product(s) or part(s)","Info.SelectInstance.Title":"Select an instance","Info.ExitScope.Title":"Scope creation command aborted","Info.ExitAssign.Title":"Product assignation command aborted","Info.SelectProvide.Title":"Select a provide","Info.SelectionIsNotProvide.Title":"Selection should be a provide","Info.NoImplementLink.Title":"No implement link was found on this node","Info.UseProductWidget.Title":"To manipulate Product structure, please use the dedicated widget","Info.ExpandCanceled.Title":"Canceled expand command","Info.NotIndexed.Title":"Element not indexed yet. Please wait for indexation","Drop.NotValidType.Title":"This type is not allowed on this view","Info.AlternateBL.Empty":"No alternate was found","Info.CapableResourceBL.Empty":"No capable resource was found","Info.MBOMViewMultipleSel.Title":"More than one MBOM selected",Dummy:"COMMENT: Dummy entry without ending coma",Dummy2:"Dummy","Info.SelectProductRevision.Title":"Select One Product Revision","Info.NoUpdate.Title":"Selected Mfg Item is upto date","Info.SelectManufactured.Title":"Select a Manufactured Item","Info.ExitReconnectScope.Title":"Reconnect Scope command aborted","Info.ExitRevReconnectScope.Title":"Revise and Reconnect Scope command aborted","ExpandFilter.EmptyResult.Message":"Filter is not matching the criteria","Info.CreateTimedOut.Title":"Create manufacturing items operation timed out.","Info.UpdateTimedOut.Title":"Update manufacturing items operation timed out."});define("DS/DELWebMfgItemDefUI/assets/nls/MGI_NLS",{"Cmd.Refresh.Title":"Refresh selected object(s)","Cmd.Hide.Title":"Remove selected object(s)","Cmd.HideAll.Title":"Remove all object(s)","Cmd.RefreshAll.Title":"Refresh All","Cmd.InsertCreateAssembly.Title":"Manufacturing Assembly","Cmd.InsertCreateMaterial.Title":"Manufactured Material","Cmd.InsertCreateKit.Title":"Manufacturing Kit","Cmd.InsertProvide.Title":"Provided Part","Cmd.CreateAssemblyAndScope.Title":"Create Manufacturing Assembly And Scope","Cmd.CreateScopeLink.Title":"Create Scope","Cmd.DeleteScopeLink.Title":"Delete Scope","Cmd.ReconnectScopeLink.Title":"Reconnect Scope for Mfg Item","Cmd.ReviseAndReconnectScopeLink.Title":"Revise and Reconnect Scope for Mfg Item","Cmd.CreateMfgItem.Title":"Create MFG Item","Cmd.UpdateMfgItem.Title":"Update MFG Item","Cmd.ExpandAll.Title":"Expand All","Cmd.ExpandNLevel.Title":"Expand N Level","Cmd.ActionViewFilter.Title":"Filter","Cmd.ActionViewFilter.DialogTitle":"Filter","Cmd.ActionViewFilter.DialogText":"Select","Cmd.ActionViewFilter.Remove":"Remove filters","Cmd.ActionViewFilter.EMPTY":"Empty","Cmd.CapableResourceRemove.Title":"Remove Capable Resource","Cmd.CapableResourceAdd.Title":"Add Capable Resource","Cmd.CapableResourceBL.Title":"Capable Resource BL","Cmd.OriginRemove.Title":"Remove Origin","Cmd.OriginAdd.Title":"Add Origin","Cmd.AlternateRemove.Title":"Remove Alternate","Cmd.AlternateAdd.Title":"Add Alternate","Cmd.AlternateBL.Title":"Alternate BL","Cmd.MBOMAddCommand.Title":"Add MBOM","Cmd.ProductAddCommand.Title":"Add Product/Part","Cmd.ActionBar_ChangeOwner.Title":"Change owner","Cmd.ActionBar_Attributes.Title":"Properties","Cmd.ToggleBodyView.Title":"Toggle Body View","Cmd.ToggleGraphView.Title":"Toggle Graph View","Cmd.ToggleOverview.Title":"Toggle Overview","Cmd.ToggleOrientation.Title":"Toggle Orientation","Cmd.Reframe.Title":"Reframe","Cmd.ReframeOn.Title":"Reframe On","EditUI.BottomBlock.text":"MBOM View","EditUI.LeftBlock.text":"Product/Part View","EditUI.RightBlock.text":"Action View",ProductImplementLink:"Scope","Dialog.CreateMfgItem.Title":"Create Mfg Items","Dialog.UpdateMfgItem.Title":"Update Mfg Item Structure","Dialog.ProductItem.Title":"Root Product","Dialog.MfgItem.Title":"Root Manufacturing Item","Dialog.AssignProductItem.Title":"Product(s)","Dialog.AssignProductMfgItem.Title":"Manufacturing Item","Dialog.SkipScope.Title":"Skip scope link creation for children","Dialog.SelectedMfgItem.Title":"Selected Manufactured Item","Dialog.AvailabeProduct.Title":"Available Product Revisions for update","Dialog.BackgroundJob.Title":"Run Update MBOM as background job","Dialog.AssignProduct.Title":"Assign","Dialog.ReconnectScopeProduct.Title":"Select an item from available product revisions","Error.RelationsNotLoaded.Title":"Relations are not loaded, Please load all Relations and try again","MfgItemDialog.Options":"Options","MfgItemDialog.CreateScopeForChildren":"Create Scope for ","MfgItemDialog.ScopeCreation.AllScope":"All Nodes","MfgItemDialog.ScopeCreation.LeafScope":"Leaf Nodes","MfgItemDialog.ScopeCreation.NoScope":"None","MfgItemDialog.PrefixForMfgItems":"Prefix for Manufacturing items","MfgItemDialog.PrefixForMfgItemsPlaceHolder":"Enter an optional prefix","MfgItemDialog.UpdateIntermediateScopedAssemblies":"Update MBOM including sub-scoped Assemblies","ReplaceCapableResourceCmd.DialogTitle":"Search to Replace Resource","ReplaceCapableResourceCmd.FormPlaceHolder":"Search in this App","ReplaceCapableResourceCmd.ReplaceResourceFailure":"Cannot Replace Capable Resource.","ReplaceCapableResourceCmd.ReplaceResourceExistsFailure":"Selected Resource already exists.","ReplaceCapableResourceCmd.ReplaceResourceSuccess":"Capable Resource replaced.","ReplaceCapableResourceCmd.SEARCH":"Search","ReplaceCapableResourceCmd.CANCEL":"Cancel","ReplaceCapableResourceCmd.LogMessage":"Replace capable resource {title} ({type})","ReplaceCapableResourceCmd.SearchTitle":"Select a Resource to replace existing",isimplemented:"BI",Manufacturing:"Manufacturing",ProductsAndParts:"Products And Parts",Alternate:"Alternates",Origin:"Origin",CapableResource:"Capable Resource",Scope:"Scope",Implement:"Implement",All:"All",Documents:"Documents",ProductImplementLinkOcc:"Realized Product",ProductImplementLink_inverse:"Scope",ProductImplementLinkOcc_inverse:"Implement","Drag.Drop.Title":"Drop here",ProductAssignmentStatus:"Assignment Status",ManufacturingItemUpdateStatus:"Update Status",Effectivity:"Effectivity",VariantEffectivity:"Variant Effectivity",CurrentEvolutionEffectivity:"Current Evolution Effectivity",ProjectedEvolutionEffectivity:"Projected Evolution Effectivity",RelationsNotLoadedQuestionMark:"??","HideShow3D.hide3D":"Hide in 3D","HideShow3D.show3D":"Show in 3D","HideShow3D.tooltip":"Hide/Show 3D"});define("DS/DELWebMfgItemDefUI/assets/nls/MGI_ODT_NLS",{"ODT.ODT.Title":"ODTTitle","ODT.ODT2.Title":"ODTTitle","ODT.ODT3.Title":"ODTTitle","ODT.ODT4.Title":"ODTTitle",Dummy:"Dummy"});define("DS/DELWebMfgItemDefUI/assets/nls/MGI_Success_NLS",{"Success.Dummy.Title":"Manufacturing Item Definition","Success.ProductAssigned.Title":"Product assigned successfully","Success.ScopeCreated.Title":"Scope created successfully","Success.ScopedDeleted.Title":"Scope deleted","Success.Removed.Title":"Removed","Success.ProductUnassigned.Title":"Product was successfully unassigned",Dummy:"Dummy","Success.CreateMfg.Title":"Mfg Item structure created successfully for selected Mfg Item","Success.UpdateMfg.Title":"Selected Mfg Item updated successfully"});