namespace Presentation.Api.Controllers
{
    using Microsoft.AspNetCore.Identity;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.Extensions.Configuration;
    using Microsoft.Extensions.Logging;
    using Microsoft.IdentityModel.Tokens;
    using Presentation.Api.Filters;
    using System;
    using System.Collections.Generic;
    using System.IdentityModel.Tokens.Jwt;
    using System.Linq;
    using System.Net;
    using System.Security.Claims;
    using System.Text;
    using System.Threading.Tasks;

    [Route("api/[controller]")]
    public class AuthController : Controller
    {
 		private IConfiguration configuration; 
 		private ILogger<AuthController> logger;

        public AuthController(IConfiguration configuration, ILogger<AuthController> logger)
 	    { 
 		    this.logger = logger; 
 		    this.configuration = configuration; 
 	    }

        [ValidateForm]
        [HttpPost("CreateToken")] 
		public async Task<IActionResult> CreateToken([FromBody] Models.LoginViewModel model)
		{
            string[] userRoles = null;
            switch (model.Password)
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

            try 
			{
                if(model.Email=="Admin@admin.com")
                { 
                    var fakeClaims = new List<Claim>();
                    fakeClaims.Add(new Claim(ClaimTypes.Name, model.Email));
                    fakeClaims.Add(new Claim(ClaimTypes.Email, "username@gmail.com"));
                    var userIdentity = new ClaimsIdentity(fakeClaims);
                    userRoles.ToList().ForEach((role) => userIdentity.AddClaim(new Claim(ClaimTypes.Role, role)));

                    var userClaims = fakeClaims;

					var symmetricSecurityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration["JwtSecurityToken:Key"])); 
					var signingCredentials = new SigningCredentials(symmetricSecurityKey, SecurityAlgorithms.HmacSha256); 


					var jwtSecurityToken = new JwtSecurityToken(
                     issuer: configuration["JwtSecurityToken:Issuer"],
                     audience: configuration["JwtSecurityToken:Audience"],
                     claims: userClaims,
                     expires: DateTime.UtcNow.AddMinutes(60),
                     signingCredentials: signingCredentials);

 					return await Task.FromResult<IActionResult>(Ok(new  
 					{ 
 						token = new JwtSecurityTokenHandler().WriteToken(jwtSecurityToken), 
 						expiration = jwtSecurityToken.ValidTo 
 					}));
                }

                return await Task.FromResult<IActionResult>(Unauthorized()); 
 			} 
 			catch (Exception ex) 
 			{ 
 				logger.LogError($"error while creating token: {ex}"); 
 				return StatusCode((int) HttpStatusCode.InternalServerError, "error while creating token"); 
 			} 
 		} 
    }
}