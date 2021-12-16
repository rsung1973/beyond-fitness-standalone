// Decompiled with JetBrains decompiler
// Type: System.Data.Linq.SqlClient.Error
// Assembly: System.Data.Linq, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089
// MVID: 43A00CAE-A2D4-43EB-9464-93379DA02EC9
// Assembly location: C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Data.Linq.dll

using System.Collections.ObjectModel;
using System.Text;
using System.Transactions;

namespace System.Data.Linq.SqlClient
{
    internal static class Error
    {
        internal static Exception VbLikeDoesNotSupportMultipleCharacterRanges() => (Exception)new ArgumentException(Strings.VbLikeDoesNotSupportMultipleCharacterRanges);

        internal static Exception VbLikeUnclosedBracket() => (Exception)new ArgumentException(Strings.VbLikeUnclosedBracket);

        internal static Exception UnrecognizedProviderMode(object p0) => (Exception)new InvalidOperationException(Strings.UnrecognizedProviderMode(p0));

        internal static Exception CompiledQueryCannotReturnType(object p0) => (Exception)new InvalidOperationException(Strings.CompiledQueryCannotReturnType(p0));

        internal static Exception ArgumentEmpty(object p0) => (Exception)new ArgumentException(Strings.ArgumentEmpty(p0));

        internal static Exception ProviderCannotBeUsedAfterDispose() => (Exception)new ObjectDisposedException(Strings.ProviderCannotBeUsedAfterDispose);

        internal static Exception ArgumentTypeMismatch(object p0) => (Exception)new ArgumentException(Strings.ArgumentTypeMismatch(p0));

        internal static Exception ContextNotInitialized() => (Exception)new InvalidOperationException(Strings.ContextNotInitialized);

        internal static Exception CouldNotDetermineSqlType(object p0) => (Exception)new InvalidOperationException(Strings.CouldNotDetermineSqlType(p0));

        internal static Exception CouldNotDetermineDbGeneratedSqlType(object p0) => (Exception)new InvalidOperationException(Strings.CouldNotDetermineDbGeneratedSqlType(p0));

        internal static Exception CouldNotDetermineCatalogName() => (Exception)new InvalidOperationException(Strings.CouldNotDetermineCatalogName);

        internal static Exception CreateDatabaseFailedBecauseOfClassWithNoMembers(object p0) => (Exception)new InvalidOperationException(Strings.CreateDatabaseFailedBecauseOfClassWithNoMembers(p0));

        internal static Exception CreateDatabaseFailedBecauseOfContextWithNoTables(object p0) => (Exception)new InvalidOperationException(Strings.CreateDatabaseFailedBecauseOfContextWithNoTables(p0));

        internal static Exception CreateDatabaseFailedBecauseSqlCEDatabaseAlreadyExists(
          object p0)
        {
            return (Exception)new InvalidOperationException(Strings.CreateDatabaseFailedBecauseSqlCEDatabaseAlreadyExists(p0));
        }

        internal static Exception DistributedTransactionsAreNotAllowed() => (Exception)new TransactionPromotionException(Strings.DistributedTransactionsAreNotAllowed);

        internal static Exception InvalidConnectionArgument(object p0) => (Exception)new ArgumentException(Strings.InvalidConnectionArgument(p0));

        internal static Exception CannotEnumerateResultsMoreThanOnce() => (Exception)new InvalidOperationException(Strings.CannotEnumerateResultsMoreThanOnce);

        internal static Exception IifReturnTypesMustBeEqual(object p0, object p1) => (Exception)new NotSupportedException(Strings.IifReturnTypesMustBeEqual(p0, p1));

        internal static Exception MethodNotMappedToStoredProcedure(object p0) => (Exception)new InvalidOperationException(Strings.MethodNotMappedToStoredProcedure(p0));

        internal static Exception ResultTypeNotMappedToFunction(object p0, object p1) => (Exception)new InvalidOperationException(Strings.ResultTypeNotMappedToFunction(p0, p1));

        internal static Exception ToStringOnlySupportedForPrimitiveTypes() => (Exception)new NotSupportedException(Strings.ToStringOnlySupportedForPrimitiveTypes);

