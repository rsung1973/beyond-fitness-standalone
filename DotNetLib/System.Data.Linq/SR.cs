// Decompiled with JetBrains decompiler
// Type: System.Data.Linq.SR
// Assembly: System.Data.Linq, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089
// MVID: 43A00CAE-A2D4-43EB-9464-93379DA02EC9
// Assembly location: C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.Linq.dll

using System.Globalization;
using System.Resources;
using System.Threading;

namespace System.Data.Linq
{
    internal sealed class SR
    {
        internal const string OwningTeam = "OwningTeam";
        internal const string CannotAddChangeConflicts = "CannotAddChangeConflicts";
        internal const string CannotRemoveChangeConflicts = "CannotRemoveChangeConflicts";
        internal const string InconsistentAssociationAndKeyChange = "InconsistentAssociationAndKeyChange";
        internal const string UnableToDetermineDataContext = "UnableToDetermineDataContext";
        internal const string ArgumentTypeHasNoIdentityKey = "ArgumentTypeHasNoIdentityKey";
        internal const string CouldNotConvert = "CouldNotConvert";
        internal const string CannotRemoveUnattachedEntity = "CannotRemoveUnattachedEntity";
        internal const string ColumnMappedMoreThanOnce = "ColumnMappedMoreThanOnce";
        internal const string CouldNotAttach = "CouldNotAttach";
        internal const string CouldNotGetTableForSubtype = "CouldNotGetTableForSubtype";
        internal const string CouldNotRemoveRelationshipBecauseOneSideCannotBeNull = "CouldNotRemoveRelationshipBecauseOneSideCannotBeNull";
        internal const string EntitySetAlreadyLoaded = "EntitySetAlreadyLoaded";
        internal const string EntitySetModifiedDuringEnumeration = "EntitySetModifiedDuringEnumeration";
        internal const string ExpectedQueryableArgument = "ExpectedQueryableArgument";
        internal const string ExpectedUpdateDeleteOrChange = "ExpectedUpdateDeleteOrChange";
        internal const string KeyIsWrongSize = "KeyIsWrongSize";
        internal const string KeyValueIsWrongType = "KeyValueIsWrongType";
        internal const string IdentityChangeNotAllowed = "IdentityChangeNotAllowed";
        internal const string DbGeneratedChangeNotAllowed = "DbGeneratedChangeNotAllowed";
        internal const string ModifyDuringAddOrRemove = "ModifyDuringAddOrRemove";
        internal const string ProviderDoesNotImplementRequiredInterface = "ProviderDoesNotImplementRequiredInterface";
        internal const string ProviderTypeNull = "ProviderTypeNull";
        internal const string TypeCouldNotBeAdded = "TypeCouldNotBeAdded";
        internal const string TypeCouldNotBeRemoved = "TypeCouldNotBeRemoved";
        internal const string TypeCouldNotBeTracked = "TypeCouldNotBeTracked";
        internal const string TypeIsNotEntity = "TypeIsNotEntity";
        internal const string UnrecognizedRefreshObject = "UnrecognizedRefreshObject";
        internal const string UnhandledExpressionType = "UnhandledExpressionType";
        internal const string UnhandledBindingType = "UnhandledBindingType";
        internal const string ObjectTrackingRequired = "ObjectTrackingRequired";
        internal const string OptionsCannotBeModifiedAfterQuery = "OptionsCannotBeModifiedAfterQuery";
        internal const string DeferredLoadingRequiresObjectTracking = "DeferredLoadingRequiresObjectTracking";
        internal const string SubqueryDoesNotSupportOperator = "SubqueryDoesNotSupportOperator";
        internal const string SubqueryNotSupportedOn = "SubqueryNotSupportedOn";
        internal const string SubqueryNotSupportedOnType = "SubqueryNotSupportedOnType";
        internal const string SubqueryNotAllowedAfterFreeze = "SubqueryNotAllowedAfterFreeze";
        internal const string IncludeNotAllowedAfterFreeze = "IncludeNotAllowedAfterFreeze";
        internal const string LoadOptionsChangeNotAllowedAfterQuery = "LoadOptionsChangeNotAllowedAfterQuery";
        internal const string IncludeCycleNotAllowed = "IncludeCycleNotAllowed";
        internal const string SubqueryMustBeSequence = "SubqueryMustBeSequence";
        internal const string RefreshOfDeletedObject = "RefreshOfDeletedObject";
        internal const string RefreshOfNewObject = "RefreshOfNewObject";
        internal const string CannotChangeInheritanceType = "CannotChangeInheritanceType";
        internal const string DataContextCannotBeUsedAfterDispose = "DataContextCannotBeUsedAfterDispose";
        internal const string TypeIsNotMarkedAsTable = "TypeIsNotMarkedAsTable";
        internal const string NonEntityAssociationMapping = "NonEntityAssociationMapping";
        internal const string CannotPerformCUDOnReadOnlyTable = "CannotPerformCUDOnReadOnlyTable";
        internal const string InsertCallbackComment = "InsertCallbackComment";
        internal const string UpdateCallbackComment = "UpdateCallbackComment";
        internal const string DeleteCallbackComment = "DeleteCallbackComment";
        internal const string RowNotFoundOrChanged = "RowNotFoundOrChanged";
        internal const string UpdatesFailedMessage = "UpdatesFailedMessage";
        internal const string CycleDetected = "CycleDetected";
        internal const string CantAddAlreadyExistingItem = "CantAddAlreadyExistingItem";
        internal const string CantAddAlreadyExistingKey = "CantAddAlreadyExistingKey";
        internal const string DatabaseGeneratedAlreadyExistingKey = "DatabaseGeneratedAlreadyExistingKey";
        internal const string InsertAutoSyncFailure = "InsertAutoSyncFailure";
        internal const string EntitySetDataBindingWithAbstractBaseClass = "EntitySetDataBindingWithAbstractBaseClass";
        internal const string EntitySetDataBindingWithNonPublicDefaultConstructor = "EntitySetDataBindingWithNonPublicDefaultConstructor";
        internal const string InvalidLoadOptionsLoadMemberSpecification = "InvalidLoadOptionsLoadMemberSpecification";
        internal const string EntityIsTheWrongType = "EntityIsTheWrongType";
        internal const string OriginalEntityIsWrongType = "OriginalEntityIsWrongType";
        internal const string CannotAttachAlreadyExistingEntity = "CannotAttachAlreadyExistingEntity";
        internal const string CannotAttachAsModifiedWithoutOriginalState = "CannotAttachAsModifiedWithoutOriginalState";
        internal const string CannotPerformOperationDuringSubmitChanges = "CannotPerformOperationDuringSubmitChanges";
        internal const string CannotPerformOperationOutsideSubmitChanges = "CannotPerformOperationOutsideSubmitChanges";
        internal const string CannotPerformOperationForUntrackedObject = "CannotPerformOperationForUntrackedObject";
        internal const string CannotAttachAddNonNewEntities = "CannotAttachAddNonNewEntities";
        internal const string QueryWasCompiledForDifferentMappingSource = "QueryWasCompiledForDifferentMappingSource";
        private static SR loader;
        private ResourceManager resources;

