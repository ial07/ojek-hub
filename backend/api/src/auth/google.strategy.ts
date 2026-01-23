import { Injectable, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { ExtractJwt, Strategy } from "passport-jwt";
import { ConfigService } from "@nestjs/config";
import { AuthService } from "./auth.service";

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, "jwt") {
  constructor(
    private configService: ConfigService,
    private authService: AuthService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>("JWT_SECRET"), // Supabase JWT Secret
    });
  }

  async validate(payload: any) {
    // Basic JWT validation pass, now check against Supabase
    // Payload contains 'sub' (uuid), 'email', 'app_metadata', etc.

    // Optional: Deep verify with AuthService if needed
    // const user = await this.authService.validateUser(payload.sub);
    // if (!user) throw new UnauthorizedException();

    return payload; // Attaches to req.user
  }
}
