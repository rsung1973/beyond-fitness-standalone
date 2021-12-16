// Decompiled with JetBrains decompiler
// Type: System.Data.Linq.SqlClient.Strings
// Assembly: System.Data.Linq, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089
// MVID: 43A00CAE-A2D4-43EB-9464-93379DA02EC9
// Assembly location: C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.Linq.dll

namespace System.Data.Linq.SqlClient
{
    internal static class Strings
    {
        internal static string OwningTeam => SR.GetString(nameof(OwningTeam));

        internal static string VbLikeDoesNotSupportMultipleCharacterRanges => SR.GetString(nameof(VbLikeDoesNotSupportMultipleCharacterRanges));

        internal static string VbLikeUnclosedBracket => SR.GetString(nameof(VbLikeUnclosedBracket));

        internal static string UnrecognizedProviderMode(object p0) => SR.GetString(nameof(UnrecognizedProviderMode), p0);

        internal static string CompiledQueryCannotReturnType(object p0) => SR.GetString(nameof(CompiledQueryCannotReturnType), p0);

        internal static string ArgumentEmpty(object p0) => SR.GetString(nameof(ArgumentEmpty), p0);

        internal static string ProviderCannotBeUsedAfterDispose => SR.GetString(nameof(ProviderCannotBeUsedAfterDispose));

        internal static string ArgumentTypeMismatch(object p0) => SR.GetString(nameof(ArgumentTypeMismatch), p0);

        internal static string ContextNotInitialized => SR.GetString(nameof(ContextNotInitialized));

        internal static string CouldNotDetermineSqlType(object p0) => SR.GetString(nameof(CouldNotDetermineSqlType), p0);

        internal static string CouldNotDetermineDbGeneratedSqlType(object p0) => SR.GetString(nameof(CouldNotDetermineDbGeneratedSqlType), p0);

        internal static string CouldNotDetermineCatalogName => SR.GetString(nameof(CouldNotDetermineCatalogName));

        internal static string CreateDatabaseFailedBecauseOfClassWithNoMembers(object p0) => SR.GetString(nameof(CreateDatabaseFailedBecauseOfClassWithNoMembers), p0);

        internal static string CreateDatabaseFailedBecauseOfContextWithNoTables(object p0) => SR.GetString(nameof(CreateDatabaseFailedBecauseOfContextWithNoTables), p0);

        internal static string CreateDatabaseFailedBecauseSqlCEDatabaseAlreadyExists(object p0) => SR.GetString(nameof(CreateDatabaseFailedBecauseSqlCEDatabaseAlreadyExists), p0);

        internal static string DistributedTransactionsAreNotAllowed => SR.GetString(nameof(DistributedTransactionsAreNotAllowed));

        internal static string InvalidConnectionArgument(object p0) => SR.GetString(nameof(InvalidConnectionArgument), p0);

        internal static string CannotEnumerateResultsMoreThanOnce => SR.GetString(nameof(CannotEnumerateResultsMoreThanOnce));

        internal static string IifReturnTypesMustBeEqual(object p0, object p1) => SR.GetString(nameof(IifReturnTypesMustBeEqual), p0, p1);

        internal static string MethodNotMappedToStoredProcedure(object p0) => SR.GetString(nameof(MethodNotMappedToStoredProcedure), p0);

        internal static string ResultTypeNotMappedToFunction(object p0, object p1) => SR.GetString(nameof(ResultTypeNotMappedToFunction), p0, p1);

        internal static string ToStringOnlySupportedForPrimitiveTypes => SR.GetString(nameof(ToStringOnlySupportedForPrimitiveTypes));

        internal static string TransactionDoesNotMatchConnection => SR.GetString(nameof(TransactionDoesNotMatchConnection));

        internal static string UnexpectedTypeCode(object p0) => SR.GetString(nameof(UnexpectedTypeCode), p0);

        internal static string UnsupportedDateTimeConstructorForm => SR.GetString(nameof(UnsupportedDateTimeConstructorForm));

        internal static string UnsupportedDateTimeOffsetConstructorForm => SR.GetString(nameof(UnsupportedDateTimeOffsetConstructorForm));

        internal static string UnsupportedStringConstructorForm => SR.GetString(nameof(UnsupportedStringConstructorForm));

        internal static string UnsupportedTimeSpanConstructorForm => SR.GetString(nameof(UnsupportedTimeSpanConstructorForm));

