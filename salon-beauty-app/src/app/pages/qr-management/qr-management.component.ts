import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { QrService } from '../../services/qr.service';
import { QRCode, QRStatsResponse } from '../../models/qr.model';

@Component({
  selector: 'app-qr-management',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './qr-management.component.html',
  styleUrls: ['./qr-management.component.css']
})
export class QrManagementComponent implements OnInit {
  qrcodes: QRCode[] = [];
  stats: any = null;
  loading = false;
  errorMessage = '';

  // Modal
  showModal = false;
  showViewModal = false;
  selectedQR: QRCode | null = null;

  // Formulario
  generateForm: FormGroup;
  generating = false;

  // Filtros
  filterEstado: string = '';

  constructor(
    private qrService: QrService,
    private fb: FormBuilder
  ) {
    this.generateForm = this.fb.group({
      puntos: [100, [Validators.required, Validators.min(1)]],
      descripcion: [''],
      uso_multiple: [false],
      dias_expiracion: [null, [Validators.min(1)]]
    });
  }

  ngOnInit(): void {
    this.loadQRCodes();
    this.loadStats();
  }

  loadQRCodes(): void {
    this.loading = true;
    this.errorMessage = '';

    this.qrService.listQRCodes(this.filterEstado || undefined, 100, 0).subscribe({
      next: (response) => {
        this.qrcodes = response.qrcodes;
        this.loading = false;
      },
      error: (error) => {
        console.error('Error cargando QRs:', error);
        this.errorMessage = 'Error al cargar los códigos QR';
        this.loading = false;
      }
    });
  }

  loadStats(): void {
    this.qrService.getQRStats().subscribe({
      next: (response: QRStatsResponse) => {
        this.stats = response.stats;
      },
      error: (error) => {
        console.error('Error cargando estadísticas:', error);
      }
    });
  }

  openGenerateModal(): void {
    this.showModal = true;
    this.generateForm.reset({
      puntos: 100,
      descripcion: '',
      uso_multiple: false,
      dias_expiracion: null
    });
  }

  closeModal(): void {
    this.showModal = false;
    this.generating = false;
  }

  onSubmitGenerate(): void {
    if (this.generateForm.invalid) {
      return;
    }

    this.generating = true;
    const formData = this.generateForm.value;

    this.qrService.generateQR(formData).subscribe({
      next: (response) => {
        this.generating = false;
        this.closeModal();
        this.loadQRCodes();
        this.loadStats();

        // Mostrar el QR generado
        if (response.qr) {
          this.selectedQR = response.qr;
          this.showViewModal = true;
        }
      },
      error: (error) => {
        console.error('Error generando QR:', error);
        alert('Error al generar el código QR: ' + (error.error?.message || error.message));
        this.generating = false;
      }
    });
  }

  viewQR(qr: QRCode): void {
    this.qrService.getQRDetails(qr.id_qr).subscribe({
      next: (response) => {
        this.selectedQR = response.qr;
        this.showViewModal = true;
      },
      error: (error) => {
        console.error('Error obteniendo detalles:', error);
        alert('Error al obtener detalles del QR');
      }
    });
  }

  closeViewModal(): void {
    this.showViewModal = false;
    this.selectedQR = null;
  }

  regenerateQR(qr: QRCode): void {
    if (!confirm('¿Estás seguro de regenerar este código QR? El anterior será invalidado.')) {
      return;
    }

    this.qrService.regenerateQR(qr.id_qr).subscribe({
      next: (response) => {
        alert('Código QR regenerado exitosamente');
        this.loadQRCodes();
        this.loadStats();

        if (response.qr) {
          this.selectedQR = response.qr;
          this.showViewModal = true;
        }
      },
      error: (error) => {
        console.error('Error regenerando QR:', error);
        alert('Error al regenerar el código QR');
      }
    });
  }

  downloadQR(qr: QRCode): void {
    if (qr.qrCodeImage) {
      this.qrService.downloadQRImage(
        qr.qrCodeImage,
        `QR-${qr.id_qr}-${qr.descripcion || 'codigo'}.png`
      );
    }
  }

  copyToClipboard(text: string): void {
    navigator.clipboard.writeText(text).then(() => {
      alert('URL copiada al portapapeles');
    }).catch(err => {
      console.error('Error copiando al portapapeles:', err);
    });
  }

  applyFilter(estado: string): void {
    this.filterEstado = estado;
    this.loadQRCodes();
  }

  getEstadoBadgeClass(estado: string): string {
    switch (estado) {
      case 'valido': return 'badge-success';
      case 'invalido': return 'badge-danger';
      case 'expirado': return 'badge-warning';
      default: return 'badge-secondary';
    }
  }

  getEstadoIcon(estado: string): string {
    switch (estado) {
      case 'valido': return '';
      case 'invalido': return '';
      case 'expirado': return '';
      default: return '';
    }
  }
}
