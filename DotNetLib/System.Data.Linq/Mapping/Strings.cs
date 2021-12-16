// Decompiled with JetBrains decompiler
// Type: System.Data.Linq.Mapping.Strings
// Assembly: System.Data.Linq, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089
// MVID: 43A00CAE-A2D4-43EB-9464-93379DA02EC9
// Assembly location: C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.Linq.dll

namespace System.Data.Linq.Mapping
{
    internal static class Strings
    {
        internal static string OwningTeam => SR.GetString(nameof(OwningTeam));

        internal static string InvalidFieldInfo(object p0, object p1, object p2) => SR.GetString(nameof(InvalidFieldInfo), p0, p1, p2);

        internal static string CouldNotCreateAccessorToProperty(object p0, object p1, object p2) => SR.GetString(nameof(CouldNotCreateAccessorToProperty), p0, p1, p2);

        internal static string UnableToAssignValueToReadonlyProperty(object p0) => SR.GetString(nameof(UnableToAssignValueToReadonlyProperty), p0);

        internal static string LinkAlreadyLoaded => SR.GetString(nameof(LinkAlreadyLoaded));

        internal static string EntityRefAlreadyLoaded => SR.GetString(nameof(EntityRefAlreadyLoaded));

        internal static string NoDiscriminatorFound(object p0) => SR.GetString(nameof(NoDiscriminatorFound), p0);

        internal static string InheritanceTypeDoesNotDeriveFromRoot(object p0, object p1) => SR.GetString(nameof(InheritanceTypeDoesNotDeriveFromRoot), p0, p1);

        internal static string AbstractClassAssignInheritanceDiscriminator(object p0) => SR.GetString(nameof(AbstractClassAssignInheritanceDiscriminator), p0);

        internal static string CannotGetInheritanceDefaultFromNonInheritanceClass => SR.GetString(nameof(CannotGetInheritanceDefaultFromNonInheritanceClass));

        internal static string InheritanceCodeMayNotBeNull => SR.GetString(nameof(InheritanceCodeMayNotBeNull));

        internal static string InheritanceTypeHasMultipleDiscriminators(object p0) => SR.GetString(nameof(InheritanceTypeHasMultipleDiscriminators), p0);

        internal static string InheritanceCodeUsedForMultipleTypes(object p0) => SR.GetString(nameof(InheritanceCodeUsedForMultipleTypes), p0);

        internal static string InheritanceTypeHasMultipleDefaults(object p0) => SR.GetString(nameof(InheritanceTypeHasMultipleDefaults), p0);

        internal static string InheritanceHierarchyDoesNotDefineDefault(object p0) => SR.GetString(nameof(InheritanceHierarchyDoesNotDefineDefault), p0);

        internal static string InheritanceSubTypeIsAlsoRoot(object p0) => SR.GetString(nameof(InheritanceSubTypeIsAlsoRoot), p0);

        internal static string NonInheritanceClassHasDiscriminator(object p0) => SR.GetString(nameof(NonInheritanceClassHasDiscriminator), p0);

        internal static string MemberMappedMoreThanOnce(object p0) => SR.GetString(nameof(MemberMappedMoreThanOnce), p0);

        internal static string BadStorageProperty(object p0, object p1, object p2) => SR.GetString(nameof(BadStorageProperty), p0, p1, p2);

        internal static string IncorrectAutoSyncSpecification(object p0) => SR.GetString(nameof(IncorrectAutoSyncSpecification), p0);

        internal static string UnhandledDeferredStorageType(object p0) => SR.GetString(nameof(UnhandledDeferredStorageType), p0);

        internal static string BadKeyMember(object p0, object p1, object p2) => SR.GetString(nameof(BadKeyMember), p0, p1, p2);

        internal static string ProviderTypeNotFound(object p0) => SR.GetString(nameof(ProviderTypeNotFound), p0);

        internal static string MethodCannotBeFound(object p0) => SR.GetString(nameof(MethodCannotBeFound), p0);

        internal static string UnableToResolveRootForType(object p0) => SR.GetString(nameof(UnableToResolveRootForType), p0);

        internal static string MappingForTableUndefined(object p0) => SR.GetString(nameof(MappingForTableUndefined), p0);

