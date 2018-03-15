using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Presentation.Api.Controllers
{
    /// <summary>
    /// 
    /// </summary>
    public class FlightManagerController : Controller
    {
        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        // GET: FlightManager
        public ActionResult Index()
        {
            return View();
        }
    }
}