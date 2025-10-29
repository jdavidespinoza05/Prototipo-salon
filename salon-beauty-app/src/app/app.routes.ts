import { Routes } from '@angular/router';
import { LoginComponent } from './pages/login/login.component';
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { AuthGuard } from './guards/auth.guard';

// páginas informativas
import { HomeComponent } from './pages/public/home/home.component';
import { ServicesComponent } from './pages/public/services/services.component';
import { GalleryComponent } from './pages/public/gallery/gallery.component';
import { TestimonialsComponent } from './pages/public/testimonials/testimonials.component';
import { ContactComponent } from './pages/public/contact/contact.component';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },

  // Todas las páginas requieren autenticación
  { path: 'home', component: HomeComponent, canActivate: [AuthGuard] },
  { path: 'services', component: ServicesComponent, canActivate: [AuthGuard] },
  { path: 'gallery', component: GalleryComponent, canActivate: [AuthGuard] },
  { path: 'testimonials', component: TestimonialsComponent, canActivate: [AuthGuard] },
  { path: 'contact', component: ContactComponent, canActivate: [AuthGuard] },
  { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard] },
];
