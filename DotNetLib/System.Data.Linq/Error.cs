// Decompiled with JetBrains decompiler
// Type: System.Data.Linq.Error
// Assembly: System.Data.Linq, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089
// MVID: 43A00CAE-A2D4-43EB-9464-93379DA02EC9
// Assembly location: C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.Linq.dll

namespace System.Data.Linq
{
    internal static class Error
    {
        internal static Exception CannotAddChangeConflicts() => (Exception)new NotSupportedException(Strings.CannotAddChangeConflicts);

        internal static Exception CannotRemoveChangeConflicts() => (Exception)new NotSupportedException(Strings.CannotRemoveChangeConflicts);

        internal static Exception InconsistentAssociationAndKeyChange(object p0, object p1) => (Exception)new InvalidOperationException(Strings.InconsistentAssociationAndKeyChange(p0, p1));

        internal static Exception UnableToDetermineDataContext() => (Exception)new InvalidOperationException(Strings.UnableToDetermineDataContext);

        internal static Exception ArgumentTypeHasNoIdentityKey(object p0) => (Exception)new ArgumentException(Strings.ArgumentTypeHasNoIdentityKey(p0));

        internal static Exception CouldNotConvert(object p0, object p1) => (Exception)new InvalidCastException(Strings.CouldNotConvert(p0, p1));

        internal static Exception CannotRemoveUnattachedEntity() => (Exception)new InvalidOperationException(Strings.CannotRemoveUnattachedEntity);

        internal static Exception ColumnMappedMoreThanOnce(object p0) => (Exception)new InvalidOperationException(Strings.ColumnMappedMoreThanOnce(p0));

        internal static Exception CouldNotAttach() => (Exception)new InvalidOperationException(Strings.CouldNotAttach);

        internal static Exception CouldNotGetTableForSubtype(object p0, object p1) => (Exception)new InvalidOperationException(Strings.CouldNotGetTableForSubtype(p0, p1));

        internal static Exception CouldNotRemoveRelationshipBecauseOneSideCannotBeNull(
          object p0,
          object p1,
          object p2)
        {
            return (Exception)new InvalidOperationException(Strings.CouldNotRemoveRelationshipBecauseOneSideCannotBeNull(p0, p1, p2));
        }

        internal static Exception EntitySetAlreadyLoaded() => (Exception)new InvalidOperationException(Strings.EntitySetAlreadyLoaded);

        internal static Exception EntitySetModifiedDuringEnumeration() => (Exception)new InvalidOperationException(Strings.EntitySetModifiedDuringEnumeration);

        internal static Exception ExpectedQueryableArgument(object p0, object p1) => (Exception)new ArgumentException(Strings.ExpectedQueryableArgument(p0, p1));

        internal static Exception ExpectedUpdateDeleteOrChange() => (Exception)new InvalidOperationException(Strings.ExpectedUpdateDeleteOrChange);

        internal static Exception KeyIsWrongSize(object p0, object p1) => (Exception)new InvalidOperationException(Strings.KeyIsWrongSize(p0, p1));

        internal static Exception KeyValueIsWrongType(object p0, object p1) => (Exception)new InvalidOperationException(Strings.KeyValueIsWrongType(p0, p1));

        internal static Exception IdentityChangeNotAllowed(object p0, object p1) => (Exception)new InvalidOperationException(Strings.IdentityChangeNotAllowed(p0, p1));

        internal static Exception DbGeneratedChangeNotAllowed(object p0, object p1) => (Exception)new InvalidOperationException(Strings.DbGeneratedChangeNotAllowed(p0, p1));

        internal static Exception ModifyDuringAddOrRemove() => (Exception)new ArgumentException(Strings.ModifyDuringAddOrRemove);

        internal static Exception ProviderDoesNotImplementRequiredInterface(
          object p0,
          object p1)
        {
            return (Exception)new InvalidOperationException(Strings.ProviderDoesNotImplementRequiredInterface(p0, p1));
        }

        internal static Exception ProviderTypeNull() => (Exception)new InvalidOperationException(Strings.ProviderTypeNull);

        internal static Exception TypeCouldNotBeAdded(object p0) => (Exception)new InvalidOperationException(Strings.TypeCouldNotBeAdded(p0));

        internal static Exception TypeCouldNotBeRemoved(object p0) => (Exception)new InvalidOperationException(Strings.TypeCouldNotBeRemoved(p0));

        internal static Exception TypeCouldNotBeTracked(object p0) => (Exception)new InvalidOperationException(Strings.TypeCouldNotBeTracked(p0));

        internal static Exception TypeIsNotEntity(object p0) => (Exception)new InvalidOperationException(Strings.TypeIsNotEntity(p0));

        internal static Exception UnrecognizedRefreshObject() => (Exception)new ArgumentException(Strings.UnrecognizedRefreshObject);

        internal static Exception UnhandledExpressionType(object p0) => (Exception)new ArgumentException(Strings.UnhandledExpressionType(p0));

        internal static Exception UnhandledBindingType(object p0) => (Exception)new ArgumentException(Strings.UnhandledBindingType(p0));

        internal static Exception ObjectTrackingRequired() => (Exception)new InvalidOperationException(Strings.ObjectTrackingRequired);

        internal static Exception OptionsCannotBeModifiedAfterQuery() => (Exception)new InvalidOperationException(Strings.OptionsCannotBeModifiedAfterQuery);

