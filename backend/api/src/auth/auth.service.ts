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
  // Login method
  async loginWithSupabase(
    supabaseUserId: string,
    email?: string,
    name?: string,
    photoUrl?: string, // Added param
  ) {
    console.log("[AuthService] Login with Supabase user:", supabaseUserId);

    // ... (Validation)

    const { data: existingUser } = await this.supabase
      .from("users")
      .select("*")
      .or(`id.eq.${supabaseUserId},email.eq.${email}`)
      .maybeSingle();

    if (existingUser) {
      // Update info if needed
      const updates: any = {};
      if (!existingUser.id || existingUser.id !== supabaseUserId)
        updates.id = supabaseUserId;
      // Update photo if provided and different (or missing)
      if (photoUrl && existingUser.photo_url !== photoUrl)
        updates.photo_url = photoUrl;

      if (Object.keys(updates).length > 0) {
        await this.supabase.from("users").update(updates).eq("email", email);
      }

      return {
        status: "success",
        pesan: "Login berhasil",
        user: { ...existingUser, ...updates }, // Return updated info
        isNewUser: false,
      };
    } else {
      // New user
      return {
        status: "needs_profile",
        pesan: "Silakan lengkapi profil",
        isNewUser: true,
        email: email,
        name: name,
        supabaseUserId: supabaseUserId,
        photoUrl: photoUrl, // Pass to frontend for registration
      };
    }
  }

  // Register method
  async register(dto: RegisterDto) {
    // ... (Validation skipped for brevity, assuming existing validation)

    // Insert into public.users
    const { data: newUser, error: dbError } = await this.supabase
      .from("users")
      .insert({
        id: dto.supabaseUserId || crypto.randomUUID(),
        email: dto.email,
        name: dto.name,
        phone: dto.phone || null,
        location: dto.location || null,
        role: dto.role === "petani" ? "farmer" : dto.role,
        worker_type:
          dto.role === "worker"
            ? dto.workerType === "harian"
              ? "daily"
              : dto.workerType === "all"
                ? null
                : dto.workerType
            : null,
        photo_url: dto.photoUrl || null,
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
