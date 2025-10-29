import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../services/client.service';
import { Admin } from '../../models/admin.model';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css'],
  standalone: true,
  imports: [CommonModule]
})
export class DashboardComponent implements OnInit {
  admin: Admin | null = null;

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.admin = this.authService.getCurrentAdmin();
  }
}
