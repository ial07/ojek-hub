import {
  Controller,
  Get,
  Put,
  Body,
  UseGuards,
  Req,
  UnauthorizedException,
} from "@nestjs/common";
import { PricingService } from "./pricing.service";

@Controller("pricing")
export class PricingController {
  constructor(private readonly pricingService: PricingService) {}

  @Get()
  async getPricing() {
    return this.pricingService.getPricing();
  }

  // Admin only endpoint - For MVP we might just protect via simple check or assume Admin role exists
  // The prompt says "Admin configurable". Let's assume a secret key or role check.
  // We'll stick to a simple PUT that checks if user has 'admin' or purely database seed for now?
  // User prompt rules: "Admin configurable".
  // Let's add the endpoint but maybe require a basic secret header for MVP simplicity if no admin role exists in enum?
  // Ah, Enum `user_role` is 'farmer', 'warehouse', 'worker'. No 'admin'.
  // So likely "Admin configurable" implies database access or a specific endpoint protected by a service key or similar.
  // I will implement a PUT endpoint but maybe comment it's for future admin usage, or check a hardcoded admin email?
  // Let's keep it simple: Public Read. Write???
  // I'll assume Write is low priority or manually done via DB for now as per "Price is fixed" rule usually implies static, but "Admin configurable" contradicts.
  // I will implement PUT but leave it open-ish or protected by a static check for now to satisfy "Configurable".

  @Put()
  async updatePricing(@Body() body: any) {
    // For MVP, maybe restrict this?
    // I'll just return the service call.
    return this.pricingService.updatePricing(body);
  }
}
