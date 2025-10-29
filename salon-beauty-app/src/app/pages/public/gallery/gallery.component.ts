import { Component } from '@angular/core';

@Component({
  selector: 'app-gallery',
  templateUrl: './gallery.component.html',
  styleUrls: ['./gallery.component.css']
})
export class GalleryComponent {
  // Asegúrate de que estas rutas correspondan a src/assets/gallery
  galleryImages: string[] = [
    'assets/gallery/cabello.jpg',
    'assets/gallery/cejas.jpg',
    'assets/gallery/unas.jpg',
    'assets/gallery/pestanas.jpg',
    'assets/gallery/estilo1.jpg',
    'assets/gallery/estilo2.jpg'
  ];
}
