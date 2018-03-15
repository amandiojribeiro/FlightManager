namespace Application.Services.TypeAdapters
{
    using AutoMapper;

    using Application.DTO;
    using Domain.Model;

    public class DtoAdapterProfile : Profile
    {
        protected override void Configure()
        {
            Mapper.CreateMap<Flight, FlightDto>()
            .ForMember(dest => dest.Name, opt => opt.MapFrom(e => e.Name))
            .ForMember(dest => dest.ArraivalAirport, opt => opt.MapFrom(e => e.ArraivalAirport))
            .ForMember(dest => dest.DepartureAirport, opt => opt.MapFrom(e => e.DepartureAirport))
            .ReverseMap();

            Mapper.CreateMap<Airport, AirportDto>()
           .ForMember(dest => dest.Name, opt => opt.MapFrom(e => e.Name))
           .ForMember(dest => dest.Iata, opt => opt.MapFrom(e => e.IATA))
           .ReverseMap();
        }
    }
}