        internal static Exception TransactionDoesNotMatchConnection() => (Exception)new InvalidOperationException(Strings.TransactionDoesNotMatchConnection);

        internal static Exception UnexpectedTypeCode(object p0) => (Exception)new InvalidOperationException(Strings.UnexpectedTypeCode(p0));

        internal static Exception UnsupportedDateTimeConstructorForm() => (Exception)new NotSupportedException(Strings.UnsupportedDateTimeConstructorForm);

        internal static Exception UnsupportedDateTimeOffsetConstructorForm() => (Exception)new NotSupportedException(Strings.UnsupportedDateTimeOffsetConstructorForm);

        internal static Exception UnsupportedStringConstructorForm() => (Exception)new NotSupportedException(Strings.UnsupportedStringConstructorForm);

        internal static Exception UnsupportedTimeSpanConstructorForm() => (Exception)new NotSupportedException(Strings.UnsupportedTimeSpanConstructorForm);

        internal static Exception UnsupportedTypeConstructorForm(object p0) => (Exception)new NotSupportedException(Strings.UnsupportedTypeConstructorForm(p0));

        internal static Exception WrongNumberOfValuesInCollectionArgument(
          object p0,
          object p1,
          object p2)
        {
            return (Exception)new ArgumentException(Strings.WrongNumberOfValuesInCollectionArgument(p0, p1, p2));
        }

        internal static Exception MemberCannotBeTranslated(object p0, object p1) => (Exception)new NotSupportedException(Strings.MemberCannotBeTranslated(p0, p1));

        internal static Exception NonConstantExpressionsNotSupportedFor(object p0) => (Exception)new NotSupportedException(Strings.NonConstantExpressionsNotSupportedFor(p0));

        internal static Exception MathRoundNotSupported() => (Exception)new NotSupportedException(Strings.MathRoundNotSupported);

        internal static Exception SqlMethodOnlyForSql(object p0) => (Exception)new NotSupportedException(Strings.SqlMethodOnlyForSql(p0));

        internal static Exception NonConstantExpressionsNotSupportedForRounding() => (Exception)new NotSupportedException(Strings.NonConstantExpressionsNotSupportedForRounding);

        internal static Exception CompiledQueryAgainstMultipleShapesNotSupported() => (Exception)new NotSupportedException(Strings.CompiledQueryAgainstMultipleShapesNotSupported);

        internal static Exception IndexOfWithStringComparisonArgNotSupported() => (Exception)new NotSupportedException(Strings.IndexOfWithStringComparisonArgNotSupported);

        internal static Exception LastIndexOfWithStringComparisonArgNotSupported() => (Exception)new NotSupportedException(Strings.LastIndexOfWithStringComparisonArgNotSupported);

        internal static Exception ConvertToCharFromBoolNotSupported() => (Exception)new NotSupportedException(Strings.ConvertToCharFromBoolNotSupported);

        internal static Exception ConvertToDateTimeOnlyForDateTimeOrString() => (Exception)new NotSupportedException(Strings.ConvertToDateTimeOnlyForDateTimeOrString);

        internal static Exception SkipIsValidOnlyOverOrderedQueries() => (Exception)new InvalidOperationException(Strings.SkipIsValidOnlyOverOrderedQueries);

        internal static Exception SkipRequiresSingleTableQueryWithPKs() => (Exception)new NotSupportedException(Strings.SkipRequiresSingleTableQueryWithPKs);

        internal static Exception NoMethodInTypeMatchingArguments(object p0) => (Exception)new InvalidOperationException(Strings.NoMethodInTypeMatchingArguments(p0));

        internal static Exception CannotConvertToEntityRef(object p0) => (Exception)new InvalidOperationException(Strings.CannotConvertToEntityRef(p0));

        internal static Exception ExpressionNotDeferredQuerySource() => (Exception)new InvalidOperationException(Strings.ExpressionNotDeferredQuerySource);

        internal static Exception DeferredMemberWrongType() => (Exception)new InvalidOperationException(Strings.DeferredMemberWrongType);

        internal static Exception ArgumentWrongType(object p0, object p1, object p2) => (Exception)new ArgumentException(Strings.ArgumentWrongType(p0, p1, p2));

