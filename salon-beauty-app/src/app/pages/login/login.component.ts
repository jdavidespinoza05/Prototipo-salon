import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';  // <-- IMPORTAR
import { ClientService } from '../../services/client.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css'],
  standalone: true,
  imports: [FormsModule, CommonModule]  // <-- AÑADIR CommonModule
})
export class LoginComponent {
  email = '';
  password = '';
  error = '';

  constructor(private clientService: ClientService, private router: Router) {}

  onLogin() {
    const cliente = this.clientService.login(this.email, this.password);
    if (cliente) {
      this.clientService.setClienteActual(cliente);
      this.router.navigate(['/dashboard']);
    } else {
      this.error = 'Email o contraseña incorrectos';
    }
  }
}
