namespace Presentation.Api.CustomHandlers
{
    using System.Web.Mvc;
    using System.Web.Routing;

    /// <summary>
    /// 
    /// </summary>
    public class AuthorizeUserAttribute : AuthorizeAttribute
    {
        /// <summary>
        /// 
        /// </summary>
        /// <param name="filterContext"></param>
        protected override void HandleUnauthorizedRequest(AuthorizationContext filterContext)
        {
            filterContext.Result = new RedirectToRouteResult(
                new RouteValueDictionary(
                    new
                    {
                        controller = "Error",
                        action = "Unauthorised"
                    })
                );
        }
    }
}