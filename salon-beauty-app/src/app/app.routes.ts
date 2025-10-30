import { Routes } from '@angular/router';
import { LoginComponent } from './pages/login/login.component';
import { RegisterComponent } from './pages/register/register.component';
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { AuthGuard } from './guards/auth.guard';
import { adminGuard } from './guards/admin.guard';

// páginas informativas
import { HomeComponent } from './pages/public/home/home.component';
import { ServicesComponent } from './pages/public/services/services.component';
import { GalleryComponent } from './pages/public/gallery/gallery.component';
import { TestimonialsComponent } from './pages/public/testimonials/testimonials.component';
import { ContactComponent } from './pages/public/contact/contact.component';

// QR System
import { QrManagementComponent } from './pages/qr-management/qr-management.component';
import { QrRedeemComponent } from './pages/qr-redeem/qr-redeem.component';
import { MisPuntosComponent } from './pages/mis-puntos/mis-puntos.component';

export const routes: Routes = [
  { path: '', redirectTo: 'login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },

  // Página pública de canje de QR (sin autenticación)
  { path: 'canjear/:token', component: QrRedeemComponent },

  // Ruta para usuarios normales (requiere autenticación)
  { path: 'mis-puntos', component: MisPuntosComponent, canActivate: [AuthGuard] },

  // Rutas SOLO PARA ADMIN (requieren autenticación + rol admin)
  { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard, adminGuard] },
  { path: 'qr-management', component: QrManagementComponent, canActivate: [AuthGuard, adminGuard] },

  // Páginas informativas (requieren autenticación)
  { path: 'home', component: HomeComponent, canActivate: [AuthGuard] },
  { path: 'services', component: ServicesComponent, canActivate: [AuthGuard] },
  { path: 'gallery', component: GalleryComponent, canActivate: [AuthGuard] },
  { path: 'testimonials', component: TestimonialsComponent, canActivate: [AuthGuard] },
  { path: 'contact', component: ContactComponent, canActivate: [AuthGuard] },
];
