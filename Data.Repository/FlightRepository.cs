namespace Data.Repository
{
    using Domain.Core.RepositoryInterfaces;
    using Domain.Model;
    using SharpRepository.XmlRepository;

    public class FlightRepository : XmlRepository<Flight>, IFlightRepository
    {
        public FlightRepository()
            : base(System.String.Format(@"{0}\bin\Dependencies", System.AppDomain.CurrentDomain.BaseDirectory))
        {
        }
    }
}
