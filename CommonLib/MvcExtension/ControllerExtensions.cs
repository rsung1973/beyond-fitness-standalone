using System.Web.Mvc;

namespace CommonLib.MvcExtension
{
    public static class ControllerExtensions
    {
        /// <summary>
        /// Transfers to the specified action using the <paramref name="actionName"/>
        /// and the <paramref name="controllerName"/>.
        /// </summary>
        /// <param name="actionName">The name of the action.</param>
        /// <param name="controllerName">The name of the controller.</param>
        /// <returns>The created <see cref="TransferToRouteResult"/> for the response.</returns>

        [NonAction]
        public static TransferToRouteResult TransferToAction(this Controller controller, string actionName, string controllerName)
        {
            return TransferToAction(controller, actionName, controllerName, routeValues: null);
        }

        /// <summary>
        /// Transfers to the specified action using the specified <paramref name="actionName"/>,
        /// <paramref name="controllerName"/>, and <paramref name="routeValues"/>.
        /// </summary>
        /// <param name="actionName">The name of the action.</param>
        /// <param name="controllerName">The name of the controller.</param>
        /// <param name="routeValues">The parameters for a route.</param>
        /// <returns>The created <see cref="TransferToRouteResult"/> for the response.</returns>
        [NonAction]
        public static TransferToRouteResult TransferToAction(this Controller controller, string actionName, string controllerName, object routeValues)
        {
            return new TransferToRouteResult(actionName, controllerName, routeValues);
        }
    }
}