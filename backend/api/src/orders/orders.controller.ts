import {
  Controller,
  Get,
  Post,
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

@Controller("orders")
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
   * Get order by ID (public)
   */
  @Get(":id")
  async getOrderById(@Param("id") id: string) {
    return this.ordersService.getOrderById(id);
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
}
