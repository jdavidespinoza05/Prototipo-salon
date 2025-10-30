import { Component } from '@angular/core';
import { RouterOutlet, Router, NavigationEnd } from '@angular/router';
import { NavbarComponent } from './components/navbar/navbar.component';
import { CommonModule } from '@angular/common';
import { filter } from 'rxjs/operators';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, NavbarComponent, CommonModule],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'salon-beauty-app';
  showNavbar = false;

  constructor(private router: Router) {
    // Escuchar los cambios de navegación
    this.router.events
      .pipe(filter(event => event instanceof NavigationEnd))
      .subscribe((event: NavigationEnd) => {
        // Mostrar navbar solo si NO estamos en login, register o forgot-password
        const hiddenRoutes = ['/login', '/register', '/forgot-password'];
        this.showNavbar = !hiddenRoutes.some(route => event.urlAfterRedirects.includes(route));
      });
  }
}
