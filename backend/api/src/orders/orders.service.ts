import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { CreateOrderDto } from "./dto/create-order.dto";
import { UpdateOrderDto } from "./dto/update-order.dto";

@Injectable()
export class OrdersService {
  private supabase: SupabaseClient;

  constructor(private configService: ConfigService) {
    this.supabase = createClient(
      this.configService.get<string>("SUPABASE_URL"),
      this.configService.get<string>("SUPABASE_KEY"),
    );
  }

  async createOrder(userId: string, dto: CreateOrderDto) {
    // 1. Verify User Role (Must be petani or warehouse)
    // Note: RLS handles this too, but API should fail fast
    const { data: user } = await this.supabase
      .from("users")
      .select("role")
      .eq("id", userId)
      .single();

    if (!user || (user.role !== "farmer" && user.role !== "warehouse")) {
      throw new ForbiddenException(
        "Hanya petani dan gudang yang bisa membuat lowongan",
      );
    }

    // 2. Insert Order
    const { data: order, error } = await this.supabase
      .from("orders")
      .insert({
        employer_id: userId,
        worker_type: dto.workerType,
        worker_count: dto.workerCount,
        description: dto.description,
        location: dto.location,
        job_date: dto.jobDate,
        status: "open",
        latitude: dto.latitude,
        longitude: dto.longitude,
        map_url: dto.mapUrl,
      })
      .select()
      .single();

    if (error) {
      throw new BadRequestException("Gagal membuat lowongan: " + error.message);
    }

    return {
      status: "success",
      pesan: "Lowongan berhasil dibuat",
      data: order,
    };
  }

  async getOrders() {
    // Public endpoint: Fetch all OPEN orders within next 7 days

    // 1. Calculate time window
    const today = new Date();
    today.setHours(0, 0, 0, 0); // Start of today

    const nextWeek = new Date(today);
    nextWeek.setDate(today.getDate() + 7); // 7 days window
    nextWeek.setHours(23, 59, 59, 999); // End of 7th day

    const { data, error } = await this.supabase
      .from("orders")
      .select("*, employer:users(name, location, phone)") // Using Supabase join if FK setup/inferred
      .eq("status", "open")
      .gte("job_date", today.toISOString())
      .lte("job_date", nextWeek.toISOString())
      .order("job_date", { ascending: true }); // Order by job info relevance (sooner first)

    if (error) {
      throw new BadRequestException("Gagal mengambil data lowongan");
    }

    return {
      status: "success",
      data: data,
    };
  }

  async getMyOrders(userId: string) {
    const { data, error } = await this.supabase
      .from("orders")
      .select("*, order_applications(count)")
      .eq("employer_id", userId)
      .order("created_at", { ascending: false });

    if (error) {
      throw new BadRequestException("Gagal mengambil data lowongan saya");
    }

    // Transform data to include current_queue from count
    const transformedData = data?.map((order) => ({
      ...order,
      current_queue: order.order_applications?.[0]?.count ?? 0,
      // Remove the nested structure to keep response clean
      order_applications: undefined,
    }));

    return { status: "success", data: transformedData };
  }

  async getOrderById(id: string) {
    const { data, error } = await this.supabase
      .from("orders")
      .select("*, employer:users(name, phone)")
      .eq("id", id)
      .single();

    if (error || !data) {
      throw new NotFoundException("Lowongan tidak ditemukan");
    }

    return { status: "success", data };
  }

