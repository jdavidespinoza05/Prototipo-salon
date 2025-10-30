import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../services/client.service';

export const adminGuard = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  const admin = authService.getCurrentAdmin();

  if (admin && admin.rol === 'admin') {
    return true;
  }

  router.navigate(['/mis-puntos']);
  return false;
};
