import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../services/client.service';
import { QrService } from '../../services/qr.service';
import { Admin } from '../../models/admin.model';
import { QRStats } from '../../models/qr.model';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css'],
  standalone: true,
  imports: [CommonModule, RouterLink]
})
export class DashboardComponent implements OnInit {
  admin: Admin | null = null;
  qrStats: QRStats | null = null;
  loadingStats = false;

  constructor(
    private authService: AuthService,
    private qrService: QrService
  ) {}

  ngOnInit(): void {
    this.admin = this.authService.getCurrentAdmin();
    this.loadQRStats();
  }

  loadQRStats(): void {
    this.loadingStats = true;
    this.qrService.getQRStats().subscribe({
      next: (response) => {
        if (response.success) {
          this.qrStats = response.stats;
        }
        this.loadingStats = false;
      },
      error: (error) => {
        console.error('Error cargando estadísticas QR:', error);
        this.loadingStats = false;
      }
    });
  }
}
