import { Component } from '@angular/core';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';

@Component({
  selector: 'app-contact',
  templateUrl: './contact.component.html',
  styleUrls: ['./contact.component.css']
})
export class ContactComponent {
  mapUrl!: SafeResourceUrl;

  constructor(private sanitizer: DomSanitizer) {
    const mapSrc = 'https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d3930.0980812362013!2d-84.0433325!3d9.9257892!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x8fa0e370dd6d0af3%3A0x2bf16575c2e49164!2sSugar%20Beauty%20Spa!5e0!3m2!1ses-419!2scr!4v1761717361890!5m2!1ses-419!2scr';
    this.mapUrl = this.sanitizer.bypassSecurityTrustResourceUrl(mapSrc);
  }
}
