import { Controller, Get } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { createClient } from "@supabase/supabase-js";

@Controller("api")
export class AppController {
  constructor(private configService: ConfigService) {}

  @Get("health")
  async healthCheck() {
    // Basic health check
    const supabaseUrl = this.configService.get<string>("SUPABASE_URL");
    const supabaseKey = this.configService.get<string>("SUPABASE_KEY");

    let dbStatus = "unknown";

    if (supabaseUrl && supabaseKey) {
      try {
        const supabase = createClient(supabaseUrl, supabaseKey);
        const { error } = await supabase.from("users").select("id").limit(1);
        dbStatus = error ? "error: " + error.message : "connected";
      } catch (e) {
        dbStatus = "error: " + String(e);
      }
    } else {
      dbStatus = "missing env vars";
    }

    return {
      status: "ok",
      timestamp: new Date().toISOString(),
      database: dbStatus,
      environment: process.env.NODE_ENV || "development",
    };
  }
}
