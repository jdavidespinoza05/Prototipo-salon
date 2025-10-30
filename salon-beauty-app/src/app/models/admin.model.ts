/**
 * Modelo de datos para Administrador/Usuario
 */
export interface Admin {
  id_admin: number;
  nombre: string;
  correo: string;
  activo: 'S' | 'N';
  rol: 'admin' | 'usuario';
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

/**
 * Datos para registro de nuevo administrador
 */
export interface RegisterData {
  nombre: string;
  correo: string;
  password: string;
}

/**
 * Respuesta del servidor al registrar
 */
export interface RegisterResponse {
  success: boolean;
  message: string;
  admin?: Admin;
  token?: string;
}