        internal static Exception ArgumentWrongValue(object p0) => (Exception)new ArgumentException(Strings.ArgumentWrongValue(p0));

        internal static Exception BadProjectionInSelect() => (Exception)new InvalidOperationException(Strings.BadProjectionInSelect);

        internal static Exception InvalidReturnFromSproc(object p0) => (Exception)new InvalidOperationException(Strings.InvalidReturnFromSproc(p0));

        internal static Exception WrongDataContext() => (Exception)new InvalidOperationException(Strings.WrongDataContext);

        internal static Exception BinaryOperatorNotRecognized(object p0) => (Exception)new InvalidOperationException(Strings.BinaryOperatorNotRecognized(p0));

        internal static Exception CannotAggregateType(object p0) => (Exception)new NotSupportedException(Strings.CannotAggregateType(p0));

        internal static Exception CannotCompareItemsAssociatedWithDifferentTable() => (Exception)new InvalidOperationException(Strings.CannotCompareItemsAssociatedWithDifferentTable);

        internal static Exception CannotDeleteTypesOf(object p0) => (Exception)new InvalidOperationException(Strings.CannotDeleteTypesOf(p0));

        internal static Exception ClassLiteralsNotAllowed(object p0) => (Exception)new InvalidOperationException(Strings.ClassLiteralsNotAllowed(p0));

        internal static Exception ClientCaseShouldNotHold(object p0) => (Exception)new InvalidOperationException(Strings.ClientCaseShouldNotHold(p0));

        internal static Exception ClrBoolDoesNotAgreeWithSqlType(object p0) => (Exception)new InvalidOperationException(Strings.ClrBoolDoesNotAgreeWithSqlType(p0));

        internal static Exception ColumnCannotReferToItself() => (Exception)new InvalidOperationException(Strings.ColumnCannotReferToItself);

        internal static Exception ColumnClrTypeDoesNotAgreeWithExpressionsClrType() => (Exception)new InvalidOperationException(Strings.ColumnClrTypeDoesNotAgreeWithExpressionsClrType);

        internal static Exception ColumnIsDefinedInMultiplePlaces(object p0) => (Exception)new InvalidOperationException(Strings.ColumnIsDefinedInMultiplePlaces(p0));

        internal static Exception ColumnIsNotAccessibleThroughGroupBy(object p0) => (Exception)new InvalidOperationException(Strings.ColumnIsNotAccessibleThroughGroupBy(p0));

        internal static Exception ColumnIsNotAccessibleThroughDistinct(object p0) => (Exception)new InvalidOperationException(Strings.ColumnIsNotAccessibleThroughDistinct(p0));

        internal static Exception ColumnReferencedIsNotInScope(object p0) => (Exception)new InvalidOperationException(Strings.ColumnReferencedIsNotInScope(p0));

        internal static Exception ConstructedArraysNotSupported() => (Exception)new NotSupportedException(Strings.ConstructedArraysNotSupported);

        internal static Exception ParametersCannotBeSequences() => (Exception)new NotSupportedException(Strings.ParametersCannotBeSequences);

        internal static Exception CapturedValuesCannotBeSequences() => (Exception)new NotSupportedException(Strings.CapturedValuesCannotBeSequences);

        internal static Exception IQueryableCannotReturnSelfReferencingConstantExpression() => (Exception)new NotSupportedException(Strings.IQueryableCannotReturnSelfReferencingConstantExpression);

        internal static Exception CouldNotAssignSequence(object p0, object p1) => (Exception)new InvalidOperationException(Strings.CouldNotAssignSequence(p0, p1));

        internal static Exception CouldNotTranslateExpressionForReading(object p0) => (Exception)new InvalidOperationException(Strings.CouldNotTranslateExpressionForReading(p0));

        internal static Exception CouldNotGetClrType() => (Exception)new InvalidOperationException(Strings.CouldNotGetClrType);

        internal static Exception CouldNotGetSqlType() => (Exception)new InvalidOperationException(Strings.CouldNotGetSqlType);

        internal static Exception CouldNotHandleAliasRef(object p0) => (Exception)new InvalidOperationException(Strings.CouldNotHandleAliasRef(p0));

