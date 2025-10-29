import { Component } from '@angular/core';

@Component({
  selector: 'app-testimonials',
  templateUrl: './testimonials.component.html',
  styleUrls: ['./testimonials.component.css']
})
export class TestimonialsComponent {
  testimonials = [
    { text: 'Excelente servicio y atención personalizada. ¡Me encantó!', author: 'María G.' },
    { text: 'El salón es hermoso y el personal muy profesional.', author: 'Carlos R.' },
    { text: 'Me hicieron un peinado increíble, definitivamente volveré.', author: 'Laura P.' },
    { text: 'Ambiente relajante y muy buena higiene. ¡Recomendado!', author: 'Fernando S.' }
  ];
}
