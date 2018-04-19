namespace Application.Services.FlightService
{
    using Application.Dto;
    using Domain.Core.RepositoryInterfaces;
    using Domain.Model;
    using Domain.Services;
    using Infrastructure.Crosscuting;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading.Tasks;

    public class FlightService : IFlightService
    {
        private readonly IFlightRepository flightRepository;
        private readonly IAirportRepository airportRepository;
        private readonly IFlightDistanceCalculatorService flightDistanceCalculatorService;

        public FlightService(IFlightRepository flightRepository, IAirportRepository airportRepository,
            IFlightDistanceCalculatorService flightDistanceCalculatorService)
        {
            this.flightRepository = flightRepository;
            this.airportRepository = airportRepository;
            this.flightDistanceCalculatorService = flightDistanceCalculatorService;
        }

        public async Task<IEnumerable<AirportDto>> GetAirportList()
        {
            var airportList = this.airportRepository.GetAll();
            return await Task.FromResult<IEnumerable<AirportDto>>(TypeAdapterHelper.Adapt<List<AirportDto>>(airportList));
        }

        public async Task<FlightDto> GetFlight(string name)
        {
            var flightResult = this.flightRepository.Find(e => e.Name == name);
            return await Task.FromResult<FlightDto>(TypeAdapterHelper.Adapt<FlightDto>(flightResult));
        }

        public async Task<IEnumerable<FlightReportDto>> GetFlightReports()
        {
            List<FlightReportDto> report = null;

            var flightResults = this.flightRepository.GetAll();
            if (flightResults != null)
            {
                report = new List<FlightReportDto>();
                var airportsList = this.airportRepository.GetAll().ToList();

                foreach (Flight flight in flightResults)
                {
                    var from = airportsList.Find(e => e.IATA == flight.DepartureAirport);
                    var to = airportsList.Find(e => e.IATA == flight.ArrivalAirport);
                    var calculatedDistance = await this.flightDistanceCalculatorService.CalculateDistances(from.Latitude, from.Longitude, to.Latitude, to.Longitude);

                    var flightReport = new FlightReportDto(calculatedDistance,this.flightDistanceCalculatorService.EstimatedConsumption, this.flightDistanceCalculatorService.FlightTime);
                    flightReport.FlightName = flight.Name;
                    flightReport.ArrivalAirport = flight.ArrivalAirport;
                    flightReport.DepartureAirport = flight.DepartureAirport;
                    report.Add(flightReport);
                }
            }

            return report;
        }

        public async Task<IEnumerable<FlightDto>> GetFlights()
        {
            var flightResults = this.flightRepository.GetAll();
            return await Task.FromResult<IEnumerable<FlightDto>>(TypeAdapterHelper.Adapt<List<FlightDto>>(flightResults));
        }

        public async Task<FlightDto> SaveFlight(FlightDto flight)
        {
            return await ManageFlight(TypeAdapterHelper.Adapt<Flight>(flight));
        }

        private async Task<FlightDto> ManageFlight(Flight flight)
        {
            var flightResult = this.flightRepository.Find(e => e.Name == flight.Name);

            if (flightResult != null)
            {
                flightResult.ArrivalAirport = flight.ArrivalAirport;
                flightResult.DepartureAirport = flight.DepartureAirport;
                this.flightRepository.Update(flightResult);
            }
            else
            {
                this.flightRepository.Add(flight);
            }

            return await Task.FromResult<FlightDto>(TypeAdapterHelper.Adapt<FlightDto>(flight));
        }
    }
}
