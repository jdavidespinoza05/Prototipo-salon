import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { AuthService } from '../../services/client.service';

interface Cliente {
  id_cliente: number;
  nombre: string;
  correo: string;
  puntos: number;
  fecha_registro: Date;
}

interface Canje {
  id_canje: number;
  fecha_canje: Date;
  puntos_aplicados: number;
  puntos_anteriores: number;
  puntos_nuevos: number;
  qr_descripcion?: string;
}

@Component({
  selector: 'app-mis-puntos',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './mis-puntos.component.html',
  styleUrls: ['./mis-puntos.component.css']
})
export class MisPuntosComponent implements OnInit {
  cliente: Cliente | null = null;
  canjes: Canje[] = [];
  loading = true;
  error = false;
  errorMessage = '';

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    this.loadMisPuntos();
    this.loadMisCanjes();
  }

  loadMisPuntos(): void {
    this.http.get<any>('/api/cliente/mis-puntos').subscribe({
      next: (response) => {
        if (response.success) {
          this.cliente = response.cliente;
        }
        this.loading = false;
      },
      error: (error) => {
        console.error('Error cargando puntos:', error);
        this.error = true;
        this.errorMessage = 'No se pudieron cargar tus puntos';
        this.loading = false;
      }
    });
  }

  loadMisCanjes(): void {
    this.http.get<any>('/api/cliente/mis-canjes').subscribe({
      next: (response) => {
        if (response.success) {
          this.canjes = response.canjes;
        }
      },
      error: (error) => {
        console.error('Error cargando canjes:', error);
      }
    });
  }
}