        internal SR() => this.resources = new ResourceManager("System.Data.Linq", this.GetType().Assembly);

        private static SR GetLoader()
        {
            if (SR.loader == null)
            {
                SR sr = new SR();
                Interlocked.CompareExchange<SR>(ref SR.loader, sr, (SR)null);
            }
            return SR.loader;
        }

        private static CultureInfo Culture => (CultureInfo)null;

        public static ResourceManager Resources => SR.GetLoader().resources;

        public static string GetString(string name, params object[] args)
        {
            return String.Join(":", name, String.Join(",", args));

            //SR loader = SR.GetLoader();
            //if (loader == null)
            //    return (string)null;
            //string format = loader.resources.GetString(name, SR.Culture);
            //if (args == null || args.Length == 0)
            //    return format;
            //for (int index = 0; index < args.Length; ++index)
            //{
            //    if (args[index] is string str1 && str1.Length > 1024)
            //        args[index] = (object)(str1.Substring(0, 1021) + "...");
            //}
            //return string.Format((IFormatProvider)CultureInfo.CurrentCulture, format, args);
        }

        public static string GetString(string name) => name;    // SR.GetLoader()?.resources.GetString(name, SR.Culture);

        public static string GetString(string name, out bool usedFallback)
        {
            usedFallback = false;
            return SR.GetString(name);
        }

        public static object GetObject(string name) => name; //SR.GetLoader()?.resources.GetObject(name, SR.Culture);
    }
}
