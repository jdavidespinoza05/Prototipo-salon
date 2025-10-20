import { bootstrapApplication } from '@angular/platform-browser';
import { provideRouter } from '@angular/router';

import { AppComponent } from './app/app.component';
import { LoginComponent } from './app/pages/login/login.component';
import { DashboardComponent } from './app/pages/dashboard/dashboard.component';

bootstrapApplication(AppComponent, {
  providers: [
    provideRouter([
      { path: '', component: LoginComponent },
      { path: 'dashboard', component: DashboardComponent }
    ])
  ]
});
