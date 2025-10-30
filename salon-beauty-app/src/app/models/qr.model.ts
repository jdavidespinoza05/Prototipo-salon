export interface QRCode {
  id_qr: number;
  token_unico: string;
  puntos: number;
  descripcion?: string;
  estado: 'valido' | 'invalido' | 'expirado';
  fecha_creacion: Date;
  fecha_expiracion?: Date;
  fecha_canje?: Date;
  id_cliente_canje?: number;
  id_admin_creador: number;
  veces_usado: number;
  uso_multiple: boolean;
  canjeUrl?: string;
  qrCodeImage?: string;
  admin_nombre?: string;
  cliente_nombre?: string;
  cliente_correo?: string;
}

export interface GenerateQRRequest {
  puntos: number;
  descripcion?: string;
  uso_multiple?: boolean;
  dias_expiracion?: number;
}

export interface GenerateQRResponse {
  success: boolean;
  message: string;
  qr?: QRCode;
}

export interface RedeemQRRequest {
  correo_cliente: string;
}

export interface RedeemQRResponse {
  success: boolean;
  message: string;
  canje?: {
    puntos_aplicados: number;
    puntos_anteriores: number;
    puntos_nuevos: number;
    cliente: {
      nombre: string;
      correo: string;
    };
  };
}

export interface QRListResponse {
  success: boolean;
  qrcodes: QRCode[];
  total: number;
}

export interface QRStats {
  total_qrs: number;
  qrs_validos: number;
  qrs_invalidos: number;
  qrs_expirados: number;
  total_canjes: number;
  total_puntos_canjeados: number;
}

export interface QRStatsResponse {
  success: boolean;
  stats: QRStats;
}

export interface Cliente {
  id_cliente: number;
  nombre: string;
  correo: string;
  telefono?: string;
  puntos: number;
  fecha_registro: Date;
  ultimo_canje?: Date;
  activo: 'S' | 'N';
}
