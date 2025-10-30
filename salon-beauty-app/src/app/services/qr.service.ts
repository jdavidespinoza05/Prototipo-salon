import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import {
  QRCode,
  GenerateQRRequest,
  GenerateQRResponse,
  RedeemQRRequest,
  RedeemQRResponse,
  QRListResponse,
  QRStatsResponse
} from '../models/qr.model';

@Injectable({
  providedIn: 'root'
})
export class QrService {
  private apiUrl = '/api/qr';

  constructor(private http: HttpClient) {}

  /**
   * Genera un nuevo código QR (requiere autenticación)
   */
  generateQR(data: GenerateQRRequest): Observable<GenerateQRResponse> {
    return this.http.post<GenerateQRResponse>(`${this.apiUrl}/generate`, data);
  }

  /**
   * Lista todos los códigos QR (requiere autenticación)
   */
  listQRCodes(estado?: string, limit = 50, offset = 0): Observable<QRListResponse> {
    let url = `${this.apiUrl}/list?limit=${limit}&offset=${offset}`;
    if (estado) {
      url += `&estado=${estado}`;
    }
    return this.http.get<QRListResponse>(url);
  }

  /**
   * Obtiene los detalles de un QR específico (requiere autenticación)
   */
  getQRDetails(id_qr: number): Observable<{ success: boolean; qr: QRCode }> {
    return this.http.get<{ success: boolean; qr: QRCode }>(`${this.apiUrl}/${id_qr}`);
  }

  /**
   * Regenera un código QR (requiere autenticación)
   */
  regenerateQR(id_qr: number): Observable<GenerateQRResponse> {
    return this.http.post<GenerateQRResponse>(`${this.apiUrl}/regenerate/${id_qr}`, {});
  }

  /**
   * Canjea un código QR (NO requiere autenticación)
   */
  redeemQR(token: string, correo_cliente: string): Observable<RedeemQRResponse> {
    const data: RedeemQRRequest = { correo_cliente };
    return this.http.post<RedeemQRResponse>(`${this.apiUrl}/redeem/${token}`, data);
  }

  /**
   * Obtiene el historial de canjes (requiere autenticación)
   */
  getRedemptionHistory(limit = 50, offset = 0): Observable<any> {
    return this.http.get(`${this.apiUrl}/history/redemptions?limit=${limit}&offset=${offset}`);
  }

  /**
   * Obtiene estadísticas de los QR codes (requiere autenticación)
   */
  getQRStats(): Observable<QRStatsResponse> {
    return this.http.get<QRStatsResponse>(`${this.apiUrl}/stats/summary`);
  }

  /**
   * Descarga la imagen del QR como archivo
   */
  downloadQRImage(qrCodeImage: string, filename: string): void {
    const link = document.createElement('a');
    link.href = qrCodeImage;
    link.download = filename;
    link.click();
  }
}