        internal static string UnsupportedTypeConstructorForm(object p0) => SR.GetString(nameof(UnsupportedTypeConstructorForm), p0);

        internal static string WrongNumberOfValuesInCollectionArgument(object p0, object p1, object p2) => SR.GetString(nameof(WrongNumberOfValuesInCollectionArgument), p0, p1, p2);

        internal static string LogGeneralInfoMessage(object p0, object p1) => SR.GetString(nameof(LogGeneralInfoMessage), p0, p1);

        internal static string LogAttemptingToDeleteDatabase(object p0) => SR.GetString(nameof(LogAttemptingToDeleteDatabase), p0);

        internal static string LogStoredProcedureExecution(object p0, object p1) => SR.GetString(nameof(LogStoredProcedureExecution), p0, p1);

        internal static string MemberCannotBeTranslated(object p0, object p1) => SR.GetString(nameof(MemberCannotBeTranslated), p0, p1);

        internal static string NonConstantExpressionsNotSupportedFor(object p0) => SR.GetString(nameof(NonConstantExpressionsNotSupportedFor), p0);

        internal static string MathRoundNotSupported => SR.GetString(nameof(MathRoundNotSupported));

        internal static string SqlMethodOnlyForSql(object p0) => SR.GetString(nameof(SqlMethodOnlyForSql), p0);

        internal static string NonConstantExpressionsNotSupportedForRounding => SR.GetString(nameof(NonConstantExpressionsNotSupportedForRounding));

        internal static string CompiledQueryAgainstMultipleShapesNotSupported => SR.GetString(nameof(CompiledQueryAgainstMultipleShapesNotSupported));

        internal static string LenOfTextOrNTextNotSupported(object p0) => SR.GetString(nameof(LenOfTextOrNTextNotSupported), p0);

        internal static string TextNTextAndImageCannotOccurInDistinct(object p0) => SR.GetString(nameof(TextNTextAndImageCannotOccurInDistinct), p0);

        internal static string TextNTextAndImageCannotOccurInUnion(object p0) => SR.GetString(nameof(TextNTextAndImageCannotOccurInUnion), p0);

        internal static string MaxSizeNotSupported(object p0) => SR.GetString(nameof(MaxSizeNotSupported), p0);

        internal static string IndexOfWithStringComparisonArgNotSupported => SR.GetString(nameof(IndexOfWithStringComparisonArgNotSupported));

        internal static string LastIndexOfWithStringComparisonArgNotSupported => SR.GetString(nameof(LastIndexOfWithStringComparisonArgNotSupported));

        internal static string ConvertToCharFromBoolNotSupported => SR.GetString(nameof(ConvertToCharFromBoolNotSupported));

        internal static string ConvertToDateTimeOnlyForDateTimeOrString => SR.GetString(nameof(ConvertToDateTimeOnlyForDateTimeOrString));

        internal static string CannotTranslateExpressionToSql => SR.GetString(nameof(CannotTranslateExpressionToSql));

        internal static string SkipIsValidOnlyOverOrderedQueries => SR.GetString(nameof(SkipIsValidOnlyOverOrderedQueries));

        internal static string SkipRequiresSingleTableQueryWithPKs => SR.GetString(nameof(SkipRequiresSingleTableQueryWithPKs));

        internal static string NoMethodInTypeMatchingArguments(object p0) => SR.GetString(nameof(NoMethodInTypeMatchingArguments), p0);

        internal static string CannotConvertToEntityRef(object p0) => SR.GetString(nameof(CannotConvertToEntityRef), p0);

        internal static string ExpressionNotDeferredQuerySource => SR.GetString(nameof(ExpressionNotDeferredQuerySource));

        internal static string DeferredMemberWrongType => SR.GetString(nameof(DeferredMemberWrongType));

        internal static string ArgumentWrongType(object p0, object p1, object p2) => SR.GetString(nameof(ArgumentWrongType), p0, p1, p2);

        internal static string ArgumentWrongValue(object p0) => SR.GetString(nameof(ArgumentWrongValue), p0);

        internal static string BadProjectionInSelect => SR.GetString(nameof(BadProjectionInSelect));

        internal static string InvalidReturnFromSproc(object p0) => SR.GetString(nameof(InvalidReturnFromSproc), p0);

