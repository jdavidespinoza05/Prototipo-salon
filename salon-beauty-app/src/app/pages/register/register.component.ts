import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../services/client.service';
import { RegisterData } from '../../models/admin.model';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent implements OnInit {
  registerForm: FormGroup;
  submitted = false;
  errorMessage = '';
  successMessage = '';
  loading = false;

  constructor(
    private fb: FormBuilder,
    private router: Router,
    private authService: AuthService
  ) {
    // Inicializar formulario
    this.registerForm = this.fb.group({
      nombre: ['', [Validators.required, Validators.minLength(3)]],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required]]
    });
  }

  ngOnInit(): void {
    console.log('RegisterComponent initialized');
  }

  /**
   * Maneja el envío del formulario de registro
   */
  onSubmit(): void {
    this.submitted = true;
    this.errorMessage = '';
    this.successMessage = '';

    // Validar formulario
    if (this.registerForm.invalid) {
      return;
    }

    // Validar que las contraseñas coincidan
    if (this.registerForm.value.password !== this.registerForm.value.confirmPassword) {
      this.errorMessage = 'Las contraseñas no coinciden';
      return;
    }

    // Mostrar indicador de carga
    this.loading = true;
    this.registerForm.disable();

    // Preparar datos de registro
    const registerData: RegisterData = {
      nombre: this.registerForm.value.nombre.trim(),
      correo: this.registerForm.value.email,
      password: this.registerForm.value.password
    };

    // Llamar al servicio de registro
    this.authService.register(registerData).subscribe({
      next: (response) => {
        this.loading = false;

        if (response.success) {
          // Registro exitoso
          console.log('Registro exitoso:', response.admin);
          this.successMessage = 'Registro exitoso. Redirigiendo al dashboard...';

          // Redirigir al dashboard después de 2 segundos
          setTimeout(() => {
            this.router.navigate(['/dashboard']);
          }, 2000);
        } else {
          // Mostrar mensaje de error
          this.errorMessage = response.message || 'Error al registrar el usuario';
          this.registerForm.enable();
        }
      },
      error: (error) => {
        this.loading = false;
        this.registerForm.enable();
        console.error('Error en registro:', error);

        // Mostrar mensaje de error amigable
        if (error.message) {
          this.errorMessage = error.message;
        } else if (error.status === 0) {
          this.errorMessage = 'No se pudo conectar con el servidor. Verifica tu conexión.';
        } else if (error.status === 409) {
          this.errorMessage = 'El correo ya está registrado';
        } else if (error.status === 500) {
          this.errorMessage = 'Error del servidor. Inténtalo más tarde.';
        } else {
          this.errorMessage = 'Error al registrar el usuario. Inténtalo de nuevo.';
        }
      }
    });
  }

  /**
   * Limpia los mensajes
   */
  clearMessages(): void {
    this.errorMessage = '';
    this.successMessage = '';
  }

  /**
   * Navega al login
   */
  goToLogin(): void {
    this.router.navigate(['/login']);
  }

  /**
   * Getter para acceso fácil a los controles del formulario
   */
  get f() {
    return this.registerForm.controls;
  }
}
