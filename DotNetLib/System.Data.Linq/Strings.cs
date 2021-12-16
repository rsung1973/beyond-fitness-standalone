// Decompiled with JetBrains decompiler
// Type: System.Data.Linq.Strings
// Assembly: System.Data.Linq, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089
// MVID: 43A00CAE-A2D4-43EB-9464-93379DA02EC9
// Assembly location: C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.Linq.dll

namespace System.Data.Linq
{
    internal static class Strings
    {
        internal static string OwningTeam => SR.GetString(nameof(OwningTeam));

        internal static string CannotAddChangeConflicts => SR.GetString(nameof(CannotAddChangeConflicts));

        internal static string CannotRemoveChangeConflicts => SR.GetString(nameof(CannotRemoveChangeConflicts));

        internal static string InconsistentAssociationAndKeyChange(object p0, object p1) => SR.GetString(nameof(InconsistentAssociationAndKeyChange), p0, p1);

        internal static string UnableToDetermineDataContext => SR.GetString(nameof(UnableToDetermineDataContext));

        internal static string ArgumentTypeHasNoIdentityKey(object p0) => SR.GetString(nameof(ArgumentTypeHasNoIdentityKey), p0);

        internal static string CouldNotConvert(object p0, object p1) => SR.GetString(nameof(CouldNotConvert), p0, p1);

        internal static string CannotRemoveUnattachedEntity => SR.GetString(nameof(CannotRemoveUnattachedEntity));

        internal static string ColumnMappedMoreThanOnce(object p0) => SR.GetString(nameof(ColumnMappedMoreThanOnce), p0);

        internal static string CouldNotAttach => SR.GetString(nameof(CouldNotAttach));

        internal static string CouldNotGetTableForSubtype(object p0, object p1) => SR.GetString(nameof(CouldNotGetTableForSubtype), p0, p1);

        internal static string CouldNotRemoveRelationshipBecauseOneSideCannotBeNull(
          object p0,
          object p1,
          object p2)
        {
            return SR.GetString(nameof(CouldNotRemoveRelationshipBecauseOneSideCannotBeNull), p0, p1, p2);
        }

        internal static string EntitySetAlreadyLoaded => SR.GetString(nameof(EntitySetAlreadyLoaded));

        internal static string EntitySetModifiedDuringEnumeration => SR.GetString(nameof(EntitySetModifiedDuringEnumeration));

        internal static string ExpectedQueryableArgument(object p0, object p1) => SR.GetString(nameof(ExpectedQueryableArgument), p0, p1);

        internal static string ExpectedUpdateDeleteOrChange => SR.GetString(nameof(ExpectedUpdateDeleteOrChange));

        internal static string KeyIsWrongSize(object p0, object p1) => SR.GetString(nameof(KeyIsWrongSize), p0, p1);

        internal static string KeyValueIsWrongType(object p0, object p1) => SR.GetString(nameof(KeyValueIsWrongType), p0, p1);

        internal static string IdentityChangeNotAllowed(object p0, object p1) => SR.GetString(nameof(IdentityChangeNotAllowed), p0, p1);

        internal static string DbGeneratedChangeNotAllowed(object p0, object p1) => SR.GetString(nameof(DbGeneratedChangeNotAllowed), p0, p1);

        internal static string ModifyDuringAddOrRemove => SR.GetString(nameof(ModifyDuringAddOrRemove));

        internal static string ProviderDoesNotImplementRequiredInterface(object p0, object p1) => SR.GetString(nameof(ProviderDoesNotImplementRequiredInterface), p0, p1);

        internal static string ProviderTypeNull => SR.GetString(nameof(ProviderTypeNull));

        internal static string TypeCouldNotBeAdded(object p0) => SR.GetString(nameof(TypeCouldNotBeAdded), p0);

        internal static string TypeCouldNotBeRemoved(object p0) => SR.GetString(nameof(TypeCouldNotBeRemoved), p0);

        internal static string TypeCouldNotBeTracked(object p0) => SR.GetString(nameof(TypeCouldNotBeTracked), p0);

        internal static string TypeIsNotEntity(object p0) => SR.GetString(nameof(TypeIsNotEntity), p0);

        internal static string UnrecognizedRefreshObject => SR.GetString(nameof(UnrecognizedRefreshObject));

        internal static string UnhandledExpressionType(object p0) => SR.GetString(nameof(UnhandledExpressionType), p0);

        internal static string UnhandledBindingType(object p0) => SR.GetString(nameof(UnhandledBindingType), p0);

        internal static string ObjectTrackingRequired => SR.GetString(nameof(ObjectTrackingRequired));

        internal static string OptionsCannotBeModifiedAfterQuery => SR.GetString(nameof(OptionsCannotBeModifiedAfterQuery));

        internal static string DeferredLoadingRequiresObjectTracking => SR.GetString(nameof(DeferredLoadingRequiresObjectTracking));

