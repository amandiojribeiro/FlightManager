namespace Application.Services.TypeAdapters
{
    using Application.Dto;
    using AutoMapper;
    using Domain.Model;

    public class DtoAdapterProfile : Profile
    {
        public override string ProfileName
        {
            get { return "DtoAdapterProfile"; }
        }

        public DtoAdapterProfile()
        {
             CreateMap<Flight, FlightDto>()
            .ForMember(dest => dest.Name, opt => opt.MapFrom(e => e.Name))
            .ForMember(dest => dest.ArraivalAirport, opt => opt.MapFrom(e => e.ArrivalAirport))
            .ForMember(dest => dest.DepartureAirport, opt => opt.MapFrom(e => e.DepartureAirport))
            .ReverseMap();

            CreateMap<Airport, AirportDto>()
           .ForMember(dest => dest.Name, opt => opt.MapFrom(e => e.Name))
           .ForMember(dest => dest.Iata, opt => opt.MapFrom(e => e.IATA))
           .ReverseMap();
        }

    }
}
