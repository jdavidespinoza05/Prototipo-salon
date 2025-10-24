import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-gallery',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './gallery.component.html',
  styleUrls: ['./gallery.component.css']
})
export class GalleryComponent {
  // Array con rutas de las imágenes locales
  galleryImages = [
    'assets/gallery/unas.jpg',
    'assets/gallery/cabello.jpg',
    'assets/gallery/pestanas.jpg',
    'assets/gallery/cejas.jpg',
    'assets/gallery/estilo1.jpg',
    'assets/gallery/estilo2.jpg'
  ];
}
