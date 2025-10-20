import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ClientService {
  clientes = [
    { email: 'cliente1@mail.com', password: '1234', puntos: 100 },
    { email: 'cliente2@mail.com', password: 'abcd', puntos: 50 }
  ];

  constructor() {}

  login(email: string, password: string) {
    return this.clientes.find(c => c.email === email && c.password === password);
  }

  setClienteActual(cliente: any) {
    localStorage.setItem('clienteActual', JSON.stringify(cliente));
  }

  getClienteActual() {
    return JSON.parse(localStorage.getItem('clienteActual') || '{}');
  }
}
