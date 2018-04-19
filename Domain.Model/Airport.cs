namespace Domain.Model
{
    public class Airport
    {
        public int Id { get; set; }

        public string Name { get; set; }

        public string SimpleName { get; set; }

        public double Latitude { get; set; }

        public double Longitude { get; set; }

        public string Country { get; set; }

        public string IATA { get; set; }

        public string ICAO { get; set; }
    }
}