        internal static Exception DeferredLoadingRequiresObjectTracking() => (Exception)new InvalidOperationException(Strings.DeferredLoadingRequiresObjectTracking);

        internal static Exception SubqueryDoesNotSupportOperator(object p0) => (Exception)new NotSupportedException(Strings.SubqueryDoesNotSupportOperator(p0));

        internal static Exception SubqueryNotSupportedOn(object p0) => (Exception)new NotSupportedException(Strings.SubqueryNotSupportedOn(p0));

        internal static Exception SubqueryNotSupportedOnType(object p0, object p1) => (Exception)new NotSupportedException(Strings.SubqueryNotSupportedOnType(p0, p1));

        internal static Exception SubqueryNotAllowedAfterFreeze() => (Exception)new InvalidOperationException(Strings.SubqueryNotAllowedAfterFreeze);

        internal static Exception IncludeNotAllowedAfterFreeze() => (Exception)new InvalidOperationException(Strings.IncludeNotAllowedAfterFreeze);

        internal static Exception LoadOptionsChangeNotAllowedAfterQuery() => (Exception)new InvalidOperationException(Strings.LoadOptionsChangeNotAllowedAfterQuery);

        internal static Exception IncludeCycleNotAllowed() => (Exception)new InvalidOperationException(Strings.IncludeCycleNotAllowed);

        internal static Exception SubqueryMustBeSequence() => (Exception)new InvalidOperationException(Strings.SubqueryMustBeSequence);

        internal static Exception RefreshOfDeletedObject() => (Exception)new InvalidOperationException(Strings.RefreshOfDeletedObject);

        internal static Exception RefreshOfNewObject() => (Exception)new InvalidOperationException(Strings.RefreshOfNewObject);

        internal static Exception CannotChangeInheritanceType(
          object p0,
          object p1,
          object p2,
          object p3)
        {
            return (Exception)new InvalidOperationException(Strings.CannotChangeInheritanceType(p0, p1, p2, p3));
        }

        internal static Exception DataContextCannotBeUsedAfterDispose() => (Exception)new ObjectDisposedException(Strings.DataContextCannotBeUsedAfterDispose);

        internal static Exception TypeIsNotMarkedAsTable(object p0) => (Exception)new InvalidOperationException(Strings.TypeIsNotMarkedAsTable(p0));

        internal static Exception NonEntityAssociationMapping(object p0, object p1, object p2) => (Exception)new InvalidOperationException(Strings.NonEntityAssociationMapping(p0, p1, p2));

        internal static Exception CannotPerformCUDOnReadOnlyTable(object p0) => (Exception)new InvalidOperationException(Strings.CannotPerformCUDOnReadOnlyTable(p0));

        internal static Exception CycleDetected() => (Exception)new InvalidOperationException(Strings.CycleDetected);

        internal static Exception CantAddAlreadyExistingItem() => (Exception)new InvalidOperationException(Strings.CantAddAlreadyExistingItem);

        internal static Exception InsertAutoSyncFailure() => (Exception)new InvalidOperationException(Strings.InsertAutoSyncFailure);

        internal static Exception EntitySetDataBindingWithAbstractBaseClass(object p0) => (Exception)new InvalidOperationException(Strings.EntitySetDataBindingWithAbstractBaseClass(p0));

        internal static Exception EntitySetDataBindingWithNonPublicDefaultConstructor(object p0) => (Exception)new InvalidOperationException(Strings.EntitySetDataBindingWithNonPublicDefaultConstructor(p0));

        internal static Exception InvalidLoadOptionsLoadMemberSpecification() => (Exception)new InvalidOperationException(Strings.InvalidLoadOptionsLoadMemberSpecification);

        internal static Exception EntityIsTheWrongType() => (Exception)new InvalidOperationException(Strings.EntityIsTheWrongType);

        internal static Exception OriginalEntityIsWrongType() => (Exception)new InvalidOperationException(Strings.OriginalEntityIsWrongType);

        internal static Exception CannotAttachAlreadyExistingEntity() => (Exception)new InvalidOperationException(Strings.CannotAttachAlreadyExistingEntity);

        internal static Exception CannotAttachAsModifiedWithoutOriginalState() => (Exception)new InvalidOperationException(Strings.CannotAttachAsModifiedWithoutOriginalState);

        internal static Exception CannotPerformOperationDuringSubmitChanges() => (Exception)new InvalidOperationException(Strings.CannotPerformOperationDuringSubmitChanges);

        internal static Exception CannotPerformOperationOutsideSubmitChanges() => (Exception)new InvalidOperationException(Strings.CannotPerformOperationOutsideSubmitChanges);

        internal static Exception CannotPerformOperationForUntrackedObject() => (Exception)new InvalidOperationException(Strings.CannotPerformOperationForUntrackedObject);

        internal static Exception CannotAttachAddNonNewEntities() => (Exception)new NotSupportedException(Strings.CannotAttachAddNonNewEntities);

        internal static Exception QueryWasCompiledForDifferentMappingSource() => (Exception)new ArgumentException(Strings.QueryWasCompiledForDifferentMappingSource);

        internal static Exception ArgumentNull(string paramName) => (Exception)new ArgumentNullException(paramName);

        internal static Exception ArgumentOutOfRange(string paramName) => (Exception)new ArgumentOutOfRangeException(paramName);

        internal static Exception NotImplemented() => (Exception)new NotImplementedException();

        internal static Exception NotSupported() => (Exception)new NotSupportedException();
    }
}