        internal static string CouldNotFindTypeFromMapping(object p0) => SR.GetString(nameof(CouldNotFindTypeFromMapping), p0);

        internal static string TwoMembersMarkedAsPrimaryKeyAndDBGenerated(object p0, object p1) => SR.GetString(nameof(TwoMembersMarkedAsPrimaryKeyAndDBGenerated), p0, p1);

        internal static string TwoMembersMarkedAsRowVersion(object p0, object p1) => SR.GetString(nameof(TwoMembersMarkedAsRowVersion), p0, p1);

        internal static string TwoMembersMarkedAsInheritanceDiscriminator(object p0, object p1) => SR.GetString(nameof(TwoMembersMarkedAsInheritanceDiscriminator), p0, p1);

        internal static string CouldNotFindRuntimeTypeForMapping(object p0) => SR.GetString(nameof(CouldNotFindRuntimeTypeForMapping), p0);

        internal static string UnexpectedNull(object p0) => SR.GetString(nameof(UnexpectedNull), p0);

        internal static string CouldNotFindElementTypeInModel(object p0) => SR.GetString(nameof(CouldNotFindElementTypeInModel), p0);

        internal static string BadFunctionTypeInMethodMapping(object p0) => SR.GetString(nameof(BadFunctionTypeInMethodMapping), p0);

        internal static string IncorrectNumberOfParametersMappedForMethod(object p0) => SR.GetString(nameof(IncorrectNumberOfParametersMappedForMethod), p0);

        internal static string CouldNotFindRequiredAttribute(object p0, object p1) => SR.GetString(nameof(CouldNotFindRequiredAttribute), p0, p1);

        internal static string InvalidDeleteOnNullSpecification(object p0) => SR.GetString(nameof(InvalidDeleteOnNullSpecification), p0);

        internal static string MappedMemberHadNoCorrespondingMemberInType(object p0, object p1) => SR.GetString(nameof(MappedMemberHadNoCorrespondingMemberInType), p0, p1);

        internal static string UnrecognizedAttribute(object p0) => SR.GetString(nameof(UnrecognizedAttribute), p0);

        internal static string UnrecognizedElement(object p0) => SR.GetString(nameof(UnrecognizedElement), p0);

        internal static string TooManyResultTypesDeclaredForFunction(object p0) => SR.GetString(nameof(TooManyResultTypesDeclaredForFunction), p0);

        internal static string NoResultTypesDeclaredForFunction(object p0) => SR.GetString(nameof(NoResultTypesDeclaredForFunction), p0);

        internal static string UnexpectedElement(object p0, object p1) => SR.GetString(nameof(UnexpectedElement), p0, p1);

        internal static string ExpectedEmptyElement(object p0, object p1, object p2) => SR.GetString(nameof(ExpectedEmptyElement), p0, p1, p2);

        internal static string DatabaseNodeNotFound(object p0) => SR.GetString(nameof(DatabaseNodeNotFound), p0);

        internal static string DiscriminatorClrTypeNotSupported(object p0, object p1, object p2) => SR.GetString(nameof(DiscriminatorClrTypeNotSupported), p0, p1, p2);

        internal static string IdentityClrTypeNotSupported(object p0, object p1, object p2) => SR.GetString(nameof(IdentityClrTypeNotSupported), p0, p1, p2);

        internal static string PrimaryKeyInSubTypeNotSupported(object p0, object p1) => SR.GetString(nameof(PrimaryKeyInSubTypeNotSupported), p0, p1);

        internal static string MismatchedThisKeyOtherKey(object p0, object p1) => SR.GetString(nameof(MismatchedThisKeyOtherKey), p0, p1);

        internal static string InvalidUseOfGenericMethodAsMappedFunction(object p0) => SR.GetString(nameof(InvalidUseOfGenericMethodAsMappedFunction), p0);

        internal static string MappingOfInterfacesMemberIsNotSupported(object p0, object p1) => SR.GetString(nameof(MappingOfInterfacesMemberIsNotSupported), p0, p1);

        internal static string UnmappedClassMember(object p0, object p1) => SR.GetString(nameof(UnmappedClassMember), p0, p1);
    }
}
