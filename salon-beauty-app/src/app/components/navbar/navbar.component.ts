import { Component, OnInit } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../services/client.service';
import { Admin } from '../../models/admin.model';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive],
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.css']
})
export class NavbarComponent implements OnInit {
  admin: Admin | null = null;
  isAdmin = false;

  constructor(private authService: AuthService) {}

  ngOnInit(): void {
    this.admin = this.authService.getCurrentAdmin();
    this.isAdmin = this.admin?.rol === 'admin';
  }
}
