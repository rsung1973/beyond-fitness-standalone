using System;
using System.Web.Mvc;
/// <summary>Represents an attribute that is used to indicate that an action method should be called only from a TransferToAction.</summary>
namespace CommonLib.MvcExtension
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = false, Inherited = true)]
    public sealed class TransferActionOnlyAttribute : FilterAttribute, IAuthorizationFilter
    {
        public const string IsTransferActionMarker = "IsTransferAction";

        /// <summary>Called when authorization is required.</summary>
        /// <param name="filterContext">An object that encapsulates the information that is required in order to authorize access to the transfer action.</param>
        public void OnAuthorization(AuthorizationContext filterContext)
        {
            if (filterContext == null)
            {
                throw new ArgumentNullException(nameof(filterContext));
            }

            if (!filterContext.IsTransferAction())
            {
                throw new InvalidOperationException(string.Format("The action '{0}' is accessible only by a transfer request.", filterContext.ActionDescriptor.ActionName));
            }
        }
    }
}