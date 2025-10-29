import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, BehaviorSubject, throwError } from 'rxjs';
import { map, catchError, tap } from 'rxjs/operators';
import { Router } from '@angular/router';
import { Admin, LoginCredentials, LoginResponse, AuthUser } from '../models/admin.model';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  // URL base del API (ajustar según configuración)
  // Puede ser ORDS o un middleware Express mínimo
  private apiUrl = '/api/auth';
  
  // BehaviorSubject para mantener el estado del usuario autenticado
  private currentUserSubject: BehaviorSubject<AuthUser | null>;
  public currentUser: Observable<AuthUser | null>;
  
  // Key para localStorage
  private readonly AUTH_KEY = 'salon_auth_user';

  constructor(
    private http: HttpClient,
    private router: Router
  ) {
    // Inicializar con datos del localStorage si existen
    const storedUser = this.getUserFromStorage();
    this.currentUserSubject = new BehaviorSubject<AuthUser | null>(storedUser);
    this.currentUser = this.currentUserSubject.asObservable();
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
   * Login - Llama al procedimiento almacenado de Oracle
   * @param credentials Credenciales de login
   */
  login(credentials: LoginCredentials): Observable<LoginResponse> {
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
   * Logout - Cierra sesión y limpia datos
   */
  logout(): void {
    // Limpiar localStorage
    this.removeUserFromStorage();
    
    // Limpiar BehaviorSubject
    this.currentUserSubject.next(null);
    
    // Redirigir al login
    this.router.navigate(['/login']);
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