using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FlightManager.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index(string id)
        {
            return this.View((object)(string.IsNullOrEmpty(id) ? "''" : "'" + id + "'"));
        }
    }
}
