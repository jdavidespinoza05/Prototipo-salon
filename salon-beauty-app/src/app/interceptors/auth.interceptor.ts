import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor,
  HttpErrorResponse
} from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { AuthService } from '../services/client.service';
import { Router } from '@angular/router';

/**
 * Interceptor HTTP que:
 * 1. Agrega automáticamente el token JWT a todas las peticiones
 * 2. Maneja errores de autenticación (401, 403)
 * 3. Refresca el token si expira
 */
@Injectable()
export class AuthInterceptor implements HttpInterceptor {

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    
    // Obtener el token del servicio de autenticación
    const token = this.authService.getToken();
    
    // Si existe token, agregarlo al header Authorization
    if (token) {
      request = request.clone({
        setHeaders: {
          Authorization: `Bearer ${token}`
        }
      });
    }

    // Continuar con la petición y manejar errores
    return next.handle(request).pipe(
      catchError((error: HttpErrorResponse) => {
        
        // Error 401: No autorizado (token inválido o expirado)
        if (error.status === 401) {
          console.error('Error 401: No autorizado');
          this.authService.logout();
          this.router.navigate(['/login'], {
            queryParams: { sessionExpired: 'true' }
          });
        }
        
        // Error 403: Prohibido (sin permisos)
        if (error.status === 403) {
          console.error('Error 403: Acceso prohibido');
          this.router.navigate(['/dashboard']);
        }
        
        // Error 500: Error del servidor
        if (error.status === 500) {
          console.error('Error 500: Error del servidor');
        }
        
        return throwError(() => error);
      })
    );
  }
}