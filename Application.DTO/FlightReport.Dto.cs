using System;

namespace Application.DTO
{
    public class FlightReportDto
    {
        public string FlightName { get; set; }

        public string DepartureAirport { get; set; }

        public string ArrivalAirport { get; set; }

        public double Distance { get; set; }

        public double EstimatedFuelConsumption { get; set; }

        public TimeSpan FlightTime { get; set; }
    }
}
