namespace Domain.Services
{
    using System.Collections.Generic;
    using Application.DTO;
    using Domain.Model;
    using System.Device.Location;
    using System;

    public class FlightDistanceCalculatorService : IFlightDistanceCalculatorService
    {
        public void CalculateDistances(List<FlightReportDto> flights, List<Airport> airportsList)
        {
            foreach(FlightReportDto flight in flights)
            {
                var from = airportsList.Find(e => e.IATA == flight.DepartureAirport);
                var to = airportsList.Find(e => e.IATA == flight.ArrivalAirport);

                GeoCoordinate c1 = new GeoCoordinate(from.Latitude, from.Longitude);
                GeoCoordinate c2 = new GeoCoordinate(to.Latitude, to.Longitude);

                flight.Distance = c1.GetDistanceTo(c2) / 1000;
                
                //Average speed 750 km/h
                flight.FlightTime = TimeSpan.FromHours(flight.Distance / 750);
                
                /// IMPORTANT - Weight and Balance are not included in this calculations!!!!!
                /// Rough estimation for 80% payload at 36000 ft with best weather possible, no taxi considerations, no legal reserves, no climbing rates, no Airline politics, no contingency
                /// This is not an accurate calculation!
                /// Medium consumption 10000 Lbs/Hour for Boeing 737-800
                flight.EstimatedFuelConsumption = flight.FlightTime.TotalHours * 10000;
            }
        }
    }
}