        internal static string SubqueryDoesNotSupportOperator(object p0) => SR.GetString(nameof(SubqueryDoesNotSupportOperator), p0);

        internal static string SubqueryNotSupportedOn(object p0) => SR.GetString(nameof(SubqueryNotSupportedOn), p0);

        internal static string SubqueryNotSupportedOnType(object p0, object p1) => SR.GetString(nameof(SubqueryNotSupportedOnType), p0, p1);

        internal static string SubqueryNotAllowedAfterFreeze => SR.GetString(nameof(SubqueryNotAllowedAfterFreeze));

        internal static string IncludeNotAllowedAfterFreeze => SR.GetString(nameof(IncludeNotAllowedAfterFreeze));

        internal static string LoadOptionsChangeNotAllowedAfterQuery => SR.GetString(nameof(LoadOptionsChangeNotAllowedAfterQuery));

        internal static string IncludeCycleNotAllowed => SR.GetString(nameof(IncludeCycleNotAllowed));

        internal static string SubqueryMustBeSequence => SR.GetString(nameof(SubqueryMustBeSequence));

        internal static string RefreshOfDeletedObject => SR.GetString(nameof(RefreshOfDeletedObject));

        internal static string RefreshOfNewObject => SR.GetString(nameof(RefreshOfNewObject));

        internal static string CannotChangeInheritanceType(object p0, object p1, object p2, object p3) => SR.GetString(nameof(CannotChangeInheritanceType), p0, p1, p2, p3);

        internal static string DataContextCannotBeUsedAfterDispose => SR.GetString(nameof(DataContextCannotBeUsedAfterDispose));

        internal static string TypeIsNotMarkedAsTable(object p0) => SR.GetString(nameof(TypeIsNotMarkedAsTable), p0);

        internal static string NonEntityAssociationMapping(object p0, object p1, object p2) => SR.GetString(nameof(NonEntityAssociationMapping), p0, p1, p2);

        internal static string CannotPerformCUDOnReadOnlyTable(object p0) => SR.GetString(nameof(CannotPerformCUDOnReadOnlyTable), p0);

        internal static string InsertCallbackComment => SR.GetString(nameof(InsertCallbackComment));

        internal static string UpdateCallbackComment => SR.GetString(nameof(UpdateCallbackComment));

        internal static string DeleteCallbackComment => SR.GetString(nameof(DeleteCallbackComment));

        internal static string RowNotFoundOrChanged => SR.GetString(nameof(RowNotFoundOrChanged));

        internal static string UpdatesFailedMessage(object p0, object p1) => SR.GetString(nameof(UpdatesFailedMessage), p0, p1);

        internal static string CycleDetected => SR.GetString(nameof(CycleDetected));

        internal static string CantAddAlreadyExistingItem => SR.GetString(nameof(CantAddAlreadyExistingItem));

        internal static string CantAddAlreadyExistingKey => SR.GetString(nameof(CantAddAlreadyExistingKey));

        internal static string DatabaseGeneratedAlreadyExistingKey => SR.GetString(nameof(DatabaseGeneratedAlreadyExistingKey));

        internal static string InsertAutoSyncFailure => SR.GetString(nameof(InsertAutoSyncFailure));

        internal static string EntitySetDataBindingWithAbstractBaseClass(object p0) => SR.GetString(nameof(EntitySetDataBindingWithAbstractBaseClass), p0);

        internal static string EntitySetDataBindingWithNonPublicDefaultConstructor(object p0) => SR.GetString(nameof(EntitySetDataBindingWithNonPublicDefaultConstructor), p0);

        internal static string InvalidLoadOptionsLoadMemberSpecification => SR.GetString(nameof(InvalidLoadOptionsLoadMemberSpecification));

        internal static string EntityIsTheWrongType => SR.GetString(nameof(EntityIsTheWrongType));

        internal static string OriginalEntityIsWrongType => SR.GetString(nameof(OriginalEntityIsWrongType));

        internal static string CannotAttachAlreadyExistingEntity => SR.GetString(nameof(CannotAttachAlreadyExistingEntity));

        internal static string CannotAttachAsModifiedWithoutOriginalState => SR.GetString(nameof(CannotAttachAsModifiedWithoutOriginalState));

        internal static string CannotPerformOperationDuringSubmitChanges => SR.GetString(nameof(CannotPerformOperationDuringSubmitChanges));

        internal static string CannotPerformOperationOutsideSubmitChanges => SR.GetString(nameof(CannotPerformOperationOutsideSubmitChanges));

        internal static string CannotPerformOperationForUntrackedObject => SR.GetString(nameof(CannotPerformOperationForUntrackedObject));

        internal static string CannotAttachAddNonNewEntities => SR.GetString(nameof(CannotAttachAddNonNewEntities));

        internal static string QueryWasCompiledForDifferentMappingSource => SR.GetString(nameof(QueryWasCompiledForDifferentMappingSource));
    }
}
