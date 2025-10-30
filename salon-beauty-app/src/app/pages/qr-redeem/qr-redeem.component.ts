import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { QrService } from '../../services/qr.service';

@Component({
  selector: 'app-qr-redeem',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  templateUrl: './qr-redeem.component.html',
  styleUrls: ['./qr-redeem.component.css']
})
export class QrRedeemComponent implements OnInit {
  token: string = '';
  redeemForm: FormGroup;
  loading = false;
  submitted = false;

  // Estados
  success = false;
  error = false;
  errorMessage = '';
  redeemData: any = null;
  requireRegistration = false;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private qrService: QrService,
    private fb: FormBuilder
  ) {
    this.redeemForm = this.fb.group({
      correo_cliente: ['', [Validators.required, Validators.email]]
    });
  }

  ngOnInit(): void {
    // Obtener el token de la URL
    this.route.params.subscribe(params => {
      this.token = params['token'];
      console.log('Token recibido:', this.token);
    });
  }

  onSubmit(): void {
    this.submitted = true;
    this.success = false;
    this.error = false;
    this.errorMessage = '';

    if (this.redeemForm.invalid) {
      return;
    }

    this.loading = true;
    const correo = this.redeemForm.value.correo_cliente;

    this.qrService.redeemQR(this.token, correo).subscribe({
      next: (response) => {
        this.loading = false;
        if (response.success) {
          this.success = true;
          this.redeemData = response.canje;
        } else {
          this.error = true;
          this.errorMessage = response.message;
        }
      },
      error: (error) => {
        this.loading = false;
        this.error = true;
        console.error('Error canjeando QR:', error);

        // Verificar si requiere registro
        if (error.error?.requireRegistration) {
          this.requireRegistration = true;
          this.errorMessage = error.error.message;
          return;
        }

        if (error.error?.message) {
          this.errorMessage = error.error.message;
        } else if (error.status === 404) {
          this.errorMessage = 'Código QR no encontrado';
        } else if (error.status === 400) {
          this.errorMessage = error.error?.message || 'Este código QR ya fue canjeado o es inválido';
        } else {
          this.errorMessage = 'Error al canjear el código. Inténtalo de nuevo.';
        }
      }
    });
  }

  get f() {
    return this.redeemForm.controls;
  }
}
