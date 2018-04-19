namespace Domain.Services
{
    using System.Collections.Generic;
    using Domain.Model;
    using System;
    using System.Threading.Tasks;
    using GeoCoordinatePortable;

    public class FlightDistanceCalculatorService : IFlightDistanceCalculatorService
    {
        private TimeSpan flightTime;
        private double estimatedConsumption;

        public TimeSpan FlightTime { get { return flightTime; } }

        public double EstimatedConsumption { get { return estimatedConsumption; } }

        public async Task<double> CalculateDistances(double fromLatitute, double fromLongitude, double toLatitude, double toLongitude)
        {

            GeoCoordinate c1 = new GeoCoordinate(fromLatitute, fromLongitude);
            GeoCoordinate c2 = new GeoCoordinate(toLatitude, toLongitude);

            var distance = c1.GetDistanceTo(c2) / 1000;

            //Average speed 750 km/h
            this.flightTime = TimeSpan.FromHours(distance / 750);

            /// IMPORTANT - Weight and Balance are not included in this calculations!!!!!
            /// Rough estimation for 80% payload at 36000 ft with best weather possible, no taxi considerations, no legal reserves, no climbing rates, no Airline politics, no contingency
            /// This is not an accurate calculation!
            /// Medium consumption 10000 Lbs/Hour for Boeing 737-800
            this.estimatedConsumption = this.flightTime.TotalHours * 10000;


            return await Task.FromResult<double>(distance);
        }
    }
}
