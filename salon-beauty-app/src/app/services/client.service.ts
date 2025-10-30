import { Injectable, Injector } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, throwError } from 'rxjs';
import { map, catchError, tap } from 'rxjs/operators';
import { Router } from '@angular/router';
import { Admin, LoginCredentials, LoginResponse, AuthUser } from '../models/admin.model';

@Injectable({
  providedIn: 'root'
})
export class ClientService {
  clientes = [
    { email: 'cliente1@mail.com', password: '1234', puntos: 100 },
    { email: 'cliente2@mail.com', password: 'abcd', puntos: 50 }
  ];
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  // URL base del API (ajustar según configuración)
  // Puede ser ORDS o un middleware Express mínimo
  private apiUrl = '/api/auth';

  // Modo desarrollo: usa autenticación mock sin backend
  private readonly DEV_MODE = false; // Cambiado a false - ahora usa el backend real con Oracle

  // BehaviorSubject para mantener el estado del usuario autenticado
  private currentUserSubject: BehaviorSubject<AuthUser | null>;
  public currentUser: Observable<AuthUser | null>;

  // Key para localStorage
  private readonly AUTH_KEY = 'salon_auth_user';

  private routerInstance?: Router;

  constructor(
    private http: HttpClient,
    private injector: Injector
  ) {
    // Inicializar con datos del localStorage si existen
    const storedUser = this.getUserFromStorage();
    this.currentUserSubject = new BehaviorSubject<AuthUser | null>(storedUser);
    this.currentUser = this.currentUserSubject.asObservable();
  }

  // Inyección lazy de Router para evitar dependencia circular
  private get router(): Router {
    if (!this.routerInstance) {
      this.routerInstance = this.injector.get(Router);
    }
    return this.routerInstance;
  }

  /**
   * Obtiene el valor actual del usuario autenticado
   */
  public get currentUserValue(): AuthUser | null {
    return this.currentUserSubject.value;
  }

  /**
   * Verifica si hay un usuario autenticado
   */
  public isAuthenticated(): boolean {
    return !!this.currentUserValue;
  }

  /**
   * Login - Llama al procedimiento almacenado de Oracle o usa mock en desarrollo
   * @param credentials Credenciales de login
   */
  login(credentials: LoginCredentials): Observable<LoginResponse> {
    // Si está en modo desarrollo, usar autenticación mock
    if (this.DEV_MODE) {
      return this.mockLogin(credentials);
    }

    // Si no, usar el backend real
    const headers = new HttpHeaders({ 'Content-Type': 'application/json' });

    return this.http.post<LoginResponse>(`${this.apiUrl}/login`, credentials, { headers })
      .pipe(
        tap(response => {
          if (response.success && response.admin && response.token) {
            // Guardar usuario y token
            const authUser: AuthUser = {
              admin: response.admin,
              token: response.token
            };
            this.setUserInStorage(authUser);
            this.currentUserSubject.next(authUser);

            // Actualizar último acceso en Oracle
            this.updateLastAccess(response.admin.id_admin).subscribe();
          }
        }),
        catchError(error => {
          console.error('Error en login:', error);
          return throwError(() => new Error(error.error?.message || 'Error al iniciar sesión'));
        })
      );
  }

  /**
   * Mock Login - Para desarrollo sin backend
   */
  private mockLogin(credentials: LoginCredentials): Observable<LoginResponse> {
    // Simular delay de red
    return new Observable(observer => {
      setTimeout(() => {
        // Credenciales de prueba
        if (credentials.correo === 'admin@salon.com' && credentials.password === '123456') {
          const mockAdmin: Admin = {
            id_admin: 1,
            nombre: 'Administrador',
            correo: 'admin@salon.com',
            activo: 'S',
            fecha_creacion: new Date(),
            ultimo_acceso: new Date()
          };

          const mockToken = 'mock-jwt-token-' + Date.now();

          const authUser: AuthUser = {
            admin: mockAdmin,
            token: mockToken
          };

          // Guardar en localStorage
          this.setUserInStorage(authUser);
          this.currentUserSubject.next(authUser);

          const response: LoginResponse = {
            success: true,
            message: 'Login exitoso (modo desarrollo)',
            admin: mockAdmin,
            token: mockToken
          };

          observer.next(response);
          observer.complete();
        } else {
          const response: LoginResponse = {
            success: false,
            message: 'Correo o contraseña incorrectos'
          };
          observer.next(response);
          observer.complete();
        }
      }, 500); // Simular 500ms de delay
    });
  }

  /**
   * Logout - Cierra sesión y limpia datos
   */
  logout(redirect: boolean = true): void {
    // Limpiar localStorage
    this.removeUserFromStorage();

    // Limpiar BehaviorSubject
    this.currentUserSubject.next(null);

    // Redirigir al login solo si se solicita
    if (redirect) {
      this.router.navigate(['/login']);
    }
  }

  /**
   * Actualiza el último acceso del administrador en Oracle
   * @param adminId ID del administrador
   */
  private updateLastAccess(adminId: number): Observable<any> {
    return this.http.post(`${this.apiUrl}/update-access`, { adminId })
      .pipe(
        catchError(error => {
          console.error('Error actualizando último acceso:', error);
          return throwError(() => error);
        })
      );
  }

  /**
   * Obtiene el token JWT del usuario actual
   */
  getToken(): string | null {
    const user = this.currentUserValue;
    return user?.token || null;
  }

  /**
   * Obtiene el admin actual
   */
  getCurrentAdmin(): Admin | null {
    return this.currentUserValue?.admin || null;
  }

  /**
   * Verifica si el usuario tiene un rol específico (para futuras implementaciones)
   */
  hasRole(role: string): boolean {
    // Por ahora solo hay administradores, pero puedes expandir esto
    return this.isAuthenticated();
  }

  /**
   * Refresca el token (implementar si usas JWT con expiración)
   */
  refreshToken(): Observable<any> {
    return this.http.post(`${this.apiUrl}/refresh-token`, {})
      .pipe(
        tap((response: any) => {
          if (response.token) {
            const currentUser = this.currentUserValue;
            if (currentUser) {
              currentUser.token = response.token;
              this.setUserInStorage(currentUser);
              this.currentUserSubject.next(currentUser);
            }
          }
        }),
        catchError(error => {
          console.error('Error refrescando token:', error);
          this.logout();
          return throwError(() => error);
        })
      );
  }

  // ========================================
  // Métodos privados para localStorage
  // ========================================

  /**
   * Guarda el usuario en localStorage
   */
  private setUserInStorage(user: AuthUser): void {
    try {
      localStorage.setItem(this.AUTH_KEY, JSON.stringify(user));
    } catch (error) {
      console.error('Error guardando en localStorage:', error);
    }
  }

  /**
   * Obtiene el usuario desde localStorage
   */
  private getUserFromStorage(): AuthUser | null {
    try {
      const userJson = localStorage.getItem(this.AUTH_KEY);
      if (userJson) {
        return JSON.parse(userJson);
      }
    } catch (error) {
      console.error('Error leyendo de localStorage:', error);
    }
    return null;
  }

  /**
   * Elimina el usuario de localStorage
   */
  private removeUserFromStorage(): void {
    try {
      localStorage.removeItem(this.AUTH_KEY);
    } catch (error) {
      console.error('Error eliminando de localStorage:', error);
    }
  }
}