        internal static Exception DidNotExpectAs(object p0) => (Exception)new InvalidOperationException(Strings.DidNotExpectAs(p0));

        internal static Exception DidNotExpectTypeBinding() => (Exception)new InvalidOperationException(Strings.DidNotExpectTypeBinding);

        internal static Exception DidNotExpectTypeChange(object p0, object p1) => (Exception)new InvalidOperationException(Strings.DidNotExpectTypeChange(p0, p1));

        internal static Exception EmptyCaseNotSupported() => (Exception)new InvalidOperationException(Strings.EmptyCaseNotSupported);

        internal static Exception ExpectedNoObjectType() => (Exception)new InvalidOperationException(Strings.ExpectedNoObjectType);

        internal static Exception ExpectedBitFoundPredicate() => (Exception)new ArgumentException(Strings.ExpectedBitFoundPredicate);

        internal static Exception ExpectedClrTypesToAgree(object p0, object p1) => (Exception)new InvalidOperationException(Strings.ExpectedClrTypesToAgree(p0, p1));

        internal static Exception ExpectedPredicateFoundBit() => (Exception)new ArgumentException(Strings.ExpectedPredicateFoundBit);

        internal static Exception ExpectedQueryableArgument(object p0, object p1, object p2) => (Exception)new ArgumentException(Strings.ExpectedQueryableArgument(p0, p1, p2));

        internal static Exception InvalidGroupByExpressionType(object p0) => (Exception)new NotSupportedException(Strings.InvalidGroupByExpressionType(p0));

        internal static Exception InvalidGroupByExpression() => (Exception)new NotSupportedException(Strings.InvalidGroupByExpression);

        internal static Exception InvalidOrderByExpression(object p0) => (Exception)new NotSupportedException(Strings.InvalidOrderByExpression(p0));

        internal static Exception Impossible() => (Exception)new InvalidOperationException(Strings.Impossible);

        internal static Exception InfiniteDescent() => (Exception)new InvalidOperationException(Strings.InfiniteDescent);

        internal static Exception InvalidFormatNode(object p0) => (Exception)new InvalidOperationException(Strings.InvalidFormatNode(p0));

        internal static Exception InvalidReferenceToRemovedAliasDuringDeflation() => (Exception)new InvalidOperationException(Strings.InvalidReferenceToRemovedAliasDuringDeflation);

        internal static Exception InvalidSequenceOperatorCall(object p0) => (Exception)new InvalidOperationException(Strings.InvalidSequenceOperatorCall(p0));

        internal static Exception ParameterNotInScope(object p0) => (Exception)new InvalidOperationException(Strings.ParameterNotInScope(p0));

        internal static Exception MemberAccessIllegal(object p0, object p1, object p2) => (Exception)new InvalidOperationException(Strings.MemberAccessIllegal(p0, p1, p2));

        internal static Exception MemberCouldNotBeTranslated(object p0, object p1) => (Exception)new InvalidOperationException(Strings.MemberCouldNotBeTranslated(p0, p1));

        internal static Exception MemberNotPartOfProjection(object p0, object p1) => (Exception)new InvalidOperationException(Strings.MemberNotPartOfProjection(p0, p1));

        internal static Exception MethodHasNoSupportConversionToSql(object p0) => (Exception)new NotSupportedException(Strings.MethodHasNoSupportConversionToSql(p0));

        internal static Exception MethodFormHasNoSupportConversionToSql(object p0, object p1) => (Exception)new NotSupportedException(Strings.MethodFormHasNoSupportConversionToSql(p0, p1));

        internal static Exception UnableToBindUnmappedMember(object p0, object p1, object p2) => (Exception)new InvalidOperationException(Strings.UnableToBindUnmappedMember(p0, p1, p2));

        internal static Exception QueryOperatorNotSupported(object p0) => (Exception)new NotSupportedException(Strings.QueryOperatorNotSupported(p0));

        internal static Exception QueryOperatorOverloadNotSupported(object p0) => (Exception)new NotSupportedException(Strings.QueryOperatorOverloadNotSupported(p0));

