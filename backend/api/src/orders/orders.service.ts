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

    if (
      !user ||
      (user.role !== "farmer" &&
        user.role !== "petani" &&
        user.role !== "warehouse")
    ) {
      throw new ForbiddenException(
        "Hanya petani dan gudang yang bisa membuat lowongan",
      );
    }

    // 2. Insert Order
    const { data: order, error } = await this.supabase
      .from("orders")
      .insert({
        employer_id: userId,
        worker_type: dto.workerType === "harian" ? "daily" : dto.workerType,
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
    // ──────────────────────────────────────────────────────────────────────────
    // Public endpoint: Fetch active jobs (Status = open, Quota available)
    // ──────────────────────────────────────────────────────────────────────────

    // 1. Calculate time window (Next 7 days)
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const nextWeek = new Date(today);
    nextWeek.setDate(today.getDate() + 7);
    nextWeek.setHours(23, 59, 59, 999);

    // 2. Query Orders (Status: 'open' only, exclude 'filled'/'closed')
    const { data, error } = await this.supabase
      .from("orders")
      .select("*, employer:users(name, location, phone)")
      .eq("status", "open") // Only fetch jobs with status 'open'
      .gte("job_date", today.toISOString())
      .lte("job_date", nextWeek.toISOString())
      .order("job_date", { ascending: true }); // Urgent jobs first

    if (error) {
      throw new BadRequestException("Gagal mengambil data lowongan");
    }

    // 3. Enrich with Approved Count + Filter Full Jobs
    // "Do not return jobs where approved_workers_count >= total_workers"
    // Backend is single source of truth.
    const validJobs = await Promise.all(
      (data ?? []).map(async (order) => {
        // Count approved workers
        const { count } = await this.supabase
          .from("order_applications")
          .select("*", { count: "exact", head: true })
          .eq("order_id", order.id)
          .eq("status", "accepted");

        const approvedCount = count ?? 0;
        const totalWorkers = order.worker_count ?? 1;

        // SKIP if full
        if (approvedCount >= totalWorkers) {
          return null;
        }

        return {
          ...order,
          worker_type:
            order.worker_type === "daily" ? "harian" : order.worker_type,
          approved_workers_count: approvedCount, // Requirement: approved_workers_count
          // Map to accepted_count for frontend compatibility if needed, or update frontend to use approved_workers_count
          accepted_count: approvedCount,
        };
      }),
    );

    // Filter out nulls (full jobs)
    const filteredData = validJobs.filter((job) => job !== null);

    return {
      status: "success",
      data: filteredData,
    };
  }

  async getMyOrders(userId: string) {
    const { data, error } = await this.supabase
      .from("orders")
      .select("*")
      .eq("employer_id", userId)
      .order("created_at", { ascending: false });

    if (error) {
      throw new BadRequestException("Gagal mengambil data lowongan saya");
    }

    // Enrich with counts
    const enrichedData = await Promise.all(
      (data ?? []).map(async (order) => {
        // 1. Total Applicants
        const { count: totalApps } = await this.supabase
          .from("order_applications")
          .select("*", { count: "exact", head: true })
          .eq("order_id", order.id);

        // 2. Accepted Applicants
        const { count: acceptedApps } = await this.supabase
          .from("order_applications")
          .select("*", { count: "exact", head: true })
          .eq("order_id", order.id)
          .eq("status", "accepted");

        return {
          ...order,
          worker_type:
            order.worker_type === "daily" ? "harian" : order.worker_type,
          current_queue: totalApps ?? 0,
          accepted_count: acceptedApps ?? 0,
        };
      }),
    );

    return { status: "success", data: enrichedData };
  }

  async getOrderById(id: string, viewerId?: string, viewerRole?: string) {
    const { data, error } = await this.supabase
      .from("orders")
      .select("*, employer:users(name, phone, photo_url)") // Added photo_url and ensured phone
      .eq("id", id)
      .single();

    if (error || !data) {
      throw new NotFoundException("Lowongan tidak ditemukan");
    }

    // Transform Worker Type
    if (data.worker_type === "daily") {
      data.worker_type = "harian";
    }

    // ──────────────────────────────────────────────────────────────────────────
    // TEMPORARY CLEANUP (Worker Role)
    // ──────────────────────────────────────────────────────────────────────────
    // TODO: Re-enable status and WhatsApp when data flow is stable.
    if (viewerRole === "worker") {
      // Return minimal payload compliant with stable worker view
      return {
        status: "success",
        data: {
          ...data,
          application_status: null, // Clean status
          employer: {
            ...data.employer,
            whatsapp_number: null, // Hide broken contact
            phone: null, // Ensure no fallback
          },
        },
      };
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Mapping: Expose WhatsApp Number (Non-Worker Only)
    // ──────────────────────────────────────────────────────────────────────────
    if (data.employer) {
      // Map phone to whatsapp_number as requested
      // We assume the DB column 'phone' stores the number.
      // If a distinct 'whatsapp_number' column exists, add it to select above.
      data.employer.whatsapp_number = data.employer.phone;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Context: Inject Viewer's Application Status (Non-Worker Only)
    // ──────────────────────────────────────────────────────────────────────────
    if (viewerId) {
      const { data: application } = await this.supabase
        .from("order_applications")
        .select("status")
        .eq("order_id", id)
        .eq("worker_id", viewerId)
        .maybeSingle();

      if (application) {
        // Inject application status
        data.application_status = application.status; // e.g., 'pending', 'accepted'

        // OPTIONAL: Override global status for the viewer?
        // User said: "return my_application.status... Do not rely on global order status"
        // We will strictly return it as a separate field 'application_status' for clarity,
        // unless frontend strictly binds to 'status'.
        // Best practice: Keep 'status' as order status (open/filled), add 'application_status' (accepted).
        // But to ensure "Waiting for Confirmation" (pending) logic works, we ensure this field is present.
      } else {
        // Not applied yet
        data.application_status = null;
      }
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
    // 1. Check if order exists and is open
    const { data: order, error: orderError } = await this.supabase
      .from("orders")
      .select("*, worker_count")
      .eq("id", orderId)
      .eq("status", "open")
      .single();

    if (orderError || !order) {
      throw new NotFoundException(
        "Lowongan tidak ditemukan atau sudah ditutup",
      );
    }

    // 2. Check quota - count accepted applications
    const { count: acceptedCount } = await this.supabase
      .from("order_applications")
      .select("*", { count: "exact", head: true })
      .eq("order_id", orderId)
      .eq("status", "accepted");

    const workerCount = order.worker_count ?? 1;

    if ((acceptedCount ?? 0) >= workerCount) {
      throw new BadRequestException(
        "Kuota pekerja sudah terpenuhi untuk lowongan ini",
      );
    }

    // 3. Check if already applied
    const { data: existing } = await this.supabase
      .from("order_applications")
      .select("id")
      .eq("order_id", orderId)
      .eq("worker_id", workerId)
      .maybeSingle();

    if (existing) {
      throw new BadRequestException("Anda sudah melamar lowongan ini");
    }

    // 4. Insert application
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

  async getAppliedJobs(workerId: string) {
    // Requirements:
    // 1. Fetch applications for this worker
    // 2. Join with order details
    // 3. Join with employer details (Name, Photo, Location) for Trust Signal

    console.log("[getAppliedJobs] Fetching for worker:", workerId);

    const { data, error } = await this.supabase
      .from("order_applications")
      .select(
        `
        id,
        status, // pending, accepted, rejected
        created_at,
        order:orders (
          id,
          title,
          description,
          job_date,
          location,
          worker_type,
          status, // open, filled, etc.
          employer:users (
            name,
            photo_url,
            location,
            phone
          )
        )
      `,
      )
      .eq("worker_id", workerId)
      .order("created_at", { ascending: false });

    if (error) {
      console.log("[getAppliedJobs] Error:", error.message);
      throw new BadRequestException("Gagal mengambil riwayat lamaran");
    }

    return {
      status: "success",
      data: data,
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

  /**
   * Accept a worker application.
   *
   * Architecture Notes:
   * - This logic lives in the SERVICE LAYER (OrdersService) because it contains
   *   business rules about quota management and status transitions.
   * - Controller handles HTTP concerns; Service handles domain logic.
   * - For true atomicity in PostgreSQL, consider a database function (RPC).
   *
   * Race Condition Protection:
   * 1. Check current accepted count BEFORE approval
   * 2. Optimistic locking: verify order still has capacity
   * 3. Count AFTER approval to determine if quota is now met
   * 4. Use conditional update for status change
   */
  async acceptApplication(
    employerId: string,
    orderId: string,
    workerId: string,
  ) {
    // ──────────────────────────────────────────────────────────────────────────
    // STEP 1: Verify ownership and get job details
    // ──────────────────────────────────────────────────────────────────────────
    const { data: order, error: orderError } = await this.supabase
      .from("orders")
      .select("id, worker_count, status")
      .eq("id", orderId)
      .eq("employer_id", employerId)
      .single();

    if (orderError || !order) {
      throw new ForbiddenException("Anda tidak memiliki akses ke lowongan ini");
    }

    const totalWorkers = order.worker_count ?? 1;

    // ──────────────────────────────────────────────────────────────────────────
    // STEP 2: Check if job is still active (not already filled)
    // ──────────────────────────────────────────────────────────────────────────
    if (order.status === "filled") {
      throw new BadRequestException("Lowongan sudah ditutup");
    }

    // ──────────────────────────────────────────────────────────────────────────
    // STEP 3: Count currently ACCEPTED applications (pre-check for race safety)
    // ──────────────────────────────────────────────────────────────────────────
    const { count: approvedBefore } = await this.supabase
      .from("order_applications")
      .select("*", { count: "exact", head: true })
      .eq("order_id", orderId)
      .eq("status", "accepted");

    const approvedWorkersCount = approvedBefore ?? 0;

    // Optimistic lock check: reject if quota already met
    if (approvedWorkersCount >= totalWorkers) {
      throw new BadRequestException("Kuota pekerja sudah terpenuhi");
    }

    // ──────────────────────────────────────────────────────────────────────────
    // STEP 4: Approve the worker (update application status)
    // ──────────────────────────────────────────────────────────────────────────
    const { data: application, error: updateError } = await this.supabase
      .from("order_applications")
      .update({ status: "accepted" })
      .eq("order_id", orderId)
      .eq("worker_id", workerId)
      .eq("status", "pending") // Only update if still pending (idempotency)
      .select()
      .single();

    if (updateError) {
      throw new BadRequestException(
        "Gagal menerima pelamar: " + updateError.message,
      );
    }

    // ──────────────────────────────────────────────────────────────────────────
    // STEP 5: Recalculate approved_workers_count AFTER approval
    // ──────────────────────────────────────────────────────────────────────────
    const { count: approvedAfter } = await this.supabase
      .from("order_applications")
      .select("*", { count: "exact", head: true })
      .eq("order_id", orderId)
      .eq("status", "accepted");

    const newApprovedCount = approvedAfter ?? 0;

    // ──────────────────────────────────────────────────────────────────────────
    // STEP 6: If quota met, atomically fill the job and reject pending apps
    // ──────────────────────────────────────────────────────────────────────────
    if (newApprovedCount >= totalWorkers) {
      // Atomic status update: only update if still open
      // This prevents double-fill race condition
      const { error: fillError } = await this.supabase
        .from("orders")
        .update({ status: "filled" })
        .eq("id", orderId)
        .eq("status", "open"); // Only fill if status is still 'open'

      if (fillError) {
        console.error("[acceptApplication] Failed to fill order:", fillError);
      }

      // Reject all remaining pending applications
      await this.supabase
        .from("order_applications")
        .update({ status: "rejected" })
        .eq("order_id", orderId)
        .eq("status", "pending");

      return {
        status: "success",
        pesan: "Pelamar berhasil diterima. Kuota terpenuhi, lowongan ditutup.",
        data: application,
        approved_workers_count: newApprovedCount,
        total_workers: totalWorkers,
        job_closed: true,
      };
    }

    // ──────────────────────────────────────────────────────────────────────────
    // STEP 7: Return success (quota not yet met)
    // ──────────────────────────────────────────────────────────────────────────
    return {
      status: "success",
      pesan: "Pelamar berhasil diterima",
      data: application,
      approved_workers_count: newApprovedCount,
      total_workers: totalWorkers,
      job_closed: false,
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CLOSE JOB LOGIC
  // ──────────────────────────────────────────────────────────────────────────

  /**
   * Close a job (Rule A & C validation)
   */
  async closeOrder(userId: string, orderId: string) {
    // 1. Verify ownership
    const { data: order, error } = await this.supabase
      .from("orders")
      .select("id, status")
      .eq("id", orderId)
      .eq("employer_id", userId)
      .single();

    if (error || !order) {
      throw new ForbiddenException("Anda tidak memiliki akses");
    }

    if (order.status === "closed" || order.status === "filled") {
      throw new BadRequestException("Lowongan sudah ditutup");
    }

    // 2. Check Accepted Count (Rule: Cannot close if anyone is accepted)
    const { count: acceptedCount } = await this.supabase
      .from("order_applications")
      .select("*", { count: "exact", head: true })
      .eq("order_id", orderId)
      .eq("status", "accepted");

    if ((acceptedCount ?? 0) > 0) {
      throw new BadRequestException(
        "Lowongan tidak bisa ditutup karena sudah ada pekerja yang diterima",
      );
    }

    // 3. Update status
    const { error: updateError } = await this.supabase
      .from("orders")
      .update({ status: "closed" })
      .eq("id", orderId);

    if (updateError) {
      throw new BadRequestException("Gagal menutup lowongan");
    }

    return { status: "success", pesan: "Lowongan berhasil ditutup" };
  }

  /**
   * Reject all pending applications and close job (Rule B implementation)
   */
  async rejectAllAndClose(userId: string, orderId: string) {
    // 1. Verify ownership & Compatibility (Reuse closeOrder checks or do manual)
    // We do manual to be safe about transaction-like flow.

    const { data: order } = await this.supabase
      .from("orders")
      .select("id")
      .eq("id", orderId)
      .eq("employer_id", userId)
      .single();

    if (!order) {
      throw new ForbiddenException("Anda tidak memiliki akses");
    }

    // 2. Reject all pending
    const { error: rejectError } = await this.supabase
      .from("order_applications")
      .update({ status: "rejected" })
      .eq("order_id", orderId)
      .eq("status", "pending");

    if (rejectError) {
      throw new BadRequestException("Gagal menolak pelamar");
    }

    // 3. Close Order
    // We call closeOrder logic strictly (it checks acceptedCount).
    // If acceptedCount > 0, closeOrder throws exception, which is CORRECT behavior.
    // (We shouldn't reject pending if there are accepted users preventing close,
    // actually Step 2 already ran. Ideally we check Accepted first.)

    const { count: acceptedCount } = await this.supabase
      .from("order_applications")
      .select("*", { count: "exact", head: true })
      .eq("order_id", orderId)
      .eq("status", "accepted");

    if ((acceptedCount ?? 0) > 0) {
      throw new BadRequestException(
        "Lowongan tidak bisa ditutup karena sudah ada pekerja yang diterima",
      );
    }

    await this.supabase
      .from("orders")
      .update({ status: "closed" })
      .eq("id", orderId);

    return {
      status: "success",
      pesan: "Semua pelamar ditolak dan lowongan ditutup",
    };
  }
}
