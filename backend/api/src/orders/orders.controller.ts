import {
  Controller,
  Get,
  Post,
  Patch,
  Put,
  Delete,
  Body,
  Param,
  Req,
  UnauthorizedException,
  ForbiddenException,
} from "@nestjs/common";
import { OrdersService } from "./orders.service";
import { CreateOrderDto } from "./dto/create-order.dto";
import { UpdateOrderDto } from "./dto/update-order.dto";
import { UsersService } from "../users/users.service";

@Controller("api/orders")
export class OrdersController {
  constructor(
    private readonly ordersService: OrdersService,
    private readonly usersService: UsersService,
  ) {}

  /**
   * Helper to extract user from JWT
   */
  private async getUserFromRequest(req: any) {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throw new UnauthorizedException("Missing Authorization header");
    }
    const token = authHeader.replace("Bearer ", "");
    return this.usersService.extractUserFromToken(token);
  }

  /**
   * Create order (lowongan) - Only farmer/warehouse can create
   */
  @Post()
  async createOrder(@Req() req, @Body() createOrderDto: CreateOrderDto) {
    const user = await this.getUserFromRequest(req);

    // Check role - only farmer or warehouse can create orders
    await this.usersService.checkRole(user.id, ["farmer", "warehouse"]);

    return this.ordersService.createOrder(user.id, createOrderDto);
  }

  /**
   * Get all orders (public)
   */
  @Get()
  async getOrders() {
    return this.ordersService.getOrders();
  }

  /**
   * Get my orders (requires auth)
   */
  @Get("my")
  async getMyOrders(@Req() req) {
    const user = await this.getUserFromRequest(req);
    return this.ordersService.getMyOrders(user.id);
  }

  /**
   * Get worker activities (applied jobs)
   */
  @Get("activities")
  async getActivities(@Req() req) {
    const user = await this.getUserFromRequest(req);
    // Role check optional but good practice
    // await this.usersService.checkRole(user.id, ["worker"]);
    return this.ordersService.getAppliedJobs(user.id);
  }

  /**
   * Get order by ID (Restricted)
   * - Worker/Ojek: Allowed
   * - Employer: Allowed ONLY if owner
   */
  @Get(":id")
  async getOrderById(@Req() req, @Param("id") id: string) {
    // 1. Authenticate
    const user = await this.getUserFromRequest(req);

    // 2. Fetch Order (Pass viewer ID and Role for context)
    const response = await this.ordersService.getOrderById(
      id,
      user.id,
      user.role,
    );
    const order = response.data;

    // 3. RBAC Logic
    // Allow: Workers and Ojek
    if (user.role === "worker" || user.role === "ojek") {
      return response;
    }

    // Allow: Employer (Farmer/Warehouse) IF they are the owner
    // Note: order.employer might be an object due to join, but employer_id is the FK
    if (
      (user.role === "farmer" ||
        user.role === "petani" ||
        user.role === "warehouse") &&
      order.employer_id === user.id
    ) {
      return response;
    }

    // Default: Deny
    throw new ForbiddenException(
      "Anda tidak memiliki akses untuk melihat lowongan ini",
    );
  }

  /**
   * Update order - Only owner can update
   */
  @Put(":id")
  async updateOrder(
    @Req() req,
    @Param("id") id: string,
    @Body() updateOrderDto: UpdateOrderDto,
  ) {
    const user = await this.getUserFromRequest(req);
    return this.ordersService.updateOrder(user.id, id, updateOrderDto);
  }

  /**
   * Delete order - Only owner can delete
   */
  @Delete(":id")
  async deleteOrder(@Req() req, @Param("id") id: string) {
    const user = await this.getUserFromRequest(req);
    return this.ordersService.deleteOrder(user.id, id);
  }

  /**
   * Apply to order - Only workers can apply
   */
  @Post(":id/apply")
  async applyToOrder(@Req() req, @Param("id") id: string) {
    const user = await this.getUserFromRequest(req);

    // Check role - only workers can apply
    await this.usersService.checkRole(user.id, ["worker"]);

    return this.ordersService.applyToOrder(user.id, id);
  }

  /**
   * Get queue for an order (view applicants)
   */
  @Get(":id/queue")
  async getQueue(@Req() req, @Param("id") id: string) {
    const user = await this.getUserFromRequest(req);
    return this.ordersService.getQueue(user.id, id);
  }

  /**
   * Accept an applicant
   */
  @Post(":id/applications/:workerId/accept")
  async acceptApplicant(
    @Req() req,
    @Param("id") orderId: string,
    @Param("workerId") workerId: string,
  ) {
    const user = await this.getUserFromRequest(req);
    return this.ordersService.acceptApplication(user.id, orderId, workerId);
  }

  /**
   * Close a job (only possible if no accepted workers)
   */
  @Patch(":id/close")
  async closeOrder(@Req() req, @Param("id") id: string) {
    const user = await this.getUserFromRequest(req);
    // Role check
    await this.usersService.checkRole(user.id, [
      "farmer",
      "petani",
      "warehouse",
    ]);
    return this.ordersService.closeOrder(user.id, id);
  }

  /**
   * Reject all applicants and close job
   */
  @Post(":id/reject-all")
  async rejectAllAndClose(@Req() req, @Param("id") id: string) {
    const user = await this.getUserFromRequest(req);
    // Role check
    await this.usersService.checkRole(user.id, [
      "farmer",
      "petani",
      "warehouse",
    ]);
    return this.ordersService.rejectAllAndClose(user.id, id);
  }
}