  async updateOrder(userId: string, orderId: string, dto: UpdateOrderDto) {
    // Construct payload mapping camelCase DTO to snake_case DB columns
    const payload = {
      ...(dto.status && { status: dto.status }),
      ...(dto.workerCount && { worker_count: dto.workerCount }),
      ...(dto.description && { description: dto.description }),
      ...(dto.location && { location: dto.location }),
      ...(dto.jobDate && { job_date: dto.jobDate }),
      ...(dto.latitude && { latitude: dto.latitude }),
      ...(dto.longitude && { longitude: dto.longitude }),
      ...(dto.mapUrl && { map_url: dto.mapUrl }),
    };

    const { data, error } = await this.supabase
      .from("orders")
      .update(payload)
      .eq("id", orderId)
      .eq("employer_id", userId) // Security check
      .select()
      .single();

    if (error) {
      throw new BadRequestException(
        "Gagal memperbarui lowongan: " + error.message,
      );
    }

    return { status: "success", pesan: "Lowongan berhasil diperbarui", data };
  }

  async deleteOrder(userId: string, orderId: string) {
    const { error } = await this.supabase
      .from("orders")
      .delete()
      .eq("id", orderId)
      .eq("employer_id", userId);

    if (error) {
      throw new BadRequestException("Gagal menghapus lowongan");
    }

    return { status: "success", pesan: "Lowongan berhasil dihapus" };
  }

  async applyToOrder(workerId: string, orderId: string) {
    // Check if order exists and is open
    const { data: order, error: orderError } = await this.supabase
      .from("orders")
      .select("*")
      .eq("id", orderId)
      .eq("status", "open")
      .single();

    if (orderError || !order) {
      throw new NotFoundException(
        "Lowongan tidak ditemukan atau sudah ditutup",
      );
    }

    // Check if already applied
    const { data: existing } = await this.supabase
      .from("order_applications")
      .select("id")
      .eq("order_id", orderId)
      .eq("worker_id", workerId)
      .maybeSingle();

    if (existing) {
      throw new BadRequestException("Anda sudah melamar lowongan ini");
    }

    // Insert application
    const { data: application, error } = await this.supabase
      .from("order_applications")
      .insert({
        order_id: orderId,
        worker_id: workerId,
        status: "pending",
      })
      .select()
      .single();

    if (error) {
      throw new BadRequestException("Gagal melamar: " + error.message);
    }

    return {
      status: "success",
      pesan: "Lamaran berhasil dikirim",
      data: application,
    };
  }

  async getQueue(userId: string, orderId: string) {
    console.log("[getQueue] orderId:", orderId, "userId:", userId);

    // 1. Check if order exists
    const { data: order, error: orderError } = await this.supabase
      .from("orders")
      .select("employer_id")
      .eq("id", orderId)
      .single();

    if (orderError || !order) {
      console.log("[getQueue] Order not found:", orderError);
      throw new NotFoundException("Lowongan tidak ditemukan");
    }

    // 2. Fetch applications with worker details
    const { data, error } = await this.supabase
      .from("order_applications")
      .select(
        "id, order_id, worker_id, status, created_at, worker:worker_id(id, name, phone, email, photo_url)",
      )
      .eq("order_id", orderId)
      .order("created_at", { ascending: true });

    console.log("[getQueue] Query result:", { data, error });

    if (error) {
      console.log("[getQueue] Error:", error.message);
      throw new BadRequestException(
        "Gagal mengambil data antrian: " + error.message,
      );
    }

    return {
      status: "success",
      data: data,
    };
  }

  async acceptApplication(
    employerId: string,
    orderId: string,
    workerId: string,
  ) {
    // 1. Verify verify order ownership
    const { data: order, error: orderError } = await this.supabase
      .from("orders")
      .select("id")
      .eq("id", orderId)
      .eq("employer_id", employerId)
      .single();

    if (orderError || !order) {
      throw new ForbiddenException("Anda tidak memiliki akses ke lowongan ini");
    }

    // 2. Update Application Status to 'accepted'
    const { data, error } = await this.supabase
      .from("order_applications")
      .update({ status: "accepted" })
      .eq("order_id", orderId)
      .eq("worker_id", workerId)
      .select()
      .single();

    if (error) {
      throw new BadRequestException("Gagal menerima pelamar: " + error.message);
    }

    return {
      status: "success",
      pesan: "Pelamar berhasil diterima",
      data: data,
    };
  }
}