        internal static string WrongDataContext => SR.GetString(nameof(WrongDataContext));

        internal static string BinaryOperatorNotRecognized(object p0) => SR.GetString(nameof(BinaryOperatorNotRecognized), p0);

        internal static string CannotAggregateType(object p0) => SR.GetString(nameof(CannotAggregateType), p0);

        internal static string CannotCompareItemsAssociatedWithDifferentTable => SR.GetString(nameof(CannotCompareItemsAssociatedWithDifferentTable));

        internal static string CannotDeleteTypesOf(object p0) => SR.GetString(nameof(CannotDeleteTypesOf), p0);

        internal static string ClassLiteralsNotAllowed(object p0) => SR.GetString(nameof(ClassLiteralsNotAllowed), p0);

        internal static string ClientCaseShouldNotHold(object p0) => SR.GetString(nameof(ClientCaseShouldNotHold), p0);

        internal static string ClrBoolDoesNotAgreeWithSqlType(object p0) => SR.GetString(nameof(ClrBoolDoesNotAgreeWithSqlType), p0);

        internal static string ColumnCannotReferToItself => SR.GetString(nameof(ColumnCannotReferToItself));

        internal static string ColumnClrTypeDoesNotAgreeWithExpressionsClrType => SR.GetString(nameof(ColumnClrTypeDoesNotAgreeWithExpressionsClrType));

        internal static string ColumnIsDefinedInMultiplePlaces(object p0) => SR.GetString(nameof(ColumnIsDefinedInMultiplePlaces), p0);

        internal static string ColumnIsNotAccessibleThroughGroupBy(object p0) => SR.GetString(nameof(ColumnIsNotAccessibleThroughGroupBy), p0);

        internal static string ColumnIsNotAccessibleThroughDistinct(object p0) => SR.GetString(nameof(ColumnIsNotAccessibleThroughDistinct), p0);

        internal static string ColumnReferencedIsNotInScope(object p0) => SR.GetString(nameof(ColumnReferencedIsNotInScope), p0);

        internal static string ConstructedArraysNotSupported => SR.GetString(nameof(ConstructedArraysNotSupported));

        internal static string ParametersCannotBeSequences => SR.GetString(nameof(ParametersCannotBeSequences));

        internal static string CapturedValuesCannotBeSequences => SR.GetString(nameof(CapturedValuesCannotBeSequences));

        internal static string IQueryableCannotReturnSelfReferencingConstantExpression => SR.GetString(nameof(IQueryableCannotReturnSelfReferencingConstantExpression));

        internal static string CouldNotAssignSequence(object p0, object p1) => SR.GetString(nameof(CouldNotAssignSequence), p0, p1);

        internal static string CouldNotTranslateExpressionForReading(object p0) => SR.GetString(nameof(CouldNotTranslateExpressionForReading), p0);

        internal static string CouldNotGetClrType => SR.GetString(nameof(CouldNotGetClrType));

        internal static string CouldNotGetSqlType => SR.GetString(nameof(CouldNotGetSqlType));

        internal static string CouldNotHandleAliasRef(object p0) => SR.GetString(nameof(CouldNotHandleAliasRef), p0);

        internal static string DidNotExpectAs(object p0) => SR.GetString(nameof(DidNotExpectAs), p0);

        internal static string DidNotExpectTypeBinding => SR.GetString(nameof(DidNotExpectTypeBinding));

        internal static string DidNotExpectTypeChange(object p0, object p1) => SR.GetString(nameof(DidNotExpectTypeChange), p0, p1);

        internal static string EmptyCaseNotSupported => SR.GetString(nameof(EmptyCaseNotSupported));

        internal static string ExpectedNoObjectType => SR.GetString(nameof(ExpectedNoObjectType));

        internal static string ExpectedBitFoundPredicate => SR.GetString(nameof(ExpectedBitFoundPredicate));

        internal static string ExpectedClrTypesToAgree(object p0, object p1) => SR.GetString(nameof(ExpectedClrTypesToAgree), p0, p1);

        internal static string ExpectedPredicateFoundBit => SR.GetString(nameof(ExpectedPredicateFoundBit));

        internal static string ExpectedQueryableArgument(object p0, object p1, object p2) => SR.GetString(nameof(ExpectedQueryableArgument), p0, p1, p2);

        internal static string InvalidGroupByExpressionType(object p0) => SR.GetString(nameof(InvalidGroupByExpressionType), p0);

