namespace Application.Dto
{
    using System;

    public class FlightReportDto
    {
        private readonly double distance;
        private readonly double estimatedFuelConsumption;
        private readonly TimeSpan flightTime;

        public FlightReportDto(double distance, double estimatedFuelConsumption, TimeSpan flightTime)
        {
            this.distance = distance;
            this.estimatedFuelConsumption = estimatedFuelConsumption;
            this.flightTime = flightTime;
        }

        public string FlightName { get; set; }

        public string DepartureAirport { get; set; }

        public string ArrivalAirport { get; set; }

        public double Distance { get { return this.distance; } }

        public double EstimatedFuelConsumption { get { return this.estimatedFuelConsumption; } }

        public TimeSpan FlightTime { get { return this.flightTime; } }

    }
}
