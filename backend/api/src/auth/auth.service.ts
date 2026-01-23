import { Injectable, BadRequestException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { RegisterDto } from "./dto/register.dto";

@Injectable()
export class AuthService {
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
   * Login with Supabase user ID
   * Trusts Supabase as the auth provider
   */
  async loginWithSupabase(
    supabaseUserId: string,
    email?: string,
    name?: string,
  ) {
    console.log("[AuthService] Login with Supabase user:", supabaseUserId);
    console.log("[AuthService] Email:", email);

    if (!supabaseUserId) {
      return {
        status: "error",
        pesan: "Supabase user ID required",
      };
    }

    // Check if user exists in our DB by Supabase ID or email
    const { data: existingUser, error: lookupError } = await this.supabase
      .from("users")
      .select("*")
      .or(`id.eq.${supabaseUserId},email.eq.${email}`)
      .maybeSingle();

    if (lookupError) {
      console.error("[AuthService] User lookup error:", lookupError);
    }

    if (existingUser) {
      console.log("[AuthService] Existing user found:", existingUser.email);

      // Update Supabase ID if not set
      if (!existingUser.id || existingUser.id !== supabaseUserId) {
        await this.supabase
          .from("users")
          .update({ id: supabaseUserId })
          .eq("email", email);
      }

      return {
        status: "success",
        pesan: "Login berhasil",
        user: existingUser,
        isNewUser: false,
      };
    } else {
      // New user - needs profile setup
      console.log("[AuthService] New user, needs profile");
      return {
        status: "needs_profile",
        pesan: "Silakan lengkapi profil",
        isNewUser: true,
        email: email,
        name: name,
        supabaseUserId: supabaseUserId,
      };
    }
  }

  /**
   * Register new user with role
   */
  async register(dto: RegisterDto) {
    // Validate rules
    if (dto.role === "worker" && !dto.workerType) {
      throw new BadRequestException(
        "Pekerja harus memilih tipe (ojek/pekerja)",
      );
    }

    // Check if user already exists
    const { data: existing } = await this.supabase
      .from("users")
      .select("id")
      .eq("email", dto.email)
      .maybeSingle();

    if (existing) {
      // User already exists - return their data
      const { data: user } = await this.supabase
        .from("users")
        .select("*")
        .eq("id", existing.id)
        .single();

      return {
        status: "success",
        pesan: "Login berhasil (akun sudah ada)",
        user: user,
      };
    }

    // Use Supabase user ID as the primary ID
    const userId = dto.supabaseUserId || crypto.randomUUID();

    // Map role from Indonesian to English if needed
    let dbRole = dto.role;
    if (dto.role === "petani") dbRole = "farmer";

    // Map workerType
    let dbWorkerType = dto.workerType;
    if (dto.workerType === "pekerja") dbWorkerType = "daily";

    // Insert into public.users
    const { data: newUser, error: dbError } = await this.supabase
      .from("users")
      .insert({
        id: userId,
        email: dto.email,
        name: dto.name,
        phone: dto.phone || null,
        location: dto.location || null,
        role: dbRole,
        worker_type: dbRole === "worker" ? dbWorkerType : null,
      })
      .select()
      .single();

    if (dbError) {
      console.error("[AuthService] Registration error:", dbError);
      throw new BadRequestException("Gagal mendaftar: " + dbError.message);
    }

    return {
      status: "success",
      pesan: "Registrasi berhasil",
      user: newUser,
    };
  }

  /**
   * Validate Supabase JWT token
   */
  async validateSupabaseToken(token: string) {
    try {
      const { data, error } = await this.supabase.auth.getUser(token);

      if (error || !data.user) {
        return { valid: false, error: error?.message };
      }

      // Lookup user in our database
      const { data: dbUser } = await this.supabase
        .from("users")
        .select("*")
        .eq("id", data.user.id)
        .maybeSingle();

      return {
        valid: true,
        supabaseUser: data.user,
        dbUser: dbUser,
      };
    } catch (e) {
      return { valid: false, error: e.message };
    }
  }
}
