using Presentation.Api.CustomHandlers;
using System;
using System.Web.Mvc;

namespace Presentation.Api.Controllers
{
    /// <summary>
    /// 
    /// </summary>
    public class FileReaderController : Controller
    {
        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        // GET: FileReader
        public ActionResult Index()
        {
            return View();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>

        [AuthorizeUser(Roles = "Admin, TextReader")]
        [HttpGet]
        public ActionResult ReadTextFile()
        {
            Array LogFileData = null;
            var logFileNameWithPath = System.String.Format(@"{0}\bin\Dependencies\textFile.txt", System.AppDomain.CurrentDomain.BaseDirectory);

            if (System.IO.File.Exists(logFileNameWithPath))
            {
                LogFileData = System.IO.File.ReadAllLines(logFileNameWithPath);
            }
            ViewBag.logFileContent = LogFileData;
            return View();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [AuthorizeUser(Roles = "Admin, JsonReader")]
        [HttpGet]
        public ActionResult ReadJsonFile()
        {
            Array LogFileData = null;
            var logFileNameWithPath = System.String.Format(@"{0}\bin\Dependencies\json.json", System.AppDomain.CurrentDomain.BaseDirectory);

            if (System.IO.File.Exists(logFileNameWithPath))
            {
                LogFileData = System.IO.File.ReadAllLines(logFileNameWithPath);
            }
            ViewBag.logFileContent = LogFileData;
            return View();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [AuthorizeUser(Roles = "Admin, XmlReader")]
        [HttpGet]
        public ActionResult ReadXmlFile()
        {
            Array LogFileData = null;
            var logFileNameWithPath = System.String.Format(@"{0}\bin\Dependencies\xmlFile.xml", System.AppDomain.CurrentDomain.BaseDirectory);

            if (System.IO.File.Exists(logFileNameWithPath))
            {
                LogFileData = System.IO.File.ReadAllLines(logFileNameWithPath);
            }
            ViewBag.logFileContent = LogFileData;
            return View();
        }

    }
}