/**
 * Modelo de datos para Administrador
 */
export interface Admin {
  id_admin: number;
  nombre: string;
  correo: string;
  activo: 'S' | 'N';
  fecha_creacion: Date;
  ultimo_acceso?: Date;
}

/**
 * Credenciales para login
 */
export interface LoginCredentials {
  correo: string;
  password: string;
}

/**
 * Respuesta del servidor al hacer login
 */
export interface LoginResponse {
  success: boolean;
  message: string;
  admin?: Admin;
  token?: string;
}

/**
 * Usuario autenticado (guardado en localStorage)
 */
export interface AuthUser {
  admin: Admin;
  token: string;
}