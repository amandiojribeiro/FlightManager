namespace Data.Repository
{
    using Domain.Core.RepositoryInterfaces;
    using Domain.Model;
    using SharpRepository.XmlRepository;

    public class AirportRepository : XmlRepository<Airport>, IAirportRepository
    {
        public AirportRepository()
            : base(System.String.Format(@"{0}\Dependencies", System.AppDomain.CurrentDomain.BaseDirectory))
        {
        }
    }
}
