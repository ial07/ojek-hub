import {
  Controller,
  Post,
  Body,
  Get,
  Req,
  UnauthorizedException,
} from "@nestjs/common";
import { AuthService } from "./auth.service";
import { RegisterDto } from "./dto/register.dto";

@Controller("api/auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * Login endpoint - extracts userId from JWT Bearer token
   * No longer requires supabaseUserId in body
   */
  @Post("login")
  async login(@Req() req, @Body() body: any) {
    // Extract user from JWT token
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throw new UnauthorizedException("Missing Authorization header");
    }

    const token = authHeader.replace("Bearer ", "");
    const userData = await this.authService.validateSupabaseToken(token);

    if (!userData.valid || !userData.supabaseUser) {
      throw new UnauthorizedException("Invalid token");
    }

    // Use userId from JWT, not from body
    return this.authService.loginWithSupabase(
      userData.supabaseUser.id,
      userData.supabaseUser.email,
      body.name || userData.supabaseUser.user_metadata?.full_name,
      body.photoUrl ||
        userData.supabaseUser.user_metadata?.avatar_url ||
        userData.supabaseUser.user_metadata?.picture,
    );
  }

  /**
   * Legacy Google endpoint - also extracts from JWT
   */
  @Post("google")
  async loginWithGoogle(@Req() req, @Body() body: any) {
    return this.login(req, body);
  }

  /**
   * Register endpoint - extracts userId from JWT
   */
  @Post("register")
  async register(@Req() req, @Body() registerDto: RegisterDto) {
    // Extract user from JWT token
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throw new UnauthorizedException("Missing Authorization header");
    }

    const token = authHeader.replace("Bearer ", "");
    const userData = await this.authService.validateSupabaseToken(token);

    if (!userData.valid || !userData.supabaseUser) {
      throw new UnauthorizedException("Invalid token");
    }

    // Override supabaseUserId with JWT value
    registerDto.supabaseUserId = userData.supabaseUser.id;
    if (!registerDto.email) {
      registerDto.email = userData.supabaseUser.email;
    }

    return this.authService.register(registerDto);
  }

  /**
   * Get current user profile
   */
  @Get("me")
  async getProfile(@Req() req) {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      throw new UnauthorizedException("No authorization header");
    }
    const token = authHeader.replace("Bearer ", "");
    return this.authService.validateSupabaseToken(token);
  }
}
