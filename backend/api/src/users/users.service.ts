import {
  Injectable,
  UnauthorizedException,
  ForbiddenException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { UpdateUserDto } from "./dto/update-user.dto";

@Injectable()
export class UsersService {
  private supabase: SupabaseClient;

  constructor(private configService: ConfigService) {
    this.supabase = createClient(
      this.configService.get<string>("SUPABASE_URL"),
      this.configService.get<string>("SUPABASE_KEY"),
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      },
    );
  }

  /**
   * Extract userId from JWT token
   */
  async extractUserFromToken(token: string) {
    const { data, error } = await this.supabase.auth.getUser(token);

    if (error || !data.user) {
      throw new UnauthorizedException("Invalid token");
    }

    return data.user;
  }

  /**
   * Get user profile by userId
   */
  async getProfile(userId: string) {
    const { data, error } = await this.supabase
      .from("users")
      .select("*")
      .eq("id", userId)
      .single();

    if (error) {
      return { status: "error", pesan: "User not found" };
    }

    return { status: "success", user: data };
  }

  /**
   * Update user role
   */
  async updateRole(userId: string, role: string, workerType?: string) {
    // Validate role
    const validRoles = ["farmer", "warehouse", "worker", "petani"];
    if (!validRoles.includes(role)) {
      throw new ForbiddenException("Invalid role");
    }

    // Map role
    let dbRole = role;
    if (role === "petani") dbRole = "farmer";

    // Map workerType
    let dbWorkerType = workerType || null;
    if (workerType === "harian") dbWorkerType = "daily";

    const { data, error } = await this.supabase
      .from("users")
      .update({
        role: dbRole,
        worker_type: dbRole === "worker" ? dbWorkerType : null,
      })
      .eq("id", userId)
      .select()
      .single();

    if (error) {
      console.error("[UsersService] Update role error:", error);
      throw new ForbiddenException("Failed to update role");
    }

    return { status: "success", user: data };
  }

  /**
   * Update user profile
   */
  async updateProfile(userId: string, updateUserDto: UpdateUserDto) {
    const { data, error } = await this.supabase
      .from("users")
      .update({
        name: updateUserDto.name,
        phone: updateUserDto.phone,
        location: updateUserDto.location,
      })
      .eq("id", userId)
      .select()
      .single();

    if (error) {
      return { status: "error", pesan: "Failed to update profile" };
    }

    return { status: "success", user: data };
  }

  /**
   * Check if user has required role for an action
   */
  async checkRole(userId: string, requiredRoles: string[]) {
    const { data, error } = await this.supabase
      .from("users")
      .select("role")
      .eq("id", userId)
      .single();

    if (error || !data) {
      throw new UnauthorizedException("User not found");
    }

    if (!requiredRoles.includes(data.role)) {
      throw new ForbiddenException(
        `Action requires role: ${requiredRoles.join(" or ")}`,
      );
    }

    return data.role;
  }
}
