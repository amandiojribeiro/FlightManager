import { Component, Inject } from '@angular/core';
import { Http } from '@angular/http';

@Component({
    selector: 'fetchdata',
    templateUrl: './fetchdata.component.html'
})
export class FetchDataComponent {
    public flightReports: FlightReport[];

    constructor(http: Http, @Inject('BASE_URL') baseUrl: string) {
        http.get('http://localhost:50993/api/FlightReports').subscribe(result => {
            this.flightReports = result.json() as FlightReport[];
        }, error => console.error(error));
    }
}

interface FlightReport {
    FlightName: string;
    DepartureAirport: string;
    ArrivalAirport: string;
    Distance: number;
    EstimatedFuelConsumption: number;
    FlightTime: string;
}           
                
                    