        internal static string InvalidGroupByExpression => SR.GetString(nameof(InvalidGroupByExpression));

        internal static string InvalidOrderByExpression(object p0) => SR.GetString(nameof(InvalidOrderByExpression), p0);

        internal static string Impossible => SR.GetString(nameof(Impossible));

        internal static string InfiniteDescent => SR.GetString(nameof(InfiniteDescent));

        internal static string InvalidFormatNode(object p0) => SR.GetString(nameof(InvalidFormatNode), p0);

        internal static string InvalidReferenceToRemovedAliasDuringDeflation => SR.GetString(nameof(InvalidReferenceToRemovedAliasDuringDeflation));

        internal static string InvalidSequenceOperatorCall(object p0) => SR.GetString(nameof(InvalidSequenceOperatorCall), p0);

        internal static string ParameterNotInScope(object p0) => SR.GetString(nameof(ParameterNotInScope), p0);

        internal static string MemberAccessIllegal(object p0, object p1, object p2) => SR.GetString(nameof(MemberAccessIllegal), p0, p1, p2);

        internal static string MemberCouldNotBeTranslated(object p0, object p1) => SR.GetString(nameof(MemberCouldNotBeTranslated), p0, p1);

        internal static string MemberNotPartOfProjection(object p0, object p1) => SR.GetString(nameof(MemberNotPartOfProjection), p0, p1);

        internal static string MethodHasNoSupportConversionToSql(object p0) => SR.GetString(nameof(MethodHasNoSupportConversionToSql), p0);

        internal static string MethodFormHasNoSupportConversionToSql(object p0, object p1) => SR.GetString(nameof(MethodFormHasNoSupportConversionToSql), p0, p1);

        internal static string UnableToBindUnmappedMember(object p0, object p1, object p2) => SR.GetString(nameof(UnableToBindUnmappedMember), p0, p1, p2);

        internal static string QueryOperatorNotSupported(object p0) => SR.GetString(nameof(QueryOperatorNotSupported), p0);

        internal static string QueryOperatorOverloadNotSupported(object p0) => SR.GetString(nameof(QueryOperatorOverloadNotSupported), p0);

        internal static string ReaderUsedAfterDispose => SR.GetString(nameof(ReaderUsedAfterDispose));

        internal static string RequiredColumnDoesNotExist(object p0) => SR.GetString(nameof(RequiredColumnDoesNotExist), p0);

        internal static string SimpleCaseShouldNotHold(object p0) => SR.GetString(nameof(SimpleCaseShouldNotHold), p0);

        internal static string TypeBinaryOperatorNotRecognized => SR.GetString(nameof(TypeBinaryOperatorNotRecognized));

        internal static string UnexpectedNode(object p0) => SR.GetString(nameof(UnexpectedNode), p0);

        internal static string UnexpectedFloatingColumn => SR.GetString(nameof(UnexpectedFloatingColumn));

        internal static string UnexpectedSharedExpression => SR.GetString(nameof(UnexpectedSharedExpression));

        internal static string UnexpectedSharedExpressionReference => SR.GetString(nameof(UnexpectedSharedExpressionReference));

        internal static string UnhandledBindingType(object p0) => SR.GetString(nameof(UnhandledBindingType), p0);

        internal static string UnhandledStringTypeComparison => SR.GetString(nameof(UnhandledStringTypeComparison));

        internal static string UnhandledMemberAccess(object p0, object p1) => SR.GetString(nameof(UnhandledMemberAccess), p0, p1);

        internal static string UnmappedDataMember(object p0, object p1, object p2) => SR.GetString(nameof(UnmappedDataMember), p0, p1, p2);

        internal static string UnrecognizedExpressionNode(object p0) => SR.GetString(nameof(UnrecognizedExpressionNode), p0);

        internal static string ValueHasNoLiteralInSql(object p0) => SR.GetString(nameof(ValueHasNoLiteralInSql), p0);

        internal static string UnionIncompatibleConstruction => SR.GetString(nameof(UnionIncompatibleConstruction));

        internal static string UnionDifferentMembers => SR.GetString(nameof(UnionDifferentMembers));

        internal static string UnionDifferentMemberOrder => SR.GetString(nameof(UnionDifferentMemberOrder));

