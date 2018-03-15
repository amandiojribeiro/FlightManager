namespace Presentation.Api.Controllers
{
    using Microsoft.AspNet.Identity;
    using Microsoft.AspNet.Identity.Owin;
    using Microsoft.Owin.Security;
    using System.Collections.Generic;
    using System.Linq;
    using System.Security.Claims;
    using System.Web;
    using System.Web.Mvc;

    /// <summary>
    /// 
    /// </summary>
    [AllowAnonymous]
    public class LoginController : Controller
    {
        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [AllowAnonymous]
        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [AllowAnonymous]
        [HttpPost]
        public ActionResult Login(Models.User user)
        {
            if (ModelState.IsValid)
            {
                string[] userRoles=null; 
                switch (user.UserName)
                {
                    case "TextReader":
                        userRoles = new string[] { "TextReader" };
                        break;
                    case "JsonReader":
                        userRoles = new string[] { "JsonReader" };
                        break;
                    case "XmlReader":
                        userRoles = new string[] { "XmlReader" };
                        break;
                    case "Admin":
                        userRoles = new string[] { "Admin" };
                        break;

                }               

                var authenticationManager = System.Web.HttpContext.Current.GetOwinContext().Authentication;
                var claims = new List<Claim>();
                claims.Add(new Claim(ClaimTypes.Name, user.UserName));
                claims.Add(new Claim(ClaimTypes.Email, "username@gmail.com"));
                var userIdentity = new ClaimsIdentity(claims, DefaultAuthenticationTypes.ApplicationCookie);
                userRoles.ToList().ForEach((role) => userIdentity.AddClaim(new Claim(ClaimTypes.Role, role)));

                authenticationManager.SignIn(new AuthenticationProperties() { IsPersistent = true }, userIdentity);

                ClaimsPrincipal principal2 = new ClaimsPrincipal(userIdentity);

                System.Threading.Thread.CurrentPrincipal = principal2;
                System.Web.HttpContext.Current.User = principal2;

                var test = System.Web.HttpContext.Current.User.Identity.IsAuthenticated;

                return RedirectToAction("Index", "Home");
            }
            else
            {
                return View("Index", user);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public ActionResult Logout()
        {
            var AuthenticationManager = System.Web.HttpContext.Current.GetOwinContext().Authentication;
            AuthenticationManager.SignOut();
            return View("Index");
        }
    }
}