        internal static Exception ReaderUsedAfterDispose() => (Exception)new InvalidOperationException(Strings.ReaderUsedAfterDispose);

        internal static Exception RequiredColumnDoesNotExist(object p0) => (Exception)new InvalidOperationException(Strings.RequiredColumnDoesNotExist(p0));

        internal static Exception SimpleCaseShouldNotHold(object p0) => (Exception)new InvalidOperationException(Strings.SimpleCaseShouldNotHold(p0));

        internal static Exception TypeBinaryOperatorNotRecognized() => (Exception)new InvalidOperationException(Strings.TypeBinaryOperatorNotRecognized);

        internal static Exception UnexpectedNode(object p0) => (Exception)new InvalidOperationException(Strings.UnexpectedNode(p0));

        internal static Exception UnexpectedFloatingColumn() => (Exception)new InvalidOperationException(Strings.UnexpectedFloatingColumn);

        internal static Exception UnexpectedSharedExpression() => (Exception)new InvalidOperationException(Strings.UnexpectedSharedExpression);

        internal static Exception UnexpectedSharedExpressionReference() => (Exception)new InvalidOperationException(Strings.UnexpectedSharedExpressionReference);

        internal static Exception UnhandledBindingType(object p0) => (Exception)new InvalidOperationException(Strings.UnhandledBindingType(p0));

        internal static Exception UnhandledStringTypeComparison() => (Exception)new NotSupportedException(Strings.UnhandledStringTypeComparison);

        internal static Exception UnhandledMemberAccess(object p0, object p1) => (Exception)new InvalidOperationException(Strings.UnhandledMemberAccess(p0, p1));

        internal static Exception UnmappedDataMember(object p0, object p1, object p2) => (Exception)new InvalidOperationException(Strings.UnmappedDataMember(p0, p1, p2));

        internal static Exception UnrecognizedExpressionNode(object p0) => (Exception)new InvalidOperationException(Strings.UnrecognizedExpressionNode(p0));

        internal static Exception ValueHasNoLiteralInSql(object p0) => (Exception)new InvalidOperationException(Strings.ValueHasNoLiteralInSql(p0));

        internal static Exception UnionIncompatibleConstruction() => (Exception)new NotSupportedException(Strings.UnionIncompatibleConstruction);

        internal static Exception UnionDifferentMembers() => (Exception)new NotSupportedException(Strings.UnionDifferentMembers);

        internal static Exception UnionDifferentMemberOrder() => (Exception)new NotSupportedException(Strings.UnionDifferentMemberOrder);

        internal static Exception UnionOfIncompatibleDynamicTypes() => (Exception)new NotSupportedException(Strings.UnionOfIncompatibleDynamicTypes);

        internal static Exception UnionWithHierarchy() => (Exception)new NotSupportedException(Strings.UnionWithHierarchy);

        internal static Exception UnhandledExpressionType(object p0) => (Exception)new ArgumentException(Strings.UnhandledExpressionType(p0));

        internal static Exception IntersectNotSupportedForHierarchicalTypes() => (Exception)new NotSupportedException(Strings.IntersectNotSupportedForHierarchicalTypes);

        internal static Exception ExceptNotSupportedForHierarchicalTypes() => (Exception)new NotSupportedException(Strings.ExceptNotSupportedForHierarchicalTypes);

        internal static Exception NonCountAggregateFunctionsAreNotValidOnProjections(object p0) => (Exception)new NotSupportedException(Strings.NonCountAggregateFunctionsAreNotValidOnProjections(p0));

        internal static Exception GroupingNotSupportedAsOrderCriterion() => (Exception)new NotSupportedException(Strings.GroupingNotSupportedAsOrderCriterion);

        internal static Exception SelectManyDoesNotSupportStrings() => (Exception)new ArgumentException(Strings.SelectManyDoesNotSupportStrings);

        internal static Exception SequenceOperatorsNotSupportedForType(object p0) => (Exception)new NotSupportedException(Strings.SequenceOperatorsNotSupportedForType(p0));

        internal static Exception SkipNotSupportedForSequenceTypes() => (Exception)new NotSupportedException(Strings.SkipNotSupportedForSequenceTypes);