        internal static string UnionOfIncompatibleDynamicTypes => SR.GetString(nameof(UnionOfIncompatibleDynamicTypes));

        internal static string UnionWithHierarchy => SR.GetString(nameof(UnionWithHierarchy));

        internal static string UnhandledExpressionType(object p0) => SR.GetString(nameof(UnhandledExpressionType), p0);

        internal static string IntersectNotSupportedForHierarchicalTypes => SR.GetString(nameof(IntersectNotSupportedForHierarchicalTypes));

        internal static string ExceptNotSupportedForHierarchicalTypes => SR.GetString(nameof(ExceptNotSupportedForHierarchicalTypes));

        internal static string NonCountAggregateFunctionsAreNotValidOnProjections(object p0) => SR.GetString(nameof(NonCountAggregateFunctionsAreNotValidOnProjections), p0);

        internal static string GroupingNotSupportedAsOrderCriterion => SR.GetString(nameof(GroupingNotSupportedAsOrderCriterion));

        internal static string SourceExpressionAnnotation(object p0) => SR.GetString(nameof(SourceExpressionAnnotation), p0);

        internal static string SelectManyDoesNotSupportStrings => SR.GetString(nameof(SelectManyDoesNotSupportStrings));

        internal static string SequenceOperatorsNotSupportedForType(object p0) => SR.GetString(nameof(SequenceOperatorsNotSupportedForType), p0);

        internal static string SkipNotSupportedForSequenceTypes => SR.GetString(nameof(SkipNotSupportedForSequenceTypes));

        internal static string ComparisonNotSupportedForType(object p0) => SR.GetString(nameof(ComparisonNotSupportedForType), p0);

        internal static string QueryOnLocalCollectionNotSupported => SR.GetString(nameof(QueryOnLocalCollectionNotSupported));

        internal static string UnsupportedNodeType(object p0) => SR.GetString(nameof(UnsupportedNodeType), p0);

        internal static string TypeColumnWithUnhandledSource => SR.GetString(nameof(TypeColumnWithUnhandledSource));

        internal static string GeneralCollectionMaterializationNotSupported => SR.GetString(nameof(GeneralCollectionMaterializationNotSupported));

        internal static string TypeCannotBeOrdered(object p0) => SR.GetString(nameof(TypeCannotBeOrdered), p0);

        internal static string InvalidMethodExecution(object p0) => SR.GetString(nameof(InvalidMethodExecution), p0);

        internal static string SprocsCannotBeComposed => SR.GetString(nameof(SprocsCannotBeComposed));

        internal static string InsertItemMustBeConstant => SR.GetString(nameof(InsertItemMustBeConstant));

        internal static string UpdateItemMustBeConstant => SR.GetString(nameof(UpdateItemMustBeConstant));

        internal static string CouldNotConvertToPropertyOrField(object p0) => SR.GetString(nameof(CouldNotConvertToPropertyOrField), p0);

        internal static string BadParameterType(object p0) => SR.GetString(nameof(BadParameterType), p0);

        internal static string CannotAssignToMember(object p0) => SR.GetString(nameof(CannotAssignToMember), p0);

        internal static string MappedTypeMustHaveDefaultConstructor(object p0) => SR.GetString(nameof(MappedTypeMustHaveDefaultConstructor), p0);

        internal static string UnsafeStringConversion(object p0, object p1) => SR.GetString(nameof(UnsafeStringConversion), p0, p1);

        internal static string CannotAssignNull(object p0) => SR.GetString(nameof(CannotAssignNull), p0);

        internal static string ProviderNotInstalled(object p0, object p1) => SR.GetString(nameof(ProviderNotInstalled), p0, p1);

        internal static string InvalidProviderType(object p0) => SR.GetString(nameof(InvalidProviderType), p0);

        internal static string InvalidDbGeneratedType(object p0) => SR.GetString(nameof(InvalidDbGeneratedType), p0);

        internal static string DatabaseDeleteThroughContext => SR.GetString(nameof(DatabaseDeleteThroughContext));

        internal static string CannotMaterializeEntityType(object p0) => SR.GetString(nameof(CannotMaterializeEntityType), p0);

        internal static string CannotMaterializeList(object p0) => SR.GetString(nameof(CannotMaterializeList), p0);

        internal static string CouldNotConvert(object p0, object p1) => SR.GetString(nameof(CouldNotConvert), p0, p1);
    }
}
