import { Injectable, BadRequestException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { createClient, SupabaseClient } from "@supabase/supabase-js";

@Injectable()
export class PricingService {
  private supabase: SupabaseClient;

  constructor(private configService: ConfigService) {
    this.supabase = createClient(
      this.configService.get<string>("SUPABASE_URL"),
      this.configService.get<string>("SUPABASE_KEY"),
    );
  }

  async getPricing() {
    const { data, error } = await this.supabase
      .from("pricing_config")
      .select("*");

    if (error) throw new BadRequestException("Gagal mengambil data harga");

    return {
      status: "success",
      data,
    };
  }

  async updatePricing(updates: any[]) {
    // Expects array of { worker_type, price_per_day }
    // Loop through and update. UPSERT ideally.
    if (!Array.isArray(updates)) {
      throw new BadRequestException("Format data salah");
    }

    const { data, error } = await this.supabase
      .from("pricing_config")
      .upsert(updates, { onConflict: "worker_type" })
      .select();

    if (error)
      throw new BadRequestException(
        "Gagal memperbarui harga: " + error.message,
      );

    return {
      status: "success",
      pesan: "Harga berhasil diperbarui",
      data,
    };
  }
}
