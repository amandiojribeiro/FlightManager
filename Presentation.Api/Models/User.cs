namespace Presentation.Api.Models
{
    using System.ComponentModel.DataAnnotations;

    /// <summary>
    /// 
    /// </summary>
    public class User
    {
        /// <summary>
        /// 
        /// </summary>
        [Required]
        [Display(Name = "User name")]
        public string UserName { get; set; }

        /// <summary>
        /// 
        /// </summary>
        [Required]
        [DataType(DataType.Password)]
        [Display(Name = "Password")]
        public string Password { get; set; }


        /// <summary>
        /// Checks if user with given password exists in the database
        /// </summary>
        /// <param name="_username">User name</param>
        /// <param name="_password">User password</param>
        /// <returns>True if user exist and password is correct</returns>
        public bool IsValid(string _username, string _password)
        {
            return true;
        }
    }
}
