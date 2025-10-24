import { Routes } from '@angular/router';
import { LoginComponent } from './pages/login/login.component';
import { DashboardComponent } from './pages/dashboard/dashboard.component';

// páginas informativas
import { HomeComponent } from './pages/public/home/home.component';
import { ServicesComponent } from './pages/public/services/services.component';
import { GalleryComponent } from './pages/public/gallery/gallery.component';
import { TestimonialsComponent } from './pages/public/testimonials/testimonials.component';
import { ContactComponent } from './pages/public/contact/contact.component';

export const routes: Routes = [
  { path: '', redirectTo: 'home', pathMatch: 'full' },
  { path: 'home', component: HomeComponent },
  { path: 'services', component: ServicesComponent },
  { path: 'gallery', component: GalleryComponent },
  { path: 'testimonials', component: TestimonialsComponent },
  { path: 'contact', component: ContactComponent },

  // login y dashboard
  { path: 'login', component: LoginComponent },
  { path: 'dashboard', component: DashboardComponent },
];
