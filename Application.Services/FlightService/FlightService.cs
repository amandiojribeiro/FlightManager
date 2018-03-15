namespace Application.Services.FlightService
{
    using System.Collections.Generic;
    using System.Linq;
    using Application.DTO;
    using Domain.Core.RepositoryInterfaces;
    using Domain.Model;
    using Domain.Services;
    using Infrastructure.CrossCutting.Adapters;

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

        public IEnumerable<AirportDto> GetAirportList()
        {
            var airportList = this.airportRepository.GetAll();
            return TypeAdapterHelper.Adapt<List<AirportDto>>(airportList);
        }

        public FlightDto GetFlight(string name)
        {
            var flightResult = this.flightRepository.Find(e => e.Name == name);
            return TypeAdapterHelper.Adapt<FlightDto>(flightResult);
        }

        public IEnumerable<FlightReportDto> GetFlightReports()
        {
            List<FlightReportDto> report = null;

            var flightResults = this.flightRepository.GetAll();
            if (flightResults != null)
            {
                report = new List<FlightReportDto>();

                foreach (Flight flight in flightResults)
                {
                    var flightReport = new FlightReportDto();
                    flightReport.FlightName = flight.Name;
                    flightReport.ArrivalAirport = flight.ArraivalAirport;
                    flightReport.DepartureAirport = flight.DepartureAirport;
                    report.Add(flightReport);
                }
            }

            this.flightDistanceCalculatorService.CalculateDistances(report, this.airportRepository.GetAll().ToList());
            return report;
        }

        public IEnumerable<FlightDto> GetFlights()
        {
            var flightResults = this.flightRepository.GetAll();
            return TypeAdapterHelper.Adapt<List<FlightDto>>(flightResults);
        }

        public FlightDto SaveFlight(FlightDto flight)
        {
            return ManageFlight(TypeAdapterHelper.Adapt<Flight>(flight));
        }

        private FlightDto ManageFlight(Flight flight)
        {
            var flightResult = this.flightRepository.Find(e => e.Name == flight.Name);

            if (flightResult != null)
            {
                flightResult.ArraivalAirport = flight.ArraivalAirport;
                flightResult.DepartureAirport = flight.DepartureAirport;
                this.flightRepository.Update(flightResult);
            }
            else
            {
                this.flightRepository.Add(flight);
            }

            return TypeAdapterHelper.Adapt<FlightDto>(flight);
        }
    }
}
