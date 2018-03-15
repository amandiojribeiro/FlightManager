namespace Data.Repository
{
    using Domain.Core.RepositoryInterfaces;
    using Domain.Model;
    using SharpRepository.XmlRepository;

    public class FlightRepository : XmlRepository<Flight>, IFlightRepository
    {
        public FlightRepository()
            : base("c:\\test")
        {
        }
    }
}
