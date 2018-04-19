namespace Domain.Services
{
    using System;
    using System.Threading.Tasks;

    public interface IFlightDistanceCalculatorService
    {
        TimeSpan FlightTime { get; }

        double EstimatedConsumption { get; }

        Task<double> CalculateDistances(double fromLatitute, double fromLongitude, double toLatitude, double toLongitude);
    }
}