        internal static Exception ComparisonNotSupportedForType(object p0) => (Exception)new NotSupportedException(Strings.ComparisonNotSupportedForType(p0));

        internal static Exception QueryOnLocalCollectionNotSupported() => (Exception)new NotSupportedException(Strings.QueryOnLocalCollectionNotSupported);

        internal static Exception UnsupportedNodeType(object p0) => (Exception)new NotSupportedException(Strings.UnsupportedNodeType(p0));

        internal static Exception TypeColumnWithUnhandledSource() => (Exception)new InvalidOperationException(Strings.TypeColumnWithUnhandledSource);

        internal static Exception GeneralCollectionMaterializationNotSupported() => (Exception)new NotSupportedException(Strings.GeneralCollectionMaterializationNotSupported);

        internal static Exception TypeCannotBeOrdered(object p0) => (Exception)new InvalidOperationException(Strings.TypeCannotBeOrdered(p0));

        internal static Exception InvalidMethodExecution(object p0) => (Exception)new InvalidOperationException(Strings.InvalidMethodExecution(p0));

        internal static Exception SprocsCannotBeComposed() => (Exception)new InvalidOperationException(Strings.SprocsCannotBeComposed);

        internal static Exception InsertItemMustBeConstant() => (Exception)new NotSupportedException(Strings.InsertItemMustBeConstant);

        internal static Exception UpdateItemMustBeConstant() => (Exception)new NotSupportedException(Strings.UpdateItemMustBeConstant);

        internal static Exception CouldNotConvertToPropertyOrField(object p0) => (Exception)new InvalidOperationException(Strings.CouldNotConvertToPropertyOrField(p0));

        internal static Exception BadParameterType(object p0) => (Exception)new NotSupportedException(Strings.BadParameterType(p0));

        internal static Exception CannotAssignToMember(object p0) => (Exception)new InvalidOperationException(Strings.CannotAssignToMember(p0));

        internal static Exception MappedTypeMustHaveDefaultConstructor(object p0) => (Exception)new InvalidOperationException(Strings.MappedTypeMustHaveDefaultConstructor(p0));

        internal static Exception UnsafeStringConversion(object p0, object p1) => (Exception)new FormatException(Strings.UnsafeStringConversion(p0, p1));

        internal static Exception CannotAssignNull(object p0) => (Exception)new InvalidOperationException(Strings.CannotAssignNull(p0));

        internal static Exception ProviderNotInstalled(object p0, object p1) => (Exception)new InvalidOperationException(Strings.ProviderNotInstalled(p0, p1));

        internal static Exception InvalidProviderType(object p0) => (Exception)new NotSupportedException(Strings.InvalidProviderType(p0));

        internal static Exception InvalidDbGeneratedType(object p0) => (Exception)new NotSupportedException(Strings.InvalidDbGeneratedType(p0));

        internal static Exception DatabaseDeleteThroughContext() => (Exception)new InvalidOperationException(Strings.DatabaseDeleteThroughContext);

        internal static Exception CannotMaterializeEntityType(object p0) => (Exception)new NotSupportedException(Strings.CannotMaterializeEntityType(p0));

        internal static Exception CannotMaterializeList(object p0) => (Exception)new NotSupportedException(Strings.CannotMaterializeList(p0));

        internal static Exception CouldNotConvert(object p0, object p1) => (Exception)new InvalidCastException(Strings.CouldNotConvert(p0, p1));

        internal static Exception ArgumentNull(string paramName) => (Exception)new ArgumentNullException(paramName);

        internal static Exception ArgumentOutOfRange(string paramName) => (Exception)new ArgumentOutOfRangeException(paramName);

        internal static Exception NotImplemented() => (Exception)new NotImplementedException();

        internal static Exception NotSupported() => (Exception)new NotSupportedException();

        internal static Exception ExpressionNotSupportedForSqlServerVersion(
          Collection<string> reasons)
        {
            StringBuilder stringBuilder = new StringBuilder(Strings.CannotTranslateExpressionToSql);
            foreach (string reason in reasons)
                stringBuilder.AppendLine(reason);
            return (Exception)new NotSupportedException(stringBuilder.ToString());
        }
    }
}
