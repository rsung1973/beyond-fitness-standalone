using System;
using System.Web.Mvc;
using System.Web.Routing;

namespace CommonLib.MvcExtension
{
    public class TransferToRouteResult : ActionResult
    {
        public TransferToRouteResult(string actionName, string controllerName, object routeValues)
            : this(actionName, controllerName, routeValues == null ? null : new RouteValueDictionary(routeValues))
        {
        }

        public TransferToRouteResult(string actionName, string controllerName, RouteValueDictionary routeValues)
        {
            ActionName = actionName;
            ControllerName = controllerName;
            RouteValues = routeValues == null ? new RouteValueDictionary() : new RouteValueDictionary(routeValues);
        }

        /// <summary>
        /// Gets or sets the name of the action to use for generating the URL.
        /// </summary>
        public string ActionName { get; set; }

        /// <summary>
        /// Gets or sets the name of the controller to use for generating the URL.
        /// </summary>
        public string ControllerName { get; set; }

        /// <summary>
        /// Gets or sets the route data to use for generating the URL.
        /// </summary>
        public RouteValueDictionary RouteValues { get; set; }

        public override void ExecuteResult(ControllerContext context)
        {
            if (context == null)
            {
                throw new ArgumentNullException(nameof(context));
            }

            RouteValues.Add(TransferActionOnlyAttribute.IsTransferActionMarker, true);

            var urlHelper = new UrlHelper(context.RequestContext);
            var destinationUrl = urlHelper.Action(ActionName, ControllerName, RouteValues);
            if (string.IsNullOrEmpty(destinationUrl))
            {
                throw new InvalidOperationException("NoRoutesMatched");
            }

            context.HttpContext.Server.TransferRequest(destinationUrl, true);
        }
    }
}