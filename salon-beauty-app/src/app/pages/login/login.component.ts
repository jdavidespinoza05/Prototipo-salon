import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../services/client.service';
import { LoginCredentials } from '../../models/admin.model';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
  loginForm: FormGroup;
  submitted = false;
  errorMessage = '';
  loading = false;
  returnUrl = '/dashboard';

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private route: ActivatedRoute,
    private authService: AuthService
  ) {
    // Si ya está autenticado, redirigir al dashboard
    if (this.authService.isAuthenticated()) {
      this.router.navigate(['/dashboard']);
    }

    // Inicializar formulario
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]],
    });
  }

  ngOnInit(): void {
    // Obtener la URL de retorno desde los query params
    this.returnUrl = this.route.snapshot.queryParams['returnUrl'] || '/dashboard';
    
    // Verificar si la sesión expiró
    const sessionExpired = this.route.snapshot.queryParams['sessionExpired'];
    if (sessionExpired === 'true') {
      this.errorMessage = 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
    }
  }

  /**
   * Maneja el envío del formulario de login
   */
  onSubmit(): void {
    this.submitted = true;
    this.errorMessage = '';

    // Validar formulario
    if (this.loginForm.invalid) {
      return;
    }

    // Mostrar indicador de carga
    this.loading = true;

    // Preparar credenciales
    const credentials: LoginCredentials = {
      correo: this.loginForm.value.email,
      password: this.loginForm.value.password
    };

    // Llamar al servicio de autenticación
    this.authService.login(credentials).subscribe({
      next: (response) => {
        this.loading = false;
        
        if (response.success) {
          // Login exitoso
          console.log('Login exitoso:', response.admin);
          
          // Redirigir a la página solicitada o al dashboard
          this.router.navigate([this.returnUrl]);
        } else {
          // Mostrar mensaje de error
          this.errorMessage = response.message || 'Correo o contraseña incorrectos';
        }
      },
      error: (error) => {
        this.loading = false;
        console.error('Error en login:', error);
        
        // Mostrar mensaje de error amigable
        if (error.message) {
          this.errorMessage = error.message;
        } else if (error.status === 0) {
          this.errorMessage = 'No se pudo conectar con el servidor. Verifica tu conexión.';
        } else if (error.status === 500) {
          this.errorMessage = 'Error del servidor. Inténtalo más tarde.';
        } else {
          this.errorMessage = 'Correo o contraseña incorrectos';
        }
      }
    });
  }

  /**
   * Limpia el mensaje de error
   */
  clearError(): void {
    this.errorMessage = '';
  }

  /**
   * Getter para acceso fácil a los controles del formulario
   */
  get f() {
    return this.loginForm.controls;
  }
}